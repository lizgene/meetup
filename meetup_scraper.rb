require 'HTTParty'
require 'Nokogiri'
require 'csv'

page = HTTParty.get(YOUR_MEETUP_URL)

parsed_page = Nokogiri::HTML(page)

candidates = []

parsed_page.css('.member-name a').each do |link|
  name = link.text
  profile_url = link['href']

  profile_page = HTTParty.get(profile_url)
  parsed_profile_page = Nokogiri::HTML(profile_page)

  interests = parsed_profile_page.css('#memberTopicList .topic-widget')
  hireable_interests = interests.select do |interest|
    interest.text.downcase.match(/ruby|rails/)
  end

  if hireable_interests.any?
    candidates << { name: name, profile: profile_url }
  end
end

CSV.open('candidates.csv', 'w', headers: candidates.first.keys) do |csv|
  candidates.to_a.each do |candidate|
    csv << candidate.values
  end
end
