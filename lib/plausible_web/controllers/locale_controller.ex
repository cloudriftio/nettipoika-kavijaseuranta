defmodule PlausibleWeb.LocaleController do
  use PlausibleWeb, :controller
  use Plausible.Repo

  @supported_locales ~w(fi en)
  @one_year 365 * 24 * 60 * 60

  def update(conn, %{"locale" => locale} = params) when locale in @supported_locales do
    if user = conn.assigns[:current_user] do
      user
      |> Plausible.Auth.User.locale_changeset(%{preferred_locale: locale})
      |> Repo.update!()
    end

    conn
    |> put_resp_cookie("np_locale", locale,
      max_age: @one_year,
      http_only: false,
      same_site: "Lax",
      secure: PlausibleWeb.Endpoint.secure_cookie?()
    )
    |> redirect(to: safe_return_to(params["return_to"]))
  end

  def update(conn, params), do: redirect(conn, to: safe_return_to(params["return_to"]))

  defp safe_return_to(path) when is_binary(path) do
    if String.starts_with?(path, "/") and not String.starts_with?(path, "//"), do: path, else: "/"
  end

  defp safe_return_to(_path), do: "/"
end
