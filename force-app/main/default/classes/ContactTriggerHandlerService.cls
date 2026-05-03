public with sharing class ContactTriggerHandlerService {
    
    public static void processContact(List<Contact> contactList){

        Set<Id> contactIds = new Set<Id>();
        for(Contact contact : contactList){
            contactIds.add(contact.Id);
        }

        System.enqueueJob(new queueEmailValidation(contactIds));

    }
}