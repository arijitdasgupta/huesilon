defmodule UserConfigFile do
    @users_filename Application.get_env(:huesilon, :userConfigFile)

    def read_hue_users_file() do
        fileReadOp = File.read(@users_filename)
        case fileReadOp do
            {:ok, content} -> cond do
                String.first(content) -> {:ok, content}
                true -> {:error, "blank file"}
            end
            {:error, _} -> fileReadOp
        end
    end

    def read_userdata(content) do
        content |> String.split("\n") |> Enum.filter(&(String.first(&1))) |> Enum.map(fn(line) -> 
            [ip, username] = String.split(line, " ")
            %{:ip => ip, :username => username}
        end)
    end

    def create_userdata(ip_and_user_list) do
         Enum.reduce(ip_and_user_list, "", fn(ip_and_user, acc) -> 
            acc <> "#{ip_and_user[:ip]} #{ip_and_user[:username]}\n"
        end)
    end

    def write_hue_users_file(content) do
        {:ok, file} = File.open(@users_filename, [:write])
        IO.write(file, content)
        File.close(file)
    end

    def write_bridges(bridges) do
        bridges 
            |> Enum.map(&(%{:ip => &1.host, :username => &1.username}))
            |> create_userdata
            |> write_hue_users_file
    end
end