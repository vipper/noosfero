require File.dirname(__FILE__) + '/../test_helper'

class EnterpriseTest < Test::Unit::TestCase
  fixtures :profiles, :environments, :users

  def test_identifier_validation
    p = Enterprise.new
    p.valid?
    assert p.errors.invalid?(:identifier)

    p.identifier = 'with space'
    p.valid?
    assert p.errors.invalid?(:identifier)

    p.identifier = 'áéíóú'
    p.valid?
    assert p.errors.invalid?(:identifier)

    p.identifier = 'rightformat2007'
    p.valid?
    assert ! p.errors.invalid?(:identifier)

    p.identifier = 'rightformat'
    p.valid?
    assert ! p.errors.invalid?(:identifier)

    p.identifier = 'right_format'
    p.valid?
    assert ! p.errors.invalid?(:identifier)
  end

  def test_has_domains
    p = Enterprise.new
    assert_kind_of Array, p.domains
  end

  def test_belongs_to_environment_and_has_default
    assert_equal Environment.default, Enterprise.create!(:name => 'my test environment', :identifier => 'mytestenvironment').environment
  end

  def test_cannot_rename
    p1 = profiles(:johndoe)
    assert_raise ArgumentError do
      p1.identifier = 'bli'
    end
  end

  should 'remove products when removing enterprise' do
    e = Enterprise.create!(:name => "My enterprise", :identifier => 'myenterprise')
    e.products.build(:name => 'One product').save!
    e.products.build(:name => 'Another product').save!

    assert_difference Product, :count, -2 do
      e.destroy
    end
  end

  should 'get a default homepage and RSS feed' do
    enterprise = Enterprise.create!(:name => 'my test enterprise', :identifier => 'myenterprise')

    assert_kind_of Article, enterprise.home_page
    assert_kind_of RssFeed, enterprise.articles.find_by_path('feed')
  end

  should 'create default set of blocks' do
    e = Enterprise.create!(:name => 'my new community', :identifier => 'mynewcommunity')

    assert e.boxes[0].blocks.map(&:class).include?(MainBlock), 'enterprise must have a MainBlock upon creation'

    assert e.boxes[1].blocks.map(&:class).include?(ProfileInfoBlock), 'enterprise must have a ProfileInfoBlock upon creation'
    assert e.boxes[1].blocks.map(&:class).include?(MembersBlock), 'enterprise must have a MembersBlock upon creation'

    assert e.boxes[2].blocks.map(&:class).include?(RecentDocumentsBlock), 'enterprise must have a RecentDocumentsBlock upon creation'
    assert e.boxes[2].blocks.map(&:class).include?(ProductsBlock), 'enterprise must have a ProductsBlock upon creation'

    assert_equal 5,  e.blocks.size
  end

  should 'be found in search for its product categories' do
    ent1 = Enterprise.create!(:name => 'test1', :identifier => 'test1')
    prod_cat = ProductCategory.create!(:name => 'pctest', :environment => Environment.default)
    prod = ent1.products.create!(:name => 'teste', :product_category => prod_cat)

    ent2 = Enterprise.create!(:name => 'test2', :identifier => 'test2')

    result = Enterprise.find_by_contents(prod_cat.name)

    assert_includes result, ent1
    assert_not_includes result, ent2
  end

   should 'be found in search for its product categories hierarchy' do
    ent1 = Enterprise.create!(:name => 'test1', :identifier => 'test1')
    prod_cat = ProductCategory.create!(:name => 'pctest', :environment => Environment.default)
    prod_child = ProductCategory.create!(:name => 'pchild', :environment => Environment.default, :parent => prod_cat)
    prod = ent1.products.create!(:name => 'teste', :product_category => prod_child)

    ent2 = Enterprise.create!(:name => 'test2', :identifier => 'test2')

    result = Enterprise.find_by_contents(prod_cat.name)

    assert_includes result, ent1
    assert_not_includes result, ent2
  end

  should 'not allow to add new members' do
    o = Enterprise.create!(:name => 'my test profile', :identifier => 'mytestprofile')
    p = create_user('mytestuser').person

    o.add_member(p)
    o.reload

    assert_not_includes  o.members, p
  end

  should 'allow to remove members' do
    c = Enterprise.create!(:name => 'my other test profile', :identifier => 'myothertestprofile')
    c.expects(:closed?).returns(false)
    p = create_user('myothertestuser').person

    c.add_member(p)
    assert_includes c.members, p
    c.remove_member(p)
    c.reload
    assert_not_includes c.members, p
  end

  should 'have foudation_year' do
    ent = Enterprise.create!(:name => 'test enteprise', :identifier => 'test_ent')

    assert_respond_to ent, 'foundation_year'
    assert_respond_to ent, 'foundation_year='
  end

  should 'have cnpj' do
    ent = Enterprise.create!(:name => 'test enteprise', :identifier => 'test_ent')

    assert_respond_to ent, 'cnpj'
    assert_respond_to ent, 'cnpj='
  end

  should 'block' do
    ent = Enterprise.create!(:name => 'test enteprise', :identifier => 'test_ent')
    ent.block
    assert Enterprise.find(ent.id).blocked?
  end

  should 'enable and make user admin' do
    ent = Enterprise.create!(:name => 'test enteprise', :identifier => 'test_ent', :enabled => false)
    p = create_user('test_user').person

    assert ent.enable(p)
    ent.reload
    assert ent.enabled
    assert_includes ent.members, p
  end

  should 'create EnterpriseActivation task when creating with enabled = false' do
    EnterpriseActivation.delete_all
    ent = Enterprise.create!(:name => 'test enteprise', :identifier => 'test_ent', :enabled => false)
    assert_equal [ent], EnterpriseActivation.find(:all).map(&:enterprise)
  end

  should 'create EnterpriseActivation with 7-characters codes' do
    EnterpriseActivation.delete_all
    Enterprise.create!(:name => 'test enteprise', :identifier => 'test_ent', :enabled => false)
    assert_equal 7, EnterpriseActivation.find(:first).code.size
  end

  should 'not create activation task when enabled = true' do
    assert_no_difference EnterpriseActivation, :count do
      Enterprise.create!(:name => 'test enteprise', :identifier => 'test_ent', :enabled => true)
    end
  end

  should 'list product categories full name' do
    full_name = mock
    ent = Enterprise.create!(:name => 'test ent', :identifier => 'test_ent')
    p = ent.products.create!(:name => 'test prod')
    p.expects(:category_full_name).returns(full_name)

    assert_equal [full_name], ent.product_categories
  end

  should 'not return nil values when have uncategorized products' do
    full_name = mock
    ent = Enterprise.create!(:name => 'test ent', :identifier => 'test_ent')
    p1 = ent.products.create!(:name => 'test prod 1')
    p1.expects(:category_full_name).returns(full_name)
    p2 = ent.products.create!(:name => 'test prod 2')

    assert_equal [full_name], ent.product_categories
  end

  should 'default home page is a EnterpriseHomepage' do
    enterprise = Enterprise.create!(:name => 'my test enterprise', :identifier => 'myenterprise')
    assert_kind_of EnterpriseHomepage, enterprise.home_page
  end

  should 'not create a products block for enterprise if environment do not let' do
    env = Environment.default
    env.enable('disable_products_for_enterprises')
    env.save!
    ent = Enterprise.create!(:name => 'test ent', :identifier => 'test_ent')
    assert_not_includes ent.blocks.map(&:class), ProductsBlock
  end

end
