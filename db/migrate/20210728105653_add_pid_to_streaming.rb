class AddPidToStreaming < ActiveRecord::Migration[5.2]
  def change
    add_column :streamings, :pid, :string, default: "0"
  end
end
