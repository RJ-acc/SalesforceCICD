@isTest
public class OpsHealthRestApiTest {
    @isTest static void testGetHealthReturnsPayload() {
        Account accountRecord = AppTestDataFactory.createAccounts(1, true)[0];
        AppTestDataFactory.createOpenTasks(UserInfo.getUserId(), accountRecord.Id, 1, true);
        AppTestDataFactory.createOpenCases(accountRecord.Id, 1, true);
        AppTestDataFactory.createOpenOpportunities(accountRecord.Id, 1, true);

        RestRequest req = new RestRequest();
        req.requestUri = '/services/apexrest/ops/health';
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = new RestResponse();

        Test.startTest();
        OpsHealthRestApi.getHealth();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        String responseText = RestContext.response.responseBody.toString();
        Map<String, Object> payload = (Map<String, Object>)JSON.deserializeUntyped(responseText);

        System.assert(payload.containsKey('openTasks'));
        System.assert(payload.containsKey('openCases'));
        System.assert(payload.containsKey('openOpportunities'));
        System.assert(payload.containsKey('openPipelineAmount'));
        System.assert(payload.containsKey('generatedAt'));
    }
}