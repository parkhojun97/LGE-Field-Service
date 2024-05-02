/**
 * Created by MS on 2023-04-21.
 */

@IsTest
private class EX_CicOrderCancel_ts {
    @TestSetup
    static void setup(){
        try {
            IF_Master__c ifmaster = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'www.test.com',
                    APIKeyName__c = 'test',
                    APIKeyValue__c = 'test',
                    IfId__c = 'CicOrderCancel',
                    isLogInsert__c = true
            );

            insert ifmaster;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        insert new PaymentAPISetting_cs__c(Name = 'SpendOrCancelPoint', ApiKey__c = 'ApiKey', EndPoint__c = 'EndPoint');
        insert new SR_SMARTRO_PAYMENT_REQUEST__c(SMARTRO_PAYMENT_REQUEST_PK__c = '3', MOID__c = 'MOID', PAYMENT_TYPE__c = 'PG_URL');

        Date paymentRequestDate = Date.newInstance(2023, 8, 7);
        ProductRequest pr = EX_TestDataUtil.getProductRequest(false);
        pr.PAYMENT_TYPE__c = 'URL';
        pr.PAYMENT_Method_Code__c = 'VBANK';
        pr.Order_Number__c = 'O90342';
        pr.Order_CHNL_TYPE_Code__c = 'V';
        pr.MOID__c = 'MOID';
        pr.LIMIT_TM__c = paymentRequestDate;
        insert pr;

        ProductRequest pr2 = pr.clone();
        pr2.PAYMENT_TYPE__c = 'VBank';
        pr2.Order_Number__c = 'O90344';
        insert pr2;

        ProductRequestLineItem rli1 = EX_TestDataUtil.getProductRequestLineItem(false);
        rli1.ParentId = pr.Id;
        rli1.Order_Number__c = pr.Order_Number__c;
        insert rli1;

        ProductRequestLineItem rli2 = rli1.clone();
        rli2.ParentId = pr2.Id;
        rli2.Order_Number__c = pr2.Order_Number__c;
        insert rli2;

        EX_TestDataUtil.getPaymentGateway(true);
    }

    @IsTest
    static void test_doPost() {
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        List<ProductRequest> productRequests = [SELECT Id FROM ProductRequest LIMIT 2];
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/heroku/CicOrderCancel'; //Request URL
        req.httpMethod = 'POST';

        EX_CicOrderCancel.InputBody inputBody = new EX_CicOrderCancel.InputBody();
        EX_CicOrderCancel.InputData inputData1 = new EX_CicOrderCancel.InputData();
        inputData1.sfId = productRequests[0].Id;
        EX_CicOrderCancel.InputData inputData2 = new EX_CicOrderCancel.InputData();
        inputData2.sfId = productRequests[1].Id;
        inputBody.params = new List<EX_CicOrderCancel.InputData>{inputData1, inputData2};
        req.requestBody = Blob.valueOf(JSON.serialize(inputBody));
        RestContext.request = req;
        RestContext.response= res;


        Test.startTest();
        EX_CicOrderCancel.doPost();
        Test.stopTest();
    }



    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = newResponse(200, req.getEndpoint());
            return res;
        }
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode, String endpoint) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{ "ACCUM_BRKDN_ID":"1000006628366", "ORIG_ACCUM_BRKDN_ID":"1000006628286", "RTN_CD":"S", "RTN_MSG":"정상처리되었습니다"}');

        return res;
    }
}