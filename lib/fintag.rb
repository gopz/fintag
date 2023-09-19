require 'logging'
require 'yaml'
require 'csv'
require 'json'
require 'pry'
require 'date'

# TODO somehow pre-load these so the order isn't impt
require_relative "fintag/ft_file_handler"
require_relative "fintag/ft_taggable"
require_relative "fintag/csv_processors/ft_fidelity_csv"
require_relative "fintag/csv_processors/ft_discover_csv"

Logging.logger.root.appenders = Logging.appenders.stdout
Logging.logger["FtFileHandler"].level = :info
Logging.logger["FtFidelityCsv"].level = :info
Logging.logger["FtDiscoverCsv"].level = :info
Logging.logger["FtTaggable"].level = :info
