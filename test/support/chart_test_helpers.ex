defmodule ChartJs.TestHelpers do
  @moduledoc """
  Test helpers for Chart.js plugin testing
  """

  @doc """
  Creates sample chart data for testing
  """
  def sample_chart_data do
    %{
      "labels" => ["January", "February", "March", "April"],
      "datasets" => [
        %{
          "label" => "Sales",
          "data" => [10, 20, 30, 25],
          "backgroundColor" => "#3b82f6",
          "borderColor" => "#1d4ed8"
        }
      ]
    }
  end

  @doc """
  Creates sample chart configuration for testing
  """
  def sample_chart_config(type \\ "bar") do
    %{
      type: type,
      options: %{
        responsive: true,
        plugins: %{
          legend: %{
            position: "top"
          }
        },
        scales: %{
          y: %{
            beginAtZero: true
          }
        }
      }
    }
  end

  @doc """
  Creates multiple datasets for testing
  """
  def multi_dataset_data do
    %{
      "labels" => ["Q1", "Q2", "Q3", "Q4"],
      "datasets" => [
        %{
          "label" => "Revenue",
          "data" => [1000, 1200, 1500, 1300],
          "backgroundColor" => "#3b82f6"
        },
        %{
          "label" => "Profit",
          "data" => [200, 250, 400, 350],
          "backgroundColor" => "#ef4444"
        },
        %{
          "label" => "Expenses",
          "data" => [800, 950, 1100, 950],
          "backgroundColor" => "#f59e0b"
        }
      ]
    }
  end

  @doc """
  Creates valid add_chart_data event payload
  """
  def add_data_event(label \\ "New Point", data \\ 42) do
    %{
      "label" => label,
      "datasets" => [%{"data" => data}]
    }
  end

  @doc """
  Creates targeted add_chart_data event payload
  """
  def targeted_add_data_event(target, label \\ "New Point", data \\ 42) do
    %{
      "target" => target,
      "label" => label,
      "datasets" => [%{"data" => data}]
    }
  end

  @doc """
  Creates multi-dataset add_chart_data event payload
  """
  def multi_dataset_add_event(datasets_data) do
    datasets =
      datasets_data
      |> Enum.with_index()
      |> Enum.map(fn {data, index} ->
        %{"datasetIndex" => index, "data" => data}
      end)

    %{
      "label" => "Multi Update",
      "datasets" => datasets
    }
  end

  @doc """
  Validates chart component assigns
  """
  def valid_chart_assigns(overrides \\ %{}) do
    defaults = %{
      id: "test_chart",
      config: sample_chart_config(),
      data: sample_chart_data(),
      height: "400px",
      width: "100%"
    }

    Map.merge(defaults, overrides)
  end

  @doc """
  Creates a mock LiveView socket for testing
  """
  def mock_socket do
    %Phoenix.LiveView.Socket{
      assigns: %{
        chart_data: sample_chart_data()
      }
    }
  end

  @doc """
  Validates JSON encoding/decoding for chart data
  """
  def validate_json_roundtrip(data) do
    case Jason.encode(data) do
      {:ok, encoded} ->
        case Jason.decode(encoded) do
          {:ok, decoded} -> {:ok, decoded}
          error -> error
        end

      error ->
        error
    end
  end

  @doc """
  Creates chart data with specific number of points
  """
  def chart_data_with_points(num_points) do
    labels = 1..num_points |> Enum.map(&"Point #{&1}")
    data_points = 1..num_points |> Enum.map(&(&1 * 10))

    %{
      "labels" => labels,
      "datasets" => [
        %{
          "label" => "Test Data",
          "data" => data_points,
          "backgroundColor" => "#3b82f6"
        }
      ]
    }
  end

  @doc """
  Validates event data structure
  """
  def validate_event_structure(event_data) do
    required_keys = ["datasets"]

    # Check required keys
    has_required = Enum.all?(required_keys, &Map.has_key?(event_data, &1))

    # Validate datasets structure
    valid_datasets =
      case event_data["datasets"] do
        datasets when is_list(datasets) ->
          Enum.all?(datasets, fn dataset ->
            is_map(dataset) and Map.has_key?(dataset, "data") and not is_nil(dataset["data"])
          end)

        _ ->
          false
      end

    has_required and valid_datasets
  end
end
