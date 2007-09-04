class BoldExt
  def self.type; 'content'; end
  def process(content)
    return '<b>' + content + '</b>'
  end
end