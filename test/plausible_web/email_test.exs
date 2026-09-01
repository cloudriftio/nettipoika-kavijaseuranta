defmodule PlausibleWeb.EmailTest do
  use Plausible.DataCase, async: true

  import Plausible.Factory

  alias PlausibleWeb.Email

  describe "base_email layout" do
    test "greets user by first name if user in template assigns" do
      email =
        Email.base_email()
        |> Email.render("welcome_email.html", %{
          user: build(:user, name: "John Doe", preferred_locale: "en"),
          code: "123"
        })

      assert email.html_body =~ "Hello John,"
      assert email.text_body =~ "Hello John,"
    end

    test "greets impersonally when user not in template assigns" do
      email =
        Email.base_email()
        |> Email.render("welcome_email.html")

      assert email.html_body =~ "Hei,"
      assert email.text_body =~ "Hei,"
    end

    test "renders plausible link" do
      email =
        Email.base_email()
        |> Email.render("welcome_email.html")

      assert email.html_body =~ plausible_link()
      assert email.text_body =~ plausible_url()
    end

    @tag :ee_only
    test "renders unsubscribe placeholder" do
      email =
        Email.base_email()
        |> Email.render("welcome_email.html")

      assert email.html_body =~ "{{{ pm:unsubscribe }}}"
    end

    test "can be disabled with a nil layout" do
      email =
        Email.base_email(%{layout: nil})
        |> Email.render("welcome_email.html", %{
          user: build(:user, name: "John Doe")
        })

      refute email.html_body =~ "Hello John,"
      refute email.html_body =~ plausible_link()

      refute email.text_body =~ "Hello John,"
      refute email.text_body =~ "\n--"
    end
  end

  describe "priority email layout" do
    @tag :ee_only
    test "uses the `priority` message stream in Postmark in EE" do
      email =
        Email.priority_email()
        |> Email.render("activation_email.html", %{
          user: build(:user, name: "John Doe", preferred_locale: "en"),
          code: "123"
        })

      assert %{"MessageStream" => "priority"} = email.private[:message_params]
    end

    @tag :ce_build_only
    test "doesn't use the `priority` message stream in Postmark in CE" do
      email =
        Email.priority_email()
        |> Email.render("activation_email.html", %{
          user: build(:user, name: "John Doe", preferred_locale: "en"),
          code: "123"
        })

      refute email.private[:message_params]["MessageStream"]
    end

    test "greets user by first name if user in template assigns" do
      email =
        Email.priority_email()
        |> Email.render("activation_email.html", %{
          user: build(:user, name: "John Doe", preferred_locale: "en"),
          code: "123"
        })

      assert email.html_body =~ "Hello John,"
      assert email.text_body =~ "Hello John,"
    end

    test "greets impersonally when user not in template assigns" do
      email =
        Email.priority_email()
        |> Email.render("password_reset_email.html", %{
          reset_link: "imaginary"
        })

      assert email.html_body =~ "Hei,"
      assert email.text_body =~ "Hei,"
    end

    test "renders plausible link" do
      email =
        Email.priority_email()
        |> Email.render("password_reset_email.html", %{
          reset_link: "imaginary"
        })

      assert email.html_body =~ plausible_link()
      assert email.text_body =~ plausible_url()
    end

    test "does not render unsubscribe placeholder" do
      email =
        Email.priority_email()
        |> Email.render("password_reset_email.html", %{
          reset_link: "imaginary"
        })

      refute email.html_body =~ "{{{ pm:unsubscribe }}}"
    end

    test "can be disabled with a nil layout" do
      email =
        Email.priority_email(%{layout: nil})
        |> Email.render("password_reset_email.html", %{
          reset_link: "imaginary"
        })

      refute email.html_body =~ "Hello John,"
      refute email.html_body =~ plausible_link()

      refute email.text_body =~ "Hello John,"
      refute email.text_body =~ plausible_url()
    end
  end

  describe "localized transactional emails" do
    test "uses Finnish by default" do
      user = build(:user, name: "Maija Meikäläinen", preferred_locale: "fi")

      email = Email.password_reset_email(user, "https://example.test/reset")

      assert email.subject == "Nettipoika Mittarin salasanan palautus"
      assert email.html_body =~ "vaihtaaksesi Nettipoika Mittarin salasanasi"
    end

    test "uses English when the recipient prefers English" do
      user = build(:user, name: "Jane Smith", preferred_locale: "en")

      email = Email.password_reset_email(user, "https://example.test/reset")

      assert email.subject == "Password reset for Nettipoika Mittari"
      assert email.html_body =~ "reset your Nettipoika Mittari password"
    end

    test "falls back to Finnish when there is no recipient locale" do
      assert Email.email_locale(%{}) == "fi"
    end

    test "renders Finnish Nettipoika Mittari onboarding by default" do
      user = build(:user, name: "Maija Meikäläinen", preferred_locale: "fi")

      email = Email.welcome_email(user)

      assert email.subject == "Tervetuloa Nettipoika Mittariin"
      assert email.html_body =~ "tarjoaa helppokäyttöisen"
      assert email.html_body =~ "Lisää verkkosivustosi"
      refute email.html_body =~ "Plausible dashboard"
    end

    test "renders English Nettipoika Mittari onboarding when selected" do
      user = build(:user, name: "Jane Smith", preferred_locale: "en")

      email = Email.welcome_email(user)

      assert email.subject == "Welcome to Nettipoika Mittari"
      assert email.html_body =~ "Nettipoika Mittari provides simple"
      assert email.html_body =~ "Add your website"
    end
  end

  describe "over_limit_email/3" do
    test "renders usage, suggested plan, and links to upgrade and account settings" do
      user = build(:user)
      team = build(:team, identifier: Ecto.UUID.generate())
      penultimate_cycle = Date.range(~D[2023-03-01], ~D[2023-03-31])
      last_cycle = Date.range(~D[2023-04-01], ~D[2023-04-30])

      usage = %{
        penultimate_cycle: %{date_range: penultimate_cycle, total: 12_300},
        last_cycle: %{date_range: last_cycle, total: 32_100}
      }

      %{html_body: html_body, subject: subject} =
        PlausibleWeb.Email.over_limit_email(user, team, usage, "100k")

      assert subject == "[Action required] You have outgrown your Plausible subscription tier"

      assert html_body =~ PlausibleWeb.TextHelpers.format_date_range(last_cycle)
      assert html_body =~ "We recommend you upgrade to the 100k pageviews/month plan"
      assert html_body =~ "your account recorded 32,100 billable pageviews"

      assert html_body =~
               "cycle before that (#{PlausibleWeb.TextHelpers.format_date_range(penultimate_cycle)}), your account used 12,300 billable pageviews"

      assert text_of_element(
               html_body,
               ~s|a[href$="/billing/choose-plan?__team=#{team.identifier}"]|
             ) ==
               "Click here to upgrade your subscription"

      assert text_of_element(
               html_body,
               ~s|a[href$="/settings/billing/subscription?__team=#{team.identifier}"]|
             ) ==
               "account settings"

      assert html_body =~
               PlausibleWeb.Router.Helpers.billing_url(PlausibleWeb.Endpoint, :choose_plan) <>
                 "?__team=#{team.identifier}"
    end

    test "asks enterprise level usage to contact us" do
      user = build(:user)
      team = build(:team, identifier: Ecto.UUID.generate())
      penultimate_cycle = Date.range(~D[2023-03-01], ~D[2023-03-31])
      last_cycle = Date.range(~D[2023-04-01], ~D[2023-04-30])
      suggested_plan = :enterprise

      usage = %{
        penultimate_cycle: %{date_range: penultimate_cycle, total: 12_300},
        last_cycle: %{date_range: last_cycle, total: 32_100}
      }

      %{html_body: html_body} =
        PlausibleWeb.Email.over_limit_email(user, team, usage, suggested_plan)

      refute html_body =~ "Click here to upgrade your subscription"
      assert html_body =~ "Your usage exceeds our standard plans, so please reply back"
    end
  end

  describe "dashboard_locked/3" do
    test "renders usage, suggested plan, and links to upgrade and account settings" do
      user = build(:user)
      team = build(:team, identifier: Ecto.UUID.generate())
      penultimate_cycle = Date.range(~D[2023-03-01], ~D[2023-03-31])
      last_cycle = Date.range(~D[2023-04-01], ~D[2023-04-30])

      usage = %{
        penultimate_cycle: %{date_range: penultimate_cycle, total: 12_300},
        last_cycle: %{date_range: last_cycle, total: 32_100}
      }

      %{html_body: html_body, subject: subject} =
        PlausibleWeb.Email.dashboard_locked(user, team, usage, "100k")

      assert subject == "[Action required] Your Plausible dashboard is now locked"

      assert html_body =~ PlausibleWeb.TextHelpers.format_date_range(last_cycle)
      assert html_body =~ "We recommend you upgrade to the 100k pageviews/month plan"
      assert html_body =~ "your account recorded 32,100 billable pageviews"

      assert html_body =~
               "cycle before that (#{PlausibleWeb.TextHelpers.format_date_range(penultimate_cycle)}), the usage was 12,300 billable pageviews"

      assert text_of_element(
               html_body,
               ~s|a[href$="/billing/choose-plan?__team=#{team.identifier}"]|
             ) ==
               "Click here to upgrade your subscription"

      assert text_of_element(
               html_body,
               ~s|a[href$="/settings/billing/subscription?__team=#{team.identifier}"]|
             ) ==
               "account settings"

      assert html_body =~
               PlausibleWeb.Router.Helpers.billing_url(PlausibleWeb.Endpoint, :choose_plan) <>
                 "?__team=#{team.identifier}"
    end

    test "asks enterprise level usage to contact us" do
      user = build(:user)
      team = build(:team, identifier: Ecto.UUID.generate())
      penultimate_cycle = Date.range(~D[2023-03-01], ~D[2023-03-31])
      last_cycle = Date.range(~D[2023-04-01], ~D[2023-04-30])
      suggested_plan = :enterprise

      usage = %{
        penultimate_cycle: %{date_range: penultimate_cycle, total: 12_300},
        last_cycle: %{date_range: last_cycle, total: 32_100}
      }

      %{html_body: html_body} =
        PlausibleWeb.Email.dashboard_locked(user, team, usage, suggested_plan)

      refute html_body =~ "Click here to upgrade your subscription"
      assert html_body =~ "Your usage exceeds our standard plans, so please reply back"
    end
  end

  describe "enterprise_over_limit_internal_email/4" do
    test "renders pageview usage by billing cycles + sites usage/limit" do
      user = build(:user)
      penultimate_cycle = Date.range(~D[2023-03-01], ~D[2023-03-31])
      last_cycle = Date.range(~D[2023-04-01], ~D[2023-04-30])

      pageview_usage = %{
        penultimate_cycle: %{date_range: penultimate_cycle, total: 100_141_888},
        last_cycle: %{date_range: last_cycle, total: 100_222_999}
      }

      %{html_body: html_body, subject: subject} =
        PlausibleWeb.Email.enterprise_over_limit_internal_email(user, pageview_usage, 80, 50)

      assert subject == "#{user.email} has outgrown their enterprise plan"

      assert html_body =~
               "Last billing cycle: #{PlausibleWeb.TextHelpers.format_date_range(last_cycle)}"

      assert html_body =~ "Last cycle pageview usage: 100,222,999 billable pageviews"

      assert html_body =~
               "Penultimate billing cycle: #{PlausibleWeb.TextHelpers.format_date_range(penultimate_cycle)}"

      assert html_body =~ "Penultimate cycle pageview usage: 100,141,888 billable pageviews"
      assert html_body =~ "Site usage: 80 / 50 allowed sites"
    end
  end

  describe "approaching accept_traffic_until" do
    test "renders first warning" do
      user = build(:user, id: 123, name: "John Doe")
      team = build(:team, identifier: Ecto.UUID.generate())

      notification = %{
        id: user.id,
        email: user.email,
        deadline: Date.add(Date.utc_today(), 7),
        site_ids: [1, 2, 3],
        name: user.name,
        team: team
      }

      %{html_body: body, subject: subject} =
        PlausibleWeb.Email.approaching_accept_traffic_until(notification)

      assert subject == "We'll stop counting your stats"
      assert body =~ plausible_link(team: team, label: "login to your Plausible account")
      assert body =~ "Hei John,"

      assert body =~
               "We've noticed that you're still sending us stats so we're writing to inform you that we'll stop accepting stats from your sites next week."
    end

    test "renders final warning" do
      user = build(:user, id: 123, name: "John Doe")
      team = build(:team, identifier: Ecto.UUID.generate())

      notification = %{
        id: user.id,
        email: user.email,
        deadline: Date.add(Date.utc_today(), 1),
        site_ids: [1, 2, 3],
        name: user.name,
        team: team
      }

      %{html_body: body, subject: subject} =
        PlausibleWeb.Email.approaching_accept_traffic_until_tomorrow(notification)

      assert subject == "A reminder that we'll stop counting your stats tomorrow"
      assert body =~ plausible_link(team: team, label: "login to your Plausible account")

      assert body =~
               "We've noticed that you're still sending us stats so we're writing to inform you that we'll stop accepting stats from your sites tomorrow."
    end
  end

  describe "site setup emails" do
    test "uses Finnish copy and Nettipoika Mittari branding by default" do
      user = new_user(preferred_locale: "fi")
      site = new_site(owner: user)

      emails = [
        PlausibleWeb.Email.create_site_email(user),
        PlausibleWeb.Email.site_setup_help(user, site.team, site),
        PlausibleWeb.Email.site_setup_success(user, site.team, site),
        PlausibleWeb.Email.check_stats_email(user)
      ]

      assert Enum.map(emails, & &1.subject) == [
               "Nettipoika Mittari: lisää verkkosivustosi tiedot",
               "Nettipoika Mittari odottaa ensimmäisiä sivulatauksia",
               "Nettipoika Mittari mittaa nyt verkkosivustoasi",
               "Tarkista verkkosivustosi kävijätilastot"
             ]

      for email <- emails do
        assert email.html_body =~ "Nettipoika Mittari"
        refute email.html_body =~ "Plausible dashboard"
      end
    end

    test "uses English copy when the recipient selects English" do
      user = new_user(preferred_locale: "en")
      site = new_site(owner: user)

      emails = [
        PlausibleWeb.Email.create_site_email(user),
        PlausibleWeb.Email.site_setup_help(user, site.team, site),
        PlausibleWeb.Email.site_setup_success(user, site.team, site),
        PlausibleWeb.Email.check_stats_email(user)
      ]

      assert Enum.map(emails, & &1.subject) == [
               "Nettipoika Mittari: add your website details",
               "Nettipoika Mittari is waiting for the first pageviews",
               "Nettipoika Mittari is now tracking your website",
               "Check your website analytics"
             ]

      assert Enum.all?(emails, &String.contains?(&1.html_body, "Nettipoika Mittari"))
    end
  end

  describe "text_body" do
    @tag :ee_only
    test "welcome_email (EE)" do
      email =
        Email.base_email()
        |> Email.render("welcome_email.html", %{
          user: build(:user, name: "John Doe", preferred_locale: "en"),
          code: "123"
        })

      assert email.text_body =~ "Hello John,"
      assert email.text_body =~ "Nettipoika Mittari provides simple"
      assert email.text_body =~ "http://localhost:8000/sites/new"
      assert email.text_body =~ "The Plausible Team"
      assert email.text_body =~ "{{{ pm:unsubscribe }}}"
    end

    @tag :ce_build_only
    test "welcome_email (CE)" do
      email =
        Email.base_email()
        |> Email.render("welcome_email.html", %{
          user: build(:user, name: "John Doe", preferred_locale: "en"),
          code: "123"
        })

      assert email.text_body =~ "Hello John,"
      assert email.text_body =~ "Nettipoika Mittari provides simple"
      assert email.text_body =~ "http://localhost:8000/sites/new"
      refute email.text_body =~ "The Plausible Team"
      refute email.text_body =~ "{{{ pm:unsubscribe }}}"
    end
  end

  def plausible_url do
    PlausibleWeb.EmailView.plausible_url()
  end

  def plausible_link(opts \\ []) do
    suffix =
      if team = Keyword.get(opts, :team) do
        "?__team=#{team.identifier}"
      else
        ""
      end

    plausible_url = plausible_url()

    label =
      if label = Keyword.get(opts, :label) do
        label
      else
        plausible_url
      end

    "<a href=\"#{plausible_url <> suffix}\">#{label}</a>"
  end
end
