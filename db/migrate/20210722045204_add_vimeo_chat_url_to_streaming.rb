class AddVimeoChatUrlToStreaming < ActiveRecord::Migration[5.2]
  def change
    add_column :streamings, :vimeo_chat_url, :string
  end
end
