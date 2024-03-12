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
        System.debug('Daylight saving setting on org (true or false) = ' + dayLightSaving);
        
        if (dayLightSaving) {
            dayEndHour = 4;
            System.debug('Day End Hour ==> ' + dayEndHour);
        }else{
            dayEndHour = 5;
            System.debug('Day End Hour ==> ' + dayEndHour);
        }
        List<Event> listOfOrgEvents = [SELECT Subject, StartDateTime, EndDateTime, isAllDayEvent, ActivityDate FROM Event /*WHERE ActivityDate >= TODAY WITH SECURITY_ENFORCED*/];
        System.debug('************ BEFORE INSERT TRIGGER ************');
        System.debug(System.now());
        System.debug(date.today());
        System.debug(UserInfo.getTimeZone().getDisplayName());  //(GMT-05:00) Eastern Standard Time (America/New_York)
        System.debug(UserInfo.getTimeZone().getID());           //America/New_York
        
        //Map of org events by their subject names (key) and List of Events (value)
        Map<String, List<Event>> mapRoomsAndListEvents = new Map<String, List<Event>>();
        if(!listOfOrgEvents.isEmpty()) {
            System.debug(listOfOrgEvents.size());
            
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
                System.debug('eachNewEventStartGMTDate ' + eachNewEventStartGMTDate);
                Date eachNewEventEndGMTDate = eachNewEvent.EndDateTime.dateGMT();
                System.debug('eachNewEventEndGMTDate ' + eachNewEventEndGMTDate);
                Date eachNewEventStartGMTDatePlus1 = eachNewEvent.StartDateTime.addDays(1).dateGMT();
                System.debug('eachNewEventStartGMTDatePlus1 ' + eachNewEventStartGMTDatePlus1);
                Date eachNewEventEndGMTDatePlus1 = eachNewEvent.EndDateTime.addDays(1).dateGMT();
                System.debug('eachNewEventEndGMTDatePlus1 ' + eachNewEventEndGMTDatePlus1);
                Integer eachNewEventStartGMTHour = eachNewEvent.StartDateTime.hourGMT();
                System.debug('eachNewEventStartGMTHour ' + eachNewEventStartGMTHour);
                Integer eachNewEventEndGMTHour = eachNewEvent.EndDateTime.hourGMT();
                System.debug('eachNewEventEndGMTHour ' + eachNewEventEndGMTHour);
                
                // Iterate through the org events
                for (Event eachOrgEvent : mapRoomsAndListEvents.get(eachNewEvent.Subject)) {
                    Date eachOrgEventStartGMTDate = eachOrgEvent.StartDateTime.dateGMT();
                    System.debug('eachOrgEventStartGMTDate ' + eachOrgEventStartGMTDate);
                    Date eachOrgEventEndGMTDate = eachOrgEvent.EndDateTime.dateGMT();
                    System.debug('eachOrgEventEndGMTDate ' + eachOrgEventEndGMTDate);
                    Date eachOrgEventStartGMTDatePlus1 = eachOrgEvent.StartDateTime.addDays(1).dateGMT();
                    System.debug('eachOrgEventStartGMTDatePlus1 ' + eachOrgEventStartGMTDatePlus1);
                    Date eachOrgEventEndGMTDatePlus1 = eachOrgEvent.EndDateTime.addDays(1).dateGMT();
                    System.debug('eachOrgEventEndGMTDatePlus1 ' + eachOrgEventEndGMTDatePlus1);
                    Integer eachOrgEventStartGMTHour = eachOrgEvent.StartDateTime.hourGMT();
                    System.debug('eachOrgEventStartGMTHour ' + eachOrgEventStartGMTHour);
                    Integer eachOrgEventEndGMTHour = eachOrgEvent.EndDateTime.hourGMT();
                    System.debug('eachOrgEventEndGMTHour ' + eachOrgEventEndGMTHour);
                    
                    Datetime eachOrgEventStartDateTimeMinus1Hour = eachOrgEvent.StartDateTime.addHours(-1);
                    Datetime eachOrgEventEndDateTimePlus1Hour = eachOrgEvent.EndDateTime.addHours(1);
                    
                    //Scenario-1: if the new event is not an all-day event and is falling within or spanning an already scheduled org event
                    if (eachNewEvent.IsAllDayEvent == false && mapRoomsAndListEvents.containsKey(eachNewEvent.Subject)) {
                        System.debug('************ Scenario-1: New event with IsAllDayEvent === FALSE === > ' + eachNewEvent.IsAllDayEvent);
                        
                        //Scenario-1a: if already scheduled org event is not an all-day event
                        if (eachOrgEvent.IsAllDayEvent == false
                            && ((eachOrgEventStartDateTimeMinus1Hour <= eachNewEvent.StartDateTime && eachNewEvent.EndDateTime <= eachOrgEventEndDateTimePlus1Hour)
                                || (eachNewEvent.StartDateTime < eachOrgEventStartDateTimeMinus1Hour && eachNewEvent.EndDateTime > eachOrgEventStartDateTimeMinus1Hour && eachNewEvent.EndDateTime <= eachOrgEventEndDateTimePlus1Hour)
                                || (eachNewEvent.EndDateTime > eachOrgEventEndDateTimePlus1Hour && eachNewEvent.StartDateTime >= eachOrgEventStartDateTimeMinus1Hour && eachNewEvent.StartDateTime < eachOrgEventEndDateTimePlus1Hour)
                                || (eachNewEvent.StartDateTime < eachOrgEventStartDateTimeMinus1Hour && eachOrgEventEndDateTimePlus1Hour < eachNewEvent.EndDateTime))) {
                                    System.debug('************ Scenario-1a: Org event with IsAllDayEvent == FALSE === > ' + eachOrgEvent.IsAllDayEvent);
                                    eachNewEvent.addError(System.Label.Event_Custom_Error_Message);
                                    System.debug('************ CUSTOM ERROR MESSAGE WAS THROWN HERE ************');
                                }
                        
                        //Scenario-1b: if already scheduled org event is an all-day event and new event's start time and end time (GMT) condition - 1
                        else if (eachOrgEvent.IsAllDayEvent == true
                                 && ((dayEndHour <= eachNewEventStartGMTHour && eachNewEventStartGMTHour <= 23) || (dayEndHour < eachNewEventEndGMTHour && eachNewEventEndGMTHour <= 23))
                                 && ((eachOrgEventStartGMTDate <= eachNewEventStartGMTDate && eachNewEventStartGMTDate <= eachOrgEventEndGMTDate)
                                     || (eachOrgEventStartGMTDate <= eachNewEventEndGMTDate && eachNewEventEndGMTDate <= eachOrgEventEndGMTDate))) {
                                         System.debug('************ Scenario-1b: Org event with IsAllDayEvent == TRUE === > ' + eachOrgEvent.IsAllDayEvent);
                                         System.debug('************ ' + dayEndHour + ' <= New Event Start Hour <= 23 OR ' + dayEndHour + ' < New Event End Hour <= 23');
                                         eachNewEvent.addError(System.Label.Event_Custom_Error_Message);
                                         System.debug('************ CUSTOM ERROR MESSAGE WAS THROWN HERE ************');
                                     }
                        
                        //Scenario-1c: if already scheduled org event is an all-day event and new event's start time and end time (GMT) condition - 2
                        else if (eachOrgEvent.IsAllDayEvent == true
                                 && ((0 <= eachNewEventStartGMTHour && eachNewEventStartGMTHour < dayEndHour) || (0 < eachNewEventEndGMTHour &&  eachNewEventEndGMTHour < dayEndHour))
                                 && ((eachOrgEventStartGMTDatePlus1 <= eachNewEventStartGMTDate && eachNewEventStartGMTDate <= eachOrgEventEndGMTDatePlus1)
                                     || (eachOrgEventStartGMTDatePlus1 <= eachNewEventEndGMTDate && eachNewEventEndGMTDate <= eachOrgEventEndGMTDatePlus1))) {
                                         System.debug('************ Scenario-1c: Org event with IsAllDayEvent == TRUE === > ' + eachOrgEvent.IsAllDayEvent);
                                         System.debug('************ 0 <= New Event Start Hour < ' + dayEndHour + ' OR 0 < New Event End Hour < ' + dayEndHour + '************');
                                         eachNewEvent.addError(System.Label.Event_Custom_Error_Message);
                                         System.debug('************ CUSTOM ERROR MESSAGE WAS THROWN HERE ************');
                                     }
                    }
                    
                    //Scenario-2: if the new event is an all-day event and is falling within or spanning an already scheduled org event
                    if (eachNewEvent.IsAllDayEvent == true && mapRoomsAndListEvents.containsKey(eachNewEvent.Subject)) {
                        System.debug('************ Scenario-2: New event with IsAllDayEvent === TRUE === > ' + eachNewEvent.IsAllDayEvent);
                        
                        //Scenario-2a: If the org event is not an all-day event and its start time and end time (GMT) condition - 1
                        if (eachOrgEvent.IsAllDayEvent == false
                            &&((dayEndHour <= eachOrgEventStartGMTHour && eachOrgEventStartGMTHour <= 23) || (dayEndHour < eachOrgEventEndGMTHour &&  eachOrgEventEndGMTHour <= 23))
                            && (eachNewEventStartGMTDate <= eachOrgEventStartGMTDate && eachOrgEventEndGMTDate <= eachNewEventEndGMTDate)) {
                                System.debug('************ Scenario-2a: ' + dayEndHour + ' <= Org Event Start Hour <= 23 OR ' + dayEndHour + ' < Org Event End Hour <= 23');
                                eachNewEvent.addError(System.Label.Event_Custom_Error_Message);
                                System.debug('************ CUSTOM ERROR MESSAGE WAS THROWN HERE ************');
                            }
                        
                        //Scenario-2b: If the org event is not an all-day event and its start time and end time (GMT) condition - 2
                        else if (eachOrgEvent.IsAllDayEvent == false
                                 && ((0 <= eachOrgEventStartGMTHour && eachOrgEventStartGMTHour < dayEndHour) || (0 <= eachOrgEventEndGMTHour &&  eachOrgEventEndGMTHour < dayEndHour))
                                 && ((eachNewEventStartGMTDatePlus1 <= eachOrgEventStartGMTDate && eachOrgEventEndGMTDate <= eachNewEventEndGMTDatePlus1)
                                     || (eachNewEventStartGMTDate == eachOrgEventStartGMTDate && eachOrgEventEndGMTDate == eachNewEventEndGMTDatePlus1))) {
                                         System.debug('************ Scenario-2b: 0 <= Org Event Start Hour < ' + dayEndHour +') OR 0 <= Org Event End Hour < ' +dayEndHour);
                                         eachNewEvent.addError(System.Label.Event_Custom_Error_Message);
                                         System.debug('************ CUSTOM ERROR MESSAGE WAS THROWN HERE ************');
                                     }
                        
                        //Scenario-2c: If the org event is an all-day event
                        else if (eachOrgEvent.IsAllDayEvent == true
                                 && (eachNewEventStartGMTDate <= eachOrgEventStartGMTDate && eachOrgEventEndGMTDate <= eachNewEventEndGMTDate)) {
                                     System.debug('************ Scenario-2c: Org event with IsAllDayEvent === TRUE === > ' + eachOrgEvent.IsAllDayEvent);
                                     eachNewEvent.addError(System.Label.Event_Custom_Error_Message);
                                     System.debug('************ CUSTOM ERROR MESSAGE WAS THROWN HERE ************');
                                 }
                    }
                }
            }
        }
    }
    
    public static void eventTriggerHandlerBeforeUpdate(List<Event> triggerNew, Map<Id, Event> triggerOldMap) {
        System.debug('Daylight saving setting on org (true or false) = ' + dayLightSaving);
        
        if (dayLightSaving) {
            dayEndHour = 4;
        }else {
            dayEndHour = 5;
        }
        
        List<Event> listOfOrgEvents = [SELECT Subject, StartDateTime, EndDateTime, isAllDayEvent, ActivityDate FROM Event WHERE ActivityDate >= TODAY WITH SECURITY_ENFORCED];
        System.debug('************ BEFORE UPDATE TRIGGER ************');
        System.debug(System.now());
        System.debug(date.today());
        System.debug(UserInfo.getTimeZone().getDisplayName());  //(GMT-05:00) Eastern Standard Time (America/New_York)
        System.debug(UserInfo.getTimeZone().getID());           //America/New_York
        
        //Map of org events by their subject names (key) and List of Events (value)
        Map<String, List<Event>> mapRoomsAndListEvents = new Map<String, List<Event>>();
        if(!listOfOrgEvents.isEmpty()) {
            System.debug(listOfOrgEvents.size());
            
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
                System.debug('eachUpdatedEventStartGMTDate ' + eachUpdatedEventStartGMTDate);
                Date eachUpdatedEventEndGMTDate = eachUpdatedEvent.EndDateTime.dateGMT();
                System.debug('eachNewEventEndGMTDate ' + eachUpdatedEventEndGMTDate);
                Date eachUpdatedEventStartGMTDatePlus1 = eachUpdatedEvent.StartDateTime.addDays(1).dateGMT();
                System.debug('eachNewEventStartGMTDatePlus1 ' + eachUpdatedEventStartGMTDatePlus1);
                Date eachUpdatedEventEndGMTDatePlus1 = eachUpdatedEvent.EndDateTime.addDays(1).dateGMT();
                System.debug('eachUpdatedEventEndGMTDatePlus1 ' + eachUpdatedEventEndGMTDatePlus1);
                Integer eachUpdatedEventStartGMTHour = eachUpdatedEvent.StartDateTime.hourGMT();
                System.debug('eachUpdatedEventStartGMTHour ' + eachUpdatedEventStartGMTHour);
                Integer eachUpdatedEventEndGMTHour = eachUpdatedEvent.EndDateTime.hourGMT();
                System.debug('eachUpdatedEventEndGMTHour ' + eachUpdatedEventEndGMTHour);
                
                // Iterate through the org events
                for (Event eachOrgEvent : mapRoomsAndListEvents.get(eachUpdatedEvent.Subject)) {
                    Date eachOrgEventStartGMTDate = eachOrgEvent.StartDateTime.dateGMT();
                    System.debug('eachOrgEventStartGMTDate ' + eachOrgEventStartGMTDate);
                    Date eachOrgEventEndGMTDate = eachOrgEvent.EndDateTime.dateGMT();
                    System.debug('eachOrgEventEndGMTDate ' + eachOrgEventEndGMTDate);
                    Date eachOrgEventStartGMTDatePlus1 = eachOrgEvent.StartDateTime.addDays(1).dateGMT();
                    System.debug('eachOrgEventStartGMTDatePlus1 ' + eachOrgEventStartGMTDatePlus1);
                    Date eachOrgEventEndGMTDatePlus1 = eachOrgEvent.EndDateTime.addDays(1).dateGMT();
                    System.debug('eachOrgEventEndGMTDatePlus1 ' + eachOrgEventEndGMTDatePlus1);
                    Integer eachOrgEventStartGMTHour = eachOrgEvent.StartDateTime.hourGMT();
                    System.debug('eachOrgEventStartGMTHour ' + eachOrgEventStartGMTHour);
                    Integer eachOrgEventEndGMTHour = eachOrgEvent.EndDateTime.hourGMT();
                    System.debug('eachOrgEventEndGMTHour ' + eachOrgEventEndGMTHour);
                    
                    Datetime eachOrgEventStartDateTimeMinus1Hour = eachOrgEvent.StartDateTime.addHours(-1);
                    Datetime eachOrgEventEndDateTimePlus1Hour = eachOrgEvent.EndDateTime.addHours(1);
                    
                    //Scenario-1: if the updated event is not an all-day event and is falling within or spanning an already scheduled org event
                    if (eachUpdatedEvent.IsAllDayEvent == false && mapRoomsAndListEvents.containsKey(eachUpdatedEvent.Subject)) {
                        System.debug('************ Scenario-1: Updated event with IsAllDayEvent === FALSE === > ' + eachUpdatedEvent.IsAllDayEvent);
                        
                        //Scenario-1a: if already scheduled org event is not an all-day event
                        if (eachUpdatedEvent.Id != eachOrgEvent.Id && eachOrgEvent.IsAllDayEvent == false
                            && ((eachOrgEventStartDateTimeMinus1Hour <= eachUpdatedEvent.StartDateTime && eachUpdatedEvent.EndDateTime <= eachOrgEventEndDateTimePlus1Hour)
                                || (eachUpdatedEvent.StartDateTime < eachOrgEventStartDateTimeMinus1Hour && eachUpdatedEvent.EndDateTime > eachOrgEventStartDateTimeMinus1Hour && eachUpdatedEvent.EndDateTime <= eachOrgEventEndDateTimePlus1Hour)
                                || (eachUpdatedEvent.EndDateTime > eachOrgEventEndDateTimePlus1Hour && eachUpdatedEvent.StartDateTime >= eachOrgEventStartDateTimeMinus1Hour && eachUpdatedEvent.StartDateTime < eachOrgEventEndDateTimePlus1Hour)
                                || (eachUpdatedEvent.StartDateTime < eachOrgEventStartDateTimeMinus1Hour && eachUpdatedEvent.EndDateTime > eachOrgEventEndDateTimePlus1Hour))) {
                                    System.debug('************ Scenario-1a: Org event with IsAllDayEvent == FALSE === > ' + eachOrgEvent.IsAllDayEvent);
                                    eachUpdatedEvent.addError(System.Label.Event_Custom_Error_Message);
                                    System.debug('************ CUSTOM ERROR MESSAGE WAS THROWN HERE ************');
                                }
                        
                        //Scenario-1b: if already scheduled org event is an all-day event and new event's start time and end time (GMT) condition - 1
                        else if (eachUpdatedEvent.Id != eachOrgEvent.Id && eachOrgEvent.IsAllDayEvent == true
                                 && ((dayEndHour <= eachUpdatedEventStartGMTHour && eachUpdatedEventStartGMTHour <= 23) || (dayEndHour < eachUpdatedEventEndGMTHour && eachUpdatedEventEndGMTHour <= 23))
                                 && ((eachOrgEventStartGMTDate <= eachUpdatedEventStartGMTDate && eachUpdatedEventStartGMTDate <= eachOrgEventEndGMTDate)
                                     || (eachOrgEventStartGMTDate <= eachUpdatedEventEndGMTDate && eachUpdatedEventEndGMTDate <= eachOrgEventEndGMTDate))) {
                                         System.debug('************ Scenario-1b: Org event with IsAllDayEvent == TRUE === > ' + eachOrgEvent.IsAllDayEvent);
                                         System.debug('************ ' + dayEndHour + ' <= Updated Event Start Hour <= 23 OR ' + dayEndHour + ' < Updated Event End Hour <= 23');
                                         eachUpdatedEvent.addError(System.Label.Event_Custom_Error_Message);
                                         System.debug('************ CUSTOM ERROR MESSAGE WAS THROWN HERE ************');
                                     }
                        
                        //Scenario-1c: if already scheduled org event is an all-day event and new event's start time and end time (GMT) condition - 2
                        else if (eachUpdatedEvent.Id != eachOrgEvent.Id && eachOrgEvent.IsAllDayEvent == true
                                 && ((0 <= eachUpdatedEventStartGMTHour && eachUpdatedEventStartGMTHour < dayEndHour) || (0 < eachUpdatedEventEndGMTHour &&  eachUpdatedEventEndGMTHour < dayEndHour))
                                 && ((eachOrgEventStartGMTDatePlus1 <= eachUpdatedEventStartGMTDate && eachUpdatedEventStartGMTDate <= eachOrgEventEndGMTDatePlus1)
                                     || (eachOrgEventStartGMTDatePlus1 <= eachUpdatedEventEndGMTDate && eachUpdatedEventEndGMTDate <= eachOrgEventEndGMTDatePlus1))) {
                                         System.debug('************ Scenario-1b: Org event with IsAllDayEvent == TRUE === > ' + eachOrgEvent.IsAllDayEvent);
                                         System.debug('************ 0 <= Updated Event Start Hour < ' + dayEndHour + ' OR 0 < Updated Event End Hour < ' + dayEndHour + '************');
                                         eachUpdatedEvent.addError(System.Label.Event_Custom_Error_Message);
                                         System.debug('************ CUSTOM ERROR MESSAGE WAS THROWN HERE ************');
                                     }
                    }
                    
                    //Scenario-2: if the updated event is an all-day event and is falling within or spanning an already scheduled org event
                    if (eachUpdatedEvent.IsAllDayEvent == true && mapRoomsAndListEvents.containsKey(eachUpdatedEvent.Subject)) {
                        System.debug('************ Scenario-2: Updated event with IsAllDayEvent === TRUE === > ' + eachUpdatedEvent.IsAllDayEvent);
                        
                        //Scenario-2a: If the org event is not an all-day event and it's start time and end time (GMT) condition - 1
                        if (eachUpdatedEvent.Id != eachOrgEvent.Id && eachOrgEvent.IsAllDayEvent == false
                            && ((dayEndHour <= eachOrgEventStartGMTHour && eachOrgEventStartGMTHour <= 23) || (dayEndHour < eachOrgEventEndGMTHour &&  eachOrgEventEndGMTHour <= 23))
                            && (eachUpdatedEventStartGMTDate <= eachOrgEventStartGMTDate && eachOrgEventEndGMTDate <= eachUpdatedEventEndGMTDate)) {
                                System.debug('************ Scenario-2a: ' + dayEndHour + ' <= Org Event Start Hour <= 23 OR ' + dayEndHour + ' < Org Event End Hour <= 23');
                                eachUpdatedEvent.addError(System.Label.Event_Custom_Error_Message);
                                System.debug('************ CUSTOM ERROR MESSAGE WAS THROWN HERE ************');
                            }
                        
                        //Scenario-2b: If the org event is not an all-day event and it's start time and end time (GMT) condition - 2
                        else if (eachUpdatedEvent.Id != eachOrgEvent.Id && eachOrgEvent.IsAllDayEvent == false
                                 && ((0 <= eachOrgEventStartGMTHour && eachOrgEventStartGMTHour < dayEndHour) || (0 <= eachOrgEventEndGMTHour &&  eachOrgEventEndGMTHour < dayEndHour))
                                 && ((eachUpdatedEventStartGMTDatePlus1 <= eachOrgEventStartGMTDate && eachOrgEventEndGMTDate <= eachUpdatedEventEndGMTDatePlus1))
                                 ||(eachUpdatedEventStartGMTDate == eachOrgEventStartGMTDate && eachOrgEventEndGMTDate == eachUpdatedEventEndGMTDatePlus1)){
                                     System.debug('************ Scenario-2b: 0 <=  Org Event Start Hour < ' + dayEndHour + ') OR 0 <= Org Event End Hour < '+ dayEndHour);
                                     eachUpdatedEvent.addError(System.Label.Event_Custom_Error_Message);
                                     System.debug('************ CUSTOM ERROR MESSAGE WAS THROWN HERE ************');
                                 }
                        
                        //Scenario-2c: If the org event is an all-day event
                        else if (eachUpdatedEvent.Id != eachOrgEvent.Id && eachOrgEvent.IsAllDayEvent == true
                                 && (eachUpdatedEventStartGMTDate <= eachOrgEventStartGMTDate && eachOrgEventEndGMTDate <= eachUpdatedEventEndGMTDate)) {
                                     System.debug('************ Scenario-2c: Org event with IsAllDayEvent === TRUE === > ' + eachOrgEvent.IsAllDayEvent);
                                     eachUpdatedEvent.addError(System.Label.Event_Custom_Error_Message);
                                     System.debug('************ CUSTOM ERROR MESSAGE WAS THROWN HERE ************');
                                 }
                    }
                }
            }
        }
    }
}