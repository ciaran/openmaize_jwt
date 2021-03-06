defmodule OpenmaizeJWT.Plug do
  @moduledoc """
  Generate JSON Web Tokens (JWTs) and add them to the connection.

  ## Storage of JSON Web Tokens

  The JWTs need to be stored somewhere, either in cookies or sessionStorage
  (or localStorage), so that they can be used in subsequent requests.
  If you want to store the token in sessionStorage, you will need to add
  the token to sessionStorage with the front-end framework you are using
  and add the token to the request headers for each request.

  If you decide to store the token in sessionStorage, and not in a cookie,
  you will not need to use the `protect_from_forgery` (csrf protection) plug.
  However, storing tokens in sessionStorage opens up the risk of cross-site
  scripting attacks.
  """

  import Plug.Conn
  import OpenmaizeJWT.Create
  alias OpenmaizeJWT.Config

  @doc """
  Generate JWT based on the user information.

  The JWT is then either stored in a cookie or added to the body of the
  response.
  """
  def add_token(conn, user, storage, uniq, override_exp \\ nil) do
    token_validity = override_exp || Config.token_validity
    user = Map.take(user, [:id, :role, uniq]) |> Map.merge(Config.token_data)
    {:ok, token} = generate_token user, {0, token_validity}
    put_token(conn, user, token, storage, token_validity)
  end

  defp put_token(conn, user, token, :cookie, validity) do
    opts = [http_only: true, max_age: validity * 60]
    put_resp_cookie(conn, "access_token", token, opts)
    |> put_private(:openmaize_user, user)
  end
  defp put_token(conn, user, token, nil, _) do
    resp(conn, 200, ~s({"access_token": "#{token}"}))
    |> put_private(:openmaize_user, user)
  end
end
