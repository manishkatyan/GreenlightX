class AddSubscriptionToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :subscription_id, :string
    add_column :users, :subscription_status, :string
  end
end
