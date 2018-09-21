defmodule HueWrapper do
    require Logger

    @application_name Application.get_env(:huesilon, :applicationName)

    defp connect(ip, username) do
        Huex.connect(ip, username)
    end

    defp connect(ip) do
        Huex.connect(ip) |> Huex.authorize(@application_name)
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

    defp find_and_set_scene(bridge, scene_name) do
        sceneToSet = String.downcase(scene_name)
        allScenes = Huex.scenes(bridge)

        scenedIds = allScenes |> Enum.filter(
            fn {_, sceneObj} -> String.downcase(sceneObj["name"]) === sceneToSet end
        ) |> Enum.map(fn {sceneId, _} -> sceneId end)

        case scenedIds do 
            [sceneId | _] -> operate_all_lights(bridge, &(Huex.set_group_state(
                &1,
                &2,
                %{"scene": sceneId}
            )))
            _ -> nil
        end
    end

    defp operate_all_lights(bridge, funk) do
        funk.(bridge, 0)
    end

    defp operate_on_lights_with_delay(bridge, lights, funk) do
        [ light_id | lights ] = lights
        funk.(light_id)

        :timer.sleep(Kernel.trunc(:rand.uniform() * 15000))

        case lights do
            [] -> :ok
            lights -> operate_on_lights_with_delay(bridge, lights, funk)
        end
    end

    defp get_all_light_ids(bridge) do
        light_maps = Huex.lights(bridge)
        Enum.map(light_maps, fn {light_id, _} -> light_id end)
    end

    def set_scene(bridge, scene_name) do
        stop_loop(bridge)
        find_and_set_scene(bridge, scene_name)
    end

    def set_brightness(bridge, brightness) do
        operate_all_lights(bridge, &(Huex.set_group_state(&1, &2, %{
            "bri": brightness
        })))
    end

    def turn_on_lights(bridge) do
        operate_all_lights(bridge, &Huex.turn_group_on/2)
    end

    def turn_off_lights(bridge) do
        operate_all_lights(bridge, &Huex.turn_group_off/2)
    end

    def blink(bridge) do
        operate_all_lights(bridge, &(Huex.set_group_state(&1, &2, %{
            "alert": "select"
        })))
    end

    def start_loop(bridge) do
        lights = get_all_light_ids(bridge)

        spawn(fn -> operate_on_lights_with_delay(bridge, lights,
            fn (light_id) -> 
                Huex.set_state(bridge, light_id, %{
                    "effect": "colorloop"
                })
            end)
        end)
    end

    def stop_loop(bridge) do
        operate_all_lights(bridge, &(Huex.set_group_state(&1, &2, %{
            "effect": "none"
        })))
    end
end