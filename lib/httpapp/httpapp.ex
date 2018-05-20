defmodule HttpApp do
    use Plug.Router

    plug :match
    plug :dispatch

    def init(options) do
      options
    end

    match "/api/v1/lights/*_", to: HttpHue, init_opts: []

    match(_, do: send_resp(conn, 404, "Oops!"))
end