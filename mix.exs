defmodule InfoServer.Mixfile do
  use Mix.Project

  def project do
    [app: :infoserver,
     version: "0.1.0",
     elixir: "~> 1.4",
     escript: [main_module: InfoServer],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :cowboy, :plug, :httpotion, :"elixir_feed_parser" , :timex]]
  end

    defp deps do
      [
        {:cowboy, "~> 1.0"},
        {:plug, "~> 1.0"},
        {:httpotion, "~> 3.0.2"},
        {:"elixir_feed_parser", "~> 0.0.1"},
        {:poison, "~> 3.0"},
        {:timex, "~> 3.0"},
        {:tzdata, "~> 0.1.8", override: true}
      ]
    end
end
