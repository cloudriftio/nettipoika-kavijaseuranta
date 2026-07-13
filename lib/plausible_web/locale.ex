defmodule PlausibleWeb.Locale do
  @moduledoc "Resolves and installs the customer-interface locale."

  @supported ~w(fi en)

  def from_conn(conn) do
    user_locale = conn.assigns[:current_user] && conn.assigns.current_user.preferred_locale

    cookie_locale =
      case conn.req_cookies do
        %Plug.Conn.Unfetched{} -> nil
        cookies when is_map(cookies) -> cookies["np_locale"]
      end

    normalize(user_locale || cookie_locale) || accept_language(conn)
  end

  def normalize(locale) when locale in @supported, do: locale
  def normalize(_locale), do: nil

  defp accept_language(conn) do
    conn
    |> Plug.Conn.get_req_header("accept-language")
    |> List.first("")
    |> String.split(",")
    |> Enum.map(&(&1 |> String.split(";") |> hd() |> String.trim() |> String.downcase()))
    |> Enum.find_value("fi", fn
      "fi" <> _ -> "fi"
      "en" <> _ -> "en"
      _ -> nil
    end)
  end
end
