# original source code is:
# http://www.depixelate.com/2006/7/19/acts-as-sequenced
module Mofumofu
  module Acts
    module Sequenced
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        # Configuration options are:
        #
        # * +column+ - specifies the column name to use for keeping the position integer (default: position)
        # * +scope+ - restricts what is to be considered a list. Given a symbol, it'll attach "_id"
        #   (if that hasn't been already) and use that as the foreign key restriction. It's also possible
        #   to give it an entire string that is interpolated if you need a tighter scope than just a foreign key.
        #   Example: <tt>acts_as_sequenced :scope => 'todo_list_id = #{todo_list_id} AND completed = 0'</tt>
        def acts_as_sequenced(options = {})
          configuration = { :column => "position", :scope => "1 = 1" }
          configuration.update(options) if options.is_a?(Hash)
          cattr_accessor :sequenced_scope
          cattr_accessor :position_column

          self.sequenced_scope = if configuration[:scope].is_a?(Symbol) && configuration[:scope].to_s !~ /_id$/
                                   "#{configuration[:scope]}_id".intern
                                 else
                                   configuration[:scope]
                                 end
          self.position_column = configuration[:column]
          include InstanceMethods
          before_create  :assign_next_number_in_sequence
        end
      end

      module InstanceMethods
        def scope_condition
          if self.class.sequenced_scope.is_a?(Symbol)
            scope = self.class.sequenced_scope
            if self.read_attribute(scope).nil?
              "#{scope} IS NULL"
            else
              ["#{scope} = ?", self.read_attribute(scope)]
            end
          else
            self.class.sequenced_scope
          end
        end

        def assign_next_number_in_sequence
          if self.class.respond_to?(:paranoid?) && self.class.paranoid?
            max = self.class.calculate_with_deleted(:max, position_column, :conditions => scope_condition)
          else
            max = self.class.maximum(position_column, :conditions => scope_condition)
          end
          self[position_column] = (max ? max : 0  ) + 1
        end

      end
    end
  end
end
