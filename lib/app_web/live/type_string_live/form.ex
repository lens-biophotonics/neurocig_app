defmodule AppWeb.TypeStringLive.Form do
  use AppWeb, :live_view

  alias App.Behavior
  alias App.Behavior.TypeString

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage type_string records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="type_string-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:type_string]} type="text" label="Type string" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Type string</.button>
          <.button navigate={return_path(@return_to, @type_string)}>Cancel</.button>
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
    type_string = Behavior.get_type_string!(id)

    socket
    |> assign(:page_title, "Edit Type string")
    |> assign(:type_string, type_string)
    |> assign(:form, to_form(Behavior.change_type_string(type_string)))
  end

  defp apply_action(socket, :new, _params) do
    type_string = %TypeString{}

    socket
    |> assign(:page_title, "New Type string")
    |> assign(:type_string, type_string)
    |> assign(:form, to_form(Behavior.change_type_string(type_string)))
  end

  @impl true
  def handle_event("validate", %{"type_string" => type_string_params}, socket) do
    changeset = Behavior.change_type_string(socket.assigns.type_string, type_string_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"type_string" => type_string_params}, socket) do
    save_type_string(socket, socket.assigns.live_action, type_string_params)
  end

  defp save_type_string(socket, :edit, type_string_params) do
    case Behavior.update_type_string(socket.assigns.type_string, type_string_params) do
      {:ok, type_string} ->
        {:noreply,
         socket
         |> put_flash(:info, "Type string updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, type_string))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_type_string(socket, :new, type_string_params) do
    case Behavior.create_type_string(type_string_params) do
      {:ok, type_string} ->
        {:noreply,
         socket
         |> put_flash(:info, "Type string created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, type_string))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _type_string), do: ~p"/behavior/type_strings"
  defp return_path("show", type_string), do: ~p"/behavior/type_strings/#{type_string}"
end
