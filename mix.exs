defmodule Doctor.MixProject do
  use Mix.Project

  @source_url "https://github.com/akoutmos/doctor"

  def project do
    [
      app: :doctor,
      version: "0.17.0",
      elixir: "~> 1.8",
      name: "Doctor",
      source_url: @source_url,
      homepage_url: "https://hex.pm/packages/doctor",
      description: "Simple utility to create documentation coverage reports",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      docs: [
        main: "readme",
        extras: ["README.md", "CHANGELOG.md"]
      ],
      package: package(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.travis": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/sample_files"]
  defp elixirc_paths(_), do: ["lib"]

  defp package() do
    [
      name: "doctor",
      files: ~w(lib mix.exs README.md LICENSE CHANGELOG.md),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "https://hexdocs.pm/doctor/changelog.html",
        "Sponsor" => "https://github.com/sponsors/akoutmos"
      }
    ]
  end

  defp deps do
    [
      {:decimal, "~> 2.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.13", only: :test, runtime: false}
    ]
  end
end
