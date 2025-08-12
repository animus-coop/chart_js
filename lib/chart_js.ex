defmodule ChartJS do
  @moduledoc """
  Phoenix LiveView Chart.js integration for reactive charts.

  ChartJS provides a seamless way to integrate Chart.js charts into Phoenix LiveView
  applications with real-time updates and reactive data binding.

  ## Features

  - **Reactive Charts**: Charts update automatically when data changes
  - **Real-time Updates**: Use `push_event` to add data points dynamically
  - **Multiple Chart Types**: Support for bar, line, pie, doughnut, radar, and more
  - **Multiple Charts**: Support for multiple independent charts on the same page
  - **Targeting**: Selective updates for specific charts
  - **Phoenix LiveView Integration**: Built specifically for LiveView applications

  ## Quick Start

  1. Add the dependency to your `mix.exs`:

      ```elixir
      def deps do
        [
          {:chart_js, "~> 0.1.0"}
        ]
      end
      ```

  2. Install Chart.js npm dependencies:

      ```bash
      mix chart_js.install
      ```

  3. Add the hook to your `app.js`:

      ```javascript
      import ChartJsHook from "../deps/chart_js/assets/chart_hook.js";

      let Hooks = { ChartJs: ChartJsHook };
      let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks });
      ```

  4. Use the component in your LiveView:

      ```elixir
      <.live_component
        module={ChartJs.ChartComponent}
        id="my_chart"
        config={%{type: "bar"}}
        data={%{
          "labels" => ["A", "B", "C"],
          "datasets" => [%{
            "label" => "Data",
            "data" => [1, 2, 3]
          }]
        }}
        height="400px"
        width="100%"
      />
      ```

  ## Real-time Updates

  Update charts dynamically using `push_event`:

      # Add data to all charts
      push_event(socket, "add_chart_data", %{
        "label" => "New Point",
        "datasets" => [%{"data" => 42}]
      })

      # Add data to specific chart
      push_event(socket, "add_chart_data", %{
        "target" => "my_chart",
        "label" => "New Point",
        "datasets" => [%{"data" => 42}]
      })

  ## Chart Types

  Supported chart types include:
  - `"bar"` - Bar charts
  - `"line"` - Line charts
  - `"pie"` - Pie charts
  - `"doughnut"` - Doughnut charts
  - `"radar"` - Radar charts
  - `"polarArea"` - Polar area charts
  - `"bubble"` - Bubble charts
  - `"scatter"` - Scatter plots

  ## Configuration

  Charts accept any valid Chart.js configuration. See the
  [Chart.js documentation](https://www.chartjs.org/docs/) for complete options.

  ## Examples

  See `ChartJs.ChartComponent` for detailed usage examples.
  """

  @doc """
  Returns the current version of the ChartJS library.

  ## Examples

      iex> ChartJS.version()
      "0.1.0"

  """
  def version do
    Application.spec(:chart_js, :vsn) |> to_string()
  end
end
