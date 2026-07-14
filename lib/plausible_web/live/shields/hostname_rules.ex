defmodule PlausibleWeb.Live.Shields.HostnameRules do
  @moduledoc """
  LiveView allowing hostname Rules management
  """

  use PlausibleWeb, :live_component

  alias PlausibleWeb.Live.Components.Modal
  alias Plausible.Shields
  alias Plausible.Shield
  alias Plausible.Stats.QueryBuilder

  def update(assigns, socket) do
    socket =
      socket
      |> assign(
        hostname_rules_count: assigns.hostname_rules_count,
        site: assigns.site,
        current_user: assigns.current_user,
        form: new_form()
      )
      |> assign_new(:hostname_rules, fn %{site: site} ->
        Shields.list_hostname_rules(site)
      end)
      |> assign_new(:redundant_rules, fn %{hostname_rules: hostname_rules} ->
        detect_redundancy(hostname_rules)
      end)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.settings_tiles>
        <.tile docs="excluding#exclude-visits-by-hostname">
          <:title>{gettext("Hostname allow list")}</:title>
          <:subtitle :if={not Enum.empty?(@hostname_rules)}>
            {gettext("Accept incoming traffic only from known hostnames.")}
          </:subtitle>

          <%= if Enum.empty?(@hostname_rules) do %>
            <div class="flex flex-col items-center justify-center pt-5 pb-6 max-w-md mx-auto">
              <h3 class="text-center text-base font-medium text-gray-900 dark:text-gray-100 leading-7">
                {gettext("Allow a hostname")}
              </h3>
              <p class="text-center text-sm mt-1 text-gray-500 dark:text-gray-400 leading-5 text-pretty">
                {gettext(
                  "Accept incoming traffic only from known hostnames. Traffic from every hostname is recorded until you add the first rule."
                )}
                <.styled_link
                  href="https://plausible.io/docs/excluding#exclude-visits-by-hostname"
                  target="_blank"
                >
                  {gettext("Learn more")}
                </.styled_link>
              </p>
              <.button
                :if={@hostname_rules_count < Shields.maximum_hostname_rules()}
                id="add-hostname-rule"
                x-data
                x-on:click={Modal.JS.open("hostname-rule-form-modal")}
                class="mt-4"
              >
                {gettext("Add hostname")}
              </.button>
            </div>
          <% else %>
            <.filter_bar
              :if={@hostname_rules_count < Shields.maximum_hostname_rules()}
              filtering_enabled?={false}
            >
              <.button
                id="add-hostname-rule"
                x-data
                x-on:click={Modal.JS.open("hostname-rule-form-modal")}
                mt?={false}
              >
                {gettext("Add hostname")}
              </.button>
            </.filter_bar>

            <.notice
              :if={@hostname_rules_count >= Shields.maximum_hostname_rules()}
              class="mt-4"
              title={gettext("Maximum number of hostnames reached")}
              theme={:gray}
            >
              <p>
                {gettext(
                  "You have reached the maximum of %{count} allowed hostnames. Remove one before adding another.",
                  count: Shields.maximum_hostname_rules()
                )}
              </p>
            </.notice>

            <div class="mt-6">
              <.table rows={@hostname_rules}>
                <:thead>
                  <.th>{gettext("Hostname")}</.th>
                  <.th hide_on_mobile>{gettext("Status")}</.th>
                  <.th invisible>{gettext("Actions")}</.th>
                </:thead>
                <:tbody :let={rule}>
                  <.td>
                    <div class="flex items-center">
                      <span
                        id={"hostname-#{rule.id}"}
                        class="mr-4 cursor-help text-ellipsis truncate max-w-xs"
                        title={gettext("Added at %{date} by %{user}",
                          date: format_added_at(rule.inserted_at, @site.timezone),
                          user: rule.added_by
                        )}
                      >
                        {rule.hostname}
                      </span>
                    </div>
                  </.td>
                  <.td hide_on_mobile>
                    <div class="flex items-center">
                      <span :if={rule.action == :deny}>
                        {gettext("Blocked")}
                      </span>
                      <span :if={rule.action == :allow}>
                        {gettext("Allowed")}
                      </span>
                      <span
                        :if={@redundant_rules[rule.id]}
                        title={gettext(
                          "This rule may be redundant because these rules can match first:\n\n%{rules}",
                          rules: Enum.join(@redundant_rules[rule.id], "\n")
                        )}
                        class="pl-4 cursor-help"
                      >
                        <Heroicons.exclamation_triangle class="h-5 w-5 text-red-800" />
                      </span>
                    </div>
                  </.td>
                  <.td actions>
                    <.delete_button
                      id={"remove-hostname-rule-#{rule.id}"}
                      phx-target={@myself}
                      phx-click="remove-hostname-rule"
                      phx-value-rule-id={rule.id}
                      data-confirm={gettext("Are you sure you want to revoke this rule?")}
                    />
                  </.td>
                </:tbody>
              </.table>
            </div>
          <% end %>

          <.live_component :let={modal_unique_id} module={Modal} id="hostname-rule-form-modal">
            <.form
              :let={f}
              for={@form}
              phx-submit="save-hostname-rule"
              phx-target={@myself}
              class="max-w-md w-full mx-auto"
            >
              <.title>{gettext("Add hostname to allow list")}</.title>

              <.live_component
                class="mt-8"
                submit_name="hostname_rule[hostname]"
                submit_value={f[:hostname].value}
                display_value={f[:hostname].value || ""}
                module={PlausibleWeb.Live.Components.ComboBox}
                suggest_fun={fn input, options -> suggest_hostnames(input, options, @site) end}
                id={"#{f[:hostname].id}-#{modal_unique_id}"}
                creatable
              />
              <.error :for={msg <- f[:hostname].errors}>{translate_error(msg)}</.error>

              <p class="mt-4 text-sm text-gray-500 dark:text-gray-400">
                {gettext("You can use a wildcard (*) to match multiple hostnames. For example,")}
                <code>*{@site.domain}</code>
                {gettext("records traffic only on the main domain and its subdomains.")}<br /><br />

                <%= if @hostname_rules_count >= 1 do %>
                  {gettext(
                    "After it is added, traffic from this hostname will be accepted within a few minutes."
                  )}
                <% else %>
                  {gettext(
                    "Note: after the first rule is added, traffic from other hostnames will be rejected within a few minutes."
                  )}
                <% end %>
              </p>
              <.button type="submit" class="w-full">
                {gettext("Add hostname")}
              </.button>
            </.form>
          </.live_component>
        </.tile>
      </.settings_tiles>
    </div>
    """
  end

  def handle_event("save-hostname-rule", %{"hostname_rule" => params}, socket) do
    user = socket.assigns.current_user

    case Shields.add_hostname_rule(
           socket.assigns.site.id,
           params,
           added_by: user
         ) do
      {:ok, rule} ->
        hostname_rules = [rule | socket.assigns.hostname_rules]

        socket =
          socket
          |> Modal.close("hostname-rule-form-modal")
          |> assign(
            form: new_form(),
            hostname_rules: hostname_rules,
            hostname_rules_count: socket.assigns.hostname_rules_count + 1,
            redundant_rules: detect_redundancy(hostname_rules)
          )

        send_flash(
          :success,
          gettext("Hostname rule added successfully. Traffic will be limited within a few minutes.")
        )

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("remove-hostname-rule", %{"rule-id" => rule_id}, socket) do
    Shields.remove_hostname_rule(socket.assigns.site.id, rule_id)

    send_flash(
      :success,
      gettext("Hostname rule removed successfully. Traffic will be adjusted within a few minutes.")
    )

    hostname_rules = Enum.reject(socket.assigns.hostname_rules, &(&1.id == rule_id))

    {:noreply,
     socket
     |> assign(
       hostname_rules_count: socket.assigns.hostname_rules_count - 1,
       hostname_rules: hostname_rules,
       redundant_rules: detect_redundancy(hostname_rules)
     )}
  end

  def send_flash(kind, message) do
    send(self(), {:flash, kind, message})
  end

  defp new_form() do
    %Shield.HostnameRule{}
    |> Shield.HostnameRule.changeset(%{})
    |> to_form()
  end

  defp format_added_at(dt, tz) do
    dt
    |> Plausible.Timezones.to_datetime_in_timezone(tz)
    |> Calendar.strftime("%Y-%m-%d %H:%M:%S")
  end

  def suggest_hostnames(input, _options, site) do
    query =
      QueryBuilder.build!(site,
        input_date_range: :all,
        metrics: [:pageviews]
      )

    site
    |> Plausible.Stats.filter_suggestions(query, "hostname", input)
    |> Enum.map(fn %{label: label, value: value} -> {label, value} end)
  end

  defp detect_redundancy(hostname_rules) do
    hostname_rules
    |> Enum.reduce(%{}, fn rule, acc ->
      {[^rule], remaining_rules} =
        Enum.split_with(
          hostname_rules,
          fn r -> r == rule end
        )

      conflicting =
        remaining_rules
        |> Enum.filter(fn candidate ->
          rule
          |> Map.fetch!(:hostname_pattern)
          |> maybe_compile()
          |> Regex.match?(candidate.hostname)
        end)
        |> Enum.map(& &1.id)

      Enum.reduce(conflicting, acc, fn conflicting_rule_id, acc ->
        Map.update(acc, conflicting_rule_id, [rule.hostname], fn existing ->
          [rule.hostname | existing]
        end)
      end)
    end)
  end

  defp maybe_compile(pattern) when is_binary(pattern), do: Regex.compile!(pattern)
  defp maybe_compile(%Regex{} = pattern), do: pattern
end
