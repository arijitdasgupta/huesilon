defmodule Huesilon do
    def start_http(port) do
        children = [Plug.Adapters.Cowboy.child_spec(:http, HttpApp, [], port: port)]
        Supervisor.start_link(children, strategy: :one_for_one)
    end

    def start(_type, _args, port) do
        case Boot.bootup() do
            {:ok, _} -> 
                start_http(port)
            {:error, reason} -> 
                exit(1)
        end
    end

    def start(type, args) do
        start(type, args, 8080)
    end

    def start(port) do
        start([], [], port)
    end

    def start do
        start([], [])
    end
end
		