@isTest
private class EventTriggerHandlerTest {
    @testSetup
    static void testSetup() {
        List<event> listEvents = new List<Event>{
            new event(Subject = 'Board Room', StartDateTime = Datetime.now().addHours(0), EndDateTime = Datetime.now().addHours(2)), 
            new event(Subject = 'Board Room', StartDateTime = Datetime.now().addHours(6), EndDateTime = Datetime.now().addHours(8)),
            new event(Subject = 'Trillium', StartDateTime = Datetime.now().addHours(0), EndDateTime = Datetime.now().addHours(2)), 
            new event(Subject = 'Trillium', StartDateTime = Datetime.now().addHours(6), EndDateTime = Datetime.now().addHours(8))
        };
        insert listEvents;
    }
    
    @isTest
    static void testEventTriggerHandlerBeforeInsert() {
        Boolean exceptionThrown = false;
        
        List<event> listEvents = new List<Event>{
            new event(Subject = 'Board Room', StartDateTime = Datetime.now().addHours(1), EndDateTime = Datetime.now().addHours(4)), 
            new event(Subject = 'Trillium', StartDateTime = Datetime.now().addHours(-2), EndDateTime = Datetime.now().addHours(1))};

        try{
            Test.startTest();
            insert listEvents;
            Test.stopTest();
        }catch (Exception e){
            exceptionThrown = true;
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Conflict:')) ? true : false; 
            Assert.areEqual(true, expectedExceptionThrown, e.getMessage()); 
        }
        Assert.areEqual(true, exceptionThrown, 'No exception was thrown');
    }

    @isTest
    static void testEventTriggerHandlerBeforeUpdate() {
        List<Event> testEvents = [SELECT Subject, StartDateTime, EndDateTime FROM Event];
        Boolean exceptionThrown = false;
        
        testEvents[1].Subject = 'Trillium';
        testEvents[2].StartDateTime = Datetime.now().addHours(2);
        testEvents[3].EndDateTime = Datetime.now().addHours(6);

        try{
            Test.startTest();
            update testEvents;
            Test.stopTest();
        }catch (Exception e){
            exceptionThrown = true;
            Boolean expectedExceptionThrown =  (e.getMessage().contains('Conflict:')) ? true : false; 
            Assert.areEqual(true, expectedExceptionThrown, e.getMessage()); 
        }
        Assert.areEqual(true, exceptionThrown, 'No exception was thrown');
    }
}