defmodule Philosopher do
  @dreaming_time 100
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
    ref = make_ref()
    Chopstick.request(left, ref)
    Chopstick.request(right, ref)
    case Chopstick.granted(ref, @timeout_time) do
      :ok ->
        IO.puts("#{name}: Received first chopstick")
        case Chopstick.granted(ref, @timeout_time) do
          :ok ->
            IO.puts("#{name}: Received second chopstick")
            sleep(@eating_time)
            IO.puts("#{name}: Finished eating, returning both chopsticks")
            send(left, {:return, ref})
            send(right, {:return, ref})
            dreaming(hunger-1, strength, right, left, name, ctrl)
          :no ->
            IO.puts("#{name}: Failed to get the second chopstick")
            send(left, {:return, ref})
            send(right, {:return, ref})
            dreaming(hunger, strength-1, right, left, name, ctrl)
        end
      :no ->
        IO.puts("#{name}: Failed to get the first chopstick")
        dreaming(hunger, strength-1, right, left, name, ctrl)
    end
  end
end
