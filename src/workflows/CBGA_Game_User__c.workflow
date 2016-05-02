<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Generate_User_Title_for_the_Game_User</fullName>
        <field>CB_Title__c</field>
        <formula>IF(CB_Budget__c &gt;= 100000,&quot;Overlord Architect&quot;,
   IF(CB_Budget__c &gt; 90000,&quot;Black belt Architect&quot;,
     IF(CB_Budget__c &gt; 80000,&quot;Competent Architect&quot;,
       IF(CB_Budget__c &gt; 70000,&quot;Junior Architect&quot;,
         IF(CB_Budget__c &gt; 60000,&quot;Structural Engineer&quot;,
           IF(CB_Budget__c &gt; 55000,&quot;Town Planner&quot;,
              &quot;City Janitor&quot;
            )
          )
        )
      )
    )
  )</formula>
        <name>Generate User Title for the Game User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Compute User Title Based on Avaliable Budget</fullName>
        <actions>
            <name>Generate_User_Title_for_the_Game_User</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND (2 OR 3)</booleanFilter>
        <criteriaItems>
            <field>CBGA_Game_User__c.CB_User__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>CBGA_Game_User__c.CB_Streak__c</field>
            <operation>greaterOrEqual</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>CBGA_Game_User__c.CB_Streak__c</field>
            <operation>lessOrEqual</operation>
            <value>-2</value>
        </criteriaItems>
        <description>The Title of the Game User is based on the Budget in hand. The workflow computes and updates the Title based on Budget Availablity</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
