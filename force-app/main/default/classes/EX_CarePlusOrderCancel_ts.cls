/**
 * Created by MS on 2023-04-21.
 */

@IsTest
private class EX_CarePlusOrderCancel_ts {
    @IsTest
    static void test01() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0011'; //Request URL
        req.httpMethod = 'POST';

        req.requestBody = Blob.valueOf(JSON.serialize(new EX_CarePlusOrderCancel.Input()));

        RestContext.request = req;
        RestContext.response= res;

        EX_TestDataUtil.getCarePlusOrder(false);
        EX_TestDataUtil.careplusOrder.TRANS_TYPE__c = 'C';
        EX_TestDataUtil.careplusOrder.WORK_FLAG__c = 'N';
        EX_TestDataUtil.careplusOrder.CANCEL_FLAG__c = 'Y';
        EX_TestDataUtil.careplusOrder.RETURN_FLAG__c = 'N';
        EX_TestDataUtil.careplusOrder.CANCEL_QTY__c = EX_TestDataUtil.getProductRequestLineItem(true).QuantityRequested;
        insert EX_TestDataUtil.careplusOrder;

        EX_CarePlusOrderCancel.doPost();
        EX_CarePlusOrderCancel.getDoubleNotNull(null);
        EX_CarePlusOrderCancel.getDatetimeWithNull(null);

        Test.stopTest();
    }

    @IsTest
    static void test02() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0011'; //Request URL
        req.httpMethod = 'POST';

        req.requestBody = Blob.valueOf(JSON.serialize(new EX_CarePlusOrderCancel.Input()));

        RestContext.request = req;
        RestContext.response= res;

        EX_TestDataUtil.getCarePlusOrder(false);
        EX_TestDataUtil.careplusOrder.TRANS_TYPE__c = 'C';
        EX_TestDataUtil.careplusOrder.WORK_FLAG__c = 'N';
        EX_TestDataUtil.careplusOrder.CANCEL_FLAG__c = 'Y';
        EX_TestDataUtil.careplusOrder.RETURN_FLAG__c = 'N';
        EX_TestDataUtil.careplusOrder.CANCEL_QTY__c = EX_TestDataUtil.getProductRequestLineItem(true).QuantityRequested;
        insert EX_TestDataUtil.careplusOrder;
        EX_TestDataUtil.getCareplusOrderComplete(true);

        delete [SELECT Id FROM ProductRequest];

        EX_CarePlusOrderCancel.doPost();
        EX_CarePlusOrderCancel.getDoubleNotNull(null);
        EX_CarePlusOrderCancel.getDatetimeWithNull(null);

        Test.stopTest();
    }

    @IsTest
    static void test03() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0011'; //Request URL
        req.httpMethod = 'POST';

        req.requestBody = Blob.valueOf(JSON.serialize(new EX_CarePlusOrderCancel.Input()));

        RestContext.request = req;
        RestContext.response= res;

        EX_TestDataUtil.getCarePlusOrder(false);
        EX_TestDataUtil.careplusOrder.TRANS_TYPE__c = 'C';
        EX_TestDataUtil.careplusOrder.WORK_FLAG__c = 'N';
        EX_TestDataUtil.careplusOrder.CANCEL_FLAG__c = 'Y';
        EX_TestDataUtil.careplusOrder.RETURN_FLAG__c = 'Y';
        EX_TestDataUtil.careplusOrder.INTERFACE_ID__c = 11112;
        EX_TestDataUtil.careplusOrder.CANCEL_QTY__c = EX_TestDataUtil.getProductRequestLineItem(true).QuantityRequested;
        insert EX_TestDataUtil.careplusOrder;

        SI_CAREPLUS_ORDER__c order = EX_TestDataUtil.careplusOrder.clone();
        order.ORDER_NO__c = '11112';
        insert order;

        insert new SI_CAREPLUS_BACKIF__c(REQUEST_SEQ__c = 1, TRANS_TYPE__c = 'C', BACK_SUB_SEQ__c = 1, INTERFACE_ID__c = 11112, ORDER_NO__c = EX_TestDataUtil.careplusOrder.ORDER_NO__c);
        insert new SI_CAREPLUS_ORDER_REQUEST__c(TRANSFER_FLAG__c = 'F', ORIG_SYS_LINE_REF__c = 'REF', ORIG_SYS_DOCUMENT_REF__c = 'DOC', ORDER_TYPE__c = 'Type', ORDER_QTY__c = 10, ITEM_NO__c = 'ITEM_NO',CORPORATION_CODE__c = 'CODE', SO_INTERFACE_ID__c= 11112);

        EX_TestDataUtil.getCareplusOrderComplete(true);
        EX_CarePlusOrderCancel.doPost();

        EX_TestDataUtil.baseProductRequestLineItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_100;
        update EX_TestDataUtil.baseProductRequestLineItem;
        EX_CarePlusOrderCancel.doPost();

        delete [SELECT Id FROM ProductRequest];
        EX_CarePlusOrderCancel.doPost();
        EX_CarePlusOrderCancel.getDoubleNotNull(null);
        EX_CarePlusOrderCancel.getDatetimeWithNull(null);
        Test.stopTest();
    }

    @IsTest
    static void test04() {
        EX_TestDataUtil.getProductRequestLineItem(true);
        Test.startTest();
        EX_CarePlusOrderCancel.getDateWithNull(Date.today());
        EX_CarePlusOrderCancel.getDatetimeWithNull(DateTime.now());
        EX_CarePlusOrderCancel.getDoubleNotNull(0);
        EX_CarePlusOrderCancel.cancelProductRequestLineItem(EX_TestDataUtil.baseProductRequestLineItem, 10, DateTime.now(), 'W');
        EX_CarePlusOrderCancel.cancelProductRequestLineItem(EX_TestDataUtil.baseProductRequestLineItem, 10, DateTime.now(), 'F');
        Test.stopTest();
    }
}