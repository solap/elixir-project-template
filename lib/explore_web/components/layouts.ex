defmodule ExploreWeb.Layouts do
  @moduledoc """
  Layout components for the Explore application.
  """
  use ExploreWeb, :html

  import ExploreWeb.CoreComponents

  embed_templates "layouts/*"
end
