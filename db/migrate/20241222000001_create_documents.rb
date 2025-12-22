class CreateDocuments < ActiveRecord::Migration[7.1]
  def change
    create_table :documents, id: :uuid do |t|
      t.string :filename, null: false
      t.string :content_type, null: false
      t.bigint :file_size, null: false
      t.string :storage_key, null: false
      
      # AI-generated content
      t.text :ai_summary
      t.string :ai_title
      t.jsonb :ai_metadata, default: {}
      
      # Owner tracking (optional - could add auth later)
      t.string :owner_token, null: false
      
      t.timestamps
    end
    
    add_index :documents, :owner_token
    add_index :documents, :storage_key, unique: true
  end
end

