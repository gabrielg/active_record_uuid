require 'uuidtools'

module ThumbleMonks
  module ActiveRecordUUID
    module Base
      def self.included(klass)
        klass.instance_eval do
          include InstanceMethods
          extend ClassMethods
          before_validation_on_create :generate_active_record_uuid
          class_inheritable_accessor :uuid_generation_enabled
          attr_readonly :uuid
          self.uuid_generation_enabled = true
        end
      end
    
      module ClassMethods
        def disable_uuid_generation
          self.uuid_generation_enabled = false
        end
      
        def enable_uuid_generation
          self.uuid_generation_enabled = true
        end
      end # ClassMethods
    
      module InstanceMethods

        def generate_active_record_uuid
          return true unless record_active_record_uuid?
          self.uuid = make_uuid
        end
      
        def make_uuid
          UUIDTools::UUID.random_create.to_s
        end
      
        def record_active_record_uuid?
          uuid_generation_enabled && respond_to?(:uuid=) && respond_to?(:uuid) && uuid.blank?
        end
      
      end # InstanceMethods
    end   # Base

    module MigrationHelpers
      module TableDefinition

        # Why does TableDefinition not have index()? It is a mystery.
        def index(*args)
          @base.add_index(@table_name, *args)
        end
      
        def uuid(opts = {})
          column(:uuid, :string, opts.except(:add_index).reverse_merge(:limit => 36, :null => false, :default => ""))
          index(:uuid, :unique => true) if opts[:add_index]
        end
      end
      
      module ChangeHelpers
        def generate_uuids!
          ThumbleMonks::ActiveRecordUUID::MigrationHelpers.generate_uuids_for_table!(@table_name.to_sym)
        end
      end
      
      def self.generate_uuids_for_table!(table_name)
        helper = ar_helper(table_name)
        updateable = helper.find(:all, :conditions => {:uuid => [nil, ""]})
        updateable.each { |u| u.update_attribute(:uuid, UUIDTools::UUID.random_create.to_s) }
      end
    
      def self.ar_helper(table_name)
        Class.new(ActiveRecord::Base) { set_table_name table_name }
      end
      
    end # MigrationHelpers
  end   # ActiveRecord
end

ActiveRecord::Base.send(:include, ThumbleMonks::ActiveRecordUUID::Base)
ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, ThumbleMonks::ActiveRecordUUID::MigrationHelpers::TableDefinition)
ActiveRecord::ConnectionAdapters::Table.send(:include, ThumbleMonks::ActiveRecordUUID::MigrationHelpers::TableDefinition)
ActiveRecord::ConnectionAdapters::Table.send(:include, ThumbleMonks::ActiveRecordUUID::MigrationHelpers::ChangeHelpers)
