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

public with sharing class EventTriggerHandler {
    
    private static Integer dayEndHour;
    private static Boolean dayLightSaving = Event_Daylight_Saving_Setting__c.getOrgDefaults().Daylight_Saving__c;
    
    public static void eventTriggerHandlerBeforeInsert(List<Event> triggerNew) {
        
        if (dayLightSaving) {
            dayEndHour = 4;
        }else{
            dayEndHour = 5;
        }
        List<Event> listOfOrgEvents = [SELECT Subject, StartDateTime, EndDateTime, isAllDayEvent, ActivityDate FROM Event /*WHERE ActivityDate >= TODAY WITH SECURITY_ENFORCED*/];
        
        //Map of org events by their subject names (key) and List of Events (value)
        Map<String, List<Event>> mapRoomsAndListEvents = new Map<String, List<Event>>();
        if(!listOfOrgEvents.isEmpty()) {
            
            for (Event recEvent : listOfOrgEvents) {
                if (mapRoomsAndListEvents.containsKey(recEvent.Subject)) {
                    mapRoomsAndListEvents.get(recEvent.Subject).add(recEvent);
                } else {
                    mapRoomsAndListEvents.put(recEvent.Subject, new List<Event>{ recEvent });
                }
            }
            
            // Iterate through the new events to find any event that overlaps with an existing event
            for (Event eachNewEvent : triggerNew) {
                Date eachNewEventStartGMTDate = eachNewEvent.StartDateTime.dateGMT();
                Date eachNewEventEndGMTDate = eachNewEvent.EndDateTime.dateGMT();
                Date eachNewEventStartGMTDatePlus1 = eachNewEvent.StartDateTime.addDays(1).dateGMT();
                Date eachNewEventEndGMTDatePlus1 = eachNewEvent.EndDateTime.addDays(1).dateGMT();
                Integer eachNewEventStartGMTHour = eachNewEvent.StartDateTime.hourGMT();
                Integer eachNewEventEndGMTHour = eachNewEvent.EndDateTime.hourGMT();
                
                // Iterate through the org events
                for (Event eachOrgEvent : mapRoomsAndListEvents.get(eachNewEvent.Subject)) {
                    Date eachOrgEventStartGMTDate = eachOrgEvent.StartDateTime.dateGMT();
                    Date eachOrgEventEndGMTDate = eachOrgEvent.EndDateTime.dateGMT();
                    Date eachOrgEventStartGMTDatePlus1 = eachOrgEvent.StartDateTime.addDays(1).dateGMT();
                    Date eachOrgEventEndGMTDatePlus1 = eachOrgEvent.EndDateTime.addDays(1).dateGMT();
                    Integer eachOrgEventStartGMTHour = eachOrgEvent.StartDateTime.hourGMT();
                    Integer eachOrgEventEndGMTHour = eachOrgEvent.EndDateTime.hourGMT();
                    
                    Datetime eachOrgEventStartDateTimeMinus1Hour = eachOrgEvent.StartDateTime.addHours(-1);
                    Datetime eachOrgEventEndDateTimePlus1Hour = eachOrgEvent.EndDateTime.addHours(1);
                    
                    //Scenario-1: if the new event is not an all-day event and is falling within or spanning an already scheduled org event
                    if (eachNewEvent.IsAllDayEvent == false && mapRoomsAndListEvents.containsKey(eachNewEvent.Subject)) {
                        
                        //Scenario-1a: if already scheduled org event is not an all-day event
                        if (eachOrgEvent.IsAllDayEvent == false
                            && ((eachOrgEventStartDateTimeMinus1Hour <= eachNewEvent.StartDateTime && eachNewEvent.EndDateTime <= eachOrgEventEndDateTimePlus1Hour)
                                || (eachNewEvent.StartDateTime < eachOrgEventStartDateTimeMinus1Hour && eachNewEvent.EndDateTime > eachOrgEventStartDateTimeMinus1Hour && eachNewEvent.EndDateTime <= eachOrgEventEndDateTimePlus1Hour)
                                || (eachNewEvent.EndDateTime > eachOrgEventEndDateTimePlus1Hour && eachNewEvent.StartDateTime >= eachOrgEventStartDateTimeMinus1Hour && eachNewEvent.StartDateTime < eachOrgEventEndDateTimePlus1Hour)
                                || (eachNewEvent.StartDateTime < eachOrgEventStartDateTimeMinus1Hour && eachOrgEventEndDateTimePlus1Hour < eachNewEvent.EndDateTime))) {
                                    eachNewEvent.addError(System.Label.Event_Custom_Error_Message);
                                }
                        
                        //Scenario-1b: if already scheduled org event is an all-day event and new event's start time and end time (GMT) condition - 1
                        else if (eachOrgEvent.IsAllDayEvent == true
                                 && ((dayEndHour <= eachNewEventStartGMTHour && eachNewEventStartGMTHour <= 23) || (dayEndHour < eachNewEventEndGMTHour && eachNewEventEndGMTHour <= 23))
                                 && ((eachOrgEventStartGMTDate <= eachNewEventStartGMTDate && eachNewEventStartGMTDate <= eachOrgEventEndGMTDate)
                                     || (eachOrgEventStartGMTDate <= eachNewEventEndGMTDate && eachNewEventEndGMTDate <= eachOrgEventEndGMTDate))) {
                                         eachNewEvent.addError(System.Label.Event_Custom_Error_Message);
                                     }
                        
                        //Scenario-1c: if already scheduled org event is an all-day event and new event's start time and end time (GMT) condition - 2
                        else if (eachOrgEvent.IsAllDayEvent == true
                                 && ((0 <= eachNewEventStartGMTHour && eachNewEventStartGMTHour < dayEndHour) || (0 < eachNewEventEndGMTHour &&  eachNewEventEndGMTHour < dayEndHour))
                                 && ((eachOrgEventStartGMTDatePlus1 <= eachNewEventStartGMTDate && eachNewEventStartGMTDate <= eachOrgEventEndGMTDatePlus1)
                                     || (eachOrgEventStartGMTDatePlus1 <= eachNewEventEndGMTDate && eachNewEventEndGMTDate <= eachOrgEventEndGMTDatePlus1))) {
                                         eachNewEvent.addError(System.Label.Event_Custom_Error_Message);
                                     }
                    }
                    
                    //Scenario-2: if the new event is an all-day event and is falling within or spanning an already scheduled org event
                    if (eachNewEvent.IsAllDayEvent == true && mapRoomsAndListEvents.containsKey(eachNewEvent.Subject)) {
                        
                        //Scenario-2a: If the org event is not an all-day event and its start time and end time (GMT) condition - 1
                        if (eachOrgEvent.IsAllDayEvent == false
                            &&((dayEndHour <= eachOrgEventStartGMTHour && eachOrgEventStartGMTHour <= 23) || (dayEndHour < eachOrgEventEndGMTHour &&  eachOrgEventEndGMTHour <= 23))
                            && (eachNewEventStartGMTDate <= eachOrgEventStartGMTDate && eachOrgEventEndGMTDate <= eachNewEventEndGMTDate)) {
                                eachNewEvent.addError(System.Label.Event_Custom_Error_Message);
                            }
                        
                        //Scenario-2b: If the org event is not an all-day event and its start time and end time (GMT) condition - 2
                        else if (eachOrgEvent.IsAllDayEvent == false
                                 && ((0 <= eachOrgEventStartGMTHour && eachOrgEventStartGMTHour < dayEndHour) || (0 <= eachOrgEventEndGMTHour &&  eachOrgEventEndGMTHour < dayEndHour))
                                 && ((eachNewEventStartGMTDatePlus1 <= eachOrgEventStartGMTDate && eachOrgEventEndGMTDate <= eachNewEventEndGMTDatePlus1)
                                     || (eachNewEventStartGMTDate == eachOrgEventStartGMTDate && eachOrgEventEndGMTDate == eachNewEventEndGMTDatePlus1))) {
                                         eachNewEvent.addError(System.Label.Event_Custom_Error_Message);
                                     }
                        
                        //Scenario-2c: If the org event is an all-day event
                        else if (eachOrgEvent.IsAllDayEvent == true
                                 && (eachNewEventStartGMTDate <= eachOrgEventStartGMTDate && eachOrgEventEndGMTDate <= eachNewEventEndGMTDate)) {
                                     eachNewEvent.addError(System.Label.Event_Custom_Error_Message);
                                 }
                    }
                }
            }
        }
    }
    
    public static void eventTriggerHandlerBeforeUpdate(List<Event> triggerNew, Map<Id, Event> triggerOldMap) {
        
        if (dayLightSaving) {
            dayEndHour = 4;
        }else {
            dayEndHour = 5;
        }
        
        List<Event> listOfOrgEvents = [SELECT Subject, StartDateTime, EndDateTime, isAllDayEvent, ActivityDate FROM Event WHERE ActivityDate >= TODAY WITH SECURITY_ENFORCED];
        
        //Map of org events by their subject names (key) and List of Events (value)
        Map<String, List<Event>> mapRoomsAndListEvents = new Map<String, List<Event>>();
        if(!listOfOrgEvents.isEmpty()) {
            
            for (Event recEvent : listOfOrgEvents) {
                if (mapRoomsAndListEvents.containsKey(recEvent.Subject)) {
                    mapRoomsAndListEvents.get(recEvent.Subject).add(recEvent);
                } else{
                    mapRoomsAndListEvents.put(recEvent.Subject, new List<Event>{ recEvent });
                }
            }
            
            // Iterate through the updated events to find any event that overlaps with an existing event
            for (Event eachUpdatedEvent : triggerNew) {
                Date eachUpdatedEventStartGMTDate = eachUpdatedEvent.StartDateTime.dateGMT();
                Date eachUpdatedEventEndGMTDate = eachUpdatedEvent.EndDateTime.dateGMT();
                Date eachUpdatedEventStartGMTDatePlus1 = eachUpdatedEvent.StartDateTime.addDays(1).dateGMT();
                Date eachUpdatedEventEndGMTDatePlus1 = eachUpdatedEvent.EndDateTime.addDays(1).dateGMT();
                Integer eachUpdatedEventStartGMTHour = eachUpdatedEvent.StartDateTime.hourGMT();
                Integer eachUpdatedEventEndGMTHour = eachUpdatedEvent.EndDateTime.hourGMT();
                
                // Iterate through the org events
                for (Event eachOrgEvent : mapRoomsAndListEvents.get(eachUpdatedEvent.Subject)) {
                    Date eachOrgEventStartGMTDate = eachOrgEvent.StartDateTime.dateGMT();
                    Date eachOrgEventEndGMTDate = eachOrgEvent.EndDateTime.dateGMT();
                    Date eachOrgEventStartGMTDatePlus1 = eachOrgEvent.StartDateTime.addDays(1).dateGMT();
                    Date eachOrgEventEndGMTDatePlus1 = eachOrgEvent.EndDateTime.addDays(1).dateGMT();
                    Integer eachOrgEventStartGMTHour = eachOrgEvent.StartDateTime.hourGMT();
                    Integer eachOrgEventEndGMTHour = eachOrgEvent.EndDateTime.hourGMT();
                    
                    Datetime eachOrgEventStartDateTimeMinus1Hour = eachOrgEvent.StartDateTime.addHours(-1);
                    Datetime eachOrgEventEndDateTimePlus1Hour = eachOrgEvent.EndDateTime.addHours(1);
                    
                    //Scenario-1: if the updated event is not an all-day event and is falling within or spanning an already scheduled org event
                    if (eachUpdatedEvent.IsAllDayEvent == false && mapRoomsAndListEvents.containsKey(eachUpdatedEvent.Subject)) {
                        
                        //Scenario-1a: if already scheduled org event is not an all-day event
                        if (eachUpdatedEvent.Id != eachOrgEvent.Id && eachOrgEvent.IsAllDayEvent == false
                            && ((eachOrgEventStartDateTimeMinus1Hour <= eachUpdatedEvent.StartDateTime && eachUpdatedEvent.EndDateTime <= eachOrgEventEndDateTimePlus1Hour)
                                || (eachUpdatedEvent.StartDateTime < eachOrgEventStartDateTimeMinus1Hour && eachUpdatedEvent.EndDateTime > eachOrgEventStartDateTimeMinus1Hour && eachUpdatedEvent.EndDateTime <= eachOrgEventEndDateTimePlus1Hour)
                                || (eachUpdatedEvent.EndDateTime > eachOrgEventEndDateTimePlus1Hour && eachUpdatedEvent.StartDateTime >= eachOrgEventStartDateTimeMinus1Hour && eachUpdatedEvent.StartDateTime < eachOrgEventEndDateTimePlus1Hour)
                                || (eachUpdatedEvent.StartDateTime < eachOrgEventStartDateTimeMinus1Hour && eachUpdatedEvent.EndDateTime > eachOrgEventEndDateTimePlus1Hour))) {
                                    eachUpdatedEvent.addError(System.Label.Event_Custom_Error_Message);
                                }
                        
                        //Scenario-1b: if already scheduled org event is an all-day event and new event's start time and end time (GMT) condition - 1
                        else if (eachUpdatedEvent.Id != eachOrgEvent.Id && eachOrgEvent.IsAllDayEvent == true
                                 && ((dayEndHour <= eachUpdatedEventStartGMTHour && eachUpdatedEventStartGMTHour <= 23) || (dayEndHour < eachUpdatedEventEndGMTHour && eachUpdatedEventEndGMTHour <= 23))
                                 && ((eachOrgEventStartGMTDate <= eachUpdatedEventStartGMTDate && eachUpdatedEventStartGMTDate <= eachOrgEventEndGMTDate)
                                     || (eachOrgEventStartGMTDate <= eachUpdatedEventEndGMTDate && eachUpdatedEventEndGMTDate <= eachOrgEventEndGMTDate))) {
                                         eachUpdatedEvent.addError(System.Label.Event_Custom_Error_Message);
                                     }
                        
                        //Scenario-1c: if already scheduled org event is an all-day event and new event's start time and end time (GMT) condition - 2
                        else if (eachUpdatedEvent.Id != eachOrgEvent.Id && eachOrgEvent.IsAllDayEvent == true
                                 && ((0 <= eachUpdatedEventStartGMTHour && eachUpdatedEventStartGMTHour < dayEndHour) || (0 < eachUpdatedEventEndGMTHour &&  eachUpdatedEventEndGMTHour < dayEndHour))
                                 && ((eachOrgEventStartGMTDatePlus1 <= eachUpdatedEventStartGMTDate && eachUpdatedEventStartGMTDate <= eachOrgEventEndGMTDatePlus1)
                                     || (eachOrgEventStartGMTDatePlus1 <= eachUpdatedEventEndGMTDate && eachUpdatedEventEndGMTDate <= eachOrgEventEndGMTDatePlus1))) {
                                         eachUpdatedEvent.addError(System.Label.Event_Custom_Error_Message);
                                     }
                    }
                    
                    //Scenario-2: if the updated event is an all-day event and is falling within or spanning an already scheduled org event
                    if (eachUpdatedEvent.IsAllDayEvent == true && mapRoomsAndListEvents.containsKey(eachUpdatedEvent.Subject)) {
                        
                        //Scenario-2a: If the org event is not an all-day event and it's start time and end time (GMT) condition - 1
                        if (eachUpdatedEvent.Id != eachOrgEvent.Id && eachOrgEvent.IsAllDayEvent == false
                            && ((dayEndHour <= eachOrgEventStartGMTHour && eachOrgEventStartGMTHour <= 23) || (dayEndHour < eachOrgEventEndGMTHour &&  eachOrgEventEndGMTHour <= 23))
                            && (eachUpdatedEventStartGMTDate <= eachOrgEventStartGMTDate && eachOrgEventEndGMTDate <= eachUpdatedEventEndGMTDate)) {
                                eachUpdatedEvent.addError(System.Label.Event_Custom_Error_Message);
                            }
                        
                        //Scenario-2b: If the org event is not an all-day event and it's start time and end time (GMT) condition - 2
                        else if (eachUpdatedEvent.Id != eachOrgEvent.Id && eachOrgEvent.IsAllDayEvent == false
                                 && ((0 <= eachOrgEventStartGMTHour && eachOrgEventStartGMTHour < dayEndHour) || (0 <= eachOrgEventEndGMTHour &&  eachOrgEventEndGMTHour < dayEndHour))
                                 && ((eachUpdatedEventStartGMTDatePlus1 <= eachOrgEventStartGMTDate && eachOrgEventEndGMTDate <= eachUpdatedEventEndGMTDatePlus1))
                                 ||(eachUpdatedEventStartGMTDate == eachOrgEventStartGMTDate && eachOrgEventEndGMTDate == eachUpdatedEventEndGMTDatePlus1)){
                                     eachUpdatedEvent.addError(System.Label.Event_Custom_Error_Message);
                                 }
                        
                        //Scenario-2c: If the org event is an all-day event
                        else if (eachUpdatedEvent.Id != eachOrgEvent.Id && eachOrgEvent.IsAllDayEvent == true
                                 && (eachUpdatedEventStartGMTDate <= eachOrgEventStartGMTDate && eachOrgEventEndGMTDate <= eachUpdatedEventEndGMTDate)) {
                                     eachUpdatedEvent.addError(System.Label.Event_Custom_Error_Message);
                                 }
                    }
                }
            }
        }
    }
}