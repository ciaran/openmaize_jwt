defmodule OpenmaizeJWT.KeyStore do
  @callback load() :: Map
  @callback save(Map) :: :ok | {:error, String.t}
end
