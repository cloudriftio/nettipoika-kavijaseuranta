defmodule PlausibleWeb.Live.Shields.PageRules do
  @moduledoc """
  LiveView allowing page Rules management
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
        page_rules_count: assigns[:page_rules_count] || socket.assigns.page_rules_count,
        site: assigns[:site] || socket.assigns.site,
        current_user: assigns[:current_user] || socket.assigns.current_user,
        form: new_form()
      )
      |> assign_new(:page_rules, fn %{site: site} ->
        Shields.list_page_rules(site)
      end)
      |> assign_new(:redundant_rules, fn %{page_rules: page_rules} ->
        detect_redundancy(page_rules)
      end)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.settings_tiles>
        <.tile docs="top-pages#block-traffic-from-specific-pages-or-sections">
          <:title>{gettext("Pages block list")}</:title>
          <:subtitle :if={not Enum.empty?(@page_rules)}>
            {gettext("Reject incoming traffic for specific pages.")}
          </:subtitle>

          <%= if Enum.empty?(@page_rules) do %>
            <div class="flex flex-col items-center justify-center pt-5 pb-6 max-w-md mx-auto">
              <h3 class="text-center text-base font-medium text-gray-900 dark:text-gray-100 leading-7">
                {gettext("Block a page")}
              </h3>
              <p class="text-center text-sm mt-1 text-gray-500 dark:text-gray-400 leading-5 text-pretty">
                {gettext("Reject incoming traffic for specific pages.")}
                <.styled_link
                  href="https://plausible.io/docs/top-pages#block-traffic-from-specific-pages-or-sections"
                  target="_blank"
                >
                  {gettext("Learn more")}
                </.styled_link>
              </p>
              <.button
                :if={@page_rules_count < Shields.maximum_page_rules()}
                id="add-page-rule"
                x-data
                x-on:click={Modal.JS.open("page-rule-form-modal")}
                class="mt-4"
              >
                {gettext("Add page")}
              </.button>
            </div>
          <% else %>
            <.filter_bar
              :if={@page_rules_count < Shields.maximum_page_rules()}
              filtering_enabled?={false}
            >
              <.button
                id="add-page-rule"
                x-data
                x-on:click={Modal.JS.open("page-rule-form-modal")}
                mt?={false}
              >
                {gettext("Add page")}
              </.button>
            </.filter_bar>

            <.notice
              :if={@page_rules_count >= Shields.maximum_page_rules()}
              class="mt-4"
              title={gettext("Maximum number of pages reached")}
              theme={:gray}
            >
              <p>
                {gettext(
                  "You have reached the maximum of %{count} blocked pages. Remove one before adding another.",
                  count: Shields.maximum_page_rules()
                )}
              </p>
            </.notice>

            <div class="mt-6">
              <.table rows={@page_rules}>
                <:thead>
                  <.th>{gettext("Page")}</.th>
                  <.th hide_on_mobile>{gettext("Status")}</.th>
                  <.th invisible>{gettext("Actions")}</.th>
                </:thead>
                <:tbody :let={rule}>
                  <.td max_width="max-w-40" truncate>
                    <span
                      id={"page-#{rule.id}"}
                      class="mr-4 cursor-help text-ellipsis truncate max-w-xs"
                      title={
                        gettext("Added at %{date} by %{user}",
                          date: format_added_at(rule.inserted_at, @site.timezone),
                          user: rule.added_by
                        )
                      }
                    >
                      {rule.page_path}
                    </span>
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
                        title={
                          gettext(
                            "This rule may be redundant because these rules can match first:\n\n%{rules}",
                            rules: Enum.join(@redundant_rules[rule.id], "\n")
                          )
                        }
                        class="pl-4 cursor-help"
                      >
                        <Heroicons.exclamation_triangle class="h-5 w-5 text-red-800" />
                      </span>
                    </div>
                  </.td>
                  <.td actions>
                    <.delete_button
                      id={"remove-page-rule-#{rule.id}"}
                      phx-target={@myself}
                      phx-click="remove-page-rule"
                      phx-value-rule-id={rule.id}
                      data-confirm={gettext("Are you sure you want to revoke this rule?")}
                    />
                  </.td>
                </:tbody>
              </.table>
            </div>
          <% end %>

          <.live_component :let={modal_unique_id} module={Modal} id="page-rule-form-modal">
            <.form
              :let={f}
              for={@form}
              phx-submit="save-page-rule"
              phx-target={@myself}
              class="max-w-md w-full mx-auto"
            >
              <.title>{gettext("Add page to block list")}</.title>

              <.live_component
                class="mt-4"
                submit_name="page_rule[page_path]"
                submit_value={f[:page_path].value}
                display_value={f[:page_path].value || ""}
                module={PlausibleWeb.Live.Components.ComboBox}
                suggest_fun={
                  fn input, options -> suggest_page_paths(input, options, @site, @page_rules) end
                }
                id={"#{f[:page_path].id}-#{modal_unique_id}"}
                creatable
              />

              <.error :for={msg <- f[:page_path].errors}>{translate_error(msg)}</.error>

              <p class="mt-4 text-sm text-gray-500 dark:text-gray-400">
                {gettext("You can use a wildcard (*) to match multiple pages. For example,")}
                <code>/blog/*</code>
                {gettext("will match")}
                <code>/blog/post</code>. {gettext(
                  "After it is added, traffic from this page will be rejected within a few minutes."
                )}
              </p>
              <.button type="submit" class="w-full">
                {gettext("Add page")}
              </.button>
            </.form>
          </.live_component>
        </.tile>
      </.settings_tiles>
    </div>
    """
  end

  def handle_event("save-page-rule", %{"page_rule" => params}, socket) do
    user = socket.assigns.current_user

    case Shields.add_page_rule(
           socket.assigns.site.id,
           params,
           added_by: user
         ) do
      {:ok, rule} ->
        page_rules = [rule | socket.assigns.page_rules]

        socket =
          socket
          |> Modal.close("page-rule-form-modal")
          |> assign(
            form: new_form(),
            page_rules: page_rules,
            page_rules_count: socket.assigns.page_rules_count + 1,
            redundant_rules: detect_redundancy(page_rules)
          )

        send_flash(
          :success,
          gettext("Page rule added successfully. Traffic will be rejected within a few minutes.")
        )

        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("remove-page-rule", %{"rule-id" => rule_id}, socket) do
    Shields.remove_page_rule(socket.assigns.site.id, rule_id)

    send_flash(
      :success,
      gettext("Page rule removed successfully. Traffic will resume within a few minutes.")
    )

    page_rules = Enum.reject(socket.assigns.page_rules, &(&1.id == rule_id))

    {:noreply,
     socket
     |> assign(
       page_rules_count: socket.assigns.page_rules_count - 1,
       page_rules: page_rules,
       redundant_rules: detect_redundancy(page_rules)
     )}
  end

  def send_flash(kind, message) do
    send(self(), {:flash, kind, message})
  end

  defp new_form() do
    %Shield.PageRule{}
    |> Shield.PageRule.changeset(%{})
    |> to_form()
  end

  defp format_added_at(dt, tz) do
    dt
    |> Plausible.Timezones.to_datetime_in_timezone(tz)
    |> Calendar.strftime("%Y-%m-%d %H:%M:%S")
  end

  def suggest_page_paths(input, _options, site, page_rules) do
    query =
      QueryBuilder.build!(site,
        input_date_range: :all,
        metrics: [:pageviews],
        filters: [[:is_not, "event:page", Enum.map(page_rules, & &1.page_path)]]
      )

    site
    |> Plausible.Stats.filter_suggestions(query, "page", input)
    |> Enum.map(fn %{label: label, value: value} -> {label, value} end)
  end

  defp detect_redundancy(page_rules) do
    page_rules
    |> Enum.reduce(%{}, fn rule, acc ->
      {[^rule], remaining_rules} =
        Enum.split_with(
          page_rules,
          fn r -> r == rule end
        )

      conflicting =
        remaining_rules
        |> Enum.filter(fn candidate ->
          rule
          |> Map.fetch!(:page_path_pattern)
          |> maybe_compile()
          |> Regex.match?(candidate.page_path)
        end)
        |> Enum.map(& &1.id)

      Enum.reduce(conflicting, acc, fn conflicting_rule_id, acc ->
        Map.update(acc, conflicting_rule_id, [rule.page_path], fn existing ->
          [rule.page_path | existing]
        end)
      end)
    end)
  end

  defp maybe_compile(pattern) when is_binary(pattern), do: Regex.compile!(pattern)
  defp maybe_compile(%Regex{} = pattern), do: pattern
end
