class BoldExt
  def self.type; 'content'; end
  def say_hi; 'Hi'; end
  
  def process(content)
    '<b>' + content + '</b>'
  end
end