defmodule AppWeb.VideoLive.Graph do
  use AppWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <div id={"#{@id}"} phx-hook=".Graph">
        <div id={"#{@id}-chart_div"}></div>
        <div id={"#{@id}-range_div"}></div>
      </div>
      <script :type={Phoenix.LiveView.ColocatedHook} name=".Graph">
        export default {
          mounted: function() {
            this.cols = null
            this.view = null
            this.mouseId = null
            window.addEventListener("phx:loadGraph", e => {
              if(this.el.id != e.detail.id) {
                return
              }
              json_path = __APP__.videoPath + '/' + e.detail.video + '_data_table.json'
              fetch(json_path).then((response) => {
                  return response.json()
              }).then(data => {
                this.dataTable = new google.visualization.DataTable(data, 0.6)
                this.view = new google.visualization.DataView(this.dataTable)
                this.chart = new google.visualization.ChartWrapper({
                  chartType: 'LineChart',
                  containerId: this.el.id + '-chart_div',
                  options: {
                    legend: {position: 'in'},
                    chartArea: {width: '90%', height: '80%'},
                    height: 300,
                  }
                })
                this.dashboard = new google.visualization.Dashboard(this.el)

                var rangeFilter = new google.visualization.ControlWrapper({
                  controlType: 'ChartRangeFilter',
                  containerId: this.el.id + '-range_div',
                  options: {
                    filterColumnLabel: 'frame',
                    ui: {
                      chartOptions: {
                        chartArea: {width: '90%'},
                        height: 80,
                      }
                    }
                  }
                })
                rangeFilter.setState({range: {start: 1, end: 1000}})

                this.dashboard.bind(rangeFilter, this.chart);

                this.setViewOptions(1, ["bb_center_speed"])
              })
            })
            window.addEventListener("phx:setFrame", e => {
              if(this.el.id != e.detail.id) {
                return
              }
              if(this.view == null) return
              this.setViewOptions(this.mouseId, e.detail.frame, this.cols)
            })
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
          }
        }
      </script>
    </div>
    """
  end
end
