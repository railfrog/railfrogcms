class Characteristic < ActiveRecord::Base
  def before_destroy
    Translation.destroy_all ['tr_key = ?', Characteristic.generate_unique_id(self.item_id, self.name)]
  end

  def self.convert_id_to_integer(id)
    return false unless id.is_a?(String)
    item = Item.find_by_name(id)
    return false if item.nil?
    return item.id
  end
  
  def self.generate_unique_id(id, key)
    '--characteristic-' + id.to_s + '-' + key
  end
  
  def self.get(id, key, lang = nil)
    return generate_unique_id(id, key).t?
  end

  def self.set(id, key, value, lang = nil)
    id = convert_id_to_integer(id) if id.is_a?(String)
    lang = Locale.language.iso_639_2 if lang.nil?
    Locale.swap(lang) { Locale.set_translation(generate_unique_id(id, key), value) }
    
    check_if_exists = find_by_item_id_and_name(id, key)
    return true unless check_if_exists.nil?
    
    char = self.new
    char.item_id = id
    char.name = key
    return char.save
  end
  
  def self.remove(id, key)
    id = convert_id_to_integer(id) if id.is_a?(String)
    
    char = find_by_item_id_and_name(id, key)
    return false if char.nil?
    return char.destroy.nil? ? false : true
  end
end
