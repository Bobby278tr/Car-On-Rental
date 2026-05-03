@RestResource(urlMapping='/v1/cars/available/*')
global with sharing class CarAvailabilityRestService {
    
    @HttpGet
    global static responseWrapper getAvailableCars(){
        // get the query parameters
        RestRequest request = RestContext.request;
        Date startDate = Date.valueOf(request.params.get('startDate'));
        Date endDate = Date.valueOf(request.params.get('endDate'));
        String fuelType = request.params.get('fuelType');
        String transmissionType = request.params.get('transmissionType');
        String location = request.params.get('location');

        if(startDate == null || endDate == null){
            return new responseWrapper(false, 'Start date and end date are required', null);
        }
        if(String.isBlank(location)){
            return new responseWrapper(false, 'Location is required', null);
        }

        // Start date should be before end date
        if(startDate > endDate){
            return new responseWrapper(false, 'Start date should be before end date', null);
        }

        // get booking recods for the same date range
        Set<Id> bookedCarIds = new Set<Id>();
        DateTime startDateTime = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
        DateTime endDateTime = DateTime.newInstance(endDate, Time.newInstance(23, 59, 59, 0));
       for(Booking__c booking : [SELECT Id, Car__c FROM Booking__c WHERE Start_Date_Time__c >= :startDateTime AND End_Date_Time__c <= :endDateTime]){
            bookedCarIds.add(booking.Car__c);
        }

        //build query for the available cars
        String available = Constants.AVAILABLE_CARS;
        String query = 'SELECT Id, Name, Fuel_Type__c, Transmission_Type__c, PickupLocation__c, Car_Description__c, Primary_Image_URL__c, Car_Family__c, Rental_Rate_Per_Day__c FROM Car__c ';
        query = query + 'WHERE Id NOT IN :bookedCarIds AND PickupLocation__c = :location AND  Availability_Status__c= :available';

        // add optional filters
        if(!String.isBlank(fuelType)){
            query = query + ' AND Fuel_Type__c = :fuelType';    
        }
        if(!String.isBlank(transmissionType)){
            query = query + ' AND Transmission_Type__c = :transmissionType';    
        }

        // execute the query and build the response
        List<Car__c> availableCars = Database.query(query);

        if(availableCars.isEmpty()){
            return new responseWrapper(false, 'No cars available for the selected criteria', null);
        }
        List<carResponseWrapper> carResponserapper = new List<carResponseWrapper>();
        for(Car__c car : availableCars){
            carResponserapper.add(new carResponseWrapper(car));
        }

        return new responseWrapper(true, 'Available cars retrieved successfully', carResponserapper);


    }
    
    global class responseWrapper{
        public Boolean success;
        public String message;
        public List<carResponseWrapper> availableCars;

        public responseWrapper(Boolean success, String message, List<carResponseWrapper> availableCars){
            this.success = success;
            this.message = message;
            this.availableCars = availableCars;
        }
    }

    global class carResponseWrapper{
        public String carId;
        public String name;
        public String fuelType;
        public String transmissionType;
        public String location;
        public String description;
        public String imageUrl;
        public String family;
        public Decimal rentalRate;
        public carResponseWrapper(Car__c car){
            this.carId = car.Id;
            this.name = car.Name;
            this.fuelType = car.Fuel_Type__c;
            this.transmissionType = car.Transmission_Type__c;
            this.location = car.PickupLocation__c;
            this.description = car.Car_Description__c;
            this.imageUrl = car.Primary_Image_Url__c;
            this.family = car.Car_Family__c;
            this.rentalRate = car.Rental_Rate_Per_Day__c;
        }

    }
}