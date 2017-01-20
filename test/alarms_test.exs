defmodule AlarmsTest do
  use ExUnit.Case
  doctest Buses

  @alarms [["07:25", "WORKDAY"],["09:30","WEEKEND"]]
  @alarms2 [["07:25", "WORKDAY"]]
  @holidays [["2017-02-06"]]

  test "get next alarm" do
    assert Alarms.get_next_alarm() |> elem(1) == "Monday 07:25"
  end

  test "get next alarm for day" do
    assert Alarms.get_next_alarm_for_day(d("2017-01-19 05:00:00"), @alarms, @holidays) == "07:25"
    assert Alarms.get_next_alarm_for_day(d("2017-01-19 08:00:00"), @alarms, @holidays) == nil
    assert Alarms.get_next_alarm_for_day(d("2017-01-21 08:00:00"), @alarms, @holidays) == "09:30"
  end

  test "get next alarm for time" do
    assert Alarms.get_next_alarm(d("2017-01-19 05:00:00"), @alarms, @holidays) == "Today 07:25"
    assert Alarms.get_next_alarm(d("2017-01-19 12:00:00"), @alarms, @holidays) == "Tomorrow 07:25"
    assert Alarms.get_next_alarm(d("2017-01-20 12:00:00"), @alarms, @holidays) == "Tomorrow 09:30"
    assert Alarms.get_next_alarm(d("2017-01-20 12:00:00"), @alarms2, @holidays) == "Monday 07:25"
    assert Alarms.get_next_alarm(d("2017-02-04 12:00:00"), @alarms2, @holidays) == "Tuesday 07:25"
    assert Alarms.get_next_alarm(d("2017-02-04 12:00:00"), [], @holidays) == "-"
  end

  test "get day type" do
    assert Alarms.get_day_type(d("2017-01-19 08:00:00") , @holidays)=="WORKDAY"
    assert Alarms.get_day_type(d("2017-01-21 08:00:00") , @holidays)=="WEEKEND"
    assert Alarms.get_day_type(d("2017-02-06 08:00:00") , @holidays)=="WEEKEND"
  end

  test "holidays" do
    Alarms.get_holidays() |> elem(1) |> Alarms.save_holidays
  end

  def d(s) do
    Timex.parse!(s, "{YYYY}-{0M}-{0D} {h24}:{m}:{s}" )
  end

end
