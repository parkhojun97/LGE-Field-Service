/****************************************************************************************
 * @filename      : EX_obsUpdateIfSendDate_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-22 오후 03:48
 * @group         :
 * @group-content :
 * @description   : EX_obsUpdateIfSendDate Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-22       I2max               Create
 ****************************************************************************************/

@IsTest
private class EX_obsUpdateIfSendDate_ts {
    @TestSetup
    static void setup() {
        Test.startTest();
        try {
            IF_Master__c ifmaster = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'www.test.com',
                    APIKeyName__c = 'test',
                    APIKeyValue__c = 'test',
                    IfId__c = 'obsUpdateIfSendDate',
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
        EX_TestDataUtil.baseProductRequestLineItem.Consumables_Order_Status__c = '030'; // shipment
        update EX_TestDataUtil.baseProductRequestLineItem;

        EX_obsUpdateIfSendDate.InputBody inputBody = new EX_obsUpdateIfSendDate.InputBody();
        EX_obsUpdateIfSendDate.InputData inputData = new EX_obsUpdateIfSendDate.InputData();
        inputData.orderNo = EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c;
        inputData.orderSeq = String.valueOf(EX_TestDataUtil.baseProductRequestLineItem.Order_SEQ__c);
        inputData.status = 'shipment';
        inputBody.data = new List<EX_obsUpdateIfSendDate.InputData>{
                inputData
        };
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/heroku/obsUpdateIfSendDate';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serialize(inputBody));
        RestContext.request = req;
        RestContext.response = res;

        Test.startTest();
        // shipment
        EX_obsUpdateIfSendDate.doPost();

        // delivery
        EX_TestDataUtil.baseProductRequestLineItem.Consumables_Order_Status__c = '070';
        update EX_TestDataUtil.baseProductRequestLineItem;
        inputData.status = 'delivery';
        inputBody.data = new List<EX_obsUpdateIfSendDate.InputData>{
                inputData
        };
        req.requestBody = Blob.valueOf(JSON.serialize(inputBody));
        RestContext.request = req;
        EX_obsUpdateIfSendDate.doPost();

        // return
        EX_TestDataUtil.baseProductRequestLineItem.Consumables_Order_Status__c = '120';
        update EX_TestDataUtil.baseProductRequestLineItem;
        EX_TestDataUtil.baseReturnOrderLineItem.Order_CHNL_TYPE_Code__c = 'B';
        EX_TestDataUtil.baseReturnOrderLineItem.RETURN_IF_SEND_DATE__c = null;
        EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '120';
        EX_TestDataUtil.baseReturnOrderLineItem.Order_SEQ__c = 1;
        update EX_TestDataUtil.baseReturnOrderLineItem;

        inputData.status = 'return';
        inputBody.data = new List<EX_obsUpdateIfSendDate.InputData>{
                inputData
        };
        req.requestBody = Blob.valueOf(JSON.serialize(inputBody));
        RestContext.request = req;
        EX_obsUpdateIfSendDate.doPost();

        // Data Not Found
        inputData.status = 'delivery';
        inputData.orderNo = 'NOT_FOUND';
        inputBody.data = new List<EX_obsUpdateIfSendDate.InputData>{
                inputData
        };
        req.requestBody = Blob.valueOf(JSON.serialize(inputBody));
        RestContext.request = req;
        EX_obsUpdateIfSendDate.doPost();

        // Null
        inputBody.data = new List<EX_obsUpdateIfSendDate.InputData>{
        };
        req.requestBody = Blob.valueOf(JSON.serialize(inputBody));
        RestContext.request = req;
        EX_obsUpdateIfSendDate.doPost();
        Test.stopTest();
    }
}