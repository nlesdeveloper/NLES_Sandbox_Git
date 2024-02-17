public with sharing class EventTriggerHandler {
  public static void eventTriggerHandlerMethod(List<Event> tirggerNew) {
    List<Event> listOfEvents = [
      SELECT Rooms__c, StartDateTime, EndDateTime
      FROM Event
      WITH SECURITY_ENFORCED
    ];

    for (Event eachEvent : listOfEvents) {
      for (Event eachNewEvent : tirggerNew) {
        if (
          eachNewEvent.Rooms__c == eachEvent.Rooms__c &&
          ((eachNewEvent.StartDateTime >= eachEvent.StartDateTime &&
          eachNewEvent.StartDateTime < eachEvent.EndDateTime) ||
          (eachNewEvent.EndDateTime > eachEvent.StartDateTime &&
          eachNewEvent.EndDateTime <= eachEvent.EndDateTime))
        ) {
          eachNewEvent.addError(
            'Conflict: There is already a scheduled event in this room for this time interval.'
          );
        }
      }
    }
  }
}