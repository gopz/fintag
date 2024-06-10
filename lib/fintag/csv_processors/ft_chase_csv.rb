class FtChaseCsv < CSV
  extend FtCsvParsable

  def self.parse(*args)
    custom_args = args.pop
    @csv = super
    @generalize = custom_args[:generalize]
    @logger = Logging.logger[self]
    @conf = YAML.load_file("./config/chase.yml")
    @valid_headers = @conf["valid_headers"]
    @date_index = @conf["date_index"]
    @run_dt_index = @conf["run_dt_index"]
    @post_dt_index = @conf["post_dt_index"]
    @desc_index = @conf["desc_index"]
    @amt_index = @conf["amt_index"]
    @fin_inst = @conf["fin_inst"]
    @accting_modifier = @conf["accting_modifier"]
    @date_format = @conf["date_format"]

    FtChaseTable.new(normalize)
  end

  class FtChaseTable < CSV::Table
    include FtTaggable
    def initialize(*)
      @conf = YAML.load_file("./config/chase.yml")
      super
    end
  end
end
