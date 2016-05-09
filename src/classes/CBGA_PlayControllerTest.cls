/**
 * This class contains unit tests for validating the behavior of CBGA_PlayController Apex classes
 */
@isTest
private class CBGA_PlayControllerTest {
	
	/**
	 * test method for init
	 */
	 
    static testMethod void initTest() {
        CBGA_TestData.createTestData();
        CBGA_Block__c block = [Select id From CBGA_Block__c where CB_Block_Name__c =: CBGA_TestData.BLOCK_4_C1Q1_NAME limit 1];
    	
    	Test.setCurrentPage(Page.CBGA_Play);
    	ApexPages.currentPage().getParameters().put('blockId', block.Id);
    	
    	Test.startTest();
    	CBGA_PlayController controller = new CBGA_PlayController();
    	controller.init();
    	
    	system.assert(controller.isBlockValidToPlay );
    	system.assertEquals(CBGA_TestData.BLOCK_4_C1Q1_NAME, controller.block.CB_Block_Name__c);
    	
    	system.assertEquals(3, controller.solutionOptionsByScoreType.size());
    	system.assertEquals(10320.00, controller.solutionOptionsByScoreType.get(CBGA_Utils.SOLUTION_OPTION_BEST).CB_Reward__c);
    	
    	Test.stopTest();
    }
    
    /**
     * test init with -ve case where block is completed with best answer.
     */ 
    static testMethod void initBlockCompletedWithBestAnsTest() {
        CBGA_TestData.createTestData();
        CBGA_Block__c block = [Select id From CBGA_Block__c where CB_Block_Name__c =: CBGA_TestData.BLOCK_1_C1Q2_NAME limit 1];
    	
    	Test.setCurrentPage(Page.CBGA_Play);
    	ApexPages.currentPage().getParameters().put('blockId', block.Id);
    	
    	Test.startTest();
    	CBGA_PlayController controller = new CBGA_PlayController();
    	controller.init();
    	
    	system.assertEquals(false, controller.isBlockValidToPlay);
    	
    	List<Apexpages.Message> msgs = ApexPages.getMessages();
    	boolean hasMessage = false;
    	for(Apexpages.Message msg:msgs) {
    		if(msg.getDetail().contains(CBGA_Utils.BLOCK_IS_COMPLETED_WITH_BEST_ANSWER)) hasMessage = true;
    	}
    	system.assert(hasMessage);
    	
    	//Check Image Url 
    	//String styleBlock = controller.getBlockStyleClass();
    	//styleBlock = controller.getBlockStyleClass();
    	
    	CBGA_City__c city = CBGA_Utils.getSelectedQuadrantCity(controller.block.CB_Quadrant__c);
    	city.CB_Image_URL__c = CBGA_Utils.CITY_0_IMAGE_URL;
    	 
    	update city;
    	
    	System.assertEquals('0',controller.getCityIndex());
    	
    	/* 
    	controller.block.CB_Quadrant__r.CB_Sequence__c = 2;
    	styleBlock = controller.getBlockStyleClass();
        System.assertEquals('city0-icons-img0',styleBlock);

        controller.block.CB_Quadrant__r.CB_Sequence__c = 4;
        styleBlock = controller.getBlockStyleClass();
        System.assertEquals('city0-icons-img1',styleBlock);

        controller.block.CB_Quadrant__r.CB_Sequence__c = 6;
        styleBlock = controller.getBlockStyleClass();
        System.assertEquals('city0-icons-img2',styleBlock);

        controller.block.CB_Quadrant__r.CB_Sequence__c = 7;
        styleBlock = controller.getBlockStyleClass();
        System.assertEquals('city0-icons-img3',styleBlock);
 
        controller.block.CB_Quadrant__r.CB_Sequence__c = 9;
        styleBlock = controller.getBlockStyleClass();
        System.assertEquals('city0-icons-img4',styleBlock);
        
        
        controller.block.CB_Quadrant__r.CB_Sequence__c = 12;
        styleBlock = controller.getBlockStyleClass();
        System.assertEquals('city0-icons-img6',styleBlock);

        controller.block.CB_Quadrant__r.CB_Sequence__c = 14;
        styleBlock = controller.getBlockStyleClass();
        System.assertEquals('city0-icons-img7',styleBlock);
       	*/ 	
        Test.stopTest();
    }
    
 
   
    /**
    */
    static testMethod void testProcessGameScore(){
        	
        CBGA_PlayController controller = new CBGA_PlayController();
        Test.startTest();
        CBGA_Game_User__c gameUser = CBGA_Utils.getCurrentLoggedInGameUser();
       
        gameUser = controller.processGameScore(CBGA_Utils.SOLUTION_OPTION_BEST,gameUser);
        System.assertEquals(gameUser.CB_Streak__c,1);
        
        gameUser = controller.processGameScore(CBGA_Utils.SOLUTION_OPTION_BEST,gameUser);
        System.assertEquals(gameUser.CB_Streak__c,2);
        
        gameUser = controller.processGameScore(CBGA_Utils.SOLUTION_OPTION_BAD,gameUser);
        System.assertEquals(gameUser.CB_Streak__c,-1);
               
        Test.stopTest();
    }
    
    /**
	 * test method for saveUserSelectedAnswer
	 */
    static testMethod void saveUserSelectedAnswerTest() {
        CBGA_TestData.createTestData();
        CBGA_Block__c block = [Select id From CBGA_Block__c where CB_Block_Name__c =: CBGA_TestData.BLOCK_4_C1Q1_NAME limit 1];
    	
    	Test.setCurrentPage(Page.CBGA_Play);
    	ApexPages.currentPage().getParameters().put('blockId', block.Id);
    	
    	CBGA_Game_User__c gameUser = CBGA_Utils.getCurrentLoggedInGameUser();
    	CBGA_User_Block__c userBlock = CBGA_Utils.getUserBlockByBlockAndGameUserId(block.Id, gameUser.Id);
    	system.assertEquals(false, userBlock.CB_Completed__c);
    	
    	Test.startTest();
    	CBGA_PlayController controller = new CBGA_PlayController();
    	controller.init();
    	
    	system.assert(controller.isBlockValidToPlay );
    	system.assertEquals(CBGA_TestData.BLOCK_4_C1Q1_NAME, controller.block.CB_Block_Name__c);
    	system.assertEquals(3, controller.solutionOptionsByScoreType.size());
    	
    	controller.selectedSolutionOptionId = controller.solutionOptionsByScoreType.get(CBGA_Utils.SOLUTION_OPTION_BEST).Id;
    	controller.saveUserSelectedAnswer();
    	
    	// Checing for User block
    	userBlock = CBGA_Utils.getUserBlockByBlockAndGameUserId(block.Id, gameUser.Id);
    	system.assertEquals(true, userBlock.CB_Completed__c);
    	
    	Test.stopTest();
    }
    
    /**
	 * test method for loadNextBlock
	 */
    static testMethod void loadNextBlockTest() {
        CBGA_TestData.createTestData();
        CBGA_Block__c block = [Select id From CBGA_Block__c where CB_Block_Name__c =: CBGA_TestData.BLOCK_3_C1Q1_NAME limit 1];
    	
    	Test.setCurrentPage(Page.CBGA_Play);
    	ApexPages.currentPage().getParameters().put('blockId', block.Id);
    	
    	CBGA_Game_User__c gameUser = CBGA_Utils.getCurrentLoggedInGameUser();
    	CBGA_User_Block__c userBlock = CBGA_Utils.getUserBlockByBlockAndGameUserId(block.Id, gameUser.Id);
    	system.assertEquals(false, userBlock.CB_Completed__c);
    	
    	Test.startTest();
    	CBGA_PlayController controller = new CBGA_PlayController();
    	controller.init();
    	
    	system.assert(controller.isBlockValidToPlay );
    	system.assertEquals(CBGA_TestData.BLOCK_3_C1Q1_NAME, controller.block.CB_Block_Name__c);
    	
    	PageReference ref = controller.loadNextBlock();
    	system.assert(controller.nextBlock != null);
    	system.assertEquals(CBGA_TestData.BLOCK_4_C1Q1_NAME, controller.nextBlock.CB_Block_Name__c);
    	
    	Test.stopTest();
    }
    
    /**
     * loadNextBlock test with not valid next block exist.
     */ 
    static testMethod void loadNextBlockNoNextBlockTest() {
        CBGA_TestData.createTestData();
        CBGA_Block__c block = [Select id From CBGA_Block__c where CB_Block_Name__c =: CBGA_TestData.BLOCK_2_C2Q1_NAME limit 1];
    	
    	Test.setCurrentPage(Page.CBGA_Play);
    	ApexPages.currentPage().getParameters().put('blockId', block.Id);
    	
    	CBGA_Game_User__c gameUser = CBGA_Utils.getCurrentLoggedInGameUser();
    	CBGA_User_Block__c userBlock = CBGA_Utils.getUserBlockByBlockAndGameUserId(block.Id, gameUser.Id);
    	system.assertEquals(false, userBlock.CB_Completed__c);
    	
    	Test.startTest();
    	CBGA_PlayController controller = new CBGA_PlayController();
    	controller.init();
    	
    	system.assert(controller.isBlockValidToPlay );
    	system.assertEquals(CBGA_TestData.BLOCK_2_C2Q1_NAME, controller.block.CB_Block_Name__c);
    	
    	PageReference ref = controller.loadNextBlock();
    	system.assert(controller.nextBlock == null);
    	system.assertEquals(false, controller.isBlockValidToPlay);
    	
    	List<Apexpages.Message> msgs = ApexPages.getMessages();
    	boolean hasMessage = false;
    	for(Apexpages.Message msg:msgs) {
    		if(msg.getDetail().contains(CBGA_Utils.ALL_QUADRANTS_AND_BLOCKS_COMPLETE)) hasMessage = true;
    	}
    	system.assert(hasMessage);
    	system.assertEquals(CBGA_Utils.OPPS_MESSAGE, controller.oopsModalMessage);
    	system.assertEquals(CBGA_Utils.NOT_BAD_MESSAGE, controller.notBadModalMessage);
    	system.assertEquals(CBGA_Utils.BEST_MESSAGE, controller.successModalMessage);
    	
    	Test.stopTest();
    }
}