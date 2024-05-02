/**
 * Created by MS on 2023-04-20.
 */

@IsTest
private class EX_SaveSales_ts {
    @IsTest
    static void testBehavior() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/heroku/SalesOrderConfirm'; //Request URL
        req.httpMethod = 'POST';

        EX_TestDataUtil.getProductRequestLineItem(false);
        EX_TestDataUtil.baseProductRequestLineItem.SourceLocationId = EX_TestDataUtil.baseLocation.Id;
        insert EX_TestDataUtil.baseProductRequestLineItem;
        String reqStr = '{ "target" : [ "' + EX_TestDataUtil.baseProductRequestLineItem.Id + '"] }';
        req.requestBody = Blob.valueOf(reqStr);

        RestContext.request = req;
        RestContext.response= res;

        EX_SaveSales.doPost();

        Test.stopTest();
    }
}