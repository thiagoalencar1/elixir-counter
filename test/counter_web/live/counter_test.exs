defmodule CounterWeb.CounterTest do
  use CounterWeb.ConnCase
  import Phoenix.LiveViewTest

  test "connected mount", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    current = Counter.Count.current()
    assert html =~ "Counter: #{current}"
  end

  test "Increment", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    current = Counter.Count.current()
    assert html =~ "Counter: #{current}"
    assert render_click(view, :inc) =~ "Counter: #{current + 1}"
  end

  test "Decrement", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    current = Counter.Count.current()
    assert html =~ "Counter: #{current}"
    assert render_click(view, :dec) =~ "Counter: #{current - 1}"
  end

  test "handle_info/2 broadcast message", %{conn: conn} do
    {:ok, view, disconnected_html} = live(conn, "/")
    current = Counter.Count.current()

    assert disconnected_html =~ "Counter: #{current}"
    assert render(view) =~ "Counter: #{current}"
    send(view.pid, {:count, 2})
    assert render(view) =~ "Counter: 2"
  end

  test "handle_info/2 Presence Update - Joiner", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    assert html =~"Connected Clients: 1"
    send(view.pid, %{
      event: "presence_diff",
      payload: %{
        joins: %{"phx-Fhb_dqdqsOCzKQAl" => %{metas: [%{phx_ref: "Fhb_dqdqsOCzKQAl"}]}},
        leaves: %{}
      }
    })
    assert render(view) =~ "Connected Clients: 3"
  end

  test "handle_info/2 Presence Update - Leaver", %{conn: conn} do
    {:ok, view, html} = live(conn, "/")
    assert html =~ "Connected Clients: 1"

    send(view.pid, %{
      event: "presence_diff",
      payload: %{
        joins: %{},
        leaves: %{"phx-Fhb_dqdqsOCzKQAl" => %{metas: [%{phx_ref: "Fhb_dqdrwlCmfABl"}]}}
      }
    })

    assert render(view) =~ "Connected Clients: 1"
  end
end
