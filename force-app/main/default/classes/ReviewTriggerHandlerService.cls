public with sharing class ReviewTriggerHandlerService {
   
    public static void shareLowRatingBookingAndCreateCase(List<Review__c> lowReviews) {

        //get customer Support group
        Group customerSupportGroup = [SELECT Id FROM Group WHERE DeveloperName = :Constants.CUSTOMER_SUPPORT_PUBLIC_GROUP LIMIT 1];

        Set<Id> bookingIds = new Set<Id>();
        for(Review__c review : lowReviews){
            if(String.isNotBlank(review.Booking__c)){
                bookingIds.add(review.Booking__c);
            }
        }

        // checing if the booking is already shared with customer support group
        List<Booking__Share> existingShare = [SELECT parentId FROM Booking__Share WHERE ParentId IN :bookingIds AND UserOrGroupId = :customerSupportGroup.Id AND RowCause = :Schema.Booking__Share.RowCause.Manual];

        Set<Id> alreadySharedBookingIds = new Set<Id>();
        for(Booking__Share share : existingShare){
            alreadySharedBookingIds.add(share.ParentId);    
        }

        List<Booking__Share> bookingSharesToInsert = new List<Booking__Share>();
        for(Id bookingId : bookingIds){
            if(!alreadySharedBookingIds.contains(bookingId)){
                Booking__Share bookingShare = new Booking__Share();
                bookingShare.ParentId = bookingId;
                bookingShare.UserOrGroupId = customerSupportGroup.Id;
                bookingShare.AccessLevel = 'Read';
                bookingShare.RowCause = Schema.Booking__Share.RowCause.Manual;
                bookingSharesToInsert.add(bookingShare);
            }
        }
        if(!bookingSharesToInsert.isEmpty()){
            try {
                insert bookingSharesToInsert;
            } catch (Exception ex) {
                Log logger = Log.get();
                logger.publish('Error while Inserting Booking Shares : '+ex.getMessage());
            }
            
        }

        // create case for low rating review
        createCaseForLowRating(lowReviews);
    }

    private static void createCaseForLowRating(List<Review__c> lowReviews){

        Id reviewIssueRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Constants.NEGATIVE_REVIEW_RECORD_TYPE).getRecordTypeId();
        List<Case> caseToInsert = new List<Case>();
        Set<Id> reviewIds = new Set<Id>();
        for(Review__c review : lowReviews){
            reviewIds.add(review.Id);
        }

        List<Review__c> reviewList = [SELECT Id, Rating__c, Comments__c, Booking__c, Customer__c, Booking__r.Car__c FROM Review__c WHERE Id IN :reviewIds];

        List<Case> existingCases = [SELECT Id, Review_Id__c FROM Case WHERE RecordTypeId = :reviewIssueRecordTypeId AND Review_Id__c IN :reviewIds AND Type = :Constants.NEGATIVE_REVIEW_CASE_TYPE];

        Set<Id> alreadyCreatedCaseReviewIds = new Set<Id>();
        for(Case cs : existingCases){
            alreadyCreatedCaseReviewIds.add(cs.Review_Id__c);
        }

        for(Review__c review : reviewList){
            if(!alreadyCreatedCaseReviewIds.contains(review.Id)){
                Case newCase = new Case();
                newCase.Subject = 'Low Rating Review: ' + review.Rating__c + ' Stars';
                newCase.Description = 'Review Comments: ' + review.Comments__c;
                newCase.Priority = Constants.CASE_PRIORITY_MEDIUM;
                newCase.Type = Constants.NEGATIVE_REVIEW_CASE_TYPE;
                newCase.RecordTypeId = reviewIssueRecordTypeId;
                newCase.Review_Id__c = review.Id;
                newCase.Related_Booking__c = review.Booking__c;
                newCase.Related_Car__c = review.Booking__r.Car__c;
                newCase.ContactId = review.Customer__c;
                caseToInsert.add(newCase);
            }
            
        }
        if(!caseToInsert.isEmpty()){
            try {
                insert caseToInsert;
            } catch (Exception ex) {
                Log logger = Log.get();
                logger.publish('Error while Inserting Cases : '+ex.getMessage());
            }
        }
    }
} 