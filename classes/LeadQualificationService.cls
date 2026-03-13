public with sharing class LeadQualificationService {
    public class LeadQualificationResult {
        @AuraEnabled public Id leadId;
        @AuraEnabled public Integer score;
        @AuraEnabled public String rating;
    }

    @AuraEnabled
    public static List<LeadQualificationResult> qualifyLeads(List<Id> leadIds) {
        if (leadIds == null || leadIds.isEmpty()) {
            return new List<LeadQualificationResult>();
        }

        List<Lead> leads = [
            SELECT Id, Email, Phone, Company, Title, AnnualRevenue, NumberOfEmployees, Rating
            FROM Lead
            WHERE Id IN :leadIds
            WITH USER_MODE
        ];

        List<LeadQualificationResult> results = new List<LeadQualificationResult>();
        for (Lead leadRecord : leads) {
            Integer score = scoreLead(leadRecord);
            String rating = mapScoreToRating(score);

            leadRecord.Rating = rating;
            leadRecord.Description = 'Qualification score: ' + String.valueOf(score);

            LeadQualificationResult resultItem = new LeadQualificationResult();
            resultItem.leadId = leadRecord.Id;
            resultItem.score = score;
            resultItem.rating = rating;
            results.add(resultItem);
        }

        if (!leads.isEmpty()) {
            Database.update(leads, AccessLevel.USER_MODE);
        }
        return results;
    }

    @TestVisible
    private static Integer scoreLead(Lead leadRecord) {
        Integer score = 0;

        if (!String.isBlank(leadRecord.Email)) {
            score += 25;
        }
        if (!String.isBlank(leadRecord.Phone)) {
            score += 20;
        }
        if (!String.isBlank(leadRecord.Title)) {
            score += 15;
        }
        if (leadRecord.AnnualRevenue != null && leadRecord.AnnualRevenue >= 1000000) {
            score += 20;
        }
        if (leadRecord.NumberOfEmployees != null && leadRecord.NumberOfEmployees >= 100) {
            score += 20;
        }

        if (score > 100) {
            score = 100;
        }
        return score;
    }

    private static String mapScoreToRating(Integer score) {
        if (score >= 70) {
            return 'Hot';
        }
        if (score >= 40) {
            return 'Warm';
        }
        return 'Cold';
    }
}