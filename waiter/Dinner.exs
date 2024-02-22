defmodule Dinner do
  def start(), do: spawn(fn -> init() end)

  def init() do
    c1= Chopstick.start()
    c2= Chopstick.start()
    c3= Chopstick.start()
    c4= Chopstick.start()
    c5= Chopstick.start()
    ctrl = self()
    waiter = Waiter.start(5)
    Philosopher.start(5, waiter, c1, c2, :arendt, ctrl)
    Philosopher.start(5, waiter, c2, c3, :hypatia, ctrl)
    Philosopher.start(5, waiter, c3, c4, :simone, ctrl)
    Philosopher.start(5, waiter, c4, c5, :elisabeth, ctrl)
    Philosopher.start(5, waiter, c5, c1, :ayn, ctrl)
    wait(5,[c1, c2, c3, c4, c5])
  end

  def wait(0, chopsticks) do
    Enum.each(chopsticks, fn(c) -> Chopstick.quit(c) end)
  end
  def wait(n, chopsticks) do
    receive do
      :done ->
        wait(n - 1,chopsticks)
      :abort->
        Process.exit(self(), :kill)
    end
  end
end
