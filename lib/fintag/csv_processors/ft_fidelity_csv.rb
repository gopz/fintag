class FtFidelityCsv < CSV
  BLANK_HEADERS_ROWS = 5
  VALID_HEADERS = ["Run Date", "Action", "Symbol", "Security Description", "Security Type", "Quantity", "Price ($)", "Commission ($)", "Fees ($)", "Accrued Interest ($)", "Amount ($)", "Settlement Date"]

  def self.parse(*)
    @logger = Logging.logger[self]
    csv = super
    return normalize!(csv)
  end

  #TODO also adds a "Code" column, get rid of hardcoding and make configurable
  def self.normalize!(csv)
    rows = csv[1..].filter_map{|row| CSV::Row.new(VALID_HEADERS + ["Code"], truncate_row(row)) if row_present?(row)}
    CSV::Table.new(rows)
  end

  def self.truncate_row(row)
    valid_header_len = VALID_HEADERS.length
    if row.length == valid_header_len
      row
    else
      truncated_row = row[0..valid_header_len]
      @logger.warn "Row length exceeds valid header length (row length #{row.length}, valid headers length: #{valid_header_len})"
      @logger.warn "Row: #{row.join(", ")}"
      @logger.warn "Returning #{truncated_row}"
      truncated_row
    end
  end

  def self.row_present?(row) 
    # TODO Every valid row has a US slash date to start, improve readability (headers get added back when table is constructed above)
    is_present = true
    begin
      Date.strptime(row[0].strip, "%m/%d/%Y")
    rescue
      @logger.warn "Removing blank or invalid row"
      @logger.warn "Row: #{row.join(", ")}" unless row[0].nil?
      is_present = false
    end
    is_present
  end
end
