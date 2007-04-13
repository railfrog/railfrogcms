require File.dirname(__FILE__) + '/../test_helper'

class SiteMappingTest < Test::Unit::TestCase

  fixtures :site_mappings, :mapping_labels

  def setup
    @root = site_mappings(:root)
    @count = SiteMapping.count
  end

  def test_find_root
    common_test SiteMapping::ROOT_DIR, SiteMapping.find_root
    assert_equal @count, SiteMapping.count

    @root.destroy
    assert_equal 0, SiteMapping.count

    # the root folder should be created now
    common_test SiteMapping::ROOT_DIR, SiteMapping.find_root
    assert_equal 1, SiteMapping.count

    # and now it should be returned from the db
    common_test SiteMapping::ROOT_DIR, SiteMapping.find_root
    assert_equal 1, SiteMapping.count
  end

  def test_create_child
    child = @root.create_child({ :path_segment => 'cakes' })
    common_test 'cakes', child
    assert_equal @count+1, SiteMapping.count
    assert_equal @root.id, child.parent_id
    assert_equal @root.id, child.root.id
    assert_equal 1, child.level

    child2 = child.create_child({ :path_segment => 'index.html' })
    common_test 'index.html', child2
    assert_equal @count+2, SiteMapping.count
    assert_equal child.id, child2.parent_id
    assert_equal @root.id, child2.root.id
    assert_equal 2, child2.level

    child = @root.create_child({ :path_segment => 'cakes2' })
    common_test 'cakes2', child
    assert_equal @count+3, SiteMapping.count
    assert_equal @root.id, child.parent_id
    assert_equal @root.id, child.root.id
    assert_equal 1, child.level
  end

  def test_create_child__internal
    @root.
      create_child({ :path_segment => 'child1', :is_internal => true }).
      create_child({ :path_segment => 'child2' }).
      create_child({ :path_segment => 'child3', :is_internal => false }).
      create_child({ :path_segment => 'child4', :is_internal => true })

    assert SiteMapping.find_by_path_segment('child1').is_internal
    assert SiteMapping.find_by_path_segment('child4').is_internal

    assert !SiteMapping.find_by_path_segment('child2').is_internal
    assert !SiteMapping.find_by_path_segment('child3').is_internal
  end

  def test_create_child__with_same_name
    child1 = @root.create_child({ :path_segment => 'child' })
    common_test 'child', child1
    assert_equal @count+1, SiteMapping.count

    assert_raise(ActiveRecord::RecordInvalid) { @root.create_child({ :path_segment => 'child' }) }
    assert_equal @count+1, SiteMapping.count
  end

  def test_create_by_path_segment
    child = @root.create_child_by_path_segment('cakes')
    common_test 'cakes', child
    assert_equal @count+1, SiteMapping.count
    assert_equal @root.id, child.parent_id
    assert_equal @root.id, child.root.id
    assert_equal 1, child.level

    child2 = child.create_child_by_path_segment('index.html')
    common_test 'index.html', child2
    assert_equal @count+2, SiteMapping.count
    assert_equal child.id, child2.parent_id
    assert_equal @root.id, child2.root.id
    assert_equal 2, child2.level

    child = @root.create_child_by_path_segment('cakes2')
    common_test 'cakes2', child
    assert_equal @count+3, SiteMapping.count
    assert_equal @root.id, child.parent_id
    assert_equal @root.id, child.root.id
    assert_equal 1, child.level
  end

  def test_find_or_create_child
    child = @root.find_or_create_child({ :path_segment => 'cakes' })
    common_test 'cakes', child
    assert_equal @count+1, SiteMapping.count
    assert_equal @root.id, child.parent_id
    assert_equal @root.id, child.root.id
    assert_equal 1, child.level

    child = @root.find_or_create_child({ :path_segment => 'cakes' })
    common_test 'cakes', child
    assert_equal @count+1, SiteMapping.count

    child2 = child.find_or_create_child({ :path_segment => 'index.html' })
    common_test 'index.html', child2
    assert_equal @count+2, SiteMapping.count
    assert_equal child.id, child2.parent_id
    assert_equal @root.id, child2.root.id
    assert_equal 2, child2.level

    child = @root.find_or_create_child({ :path_segment => 'index2.html' })
    common_test 'index2.html', child
    assert_equal @count+3, SiteMapping.count
    assert_equal @root.id, child.parent_id
    assert_equal @root.id, child.root.id
    assert_equal 1, child.level

    child = @root.find_or_create_child({ :path_segment => 'index2.html' })
    common_test 'index2.html', child
    assert_equal @count+3, SiteMapping.count
  end

  def test_is_root
    assert @root.root?
    assert_nil @root.parent_mapping

    child = @root.create_child({ :path_segment => 'cakes' })
    assert !child.root?
    common_test SiteMapping::ROOT_DIR, child.parent_mapping

    child = child.create_child({ :path_segment => 'index.html' })
    assert !child.root?
    common_test 'cakes', child.parent_mapping

    child = child.find_or_create_child({ :path_segment => 'index.html' })
    assert !child.root?
    common_test 'index.html', child.parent_mapping

    root = SiteMapping.find_root
    assert root.root?
    assert_nil root.parent_mapping
  end

  def test_destroy
    assert @count > 0
    assert MappingLabel.count > 0
    @root.destroy
    assert_equal 0, SiteMapping.count
    assert 0, MappingLabel.count

    root = SiteMapping.find_root
    root.create_child_by_path_segment('cakes').create_child_by_path_segment('chocolate_cakes').create_child_by_path_segment('index.html')
    assert_equal 4, SiteMapping.count
    root.destroy
    assert_equal 0, SiteMapping.count

    branch = SiteMapping.find_root.create_child_by_path_segment('cakes')
    branch.create_child_by_path_segment('chocolate_cakes').create_child_by_path_segment('index.html')
    assert_equal 4, SiteMapping.count
    branch.destroy
    assert_equal 1, SiteMapping.count
    assert_equal SiteMapping::ROOT_DIR, SiteMapping.find(:first).path_segment
  end

  def test_full_path
    # for root
    assert_equal '/', @root.full_path

    # for external mappings
    assert_equal '/images', site_mappings(:images).full_path
    assert_equal '/images/logo.jpg', site_mappings(:logo).full_path
    assert_equal '/images/background.gif', site_mappings(:background).full_path
    assert_equal '/index.html', site_mappings(:index).full_path

    # for internal mappings
    assert_equal '/layouts/main_layout', site_mappings(:main_layout).full_path
    assert_equal '/layouts/header', site_mappings(:header).full_path
    assert_equal '/layouts/footer', site_mappings(:footer).full_path

    # for just created mappings
    leaf = @root.create_child_by_path_segment('cakes').create_child_by_path_segment('chocalate_cake.html')
    assert_equal '/cakes/chocalate_cake.html', leaf.full_path
  end

  def test_find_mapping
    common_test SiteMapping::ROOT_DIR, SiteMapping.find_mapping
    common_test SiteMapping::ROOT_DIR, SiteMapping.find_mapping([])

    subtest_find_mapping [SiteMapping::ROOT_DIR]
    subtest_find_mapping [SiteMapping::ROOT_DIR, 'images']
    subtest_find_mapping ['images']
    subtest_find_mapping [SiteMapping::ROOT_DIR, 'images', 'logo.jpg']
    subtest_find_mapping ['images', 'logo.jpg']
    subtest_find_mapping [SiteMapping::ROOT_DIR, 'images', 'background.gif']
    subtest_find_mapping ['images', 'background.gif']
    subtest_find_mapping [SiteMapping::ROOT_DIR, 'layouts', 'main_layout']
    subtest_find_mapping ['layouts', 'main_layout']
    subtest_find_mapping [SiteMapping::ROOT_DIR, 'layouts', 'header']
    subtest_find_mapping ['layouts', 'header']
    subtest_find_mapping [SiteMapping::ROOT_DIR, 'layouts', 'footer']
    subtest_find_mapping ['layouts', 'footer']
    subtest_find_mapping [SiteMapping::ROOT_DIR, 'index.html']
    subtest_find_mapping ['index.html']

    # for just created mappings
    leaf = @root.create_child_by_path_segment('cakes').create_child_by_path_segment('chocalate_cake.html')
    subtest_find_mapping ['cakes', 'chocalate_cake.html']
    subtest_find_mapping [SiteMapping::ROOT_DIR, 'cakes', 'chocalate_cake.html']

    assert_nil SiteMapping.find_mapping(['no'])
    assert_nil SiteMapping.find_mapping(['no', 'such'])
    assert_nil SiteMapping.find_mapping(['no', 'such', 'path'])
  end

  def test_find_mapping__internal
    # find internal site_mapping with external_only = true
    assert_nil SiteMapping.find_mapping(['layouts', 'main_layout'], nil, true)
    assert_nil SiteMapping.find_mapping(['layouts', 'header'], nil, true)
    assert_nil SiteMapping.find_mapping(['layouts', 'footer'], nil, true)

    # check with default external_only = false
    common_test 'main_layout', SiteMapping.find_mapping(['layouts', 'main_layout'])
    common_test 'header', SiteMapping.find_mapping(['layouts', 'header'])
    common_test 'footer', SiteMapping.find_mapping(['layouts', 'footer'])

    # check with external_only = false
    common_test 'main_layout', SiteMapping.find_mapping(['layouts', 'main_layout'], nil, false)
    common_test 'header', SiteMapping.find_mapping(['layouts', 'header'], nil, false)
    common_test 'footer', SiteMapping.find_mapping(['layouts', 'footer'], nil, false)

    # check site_mapping with explicit is_internal = false
    common_test 'index.html', SiteMapping.find_mapping(['index.html'])
    common_test 'index.html', SiteMapping.find_mapping(['index.html'], nil, false)
    common_test 'index.html', SiteMapping.find_mapping(['index.html'], nil, true)

    # check site_mapping with implicit is_internal = false (database default value)
    common_test 'logo.jpg', SiteMapping.find_mapping(['images', 'logo.jpg'])
    common_test 'logo.jpg', SiteMapping.find_mapping(['images', 'logo.jpg'], nil, false)
    common_test 'logo.jpg', SiteMapping.find_mapping(['images', 'logo.jpg'], nil, true)
  end

  def test_find_mapping__with_labels
    sm = SiteMapping.find_mapping(['images', 'logo.jpg'])

    assert_not_nil sm.instance_variables.find {|v| v == '@mapping_labels'}
    assert_not_nil sm.parent_mapping.instance_variables.find {|v| v == '@mapping_labels'}
    assert_not_nil sm.parent_mapping.parent_mapping.instance_variables.find {|v| v == '@mapping_labels'}

    assert_equal 4, sm.mapping_labels.size
    assert_equal mapping_labels(:logo_label1), sm.mapping_labels[0]
    assert_equal mapping_labels(:logo_label2), sm.mapping_labels[1]
    assert_equal mapping_labels(:logo_label3), sm.mapping_labels[2]
    assert_equal mapping_labels(:logo_label4), sm.mapping_labels[3]

    assert_equal 0, sm.parent_mapping.mapping_labels.size

    assert_equal 1, sm.parent_mapping.parent_mapping.mapping_labels.size
    assert_equal mapping_labels(:root_label), sm.parent_mapping.parent_mapping.mapping_labels[0]
  end

  def test_process_labels
    result = { "index-page" => 'index.html' }
    assert_equal result, SiteMapping.process_labels(SiteMapping.find_root)
    assert_equal result, SiteMapping.process_labels(SiteMapping.find_mapping)
    assert_equal result, SiteMapping.process_labels(SiteMapping.find_mapping( ['images']))
    assert_equal result, SiteMapping.process_labels(SiteMapping.find_mapping( ['images', 'background.gif']))

    result['label1'] = 'value1'
    result['label2'] = 'value2'
    result['label3'] = 'value3'
    result['label4'] = 'value4'
    assert_equal result, SiteMapping.process_labels(SiteMapping.find_mapping( ['images', 'logo.jpg'] ))

    result = { 'index-page' => mapping_labels(:layouts_label).value }
    assert_equal result, SiteMapping.process_labels(SiteMapping.find_mapping( ['layouts']))
    assert_equal result, SiteMapping.process_labels(SiteMapping.find_mapping( ['layouts', 'main_layout'] ))
  end

  def test_find_mapping__with_version
    #flunk 'need to be tested'
  end

  def test_find_mapping_plus
    result = SiteMapping.find_mapping_plus([''])
    assert_not_nil result
    assert_instance_of Array, result
    assert_equal 3, result.size
    assert_nil result[0]
    assert_instance_of Hash, result[1]
    assert_equal 1, result[1].size
    assert_instance_of SiteMapping, result[2]

    result = SiteMapping.find_mapping_plus(['images'])
    assert_not_nil result
    assert_instance_of Array, result
    assert_equal 3, result.size
    assert_nil result[0]
    assert_instance_of Hash, result[1]
    assert_equal 1, result[1].size
    assert_instance_of SiteMapping, result[2]

    result = SiteMapping.find_mapping_plus(['images', 'logo.jpg'])
    assert_not_nil result
    assert_instance_of Array, result
    assert_equal 3, result.size
    assert_nil result[0]
    assert_instance_of Hash, result[1]
    assert_equal 5, result[1].size
    assert_instance_of SiteMapping, result[2]

    # fails on internal chunk
    result = SiteMapping.find_mapping_plus(['layouts', 'main_layout'])
    assert_not_nil result
    assert_instance_of Array, result
    assert_equal 3, result.size
    assert_nil result[0]
    assert_instance_of Hash, result[1]
    assert_equal 1, result[1].size
    assert_instance_of SiteMapping, result[2]

    # fails on internal chunk
    assert_nil SiteMapping.find_mapping_plus(['layouts', 'main_layout'], nil, true)

    # fails on bad path
    assert_nil SiteMapping.find_mapping_plus(['no-such-path'])
  end

  def test_kid_dirs
    # flunk
  end

  def subtest_find_mapping(path, external_only = false)
    sm = SiteMapping.find_mapping(path, nil, external_only)
    assert !sm.is_internal if external_only

    path.reverse.each_with_index {|p, i|
      common_test p, sm
      sm = sm.parent_mapping
    }
  end

  def common_test(path_segment, sm)
    assert_not_nil sm
    assert_instance_of SiteMapping, sm
    assert_valid sm
    assert sm.errors.empty?
    assert_equal path_segment, sm.path_segment
  end

end
