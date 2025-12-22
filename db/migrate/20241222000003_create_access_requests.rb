class CreateAccessRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :access_requests, id: :uuid do |t|
      t.references :share_link, null: false, foreign_key: true, type: :uuid
      t.string :email, null: false
      t.string :ip_address
      t.string :user_agent
      t.datetime :verified_at
      
      t.timestamps
    end
    
    add_index :access_requests, [:share_link_id, :email]
  end
end

