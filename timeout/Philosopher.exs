defmodule Philosopher do
  @dreaming_time 0
  @eating_time 100
  @timeout_time 100

  def sleep(0) do
    :ok
  end
  def sleep(t) do
    :timer.sleep(:rand.uniform(t))
  end

  def start(hunger, strength, left, right, name, ctrl) do
    spawn_link(fn -> init(hunger, strength, right, left, name, ctrl) end)
  end

  def init(hunger, strength, left, right, name, ctrl) do
    dreaming(hunger, strength, left, right, name, ctrl)
  end

  def dreaming(_, 0, _, _, name, ctrl) do
    IO.puts("#{name}: strength is zero")
    send(ctrl, :done)
  end

  def dreaming(0, _, _, _, name, ctrl) do
    IO.puts("#{name}: Hunger is zero")
    send(ctrl, :done)
  end

  def dreaming(hunger, strength, left, right, name, ctrl) do
    IO.puts("#{name}: Start dreaming")
    sleep(@dreaming_time)
    eating(hunger, strength, right, left, name, ctrl)
  end

  def eating(hunger, strength, right, left, name, ctrl) do
    IO.puts("#{name}: Start eating")
    case Chopstick.request(left, @timeout_time) do
      :ok ->
        IO.puts("#{name}: Received left chopstick")
        case Chopstick.request(right, @timeout_time) do
          :ok ->
            IO.puts("#{name}: Received right chopstick")
            sleep(@eating_time)
            IO.puts("#{name}: Finished eating, returning both chopsticks")
            send(left, :return)
            send(right, :return)
            dreaming(hunger-1, strength, right, left, name, ctrl)
          :no ->
            IO.puts("#{name}: right chopstick timeout")
            IO.puts("#{name}: return left chopstick after timeout")
            send(left, :return)
            dreaming(hunger, strength-1, right, left, name, ctrl)
        end
      :no ->
        IO.puts("#{name}: left chopstick timeout")
        dreaming(hunger, strength-1, right, left, name, ctrl)
    end
  end
end
