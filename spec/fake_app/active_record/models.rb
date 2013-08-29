# models
class Entity < ActiveRecord::Base

end

#migrations
class CreateAllTables < ActiveRecord::Migration
  def self.up
    create_table :entities do |t|
      t.integer :custom
      t.datetime :custom_time
      t.timestamps
    end
  end
end

ActiveRecord::Migration.verbose = false
CreateAllTables.up
