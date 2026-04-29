public with sharing class BookingTriggerHandlerService {
    
    public static void updateTotalBookingValueForCar(List<Booking__c> bookings, Map<Id, Booking__c> oldBookingsMap ){

        Set<Id> carIds = new Set<Id>();
        for(Booking__c booking : bookings){
            String newBookingStatus = booking.Status__c;
            String oldBookingStatus = oldBookingsMap.get(booking.Id).Status__c;
            if(!newBookingStatus.equals(oldBookingStatus) && newBookingStatus == Constants.BOOKING_CLOSED_STATUS){
                carIds.add(booking.Car__c);
            }
        }

        if(carIds.isEmpty()) {return;}

        // Enqueue the job to update total booking value for cars
        System.enqueueJob(new QueueableTotalCarValue(carIds));
    }
}