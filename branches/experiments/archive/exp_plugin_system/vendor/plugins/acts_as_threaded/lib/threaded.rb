module RailtieNet
  module Acts #:nodoc:
    module Threaded #:nodoc:
      def self.included(base)
        super
        base.extend(ClassMethods)
      end


      module ClassMethods
        # Configuration options are:
        #
        # * +root_column+ - specifies the column name to use for identifying the root thread, default "root_id"
        # * +parent_column+ - specifies the column name to use for keeping the position integer, default "parent_id"
        # * +left_column+ - column name for left boundry data, default "lft"
        # * +right_column+ - column name for right boundry data, default "rgt"
        # * +depth+ - column name used to track the depth in the thread, default "depth"
        # * +scope+ - adds an additional contraint on the threads when searching or updating
        def acts_as_threaded(options = {})
          configuration = { :root_column => "root_id", :parent_column => "parent_id", :left_column => "lft", :right_column => "rgt", :depth_column => 'depth', :scope => "1 = 1" }
          configuration.update(options) if options.is_a?(Hash)
          configuration[:scope] = "#{configuration[:scope]}_id".intern if configuration[:scope].is_a?(Symbol) && configuration[:scope].to_s !~ /_id$/

          if configuration[:scope].is_a?(Symbol)
            scope_condition_method = %(
              def scope_condition
                if #{configuration[:scope].to_s}.nil?
                  "#{configuration[:scope].to_s} IS NULL"
                else
                  "#{configuration[:scope].to_s} = \#{#{configuration[:scope].to_s}}"
                end
              end
            )
          else
            scope_condition_method = "def scope_condition() \"#{configuration[:scope]}\" end"
          end

          class_eval <<-EOV
            include RailtieNet::Acts::Threaded::InstanceMethods

            #{scope_condition_method}

            def root_column() "#{configuration[:root_column]}" end
            def parent_column() "#{configuration[:parent_column]}" end
            def left_col_name() "#{configuration[:left_column]}" end
            def right_col_name() "#{configuration[:right_column]}" end
            def depth_column() "#{configuration[:depth_column]}" end

          EOV
        end
      end

      module InstanceMethods

        # Returns true is this is a root thread.
        def root?
          parent_id = self[parent_column]
          (parent_id == 0 || parent_id.nil?) && (self[left_col_name] == 1) && (self[right_col_name] > self[left_col_name])
        end

        # Returns true is this is a child node
        def child?
          parent_id = self[parent_column]
          !(parent_id == 0 || parent_id.nil?) && (self[left_col_name] > 1) && (self[right_col_name] > self[left_col_name])
        end

        # Returns true if we have no idea what this is
        def unknown?
          !root? && !child?
        end

        def after_create
          if self.parent_id.zero?
            self.reload # Reload to bring in the id
            self[root_column] = self.id
            self.save
          else
            self.reload
            # Load the parent
            parent = self.class.find(self.parent_id)
            parent.add_child self
          end
        end

        # Adds a child to this object in the tree.  If this object hasn't been initialized,
        # it gets set up as a root node.  Otherwise, this method will update all of the
        # other elements in the tree and shift them to the right, keeping everything
        # balanced.
        def add_child( child )
          child.reload

          if unknown?
            # Convert this node to a parent node
            self[left_col_name] = 1
            self[right_col_name] = 4
            return false unless self.save

            child[root_column] = self[root_column]
            child[parent_column] = self.id
            child[depth_column] = self[depth_column] + 1
            child[left_col_name] = 2
            child[right_col_name]= 3
            return child.save

          else

            # OK, we need to add and shift everything else to the right
            child[root_column] = self[root_column]
            child[parent_column] = self.id
            child[depth_column] = self[depth_column] + 1
            right_bound = self[right_col_name]
            child[left_col_name] = right_bound
            child[right_col_name] = right_bound + 1
            self[right_col_name] += 2
            self.class.transaction {
              self.class.update_all( "#{left_col_name} = (#{left_col_name} + 2)",  "#{scope_condition} AND #{root_column} = #{self[root_column]} AND #{left_col_name} >= #{right_bound}" )
              self.class.update_all( "#{right_col_name} = (#{right_col_name} + 2)",  "#{scope_condition} AND #{root_column} = #{self[root_column]} AND #{right_col_name} >= #{right_bound}" )
              self.save
              child.save
            }
          end
        end

        # Returns the number of nested children of this object.
        def children_count
          return unknown? ? 0 : (self[right_col_name] - self[left_col_name] - 1)/2
        end

        # Returns a set of itself and all of its nested children
        def full_set
          self.class.find(:all, :conditions => "#{scope_condition} AND #{root_column} = #{self[root_column]} AND (#{left_col_name} BETWEEN #{self[left_col_name]} and #{self[right_col_name]})" )
        end

        # Returns a set of all of its children and nested children
        def all_children
          self.class.find(:all, :conditions => "#{scope_condition} AND #{root_column} = #{self[root_column]} AND #{left_col_name} > #{self[left_col_name]} AND #{right_col_name} < #{self[right_col_name]}" )
        end

        # Returns a set of only this entry's immediate children
        def direct_children
          self.class.find(:all, :conditions => "#{scope_condition} AND #{parent_column} = #{self.id}")
        end

        # Prunes a branch off of the tree, shifting all of the elements on the right
        # back to the left so the counts still work.
        def before_destroy
          return if self[right_col_name].nil? || self[left_col_name].nil?
          dif = self[right_col_name] - self[left_col_name] + 1

          self.class.transaction {
            self.class.delete_all( "#{scope_condition} AND #{root_column} = #{self[root_column]} AND #{left_col_name} > #{self[left_col_name]} AND #{right_col_name} < #{self[right_col_name]}" )
            self.class.update_all( "#{left_col_name} = (#{left_col_name} - #{dif})",  "#{scope_condition} AND #{root_column} = #{self[root_column]} AND #{left_col_name} >= #{self[right_col_name]}" )
            self.class.update_all( "#{right_col_name} = (#{right_col_name} - #{dif} )",  "#{scope_condition} AND #{root_column} = #{self[root_column]} AND #{right_col_name} >= #{self[right_col_name]}" )
          }
        end
      end
    end
  end
end
