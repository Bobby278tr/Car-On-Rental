public with sharing class carTileListController {
    
    public class Filters{
        @AuraEnabled public String searchKey{get; set;}
        @AuraEnabled public Integer maxSeats{get; set;}
        @AuraEnabled public Date startDate{get; set;}
        @AuraEnabled public Date endDate{get; set;}
        @AuraEnabled public Decimal maxRentalRate{get; set;}
        @AuraEnabled public Decimal minRating{get; set;}
        @AuraEnabled public String pickupLocation{get; set;}
        @AuraEnabled public List<String> transmissionType{get; set;}
        @AuraEnabled public List<String> fuelType{get; set;}
    }

    @AuraEnabled
    public static List<Car__c> getCars(Filters filters){
        try {
            List<String> criteria = new List<String>();
            String key, pickupLocation;
            Decimal maxSeat, maxRentalRate,  minRating;
            List<String> transmissionType, fuelType ;
           // defaut filter criteria
           String availableCars = Constants.AVAILABLE_CARS;
           criteria.add('Availability_Status__c = :availableCars');

           //Optional Parameters
           If(String.isNotBlank(filters.searchKey)){
                key = '%' + filters.searchKey+'%';
                criteria.add('Name like :key');
           }
           If(filters.maxSeats != null){
                maxSeat = filters.maxSeats;
                criteria.add('Number_of_Seats__c <= :maxSeat');
           }
           If(filters.maxRentalRate != null){
                maxRentalRate = filters.maxRentalRate;
                criteria.add('Rental_Rate_Per_Day__c <= :filters.maxRentalRate');
           }
           If(filters.minRating != null){
                minRating = filters.minRating;
                if(minRating == 0){
                    criteria.add('Average_Rating__c = null OR Average_Rating__c >= 0');
                }else{
                    criteria.add('Average_Rating__c >= :filters.minRating');
                }
           }
           If(String.isNotBlank(filters.pickupLocation)){
                pickupLocation = filters.pickupLocation;
                criteria.add('PickupLocation__c = :pickupLocation');
           }

           If(filters.transmissionType !=null && !filters.transmissionType.isEmpty()){
                transmissionType = filters.transmissionType;
                criteria.add('Transmission_Type__c IN :transmissionType');
           }
           If(filters.fuelType !=null && !filters.fuelType.isEmpty()){
                fuelType = filters.fuelType;
                criteria.add('Fuel_Type__c IN :fuelType');
           }

           DateTime starDateTime = DateTime.newInstance(filters.startDate, Time.newInstance(0, 0, 0, 0));
           DateTime endDateTime = DateTime.newInstance(filters.endDate, Time.newInstance(23, 59, 59, 0));
           Set<Id> bookedCarIds = new Set<Id>();

           //get booking between the start date and end date and we are excluding the cars which are having the booking
           for(Booking__c booking : [SELECT id, Car__c FROM Booking__c where Start_Date_Time__c >= :starDateTime AND End_Date_Time__c <= :endDateTime]){
                bookedCarIds.add(booking.Car__c);
           }
           if(!bookedCarIds.isEmpty()){
                criteria.add('Id NOT IN :bookedCarIds');
           }

           String query = 'SELECT Id, Average_Rating__c, Car_Description__c, Car_Family__c, Fuel_Type__c, Make__c, Mileage_Limit_Per_Day__c, Model__c , Name, Number_of_Seats__c, PickupLocation__c, Primary_Image_Url__c, Rental_Rate_Per_Day__c, Transmission_Type__c from Car__c';
           String whereClause = ' WHERE '+ String.JOIN(criteria, ' AND ');
           query = query + whereClause;
           query +=' order by Name ';

           System.debug('Query ' + query);
           return Database.query(query);

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}