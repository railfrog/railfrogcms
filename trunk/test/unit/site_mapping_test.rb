require File.dirname(__FILE__) + '/../test_helper'

class SiteMappingTest < Test::Unit::TestCase

  def setup
    assert_equal 0, SiteMapping.find(:all).size
    @root = SiteMapping.find_root  
    assert_equal 1, SiteMapping.find(:all).size
  end
  
  def test_root
    @root = SiteMapping.find_root
    subtest SiteMapping::ROOT_DIR, @root
    assert_equal 1, SiteMapping.find(:all).size
    
    root = SiteMapping.find_root
    subtest SiteMapping::ROOT_DIR, root
    assert_equal 1, SiteMapping.find(:all).size
  end
  
  def test_create_child
    child = @root.create_child('cakes')
    subtest 'cakes', child
    assert_equal 2, SiteMapping.find(:all).size
    assert_equal @root.id, child.parent_id
    assert_equal @root.id, child.root.id
    assert_equal 1, child.level
    
    child2 = child.create_child('index.html')
    subtest 'index.html', child2
    assert_equal 3, SiteMapping.find(:all).size
    assert_equal child.id, child2.parent_id
    assert_equal @root.id, child2.root.id
    assert_equal 2, child2.level
    
    child = @root.create_child('index.html')
    subtest 'index.html', child
    assert_equal 4, SiteMapping.find(:all).size
    assert_equal @root.id, child.parent_id
    assert_equal @root.id, child.root.id
    assert_equal 1, child.level
  end
  
  def test_create_child__internal
    @root.
      create_child('child1', true).
      create_child('child2').
      create_child('child3', false).
      create_child('child4', true)
    
    assert SiteMapping.find_by_path_segment('child1').is_internal
    assert SiteMapping.find_by_path_segment('child4').is_internal
    
    assert !SiteMapping.find_by_path_segment('child2').is_internal
    assert !SiteMapping.find_by_path_segment('child3').is_internal
  end
  
  def test_create_child__with_same_name
    child1 = @root.create_child('child')
    subtest 'child', child1
    assert_equal 2, SiteMapping.find(:all).size
    
    assert_raise(ActiveRecord::RecordInvalid) { @root.create_child('child') }
    assert_equal 2, SiteMapping.find(:all).size
  end
  
  def test_find_or_create_child
    child = @root.find_or_create_child('cakes')
    subtest 'cakes', child
    assert_equal 2, SiteMapping.find(:all).size
    assert_equal @root.id, child.parent_id
    assert_equal @root.id, child.root.id
    assert_equal 1, child.level
    
    child = @root.find_or_create_child('cakes')
    subtest 'cakes', child
    assert_equal 2, SiteMapping.find(:all).size
    
    child2 = child.find_or_create_child('index.html')
    subtest 'index.html', child2
    assert_equal 3, SiteMapping.find(:all).size
    assert_equal child.id, child2.parent_id
    assert_equal @root.id, child2.root.id
    assert_equal 2, child2.level
    
    child = @root.find_or_create_child('index.html')
    subtest 'index.html', child
    assert_equal 4, SiteMapping.find(:all).size
    assert_equal @root.id, child.parent_id
    assert_equal @root.id, child.root.id
    assert_equal 1, child.level
    
    child = @root.find_or_create_child('index.html')
    subtest 'index.html', child
    assert_equal 4, SiteMapping.find(:all).size
  end
  
  def test_is_root
    assert @root.root?
    
    child = @root.create_child('cakes')
    assert !child.root?

    child = child.create_child('index.html')
    assert !child.root?

    root = SiteMapping.find_root
    assert root.root?
  end
  
  def test_destroy
    assert_equal 1, SiteMapping.find(:all).size
    @root.destroy
    assert_equal 0, SiteMapping.find(:all).size
    
    root = SiteMapping.find_root
    root.create_child('cakes').create_child('chocolate_cakes').create_child('index.html')
    assert_equal 4, SiteMapping.find(:all).size
    root.destroy
    assert_equal 0, SiteMapping.find(:all).size
    
    branch = SiteMapping.find_root.create_child('cakes')
    branch.create_child('chocolate_cakes').create_child('index.html')
    assert_equal 4, SiteMapping.find(:all).size
    branch.destroy
    assert_equal 1, SiteMapping.find(:all).size
    assert_equal SiteMapping::ROOT_DIR, SiteMapping.find(:first).path_segment
  end
  
  def test_full_path
    assert_equal '/', @root.full_path
    
    branch = @root.find_or_create_child 'cakes'
    assert_equal '/cakes', branch.full_path
    
    leaf = branch.find_or_create_child 'chocalate_cake.html'
    assert_equal '/cakes/chocalate_cake.html', leaf.full_path
  end

  def test_find_mapping
    cakes = @root.find_or_create_child('cakes')
    cakes_index = cakes.find_or_create_child('index.html')
    cookies = @root.find_or_create_child('cookies')
    cookies_index = cookies.find_or_create_child('index.html')

    sm = SiteMapping.find_mapping
    subtest SiteMapping::ROOT_DIR, sm
    assert_nil sm.parent_mapping
    
    sm = SiteMapping.find_mapping([])
    subtest SiteMapping::ROOT_DIR, sm
    assert_nil sm.parent_mapping

    subtest_find_mapping [SiteMapping::ROOT_DIR]
    subtest_find_mapping [SiteMapping::ROOT_DIR, 'cakes']
    subtest_find_mapping ['cakes']
    subtest_find_mapping [SiteMapping::ROOT_DIR, 'cakes', 'index.html']
    subtest_find_mapping ['cakes', 'index.html']
    subtest_find_mapping [SiteMapping::ROOT_DIR, 'cookies', 'index.html']
    subtest_find_mapping ['cookies', 'index.html']
    
    sm = SiteMapping.find_mapping(['no', 'such', 'path'])
    assert_nil sm
  end

  def test_find_mapping__internal
    @root.
      create_child('child1', true).
      create_child('child2').
      create_child('child3', false).
      create_child('child4', true)

    subtest_find_mapping ['child1', 'child2', 'child3', 'child4']
    subtest_find_mapping(['child1', 'child2', 'child3', 'child4'], false)
    
    sm = SiteMapping.find_mapping(['child1', 'child2', 'child3', 'child4'], nil, true)
    assert_nil sm
    sm = SiteMapping.find_mapping(['child1'], nil, true)
    assert_nil sm

    subtest_find_mapping(['child1', 'child2'], true)
    subtest_find_mapping(['child1', 'child2', 'child3'], true)
  end
  
  def test_find_mapping__with_labels
    insert_data_for_labels_tests

    sm = SiteMapping.find_mapping(['child1', 'child2', 'child3'])
    
    assert_not_nil sm.instance_variables.find {|v| v == '@mapping_labels'}
    assert_not_nil sm.parent_mapping.instance_variables.find {|v| v == '@mapping_labels'}
    assert_not_nil sm.parent_mapping.parent_mapping.instance_variables.find {|v| v == '@mapping_labels'}
    assert_not_nil sm.parent_mapping.parent_mapping.parent_mapping.instance_variables.find {|v| v == '@mapping_labels'}
    
    assert_equal 2, sm.mapping_labels.size
    assert_equal 0, sm.parent_mapping.mapping_labels.size
    assert_equal 1, sm.parent_mapping.parent_mapping.mapping_labels.size
    assert_equal 4, sm.parent_mapping.parent_mapping.parent_mapping.mapping_labels.size
  end
  
  def test_process_labels
    sm = SiteMapping.find_root
    result = {}
    assert_equal result, SiteMapping.process_labels(sm)
    
    sm = SiteMapping.find_mapping
    result = {}
    assert_equal result, SiteMapping.process_labels(sm)

    insert_data_for_labels_tests
    
    result = {
      'label1' => 'value1',
      'label2' => 'value2',
      'label3' => 'value3',
      'label4' => 'value4'}
    
    sm = SiteMapping.find_root
    assert_equal result, SiteMapping.process_labels(sm)

    sm = SiteMapping.find_mapping
    assert_equal result, SiteMapping.process_labels(sm)

    sm = SiteMapping.find_mapping(['child1'])
    result['label1'] = 'value1-new'
    assert_equal result, SiteMapping.process_labels(sm)
    
    sm = SiteMapping.find_mapping(['child1', 'child2'])
    assert_equal result, SiteMapping.process_labels(sm)

    sm = SiteMapping.find_mapping(['child1', 'child2', 'child3'])
    result['label3'] = 'value3-new'
    result['label33'] = 'value33'
    assert_equal result, SiteMapping.process_labels(sm)
  end
  
  def test_find_mapping__with_version
    #flunk 'need to be tested'
  end
  
  def subtest_find_mapping(path, external_only = false)
    sm = SiteMapping.find_mapping(path, nil, external_only)
    if external_only
      assert !sm.is_internal
    end
    path.reverse.each_with_index {|p, i|
      subtest p, sm
      sm = sm.parent_mapping
    }
  end
  
  def subtest(path_segment, sm)
    assert_not_nil sm
    assert_instance_of SiteMapping, sm
    assert_valid sm
    assert sm.errors.empty?
    assert_equal path_segment, sm.path_segment
  end
  
  def insert_data_for_labels_tests
    child1 = @root.create_child('child1')
    child2 = child1.create_child('child2')
    child3 = child2.create_child('child3')
  
    @root.mapping_labels.create(:name => 'label1', :value => 'value1')
    @root.mapping_labels.create(:name => 'label2', :value => 'value2')
    @root.mapping_labels.create(:name => 'label3', :value => 'value3')
    @root.mapping_labels.create(:name => 'label4', :value => 'value4')
    
    child1.mapping_labels.create(:name => 'label1', :value => 'value1-new')

    child3.mapping_labels.create(:name => 'label3', :value => 'value3-new')
    child3.mapping_labels.create(:name => 'label33', :value => 'value33')
  end
end
