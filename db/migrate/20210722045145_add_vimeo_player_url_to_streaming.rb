class AddVimeoPlayerUrlToStreaming < ActiveRecord::Migration[5.2]
  def change
    add_column :streamings, :vimeo_player_url, :string
  end
end
