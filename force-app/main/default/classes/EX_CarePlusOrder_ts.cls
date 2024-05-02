/**
 * Created by MS on 2023-04-20.
 */

@IsTest
private class EX_CarePlusOrder_ts {

    @TestSetup
    static void setup(){
        Test.startTest();
        EX_TestDataUtil.getCareplusOrder(true);
        // EX_TestDataUtil.getCareplusOrder1(true);
        // 필수필드 개많음;
        // insert new SI_CAREPLUS_ORDER_REQUEST__c(SO_INTERFACE_ID__c = 10);
        // insert new SI_CAREPLUS_BACKIF__c(INTERFACE_ID__c = 10);
        EX_TestDataUtil.getContact(true);
        Test.stopTest();
    }

    @IsTest
    static void test01() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0013'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new EX_CarePlusOrder.Input()));
        RestContext.request = req;
        RestContext.response= res;
        EX_CarePlusOrder.doPost();
        Test.stopTest();

    }

    @IsTest
    static void test02() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0013'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new EX_CarePlusOrder.Input()));
        RestContext.request = req;
        RestContext.response= res;
        List<SI_CAREPLUS_ORDER__c> order = [SELECT Id, INTERFACE_ID__c FROM SI_CAREPLUS_ORDER__c];
        if(!order.isEmpty()){
            order[0].WORK_FLAG__c = 'H';
            update order;
            SI_CAREPLUS_ORDER_COMPLETE__c careplusOrderComplete = new SI_CAREPLUS_ORDER_COMPLETE__c();
            careplusOrderComplete.INTERFACE_ID__c =order[0].INTERFACE_ID__c;
            careplusOrderComplete.ORG_ID__c = 34142;
            careplusOrderComplete.ORIG_SYS_DOCUMENT_REF__c = [SELECT Order_Number__c FROM ProductRequest][0].Order_Number__c;
            careplusOrderComplete.ITEM_NO__c = [SELECT PART_NO__c FROM ProductRequestLineItem][0].PART_NO__c;
            careplusOrderComplete.ORDER_TYPE__c = 'PO';
            careplusOrderComplete.LINE_STATUS_CODE__c = 'SHIPPED';
            careplusOrderComplete.WORK_FLAG__c = 'Y';
            insert careplusOrderComplete;
            EX_CarePlusOrder.doPost();

            ProductRequestLineItem lineItem = [SELECT Id, PART_NO__c, Order_Number__c FROM ProductRequestLineItem LIMIT 1];
            SI_CAREPLUS_ORDER_COMPLETE__c careplusOrderComplete2 = careplusOrderComplete.clone();
            careplusOrderComplete2.LINE_STATUS_CODE__c = 'NOT';
            careplusOrderComplete2.ORIG_SYS_DOCUMENT_REF__c = lineItem.Order_Number__c;
            careplusOrderComplete2.ITEM_NO__c = lineItem.PART_NO__c;
            careplusOrderComplete2.WORK_FLAG__c = 'N';
            insert careplusOrderComplete2;
            EX_CarePlusOrder.doPost();
        }
        Test.stopTest();
    }

    @IsTest
    static void test_batch02() {
        Test.startTest();
        List<SI_CAREPLUS_ORDER__c> order = [SELECT Id, INTERFACE_ID__c, ORDER_NO__c, BILL_TO_CODE__c,ORDER_DATE__c,SHIP_TO_CODE__c,RECEIVER_NAME__c,RECEIVER_PHONE_NO__c,BASIC_ADDRESS__c,DETAIL_ADDRESS__c,ORDER_DESCRIPTION__c,POSTAL_CODE__c,ATTRIBUTE8__c,ORDER_AMT__c,ORDER_QTY__c,DIV_CODE__c,PART_NO__c,ATTRIBUTE4__c,WORK_FLAG__c,CANCEL_FLAG__c,CANCEL_DATE__c,CANCEL_QTY__c,MODEL_CODE__c,ORDER_PRICE__c FROM SI_CAREPLUS_ORDER__c];
        if(!order.isEmpty()){
            ProductRequest setPr = new ProductRequest();
            setPr = EX_CarePlusOrder.setProductRequest(order[0], setPr);
            ProductRequestLineItem setPrli = new ProductRequestLineItem();
            List<Product2> p2List = new List<Product2>();
            List<ProductItem> piList = new List<ProductItem>();
            setPrli = EX_CarePlusOrder.setProductRequestLineItem(order[0], setPr, setPrli, p2List, piList, false);
            //order[0].WORK_FLAG__c = 'H';
            order[0].WORK_FLAG__c = 'I';
            update order;
            SI_CAREPLUS_ORDER_COMPLETE__c careplusOrderComplete = new SI_CAREPLUS_ORDER_COMPLETE__c();
            careplusOrderComplete.INTERFACE_ID__c =order[0].INTERFACE_ID__c;
            careplusOrderComplete.ORG_ID__c = 34142;
            careplusOrderComplete.ORIG_SYS_DOCUMENT_REF__c = [SELECT Order_Number__c FROM ProductRequest][0].Order_Number__c;
            careplusOrderComplete.ITEM_NO__c = [SELECT PART_NO__c FROM ProductRequestLineItem][0].PART_NO__c;
            careplusOrderComplete.ORDER_TYPE__c = 'PO';
            //careplusOrderComplete.LINE_STATUS_CODE__c = 'SHIPPED';
            careplusOrderComplete.LINE_STATUS_CODE__c = 'AWAITING_SHIPPING';
            //careplusOrderComplete.LINE_STATUS_CODE__c = 'AWAITING_SHIPPING';
            careplusOrderComplete.WORK_FLAG__c = 'Y';
            insert careplusOrderComplete;

            order[0].WORK_FLAG__c = 'I';
            update order;
            ProductRequestLineItem lineItem = [SELECT Id, PART_NO__c, Order_Number__c FROM ProductRequestLineItem LIMIT 1];
            SI_CAREPLUS_ORDER_COMPLETE__c careplusOrderComplete2 = careplusOrderComplete.clone();
            careplusOrderComplete2.LINE_STATUS_CODE__c = 'NOT';
            careplusOrderComplete2.ORIG_SYS_DOCUMENT_REF__c = lineItem.Order_Number__c;
            careplusOrderComplete2.ITEM_NO__c = lineItem.PART_NO__c;
            careplusOrderComplete2.WORK_FLAG__c = 'N';
            insert careplusOrderComplete2;

            EX_CarePlusOrder.doPost();

            ProductRequest pr = [SELECT id, Order_Number__c FROM ProductRequest WHERE Order_Number__c = 'O3443243' LIMIT 1];
            pr.Order_Number__c = 'O3443243-11';
            update pr;
            EX_CarePlusOrder.doPost();


        }
        Test.stopTest();
    }

    @IsTest
    static void test03() {
        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0013'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(new EX_CarePlusOrder.Input()));
        RestContext.request = req;
        RestContext.response= res;
        List<Product2> pd = [SELECT Id FROM Product2 WHERE DISABLED_DT__c != NULL];
        if(!pd.isEmpty()){
            pd[0].DISABLED_DT__c = NULL;
            update pd;

            delete [SELECT Id FROM ProductRequest];
            EX_CarePlusOrder.doPost();
        }
        Test.stopTest();

    }

    @IsTest
    static void test04(){
        Test.startTest();
        List<SI_CAREPLUS_ORDER__c> order = [SELECT Id, INTERFACE_ID__c FROM SI_CAREPLUS_ORDER__c];
        List<ProductRequest> pr = [SELECT Order_Number__c FROM ProductRequest];
        if(!order.isEmpty() && !pr.isEmpty()){
            order[0].WORK_FLAG__c = 'H';
            update order;
            SI_CAREPLUS_ORDER_COMPLETE__c careplusOrderComplete = new SI_CAREPLUS_ORDER_COMPLETE__c();
            careplusOrderComplete.INTERFACE_ID__c =order[0].INTERFACE_ID__c;
            careplusOrderComplete.ORG_ID__c = 34142;
            careplusOrderComplete.ORIG_SYS_DOCUMENT_REF__c = pr[0].Order_Number__c;
            careplusOrderComplete.ITEM_NO__c = [SELECT PART_NO__c FROM ProductRequestLineItem][0].PART_NO__c;
            careplusOrderComplete.ORDER_TYPE__c = 'PO';
            careplusOrderComplete.LINE_STATUS_CODE__c = 'OVERDUE_HOLD';
            careplusOrderComplete.WORK_FLAG__c = 'Y';
            insert careplusOrderComplete;

            EX_CarePlusOrder.getSiCareplusOrderComplete(careplusOrderComplete.ORIG_SYS_DOCUMENT_REF__c, careplusOrderComplete.ITEM_NO__c, careplusOrderComplete.WORK_FLAG__c,careplusOrderComplete.ORDER_TYPE__c );
        }
        Test.stopTest();
    }
}