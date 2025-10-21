defmodule AppWeb.VideoLive.Form do
  alias App.Annotations
  use AppWeb, :live_view

  alias App.Videos
  alias App.Videos.Video

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@video.name}
      </.header>

      <.form for={@control_form} id="video-form" phx-change="control_change">
        <div class="flex gap-4">
          <.input field={@control_form[:show_bb]} type="toggle" label="Show bounding boxes" />
          <.input field={@control_form[:show_keypoints]} type="toggle" label="Show keypoints" />
        </div>
        <div class="flex gap-4">
          <.input
            field={@control_form[:go_to_frame]}
            type="number"
            label="Go to frame"
            phx-debounce="800"
          />
          <.fieldset class="mt-2">
            <.fieldset_label>&nbsp;</.fieldset_label>
            <.button type="button" name="go_to_frame_button" phx-click={JS.dispatch("change")}>
              Go to frame
            </.button>
          </.fieldset>
        </div>
        <div class="flex gap-4">
          <.input
            type="time"
            field={@control_form[:go_to_time]}
            step="1"
            label="Go to time"
          />
          <.fieldset class="mt-2">
            <.fieldset_label>&nbsp;</.fieldset_label>
            <.button type="button" name="go_to_time_button" phx-click={JS.dispatch("change")}>
              Go to time
            </.button>
          </.fieldset>
        </div>
      </.form>
      <br />

      <p>Frame: {@frame}</p>
      <p>Time: {Time.from_seconds_after_midnight(Integer.floor_div(@frame, 15))}</p>
      <.header>
        <:subtitle>
          To move frame by frame, click on the image then use the keyboard arrow keys.
          <kbd class="kbd">◀︎</kbd>
          <kbd class="kbd">▶︎</kbd>
        </:subtitle>
      </.header>
      <div tabindex="-1" phx-keydown="key_event">
        <svg width="640" height="480" xmlns="http://www.w3.org/2000/svg">
          <image href={@frame_path} />
          <text
            :for={ann <- @annotations}
            :if={@control_form[:show_bb].value}
            x={ann.bb_x1}
            y={ann.bb_y1 - 10}
            font-family="Arial"
            font-size="16"
            fill={@colors[ann.mouse_id]}
          >
            {ann.mouse_id}
          </text>
          <rect
            :for={ann <- @annotations}
            :if={@control_form[:show_bb].value}
            width={ann.bb_x2 - ann.bb_x1}
            height={ann.bb_y2 - ann.bb_y1}
            x={ann.bb_x1}
            y={ann.bb_y1}
            fill="none"
            stroke={@colors[ann.mouse_id]}
            stroke-width="2"
          />

          <%= if @control_form[:show_keypoints].value do %>
            <%= for ann <- @annotations do %>
              <circle r="3" cx={ann.nose_x} cy={ann.nose_y} fill="yellow" />
              <circle r="3" cx={ann.earL_x} cy={ann.earL_y} fill="orchid" />
              <circle r="3" cx={ann.earR_x} cy={ann.earR_y} fill="lightpink" />
              <circle r="3" cx={ann.tailB_x} cy={ann.tailB_y} fill="orange" />
            <% end %>
          <% end %>
        </svg>
      </div>
      <footer>
        <.button navigate={return_path(@return_to, @video)}>Back</.button>
      </footer>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:colors, %{
       1 => "red",
       2 => "gold",
       3 => "lawngreen",
       4 => "cyan",
       5 => "magenta"
     })
     |> assign_control_form(%{})
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    video = Videos.get_video!(id)

    socket
    |> assign(:video, video)
    |> assign(:annotations, [])
    |> assign_frame(1)
  end

  defp apply_action(socket, :new, _params) do
    video = %Video{}

    socket
    |> assign(:page_title, "New Video")
    |> assign(:video, video)
    |> assign(:form, to_form(Videos.change_video(video)))
  end

  @impl Phoenix.LiveView
  def handle_event(
        "control_change",
        %{"_target" => ["go_to_frame_button"], "go_to_frame" => frame},
        socket
      ) do
    {:noreply, assign_frame(socket, String.to_integer(frame))}
  end

  @impl Phoenix.LiveView
  def handle_event(
        "control_change",
        %{"_target" => ["go_to_time_button"], "go_to_time" => time},
        socket
      ) do
    {:ok, time} = Time.from_iso8601(time)
    {seconds, _} = Time.to_seconds_after_midnight(time)
    {:noreply, assign_frame(socket, seconds * 15)}
  end

  @impl Phoenix.LiveView
  def handle_event("control_change", params, socket) do
    {:noreply, assign_control_form(socket, params)}
  end

  @impl Phoenix.LiveView
  def handle_event("key_event", %{"ctrlKey" => false, "key" => "ArrowRight"}, socket) do
    {:noreply, inc_frame(socket)}
  end

  @impl Phoenix.LiveView
  def handle_event("key_event", %{"ctrlKey" => false, "key" => "ArrowLeft"}, socket) do
    {:noreply, dec_frame(socket)}
  end

  @impl Phoenix.LiveView
  def handle_event("key_event", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"video" => video_params}, socket) do
    save_video(socket, socket.assigns.live_action, video_params)
  end

  defp save_video(socket, :edit, video_params) do
    case Videos.update_video(socket.assigns.video, video_params) do
      {:ok, video} ->
        {:noreply,
         socket
         |> put_flash(:info, "Video updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, video))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_video(socket, :new, video_params) do
    case Videos.create_video(video_params) do
      {:ok, video} ->
        {:noreply,
         socket
         |> put_flash(:info, "Video created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, video))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _video), do: ~p"/videos"

  defp assign_frame(socket, frame) do
    frame_string =
      Integer.to_string(frame)
      |> String.pad_leading(5, "0")

    frame_path = "/videos/#{socket.assigns.video.name}_frames/#{frame_string}.jpg"

    socket
    |> assign(:frame, frame)
    |> assign(:frame_path, frame_path)
    |> assign(:annotations, Annotations.get_annotations(socket.assigns.video, frame))
  end

  defp inc_frame(socket) do
    new_frame = socket.assigns.frame + 1

    socket
    |> assign_frame(new_frame)
  end

  defp dec_frame(socket) do
    new_frame =
      case socket.assigns.frame do
        1 -> 1
        _ -> socket.assigns.frame - 1
      end

    socket
    |> assign_frame(new_frame)
  end

  defp assign_control_form(socket, params) do
    assign(socket,
      control_form:
        to_form(%{
          "show_bb" => Map.get(params, "show_bb", "true") |> String.to_existing_atom(),
          "show_keypoints" =>
            Map.get(params, "show_keypoints", "true") |> String.to_existing_atom(),
          "go_to_time" => Map.get(params, "go_to_time", "00:00:00")
        })
    )
  end
end
