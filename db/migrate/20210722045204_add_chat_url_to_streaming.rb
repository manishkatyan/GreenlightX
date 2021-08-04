class AddChatUrlToStreaming < ActiveRecord::Migration[5.2]
  def change
    add_column :streamings, :chat_url, :string
  end
end
