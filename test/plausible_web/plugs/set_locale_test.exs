defmodule PlausibleWeb.Plugs.SetLocaleTest do
  use ExUnit.Case, async: true

  import Plug.Conn
  import Plug.Test

  alias PlausibleWeb.Plugs.SetLocale

  test "prefers the signed-in user's locale" do
    conn =
      conn(:get, "/")
      |> put_req_cookie("np_locale", "fi")
      |> assign(:current_user, %Plausible.Auth.User{preferred_locale: "en"})

    assert PlausibleWeb.Locale.from_conn(conn) == "en"
  end

  test "uses the locale cookie and defaults to Finnish" do
    cookie_conn = conn(:get, "/") |> put_req_cookie("np_locale", "en")
    assert PlausibleWeb.Locale.from_conn(cookie_conn) == "en"

    assert PlausibleWeb.Locale.from_conn(conn(:get, "/")) == "fi"
  end

  test "falls back to a supported Accept-Language locale" do
    conn = conn(:get, "/") |> put_req_header("accept-language", "sv-SE, en;q=0.8")
    assert PlausibleWeb.Locale.from_conn(conn) == "en"
  end

  test "installs the locale for templates and LiveView sessions" do
    conn =
      conn(:get, "/")
      |> init_test_session(%{})
      |> put_req_cookie("np_locale", "fi")
      |> SetLocale.call([])

    assert conn.assigns.locale == "fi"
    assert get_session(conn, :locale) == "fi"
    assert Gettext.get_locale(PlausibleWeb.Gettext) == "fi"
    assert Gettext.gettext(PlausibleWeb.Gettext, "Details") == "Näytä tarkemmin"
  end
end
