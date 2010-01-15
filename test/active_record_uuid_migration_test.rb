require File.join(File.dirname(__FILE__), 'test_helper')

class ActiveRecordUUIDMigrationTest < Test::Unit::TestCase

  def new_migration(&block)
    Class.new(ActiveRecord::Migration) do
      def self.up_suppressed; suppress_messages { up }; end
      (class<<self;self;end).instance_eval { define_method(:up, &block) }
    end
  end

  def setup
    ActiveRecord::Base.connection.stubs(:execute).returns(true)
    ActiveRecord::ConnectionAdapters::TableDefinition.any_instance.stubs(:column)
    ActiveRecord::ConnectionAdapters::Table.any_instance.stubs(:column)
  end
  
  context "creating a new table with a uuid" do
    setup do
      @migration = new_migration do 
        create_table(:uuid_test, :id => false) { |t| t.uuid }
      end
    end
    
    should_eventually "add a unique index" do
      ActiveRecord::ConnectionAdapters::TableDefinition.any_instance.expects(:index).with(:uuid, :unique => true)
      @migration.up_suppressed
    end
    
    should "create a string column for the UUID" do
      ActiveRecord::ConnectionAdapters::TableDefinition.any_instance.expects(:column).with(:uuid, :string, :null => false, :limit => 36)
      @migration.up_suppressed
    end
    
    should "skip adding the unique index if add_index is false" do
      migration = new_migration do 
        create_table(:uuid_test) { |t| t.uuid(:add_index => false) }
      end
      ActiveRecord::ConnectionAdapters::Table.any_instance.expects(:index).never
      migration.up_suppressed
    end
  
    should "merge in other options given to uuid() as part of the column call" do
      migration = new_migration do 
        create_table(:uuid_test) { |t| t.uuid(:bar => :baz) }
      end
      ActiveRecord::ConnectionAdapters::TableDefinition.any_instance.expects(:column).with(:uuid, :string, has_entry(:bar, :baz))
      migration.up_suppressed
    end  
    
  end # creating a new table with a uuid
  
  context "adding a uuid to an existing table" do
    setup do
      @migration = new_migration do 
        change_table(:uuid_test) { |t| t.uuid }
      end
    end
    
    should "create a string column for the UUID" do
      ActiveRecord::ConnectionAdapters::Table.any_instance.expects(:column).with(:uuid, :string, :null => false, :limit => 36)
      @migration.up_suppressed
    end
    
    should_eventually "add a unique index" do
      ActiveRecord::ConnectionAdapters::Table.any_instance.expects(:index).with(:uuid, :unique => true)
      @migration.up_suppressed
    end

    should "skip adding the unique index if add_index is false" do
      migration = new_migration do 
        change_table(:uuid_test) { |t| t.uuid(:add_index => false) }
      end
      ActiveRecord::ConnectionAdapters::Table.any_instance.expects(:index).never
      migration.up_suppressed
    end
    
    should "merge in other options given to uuid() as part of the column call" do
      migration = new_migration do 
        change_table(:uuid_test) { |t| t.uuid(:foo => :bar) }
      end
      ActiveRecord::ConnectionAdapters::Table.any_instance.expects(:column).with(:uuid, :string, has_entry(:foo, :bar))
      migration.up_suppressed
    end

    
    should "delegate generate_uuids to the module helper method" do
      migration = new_migration do 
        change_table(:uuid_test) { |t| t.generate_uuids! }
      end
      ThumbleMonks::ActiveRecordUUID::MigrationHelpers.expects(:generate_uuids_for_table!).with(:uuid_test)
      migration.up_suppressed
    end
        
  end # adding a uuid to an existing table

  
  context "migration helpers" do
    
    setup do
      @table = :yoyomas
    end
    
    should "return an anonymous ar class for the table when calling ar_helper" do
      klass = ThumbleMonks::ActiveRecordUUID::MigrationHelpers.ar_helper(@table)
      assert_equal @table, klass.table_name.to_sym
    end
    
    context "generate_uuids_for_table()" do
      setup do 
        @mock_ar_helper = mock
        ThumbleMonks::ActiveRecordUUID::MigrationHelpers.expects(:ar_helper).with(@table).returns(@mock_ar_helper)
      end
      
      should "find all records for the given table without a UUID" do
        @mock_ar_helper.expects(:find).with(:all, :conditions => {:uuid => [nil, ""]}).returns([])
        ThumbleMonks::ActiveRecordUUID::MigrationHelpers.generate_uuids_for_table!(@table)
      end
    
      should "update the uuid attribute on each record" do
        mock_record = mock
        mock_record.expects(:update_attribute).with(:uuid, regexp_matches(/^.{36}$/))
        @mock_ar_helper.expects(:find).with(:all, :conditions => {:uuid => [nil, ""]}).returns([mock_record])
        ThumbleMonks::ActiveRecordUUID::MigrationHelpers.generate_uuids_for_table!(@table)
      end
    end # generate_uuids_for_table()
    
  end
  
end
