/****************************************************************************************
 * @filename      : EX_CicOrderAlarm_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-18 오후 1:30
 * @group         :
 * @group-content :
 * @description   : EX_CicOrderAlarm Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-18       I2max               Create
 ****************************************************************************************/

@IsTest
private class EX_CicOrderAlarm_ts {
    @TestSetup
    static void setup() {
        Test.startTest();
        try {
            IF_Master__c ifmaster = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'www.test.com',
                    APIKeyName__c = 'test',
                    APIKeyValue__c = 'test',
                    IfId__c = 'CicOrderAlarm',
                    isLogInsert__c = true
            );

            insert ifmaster;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    @IsTest
    static void test_doPost() {
        EX_TestDataUtil.getReturnOrderLineItem(true);
        EX_CicOrderAlarm.InputBody param = new EX_CicOrderAlarm.InputBody();
        param.sfid = EX_TestDataUtil.baseProductRequest.Id;
        param.updateDate = String.valueOf(Date.today());

        EX_CicOrderAlarm.Input requestInput = new EX_CicOrderAlarm.Input();
        requestInput.ReqType = 'PaymentDelayAlarmDate';
        requestInput.params = new List<EX_CicOrderAlarm.InputBody>{
                param
        };

        Test.startTest();
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/heroku/CicOrderAlarm'; //Request URL
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(requestInput));
        RestContext.request = req;
        RestContext.response = res;
        EX_CicOrderAlarm.doPost();

        requestInput.ReqType = 'SoldOutAlarmDate';
        req.requestBody = Blob.valueOf(JSON.serialize(requestInput));
        RestContext.request = req;
        EX_CicOrderAlarm.doPost();

        requestInput.ReqType = 'DisabledAlarmDate';
        req.requestBody = Blob.valueOf(JSON.serialize(requestInput));
        RestContext.request = req;
        EX_CicOrderAlarm.doPost();

        param.sfid = EX_TestDataUtil.baseProductRequestLineItem.Id;
        requestInput.params = new List<EX_CicOrderAlarm.InputBody>{
                param
        };
        requestInput.ReqType = 'SoldOutReceivingAlarmDate';
        req.requestBody = Blob.valueOf(JSON.serialize(requestInput));
        RestContext.request = req;
        EX_CicOrderAlarm.doPost();

        param.sfid = EX_TestDataUtil.baseReturnOrderLineItem.Id;
        requestInput.params = new List<EX_CicOrderAlarm.InputBody>{
                param
        };
        requestInput.ReqType = 'ReturnConfirmAlarmDate';
        req.requestBody = Blob.valueOf(JSON.serialize(requestInput));
        RestContext.request = req;
        EX_CicOrderAlarm.doPost();

        Test.stopTest();
    }
}