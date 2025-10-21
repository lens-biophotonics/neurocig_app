defmodule AppWeb.VideoLive.CorrectionTable do
  use AppWeb, :live_component

  alias App.Corrections
  alias App.Corrections.Correction

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, corrections: nil, show_correction_form: false)}
  end

  @impl Phoenix.LiveComponent
  def update(%{video: video} = assigns, socket) when not is_nil(video) do
    socket =
      socket
      |> assign(assigns)
      |> assign_corrections()

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
      <.button
        :if={not @show_correction_form}
        type="button"
        phx-click="new_correction"
        phx-target={@myself}
      >
        New correction
      </.button>
      {correction_form(assigns)}
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

  defp correction_form(assigns) do
    ~H"""
    <div>
      <.form
        :if={@show_correction_form}
        for={@form}
        id="correction-form"
        phx-change="change"
        phx-submit="submit"
        phx-target={@myself}
        class="flex gap-2"
      >
        <.input type="number" field={@form[:frame]} label="frame" />
        <.input type="number" field={@form[:mouse_from]} label="mouse from" />
        <.input type="number" field={@form[:mouse_to]} label="mouse to" />
        <.fieldset>
          <.fieldset_label class="mt-2">&nbsp;</.fieldset_label>
          <.button type="submit" color="primary" phx-target={@myself}>Save</.button>
        </.fieldset>
        <.fieldset>
          <.fieldset_label class="mt-2">&nbsp;</.fieldset_label>
          <.button type="button" phx-click="close_form" phx-target={@myself}>Cancel</.button>
        </.fieldset>
      </.form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("new_correction", _unsigned_params, socket) do
    socket =
      assign(socket,
        form: to_form(Correction.changeset(%Correction{}, %{})),
        show_correction_form: true
      )

    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("close_form", _unsigned_params, socket) do
    {:noreply, assign(socket, show_correction_form: false)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("change", %{"correction" => params}, socket) do
    cs =
      Correction.changeset(%Correction{}, put_in(params, ["video_id"], socket.assigns.video.id))

    {:noreply, assign(socket, form: to_form(cs, action: :validate))}
  end

  @impl Phoenix.LiveComponent
  def handle_event("submit", %{"correction" => params}, socket) do
    params = put_in(params, ["video_id"], socket.assigns.video.id)
    cs = Correction.changeset(%Correction{}, params)

    with true <- cs.valid?,
         {:ok, _corr} <- Corrections.create_correction(params) do
      socket =
        socket
        |> assign(show_correction_form: false)
        |> assign_corrections()

      {:noreply, socket}
    else
      _ -> {:noreply, assign(socket, form: to_form(cs, action: :validate))}
    end
  end

  defp assign_corrections(socket) do
    assign(socket, corrections: Corrections.list_corrections_by_video(socket.assigns.video))
  end
end
