public with sharing class EventTriggerHandler {
  public static void eventTriggerHandlerBeforeInsert(List<Event> triggerNew) {
    List<Event> listOfOrgEvents = [SELECT Subject, StartDateTime, EndDateTime FROM Event WHERE StartDateTime >= TODAY  AND EndDateTime >= TODAY WITH SECURITY_ENFORCED];

    for (Event eachOrgEvent : listOfOrgEvents) {
      for (Event eachNewEvent : triggerNew) {
        if (eachNewEvent.Subject == eachOrgEvent.Subject &&
          ((eachNewEvent.StartDateTime >= (eachOrgEvent.StartDateTime.addHours(-1)) && eachNewEvent.StartDateTime < (eachOrgEvent.EndDateTime.addHours(+1))) ||
          (eachNewEvent.EndDateTime > (eachOrgEvent.StartDateTime.addHours(-1)) && eachNewEvent.EndDateTime <= (eachOrgEvent.EndDateTime.addHours(+1))))) {
          eachNewEvent.addError('Conflict: There is already a scheduled event in this room for this time interval.');
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
          ((eachNewEvent.StartDateTime >= (eachOrgEvent.StartDateTime.addHours(-1)) && eachNewEvent.StartDateTime < (eachOrgEvent.EndDateTime.addHours(+1))) ||
          (eachNewEvent.EndDateTime > (eachOrgEvent.StartDateTime.addHours(-1)) && eachNewEvent.EndDateTime <= (eachOrgEvent.EndDateTime.addHours(+1))))) {
          eachNewEvent.addError('Conflict: There is already a scheduled event in this room for this time interval.');
           }
        }
  //code here
      }
    }
  }
}