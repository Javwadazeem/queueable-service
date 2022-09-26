public without sharing class Utils 
{
    public static Boolean isAsyncContext()
    {
        return (System.isBatch() || System.isFuture() 
                || System.isQueueable() || system.isScheduled());
    }
}