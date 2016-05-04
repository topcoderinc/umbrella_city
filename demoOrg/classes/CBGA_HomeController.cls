/**
 * Home controller class holding logic to laod cities and there related records to show on city Map.
 */
public with sharing class CBGA_HomeController {
    
    /**
     *  Method to get the Game User details for current logged in user. Create a Game User if one does not exist for current user.
     */
    public CBGA_Game_User__c gameUserInfo {get; private set;}
    
    public String userRank {get;set;}
    
    /**
     * Method call on the initial load of the UI to laod Game User. If Game User is not available for 
     * logged in user, a new Game User will be created. 
     */
    public void init() {
        // Method to get the Game User details for current logged in user. Create a Game User if one does not exist for current user
        this.gameUserInfo = CBGA_Utils.getCurrentLoggedInGameUser();
        this.userRank = CBGA_Utils.getUserRank(UserInfo.getUserId());
    }
    
    /**
     * Method to get the current city name. For now getting the first city name in the list. 
     */ 
    public String getCurrentCityName() {
        List<CBGA_City__c> cityList = CBGA_Utils.getCities();
        return (!cityList.isEmpty()) ? cityList.get(0).Name : ''; 
    }
    
    /**
     * Method to get completed quadrant count.
     */ 
    public Integer getCompletedQuadrantCount() {
        Map<Id, Integer> completedQuadrantCountByGameUserIdMap = CBGA_Utils.getCompletedQuadrantCountByGameUser(new List<CBGA_Game_User__c>{this.gameUserInfo});
        return completedQuadrantCountByGameUserIdMap.get(this.gameUserInfo.Id);
    }

    /**
     * Method to load all cities along with associated quadrants and blocks. The method set the state of each block
     * as per the logic specifed in the requirment (Refer to CBGA_Utils.getBlockState method for related logic).
     */
    public List<CB_City> getCities() {
        List<CB_City> cities = new List<CB_City>();
        
        // Get cities
        List<CBGA_City__c> cityList = CBGA_Utils.getCities();
        
        // City id set
        set<Id> cityIds = new Map<Id, CBGA_City__c>(cityList).keySet();
        
        // Getting list quadrant for the city ids
        List<CBGA_Quadrant__c> quadrantList = CBGA_Utils.getQuadrantByCityIds(cityIds);
        
        // Map holding Quadrant list by city id as key.
        map<Id, List<CBGA_Quadrant__c>> quadrantListByCityIdMap = new map<Id, List<CBGA_Quadrant__c>>();
        List<CBGA_Block__c> blockList = new List<CBGA_Block__c>();
        for(CBGA_Quadrant__c quadrant:quadrantList) {
            List<CBGA_Quadrant__c> quadrants = quadrantListByCityIdMap.get(quadrant.CB_City__c);
            if(!quadrantListByCityIdMap.containsKey(quadrant.CB_City__c)){
                quadrants = new List<CBGA_Quadrant__c>();
                quadrantListByCityIdMap.put(quadrant.CB_City__c, quadrants);
            }
            quadrants.add(quadrant);
            blockList.addAll(quadrant.Block__r);
        }
        
        // getting set of block ids using the list of block
        set<Id> blockIds = new map<Id, CBGA_Block__c>(blockList).keyset();
        
        // Getting stories associated with block (along  with solution options and story answers specific to Game user). 
        // As there will be one story associated with the block so 
        // the map will contain key as block id and value as story record.
        Map<Id, CBGA_Story__c> storyByBlockIdMap = CBGA_Utils.getStoryByBlockIdSet(blockIds, this.gameUserInfo.Id);
        
        // Getting User blocks associated with block and current Game user. As there will be one User block associated with the block
        // so Map will contain key as Block id and value as User Block record.
        Map<Id, CBGA_User_Block__c> userBlockByBlockIdMap = CBGA_Utils.getUserBlocksByBlockIdSet(blockIds, this.gameUserInfo.Id);
        
        String currencySymbol;
        
        // setting start index as 0
        Integer ci = 0; 
        for(CBGA_City__c c:cityList) {
            CB_City city = new CB_City();
            city.name = c.Name;
            city.resource = c.CB_Image_URL__c;
            city.quadrants = new List<CB_Quadrant>();
            city.sequence = ci;
            
            for (CBGA_Quadrant__c quad: quadrantListByCityIdMap.get(c.Id)) {
                CB_Quadrant quadrant = new CB_Quadrant();
                quadrant.name = quad.CB_Quadrant_Name__c;
                quadrant.sequence = (Integer)quad.CB_Sequence__c - 1;
                quadrant.blocks = new List<CB_Blocks>();
                
                for(CBGA_Block__c blockObj:quad.Block__r) {
                    CB_Blocks block = new CB_Blocks();
                    block.id = blockObj.Id;
                    block.name = blockObj.CB_Block_Name__c;
                    block.sequence = (Integer)blockObj.CB_Sequence__c - 1;
                    
                    // Getting currency symbol
                    currencySymbol = String.isBlank(currencySymbol) ? CBGA_Utils.getCurrencySymbol(blockObj) : currencySymbol;
                    block.cost = blockObj.CB_Cost__c != null ? currencySymbol + blockObj.CB_Cost__c: currencySymbol+'0.0';
                    
                    CBGA_Story__c story = storyByBlockIdMap.get(blockObj.Id);
                    CBGA_User_Block__c userBlock = userBlockByBlockIdMap.get(blockObj.Id);
                    
                    // getting state of block 
                    block.state = CBGA_Utils.getBlockState(story, userBlock, this.gameUserInfo.CB_Budget__c, blockObj.CB_Cost__c);
                    block.question = story != null ? story.CB_Story_Text__c : '';
                    
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
        public String question { get; set; }
    }
}