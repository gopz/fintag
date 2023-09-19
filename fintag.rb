#!/usr/bin/env ruby

require_relative "lib/fintag"

MONTH_ARGS = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"]
FIN_INST_ARGS = ["fidelity", "chase", "discover"]

def print_help
  puts "Acceptable options: #{MONTH_ARGS.join(",")}"
  puts "Options given: #{ARGV.to_s}"
end

main_logger = Logging.logger(STDOUT)


month = ARGV.detect {|cmd| MONTH_ARGS.include?(cmd)}
fin_inst = ARGV.detect {|cmd| FIN_INST_ARGS.include?(cmd)}

unless month && fin_inst
  print_help
  exit
end

conf = YAML.load_file("./config/tag_maps/#{fin_inst}.yml")
amt_col_name = conf["amount_column"]
file_handler = FtFileHandler.new({fin_source: fin_inst, month: month})
kcsv = Object.const_get("Ft#{fin_inst.capitalize}Csv")

main_logger.info "Reading from CSV.."
csv_file = file_handler.in_csv

main_logger.info "Parsing CSV.."
parsed_csv = kcsv.parse(csv_file)

main_logger.info "Tagging CSV.."
parsed_csv.tag!

main_logger.info "Sorting CSV.."
# TODO have to create a new table for some reason, probably should sort at some point earlier
# TODO probably export to the csv classes, a lot of ways to go here, could use type converters
tagged_sorted_csv = CSV::Table.new(parsed_csv.sort{|a,b| a[amt_col_name].to_i <=> b[amt_col_name].to_i})

file_handler.write_csv(tagged_sorted_csv)
