/**
 * Created by MS on 2023-04-19.
 */

@IsTest
private class EX_SuppliesPDFController_ts {
    @IsTest
    static void testBehavior() {
        SR_ONLINE_SALE_ESTIMATE__c estimate = new SR_ONLINE_SALE_ESTIMATE__c();
        estimate.Order_Number__c = EX_TestDataUtil.getProductRequestLineItem(true).ParentId;
        estimate.OrderNumber__c = EX_TestDataUtil.getProductRequestLineItem(true).Order_Number__c;
        insert estimate;

        Test.startTest();
        ApexPages.currentPage().getParameters().put('Id', 'quote');
        ApexPages.currentPage().getParameters().put('quoteHistoryId', estimate.Id);
        ApexPages.currentPage().getParameters().put('orderNumber', EX_TestDataUtil.getProductRequestLineItem(true).ParentId);

        EX_SuppliesPDFController controller = new EX_SuppliesPDFController();
        controller.getResult();

        ApexPages.currentPage().getParameters().put('Id', 'regi');
        controller.getResult();

        ApexPages.currentPage().getParameters().put('Id', 'bank');
        controller.getResult();

        ApexPages.currentPage().getParameters().put('Id', 'invoice');
        controller.getResult();

        ApexPages.currentPage().getParameters().put('Id', 'Other');
        controller.getResult();
        Test.stopTest();
    }
}