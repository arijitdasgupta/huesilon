defmodule HueWrapper do
    require Logger

    defp connect(ip, username) do
        Huex.connect(ip, username)
    end

    defp connect(ip) do
        Huex.connect(ip) |> Huex.authorize("huesilon#application")
    end

    defp map_to_ok_err(bridge) do
        case bridge.status do
            :error -> {:error, bridge}
            _ -> {:ok, bridge}
        end
    end

    def find_and_connect_all do
        find_hue_bridges() |> Enum.map(&(hueconnect &1))
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

    def set_scene(bridge, scene_name) do
        sceneToSet = String.downcase(scene_name)
        allScenes = Huex.scenes(bridge)

        Enum.each(allScenes, fn {sceneId, sceneObj} -> 
            if String.downcase(sceneObj["name"]) === sceneToSet do
                Huex.set_group_state(bridge, 0, %{
                    "scene": sceneId
                })
            end
        end)
    end

    defp operate_lights(bridge, funk) do
        funk.(bridge, 0)
    end

    defp operate_lights_individually(bridge, funk) do
        lights = Huex.lights(bridge)
        Enum.each(lights, fn {light_index, _} -> 
            funk.(light_index)
        end)
    end

    def set_brightness(bridge, brightness) do
        Huex.set_group_state(bridge, 0, %{
            "bri": brightness
        })
    end

    def turn_on_lights(bridge) do
        operate_lights(bridge, &Huex.turn_group_on/2)
    end

    def turn_off_lights(bridge) do
        operate_lights(bridge, &Huex.turn_group_off/2)
    end

    def blink(bridge) do
        Huex.set_group_state(bridge, 0, %{
            "alert": "select"
        })
    end

    def start_loop(bridge) do
        Huex.set_group_state(bridge, 0, %{
            "effect": "colorloop"
        })
    end

    def stop_loop(bridge) do
        Huex.set_group_state(bridge, 0, %{
            "effect": "none"
        })
    end
end