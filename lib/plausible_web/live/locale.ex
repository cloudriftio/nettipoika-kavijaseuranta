defmodule PlausibleWeb.Live.Locale do
  @moduledoc false

  import Phoenix.Component, only: [assign: 3]

  def on_mount(:default, _params, session, socket) do
    locale =
      PlausibleWeb.Locale.normalize(
        socket.assigns[:current_user] && socket.assigns.current_user.preferred_locale
      ) ||
        PlausibleWeb.Locale.normalize(session["locale"]) || PlausibleWeb.Locale.default()

    Gettext.put_locale(PlausibleWeb.Gettext, locale)
    {:cont, assign(socket, :locale, locale)}
  end
end
