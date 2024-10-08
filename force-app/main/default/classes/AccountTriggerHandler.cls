public with sharing class AccountTriggerHandler extends TriggerHandler {

    AccountHelper newAccountHelper = new AccountHelper((List<Account>) Trigger.new);

    public override void beforeInsert() { 
        
        newAccountHelper.setTypeProspect();

        newAccountHelper.addressCopy();
        
        newAccountHelper.setRating();

    }

    public override void afterInsert(){
    
        newAccountHelper.defaultContact();
    
    }
}