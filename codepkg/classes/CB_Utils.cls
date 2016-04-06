/**
 * Utility class holding static utility method used on Home, Leaderboard and Play controller.
 */
public with sharing class CB_Utils {
	
	public static final String SOLUTION_OPTION_OK = 'Ok';
	public static final String SOLUTION_OPTION_BEST = 'Best';
	public static final String SOLUTION_OPTION_BAD = 'Bad';
	public static final String ID_KEY_SEPERATOR = '-';
	
	// Message constants
	public static final String NO_STORY_DEFINED = 'No story defined for this block.';
	public static final String NO_STORY_SOLUTION_OPTION_DEFINED = 'No story solution options defined for this block.';
	public static final String BLOCK_IS_COMPLETED_WITH_BEST_ANSWER = 'You have played this block with best answer. You can not replay.';
	public static final String NOT_ENOUGH_BUDGET = 'You do not have enough Budget to play this block.';
	public static final String ALL_QUADRANTS_AND_BLOCKS_COMPLETE = 'All quadrants and blocks are complete.';
	
	public static String OPPS_MESSAGE = 'You have lost ';
	public static String NOT_BAD_MESSAGE = 'You will not receive a budget increase';
	public static String BEST_MESSAGE = 'You have gained ';
	
	// Setting default Game user query limit as 20 
	public static final Integer GAME_USER_QUERY_LIMIT = 20;
	
	/**
	 * Method to get the User block record matching the Block and Game user id passed as argument. If there is not User Blcok 
	 * record available, it will create a new record using the block and Game user id. 
	 *
	 * Method return User Block record - CB_User_Block__c
	 */
	public static CB_User_Block__c getUserBlockByBlockAndGameUserId(Id blockId, Id gameUserId) {
		
		// Quering User block matching the blockId and ganeUserId
		List<CB_User_Block__c> userBlocks = [Select Id, CB_Game_User__c, CB_Completed__c, CB_Block__c From CB_User_Block__c where CB_Block__c =: blockId and CB_Game_User__c =: gameUserId];
		
		// Creating a new Userblock record for the current gameuser and block id if one not exist.
		if(userBlocks.isEmpty()) {
			CB_User_Block__c userBlock = new CB_User_Block__c();
			userBlock.CB_Block__c = blockId;
			userBlock.CB_Game_User__c = gameUserId;
			insert userBlock;
			userBlocks = [Select Id, CB_Game_User__c, CB_Completed__c, CB_Block__c From CB_User_Block__c where CB_Block__c =: blockId and CB_Game_User__c =: gameUserId];
		}
		return userBlocks.get(0);
	}	
	
	/**
	 * Method to get the all Game User details to show on leader board.
	 */
	public static List<CB_Game_User__c> getGameUsers() {
		List<CB_Game_User__c> gameUsers = [Select Name, CB_Title__c, CB_Level__c, CB_Budget__c, CB_User__c, CB_Blocks_Completed__c, CB_User__r.Name, 
									CB_User__r.SmallPhotoUrl From CB_Game_User__c order by CB_Budget__c desc limit :GAME_USER_QUERY_LIMIT];
		return gameUsers;
	}
		
	
	/**
	 * Method to get the Game User details for current logged in user. Creating a Game User if one does not exist for current user.
	 */
	public static CB_Game_User__c getCurrentLoggedInGameUser() {
		List<CB_Game_User__c> gameUsers = [Select Name, CB_Title__c, CB_Level__c, CB_Budget__c, CB_User__r.SmallPhotoUrl, CB_Blocks_Completed__c From CB_Game_User__c where CB_User__c =: UserInfo.getUserId()];
		
		if(gameUsers.isEmpty()) {
			CB_Game_User__c gameUser = new CB_Game_User__c();
			gameUser.Name = UserInfo.getName();
			gameUser.CB_User__c = UserInfo.getUserId();
			insert gameUser;
			// Quering the inserted record with other fields. 
			gameUsers = [Select Name, CB_Title__c, CB_Level__c, CB_Budget__c, CB_User__r.SmallPhotoUrl, CB_Blocks_Completed__c From CB_Game_User__c where id =: gameUser.Id];
		}
		return gameUsers.get(0);
	}
	
	/**
	 * Method to get block detail using block id passed as argument. 
	 */
	public static CB_Block__c getBlockInfoByBlockId(Id blockId) {
		List<CB_Block__c> blocks = [Select CB_Sequence__c, CB_Quadrant__r.CB_Quadrant_Name__c, CB_Quadrant__c, CB_Quadrant__r.CB_Sequence__c,
						 CB_Quadrant__r.CB_City__c, CB_Icon_Image_URL__c, CB_Cost__c, CB_Block_Name__c From CB_Block__c where id =:blockId]; 
		
		CB_Block__c block;
		if(!blocks.isEmpty()) block = blocks.get(0);
		return block;
	}
	
	/**
	 * Method to load stories (along with Solution Options and answers) associated with the Block id passed as argument.
	 */
	public static CB_Story__c getStoriesByBlockId(Id blockId, Id gameUserId) {
		List<CB_Story__c> blockStories = [Select Name, CB_Story_Text__c, CB_Solution_Data_Type__c, CB_Block__c, 	
							(Select CB_Reward__c, CB_Score__c, CB_Sequence__c, CB_Solution_Selection_Description__c, 
							CB_Solution_Text__c From Solutions_Options__r order by CB_Sequence__c),
							(Select CB_Solution_Option__c From Story_Answer__r where CB_Game_User__c =: gameUserId)
							 From CB_Story__c where CB_Block__c =: blockId];
		
		CB_Story__c story;
		if(!blockStories.isEmpty()) story = blockStories.get(0);
		
		return story;
	}
	
	/**
	 * Method to load stories (along with associated Solution Option and Stroy answers specific to game user id passed as argument)
	 * associated with the Block id set passed as argument. 
	 */
	public static Map<Id, CB_Story__c> getStoryByBlockIdSet(set<Id> blockIds, Id gameUserId) {
		List<CB_Story__c> blockStories = [Select Name, CB_Story_Text__c, CB_Solution_Data_Type__c, CB_Block__c,
							(Select CB_Reward__c, CB_Score__c, CB_Sequence__c, CB_Solution_Selection_Description__c, 
							CB_Solution_Text__c From Solutions_Options__r order by CB_Sequence__c),
							(Select CB_Solution_Option__c From Story_Answer__r where CB_Game_User__c =: gameUserId) From CB_Story__c 
							where CB_Block__c IN :blockIds];
		
		Map<Id, CB_Story__c> storyByBlockIdMap = new Map<Id, CB_Story__c>();
		for(CB_Story__c story:blockStories) {
			 storyByBlockIdMap.put(story.CB_Block__c, story);
		}
		return storyByBlockIdMap;
	}
	
	/**
	 * Method to laod User blocks associated with block ids and game user id passed as parameter.
	 */
	public static Map<Id, CB_User_Block__c> getUserBlocksByBlockIdSet(set<Id> blockIds, Id gameUserId) {
		// Quering User block matching the blockIds
		List<CB_User_Block__c> userBlocks = [Select CB_Completed__c, CB_Block__c From CB_User_Block__c where CB_Block__c IN: blockIds and CB_Game_User__c =:gameUserId];
		
		// Map with key as Bock Id and value as User Block record.
		Map<Id, CB_User_Block__c> userBlockByBlockIdMap = new Map<Id, CB_User_Block__c>();
		for(CB_User_Block__c userBlock:userBlocks) {
			userBlockByBlockIdMap.put(userBlock.CB_Block__c, userBlock);
		}
		return userBlockByBlockIdMap;
	}
	
	/** 
	 * Method to get the SolutionOptions Map with key as Score type (OK, Best and Bad) and value SolutionOption record.
	 */
	public static Map<String, CB_Solution_Option__c> getSolutionOptionsByScoreType(List<CB_Solution_Option__c> solutionOptions) {
		Map<String, CB_Solution_Option__c> solutionOptionMapByScoreType = new Map<String, CB_Solution_Option__c>();
		for(CB_Solution_Option__c opt : solutionOptions) {
			solutionOptionMapByScoreType.put(opt.CB_Score__c, opt);
		}
		return solutionOptionMapByScoreType;
	}
	
	/**
	 * Method to get the block status based on the below logic. 
	 *
	 * A Block can have 5 states 
     * State 1 No Question available for the Block
     * State 2 Question available, but the user doesn't have the budget to select it
     * State 3 Question avaliable, user has the budget to select it or hasn't completed the block in earlier attempts
     *  A Block is set to be completed, when user answer the question, with ok or best score
     * State 4 Block completed, user passed with OK scores
     * State 5 Block Completed, user passed with Best scores 
     * Please note a user has the option to play the same question more than once.
     * Query Story with the Block to check if Block has a question
     * Check Budget field on the Game_User to check if the block can be purchased if not already purchased
     * Check the Story_Answer object to check if user has answered correctly
     * A field CB_Completed is available to on User_Block to check if the answer has been made correctly
	 */
	public static Integer getBlockState(CB_Story__c story, CB_User_Block__c userBlock, Decimal gameUserBudget, Decimal blockCost) {
		
		Integer state = 0;
		
		if(story == null) {
			// State 1 No Question available for the Block
			state = 1;
		} else if(gameUserBudget < blockCost) {
        	// State 2 Question available, but the user doesn't have the budget to select it
        	state = 2;
        } else if(userBlock == null || userBlock.CB_Completed__c == false) {
        	// State 3 Question avaliable, user has the budget to select it or hasn't completed the block in earlier attempts
            // A Block is set to be completed, when user answer the question, with ok or best score
        	state = 3;
        } else {
        	// Processing block state using the Solution options and answers given by the Game user 
        	state = getBlockStateBasedOnUserAnswer(story.Solutions_Options__r, story.Story_Answer__r, userBlock.CB_Completed__c);
        }
        return state; 
	}
	
	/**
	 * Method to get Block state based on the Answers given by the Game User. If there a best answer than state will be 5 and for
	 * OK answer it will be 4
	 */
	public static Integer getBlockStateBasedOnUserAnswer(List<CB_Solution_Option__c> solutionOptions, List<CB_Story_Answer__c> storyAnswers, boolean isUserBlockCompleted) {
		// Getting solution option Map with key as Score type and value as solution option.
		Map<String, CB_Solution_Option__c> solutionOptionMapByScoreType = getSolutionOptionsByScoreType(solutionOptions);
        
        // collecting all answered solution option id in a set to check if there a solution option matching OK or Best option record.
        set<Id> answeredSolutionOptionIdSet = new set<Id>();
        for(CB_Story_Answer__c answer:storyAnswers) {
        	answeredSolutionOptionIdSet.add(answer.CB_Solution_Option__c);
        }
        
        // getting the ok and best solution option id from the Map.
        Id okSolutionOptionId = solutionOptionMapByScoreType.get(SOLUTION_OPTION_OK) != null ? solutionOptionMapByScoreType.get(SOLUTION_OPTION_OK).Id : null;
        Id bestSolutionOptionId = solutionOptionMapByScoreType.get(SOLUTION_OPTION_BEST) != null ? solutionOptionMapByScoreType.get(SOLUTION_OPTION_BEST).Id : null;
        
        Integer state = 0;
        if(isUserBlockCompleted && bestSolutionOptionId != null && answeredSolutionOptionIdSet.contains(bestSolutionOptionId)) {
        	// State 5 Block Completed, user passed with Best scores 
        	// Processing state 5 i.e answer as best before 4 i.e OK to check if there is best answer available 
        	// for any multiple answer for same story and game user.
        	state = 5;
        } else if(isUserBlockCompleted && okSolutionOptionId != null && answeredSolutionOptionIdSet.contains(okSolutionOptionId)) {
        	// State 4 Block completed, user passed with OK scores
        	state = 4;
        }
        return state;
	}
	
	/**
	 * Method to get list of quadrants (along with associated Blocks) associated with the city ids passed as parameter.
	 */
	public static List<CB_Quadrant__c> getQuadrantByCityIds(set<Id> cityIds) {
		List<CB_Quadrant__c> quadrants = [SELECT Id, CB_Quadrant_Name__c, CB_City__c, CB_Sequence__c,
        						(SELECT Id, CB_Block_Name__c, CB_Cost__c, CB_Sequence__c FROM Block__r ORDER BY CB_Sequence__c LIMIT 4)
         						FROM CB_Quadrant__c WHERE CB_City__c IN :cityIds ORDER BY CB_Sequence__c];
    	return quadrants;      						
	}
	
	/**
	 * Method to get list of cities
	 */
	public static List<CB_City__c> getCities() {
		return [SELECT Id, CB_City_Name__c, CB_Image_URL__c from CB_City__c ORDER BY CreatedDate DESC];
	}
	
	/**
	 * Method to get the next valid block for the Game user based on the current block and sequence. 
	 * A block is valid to play/replay if is not completed with best answer and user enough budget to play for that block.
	 */
	public static CB_Block__c getNextBlockToPlay(Decimal currentBlockSequence, Decimal currentQuadSequence, Id currentBlockQuadrantId, Id currentQuadCityId, CB_Game_User__c gameUser) {
		List<CB_Block__c> blocks = [Select Id, CB_Cost__c, CB_Block_Name__c From CB_Block__c where CB_Sequence__c > :currentBlockSequence
						  and CB_Quadrant__c =:currentBlockQuadrantId order by CB_Sequence__c];
		
		// If return blocks is empty that mean there is no next block in current Quadrant 				  
		if(blocks.isEmpty()) {
			List<CB_Quadrant__c> quadrants = [SELECT Id, CB_Sequence__c, (SELECT Id, CB_Cost__c FROM Block__r ORDER BY CB_Sequence__c) 
							FROM CB_Quadrant__c WHERE CB_Sequence__c > :currentBlockSequence and CB_City__c =:currentQuadCityId ORDER BY CB_Sequence__c];
         	
         	blocks = new List<CB_Block__c>();
         	for(CB_Quadrant__c quadrant:quadrants) {
         		blocks.addAll(quadrant.Block__r);
         	}
		}
		// Passing all Quadrant blocks for getting the next valid block to play
		CB_Block__c nextValidBlockToPlay = getValidNextBlock(blocks, gameUser.Id, gameUser.CB_Budget__c);
         	
		return nextValidBlockToPlay;
	}
	
	/**
	 * Method to get the next valid block for the Game user. 
	 * A block is valid to play/replay if is not completed with best answer and user enough budget to play for that block.
	 */
	public static CB_Block__c getValidNextBlock(List<CB_Block__c> blocks, Id gameUserId, Decimal userBudget) {
		CB_Block__c nextValidBlockToPlay;
		
		if(blocks != null && !blocks.isEmpty()) {
			set<Id> blockIds = new Map<Id, CB_Block__c>(blocks).keySet();
			Map<Id, CB_Story__c> storiesByBlockIdMap = getStoryByBlockIdSet(blockIds, gameUserId);
			
			// Map with key as Bock Id and value as User Block record.
			Map<Id, CB_User_Block__c> userBlockByBlockIdMap = getUserBlocksByBlockIdSet(blockIds, gameUserId);
			
			for(CB_Block__c block:blocks) {
				CB_Story__c story = storiesByBlockIdMap.get(block.Id);
				CB_User_Block__c userBlock = userBlockByBlockIdMap.get(block.Id);
				
				if(story != null) {
					boolean isCompleted = (userBlock != null ? userBlock.CB_Completed__c : false);
			        // Processing block state using the Solution options and answers given by the Game user 
			        Integer state = getBlockStateBasedOnUserAnswer(story.Solutions_Options__r, story.Story_Answer__r, isCompleted);
			        
			        // If state == 5 mean user completed this block with best answer and can not replay. Continue process next block.
			        // OR if current user budget in not enough to play this block. Check for next block with low cost.
			        if(state == 5 || (userBudget < block.CB_Cost__c)) continue;
			        
			        // set the current block as next block to play if it is not completed with best answer. 
			        nextValidBlockToPlay = block;
				}
			}
		}
		return nextValidBlockToPlay;
	}
	
	/**
	 * Method to check if block passed as argument is valid for current Game user to play or not.
	 */
	public static boolean isBlockValidForCurrentUserToPlay(CB_Block__c block, CB_Story__c story, CB_Game_User__c gameUser) {
		// Map with key as Bock Id and value as User Block record.
		Map<Id, CB_User_Block__c> userBlockByBlockIdMap = getUserBlocksByBlockIdSet(new set<Id>{block.Id}, gameUser.Id);
		
		CB_User_Block__c userBlock = userBlockByBlockIdMap.get(block.Id);
		
		// Throw exception if no story defined for the block
		if(story == null) throw new CB_GameException(NO_STORY_DEFINED);
		
		// Throw exception if no solution option defined for the story
		if(story.Solutions_Options__r == null) throw new CB_GameException(NO_STORY_SOLUTION_OPTION_DEFINED);
		
		boolean isCompleted = (userBlock != null ? userBlock.CB_Completed__c : false);
        // Processing block state using the Solution options and answers given by the Game user 
        Integer state = getBlockStateBasedOnUserAnswer(story.Solutions_Options__r, story.Story_Answer__r, isCompleted);
        
        // If state == 5 mean user completed this block with best answer and can not replay.
        if(state == 5) throw new CB_GameException(BLOCK_IS_COMPLETED_WITH_BEST_ANSWER);
        
        // if current user budget in not enough to play this block. Check for next block with low cost.
        if(gameUser.CB_Budget__c < block.CB_Cost__c) throw new CB_GameException(NOT_ENOUGH_BUDGET);

		return true;
	}
	
	/**
	 * Method to get currency ISO code for an object passed argument.
	 */
	public static String getCurrencyIsoCode(SObject sourceObject){
        String currencyIso = UserInfo.isMultiCurrencyOrganization() ? (String)sourceObject.get('CurrencyIsoCode') : UserInfo.getDefaultCurrency();
        return currencyIso;
    }
	
	/**
	 * Method to get currency symbol.
	 */
    public static String getCurrencySymbol(SObject someObject) {
        return getCurrencySymbolFromIso(getCurrencyIsoCode(someObject));
    }
	
	/** 
	 * Method to get currency symbol based currency ISO code.
	 */
    public static String getCurrencySymbolFromIso(String Iso) {
         String currencySymbol = 
           ('USD' == Iso ? '$' : 
           ('CAD' == Iso ? '$' : 
           ('EUR' == Iso ? '€' : 
           ('GBP' == Iso ? '£' : 
           ('JPY' == Iso ? '¥' : 
           ('KRW' == Iso ? '₩' : 
           ('CNY' == Iso ? '元' : 
           Iso)))))));
           return currencySymbol;
    }
    
    /**
	 * Method to laod User blocks associated with block ids
	 */
	public static Map<String, CB_User_Block__c> getUserBlocksGroupbyBlockAndGameUserIds(set<Id> blockIds) {
		// Quering User block matching the blockIds
		List<CB_User_Block__c> userBlocks = [Select CB_Completed__c, CB_Block__c, CB_Game_User__c From CB_User_Block__c where CB_Block__c IN: blockIds];
		
		// Map with key as Bock and Game user Id and value as User Block record.
		Map<String, CB_User_Block__c> userBlockByBlockAndGameUserIdMap = new Map<String, CB_User_Block__c>();
		for(CB_User_Block__c userBlock:userBlocks) {
			userBlockByBlockAndGameUserIdMap.put(userBlock.CB_Block__c + ID_KEY_SEPERATOR + userBlock.CB_Game_User__c, userBlock);
		}
		return userBlockByBlockAndGameUserIdMap;
	}
    
    /**
     * Method to get the count of completed quadrants for each Game User.
     */
    public static Map<Id, Integer> getCompletedQuadrantCountByGameUser(List<CB_Game_User__c> gameUsers) {
    	List<CB_Quadrant__c> quadrants = [SELECT Id, CB_Quadrant_Name__c, CB_City__c, CB_Sequence__c,
        						(SELECT Id, CB_Block_Name__c, CB_Cost__c, CB_Sequence__c FROM Block__r ORDER BY CB_Sequence__c LIMIT 4)
         						FROM CB_Quadrant__c ORDER BY CB_Sequence__c];
       
       List<CB_Block__c> blocks = new List<CB_Block__c>();
       for(CB_Quadrant__c quad:quadrants) {
       		blocks.addAll(quad.Block__r);
       }
       
       set<Id> blockIdSet = new map<id, CB_Block__c>(blocks).keySet(); 
       
       // Map with key as block id and game user id and value as User Block record.
       Map<String, CB_User_Block__c> userBlockByBlockAndGameUserIdMap = getUserBlocksGroupbyBlockAndGameUserIds(blockIdSet);
       
       // Map with key as Game User Id and value as completed quadrant count
       Map<Id, Integer> completedQuadrantCountByGameUserIdMap = new Map<Id, Integer>();
       for(CB_Game_User__c user:gameUsers) {
       		for(CB_Quadrant__c quad:quadrants) {
       			boolean isQuadrantComplete = true;
       			for(CB_Block__c block:quad.Block__r) {
       				String key = block.Id + ID_KEY_SEPERATOR + user.Id;
       				if(!userBlockByBlockAndGameUserIdMap.containsKey(key) || userBlockByBlockAndGameUserIdMap.get(key).CB_Completed__c == false){
       					isQuadrantComplete = false;
       					break; // break from the loop
       				}
       			}
       			Integer quadCount = completedQuadrantCountByGameUserIdMap.containsKey(user.Id) ? completedQuadrantCountByGameUserIdMap.get(user.Id) : 0;
       			// Increment the quadCount by 1 if isQuadrantComplete = true
       			if(isQuadrantComplete) quadCount += 1;
       			
       			// put the updated count value to map.
       			completedQuadrantCountByGameUserIdMap.put(user.Id, quadCount);
       		}
       }
       return completedQuadrantCountByGameUserIdMap;
    }
    
    /** 
     * Searching for user based on the search string passed as parameter.
     */
    public static List<CB_Game_User__c> searchUserResult(String searchString) {
    	List<CB_Game_User__c> gameUsers = [Select Name, CB_Title__c, CB_Level__c, CB_Budget__c, CB_User__c, CB_User__r.Name, 
						CB_Blocks_Completed__c, CB_User__r.SmallPhotoUrl From CB_Game_User__c 
						where CB_Title__c like: searchString OR CB_User__r.Name like: searchString
						order by CB_Budget__c desc limit : GAME_USER_QUERY_LIMIT];
		return gameUsers;				
    }
	
	// Custom exception class
	public class CB_GameException extends Exception {}

}