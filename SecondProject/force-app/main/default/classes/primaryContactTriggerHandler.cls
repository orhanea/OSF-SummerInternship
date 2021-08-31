/*
* @author Orhan Emre Anıl
* @date Aug 24, 2021
* @name primaryContactTriggerHandler 
* @description a handler for primaryContactTrigger 
*/

public with sharing class primaryContactTriggerHandler {

    Integer primaryCounter; 

    /*
    * @author Orhan Emre Anıl
    * @date Aug 24, 2021
    * @name onBeforeInsert 
    * @description executes before the insert-update logic
    */
    public void onBeforeInsert(List<Contact> newContacts) { 
        for (Contact contacts : newContacts) {
            if (contacts.Is_Primary_Contact__c) {
                try {
                    primaryCounter = [SELECT COUNT()
                                      FROM Contact
                                      WHERE AccountId =: contacts.AccountId
                                      AND ID != :contacts.ID
                                      AND Is_Primary_Contact__c = TRUE
                                      LIMIT 1];
                    if (primaryCounter > 0) {
                         contacts.addError('There is a primary contact that already exist.');
                    }                     
                } catch(Exception e) {
                    System.debug('Warning. There is an exception.' + e.getMessage());
                }
            }
        }
    }
     
    /*
    * @author Orhan Emre Anıl
    * @date Aug 24, 2021
    * @name onAfterInsert
    * @description executes after the insert logic
    */
    public void onAfterInsert(List<Contact> newContacts) {
        try {
            for (Contact contacts : newContacts) {
                if (contacts.Is_Primary_Contact__c) {
                    Database.executeBatch (new updatePhone(contacts.AccountId));   
                }    
            }        
        } catch(Exception e) {
            System.debug('Warning. There is an exception.' + e.getMessage());
        }
    }
    
    /*
    * @author Orhan Emre Anıl
    * @date Aug 24, 2021
    * @name onAfterUpdate
    * @description executes after the update logic
    */
    public void onAfterUpdate(List<Contact> newContacts, List<Contact> oldContacts) { 
        try {
            for (Integer i=0; i<newContacts.size(); i++) {
                Contact newContact = newContacts[i];
                Contact oldContact = oldContacts[i];
                
                if( newContact.Is_Primary_Contact__c && !oldContact.Is_Primary_Contact__c ) {
                    Database.executeBatch(new updatePhone(newContact.AccountId));
                }
            }
        } catch(Exception e) {
            System.debug('Warning. There is an exception.' + e.getMessage());
        }
    }
}
