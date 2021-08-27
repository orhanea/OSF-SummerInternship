/*
* **OSF Summer Internship**** 
* *****Second Exercise********
* @author Orhan Emre Anıl
* @date Aug 24, 2021
* @name updatePhone
* @description a batch class for updating the primary contact phone
*/

public class updatePhone implements Database.Batchable<SObject>, Database.Stateful {

    public Contact primaryContact;
    public Integer progressed = 0; // Test.
    private ID accountID; // Account to be updated.
    List<Contact> primaryContacts = new List<Contact>();

    /*
    * @author Orhan Emre Anıl
    * @date Aug 24 , 2021
    * @name updatePhone
    * @description constructor.
    */
    public updatePhone(ID accountID) {
        try{
            this.accountID = accountID;
            primaryContacts = [SELECT ID, Phone, AccountID
                               FROM Contact
                               WHERE AccountID = :accountID AND Is_Primary_Contact__c = true
                               LIMIT 1];
            if (primaryContacts != null && primaryContacts.size() > 0) {
               this.PrimaryContact = primaryContacts[0];
            }                          
        } catch(Exception e) {
            System.debug('Warning. There is an exception: ' + e.getMessage()); 
        }
    }

    /*
    * @author Orhan Emre Anıl
    * @date Aug 24 , 2021
    * @name start
    * @description collect batches of records or objects to passed to the method execute.
    */
    public Database.QueryLocator start(Database.BatchableContext batchable) {
       try {
			return Database.getQueryLocator('SELECT ID FROM Contact' + 'Where AccountId = \'' 
                                            + PrimaryContact.AccountId + '\' and Id != \'' + PrimaryContact.ID + '\'');
		} catch(Exception e) {
			System.debug('Warning. There is an exception: ' + e.getMessage());
            return null;
		}        
    }

    /*
    * @author Orhan Emre Anıl
    * @date Aug 24 , 2021
    * @name execute
    * @description perform the processing for each batch of specified data.
    */
    public void execute(Database.BatchableContext batchable, List<Contact> scope) {
        try {
			for (Contact focusedContacts : scope) {
				focusedContacts.Primary_Contact_Phone__c = PrimaryContact.Phone;
			}
			update scope;
		} catch(Exception e) {
			System.debug('Warning. There is an exception: ' + e.getMessage());
		}
    }

    /*
    * @author Orhan Emre Anıl
    * @date Aug 24 , 2021
    * @name finish
    * @description execute any post-processing operations.
    */
    public void finish(Database.BatchableContext batchable) {
        System.debug(progressed + 'record(s) are progressed successfully.');  
	}  

}
