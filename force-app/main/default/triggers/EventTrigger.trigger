/*
* @File Name        : EventTrigger
* @Description      : Trigger on Event object Before Insert and Before Update
* @Date Created     : 22/02/2024
* @Author           : Tyler K.
* @Modification Log : All-Day Event Field is now included in the custom error messages.
* @User Story       : Prevent overlapping events for the Event object - 0001
* ____________________________________________________________________________________
* Ver            Date            Author            Modification
* 1.0            22/02/2024      Tyler K.          Initial Version
* 1.1            12/03/2024      Tyler K.          All-Day Event Field Check
* ____________________________________________________________________________________
*/

trigger EventTrigger on Event(before insert, before update) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            EventTriggerHandler.eventTriggerHandlerBeforeInsert(Trigger.New);
        }
        if (Trigger.isUpdate) {
            EventTriggerHandler.eventTriggerHandlerBeforeUpdate(Trigger.New, Trigger.OldMap);
        }
    }
}