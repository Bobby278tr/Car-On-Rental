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

    public static void updateCarAverageRating(List<Review__c> reviews){
        Set<Id> carIds = new Set<Id>();
        Set<Id> bookingIds = new Set<Id>();
        for(Review__c review : reviews){
            if(String.isNotBlank(review.Booking__c)){
                bookingIds.add(review.Booking__c);  
            }
        }

        Map<Id, Booking__c> bookingList = new Map<Id, Booking__c>([SELECT Id, Car__c FROM Booking__c WHERE Id IN :bookingIds]);

        for(Review__c review : reviews){
            if(bookingList.containsKey(review.Booking__c)){
                Id carId = bookingList.get(review.Booking__c).Car__c;
                if(carId != null){
                    carIds.add(carId);
                }
            }
        }

        Map<Id, Decimal> carAverageRatingMap = new Map<Id, Decimal>();

        for(AggregateResult ar: [SELECT Booking__r.Car__c, AVG(Rating__c) avgRating from Review__c Where Booking__r.Car__c IN :carIds GROUP By Booking__r.Car__c ]){
            Id carId = (Id)ar.get('Car__c');
            Decimal avgRating = (Decimal)ar.get('avgRating');
            carAverageRatingMap.put(carId, avgRating.round(System.RoundingMode.HALF_UP));
        }

        List<Car__c> carsToUpdate = new List<Car__c>();
        for(Id carId : carIds){
            if(carAverageRatingMap.containsKey(carId)){
                Car__c carToUpdate = new Car__c();
                carToUpdate.Id = carId;
                carToUpdate.Average_Rating__c = carAverageRatingMap.get(carId);
                carsToUpdate.add(carToUpdate);
            }
        }

        if(!carsToUpdate.isEmpty()){
            try {
                update carsToUpdate;
            } catch (Exception ex) {
                Log logger = Log.get();
                logger.publish('Error while Updating Car Average Rating : '+ex.getMessage());
            }
        }
    }
}
