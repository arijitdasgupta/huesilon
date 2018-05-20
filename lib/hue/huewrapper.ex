defmodule HueWrapper do
    require Logger

    defp connect(ip, username) do
        Huex.connect(ip, username)
    end

    defp connect(ip) do
        Huex.connect(ip) |> Huex.authorize("huesilon#kuch-bhi")
    end

    defp map_to_ok_err(bridge) do
        case bridge.status do
            :error -> {:error, bridge}
            _ -> {:ok, bridge}
        end
    end

    defp find_hue_bridges do
        Huex.Discovery.discover()
    end

    def hueconnect(ipAddr, username) do
        Logger.info "Connecting to Hue bridge (#{ipAddr}) with existing username, password"
        
        connect(ipAddr, username) |> map_to_ok_err
    end

    defp hueconnect(ipAddr) do
        Logger.info "Connecting to the Hue bridge at (#{ipAddr})"
        
        connect(ipAddr) |> map_to_ok_err
    end

    def find_and_connect_all do
        find_hue_bridges() |> Enum.map(&(hueconnect &1))
    end

    defp operate_lights(bridge, funk) do
        lights = Huex.lights(bridge)
        Enum.each(lights, fn {k, _} -> 
            {numb, _} = Integer.parse(k)
            funk.(bridge, numb)
        end)
    end

    def turn_on_lights(bridge) do
        operate_lights(bridge, &Huex.turn_on/2)
    end

    def turn_off_lights(bridge) do
        operate_lights(bridge, &Huex.turn_off/2)
    end

    def test_beep(bridges) do
        Enum.each(bridges, fn(bridge) -> 
            turn_on_lights(bridge)
        end)

        Process.sleep(1000)

        Enum.each(bridges, fn(bridge) -> 
            turn_off_lights(bridge)
        end)

        :ok
    end
end