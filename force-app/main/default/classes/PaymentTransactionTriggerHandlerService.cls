public with sharing class PaymentTransactionTriggerHandlerService {
    
    public static void handlePaymentTransaction(List<Payment_Transaction__c> paymentTransaction){
        // get all the affected booking ids
        Set<Id> bookingIds = new Set<Id>();
        for(Payment_Transaction__c pt : paymentTransaction){
            if(pt.Booking__c != null){
                bookingIds.add(pt.Booking__c);
            }
        }

        // parent --> Child relationship query
        //bookingId to list of related payment transaction
        Set<String> paymentType = new Set<String>();
        paymentType.add(Constants.TYPE_INITIAL_PAYMENT);
        paymentType.add(Constants.TYPE_SECURITY_DEPOSIT);
        paymentType.add(Constants.TYPE_PARTIAL_PAYMENT);

        List<Booking__c> updateBookingList = new List<Booking__c>();

        List<Booking__c> bookingList = [SELECT Id, Status__c, Payment_Status__c, Final_Booking_Price__c, Security_Deposit__c, (SELECT Id, Amount__c, Type__c, Status__c FROM Payment_Transactions__r Where Status__c = :Constants.SUCCESS AND Type__c IN :paymentType) FROM Booking__c WHERE Id IN :bookingIds];

        for(Booking__c booking : bookingList){
            Decimal initialPayment = 0;
            Decimal securityPayment = 0;
            Decimal partialPayment = 0;

            for(Payment_Transaction__c pt : booking.Payment_Transactions__r){
                if(pt.Type__c == Constants.TYPE_INITIAL_PAYMENT){
                    initialPayment += pt.Amount__c;
                } else if(pt.Type__c == Constants.TYPE_SECURITY_DEPOSIT){
                    securityPayment += pt.Amount__c;
                } else if(pt.Type__c == Constants.TYPE_PARTIAL_PAYMENT){
                    partialPayment += pt.Amount__c;
                }
            }

            //payment Status = Final Booking Price >= Initial Payment + Patial Payment && Security deposite >= securityPayment -->paid else Partially Paid
            // booking Status = Existing Booking Status = Pending && initialPayment, securityDeposit, partialPayment > 0 --> Confirmed
            booking.Payment_Status__c = calculatePaymentStatus(booking.Final_Booking_Price__c, initialPayment, booking.Security_Deposit__c, partialPayment, securityPayment);
            booking.Status__c = calculateBookingStatus(booking.Status__c, initialPayment, securityPayment, partialPayment);
            updateBookingList.add(booking);
        }

        if(!updateBookingList.isEmpty()){
            try{
                update updateBookingList;
            } catch(Exception ex){
                Log logger = Log.get();
                logger.publish('Error while updating Payment and Booking STatus : '+ex.getMessage());
            }
            
        }
    }

    public static String calculatePaymentStatus(Decimal finalBookingPrice, Decimal initialPayment, Decimal securityDeposit, Decimal         partialPayment, Decimal securityPayment){
        if(initialPayment == 0 && finalBookingPrice == 0 && securityDeposit ==0 ){
            return Constants.BOOKING_PENDING_STATUS;
        } 
        Decimal totalRentalPayment = initialPayment + partialPayment;
        Boolean isTotalRentalPaymentCompleted = finalBookingPrice <= totalRentalPayment;
        Boolean isSecurityDepositCompleted = securityDeposit <= securityPayment;

        if(isTotalRentalPaymentCompleted && isSecurityDepositCompleted){
            return Constants.BOOKING_PAID;
        } else {
            return Constants.BOOKING_PARTIAL_PAID;
        }
    }

    public static String calculateBookingStatus(String existingBookingStatus, Decimal initialPayment, Decimal securityPayment, Decimal partialPayment){
        if(existingBookingStatus == Constants.BOOKING_PENDING_STATUS && (initialPayment > 0 || securityPayment > 0 || partialPayment > 0)){
            return Constants.BOOKING_CONFIRM_STATUS;
        } else {
            return existingBookingStatus;
        }
    }
}