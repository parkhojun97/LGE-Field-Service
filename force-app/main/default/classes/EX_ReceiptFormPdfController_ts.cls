/**
 * @description       : 
 * @author            : hojun.park@dkbmc.com
 * @group             : 
 * @last modified on  : 09-14-2023
 * @last modified by  : hyungho.chun@dkbmc.com
**/
@IsTest
private class EX_ReceiptFormPdfController_ts {
    
    @TestSetup
    static void setup() {
        SR_SALE__c sr = EX_TestDataUtil.getSrSale(true);
        ProductRequest productRequest = EX_TestDataUtil.getProductRequest(true);
        ProductRequestLineItem productRequestLineItem = EX_TestDataUtil.getProductRequestLineItem(true);
        SM_DEPT__c deptOne = EX_TestDataUtil.getDept(true,'PH8002');

        EX_TestDataUtil.baseProductRequest.PAYMENT_COMPLETED_DTM__c = System.now();
        EX_TestDataUtil.baseProductRequestLineItem.sr_sale__c = EX_TestDataUtil.getSrSale(true).Id;
        update EX_TestDataUtil.baseProductRequest;
        update EX_TestDataUtil.baseProductRequestLineItem;
                
    }

    @IsTest
    static void EX_ReceiptFormPdfController_ts_01() {

        Test.startTest();
        PageReference pageRef = Page.EX_receiptForm;
        Test.setCurrentPage(pageRef);
        List<productRequest> prList = [SELECT id FROM productRequest Limit 1];
        ApexPages.currentPage().getParameters().put('productRequestId', prList[0].Id);
        EX_ReceiptFormPdfController.doPdfGenerate();
        ApexPages.currentPage().getParameters().put('OrderChannel', '소모품택배');
        EX_ReceiptFormPdfController.doPdfGenerate();

        Test.stopTest();
    }
}