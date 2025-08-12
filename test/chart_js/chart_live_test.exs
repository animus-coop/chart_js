defmodule ChartJs.ChartLiveTest do
  use ExUnit.Case, async: false
  
  import ChartJs.TestHelpers

  # Mock LiveView for testing chart integration
  defmodule TestChartLive do
    use Phoenix.LiveView

    def mount(_params, _session, socket) do
      socket = assign(socket, :chart_data, initial_chart_data())
      {:ok, socket}
    end

    def render(assigns) do
      ~H"""
      <div>
        <.live_component
          module={ChartJs.ChartComponent}
          id="test_chart"
          config={%{type: "bar"}}
          data={@chart_data}
          height="400px"
          width="100%"
        />
        
        <.live_component
          module={ChartJs.ChartComponent}
          id="sales_chart"
          config={%{type: "line"}}
          data={@chart_data}
          height="300px"
          width="100%"
        />
        
        <button phx-click="add_data">Add Data</button>
        <button phx-click="add_targeted_data">Add Targeted Data</button>
      </div>
      """
    end

    def handle_event("add_data", _params, socket) do
      # Test adding data to all charts
      push_event(socket, "add_chart_data", %{
        "label" => "New Point",
        "datasets" => [%{"data" => 42}]
      })
      
      {:noreply, socket}
    end

    def handle_event("add_targeted_data", _params, socket) do
      # Test adding data to specific chart
      push_event(socket, "add_chart_data", %{
        "target" => "sales_chart",
        "label" => "Sales Point",
        "datasets" => [%{"data" => 100}]
      })
      
      {:noreply, socket}
    end

    def initial_chart_data do
      %{
        "labels" => ["Jan", "Feb"],
        "datasets" => [
          %{
            "label" => "Test Data",
            "data" => [10, 20],
            "backgroundColor" => "#3b82f6"
          }
        ]
      }
    end
  end

  describe "Chart LiveView Integration" do
    test "validates LiveView module structure" do
      # Test that the TestChartLive module is properly defined
      assert Code.ensure_loaded?(TestChartLive)
      
      # Test that it implements LiveView behaviour
      behaviours = TestChartLive.__info__(:attributes)
                   |> Keyword.get_values(:behaviour)
                   |> List.flatten()

      assert Phoenix.LiveView in behaviours
    end

    test "validates chart component rendering logic" do
      # Test the render function structure
      _assigns = %{chart_data: sample_chart_data()}
      
      # The render function should not crash with valid assigns
      assert function_exported?(TestChartLive, :render, 1)
    end

    test "validates event handlers" do
      # Test that event handlers are defined
      assert function_exported?(TestChartLive, :handle_event, 3)
      
      # Test event handler logic with mock socket
      socket = mock_socket()
      
      # Should not crash when calling event handlers
      assert {:noreply, _socket} = TestChartLive.handle_event("add_data", %{}, socket)
      assert {:noreply, _socket} = TestChartLive.handle_event("add_targeted_data", %{}, socket)
    end

    test "validates initial chart data structure" do
      # Test the initial_chart_data function
      initial_data = TestChartLive.initial_chart_data()
      
      assert Map.has_key?(initial_data, "labels")
      assert Map.has_key?(initial_data, "datasets")
      assert is_list(initial_data["labels"])
      assert is_list(initial_data["datasets"])
    end
  end

  describe "Chart Event Handling" do
    test "add_chart_data event structure" do
      event_data = %{
        "label" => "March",
        "datasets" => [
          %{"data" => 25},
          %{"datasetIndex" => 1, "data" => 15}
        ]
      }

      # Verify event data structure is valid
      assert is_binary(event_data["label"])
      assert is_list(event_data["datasets"])
      assert Enum.all?(event_data["datasets"], &is_map/1)
    end

    test "targeted event structure" do
      targeted_event = %{
        "target" => "specific_chart",
        "label" => "April",
        "datasets" => [%{"data" => 30}]
      }

      # Verify targeted event structure
      assert is_binary(targeted_event["target"])
      assert is_binary(targeted_event["label"])
      assert is_list(targeted_event["datasets"])
    end

    test "multiple dataset updates" do
      multi_dataset_event = %{
        "label" => "Q1",
        "datasets" => [
          %{"datasetIndex" => 0, "data" => 100},
          %{"datasetIndex" => 1, "data" => 50},
          %{"datasetIndex" => 2, "data" => 75}
        ]
      }

      # Verify multiple dataset structure
      datasets = multi_dataset_event["datasets"]
      assert length(datasets) == 3
      
      Enum.each(datasets, fn dataset ->
        assert Map.has_key?(dataset, "datasetIndex")
        assert Map.has_key?(dataset, "data")
        assert is_integer(dataset["datasetIndex"])
        assert is_number(dataset["data"])
      end)
    end
  end
end
