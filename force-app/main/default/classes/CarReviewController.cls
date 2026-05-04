public with sharing class CarReviewController {
    
    @AuraEnabled(cacheable=true)
    public static ReviewWrapper getCarReview(Id carId){
        try {
            System.debug('carId: ' + carId);
            Car__c car = [SELECT Id, Average_Rating__c FROM Car__c Where Id = :carId LIMIT 1];
            Decimal averageRating = 0;
            if(car.Average_Rating__c != null && car.Average_Rating__c > 0) {
                averageRating = car.Average_Rating__c;
            }

            List<Review__c> allReviews = [SELECT Id, Rating__c, Comments__c, CreatedDate, Booking__r.Car__c FROM Review__c WHERE Booking__r.Car__c = :carId Order by CreatedDate DESC];
            System.debug('allReviews size: ' + allReviews.size());

            Integer totalReviews = allReviews.size();

            Map<Integer, Integer> ratingDistribution = new Map<Integer, Integer>();
            for(Integer i = 1; i <= 5; i++) {
                ratingDistribution.put(i, 0);
            }

            for(Review__c review : allReviews) {
                Integer rating = Integer.valueOf(review.Rating__c);
                if(ratingDistribution.containsKey(rating)) {
                    ratingDistribution.put(rating, ratingDistribution.get(rating) + 1);
                }
            }
            ReviewWrapper reviewWrapper = new ReviewWrapper(allReviews, ratingDistribution, totalReviews, averageRating);
            System.debug('reviewWrapper.reviews size: ' + reviewWrapper.reviews.size());
            return reviewWrapper;

        } catch (Exception e) {
            Log logger = Log.get();
            logger.publish('Error Encountered: '+e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class ReviewWrapper{
        @AuraEnabled public List<Review__c> reviews;
        @AuraEnabled public Map<Integer, Integer> ratingDistribution;
        @AuraEnabled public Integer totalReview;
        @AuraEnabled public Decimal averageRating; 

        public ReviewWrapper(List<Review__c> reviews, Map<Integer, Integer> ratingDistribution, Integer totalReview, Decimal averageRating){
            this.reviews = reviews;
            this.ratingDistribution = ratingDistribution;
            this.totalReview = totalReview;
            this.averageRating = averageRating;
        }

    }
}