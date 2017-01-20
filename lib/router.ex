defmodule Router do

  use Plug.Router

  plug Plug.Logger
  plug :match
  plug :dispatch

  get "/news", do: route(conn, News.get_news())

  get "/buses", do: route(conn, Buses.get_buses())

  get "/alarms", do: route(conn, Alarms.get_alarms())
  get "/nextalarm", do: route(conn, Alarms.get_next_alarm())
  get "/holidays", do: route(conn, Alarms.get_holidays())

  post "/alarms", do: route(conn, Alarms.save_alarms(read_body(conn) |> elem(1)))
  post "/holidays", do: route(conn, Alarms.save_holidays(read_body(conn) |> elem(1)))


  get "/", do: send_resp(conn, 200, "Welcome")
  match _, do: send_resp(conn, 404, "Oops!")

  def route(conn, response) do
    {status, body} = response
    send_resp(conn, status, body)
  end
  
end