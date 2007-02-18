module Phrases
  @@default_phrases = { 
    'doesnt_exist'  => '%s doesn\'t exist.',
    'invalid'       => '%s is invalid.'
    }
    
  def self.method_missing(methid)
    methid = methid.to_s
    return @@default_phrases[methid] unless @default_phrases[methid].nil?
    nil
  end
end