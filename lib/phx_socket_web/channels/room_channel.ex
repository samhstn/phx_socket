defmodule PhxSocketWeb.RoomChannel do
  use PhxSocketWeb, :channel

  def join("room:lobby", payload, socket) do
    IO.inspect payload, label: "JOIN PAYLOAD"
    if authorized?(payload) do
      {:ok, "joining", socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("ping", payload, socket) do
    IO.inspect payload, label: "HANDLE_IN PING PAYLOAD"
    push socket, "hello", %{hello: "worlds"}
    {:reply, {:ok, payload}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
