trigger EventTrigger on Event(before insert) {
  if (Trigger.isBefore) {
    if (Trigger.isInsert) {
      EventTriggerHandler.eventTriggerHandlerMethod(Trigger.new);
    }
  }
}
