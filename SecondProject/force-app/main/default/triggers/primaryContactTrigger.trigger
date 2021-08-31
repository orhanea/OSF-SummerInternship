/*
* @author Orhan Emre Anıl
* @date Aug 24, 2021
* @name primaryContactTrigger
* @description trigger for changing primary contact phone
*/

trigger primaryContactTrigger on Contact (before insert, before update, after insert, after update) {

    primaryContactTriggerHandler myHandler = new PrimaryContactTriggerHandler();

    if (Trigger.isBefore) {
		myHandler.onBeforeInsert(Trigger.new);
	} else if (Trigger.isAfter && Trigger.isInsert) {
		myHandler.onAfterInsert(Trigger.new);
	} else if (Trigger.isAfter && Trigger.isUpdate) {
		myHandler.onAfterUpdate(Trigger.old, Trigger.new);
	}

}