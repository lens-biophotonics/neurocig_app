defmodule AppWeb.VideoLive.BehaviorTable do
  use AppWeb, :live_component

  alias App.Behavior
  alias App.Behavior.Annotation

  @impl Phoenix.LiveComponent
  def mount(socket) do
    {:ok,
     assign(socket,
       edit_annotation: false,
       type_strings: Behavior.list_type_strings() |> Enum.map(& &1.type_string)
     )}
  end

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div id={@id}>
      <.table :if={@annotations} class="table-auto">
        <.thead>
          <.tr>
            <.th class="text-right">frame</.th>
            <.th class="text-right">time</.th>
            <.th class="text-right">mouse</.th>
            <.th class="text-right">behavior</.th>
            <.th class="text-right">start/stop</.th>
            <.th class="text-right"></.th>
          </.tr>
        </.thead>
        <.tbody>
          <.tr :for={ann <- @annotations}>
            <%= if @edit_annotation && @edit_annotation.id == ann.id do %>
              {behavior_form(assigns)}
            <% else %>
              <.td class="text-right">
                <a class="link" phx-click="go_to_frame" phx-value-value={ann.frame}>{ann.frame}</a>
              </.td>
              <.td class="text-right">
                {Time.from_seconds_after_midnight(Integer.floor_div(ann.frame, 15))}
              </.td>
              <.td class="text-right">{ann.mouse_id}</.td>
              <.td class="text-right">{ann.behavior}</.td>
              <.td class="text-right">{ann.start_stop}</.td>
              <.td class="text-right flex gap-1">
                <.tooltip text="edit">
                  <.button
                    type="button"
                    phx-click="edit_annotation"
                    phx-value-id={ann.id}
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
                    phx-click="delete_annotation"
                    phx-value-id={ann.id}
                    phx-target={@myself}
                    size="sm"
                  >
                    <.icon name="hero-trash" class="w-5 h-5" />
                  </.button>
                </.tooltip>
              </.td>
            <% end %>
          </.tr>
          <.tr
            :if={@edit_annotation && @edit_annotation.id == nil}
            class="items-center"
          >
            {behavior_form(assigns)}
          </.tr>
          <tfoot>
            <.tr>
              <.th class="text-right w-1/10">frame</.th>
              <.th class="text-right w-1/10">time</.th>
              <.th class="text-right w-1/10">mouse</.th>
              <.th class="text-right w-1/10">behavior</.th>
              <.th class="text-right w-1/10">start/stop</.th>
              <.th class="text-right w-1/10"></.th>
            </.tr>
          </tfoot>
        </.tbody>
      </.table>
    </div>
    """
  end

  defp behavior_form(assigns) do
    ~H"""
    <.td class="text-right" id="behavior-annotation-form">
      <.form
        for={@edit_annotation_form}
        id="edit-behavior-annotation-form"
        phx-change="change_edit_annotation"
        phx-submit="submit_edit_annotation"
        phx-target={@myself}
      >
      </.form>
      <AppWeb.CoreComponents.input
        type="number"
        class="input input-sm"
        min="1"
        max={@maxframe}
        form="edit-behavior-annotation-form"
        field={@edit_annotation_form[:frame]}
      />
    </.td>
    <.td class="text-right">
      <%= if @edit_annotation_form[:frame].value do %>
        {Time.from_seconds_after_midnight(Integer.floor_div(@edit_annotation_form[:frame].value, 15))}
      <% else %>
        --:--:--
      <% end %>
    </.td>
    <.td class="text-right">
      <AppWeb.CoreComponents.input
        type="number"
        class="input input-sm"
        form="edit-behavior-annotation-form"
        field={@edit_annotation_form[:mouse_id]}
        min="1"
        max="5"
      />
    </.td>
    <.td class="text-right">
      <AppWeb.CoreComponents.input
        type="select"
        prompt="---"
        options={@type_strings}
        class="input input-sm"
        form="edit-behavior-annotation-form"
        field={@edit_annotation_form[:behavior]}
      />
    </.td>
    <.td class="text-right">
      <AppWeb.CoreComponents.input
        type="select"
        prompt="---"
        options={["start", "stop"]}
        class="input input-sm"
        form="edit-behavior-annotation-form"
        field={@edit_annotation_form[:start_stop]}
      />
    </.td>
    <.td class="text-right flex gap-1">
      <.tooltip text="save">
        <.button
          type="button"
          color="primary"
          size="sm"
          phx-click={JS.dispatch("submit", to: "#edit-behavior-annotation-form")}
          phx-target={@myself}
        >
          <.icon name="hero-check" class="w-5 h-5" />
        </.button>
      </.tooltip>
      <.tooltip text="cancel">
        <.button
          type="button"
          size="sm"
          phx-click="cancel_edit_annotation"
          phx-target={@myself}
        >
          <.icon name="hero-x-mark" class="w-5 h-5" />
        </.button>
      </.tooltip>
    </.td>
    """
  end

  @impl Phoenix.LiveComponent
  def handle_event("new_annotation", _unsigned_params, socket) do
    ann = %Annotation{}

    socket =
      assign(socket,
        edit_annotation: ann,
        edit_annotation_form:
          to_form(Annotation.changeset(ann, %{"frame" => socket.assigns.frame}))
      )
      |> push_event("scroll-to-bottom", %{id: socket.assigns.id})

    {:noreply, socket}
  end

  # edit correction
  @impl Phoenix.LiveComponent
  def handle_event("delete_annotation", %{"id" => id}, socket) do
    Behavior.delete_annotation(%Annotation{id: String.to_integer(id)})
    socket.assigns.notify_changed.(nil)
    {:noreply, socket}
  end

  @impl Phoenix.LiveComponent
  def handle_event("edit_annotation", %{"id" => id}, socket) do
    id = String.to_integer(id)
    ann = Behavior.get_annotation!(id)
    cs = Annotation.changeset(ann, %{})

    {:noreply, assign(socket, edit_annotation: ann, edit_annotation_form: to_form(cs))}
  end

  @impl Phoenix.LiveComponent
  def handle_event("cancel_edit_annotation", _params, socket) do
    {:noreply, assign(socket, edit_annotation: false)}
  end

  @impl Phoenix.LiveComponent
  def handle_event("change_edit_annotation", %{"annotation" => params}, socket) do
    cs =
      Annotation.changeset(
        socket.assigns.edit_annotation,
        put_in(params["video_id"], socket.assigns.video.id)
      )

    {:noreply, assign(socket, edit_annotation_form: to_form(cs, action: :validate))}
  end

  @impl Phoenix.LiveComponent
  def handle_event("submit_edit_annotation", %{"annotation" => params}, socket) do
    ann = socket.assigns.edit_annotation

    cs = Annotation.changeset(ann, put_in(params["video_id"], socket.assigns.video.id))

    func =
      if ann.id == nil do
        fn -> Behavior.create_annotation(cs.params) end
      else
        fn -> Behavior.update_annotation(ann, cs.params) end
      end

    with true <- cs.valid?,
         {:ok, ann} <- func.() do
      socket =
        socket
        |> assign(edit_annotation: false)

      socket.assigns.notify_changed.(ann)

      {:noreply, socket}
    else
      {:error, cs} ->
        {:noreply, assign(socket, edit_annotation_form: to_form(cs, action: :validate))}

      _ ->
        {:noreply, assign(socket, edit_annotation_form: to_form(cs, action: :validate))}
    end
  end
end
