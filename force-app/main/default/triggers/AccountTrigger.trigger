trigger AccountTrigger on Account (before insert, after insert){
    List<Contact> defaultContacts = new List<Contact>();
    if(Trigger.isBefore == true){
        for(Account a : Trigger.new){
            //Lists of Billing and Shipping Fields
            List<String> fieldList = new List<String>{'Street','City', 'State','PostalCode', 'Country'};
            
        
            //If Type is null or empty assign 'Prospect'
            if(a.Type == null){
                a.Type = 'Prospect';
            }

            //For each account, copy the shipping fields to the billing fields, unless the field is null or empty
            for(String field : fieldList){
                if(a.get('Shipping' + field) != null){
                    // Use the set method correctly
                    a.put('Billing' + field, a.get('Shipping' + field));
                }
            }

            //Set rating to 'Hot' if phone, website, and fax all have a value. 
            if(a.get('Rating') != 'Hot'){
                if(a.get('Phone') != null && a.get('Website') != null && a.get('Fax') != null){
                    a.put('Rating','Hot');
                }
            }
        }
    }
    //Default contact
    if(Trigger.isAfter == true){
        for(Account a : Trigger.new){
            Contact newCon = new Contact(LastName = 'DefaultContact', Email = 'default@email.com', AccountId = a.Id);
            defaultContacts.add(newCon);
        }     
        if(defaultContacts.size() > 0){
            insert defaultContacts;
        }
    }
}