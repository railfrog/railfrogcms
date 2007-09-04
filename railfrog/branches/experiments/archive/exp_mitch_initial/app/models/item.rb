require_dependency 'role_methods'

class Item < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  
  has_many :characteristics, :dependent => true
  has_many :item_extensions, :dependent => true
  belongs_to :extension
  
  def name=(name); write_attribute 'name', name; end
  def temp=(temp); write_attribute 'temp', temp; end
  def extension_id=(eid); write_attribute 'extension_id', eid.to_i; end
  
  def run_content(content)
    return content if item_extensions.count == 0
    item_extensions.each do |ext|
      content = ext.ext_process(content)
    end
    
    return content
  end
  
  def set_content_extension(ext_info)
    ItemExtension.set(self, ext_info)
    reload
    return true
  end
  
  def unset_content_extension(ext_info)
    ItemExtension.unset(self, ext_info)
    reload
    return true
  end
  
  def has_extension?(ext_info)
    check_content = ItemExtension.has?(self, ext_info)
    return check_content if check_content
    
    check_ext = Item.get_extension(ext_info)
    raise(ExtensionDoesntExistException, ext_info.to_s) if check_ext.nil?
    return true if self.extension_id == check_ext.id
    return false
  end
  
  def finalize
    self.temp = 0
    self.save!
    reload
    return true
  end
  
  def extklass
    return self.extension.extklass
  end
  
  def [](key)
    char = self.characteristics.find_by_name(key)
    return nil if char.nil?
    return Characteristic.get(self.id, key)
  end
  
  def []=(key, value)
    Characteristic.set(self.id, key, value)
  end
  
  def remove_characteristic(key)
    Characteristic.remove(self.id, key)
  end
  
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
end
