require 'logging'
require 'yaml'
require 'csv'
require 'json'
require 'pry'
require 'date'

require_relative "fintag/ft_file_handler"
require_relative "fintag/csv_processors/ft_fidelity_csv"
require_relative "fintag/taggers/ft_fidelity_tagger"

Logging.logger.root.appenders = Logging.appenders.stdout
Logging.logger["FtFileHandler"].level = :info
Logging.logger["FtFidelityCsv"].level = :info
Logging.logger["FtFidelityTagger"].level = :info
