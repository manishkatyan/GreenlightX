class AddHidePresentationToStreaming < ActiveRecord::Migration[5.2]
  def change
    add_column :streamings, :hide_presentation, :string
  end
end
