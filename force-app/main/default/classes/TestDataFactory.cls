@IsTest
public with sharing class TestDataFactory {
    
    // create contacts
    public static List<Contact> createContacts(Integer numberOfContacts){
        List<Contact> contactList = new List<Contact>();
        for(Integer i=0; i<numberOfContacts; i++){
            Contact con = new Contact();
            con.FirstName = 'TestFirstName'+i;
            con.LastName = 'TestLastName'+i;
            con.Email = 'testemail'+i+'@test.com';
            contactList.add(con);
        }
        insert contactList;
        return contactList;
    }


    // create Cars
    public static List<Car__c> createCars(Integer numberOfCars){
        List<Car__c> carList = new List<Car__c>();
        for(Integer i=0; i<numberOfCars; i++){
            Car__c car = new Car__c();
            car.Name = 'TestCar'+i;
            car.Make__c = 'TATA';
            car.Model__c = 'Nexon';
            car.Fuel_Type__c = 'Petrol';
            car.Transmission_Type__c = 'Automatic';
            car.Year__c = 2020;
            car.Availability_Status__c = 'Available';
            car.Rental_Rate_Per_Day__c = 100;
            car.Mileage_Limit_Per_Day__c = 200;
            car.Number_of_Seats__c = 7;
            carList.add(car);
        }
        insert carList;
        return carList;
    }

    // create Bookings
    public static List<Booking__c> createBookings(Integer numberOfBookings, List<Contact> contacts, List<Car__c> cars){
        List<Booking__c> bookingList = new List<Booking__c>();
        for(Integer i=0; i<numberOfBookings; i++){
            Contact con = contacts[Math.mod(i, contacts.size())];
            Car__c car = cars[Math.mod(i, cars.size())];
            Booking__c booking = new Booking__c();
            booking.Customer__c = con.Id;
            booking.Car__c = car.Id;
            booking.Start_Date_Time__c = Date.today().addDays(1);
            booking.End_Date_Time__c = Date.today().addDays(5);
            booking.Status__c = Constants.BOOKING_PENDING_STATUS;
            booking.Payment_Status__c = Constants.BOOKING_PENDING_STATUS;
            booking.Final_Booking_Price__c = 500.00;
            bookingList.add(booking);
        }
        insert bookingList;
        return bookingList;
    }
}