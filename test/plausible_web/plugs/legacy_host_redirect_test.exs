defmodule PlausibleWeb.Plugs.LegacyHostRedirectTest do
  use ExUnit.Case, async: false

  import Plug.Conn, only: [get_resp_header: 2]
  import Plug.Test

  alias PlausibleWeb.Plugs.LegacyHostRedirect

  setup do
    original = Application.get_env(:plausible, :nettipoika)

    Application.put_env(:plausible, :nettipoika,
      legacy_base_urls: ["https://plausible.cloudrift.io"]
    )

    on_exit(fn ->
      if original do
        Application.put_env(:plausible, :nettipoika, original)
      else
        Application.delete_env(:plausible, :nettipoika)
      end
    end)
  end

  test "redirects browser routes on a legacy host and preserves the query string" do
    conn =
      conn(:get, "/sites?period=30d")
      |> Map.put(:host, "plausible.cloudrift.io")
      |> LegacyHostRedirect.call([])

    assert conn.status == 308

    assert get_resp_header(conn, "location") == [
             PlausibleWeb.Endpoint.url() <> "/sites?period=30d"
           ]

    assert conn.halted
  end

  test "keeps tracker and event API routes available on a legacy host" do
    for path <- [
          "/js/script.js",
          "/api/event",
          "/css/app.css",
          "/images/logo.png",
          "/favicon.ico"
        ] do
      conn =
        conn(:get, path)
        |> Map.put(:host, "plausible.cloudrift.io")
        |> LegacyHostRedirect.call([])

      refute conn.halted
      refute conn.status
    end
  end

  test "does not redirect the canonical host" do
    conn =
      conn(:get, "/sites")
      |> Map.put(:host, "mittari.nettipoika.fi")
      |> LegacyHostRedirect.call([])

    refute conn.halted
  end
end
