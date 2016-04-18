/**
 * Class holding static method to create test data used by test classes
 */
public with sharing class CB_TestData {

	public static final String CITY_NAME_1 = 'Test Game City1';
	public static final String CITY_NAME_2 = 'Test Game City2';
	public static final String BLOCK_3_C1Q1_NAME = 'Block3-C1-Q1';
	public static final String BLOCK_4_C1Q1_NAME = 'Block4-C1-Q1';
	public static final String BLOCK_1_C1Q2_NAME = 'Block1-C1-Q2';
	public static final String BLOCK_2_C2Q1_NAME = 'Block2-C2-Q1';
	
	public static CB_City__c createCity(String cityName) {
		return createCity(cityName, CB_Utils.CITY_0_IMAGE_URL);
	}
	
	public static CB_City__c createCity(String cityName, String cityImageURL) {
		CB_City__c city = new CB_City__c();
		city.CB_City_Name__c = cityName;
		city.CB_Image_URL__c = cityImageURL;
		return city;
	}
	
	public static CB_Quadrant__c createQuadrant(String quadrantName, Id cityId, Integer sequence) {
		CB_Quadrant__c quadrant = new CB_Quadrant__c();
		quadrant.CB_Quadrant_Name__c = quadrantName;
		quadrant.CB_City__c = cityId;
		quadrant.CB_Sequence__c = sequence;
		return quadrant;
	}
	
	public static CB_Block__c createBlock(String blockName, Id quadrantId, Integer sequence, Decimal cost) {
		CB_Block__c block = new CB_Block__c();
		block.CB_Block_Name__c = blockName;
		block.CB_Sequence__c = sequence;
		block.CB_Quadrant__c = quadrantId;
		block.CB_Cost__c = cost != null ? cost:5000;
		return block;
	}
	
	public static CB_Story__c createStory(String storyText, Id blockId) {
		CB_Story__c story = new CB_Story__c();
		story.CB_Story_Text__c = storyText;
		story.CB_Solution_Data_Type__c = 'Radio';
		story.CB_Block__c = blockId;
		return story;
	}
	
	public static CB_Solution_Option__c createSolutionOptions(String solutionText, Id storyId, Decimal reward, String score, Integer sequence) {
		CB_Solution_Option__c option = new CB_Solution_Option__c();
		option.CB_Story__c = storyId;
		option.CB_Sequence__c = sequence;
		option.CB_Solution_Text__c = solutionText;
		option.CB_Solution_Selection_Description__c = solutionText;
		option.CB_Reward__c = reward;
		option.CB_Score__c = score;
		return option;
	}
	
	public static CB_User_Block__c createUserBlock(Id blockId, Id gameUserId, boolean isCompleted) {
		CB_User_Block__c userBlock = new CB_User_Block__c();
		userBlock.CB_Block__c = blockId;
		userBlock.CB_Game_User__c = gameUserId;
		userBlock.CB_Completed__c = isCompleted;
		return userBlock;
	}
	
	public static CB_Story_Answer__c createStoryAnswer(Id storyId, Id gameUserId, Id solutionOptionId, Decimal wonAmount, Decimal blockCost) {
		CB_Story_Answer__c answer = new CB_Story_Answer__c();
		answer.CB_Story__c = storyId;
		answer.CB_Game_User__c = gameUserId;
		answer.CB_Solution_Option__c = solutionOptionId;
		answer.CB_Won__c = wonAmount;
		answer.CB_Block_Cost__c = blockCost;
		return answer;
	}
	
	public static CB_Game_User__c createGameUser(User u, String title, Decimal allocatedBudget) {
		CB_Game_User__c gameUser = new CB_Game_User__c();
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
		CB_City__c city1 = createCity(CITY_NAME_1);
    	CB_City__c city2 = createCity(CITY_NAME_2);
    	insert new List<CB_City__c>{city1, city2};
    	
    	CB_Quadrant__c quadrant11 = createQuadrant('Quadrant1 in City1', city1.id, 0);
    	CB_Quadrant__c quadrant12 = createQuadrant('Quadrant2 in City1', city1.id, 1);
    	CB_Quadrant__c quadrant21 = createQuadrant('Quadrant1 in City2', city2.id, 0);
    	insert new List<CB_Quadrant__c>{quadrant11, quadrant12, quadrant21};
    	
    	CB_Block__c block1 = createBlock('Block1-C1-Q1', quadrant11.Id, 0, 5000);
    	CB_Block__c block2 = createBlock('Block2-C1-Q1', quadrant11.Id, 1, 3000);
    	CB_Block__c block3 = createBlock(BLOCK_3_C1Q1_NAME, quadrant11.Id, 2, 4000);
    	CB_Block__c block4 = createBlock(BLOCK_4_C1Q1_NAME, quadrant11.Id, 3, 6000);
    	
    	CB_Block__c block5 = createBlock(BLOCK_1_C1Q2_NAME, quadrant12.Id, 0, 5000);
    	
    	CB_Block__c block6 = createBlock('Block1-C2-Q1', quadrant21.Id, 0, 8000); // No question for this block
    	CB_Block__c block7 = createBlock(BLOCK_2_C2Q1_NAME, quadrant21.Id, 1, 8000);
    	insert new List<CB_Block__c>{block1, block2, block3, block4, block5, block6, block7}; 
    	
    	
    	CB_Story__c storyB1 = createStory('How was your day1 today?', block1.Id);
    	CB_Story__c storyB2 = createStory('How was your day2 today?', block2.Id);
    	CB_Story__c storyB3 = createStory('How was your day3 today?', block3.Id);
    	CB_Story__c storyB4 = createStory('How was your day4 today?', block4.Id);
    	CB_Story__c storyB5 = createStory('How was your day5 today?', block5.Id);
    	CB_Story__c storyB6 = createStory('How was your day6 today?', block7.Id);
    	List<CB_Story__c> storyList = new List<CB_Story__c>{storyB1, storyB2, storyB3, storyB4, storyB5, storyB6};
    	insert storyList;
    	
    	List<CB_Solution_Option__c> solutions = new List<CB_Solution_Option__c>();
    	// Creating solution for each 6 stories. There will 3 solution for each story. So total 18 solution options will be created. 
    	for(Integer i=0; i < 6; i++) {
    		CB_Story__c story = storyList.get(i);
    		solutions.add(createSolutionOptions('It was very good', story.Id, 15000, CB_Utils.SOLUTION_OPTION_BEST, 0));
    		solutions.add(createSolutionOptions('It was very Bad', story.Id, -5000, CB_Utils.SOLUTION_OPTION_BAD, 1));
    		solutions.add(createSolutionOptions('It was Ok', story.Id, 0, CB_Utils.SOLUTION_OPTION_OK, 2));
    	}
    	insert solutions;
    	
    	// Creating solution option and User Block for Block5 and related story 
    	CB_Solution_Option__c solutionOpt = [Select Id, CB_Reward__c from CB_Solution_Option__c where CB_Story__c =:storyB5.Id and CB_Score__c =: CB_Utils.SOLUTION_OPTION_BEST limit 1];
    	
    	CB_Game_User__c gameUser = CB_Utils.getCurrentLoggedInGameUser();
    	CB_Story_Answer__c answer = createStoryAnswer(storyB5.Id, gameUser.Id, solutionOpt.Id, solutionOpt.CB_Reward__c, block5.CB_Cost__c);
    	insert answer;
    	CB_User_Block__c userBlock = createUserBlock(block5.Id, gameUser.Id, true);
    	insert userBlock;
	}
	
}