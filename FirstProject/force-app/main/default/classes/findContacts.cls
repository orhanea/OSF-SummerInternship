/*
* **OSF Summer Internship**** 
* *****First Exercise********
* @author Orhan Emre Anıl
* @date Aug 21, 2021
* @name findContacts
* @description extension for the AccountWithContacts visualforce page
*/
public with sharing class findContacts {

    public List<Contact> contacts { get; set; }
    public List<Contact> primaryContacts {get; set; }
    public String searchField { get; set; }
    public ID primaryID { get; set; }
    private final Account account;
    public Integer pageSize = 10; //define the page size of related contacts.

    public findContacts(ApexPages.StandardController stdController) {
        this.account = (Account) stdController.getRecord();
    }

     /*
    * @author Orhan Emre Anıl
    * @date Aug 21 , 2021
    * @name searchContact
    * @description search for related contacts.
    */
    public void searchContact() {
        contacts = [
            SELECT ID, lastName, title, phone, Is_Primary_Contact__c
            FROM Contact
            WHERE Accountid = :this.account.ID AND lastName LIKE :'%' + searchField + '%'
            LIMIT :pageSize  
        ];
    }

    /*
    * @author Orhan Emre Anıl
    * @date Aug 21 , 2021
    * @name setAsPrimary
    * @description configure the selected contact as "a primary contact".
    */
    public void setAsPrimary() {
        try{
            primaryContacts = [
                SELECT ID, Is_Primary_Contact__c
                FROM Contact
                WHERE ID = :account.ID
                AND (Is_Primary_Contact__c = true OR ID = :primaryID)         
            ];
            for(Contact primary : primaryContacts){
                if(primary.Is_Primary_Contact__c){
                    primary.Is_Primary_Contact__c = false;  
                }else if(primary.ID == primaryId){
                    primary.Is_Primary_Contact__c = true;
                }
            }update primaryContacts;
        }catch(Exception e){
            System.debug('Warning. There is an exception: ' + e.getMessage());
        }
    }
}
