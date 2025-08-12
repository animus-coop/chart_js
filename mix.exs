defmodule ChartJS.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :chart_js,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),

      # Documentation
      name: "ChartJS",
      description: "Phoenix LiveView Chart.js integration for reactive charts",
      source_url: "https://github.com/animus-coop/chart_js",
      homepage_url: "https://github.com/animus-coop/chart_js",
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix_live_view, "~> 1.0.2"},
      {:jason, "~> 1.2"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  # Aliases for running tasks
  defp aliases do
    [
      setup: ["deps.get", "assets.install"],
      "assets.install": &install_assets/1
    ]
  end

  defp install_assets(_) do
    assets_path = Path.join(File.cwd!(), "assets")

    if File.exists?(assets_path) and File.exists?(Path.join(assets_path, "package.json")) do
      Mix.shell().info("Installing Chart.js assets dependencies...")

      case System.cmd("npm", ["install"], cd: assets_path, stderr_to_stdout: true) do
        {output, 0} ->
          Mix.shell().info("Chart.js assets installed successfully")
          Mix.shell().info(output)

        {output, exit_code} ->
          Mix.shell().error("Failed to install Chart.js assets (exit code: #{exit_code})")
          Mix.shell().error(output)
          {:error, exit_code}
      end
    else
      Mix.shell().info("No assets directory or package.json found, skipping npm install")
    end
  end

  # Documentation configuration
  defp docs do
    [
      main: "ChartJS",
      extras: [
        "README.md": [title: "Overview"]
      ],
      groups_for_modules: [
        Components: [ChartJs.ChartComponent],
        Core: [ChartJS],
        "Mix Tasks": [Mix.Tasks.ChartJs.Install]
      ],
      source_ref: "v#{@version}",
      source_url: "https://github.com/animus-coop/chart_js",
      authors: ["Julian Somoza"]
    ]
  end

  # Package configuration for Hex
  defp package do
    [
      description:
        "Phoenix LiveView Chart.js integration for reactive charts with real-time updates",
      files: ~w(lib assets mix.exs README.md LICENSE),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/juliansomoza/chart_js",
        "Docs" => "https://hexdocs.pm/chart_js"
      },
      maintainers: ["Julian Somoza"],
      keywords: [
        "phoenix",
        "liveview",
        "charts",
        "chartjs",
        "visualization",
        "reactive",
        "realtime"
      ]
    ]
  end
end
