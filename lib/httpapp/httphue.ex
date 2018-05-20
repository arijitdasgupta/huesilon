defmodule HttpHue do
    use Plug.Router

    plug Plug.Logger
    plug :match
    plug :dispatch

    def init(options) do
        options
    end

    get "/api/v1/lights/on" do
        bridges = Bridges.get_bridges()
        Enum.each(bridges, fn(bridge) -> 
            HueWrapper.turn_on_lights(bridge)
        end)

        send_resp(conn, 200, 'OK')
    end

    get "/api/v1/lights/off" do
        bridges = Bridges.get_bridges()
        Enum.each(bridges, fn(bridge) -> 
            HueWrapper.turn_off_lights(bridge)
        end)

        send_resp(conn, 200, 'OK')
    end
end