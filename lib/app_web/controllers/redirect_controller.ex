defmodule AppWeb.RedirectController do
  @moduledoc false

  use AppWeb, :controller

  def redirect_to_videos(conn, _params) do
    conn
    |> Phoenix.Controller.redirect(to: ~p"/videos")
    |> Plug.Conn.halt()
  end
end
