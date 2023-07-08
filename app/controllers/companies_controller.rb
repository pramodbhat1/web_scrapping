require 'nokogiri'
require 'mechanize'
require 'parallel'

# Handle webscraping
class CompaniesController < ApplicationController
  def index
    scrape_data
    send_data_file
  end

  private

  # Scraping URLs
  def scrape_data
    agent = Mechanize.new

    urls = [
      'https://www.ycombinator.com/companies/airbnb',
      'https://www.ycombinator.com/companies/doordash',
      'https://www.ycombinator.com/companies/gitlab',
      'https://www.ycombinator.com/companies/fivetran',
      'https://www.ycombinator.com/companies/checkr',
      'https://www.ycombinator.com/companies/zapier',
      'https://www.ycombinator.com/companies/meesho',
      'https://www.ycombinator.com/companies/segment'
      # Add more URLs here
    ]

    companies = Parallel.map(urls, in_threads: urls.length) do |url|
      page = agent.get(url)
      scrape_company_data(page)
    end

    # Save the scraped data to the database in a batch insert
    Company.create(companies)
  end

  # Scrape data for a single company from the page
  def scrape_company_data(page)
    comp_name = page.at('//div[@class="prose max-w-full"]').text
    desc = page.at('//div[@class="prose hidden max-w-full md:block"]').text

    image_link = page.at('.h-32.w-32.shrink-0.clip-circle-32 img')['src']
    founded = page.at('//div[@class="flex flex-row justify-between"]').text.split(":")[1]

    linked_in_url = page.at('//a[@class="inline-block w-5 h-5 bg-contain bg-image-linkedin"]').attribute_nodes[1].value


    {
      name: comp_name,
      description: desc,
      image_link: image_link,
      website: page.uri.to_s,
      linkedin_url: linked_in_url,
      founding_year: founded
    }
  end

  # Generate the Excel file
  def send_data_file
    p = Axlsx::Package.new
    wb = p.workbook
    wb.add_worksheet(name: 'Companies') do |sheet|
      sheet.add_row ['Name', 'Description', 'Image Link', 'Website', 'LinkedIn URL', 'Founded Year'] # Add column headers

      # Iterate over the companies and add their data rows
      Company.find_each(batch_size: 1000) do |company|
        sheet.add_row [
          company.name,
          company.description,
          company.image_link,
          company.website,
          company.linkedin_url,
          company.founding_year
        ]
      end
    end

    # Save the Excel file
    file_path = Rails.root.join('public', 'companies_data.xlsx')
    p.serialize(file_path)

    # Send the file to the user
    send_file(file_path, filename: 'companies_data.xlsx', type: 'application/xlsx')
  end
end
