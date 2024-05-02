/**
 * Created by MS on 2023-04-21.
 */

@IsTest
private class IF_MACN_OBS_SFDC_0020_ts {
    @IsTest
    static void test01() {
        Test.startTest();

        try {

            IF_Master__c ifmaster = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'www.test.com',
                    APIKeyName__c = 'test',
                    APIKeyValue__c = 'test',
                    IfId__c = 'IF-NEW-544',
                    isLogInsert__c = true
            );

            insert ifmaster;

            RestRequest req = new RestRequest();
            RestResponse res = new RestResponse();
            req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0020'; //Request URL
            req.httpMethod = 'POST';

            EX_TestDataUtil.getDept(false, 'PH8002');
            EX_TestDataUtil.dept.Name = System.Label.EX_Location;
            EX_TestDataUtil.getLocation(true, 'DIV', 'PH8002');
            EX_TestDataUtil.getProductItem(true);

            String requestStr = '{"orderItem" : [{ "divCode" : "' + EX_TestDataUtil.baseProductItem.DIV_CODE__c + '" , "partNo" : "' + EX_TestDataUtil.baseProduct.Name + '" }] }';

            req.requestBody = Blob.valueOf(requestStr);

            RestContext.request = req;
            RestContext.response = res;

            IF_MACN_OBS_SFDC_0020.doPost();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
}