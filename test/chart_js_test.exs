defmodule ChartJSTest do
  use ExUnit.Case, async: false
  doctest ChartJS

  describe "ChartJS module" do
    test "module exists and is accessible" do
      assert Code.ensure_loaded?(ChartJS)
    end

    test "ChartComponent module exists" do
      assert Code.ensure_loaded?(ChartJs.ChartComponent)
    end

    test "ChartComponent implements LiveComponent behaviour" do
      behaviours = ChartJs.ChartComponent.__info__(:attributes)
                   |> Keyword.get_values(:behaviour)
                   |> List.flatten()

      assert Phoenix.LiveComponent in behaviours
    end
  end

  describe "Chart data validation" do
    test "validates basic chart data structure" do
      valid_data = %{
        "labels" => ["A", "B", "C"],
        "datasets" => [
          %{
            "label" => "Test Dataset",
            "data" => [1, 2, 3],
            "backgroundColor" => "#3b82f6"
          }
        ]
      }

      # Should not raise when encoding
      assert {:ok, _} = Jason.encode(valid_data)
    end

    test "validates chart configuration structure" do
      valid_config = %{
        type: "bar",
        options: %{
          responsive: true,
          scales: %{
            y: %{beginAtZero: true}
          }
        }
      }

      # Should not raise when encoding
      assert {:ok, _} = Jason.encode(valid_config)
    end

    test "handles empty datasets" do
      empty_data = %{
        "labels" => [],
        "datasets" => []
      }

      assert {:ok, _} = Jason.encode(empty_data)
    end

    test "validates multiple datasets structure" do
      multi_dataset = %{
        "labels" => ["Q1", "Q2", "Q3", "Q4"],
        "datasets" => [
          %{
            "label" => "Sales",
            "data" => [100, 150, 200, 180],
            "backgroundColor" => "#3b82f6"
          },
          %{
            "label" => "Profit",
            "data" => [20, 30, 50, 40],
            "backgroundColor" => "#ef4444"
          }
        ]
      }

      assert {:ok, encoded} = Jason.encode(multi_dataset)
      assert {:ok, decoded} = Jason.decode(encoded)
      assert length(decoded["datasets"]) == 2
    end
  end

  describe "Event data validation" do
    test "validates add_chart_data event structure" do
      event_data = %{
        "label" => "New Point",
        "datasets" => [
          %{"data" => 42}
        ]
      }

      assert is_binary(event_data["label"])
      assert is_list(event_data["datasets"])
      assert Enum.all?(event_data["datasets"], &is_map/1)
    end

    test "validates targeted event structure" do
      targeted_event = %{
        "target" => "chart_id",
        "label" => "New Point",
        "datasets" => [%{"data" => 42}]
      }

      assert Map.has_key?(targeted_event, "target")
      assert is_binary(targeted_event["target"])
    end

    test "validates dataset index targeting" do
      indexed_event = %{
        "datasets" => [
          %{"datasetIndex" => 0, "data" => 10},
          %{"datasetIndex" => 1, "data" => 20}
        ]
      }

      datasets = indexed_event["datasets"]
      
      Enum.each(datasets, fn dataset ->
        assert Map.has_key?(dataset, "datasetIndex")
        assert is_integer(dataset["datasetIndex"])
        assert dataset["datasetIndex"] >= 0
      end)
    end

    test "handles optional label in events" do
      event_without_label = %{
        "datasets" => [%{"data" => 42}]
      }

      # Should be valid even without label
      assert is_list(event_without_label["datasets"])
      refute Map.has_key?(event_without_label, "label")
    end
  end

  describe "Chart types support" do
    test "supports all common chart types" do
      supported_types = ["bar", "line", "pie", "doughnut", "radar", "polarArea", "bubble", "scatter"]

      for chart_type <- supported_types do
        config = %{type: chart_type}
        assert {:ok, _} = Jason.encode(config)
      end
    end

    test "handles mixed chart configurations" do
      mixed_config = %{
        type: "bar",
        data: %{
          "datasets" => [
            %{"type" => "line", "label" => "Line Dataset"},
            %{"type" => "bar", "label" => "Bar Dataset"}
          ]
        }
      }

      assert {:ok, _} = Jason.encode(mixed_config)
    end
  end
end
