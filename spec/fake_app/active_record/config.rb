ActiveRecord::Base.configurations = {'test' => {:adapter => 'sqlite3', :database => ':memory:'}}
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.establish_connection('test')
