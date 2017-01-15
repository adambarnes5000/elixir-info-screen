defmodule InfoServer do

  def main(_args) do
    children = [
      Plug.Adapters.Cowboy.child_spec(:http, Router, [])
    ]
    Supervisor.start_link(children, strategy: :one_for_one)
    IO.puts "Running"
    :timer.sleep(:infinity)
  end

end