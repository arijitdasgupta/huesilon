defmodule Boot do
    require Logger

    def bootup do
        Bridges.start()

        validBridges = Bridges.try_connecting_to_bridges() |> Bridges.get_valid_bridges

        :ok = UserConfigFile.write_bridges(validBridges)

        Bridges.set_bridges(validBridges)

        case validBridges do
            [] -> {:error, "No valid bridges found"}
            _ -> {:ok, validBridges}
        end
    end
end