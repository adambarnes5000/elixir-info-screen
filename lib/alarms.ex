import Enum, only: [member?: 2, filter: 2, at: 2]

defmodule Alarms do

  use Provider

  def get_next_alarm(_, [], _) do
    "-"
  end

  def get_next_alarm(date_time, alarms, holidays) do
    get_next_alarm(date_time, alarms, holidays, 0)
  end

  def get_next_alarm(date_time, alarms, holidays, offset) do
    day = case offset do
              0 -> date_time
              _ -> date_time |> Timex.shift(days: 1) |> Timex.beginning_of_day
            end
    case get_next_alarm_for_day(day, alarms, holidays) do
      nil -> get_next_alarm(day, alarms, holidays,offset+1)
      time -> case offset do
                0 -> "Today #{time}"
                1 -> "Tomorrow #{time}"
                _ -> "#{Timex.format!(day, "{WDfull}")} #{time}"
              end
    end
  end

  def get_next_alarm_for_day(date_time, alarms, holidays) do
    case get_remaining_alarms(date_time, alarms, holidays) do
      [] -> nil
      list -> Enum.sort(list) |> hd |> at(0)
    end
  end

  def get_remaining_alarms(date_time, alarms, holidays) do
    date_time |> filter_out_invalid_days(alarms, holidays) |> filter_out_past_alarms(date_time)
  end

  def get_day_type(date_time, holidays)  do
    date_str = Timex.format!(date_time, "{YYYY}-{0M}-{0D}")
    if member?(holidays, [date_str]) do
      "WEEKEND"
    else
      case Timex.format!(date_time, "{WDshort}") do
        "Sat" -> "WEEKEND"
        "Sun" -> "WEEKEND"
        _ -> "WORKDAY"
      end
    end
  end

  def filter_out_invalid_days(date_time, alarms, holidays) do
    filter(alarms, fn(x) -> at(x,1)==get_day_type(date_time, holidays) || at(x,1)=="EVERYDAY" end)
  end

  def filter_out_past_alarms(alarms, date_time) do
    time_str = Timex.format!(date_time, "{ISOtime}")
    result = filter(alarms, fn(x)-> at(x,0)>time_str end)
    result
  end



end