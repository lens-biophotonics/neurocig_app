defmodule AppWeb.VideoLive.Form do
  use AppWeb, :live_view

  alias App.Videos
  alias App.Videos.Video

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div phx-window-keydown="key_event">
        <.header>
          {@video.name}
        </.header>

        <.form for={@form} id="video-form" phx-change="validate" phx-submit="save">
          <.input field={@form[:name]} type="text" label="Name" /> Frame: {@frame}

          <img src={@frame_path} />

          <footer>
            <.button navigate={return_path(@return_to, @video)}>Back</.button>
          </footer>
        </.form>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    video = Videos.get_video!(id)

    socket
    |> assign(:video, video)
    |> assign_frame(1)
    |> assign(:form, to_form(Videos.change_video(video)))
  end

  defp apply_action(socket, :new, _params) do
    video = %Video{}

    socket
    |> assign(:page_title, "New Video")
    |> assign(:video, video)
    |> assign(:form, to_form(Videos.change_video(video)))
  end

  @impl true
  def handle_event("validate", %{"video" => video_params}, socket) do
    changeset = Videos.change_video(socket.assigns.video, video_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
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
end
