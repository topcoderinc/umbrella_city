/**
 * Utility class holding logic for process uploaded csv file content and creating cities, 
 * quadrants, blocks, stories and story solution options.
 */
public with sharing class CBGA_CityDataLoaderUtils {
	
	public static final String ROW_KEY_CITY = 'City';
    public static final String ROW_KEY_QUADRANT = 'Quadrant';
    public static final String ROW_KEY_BLOCK = 'Block';
    public static final String ROW_KEY_STORY = 'STORY';
    public static final String ROW_KEY_STORY_OPTION = 'Option';
    public static final String ERROR_MSG_NO_CITY_DATA = 'No city data available in the csv file or invalid data.';
    public static final String ERROR_MSG_NO_QUADRANT_DATA = 'No quadrants data available in the csv file or invalid data.';
    public static final String ERROR_MSG_NO_BLOCK_DATA = 'No blocks data available in the csv file or invalid data.';
    public static final String ERROR_MSG_NO_STORY_DATA = 'No Stories data available in the csv file or invalid data.';
    public static final String ERROR_MSG_NO_STORY_SOLUTION_OPTION_DATA = 'No Story Solution options defined in the csv file or invalid data.';
    public static final String INFO_MSG_SUCCESSFULY_UPLOADED = 'Successfully done with uploading city data.';
    public static final String ERROR_MSG_FAILED_TO_UPLOAD_FILE = 'An error has occured. Please check the csv file data format and try again later.';
    public static final String ERROR_MSG_NO_STATIC_RESOURCE_AVAILABLE = 'No static resource found matching the provided file name.';
    public static String dateUploadMessage = 'Uploaded {0} cities with {1} quadrants and {2} blocks.';
    
    /**
     * Method to uplaod city data using the csv static resource file name as parameter. 
     * Method load the static resource content matching the static resource file name and process it for 
     * city data creation
     *
     * @param staticResourceCSVFileName String  - csv Static resource file name.
     * @return message string - message with could of uploaded city, quadrants and blocks
     */
    public static string updateCityDataUsingStaticResourceName(String staticResourceCSVFileName) {
    	 List<StaticResource> staticResourceList = [Select Id,Body from StaticResource where name =:staticResourceCSVFileName];
    	 if(staticResourceList.isEmpty()) throw new CityDataLoaderException(ERROR_MSG_NO_STATIC_RESOURCE_AVAILABLE);
         return uploadCityData(blobToString(staticResourceList.get(0).Body,'ISO-8859-1'));
    }
    
    /**
     * Method to uplaod city data using the csv file content passed as string. 
     * Method parses the string content and create cities, quadrants, blocks, stories and story solution options.
     *
     * @param staticResourceCSVFileName String  - csv Static resource file name.
     * @return message string - message with could of uploaded city, quadrants and blocks
     */
	public static string uploadCityData(String fileContentAsString) {
		String successMessage;
		Savepoint sp = Database.setSavepoint();
		try {
	        String[] filelines = fileContentAsString.split('\n');
	        //citiesToUpload = new List<CBGA_City__c>();
	        
	        Map<String, CBGA_City__c> cityByCityKeyMap = new Map<String, CBGA_City__c>();
	        
	        // Processing all cities with in the file.
	        for (Integer i=0;i<filelines.size();i++){
	            String[] inputvalues = filelines[i].split(',');
	            
	            // blank line. Continue to next line	
	            if(inputvalues.size() == 0) continue;
	            
	        	if(inputvalues[0].trim().equalsIgnoreCase(ROW_KEY_CITY)) {
	        		// Line: City, City Key, City Name, City URL
	        		// For Example: City, C1, Londan, Test_city01
	        		cityByCityKeyMap.put(inputvalues[1], CBGA_TestData.createCity(inputvalues[2], inputvalues[3]));
	        		
	        	}
	        }
	        // Throw exception if there is no city data entered in the csv file as per the format.
	        if(cityByCityKeyMap.isEmpty()) throw new CityDataLoaderException(ERROR_MSG_NO_CITY_DATA);
	        insert cityByCityKeyMap.values();
	        
	        //============== Processing Quadrant =======================
	        // Map with key as city + Quadrant Key (some unique value combination of city and Quadrant keys) and value as Quadrant record
	        Map<String, CBGA_Quadrant__c> quadrantsByUniqueKeyMap = new Map<String, CBGA_Quadrant__c>();
	        // Processing all quadrants with in the file.
	        for (Integer i=0;i<filelines.size();i++){
	            String[] inputvalues = filelines[i].split(',');
	            
	            // blank line. Continue to next line	
	            if(inputvalues.size() == 0) continue;
	            
	        	if(inputvalues[0].trim().equalsIgnoreCase(ROW_KEY_QUADRANT)) {
	        		// Line: Quadrant, City key, Quadrant key, Quadrant Name, Sequence
	        		// For Example: Quadrant, C1, Q1, Quadrant1 Londan, 0
	        		CBGA_City__c city = cityByCityKeyMap.get(inputvalues[1]);
	        		String key = inputvalues[1] +'-' + inputvalues[2];
	        		quadrantsByUniqueKeyMap.put(key, CBGA_TestData.createQuadrant(inputvalues[3], city.Id, Integer.valueOf(inputvalues[4].trim())) );
	        	}
	        }
	        // Throw exception if there is no quadrants data entered in the csv file as per the format.
	        if(quadrantsByUniqueKeyMap.isEmpty()) throw new CityDataLoaderException(ERROR_MSG_NO_QUADRANT_DATA);
	        insert quadrantsByUniqueKeyMap.values();
	        
	        //============== Processing Blocks =======================
	        // Map with key as city + Quadrant Key + block key (some unique value combination of city, Quadrant and block keys) and value as Block record
	        Map<String, CBGA_Block__c> blocksByUniqueKeyMap = new Map<String, CBGA_Block__c>();
	        // Processing all blocks with in the file.
	        for (Integer i=0;i<filelines.size();i++){
	            String[] inputvalues = filelines[i].split(',');
	            
	            // blank line. Continue to next line	
	            if(inputvalues.size() == 0) continue;
	            
	        	if(inputvalues[0].trim().equalsIgnoreCase(ROW_KEY_BLOCK)) {
	        		// Line: Block, City key, Quadrant key, Block key, Block Name, Sequence, Block Cost
	        		// For Example: Block, C1, Q1, B1, Block1 Quadrant1 Londan, 0, 5000.0
	        		CBGA_Quadrant__c quadrant = quadrantsByUniqueKeyMap.get(inputvalues[1] +'-' + inputvalues[2]);
	        		String blockKey = inputvalues[1] +'-' + inputvalues[2] +'-' + inputvalues[3];
	        		blocksByUniqueKeyMap.put(blockKey, CBGA_TestData.createBlock(inputvalues[4], quadrant.Id, Integer.valueOf(inputvalues[5].trim()), Decimal.valueOf(inputvalues[6].trim())) );
	        	}
	        }
	        // Throw exception if there is no blocks data entered in the csv file as per the format.
	        if(blocksByUniqueKeyMap.isEmpty()) throw new CityDataLoaderException(ERROR_MSG_NO_BLOCK_DATA);
	        insert blocksByUniqueKeyMap.values();
	        
	        //============== Processing Block Story =======================
	        // Map with key as city + Quadrant Key + block key + story key and value as story record
	        Map<String, CBGA_Story__c> storiesByUniqueKeyMap = new Map<String, CBGA_Story__c>();
	        // Processing all story with in the file.
	        for (Integer i=0;i<filelines.size();i++){
	            String[] inputvalues = filelines[i].split(',');
	            
	            // blank line. Continue to next line	
	            if(inputvalues.size() == 0) continue;
	            
	        	if(inputvalues[0].trim().equalsIgnoreCase(ROW_KEY_STORY)) {
	        		// Line: Story, City key, Quadrant key, Block Key, Story key, Story text
	        		// For Example: Story, C1, Q1, B1, S1, Some Story text
	        		CBGA_Block__c block = blocksByUniqueKeyMap.get(inputvalues[1] +'-' + inputvalues[2] +'-' + inputvalues[3]);
	        		String storyKey = inputvalues[1] +'-' + inputvalues[2] +'-' + inputvalues[3] +'-' + inputvalues[4];
	        		storiesByUniqueKeyMap.put(storyKey, CBGA_TestData.createStory(inputvalues[5], block.Id) );
	        	}
	        }
	        // Throw exception if there is no stories data entered in the csv file as per the format.
	        if(storiesByUniqueKeyMap.isEmpty()) throw new CityDataLoaderException(ERROR_MSG_NO_STORY_DATA);
	        insert storiesByUniqueKeyMap.values();
	        
	        //============== Processing Story solution options  ===============
	        // List of all Solution options 
	        List<CBGA_Solution_Option__c> storySolutionOptionList = new List<CBGA_Solution_Option__c>();
	        // Processing all story solution options with in the file.
	        for (Integer i=0;i<filelines.size();i++){
	            String[] inputvalues = filelines[i].split(',');
	            
	            // blank line. Continue to next line	
	            if(inputvalues.size() == 0) continue;
	            
	        	if(inputvalues[0].trim().equalsIgnoreCase(ROW_KEY_STORY_OPTION)) {
	        		// Line: Option, City key, Quadrant key, Block Key, Story key, score, reward, solution text, sequence
	        		// For Example: Option, C1, Q1, B1, S1, Best/Ok/Bad, 2000.0, Some solution text, 1
	        		CBGA_Story__c story = storiesByUniqueKeyMap.get(inputvalues[1] +'-' + inputvalues[2] +'-' + inputvalues[3] +'-' + inputvalues[4]);
	        		CBGA_Solution_Option__c option = CBGA_TestData.createSolutionOptions(inputvalues[7],inputvalues[8],
	        		     story.Id, Decimal.valueOf(inputvalues[6].trim()), inputvalues[5],Integer.valueOf(inputvalues[9].trim()));
	        		     storySolutionOptionList.add(option);
	        	}
	        }
	        // Throw exception if there is no stories data entered in the csv file as per the format.
	        if(storySolutionOptionList.isEmpty()) throw new CityDataLoaderException(ERROR_MSG_NO_STORY_SOLUTION_OPTION_DATA);
	        insert storySolutionOptionList;
	        
	        // formating the message to include the created record counts to show on UI.
	        successMessage = String.format(dateUploadMessage, new String[]{''+cityByCityKeyMap.Size(), ''+ quadrantsByUniqueKeyMap.size(), ''+ blocksByUniqueKeyMap.size()});
		
		} catch(Exception e) {
			// roll back is any exception while parsing csv file.
			Database.rollback(sp);
			throw e;
		}
		// returning the message with inserted record counts.
		return successMessage;
	}
	
	/**
     * This function convers the input CSV file in BLOB format into a string
     * @param input    Blob data representing correct string in @inCharset encoding
     * @param inCharset    encoding of the Blob data (for example 'ISO 8859-1')
     *
     */
    public static String blobToString(Blob input, String inCharset){
        String hex = EncodingUtil.convertToHex(input);
        System.assertEquals(0, hex.length() & 1);
        final Integer bytesCount = hex.length() >> 1;
        String[] bytes = new String[bytesCount];
        for(Integer i = 0; i < bytesCount; ++i)
            bytes[i] =  hex.mid(i << 1, 2);
        return EncodingUtil.urlDecode('%' + String.join(bytes, '%'), inCharset);
    }
	
	// Custom exception for City Data Loader 
	public class CityDataLoaderException extends Exception { }

}