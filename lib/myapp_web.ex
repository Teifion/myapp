defmodule MyAppWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use MyAppWeb, :controller
      use MyAppWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(css js assets webfonts fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json],
        layouts: [html: MyAppWeb.Layouts]

      import Plug.Conn
      import MyAppWeb.Gettext

      unquote(verified_routes())
    end
  end

  def schema do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import MyApp.Account.AuthLib, only: [allow?: 2, allow_any?: 2]
      import MyApp.Helpers.SchemaHelper
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {MyAppWeb.Layouts, :app}

      import MyApp.Account.AuthLib,
        only: [
          allow?: 2,
          allow_any?: 2,
          allow_all?: 2,
          mount_require_all: 2,
          mount_require_any: 2
        ]

      alias MyApp.Helper.StylingHelper

      defguard is_connected?(socket) when socket.transport_pid != nil
      def ok(socket), do: {:ok, socket}
      def noreply(socket), do: {:noreply, socket}
      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components and translation
      import MyAppWeb.{CoreComponents, NavComponents}
      import MyAppWeb.Gettext

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS

      # Routes generation with the ~p sigil
      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: MyAppWeb.Endpoint,
        router: MyAppWeb.Router,
        statics: MyAppWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
