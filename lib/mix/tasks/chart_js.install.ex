defmodule Mix.Tasks.ChartJs.Install do
  @moduledoc """
  Installs Chart.js npm dependencies in the current project's assets directory.

  ## Usage

      mix chart_js.install

  This task will:
  1. Check if an assets directory exists
  2. Install chart.js npm package if not already present
  3. Provide instructions for manual installation if automatic fails
  """

  use Mix.Task

  @shortdoc "Installs Chart.js npm dependencies"

  def run(_args) do
    assets_path = Path.join(File.cwd!(), "assets")

    if File.exists?(assets_path) do
      install_chart_js_dependencies(assets_path)
    else
      Mix.shell().error("""
      No assets directory found in the current project.

      Chart.js requires npm dependencies to be installed in your assets directory.
      Please create an assets directory and package.json first, then run this task again.
      """)
    end
  end

  defp install_chart_js_dependencies(assets_path) do
    package_json_path = Path.join(assets_path, "package.json")

    if File.exists?(package_json_path) do
      # Check if chart.js is already installed
      node_modules_path = Path.join(assets_path, "node_modules/chart.js")

      if File.exists?(node_modules_path) do
        Mix.shell().info("✓ Chart.js is already installed in #{assets_path}")
      else
        install_chart_js(assets_path)
      end
    else
      Mix.shell().error("""
      No package.json found in #{assets_path}.

      Please initialize npm in your assets directory first:

        cd assets
        npm init -y
        
      Then run this task again.
      """)
    end
  end

  defp install_chart_js(assets_path) do
    Mix.shell().info("Installing Chart.js dependencies in #{assets_path}...")

    case System.cmd("npm", ["install", "chart.js"], cd: assets_path, stderr_to_stdout: true) do
      {output, 0} ->
        Mix.shell().info("✓ Chart.js installed successfully!")

        if String.trim(output) != "" do
          Mix.shell().info(output)
        end

        Mix.shell().info("""

        Chart.js is now ready to use! Make sure to import the hook in your app.js:

          import ChartJsHook from "../deps/chart_js/assets/chart_hook.js";
          
          let Hooks = { ChartJs: ChartJsHook };
          let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks });
        """)

      {output, exit_code} ->
        Mix.shell().error("✗ Failed to install Chart.js (exit code: #{exit_code})")
        Mix.shell().error(output)

        Mix.shell().error("""

        Automatic installation failed. Please install Chart.js manually:

          cd assets
          npm install chart.js

        """)
    end
  end
end
