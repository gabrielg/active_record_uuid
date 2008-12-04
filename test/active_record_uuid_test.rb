require File.join(File.dirname(__FILE__), 'test_helper')

class ActiveRecordUUIDTest < Test::Unit::TestCase
  
  class UUIDTest < ActiveRecord::Base; end
  
  context "a record" do
    setup do
      UUIDTest.stubs(:columns).returns([])
      @record = UUIDTest.new
    end
    
    teardown do
      UUIDTest.enable_uuid_generation
    end
    
    context "on create" do
      setup do
        @record.expects(:create_without_callbacks).returns(true)
      end
      
      should "assign a UUID on save if the record responds to uuid" do
        @record.expects(:uuid).returns(nil)
        @record.expects(:uuid=).with(regexp_matches(/^.{36}$/))
        assert @record.save
      end
    
      should "not assign a UUID when UUID generation is disabled" do
        UUIDTest.disable_uuid_generation
        @record.expects(:uuid=).never
        assert @record.save
      end
    
      should "not assign a UUID if the record doesnt respond to 'uuid'" do
        @record.expects(:uuid=).never
        assert @record.save
      end
    
      should "not assign a UUID if the 'uuid' getter returns a non-nil value" do
        @record.expects(:uuid).returns("foo bar")
        @record.expects(:uuid=).never
        assert @record.save
      end
      
    end # on create
    
    context "on update" do
    
      should "not assign a UUID on update rather than create" do
        @record.expects(:update_without_callbacks).returns(true)
        @record.expects(:new_record?).at_least_once.returns(false)
        @record.expects(:uuid=).never
        assert @record.save
      end
    end # on update
    
  end # a new record
  
end
