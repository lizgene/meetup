class CandidateProcessor
  require 'HTTParty'
  require 'Nokogiri'
  require 'csv'

  def initialize(meetup_url)
    @meetup_url = meetup_url
    @meetup_name = @meetup_url.match(/meetup.com\/(?<name>.+)\/events/)[:name]
  end

  def process!
    page = get_and_parse_url(@meetup_url)
    candidates = []

    page.css('.member-name a').each do |profile_link|
      profile = get_and_parse_url(profile_link['href'])

      interests = profile.css('#memberTopicList .topic-widget')

      hireable_interests = interests.select do |interest|
        interest.text.downcase.match(/ruby|rails/)
      end

      if hireable_interests.any?
        candidates << { name: profile_link.text, profile: profile_link['href'] }
      end
    end

    if candidates.any?
      generate_csv(candidates)
      puts "Success! Check candidates-#{@meetup_name}.csv"
    else
      puts "Sorry, nobody was interested in Ruby on Rails at this meetup."
    end
  end

  def generate_csv(candidates)
    CSV.open("candidates-#{@meetup_name}.csv", 'w', headers: candidates.first.keys) do |csv|
      candidates.to_a.each do |candidate|
        csv << candidate.values
      end
    end
  end


  def get_and_parse_url(url)
    page = HTTParty.get(url)
    Nokogiri::HTML(page)
  end
end
