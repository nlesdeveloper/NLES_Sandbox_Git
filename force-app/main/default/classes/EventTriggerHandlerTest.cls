/*
 * @File Name    :   EventTriggerHandlerTest
 * @Description  :   Test Event Trigger and Handler for the Event object
 * @Date Created :   22/02/2024
 * @Author       :   Tyler K.
 * @Modification Log:
 * @User Story   :   Prevent double bookings for the Event object - 0001
 * ____________________________________________________________________________________
 * Ver       Date           Author                   Modification
 * 1.0       22/6/2024      Tyler K.                 Intial Version
 * ____________________________________________________________________________________
 */

@isTest
private class EventTriggerHandlerTest {
  @testSetup
  static void testSetup() {
    List<event> listEvents = new List<Event>{
      new event(Subject = 'Board Room', StartDateTime = Datetime.now().addHours(0), EndDateTime = Datetime.now().addHours(2)),
      new event(Subject = 'Trillium', StartDateTime = Datetime.now().addHours(0), EndDateTime = Datetime.now().addHours(2)),
      new event(Subject = 'Trillium', StartDateTime = Datetime.now().addHours(4), EndDateTime = Datetime.now().addHours(6)),
      new event(Subject = 'Trillium', StartDateTime = Datetime.now().addHours(8), EndDateTime = Datetime.now().addHours(10))};
    insert listEvents;
  }

  @isTest
  static void testEventTriggerHandlerBeforeInsert() {
    Boolean exceptionThrown = false;

    List<event> listEvents = new List<Event>{
      new event(Subject = 'Board Room', StartDateTime = Datetime.now().addHours(0), EndDateTime = Datetime.now().addHours(2)),
      new event(Subject = 'Board Room', StartDateTime = Datetime.now().addHours(1), EndDateTime = Datetime.now().addHours(4)),
      new event(Subject = 'Board Room', StartDateTime = Datetime.now().addHours(-2), EndDateTime = Datetime.now().addHours(1))};
      

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
    List<Event> testEvents = [
      SELECT Subject, StartDateTime, EndDateTime
      FROM Event
    ];
    Boolean exceptionThrown = false;

    testEvents[1].Subject = 'Trillium';
    testEvents[3].StartDateTime = Datetime.now().addHours(2);
    testEvents[3].EndDateTime = Datetime.now().addHours(8);

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