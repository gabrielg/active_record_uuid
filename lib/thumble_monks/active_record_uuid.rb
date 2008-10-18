require 'uuidtools'

module ThumbleMonks
  module ActiveRecordUUID
    module Base
      def self.included(klass)
        klass.instance_eval do
          include InstanceMethods
          extend ClassMethods
          before_create :generate_active_record_uuid
          class_inheritable_accessor :uuid_generation_enabled
          attr_readonly :uuid
          attr_protected :uuid
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
          UUID.random_create.to_s
        end
      
        def record_active_record_uuid?
          uuid_generation_enabled && respond_to?(:uuid=) && respond_to?(:uuid) && uuid.blank?
        end
      
      end # InstanceMethods
    end   # Base
    
    module TableDefinition
      
      def uuid
        column(:uuid, :string, :limit => 36, :null => false)
      end
      
    end
  end # ActiveRecordUUID
  
end

ActiveRecord::Base.send(:include, ThumbleMonks::ActiveRecordUUID::Base)
ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, ThumbleMonks::ActiveRecordUUID::TableDefinition)