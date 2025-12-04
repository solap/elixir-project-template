defmodule ExploreWeb.PageController do
  use ExploreWeb, :controller

  def home(conn, _params) do
    redirect(conn, to: ~p"/game")
  end
end
