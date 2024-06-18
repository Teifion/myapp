defmodule MyApp.Account.UserQueries do
  @moduledoc false
  use MyAppMacros, :queries
  alias MyApp.Account.User
  require Logger

  @spec user_query(MyApp.query_args()) :: Ecto.Query.t()
  def user_query(args) do
    query = from(users in User)

    query
    |> do_where(id: args[:id])
    |> do_where(args[:where])
    |> do_preload(args[:preload])
    |> do_order_by(args[:order_by])
    |> QueryHelper.query_select(args[:select])
    |> QueryHelper.limit_query(args[:limit] || 50)
  end

  @spec do_where(Ecto.Query.t(), list | map | nil) :: Ecto.Query.t()
  defp do_where(query, nil), do: query

  defp do_where(query, params) do
    params
    |> Enum.reduce(query, fn {key, value}, query_acc ->
      _where(query_acc, key, value)
    end)
  end

  @spec _where(Ecto.Query.t(), atom, any()) :: Ecto.Query.t()
  def _where(query, _, ""), do: query
  def _where(query, _, nil), do: query

  def _where(query, :id, id_list) do
    from(users in query,
      where: users.id in ^List.wrap(id_list)
    )
  end

  def _where(query, :name, name) do
    from(users in query,
      where: users.name == ^name
    )
  end

  def _where(query, :name_lower, value) do
    from(users in query,
      where: lower(users.name) == ^String.downcase(value)
    )
  end

  def _where(query, :email, email) do
    from(users in query,
      where: users.email == ^email
    )
  end

  def _where(query, :email_lower, value) do
    from(users in query,
      where: lower(users.email) == ^String.downcase(value)
    )
  end

  def _where(query, :name_or_email, value) do
    from(users in query,
      where: users.email == ^value or users.name == ^value
    )
  end

  def _where(query, :name_like, name) do
    uname = "%" <> name <> "%"

    from(users in query,
      where: ilike(users.name, ^uname)
    )
  end

  def _where(query, :basic_search, value) do
    from(users in query,
      where:
        ilike(users.name, ^"%#{value}%") or
          ilike(users.email, ^"%#{value}%")
    )
  end

  def _where(query, :inserted_after, timestamp) do
    from(users in query,
      where: users.inserted_at >= ^timestamp
    )
  end

  def _where(query, :inserted_before, timestamp) do
    from(users in query,
      where: users.inserted_at < ^timestamp
    )
  end

  def _where(query, :has_group, group_name) do
    from(users in query,
      where: ^group_name in users.groups
    )
  end

  def _where(query, :not_has_group, group_name) do
    from(users in query,
      where: ^group_name not in users.groups
    )
  end

  def _where(query, :has_permission, permission_name) do
    from(users in query,
      where: ^permission_name in users.permissions
    )
  end

  def _where(query, :not_has_permission, permission_name) do
    from(users in query,
      where: ^permission_name not in users.permissions
    )
  end

  @spec do_order_by(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_order_by(query, nil), do: query

  defp do_order_by(query, params) when is_list(params) do
    params
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _order_by(query_acc, key)
    end)
  end

  @spec _order_by(Ecto.Query.t(), any()) :: Ecto.Query.t()
  def _order_by(query, "Name (A-Z)") do
    from(users in query,
      order_by: [asc: users.name]
    )
  end

  def _order_by(query, "Name (Z-A)") do
    from(users in query,
      order_by: [desc: users.name]
    )
  end

  def _order_by(query, "Newest first") do
    from(users in query,
      order_by: [desc: users.inserted_at]
    )
  end

  def _order_by(query, "Oldest first") do
    from(users in query,
      order_by: [asc: users.inserted_at]
    )
  end

  @spec do_preload(Ecto.Query.t(), list | nil) :: Ecto.Query.t()
  defp do_preload(query, nil), do: query

  defp do_preload(query, preloads) do
    preloads
    |> List.wrap()
    |> Enum.reduce(query, fn key, query_acc ->
      _preload(query_acc, key)
    end)
  end

  def _preload(query, :tokens) do
    from(user in query,
      left_join: tokens in assoc(user, :tokens),
      preload: [tokens: tokens]
    )
  end
end
