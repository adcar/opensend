class AddLimitsToShareLinks < ActiveRecord::Migration[7.1]
  def change
    add_column :share_links, :max_views, :integer
    add_column :share_links, :max_downloads, :integer
  end
end

