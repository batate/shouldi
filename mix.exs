defmodule Shouldi.Mixfile do
  use Mix.Project

  def project do
    [app: :shouldi,
     version: "0.2.2",
     elixir: "~> 1.0",
     deps: deps,
     name: "ShouldI",
     source_url: "https://github.com/batate/shouldi",
     docs: fn ->
       {ref, 0} = System.cmd("git", ["rev-parse", "--verify", "--quiet", "HEAD"])
       [source_ref: ref, main: "README", readme: "README.md"]
     end,
     description: "Elixir testing libraries with support for nested contexts",
     package: package]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:poison, []},
     {:ex_doc, only: :dev},
     {:earmark, only: :dev}]
  end

  defp package do
    [contributors: ["Bruce Tate", "Eric Meadows-Jönsson"],
     licenses: ["Apache 2.0"],
     links: %{"Github" => "https://github.com/batate/shouldi"}]
  end
end
