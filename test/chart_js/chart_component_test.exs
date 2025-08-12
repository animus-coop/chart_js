defmodule ChartJs.ChartComponentTest do
  use ExUnit.Case, async: false
  import Phoenix.LiveViewTest

  alias ChartJs.ChartComponent

  describe "ChartComponent" do
    test "renders chart container with correct attributes" do
      assigns = %{
        id: "test_chart",
        config: %{type: "bar"},
        data: %{
          "labels" => ["A", "B"],
          "datasets" => [%{"label" => "Test", "data" => [1, 2]}]
        },
        height: "400px",
        width: "100%"
      }

      html = render_component(ChartComponent, assigns)

      assert html =~ ~s(id="test_chart")
      assert html =~ ~s(phx-hook="ChartJs")
      assert html =~ ~s(data-config=)
      assert html =~ ~s(data-data=)
      assert html =~ ~s(height: 400px)
      assert html =~ ~s(width: 100%)
      assert html =~ ~s(<canvas id="test_chart_canvas">)
    end

    test "encodes config and data as JSON" do
      config = %{type: "line", responsive: true}

      data = %{
        "labels" => ["Jan", "Feb", "Mar"],
        "datasets" => [
          %{
            "label" => "Sales",
            "data" => [10, 20, 30],
            "backgroundColor" => "#3b82f6"
          }
        ]
      }

      assigns = %{
        id: "sales_chart",
        config: config,
        data: data,
        height: "300px",
        width: "100%"
      }

      html = render_component(ChartComponent, assigns)

      # Verify JSON encoding (HTML entities are encoded)
      assert html =~ "data-config="
      assert html =~ "data-data="
      assert html =~ "line"
      assert html =~ "Sales"
    end

    test "handles different chart types" do
      chart_types = ["bar", "line", "pie", "doughnut", "radar"]

      for chart_type <- chart_types do
        assigns = %{
          id: "#{chart_type}_chart",
          config: %{type: chart_type},
          data: %{"labels" => ["A"], "datasets" => [%{"data" => [1]}]},
          height: "400px",
          width: "100%"
        }

        html = render_component(ChartComponent, assigns)

        # Check for chart type in HTML (encoded as HTML entities)
        assert html =~ chart_type
        assert html =~ "data-config="
      end
    end

    test "renders with custom dimensions" do
      assigns = %{
        id: "custom_chart",
        config: %{type: "bar"},
        data: %{"labels" => ["A"], "datasets" => [%{"data" => [1]}]},
        height: "600px",
        width: "80%"
      }

      html = render_component(ChartComponent, assigns)

      assert html =~ "height: 600px"
      assert html =~ "width: 80%"
    end

    test "handles complex chart configuration" do
      complex_config = %{
        type: "line",
        options: %{
          responsive: true,
          scales: %{
            y: %{
              beginAtZero: true
            }
          },
          plugins: %{
            legend: %{
              position: "top"
            }
          }
        }
      }

      assigns = %{
        id: "complex_chart",
        config: complex_config,
        data: %{"labels" => ["A"], "datasets" => [%{"data" => [1]}]},
        height: "400px",
        width: "100%"
      }

      html = render_component(ChartComponent, assigns)

      # Verify complex config elements are present
      assert html =~ "data-config="
      assert html =~ "line"
      assert html =~ "responsive"
      assert html =~ "beginAtZero"
    end

    test "handles multiple datasets" do
      data_with_multiple_datasets = %{
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

      assigns = %{
        id: "multi_dataset_chart",
        config: %{type: "bar"},
        data: data_with_multiple_datasets,
        height: "400px",
        width: "100%"
      }

      html = render_component(ChartComponent, assigns)

      # Verify multiple datasets are present
      assert html =~ "data-data="
      assert html =~ "Sales"
      assert html =~ "Profit"
      assert html =~ "Q1"
      assert html =~ "Q4"
    end

    test "generates unique canvas id based on component id" do
      assigns = %{
        id: "unique_chart_123",
        config: %{type: "bar"},
        data: %{"labels" => ["A"], "datasets" => [%{"data" => [1]}]},
        height: "400px",
        width: "100%"
      }

      html = render_component(ChartComponent, assigns)

      assert html =~ ~s(id="unique_chart_123_canvas")
    end
  end
end
