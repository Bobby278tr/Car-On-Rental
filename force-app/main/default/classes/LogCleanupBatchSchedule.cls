public with sharing class LogCleanupBatchSchedule implements Schedulable {

    public void execute(SchedulableContext tc) {
        LogCleanupBatch batch = new LogCleanupBatch();
        Database.executeBatch(batch, 200);
    }
}