/**
 * Created by MS on 2023-05-08.
 */

@IsTest
private class IF_MACN_SFDC_THINQAPP_0030_ts {
    @TestSetup
    static void setup() {
        Test.startTest();
        try {
            IF_Master__c ifmaster = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'www.test.com',
                    APIKeyName__c = 'test',
                    APIKeyValue__c = 'test',
                    IfId__c = 'IF-NEW-744',
                    isLogInsert__c = true
            );

            insert ifmaster;
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }

    @IsTest
    static void testBehavior() {
        Test.startTest();

        SM_PRODUCT_LINE__c pl = new SM_PRODUCT_LINE__c();
        pl.Name = 'ZZ';
        pl.PROD_LINE_LEVEL__c = '1';
        pl.LIFE_PERIOD__c = 1;
        pl.PROD_LINE_NAME__c = pl.Name;
        pl.PROD_LINE_NAME_ENG__c = pl.Name;
        pl.INWTY_PERIOD__c = 10;
        pl.USE_YN__c = 'Y';
        insert pl;

        Product2 baseProduct = new Product2();
        baseProduct.DISABLED_DT__c = Date.today();
        baseProduct.ACCESSORY_YN__c = 'Y';
        baseProduct.PROD_LINE_CODE__c = pl.Id;
        baseProduct.ASC_PRICE__c = 3000;
        baseProduct.AUTO_EX_YN__c = 'N';
        baseProduct.AVG_PRICE__c = 2000;
        baseProduct.MODEL_CODE__c = 'PFH9M1A.AKOR';
        baseProduct.MEASURE_UNIT__c = 'EA';
        baseProduct.NAME = 'ADQ75153413';
        baseProduct.CAREPLUS_MODEL_CODE__c = 'PFH9M1A.AKOR';
        baseProduct.CAREPLUS_AGENT_PRICE__c = 1000;
        // baseProduct.CAREPLUS_PRODUCT_DETAIL__c = '8';
//            baseProduct.CAREPLUS_PRODUCT_TYPE__c = 'A';
        baseProduct.CAREPLUS_YN__c = 'Y';
        baseProduct.CLASS_CODE__c = 'ADQ0000';
        baseProduct.CORE_PART_TYPE__c = '1';
        baseProduct.COUNS_PART_YN__c = 'N';
        baseProduct.CUST_PRICE__c = 5000;
        baseProduct.DC_YN__c = 'N';
        baseProduct.INWTY_SUPPLY_YN__c = 'N';
        baseProduct.DISABLED_REL_DT__c = baseProduct.DISABLED_DT__c;
        baseProduct.FIRST_RCV_DT__c = baseProduct.DISABLED_DT__c;
        baseProduct.INPUT_DATE__c = baseProduct.DISABLED_DT__c;
        baseProduct.DIV_INDEX_EX_YN__c = 'N';
        baseProduct.DIV_CODE__c = 'DMZ';
        baseProduct.DISABLED_REL_DT__c = baseProduct.DISABLED_DT__c;
        baseProduct.IsActive = true;
        baseProduct.isByPass__c = false;
        baseProduct.IsMIG__c = false;
        baseProduct.LAST_RCV_DT__c = baseProduct.DISABLED_DT__c;
        baseProduct.LAST_RCV_PRICE__c = 4000;
        baseProduct.ProductCode = baseProduct.NAME;
        baseProduct.SALE_MODEL_CODE__c = 'EXS9342523';
        baseProduct.PART_DESC__c = 'TEST_PART_DESC';
        baseProduct.PART_SPEC__c = 'TEST_PART_SPEC';
        baseProduct.THINQ_ITEM_YN__c = 'Y';
        baseProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('SM_MODEL').getRecordTypeId();
        insert baseProduct;

        SI_THINQ_PRODUCT_LINE__c thinqPL = new SI_THINQ_PRODUCT_LINE__c();
        thinqPL.SALE_MODEL_CODE__c = baseProduct.SALE_MODEL_CODE__c;
        thinqPL.PROD_LINE_CODE__c = pl.PROD_LINE_NAME__c; //double check
        thinqPL.PROD_LINE_NAME_ENG__c = pl.PROD_LINE_NAME__c;//double check
        //thinqPL.LIFE_PERIOD__c = pd.PROD_LINE_CODE__r.LIFE_PERIOD__c;
        thinqPL.LIFE_PERIOD__c = baseProduct.fm_INWTY_PERIOD__c;//double check
        thinqPL.TRANSFER_FLAG__c = 'Y';
        insert thinqPL;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/v1/api/ma/thinqstore/IF_MACN_SFDC_THINQAPP_0030'; //Request URL
        req.httpMethod = 'POST';

        String requestStr = '{' ;
        requestStr       += '"Body" : { "rcptInfo" : {"lastkey": 1234, "limitedcount" : "1" } } ';
        requestStr       += '}';

        req.requestBody = Blob.valueOf(requestStr);

        RestContext.request = req;
        RestContext.response= res;

        try {
        IF_MACN_SFDC_THINQAPP_0030.getProduct2List(System.now());
        IF_MACN_SFDC_THINQAPP_0030.saveSITHINQProductLine();
        IF_MACN_SFDC_THINQAPP_0030.updateTransferFlag(new List<SI_THINQ_PRODUCT_LINE__c>{thinqPL});

        IF_MACN_SFDC_THINQAPP_0030.InputBody inputBody = new IF_MACN_SFDC_THINQAPP_0030.InputBody();
        inputBody.rcptInfo.lastkey = 1234;
        inputBody.rcptInfo.limitedcount = 3;
        IF_MACN_SFDC_THINQAPP_0030.getSiThinqProductLines(inputBody);
        IF_MACN_SFDC_THINQAPP_0030.doPost();

        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
}