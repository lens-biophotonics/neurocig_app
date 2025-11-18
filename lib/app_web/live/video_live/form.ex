defmodule AppWeb.VideoLive.Form do
  alias App.Annotations
  use AppWeb, :live_view

  alias App.Videos
  alias App.Videos.Video

  alias App.Corrections

  import Phoenix.Component

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="grid grid-cols-2 gap-4 h-[92dvh]">
        <div>
          <.header :if={@video}>
            {@video.name}
            <:subtitle>
              To move frame by frame, click on the image then use the keyboard arrow keys
              <kbd class="kbd">◀︎</kbd>
              <kbd class="kbd">▶︎</kbd>.
            </:subtitle>
          </.header>

          <.video_frame
            show_bb={@control_form[:show_bb].value == true}
            show_keypoints={@control_form[:show_keypoints].value == true}
            annotations={@annotations && @annotations.ok? && (@annotations.result[@frame] || %{})}
            frame_path={@frame_path}
            corrected={@control_form[:show_corrected].value == "true"}
          />
          <.async_result :if={@loading && @loading.result == true} assign={@loading}>
            Loading annotations...<.progress />
            <:failed :let={_failure}>there was an error loading the annotations</:failed>
          </.async_result>
          <.async_result :let={maxframe} :if={@maxframe} assign={@maxframe}>
            <div class="flex">
              <div class="flex-1">
                Time: <span>{Time.from_seconds_after_midnight(Integer.floor_div(@frame, 15))}</span>
                / <span>{Time.from_seconds_after_midnight(Integer.floor_div(maxframe, 15))}</span>
              </div>

              <div class="flex-1 text-right">Frame: {@frame} / {maxframe}</div>
            </div>
          </.async_result>
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
            max={@maxframe && @maxframe.ok? && @maxframe.result}
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
          <.fieldset class="flex mt-2">
            <.label for="show-original-radio">
              <.input
                id="show-original-radio"
                form="control-form"
                type="radio"
                name={@control_form[:show_corrected].name}
                value="false"
                checked={@control_form[:show_corrected].value == "false"}
              /> Show original
            </.label>
            <.label for="show-corrected-radio">
              <.input
                id="show-corrected-radio"
                form="control-form"
                type="radio"
                name={@control_form[:show_corrected].name}
                value="true"
                checked={@control_form[:show_corrected].value == "true"}
              /> Show corrected
            </.label>
          </.fieldset>
          <.live_component
            id="graph"
            module={AppWeb.VideoLive.Graph}
          />
        </div>

        <div class="h-full overflow-y-auto">
          <.header>Corrections</.header>
          <.live_component
            id="correction-table"
            module={AppWeb.VideoLive.CorrectionTable}
            frame={@frame}
            maxframe={@maxframe && @maxframe.ok? && @maxframe.result}
            video={@video}
            corrections={@corrections}
            notify_changed={fn _ -> send(self(), :corrections_changed) end}
          />
        </div>
      </div>
    </Layouts.app>
    """
  end

  attr :frame_path, :string, required: true
  attr :annotations, :map, default: %{}
  attr :show_bb, :boolean, default: false
  attr :show_keypoints, :boolean, default: true
  attr :corrected, :boolean, default: false

  defp video_frame(assigns) do
    get_mouse_id =
      if assigns.corrected do
        fn ann -> ann.new_mouse_id end
      else
        fn ann -> ann.mouse_id end
      end

    assigns =
      assign(assigns,
        colors: %{
          1 => "red",
          2 => "gold",
          3 => "lawngreen",
          4 => "cyan",
          5 => "magenta"
        },
        annotations: assigns.annotations || %{},
        get_mouse_id: get_mouse_id
      )

    ~H"""
    <div :if={@frame_path} tabindex="-1" phx-keydown="key_event">
      <svg width="640" height="480" viewBox="0 0 640 480" xmlns="http://www.w3.org/2000/svg">
        <image href={@frame_path} />
        <text
          :for={{_mouse_id, ann} <- @annotations}
          :if={@show_bb}
          x={ann.bb_x1}
          y={ann.bb_y1 - 10}
          font-family="Arial"
          font-size="16"
          fill={@colors[@get_mouse_id.(ann)]}
        >
          {@get_mouse_id.(ann)}
        </text>
        <rect
          :for={{mouse_id, ann} <- @annotations}
          :if={@show_bb}
          width={ann.bb_x2 - ann.bb_x1}
          height={ann.bb_y2 - ann.bb_y1}
          x={ann.bb_x1}
          y={ann.bb_y1}
          fill="none"
          stroke={@colors[@get_mouse_id.(ann)]}
          stroke-width="2"
        />
        <rect
          width="106"
          height="92"
          x="364"
          y="139"
          fill="none"
          stroke-width="2"
        >
        </rect>
        <%= if @show_keypoints do %>
          <%= for {_mouse_id, ann} <- @annotations do %>
            <.keypoint cx={ann.nose_x} cy={ann.nose_y} color="yellow" />
            <.keypoint cx={ann.earL_x} cy={ann.earL_y} color="orchid" />
            <.keypoint cx={ann.earR_x} cy={ann.earR_y} color="lightpink" />
            <.keypoint cx={ann.tailB_x} cy={ann.tailB_y} color="orange" />
          <% end %>
        <% end %>
      </svg>
    </div>
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
     |> assign_control_form(%{
       "show_bb" => "true",
       "show_keypoints" => "true",
       "show_corrected" => "true"
     })
     |> assign(
       annotations: nil,
       corrections: [],
       frame: nil,
       video: nil,
       maxframe: nil,
       loading: nil
     )
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> maybe_assign_video(id)
    |> assign_frame(1)
  end

  @impl Phoenix.LiveView
  def handle_info(:corrections_changed, socket) do
    {:noreply, assign_corrections(socket)}
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

  @impl Phoenix.LiveView
  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  defp assign_frame(socket, frame) when is_integer(frame) do
    frame_string =
      Integer.to_string(frame)
      |> String.pad_leading(5, "0")

    video_path = Application.get_env(:app, :neurocig)[:video_serve_path]

    frame_path = "#{video_path}/#{socket.assigns.video.name}_frames/#{frame_string}.jpg"

    socket
    |> assign(:frame, frame)
    |> assign(:frame_path, frame_path)
  end

  defp maybe_assign_video(socket, video_id) do
    video = socket.assigns.video || %Video{}

    if video.id != video_id do
      video = Videos.get_video!(video_id)
      corrections = Corrections.list_corrections_by_video(video)

      socket =
        assign(socket, video: video, corrections: corrections)

      if Phoenix.LiveView.connected?(socket) do
        socket
        |> assign_async([:loading], fn -> {:ok, %{loading: true}} end)
        |> assign_async([:annotations, :maxframe], fn ->
          ann = Annotations.load_annotations(video)

          {:ok,
           %{
             loading: false,
             annotations: apply_corrections_to_annotations(corrections, ann),
             maxframe: Enum.max(Map.keys(ann))
           }}
        end)
        |> push_event("load-graph", %{id: "graph", video: video.name})
      else
        socket
      end
    else
      socket
    end
  end

  defp assign_corrections(socket) do
    corrections = Corrections.list_corrections_by_video(socket.assigns.video)
    annotations = socket.assigns.annotations.result

    socket =
      if annotations do
        socket
        |> assign_async([:loading], fn -> {:ok, %{loading: true}} end)
        |> assign_async([:annotations], fn ->
          {:ok,
           %{
             loading: false,
             annotations: apply_corrections_to_annotations(corrections, annotations)
           }}
        end)
      else
        socket
      end

    socket
    |> assign(corrections: corrections)
  end

  defp apply_corrections_to_annotations(corrections, annotations) do
    annotations = reset_corrections(annotations)
    Enum.reduce(corrections, annotations, &apply_correction/2)
  end

  defp reset_corrections(annotations) do
    Enum.reduce(Map.keys(annotations), annotations, fn frame, annotations ->
      Enum.reduce(Map.keys(annotations[frame]), annotations, fn mouse_id, annotations ->
        update_in(annotations[frame][mouse_id], fn ann -> %{ann | new_mouse_id: ann.mouse_id} end)
      end)
    end)
  end

  defp apply_correction(corr, annotations) do
    Enum.reduce(
      Map.keys(annotations) |> Enum.filter(&(&1 >= corr.frame)),
      annotations,
      fn frame, acc ->
        if Map.has_key?(acc, frame) and Map.has_key?(acc[frame], corr.mouse_from) and
             Map.has_key?(acc[frame], corr.mouse_to) do
          {_, found_from} =
            Enum.find(acc[frame], fn {_m_id, ann} -> ann.new_mouse_id == corr.mouse_from end)

          {_, found_to} =
            Enum.find(acc[frame], fn {_m_id, ann} -> ann.new_mouse_id == corr.mouse_to end)

          acc =
            update_in(acc[frame][found_from.mouse_id], fn ann ->
              %{ann | new_mouse_id: corr.mouse_to}
            end)

          acc =
            update_in(acc[frame][found_to.mouse_id], fn ann ->
              %{ann | new_mouse_id: corr.mouse_from}
            end)

          acc
        else
          acc
        end
      end
    )
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
    params =
      params
      |> put_in(["show_bb"], Map.get(params, "show_bb", "false") |> String.to_existing_atom())
      |> put_in(
        ["show_keypoints"],
        Map.get(params, "show_keypoints", "false") |> String.to_existing_atom()
      )
      |> put_in(["go_to_time"], Map.get(params, "go_to_time", "00:00:00"))

    assign(socket, control_form: to_form(params))
  end
end
