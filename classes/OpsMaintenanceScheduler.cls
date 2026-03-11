public with sharing class OpsMaintenanceScheduler implements Schedulable {
    public void execute(SchedulableContext sc) {
        TaskHygieneBatch.runNow(30, 100);
    }

    @AuraEnabled
    public static String scheduleDaily(String jobName, Integer hour24, Integer minute) {
        Integer safeHour = (hour24 == null || hour24 < 0 || hour24 > 23) ? 2 : hour24;
        Integer safeMinute = (minute == null || minute < 0 || minute > 59) ? 0 : minute;
        String safeName = String.isBlank(jobName) ? 'OpsMaintenanceDaily' : jobName;

        String cron = '0 ' + String.valueOf(safeMinute) + ' ' + String.valueOf(safeHour) + ' * * ?';
        return System.schedule(safeName, cron, new OpsMaintenanceScheduler());
    }
}