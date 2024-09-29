public with sharing class OpportunityTriggerHandler extends TriggerHandler {

    
    
    OpportunityHelper newOpportunityHelper = new OpportunityHelper((List<Opportunity>) Trigger.new);
    

    

    public override void beforeInsert() {        
        newOpportunityHelper.assignPrimaryContact((List<Opportunity>)Trigger.new);
        System.debug('this is a test');
    }

    public override void afterInsert(){
    
       
    
    }

}