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

    public void assignPrimaryContact(){
        Map<Opportunity, Id> opportunitiesWithoutPrimaryContactToAccountIdMap = new Map<Opportunity, Id>();
        
        for(Opportunity opp : triggerList){
            if(opp.Primary_Contact__c == null){
                opportunitiesWithoutPrimaryContactToAccountIdMap.put(opp, opp.AccountId);
            }
        }
        
        List<Contact> vpSalesContactList = [SELECT Id, Name, Title, AccountId FROM CONTACT WHERE Title = 'VP Sales' AND AccountId IN :opportunitiesWithoutPrimaryContactToAccountIdMap.values()];

        
        Map<Id, Id> accIdConIdMap = new Map<Id, Id>();

        for(Contact con : vpSalesContactList){
            accIdConIdMap.put(con.AccountId, con.Id);
        }

        List<Opportunity> opportunitiesToUpdateList = new List<Opportunity>();

        for(Opportunity opp : opportunitiesWithoutPrimaryContactToAccountIdMap.keySet()){
            opp.Primary_Contact__c = accIdConIdMap.get(opp.AccountId);
            System.debug('Hi');
        }
        
    }



}