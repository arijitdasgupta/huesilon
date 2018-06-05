defmodule HueWrapper do
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

    defp find_hue_bridges do
        Huex.Discovery.discover()
    end

    def hueconnect(ipAddr, username) do        
        connect(ipAddr, username) |> map_to_ok_err
    end

    defp hueconnect(ipAddr) do
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

    def set_brightness(bridge, brightness) do
        Huex.set_group_state(bridge, 0, %{
            "bri": brightness
        })
    end

    def find_and_connect_all do
        find_hue_bridges() |> Enum.map(&(hueconnect &1))
    end

    defp operate_lights(bridge, funk) do
        funk.(bridge, 0)
    end

    def turn_on_lights(bridge) do
        operate_lights(bridge, &Huex.turn_group_on/2)
    end

    def turn_off_lights(bridge) do
        operate_lights(bridge, &Huex.turn_group_off/2)
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