require File.join(File.dirname(__FILE__), 'test_helper')

class UUIDTest < ActiveRecord::Base; end

class ActiveRecordUUIDTest < Test::Unit::TestCase
  include FlexMock::MockContainer
  
  def setup
    flexmock(UUIDTest).should_receive(:columns).at_least.once.and_return([])
    @record = UUIDTest.new
    flexmock(@record).should_receive(:create_without_callbacks => true)
  end
  
  def test_callback_fires_normally
    flexmock(@record) do |m|
      m.should_receive(:uuid => nil).at_least.once
      m.should_receive(:uuid=).at_least.once.with(/^.{36}$/)
    end
    assert @record.save
  end
  
  def test_callback_doesnt_fire_when_manually_disabled
    UUIDTest.disable_uuid_generation
    flexmock(@record).should_receive(:uuid, :uuid=).never
    assert @record.save
  ensure
    UUIDTest.enable_uuid_generation
  end

  def test_callback_doesnt_fire_when_record_doesnt_respond_to_uuid
    flexmock(@record).should_receive(:uuid=).never
    assert @record.save
  end
  
  def test_callback_doesnt_fire_when_record_uuid_is_already_set
    flexmock(@record) do |m|
      m.should_receive(:uuid => "already set").at_least.once
      m.should_receive(:uuid=).never
    end
    assert @record.save
  end
  
  def test_callback_only_fires_on_create
    flexmock(@record) do |m|
      m.should_receive(:update_without_callbacks => true).at_least.once.and_return(true)
      m.should_receive(:new_record? => false).at_least.once
      m.should_receive(:uuid=).never
    end
    assert @record.save
  end
  
end
