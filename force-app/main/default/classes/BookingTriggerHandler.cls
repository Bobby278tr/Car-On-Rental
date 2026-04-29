public with sharing class BookingTriggerHandler extends TriggerHandler {
    
    override public void afterUpdate(){
        BookingTriggerHandlerService.updateTotalBookingValueForCar(Trigger.new, (Map<Id, Booking__c>)Trigger.oldMap);
    }
}