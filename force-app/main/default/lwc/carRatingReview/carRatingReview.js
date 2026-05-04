import { LightningElement, wire, api } from 'lwc';
import getCarReview from '@salesforce/apex/CarReviewController.getCarReview';
import CreatedDate from '@salesforce/schema/Account.CreatedDate';

export default class CarRatingReview extends LightningElement {
    @api recordId;
    carReview = [];
    averageRating = 0;
    ratingDistribution = {};
    totalReview = 0;

    @wire(getCarReview, { carId: '$recordId' })
    wiredCarReview({ error, data }) {
        console.log('wiredCarReview data:', data);
        console.log('wiredCarReview error:', error);
        if (data) {
            this.carReview = data.reviews;
            this.averageRating = data.averageRating;
            this.ratingDistribution = data.ratingDistribution;
            this.totalReview = data.totalReview;
            this.processReviews();
        } else if (error) {
            this.error = error;
            this.carReview = undefined;
        }
    }

    processReviews(){
        if(this.carReview){
            this.carReview = this.carReview.map(review => {
                return {
                    ...review,
                    CreatedDate : this.formatDate(review.CreatedDate)
                };
            });
        }

    }

    formatDate(dateString) {
        const date = new Date(dateString);
        const options = { year: 'numeric', month: 'long', day: 'numeric' };
        return date.toLocaleDateString('en-US', options);
    } 

    get ratingDistributionList(){
        const distribution = [];
        for(let i = 5; i >= 1; i--){
            const count = this.ratingDistribution[i];
            const total = this.totalReview;
            const percentage = (count / total) * 100;
            const fixedPercentage = percentage.toFixed(2);
            distribution.push({
                rating: i,
                count: count,
                percentage: fixedPercentage
            });
        }
        return distribution;
    }
}