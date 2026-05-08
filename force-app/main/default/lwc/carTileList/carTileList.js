import { LightningElement, wire } from 'lwc';
import { publish, subscribe, unsubscribe, APPLICATION_SCOPE, MessageContext} from "lightning/messageService";
import carFilter from "@salesforce/messageChannel/carFilter__c";
import getCars from '@salesforce/apex/carTileListController.getCars';
import carSelection from "@salesforce/messageChannel/carSelection__c";


export default class CarTileList extends LightningElement {

    subscription = null;
    filters;
    showInitialMessage = true;

    @wire(MessageContext)
    messageContext;

    @wire(getCars, {filters : '$filters'})
    filteredCars;

    get isRecordFound(){
        return this.filteredCars.data && this.filteredCars.data.length > 0;
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
            carFilter,
            (message) => this.handleMessage(message),
            { scope: APPLICATION_SCOPE },
        );
        }
    }

    // Handler for message received by component
    handleMessage(message) {
        this.filters = {...message.selectedCarFilter.filters};
        console.log(this.filters);
        this.showInitialMessage = false;
    }

    unsubscribeToMessageChannel() {
        unsubscribe(this.subscription);
        this.subscription = null;
    }

    handleCarSelected(event){
        console.log('Car Tile Selected :: ', event.detail);
        const payload = { carId: event.detail };

        publish(this.messageContext, carSelection, payload);
    }

    handleEstimateBooking(event){
        console.log('EstimateBooking selected ::: ', event.detail);
    }

    handleBookNow(event){
        console.log('Book Now clicked ::', event.detail);
    }
}