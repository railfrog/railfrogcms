class Option < ActiveRecord::Base
  def self.get(key)
    opt = find_by_name(key)
    return nil if opt.nil?
    return opt.value
  end
  
  def self.set(key, value)
    check_if_exists = find_by_name(key)
    unless check_if_exists.nil? then
      check_if_exists.value = value
      return check_if_exists.save
    end
    
    newopt = self.new
    newopt.name = key
    newopt.value = value
    return newopt.save
  end
  
  def self.remove(key)
    check_if_exists = find_by_name(key)
    return false if check_if_exists.nil?
    check_if_exists.destroy
    return true
  end
end
