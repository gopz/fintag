# TODO maket this not rely on CSVs
class FtFileHandler
  attr_accessor :csv

  def initialize(params)
    # TODO abstract out to module
    @in_csv = nil
    @params = params
    @config = YAML.load_file("./config/config.yml")
    @logger = Logging.logger[self]
    @data_dir = @config["project_dir"] + @config["data_dir"]

    @source_dir = @data_dir +
      @config["in_dir"] +
      @config["csvs_dir"] +
      "/#{@params[:fin_source]}"

    @source_path = @source_dir + "/#{@params[:month]}.csv"

    @output_dir = @data_dir +
     @config["output_dir"] +
    @config["csvs_dir"] +
    "/#{@params[:fin_source]}"

    @output_path = @output_dir + "/#{@params[:month]}.csv"
  end

  def in_csv
    @in_csv ||= read_csv
  end

  def write_csv(csv_obj)
    # TODO I think default is overwrite anyway
      @logger.warn "Overwriting #{@output_path}" if File.file?(@output_path)
      File.open(@output_path, 'w') { |file| file.write(csv_obj) }
  end

  def read_csv
    @logger.info "Checking #{@source_dir} for #{@source_path}:"
    @logger.info "\n" + Dir["#{@source_dir}/*"].join("\n")

    if File.file?(@source_path)
      #TODO returns a file in memory, maybe not the best?
      return File.read(@source_path)
    else
      raise "Unable to locate data source"
    end
  end
end
