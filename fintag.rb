#!/usr/bin/env ruby

require_relative "lib/fintag" 

def print_help
  puts "Acceptable options: #{month_args.join(",")}"
  puts "Options given: #{ARGV.to_s}"
end

main_logger = Logging.logger(STDOUT)

month_args = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]
fin_inst_args = ["fidelity"]

month = ARGV.detect {|cmd| month_args.include?(cmd)}
fin_inst = ARGV.detect {|cmd| fin_inst_args.include?(cmd)}

unless month && fin_inst
  print_help
  exit
end

file_handler = FtFileHandler.new({fin_source: fin_inst, month: month})
kcsv = Object.const_get("Ft#{fin_inst.capitalize}Csv")
ktagger = Object.const_get("Ft#{fin_inst.capitalize}Tagger")

main_logger.info "Reading from CSV.."
csv_file = file_handler.in_csv

main_logger.info "Parsing CSV.."
parsed_csv = kcsv.parse(csv_file)

main_logger.info "Tagging CSV.."
tagged_csv = ktagger.tag(parsed_csv)

main_logger.info "Sorting CSV.."
# TODO have to create a new table for some reason, probably should sort at some point earlier
tagged_sorted_csv = CSV::Table.new(tagged_csv.sort{|a,b| a["Amount ($)"].to_i <=> b["Amount ($)"].to_i})

file_handler.write_csv(tagged_sorted_csv)
