defmodule PlausibleWeb.SiteView do
  use PlausibleWeb, :view
  use Plausible

  def plausible_url do
    PlausibleWeb.Endpoint.url()
  end

  def with_indefinite_article(word) do
    if String.starts_with?(word, ["a", "e", "i", "o", "u"]) do
      "an " <> word
    else
      "a " <> word
    end
  end

  def site_role(%{role: :viewer}) do
    gettext("Guest Viewer")
  end

  def site_role(%{role: :editor}) do
    gettext("Guest Editor")
  end

  def site_role(%{role: :owner}), do: gettext("Owner")
  def site_role(%{role: :admin}), do: gettext("Administrator")
  def site_role(%{role: :billing}), do: gettext("Billing")
end
