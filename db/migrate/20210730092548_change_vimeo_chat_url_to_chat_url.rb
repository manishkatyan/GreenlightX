class ChangeVimeoChatUrlToChatUrl < ActiveRecord::Migration[5.2]
  def change
    rename_column :streamings, :vimeo_chat_url, :chat_url
    rename_column :streamings, :vimeo_player_url, :player_url
    #Ex:- rename_column("admin_users", "pasword","hashed_pasword")
  end
end
