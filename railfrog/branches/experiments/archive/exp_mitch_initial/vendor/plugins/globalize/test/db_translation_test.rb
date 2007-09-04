require File.dirname(__FILE__) + '/test_helper'

class TranslationTest < Test::Unit::TestCase
  self.use_instantiated_fixtures = true
  fixtures :globalize_languages, :globalize_translations, :globalize_countries, 
    :globalize_products, :globalize_manufacturers, :globalize_categories, 
    :globalize_categories_products

  class Product < ActiveRecord::Base
    set_table_name "globalize_products"

    has_and_belongs_to_many :categories, :join_table => "globalize_categories_products"
    belongs_to :manufacturer, :foreign_key => 'manufacturer_id'

    translates :name, :description, :specs
  end

  class Category < ActiveRecord::Base
    set_table_name "globalize_categories"
    has_and_belongs_to_many :products, :join_table => "globalize_categories_products"

    translates :name
  end

  class Manufacturer < ActiveRecord::Base
    set_table_name "globalize_manufacturers"
    has_many :products

    translates :name  
  end

  def setup
    Globalize::Locale.set("en-US")
    Globalize::Locale.set_base_language("en-US")
  end

  def test_native_language
    heb = Globalize::Language.pick("he")
    assert_equal "עברית", heb.native_name
  end

  def test_nil
    Globalize::Locale.set(nil)
    prod = Product.find(1)
    assert_equal "first-product", prod.code 
    assert_equal "these are the specs for the first product",
      prod.specs   
  end

  def test_nil_include_translated
    Globalize::Locale.set(nil)
    prods = Product.find(:all, :include_translated => :manufacturer)
    assert_equal 5, prods.size
    assert_equal "Reverend", prods.first.manufacturer_name
    assert_equal "Reverend", prods.last.manufacturer_name  
  end

  def test_prod_tr_all
    prods = Product.find(:all, :order => "code" )
    assert_equal 5, prods.length
    assert_equal "first-product", prods[1].code 
    assert_equal "second-product", prods[3].code 
    assert_equal "these are the specs for the first product",
      prods[1].specs    
    assert_equal "This is a description of the first product",
      prods[1].description    
    assert_equal "these are the specs for the second product",
      prods[3].specs
  end

  def test_prod_tr_first
    prod = Product.find(1)
    assert_equal "first-product", prod.code 
    assert_equal "these are the specs for the first product",
      prod.specs    
    assert_equal "This is a description of the first product",
      prod.description    
  end

  def test_prod_tr_id
    prod = Product.find(1)
    assert_equal "first-product", prod.code 
    assert_equal "these are the specs for the first product",
      prod.specs    
    assert_equal "This is a description of the first product",
      prod.description    
  end

  def test_prod_tr_ids
    prods = Product.find(1, 2)
    assert_equal 2, prods.length
    assert_equal "first-product", prods[0].code 
    assert_equal "second-product", prods[1].code 
    assert_equal "these are the specs for the first product",
      prods[0].specs    
    assert_equal "This is a description of the first product",
      prods[0].description    
    assert_equal "these are the specs for the second product",
      prods[1].specs
  end

  def test_base
    Globalize::Locale.set("he-IL")
    prod = Product.find(1)
    assert_equal "first-product", prod.code 
    assert_equal "these are the specs for the first product",
      prod.specs    
    assert_equal "זהו תיאור המוצר הראשון",
      prod.description    
  end

  def test_habtm_translation
    Globalize::Locale.set("he-IL")
    cat = Category.find(1)
    prods = cat.products
    assert_equal 1, prods.length
    prod = prods.first
    assert_equal "first-product", prod.code 
    assert_equal "these are the specs for the first product",
      prod.specs    
    assert_equal "זהו תיאור המוצר הראשון",
      prod.description        
  end

  # test has_many translation
  def test_has_many_translation
    Globalize::Locale.set("he-IL")
    mfr = Manufacturer.find(1)
    assert_equal 5, mfr.products.length
    prod = mfr.products.find(1)
    assert_equal "first-product", prod.code 
    assert_equal "these are the specs for the first product",
      prod.specs    
    assert_equal "זהו תיאור המוצר הראשון",
      prod.description        
  end

  def test_belongs_to_translation
    Globalize::Locale.set("he-IL")
    prod = Product.find(1)
    mfr = prod.manufacturer
    assert_equal "first-mfr", mfr.code 
    assert_equal "רברנד",
      mfr.name
  end

  def test_new
    prod = Product.new(:code => "new-product", :specs => "These are the product specs")
    assert_equal "These are the product specs", prod.specs
    assert_nil prod.description
  end

  # test creating updating
  def test_create_update
    prod = Product.create(:code => "new-product", 
      :specs => "These are the product specs")
    assert prod.errors.empty?, prod.errors.full_messages.first
    prod = nil
    prod = Product.find_by_code("new-product")
    assert_not_nil prod
    assert_equal "These are the product specs", prod.specs

    prod.specs = "Dummy"
    prod.save
    prod = nil
    prod = Product.find_by_code("new-product")
    assert_not_nil prod
    assert_equal "Dummy", prod.specs
  end

  def test_include_translated
    Globalize::Locale.set("he-IL")
    prods = Product.find(:all, :include_translated => :manufacturer)
    assert_equal 5, prods.size
    assert_equal "רברנד", prods.first.manufacturer_name
    assert_equal "רברנד", prods.last.manufacturer_name

    Globalize::Locale.set("en-US")
    prods = Product.find(:all, :include_translated => :manufacturer)
    assert_equal 5, prods.size
    assert_equal "Reverend", prods.first.manufacturer_name
    assert_equal "Reverend", prods.last.manufacturer_name  
  end

  # Doesn't pull in translations
  def test_include
    prods = Product.find(:all, :include => :manufacturer)
    assert_equal 5, prods.size
    assert_equal "first-mfr", prods.first.manufacturer.code
  end

  def test_order_en
    prods = Product.find(:all, :order => "name").select {|rec| rec.name}
    assert_equal 5, prods[0].id
    assert_equal 3, prods[1].id
    assert_equal 4, prods[2].id
  end

  def test_order_he
    Globalize::Locale.set("he-IL")
    prods = Product.find(:all, :order => "name").select {|rec| rec.name}
    assert_equal 4, prods[0].id
    assert_equal 5, prods[1].id
    assert_equal 3, prods[2].id
  end

  def test_base_translation_create
    prod = Product.create!(:code => 'test-base', :name => 'english test')
    prod.reload
    assert_equal 'english test', prod.name
    Globalize::Locale.set("he-IL")
    prod = Product.find_by_code('test-base')
    assert_equal 'english test', prod.name
    prod.name = "hebrew test"
    prod.save!
    prod.reload
    assert_equal 'hebrew test', prod.name

    # delete hebrew version and test if it reverts to english base
    prod.name = nil
    assert_nil prod.name
    prod.save!
    prod.reload
    assert_equal 'english test', prod.name

    # change base and see if hebrew gets updated
    Globalize::Locale.set("en-US")
    prod.reload
    prod.name = "english test two"
    prod.save!
    prod.reload
    assert_equal "english test two", prod.name
    Globalize::Locale.set("he-IL")
    prod.reload
    assert_equal "english test two", prod.name
  end

  def test_wrong_language
    prod = Product.find(1)

    # this is ok, because original language was base language
    # probably should stay away from this sort of thing, though
    Globalize::Locale.set("he-IL")
    assert_equal "זהו תיאור המוצר הראשון", prod.description
    prod.description = "זהו תיאור המוצר השני"
    prod.save!
    prod = Product.find(1)
    assert_equal "זהו תיאור המוצר השני", prod.description

    # can't do this though
    Globalize::Locale.set("en-US")
    assert_raise(Globalize::WrongLanguageError) { prod.description }
    assert_raise(Globalize::WrongLanguageError) { prod.save! }    
  end

  def test_destroy
    prod = Product.find(1)    
    tr = Globalize::ModelTranslation.find(:first, :conditions => [
      "table_name = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "globalize_products", 1, "description", 2 ])
    assert_not_nil tr
    prod.destroy
    tr = Globalize::ModelTranslation.find(:first, :conditions => [
      "table_name = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "globalize_products", 1, "description", 2 ])
    assert_nil tr
  end

  def test_destroy_class_method
    tr = Globalize::ModelTranslation.find(:first, :conditions => [
      "table_name = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "globalize_products", 1, "description", 2 ])
    assert_not_nil tr
    Product.destroy(1)
    tr = Globalize::ModelTranslation.find(:first, :conditions => [
      "table_name = ? AND item_id = ? AND facet = ? AND language_id = ?",
      "globalize_products", 1, "description", 2 ])
    assert_nil tr
  end

  # association building/creating?
end
