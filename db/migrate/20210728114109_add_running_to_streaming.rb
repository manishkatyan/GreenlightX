class AddRunningToStreaming < ActiveRecord::Migration[5.2]
  def change
    add_column :streamings, :running, :boolean, default: false
  end
end
