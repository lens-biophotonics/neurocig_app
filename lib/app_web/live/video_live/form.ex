defmodule AppWeb.VideoLive.Form do
  use AppWeb, :live_view

  alias App.Videos
  alias App.Videos.Video

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage video records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="video-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Video</.button>
          <.button navigate={return_path(@return_to, @video)}>Cancel</.button>
        </footer>
      </.form>
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
    |> assign(:page_title, "Edit Video")
    |> assign(:video, video)
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
end
