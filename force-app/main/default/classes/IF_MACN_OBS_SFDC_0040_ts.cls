/****************************************************************************************
 * @filename      : IF_MACN_OBS_SFDC_0040_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-09 오후 2:46
 * @group         :
 * @group-content :
 * @description   : IF_MACN_OBS_SFDC_0040 Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-09       I2max               Create
 ****************************************************************************************/

@IsTest
private class IF_MACN_OBS_SFDC_0040_ts {
    @TestSetup
    static void setup() {
        ReturnOrder sr = EX_TestDataUtil.getReturnOrder(false);
        sr.Request_Number__c = 'Test';
        insert sr;

        ReturnOrderLineItem reLineItem = EX_TestDataUtil.getReturnOrderLineItem(false);
        reLineItem.ReturnOrderId = sr.Id;
        insert reLineItem;

        ProductRequestLineItem prli = EX_TestDataUtil.baseProductRequestLineItem;
        prli.INVOICE_Number__c = 'Test';
        update prli;

        EX_TestDataUtil.getProductRequestLineItem(true);
        SR_ONLINE_DELIVERY_INFO__c deliveryInfo = new SR_ONLINE_DELIVERY_INFO__c();
        deliveryInfo.ProductRequestLineItem__c = EX_TestDataUtil.baseProductRequestLineItem.Id;
        deliveryInfo.ReturnOrderLineItem__c = reLineItem.Id;
        deliveryInfo.ORDER_TYPE__c = 'O';


        insert deliveryInfo;
    }

    @IsTest
    static void test_doPost() {
        ReturnOrder sr = [select Id,Request_Number__c from ReturnOrder Limit 1];
        Product2 prod  = [select id,Name,DIV_CODE__c from Product2 Limit 1];
        ProductRequestLineItem prdItemLine = [select id,Order_SEQ__c,Parent.Order_Number__c from ProductRequestLineItem Limit 1];

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0040'; //Request URL
        req.httpMethod = 'POST';
        String requestStr1 = '{"OrderReturn" : [{ "originOrderSeq" : "'+prdItemLine.Order_SEQ__c+'", "originOrderNo" : "'+prdItemLine.Parent.Order_Number__c+'", "orderNo" : "' + sr.Request_Number__c + '" , "divCode" : "' + prod.DIV_CODE__c + '" , "partNo" : "' + prod.Name+ '", "orderSeq" : "' + prdItemLine.Order_SEQ__c+ '" }] }';
        String requestStr2 = '{"OrderReturn" : [{ "originOrderSeq" : "'+prdItemLine.Order_SEQ__c+'", "originOrderNo" : "'+prdItemLine.Parent.Order_Number__c+'", "orderNo" : "' + 'NEW_ORDER_ID' + '" , "divCode" : "' + prod.DIV_CODE__c + '" , "partNo" : "' + prod.Name+ '", "orderSeq" : "' + prdItemLine.Order_SEQ__c+ '" }] }';
        req.requestBody = Blob.valueOf(requestStr1);
        RestContext.request = req;
        RestContext.response= res;
        try{
            IF_MACN_OBS_SFDC_0040.doPost();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        try{
            req.requestBody = Blob.valueOf(requestStr2);
            IF_MACN_OBS_SFDC_0040.doPost();
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
}