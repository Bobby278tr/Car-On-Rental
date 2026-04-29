public with sharing class QueueableTotalCarValue implements Queueable {

    Set<Id> carIds;
    public QueueableTotalCarValue(Set<Id> carIds) {
        this.carIds = carIds;
    }
    
    public void execute(QueueableContext context) {
        Map<Id, Decimal> carIdToTotalValueMap = new Map<Id, Decimal>();
        List<Car__c> carsToUpdate = new List<Car__c>();
        for(AggregateResult ar : [SELECT Car__c, SUM(Total_Paid_Amount__c) totalValue FROM Booking__c WHERE Car__c IN :carIds AND Status__c = :Constants.BOOKING_CLOSED_STATUS GROUP BY Car__c]){
            Id carId = (Id)ar.get('Car__c');
            Decimal totalValue = (Decimal)ar.get('totalValue');
            carIdToTotalValueMap.put(carId, totalValue);
        }

        for(Id carId : carIds){
            Car__c car = new Car__c(Id = carId);
            car.Total_Bookings_Value__c = carIdToTotalValueMap.get(carId) != null ? carIdToTotalValueMap.get(carId) : 0;
            carsToUpdate.add(car);
        }

        try {
            if(!carsToUpdate.isEmpty()){
            update carsToUpdate;
        }
        } catch (Exception ex) {
            Log logger = Log.get();
            logger.publish('Error updating total booking value for cars: ' + ex.getMessage());
        }
        
    }
}