defmodule OpenmaizeJWT.KeyStore.File do
  @behaviour OpenmaizeJWT.KeyStore

  @store_path Path.join(Application.app_dir(:openmaize_jwt, "priv"), "key_state.json")

  def load do
    state =
      case File.read(@store_path) do
        {:ok, state} -> Poison.decode!(state)
        {:error, _} -> nil
      end
    File.rm @store_path
    state
  end

  def save(state) do
    File.write(@store_path, Poison.encode!(state))
  end
end
