defmodule ExploreWeb.ErrorHTML do
  @moduledoc """
  Error pages for HTML requests.
  """
  use ExploreWeb, :html

  def render(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end
end
