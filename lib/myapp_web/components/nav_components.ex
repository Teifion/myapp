defmodule MyAppWeb.NavComponents do
  @moduledoc false
  use Phoenix.Component

  # import MyApp.Account.AuthLib, only: [allow?: 2, allow_any?: 2, allow_all?: 2]

  use Phoenix.VerifiedRoutes,
    endpoint: MyAppWeb.Endpoint,
    router: MyAppWeb.Router,
    statics: MyAppWeb.static_paths()

  @doc """
  <MyAppWeb.NavComponents.top_nav_item active={active} route={route} icon={icon} />
  """
  def top_nav_item(assigns) do
    active = if assigns[:active], do: "active", else: ""

    assigns =
      assigns
      |> assign(:active, active)

    ~H"""
    <li class="nav-item">
      <a class={"nav-link #{@active}"} href={@route}>
        <%= if assigns[:icon] do %>
          <i class={"fa-fw #{@icon}"}></i>
        <% end %>
        <%= @text %>
      </a>
    </li>
    """
  end

  @doc """
  <MyAppWeb.NavComponents.top_navbar current_user={@current_user} active={"string"} />
  """
  attr :current_user, :map, required: true
  attr :active, :string, required: true

  def top_navbar(assigns) do
    ~H"""
    <nav class="navbar navbar-expand-lg m-0 p-0" id="top-nav">
      <!-- Container wrapper -->
      <div class="container-fluid">
        <!-- Collapsible wrapper -->
        <div class="collapse navbar-collapse" id="navbarSupportedContent">
          <!-- Navbar brand -->
          <a class="navbar-brand mt-2 mt-lg-0" href="/">
            <i
              class={"fa-fw #{Application.get_env(:myapp, MyApp)[:site_icon]}"}
              style="margin: -4px 20px 0 0px;"
            >
            </i>
            <span id="page-title"></span>
          </a>
          <!-- Left links -->
          <ul class="navbar-nav me-auto mb-2 mb-lg-0">
            <.top_nav_item text="Home" active={@active == "home"} route={~p"/"} />

            <.top_nav_item text="Readme" active={@active == "readme"} route={~p"/readme"} />
          </ul>
          <!-- Left links -->
        </div>
        <!-- Collapsible wrapper -->

        <!-- Right elements -->
        <div class="d-flex align-items-center">
          <%= if @current_user do %>
            <MyAppWeb.UserComponents.recents_dropdown current_user={@current_user} />
            <MyAppWeb.UserComponents.account_dropdown current_user={@current_user} />
          <% else %>
            <a class="nav-link" href={~p"/login"}>
              Sign in
            </a>
          <% end %>
        </div>
        <!-- Right elements -->
      </div>
    </nav>
    """
  end

  @doc """
  <.tab_header>
    <.tab_nav tab="h1">Header 1</.tab_nav>
    <.tab_nav tab="h2">Header 2</.tab_nav>
    <.tab_nav tab="h3">Header 3</.tab_nav>
  </.tab_header>
  """
  # attr :selected, :string, required: :true
  slot :inner_block, required: true

  def tab_header(assigns) do
    ~H"""
    <ul class="nav nav-tabs" role="tablist">
      <%= render_slot(@inner_block) %>
    </ul>
    """
  end

  attr :selected, :boolean, required: true
  attr :url, :string, required: true
  slot :inner_block, required: true

  def tab_nav(assigns) do
    assigns =
      assigns
      |> assign(:active_class, if(assigns[:selected], do: "active"))

    ~H"""
    <li class="nav-item">
      <.link patch={@url} class={"nav-link #{@active_class}"}>
        <%= render_slot(@inner_block) %>
      </.link>
    </li>
    """
  end

  @doc """
  <.menu_card
    icon="icon"
    url={~p""}
    size={:auto | :small | :medium | :large | nil}
  >
    Text here
  </.menu_card>
  """
  attr :url, :string, default: nil
  attr :icon, :string, required: true
  attr :icon_class, :string, default: "duotone"
  attr :size, :atom, default: nil
  attr :dynamic_attrs, :map, default: []
  attr :col_classes, :string, default: nil
  slot :inner_block, required: true

  def menu_card(assigns) do
    style =
      cond do
        assigns[:disabled] -> "color: #888; cursor: default;"
        assigns[:style] -> assigns[:style]
        true -> ""
      end

    extra_classes = assigns[:class] || ""

    col_classes =
      case assigns[:size] do
        :auto -> "col"
        :small -> "col-sm-6 col-md-4 col-lg-2 col-xl-1 col-xxl-1"
        :medium -> "col-sm-6 col-md-4 col-lg-3 col-xl-2 col-xxl-1"
        :large -> "col-sm-6 col-md-6 col-lg-4 col-xl-3 col-xxl-2"
        nil -> assigns[:col_classes] || "col-sm-6 col-md-4 col-lg-3 col-xl-2 col-xxl-1"
      end

    icon_size =
      case assigns[:size] do
        :small -> "fa-3x"
        :auto -> "fa-4x"
        :medium -> "fa-4x"
        :large -> "fa-6x"
        nil -> assigns[:icon_size] || "fa-4x"
      end

    assigns =
      assigns
      |> assign(:col_classes, col_classes)
      |> assign(:extra_classes, extra_classes)
      |> assign(:icon_size, icon_size)
      |> assign(:style, style)

    ~H"""
    <div class={"#{@col_classes} menu-card #{@extra_classes}"} {@dynamic_attrs}>
      <a href={@url} class="block-link" style={@style}>
        <Fontawesome.icon icon={@icon} style={@icon_class} size={@icon_size} /><br />
        <%= render_slot(@inner_block) %>
      </a>
    </div>
    """
  end

  @doc """
  <.sub_menu_button bsname={bsname} icon={lib} active={true/false} url={url}>
    Text goes here
  </.sub_menu_button>
  """
  attr :icon, :string, default: nil
  attr :url, :string, required: true
  attr :bsname, :string, default: "secondary"
  attr :active, :boolean, default: false
  slot :inner_block, required: true

  def sub_menu_button(assigns) do
    assigns =
      assigns
      |> assign(:active_class, if(assigns[:active], do: "active"))

    ~H"""
    <div class="col sub-menu-icon">
      <a href={@url} class={"block-link #{@active_class}"}>
        <Fontawesome.icon
          :if={@icon}
          icon={@icon}
          style={if @active, do: "solid", else: "regular"}
          size="2x"
        /><br />
        <%= render_slot(@inner_block) %>
      </a>
    </div>
    """
  end

  @doc """
  <.section_menu_button bsname={bsname} icon={lib} active={true/false} url={url}>
    Text goes here
  </.section_menu_button>
  """
  attr :icon, :string, default: nil
  attr :url, :string, required: true
  attr :bsname, :string, default: "secondary"
  attr :active, :boolean, default: false
  slot :inner_block, required: true

  def section_menu_button(assigns) do
    assigns =
      assigns
      |> assign(:active_class, if(assigns[:active], do: "active"))

    ~H"""
    <.link navigate={@url} class={"btn btn-outline-#{@bsname} #{@active_class}"}>
      <Fontawesome.icon :if={@icon} icon={@icon} style={if @active, do: "solid", else: "regular"} />
      &nbsp; <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  @doc """
  <.section_menu_button bsname={bsname} icon={lib} active={true/false} url={url}>
    Text goes here
  </.section_menu_button>

  <.section_menu_button
      bsname={@view_colour}
      icon={StylingHelper.icon(:list)}
      active={@active == "index"}
      url={~p"/account/relationship"}
    >
      List
    </.section_menu_button>
  """
  attr :icon, :string, default: nil
  attr :url, :string, required: true
  attr :bsname, :string, default: "secondary"
  attr :active, :boolean, default: false
  slot :inner_block, required: true

  def section_menu_button_patch(assigns) do
    assigns =
      assigns
      |> assign(:active_class, if(assigns[:active], do: "active"))

    ~H"""
    <.link patch={@url} class={"btn btn-outline-#{@bsname} #{@active_class}"}>
      <Fontawesome.icon :if={@icon} icon={@icon} style={if @active, do: "solid", else: "regular"} />
      <%= render_slot(@inner_block) %>
    </.link>
    """
  end

  @doc """
  <.breadcrumb_trail trails={@breadcrumb_trails} />
  """
  def breadcrumb_trail(assigns) do
    ~H"""
    <nav class="navbar navbar-expand-lg" id="breadcrumb-wrapper" aria-label="breadcrumb">
      <div class="container-fluid">
        <nav aria-label="breadcrumb">
          <%= for breadcrumb_trail <- @trails do %>
            <ol class="breadcrumb">
              <%= for breadcrumb <- breadcrumb_trail do %>
                <%= if breadcrumb[:url] == "#" do %>
                  <li class="breadcrumb-item active" aria-current="page">
                    <a href={breadcrumb[:url]}><%= breadcrumb[:name] %></a>
                  </li>
                <% else %>
                  <li class="breadcrumb-item">
                    <a href={breadcrumb[:url]}><%= breadcrumb[:name] %></a>
                  </li>
                <% end %>
              <% end %>
            </ol>
          <% end %>
        </nav>

        <%= if assigns[:breadcrumb_extra] do %>
          <div id="breadcrumb-right">
            <%= assigns[:breadcrumb_extra] %>
          </div>
        <% end %>
      </div>
    </nav>
    """
  end

  @doc """
  <MyAppWeb.NavComponents.ward_nav_item active={active} route={route} icon={icon} />
  """
  def ward_nav_item(assigns) do
    active = if assigns[:active], do: "btn-primary", else: "btn-outline-info"

    assigns =
      assigns
      |> assign(:active, active)

    ~H"""
    <.link
      patch={@route}
      class={"btn #{@active}"}
    >
      <Fontawesome.icon icon={@icon} style="solid" />
      <%= @text %>
    </.link>
    """
  end

  @doc """
  <MyAppWeb.NavComponents.ward_navbar game_id={@game_id} active={"string"} />
  """
  attr :active, :string, required: true
  attr :game_id, :string, required: true

  def ward_navbar(assigns) do
    ~H"""
    <div class="">
      <.ward_nav_item text="Ward" active={@active == "ward"} route={~p"/play/ward/#{@game_id}"} icon="stretcher" />

      <.ward_nav_item text="Patients" active={@active == "patients"} route={~p"/play/patients/#{@game_id}"} icon="users-medical" />
    </div>
    """
  end
end
