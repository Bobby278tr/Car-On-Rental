public with sharing class queueEmailValidation implements Queueable, Database.AllowsCallouts {

    private Set<Id> contactIds;
    
    public queueEmailValidation(Set<Id> contactIds){
        this.contactIds = contactIds;
    }
    
    public void execute(QueueableContext context) {
        List<Contact> contactToUpdate = new List<Contact>();
        List<Contact> contactList = [SELECT Id, Email FROM Contact WHERE Id IN :contactIds];
        for(Contact contact : contactList){
            Boolean isValid = isEmailValid(contact.Email);
            Contact contactRecord = new Contact(Id = contact.Id);
            contactRecord.Email_Verified__c = isValid;
            contactToUpdate.add(contactRecord);
        }
        try {
            if(!contactToUpdate.isEmpty()){
                update contactToUpdate;
            }
        } catch (Exception ex) {
            Log logger = Log.get();
            logger.publish('An error occurred while updating contact email verification status. Error: ' + ex.getMessage());
        }
    }

    private static Boolean isEmailValid(String email) {
        
        //get the api from the system threshold metadata
        System_Threshold__mdt emailReputationMdt = System_Threshold__mdt.getInstance('Email_Reputation');
        String apiKey = emailReputationMdt.Value__c;

        //Make an HTTP callout to the email validation service
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('callout:EmailReputation/?api_key=' + apiKey + '&email=' + email);
        request.setHeader('Content-Type', 'application/json');
        request.setMethod('GET');
        request.setTimeout(120000); // Set a timeout for the callout
        Log logger = Log.get();
        try {
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200){
                Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> deliverability = (Map<String, Object>)resultMap.get('email_deliverability');
                String status = (String)deliverability.get('status');
                String statusDetail = (String)deliverability.get('status_detail');
                if(status == Constants.STATUS_EMAIL && statusDetail == Constants.STATUS_DETAIL_EMAIL){
                    return true;
                }

                return false;
            } 
            else {
                // Handle callout failure
                logger.publish('Email validation callout failed with status code: ' + response.getBody());
                return false;
            }
        } catch (Exception ex) {
            // Handle any exceptions that occur during the callout
            logger.publish('An error occurred while validating email: ' + ex.getMessage());
            return false;
        }
    }
}