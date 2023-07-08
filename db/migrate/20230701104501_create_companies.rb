class CreateCompanies < ActiveRecord::Migration[7.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :address
      t.text :description
      t.string :image_link
      t.string :website
      t.string :linkedin_url
      t.integer :founding_year

      t.timestamps
    end
  end
end
