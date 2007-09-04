require File.dirname(__FILE__) + '/../test_helper'

class MimeTypeToolsTest < Test::Unit::TestCase


  def test_lookups
    # Lookup a value in the MIME::Type registry
    mt = Railfrog::MimeType::Tools.find_by_file_name('the-fall.jpg')
    assert_not_nil(mt)
    assert_instance_of(Mime::Type, mt)
    assert_equal("image/jpeg", mt.to_s)

    # Test a custom mime-type
    mt = Railfrog::MimeType::Tools.find_by_file_name('the-fall.mdtext')
    assert_not_nil(mt)
    assert_instance_of(Mime::Type, mt)
    assert_equal("text/x-markdown", mt.to_s)

    # Register a new mime-type and test it
    Railfrog::MimeType::Tools.register("text/railfrog-croak", :croak, [], ["rfcroak", "rfcrk"])
    mt = Railfrog::MimeType::Tools.find_by_file_name('the-fall.rfcroak')
    assert_not_nil(mt)
    assert_instance_of(Mime::Type, mt)
    assert_equal("text/railfrog-croak", mt.to_s)
    assert_equal(Mime::CROAK, mt)    # The primary extension / symbol is made available as an upper-case constant

  end
end

