@isTest
private class EventTriggerHandlerTest {
    @testSetup
    static void testSetup() {
        List<Event> newEvents = new List<Event>();
        for (Integer i = 0; i < 100; i++) {
            if(i<25){
            newEvents.add(new Event(Subject = 'Board Room', StartDateTime = Datetime.now().addHours(2), EndDateTime = Datetime.now().addHours(3)));
        }  else if(i<50){
            newEvents.add(new Event(Subject = 'Trillium', StartDateTime = Datetime.now().addHours(2), EndDateTime = Datetime.now().addHours(3)));
        }  else if(i<75){
            newEvents.add(new Event(Subject = 'Rose', StartDateTime = Datetime.now().addHours(2), EndDateTime = Datetime.now().addHours(3)));
        }else{
            newEvents.add(new Event(Subject = 'Tulip', StartDateTime = Datetime.now().addHours(2), EndDateTime = Datetime.now().addHours(3)));
        }
    }
    insert newEvents;
    System.debug(newEvents.size());

    }

    @isTest
    static void testEventTriggerHandlerBeforeInsert() {
        // Retrieve the test Event
        List<Event> testEvents = [SELECT Id, Subject, StartDateTime, EndDateTime FROM Event];
        System.debug(testEvents.size());

        // Call the EventTriggerHandler method
Test.startTest();
        EventTriggerHandler.eventTriggerHandlerBeforeInsert(new List<Event>{new Event(Subject = 'Board Room', StartDateTime = Datetime.now().addHours(2), EndDateTime = Datetime.now().addHours(3))});
Test.stopTest();

        // Assert that the Subject is updated correctly
        //Assert.assertEquals('Test Event', testEvent.Subject, 'Subject should not be changed');
    }
/*
    @isTest
    static void testEventTriggerHandlerBeforeUpdate() {
        // Retrieve the test Event
        Event testEvent = [SELECT Id, Subject, StartDateTime, EndDateTime FROM Event LIMIT 1];

        // Update the Subject
        testEvent.Subject = 'Test Event Updated';

        // Call the EventTriggerHandler method
        EventTriggerHandler.beforeUpdate(new List<Event>{testEvent}, new Map<Id, Event>{testEvent.Id => testEvent});

        // Assert that the Subject is updated correctly
        Event updatedEvent = [SELECT Id, Subject, StartDateTime, EndDateTime FROM Event WHERE Id = :testEvent.Id];
        System.assertEquals('Test Event Updated', updatedEvent.Subject, 'Subject should be updated');
    }
*/
}