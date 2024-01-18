# Introduction

A Redis server is just a TCP server sends and receives messages. Redis uses its own protocol (more on this in a while) on top of TCP to exchange data, without relying on common protocols such as HTTP, but we will not focus on that: we will only deal with the TCP connection from Elixir to the Redis server.

A little side note: obviously, there are several Erlang and Elixir libraries for talking to Redis, but bear with me. Since there's no point in coming up with a clever name for the library we're going to write, we'll just call it Redis

In Erlang and Elixir, TCP connections are handled using the :gen_tcp module. In this article we'll only set up clients that connect to an external TCP server, but the :gen_tcp module can also be used to set up TCP servers.

All messages to the server are sent using :gen_tcp.send/2. Messages sent from the server to the client are usually delivered to the client process as Erlang messages, so it's straightforward to work with them. As we will see later on, we can control how messages are delivered to the client process with the value of the :active option on the TCP socket.

```elixir
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



```


# Source

https://andrealeopardi.com/posts/handling-tcp-connections-in-elixir/
