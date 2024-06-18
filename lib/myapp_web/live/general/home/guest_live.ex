defmodule MyAppWeb.General.HomeLive.Guest do
  use MyAppWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(user_agent: get_connect_info(socket, :user_agent))
      |> assign(address: get_connect_info(socket, :peer_data) |> Map.get(:address))

    if socket.assigns.current_user do
      {:ok, redirect(socket, to: ~p"/")}
    else
      {:ok, socket}
    end
  end

  @impl true
  def handle_event("guest-account", _, socket) do
    name = MyApp.Account.generate_guest_name()

    {:ok, user} = MyApp.Account.create_user(%{
      "name" => name,
      "email" => "#{String.replace(name, " ", "")}@somedomain",
      "password" => MyApp.Account.generate_password()
    })

    user_agent = socket.assigns.user_agent
    ip = socket.assigns.address |> Tuple.to_list() |> Enum.join(".")

    {:ok, token} = MyApp.Account.create_user_token(user.id, "web", user_agent, ip)

    code = Ecto.UUID.generate()
    Cachex.put(:one_time_login_code, code, token.id)

    {:noreply, redirect(socket, to: ~p"/login/#{code}")}
  end
end
