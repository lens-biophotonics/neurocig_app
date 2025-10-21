defmodule AppWeb.VideoLive.CorrectionTable do
  use AppWeb, :live_component

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, corrections: nil)}
  end

  @impl Phoenix.LiveComponent
  def update(%{video: video} = assigns, socket) when not is_nil(video) do
    socket =
      socket
      |> assign(assigns)
      |> assign(corrections: App.Corrections.list_corrections_by_video(video))

    {:ok, socket}
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.table :if={@corrections} id="corrections-table">
        <.thead>
          <.tr>
            <.th class="text-right">frame</.th>
            <.th class="text-right">time</.th>
            <.th class="text-right">mouse from</.th>
            <.th class="text-right">mouse to</.th>
          </.tr>
        </.thead>
        <.tbody>
          <.tr :for={c <- @corrections}>
            <.td class="text-right">{c.frame}</.td>
            <.td class="text-right">
              {Time.from_seconds_after_midnight(Integer.floor_div(c.frame, 15))}
            </.td>
            <.td class="text-right">{c.mouse_from}</.td>
            <.td class="text-right">{c.mouse_to}</.td>
          </.tr>
        </.tbody>
      </.table>
    </div>
    """
  end
end
