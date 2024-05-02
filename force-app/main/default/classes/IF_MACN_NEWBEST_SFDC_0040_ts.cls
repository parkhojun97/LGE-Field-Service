/**
 * Created by MS on 2023-04-27.
 */

@IsTest
private class IF_MACN_NEWBEST_SFDC_0040_ts {
    @IsTest
    static void testBehavior() {
        Test.startTest();

        List<IF_Master__c> ifMasterList = new List<IF_Master__c>();
        IF_Master__c objIfMaster = new IF_Master__c();
        objIfMaster.Name = 'IF-NEW-547';
        objIfMaster.Endpoint__c = 'https://test.test.com/test';
        objIfMaster.Method__c = 'POST';
        objIfMaster.ContentType__c = 'application/json';
        objIfMaster.ParaSuccess__c = 'result';
        objIfMaster.ParaSuccessValue__c = 'success';
        objIfMaster.ParaErrorMessage__c = 'message';
        objIfMaster.ParaAddHeader__c = '{"x-apikey":"MTdFNjS183Gs5DrSabAkSMn12jBswn1n"}';
        objIfMaster.isLogInsert__c = true;
        objIfMaster.IfId__c = 'IF-NEW-547';
        ifMasterList.add(objIfMaster);

        insert ifMasterList;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0040'; //Request URL
        req.httpMethod = 'POST';

        EX_TestDataUtil.getDept(false, 'PH0300');
        EX_TestDataUtil.dept.Name = '99A999';
        EX_TestDataUtil.getLocation(true,'Location', 'PH0300');
        EX_TestDataUtil.getProductItem(true);

        String requestStr = '{ ' ;
        requestStr       += ' "Body" : {"data" :  { "deptCode" : "' + EX_TestDataUtil.dept.DEPT_CODE__c + '" , "partNo" : "' + EX_TestDataUtil.baseProduct.Name + '" }  } ';
        requestStr       += '';
        requestStr       += ' }';

        req.requestBody = Blob.valueOf(requestStr);

        RestContext.request = req;
        RestContext.response= res;

        IF_MACN_NEWBEST_SFDC_0040.doPost();

        IF_MACN_NEWBEST_SFDC_0040.Input input = new IF_MACN_NEWBEST_SFDC_0040.Input();

        Test.stopTest();

    }
}