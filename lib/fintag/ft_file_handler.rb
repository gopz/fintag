require 'google/apis/sheets_v4'
require 'googleauth'
require 'yaml'
require 'logging'

class FtFileHandler
  attr_accessor :csv

  def initialize(params)
    @params = params
    @config = YAML.load_file("./config/config.yml")
    @logger = Logging.logger[self]
    @data_dir = @config["project_dir"] + @config["data_dir"]
    @generalized_output_sheet_id = @config["generalized_output_sheet_id"]

    @source_dir = @data_dir +
                  @config["in_dir"] +
                  @config["csvs_dir"] +
                  "/#{@params[:fin_source]}" +
                  "/#{@params[:year]}"

    @source_path = @source_dir + "/#{@params[:month]}.csv"

    @output_dir = @data_dir +
                  @config["output_dir"] +
                  @config["csvs_dir"] +
                  "/#{@params[:fin_source]}" +
                  "/#{@params[:year]}"

    @output_path = @output_dir + "/#{@params[:month]}.csv"
  end

  def write_to_cloud
    service = initialize_google_sheets_api
    sheet_name = @params[:month]
    clear_sheet_content(service, sheet_name)
    update_sheet(service, sheet_name)
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

  private

  def initialize_google_sheets_api
    service = Google::Apis::SheetsV4::SheetsService.new
    service.authorization = Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: File.open(@config["google_sheets_api_key"]),
      scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS
    )
    service
  end

  def clear_sheet_content(service, sheet_name)
    clear_request = Google::Apis::SheetsV4::ClearValuesRequest.new
    range = "#{sheet_name}!A1:Z1000"
    service.clear_values(@generalized_output_sheet_id, range, clear_request)
  end

  def update_sheet(service, sheet_name)
    range = "#{sheet_name}!A1"
    value_range = Google::Apis::SheetsV4::ValueRange.new
    csv_data = CSV.read(@output_path)
    value_range.values = csv_data

    service.update_spreadsheet_value(@generalized_output_sheet_id, range, value_range, value_input_option: 'USER_ENTERED')
  end
end
