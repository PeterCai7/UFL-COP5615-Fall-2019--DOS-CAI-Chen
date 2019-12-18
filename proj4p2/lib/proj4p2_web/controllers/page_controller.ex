defmodule Proj4p2Web.PageController do
  use Proj4p2Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
