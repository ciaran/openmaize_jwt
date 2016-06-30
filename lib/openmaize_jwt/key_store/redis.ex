defmodule OpenmaizeJWT.KeyStore.Redis do
  import Exredis
  import Exredis.Api

  @behaviour OpenmaizeJWT.KeyStore

  defp client() do
    start_link() |> elem(1)
  end

  def load do
    client() |> load()
  end

  def save(state) do
    client() |> save(state)
  end

  defp load({:connection_error, _}),
    do: nil
  defp load(client) do
    case get(client, :auth_state) do
      :undefined -> nil
      state -> Poison.decode!(state)
    end
  end

  defp save({:connection_error, _}, _),
    do: nil
  defp save(client, state) do
    set(client, :auth_state, Poison.encode!(state))
  end
end
