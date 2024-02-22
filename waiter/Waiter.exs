defmodule Waiter do
  def start(n) do
    spawn_link(fn -> serve(n) end)
  end

  def serve(1) do
    receive do
      :finish -> serve(2)
    end
  end

  def serve(n) do
    receive do
      {:request, from} ->
        send(from, :granted)
        serve(n-1)
      {:finish} -> serve(n+1)
    end
  end
end
