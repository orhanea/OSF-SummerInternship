/*
* **OSF Summer Internship****
* *****Third Exercise********
* @author Orhan Emre Anıl
* @date Aug 28, 2021
* @name OverviewOpportunityAmountsBatch 
* @description a batch class for sending general opportunity overview emails to primary contacts 
*/
global inherited sharing class OverviewOpportunityAmountsBatch implements Database.Batchable<SObject>, Database.Stateful {
    
  private Map<Id, String> primaryEmails;
  private List<AggregateResult> overviewResult;
  private String email;
    
	global OverviewOpportunityAmountsBatch(Map<Id, String> primaryEmails, List<AggregateResult> overviewResult) {
		this.primaryEmails = primaryEmails;
		this.overviewResult = overviewResult;
	}

	global Database.QueryLocator start(Database.BatchableContext batchable) {
		return Database.getQueryLocator('overviewResult');
	}

	global void execute(Database.BatchableContext batchable, List<sObject> records) {
	    try {
		  primaryContacts = [SELECT ID, AccountId, Email
			             FROM Contact
			             WHERE Is_Primary_Contact__c = true];

		  // Fill the map object.
		  for (Contact primary : primaryContacts) {
		       if (!primaryEmails.containsKey(primary.AccountId)) {
		           primaryEmails.put(primary.AccountId, primary.Email);
	               }
		  } 
            
                takeOpportunities();

		// Mount mail contents according to accountIDs.
		Map<Id, String> contents = getMail(records);

		// Add created emails to the list.
		List<Messaging.SingleEmailMessage> mails = getMails(contents);

		// Send.
		Messaging.sendEmail(mails);
	    } catch(Exception e) {
                System.debug('Warning. There is an exception: ' + e.getMessage());
            }	    
	}
		
        global void takeOpportunities() {
	    try {
                  // Searching for who has a primary contact "Used in the WHERE clause".
		  Set<Id> accountIdSet = primaryEmails.keySet();

		  // Time.
		  DateTime nowDate = System.now();
		  Date startDate = Date.newinstance(nowDate.year(), nowDate.month(), 1);

		  overviewResult = [SELECT AccountId, Account.Name AccountName, StageName, format(sum(Amount))SumAmount
			            FROM Opportunity
			            WHERE AccountId in :accountIdSet 
                                    AND (CreatedDate >= :startDate or LastModifiedDate >= :startDate)
			            GROUP BY AccountId, Account.Name, StageName
			            ORDER BY AccountId];
            
           } catch(Exception e) {	    
               System.debug('Warning. There is an exception: ' + e.getMessage());
           }    
      }	

	private Map<Id, String> getMail(List<sObject> records) {
        
		Map<Id, String> contents = new Map<Id, String>();
        
		for (sObject s : records) {
            
			AggregateResult ar = (AggregateResult)s;
			Id accountId = (Id) ar.get('AccountId');
			String accountName = (String) ar.get('AccountName');
			String stageName = (String) ar.get('StageName');
			String sumAmount = (String) ar.get('SumAmount');
			String content = contents.get(accountId);
            
			if (String.isBlank(content)) {
				//initialize the html content
				content = '<p>You can find a table of opportunities related to that account: ' + accountName + '</p>' + 
						  '<table border="2" style="border-collapse: initial;font-family: Helvetica Neue Light;" cellpadding="8px">' + 
						  '<tr style="background: #ddd;"><th>Account</th><th>Stage</th><th>Amount</th></tr>';
			}

			// Add row.
			content += '<tr><td>' + accountName + '</td><td>' + stageName + '</td><td>' + sumAmount + '</td></tr>';

			// Update.
			contents.put(accountId, content);
		}
		return contents;
	}
    
	private List<Messaging.SingleEmailMessage> getMails(Map<Id, String> contents) {
        
		List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
         
                // Get the value for a related field with the help of keySet().
		for (Id accountId : contents.keySet()) {
            
                        // Retrieve a value from a given key.
			String mailContent = contents.get(accountId); 

			// Close the tag.
			mailContent += '</table>';

			// Create a new object and add to the list.
			Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();            
                        // Assign the addresses.
			message.setToAddresses(new List<string>{primaryEmails.get(accountId)});            
                        // Specify the subject
			message.setSubject('Opportunity Overview');
			message.setHtmlBody(mailContent);
			mails.add(message);
		}
		return mails;
	}

	global void finish(Database.BatchableContext batchable){
		try{
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {email});
            mail.setReplyTo('orhan.anil@osf.digital');
            mail.setSenderDisplayName('Batch Processing');
            mail.setSubject('Batch Process Completed');
            mail.setPlainTextBody('Batch Process has completed');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		} catch (Exception e){
            System.debug('Warning. There is an exception: ' + e.getMessage());
		}
	}
 
}


