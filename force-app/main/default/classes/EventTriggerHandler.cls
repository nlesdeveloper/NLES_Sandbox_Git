public with sharing class EventTriggerHandler {
  public static void eventTriggerHandlerMethod(List<Event> triggerNew) {
    List<Event> listOfOrgEvents = [
      SELECT Subject, StartDateTime, EndDateTime
      FROM Event
      WITH SECURITY_ENFORCED
    ];

    for (Event eachOrgEvent : listOfOrgEvents) {
      for (Event eachNewEvent : triggerNew) {
        if (
          eachNewEvent.Subject == eachOrgEvent.Subject &&
          ((eachNewEvent.StartDateTime >=
          (eachOrgEvent.StartDateTime.addHours(-1)) &&
          eachNewEvent.StartDateTime <
          (eachOrgEvent.EndDateTime.addHours(+1))) ||
          (eachNewEvent.EndDateTime >
          (eachOrgEvent.StartDateTime.addHours(-1)) &&
          eachNewEvent.EndDateTime <= (eachOrgEvent.EndDateTime.addHours(+1))))
        ) {
          eachNewEvent.addError(
            'Conflict: There is already a scheduled event in this room for this time interval.'
          );
        }
      }
    }
  }
}