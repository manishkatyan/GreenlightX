class AddStreamingEnabledToStreaming < ActiveRecord::Migration[5.2]
  def change
    add_column :streamings, :streaming_enabled, :boolean
  end
end
