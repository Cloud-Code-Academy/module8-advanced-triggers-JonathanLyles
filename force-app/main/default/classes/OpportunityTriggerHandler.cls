public with sharing class OpportunityTriggerHandler extends TriggerHandler {
     
    public override void beforeInsert(){
        OpportunityHelper newOpportunityHelper = new OpportunityHelper((List<Opportunity>) Trigger.new);
        newOpportunityHelper.setDefaultOpportunityType();
    }

    public override void beforeDelete(){
        OpportunityHelper newOpportunityHelper = new OpportunityHelper((List<Opportunity>) Trigger.old);
        newOpportunityHelper.deleteCloseWonOpportunity();
    }
    
    public override void afterUndelete(){
        OpportunityHelper newOpportunityHelper = new OpportunityHelper((List<Opportunity>) Trigger.new);
        newOpportunityHelper.assignPrimaryContact();
    }  

}