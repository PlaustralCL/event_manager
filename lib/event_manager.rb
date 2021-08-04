# frozen_string_literal: true

require "csv"
require "google-apis-civicinfo_v2"
require "erb"
require "time"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: "country",
      roles: ["legislatorUpperBody", "legislatorLowerBody"]
    ).officials

  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir("output") unless Dir.exist?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename, "w") do |file|
    file.puts form_letter
  end
end

def remove_bad_characters(phone_number)
  bad_characters = ["-", ".", "(", ")", " "]
  bad_characters.each do |char|
    phone_number = phone_number.tr(char, "")
  end
  phone_number
end

def red(word)
  "\e[31m#{word}\e[0m"
end

def clean_phone_number(phone_number)
  phone_number = remove_bad_characters(phone_number)
  phone_number_length = phone_number.length
  if phone_number_length == 10
    phone_number
  elsif phone_number_length == 11 && phone_number[0] == 1
    phone_number[1..10]
  else
    ""
  end
end

def count_frequency(ary)
  # Frequency hash from: https://womanonrails.com/each-with-object
  ary.each_with_object(Hash.new(0)) do |item, hash|
    hash[item] += 1
  end
end

def sort_hash(hash)
  # Hash sorting from:https://medium.com/@florenceliang/some-notes-about-using-hash-sort-by-in-ruby-f4b3a700fc33
  # sorts in descending order
  (hash.sort_by { |_key, value| -value }).to_h
end

# Turns an array into a frequency hash, sorted by the most frequently occurring elements
def analyze_data(ary)
  frequency = count_frequency(ary)
  sort_hash(frequency)
end

def time_targeting(registration_hours)
  hours_frequency = analyze_data(registration_hours)

  puts "Hour => # of registrations"
  hours_frequency.each_pair do |key, value|
    puts "#{key} => #{value}"
  end
end

def day_targeting(registration_day)
  day_frequency = analyze_data(registration_day)

  puts "Day  => # of registrations"
  day_frequency.each_pair do |key, value|
    puts "#{key} => #{value}"
  end
end


puts "Event Manager Initialized!\n\n"

contents = CSV.open(
  "event_attendees.csv",
  headers: true,
  header_converters: :symbol
)
### Form Letter Section ###
# template_letter = File.read("form_letter.erb")
# erb_template = ERB.new template_letter

# contents.each do |row|
#   id = row[0]
#   name = row[:first_name]

#   zipcode = clean_zipcode(row[:zipcode])

#   legislators = legislators_by_zipcode(zipcode)

#   form_letter = erb_template.result(binding)

#   save_thank_you_letter(id, form_letter)
# end

registration_hours = []
registration_day = []

contents.each do |row|
  name = row[:first_name]
  phone_number = row[:homephone]
  registration_time = Time.strptime(row[:regdate], "%m/%d/%y %k:%M")
  registration_hours.push(registration_time.hour)
  registration_day.push(registration_time.strftime("%A"))
  phone_number = clean_phone_number(phone_number)

  puts "#{name} #{phone_number}"
end

puts ""
time_targeting(registration_hours)
puts ""
day_targeting(registration_day)
