/****************************************************************************************
 * @filename      : EX_ReturnConfirm_ba_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-25 오후 2:11
 * @group         :
 * @group-content :
 * @description   : EX_ReturnConfirm_ba Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-25       I2max               Create
 ****************************************************************************************/

@IsTest
private class EX_ReturnConfirm_ba_ts {
    @TestSetup
    static void setup(){
        EX_TestDataUtil.getReturnOrderLineItem(false);
        EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_YN__c = TRUE;
        EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '120';
        EX_TestDataUtil.baseReturnOrderLineItem.COLLECTION_YN__c = TRUE;
        EX_TestDataUtil.baseReturnOrderLineItem.REFUND_Complete_YN__c = FALSE;
        EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Business_Type_Code__c = 'Return';
        EX_TestDataUtil.baseReturnOrderLineItem.Return_Order_CONFIRM_DTM__c = NULL;
        EX_TestDataUtil.baseReturnOrderLineItem.isMig__c = FALSE;
        EX_TestDataUtil.baseReturnOrderLineItem.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
        EX_TestDataUtil.getReturnOrderLineItem(true);
        EX_TestDataUtil.baseReturnOrder.Consumables_Order_YN__c = TRUE;
        update EX_TestDataUtil.baseReturnOrder;

        EX_TestDataUtil.baseProductRequest.SR_SALE__c = EX_TestDataUtil.getSrSale(true).Id;
        EX_TestDataUtil.baseProductRequest.Consumables_Order_YN__c = TRUE;
        EX_TestDataUtil.baseProductRequest.Consumables_Order_USE_YN__c = TRUE;
        EX_TestDataUtil.baseProductRequest.SALE_Number__c = EX_TestDataUtil.baseProductRequest.Order_Number__c;
        update EX_TestDataUtil.baseProductRequest;

        SR_PAYMENT_BASIS__c basis = new SR_PAYMENT_BASIS__c(SR_SALE_ID__c = EX_TestDataUtil.srSale.Id, BASIS_NO__c = EX_TestDataUtil.baseProductRequest.Order_Number__c, RED_BLACK__c = 'B', BASIS_DT__c = Date.newInstance(2023, 1, 25), SETTLE_AMT__c = 1000, BIZ_ORIGIN_TYPE__c = 'B');
        insert basis;
        insert new SR_AR_CONFIRM__c(SR_PAYMENT_BASIS_ID__c = basis.Id, DEPOSIT_TYPE__c = 'A', INVOICE_ISSUE_TYPE__c = 'B', DEPOSIT_AMT__c = 1000);
        EX_TestDataUtil.getPrePaymentDetail(true);
    }

    @IsTest
    static void test_batch() {
        Test.startTest();
        Database.executeBatch(new EX_ReturnConfirm_ba(), 1);
        Test.stopTest();
    }
}