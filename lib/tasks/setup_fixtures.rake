desc 'Create YAML test fixtures from data in an existing database.
Defaults to development database.  Set RAILS_ENV to override.'

task :setup_fixtures => :environment do
  sql         = "SELECT * FROM %s"
  skip_tables = ["schema_migrations"]
  tables      = ActiveRecord::Base.connection.tables - skip_tables  
  ActiveRecord::Base.establish_connection
  tables.each do |table_name|
    i = "000"
    File.open("#{Rails.root}/test/fixtures/#{table_name}.yml", 'w') do |file|
      data = ActiveRecord::Base.connection.select_all(sql % table_name)
      file.write data.inject({}) { |hash, record|
        hash["#{table_name}_#{i.succ!}"] = record
        hash
      }.to_yaml
    end
  end
end