# frozen_string_literal: true

require "csv"

# Create an object for missing zipcodes to prevent nil checks
class NullZip
  def length
    0
  end

  def rjust(*)
    "00000"
  end
end

def clean_zipcode(zipcode)
  zipcode = zipcode || NullZip.new
  if zipcode.length < 5
    zipcode.rjust(5, "0")
  elsif zipcode.length > 5
    zipcode[0..4]
  else zipcode.length == 5
    zipcode
  end
end

puts "Event Manager Initialized!\n\n"

contents = CSV.open(
  "event_attendees.csv",
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode])

  puts "#{name} #{zipcode}"
end
