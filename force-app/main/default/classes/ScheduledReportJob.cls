public class ScheduledReportJob implements Schedulable {
    public void execute(SchedulableContext sc) {
        Integer openCases = [SELECT COUNT() FROM Case WHERE IsClosed = false AND Priority = 'High'];
        Integer overdueOps = [SELECT COUNT() FROM Opportunity WHERE CloseDate < TODAY AND IsClosed = false];
        System.debug('Daily Report - Open High Cases: ' + openCases + ', Overdue Opps: ' + overdueOps);
    }
}