import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class EstimateCarBookingModal extends LightningModal {
    @api carId;
    get inputVariables() {
        return [
            {
                name: 'recordId',
                type: 'String',
                value: this.carId
            }
        ];
    }

    handleStatusChange(event){
        if (event.detail.status === 'FINISHED') {
            this.close('Success');
        }
    }
}