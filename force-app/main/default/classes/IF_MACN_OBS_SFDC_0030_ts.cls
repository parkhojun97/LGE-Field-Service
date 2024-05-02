/**
 * Created by MS on 2023-04-21.
 */

@IsTest
private class IF_MACN_OBS_SFDC_0030_ts {
    @IsTest
    static void test01() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0030'; //Request URL
        req.httpMethod = 'POST';

        String requestStr = '{"orderCancel" : [{ "orderNo" : "' + EX_TestDataUtil.getProductRequestLineItem(true).Order_Number__c + '" , "divCode" : "' + EX_TestDataUtil.baseProduct.DIV_CODE__c + '" , "partNo" : "' + EX_TestDataUtil.baseProduct.Name + '", "orderSeq" : "' + EX_TestDataUtil.getProductRequestLineItem(true).Order_SEQ__c + '" }] }';
        req.requestBody = Blob.valueOf(requestStr);
        RestContext.request = req;
        RestContext.response = res;

        try {
            IF_MACN_OBS_SFDC_0030.doPost();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void test02() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0030'; //Request URL
        req.httpMethod = 'POST';

        SR_ONLINE_DELIVERY_INFO__c deliveryInfo = new SR_ONLINE_DELIVERY_INFO__c();
        deliveryInfo.ProductRequestLineItem__c = EX_TestDataUtil.getProductRequestLineItem(true).Id;
        insert deliveryInfo;

        String requestStr = '{"orderCancel" : [{ "orderNo" : "' + EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c + '" , "divCode" : "' + EX_TestDataUtil.baseProduct.DIV_CODE__c + '" , "partNo" : "' + EX_TestDataUtil.baseProduct.Name + '", "orderSeq" : "' + EX_TestDataUtil.getProductRequestLineItem(true).Order_SEQ__c + '" }] }';
        req.requestBody = Blob.valueOf(requestStr);
        RestContext.request = req;
        RestContext.response = res;

        try {
            IF_MACN_OBS_SFDC_0030.doPost();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void test03() {
        Test.startTest();
        String requestStr = '{"orderCancel" : [{ "orderNo" : 1 , "divCode" : "divCode" , "partNo" : "partNo", "orderSeq" : 1 }] }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0030'; //Request URL
        req.httpMethod = 'POST';
        try {
            IF_MACN_OBS_SFDC_0030.doPost();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        req.requestBody = Blob.valueOf(requestStr);
        RestContext.request = req;
        RestContext.response = res;
        try {
            IF_MACN_OBS_SFDC_0030.doPost();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void test04() { // code: 500
        Test.startTest();
        String requestStr = '}';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestStr);
        RestContext.request = req;
        RestContext.response = res;
        try {
            IF_MACN_OBS_SFDC_0030.doPost();
        } catch (Exception e) {
        }
        Test.stopTest();
    }

    @IsTest
    static void test05() { // 정상적으로 취소요청 되었습니다
        SR_RESRV_PART__c[] parts = new SR_RESRV_PART__c[]{
                new SR_RESRV_PART__c(),
                new SR_RESRV_PART__c()
        };
        insert parts;
        ProductRequest[] prs = new ProductRequest[]{
                new ProductRequest(Order_Number__c = '1', SR_RSRV_PART_Id__c = parts[0].Id),
                new ProductRequest(Order_Number__c = '2', SR_RSRV_PART_Id__c = parts[1].Id),
                new ProductRequest(Order_Number__c = '3', SR_RSRV_PART_Id__c = null)
        };
        insert prs;
        Product2[] product2s = new Product2[]{
                EX_TestDataUtil.createProduct()
        };

        insert new ProductRequestLineItem[]{
                new ProductRequestLineItem(ParentId = prs[0].Id, Product2Id = product2s[0].Id, ENDP_RSV_Quantity__c = 1, QuantityRequested = 1),
                new ProductRequestLineItem(ParentId = prs[1].Id, Product2Id = product2s[0].Id, ENDP_RSV_Quantity__c = 0, QuantityRequested = 1),
                new ProductRequestLineItem(ParentId = prs[2].Id, Product2Id = product2s[0].Id, ENDP_RSV_Quantity__c = 0, QuantityRequested = 1)
        };
        Test.startTest();
        String requestStr = '{"orderCancel" : [{ "orderNo" : "1" , "divCode" : "dc-1" , "partNo" : "p-1", "orderSeq" : "1" },' +
                '{ "orderNo" : "1" , "divCode" : "dc-12" , "partNo" : "p-12", "orderSeq" : "2" },' +
                '{ "orderNo" : "2" , "divCode" : "dc-2" , "partNo" : "p-2", "orderSeq" : "1" }' +
                '] }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestStr);
        RestContext.request = req;
        RestContext.response = res;
        try {
            IF_MACN_OBS_SFDC_0030.doPost();
        } catch (Exception e) {
        }
        Test.stopTest();
    }
    @IsTest
    static void test06() { // 해당 주문의 판매번호가 이미 존재합니다
        SR_RESRV_PART__c[] parts = new SR_RESRV_PART__c[]{
                new SR_RESRV_PART__c(),
                new SR_RESRV_PART__c()
        };
        insert parts;
        ProductRequest[] prs = new ProductRequest[]{
                new ProductRequest(Order_Number__c = '1', SR_RSRV_PART_Id__c = parts[0].Id, SALE_Number__c = '1234'),
                new ProductRequest(Order_Number__c = '2', SR_RSRV_PART_Id__c = parts[1].Id),
                new ProductRequest(Order_Number__c = '3', SR_RSRV_PART_Id__c = null)
        };
        insert prs;
        Product2[] product2s = new Product2[]{
                EX_TestDataUtil.createProduct()
        };

        insert new ProductRequestLineItem[]{
                new ProductRequestLineItem(ParentId = prs[0].Id, Product2Id = product2s[0].Id, ENDP_RSV_Quantity__c = 1, QuantityRequested = 1),
                new ProductRequestLineItem(ParentId = prs[1].Id, Product2Id = product2s[0].Id, ENDP_RSV_Quantity__c = 0, QuantityRequested = 1),
                new ProductRequestLineItem(ParentId = prs[2].Id, Product2Id = product2s[0].Id, ENDP_RSV_Quantity__c = 0, QuantityRequested = 1)
        };
        Test.startTest();
        String requestStr = '{"orderCancel" : [{ "orderNo" : "1" , "divCode" : "dc-1" , "partNo" : "p-1", "orderSeq" : "1" },' +
                '{ "orderNo" : "1" , "divCode" : "dc-12" , "partNo" : "p-12", "orderSeq" : "2" },' +
                '{ "orderNo" : "2" , "divCode" : "dc-2" , "partNo" : "p-2", "orderSeq" : "1" }' +
                '] }';
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestBody = Blob.valueOf(requestStr);
        RestContext.request = req;
        RestContext.response = res;
        try {
            IF_MACN_OBS_SFDC_0030.doPost();
        } catch (Exception e) {
        }
        Test.stopTest();
    }
}