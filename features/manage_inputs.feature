Feature: manage inputs
  As an enterprise owner
  I want to manage my product's inputs

  Background:
    Given the following users
      | login | name |
      | joaosilva | Joao Silva |
    And the following enterprises
      | identifier | owner | name | enabled |
      | redemoinho | joaosilva | Rede Moinho | true |
    Given the following product_category
      | name  |
      | Music |
    And the following product_categories
      | name | parent  |
      | Rock | music   |
      | CD Player | music   |
    And the following product
      | owner      | category | name       |
      | redemoinho | rock     | Abbey Road |
    And feature "products_for_enterprises" is enabled on environment
    And the following units
      | singular | plural |
      | Meter    | Meters |
      | Litre    | Litres |

  @selenium
  Scenario: add first input to a product
    Given I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Inputs"
    Then I should not see "Add new input or raw material"
    And I follow "Add the inputs or raw material used by this product"
    And I select "Music »" from "category_id" within "#categories_container_level0"
    And I select "Rock" from "category_id" within "#categories_container_level1"
    And I press "Save and continue"
    Then I should see "Rock"

  @selenium
  Scenario: add input to a product that already has inputs
    Given the following input
      | product    | category |
      | Abbey Road | music    |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Inputs"
    And I should not see "Add the inputs or raw material used by this product"
    And I follow "Add new input or raw material"
    And I select "Music »" from "category_id" within "#categories_container_level0"
    And I select "Rock" from "category_id" within "#categories_container_level1"
    And I press "Save and continue"
    Then I should see "Rock"

  @selenium
  Scenario: cancel addition of a product input
    Given I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Inputs"
    And I follow "Add the inputs or raw material used by this product"
    And I follow "Cancel" within "#categories_selection_actionbar"
    Then I should see "Abbey Road"
    And I should see "Add the inputs or raw material used by this product"

  Scenario: show input name and link to add details
    Given the following input
      | product | category |
      | Abbey Road | music |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Inputs and raw material"
    Then I should see "Music" within ".input-name"
    And I should see "Click here to add price and the amount used"

  Scenario: Not show input edit button when dont have details yet
    Given the following input
      | product | category |
      | Abbey Road | music |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Inputs and raw material"
    Then I should not see "Edit" within ".input-item"

  Scenario: Show button to edit input
    Given the following input
      | product    | category | price_per_unit |
      | Abbey Road | music    | 10.0           |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Inputs and raw material"
    Then I should see "Edit" within ".input-item"

  @selenium-fixme
  Scenario: Order inputs by position
    Given the following product_categories
      | name  |
      | Instrumental |
    And the following inputs
      | product    | category     | position |
      | Abbey Road | Instrumental | 2        |
      | Abbey Road | Rock         | 1        |
      | Abbey Road | CD Player    | 3        |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Inputs"
    Then I should see "Rock" above of "Instrumental"
    And I should see "Instrumental" above of "CD Player"

  @selenium
  Scenario: Save price of input
    Given the following input
      | product    | category |
      | Abbey Road | music    |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Inputs"
    Then I should see "Music"
    When I follow "Click here to add price and the amount used"
    And I should see "Price"
    And I fill in "Price" with "10.50"
    And I press "Save"
    Then I should not see "Save"

  @selenium
  Scenario: Update label of input price with selected unit
    Given the following input
      | product | category |
      | Abbey Road | music |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Inputs"
    And I follow "Click here to add price and the amount used"
    And I should not see "Price by Meter ($)"
    When I select "Meter" from "input_unit_id" within ".edit_input"
    Then I should see "Price by Meter ($)"

  @selenium
  Scenario: Save all price details of input
    Given the following input
      | product | category |
      | Abbey Road | music |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Inputs"
    And I follow "Click here to add price and the amount used"
    And I fill in "Amount used" with "2.5"
    And I fill in "Price" with "11.50"
    And I select "Meter" from "input_unit_id" within ".edit_input"
    And I press "Save"
    Then I should see "2.5"
    And I should see "Meter"
    And I should not see "$ 11.50"

  @selenium
  Scenario: Save and then edit price details of input
    Given the following input
      | product | category |
      | Abbey Road | music |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Inputs"
    And I follow "Click here to add price and the amount used"
    And I fill in "Amount used" with "2.5"
    And I fill in "Price" with "11.50"
    And I select "Meter" from "input_unit_id" within ".edit_input"
    And I press "Save"
    Then I should see "2.5"
    And I should see "Meter"
    When I follow "Edit" within ".input-details"
    And I fill in "Amount used" with "3.0"
    And I fill in "Price" with "23.31"
    And I select "Litre" from "input_unit_id" within ".edit_input"
    And I press "Save"
    Then I should see "3"
    And I should see "Litre"

  @selenium
  Scenario: Cancel edition of a input
    Given the following input
      | product | category |
      | Abbey Road | music |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Inputs"
    And I follow "Click here to add price and the amount used"
    Then I should see "Cancel"
    And I should see "Amount used"
    And I should see "Price"
    And I should see "This input or raw material inpact on the final price of the product?"
    When I follow "Cancel" within ".edit_input"
    Then I should see "Click here to add price and the amount used"

  @selenium
  Scenario: Cancel edition of an input then edit again
    Given the following input
      | product | category | price_per_unit | unit |
      | Abbey Road | music | 10.0           | Meter |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Abbey Road
    And I follow "Inputs"
    And I follow "Edit" within ".input-details"
    And I follow "Cancel" within ".edit_input"
    And I follow "Edit" within ".input-details"
    Then I should see "Amount used"
    And I should see "Price by Meter"

  @selenium
  Scenario: remove input
    Given the following input
      | product    | category |
      | Abbey Road | rock     |
    And I am logged in as "joaosilva"
    And I go to Rede Moinho's page of product Abbey Road
    And I follow "Inputs"
    Then I should see "Rock"
    And I should not see "Add the inputs or raw material used by this product"
    When I follow "Remove"
    And I confirm the browser dialog
    Then I should see "Add the inputs or raw material used by this product"

  @selenium
  Scenario: Remember in which tab I was
    Given the following products
      | owner      | category | name         |
      | redemoinho | Music    | Depeche Mode |
      | redemoinho | Music    | Manu Chao    |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Depeche Mode
    Then I should see "Add some description to your product"
    And "Add the inputs or raw material used by this product" should not be visible within "#show_product"
    When I follow "Inputs and raw material"
    Then I should see "Add the inputs or raw material used by this product"
    And "Add some description to your product" should not be visible within "#show_product"
    When I go to Rede Moinho's page of product Manu Chao
    Then I should see "Add some description to your product"
    When I go to Rede Moinho's page of product Depeche Mode
    Then I should see "Add the inputs or raw material used by this product"
    And "Add some description to your product" should not be visible within "#show_product"

  @selenium-fixme
  Scenario: Order input list
    Given the following product_category
      | name  |
      | Movie |
    And the following product
      | owner | category | name |
      | redemoinho | Movie | Ramones |
    And the following inputs
      | product | category |
      | Ramones | Rock |
      | Ramones | Music |
      | Ramones | CD Player |
    And I am logged in as "joaosilva"
    When I go to Rede Moinho's page of product Ramones
    And I follow "Inputs"
    Then I should see "Rock" above of "Music"
    And I should see "Music" above of "CD Player"
    When I drag "Rock" to "Music"
    Then I should see "Music" above of "Rock"
    And I should see "Rock" above of "CD Player"
    When I follow "Back to the product listing"
    And I go to Rede Moinho's page of product Ramones
    Then I should see "Music" above of "Rock"
    And I should see "Rock" above of "CD Player"
