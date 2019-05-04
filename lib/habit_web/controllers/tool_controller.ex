defmodule HabitWeb.ToolController do
  use HabitWeb, :controller

  def decrypt(conn, %{"code" => code, "encryptedData" => encrypted_data, "iv" => iv}) do
    json(conn, %{success: true })
  end
end
