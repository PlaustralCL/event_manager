# frozen_string_literal: true

puts "Event Manager Initialized!\n\n"

# contents = File.read("event_attendees.csv")
# puts contents

lines = File.readlines("event_attendees.csv")
lines.each_with_index do |line, index|
  next if index.zero?

  columns = line.split(",")
  name = columns[2]
  puts name
end
