defmodule HttpHue do
    use Plug.Router

    plug Plug.Logger
    plug :match
    plug :dispatch

    def init(options) do
        options
    end

    post "/api/v1/lights/on" do
        bridges = Bridges.get_bridges()
        Enum.each(bridges, fn(bridge) -> 
            HueWrapper.turn_on_lights(bridge)
        end)

        send_resp(conn, 200, 'OK')
    end

    post "/api/v1/lights/off" do
        bridges = Bridges.get_bridges()
        Enum.each(bridges, fn(bridge) -> 
            HueWrapper.turn_off_lights(bridge)
        end)

        send_resp(conn, 200, 'OK')
    end

    # POST body <brightness> 0 to 100
    post "/api/v1/lights/brightness" do
        {:ok, body, _} = read_body(conn)

        {brightness, _} = Integer.parse(body)
        
        brightness = cond do
            brightness > 100 -> 100
            brightness < 0 -> 0
            true -> brightness
        end

        brightness = Kernel.trunc((brightness / 100) * 255)

        bridges = Bridges.get_bridges()
        Enum.each(bridges, fn(bridge) ->
            HueWrapper.set_brightness(bridge, brightness)
        end)

        send_resp(conn, 200, 'OK')
    end

    # POST body <scene> 'Savannah Sunset'
    post "/api/v1/lights/scene" do
        {:ok, body, _} = read_body(conn)

        bridges = Bridges.get_bridges()
        Enum.each(bridges, fn(bridge) ->
            HueWrapper.set_scene(bridge, body)
        end)

        send_resp(conn, 200, 'OK')
    end
end