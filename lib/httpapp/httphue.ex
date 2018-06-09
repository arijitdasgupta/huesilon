defmodule HttpHue do
    use Plug.Router

    plug Plug.Logger
    plug :match
    plug :dispatch

    defp clamp_brightness_value(brightness) do
        brightness = cond do
            brightness > 100 -> 100
            brightness < 0 -> 0
            true -> brightness
        end

        Kernel.trunc((brightness / 100) * 255)
    end

    defp act_on_all_bridges(funk) do
        bridges = Bridges.get_bridges()
        Enum.each(bridges, funk)
    end

    def blink() do
        act_on_all_bridges(fn(bridge) ->
            HueWrapper.blink(bridge)
        end)
    end

    def init(options) do
        options
    end

    post "/api/v1/lights/on" do
        act_on_all_bridges(fn(bridge) -> 
            HueWrapper.turn_on_lights(bridge)
        end)

        send_resp(conn, 200, 'OK')
    end

    post "/api/v1/lights/off" do
        act_on_all_bridges(fn(bridge) -> 
            HueWrapper.turn_off_lights(bridge)
        end)

        send_resp(conn, 200, 'OK')
    end

    # POST body <brightness> 0 to 100
    post "/api/v1/lights/brightness" do
        {:ok, body, _} = read_body(conn)

        {brightness, _} = Integer.parse(body)
        
        brightness = clamp_brightness_value(brightness)

        act_on_all_bridges(fn(bridge) ->
            HueWrapper.set_brightness(bridge, brightness)
        end)

        send_resp(conn, 200, 'OK')
    end

    post "/api/v1/lights/blink" do
        blink()        

        send_resp(conn, 200, 'OK')
    end

    # POST body <scene> 'Savannah Sunset'
    post "/api/v1/lights/scene" do
        {:ok, body, _} = read_body(conn)

        act_on_all_bridges(fn(bridge) ->
            HueWrapper.set_scene(bridge, body)
        end)

        send_resp(conn, 200, 'OK')
    end
end