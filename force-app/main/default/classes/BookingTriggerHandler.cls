public with sharing class BookingTriggerHandler extends TriggerHandler {

    override public void beforeInsert(){
        BookingTriggerHandlerService.validateBookingOverlap(Trigger.new);
    }

    override public void beforeUpdate(){
        List<Booking__c> bookings = Trigger.new;
        Map<Id, Booking__c> oldBookingsMap = (Map<Id, Booking__c>)Trigger.oldMap;
        List<Booking__c> bookingsToValidate = new List<Booking__c>();
        for(Booking__c booking : bookings){
            String newCarId = booking.Car__c;
            String oldCarId = oldBookingsMap.get(booking.Id).Car__c;
            DateTime newStartDateTime = booking.Start_Date_Time__c;
            DateTime oldStartDateTime = oldBookingsMap.get(booking.Id).Start_Date_Time__c;
            DateTime newEndDateTime = booking.End_Date_Time__c;
            DateTime oldEndDateTime = oldBookingsMap.get(booking.Id).End_Date_Time__c;
            if(newCarId != oldCarId || newStartDateTime != oldStartDateTime || newEndDateTime != oldEndDateTime){
                bookingsToValidate.add(booking);
            } 
        }
        if(!bookingsToValidate.isEmpty()){
            BookingTriggerHandlerService.validateBookingOverlap(bookingsToValidate);
        }
    }
    
    override public void afterUpdate(){
        BookingTriggerHandlerService.updateTotalBookingValueForCar(Trigger.new, (Map<Id, Booking__c>)Trigger.oldMap);
    }
}