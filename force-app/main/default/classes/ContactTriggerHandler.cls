public with sharing class ContactTriggerHandler extends triggerHandler {
    
    override public void afterInsert(){
        List<Contact> contactList = (List<Contact>)Trigger.new;
        ContactTriggerHandlerService.processContact(contactList);
    }

    override public void afterUpdate(){
        List<Contact> contactList = (List<Contact>)Trigger.new;
        Map<Id, Contact> oldContactMap = (Map<Id, Contact>)Trigger.oldMap;
        List<Contact> contactToProcess = new List<Contact>();
        for(Contact contact : contactList){
            Contact oldContact = oldContactMap.get(contact.Id);
            if(contact.Email != oldContact.Email){
                contactToProcess.add(contact);
            }
        }

        if(!contactToProcess.isEmpty()){
            ContactTriggerHandlerService.processContact(contactToProcess);
        }
    }
}