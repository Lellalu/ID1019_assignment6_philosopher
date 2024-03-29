defmodule Chopstick do
  def start do
    spawn_link(fn -> available() end)
  end

  def available() do
    receive do
      {:request, from} ->
        send(from, :granted)
        gone()
      :quit -> :ok
    end
  end

  def gone() do
    receive do
      :return -> available()
      :quit -> :ok
    end
  end

  def request(stick) do
    send(stick, {:request, self()})
    receive do
      :granted -> :ok
    end
  end

  def quit(stick) do
    send(stick, :quit)
  end
end
