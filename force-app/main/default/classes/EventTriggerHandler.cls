/*
 * @File Name    :   EventTriggerHandler
 * @Description  :   Prevent double bookings for the Event object
 * @Date Created :   22/02/2024
 * @Author       :   Tyler K.
 * @Modification Log:
 * @User Story   :   Prevent double bookings for the Event object - 0001
 * ____________________________________________________________________________________
 * Ver       Date           Author                   Modification
 * 1.0       22/6/2024      Tyler K.                 Initial Version
 * ____________________________________________________________________________________
 */

public with sharing class EventTriggerHandler {
  public static void eventTriggerHandlerBeforeInsert(List<Event> triggerNew) {
    List<Event> listOfOrgEvents = [
      SELECT Subject, StartDateTime, EndDateTime
      FROM Event
      WHERE StartDateTime >= TODAY AND EndDateTime >= TODAY
      WITH SECURITY_ENFORCED
    ];

    Map<String, List<Event>> mapRoomsAndListEvents = new Map<String, List<Event>>();

    for (Event recEvent : listOfOrgEvents) {
      if (mapRoomsAndListEvents.containsKey(recEvent.Subject)) {
        mapRoomsAndListEvents.get(recEvent.Subject).add(recEvent);
      } else {
        mapRoomsAndListEvents.put(recEvent.Subject, new List<Event>{ recEvent });
      }
    }

    for (Event eachNewEvent : triggerNew) {
      if (mapRoomsAndListEvents.containsKey(eachNewEvent.Subject)) {
        for (Event eachOrgEvent : mapRoomsAndListEvents.get(eachNewEvent.Subject)) {
          if ((eachNewEvent.StartDateTime >= (eachOrgEvent.StartDateTime.addHours(-1)) && eachNewEvent.StartDateTime < (eachOrgEvent.EndDateTime.addHours(+1))
        ||   (eachNewEvent.EndDateTime > (eachOrgEvent.StartDateTime.addHours(-1)) && eachNewEvent.EndDateTime <= (eachOrgEvent.EndDateTime.addHours(+1))))) {
            eachNewEvent.addError(System.Label.Event_Custom_Error_Message);
          }
        }
      }
    }
  }

  public static void eventTriggerHandlerBeforeUpdate(List<Event> triggerNew, Map<Id, Event> triggerOldMap) {
    List<Event> listOfOrgEvents = [
      SELECT Subject, StartDateTime, EndDateTime
      FROM Event
      WHERE StartDateTime >= TODAY AND EndDateTime >= TODAY
      WITH SECURITY_ENFORCED
    ];

    Map<String, List<Event>> mapRoomsAndListEvents = new Map<String, List<Event>>();

    for (Event recEvent : listOfOrgEvents) {
      if (mapRoomsAndListEvents.containsKey(recEvent.Subject)) {
        mapRoomsAndListEvents.get(recEvent.Subject).add(recEvent);
      } else {
        mapRoomsAndListEvents.put(recEvent.Subject, new List<Event>{ recEvent });
      }
    }

    for (Event eachNewEvent : triggerNew) {
      if (mapRoomsAndListEvents.containsKey(eachNewEvent.Subject)) {
        for (Event eachOrgEvent : mapRoomsAndListEvents.get(eachNewEvent.Subject)) {
          if (eachNewEvent.Subject != triggerOldMap.get(eachNewEvent.Id).Subject
        ||    eachNewEvent.StartDateTime != triggerOldMap.get(eachNewEvent.Id).StartDateTime
        ||    eachNewEvent.EndDateTime != triggerOldMap.get(eachNewEvent.Id).EndDateTime) {
            if (eachNewEvent.Id != eachOrgEvent.Id
        &&     (eachNewEvent.StartDateTime >= (eachOrgEvent.StartDateTime.addHours(-1)) && eachNewEvent.StartDateTime < (eachOrgEvent.EndDateTime.addHours(+1))
        ||     (eachNewEvent.EndDateTime > (eachOrgEvent.StartDateTime.addHours(-1)) && eachNewEvent.EndDateTime <= (eachOrgEvent.EndDateTime.addHours(+1))))) {
              eachNewEvent.addError(System.Label.Event_Custom_Error_Message);
            }
          }
        }
      }
    }
  }
}