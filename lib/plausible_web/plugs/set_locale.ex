defmodule PlausibleWeb.Plugs.SetLocale do
  @moduledoc false

  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    locale = PlausibleWeb.Locale.from_conn(conn)
    Gettext.put_locale(PlausibleWeb.Gettext, locale)

    conn
    |> put_session(:locale, locale)
    |> assign(:locale, locale)
  end
end
