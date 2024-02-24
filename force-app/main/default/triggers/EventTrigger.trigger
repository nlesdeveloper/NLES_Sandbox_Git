/*
* @File Name    :   EventTrigger
* @Description  :   Trigger on Event object Before Insert and Before Update
* @Date Created :   22/02/2024
* @Author       :   Turgay K.
* @Modification Log:
* @User Story   :   Prevent double bookings for the Event object - 0001
* ____________________________________________________________________________________
* Ver       Date           Author                   Modification
* 1.0       22/6/2024      Turgay K.                Intial Version
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
