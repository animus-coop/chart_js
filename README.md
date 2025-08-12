# ChartJS

This plugin allows you to render Chart.js charts in Phoenix LiveView applications easily and reactively.

## Installation

### As a Published Package (Hex.pm)

Add `chart_js` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:chart_js, "~> 0.1.0"}
  ]
end
```


### Installing Chart.js Dependencies

After adding the dependency, install the required npm packages:

```bash
# Install Elixir dependencies
mix deps.get

# Install Chart.js npm dependencies
mix chart_js.install
```

### Setup for Development

To set up the Chart.js plugin project itself:

```bash
mix setup
```

## Quick Usage

1. **Add the component to your LiveView:**

```elixir
<.live_component
  module={ChartJs.ChartComponent}
  id="my_chart"
  type="bar" # or "line", "pie", etc.
  data={%{"labels" => ["A", "B"], "datasets" => [%{"label" => "Demo", "data" => [1,2]}]}}
  options={%{}}
/>
```

2. **Include the JS hook in your app.js**

```javascript
import ChartJsHook from "../deps/chart_js/assets/chart_hook.js";

let Hooks = { ChartJs: ChartJsHook };
let liveSocket = new LiveSocket("/live", Socket, { hooks: Hooks });
```

3. **Done!**

Whenever the data or options change, the chart will automatically update.

---

## Real-time Chart Updates

You can update charts dynamically using `push_event` from your LiveView:

### Adding Data Points

```elixir
# Add a new data point to ALL charts (push_event/3)
push_event(socket, "add_chart_data", %{
  "label" => "March",      # new label (optional)
  "datasets" => [
    %{"data" => 25}        # new data point for first dataset
  ]
})

# Add data to multiple datasets
push_event(socket, "add_chart_data", %{
  "label" => "April",
  "datasets" => [
    %{"datasetIndex" => 0, "data" => 30},  # first dataset
    %{"datasetIndex" => 1, "data" => 15}   # second dataset
  ]
})
```

**Note:** With `push_event/3`, the event is sent to ALL chart components. If you need to target specific charts, you have two options:

### Option A: Include target in the event data and modify the hook

```elixir
# Send target in the event payload
push_event(socket, "add_chart_data", %{
  "target" => "sales_chart",  # chart component id
  "label" => "Sales Data",
  "datasets" => [%{"data" => 100}]
})
```

### Option B: Use separate event names for different charts

```elixir
# Different events for different charts
push_event(socket, "add_sales_chart_data", %{
  "label" => "Q1", "datasets" => [%{"data" => 1500}]
})

push_event(socket, "add_users_chart_data", %{
  "label" => "Q1", "datasets" => [%{"data" => 250}]
})
```

### Example LiveView Implementation

```elixir
defmodule MyAppWeb.ChartLive do
  use MyAppWeb, :live_view

  def mount(_params, _session, socket) do
    if connected?(socket) do
      :timer.send_interval(2000, self(), :update_chart)
    end

    socket = assign(socket, :chart_data, initial_chart_data())
    {:ok, socket}
  end

  def handle_info(:update_chart, socket) do
    new_value = :rand.uniform(100)
    
    push_event(socket, "add_chart_data", %{
      "label" => "Point #{System.system_time(:second)}",
      "datasets" => [%{"data" => new_value}]
    })
    
    {:noreply, socket}
  end

  defp initial_chart_data do
    %{
      "labels" => ["Jan", "Feb"],
      "datasets" => [
        %{
          "label" => "Sales",
          "data" => [10, 20],
          "backgroundColor" => "#3b82f6"
        }
      ]
    }
  end
end
```

## Customization

You can pass any valid Chart.js configuration in `data` and `options`.

## Example data

```elixir
%{"labels" => ["Red", "Blue"],
  "datasets" => [
    %{"label" => "Votes", "data" => [12, 19], "backgroundColor" => ["#f00", "#00f"]}
  ]}
```

## Troubleshooting

### "Could not resolve 'chart.js/auto'" Error

If you see this error when using the plugin as a local dependency:

```
✘ [ERROR] Could not resolve "chart.js/auto"
```

**Solution:**
1. Make sure you've installed Chart.js dependencies:
   ```bash
   mix chart_js.install
   ```

2. Or install manually:
   ```bash
   cd assets
   npm install chart.js
   ```

3. Verify the import path in your `app.js`:
   ```javascript
   import ChartJsHook from "../deps/chart_js/assets/chart_hook.js";
   ```

### Multiple Charts Not Updating Correctly

Make sure each chart has a unique `id`:
```elixir
<.live_component module={ChartJs.ChartComponent} id="chart_1" ... />
<.live_component module={ChartJs.ChartComponent} id="chart_2" ... />
```

Use the `target` parameter for selective updates:
```elixir
push_event(socket, "add_chart_data", %{
  "datasets" => [%{"data" => 42}]
}, target: "chart_1")  # Only updates chart_1
```

## Notes
- The component renders a `<canvas>` and uses a hook to initialize Chart.js.
- The hook destroys the previous chart before creating a new one to avoid memory leaks.
- You can have multiple charts in the same view, just use different `id`s.


## Installation

The package can be installed by adding `chart_js` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:chart_js, "~> 0.1.0"}
  ]
end
```
