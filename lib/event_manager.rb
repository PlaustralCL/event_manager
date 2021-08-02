# frozen_string_literal: true

require "csv"
require "google-apis-civicinfo_v2"
require 'erb'


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

def determine_phone_number_status(phone_number)
  if phone_number.length == 10
    "Good"
  elsif phone_number.length == 11 && phone_number[0] == 1
    "Good"
  else
    red("Bad")
  end
end

def red(word)
  "\e[31m#{word}\e[0m"
end

def clean_phone_number(phone_number)
  phone_number = remove_bad_characters(phone_number)
  phone_number_status = determine_phone_number_status(phone_number)
  { phone_number: phone_number, phone_number_status: phone_number_status }
end
puts "Event Manager Initialized!\n\n"

contents = CSV.open(
  "event_attendees.csv",
  headers: true,
  header_converters: :symbol
)

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

contents.each do |row|
  name = row[:first_name]
  phone_number = row[:homephone]

  clean_number = clean_phone_number(phone_number)
  phone_number = clean_number[:phone_number]
  phone_number_status = clean_number[:phone_number_status]

  puts "#{name} #{phone_number} #{phone_number_status}"

end
