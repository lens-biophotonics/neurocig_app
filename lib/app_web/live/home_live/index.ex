defmodule AppWeb.HomeLive.Index do
  use AppWeb, :live_view

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div>
        <.link href={~p"/videos"}><.button>Videos</.button></.link>
        <.link href={~p"/behavior/type_strings"}><.button>Behavior strings</.button></.link>
      </div>
    </Layouts.app>
    """
  end
end
