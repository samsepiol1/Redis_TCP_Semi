defmodule RedisSimulation do
  use GenServer
  @initial_state %{socket: nil}

  def command(pid, cmd) do
    GenServer.call(pid, {:command, cmd})
  end

  def handle_call({:command, cmd} from %{socket:socket} = state) do
    :ok -> gen_tcp.send(socket, Redis.RESP.encode(cmd))

    # 0 Means recive all avaliable bytes on the socket

    {:ok, msg} = :gen_tcp.recv(socket,0)
    {:reply, Redis.RESP.decode(msg), state}
  end
end

  def start_link do
    GenServer.start_link(__MODULE__, @initial_state)
  end

  def init(state) do
    # Binary Instructions socket to deliver messages from TCP insted charlists from earlang

   opts = [:binary, active: false]
   {:ok, socket} = :gen_tcp.connect('localhost', 6379, opts)
   {:ok, %{state | socket: socket}}
  end
end
