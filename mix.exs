defmodule Condet.Mixfile do
  use Mix.Project

  def project do
    [app: :condet,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     escript: [main_module: Condet],
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :ecto, :postgrex, :geoip, :geocalc, :asn],
     mod: {Condet, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:postgrex, ">= 0.12.0"},
     {:ecto, "~> 2.0.5"},
     {:geoip, "~> 0.1"},
     {:geocalc, "~> 0.5"},
     {:asn, ">= 0.1.0"}]
  end
end
