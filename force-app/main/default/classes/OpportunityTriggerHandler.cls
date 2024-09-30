public with sharing class OpportunityTriggerHandler extends TriggerHandler {
     
    OpportunityHelper newOpportunityHelper = new OpportunityHelper((List<Opportunity>) Trigger.new);
    
    public override void afterUndelete(){
        newOpportunityHelper.assignPrimaryContact();
    }  
}