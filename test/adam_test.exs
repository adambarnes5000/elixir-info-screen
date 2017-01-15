defmodule AdamTest do
  use ExUnit.Case
  doctest InfoServer

  test "start" do
    InfoServer.start()
  end


end
