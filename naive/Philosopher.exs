defmodule Philosopher do
  @dreaming_time 0
  @eating_time 100

  def sleep(0) do
    :ok
  end
  def sleep(t) do
    :timer.sleep(:rand.uniform(t))
  end

  def start(hunger, left, right, name, ctrl) do
    spawn_link(fn -> init(hunger, right, left, name, ctrl) end)
  end

  def init(hunger, left, right, name, ctrl) do
    dreaming(hunger, left, right, name, ctrl)
  end

  def dreaming(0, _, _, name, ctrl) do
    IO.puts("#{name}: Hunger is zero")
    send(ctrl, :done)
  end

  def dreaming(hunger, left, right, name, ctrl) do
    IO.puts("#{name}: Start dreaming")
    sleep(@dreaming_time)
    eating(hunger, right, left, name, ctrl)
  end

  def eating(hunger, right, left, name, ctrl) do
    IO.puts("#{name}: Start eating")
    Chopstick.request(left)
    IO.puts("#{name}: Received left chopstip")
    Chopstick.request(right)
    IO.puts("#{name}: Received right chopstip")
    sleep(@eating_time)
    IO.puts("#{name}: Finished eating, returning both chopsticks")
    send(left, :return)
    send(right, :return)
    dreaming(hunger-1, right, left, name, ctrl)
  end
end
