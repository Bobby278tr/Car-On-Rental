@IsTest
public with sharing class ReviewTriggerHandlerTest {
    
    @TestSetup
    static void makeData(){
        List<Contact> contacts = TestDataFactory.createContacts(1);
        List<Car__c> cars = TestDataFactory.createCars(1);
        List<Booking__c> bookings = TestDataFactory.createBookings(1, contacts, cars);
    }

    @IsTest
    static void testInsertReviewTriggerHandlerForNegartiveRating(){
        List<Booking__c> bookings = [SELECT Id, Customer__c FROM Booking__c Limit 1];

        Test.startTest();
            List<Review__c> reviews = TestDataFactory.createReviews(1, bookings, 2);
        Test.stopTest();

        // Asserting if the booking is shared with customer support group
        Group customerSupportGroup = [SELECT Id FROM Group WHERE DeveloperName = :Constants.CUSTOMER_SUPPORT_PUBLIC_GROUP LIMIT 1];
        List<Booking__Share> bookingShares = [SELECT Id FROM Booking__Share WHERE ParentId = :bookings[0].Id AND UserOrGroupId = :customerSupportGroup.Id AND RowCause = :Schema.Booking__Share.RowCause.Manual];
        System.assertEquals(1, bookingShares.size(), 'Booking should be shared with customer support group');   

        // Asserting if the case is created for low rating review
        Id reviewIssueRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.NEGATIVE_REVIEW_RECORD_TYPE).getRecordTypeId();
        List<Case> cases = [SELECT Id FROM Case WHERE RecordTypeId = :reviewIssueRecordTypeId AND Review_Id__c = :reviews[0].Id AND Type = :Constants.NEGATIVE_REVIEW_CASE_TYPE];
        System.assertEquals(1, cases.size(), 'Case should be created for low rating review');

    }

    @IsTest
    static void testUpdateReviewTriggerHandlerForNegartiveRating(){
        List<Booking__c> bookings = [SELECT Id, Customer__c FROM Booking__c Limit 1];

        List<Review__c> reviews = TestDataFactory.createReviews(1, bookings, 4);

        // Asserting if the booking is shared with customer support group
        Group customerSupportGroup = [SELECT Id FROM Group WHERE DeveloperName = :Constants.CUSTOMER_SUPPORT_PUBLIC_GROUP LIMIT 1];
        List<Booking__Share> bookingShares = [SELECT Id FROM Booking__Share WHERE ParentId = :bookings[0].Id AND UserOrGroupId = :customerSupportGroup.Id AND RowCause = :Schema.Booking__Share.RowCause.Manual];
        System.assertEquals(0, bookingShares.size(), 'Booking should not be shared with customer support group');   

        // Asserting if the case is created for low rating review
        Id reviewIssueRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.NEGATIVE_REVIEW_RECORD_TYPE).getRecordTypeId();
        List<Case> cases = [SELECT Id FROM Case WHERE RecordTypeId = :reviewIssueRecordTypeId AND Review_Id__c = :reviews[0].Id AND Type = :Constants.NEGATIVE_REVIEW_CASE_TYPE];
        System.assertEquals(0, cases.size(), 'Case should not be created for low rating review');

        Test.startTest();
            reviews[0].Rating__c = 2;
            update reviews;
        Test.stopTest();

        // Asserting if the booking is shared with customer support group
        bookingShares = [SELECT Id FROM Booking__Share WHERE ParentId = :bookings[0].Id AND UserOrGroupId = :customerSupportGroup.Id AND RowCause = :Schema.Booking__Share.RowCause.Manual];
        System.assertEquals(1, bookingShares.size(), 'Booking should be shared with customer support group');   

        // Asserting if the case is created for low rating review
        cases = [SELECT Id FROM Case WHERE RecordTypeId = :reviewIssueRecordTypeId AND Review_Id__c = :reviews[0].Id AND Type = :Constants.NEGATIVE_REVIEW_CASE_TYPE];
        System.assertEquals(1, cases.size(), 'Case should be created for low rating review');

    }
}