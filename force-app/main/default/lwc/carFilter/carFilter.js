import { LightningElement, wire } from 'lwc';
import { getPicklistValues } from "lightning/uiObjectInfoApi";
import PICKUP_LOCATION from "@salesforce/schema/Car__c.PickupLocation__c";
import TRANSMISSION_TYPE from "@salesforce/schema/Car__c.Transmission_Type__c";
import FUEL_TYPE from "@salesforce/schema/Car__c.Fuel_Type__c";

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

    publishFilter(){
        console.log("Filters" , JSON.stringify(this.filter))
    }

    handleCheckboxGroupChange(event){
        const name = event.target.name;
        this.filter[name] = event.detail.value;
        this.publishFilter();
    }
}