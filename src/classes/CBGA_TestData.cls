/**
 * Class holding static method to create test data used by test classes
 */
public with sharing class CBGA_TestData {

    public static final String CITY_NAME_1 = 'Test Game City1';
    public static final String CITY_NAME_2 = 'Test Game City2';
    public static final String BLOCK_3_C1Q1_NAME = 'Block3-C1-Q1';
    public static final String BLOCK_4_C1Q1_NAME = 'Block4-C1-Q1';
    public static final String BLOCK_1_C1Q2_NAME = 'Block1-C1-Q2';
    public static final String BLOCK_2_C2Q1_NAME = 'Block2-C2-Q1';
    
    public static CBGA_City__c createCity(String cityName) {
        CBGA_City__c city = new CBGA_City__c();
        city.Name = cityName;
        city.CB_Image_URL__c = 'Test_city01';
        return city;
    }
    
    public static CBGA_City__c createCity(String cityName, String cityImageURL) {
        CBGA_City__c city = new CBGA_City__c();
        city.Name = cityName;
        city.CB_Image_URL__c = cityImageURL;
        return city;
    }
    
    public static CBGA_Quadrant__c createQuadrant(String quadrantName, Id cityId, Integer sequence) {
        CBGA_Quadrant__c quadrant = new CBGA_Quadrant__c();
        quadrant.CB_Quadrant_Name__c = quadrantName;
        quadrant.CB_City__c = cityId;
        quadrant.CB_Sequence__c = sequence;
        return quadrant;
    }
    
    public static CBGA_Block__c createBlock(String blockName, Id quadrantId, Integer sequence, Decimal cost) {
        CBGA_Block__c block = new CBGA_Block__c();
        block.CB_Block_Name__c = blockName;
        block.CB_Sequence__c = sequence;
        block.CB_Quadrant__c = quadrantId;
        block.CB_Cost__c = cost != null ? cost:5000;
        return block;
    }
    
    public static CBGA_Story__c createStory(String storyText, Id blockId) {
        CBGA_Story__c story = new CBGA_Story__c();
        story.CB_Story_Text__c = storyText;
        story.CB_Solution_Data_Type__c = 'Radio';
        story.CB_Block__c = blockId;
        return story;
    }
    
    public static CBGA_Solution_Option__c createSolutionOptions(String solutionText, String solutionDescription,Id storyId, Decimal reward, 
    String score, Integer sequence) {
        CBGA_Solution_Option__c option = new CBGA_Solution_Option__c();
        option.CB_Story__c = storyId;
        option.CB_Sequence__c = sequence;
        option.CB_Solution_Text__c = solutionText;
        option.CB_Solution_Selection_Description__c = solutionDescription;
        option.CB_Score__c = score;
        return option;
    }
    
    public static CBGA_User_Block__c createUserBlock(Id blockId, Id gameUserId, boolean isCompleted) {
        CBGA_User_Block__c userBlock = new CBGA_User_Block__c();
        userBlock.CB_Block__c = blockId;
        userBlock.CB_Game_User__c = gameUserId;
        userBlock.CB_Completed__c = isCompleted;
        return userBlock;
    }
    
    public static CBGA_Story_Answer__c createStoryAnswer(Id storyId, Id gameUserId, Id solutionOptionId, Decimal wonAmount, Decimal blockCost) {
        CBGA_Story_Answer__c answer = new CBGA_Story_Answer__c();
        answer.CB_Story__c = storyId;
        answer.CB_Game_User__c = gameUserId;
        answer.CB_Solution_Option__c = solutionOptionId;
        answer.CB_Won__c = wonAmount;
        answer.CB_Block_Cost__c = blockCost;
        return answer;
    }
    
    public static CBGA_Game_User__c createGameUser(User u, String title, Decimal allocatedBudget) {
        CBGA_Game_User__c gameUser = new CBGA_Game_User__c();
        gameUser.Name = u.LastName;
        gameUser.CB_Title__c = title;
        gameUser.CB_User__c = u.id;
        gameUser.CB_Allocated_Budget__c = allocatedBudget;
        return gameUser;
    }
    
    public static User createTestUser(String userName, String lastName) {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName=lastName, LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName=userName);
        return u;     
    }
    
    /**
     * Method to create test data will city, quadrants, Blocks, stories, Options and User Block
     */
    public static void createTestData() {
        CBGA_City__c city1 = createCity(CITY_NAME_1);
        CBGA_City__c city2 = createCity(CITY_NAME_2);
        insert new List<CBGA_City__c>{city1, city2};
        
        CBGA_Quadrant__c quadrant11 = createQuadrant('Quadrant1 in City1', city1.id, 0);
        CBGA_Quadrant__c quadrant12 = createQuadrant('Quadrant2 in City1', city1.id, 1);
        CBGA_Quadrant__c quadrant21 = createQuadrant('Quadrant1 in City2', city2.id, 0);
        insert new List<CBGA_Quadrant__c>{quadrant11, quadrant12, quadrant21};
        
        CBGA_Block__c block1 = createBlock('Block1-C1-Q1', quadrant11.Id, 0, 5000);
        CBGA_Block__c block2 = createBlock('Block2-C1-Q1', quadrant11.Id, 1, 3000);
        CBGA_Block__c block3 = createBlock(BLOCK_3_C1Q1_NAME, quadrant11.Id, 2, 4000);
        CBGA_Block__c block4 = createBlock(BLOCK_4_C1Q1_NAME, quadrant11.Id, 3, 6000);
        
        CBGA_Block__c block5 = createBlock(BLOCK_1_C1Q2_NAME, quadrant12.Id, 0, 5000);
        
        CBGA_Block__c block6 = createBlock('Block1-C2-Q1', quadrant21.Id, 0, 8000); // No question for this block
        CBGA_Block__c block7 = createBlock(BLOCK_2_C2Q1_NAME, quadrant21.Id, 1, 8000);
        insert new List<CBGA_Block__c>{block1, block2, block3, block4, block5, block6, block7}; 
        
        
        CBGA_Story__c storyB1 = createStory('How was your day1 today?', block1.Id);
        CBGA_Story__c storyB2 = createStory('How was your day2 today?', block2.Id);
        CBGA_Story__c storyB3 = createStory('How was your day3 today?', block3.Id);
        CBGA_Story__c storyB4 = createStory('How was your day4 today?', block4.Id);
        CBGA_Story__c storyB5 = createStory('How was your day5 today?', block5.Id);
        CBGA_Story__c storyB6 = createStory('How was your day6 today?', block7.Id);
        List<CBGA_Story__c> storyList = new List<CBGA_Story__c>{storyB1, storyB2, storyB3, storyB4, storyB5, storyB6};
        insert storyList;
        
        List<CBGA_Solution_Option__c> solutions = new List<CBGA_Solution_Option__c>();
        // Creating solution for each 6 stories. There will 3 solution for each story. So total 18 solution options will be created. 
        for(Integer i=0; i < 6; i++) {
            CBGA_Story__c story = storyList.get(i);
            solutions.add(createSolutionOptions('It was very good','It was very good Description', story.Id, 15000, CBGA_Utils.SOLUTION_OPTION_BEST, 0));
            solutions.add(createSolutionOptions('It was very Bad','It was very bad Description', story.Id, -5000, CBGA_Utils.SOLUTION_OPTION_BAD, 1));
            solutions.add(createSolutionOptions('It was Ok','It was very ok Description',story.Id, 0, CBGA_Utils.SOLUTION_OPTION_OK, 2));
        }
        insert solutions;
        
        // Creating solution option and User Block for Block5 and related story 
        CBGA_Solution_Option__c solutionOpt = [Select Id, CB_Reward__c from CBGA_Solution_Option__c where CB_Story__c =:storyB5.Id and CB_Score__c =: CBGA_Utils.SOLUTION_OPTION_BEST limit 1];
        
        CBGA_Game_User__c gameUser = CBGA_Utils.getCurrentLoggedInGameUser();
        CBGA_Story_Answer__c answer = createStoryAnswer(storyB5.Id, gameUser.Id, solutionOpt.Id, solutionOpt.CB_Reward__c, block5.CB_Cost__c);
        insert answer;
        CBGA_User_Block__c userBlock = createUserBlock(block5.Id, gameUser.Id, true);
        insert userBlock;
    }
    
}