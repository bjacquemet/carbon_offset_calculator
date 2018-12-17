require 'csv'
require_relative 'great_circle'

def generate_data(filename, col_origin, col_destination, col_class=0)
  total_co2 = 0
  total_km = 0
  airports = File.read('data/airport.csv')
  csv_airports = CSV.parse(airports, :headers => false)
  CSV.foreach(filename, :headers => true) do |leg|
    begin
      airport_origin = csv_airports.find  do |row|
          row[4] == leg[col_origin]
      end
      airport_destination = csv_airports.find  do |row|
          row[4] == leg[col_destination]
      end
      distance = GreatCircle.distance(
        airport_origin[6].to_f,
        airport_origin[7].to_f,
        airport_destination[6].to_f,
        airport_destination[7].to_f)
      leg_co2 = calculate_eq_co2(distance)
      total_co2 += leg_co2
      total_km += distance
    rescue StandardError => e
    end
  end
  puts "TOTAL CO2 = #{total_co2.round} kg C02"
  puts "TOTAL KM = #{total_km.round} km"
end

# Simplified calculation
# using CarbonNeutral document (./documents/carbon_offset_factors.pdf)
def calculate_eq_co2(distance)
  # distance * 1.09 to take into account the uplift factor
  flight_distance = distance * 1.09
  if (flight_distance < 785)
    return flight_distance*0.17271
  elsif (flight_distance >= 785 && flight_distance < 3700)
    return flight_distance*0.09695
  else
    return flight_distance*0.08740
  end
end


filename = 'tmp/flights.csv'
col_origin = 1
col_destination = 2

generate_data(filename, col_origin, col_destination)
