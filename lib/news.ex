defmodule News do

  use Provider

  @news_url "http://feeds.bbci.co.uk/news/world/rss.xml?edition=uk"

  def get_news() do
    case download(@news_url) do
      {:ok, body} -> body |> ElixirFeedParser.parse |> marshal |> Poison.encode! |> to_string |> success
      {:error, message} -> bad_gateway(message)
    end
  end



  defp marshal(feed) do
    Enum.map(feed.entries, fn(f) -> %{:title=>f.title, :detail=>f.description} end)
  end
  
end