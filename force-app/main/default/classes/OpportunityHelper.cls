public with sharing class OpportunityHelper {

    List<Opportunity> triggerList = new List<Opportunity>();

    public OpportunityHelper(List<Opportunity> triggerList){
        this.triggerList = triggerList;
    }
     
    /*
    - assignPrimaryContact:
    - Assigns a primary contact with the title of 'VP Sales' to undeleted Opportunities.
    - Only updates the Opportunities that don't already have a primary contact.
    */

    public void assignPrimaryContact(List<Opportunity> oppNewList){

        //Map of OpportunityId to Opportunity object, for Opportunities that do not have a Primary_Contact__c
        Map<Id, Opportunity> oppIdOppMap = new Map<Id, Opportunity>();

        //Map of OpportunityId to AccountId, for Opportunities that do not have a Primary_Contact__c
        Map<Id, Id> oppIdAccIdMap = new Map<Id, Id>();

        //Map of AccountId (values of oppIdAccIdMap) to ContactId
        Map<Id, Id> accIdConIdMap = new Map<Id, Id>();

        //Final list to update
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        //Build oppIdAccIdMap & oppIdOppMap
        for(Opportunity opp : oppNewList){
            if(opp.isSet(opp.Primary_Contact__c) == false){
                oppIdAccIdMap.put(opp.Id, opp.AccountId);
                oppIdOppMap.put(opp.Id, opp);
            }
        }

        //Build accIdConIdMap
        for(Contact con : [SELECT Id, AccountId FROM CONTACT WHERE Title = 'VP Sales' AND AccountId in :oppIdAccIdMap.values()]){
            accIdConIdMap.put(con.AccountId, con.Id);
        }

        //Assign Contacts to Opportunities
        for(Opportunity opp : oppIdOppMap.values()){
            //Access ContactId via AccountId which we can access via OpportunityId
            //Step 1: Get AccountId
            Id accId = opp.AccountId;
            //Step 2: Get and assign ContactId, but verify it is not null first
            System.Debug('***********' + accIdConIdMap.containsKey(accId) + '***********');
            if(accIdConIdMap.containsKey(accId)){
                Id conId = accIdConIdMap.get(accId);
                opp.Primary_Contact__c = conId;
            }
        } 
    }     



}