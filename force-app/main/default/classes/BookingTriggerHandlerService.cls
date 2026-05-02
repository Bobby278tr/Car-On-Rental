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

    public static void validateBookingOverlap(List<Booking__c> bookings){
        Set<Id> carIds = new Set<Id>();
        Set<Id> existingBookingIds = new Set<Id>();
        for(Booking__c booking : bookings){
            carIds.add(booking.Car__c);
            if(String.isNotBlank(booking.Id)){
                existingBookingIds.add(booking.Id);
            }
        }

        Set<String> activeBookingStatuses = new Set<String>{Constants.BOOKING_PENDING_STATUS, Constants.BOOKING_CONFIRM_STATUS, Constants.BOOKING_STARTED_STATUS, Constants.BOOKING_COMPLETED_STATUS };

        String query = 'SELECT Id, Car__c, Start_Date_Time__c, End_Date_Time__c FROM Booking__c WHERE Car__c IN :carIds AND Status__c IN :activeBookingStatuses';
        if(!existingBookingIds.isEmpty()){
            query += ' AND Id NOT IN :existingBookingIds';
        }

        List<Booking__c> existingActiveBookings = Database.query(query);
        Map<Id, List<Booking__c>> carIdToBookingsMap = new Map<Id, List<Booking__c>>();

        for(Booking__c existingBooking : existingActiveBookings){
            if(!carIdToBookingsMap.containsKey(existingBooking.Car__c)){
                carIdToBookingsMap.put(existingBooking.Car__c, new List<Booking__c>());
            }
            List<Booking__c> overlappingBookings = carIdToBookingsMap.get(existingBooking.Car__c);
            overlappingBookings.add(existingBooking);
            carIdToBookingsMap.put(existingBooking.Car__c, overlappingBookings);
        }

        for(Booking__c newbooking : bookings){
            List<Booking__c> existingBookingList = carIdToBookingsMap.get(newbooking.Car__c);
            System.debug('Existing Bookings for Car ' + newbooking.Car__c + ': ' + existingBookingList);
            
            if(existingBookingList == null || existingBookingList.isEmpty()){
                continue; // No existing bookings for this car, so no overlap
            }
            for(Booking__c existingBooking : existingBookingList){
                Boolean isOverlap = hasOverlap(newbooking, existingBooking);
                if(isOverlap){
                    newbooking.addError(System.Label.Booking_Overlap_Message);
                    break; // No need to check further if we found an overlap
                }
            }
        }
    }

    public static boolean hasOverlap(Booking__c newBooking, Booking__c existingBooking){
        return newBooking.Start_Date_Time__c <= existingBooking.End_Date_Time__c && newBooking.End_Date_Time__c >= existingBooking.Start_Date_Time__c;
    }
}