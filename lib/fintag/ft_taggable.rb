MISC_SPENDING = 10

module FtTaggable
	def tag!
    logger = Logging.logger[self]
    # TODO Move to the file handler
    conf = YAML.load_file("./config/tag_maps/#{self.class.name.match(/Ft(.*?)Csv/)[1]}.yml")
    reg_map = conf["codes"]
    match_col_name = conf["match_column"]
    self.each do |row|
			match_txt = row[match_col_name]
			hits = reg_map.select{|_k,v| v["regex"].match(match_txt)}
			if !hits.empty?
				if hits.length > 1
					raise "Multiple hits for transaction  #{match_txt}\n#{JSON.pretty_generate(hits)}"
				else
					# TODO consider adjusting map structure to avoid the [1]
          code = hits.first[1]["code"]
					row["Code"] = code
				end
      else
        row["Code"] = MISC_SPENDING
      end
		end
	end
end
