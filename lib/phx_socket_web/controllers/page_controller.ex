defmodule PhxSocketWeb.PageController do
  use PhxSocketWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
