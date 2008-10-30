require File.join(File.dirname(__FILE__), 'test_helper')

class ActiveRecordUUIDTestMigration < ActiveRecord::Migration
  def self.up
    create_table :uuid_test, :id => false do |t|
      t.uuid
    end
  end
end

class ActiveRecordUUIDTestChangeTableMigration  < ActiveRecord::Migration
  def self.up
    change_table :uuid_test do |t|
      t.uuid
    end
  end
end

class ActiveRecordUUIDMigrationTest < Test::Unit::TestCase
  include FlexMock::MockContainer

  def test_uuid_migration_method_creates_string_column
    flexmock(ActiveRecord::Base.connection).should_receive(:execute).at_least.once.and_return(true)
    flexmock(ActiveRecord::ConnectionAdapters::TableDefinition) do |m|
      m.new_instances.should_receive(:column).with(:uuid, :string, :null => false, :limit => 36).at_least.once.and_return(true)
    end
    ActiveRecordUUIDTestMigration.suppress_messages { ActiveRecordUUIDTestMigration.migrate(:up) }
  end
  
  def test_uuid_migration_method_when_changing_table_creates_string_column
    flexmock(ActiveRecord::ConnectionAdapters::Table) do |m|
      m.new_instances.should_receive(:column).with(:uuid, :string, :null => false, :limit => 36).at_least.once.and_return(true)
    end
    ActiveRecordUUIDTestChangeTableMigration.suppress_messages { ActiveRecordUUIDTestChangeTableMigration.migrate(:up) }
  end
  
end
