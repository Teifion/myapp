defmodule MyApp do
  @moduledoc """
  MyApp
  """

  @type user_id :: MyApp.Account.User.id()

  @spec uuid() :: String.t()
  def uuid() do
    Ecto.UUID.generate()
  end

  # PubSub delegation
  alias MyApp.Helpers.PubSubHelper

  @doc false
  @spec broadcast(String.t(), map()) :: :ok
  defdelegate broadcast(topic, message), to: PubSubHelper

  @doc false
  @spec subscribe(String.t()) :: :ok
  defdelegate subscribe(topic), to: PubSubHelper

  @doc false
  @spec unsubscribe(String.t()) :: :ok
  defdelegate unsubscribe(topic), to: PubSubHelper

  # Cluster cache delegation
  @spec invalidate_cache(atom, any) :: :ok
  defdelegate invalidate_cache(table, key_or_keys), to: MyApp.CacheClusterServer
end
