/**
 * Created by MS on 2023-04-21.
 */

@IsTest
private class EX_CarePlusOrderReturn_ts {
    @IsTest
    static void test01() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0012'; //Request URL
        req.httpMethod = 'POST';

        req.requestBody = Blob.valueOf(JSON.serialize(new EX_CarePlusOrderReturn.Input()));

        RestContext.request = req;
        RestContext.response= res;

        EX_TestDataUtil.getCarePlusOrder(false);
        EX_TestDataUtil.careplusOrder.TRANS_TYPE__c = 'R';
        EX_TestDataUtil.careplusOrder.WORK_FLAG__c = 'N';
        insert EX_TestDataUtil.careplusOrder;

        EX_TestDataUtil.getReturnOrderLineItem(true);


        EX_CarePlusOrderReturn.doPost();

        Test.stopTest();
    }

    @IsTest
    static void test02() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0012'; //Request URL
        req.httpMethod = 'POST';

        req.requestBody = Blob.valueOf(JSON.serialize(new EX_CarePlusOrderReturn.Input()));

        RestContext.request = req;
        RestContext.response= res;

        EX_TestDataUtil.getCarePlusOrder(false);
        EX_TestDataUtil.careplusOrder.TRANS_TYPE__c = 'R';
        EX_TestDataUtil.careplusOrder.WORK_FLAG__c = 'N';
        insert EX_TestDataUtil.careplusOrder;

        EX_TestDataUtil.getReturnOrder(true);


        EX_CarePlusOrderReturn.doPost();
        EX_CarePlusOrderReturn.getDateWithNull(null);
        EX_CarePlusOrderReturn.getDoubleNotNull(null);

        Test.stopTest();
    }
}