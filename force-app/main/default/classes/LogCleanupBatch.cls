public with sharing class LogCleanupBatch implements Database.Batchable<SObject>, Database.Stateful {
    
    private Integer recordsProcessed = 0;
    private Integer daysToKeep = 7;
    private Integer recordsDeletedSuccessfully = 0;
    private Integer recordsDeletionFailed = 0;
    private String notificationEmail;

    public LogCleanupBatch() {
        loadConfiguration();
    }

    public void loadConfiguration(){
        // Fetch the number of days to keep logs and notification email from Custom Metadata
        System_Threshold__mdt logCleanupMdt = System_Threshold__mdt.getInstance('Log_Clean_Up_Notification__c');
        notificationEmail = logCleanupMdt.value__c;
        System_Threshold__mdt daysToKeepMdt = System_Threshold__mdt.getInstance('Days_To_Keep_Logs');
        daysToKeep = Integer.valueOf(daysToKeepMdt.value__c);
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Date cutOffDate = Date.today().addDays(-daysToKeep);
        String query = 'SELECT Id FROM LogEvent__c WHERE CreatedDate < :cutOffDate';
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<LogEvent__c> scope){
        if(scope == null || scope.isEmpty()){ return; }

        recordsProcessed += scope.size();
        List<Database.DeleteResult> deleteResults = Database.delete(scope, false);
        Log logger = Log.get();

        for(Database.DeleteResult result : deleteResults) {
            if(result.isSuccess()) {
                recordsDeletedSuccessfully++;
            } else {
                recordsDeletionFailed++;
                //List<Database.Error> errors = result.getErrors();
                logger.add('Record deletion failed: ' + String.join(new List<String>{'Id: ' + result.getId(), 'Errors: ' + String.valueOf(result.getErrors())}, ', '));
            }
        }
        logger.publish();
    }

    public void finish(Database.BatchableContext bc) {
        // Send email notification with the results of the batch job
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] { notificationEmail };
        email.setToAddresses(toAddresses);
        email.setSenderDisplayName('Car On Rental');
        email.setSubject('Log Cleanup Batch Job Completed - '+ DateTime.now().format('MM dd, yyyy HH:mm:ss'));
        email.setPlainTextBody('The Log Cleanup Batch Job has completed. \n\n' +
            'Total Records Processed: ' + recordsProcessed + '\n' +
            'Records Deleted Successfully: ' + recordsDeletedSuccessfully + '\n' +
            'Records Failed to Delete: ' + recordsDeletionFailed);

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

    }
}