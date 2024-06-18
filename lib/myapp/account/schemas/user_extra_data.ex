defmodule MyApp.Account.ExtraUserData do
  @moduledoc """
  A blob of extra key-values for each user. Intended to be used as an easy to
  extend object which doesn't need to be queried quite as often as users.
  """
  use MyAppMacros, :schema

  @primary_key false
  schema "account_extra_user_data" do
    belongs_to(:user, MyApp.Account.User, primary_key: true, type: Ecto.UUID)
    field(:data, :map, default: %{})
  end

  @doc false
  def changeset(stats, attrs \\ %{}) do
    stats
    |> cast(attrs, [:user_id, :data])
    |> validate_required([:user_id, :data])
  end
end
