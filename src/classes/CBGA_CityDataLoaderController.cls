/**
 * Controller class holding logic to support uploading of csv file from VF page.
 */
public with sharing class CBGA_CityDataLoaderController {
    
    public string nameFile{get;set;}
    public Blob contentFile{get;set;}
    
    /**
     * Method to read csv file uploaded by user.
     */
    public Pagereference readCSVFile(){
    	String[] filelines = new String[]{};
    	
    	//string nameFile = contentFile.toString();
    	nameFile = CBGA_CityDataLoaderUtils.blobToString(contentFile,'ISO-8859-1');
        
        try{ 
        	String message = CBGA_CityDataLoaderUtils.uploadCityData(nameFile);
        	ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.INFO,CBGA_CityDataLoaderUtils.INFO_MSG_SUCCESSFULY_UPLOADED + message));
        }
        catch (Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,CBGA_CityDataLoaderUtils.ERROR_MSG_FAILED_TO_UPLOAD_FILE + e.getMessage()));
        }    
        return null;
    }
}