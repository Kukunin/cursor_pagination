# models
class Entity < ActiveRecord::Base

end

#migrations
class CreateAllTables < ActiveRecord::Migration[6.0]
  def self.up
    return if ActiveRecord::Base.connection.table_exists? 'entities'

    create_table :entities do |t|
      t.integer :custom
      t.datetime :custom_time
      t.timestamps
    end
  end
end

ActiveRecord::Migration.verbose = false
CreateAllTables.up
