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
* 1.1            10/03/2024      Tyler K.          All-Day Event Field Check
* ____________________________________________________________________________________
*/

@isTest
private class EventTriggerHandlerTest {
    @testSetup
    static void testSetup() {
        
        List<event> listEvents = new List<Event>{
                //events for Insert
                new event(Subject = 'Board Room', isAllDayEvent = false, StartDateTime = Datetime.now().addHours(0), EndDateTime = Datetime.now().addHours(2)),
                new event(Subject = 'Board Room', isAllDayEvent = true, StartDateTime = Date.newInstance(2024, 03, 10), EndDateTime = Date.newInstance(2024, 03, 10)),
                new event(Subject = 'Board Room', isAllDayEvent = true, StartDateTime = Date.newInstance(2024, 03, 12), EndDateTime = Date.newInstance(2024, 03, 13)),
                new event(Subject = 'Board Room', isAllDayEvent = false, StartDateTime = DateTime.newInstance(2024, 03, 11, 5, 0, 0), EndDateTime = DateTime.newInstance(2024, 03, 11, 10, 0, 0)),
                new event(Subject = 'Board Room', isAllDayEvent = false, StartDateTime = DateTime.newInstance(2024, 03, 25, 19, 0, 0), EndDateTime = DateTime.newInstance(2024, 03, 25, 20, 0, 0)),
                //events for update
                new event(Subject = 'Trillium', isAllDayEvent = false, StartDateTime = Datetime.now().addHours(0), EndDateTime = Datetime.now().addHours(1)),
                new event(Subject = 'Trillium', isAllDayEvent = false, StartDateTime = Datetime.now().addHours(3), EndDateTime = Datetime.now().addHours(4)),
                new event(Subject = 'Trillium', isAllDayEvent = true, StartDateTime = Date.newInstance(2024, 03, 18), EndDateTime = Date.newInstance(2024, 03, 18)),
                new event(Subject = 'Trillium', isAllDayEvent = false, StartDateTime = DateTime.newInstance(2024, 03, 19, 5, 0, 0), EndDateTime = DateTime.newInstance(2024, 03, 19, 10, 0, 0)),
                new event(Subject = 'Trillium', isAllDayEvent = false, StartDateTime = DateTime.newInstance(2024, 03, 20, 5, 0, 0), EndDateTime = DateTime.newInstance(2024, 03, 20, 10, 0, 0)),
                new event(Subject = 'Trillium', isAllDayEvent = true, StartDateTime = Date.newInstance(2024, 03, 21), EndDateTime = Date.newInstance(2024, 03, 21)),
                new event(Subject = 'Trillium', isAllDayEvent = true, StartDateTime = DateTime.newInstance(2024, 03, 22, 0, 0, 0), EndDateTime = DateTime.newInstance(2024, 03, 22, 0, 0, 0)),
                new event(Subject = 'Trillium', isAllDayEvent = false, StartDateTime = DateTime.newInstance(2024, 03, 23, 22, 0, 0), EndDateTime = DateTime.newInstance(2024, 03, 23, 23, 0, 0)),
                new event(Subject = 'Trillium', isAllDayEvent = false, StartDateTime = DateTime.newInstance(2024, 03, 26, 19, 0, 0), EndDateTime = DateTime.newInstance(2024, 03, 26, 20, 0, 0)),
                new event(Subject = 'Trillium', isAllDayEvent = true, StartDateTime = DateTime.newInstance(2024, 03, 27, 0, 0, 0), EndDateTime = DateTime.newInstance(2024, 03, 27, 0, 0, 0)),
                new event(Subject = 'Trillium', isAllDayEvent = true, StartDateTime = DateTime.newInstance(2024, 03, 28, 0, 0, 0), EndDateTime = DateTime.newInstance(2024, 03, 28, 0, 0, 0)),
                new event(Subject = 'Trillium', isAllDayEvent = true, StartDateTime = DateTime.newInstance(2024, 03, 29, 0, 0, 0), EndDateTime = DateTime.newInstance(2024, 03, 29, 0, 0, 0))
                };
                    insert listEvents;
    }
    
    @isTest
    static void testEventTriggerHandlerBeforeInsert() {
        Boolean exceptionThrown = false;
        
        List<event> listEvents = new List<Event>{
            new event(Subject = 'Board Room', isAllDayEvent = false, StartDateTime = Datetime.now().addHours(0), EndDateTime = Datetime.now().addHours(2)),
                new event(Subject = 'Board Room', isAllDayEvent = false, StartDateTime = Datetime.now().addHours(-2), EndDateTime = Datetime.now().addHours(2)),
                new event(Subject = 'Board Room', isAllDayEvent = false, StartDateTime = Datetime.now().addHours(0), EndDateTime = Datetime.now().addHours(4)),
                new event(Subject = 'Board Room', isAllDayEvent = false, StartDateTime = Datetime.now().addHours(-2), EndDateTime = Datetime.now().addHours(4)),
                new event(Subject = 'Board Room', isAllDayEvent = false, StartDateTime = DateTime.newInstance(2024, 03, 10, 19, 0, 0), EndDateTime = DateTime.newInstance(2024, 03, 10, 20, 0, 0)),
                new event(Subject = 'Board Room', isAllDayEvent = false, StartDateTime = DateTime.newInstance(2024, 03, 11, 0, 0, 0), EndDateTime = DateTime.newInstance(2024, 03, 13, 5, 0, 0)),
                new event(Subject = 'Board Room', isAllDayEvent = true, StartDateTime = DateTime.newInstance(2024, 03, 11, 0, 0, 0), EndDateTime = DateTime.newInstance(2024, 03, 13, 0, 0, 0)),
                new event(Subject = 'Board Room', isAllDayEvent = true, StartDateTime = DateTime.newInstance(2024, 03, 25, 0, 0, 0), EndDateTime = DateTime.newInstance(2024, 03, 25, 0, 0, 0))
                };    
                    
                    try {
                        Test.startTest();
                        insert listEvents;
                        Test.stopTest();
                    } catch (Exception e) {
                        exceptionThrown = true;
                        Boolean expectedExceptionThrown = (e.getMessage().contains('Conflict:')) ? true : false;
                        Assert.areEqual(true, expectedExceptionThrown, e.getMessage());
                    }
        Assert.areEqual(true, exceptionThrown, 'No exception was thrown');
    }
    
    @isTest
    static void testEventTriggerHandlerBeforeUpdate() {
        List<Event> testEvents = [SELECT Subject, StartDateTime, EndDateTime FROM Event];
        Boolean exceptionThrown = false;
        
        testEvents[6].StartDateTime = Datetime.now().addHours(-2);
        testEvents[8].StartDateTime = DateTime.newInstance(2024, 03, 18, 5, 0, 0);
        testEvents[8].EndDateTime = DateTime.newInstance(2024, 03, 18, 10, 0, 0);
        testEvents[10].StartDateTime = DateTime.newInstance(2024, 03, 20, 0, 0, 0);
        testEvents[10].EndDateTime = DateTime.newInstance(2024, 03, 20, 0, 0, 0);
        testEvents[12].StartDateTime = DateTime.newInstance(2024, 03, 22, 22, 0, 0);
        testEvents[12].EndDateTime = DateTime.newInstance(2024, 03, 22, 23, 0, 0);
        testEvents[14].StartDateTime = DateTime.newInstance(2024, 03, 26, 0, 0, 0);
        testEvents[14].EndDateTime = DateTime.newInstance(2024, 03, 26, 0, 0, 0);
        testEvents[16].StartDateTime = DateTime.newInstance(2024, 03, 28, 0, 0, 0);
        testEvents[16].EndDateTime = DateTime.newInstance(2024, 03, 28, 0, 0, 0);
        try {
            Test.startTest();
            update testEvents;
            Test.stopTest();
        } catch (Exception e) {
            exceptionThrown = true;
            Boolean expectedExceptionThrown = (e.getMessage().contains('Conflict:')) ? true : false;
            Assert.areEqual(true, expectedExceptionThrown, e.getMessage());
        }
        Assert.areEqual(true, exceptionThrown, 'No exception was thrown');
    }
}