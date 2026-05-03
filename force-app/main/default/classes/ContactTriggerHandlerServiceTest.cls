@IsTest
public with sharing class ContactTriggerHandlerServiceTest {
    
    @TestSetup
    static void makeData(){
        List<Contact> contactList = TestDataFactory.createContacts(2);
    }

    @IsTest
    static void testContactForInsertOrUpdate(){
        // using the mock class to simulate the callout response
        Test.setMock(HttpCalloutMock.class, new EmailValidationHttpMock());
        List<Contact> contactList = [SELECT Id, Email_Verified__c FROM Contact ];
        for(Contact con : contactList){
            con.Email = 'test' + con.Id + '@example.com';
        }

        Test.startTest();
        update contactList;
        Test.stopTest();

        List<Contact> updatedContactList = [SELECT Id, Email_Verified__c FROM Contact ];
        for(Contact con : updatedContactList){
            System.assertEquals(true, con.Email_Verified__c, 'Email should be marked as verified');
        }

        
    }
}