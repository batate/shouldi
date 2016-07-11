defmodule Shouldi.Mixfile do
  use Mix.Project

  @version "0.3.2"

  def project do
    [app: :shouldi,
     version: @version,
     elixir: "~> 1.0",
     deps: deps(),
     name: "ShouldI",
     source_url: "https://github.com/batate/shouldi",
     docs: docs(),
     description: "Elixir testing libraries with support for nested contexts",
     package: package()]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:ex_doc, ">= 0.0.0", only: :dev},
     {:earmark, ">= 0.0.0", only: :dev}]
  end

  defp package do
    [maintainers: ["Bruce Tate", "Eric Meadows-Jönsson"],
     licenses: ["Apache 2.0"],
     links: %{"Github" => "https://github.com/batate/shouldi"}]
  end

  defp docs do
    [source_ref: "v" <> @version,
     main: "readme",
     extras: ["README.md"]]
  end
end
