defmodule PlausibleWeb.SettingsViewTest do
  use Plausible.DataCase, async: true

  alias Plausible.Auth.UserSession
  alias PlausibleWeb.SettingsView

  test "localizes relative session times" do
    Gettext.put_locale(PlausibleWeb.Gettext, "fi")
    on_exit(fn -> Gettext.put_locale(PlausibleWeb.Gettext, "en") end)

    now = ~N[2026-07-14 12:00:00]

    assert SettingsView.last_used_humanize(
             %UserSession{last_used_at: ~N[2026-07-14 11:45:00]},
             now
           ) == "Juuri äsken"

    assert SettingsView.last_used_humanize(
             %UserSession{last_used_at: ~N[2026-07-14 02:00:00]},
             now
           ) == "10 tuntia sitten"

    assert SettingsView.last_used_humanize(
             %UserSession{last_used_at: ~N[2026-07-11 12:00:00]},
             now
           ) == "3 päivää sitten"
  end
end
