/*
AccountHelper Overview

The `AccountHelper` class is designed to provide helper methods that assist in performing specific operations on Account records. 
This class is intended to modularize the logic used in the `AccountTrigger` to ensure separation of concerns, improve readability, and ease maintenance. 

This class is currently stubbed out. As part of this exercise, you are expected to:
1. Implement the method bodies to carry out the specified operations on Account records.
2. Refactor the `AccountTrigger` to utilize the methods provided in this `AccountHelper` class.

Methods:
- `setTypeProspect(SObject objects)`: 
    - Purpose: Update the 'Type' field of the given Account record to 'Prospect' if it's not already set.
    - Note: You'll likely need to adjust the method signature to accept the necessary parameters.

- `addressCopy()`: 
    - Purpose: Copy the shipping address of the Account to its billing address. 
    - Note: You'll likely need to adjust the method signature to accept the necessary parameters.

- `setRating`: 
    - Purpose: Evaluate certain conditions on the Account and assign a rating based on that evaluation. You'll need to define the method's signature and implement its logic.

- `defaultContact`: 
    - Purpose: Create a default contact related to the Account after the Account is inserted. You'll need to define the method's signature and implement its logic.

Remember:
Always ensure that your helper methods are bulk-safe to handle multiple records efficiently. 
*/
public with sharing class AccountHelper {

    List<Contact> defaultContacts = new List<Contact>();

    List<Account> triggerList = new List<Account>();

    public AccountHelper(List<Account> triggerList){
        this.triggerList = triggerList;
    }
    
    public void setTypeProspect(){
        for(Account acc : this.triggerList){
            //If Type is null or empty assign 'Prospect'
            if(acc.Type == null){
                acc.Type = 'Prospect';
            }
        }
    }

    public void addressCopy(){

        //Lists of Billing and Shipping Fields
        List<String> fieldList = new List<String>{'Street','City', 'State','PostalCode', 'Country'};
        for(Account a : this.triggerList){
            for(String field : fieldList){
                if(a.get('Shipping' + field) != null){
                    // Use the set method correctly
                    a.put('Billing' + field, a.get('Shipping' + field));
                }
            }
        }
    }
        
    public void setRating () {

        for(Account a : this.triggerList){
            if(a.get('Rating') != 'Hot'){
                if(a.get('Phone') != null && a.get('Website') != null && a.get('Fax') != null){
                    a.put('Rating','Hot');
                }
            }
        }
    }

    public void defaultContact () {
        
        for(Account a : this.triggerList){
            Contact newCon = new Contact(LastName = 'DefaultContact', Email = 'default@email.com', AccountId = a.Id);
            defaultContacts.add(newCon);
        }     
        if(defaultContacts.size() > 0){
            insert defaultContacts;
        }    
    }
}