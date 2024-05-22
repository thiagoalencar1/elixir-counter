defmodule CounterWeb.Counter do
  use CounterWeb, :live_view

  @topic "live"

  def mount(_params, _session, socket) do
    CounterWeb.Endpoint.subscribe(@topic)
    {:ok, assign(socket, :val, 0)}
  end

  def handle_event("inc", _msg, socket) do
    new_state = update(socket, :val, &(&1 + 1))
    CounterWeb.Endpoint.broadcast_from(self(), @topic, "inc", new_state.assigns)
    {:noreply, new_state}
  end

  def handle_event("dec", _msg, socket) do
    new_state = update(socket, :val, &(&1 - 1))
    CounterWeb.Endpoint.broadcast_from(self(), @topic, "dec", new_state.assigns)
    {:noreply, new_state}
  end

  def handle_info(msg, socket) do
    {:noreply, assign(socket, val: msg.payload.val)}
  end

  def render(assigns) do
    ~H"""
      <.live_component module={CounterComponent} id="counter" val={@val} />
    """
  end
end
