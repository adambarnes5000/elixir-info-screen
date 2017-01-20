import Enum, only: [sort: 1, filter: 2, at: 2]

defmodule Alarms do

  @alarms_file "/home/pi/Alarms/alarms.json"
  @holidays_file "/home/pi/Alarms/holidays.json"

  use Provider

  def get_alarms() do
    case File.read(@alarms_file) do
      {:ok, file} -> file |> success
      _ -> bad_gateway("Unable to open file #{@alarms_file}")
    end
  end

  def get_holidays() do
    case File.read(@holidays_file) do
      {:ok, file} -> file |> success
      _ -> bad_gateway("Unable to open file #{@holidays_file}")
    end
  end
  
  def save_holidays(holidays) do
    case File.write(@holidays_file, holidays) do
      :ok -> success("OK")
      {:error, reason} -> bad_gateway(reason)
    end
  end

  def save_alarms(alarms) do
    case File.write(@alarms_file, alarms) do
      :ok -> success("OK")
      {:error, reason} -> bad_gateway(reason)
    end
  end

  def get_next_alarm() do
    with  {200, alarms} <- get_alarms(),
          {200, holidays} <- get_holidays() do
            date_time = Timex.now()
            get_next_alarm(date_time,Poison.decode!(alarms),Poison.decode!(holidays)) |> success

    else
      _ -> bad_gateway("Unable to open data files")
    end

  end

  def get_next_alarm(_, [], _) do
    "-"
  end

  def get_next_alarm(date_time, alarms, holidays, counter \\ 0) do
    day = case counter do
              0 -> date_time
              _ -> date_time |> Timex.shift(days: 1) |> Timex.beginning_of_day
            end
    case get_next_alarm_for_day(day, alarms, holidays) do
      nil -> get_next_alarm(day, alarms, holidays,counter+1)
      time -> case counter do
                0 -> "Today #{time}"
                1 -> "Tomorrow #{time}"
                n when n<7 -> "#{Timex.format!(day, "{WDfull}")} #{time}"
                _ -> "#{Timex.format!(day, "{ISOdate}")} #{time}"
              end
    end
  end

  def get_next_alarm_for_day(date_time, alarms, holidays) do
    case get_remaining_alarms(date_time, alarms, holidays) do
      [] -> nil
      list -> sort(list) |> hd |> at(0)
    end
  end

  def get_remaining_alarms(date_time, alarms, holidays) do
    date_time |> filter_out_invalid_days(alarms, holidays) |> filter_out_past_alarms(date_time)
  end

  def get_day_type(date_time, holidays)  do
    date_str = Timex.format!(date_time, "{YYYY}-{0M}-{0D}")
    if [date_str] in holidays do
      "WEEKEND"
    else
      case Timex.format!(date_time, "{WDshort}") do
        day when day in ["Sat","Sun"] -> "WEEKEND"
        _ -> "WORKDAY"
      end
    end
  end

  def filter_out_invalid_days(date_time, alarms, holidays) do
    filter(alarms, &(at(&1,1)=="EVERYDAY" || at(&1,1)==get_day_type(date_time, holidays) ))
  end

  def filter_out_past_alarms(alarms, date_time) do
    time_str = Timex.format!(date_time, "{ISOtime}")
    filter(alarms, &(at(&1,0)>time_str))
  end


end