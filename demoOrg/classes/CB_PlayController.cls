/**
 * Class holding logic to play for a selected block. The logic checks if selected block is valid to play or not.
 */
public with sharing class CB_PlayController {
	// Story detail for game user to answer
	public CB_Story__c story {get; private set;}
	
	// Current block detail 
	public CB_Block__c block {get; private set;}
	
	// Map holding Solution Options with key as solution type (Bad, OK and Best) and value as Solution Option Record corresponding to that type.
	public Map<String, CB_Solution_Option__c> solutionOptionsByScoreType {get; private set;}
	
	// Next valid block for game user to play
	public CB_Block__c nextBlock {get; private set;}
	
	// Variable to hold the id of the selected Solution Option answer
	public String selectedSolutionOptionId {get;set;}
	
	public boolean isBlockValidToPlay {get;set;}
	
	private CB_Game_User__c gameUser;
	
	/**
	 * Init method to load block details and validate if current block is valid to play or not.
	 */
	public void init() {
		// get the blockId
		Id blockId = (Id)ApexPages.currentPage().getParameters().get('blockId');
		this.isBlockValidToPlay = true;
		try {
			// Getting block detail using the block id
			block = CB_Utils.getBlockInfoByBlockId(blockId);
			
			// get the current logged in game user.
			gameUser = CB_Utils.getCurrentLoggedInGameUser();
			
			// getting the story and related Solutions Options associated with the block
			story = CB_Utils.getStoriesByBlockId(blockId, gameUser.Id);
			
			this.isBlockValidToPlay = CB_Utils.isBlockValidForCurrentUserToPlay(block, story, gameUser);
			// Preparing the solutionOptions with key as score type and value as solutionOption record.
			solutionOptionsByScoreType = CB_Utils.getSolutionOptionsByScoreType(this.story.Solutions_Options__r);
		} catch(Exception e) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
			this.isBlockValidToPlay = false;
		}
	}
	
	/**
	 * Method to save the user selected answer and updating the User Block record to completed if the selected 
	 * answer is best or OK. 
	 */
	public void saveUserSelectedAnswer() {
		Savepoint sp = Database.setSavepoint();
		try {
			// Converting the Solution Options from story to Map(key as id and value as record).
			Map<Id, CB_Solution_Option__c> solutionOptionByIdMap = new Map<Id, CB_Solution_Option__c>(this.story.Solutions_Options__r);
			
			CB_Game_User__c gameUser = CB_Utils.getCurrentLoggedInGameUser();
			
			// Getting User Block record for block id and game user passed as argument.
			CB_User_Block__c userBlock = CB_Utils.getUserBlockByBlockAndGameUserId(this.block.Id, gameUser.Id);
			
			CB_Story_Answer__c storyAnswer = new CB_Story_Answer__c();
			storyAnswer.CB_Story__c = this.story.Id;
			storyAnswer.CB_Solution_Option__c = this.selectedSolutionOptionId;
			storyAnswer.CB_Game_User__c = gameUser.Id;
			storyAnswer.CB_Block_Cost__c = this.block.CB_Cost__c;
			CB_Solution_Option__c solutionOption = solutionOptionByIdMap.get(this.selectedSolutionOptionId);
			Double reward = solutionOption.CB_Reward__c;
			storyAnswer.CB_Won__c = reward;
			insert storyAnswer;
			
			// marking the userBlock as completed if selected solution option score is either OK or Best.
			if(solutionOption.CB_Score__c == CB_Utils.SOLUTION_OPTION_OK || solutionOption.CB_Score__c == CB_Utils.SOLUTION_OPTION_BEST){
				userBlock.CB_Completed__c = true;
				update userBlock;
			}
		}catch(Exception e) {
			Database.rollback(sp);
			this.isBlockValidToPlay = false;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
		}
	}
	
	/**
	 * Method to get load the next valid block for user to play next. 
	 */
	public PageReference loadNextBlock() {
		PageReference ref = null;
		try {
			// Get the next valid block for the game user to play after this block.
			nextBlock = CB_Utils.getNextBlockToPlay(this.block.CB_Sequence__c, this.block.CB_Quadrant__r.CB_Sequence__c, this.block.CB_Quadrant__c, this.block.CB_Quadrant__r.CB_City__c, this.gameUser);
			
			// if nextblock - null, throw exception with message - all quadrants and blocks complete 
			if(nextBlock == null) throw new CB_Utils.CB_GameException(CB_Utils.ALL_QUADRANTS_AND_BLOCKS_COMPLETE);
			
			ref = Page.CB_Play;
			ref.getParameters().put('blockId', nextBlock.id);
			ref.setRedirect(true);
		} catch(Exception e) {
			this.isBlockValidToPlay = false;
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
		}
		return ref;
	}
	
	// Message variables used on VF page 
	public String oopsModalMessage { get { return CB_Utils.OPPS_MESSAGE; } set;}
	public String notBadModalMessage { get { return CB_Utils.NOT_BAD_MESSAGE; } set;}
	public String successModalMessage { get { return CB_Utils.BEST_MESSAGE; } set;}
}