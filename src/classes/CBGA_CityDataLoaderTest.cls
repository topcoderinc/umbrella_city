/**
 * This class contains unit tests for validating the behavior of CBGA_CityDataLoaderUtils 
 * and CB_CityDataLoaderController Apex classes
 */
@isTest
private class CBGA_CityDataLoaderTest {
	final static String CSV_FILE_NAME = 'Sample_City_CSV_Data_File';
	
	static string getCSVContentAsString() {
		String csvAsStringForCity = 'City,LON,Londan,Test_city01\n'+
						'Quadrant,LON,Q2,Quadrant2 Londan,1\n'+
						'Block,LON,Q2,B1,Block1 Quadrant1 Londan,1,3500.0\n'+
						'Story,LON,Q2,B1,S1,This is Londan city sample test story\n'+
						'Option,LON,Q2,B1,S1,Best,5000.0, Best Solution,Best Description,2\n'+
						'Option,LON,Q2,B1,S1,Ok,0.0,Its Ok,Ok Description,1\n'+
						'Option,LON,Q2,B1,S1,Bad,1500.0,Its too Bad,Bad Description,3\n';
		return csvAsStringForCity;				
	}
	
	/**
	 * Test method for CB_CityDataLoaderController readCSVFile method
	 */
	static testMethod void readCSVFileTest() {
    	
    	List<CBGA_City__c> cityList = [Select Id, Name from CBGA_City__c];
    	system.assert(cityList.isEmpty());
    	
    	Test.startTest();
    	
    	CBGA_CityDataLoaderController controller = new CBGA_CityDataLoaderController();
    	controller.contentFile = Blob.valueOf(getCSVContentAsString());
    	
    	controller.readCSVFile();
    	
    	List<Apexpages.Message> msgs = ApexPages.getMessages();
    	system.assert(!msgs.isEmpty());
    	// checking for success message.
    	system.assert(msgs.get(0).getDetail().contains(CBGA_CityDataLoaderUtils.INFO_MSG_SUCCESSFULY_UPLOADED));
    	
    	cityList = [Select Id, Name from CBGA_City__c];
    	system.assert(!cityList.isEmpty());
    	system.assertEquals(1, cityList.size());
    	
    	Test.stopTest();
    }
    
    /**
     * test method negative case: No blocks to create in csv content.
     */
    static testMethod void readCSVFileNegativeTest() {
    	// csv string with no block records to create.
    	String csvAsStringForCity = 'City,LON,Londan,Test_city01\n'+
						'Quadrant,LON,Q2,Quadrant2 Londan,1\n';
						
    	
    	List<CBGA_City__c> cityList = [Select Id, Name from CBGA_City__c];
    	system.assert(cityList.isEmpty());
    	
    	Test.startTest();
    	
    	CBGA_CityDataLoaderController controller = new CBGA_CityDataLoaderController();
    	controller.contentFile = Blob.valueOf(csvAsStringForCity);
    	
    	controller.readCSVFile();
    	
    	List<Apexpages.Message> msgs = ApexPages.getMessages();
    	system.assert(!msgs.isEmpty());
    	// checking for error message.
    	system.assert(msgs.get(0).getDetail().contains(CBGA_CityDataLoaderUtils.ERROR_MSG_FAILED_TO_UPLOAD_FILE));
    	
    	cityList = [Select Id, Name from CBGA_City__c];
    	system.assert(cityList.isEmpty());
    	
    	Test.stopTest();
    }
	
	/**
	*
	*/
	static testMethod void testLoadingStaticResource(){
		try {
		  CBGA_CityDataLoaderUtils.updateCityDataUsingStaticResourceName('XXSSSXXSDFSDFDSFDFDSF');
		}
		catch(Exception ex){
		    System.assertEquals('CBGA_CityDataLoaderUtils.CityDataLoaderException',ex.getTypeName());
		}		
	}
	
	/**
	 * Test method for CBGA_CityDataLoaderUtils uploadCityData method
	 */
    static testMethod void uploadCityDataTest() {
    	
    	List<CBGA_City__c> cityList = [Select Id, Name from CBGA_City__c];
    	system.assert(cityList.isEmpty());
    	
    	List<CBGA_Quadrant__c> quadrantList = [Select Id, Name from CBGA_Quadrant__c];
    	system.assert(quadrantList.isEmpty());
    	
    	List<CBGA_Block__c> blockList = [Select Id, Name from CBGA_Block__c];
    	system.assert(blockList.isEmpty());
    	
    	List<CBGA_Solution_Option__c> optionList = [Select Id, Name from CBGA_Solution_Option__c];
    	system.assert(optionList.isEmpty());
    	
    	Test.startTest();
    	
    	//CBGA_CityDataLoaderUtils.updateCityDataUsingStaticResourceName(CSV_FILE_NAME);
    	String csvAsStringForCity = getCSVContentAsString();
    	CBGA_CityDataLoaderUtils.uploadCityData(csvAsStringForCity);
    	
    	cityList = [Select Id, Name from CBGA_City__c];
    	system.assert(!cityList.isEmpty());
    	system.assertEquals(1, cityList.size());
    	
    	quadrantList = [Select Id, Name from CBGA_Quadrant__c];
    	system.assert(!quadrantList.isEmpty());
    	system.assertEquals(1, quadrantList.size());
    	
    	blockList = [Select Id, Name from CBGA_Block__c];
    	system.assert(!blockList.isEmpty());
    	system.assertEquals(1, blockList.size());
    	
    	optionList = [Select Id, Name from CBGA_Solution_Option__c];
    	system.assert(!optionList.isEmpty());
    	system.assertEquals(3, optionList.size());
    	
    	Test.stopTest();
    }
}