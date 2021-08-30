/*
* @author Orhan Emre Anıl
* @date Aug 28, 2021
* @name OverviewOpportunityAmountsScheduler 
* @description a scheduler class for calculating and sending general opportunity overview emails
* with the help of batch according to prespecified periods.
*/

global inherited sharing class OverviewOpportunityAmountsScheduler implements Schedulable {
    
    private Map<Id, String> primaryEmails = new Map<Id, String>();
    private List<Contact> primaryContacts = new List<Contact>();
    private List<AggregateResult> overviewResult = new List<AggregateResult>();
    
	global void execute(SchedulableContext context) {
		try {
            
			primaryContacts = [SELECT ID, AccountId, Email
			                   FROM Contact
			                   WHERE Is_Primary_Contact__c = true];

			// Fill the map object.
			for (Contact primary : primaryContacts) {
				if (!primaryEmails.containsKey(primary.AccountId)){
					primaryEmails.put(primary.AccountId, primary.Email);
				}
			}

			// Searching for who has a primary contact "Used in the WHERE clause".
			Set<Id> accountIdSet = primaryEmails.keySet();

			// Time.
			DateTime nowDate = System.now();
			Date startDate = Date.newinstance(nowDate.year(), nowDate.month(), 1);
            
			System.debug('Schedule is starting for: ' + string.valueOfGmt(startDate));

			overviewResult = [SELECT AccountId, Account.Name AccountName, StageName, format(sum(Amount))SumAmount
			                  FROM Opportunity
			                  WHERE AccountId in :accountIdSet 
                              AND (CreatedDate >= :startDate or LastModifiedDate >= :startDate)
			                  GROUP BY AccountId, Account.Name, StageName
			                  ORDER BY AccountId];

			// Execute.
			OverviewOpportunityAmountsBatch batch = new OverviewOpportunityAmountsBatch(primaryEmails, overViewResult);
			Database.executeBatch(batch);
            
		} catch (Exception e) {
			System.debug('Warning. There is an exception: ' + e.getMessage());
		}
	}
}
/****************SCHEDULE SCRIPT*********************/
/* OverviewOpportunityAmountsScheduler schedule = new OverviewOpportunityAmountsScheduler(); 
*  String schedule1 = '0 0 10 * * ?';
*  String job1 = System.schedule('Opportunity Amount Overview', schedule1, schedule);
*  String schedule2 = '0 0 13 ? * 6';
*  String job2 = System.schedule('Opportunity Amount Overview 2', schedule2, schedule);
*  String schedule3 = '0 0 18 ? * 6L';
*  String job3 = System.schedule('Opportunity Amount Overview 3', schedule3, schedule); 
*  OverviewOpportunityAmountsScheduler sch = new OverviewOpportunityAmountsScheduler();
*  sch.execute(null);
*/