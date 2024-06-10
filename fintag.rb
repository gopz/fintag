#!/usr/bin/env ruby

require_relative "lib/fintag"

MONTH_ARGS = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "spt", "oct", "nov", "dec"]
FIN_INST_ARGS = ["fidelity", "chase", "discover", "personal", "all"]
PERSONAL_FIN_INSTS = ["fidelity", "discover"]
BIZ_FIN_INSTS = ["chase"]
YEAR_ARGS = ["2023", "2024"]
DEFAULT_YEAR = "2024"

def print_help
  puts "Acceptable options: #{MONTH_ARGS.join(",")}"
  puts "Options given: #{ARGV.to_s}"
end

def parse_and_tag_csv(fin_inst, month, file_handler, generalize: false)
  main_logger = Logging.logger(STDOUT)

  conf = YAML.load_file("./config/#{fin_inst}.yml")
  amt_col_name = conf["amount_column"]
  kcsv = Object.const_get("Ft#{fin_inst.capitalize}Csv")

  main_logger.info "Reading from CSV.."
  csv_file = file_handler.in_csv

  main_logger.info "Parsing CSV.."
  parsed_csv = kcsv.parse(csv_file, generalize: generalize)

  main_logger.info "Tagging CSV.."
  parsed_csv.tag!

  main_logger.info "Sorting CSV.."
  # TODO have to create a new table for some reason, probably should sort at some point earlier
  # TODO probably export to the csv classes, a lot of ways to go here, could use type converters
  CSV::Table.new(parsed_csv.sort{|a,b| a[amt_col_name].to_i <=> b[amt_col_name].to_i})
end


# This is probably a little bit dangrous as it assumes that none of these positional arguments
# ever overlap, for instance having a fin_inst named "jan" could break this
month = ARGV.detect {|cmd| MONTH_ARGS.include?(cmd)}
year = ARGV.detect {|cmd| YEAR_ARGS.include?(cmd)} || DEFAULT_YEAR
fin_inst = ARGV.detect {|cmd| FIN_INST_ARGS.include?(cmd)}

unless month && fin_inst && year
  print_help
  exit
end

if fin_inst == "personal"
    rs = []
    PERSONAL_FIN_INSTS.each do |fin_inst|
      t_and_p = parse_and_tag_csv(fin_inst, month, FtFileHandler.new({fin_source: fin_inst, month: month, year: year}), generalize: true)
      # Todo another run through the csv file :(
      t_and_p.each {|r| rs << r}
    end

    table = CSV::Table.new(rs)
    FtFileHandler.new(fin_source: "personal", month: month, year: year).write_csv(table) 

elsif fin_inst == "all"
    rs = []
    (BIZ_FIN_INSTS + PERSONAL_FIN_INSTS).each do |fin_inst|
      t_and_p = parse_and_tag_csv(fin_inst, month, FtFileHandler.new({fin_source: fin_inst, month: month, year: year}), generalize: true)
      # Todo another run through the csv file :(
      t_and_p.each {|r| rs << r}
    end

    table = CSV::Table.new(rs)
    ft = FtFileHandler.new(fin_source: "all", month: month, year: year) 
    ft.write_csv(table)
    ft.write_to_cloud
else
  file_handler = FtFileHandler.new({fin_source: fin_inst, month: month, year: year})
  file_handler.write_csv(parse_and_tag_csv(fin_inst, month, file_handler, generalize: false))
end


