defmodule PlausibleWeb.Plugs.LegacyHostRedirect do
  @moduledoc false

  import Plug.Conn

  @compatibility_prefixes ["/api/", "/js/", "/css/", "/images/"]
  @compatibility_paths ["/favicon.ico", "/robots.txt"]

  def init(opts), do: opts

  def call(conn, _opts) do
    if legacy_host?(conn.host) and not compatibility_path?(conn.request_path) do
      location = canonical_url() <> conn.request_path <> query_suffix(conn.query_string)

      conn
      |> put_resp_header("location", location)
      |> send_resp(308, "")
      |> halt()
    else
      conn
    end
  end

  defp legacy_host?(host) do
    Application.get_env(:plausible, :nettipoika, [])
    |> Keyword.get(:legacy_base_urls, [])
    |> Enum.any?(fn url -> URI.parse(url).host == host end)
  end

  defp compatibility_path?(path) do
    path in @compatibility_paths or
      Enum.any?(@compatibility_prefixes, &String.starts_with?(path, &1))
  end

  defp canonical_url do
    PlausibleWeb.Endpoint.url()
  end

  defp query_suffix(""), do: ""
  defp query_suffix(query), do: "?" <> query
end
