import { LightningElement, wire } from 'lwc';
import { subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext} from "lightning/messageService";
import carSelection from "@salesforce/messageChannel/carSelection__c";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/Car__c.Name';
import RATING_FIELD from '@salesforce/schema/Car__c.Average_Rating__c';
import MODEL_FIELD from '@salesforce/schema/Car__c.Model__c';
import CAR_FAMILY_FIELD from '@salesforce/schema/Car__c.Car_Family__c';
import SEATS_FIELD from '@salesforce/schema/Car__c.Number_of_Seats__c';
import TRANSMISSION_FIELD from '@salesforce/schema/Car__c.Transmission_Type__c';
import FUEL_FIELD from '@salesforce/schema/Car__c.Fuel_Type__c';
import RENTAL_RATE_FIELD from '@salesforce/schema/Car__c.Rental_Rate_Per_Day__c';
import DESCRIPTION_FIELD from '@salesforce/schema/Car__c.Car_Description__c';
import bookCarModal from "c/bookCarModal";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { NavigationMixin } from "lightning/navigation";
import BOOKING_OBJECT from '@salesforce/schema/Booking__c'

const FIELDS = [NAME_FIELD, RATING_FIELD, MODEL_FIELD, CAR_FAMILY_FIELD, SEATS_FIELD, TRANSMISSION_FIELD, FUEL_FIELD, RENTAL_RATE_FIELD, DESCRIPTION_FIELD];

export default class CarCard extends NavigationMixin(LightningElement) {

    subscription = null;
    carId;
    productName;
    modelField;
    carFamilyField;
    seatingCapacityBadge;
    transmissionBadge;
    fuelTypeBadge;
    rentalRateBadge;
    descriptionBdge;
    hasData = false;

    @wire(MessageContext)
    messageContext;

    @wire(getRecord, {recordId : '$carId', fields: FIELDS})
    wiredData({error, data}){
        if(data){
            this.productName = getFieldValue(data, NAME_FIELD);
            this.modelField = getFieldValue(data, MODEL_FIELD);
            this.carFamilyField = getFieldValue(data, CAR_FAMILY_FIELD);
            this.descriptionBdge = getFieldValue(data, DESCRIPTION_FIELD);

            const seatingCapacity = getFieldValue(data, SEATS_FIELD);
            this.seatingCapacityBadge = `Seats : ${seatingCapacity}` +"Persons";

            const transmission = getFieldValue(data, TRANSMISSION_FIELD);
            this.transmissionBadge = transmission ? `Transmission : ${transmission}` : "N/A";

            const fuelType = getFieldValue(data, FUEL_FIELD);
            this.fuelTypeBadge = fuelType ? `Fuel : ${fuelType}` : "N/A";

            const rentalRate = getFieldValue(data, RENTAL_RATE_FIELD);
            this.rentalRateBadge = rentalRate ? `Rate : $${rentalRate}/day` : "N/A";

            this.hasData = true;
        }else if(error){
            console.log(error);
        }
    }

    // Standard lifecycle hooks used to subscribe and unsubsubscribe to the message channel
    connectedCallback() {
        this.subscribeToMessageChannel();
    }

    disconnectedCallback() {
        this.unsubscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        if (!this.subscription) {
            this.subscription = subscribe(
                this.messageContext,
                carSelection,
                (message) => this.handleMessage(message),
                { scope: APPLICATION_SCOPE },
            );
        }
    }

    // Handler for message received by component
    handleMessage(message) {
        this.carId = message.carId;
        console.log(this.carId);
        this.hasData = false;
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleBookNow(event){
        bookCarModal.open({
            carId : this.carId,
            size : 'medium'
        }).then((result) => {
            if(result && result.output == 'Success'){
                //showToastMessage
                this.showToast("Success", "Booking Created Successfully", "Success");
                //Navigate to the booking record
                let bookingId = result.bookingId;
                let pageReferenceOfBooking = {
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: bookingId,
                            objectApiName: BOOKING_OBJECT.objectApiName,
                            actionName: 'view'
                        }
                }
                 this[NavigationMixin.Navigate](pageReferenceOfBooking);
                
            }
        })
    }

    showToast(message, title, variant){
        const event = new ShowToastEvent({
            title : title,
            message : message,
            variant : variant
        });
        this.dispatchEvent(event);
    }
}