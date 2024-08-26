defmodule MyAppWeb.General.HomeLive.Index do
  use MyAppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if socket.assigns.current_user do
      {:ok,
       socket
       |> assign(:site_menu_active, "home")}
    else
      {:ok, redirect(socket, to: ~p"/guest")}
    end
  end
end
