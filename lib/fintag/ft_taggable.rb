module FtTaggable
  def tag!
    logger = Logging.logger[self]
    match_col_name = @conf["desc_column"]
    amount_col_name = @conf["amount_column"]
    unidentifiable_pos_tag = @conf["unidentifiable_pos_tag"]
    unidentifiable_pos_code = @conf["unidentifiable_pos_code"]
    unidentifiable_neg_tag = @conf["unidentifiable_neg_tag"]
    unidentifiable_neg_code = @conf["unidentifiable_neg_code"]

    reg_map = YAML.safe_load(File.read("./config/tag_maps/common.yml"), permitted_classes: [Regexp])["codes"]

    self.each do |row|
      # This handles the case where the csv has been generalized, but the fidelity column name is "Action"
      # where as for Chase and Discover it's also "Description"
      match_txt = row[match_col_name] || row["Description"]
      hits = reg_map.select { |_k, v| v["regex"].match(match_txt) }

      if hits.empty?
        # Same as above
        amount_col = row[amount_col_name] || row["Amount"]
        if amount_col.to_f > 0
          row["Code"] = unidentifiable_pos_code
          row["Tag"] = unidentifiable_pos_tag
        else
          row["Code"] = unidentifiable_neg_code
          row["Tag"] = unidentifiable_neg_tag
        end
      else
        if hits.length > 1
          raise "Multiple hits for transaction #{match_txt}\n#{JSON.pretty_generate(hits)}"
        else
          code = hits.first[1]["code"]
          row["Code"] = code
          row["Tag"] = hits.first[0]
        end
      end
    end
  end
end
