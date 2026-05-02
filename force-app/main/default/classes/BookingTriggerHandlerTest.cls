@IsTest
public with sharing class BookingTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){
        List<Contact> contactList = TestDataFactory.createContacts(1);
        List<Car__c> carList = TestDataFactory.createCars(1);
        
    }

    @IsTest
    static void testAfterBookingClosed(){
        Car__c car = [SELECT Id, Total_Bookings_Value__c FROM Car__c LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Booking__c booking = new Booking__c();
        booking.Customer__c = contact.Id;
        booking.Car__c = car.Id;
        booking.Start_Date_Time__c = Date.today().addDays(2);
        booking.End_Date_Time__c = Date.today().addDays(6);
        booking.Status__c = Constants.BOOKING_PENDING_STATUS;
        booking.Payment_Status__c = Constants.BOOKING_PENDING_STATUS;
        booking.Final_Booking_Price__c = 500.00;
        insert booking;

        // Security Payment Transaction
        List<Payment_Transaction__c> paymentList = new List<Payment_Transaction__c>();
        System_Threshold__mdt st = System_Threshold__mdt.getInstance(Constants.SECURITY_DEPOSIT_THRESHOLD);
        Decimal securityDepositPercentage = Decimal.valueOf(st.value__c)/100;
        Decimal securityDepositAmount = booking.Final_Booking_Price__c * securityDepositPercentage;
        Payment_Transaction__c securityPayment = new Payment_Transaction__c();
        securityPayment.Booking__c = booking.Id;
        securityPayment.Amount__c = securityDepositAmount;
        securityPayment.Type__c = Constants.TYPE_SECURITY_DEPOSIT;
        securityPayment.Status__c = Constants.SUCCESS;
        securityPayment.Transaction_Date__c = DateTime.now();
        paymentList.add(securityPayment);

        //Rental Payment Transaction
        Payment_Transaction__c rentalPayment = new Payment_Transaction__c();
        rentalPayment.Booking__c = booking.Id;
        rentalPayment.Amount__c = booking.Final_Booking_Price__c;
        rentalPayment.Type__c = Constants.TYPE_PARTIAL_PAYMENT;
        rentalPayment.Status__c = Constants.SUCCESS;
        rentalPayment.Transaction_Date__c = DateTime.now();
        paymentList.add(rentalPayment);

        insert paymentList;

        // Update Booking Status to Closed
        test.startTest();
            booking.Status__c = Constants.BOOKING_CLOSED_STATUS;
            update booking;
        test.stopTest();

        Car__c updatedCar = [SELECT Id, Total_Bookings_Value__c FROM Car__c WHERE Id = :car.Id];
        Decimal expectedTotalBookingValue = booking.Final_Booking_Price__c;
        Decimal actualTotalBookingValue = updatedCar.Total_Bookings_Value__c;
        System.assertEquals(expectedTotalBookingValue, actualTotalBookingValue, 'Total Booking Value on Car is not updated correctly');

    }

    @IsTest
    static void testBookingOverlap(){
        Car__c car = [SELECT Id FROM Car__c LIMIT 1];
        Contact contact = [SELECT Id FROM Contact LIMIT 1];
        Booking__c firstBooking = new Booking__c();
        firstBooking.Customer__c = contact.Id;
        firstBooking.Car__c = car.Id;
        firstBooking.Start_Date_Time__c = Date.today().addDays(2);
        firstBooking.End_Date_Time__c = Date.today().addDays(6);
        firstBooking.Status__c = Constants.BOOKING_PENDING_STATUS;
        firstBooking.Payment_Status__c = Constants.BOOKING_PENDING_STATUS;
        firstBooking.Final_Booking_Price__c = 500.00;
        insert firstBooking;    

        Booking__c secondBooking = new Booking__c();
        secondBooking.Customer__c = contact.Id;
        secondBooking.Car__c = car.Id;
        secondBooking.Start_Date_Time__c = Date.today().addDays(7);
        secondBooking.End_Date_Time__c = Date.today().addDays(10);
        secondBooking.Status__c = Constants.BOOKING_PENDING_STATUS;
        secondBooking.Payment_Status__c = Constants.BOOKING_PENDING_STATUS;
        secondBooking.Final_Booking_Price__c = 400.00;
        insert secondBooking;

        Booking__c overlappingBooking = new Booking__c();
        overlappingBooking.Customer__c = contact.Id;
        overlappingBooking.Car__c = car.Id;
        overlappingBooking.Start_Date_Time__c = Date.today().addDays(5);
        overlappingBooking.End_Date_Time__c = Date.today().addDays(8);
        overlappingBooking.Status__c = Constants.BOOKING_PENDING_STATUS;
        overlappingBooking.Payment_Status__c = Constants.BOOKING_PENDING_STATUS;
        overlappingBooking.Final_Booking_Price__c = 400.00;
        Test.startTest();
            try {
                insert overlappingBooking;
                System.assert(false, 'Expected an exception due to booking overlap, but it was not thrown.');
            } catch (DmlException e) {
                System.assert(e.getMessage().contains(System.Label.Booking_Overlap_Message), 'Expected booking overlap error message, but got: ' + e.getMessage());
            }

        secondBooking.Start_Date_Time__c = Date.today().addDays(1);
        secondBooking.End_Date_Time__c = Date.today().addDays(4);
        try {            
            update secondBooking;
            System.assert(false, 'Expected an exception due to booking overlap on update, but it was not thrown.');
        } catch (DmlException e) {
            System.assert(e.getMessage().contains(System.Label.Booking_Overlap_Message), 'Expected booking overlap error message on update, but got: ' + e.getMessage());
        }
        Test.stopTest();
    }
}