# TODO this can probably be generic

MISC_SPENDING = 10

class FtFidelityTagger
	def self.tag(fidelity_csv)
    logger = Logging.logger[self]
		reg_map = YAML.load_file("./config/tag_maps/fidelity.yml")
		fidelity_csv.each do |row|
			action = row["Action"]
			hits = reg_map.select{|_k,v| v["regex"].match(action)}
			if !hits.empty?
				if hits.length > 1
					raise "Multiple hits for action #{action}\n#{JSON.pretty_generate(hits)}"
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
