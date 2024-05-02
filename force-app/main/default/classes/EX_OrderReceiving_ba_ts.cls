/****************************************************************************************
 * @filename      : EX_OrderReceiving_ba_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-16 오후 1:17
 * @group         :
 * @group-content :
 * @description   : EX_OrderReceiving_ba Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-16       I2max               Create
 ****************************************************************************************/

@IsTest
private class EX_OrderReceiving_ba_ts {



    @IsTest
    static void test_batch02_2() {

        Test.startTest();
        EX_TestDataUtil.getLocation(true, 'Center',  'PH8002');
        EX_TestDataUtil.getFulfillmentReceiving(true);
        ProductRequestLineItem prli = EX_TestDataUtil.baseProductRequestLineItem;
        EX_TestDataUtil.baseProductRequestLineItem = null;
        EX_TestDataUtil.baseProductRequest = null;
        EX_TestDataUtil.getProductRequestLineItem(true);
        EX_TestDataUtil.baseProductTransfer.QuantityReceived = 100;
        EX_TestDataUtil.baseProductTransfer.QuantitySent = 200;
        update EX_TestDataUtil.baseProductTransfer;

        EX_OrderReceiving_ba.ConsumableOrderReceive(new List<String>{prli.Id});
        prli.BASIS_Parts_Number__c = 'PART_NUMBER';
        update prli;
        EX_OrderReceiving_ba.ConsumableOrderReceive(new List<String>{prli.Id});
        Test.stopTest();
    }    

    @IsTest
    static void test_batch02() {
        Test.startTest();
        EX_TestDataUtil.getProductRequestLineItem2(true);
        EX_TestDataUtil.getLocation(true, 'Center',  'PH8002');
        EX_TestDataUtil.getFulfillmentReceiving(true);
        ProductRequestLineItem prli = EX_TestDataUtil.baseProductRequestLineItem;
        // EX_TestDataUtil.baseProductRequestLineItem = null;
        // EX_TestDataUtil.baseProductRequest = null;
        // EX_TestDataUtil.getProductRequestLineItem(true);
        EX_TestDataUtil.baseProductTransfer.QuantityReceived = 100;
        EX_TestDataUtil.baseProductTransfer.QuantitySent = 200;
        update EX_TestDataUtil.baseProductTransfer;

        EX_OrderReceiving_ba.ConsumableOrderReceive(new List<String>{prli.Id});
        prli.BASIS_Parts_Number__c = 'PART_NUMBER';
        update prli;
        EX_OrderReceiving_ba.ConsumableOrderReceive(new List<String>{prli.Id});
        Test.stopTest();
    }

    @IsTest
    static void test_batch02_03() {

        
        Test.startTest();
        EX_TestDataUtil.getProductRequestLineItem(true);
        EX_TestDataUtil.getLocation(true, 'Center',  'PH8002');
        EX_TestDataUtil.getFulfillmentReceiving2(true);
        ProductRequestLineItem prli = EX_TestDataUtil.baseProductRequestLineItem2;
        // EX_TestDataUtil.baseProductRequestLineItem = null;
        // EX_TestDataUtil.baseProductRequest = null;
        // EX_TestDataUtil.getProductRequestLineItem(true);
        EX_TestDataUtil.baseProductTransfer.QuantityReceived = 100;
        EX_TestDataUtil.baseProductTransfer.QuantitySent = 200;
        update EX_TestDataUtil.baseProductTransfer;

        EX_OrderReceiving_ba.ConsumableOrderReceive(new List<String>{prli.Id});
        prli.BASIS_Parts_Number__c = 'PART_NUMBERssss';
        update prli;
        
        System.debug([SELECT ID, BASIS_Parts_Number__c FROM ProductRequestLineItem WHERE ID = :prli.Id ]);
        System.debug([SELECT ID, fm_PART_NO__c FROM ProductTransfer]);
        System.debug([SELECT ID, fm_PartNo__c FROM Product2]);
        EX_OrderReceiving_ba.ConsumableOrderReceive(new List<String>{prli.Id});
        Test.stopTest();
    }


    @IsTest
    static void test_batch03() {
        Test.startTest();
        Set<String> setPhoneNumber = new Set<String>();
        IF_Master__c master = new IF_Master__c();
        IF_CM_SFDC_KAKAO.InputParam inputParam = new IF_CM_SFDC_KAKAO.InputParam();
        
            master.isLogInsert__c = TRUE;        //로그 적재 여부
            master.WebServiceType__c = 'REST';     //WebServiceType
            master.Method__c = 'POST';     //Method
            master.Type__c = 'Outbound';       //Type
            master.IfId__c = 'infobip_kakao';      //IfId
            master.SystemName__c = 'infobip';      //SystemName
            master.ApexClass__c = 'IF_CM_SFDC_KAKAO';      //Apex Class
            master.Endpoint__c = 'https://xrenll.api.infobip.com/omni/1/advanced';     //Endpoint
            master.EndpointDev__c = 'https://xrenll.api.infobip.com/omni/1/advanced';      //Endpoint (Dev)
            master.EndpointProd__c = 'https://xrenll.api.infobip.com/omni/1/advanced';     //Endpoint (Prod)
            master.IsSendParameter__c = FALSE;       //IsSendParameter
            master.APIKeyName__c = 'Authorization';        //APIKeyName
            master.ContentType__c = 'application/json';        //Content Type
            master.APIKeyValue__c = 'App d46fc6972158988ceb6e0fc6760cfb3d-d6104bab-1322-43aa-ac2a-3dba6461b3f3';       //APIKeyValue
            master.ParaAddHeader__c = '{"Host":"api.infobip.com"}';        //Para Add Header
            master.Name = '[공통] 인포빕 카카오 알림톡 발송';      //IF_Master Name
            insert master;        
            
            setPhoneNumber = new Set<String>{'010-0000-1111'};
            inputParam.kakaoMsg = 'kakaoMsg';
            inputParam.kakaoTitle = 'kakaoTitle';
            inputParam.sendAt = Datetime.now();
            inputParam.smsMsg = 'smsMsg';
            inputParam.smsTitle = 'smsTitle';
            inputParam.templateCode = 'templateCode';
            inputParam.listKakaoButton = new List<IF_CM_SFDC_KAKAO.Button>();
            inputParam.setPhoneNumber = setPhoneNumber;
            inputParam.isSaveResponse = true;
        
        // Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        Test.setMock(HttpCalloutMock.class, new TestHttpCalloutMock(200, true));
        TemplateMgmt__c template = new TemplateMgmt__c();
        template.Content_c__c = '소모품 택배주문 건이 창고에 입고 되어 출하 가능합니다.\n' +
                '- 주문번호 : #{Label1__c}\n' +
                '- P/N : #{Label2__c}\n' +
                '소모품택배주문관리 화면에서 상세 내용 확인부탁드리며, 고객님께 주문의향 확인 후 주문을 원하시는 고객님께는 결제 처리 부탁드리겠습니다.';
        template.Title__c = '소모품 입고';
        template.TemplateCode__c = 'SVC_LGE_MACN_S020';
        insert template;

        TemplateParams__c tp = new TemplateParams__c();
        tp.Name = '{Label1__c}';
        tp.FieldApi__c = 'Label1__c';
        tp.TemplateMgmt__c = template.Id;
        insert tp;

        TemplateParams__c tp2 = new TemplateParams__c();
        tp2.Name = '{Label2__c}';
        tp2.FieldApi__c = 'Label2__c';
        tp2.TemplateMgmt__c = template.Id;
        insert tp2;

        List<Map<String,Object>> kakaoMapList = new List<Map<String, Object>>();
        Map<String,Object> kakaoMap = new Map<String, Object>();
        kakaoMap.put('orderNo','orderNoTest1');
        kakaoMap.put('partNo','partNoTest1');
        kakaoMap.put('phoneNo','01012345678');
        kakaoMapList.add(kakaoMap);

        Map<String,Object> kakaoMap2 = new Map<String, Object>();
        kakaoMap2.put('orderNo','orderNoTest2');
        kakaoMap2.put('partNo','partNoTest2');
        kakaoMap2.put('phoneNo','01023456789');
        kakaoMapList.add(kakaoMap2);

        EX_OrderReceiving_ba.sendKaKao(kakaoMapList);
        Test.stopTest();
    }

    @IsTest
    static void test_batch04() {

        Test.startTest();
        EX_TestDataUtil.getFulfillmentReceiving2(true);

        
        EX_TestDataUtil.baseProductRequestLineItem2.Order_CHNL_TYPE_Code__c = 'V';
        EX_TestDataUtil.baseProductRequestLineItem2.Consumables_Order_Status__c = '000';
        EX_TestDataUtil.baseProductRequestLineItem2.soldoutreceivingalarmdate__c = null;
        update EX_TestDataUtil.baseProductRequestLineItem2;


        EX_TestDataUtil.getDIV(true);
        EX_TestDataUtil.getOnlineInStockNotice(true);
        EX_TestDataUtil.getProductRequest(true);
        EX_TestDataUtil.getProductRequestLineItem(true);

        SR_RESRV_PART__c srp = new SR_RESRV_PART__c();
        srp.Consumables_Order_YN__c = true;
        srp.RESRV_Number__c = 'C000403468';
        insert srp;

        EX_TestDataUtil.baseProductRequestLineItem2.SR_RESRV_PART_Id__c = srp.Id;
        update EX_TestDataUtil.baseProductRequestLineItem2;

        EX_TestDataUtil.baseProduct.Name = 'EXS9342523';
        update EX_TestDataUtil.baseProduct;


        EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_CIC;
        EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443244';
        EX_TestDataUtil.getProductRequest(true);

        EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
        EX_TestDataUtil.getProductRequestLineItem(true);
        
        EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
        EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
        EX_TestDataUtil.getPrePaymentDetail(true);

        EX_TestDataUtil.getSmCode(true);

        //OBS
        EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_OBS;
        EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443245';
        EX_TestDataUtil.getProductRequest(true);

        EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
        EX_TestDataUtil.getProductRequestLineItem(false).CONSUMER_Price__c = 1000;
        EX_TestDataUtil.getProductRequestLineItem(true);

        EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
        EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'D';
        EX_TestDataUtil.getPrePaymentDetail(true);

        EX_TestDataUtil.getSmCode(true);


        //ThinQ
        EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_THINQ;
        EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443246';
        EX_TestDataUtil.getProductRequest(true);

        EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
        EX_TestDataUtil.getProductRequestLineItem(true);

        EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
        EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
        EX_TestDataUtil.getPrePaymentDetail(true);

        EX_TestDataUtil.getSmCode(true);


        //BestShop
        EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;
        EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443246';
        EX_TestDataUtil.getProductRequest(true);

        EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
        EX_TestDataUtil.getProductRequestLineItem(true);

        EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
        EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
        EX_TestDataUtil.getPrePaymentDetail(true);

        EX_TestDataUtil.getSmCode(true);

        Schema.Location lo = EX_TestDataUtil.getLocation(true, 'Center',  'PH8002');
        System.debug('lo :::: ' + lo);
        update lo;


        // EX_TestDataUtil.getProductItem_sold(true);



       

        
        
        Database.executeBatch(new EX_OrderReceiving_ba(), 1);
        Test.stopTest();
    }

    
    @IsTest
    static void test_batch05() {

        Test.startTest();
        EX_TestDataUtil.getFulfillmentReceiving2(true);

        
        EX_TestDataUtil.baseProductRequestLineItem2.Order_CHNL_TYPE_Code__c = 'V';
        EX_TestDataUtil.baseProductRequestLineItem2.Consumables_Order_Status__c = '000';
        EX_TestDataUtil.baseProductRequestLineItem2.soldoutreceivingalarmdate__c = null;
        EX_TestDataUtil.baseProductRequestLineItem2.BASIS_Parts_Number__c = 'EXS9342523';
        // EX_TestDataUtil.baseProductRequestLineItem2.BASIS_Parts_Number__c = 'ADQ75153413';
        update EX_TestDataUtil.baseProductRequestLineItem2;


        EX_TestDataUtil.getDIV(true);
        EX_TestDataUtil.getOnlineInStockNotice(true);
        EX_TestDataUtil.getProductRequest(true);
        EX_TestDataUtil.getProductRequestLineItem2(true);

        EX_TestDataUtil.baseProduct.Name = 'EXS9342523';
        update EX_TestDataUtil.baseProduct;


            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_CIC;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443244';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(true);
            
            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);

            //OBS
            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_OBS;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443245';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(false).CONSUMER_Price__c = 1000;
            EX_TestDataUtil.getProductRequestLineItem(true);

            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'D';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);


            //ThinQ
            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_THINQ;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443246';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(true);

            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);


            //BestShop
            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443246';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(true);

            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);

            Schema.Location lo = EX_TestDataUtil.getLocation(true, 'Center',  'PH8002');
            System.debug('lo :::: ' + lo);
            update lo;


        // EX_TestDataUtil.getProductItem_sold(true);


        // EX_TestDataUtil.baseProductTransfer.Order_Number__c = EX_TestDataUtil.baseProductRequestLineItem2.Order_Number__c;
        // EX_TestDataUtil.baseProductTransfer.ProductRequestLineItemId = EX_TestDataUtil.baseProductRequestLineItem2.Id;
        // update EX_TestDataUtil.baseProductTransfer;



        Database.executeBatch(new EX_OrderReceiving_ba(), 1);
        Test.stopTest();
    }

    @IsTest
    static void test_batch06() {

        Test.startTest();
        // List<ProductItem> currPdItem = [SELECT id FROM productItem];
        // delete currPdITem;

        EX_TestDataUtil.getFulfillmentReceiving2(true);
        // EX_TestDataUtil.baseProductItem.RESRV_QTY__c = null;
        // update EX_TestDataUtil.baseProductItem;

        EX_TestDataUtil.getDIV(true);
        EX_TestDataUtil.getOnlineInStockNotice(true);
        EX_TestDataUtil.getProductRequest(true);
        EX_TestDataUtil.getProductRequestLineItem(true);



            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_CIC;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443244';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(true);
            
            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);

            //OBS
            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_OBS;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443245';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(false).CONSUMER_Price__c = 1000;
            EX_TestDataUtil.getProductRequestLineItem(true);

            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'D';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);


            //ThinQ
            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_THINQ;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443246';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(true);

            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);


            //BestShop
            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443246';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(true);

            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);

            Schema.Location lo = EX_TestDataUtil.getLocation(true, 'Center',  'PH8002');
            System.debug('lo :::: ' + lo);
            // lo.LocationType = 'Warehouse';
            // lo.RecordType.DeveloperName = 'DIV';

            update lo;

        Product2 tempPd =  new Product2();
        //baseProduct.DISABLED_DT__c = tDate;
        tempPd.ACCESSORY_YN__c = 'Y';
        tempPd.ASC_PRICE__c = 3000;
        tempPd.AUTO_EX_YN__c = 'N';
        tempPd.AVG_PRICE__c = 2000;
        tempPd.MODEL_CODE__c = 'PFH9M1A.AKOR';
        tempPd.MEASURE_UNIT__c = 'EA';
        tempPd.NAME = 'ADQ75153413';
        tempPd.CAREPLUS_MODEL_CODE__c = 'PFH9M1A.AKOR';
        tempPd.CAREPLUS_AGENT_PRICE__c = 1000;
        tempPd.CAREPLUS_PRODUCT_DETAIL__c = '8';
//            baseProduct.CAREPLUS_PRODUCT_TYPE__c = 'A';
        tempPd.CAREPLUS_YN__c = 'Y';
        //tempPd.CLASS_CODE__c = 'ADQ0000';
        tempPd.CORE_PART_TYPE__c = '1';
        tempPd.COUNS_PART_YN__c = 'N';
        tempPd.CUST_PRICE__c = 5000;
        tempPd.DC_YN__c = 'N';
        tempPd.INWTY_SUPPLY_YN__c = 'N';
        tempPd.DISABLED_REL_DT__c = Date.today();
        tempPd.FIRST_RCV_DT__c = Date.today();
        tempPd.INPUT_DATE__c = Datetime.now();
        tempPd.DIV_INDEX_EX_YN__c = 'N';
        tempPd.DIV_CODE__c = 'DMZ';
        tempPd.DISABLED_REL_DT__c = Date.today();
        tempPd.IsActive = true;
        tempPd.isByPass__c = false;
        tempPd.IsMIG__c = false;
        tempPd.LAST_RCV_DT__c = Date.today();
        tempPd.LAST_RCV_PRICE__c = 4000;
        tempPd.ProductCode = 'EXS9342523b';
        tempPd.SALE_MODEL_CODE__c = 'EXS9342523a';
        tempPd.PART_DESC__c = 'TEST_PART_DESC';
        tempPd.PART_SPEC__c = 'TEST_PART_SPEC';
        tempPd.THINQ_ITEM_YN__c = 'Y';
        tempPd.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('PART_NO').getRecordTypeId();        
        insert tempPd;


//         productItem tempPdItem = new ProductItem();
//         tempPdItem.LocationId = EX_TestDataUtil.getLocation_sold4(true, 'Location', 'PH8002').Id;
//         tempPdItem.Product2Id = tempPd.Id;
//         tempPdItem.QuantityOnHand = 10;
//         tempPdItem.DIV_CODE__c = 'DMZ';
//         insert tempPdItem;

        ProductTransfer ptf = EX_TestDataUtil.baseProductTransfer.clone();
        // ptf.destinationLocationId = EX_TestDataUtil.getLocation(true, 'Center',  'PH8002').Id;
        ptf.ProductRequestLineItemId = EX_TestDataUtil.getProductRequestLineItem(true).Id;
        // ptf.QuantitySent = 200;
        // ptf.QuantityReceived = 100;
        insert ptf;

        // EX_TestDataUtil.baseProductTransfer.product2Id = tempPd.Id;
        // EX_TestDataUtil.baseProductTransfer.DestinationLocationId = EX_TestDataUtil.getLocation(true, 'Center',  'PH8002').Id;
        // EX_TestDataUtil.baseProductTransfer.QuantityReceived = 100;
        // EX_TestDataUtil.baseProductTransfer.QuantitySent = 200;
        // update EX_TestDataUtil.baseProductTransfer;


        EX_TestDataUtil.baseLocation.ParentLocationId__c = EX_TestDataUtil.baseLocation2.Id;
        update EX_TestDataUtil.baseLocation;


        Database.executeBatch(new EX_OrderReceiving_ba(), 1);
        Test.stopTest();
    }    

    @IsTest
    static void test_batch07() {

        Test.startTest();
        // List<ProductItem> currPdItem = [SELECT id FROM productItem];
        // delete currPdITem;

        EX_TestDataUtil.getFulfillmentReceiving2(true);
        // EX_TestDataUtil.baseProductItem.RESRV_QTY__c = null;
        // update EX_TestDataUtil.baseProductItem;

        EX_TestDataUtil.getDIV(true);
        EX_TestDataUtil.getOnlineInStockNotice(true);
        EX_TestDataUtil.getProductRequest(true);
        EX_TestDataUtil.getProductRequestLineItem(true);



            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_CIC;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443244';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(true);
            
            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);

            //OBS
            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_OBS;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443245';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(false).CONSUMER_Price__c = 1000;
            EX_TestDataUtil.getProductRequestLineItem(true);

            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'D';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);


            //ThinQ
            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_THINQ;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443246';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(true);

            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);


            //BestShop
            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443246';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(true);

            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);

            Schema.Location lo = EX_TestDataUtil.getLocation(true, 'Center',  'PH8002');
            System.debug('lo :::: ' + lo);
            // lo.LocationType = 'Warehouse';
            // lo.RecordType.DeveloperName = 'DIV';

            update lo;

        Product2 tempPd =  new Product2();
        //baseProduct.DISABLED_DT__c = tDate;
        tempPd.ACCESSORY_YN__c = 'Y';
        tempPd.ASC_PRICE__c = 3000;
        tempPd.AUTO_EX_YN__c = 'N';
        tempPd.AVG_PRICE__c = 2000;
        tempPd.MODEL_CODE__c = 'PFH9M1A.AKOR';
        tempPd.MEASURE_UNIT__c = 'EA';
        tempPd.NAME = 'ADQ75153413';
        tempPd.CAREPLUS_MODEL_CODE__c = 'PFH9M1A.AKOR';
        tempPd.CAREPLUS_AGENT_PRICE__c = 1000;
        tempPd.CAREPLUS_PRODUCT_DETAIL__c = '8';
//            baseProduct.CAREPLUS_PRODUCT_TYPE__c = 'A';
        tempPd.CAREPLUS_YN__c = 'Y';
        //tempPd.CLASS_CODE__c = 'ADQ0000';
        tempPd.CORE_PART_TYPE__c = '1';
        tempPd.COUNS_PART_YN__c = 'N';
        tempPd.CUST_PRICE__c = 5000;
        tempPd.DC_YN__c = 'N';
        tempPd.INWTY_SUPPLY_YN__c = 'N';
        tempPd.DISABLED_REL_DT__c = Date.today();
        tempPd.FIRST_RCV_DT__c = Date.today();
        tempPd.INPUT_DATE__c = Datetime.now();
        tempPd.DIV_INDEX_EX_YN__c = 'N';
        tempPd.DIV_CODE__c = 'DMZ';
        tempPd.DISABLED_REL_DT__c = Date.today();
        tempPd.IsActive = true;
        tempPd.isByPass__c = false;
        tempPd.IsMIG__c = false;
        tempPd.LAST_RCV_DT__c = Date.today();
        tempPd.LAST_RCV_PRICE__c = 4000;
        tempPd.ProductCode = EX_TestDataUtil.baseProduct.NAME;
        tempPd.SALE_MODEL_CODE__c = 'EXS9342523';
        tempPd.PART_DESC__c = 'TEST_PART_DESC';
        tempPd.PART_SPEC__c = 'TEST_PART_SPEC';
        tempPd.THINQ_ITEM_YN__c = 'Y';
        tempPd.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('PART_NO').getRecordTypeId();        
        insert tempPd;


//         productItem tempPdItem = new ProductItem();
//         tempPdItem.LocationId = EX_TestDataUtil.getLocation_sold4(true, 'Location', 'PH8002').Id;
//         tempPdItem.Product2Id = tempPd.Id;
//         tempPdItem.QuantityOnHand = 10;
//         tempPdItem.DIV_CODE__c = 'DMZ';
//         insert tempPdItem;

        ProductTransfer ptf = EX_TestDataUtil.baseProductTransfer.clone();
        // ptf.destinationLocationId = EX_TestDataUtil.getLocation(true, 'Center',  'PH8002').Id;
        ptf.ProductRequestLineItemId = EX_TestDataUtil.getProductRequestLineItem(true).Id;
        ptf.QuantitySent = 200;
        ptf.QuantityReceived = 100;
        insert ptf;

        // EX_TestDataUtil.baseProductTransfer.product2Id = tempPd.Id;
        // EX_TestDataUtil.baseProductTransfer.DestinationLocationId = EX_TestDataUtil.getLocation(true, 'Center',  'PH8002').Id;
        // EX_TestDataUtil.baseProductTransfer.QuantityReceived = 100;
        // EX_TestDataUtil.baseProductTransfer.QuantitySent = 200;
        // update EX_TestDataUtil.baseProductTransfer;


        EX_TestDataUtil.baseLocation.ParentLocationId__c = EX_TestDataUtil.baseLocation2.Id;
        update EX_TestDataUtil.baseLocation;


        Database.executeBatch(new EX_OrderReceiving_ba(), 1);
        Test.stopTest();
    } 

    @IsTest
    static void test_batch08() {

        Test.startTest();
        // List<ProductItem> currPdItem = [SELECT id FROM productItem];
        // delete currPdITem;

        EX_TestDataUtil.getFulfillmentReceiving2(true);
        // EX_TestDataUtil.baseProductItem.RESRV_QTY__c = null;
        // update EX_TestDataUtil.baseProductItem;

        EX_TestDataUtil.getDIV(true);
        EX_TestDataUtil.getOnlineInStockNotice(true);
        EX_TestDataUtil.getProductRequest(true);
        EX_TestDataUtil.getProductRequestLineItem(true);



            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_CIC;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443244';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(true);
            
            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);

            //OBS
            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_OBS;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443245';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(false).CONSUMER_Price__c = 1000;
            EX_TestDataUtil.getProductRequestLineItem(true);

            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'D';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);


            //ThinQ
            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_THINQ;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443246';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(true);

            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);


            //BestShop
            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443246';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(true);

            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);

            Schema.Location lo = EX_TestDataUtil.getLocation(true, 'Center',  'PH8002');
            System.debug('lo :::: ' + lo);
            // lo.LocationType = 'Warehouse';
            // lo.RecordType.DeveloperName = 'DIV';

            update lo;

        Product2 tempPd =  new Product2();
        //baseProduct.DISABLED_DT__c = tDate;
        tempPd.ACCESSORY_YN__c = 'Y';
        tempPd.ASC_PRICE__c = 3000;
        tempPd.AUTO_EX_YN__c = 'N';
        tempPd.AVG_PRICE__c = 2000;
        tempPd.MODEL_CODE__c = 'PFH9M1A.AKOR';
        tempPd.MEASURE_UNIT__c = 'EA';
        tempPd.NAME = 'ADQ75153413';
        tempPd.CAREPLUS_MODEL_CODE__c = 'PFH9M1A.AKOR';
        tempPd.CAREPLUS_AGENT_PRICE__c = 1000;
        tempPd.CAREPLUS_PRODUCT_DETAIL__c = '8';
//            baseProduct.CAREPLUS_PRODUCT_TYPE__c = 'A';
        tempPd.CAREPLUS_YN__c = 'Y';
        //tempPd.CLASS_CODE__c = 'ADQ0000';
        tempPd.CORE_PART_TYPE__c = '1';
        tempPd.COUNS_PART_YN__c = 'N';
        tempPd.CUST_PRICE__c = 5000;
        tempPd.DC_YN__c = 'N';
        tempPd.INWTY_SUPPLY_YN__c = 'N';
        tempPd.DISABLED_REL_DT__c = Date.today();
        tempPd.FIRST_RCV_DT__c = Date.today();
        tempPd.INPUT_DATE__c = Datetime.now();
        tempPd.DIV_INDEX_EX_YN__c = 'N';
        tempPd.DIV_CODE__c = 'DMZ';
        tempPd.DISABLED_REL_DT__c = Date.today();
        tempPd.IsActive = true;
        tempPd.isByPass__c = false;
        tempPd.IsMIG__c = false;
        tempPd.LAST_RCV_DT__c = Date.today();
        tempPd.LAST_RCV_PRICE__c = 4000;
        tempPd.ProductCode = EX_TestDataUtil.baseProduct.NAME;
        tempPd.SALE_MODEL_CODE__c = 'EXS9342523';
        tempPd.PART_DESC__c = 'TEST_PART_DESC';
        tempPd.PART_SPEC__c = 'TEST_PART_SPEC';
        tempPd.THINQ_ITEM_YN__c = 'Y';
        tempPd.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('PART_NO').getRecordTypeId();        
        insert tempPd;


//         productItem tempPdItem = new ProductItem();
//         tempPdItem.LocationId = EX_TestDataUtil.getLocation_sold4(true, 'Location', 'PH8002').Id;
//         tempPdItem.Product2Id = tempPd.Id;
//         tempPdItem.QuantityOnHand = 10;
//         tempPdItem.DIV_CODE__c = 'DMZ';
//         insert tempPdItem;

        ProductTransfer ptf = EX_TestDataUtil.baseProductTransfer.clone();
        // ptf.destinationLocationId = EX_TestDataUtil.getLocation(true, 'Center',  'PH8002').Id;
        ptf.ProductRequestLineItemId = EX_TestDataUtil.getProductRequestLineItem(true).Id;
        ptf.QuantitySent = 200;
        ptf.QuantityReceived = 100;
        insert ptf;

        EX_TestDataUtil.baseProductRequestLineItem.BASIS_Parts_Number__c = 'PART_NUMBER';
        // EX_TestDataUtil.baseProductRequestLineItem2.BASIS_Parts_Number__c = 'PART_NUMBER';
        update EX_TestDataUtil.baseProductRequestLineItem;
        // update EX_TestDataUtil.baseProductRequestLineItem2;
        // EX_TestDataUtil.baseProductTransfer.product2Id = tempPd.Id;
        // EX_TestDataUtil.baseProductTransfer.DestinationLocationId = EX_TestDataUtil.getLocation(true, 'Center',  'PH8002').Id;
        // EX_TestDataUtil.baseProductTransfer.QuantityReceived = 100;
        // EX_TestDataUtil.baseProductTransfer.QuantitySent = 200;
        // update EX_TestDataUtil.baseProductTransfer;


        EX_TestDataUtil.baseLocation.ParentLocationId__c = EX_TestDataUtil.baseLocation2.Id;
        update EX_TestDataUtil.baseLocation;


        Database.executeBatch(new EX_OrderReceiving_ba(), 1);
        Test.stopTest();
    }     

    @IsTest
    static void test_exception_batch01() {
        Test.startTest();
        SI_FULFILLMENT_RECEIVING__c ffmt = EX_TestDataUtil.getFulfillmentReceiving(true);
        Database.executeBatch(new EX_OrderReceiving_ba(), 1);
        Test.stopTest();
    }     

    @isTest
    static void testException_02() {
        EX_TestDataUtil.getReturnOrderLineItem(true);
        EX_TestDataUtil.getFulfillmentReceiving(true);
        
        ProductTransfer pt = [SELECT Id, ProductRequestId, ReturnOrderLineItemId, ProductRequestLineItemId, DestinationLocationId, DestinationLocation.name, RecordTypeId, QuantityReceived,Return_Order_Quantity__c,RSV_Quantity__c,SHIPPED_Date__c,MOVE_Type_Code__c,
        Product2Id, CARTON__c FROM ProductTransfer LIMIT 1];

        List<Map<String, Object>> listPT = new List<Map<String, Object>>();
        Map<String,Object> ptMap = new Map<String,Object>();
        ptMap.put('Id', pt.Id);
        ptMap.put('ProductRequestId', pt.ProductRequestId);
        ptMap.put('ProductRequestLineItemId', pt.ProductRequestLineItemId);
        ptMap.put('DestinationLocationId', pt.DestinationLocationId);
        ptMap.put('stockPlace', pt.DestinationLocation.name);
        ptMap.put('RecordTypeId', pt.RecordTypeId);
        ptMap.put('QuantityReceived', pt.QuantityReceived);
        ptMap.put('quantityReturned', pt.Return_Order_Quantity__c);
        ptMap.put('RSV_Quantity__c', pt.RSV_Quantity__c);
        ptMap.put('SHIPPED_Date__c', pt.SHIPPED_Date__c);
        ptMap.put('MOVE_Type_Code__c', pt.MOVE_Type_Code__c);
        ptMap.put('ReturnOrderLineItemId', pt.ReturnOrderLineItemId);
        ptMap.put('Product2Id', pt.Product2Id);
        ptMap.put('CARTON__c', pt.CARTON__c);
        listPT.add(ptMap);


        Test.startTest();
        EX_OrderReceiving_ba.doSaveReceivingItems(listPT);
        Test.stopTest();
    }

    @isTest
    static void test_sendCalloutKakao() {
        Test.startTest();
        String templateCode = 'SVC_LGE_MACN_S020';
        String kakaoMsg = 'testKAKAOMsg';
        String kakaoTitle = 'testKAKAOTitle';
        String smsMsg = 'testSMSMsg';
        String smsTitle = 'testSMSTitle';
        String phoneNoStr = '010-1111-2222';
        Datetime sendAt = System.now();
        EX_OrderReceiving_ba.sendCalloutKakao(templateCode, kakaoMsg, kakaoTitle, smsMsg, smsTitle, phoneNoStr, sendAt);
        Test.stopTest();
    }



    // StatusCode=200 Mock
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = newResponse(200);
            return res;
        }
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{ "Header" : {"rstType" : "test", "rstMsg" : "test" } , "Body" : { "data" : [ { "partNo" : "test", "divCode" : "test","PartNameKor" : "test","ObsSalesYN" : "Y", "ObsImageURL" : "testt","ObsSalesURL" : "test", "ObsMemberPrice" : 3000 } ] } } ');
        return res;
    }

    private class TestHttpCalloutMock implements HttpCalloutMock {
        private Integer statusCode;
        private Boolean isSUCCESS;
        private TestHttpCalloutMock(Integer statusCode, Boolean isSUCCESS) {
            this.statusCode = statusCode;
            this.isSUCCESS = isSUCCESS;
        }
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = newResponse(statusCode, isSUCCESS);
            return response;
        } 
    }
    
    private static HTTPResponse newResponse(Integer statusCode, Boolean isSUCCESS) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(statusCode);
        if(isSUCCESS) {
            response.setBody('{"messages":[{"to":{"phoneNumber":"820100001111"},"status":{"groupId":1,"groupName":"testGroupName","id":7,"name":"testName","description":"Message sent to next instance"},"messageId":"testMessageId"}]}');   
        } else {
            response.setBody('fail');    
        }
        return response;
    }

}