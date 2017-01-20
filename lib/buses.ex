import Map, only: [get: 2]
import Enum, only: [filter: 2, map: 2]
import String, only: [slice: 3]

defmodule Buses do

  use Provider

  def get_buses() do
    with {:ok, buses1} <- get_buses_for_stop(753, "39A"),
         {:ok, buses2} <- get_buses_for_stop(781, "18") do
       buses1++buses2 |> Poison.encode! |> to_string |> success
    else
      {:error, message} -> bad_gateway(message)
    end
  end

  def get_buses_for_stop(stop_id, route) do
    case download("https://data.dublinked.ie/cgi-bin/rtpi/realtimebusinformation?stopid=#{stop_id}&format=json") do
          {:ok, body} -> buses = body |> Poison.decode! |> marshal |> only_route(route)
                         {:ok, buses}
          {:error, message} -> {:error, message}
    end
  end

  defp marshal(data) do
    map(get(data,"results"), &(%{:route=>&1["route"], :destination=>&1["destination"], :time=>slice(&1["departuredatetime"],-8,5)}))
  end

  defp only_route(data, route) do
    filter(data, &(&1.route==route))
  end
  
end