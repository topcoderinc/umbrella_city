/**
 * This class contains unit tests for validating the behaviour of CB_LeaderboardController Apex classes
 */
@isTest
public class CB_LeaderboardControllerTest {
    
    @testSetup
    static void testData() {
        User user1 = CB_TestData.createTestUser('testUser1@gmail.com', 'User1');
        User user2 = CB_TestData.createTestUser('testUser2@gmail.com', 'User2');
        User user3 = CB_TestData.createTestUser('testUser3@gmail.com', 'User3');
        
        CB_Game_User__c gameUser1 = CB_TestData.createGameUser(user1, 'New User1 Tile', 20000);
        CB_Game_User__c gameUser2 = CB_TestData.createGameUser(user2, 'New User2 Tile', 15000);
        CB_Game_User__c gameUser3 = CB_TestData.createGameUser(user3, 'New User3 Tile', 55000);
        insert new List<CB_Game_User__c>{gameUser1, gameUser2, gameUser3};
    }
    
    /**
     * Test method for getGameUsers method
     */ 
    static testMethod void initTest() {
        Test.startTest();
        CB_LeaderboardController controller = new CB_LeaderboardController();
        controller.init();
        List<List<CB_LeaderboardController.GameUser>> gameUserResult = controller.gameUsers;
        system.assert(gameUserResult != null);
        system.assertEquals(2, gameUserResult.size());
        system.assertEquals(2, gameUserResult.get(0).size());
        system.assertEquals('User3', gameUserResult.get(0).get(0).userName);
        system.assertEquals(1, gameUserResult.get(1).size());
        
        Test.stopTest();
    }
    
    
    /**
     * Test method for searchGameUser method with search string 
     */ 
    static testMethod void searchGameUserTest() {
        Test.startTest();
        CB_LeaderboardController controller = new CB_LeaderboardController();
        controller.init();
        List<List<CB_LeaderboardController.GameUser>> gameUserResult = controller.gameUsers;
        system.assert(gameUserResult != null);
        system.assertEquals(2, gameUserResult.size());
        system.assertEquals(2, gameUserResult.get(0).size());
        system.assertEquals('User3', gameUserResult.get(0).get(0).userName);
        system.assertEquals(1, gameUserResult.get(1).size());
        
        controller.searchString = 'User2';
        // calling search result
        controller.searchGameUser();
        
        gameUserResult = controller.gameUsers;
        system.assert(gameUserResult != null);
        system.assertEquals(1, gameUserResult.size());
        system.assertEquals(1, gameUserResult.get(0).size());
        system.assertEquals('User2', gameUserResult.get(0).get(0).userName);
        
        Test.stopTest();
    }
}