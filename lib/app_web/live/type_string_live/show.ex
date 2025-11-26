defmodule AppWeb.TypeStringLive.Show do
  use AppWeb, :live_view

  alias App.Behavior

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Type string {@type_string.id}
        <:subtitle>This is a type_string record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/behavior/type_strings"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            variant="primary"
            navigate={~p"/behavior/type_strings/#{@type_string}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit type_string
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Type string">{@type_string.type_string}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Type string")
     |> assign(:type_string, Behavior.get_type_string!(id))}
  end
end
