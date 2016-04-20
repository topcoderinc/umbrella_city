# Umbrella City Builder


## Overview

**Umbrella City Builder**, is a super cool city builder game running on *Salesforce*.

### City Apex Data Loader
**City Apex Data Loader**, is a utility with set of apex classes and VF page to pull the data from a static resource (csv file) or can be uploaded manually using VF page to upload citie(s) and all related data (Quadrants, Block, Story and Story Solution Options)


#### How it work?

City apex data loader can be used to upload data using following two approach.

* __Using City Data Loader VF Page__: One can manually upload a csv file using the __City Data Loader__ VF page.  You can access this page either using the __City Data Loader__ tab or can access directly by adding following url to your saleforce base url as postfix.

	_https://{your salesfoce org base url}/apex/CB_CityDataLoader_

* __Using csv file as static resource__: The other option is to use a csv static resource file to upload the data. Execute following code from anonymous apex window. Pass the name of the csv static resource file as argument.

		CB_CityDataLoaderUtils.updateCityDataUsingStaticResourceName('CityDataSampleCSVFile');

#### CSV file format
Following will the format of the csv file used to upload the city data using either of the above approach.

##### Syntax
**City Row:**
City,{city_unique_key},{city_name},{city_image_URL}

**Quadrant Row:**
Quadrant,{city_unique_key},{quadrant_unique_key},{quadrant_name},{quadrant_sequence}

**Block Row:**
Block,{city_unique_key},{quadrant_unique_key},{block_unique_key},{block_name},{block_sequence},{block_cost}

**Story Row:**
Story,{city_unique_key},{quadrant_unique_key},{block_unique_key},{story_unique_key},{story_text}

**Story Solution Option Row:**
Option,{city_unique_key},{quadrant_unique_key},{block_unique_key},{story_unique_key},{score},{Reward_amount},{solution_text},{solution_sequence}

Example

````
City,LON,Londan,Test_city01
Quadrant,LON,Q1,Quadrant1 Londan,0
Block,LON,Q1,B1,Block1 Quadrant1 Londan,0,3000.0
Story,LON,Q1,B1,S1,This is Londan city sample test story
Option,LON,Q1,B1,S1,Best,5000.0, Best Solution,1
Option,LON,Q1,B1,S1,Ok,0.0,Its Ok,3
Option,LON,Q1,B1,S1,Bad,1000.0,Its very Bad,2
````

You can use the above example scripts to add multiple entries in your csv file.


#### Apex Code
Following are the related files added for city apex data loader:

###### Visualforce Page
* __CB_CityDataLoader.page__: VF page for supporting manual uploading of csv file for uploading city data.

###### Apex Class:
* __CB_CityDataLoaderController.cls__: Controller class holding logic to support uploading of csv file from VF page.
* __CB_CityDataLoaderUtils.cls__: Utility class holding logic for process uploaded csv file content and creating cities, quadrants, blocks, stories and story solution options.
* __CB_CityDataLoaderTest.cls__: This class contains unit tests for validating the behavior of CB_CityDataLoaderUtils and CB_CityDataLoaderController Apex classes

###### Static Resource:
* __CityDataSampleCSVFile.resource__: Sample static resource file for uploading city data.

#### Unmanage Package

Use the following URL to install unmanage package with latest code and city apex data loader utility.

<https://login.salesforce.com/packaging/installPackage.apexp?p0=04t36000000WSRt>

#### Jing Video
* Functional walk through:
<http://screencast.com/t/xHEMrV8n>

* Code walk through: <http://screencast.com/t/zacGTPgX>
