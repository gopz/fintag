def create_table_instance(rows)
  Object.const_get("#{self.name}::Ft#{self.name.match(/Ft(.*?)Csv/)[1]}Table").new(rows.compact)
end
