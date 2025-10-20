defmodule AppWeb.VideoLive.Show do
  use AppWeb, :live_view

  alias App.Videos

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Video {@video.id}
        <:subtitle>This is a video record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/videos"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/videos/#{@video}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit video
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@video.name}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Video")
     |> assign(:video, Videos.get_video!(id))}
  end
end
