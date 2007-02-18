class PageItem < ActiveRecord::Base
  belongs_to :item
  belongs_to :page, :foreign_key => 'page_id', :class_name => 'Item'
end
