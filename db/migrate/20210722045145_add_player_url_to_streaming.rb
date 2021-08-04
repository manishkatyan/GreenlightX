class AddPlayerUrlToStreaming < ActiveRecord::Migration[5.2]
  def change
    add_column :streamings, :player_url, :string
  end
end
