/****************************************************************************************************************************************************************
Class Name:         QueueableService
Inheritance:        Implements - Queueable,Database.Allowscallouts
Description:        This class is specifically designed for performing async logics in a more scablable and optimize manner.
Author:             Javwad Azeem
Date:               03/05/2022
Modification Logs:  
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Developer                 Date                   Description
-----------------------------------------------------------------------------------------------------------------------------------------------------------------
Javwad Azeem            03/05/2022               Initial Version.
------------------------------------------------------------------------------------------------------------------------------------------------------------------
Developer Notes:-
TODO -  Implement Transaction Finalizer Interface for this Application.
        The Transaction Finalizers feature enables you to attach actions, using the System.Finalizer interface, 
        to asynchronous Apex jobs that use the Queueable framework.
        A specific use case is to design recovery actions when a Queueable job fails.
*******************************************************************************************************************************************************************/

public abstract class QueueableService implements Queueable, Database.Allowscallouts
{ 
    private Id m_jobId;
    private String m_strComponentName = 'QueueableService';
    private Boolean m_Run_In_Sync = false;
    private Boolean m_Run_In_Async = false;
    
    //Override this method in your base class and implement your business logics
    //inside this method that should be performed asynchronously Or Synchronously.
    public abstract void executeProcess();
    
    //Pass True in Parameter, if you don't want to execute your logic in a queue job.
    public QueueableService runSync(Boolean isSync)
    {
        this.m_Run_In_Sync = isSync == true;
        return this;
    } 
    public QueueableService runAsync(Boolean isAsync)
    {
        this.m_Run_In_Async = isAsync == true;
        return this;
    } 
    //Pass the component name for exception handling.
    public QueueableService invokedFrom(String strComponentName)
    {
        this.m_strComponentName = strComponentName;
        return this;
    }
    //Call this method to start asynch process.
    //This method will check whether we are already in an async process or not.
    //Returns Queueable Job Id
    public Id run()
    {
        Savepoint sp = Database.setSavePoint();
        try
        {
            If(m_Run_In_Sync) executeProcess();
            else If(!Utils.isAsyncContext() || m_Run_In_Async) m_jobId = System.enqueueJob(this);
            else executeProcess();
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            throw ex;
        }
        return m_jobId;
    }
    public void execute(QueueableContext qc)
    {
        executeProcess();
    }
    
/*Illustration to use all of the methods
 *  new YourClasName().run(); - This will run your logic based on current context.
 *  new YourClasName().runInSync(True).run(); - This will run your logic synchronously irrespective of Current context.
 *  new YourClassName().InvokeFrom('FLow/Apexclass name').run(); - This will run your logic based on current context and
 *                                                                 Create error logs with the name this process invoked from.
*/
}