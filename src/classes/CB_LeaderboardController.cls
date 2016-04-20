/**
 * Class holding method to get the list of all user to show on leader board UI
 */
public with sharing class CB_LeaderboardController {
	
	/**
	 * Method to get the list of Game user to show on UI.
	 */
	public List<List<GameUser>> gameUsers {get; set;}
	
	public void init() {
		List<CB_Game_User__c> gameUsersList = CB_Utils.getGameUsers();
		this.gameUsers = prepareGameUserDisplayList(gameUsersList);
	}
	
	/**
	 * Method to prepare 2 by 2 list of Game User to display on UI.
	 */
	public List<List<GameUser>> prepareGameUserDisplayList(List<CB_Game_User__c> gameUsers) {
		
		Map<Id, Integer> completedQuadrantCountByGameUserIdMap = CB_Utils.getCompletedQuadrantCountByGameUser(gameUsers);
		
		List<GameUser> gameUserList = new List<GameUser>();
		
		Integer rank=1;
		for(CB_Game_User__c user:gameUsers) {
			GameUser gameUser = new GameUser();
			gameUser.sfdcUserId = user.CB_User__c;
			gameUser.rank = rank;
			gameUser.level = String.valueOf(user.CB_Level__c);
			gameUser.title = user.CB_Title__c;
			// add the case of test class. In test class user.CB_User__r.Name is getting null
			gameUser.userName = user.CB_User__r.Name == null ? user.Name : user.CB_User__r.Name;
			gameUser.photoURL = user.CB_User__r.SmallPhotoUrl;
			gameUser.blocksCompleted = (Integer)user.CB_Blocks_Completed__c;
			gameUser.quadrantsCompleted = completedQuadrantCountByGameUserIdMap.get(user.id);
			
			//Decimal budgetInMillion = user.CB_Budget__c != null ? (user.CB_Budget__c/100000) : 0.00;
			Decimal budgetInMillion = getRoundedValueInMillion(user.CB_Budget__c); 
			
			gameUser.currentBudget = CB_Utils.getCurrencySymbol(user) + budgetInMillion +'M';
			rank++;
			gameUserList.add(gameUser);
		}
		
		List<List<GameUser>> gameUserListOfList = new List<List<GameUser>>();
		
		List<GameUser> guList = new List<GameUser>();
		gameUserListOfList.add(guList);
		
		for(GameUser gu:gameUserList) {
			if(guList.size() == 2) {
				guList = new List<GameUser>();
				gameUserListOfList.add(guList);
			}
			guList.add(gu);
		}
		return gameUserListOfList;
	}
	
	
	public Decimal getRoundedValueInMillion(Decimal budget){
	  if(budget == null) return 0.00;
	  //convert to 2 decimal places
	  budget = budget / 100000;
	  
	  //Set Rounding expectations
	  budget = budget.setScale(2, RoundingMode.HALF_UP);
	  return budget;
	  
	}
	
	// Variable holding search string enterd by user
	public String searchString {get;set;}
	
	/**
	 * Search for game user based on search string enter by user.
	 */ 
	public void searchGameUser() {
		String searchParam = '%'+ String.escapeSingleQuotes(searchString) +'%';
		List<CB_Game_User__c> gameUsers = CB_Utils.searchUserResult(searchParam);
		this.gameUsers = prepareGameUserDisplayList(gameUsers);
	}
	
	/**
	 * Inner class holding Game User detail
	 */
	public class GameUser {
		public Id sfdcUserId {get;set;}
		public String userName {get;set;}
		public String level {get;set;}
		public String title {get;set;}
		public Integer rank {get;set;}
		public String photoURL {get;set;}
		public Integer blocksCompleted {get;set;}
		public Integer quadrantsCompleted {get;set;}
		public String currentBudget {get;set;}
	}
	
	
}