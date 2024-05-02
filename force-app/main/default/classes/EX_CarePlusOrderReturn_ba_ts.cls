/****************************************************************************************
 * @filename      : EX_CarePlusOrderReturn_ba_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-16 오후 1:17
 * @group         :
 * @group-content :
 * @description   : EX_CarePlusOrderReturn_ba Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-16       I2max               Create
 ****************************************************************************************/

@IsTest
private class EX_CarePlusOrderReturn_ba_ts {
    @IsTest
    static void test_batch01() {
        Test.startTest();

       

        
         EX_TestDataUtil.getCarePlusOrder(false);
         EX_TestDataUtil.careplusOrder.TRANS_TYPE__c = 'R';
        EX_TestDataUtil.careplusOrder.WORK_FLAG__c = 'N';
        EX_TestDataUtil.careplusOrder.ORDER_PRICE__c = 10000;
        EX_TestDataUtil.careplusOrder.ORDER_QTY__c = 2;
        insert EX_TestDataUtil.careplusOrder;

        EX_TestDataUtil.getCarePlusOrder1(false);
        EX_TestDataUtil.careplusOrder1.TRANS_TYPE__c = 'O';
        EX_TestDataUtil.careplusOrder1.CANCEL_FLAG__c = null;
        EX_TestDataUtil.careplusOrder1.PART_NO__c = EX_TestDataUtil.baseProductRequestLineItem.PART_NO__c;
        EX_TestDataUtil.careplusOrder1.BILL_TO_CODE__c = EX_TestDataUtil.getAccount(true).AR_CODE__c;
        EX_TestDataUtil.careplusOrder1.SHIP_TO_CODE__c = 'KR034984003-S';
        EX_TestDataUtil.careplusOrder1.MODEL_CODE__c = 'ModelCode';
        EX_TestDataUtil.careplusOrder1.ORDER_PRICE__c = 10000;
        EX_TestDataUtil.careplusOrder1.ORDER_QTY__c = 2;
        insert EX_TestDataUtil.careplusOrder1;

        EX_TestDataUtil.getReturnOrderLineItem(true);
        // EX_TestDataUtil.getReturnOrderLineItem(false);
        // EX_TestDataUtil.baseReturnOrderLineItem.
        Database.executeBatch(new EX_CarePlusOrderReturn_ba(), 1);
        Test.stopTest();
    }


    @IsTest
    static void test_batch02() {
        Test.startTest();
        EX_TestDataUtil.getCarePlusOrder(false);
        EX_TestDataUtil.careplusOrder.TRANS_TYPE__c = 'R';
        EX_TestDataUtil.careplusOrder.WORK_FLAG__c = 'N';
        EX_TestDataUtil.careplusOrder.ORDER_PRICE__c = 10000;
        insert EX_TestDataUtil.careplusOrder;
        EX_TestDataUtil.getReturnOrder(false);
        EX_TestDataUtil.baseReturnOrder.Order_CHNL_TYPE_Code__c = 'BestShop';
        // EX_TestDataUtil.baseReturnOrder.SHIP_TO_CODE__c = 'KR034984003-S';
        // EX_TestDataUtil.baseReturnOrder.MODEL_CODE__c = 'ModelCode';

        // careplusOrder.SHIP_TO_CODE__c = 'KR034984003-S';
        // careplusOrder.MODEL_CODE__c = 'ModelCode';
        insert EX_TestDataUtil.baseReturnOrder;
        Database.executeBatch(new EX_CarePlusOrderReturn_ba(), 1);
        Test.stopTest();
    }
}