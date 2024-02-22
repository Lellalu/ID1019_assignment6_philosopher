defmodule Chopstick do
  def start do
    spawn_link(fn -> available() end)
  end

  def available() do
    receive do
      {:request, ref, from} ->
        send(from, {:granted, ref})
        gone(ref)
      {:return, _} -> available()
      :quit -> :ok
    end
  end

  def gone(ref) do
    receive do
      {:return, ^ref} -> available()
      :quit -> :ok
    end
  end

  def request(stick, ref) do
    send(stick, {:request, ref, self()})
  end

  def granted(ref, timeout) do
    receive do
      {:granted, ^ref} -> :ok
      {:granted, _} -> granted(ref, timeout)
    after timeout -> :no
    end
  end

  def quit(stick) do
    send(stick, :quit)
  end
end
