@RestResource(urlMapping='/ops/health/*')
global with sharing class OpsHealthRestApi {
    global class HealthPayload {
        public Integer openTasks;
        public Integer openCases;
        public Integer openOpportunities;
        public Decimal openPipelineAmount;
        public String generatedAt;
    }

    @HttpGet
    global static void getHealth() {
        HealthPayload payload = new HealthPayload();
        payload.openTasks = [SELECT COUNT() FROM Task WHERE IsClosed = false WITH USER_MODE];
        payload.openCases = [SELECT COUNT() FROM Case WHERE IsClosed = false WITH USER_MODE];
        payload.openOpportunities = [SELECT COUNT() FROM Opportunity WHERE IsClosed = false WITH USER_MODE];

        List<AggregateResult> pipeline = [
            SELECT SUM(Amount) totalAmount
            FROM Opportunity
            WHERE IsClosed = false
            WITH USER_MODE
        ];
        payload.openPipelineAmount =
            (pipeline.isEmpty() || pipeline[0].get('totalAmount') == null)
            ? 0
            : Decimal.valueOf(String.valueOf(pipeline[0].get('totalAmount')));
        payload.generatedAt = String.valueOf(System.now());

        RestResponse response = RestContext.response;
        response.statusCode = 200;
        response.addHeader('Content-Type', 'application/json');
        response.responseBody = Blob.valueOf(JSON.serialize(payload));
    }
}