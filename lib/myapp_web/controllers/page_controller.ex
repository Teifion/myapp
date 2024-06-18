defmodule MyAppWeb.PageController do
  use MyAppWeb, :controller

  def readme(conn, _params) do
    render(conn, :readme, site_menu_active: "readme")
  end
end
