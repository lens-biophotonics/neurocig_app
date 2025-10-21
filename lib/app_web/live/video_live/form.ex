defmodule AppWeb.VideoLive.Form do
  alias App.Annotations
  use AppWeb, :live_view

  alias App.Videos
  alias App.Videos.Video

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header :if={@video}>
        {@video.name}
        <:subtitle>
          To move frame by frame, click on the image then use the keyboard arrow keys
          <kbd class="kbd">◀︎</kbd>
          <kbd class="kbd">▶︎</kbd>.
        </:subtitle>
      </.header>

      <div :if={@frame == nil}>Loading annotations... <.progress /></div>

      <div :if={@frame && @annotations} tabindex="-1" phx-keydown="key_event">
        <svg width="640" height="480" xmlns="http://www.w3.org/2000/svg">
          <image href={@frame_path} />
          <text
            :for={{mouse_id, ann} <- @annotations[@frame] || %{}}
            :if={@control_form[:show_bb].value == true}
            x={ann.bb_x1}
            y={ann.bb_y1 - 10}
            font-family="Arial"
            font-size="16"
            fill={@colors[mouse_id]}
          >
            {ann.mouse_id}
          </text>
          <rect
            :for={{mouse_id, ann} <- @annotations[@frame] || %{}}
            :if={@control_form[:show_bb].value == true}
            width={ann.bb_x2 - ann.bb_x1}
            height={ann.bb_y2 - ann.bb_y1}
            x={ann.bb_x1}
            y={ann.bb_y1}
            fill="none"
            stroke={@colors[mouse_id]}
            stroke-width="2"
          />
          <%= if @control_form[:show_keypoints].value == true do %>
            <%= for {_mouse_id, ann} <- @annotations[@frame] || %{} do %>
              <.keypoint cx={ann.nose_x} cy={ann.nose_y} color="yellow" />
              <.keypoint cx={ann.earL_x} cy={ann.earL_y} color="orchid" />
              <.keypoint cx={ann.earR_x} cy={ann.earR_y} color="lightpink" />
              <.keypoint cx={ann.tailB_x} cy={ann.tailB_y} color="orange" />
            <% end %>
          <% end %>
        </svg>
        <div class="flex">
          <div class="flex-1">
            Time: <span>{Time.from_seconds_after_midnight(Integer.floor_div(@frame, 15))}</span>
            / <span>{Time.from_seconds_after_midnight(Integer.floor_div(@maxframe, 15))}</span>
          </div>

          <div class="flex-1 text-right">Frame: {@frame} / {@maxframe}</div>
        </div>
      </div>

      <.form
        for={@control_form}
        id="control-form"
        phx-change="control_change"
        phx-submit="control_change"
      >
      </.form>
      <.input
        type="range"
        form="control-form"
        field={@control_form[:frame]}
        min="1"
        max={@maxframe}
        value={@frame}
      />
      <div class="flex gap-4 items-center">
        <.input
          type="toggle"
          form="control-form"
          field={@control_form[:show_bb]}
          label="Show bounding boxes"
        />
        <.input
          type="toggle"
          form="control-form"
          field={@control_form[:show_keypoints]}
          label="Show keypoints"
        />
        <.input
          type="number"
          form="control-form"
          phx-keydown="go_to_frame"
          phx-key="Enter"
          field={@control_form[:go_to_frame]}
          label="Go to frame"
        />
        <.input
          type="time"
          form="control-form"
          phx-keydown="go_to_time"
          phx-key="Enter"
          field={@control_form[:go_to_time]}
          step="1"
          label="Go to time"
        />
      </div>
      <.live_component
        id="correction-table"
        module={AppWeb.VideoLive.CorrectionTable}
        video={@video}
        }
      />
    </Layouts.app>
    """
  end

  defp keypoint(assigns) do
    ~H"""
    <circle :if={@cx && @cy} r="3" cx={@cx} cy={@cy} fill={@color} />
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:colors, %{
       1 => "red",
       2 => "gold",
       3 => "lawngreen",
       4 => "cyan",
       5 => "magenta"
     })
     |> assign_control_form(%{"show_bb" => "true", "show_keypoints" => "true"})
     |> assign(annotations: %{}, frame: nil, video: nil, maxframe: nil)
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    if Phoenix.LiveView.connected?(socket) do
      socket
      |> maybe_assign_video(id)
      |> assign_frame(1)
    else
      socket
    end
  end

  @impl Phoenix.LiveView
  def handle_event("control_change", %{"_target" => ["frame"], "frame" => frame}, socket) do
    {:noreply, assign_frame(socket, String.to_integer(frame))}
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
  def handle_event("go_to_frame", %{"value" => frame}, socket) do
    {:noreply, assign_frame(socket, String.to_integer(frame))}
  end

  @impl Phoenix.LiveView
  def handle_event("go_to_time", %{"value" => time}, socket) do
    {:ok, time} = Time.from_iso8601(time)
    {seconds, _} = Time.to_seconds_after_midnight(time)

    frame =
      case seconds * 15 do
        frame when frame > 0 -> frame
        _ -> 1
      end

    {:noreply, assign_frame(socket, frame)}
  end

  @impl Phoenix.LiveView
  def handle_event("key_event", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("save", %{"video" => video_params}, socket) do
    save_video(socket, socket.assigns.live_action, video_params)
  end

  @impl Phoenix.LiveView
  def handle_event(_event, _params, socket) do
    {:noreply, socket}
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

  defp assign_frame(socket, frame) when is_integer(frame) do
    frame_string =
      Integer.to_string(frame)
      |> String.pad_leading(5, "0")

    frame_path = "/videos/#{socket.assigns.video.name}_frames/#{frame_string}.jpg"

    socket
    |> assign(:frame, frame)
    |> assign(:frame_path, frame_path)
  end

  defp maybe_assign_video(socket, video_id) do
    video = socket.assigns.video || %Video{}

    if video.id != video_id do
      video = Videos.get_video!(video_id)
      ann = Annotations.load_annotations(video)

      socket
      |> assign(:video, video)
      |> assign(:annotations, ann)
      |> assign(:maxframe, Enum.max(Map.keys(ann)))
    else
      socket
    end
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
          "show_bb" => Map.get(params, "show_bb", "false") |> String.to_existing_atom(),
          "show_keypoints" =>
            Map.get(params, "show_keypoints", "false") |> String.to_existing_atom(),
          "go_to_time" => Map.get(params, "go_to_time", "00:00:00")
        })
    )
  end
end
