@IsTest
public with sharing class PaymentTransactionTriggerHandlerTest {

    @TestSetup
    static void makeData(){
        List<Contact> contactList = TestDataFactory.createContacts(2);
        List<Car__c> carList = TestDataFactory.createCars(2);
        List<Booking__c> bookingList = TestDataFactory.createBookings(2, contactList, carList);
    }

    @IsTest
    static void testBookigAndPaymentStatus(){
        Booking__c bookings = [SELECT Id, Status__c, Payment_Status__c FROM Booking__c LIMIT 1];

        // create Payment Transction Record
        Payment_Transaction__c pt = new Payment_Transaction__c();
        pt.Booking__c = bookings.Id;
        pt.Amount__c = 250;
        pt.Type__c = Constants.TYPE_INITIAL_PAYMENT;
        pt.Status__c = Constants.SUCCESS;
        pt.Transaction_Date__c = DateTime.now();
        insert pt;

        String expectedPaymentStatus = Constants.BOOKING_PARTIAL_PAID;
        String expectedBookingStatus = Constants.BOOKING_CONFIRM_STATUS;

        Booking__c updatedBooking = [SELECT Id, Status__c, Payment_Status__c FROM Booking__c WHERE Id = :bookings.Id ];

        System.assertEquals(expectedPaymentStatus, updatedBooking.Payment_Status__c, 'Payment Status is not updated correctly');
        System.assertEquals(expectedBookingStatus, updatedBooking.Status__c, 'Booking Status is not updated correctly');

        // Remaining Rental Payment
        Payment_Transaction__c partialPayment = new Payment_Transaction__c();
        partialPayment.Booking__c = bookings.Id;
        partialPayment.Amount__c = 250;
        partialPayment.Type__c = Constants.TYPE_PARTIAL_PAYMENT;
        partialPayment.Status__c = Constants.SUCCESS;
        partialPayment.Transaction_Date__c = DateTime.now();

        //Security Deposite Payment
        Payment_Transaction__c securityPayment = new Payment_Transaction__c();
        securityPayment.Booking__c = bookings.Id;
        securityPayment.Amount__c = 100;
        securityPayment.Type__c = Constants.TYPE_SECURITY_DEPOSIT;
        securityPayment.Status__c = Constants.SUCCESS;
        securityPayment.Transaction_Date__c = DateTime.now();

        // store the transaction in collection
        List<Payment_Transaction__c> paymentList = new List<Payment_Transaction__c>{partialPayment, securityPayment};

        // DML Operations
        insert paymentList;

        //validate the result 
        updatedBooking = [SELECT Id, Status__c, Payment_Status__c FROM Booking__c WHERE Id = :bookings.Id ];
        expectedPaymentStatus = Constants.BOOKING_PAID;

        System.assertEquals(expectedPaymentStatus, updatedBooking.Payment_Status__c, 'Payment Status is not updated correctly');

        List<Payment_Transaction__c> securityTransaction = [Select Id from Payment_Transaction__c WHERE Booking__c = :bookings.Id AND Type__c = :Constants.TYPE_SECURITY_DEPOSIT];
        delete securityTransaction;

        updatedBooking = [SELECT Id, Status__c, Payment_Status__c FROM Booking__c WHERE Id = :bookings.Id ];
        System.assertEquals(Constants.BOOKING_PARTIAL_PAID, updatedBooking.Payment_Status__c, 'Payment Status after deleting Security Deposit is not correct');
    }
}