json.extract! company, :id, :name, :address, :description, :image_link, :website, :linkedin_url, :founding_year, :created_at, :updated_at
json.url company_url(company, format: :json)
