defmodule HabitWeb.ToolController do
  use HabitWeb, :controller

  def decrypt(conn, %{"encryptedData" => encrypted_data, "iv" => iv}) do
    json(conn, %{encrypted_data: encrypted_data, iv: iv, success: true})
  end
end
