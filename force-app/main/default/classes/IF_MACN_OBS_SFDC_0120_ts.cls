/**
 * Created by MS on 2023-04-21.
 */

@IsTest
private class IF_MACN_OBS_SFDC_0120_ts {
    @TestSetup
    static void testSetup(){
        IF_Master__c ifmaster = new IF_Master__c(
                Method__c = 'POST',
                Endpoint__c = 'www.test.com',
                APIKeyName__c = 'test',
                APIKeyValue__c ='test',
                IfId__c ='IF-NEW-544',
                isLogInsert__c = true
        );
        insert ifmaster;
    }

    @IsTest
    static void test01() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        IF_MACN_OBS_SFDC_0120.updateObsSalesInfo('test','test');
        IF_MACN_OBS_SFDC_0120.getObsSalesInfo('test','test');
        IF_MACN_OBS_SFDC_0120.getObsSalesInfoList(new Set<String>{'test_test'});
        Test.stopTest();
    }

    // StatusCode=200 Mock
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = newResponse(200);
            return res;
        }
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{ "Header" : {"rstType" : "test", "rstMsg" : "test" } , "Body" : { "data" : [ { "partNo" : "test", "divCode" : "test","PartNameKor" : "test","ObsSalesYN" : "Y", "ObsImageURL" : "testt","ObsSalesURL" : "test", "ObsMemberPrice" : 3000 } ] } } ');
        return res;
    }
}