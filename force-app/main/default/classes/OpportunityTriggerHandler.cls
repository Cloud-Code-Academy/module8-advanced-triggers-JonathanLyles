public with sharing class OpportunityTriggerHandler extends TriggerHandler {
     
    public override void beforeInsert(){
        OpportunityHelper newOpportunityHelper = new OpportunityHelper((List<Opportunity>) Trigger.new);
        newOpportunityHelper.setDefaultOpportunityType();
    }
    public override void afterInsert(){
        OpportunityHelper newOpportunityHelper = new OpportunityHelper((List<Opportunity>) Trigger.new);
        newOpportunityHelper.insertTask();
    }

    public override void beforeUpdate(){
        OpportunityHelper newOpportunityHelper = new OpportunityHelper((List<Opportunity>) Trigger.new);
        newOpportunityHelper.setPrimaryContact();
        newOpportunityHelper.amountValidation();
        newOpportunityHelper.updateDescriptionFromStage();

    }

    public override void beforeDelete(){
        OpportunityHelper newOpportunityHelper = new OpportunityHelper((List<Opportunity>) Trigger.old);
        newOpportunityHelper.deleteCloseWonOpportunity();
        newOpportunityHelper.validateCloseOpportunity();
    }
    
    public override void afterUndelete(){
        OpportunityHelper newOpportunityHelper = new OpportunityHelper((List<Opportunity>) Trigger.new);
        newOpportunityHelper.assignPrimaryContact();
    } 

    public override void afterDelete(){
        OpportunityHelper newOpportunityHelper = new OpportunityHelper((List<Opportunity>) Trigger.old);
        newOpportunityHelper.notifyOwnersOpportunityDeleted();
    }

}