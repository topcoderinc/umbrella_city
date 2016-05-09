/**
 * Class holding logic to play for a selected block. The logic checks if selected block is valid to play or not.
 */
public with sharing class CBGA_PlayController {
    // Story detail for game user to answer
    public CBGA_Story__c story {get; private set;}

    // Current block detail
    public CBGA_Block__c block {get; private set;}

    // Map holding Solution Options with key as solution type (Bad, OK and Best) and value as Solution Option Record corresponding to that type.
    public Map<String, CBGA_Solution_Option__c> solutionOptionsByScoreType {get; private set;}

    // Next valid block for game user to play
    public CBGA_Block__c nextBlock {get; private set;}

    // Variable to hold the id of the selected Solution Option answer
    public String selectedSolutionOptionId {get;set;}

    public boolean isBlockValidToPlay {get;set;}

    private CBGA_Game_User__c gameUser;

    //Whats the Block state, is it cleared by ok, or best score
    public String blockState {get;set;}

    /**
     * Init method to load block details and validate if current block is valid to play or not.
     */
    public void init() {
        // get the blockId
        Id blockId = (Id)ApexPages.currentPage().getParameters().get('blockId');
        this.isBlockValidToPlay = true;
        try {
            // Getting block detail using the block id
            this.block = CBGA_Utils.getBlockInfoByBlockId(blockId);

            // get the current logged in game user.
            this.gameUser = CBGA_Utils.getCurrentLoggedInGameUser();

            // getting the story and related Solutions Options associated with the block
            this.story = CBGA_Utils.getStoriesByBlockId(blockId, gameUser.Id);

            Map<Id, CBGA_User_Block__c> userBlockByBlockIdMap = CBGA_Utils.getUserBlocksByBlockIdSet(new set<Id>{block.Id}, gameUser.Id);
            CBGA_User_Block__c userBlock = userBlockByBlockIdMap.get(blockId);
            boolean isCompleted = (userBlock != null ? userBlock.CB_Completed__c : false);

            Integer blockIntState = CBGA_Utils.getBlockStateBasedOnUserAnswer(this.story.Solutions_Options__r,story.Story_Answer__r,isCompleted);
            
            System.debug('***blockIntState***' + blockIntState);
            
            if(blockIntState <= 3){
              this.blockState = '';
            }
            else if(blockIntState == 4 ){
                this.blockState = '_passed';
            }
            else {
                this.blockState = '_completed';
            }

            this.isBlockValidToPlay = CBGA_Utils.isBlockValidForCurrentUserToPlay(block, story, gameUser);
            // Preparing the solutionOptions with key as score type and value as solutionOption record.
            solutionOptionsByScoreType = CBGA_Utils.getSolutionOptionsByScoreType(this.story.Solutions_Options__r);
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
            Map<Id, CBGA_Solution_Option__c> solutionOptionByIdMap = new Map<Id, CBGA_Solution_Option__c>(this.story.Solutions_Options__r);

            CBGA_Game_User__c gameUser = CBGA_Utils.getCurrentLoggedInGameUser();

            // Getting User Block record for block id and game user passed as argument.
            CBGA_User_Block__c userBlock = CBGA_Utils.getUserBlockByBlockAndGameUserId(this.block.Id, gameUser.Id);

            CBGA_Story_Answer__c storyAnswer = new CBGA_Story_Answer__c();
            storyAnswer.CB_Story__c = this.story.Id;
            storyAnswer.CB_Solution_Option__c = this.selectedSolutionOptionId;
            storyAnswer.CB_Game_User__c = gameUser.Id;
            storyAnswer.CB_Block_Cost__c = this.block.CB_Cost__c;
            CBGA_Solution_Option__c solutionOption = solutionOptionByIdMap.get(this.selectedSolutionOptionId);
            Double reward = solutionOption.CB_Reward__c;
            storyAnswer.CB_Won__c = reward;
            insert storyAnswer;

            // marking the userBlock as completed if selected solution option score is either OK or Best.
            if(solutionOption.CB_Score__c == CBGA_Utils.SOLUTION_OPTION_OK || solutionOption.CB_Score__c == CBGA_Utils.SOLUTION_OPTION_BEST){
                userBlock.CB_Completed__c = true;
                update userBlock;
            }
            gameUser = processGameScore(solutionOption.CB_Score__c,gameUser);
            update gameUser;

        }catch(Exception e) {
            Database.rollback(sp);
            this.isBlockValidToPlay = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
    }


    /**
    *Process Game scores for the user
    */
    public CBGA_Game_User__c processGameScore(String score,CBGA_Game_User__c gameUser){

        //Initially the value might be null, set as zero to avoid computing on nulls
        if(gameUser.CB_Streak__c == null){
            gameUser.CB_Streak__c = 0;
        }

        //Best answers increase your winning streaks
        if(score == CBGA_Utils.SOLUTION_OPTION_BEST){
            if(gameUser.CB_Streak__c > 0){
                gameUser.CB_Streak__c++; //Continue the winning streak,add 1 for a series of wins
            }
            else {
                gameUser.CB_Streak__c = 1; //We have won the first answer after a long time
            }
        }

        if(score == CBGA_Utils.SOLUTION_OPTION_OK || score == CBGA_Utils.SOLUTION_OPTION_BAD){
            if(gameUser.CB_Streak__c < 0){
                gameUser.CB_Streak__c--; //Continue the loosing streak
            }
            else {
                gameUser.CB_Streak__c = -1; //We have answered a ok or bad answer,after long time
            }

        }
        return gameUser;
    }

    /**
     * Method to get load the next valid block for user to play next.
     */
    public PageReference loadNextBlock() {
        PageReference ref = null;
        try {
            // Get the next valid block for the game user to play after this block.
            nextBlock = CBGA_Utils.getNextBlockToPlay(this.block.CB_Sequence__c, this.block.CB_Quadrant__r.CB_Sequence__c, this.block.CB_Quadrant__c, this.block.CB_Quadrant__r.CB_City__c, this.gameUser);

            // if nextblock - null, throw exception with message - all quadrants and blocks complete
            if(nextBlock == null) throw new CBGA_Utils.CB_GameException(CBGA_Utils.ALL_QUADRANTS_AND_BLOCKS_COMPLETE);

            ref = Page.CBGA_Play;
            ref.getParameters().put('blockId', nextBlock.id);
            ref.setRedirect(true);
        } catch(Exception e) {
            this.isBlockValidToPlay = false;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
        return ref;
    }


       /**
     * Method to get city index based on the city URL. Default index will be zero
     */
    public string getCityIndex() {
        CBGA_City__c city = CBGA_Utils.getSelectedQuadrantCity(this.block.CB_Quadrant__c);
        String index = '0';
        if(city != null && city.CB_Image_URL__c == CBGA_Utils.CITY_1_IMAGE_URL) {
            index = '1';
        }
        return index;
    }

    // Message variables used on VF page
    public String oopsModalMessage { get { return CBGA_Utils.OPPS_MESSAGE; } set;}
    public String notBadModalMessage { get { return CBGA_Utils.NOT_BAD_MESSAGE; } set;}
    public String successModalMessage { get { return CBGA_Utils.BEST_MESSAGE; } set;}
}