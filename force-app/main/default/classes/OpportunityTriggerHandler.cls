public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    OpportunityHelper newOpportunityHelper = new OpportunityHelper((List<Opportunity>) Trigger.new);

    public override void beforeUpdate(){
        newOpportunityHelper.assignPrimaryContact();
    }

    public override void afterUpdate(){        
    }

    
}