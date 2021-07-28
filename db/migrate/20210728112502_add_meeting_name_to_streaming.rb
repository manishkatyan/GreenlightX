class AddMeetingNameToStreaming < ActiveRecord::Migration[5.2]
  def change
    add_column :streamings, :meeting_name, :string
  end
end
