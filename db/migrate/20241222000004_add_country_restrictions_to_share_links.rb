class AddCountryRestrictionsToShareLinks < ActiveRecord::Migration[7.1]
  def change
    add_column :share_links, :allowed_countries, :string, array: true, default: []
    add_column :share_links, :blocked_countries, :string, array: true, default: []
  end
end

