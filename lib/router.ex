defmodule Router do

  use Plug.Router

  plug :match
  plug :dispatch

  get "/news", do: route(conn, News.get_news())
  get "/buses", do: route(conn, Buses.get_buses())
  get "/", do: send_resp(conn, 200, "Welcome")
  match _, do: send_resp(conn, 404, "Oops!")

  def route(conn, response) do
    {status, body} = response
    send_resp(conn, status, body)
  end
  
end