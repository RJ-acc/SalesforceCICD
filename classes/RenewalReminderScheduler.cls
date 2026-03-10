public with sharing class RenewalReminderScheduler implements Schedulable {
    private static final Integer DEFAULT_LOOKAHEAD_DAYS = 30;
    private static final Integer MAX_ITEMS_IN_DIGEST = 25;
    private static final String DIGEST_SUBJECT = 'Upcoming Renewals Digest';

    public void execute(SchedulableContext sc) {
        sendDigestToCurrentUser(DEFAULT_LOOKAHEAD_DAYS);
    }

    @AuraEnabled
    public static Integer sendDigestToCurrentUser(Integer lookAheadDays) {
        Integer safeLookAhead = (lookAheadDays == null || lookAheadDays < 1) ? DEFAULT_LOOKAHEAD_DAYS : lookAheadDays;
        String userEmail = UserInfo.getUserEmail();
        if (String.isBlank(userEmail)) {
            return 0;
        }

        Date closeByDate = Date.today().addDays(safeLookAhead);
        List<Opportunity> renewalCandidates = [
            SELECT Id, Name, Amount, CloseDate, Account.Name
            FROM Opportunity
            WHERE IsClosed = false
                AND CloseDate <= :closeByDate
            ORDER BY CloseDate ASC
            LIMIT :MAX_ITEMS_IN_DIGEST
        ];

        if (renewalCandidates.isEmpty()) {
            return 0;
        }

        String body = buildDigestBody(renewalCandidates, safeLookAhead);
        NotificationService.sendEmailNotification(new List<String>{ userEmail }, DIGEST_SUBJECT, body);
        return renewalCandidates.size();
    }

    @TestVisible
    private static String buildDigestBody(List<Opportunity> opportunities, Integer lookAheadDays) {
        List<String> lines = new List<String>();
        lines.add('Upcoming renewals in the next ' + String.valueOf(lookAheadDays) + ' day(s):');
        for (Opportunity opp : opportunities) {
            String amountLabel = (opp.Amount == null) ? 'N/A' : String.valueOf(opp.Amount.setScale(2));
            String accountName = (opp.Account == null) ? 'No Account' : opp.Account.Name;
            lines.add('- ' + opp.Name + ' | ' + accountName + ' | ' + String.valueOf(opp.CloseDate) + ' | ' + amountLabel);
        }
        return String.join(lines, '\n');
    }
}