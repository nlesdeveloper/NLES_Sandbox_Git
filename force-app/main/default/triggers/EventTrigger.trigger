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
