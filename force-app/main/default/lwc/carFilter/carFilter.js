import { LightningElement, wire } from 'lwc';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import PICKUP_LOCATION from "@salesforce/schema/Car__c.PickupLocation__c";
import TRANSMISSION_TYPE from "@salesforce/schema/Car__c.Transmission_Type__c";
import FUEL_TYPE from "@salesforce/schema/Car__c.Fuel_Type__c";
import { publish, MessageContext } from "lightning/messageService";
import carFilter from "@salesforce/messageChannel/carFilter__c";


const DELAY = 350;
export default class CarFilter extends LightningElement {
    filter ={
        searchKey : "",
        maxSeats : 8,
        startDate : null,
        endDate : null,
        maxRentalRate : 10000,
        minRating : 0,
        pickupLocation : "Delhi",
        transmissionType : [],
        fuelType : []
    }
    delayTimeout;

    @wire(MessageContext)
    messageContext;

    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: PICKUP_LOCATION })
    pickupLocationValues;
    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: TRANSMISSION_TYPE })
    transmissionTypeValues;
    @wire(getPicklistValues, { recordTypeId: "012000000000000AAA", fieldApiName: FUEL_TYPE })
    fuelTypeValues;

    handleSearchChange(event){
        this.filter.searchKey = event.target.value;
        this.publishFilter();
    }

    handlePickupLocationChange(event){
        this.filter.pickupLocation = event.detail.value;
        this.publishFilter();
    }

    handleStartDateChange(event){
        this.filter.startDate = event.detail.value;
        this.publishFilter();
    }
    handleEndDateChange(event){
        this.filter.endDate = event.detail.value;
        this.publishFilter();
    }
    handleMaxSeatChange(event){
        this.filter.maxSeats = event.detail.value;
        this.publishFilter();
    }
    handleMaxRentalRateChange(event){
        this.filter.maxRentalRate = event.detail.value;
        this.publishFilter();
    }
    handleMinRatingChange(event){
        this.filter.minRating = event.detail.value;
        this.publishFilter();
    }
    // handleCheckboxChange(event){
    //     const value = event.target.dataset.value;
    //     const name = event.target.name

    //     if(name == "transmissionType"){
    //         if(event.target.checked){
    //             if(!this.filter.transmissionType.includes(value)){
    //                 this.filter.transmissionType.push(value);
    //             }
    //         }else{
    //             // keep all the values except the value unchecked
    //             this.filter.transmissionType = this.filter.transmissionType.filter((item)=> item != value);
    //         }
    //     }
    //     if(name == "fuelType"){
    //         if(event.target.checked){
    //             if(!this.filter.fuelType.includes(value)){
    //                 this.filter.fuelType.push(value);
    //             }
    //         }else{
    //             // keep all the values except the value unchecked
    //             this.filter.fuelType = this.filter.fuelType.filter((item)=> item != value);
    //         }
    //     }
    //     this.publishFilter();
    // }

    handleCheckboxGroupChange(event){
        const name = event.target.name;
        this.filter[name] = event.detail.value;
        this.publishFilter();
    }

    validateFilters(){
        let isValid = true;
        const startDate = this.template.querySelector('.startDateClass');
        const endDate = this.template.querySelector('.endDateClass');

        // set error message to be blank
        startDate.setCustomValidity('');
        endDate.setCustomValidity('');

        // validate the start date and end date is required
        if(!this.filter.startDate){
            startDate.setCustomValidity('Start Date is required');
            isValid = false;
        }
        const today = new Date().toISOString().split('T')[0];
        if(this.filter.startDate < today){
            startDate.setCustomValidity('Start Date should not be in the past');
            isValid = false;
        }
        
        if(!this.filter.endDate){
            endDate.setCustomValidity('End Date is required');
            isValid = false;
        }

        if(this.filter.startDate && this.filter.endDate){
            if(this.filter.startDate > this.filter.endDate){
                startDate.setCustomValidity('Start Date should be less than end date');
                isValid = false;
            }
        }

        //report the message
        startDate.reportValidity();
        endDate.reportValidity();

        return isValid;
    }

    publishFilter(){
        console.log("Filters" , JSON.stringify(this.filter))
        if(this.validateFilters()){
            // publish the event with debouncing
            clearTimeout(this.delayTimeout);
            this.delayTimeout = setTimeout(() => {
                // publish the changes to the message channel
                 const payload = { selectedCarFilter: {
                        filters : this.filter 
                    }
                };
                publish(this.messageContext, carFilter, payload);
                console.log('payload', JSON.stringify(payload));
                console.log('Filter Published Successfully');
            }, DELAY)
        }
    }
}