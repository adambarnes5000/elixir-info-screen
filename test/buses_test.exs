defmodule BusesTest do
  use ExUnit.Case
  doctest Buses

  test "start" do
    {status, body} = Buses.get_buses()
    assert status == 200
    assert String.length(body) >0
    IO.puts body
  end


end
