/****************************************************************************************
 * @filename      : EX_ReturnOrderConfirm_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-09 오후 2:46
 * @group         :
 * @group-content :
 * @description   : EX_ReturnOrderConfirm Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-09       I2max               Create
 ****************************************************************************************/

@IsTest
private class EX_ReturnOrderConfirm_ts {
    @TestSetup
    static void setup() {
        SR_SALE__c sr = EX_TestDataUtil.getSrSale(true);
        ProductRequest productRequest = EX_TestDataUtil.getProductRequest(false);
        productRequest.SR_SALE__c = sr.Id;
        insert ProductRequest;

        ProductRequestLineItem productRequestLineItem = EX_TestDataUtil.getProductRequestLineItem(false);
        productRequestLineItem.ParentID = productRequest.Id;
        insert productRequestLineItem;

        ReturnOrderLineItem returnOrderLineItem = EX_TestDataUtil.getReturnOrderLineItem(false);
        returnOrderLineItem.RecordTypeID = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
        returnOrderLineItem.ProductRequestLineItemId = productRequestLineItem.Id;
        returnOrderLineItem.Consumables_Order_YN__c = true;
        returnOrderLineItem.Consumables_Business_Type_Code__c = 'Return';
        returnOrderLineItem.Order_CHNL_TYPE_Code__c = 'BestShop';
        insert returnOrderLineItem;
    }

    @IsTest
    static void test_doPost() {
        Test.startTest();
        EX_ReturnOrderConfirm.doPost();
        Test.stopTest();
    }


    @IsTest
    static void test_doReturnOrderConfirm() {
        ReturnOrderLineItem targetRoID = [SELECT Id FROM ReturnOrderLineItem Limit 1];
        Test.startTest();
        EX_ReturnOrderConfirm.doReturnOrderConfirm(new Set<String>{targetRoID.Id});
        EX_ReturnOrderConfirm.doReturnOrderConfirm(new Set<String>{'ERROR_ID'});
        EX_ReturnOrderConfirm.doReturnOrderConfirm();
        Test.stopTest();
    }

    @IsTest
    static void test_doConfirm() {
        Test.startTest();
        EX_ReturnOrderConfirm.doConfirm(new Set<String>{});
        Test.stopTest();
    }
}