require_relative "../utils/ft_resolver"

GENERALIZED_HEADERS = ["Run Date", "Post Date", "Description", "Amount", "Inst", "Code", "Tag"]

module FtCsvParsable
  def normalize 
    rows = @csv.filter_map do |row|
      if row_present?(row)
        if @generalize
          CSV::Row.new(
            GENERALIZED_HEADERS, [
              Date.strptime(row[@date_index].strip, @date_format),
              row[@post_dt_index], 
              row[@desc_index], 
              accting_modifier(row[@amt_index]), 
              @fin_inst]
          )
        else
          CSV::Row.new(@valid_headers + ["Code", "Tag"], truncate_row(row, @valid_headers.length))
        end
      end
    end.compact
  end

  def truncate_row(row, valid_header_len)
    if row.length == valid_header_len
      row
    else
      truncated_row = row[0..valid_header_len]
      log_row_length_warning(row, valid_header_len, truncated_row)
      truncated_row
    end
  end

  # Rests on the premise that each row containing transaction information will have a valid
  # date in the column at date_index
  def row_present?(row)
    return false if row[1].nil? || row[@date_index].nil?

    Date.strptime(row[@date_index].strip, @date_format)
    true
  rescue
    log_invalid_row_warning(row)
    false
  end

  private

  def log_row_length_warning(row, valid_header_len, truncated_row)
    @logger.warn "Row length exceeds valid header length (row length #{row.length}, valid headers length: #{valid_header_len})"
    @logger.warn "Row: #{JSON.parse(row)}"
    @logger.warn "Returning #{truncated_row}"
  end

  def log_invalid_row_warning(row)
    @logger.warn "Removing blank or invalid row"
    @logger.warn row.empty? ? "Row: blank" : "Row: #{row.join(", ")}" 
  end

  def accting_modifier(amt)
    amt.to_f * @accting_modifier
  end
end
