defmodule AppWeb.VideoLive.Graph do
  use AppWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <div id={@id} phx-hook=".Graph" class="w-full h-70"></div>
      <script :type={Phoenix.LiveView.ColocatedHook} name=".Graph">
        export default {
          mounted: function() {
            this.frame = null
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
                this.chart = new google.visualization.LineChart(this.el)

                this.maxFrame = this.dataTable.getColumnRange(this.view.getColumnIndex('frame')).max

                this.setViewOptions(1, 1, ["bb_center_speed"])
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

          setViewOptions: function(mouseId, frame, columns) {
            const frameCol = this.dataTable.getColumnIndex('frame')
            const mouseCol = this.dataTable.getColumnIndex('mouse_id')
            this.mouseId = mouseId
            this.cols = columns
            var cols = columns.map((x) => this.dataTable.getColumnIndex(x))

            const range = 500

            var frameFrom = Math.min(frame - range / 2, this.maxFrame - range)
            if (frameFrom < 0) frameFrom += range / 2
            var frameTo = Math.min(frameFrom + range, this.maxFrame)

            var rows = this.dataTable.getFilteredRows([
              {column: mouseCol, value: mouseId},
              {column: frameCol, minValue: frameFrom,  maxValue: frameTo}
            ])
            this.view.setRows(rows);
            this.view.setColumns([frameCol].concat(cols))

            var options = {
              legend: {
                position: 'in'
              },
              chartArea: {width: '85%', height: '80%'},
            };

            this.chart.draw(this.view, options);
          }
        }
      </script>
    </div>
    """
  end
end
