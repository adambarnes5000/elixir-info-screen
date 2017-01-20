defmodule Provider do
  defmacro __using__(_) do
      quote do
          def success(body) do
            {200,body}
          end
          def not_found(body) do
            {404,body}
          end
          def bad_gateway(body) do
            {502,body}
          end
          def download(url) do
            case HTTPotion.get(url) do
              %HTTPotion.Response{status_code: code, body: body} when code>=200 and code<400 ->
                {:ok, to_string(body)}
              %HTTPotion.Response{status_code: code} ->
                {:error, "#{url} returned status #{code}"}
              %HTTPotion.ErrorResponse{message: message} ->
                IO.puts "Error from #{url}"
                {:error, message}
            end
          end
      end
   end
  
end