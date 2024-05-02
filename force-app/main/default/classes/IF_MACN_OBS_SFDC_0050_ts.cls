/**
 * Created by MS on 2023-04-27.
 */

@IsTest
private class IF_MACN_OBS_SFDC_0050_ts {
    @TestSetup
    static void setup(){
        Test.startTest();
        try {
            IF_Master__c ifmaster = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'www.test.com',
                    APIKeyName__c = 'test',
                    APIKeyValue__c = 'test',
                    IfId__c = 'IF-NEW-506',
                    isLogInsert__c = true
            );

            insert ifmaster;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        Test.stopTest();
    }
    @IsTest
    static void test01() {

        Test.startTest();


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0050'; //Request URL
        req.httpMethod = 'POST';

        EX_TestDataUtil.getProductRequestLineItem(true);
        String input = '{ ';
        input       += ' "Body" : {"orderCancel" : [ { "orderNo" : "' + EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c + '" , "orderSeq" : "' + EX_TestDataUtil.baseProductRequestLineItem.Order_SEQ__c + '" } ] } ';
        input       += ' }';

        req.requestBody = Blob.valueOf(input);

        RestContext.request = req;
        RestContext.response= res;

        IF_MACN_OBS_SFDC_0050.doPost();

        Test.stopTest();
    }

    @IsTest
    static void test02() {

        Test.startTest();


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0050'; //Request URL
        req.httpMethod = 'POST';

        EX_TestDataUtil.getProductRequestLineItem(false);
        EX_TestDataUtil.baseProductRequestLineItem.SALE_Number__c = '3243';
        EX_TestDataUtil.getProductRequestLineItem(true);

        String input = '{ ';
        input       += ' "Body" : {"orderCancel" : [ { "orderNo" : "' + EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c + '" , "orderSeq" : "' + EX_TestDataUtil.baseProductRequestLineItem.Order_SEQ__c + '" } ] } ';
        input       += ' }';

        req.requestBody = Blob.valueOf(input);

        RestContext.request = req;
        RestContext.response= res;

        IF_MACN_OBS_SFDC_0050.doPost();

        Test.stopTest();
    }

    @IsTest
    static void test03() {

        Test.startTest();


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0050'; //Request URL
        req.httpMethod = 'POST';

        EX_TestDataUtil.getProductRequestLineItem(false);
        EX_TestDataUtil.baseProductRequestLineItem.Consumables_Order_Status__c = '004';
        EX_TestDataUtil.getProductRequestLineItem(true);

        String input = '{ ';
        input       += ' "Body" : {"orderCancel" : [ { "orderNo" : "' + EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c + '" , "orderSeq" : "' + EX_TestDataUtil.baseProductRequestLineItem.Order_SEQ__c + '" } ] } ';
        input       += ' }';

        req.requestBody = Blob.valueOf(input);

        RestContext.request = req;
        RestContext.response= res;

        IF_MACN_OBS_SFDC_0050.doPost();

        Test.stopTest();
    }

    @IsTest
    static void test04() {

        Test.startTest();


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0050'; //Request URL
        req.httpMethod = 'POST';

        EX_TestDataUtil.getProductRequestLineItem(false);
        EX_TestDataUtil.baseProductRequestLineItem.INVOICE_Number__c = '032404';
        EX_TestDataUtil.getProductRequestLineItem(true);

        String input = '{ ';
        input       += ' "Body" : {"orderCancel" : [ { "orderNo" : "' + EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c + '" , "orderSeq" : "' + EX_TestDataUtil.baseProductRequestLineItem.Order_SEQ__c + '" } ] } ';
        input       += ' }';

        req.requestBody = Blob.valueOf(input);

        RestContext.request = req;
        RestContext.response= res;

        IF_MACN_OBS_SFDC_0050.doPost();

        Test.stopTest();
    }
}