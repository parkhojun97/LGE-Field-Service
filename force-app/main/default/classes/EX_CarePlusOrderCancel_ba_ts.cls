/****************************************************************************************
 * @filename      : EX_CarePlusOrderCancel_ba_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-16 오후 1:17
 * @group         :
 * @group-content :
 * @description   : EX_CarePlusOrderCancel_ba Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-16       I2max               Create
 ****************************************************************************************/

@IsTest
private class EX_CarePlusOrderCancel_ba_ts {
    @TestSetup
    static void setup() {
        EX_TestDataUtil.getCarePlusOrder(false);
        EX_TestDataUtil.careplusOrder.CANCEL_QTY__c = EX_TestDataUtil.getProductRequestLineItem(true).QuantityRequested;
        EX_TestDataUtil.careplusOrder.INTERFACE_ID__c = 11112;
        insert EX_TestDataUtil.careplusOrder;
        SI_CAREPLUS_ORDER__c order = EX_TestDataUtil.careplusOrder.clone();
        order.ORDER_NO__c = '11112';
        insert order;
        insert new SI_CAREPLUS_BACKIF__c(REQUEST_SEQ__c = 1, TRANS_TYPE__c = 'C', BACK_SUB_SEQ__c = 1, INTERFACE_ID__c = 11112, ORDER_NO__c = EX_TestDataUtil.careplusOrder.ORDER_NO__c);
        insert new SI_CAREPLUS_ORDER_REQUEST__c(TRANSFER_FLAG__c = 'F', ORIG_SYS_LINE_REF__c = 'REF', ORIG_SYS_DOCUMENT_REF__c = 'DOC', ORDER_TYPE__c = 'Type', ORDER_QTY__c = 10, ITEM_NO__c = 'ITEM_NO',CORPORATION_CODE__c = 'CODE', SO_INTERFACE_ID__c= 11112);
    }

    @IsTest
    static void test_batch01() {
        SI_CAREPLUS_ORDER__c order = [select id,TRANS_TYPE__c,WORK_FLAG__c,CANCEL_FLAG__c,RETURN_FLAG__c From SI_CAREPLUS_ORDER__c Limit 1];
        order.TRANS_TYPE__c = 'C';
        order.WORK_FLAG__c = 'N';
        order.CANCEL_FLAG__c = 'Y';
        order.RETURN_FLAG__c = 'N';
        update order;
        Test.startTest();
        Database.executeBatch(new EX_CarePlusOrderCancel_ba(null), 1);
        Test.stopTest();
    }

    @IsTest
    static void test_batch02() {
        SI_CAREPLUS_ORDER__c order = [select id,TRANS_TYPE__c,WORK_FLAG__c,CANCEL_FLAG__c,RETURN_FLAG__c From SI_CAREPLUS_ORDER__c Limit 1];
        order.TRANS_TYPE__c = 'C';
        order.WORK_FLAG__c = 'N';
        order.CANCEL_FLAG__c = 'Y';
        order.RETURN_FLAG__c = 'Y';
        update order;
        Test.startTest();
        Database.executeBatch(new EX_CarePlusOrderCancel_ba(null), 1);
        Test.stopTest();
    }

    @IsTest
    static void test_batch03() {
        SI_CAREPLUS_ORDER__c order = [select id,TRANS_TYPE__c,WORK_FLAG__c,CANCEL_FLAG__c,RETURN_FLAG__c From SI_CAREPLUS_ORDER__c Limit 1];
        order.TRANS_TYPE__c = 'C';
        order.WORK_FLAG__c = 'N';
        order.CANCEL_FLAG__c = 'Y';
        order.RETURN_FLAG__c = 'N';
        update order;
        delete [SELECT Id FROM ProductRequest];
        Test.startTest();
        Database.executeBatch(new EX_CarePlusOrderCancel_ba(null), 1);
        Test.stopTest();
    }

    @IsTest
    static void test_batch04() {
        SI_CAREPLUS_ORDER__c order = [select id,TRANS_TYPE__c,WORK_FLAG__c,CANCEL_FLAG__c,RETURN_FLAG__c From SI_CAREPLUS_ORDER__c Limit 1];
        order.TRANS_TYPE__c = 'C';
        order.WORK_FLAG__c = 'N';
        order.CANCEL_FLAG__c = 'Y';
        order.RETURN_FLAG__c = 'Y';
        update order;
        delete [SELECT Id FROM ProductRequest];
        Test.startTest();
        Database.executeBatch(new EX_CarePlusOrderCancel_ba(null), 1);
        Test.stopTest();
    }

    @IsTest
    static void test_batch05() {
        ProductRequestLineItem lineItem = [select id,SALE_Quantity__c from ProductRequestLineItem Limit 1];
        SI_CAREPLUS_ORDER__c order = [SELECT id,ORDER_NO__c, REQUEST_SEQ__c, SHIP_TO_CODE__c,RECEIVER_NAME__c,PART_NO__c,ORDER_QTY__c, MODEL_CODE__c, ORDER_PRICE__c,DIV_CODE__c FROM SI_CAREPLUS_ORDER__c LIMIT 1];
        // SI_CAREPLUS_ORDER_COMPLETE__c complte = [SELECT Id, LINE_STATUS_CODE__c, LINE_ID__c,WORK_FLAG__c FROM SI_CAREPLUS_ORDER_COMPLETE__c LIMIT 1];
        Test.startTest();
        EX_CarePlusOrderCancel_ba.getDateWithNull(Date.today());
        EX_CarePlusOrderCancel_ba.getDatetimeWithNull(DateTime.now());
        EX_CarePlusOrderCancel_ba.getDoubleNotNull(0);
        EX_CarePlusOrderCancel_ba.cancelProductRequestLineItem(lineItem, 10, DateTime.now(), 'W');
        EX_CarePlusOrderCancel_ba.cancelProductRequestLineItem(lineItem, 10, DateTime.now(), 'F');
        EX_CarePlusOrderCancel_ba.insertSiCareplusOrderRequest(order, true, 299999900, 1,0);
        Test.stopTest();
    }
}