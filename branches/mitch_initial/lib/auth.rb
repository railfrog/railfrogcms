require 'digest/sha1'

module Auth
  @@sess_hash = nil
  
  class <<self
    def session=(sess_hash); @@sess_hash = sess_hash; end
    def session; @@sess_hash; end
  
    def hash(password)
      return Digest::SHA1.hexdigest(password)
    end
    
    def second_hash(password); self.hash(password); end
    
    def save(user_id, hashed_password)
      return false if session.nil?
      session[:auth] = {}
      session[:auth][:login]    = user_id
      session[:auth][:password] = Auth::second_hash(hashed_password)
      return true
    end
    
    def clear
      session[:auth] = nil
    end
    
    def load
      return [nil, nil] if session.nil? or session[:auth].nil?
      user = nil
      user = session[:auth][:login] unless session[:auth][:login].nil?
      pass = nil
      pass = session[:auth][:password] unless session[:auth][:password].nil?
      
      return [user, pass]
    end
  end
end