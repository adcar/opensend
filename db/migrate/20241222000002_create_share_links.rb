class CreateShareLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :share_links, id: :uuid do |t|
      t.references :document, null: false, foreign_key: true, type: :uuid
      
      # Unique token for the share link
      t.string :token, null: false
      t.string :name # Optional name for the link
      
      # Permission settings (like DocuSend)
      t.boolean :require_email, default: false
      t.boolean :allow_download, default: true
      t.datetime :expires_at
      t.string :passcode_digest # BCrypt hash of passcode
      
      # Analytics
      t.integer :view_count, default: 0
      t.integer :download_count, default: 0
      t.datetime :last_viewed_at
      
      # Access log (emails that accessed this link)
      t.jsonb :access_log, default: []
      
      t.timestamps
    end
    
    add_index :share_links, :token, unique: true
    add_index :share_links, :expires_at
  end
end

