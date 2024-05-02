/**
 * Created by I2MAX.SEOKHOLEE on 2022-05-30.
 */

@IsTest
private class EX_RsrvModule_qa_ts {
    @TestSetup
    static void setData() {
        EX_TestDataUtil.getProductRequestLineItem(true);

    }

    @IsTest
    static void testBehavior() {
        String failProductRequestLineItemId =[
                SELECT Id
                FROM ProductRequestLineItem
                LIMIT 1
        ].Id;
        List<Map<String, Object>> mapList = new List<Map<String, Object>>();
        Map<String, Object> mapInfo = new Map<String, Object>();
        mapList.add(mapInfo);

        System.debug('failProductRequestLineItemId -> ' + failProductRequestLineItemId);
        EX_RsrvModule_qa rmQa = new EX_RsrvModule_qa(mapList);
        rmQa.failPrliIdSet = new Set<String>();
        rmQa.failPrliIdSet.add(failProductRequestLineItemId);

        System.enqueueJob(rmQa);
    }
}