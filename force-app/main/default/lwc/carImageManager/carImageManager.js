import { LightningElement, api, wire } from 'lwc';
import createFile from '@salesforce/apex/carImageController.createFile';
import getCarImages from '@salesforce/apex/carImageController.getCarImages';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {notifyRecordUpdateAvailable} from 'lightning/uiRecordApi';
import {refreshApex} from '@salesforce/apex';

export default class CarImageManager extends LightningElement {
    @api recordId;
    @api hideUploadSection = false;
    isPrimaryChecked = true;
    carImages = [];
    isLoading = false;
    hasError = false;
    wiredImagesResult;

    @wire(getCarImages, { productId: '$recordId' })
    wiredCarImages(result) {
        console.log('Wire result received:', result);
        this.wiredImagesResult = result;
        
        if(result.data) {
            console.log('Images loaded:', result.data);
            this.carImages = result.data;
            this.isLoading = false;
            this.hasError = false;
        } else if(result.error) {
            console.error('Error loading images:', result.error);
            this.hasError = true;
            this.isLoading = false;
        } else {
            this.isLoading = true;
        }
    }

    get hasProductImages(){
        console.log('hasProductImages check - Loading:', this.isLoading, 'Error:', this.hasError, 'Images count:', this.carImages?.length);
        return !this.isLoading && !this.hasError && this.carImages && this.carImages.length > 0;
    }

    handlePrimaryChange(event) {
        this.isPrimaryChecked = event.target.checked;
    }

    async handleUploadFinished(event){
        const uploadedFiles = event.detail.files;
        const carFile = uploadedFiles[0];

        let documentId = carFile.documentId;
        let fileName = carFile.name;

        try{
            await createFile({ recordId: this.recordId, documentId: documentId, fileName: fileName, isPrimaryImage: this.isPrimaryChecked });
            this.showToast('Success', 'Image uploaded successfully', 'success');
            await refreshApex(this.wiredImagesResult);
            await notifyRecordUpdateAvailable([{recordId: this.recordId}]);
        } catch(error){
            console.error('Error creating file record: ', error);
            this.showToast('Error', 'Failed to upload image', 'error');
        }
        
    }

    showToast(title, message, variant){
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }

    get showUploadSection(){
        return !this.hideUploadSection;
    }

}