require File.dirname(__FILE__) + '/../test_helper'

class ActiveRecordExtTest < Test::Unit::TestCase
  def setup
    Locale.set('eng')
  end
  
  def test_should_retrive_full_messages_from_nil_base
    bla = ActiveRecord::Errors.new(nil)
    
    data = {  'test' => 'that this works',
              'another' => 'test' }
    data.each { |attr,msg| bla.add(attr, msg) }
    
    assert bla.respond_to?('each_full_no_humanize')
    
    data = ''
    bla.each_full_no_humanize do |msg|
      data += msg
    end
    assert_equal data.to_s.gsub(' ', ''), data.gsub(' ', '')
  end
  
  def test_should_strip_base_from_base_messages
    bla = ActiveRecord::Errors.new(nil)
    bla.add_to_base('test is cool')
    data = ''
    bla.each_full_no_humanize { |msg| data += msg }
    assert_equal 'test is cool', data
  end
  
  def test_should_build_error_message
    bla = ActiveRecord::Errors.new(nil)
    'test'._t('system', '%s says woohoo')
    assert_equal 'I says woohoo', bla.build_error('I', 'test')
  end
end