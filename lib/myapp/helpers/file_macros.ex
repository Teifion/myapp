defmodule MyAppMacros do
  @moduledoc """
  A set of macros for defining common file types.

  This can be used in your application as:

      use MyAppMacros, :queries
      use MyAppMacros, :library
  """

  def queries do
    quote do
      import Ecto.Query, warn: false
      import MyApp.Helpers.QueryMacros
      alias MyApp.Helpers.QueryHelper
      alias MyApp.Repo
    end
  end

  def library do
    quote do
      alias MyApp.Repo
    end
  end

  def schema do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      alias MyApp.Helpers.SchemaHelper
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
