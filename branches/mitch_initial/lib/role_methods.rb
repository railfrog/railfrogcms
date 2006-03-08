module ActiveRecord
  class Base
    class <<self
      def check_role_and_perm(role_info, perm_info)
        check_role = get_role(role_info)
        raise(RoleDoesntExistException, role_info.to_s) if check_role.nil?
        
        check_perm = get_perm(perm_info)
        raise(PermDoesntExistException, perm_info) if check_perm.nil?
        return [check_role, check_perm]
      end
      
      def check_role_and_extension(role_info, ext_info)
        check_role = get_role(role_info)
        raise(RoleDoesntExistException, role_info.to_s) if check_role.nil?
        
        check_ext = get_extension(ext_info)
        raise(ExtensionDoesntExistException, ext_info.to_s) if check_ext.nil?
        return [check_role, check_ext]
      end
      
      def check_item_and_extension(item_info, ext_info)
        check_item = get_item(item_info)
        raise(ItemDoesntExistException, item_info.to_s) if check_item.nil?
        
        check_ext = get_extension(ext_info)
        raise(ExtensionDoesntExistException, ext_info.to_s) if check_ext.nil?
        return [check_item, check_ext]
      end
    
      def get_extension(ext_info)
        check_ext = nil
        if ext_info.kind_of?(Numeric) then
          check_ext = Extension.find_by_id(ext_info)
        elsif ext_info.kind_of?(String) or ext_info.kind_of?(Symbol) then
          check_ext = Extension.find_by_name(ext_info.to_s)
        elsif ext_info.kind_of?(Extension) then
          check_ext = ext_info
        end
        
        return check_ext
      end
    
      def get_role(role_info)
        check_role = nil
        if role_info.kind_of?(Numeric) then
          check_role = Role.find_by_id(role_info)
        elsif role_info.kind_of?(String) or role_info.kind_of?(Symbol) then
          check_role = Role.find_by_name(role_info.to_s)
        elsif role_info.kind_of?(Role) then
          check_role = role_info
        end
        
        return check_role
      end
      
      def get_perm(perm_info)
        check_perm = nil
        if perm_info.kind_of?(Numeric) then
          check_perm = Permission.find_by_id(perm_info)
        elsif perm_info.kind_of?(String) or perm_info.kind_of?(Symbol) then
          check_perm = Permission.find_by_name(perm_info.to_s)
        elsif perm_info.kind_of?(Permission) then
          check_perm = perm_info
        end
        
        return check_perm
      end 
      
      def get_user(user_info)
        check_user = nil
        if user_info.kind_of?(Numeric) then
          check_user = User.find_by_id(user_info)
        elsif user_info.kind_of?(String) or user_info.kind_of?(Symbol) then
          check_user = User.find_by_name(user_info.to_s)
        elsif user_info.kind_of?(User) then
          check_user = user_info
        end
        
        return check_user
      end
      
      def get_item(item_info)
        check_item = nil
        if item_info.kind_of?(Numeric) then
          check_item = Item.find_by_id(item_info)
        elsif item_info.kind_of?(String) or item_info.kind_of?(Symbol) then
          check_item = Item.find_by_name(item_info.to_s)
        elsif item_info.kind_of?(Item) then
          check_item = item_info
        end
        
        return check_item
      end
    end
  end
end