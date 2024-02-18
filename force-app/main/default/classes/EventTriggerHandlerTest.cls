@isTest
private class EventTriggerHandlerTest {
    @testSetup
    static void testSetup() {
        List<Event> newEvents = new List<Event>();
        for (Integer i = 0; i < 100; i++) {
            if(i<50){
                newEvents.add(new Event(Subject = 'Board Room', StartDateTime = Datetime.now().addHours(2), EndDateTime = Datetime.now().addHours(3)));
            }  else{
                newEvents.add(new Event(Subject = 'Trillium', StartDateTime = Datetime.now().addHours(2), EndDateTime = Datetime.now().addHours(3)));
            }
            insert newEvents;
        }
    }
    
    @isTest
    static void testEventTriggerHandlerBeforeInsert() {
        // Retrieve the test Event
        List<Event> testEvents = [SELECT Id, Subject, StartDateTime, EndDateTime FROM Event];
        Boolean exceptionThrown = false;
        // Call the EventTriggerHandler method
        try{
            Test.startTest();
            EventTriggerHandler.eventTriggerHandlerBeforeInsert(new List<Event>{new Event(Subject = 'Board Room', StartDateTime = Datetime.now().addHours(2), EndDateTime = Datetime.now().addHours(3))});
            Test.stopTest();
        }catch (Exception e){
            exceptionThrown = true;
            // assert
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Conflict:')) ? true : false; 
            Assert.areEqual(true, expectedExceptionThrown, e.getMessage()); 
        }
        Assert.areEqual(true, exceptionThrown, 'No exception was thrown');
    }
}