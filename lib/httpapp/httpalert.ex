defmodule HttpAlert do
    use Plug.Router

    plug Plug.Logger
    plug :match
    plug :dispatch

    def init(options) do
        options
    end

    post "/api/v1/alert" do
        {:ok, body, _} = read_body(conn)
        Task.async(fn -> 
            HttpHue.blink()
            Notifier.notify_by_post(body, 'localhost', '2300')
        end)

        send_resp(conn, 200, 'OK')
    end
end