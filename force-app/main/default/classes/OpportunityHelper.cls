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

        //For undelete you need to explicitly call the records to be updated as the records from Trigger.new are read-only
        List<Id> triggerListAccountIds = new List<Id>();
        for(Opportunity opp : triggerList){
            triggerListAccountIds.add(opp.AccountId);
        }

        this.triggerList = [SELECT Id, Primary_Contact__c, AccountId FROM Opportunity WHERE AccountId IN :triggerListAccountIds];
        
        List<Opportunity> opportunitiesToUpdateList = new List<Opportunity>();
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

        for(Opportunity opp : opportunitiesWithoutPrimaryContactToAccountIdMap.keySet()){
            opp.Primary_Contact__c = accIdConIdMap.get(opp.AccountId);
        }
        update triggerList;
    }

    public void setDefaultOpportunityType(){
        // Set default Type for new Opportunities
        System.debug('++++++ setOpportunityType ++++++');
        for(Opportunity opp : triggerList){
            if (opp.Type == null){
                opp.Type = 'New Customer';
            }
        }
    }

    /*
    * deleteCloseWonOpportunity()
    * When an opportunity is deleted prevent the deletion of a closed won opportunity if the account industry is 'Banking'.
    * Trigger should only fire on delete.
    */
    public void deleteCloseWonOpportunity(){
        List<Id> accIds = new List<Id>();
        for(Opportunity opp : triggerList){
            accIds.add(opp.AccountId);
        }
        List<Account> relatedAccounts = [SELECT Id, Industry FROM Account WHERE Id IN :accIds];

        Map<Id, String> accIdIndustryMap = new Map<Id, String>();

        for(Account acc : relatedAccounts){
            accIdIndustryMap.put(acc.Id, acc.Industry);
        }
        
        for(Opportunity opp : triggerList){
            System.debug(triggerList);
            if( accIdIndustryMap.get(opp.AccountId) == 'Banking' && opp.StageName == 'Closed Won'){
                opp.addError('Cannot delete closed opportunity');
            }
        }
    }

}