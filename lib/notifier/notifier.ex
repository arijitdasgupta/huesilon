defmodule Notifier do
    def notify_by_post(text, host, port) do
        HTTPoison.post "http://#{host}:#{port}", text, [{"Content-Type", "text/text"}]
    end
end