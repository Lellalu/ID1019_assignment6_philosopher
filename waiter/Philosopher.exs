defmodule Philosopher do
  @dreaming_time 0
  @eating_time 100

  def sleep(0) do
    :ok
  end
  def sleep(t) do
    :timer.sleep(:rand.uniform(t))
  end

  def start(hunger, waiter, left, right, name, ctrl) do
    spawn_link(fn -> init(hunger, waiter, left, right, name, ctrl) end)
  end

  def init(hunger, waiter, left, right, name, ctrl) do
    dreaming(hunger, waiter, left, right, name, ctrl)
  end

  def dreaming(0, _, _, _, name, ctrl) do
    IO.puts("#{name}: Hunger is zero")
    send(ctrl, :done)
  end

  def dreaming(hunger, waiter, left, right, name, ctrl) do
    IO.puts("#{name}: Start dreaming")
    sleep(@dreaming_time)
    eating(hunger, waiter, right, left, name, ctrl)
  end

  def eating(hunger, waiter, right, left, name, ctrl) do
    IO.puts("#{name}: Start eating")
    send(waiter, {:request, self()})
    receive do
      :granted ->
        IO.puts("#{name}: Granted to eat by waiter")
        Chopstick.request(left)
        IO.puts("#{name}: Received left chopstick")
        Chopstick.request(right)
        IO.puts("#{name}: Received right chopstick")
        sleep(@eating_time)
        IO.puts("#{name}: Finished eating, returning both chopsticks")
        send(left, :return)
        send(right, :return)
        send(waiter, :finish)
        dreaming(hunger-1, waiter, right, left, name, ctrl)
    end
  end
end
