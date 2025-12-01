defmodule AppWeb.VideoLive.Timeline do
  use AppWeb, :live_component

  def mount(socket) do
    socket = socket |> assign(class: "")
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id={@id} class={@class} phx-hook=".Timeline">
      <div
        class="relative h-[350px] bg-white"
        tabindex="-1"
      >
        <div id={"#{@id}-timeline_div"} class="w-full absolute top-0 left-0 h-full"></div>
      </div>
      <script :type={Phoenix.LiveView.ColocatedHook} name=".Timeline">
        export default {
          mounted: function() {
            this.dataTable = null
            this.chartWrapper = null

            this.handleEvent("setupTimeline", (reply) => this.setupTimeline(reply))

            this.chartWrapper = new google.visualization.ChartWrapper({
              chartType: 'Timeline',
              containerId: this.el.id + '-timeline_div',
            })
          },

          setupTimeline: function(reply) {
            // reply.dataTable should include cols and rows already prepared server-side
            var timeZoneOffset = new Date(0).getHours() * 3600 * 1000
            dataTable = new google.visualization.DataTable(reply.dataTable, 0.6)

            for (var i = 0; i < dataTable.getNumberOfRows(); i++) {
              for (var j = 3; j <= 4; j++) {
                var d = dataTable.getValue(i, j) - timeZoneOffset;
                dataTable.setValue(i, j, d);
              }
            }

            this.dataTable = dataTable

            // ensure rows ordered by mouse id ascending
            const mouseCol = this.dataTable.getColumnIndex('mouse_id')
            this.dataTable.sort({column: mouseCol, asc: true})

            const fullLength = reply.full_length || (function() {
              // fallback to max value in the table
              const endCol = this.dataTable.getColumnIndex('end')
              let max = 0
              for (let r = 0; r < this.dataTable.getNumberOfRows(); r++) {
                const v = this.dataTable.getValue(r, endCol)
                if (typeof v === 'number' && v > max) max = v
              }
              return max
            }).call(this)

            const options = {
              timeline: { showRowLabels: true },
              avoidOverlappingGridLines: false,
            }

            // Set DataTable and options on the ChartWrapper and draw it directly.
            this.chartWrapper.setDataTable(this.dataTable)
            this.chartWrapper.setOptions(options)
            this.chartWrapper.draw()

            // attach selection handler now that chart exists
            const chart = this.chartWrapper.getChart()
            google.visualization.events.addListener(chart, 'select', () => {
              const sel = chart.getSelection()
              if (!sel || !sel.length) return
              const row = sel[0].row
              const startCol = this.dataTable.getColumnIndex('start')
              const start = this.dataTable.getValue(row, startCol)
              // start is in seconds; convert back to frame index (15 fps)
              const frame = Math.floor((start + new Date(0).getHours() * 3600 * 1000) / 1000 * 15) + 1
              this.pushEvent('go_to_frame', { value: frame })
            })
          }
        }
      </script>
    </div>
    """
  end
end
