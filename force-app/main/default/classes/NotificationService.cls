public with sharing class NotificationService {
    private static final Integer MAX_RECIPIENTS_PER_EMAIL = 100;
    private static final String DEFAULT_EMAIL_ERROR = 'Email delivery failed.';

    public class NotificationValidationException extends Exception {
    }

    public class EmailSendException extends Exception {
    }

    public class EmailRequest {
        @AuraEnabled public List<String> toAddresses;
        @AuraEnabled public String subject;
        @AuraEnabled public String body;
        @AuraEnabled public Boolean saveAsActivity;
    }

    public static void sendEmailNotification(List<String> toAddresses, String subject, String body) {
        EmailRequest request = new EmailRequest();
        request.toAddresses = toAddresses;
        request.subject = subject;
        request.body = body;
        request.saveAsActivity = false;

        sendEmailNotifications(new List<EmailRequest>{ request });
    }

    @AuraEnabled
    public static void sendEmailNotificationFromUi(String toAddress, String subject, String body) {
        sendEmailNotification(new List<String>{ toAddress }, subject, body);
    }

    public static void sendEmailNotifications(List<EmailRequest> requests) {
        if (requests == null || requests.isEmpty()) {
            throw new NotificationValidationException('At least one email request is required.');
        }

        List<Messaging.SingleEmailMessage> outgoingEmails = new List<Messaging.SingleEmailMessage>();

        for (EmailRequest request : requests) {
            validateRequest(request);

            List<String> recipients = normalizeRecipients(request.toAddresses);
            for (Integer start = 0; start < recipients.size(); start += MAX_RECIPIENTS_PER_EMAIL) {
                List<String> chunk = new List<String>();
                Integer endIndex = Math.min(start + MAX_RECIPIENTS_PER_EMAIL, recipients.size());
                for (Integer idx = start; idx < endIndex; idx++) {
                    chunk.add(recipients[idx]);
                }

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(chunk);
                email.setSubject(request.subject.trim());
                email.setPlainTextBody(request.body.trim());
                email.setSaveAsActivity(request.saveAsActivity == true);
                outgoingEmails.add(email);
            }
        }

        if (!outgoingEmails.isEmpty()) {
            Messaging.SendEmailResult[] sendResults = Messaging.sendEmail(outgoingEmails, false);
            assertSendSucceeded(sendResults);
        }
    }

    private static void validateRequest(EmailRequest request) {
        if (request == null) {
            throw new NotificationValidationException('Email request cannot be null.');
        }
        if (request.toAddresses == null || request.toAddresses.isEmpty()) {
            throw new NotificationValidationException('At least one recipient is required.');
        }
        if (String.isBlank(request.subject)) {
            throw new NotificationValidationException('Email subject is required.');
        }
        if (String.isBlank(request.body)) {
            throw new NotificationValidationException('Email body is required.');
        }
    }

    private static List<String> normalizeRecipients(List<String> rawAddresses) {
        Set<String> seen = new Set<String>();
        List<String> normalized = new List<String>();

        for (String rawAddress : rawAddresses) {
            if (String.isBlank(rawAddress)) {
                continue;
            }

            String cleanedAddress = rawAddress.trim().toLowerCase();
            if (!seen.contains(cleanedAddress)) {
                seen.add(cleanedAddress);
                normalized.add(cleanedAddress);
            }
        }

        if (normalized.isEmpty()) {
            throw new NotificationValidationException('At least one valid recipient is required.');
        }

        return normalized;
    }

    private static void assertSendSucceeded(Messaging.SendEmailResult[] sendResults) {
        for (Integer i = 0; i < sendResults.size(); i++) {
            if (!sendResults[i].isSuccess()) {
                String errorMessage = DEFAULT_EMAIL_ERROR;
                if (sendResults[i].getErrors() != null && !sendResults[i].getErrors().isEmpty()) {
                    errorMessage = sendResults[i].getErrors()[0].getMessage();
                }
                throw new EmailSendException('Email request #' + String.valueOf(i + 1) + ' failed: ' + errorMessage);
            }
        }
    }

    @TestVisible
    private static Integer getChunkCountForRecipients(List<String> toAddresses) {
        List<String> recipients = normalizeRecipients(toAddresses);
        Integer chunks = 0;
        for (Integer start = 0; start < recipients.size(); start += MAX_RECIPIENTS_PER_EMAIL) {
            chunks++;
        }
        return chunks;
    }

    @AuraEnabled(cacheable=true)
    public static Integer getUnreadNotificationCount() {
        return [SELECT COUNT() FROM Task WHERE OwnerId = :UserInfo.getUserId() AND IsClosed = false AND ActivityDate <= TODAY WITH USER_MODE];
    }
}
