trigger EventTrigger on Event(before insert, before update) {
  if (Trigger.isBefore) {
    if (Trigger.isInsert || Trigger.isUpdate) {
      EventTriggerHandler.eventTriggerHandlerMethod(Trigger.new);
    }
  }
}
