public with sharing class ReviewTriggerHandler extends triggerHandler {
    
    override public void afterInsert(){
        List<Review__c> reviewList = (List<Review__c>)Trigger.new;
        List<Review__c> lowReview =new List<Review__c>();
        for(Review__c review : reviewList){
            if(review.Rating__c <= Constants.LOW_RATING_THRESHOLD){
                lowReview.add(review);
            }
        }
        if(!lowReview.isEmpty()){
            ReviewTriggerHandlerService.shareLowRatingBookingAndCreateCase(lowReview);
        }
        ReviewTriggerHandlerService.updateCarAverageRating(reviewList);
        
    }

    override public void afterUpdate(){
        List<Review__c> reviewList = (List<Review__c>)Trigger.new;
        List<Review__c> lowReview =new List<Review__c>();
        Map<Id, Review__c> oldReviewMap = (Map<Id, Review__c>)Trigger.oldMap;
        List<Review__c> updatedReviews = new List<Review__c>();
        for(Review__c review : reviewList){
            Decimal newReview = review.Rating__c;
            Decimal oldReview = oldReviewMap.get(review.Id).Rating__c;
            if(newReview <= Constants.LOW_RATING_THRESHOLD && newReview!=oldReview){
                lowReview.add(review);
            }
            if(newReview != oldReview){
                updatedReviews.add(review);
            }
        }
        if(!lowReview.isEmpty()){
            ReviewTriggerHandlerService.shareLowRatingBookingAndCreateCase(lowReview);
        }
        if(!updatedReviews.isEmpty()){
            ReviewTriggerHandlerService.updateCarAverageRating(updatedReviews);
        }
    }
}