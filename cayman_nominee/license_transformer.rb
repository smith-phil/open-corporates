require 'json'
require 'date'

STDIN.each_line do |line|
  raw_record = JSON.parse(line)

  licence_record = {
    :company_name => raw_record['name'],
    :company_jurisdiction => 'Cayman Islands',
    :source_url => raw_record['source_url'],
    :sample_date => Date.parse(raw_record['recognised']),
    :licence_number => raw_record['number'],
    :jurisdiction_classification => raw_record['license_type'],
    :category => "Financial",
    :confidence => 'HIGH',
  }

  puts licence_record.to_json
end