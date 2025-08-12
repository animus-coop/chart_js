defmodule ChartJs.ChartHookTest do
  use ExUnit.Case, async: false
  
  import ChartJs.TestHelpers

  describe "Chart Hook Event Handling" do
    test "add_chart_data event structure validation" do
      # Test basic event structure
      basic_event = add_data_event("March", 25)
      assert validate_event_structure(basic_event)
      
      # Test event with multiple datasets
      multi_event = multi_dataset_add_event([10, 20, 30])
      assert validate_event_structure(multi_event)
      
      # Test targeted event
      targeted_event = targeted_add_data_event("sales_chart", "April", 35)
      assert validate_event_structure(targeted_event)
      assert targeted_event["target"] == "sales_chart"
    end

    test "event payload JSON serialization" do
      event_data = %{
        "target" => "test_chart",
        "label" => "New Data Point",
        "datasets" => [
          %{"datasetIndex" => 0, "data" => 42},
          %{"datasetIndex" => 1, "data" => 38}
        ]
      }

      # Should serialize and deserialize correctly
      assert {:ok, decoded} = validate_json_roundtrip(event_data)
      assert decoded["target"] == "test_chart"
      assert decoded["label"] == "New Data Point"
      assert length(decoded["datasets"]) == 2
    end

    test "dataset targeting validation" do
      # Test with datasetIndex
      indexed_datasets = [
        %{"datasetIndex" => 0, "data" => 10},
        %{"datasetIndex" => 2, "data" => 30}
      ]

      event = %{"datasets" => indexed_datasets}
      assert validate_event_structure(event)

      # Verify each dataset has proper structure
      Enum.each(indexed_datasets, fn dataset ->
        assert is_integer(dataset["datasetIndex"])
        assert dataset["datasetIndex"] >= 0
        assert is_number(dataset["data"])
      end)
    end

    test "hook targeting logic simulation" do
      # Simulate hook targeting logic
      chart_id = "sales_chart"
      
      # Event with matching target
      matching_event = %{
        "target" => "sales_chart",
        "label" => "Sales Update",
        "datasets" => [%{"data" => 100}]
      }
      
      # Event with non-matching target
      non_matching_event = %{
        "target" => "users_chart", 
        "label" => "Users Update",
        "datasets" => [%{"data" => 50}]
      }
      
      # Event without target (should apply to all)
      global_event = %{
        "label" => "Global Update",
        "datasets" => [%{"data" => 75}]
      }

      # Simulate hook logic: if target && target !== this.el.id, return
      should_process_matching = !(matching_event["target"] && matching_event["target"] != chart_id)
      should_process_non_matching = !(non_matching_event["target"] && non_matching_event["target"] != chart_id)
      should_process_global = !(global_event["target"] && global_event["target"] != chart_id)

      assert should_process_matching == true
      assert should_process_non_matching == false
      assert should_process_global == true
    end

    test "chart data update simulation" do
      # Simulate chart data before update
      initial_data = sample_chart_data()
      
      # Simulate adding a new data point
      new_label = "May"
      new_data_point = 40
      
      # Simulate the hook's addData logic
      updated_labels = initial_data["labels"] ++ [new_label]
      
      first_dataset = List.first(initial_data["datasets"])
      updated_first_dataset = %{first_dataset | "data" => first_dataset["data"] ++ [new_data_point]}
      updated_datasets = [updated_first_dataset | tl(initial_data["datasets"])]
      
      updated_data = %{initial_data | "labels" => updated_labels, "datasets" => updated_datasets}
      
      # Verify the update
      assert length(updated_data["labels"]) == length(initial_data["labels"]) + 1
      assert List.last(updated_data["labels"]) == new_label
      
      first_updated_dataset = List.first(updated_data["datasets"])
      assert length(first_updated_dataset["data"]) == length(first_dataset["data"]) + 1
      assert List.last(first_updated_dataset["data"]) == new_data_point
    end

    test "multiple dataset update simulation" do
      # Start with multi-dataset data
      initial_data = multi_dataset_data()
      
      # Simulate updating multiple datasets with different values
      dataset_updates = [
        %{"datasetIndex" => 0, "data" => 1600},  # Revenue
        %{"datasetIndex" => 1, "data" => 450},   # Profit
        %{"datasetIndex" => 2, "data" => 1150}   # Expenses
      ]
      
      # Simulate the hook's logic for multiple dataset updates
      updated_datasets = 
        initial_data["datasets"]
        |> Enum.with_index()
        |> Enum.map(fn {dataset, index} ->
          case Enum.find(dataset_updates, &(&1["datasetIndex"] == index)) do
            %{"data" => new_data} ->
              %{dataset | "data" => dataset["data"] ++ [new_data]}
            nil ->
              dataset
          end
        end)
      
      updated_data = %{initial_data | "datasets" => updated_datasets}
      
      # Verify all datasets were updated
      Enum.with_index(updated_data["datasets"], fn dataset, index ->
        original_dataset = Enum.at(initial_data["datasets"], index)
        assert length(dataset["data"]) == length(original_dataset["data"]) + 1
        
        expected_update = Enum.find(dataset_updates, &(&1["datasetIndex"] == index))
        if expected_update do
          assert List.last(dataset["data"]) == expected_update["data"]
        end
      end)
    end
  end

  describe "Chart Configuration Validation" do
    test "validates chart.js configuration options" do
      configs = [
        sample_chart_config("bar"),
        sample_chart_config("line"),
        sample_chart_config("pie"),
        sample_chart_config("doughnut")
      ]

      Enum.each(configs, fn config ->
        assert {:ok, _} = validate_json_roundtrip(config)
        assert Map.has_key?(config, :type)
        assert Map.has_key?(config, :options)
      end)
    end

    test "validates complex chart configurations" do
      complex_config = %{
        type: "line",
        options: %{
          responsive: true,
          maintainAspectRatio: false,
          interaction: %{
            mode: "index",
            intersect: false
          },
          scales: %{
            x: %{
              display: true,
              title: %{
                display: true,
                text: "Month"
              }
            },
            y: %{
              display: true,
              title: %{
                display: true,
                text: "Value"
              },
              beginAtZero: true
            }
          },
          plugins: %{
            legend: %{
              position: "top"
            },
            tooltip: %{
              mode: "index",
              intersect: false
            }
          }
        }
      }

      assert {:ok, _} = validate_json_roundtrip(complex_config)
    end
  end

  describe "Error Handling" do
    test "handles invalid event structures gracefully" do
      invalid_events = [
        %{},  # Missing datasets
        %{"datasets" => nil},  # Null datasets
        %{"datasets" => "invalid"},  # String instead of array
        %{"datasets" => [%{}]},  # Dataset without data
        %{"datasets" => [%{"data" => nil}]}  # Dataset with null data
      ]

      Enum.each(invalid_events, fn event ->
        refute validate_event_structure(event)
      end)
    end

    test "handles edge cases in dataset targeting" do
      # Negative datasetIndex
      negative_index_event = %{
        "datasets" => [%{"datasetIndex" => -1, "data" => 10}]
      }
      
      # Very large datasetIndex
      large_index_event = %{
        "datasets" => [%{"datasetIndex" => 999, "data" => 10}]
      }
      
      # Both should have valid structure but may not work in practice
      assert validate_event_structure(negative_index_event)
      assert validate_event_structure(large_index_event)
    end

    test "handles missing optional fields" do
      # Event without label
      no_label_event = %{
        "datasets" => [%{"data" => 42}]
      }
      
      # Event without target
      no_target_event = %{
        "label" => "Test",
        "datasets" => [%{"data" => 42}]
      }
      
      assert validate_event_structure(no_label_event)
      assert validate_event_structure(no_target_event)
    end
  end
end
