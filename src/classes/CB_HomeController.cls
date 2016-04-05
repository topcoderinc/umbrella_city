/**
 * Home controller class holding logic to laod cities and there related records to show on city Map.
 */
public with sharing class CB_HomeController {
	
	/**
     *  Method to get the Game User details for current logged in user. Create a Game User if one does not exist for current user.
     */
    public CB_Game_User__c gameUserInfo {get; private set;}
    
	/**
	 * Method call on the initial load of the UI to laod Game User. If Game User is not available for 
	 * logged in user, a new Game User will be created. 
	 */
	public void init() {
    	// Method to get the Game User details for current logged in user. Create a Game User if one does not exist for current user
    	this.gameUserInfo = CB_Utils.getCurrentLoggedInGameUser();
    }
    
    /**
     * Method to get the current city name. For now getting the first city name in the list. 
     */ 
    public String getCurrentCityName() {
    	List<CB_City__c> cityList = CB_Utils.getCities();
    	return (!cityList.isEmpty()) ? cityList.get(0).CB_City_Name__c : ''; 
    }
    
    /**
     * Method to get completed quadrant count.
     */ 
    public Integer getCompletedQuadrantCount() {
    	Map<Id, Integer> completedQuadrantCountByGameUserIdMap = CB_Utils.getCompletedQuadrantCountByGameUser(new List<CB_Game_User__c>{this.gameUserInfo});
    	return completedQuadrantCountByGameUserIdMap.get(this.gameUserInfo.Id);
    }

	/**
	 * Method to load all cities along with associated quadrants and blocks. The method set the state of each block
	 * as per the logic specifed in the requirment (Refer to CB_Utils.getBlockState method for related logic).
	 */
    public List<CB_City> getCities() {
        List<CB_City> cities = new List<CB_City>();
        
        // Get cities
        List<CB_City__c> cityList = CB_Utils.getCities();
        
        // City id set
        set<Id> cityIds = new Map<Id, CB_City__c>(cityList).keySet();
        
		// Getting list quadrant for the city ids
		List<CB_Quadrant__c> quadrantList = CB_Utils.getQuadrantByCityIds(cityIds);
		
		// Map holding Quadrant list by city id as key.
		map<Id, List<CB_Quadrant__c>> quadrantListByCityIdMap = new map<Id, List<CB_Quadrant__c>>();
		List<CB_Block__c> blockList = new List<CB_Block__c>();
		for(CB_Quadrant__c quadrant:quadrantList) {
			List<CB_Quadrant__c> quadrants = quadrantListByCityIdMap.get(quadrant.CB_City__c);
			if(!quadrantListByCityIdMap.containsKey(quadrant.CB_City__c)){
				quadrants = new List<CB_Quadrant__c>();
				quadrantListByCityIdMap.put(quadrant.CB_City__c, quadrants);
			}
			quadrants.add(quadrant);
			blockList.addAll(quadrant.Block__r);
		}
		
		// getting set of block ids using the list of block
		set<Id> blockIds = new map<Id, CB_Block__c>(blockList).keyset();
		
		// Getting stories associated with block (along  with solution options and story answers specific to Game user). 
		// As there will be one story associated with the block so 
		// the map will contain key as block id and value as story record.
		Map<Id, CB_Story__c> storyByBlockIdMap = CB_Utils.getStoryByBlockIdSet(blockIds, this.gameUserInfo.Id);
		
		// Getting User blocks associated with block and current Game user. As there will be one User block associated with the block
		// so Map will contain key as Block id and value as User Block record.
		Map<Id, CB_User_Block__c> userBlockByBlockIdMap = CB_Utils.getUserBlocksByBlockIdSet(blockIds, this.gameUserInfo.Id);
		
		String currencySymbol;
		
		// setting start index as 0
		Integer ci = 0; 
		for(CB_City__c c:cityList) {
			CB_City city = new CB_City();
            city.name = c.CB_City_Name__c;
            city.resource = c.CB_Image_URL__c;
            city.quadrants = new List<CB_Quadrant>();
            city.sequence = ci;
            
            for (CB_Quadrant__c quad: quadrantListByCityIdMap.get(c.Id)) {
                CB_Quadrant quadrant = new CB_Quadrant();
                quadrant.name = quad.CB_Quadrant_Name__c;
                quadrant.sequence = (Integer)quad.CB_Sequence__c;
                quadrant.blocks = new List<CB_Blocks>();
                
                for(CB_Block__c blockObj:quad.Block__r) {
                	CB_Blocks block = new CB_Blocks();
                    block.id = blockObj.Id;
                    block.name = blockObj.CB_Block_Name__c;
                    block.sequence = (Integer)blockObj.CB_Sequence__c;
                    
                    // Getting currency symbol
                    currencySymbol = String.isBlank(currencySymbol) ? CB_Utils.getCurrencySymbol(blockObj) : currencySymbol;
                    block.cost = blockObj.CB_Cost__c != null ? currencySymbol + blockObj.CB_Cost__c: currencySymbol+'0.0';
                    
                    CB_Story__c story = storyByBlockIdMap.get(blockObj.Id);
                    CB_User_Block__c userBlock = userBlockByBlockIdMap.get(blockObj.Id);
                    
                    // getting state of block 
                    block.state = CB_Utils.getBlockState(story, userBlock, this.gameUserInfo.CB_Budget__c, blockObj.CB_Cost__c);
                    quadrant.blocks.add(block);
                }
                city.quadrants.add(quadrant);
            }
            cities.add(city);
            ci++;
		}
        return cities;
    }

    public class CB_City {
        public String name { get; set; }
        public String resource { get; set; }
        public Integer sequence { get; set; }
        public List<CB_Quadrant> quadrants { get; set; }
    }
    public class CB_Quadrant {
        public String name { get; set; }
        public Integer sequence { get; set; }
        public List<CB_Blocks> blocks { get; set; }
    }
    public class CB_Blocks {
        public String id { get; set; }
        public String name { get; set; }
        public Integer sequence { get; set; }
        public Integer state { get; set; }
        public String cost { get; set; }
    }
}