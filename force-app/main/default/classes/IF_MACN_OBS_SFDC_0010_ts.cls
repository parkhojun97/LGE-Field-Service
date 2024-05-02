/**
 * Created by MS on 2023-04-21.
 */

@IsTest
private class IF_MACN_OBS_SFDC_0010_ts {

    @TestSetup
    static void setup(){
        Test.startTest();
        try {
            IF_Master__c ifmaster = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'www.test.com',
                    APIKeyName__c = 'test',
                    APIKeyValue__c = 'test',
                    IfId__c = 'IF-NEW-500',
                    isLogInsert__c = true
            );

            insert ifmaster;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }


        EX_TestDataUtil.getLocation(false, 'Location', 'PH8002');
        EX_TestDataUtil.baseLocation.LocationType = 'Warehouse';
        EX_TestDataUtil.baseLocation.Name = System.Label.EX_Location;
        insert EX_TestDataUtil.baseLocation;
        EX_TestDataUtil.getProductItem(true);

        EX_TestDataUtil.baseLocation = null;
        EX_TestDataUtil.baseProductItem = null;
        EX_TestDataUtil.getLocation(true, 'DIV', 'PH8002');
        EX_TestDataUtil.getProductItem(true);

        EX_TestDataUtil.baseLocation = null;
        EX_TestDataUtil.baseProductItem = null;
        EX_TestDataUtil.getLocation(true, 'Center', 'PH8002');
        EX_TestDataUtil.getProductItem(true);

        SM_DIV__c divObj = EX_TestDataUtil.getDIV(false);
        TriggerHandler.bypass('SM_DIV_trHandler');
        insert divObj;
        TriggerHandler.clearBypass('SM_DIV_trHandler');

        Test.stopTest();
    }
    @IsTest
    static void test01() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0010'; //Request URL
        req.httpMethod = 'POST';

        List<Product2> pd = [SELECT Id, DIV_CODE__c, ProductCode FROM Product2 LIMIT 1];
        if(!pd.isEmpty()){
            String requestStr = '{' ;
            requestStr       += '"orderItem" : [{ "orderNo" : "1234567" , "divCode" : "' + pd[0].DIV_CODE__c + '" , "partNo" : "' +pd[0].ProductCode+ '", "orderSeq" : "1", "orderQty" : "1", "orderPrice" : "60000", "depositType" : "A", "invoiceissueType" : "B", "apprAmt" : "60000", "pointAmt" : "0", "priceCost" : "0" }]';
            requestStr       += ' , "orderInfo" : [{ "orderNo" : "1234567", "orderCustName" : "홍길동","orderTelNo1" : "01012345678","orderTelNo2" : "021231234","orderAddress" : "서울시 금천구 디지털로 10길 56","orderDtlAddress" : "엘지전자 가산A","orderPostalCode" : "123456","description" : "additionalMapList","receiverName" : "홍길동","receiverTelNo1" : "01012345678","receiverTelNo2" : "021231234","receiverAddress" : "서울시 금천구 디지털로 10길 56","receiverDtlAddress" : "additionalMapList","receiverPostalCode" : "123456","orderAmt" : "100000","deliveryAmt" : "0","totApprAmt" : "100000" ,"totPointAmt" : "0"}] ';
            requestStr       += '}';

            req.requestBody = Blob.valueOf(requestStr);

            RestContext.request = req;
            RestContext.response= res;

            try {
                IF_MACN_OBS_SFDC_0010.doPost();

            } catch (Exception e) {
                System.debug(e.getMessage());
            }


        }

        Test.stopTest();
    }

    @IsTest
    static void test02() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0010'; //Request URL
        req.httpMethod = 'POST';

        List<Product2> pd = [SELECT Id, DIV_CODE__c, ProductCode FROM Product2 LIMIT 1];        
        if(!pd.isEmpty()){
            String requestStr = '{' ;
            requestStr       += '"orderItem" : [{ "orderNo" : "1234567" , "divCode" : "' + pd[0].DIV_CODE__c + '" , "partNo" : "' +pd[0].ProductCode+ '", "orderSeq" : "1", "orderQty" : "1", "orderPrice" : "60000", "depositType" : "B", "invoiceissueType" : "B", "apprAmt" : "60000", "pointAmt" : "0", "priceCost" : "0" }]';
            requestStr       += ' , "orderInfo" : [{ "orderNo" : "1234567", "orderCustName" : "홍길동","orderTelNo1" : "01012345678","orderTelNo2" : "021231234","orderAddress" : "서울시 금천구 디지털로 10길 56","orderDtlAddress" : "엘지전자 가산A","orderPostalCode" : "123456","description" : "additionalMapList","receiverName" : "홍길동","receiverTelNo1" : "01012345678","receiverTelNo2" : "021231234","receiverAddress" : "서울시 금천구 디지털로 10길 56","receiverDtlAddress" : "additionalMapList","receiverPostalCode" : "123456","orderAmt" : "100000","deliveryAmt" : "0","totApprAmt" : "100000" ,"totPointAmt" : "0"}] ';
            requestStr       += '}';

            req.requestBody = Blob.valueOf(requestStr);

            RestContext.request = req;
            RestContext.response= res;

            try {
                IF_MACN_OBS_SFDC_0010.doPost();

                EX_TestDataUtil.getHolidays(true, '1');
                EX_TestDataUtil.getHolidays(true, '0');
                EX_SuppliesController.getDeliveryDate();

            } catch (Exception e) {
                System.debug(e.getMessage());
            }

        }

        Test.stopTest();
    }

    @IsTest
    static void test03() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0010'; //Request URL
        req.httpMethod = 'POST';

        List<Product2> pd = [SELECT Id, DIV_CODE__c, ProductCode FROM Product2 LIMIT 1];
        if(!pd.isEmpty()){
            String requestStr = '{' ;
            requestStr       += '"orderItem" : [{ "orderNo" : "1234567" , "divCode" : "' + pd[0].DIV_CODE__c + '" , "partNo" : "' +pd[0].ProductCode+ '", "orderSeq" : "1", "orderQty" : "20", "orderPrice" : "60000", "depositType" : "D", "invoiceissueType" : "B", "apprAmt" : "60000", "pointAmt" : "0", "priceCost" : "0" }]';
            requestStr       += ' , "orderInfo" : [{ "orderNo" : "1234567", "orderCustName" : "홍길동","orderTelNo1" : "01012345678","orderTelNo2" : "021231234","orderAddress" : "서울시 금천구 디지털로 10길 56","orderDtlAddress" : "엘지전자 가산A","orderPostalCode" : "123456","description" : "additionalMapList","receiverName" : "홍길동","receiverTelNo1" : "01012345678","receiverTelNo2" : "021231234","receiverAddress" : "서울시 금천구 디지털로 10길 56","receiverDtlAddress" : "additionalMapList","receiverPostalCode" : "123456","orderAmt" : "100000","deliveryAmt" : "0","totApprAmt" : "100000" ,"totPointAmt" : "0"}] ';
            requestStr       += '}';

            req.requestBody = Blob.valueOf(requestStr);

            RestContext.request = req;
            RestContext.response= res;

            try {
                IF_MACN_OBS_SFDC_0010.doPost();

            } catch (Exception e) {
                System.debug(e.getMessage());
            }

        }

        Test.stopTest();
    }

    @IsTest
    static void test04() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0010'; //Request URL
        req.httpMethod = 'POST';

        List<Product2> pd = [SELECT Id, DIV_CODE__c, ProductCode FROM Product2 LIMIT 1];
        if(!pd.isEmpty()){
            String requestStr = '{' ;
            requestStr       += '"orderItem" : [{ "orderNo" : "1234567" , "divCode" : "' + pd[0].DIV_CODE__c + '" , "partNo" : "' +pd[0].ProductCode+ '", "orderSeq" : "1", "orderQty" : "2", "orderPrice" : "60000", "depositType" : "NA", "invoiceissueType" : "B", "apprAmt" : "60000", "pointAmt" : "0", "priceCost" : "0" }]';
            requestStr       += ' , "orderInfo" : [{ "orderNo" : "1234567", "orderCustName" : "홍길동","orderTelNo1" : "01012345678","orderTelNo2" : "021231234","orderAddress" : "서울시 금천구 디지털로 10길 56","orderDtlAddress" : "엘지전자 가산A","orderPostalCode" : "123456","description" : "additionalMapList","receiverName" : "홍길동","receiverTelNo1" : "01012345678","receiverTelNo2" : "021231234","receiverAddress" : "서울시 금천구 디지털로 10길 56","receiverDtlAddress" : "additionalMapList","receiverPostalCode" : "123456","orderAmt" : "100000","deliveryAmt" : "0","totApprAmt" : "100000" ,"totPointAmt" : "0"}] ';
            requestStr       += '}';

            req.requestBody = Blob.valueOf(requestStr);

            RestContext.request = req;
            RestContext.response= res;

            try {
                IF_MACN_OBS_SFDC_0010.doPost();

            } catch (Exception e) {
                System.debug(e.getMessage());
            }

        }

    }

    @IsTest
    static void test05() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0010'; //Request URL
        req.httpMethod = 'POST';

        List<Product2> pd = [SELECT Id, DIV_CODE__c, ProductCode FROM Product2 LIMIT 1];
        if(!pd.isEmpty()){
            String requestStr = '{' ;
            requestStr       += '"orderItem" : [{ "orderNo" : "1234567" , "divCode" : "' + pd[0].DIV_CODE__c + '" , "partNo" : "' +pd[0].ProductCode+ '", "orderSeq" : "1", "orderQty" : "10", "orderPrice" : "60000", "depositType" : "NB", "invoiceissueType" : "B", "apprAmt" : "60000", "pointAmt" : "0", "priceCost" : "0" }]';
            requestStr       += ' , "orderInfo" : [{ "orderNo" : "1234567", "orderCustName" : "홍길동","orderTelNo1" : "01012345678","orderTelNo2" : "021231234","orderAddress" : "서울시 금천구 디지털로 10길 56","orderDtlAddress" : "엘지전자 가산A","orderPostalCode" : "123456","description" : "additionalMapList","receiverName" : "홍길동","receiverTelNo1" : "01012345678","receiverTelNo2" : "021231234","receiverAddress" : "서울시 금천구 디지털로 10길 56","receiverDtlAddress" : "additionalMapList","receiverPostalCode" : "123456","orderAmt" : "100000","deliveryAmt" : "0","totApprAmt" : "100000" ,"totPointAmt" : "0"}] ';
            requestStr       += '}';

            req.requestBody = Blob.valueOf(requestStr);

            RestContext.request = req;
            RestContext.response= res;

            try {
                IF_MACN_OBS_SFDC_0010.doPost();

            } catch (Exception e) {
                System.debug(e.getMessage());
            }


        }

        Test.stopTest();
    }

    @IsTest
    static void test06() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0010'; //Request URL
        req.httpMethod = 'POST';

        List<Product2> pd = [SELECT Id, DIV_CODE__c, ProductCode FROM Product2 LIMIT 1];
        if(!pd.isEmpty()){
            String requestStr = '{' ;
            requestStr       += '"orderItem" : [{ "orderNo" : "1234567" , "divCode" : "' + pd[0].DIV_CODE__c + '" , "partNo" : "' +pd[0].ProductCode+ '", "orderSeq" : "1", "orderQty" : "10", "orderPrice" : "60000", "depositType" : "NB", "invoiceissueType" : "B", "apprAmt" : "60000", "pointAmt" : "0", "priceCost" : "0" }]';
            requestStr       += ' , "orderInfo" : [{ "orderNo" : "1234567", "orderCustName" : "홍길동","orderTelNo1" : "01012345678","orderTelNo2" : "021231234","orderAddress" : "서울시 금천구 디지털로 10길 56","orderDtlAddress" : "엘지전자 가산A","orderPostalCode" : "123456","description" : "additionalMapList","receiverName" : "홍길동","receiverTelNo1" : "01012345678","receiverTelNo2" : "021231234","receiverAddress" : "서울시 금천구 디지털로 10길 56","receiverDtlAddress" : "additionalMapList","receiverPostalCode" : "123456","orderAmt" : "100000","deliveryAmt" : "0","totApprAmt" : "100000" ,"totPointAmt" : "0"}] ';
            requestStr       += '}';

            // req.requestBody = Blob.valueOf(requestStr);

            
            // RestContext.request = req;
            // RestContext.response= res;
            
            try {
                IF_MACN_OBS_SFDC_0010.Input objInput = (IF_MACN_OBS_SFDC_0010.Input) JSON.deserialize(requestStr, IF_MACN_OBS_SFDC_0010.Input.class);
                List<Map<String, Object>> additionalMapList = new List<Map<String, Object>>();
                Map<String, Object> tempObj = new Map<String, Object>{
                    'orderNo' => '1234567',
                    'cashTy' => '1',
                    'orderTime' => String.valueOf(System.today())
                };
                additionalMapList.add(tempObj);
                IF_MACN_OBS_SFDC_0010.createConsumableOrderFromOBS(objInput, 'S', additionalMapList);

            } catch (Exception e) {
                System.debug(e.getMessage());
            }


        }

        Test.stopTest();
    }

    @IsTest
    static void test07() {
        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/obs/IF_MACN_OBS_SFDC_0010'; //Request URL
        req.httpMethod = 'POST';

        List<Product2> pd = [SELECT Id, DIV_CODE__c, ProductCode FROM Product2 LIMIT 1];
        if(!pd.isEmpty()){
            String requestStr = '{' ;
            requestStr       += '"orderItem" : [{ "orderNo" : "1234567" , "divCode" : "' + pd[0].DIV_CODE__c + '" , "partNo" : "' +pd[0].ProductCode+ '", "orderSeq" : "1", "orderQty" : "1", "orderPrice" : "60000", "depositType" : "B", "invoiceissueType" : "B", "apprAmt" : "60000", "pointAmt" : "0", "priceCost" : "0" }]';
            requestStr       += ' , "orderInfo" : [{ "orderNo" : "1234567", "orderCustName" : "홍길동","orderTelNo1" : "01012345678","orderTelNo2" : "1111","orderAddress" : "서울시 금천구 디지털로 10길 56","orderDtlAddress" : "엘지전자 가산A","orderPostalCode" : "123456","description" : "additionalMapList","receiverName" : "홍길동","receiverTelNo1" : "01012345678","receiverTelNo2" : "021231234","receiverAddress" : "서울시 금천구 디지털로 10길 56","receiverDtlAddress" : "additionalMapList","receiverPostalCode" : "123456","orderAmt" : "100000","deliveryAmt" : "0","totApprAmt" : "100000" ,"totPointAmt" : "0"}] ';
            requestStr       += '}';

            req.requestBody = Blob.valueOf(requestStr);

            RestContext.request = req;
            RestContext.response= res;

            try {
                IF_MACN_OBS_SFDC_0010.doPost();

                EX_TestDataUtil.getHolidays(true, '1');
                EX_TestDataUtil.getHolidays(true, '0');
                EX_SuppliesController.getDeliveryDate();

            } catch (Exception e) {
                System.debug(e.getMessage());
            }

        }

        Test.stopTest();
    }
}