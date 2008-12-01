require File.join(File.dirname(__FILE__), 'test_helper')

class ActiveRecordUUIDMigrationTest < Test::Unit::TestCase

  class ActiveRecordUUIDTestMigration < ActiveRecord::Migration
    def self.up; create_table(:uuid_test, :id => false) { |t| t.uuid }; end
  end

  class ActiveRecordUUIDTestChangeTableMigration  < ActiveRecord::Migration
    def self.up; change_table(:uuid_test) { |t| t.uuid }; end
  end  

  def setup
    ActiveRecord::Base.connection.stubs(:execute).returns(true)
  end
  
  context "creating a new table with a uuid" do
    
    should "add a unique index" do
      ActiveRecord::ConnectionAdapters::TableDefinition.any_instance.expects(:index).with(:uuid, :unique => true)
      ActiveRecordUUIDTestMigration.suppress_messages { ActiveRecordUUIDTestMigration.up }
    end
    
    should "create a string column for the UUID" do
      ActiveRecord::ConnectionAdapters::TableDefinition.any_instance.expects(:column).with(:uuid, :string, :null => false, :limit => 36)
      ActiveRecordUUIDTestMigration.suppress_messages { ActiveRecordUUIDTestMigration.up }
    end
    
  end # creating a new table with a uuid
  
  context "adding a uuid to an existing table" do
    
    should "create a string column for the UUID" do
      ActiveRecord::ConnectionAdapters::Table.any_instance.expects(:column).with(:uuid, :string, :null => false, :limit => 36)
      ActiveRecordUUIDTestChangeTableMigration.suppress_messages { ActiveRecordUUIDTestChangeTableMigration.migrate(:up) }
    end
    
    should "add a unique index" do
      ActiveRecord::ConnectionAdapters::Table.any_instance.expects(:index).with(:uuid, :unique => true)
      ActiveRecordUUIDTestChangeTableMigration.suppress_messages { ActiveRecordUUIDTestChangeTableMigration.migrate(:up) }
    end

  end # adding a uuid to an existing table
  
end
