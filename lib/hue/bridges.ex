defmodule Bridges do
    def start do
        {:ok, bridgesAgent} = Agent.start_link(fn -> %{bridges: nil} end, name: __MODULE__)

        bridgesAgent
    end

    def set_bridges(newBridges) do
        Agent.update(__MODULE__, fn(_) -> 
            %{bridges: newBridges}
        end)
    end

    def get_bridges() do
        Agent.get(__MODULE__, fn bridges -> 
            case bridges.bridges do
                nil -> nil
                bridges -> bridges
            end
        end)
    end

    def try_connecting_to_bridges() do
        case UserConfigFile.read_hue_users_file() do
            {:ok, content} -> 
                UserConfigFile.read_userdata(content) |> 
                Enum.map(&(HueWrapper.hueconnect(&1[:ip], &1[:username])))
            {:error, _} -> HueWrapper.find_and_connect_all()
        end
    end

    def get_valid_bridges(bridgesOk) do
        bridgesOk |> Enum.filter(fn(bridge) -> 
            case bridge do
                {:ok, _} -> true
                {:error, _} -> false
            end
        end) |> Enum.map(fn(bridge) -> 
            {:ok, bridge} = bridge
            bridge
        end)
    end
end