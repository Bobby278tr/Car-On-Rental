import { LightningElement, api } from 'lwc';
import fivestar from '@salesforce/resourceUrl/fivestar';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class StarRating extends LightningElement {
    @api value = 0;
    @api maxValue = 5;
    @api readOnly = false;

    isRendered = false;
    
    renderedCallback() {
        if (this.isRendered) {
            return;
        }
        this.loadScriptAndStyle();
        this.isRendered = true;
    }

    loadScriptAndStyle(){
        console.log('Loading fivestar resources');
        Promise.all([
            loadStyle(this, fivestar + '/rating.css'),
            loadScript(this, fivestar + '/rating.js')
        ]).then(() => {
            console.log('fivestar resources loaded');
            this.afterScriptsLoaded();
        }).catch(error => {
            console.error('Error loading resources: ', error);
        });

    }

    get starClass(){
        return this.readOnly ? 'readonly c-rating' : 'c-rating'
    }

    afterScriptsLoaded(){
        console.log('afterScriptsLoaded called, value:', this.value, 'readOnly:', this.readOnly);
        console.log('window.rating:', window.rating);
        const domEl = this.template.querySelector("ul");
        console.log('domEl:', domEl);
        const callback = (rating) => {
            this.value = rating;
            let myEvent = new CustomEvent('ratingchange', {
                detail: { 
                    rating:rating }
            });
            this.dispatchEvent(myEvent);
        };
        this.ratingObj = window.rating(domEl, this.value, this.maxValue, callback, this.readOnly);
        console.log('ratingObj:', this.ratingObj);
    }


}