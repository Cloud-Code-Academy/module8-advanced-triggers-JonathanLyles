/*
AccountTrigger Overview

This trigger performs several operations on the Account object during its insertion. Depending on the values and conditions of the newly created Account, this trigger can:

1. Set the account's type to 'Prospect' if it's not already set.
2. Copy the shipping address of the account to its billing address.
3. Assign a rating of 'Hot' to the account if it has Phone, Website, and Fax filled.
4. Create a default contact related to the account after it's inserted.

Usage Instructions:
For this lesson, students have two options:
1. Use the provided `AccountTrigger` class as is.
2. Use the `AccountTrigger` from you created in previous lessons. If opting for this, students should:
    a. Copy over the code from the previous lesson's `AccountTrigger` into this file.
    b. Save and deploy the updated file into their Salesforce org.
*/
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