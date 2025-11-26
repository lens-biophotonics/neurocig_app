defmodule AppWeb.VideoLive.Chart do
  use AppWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <div
        id={"#{@id}"}
        phx-hook=".Chart"
        class="relative h-[380px]"
        tabindex="-1"
        phx-keydown="key_event"
      >
        <div id={"#{@id}-shade_div"} style="w-full absolute top-0 left-0"></div>
        <div id={"#{@id}-chart_div"} class="w-full absolute top-0 left-0"></div>
        <div id={"#{@id}-range_div"} class="w-full absolute top-[300px] left-0"></div>
      </div>
      <script :type={Phoenix.LiveView.ColocatedHook} name=".Chart">
        export default {
          mounted: function() {
            this.mouseId = null
            this.frame = 1

            this.handleEvent("setupChart", (reply) => this.setupChart(reply))

            this.chartWrapper = new google.visualization.ChartWrapper({
              chartType: 'LineChart',
              containerId: this.el.id + '-chart_div',
              options: {
                legend: {position: 'in'},
                chartArea: {width: '90%', height: '80%'},
                height: 300,
                crosshair: {trigger: 'selection'},
                pointSize: 3,
                backgroundColor: "transparent"
              }
            })

            this.shadeChart = new google.visualization.AreaChart(document.getElementById(this.el.id + '-shade_div'))

            console.log(this.chartWrapper)

            // google.visualization.events.addListener(this.chartWrapper, 'select', () => this.selectHandler());

            google.visualization.events.addListener(this.chartWrapper, 'ready', (e) => {
                this.drawShade()
            })

            var rangeFilter = new google.visualization.ControlWrapper({
              controlType: 'ChartRangeFilter',
              containerId: this.el.id + '-range_div',
              options: {
                filterColumnLabel: 'frame',
                ui: {
                  chartOptions: {
                    chartArea: {width: '90%'},
                    height: 80,
                    hAxis: {viewWindow: { min: 0}},
                  }
                }
              }
            })

            rangeFilter.setState({range: {start: 0, end: 2000}})

            this.dashboard = new google.visualization.Dashboard(this.el)
            this.dashboard.bind(rangeFilter, this.chartWrapper);
          },

          setupChart: function(reply) {
            console.log(reply)
            this.dataTable = new google.visualization.DataTable(reply.dataTable, 0.6)
            this.dataTable.sort({column: 0, asc: true})
            console.log(this.dataTable)
            this.dashboard.draw(this.dataTable)
          },

          setViewOptions: function(mouseId, columns) {
            const frameCol = this.dataTable.getColumnIndex('frame')
            const mouseCol = this.dataTable.getColumnIndex('mouse_id')
            this.mouseId = mouseId
            this.cols = columns
            var cols = columns.map((x) => this.dataTable.getColumnIndex(x))

            var rows = this.dataTable.getFilteredRows([{column: mouseCol, value: mouseId}])
            this.view.setRows(rows);
            this.view.setColumns([frameCol].concat(cols))

            this.dashboard.draw(this.view);
          },

          selectHandler: function() {
            var selection = this.chartWrapper.getChart().getSelection()
            if (selection == null || selection[0].row == null) return
            const dataTable = this.chartWrapper.getDataTable()
            var frame = dataTable.getValue(selection[0].row, dataTable.getColumnIndex('frame'))
            this.pushEvent("go_to_frame", {value: frame})
          },

          updateCrosshair: function(frame) {
              const dataTable = this.chartWrapper.getDataTable()
              const frameCol = dataTable.getColumnIndex('frame')
              const row = dataTable.getFilteredRows([{column: frameCol, value: frame}])[0]

              this.chartWrapper.getChart().setSelection([{row: row, col: 1}])
          },

          drawShade: function() {
            const shadeMin = -17.74
            const shadeMax = 17.73
            const shade = new google.visualization.DataTable();
            shade.addColumn('number', 'x');
            shade.addColumn('number', 'low');
            shade.addColumn('number', 'high');

            // Only two rows defining horizontal region:
            shade.addRow([0, shadeMin, shadeMax - shadeMin]);
            shade.addRow([999, shadeMin, shadeMax - shadeMin]);

            const chartLayoutInterface = this.chartWrapper.getChart().getChartLayoutInterface()

            const shadeOptions = {
              legend: 'none',
              hAxis: { textPosition: 'none', gridlines: { color: 'transparent' } },
              vAxis: {
                textPosition: 'none', gridlines: { color: 'transparent' },
                viewWindow: {
                  min: chartLayoutInterface.getVAxisValue(30.5),
                  max: chartLayoutInterface.getVAxisValue(269.5)
                }
              },
              series: {
                0: { type: 'area', color: '#a0a0a0', lineWidth: 0 },
                1: { type: 'area', color: '#a0a0a0', lineWidth: 0 }
              },
              isStacked: true,
              height: 300,
              chartArea: {width: '90%', height: '80%'},
            }

            this.shadeChart.draw(shade, shadeOptions);
          }
        }
      </script>
    </div>
    """
  end
end
