public with sharing class PaymentTransactionTriggerHandler extends TriggerHandler {
    
    override public void afterInsert(){
        PaymentTransactionTriggerHandlerService.handlePaymentTransaction(Trigger.new);
    }
    
    override public void afterDelete(){
        PaymentTransactionTriggerHandlerService.handlePaymentTransaction(Trigger.old);
    }
}