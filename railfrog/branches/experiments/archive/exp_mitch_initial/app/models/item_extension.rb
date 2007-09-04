require_dependency 'role_methods'

class ItemExtension < ActiveRecord::Base
  belongs_to :item
  belongs_to :extension

  def method_missing(method_id, *args)
    if method_id.to_s[0..3] == 'ext_' then
      begin
        return self.extension.method_missing(method_id, *args) unless args.empty?
        return self.extension.method_missing(method_id)
      rescue NoMethodError
        super(method_id, *args)
      end
    end
    
    super(method_id, *args)
  end
  
  class <<self
    def set(item_info, ext_info)
      check_item, check_ext = check_item_and_extension(item_info, ext_info)
      raise(ItemExtensionAlreadyExistsException) unless self.find_by_item_id_and_extension_id(check_item.id, check_ext.id).nil?
      
      newconn = self.new
      newconn.item_id = check_item.id
      newconn.extension_id = check_ext.id
      newconn.save!
      return true
    end
    
    def unset(item_info, ext_info)
      check_item, check_ext = check_item_and_extension(item_info, ext_info)
      raise(ItemExtensionDoesntExistException) if (to_unset = self.find_by_item_id_and_extension_id(check_item.id, check_ext.id)).nil?
      
      to_unset.destroy
      return true
    end
    
    def has?(item_info, ext_info)
      check_item, check_ext = check_item_and_extension(item_info, ext_info)
      return false if (to_unset = self.find_by_item_id_and_extension_id(check_item.id, check_ext.id)).nil?
      return true
    end
  end
end
