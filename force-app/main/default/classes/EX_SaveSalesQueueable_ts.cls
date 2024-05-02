/**
 * Created by MS on 2023-04-21.
 */

@IsTest
private class EX_SaveSalesQueueable_ts {
    @IsTest
    static void testBehavior() {
        Test.startTest();
        EX_SaveSalesQueueable q = new EX_SaveSalesQueueable(new List<String>{EX_TestDataUtil.getProductRequestLineItem(true).Order_Number__c});
        System.enqueueJob(q);
        Test.stopTest();

    }
}