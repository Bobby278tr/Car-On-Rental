public with sharing class carImageController {
    
    @AuraEnabled
    public static void createFile(String documentId, String fileName, String recordId, Boolean isPrimaryImage){
        
        //get the latest content version of the document
        List<ContentVersion> contentVersions = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId = :documentId  AND isLatest = true ORDER BY CreatedDate DESC LIMIT 1];

        if(contentVersions.isEmpty()){
            throw new AuraHandledException('No content version found for the provided documentId');
        }

        // insert record in Car Image
        Car_Image__c carImage = new Car_Image__c();
        carImage.Car__c = recordId;
        carImage.Image_Url__c = '/sfc/servlet.shepherd/version/download/' + contentVersions[0].Id;
        if(isPrimaryImage){
            carImage.Primary_Image__c = true;
        } else {
            carImage.Primary_Image__c = false;
        }

        try {
            insert carImage;
        } catch (Exception ex) {
            Log logger = Log.get();
            logger.publish('Error Encountered: '+ex.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Car_Image__c> getCarImages(Id productId){
        try {
            return [SELECT Id, Car__r.Name, Image_Url__c, Primary_Image__c FROM Car_Image__c WHERE Car__c = :productId with USER_MODE];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}