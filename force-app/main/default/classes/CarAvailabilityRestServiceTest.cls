@IsTest
public with sharing class CarAvailabilityRestServiceTest {
    
    @TestSetup
    static void makeData(){
        List<Contact> conList = TestDataFactory.createContacts(2);
        List<Car__c> carList = TestDataFactory.createCars(4);
        List<Booking__c> bookingList = TestDataFactory.createBookings(1, conList, carList);

    }

    @IsTest
    static void testGetAvailableCars(){
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        
        RestContext.request = req;
        RestContext.response = res;
        req.params.put('startDate', formateDate(Date.today().addDays(1)));
        req.params.put('endDate', formateDate(Date.today().addDays(5)));
        req.params.put('location', 'Pune');
        req.params.put('fuelType', 'Petrol');
        req.params.put('transmissionType', 'Automatic');

        CarAvailabilityRestService.responseWrapper response = CarAvailabilityRestService.getAvailableCars();

        Test.stopTest();
        System.assert(response != null, 'Response should not be null');
        System.assertEquals(true, response.success, 'Response should be successful');
        System.assertEquals(true, response.availableCars != null, 'Cars list should not be null');
        System.assertEquals(3, response.availableCars.size(), 'There should be 3 available cars');
    }

    private static String formateDate(Date inpdate){
        return inpdate.year() + '-' + inpdate.month() + '-' + inpdate.day();
    }
}