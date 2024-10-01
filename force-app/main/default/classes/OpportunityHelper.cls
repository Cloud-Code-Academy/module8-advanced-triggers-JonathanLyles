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
        System.debug('triggerList: ' + triggerList);
        System.debug('this.triggerList: ' + this.triggerList);
        for(Opportunity opp : triggerList){
            triggerListAccountIds.add(opp.AccountId);
        }

        this.triggerList = [SELECT Id, Primary_Contact__c, AccountId FROM Opportunity WHERE AccountId IN :triggerListAccountIds];
        System.debug(this.)
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
        
        for(Opportunity opp: triggerList){
            System.debug('Opp Id' + opp.Id);
            System.debug('Account Id' + opp.AccountId);
            System.debug('Primary_Contact__c' + opp.Primary_Contact__c);
        }
        
    }

    public void setDefaultOpportunityType(){
        // Set default Type for new Opportunities
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
            if( accIdIndustryMap.get(opp.AccountId) == 'Banking' && opp.StageName == 'Closed Won'){
                opp.addError('Cannot delete closed opportunity');
            }
        }
    }

    // Create a new Task for newly inserted Opportunities
    public void insertTask(){
        System.debug('********** Insert Task *************');
        List<Task> tasksToInsert = new List<Task>();
        for (Opportunity opp : triggerList){
            Task tsk = new Task();
            tsk.Subject = 'Call Primary Contact';
            tsk.WhatId = opp.Id;
            tsk.WhoId = opp.Primary_Contact__c;
            tsk.OwnerId = opp.OwnerId;
            tsk.ActivityDate = Date.today().addDays(3);
            tasksToInsert.add(tsk);
        }
        System.debug('Line 95');
        insert tasksToInsert;
        System.debug('Line 97');
    }

    /*
    * setPrimaryContact()
    * Before Update
    * When an opportunity is updated set the primary contact on the opportunity to the contact with the title of 'CEO'.
    */
    public void setPrimaryContact(){
        System.debug('++++ setPrimaryContact ++++');
        List<Id> accountIds = new List<Id>();
        
        for(Opportunity opp : triggerList){
            accountIds.add(opp.AccountId);
        }

        List<Contact> ceoList = [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountIds AND Title = 'CEO'];

        Map<Id, Id> accIdConIdMap = new Map<Id, Id>();

        for(Contact con : ceoList){
            accIdConIdMap.put(con.AccountId,con.Id);
        }

        for(Opportunity opp : triggerList){
            opp.Primary_Contact__c = accIdConIdMap.get(opp.AccountId);
        }
    }

    /*
    * amountValidation()
    * When an opportunity is updated validate that the amount is greater than 5000.
    * 
    */
    public void amountValidation(){
        for(Opportunity opp : triggerList){
            if(opp.Amount <= 5000){
                opp.addError('Opportunity amount must be greater than 5000');
            }
        }
    }

    /*
    * updateDescriptionFromStage()
    * When an opportunity is updated, the stage name is written in the description
    */
    public void updateDescriptionFromStage(){
        for(Opportunity opp : triggerList){
            opp.Description = 'Stage Change:' + opp.StageName;            
        }
    }

    /*
    * notifyOwnersOpportunityDeleted()
    * Sends an email notification to the owner of the Opportunity when it gets deleted.
    * Uses Salesforce's Messaging.SingleEmailMessage to send the email.
    */
    public void notifyOwnersOpportunityDeleted() {
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        for (Opportunity opp : triggerList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {[SELECT Id, Email FROM User WHERE Id = :opp.OwnerId].Email};
            mail.setToAddresses(toAddresses);
            mail.setSubject('Opportunity Deleted : ' + opp.Name);
            mail.setPlainTextBody('Your Opportunity: ' + opp.Name +' has been deleted.');
            mails.add(mail);
        }        
        
        try {
            Messaging.sendEmail(mails);
        } catch (Exception e){
            System.debug('Exception: ' + e.getMessage());
        }
    }

    public void validateCloseOpportunity(){
        for(Opportunity opp : triggerList){
            if(opp.StageName.contains('Closed')){
                opp.AddError('Cannot delete closed opportunity');
            }
        }
    }
}