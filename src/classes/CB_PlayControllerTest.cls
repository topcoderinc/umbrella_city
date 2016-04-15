/**
 * This class contains unit tests for validating the behavior of CB_PlayController Apex classes
 */
@isTest
private class CB_PlayControllerTest {
	
	/**
	 * test method for init
	 */
	 
    static testMethod void initTest() {
        CB_TestData.createTestData();
        CB_Block__c block = [Select id From CB_Block__c where CB_Block_Name__c =: CB_TestData.BLOCK_4_C1Q1_NAME limit 1];
    	
    	Test.setCurrentPage(Page.CB_Play);
    	ApexPages.currentPage().getParameters().put('blockId', block.Id);
    	
    	Test.startTest();
    	CB_PlayController controller = new CB_PlayController();
    	controller.init();
    	
    	system.assert(controller.isBlockValidToPlay );
    	system.assertEquals(CB_TestData.BLOCK_4_C1Q1_NAME, controller.block.CB_Block_Name__c);
    	
    	system.assertEquals(3, controller.solutionOptionsByScoreType.size());
    	system.assertEquals(15000, controller.solutionOptionsByScoreType.get(CB_Utils.SOLUTION_OPTION_BEST).CB_Reward__c);
    	
    	Test.stopTest();
    }
    
    /**
     * test init with -ve case where block is completed with best answer.
     */ 
    static testMethod void initBlockCompletedWithBestAnsTest() {
        CB_TestData.createTestData();
        CB_Block__c block = [Select id From CB_Block__c where CB_Block_Name__c =: CB_TestData.BLOCK_1_C1Q2_NAME limit 1];
    	
    	Test.setCurrentPage(Page.CB_Play);
    	ApexPages.currentPage().getParameters().put('blockId', block.Id);
    	
    	Test.startTest();
    	CB_PlayController controller = new CB_PlayController();
    	controller.init();
    	
    	system.assertEquals(false, controller.isBlockValidToPlay);
    	
    	List<Apexpages.Message> msgs = ApexPages.getMessages();
    	boolean hasMessage = false;
    	for(Apexpages.Message msg:msgs) {
    		if(msg.getDetail().contains(CB_Utils.BLOCK_IS_COMPLETED_WITH_BEST_ANSWER)) hasMessage = true;
    	}
    	system.assert(hasMessage);
    	
    	Test.stopTest();
    }
    
    /**
	 * test method for saveUserSelectedAnswer
	 */
    static testMethod void saveUserSelectedAnswerTest() {
        CB_TestData.createTestData();
        CB_Block__c block = [Select id From CB_Block__c where CB_Block_Name__c =: CB_TestData.BLOCK_4_C1Q1_NAME limit 1];
    	
    	Test.setCurrentPage(Page.CB_Play);
    	ApexPages.currentPage().getParameters().put('blockId', block.Id);
    	
    	CB_Game_User__c gameUser = CB_Utils.getCurrentLoggedInGameUser();
    	CB_User_Block__c userBlock = CB_Utils.getUserBlockByBlockAndGameUserId(block.Id, gameUser.Id);
    	system.assertEquals(false, userBlock.CB_Completed__c);
    	
    	Test.startTest();
    	CB_PlayController controller = new CB_PlayController();
    	controller.init();
    	
    	system.assert(controller.isBlockValidToPlay );
    	system.assertEquals(CB_TestData.BLOCK_4_C1Q1_NAME, controller.block.CB_Block_Name__c);
    	system.assertEquals(3, controller.solutionOptionsByScoreType.size());
    	
    	controller.selectedSolutionOptionId = controller.solutionOptionsByScoreType.get(CB_Utils.SOLUTION_OPTION_BEST).Id;
    	controller.saveUserSelectedAnswer();
    	
    	// Checing for User block
    	userBlock = CB_Utils.getUserBlockByBlockAndGameUserId(block.Id, gameUser.Id);
    	system.assertEquals(true, userBlock.CB_Completed__c);
    	
    	Test.stopTest();
    }
    
    /**
	 * test method for loadNextBlock
	 */
    static testMethod void loadNextBlockTest() {
        CB_TestData.createTestData();
        CB_Block__c block = [Select id From CB_Block__c where CB_Block_Name__c =: CB_TestData.BLOCK_3_C1Q1_NAME limit 1];
    	
    	Test.setCurrentPage(Page.CB_Play);
    	ApexPages.currentPage().getParameters().put('blockId', block.Id);
    	
    	CB_Game_User__c gameUser = CB_Utils.getCurrentLoggedInGameUser();
    	CB_User_Block__c userBlock = CB_Utils.getUserBlockByBlockAndGameUserId(block.Id, gameUser.Id);
    	system.assertEquals(false, userBlock.CB_Completed__c);
    	
    	Test.startTest();
    	CB_PlayController controller = new CB_PlayController();
    	controller.init();
    	
    	system.assert(controller.isBlockValidToPlay );
    	system.assertEquals(CB_TestData.BLOCK_3_C1Q1_NAME, controller.block.CB_Block_Name__c);
    	
    	PageReference ref = controller.loadNextBlock();
    	system.assert(controller.nextBlock != null);
    	system.assertEquals(CB_TestData.BLOCK_4_C1Q1_NAME, controller.nextBlock.CB_Block_Name__c);
    	
    	Test.stopTest();
    }
    
    /**
     * loadNextBlock test with not valid next block exist.
     */ 
    static testMethod void loadNextBlockNoNextBlockTest() {
        CB_TestData.createTestData();
        CB_Block__c block = [Select id From CB_Block__c where CB_Block_Name__c =: CB_TestData.BLOCK_2_C2Q1_NAME limit 1];
    	
    	Test.setCurrentPage(Page.CB_Play);
    	ApexPages.currentPage().getParameters().put('blockId', block.Id);
    	
    	CB_Game_User__c gameUser = CB_Utils.getCurrentLoggedInGameUser();
    	CB_User_Block__c userBlock = CB_Utils.getUserBlockByBlockAndGameUserId(block.Id, gameUser.Id);
    	system.assertEquals(false, userBlock.CB_Completed__c);
    	
    	Test.startTest();
    	CB_PlayController controller = new CB_PlayController();
    	controller.init();
    	
    	system.assert(controller.isBlockValidToPlay );
    	system.assertEquals(CB_TestData.BLOCK_2_C2Q1_NAME, controller.block.CB_Block_Name__c);
    	
    	PageReference ref = controller.loadNextBlock();
    	system.assert(controller.nextBlock == null);
    	system.assertEquals(false, controller.isBlockValidToPlay);
    	
    	List<Apexpages.Message> msgs = ApexPages.getMessages();
    	boolean hasMessage = false;
    	for(Apexpages.Message msg:msgs) {
    		if(msg.getDetail().contains(CB_Utils.ALL_QUADRANTS_AND_BLOCKS_COMPLETE)) hasMessage = true;
    	}
    	system.assert(hasMessage);
    	system.assertEquals(CB_Utils.OPPS_MESSAGE, controller.oopsModalMessage);
    	system.assertEquals(CB_Utils.NOT_BAD_MESSAGE, controller.notBadModalMessage);
    	system.assertEquals(CB_Utils.BEST_MESSAGE, controller.successModalMessage);
    	
    	Test.stopTest();
    }
}