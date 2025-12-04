defmodule ExploreWeb.ErrorJSON do
  @moduledoc """
  Error pages for JSON requests.
  """

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end
end
