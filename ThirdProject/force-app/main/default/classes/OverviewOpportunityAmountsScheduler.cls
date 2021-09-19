/*
* @author Orhan Emre Anıl
* @date Aug 28, 2021
* @name OverviewOpportunityAmountsScheduler 
* @description a scheduler class for calculating and sending general opportunity overview emails
* with the help of batch according to prespecified periods.
*/

global inherited sharing class OverviewOpportunityAmountsScheduler implements Schedulable {
    
    private Map<Id, String> primaryEmails = new Map<Id, String>();
    private List<AggregateResult> overviewResult = new List<AggregateResult>();
    
	global void execute(SchedulableContext context) {
		try {
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
