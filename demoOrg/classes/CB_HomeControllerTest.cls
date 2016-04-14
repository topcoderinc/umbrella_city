/**
 * This class contains unit tests for validating the behavior of CB_HomeController Apex classes
 */
@isTest
private class CB_HomeControllerTest {
	
	/**
	 * Test method for get cities
	 */ 
    static testMethod void getCitiesTest() {
    	CB_TestData.createTestData();
    	
    	Test.startTest();
    	CB_HomeController controller = new CB_HomeController();
    	controller.init();
    	
    	system.assert(controller.gameUserInfo != null);
    	system.assertEquals(UserInfo.getUserId(), controller.gameUserInfo.CB_User__c);
    	
    	List<CB_HomeController.CB_City> cities = controller.getCities();
    	system.assertEquals(2, cities.size()); 
    	
    	CB_HomeController.CB_City city1 = (cities.get(0).name == CB_TestData.CITY_NAME_1) ? cities.get(0) : cities.get(1);
		system.assertEquals(2, city1.quadrants.size());
		List<CB_HomeController.CB_Quadrant> quadrants = city1.quadrants;
		system.assertEquals('Quadrant1 in City1', quadrants.get(0).Name);
		List<CB_HomeController.CB_Blocks> blocks = quadrants.get(0).blocks;
		system.assertEquals(4, blocks.size());
		system.assertEquals('Block1-C1-Q1', blocks.get(0).Name);
		system.assertEquals(3, blocks.get(0).state);
		
		CB_HomeController.CB_City city2 = (cities.get(1).name == CB_TestData.CITY_NAME_2) ? cities.get(1) : cities.get(0);
		system.assertEquals(1, city2.quadrants.size());
		quadrants = city2.quadrants;
		system.assertEquals('Quadrant1 in City2', quadrants.get(0).Name);
		blocks = quadrants.get(0).blocks;
		system.assertEquals(2, blocks.size());
		system.assertEquals('Block1-C2-Q1', blocks.get(0).Name);
		system.assertEquals(1, blocks.get(0).state); // No question available for this block.
    	
    	Test.stopTest();
    }
    
    /**
	 * Test method for getCompletedQuadrantCount
	 */ 
    static testMethod void getCompletedQuadrantCountTest() {
    	CB_TestData.createTestData();
    	
    	Test.startTest();
    	CB_HomeController controller = new CB_HomeController();
    	controller.init();
    	
    	system.assert(controller.gameUserInfo != null);
    	system.assertEquals(UserInfo.getUserId(), controller.gameUserInfo.CB_User__c);
    	
    	Integer quadCount = controller.getCompletedQuadrantCount();
    	system.assertEquals(1, quadCount);
    	
    	Test.stopTest();
    }
}