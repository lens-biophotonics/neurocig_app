defmodule AppWeb.VideoLive.CorrectionTable do
  use AppWeb, :live_component

  alias App.Corrections
  alias App.Corrections.Correction

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok, assign(socket, corrections: nil, edit_correction: false)}
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
        type="button"
        phx-click="new_correction"
        phx-target={@myself}
      >
        New correction
      </.button>
      <.table :if={@corrections} id="corrections-table">
        <.thead>
          <.tr>
            <.th class="text-right">frame</.th>
            <.th class="text-right">time</.th>
            <.th class="text-right">mouse from</.th>
            <.th class="text-right">mouse to</.th>
            <.th>&nbsp;</.th>
          </.tr>
        </.thead>
        <.tbody>
          <.tr :if={@edit_correction && @edit_correction.id == nil} class="items-center">
            {correction_form(assigns)}
          </.tr>
          <.tr :for={c <- @corrections}>
            <%= if @edit_correction && @edit_correction.id == c.id do %>
              {correction_form(assigns)}
            <% else %>
              <.td class="text-right">{c.frame}</.td>
              <.td class="text-right">
                {Time.from_seconds_after_midnight(Integer.floor_div(c.frame, 15))}
              </.td>
              <.td class="text-right">{c.mouse_from}</.td>
              <.td class="text-right">{c.mouse_to}</.td>
              <.td class="gap-2">
                <.tooltip text="edit">
                  <.button
                    type="button"
                    phx-click="edit_correction"
                    phx-value-id={c.id}
                    phx-target={@myself}
                    size="sm"
                  >
                    <.icon name="hero-pencil-square" class="w-5 h-5" />
                  </.button>
                </.tooltip>
                <.tooltip text="delete">
                  <.button
                    type="button"
                    color="error"
                    phx-click="delete_correction"
                    phx-value-id={c.id}
                    phx-target={@myself}
                    size="sm"
                  >
                    <.icon name="hero-trash" class="w-5 h-5" />
                  </.button>
                </.tooltip>
              </.td>
            <% end %>
          </.tr>
        </.tbody>
      </.table>
    </div>
    """
  end

  defp correction_form(assigns) do
    ~H"""
    <div>
      <.td class="text-right">
        <.form
          for={@edit_correction_form}
          id="edit-correction-form"
          phx-change="change_edit_correction"
          phx-submit="submit_edit_correction"
          phx-target={@myself}
        >
        </.form>
        <AppWeb.CoreComponents.input
          type="number"
          min="1"
          max={@maxframe}
          form="edit-correction-form"
          field={@edit_correction_form[:frame]}
        />
      </.td>
      <.td class="text-right">
        <%= if @edit_correction_form[:frame].value do %>
          {Time.from_seconds_after_midnight(
            Integer.floor_div(@edit_correction_form[:frame].value, 15)
          )}
        <% else %>
          --:--:--
        <% end %>
      </.td>
      <.td class="text-right">
        <AppWeb.CoreComponents.input
          type="number"
          form="edit-correction-form"
          field={@edit_correction_form[:mouse_from]}
          min="1"
          max="5"
        />
      </.td>
      <.td class="text-right">
        <AppWeb.CoreComponents.input
          type="number"
          form="edit-correction-form"
          field={@edit_correction_form[:mouse_to]}
          min="1"
          max="5"
        />
      </.td>
      <.td>
        <div class="flex gap-2">
          <.tooltip text="save">
            <.button
              type="button"
              color="primary"
              size="sm"
              class="mb-2"
              phx-click={JS.dispatch("submit", to: "#edit-correction-form")}
              phx-target={@myself}
            >
              <.icon name="hero-check" class="w-5 h-5" />
            </.button>
          </.tooltip>
          <.tooltip text="cancel">
            <.button
              type="button"
              size="sm"
              phx-click="cancel_edit_correction"
              phx-target={@myself}
            >
              <.icon name="hero-x-mark" class="w-5 h-5" />
            </.button>
          </.tooltip>
        </div>
      </.td>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("new_correction", _unsigned_params, socket) do
    corr = %Correction{}

    socket =
      assign(socket,
        edit_correction: corr,
        edit_correction_form:
          to_form(Correction.changeset(corr, %{"frame" => socket.assigns.frame}))
      )

    {:noreply, socket}
  end

  # edit correction
  @impl Phoenix.LiveComponent
  def handle_event("delete_correction", %{"id" => id}, socket) do
    Corrections.delete_correction(%Correction{id: String.to_integer(id)})

    {:noreply, assign_corrections(socket)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("edit_correction", %{"id" => id}, socket) do
    id = String.to_integer(id)
    corr = Corrections.get_correction!(id)
    cs = Correction.changeset(corr, %{})
    {:noreply, assign(socket, edit_correction: corr, edit_correction_form: to_form(cs))}
  end

  @impl Phoenix.LiveComponent
  def handle_event("cancel_edit_correction", _params, socket) do
    {:noreply, assign(socket, edit_correction: false)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("change_edit_correction", %{"correction" => params}, socket) do
    cs =
      Correction.changeset(
        socket.assigns.edit_correction,
        put_in(params["video_id"], socket.assigns.video.id)
      )

    {:noreply, assign(socket, edit_correction_form: to_form(cs, action: :validate))}
  end

  @impl Phoenix.LiveComponent
  def handle_event("submit_edit_correction", %{"correction" => params}, socket) do
    corr = socket.assigns.edit_correction

    cs = Correction.changeset(corr, put_in(params["video_id"], socket.assigns.video.id), :save)

    func =
      if corr.id == nil do
        fn -> Corrections.create_correction(cs.params) end
      else
        fn -> Corrections.update_correction(corr, cs.params) end
      end

    with true <- cs.valid?,
         {:ok, _corr} <- func.() do
      socket =
        socket
        |> assign(edit_correction: false)
        |> assign_corrections()

      {:noreply, socket}
    else
      {:error, cs} ->
        {:noreply, assign(socket, edit_correction_form: to_form(cs, action: :validate))}

      _ ->
        {:noreply, assign(socket, edit_correction_form: to_form(cs, action: :validate))}
    end
  end

  defp assign_corrections(socket) do
    assign(socket, corrections: Corrections.list_corrections_by_video(socket.assigns.video))
  end
end
