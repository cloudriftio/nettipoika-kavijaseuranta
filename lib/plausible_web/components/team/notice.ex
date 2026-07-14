defmodule PlausibleWeb.Team.Notice do
  @moduledoc """
  Components with teams related notices.
  """
  use PlausibleWeb, :component

  def owner_cta_banner(assigns) do
    ~H"""
    <aside class="mt-4 mb-4">
      <.notice
        title={gettext("A better way to invite people to your team")}
        class="shadow-md dark:shadow-none mt-4"
      >
        <p>
          {gettext(
            "You can create a team and assign roles such as administrator, editor, viewer or billing. Team members will have access to all your sites."
          )}
          <.styled_link href={Routes.team_setup_path(PlausibleWeb.Endpoint, :setup)}>
            {gettext("Create your team")}
          </.styled_link>.
        </p>
      </.notice>
    </aside>
    """
  end

  def guest_cta_banner(assigns) do
    ~H"""
    <aside class="mt-4 mb-4">
      <.notice
        title={gettext("A better way to invite people to a team")}
        class="shadow-md dark:shadow-none mt-4"
      >
        <p>
          {gettext(
            "A team can have roles such as administrator, editor, viewer or billing. Team members can access all of its sites. Ask the site owner to create the team."
          )}
        </p>
      </.notice>
    </aside>
    """
  end

  def team_members_notice(assigns) do
    ~H"""
    <aside class="mt-4 mb-4">
      <.notice theme={:gray} class="mt-4">
        <p>
          {gettext("Team members automatically have access to this site.")}
          <.styled_link href={Routes.settings_path(PlausibleWeb.Endpoint, :team_general)}>
            {gettext("View team members")}
          </.styled_link>
        </p>
      </.notice>
    </aside>
    """
  end

  def team_invitations(assigns) do
    ~H"""
    <aside :if={not Enum.empty?(@team_invitations)} class="mt-4 mb-4">
      <.notice
        :for={i <- @team_invitations}
        id={"invitation-#{i.invitation_id}"}
        title="You have received team invitation"
        class="shadow-md dark:shadow-none mt-4"
      >
        {i.inviter.name} has invited you to join the "{i.team.name}" as {i.role} member.
        <.link
          method="post"
          href={Routes.invitation_path(PlausibleWeb.Endpoint, :accept_invitation, i.invitation_id)}
          class="whitespace-nowrap font-semibold"
        >
          Accept
        </.link>
        or
        <.link
          method="post"
          href={Routes.invitation_path(PlausibleWeb.Endpoint, :reject_invitation, i.invitation_id)}
          phx-value-invitation-id={i.invitation_id}
          class="whitespace-nowrap font-semibold"
        >
          Reject
        </.link>
      </.notice>
    </aside>
    """
  end
end
