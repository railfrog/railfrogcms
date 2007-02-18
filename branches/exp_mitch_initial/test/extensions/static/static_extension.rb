class StaticExt
  def self.type; 'base'; end
  
  def install(extension)
    Theme::render('install')
  end
  
  def view(item)
    Theme::render('good')
  end

  def test_pass
    return 'Pass'
  end
  
  def test_run
    return 'We did it'
  end
  
  def test_args(arg)
    return arg.reverse
  end
  
  def test_forward(ext)
    Theme::render('test_forward')
    return ext.name
  end
  
  def new_item(ext, item)
    Theme::render('new_item')
  end
end