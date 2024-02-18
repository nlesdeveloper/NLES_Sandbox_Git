public with sharing class EventTriggerHandler {
  public static void eventTriggerHandlerBeforeInsert(List<Event> triggerNew) {
    List<Event> listOfOrgEvents = [SELECT Subject, StartDateTime, EndDateTime FROM Event WHERE StartDateTime >= TODAY  AND EndDateTime >= TODAY WITH SECURITY_ENFORCED];
    Map<String, List<Event>> mapRoomNamesWithListEvents = new Map<String, List<Event>>();
    //mapRoomNamesWithListEvent
    for (Event recEvent : listOfOrgEvents) {
      if (mapRoomNamesWithListEvents.containsKey(recEvent.Subject)) {
        mapRoomNamesWithListEvents.get(recEvent.Subject).add(recEvent);
      } else {
        mapRoomNamesWithListEvents.put(recEvent.Subject, new List<Event> {recEvent});
      }
    }

    for (Event eachNewEvent : triggerNew) {
      if (mapRoomNamesWithListEvents.containsKey(eachNewEvent.Subject)) {
          for (Event eachOrgEvent : mapRoomNamesWithListEvents.get(eachNewEvent.Subject)) {
            if ((eachNewEvent.StartDateTime >= (eachOrgEvent.StartDateTime) && eachNewEvent.StartDateTime < (eachOrgEvent.EndDateTime) ||
              (eachNewEvent.EndDateTime > (eachOrgEvent.StartDateTime) && eachNewEvent.EndDateTime <= (eachOrgEvent.EndDateTime)))) {
              eachNewEvent.addError('Conflict: There is already a scheduled event in this room for this time interval.');
            }
          }
      }
    }
}

  public static void eventTriggerHandlerBeforeUpdate(List<Event> triggerNew, Map<Id,Event> triggerOldMap) {
    List<Event> listOfOrgEvents = [SELECT Subject, StartDateTime, EndDateTime FROM Event WHERE StartDateTime >= TODAY  AND EndDateTime >= TODAY WITH SECURITY_ENFORCED];
    
    for (Event eachOrgEvent : listOfOrgEvents) {
      for (Event eachNewEvent : triggerNew) {
        
        if (eachNewEvent.Subject != triggerOldMap.get(eachNewEvent.Id).Subject || eachNewEvent.StartDateTime == triggerOldMap.get(eachNewEvent.Id).StartDateTime || eachNewEvent.EndDateTime == triggerOldMap.get(eachNewEvent.Id).EndDateTime) {
          if (eachNewEvent.Subject == eachOrgEvent.Subject &&
          ((eachNewEvent.StartDateTime >= (eachOrgEvent.StartDateTime) && eachNewEvent.StartDateTime < (eachOrgEvent.EndDateTime)) ||
          (eachNewEvent.EndDateTime > (eachOrgEvent.StartDateTime) && eachNewEvent.EndDateTime <= (eachOrgEvent.EndDateTime)))) {
          eachNewEvent.addError('Conflict: There is already a scheduled event in this room for this time interval.');
           }
        }
      }
    }
  }
}