defmodule AppWeb.TypeStringLive.Index do
  use AppWeb, :live_view

  alias App.Behavior

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Type strings
        <:actions>
          <.button variant="primary" navigate={~p"/behavior/type_strings/new"}>
            <.icon name="hero-plus" /> New Type string
          </.button>
        </:actions>
      </.header>

      <.table
        id="type_strings"
        rows={@streams.type_strings}
        row_click={
          fn {_id, type_string} -> JS.navigate(~p"/behavior/type_strings/#{type_string}") end
        }
      >
        <:col :let={{_id, type_string}} label="Type string">{type_string.type_string}</:col>
        <:action :let={{_id, type_string}}>
          <div class="sr-only">
            <.link navigate={~p"/behavior/type_strings/#{type_string}"}>Show</.link>
          </div>
          <.link navigate={~p"/behavior/type_strings/#{type_string}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, type_string}}>
          <.link
            phx-click={JS.push("delete", value: %{id: type_string.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Type strings")
     |> stream(:type_strings, list_type_strings())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    type_string = Behavior.get_type_string!(id)
    {:ok, _} = Behavior.delete_type_string(type_string)

    {:noreply, stream_delete(socket, :type_strings, type_string)}
  end

  defp list_type_strings() do
    Behavior.list_type_strings()
  end
end
