defmodule AppWeb.VideoLive.Graph do
  use AppWeb, :live_component

  def render(assigns) do
    ~H"""
    <div>
      <div id={@id} phx-hook=".Graph"></div>
      <script :type={Phoenix.LiveView.ColocatedHook} name=".Graph">
        export default {
          mounted() {
            this.frame = 1
            window.addEventListener("phx:load-graph", e => {
              if(this.el.id != e.detail.id) {
                return
              }
              json_path = __APP__.videoPath + '/' + e.detail.video + '_data_table.json'
              fetch(json_path).then((response) => {
                  return response.json()
              }).then(data => {
                var dataTable = new google.visualization.DataTable(data, 0.6)
                var view = new google.visualization.DataView(dataTable)
                console.log(view)

                const frameCol = view.getColumnIndex('frame')
                const mouseCol = view.getColumnIndex('mouse_id')

                view.setRows(view.getFilteredRows([{column: mouseCol, value: 1}, {column: frameCol, maxValue: 1000}]));
                view.setColumns([frameCol, 4])

                var options = {
                  title: 'LineChart',
                };

                var chart = new google.visualization.LineChart(this.el);

                chart.draw(view, options);
              })

            })
          }
        }
      </script>
    </div>
    """
  end
end
