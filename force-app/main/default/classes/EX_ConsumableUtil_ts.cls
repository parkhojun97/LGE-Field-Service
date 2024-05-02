/****************************************************************************************
 * @filename      : EX_ConsumableUtil_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-10 오전 11:27
 * @group         :
 * @group-content :
 * @description   : EX_ConsumableUtil Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-10       I2max               Create
 ****************************************************************************************/

@IsTest
private class EX_ConsumableUtil_ts {
    @IsTest
    static void test_returnStatusKORMap() {
        Test.startTest();
        EX_ConsumableUtil.returnStatusKORMap('test');
        Test.stopTest();
    }

    @IsTest
    static void test_returnStatusCodeMap() {
        Test.startTest();
        EX_ConsumableUtil.returnStatusCodeMap('test');
        Test.stopTest();
    }

    @IsTest
    static void test_getExOrderStatusList() {
        Test.startTest();
        EX_ConsumableUtil.getExOrderStatusList('ProductRequestLineItem', 'Order');
        EX_ConsumableUtil.getExOrderStatusList('ProductRequestLineItem', 'Order2');
        Test.stopTest();
    }

    @IsTest
    static void test_createReturnRequest() {
        ProductRequestLineItem lineItem = EX_TestDataUtil.getProductRequestLineItem(true);
        List<Map<String, Object>> pListMapReturnRequestInfo = new List<Map<String, Object>>();
        List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable> exchangeReturnItemTables = new List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable>();
        EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable item = new EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable();
        item.Id = lineItem.Id;
        item.PartNameKOR = 'PartNameKOR';
        item.OrderSEQ = 0;
        item.CashAmount = 0;
        item.CardAmount = 0;
        item.PointAmount = 0;
        item.RequestedReturnQuantity = 1000;
        item.ReturnSaleAmount = 1000;
        item.ReturnPaymentAmount = 1000;
        item.ReturnDiscountAmount = 1000;
        item.ReturnCardPaymentAmount = 1000;
        item.ReturnVBankPaymentAmount = 1000;
        item.ReturnPointAmount = 1000;
        item.OrderChannel = '소모품택배';
        EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable item2 = item.clone();
        item2.Id = lineItem.Id;
        item2.PartNameKOR = 'PartNameKOR';
        item2.OrderSEQ = 0;
        item2.CashAmount = 0;
        item2.CardAmount = 0;
        item2.PointAmount = 0;
        item2.RequestedReturnQuantity = 1000;
        item2.ReturnSaleAmount = 1000;
        item2.ReturnPaymentAmount = 1000;
        item2.ReturnDiscountAmount = 1000;
        item2.ReturnCardPaymentAmount = 1000;
        item2.ReturnVBankPaymentAmount = 1000;
        item2.ReturnPointAmount = 1000;
        item2.OrderChannel = '소모품택배';
        item2.IsRequestRefund = true;
        exchangeReturnItemTables.add(item2);

        EX_ConsumableUtil.ConsumableReturnOrderTable consumableReturnOrderTable = new EX_ConsumableUtil.ConsumableReturnOrderTable();
        consumableReturnOrderTable.ConsumableReturnOrderLineItemTables = exchangeReturnItemTables;
        consumableReturnOrderTable.OriginOrderNumber = 'test';
        consumableReturnOrderTable.OriginOrderId = EX_TestDataUtil.getProductRequest(true).Id;
        consumableReturnOrderTable.ContactId = EX_TestDataUtil.getContact(true).Id;
        consumableReturnOrderTable.CustomerName = 'test';
        consumableReturnOrderTable.CustomerPhone = '000-0000-0000';
        consumableReturnOrderTable.CustomerPhone2 = '111-1111-1111';
        consumableReturnOrderTable.CustomerAddress = 'test';
        consumableReturnOrderTable.CustomerDetailAddress = 'test';
        consumableReturnOrderTable.CustomerPostalCode = 'test';
        consumableReturnOrderTable.OrderSEQ = 1;
        consumableReturnOrderTable.ReturnSaleAmount = 1000;
        consumableReturnOrderTable.ReturnPaymentAmount = 1000;
        consumableReturnOrderTable.ReturnDiscountAmount = 1000;
        consumableReturnOrderTable.ReturnCardPaymentAmount = 1000;
        consumableReturnOrderTable.ReturnVBankPaymentAmount = 1000;
        consumableReturnOrderTable.ReturnPointAmount = 1000;

        Map<String, Object> mapRequestInfo = new Map<String, Object>();
        mapRequestInfo.put('consumableReturnOrderTable', consumableReturnOrderTable);
        pListMapReturnRequestInfo.add(mapRequestInfo);

        Test.startTest();
        TriggerHandler.bypass('ReturnOrder_tr');
        TriggerHandler.bypass('ReturnOrderLineItem_tr');
        EX_ConsumableUtil.createReturnRequest(pListMapReturnRequestInfo, 'B', 'ExchangeReturn');
        EX_ConsumableUtil.createReturnRequest(pListMapReturnRequestInfo, 'B', 'Return');
        Test.stopTest();
    }

    @IsTest
    static void test_checkBankAccountUtil() {
        insert new PaymentAPISetting_cs__c(Name = 'CheckRefundAccount', ApiKey__c = 'ApiKey', EndPoint__c = 'EndPoint');
        Test.startTest();
        try{
            List<SM_DEPT__c> sm = new List<SM_DEPT__c>();
            sm = [SELECT Id FROM SM_DEPT__c WHERE DEPT_CODE__c = 'PH8002' LIMIT 1];
            if(sm.isEmpty()){
                SM_DEPT__c sd = EX_TestDataUtil.getDept(true,'PH8002');
                sm.add(sd);
            }
            Payment_Gateway__c pg2 = new Payment_Gateway__c();
            pg2.DIV_CODE__c = 'PG카드_URL/가상계좌';
            pg2.MID__c = 'tlgsmp001m';
            pg2.SIGN_KEY__c = 'IGp3k/3j2e3toqdnizlGFZIE9YKLQ15TDqTVP+f3uy3iOPt3hxhXfywDDC7cde1f5YrrxfV3wZxVVR8zuL2fbw==';
            pg2.SM_DEPT__c = sm[0].Id;
            insert pg2;
            
            Test.setMock(HttpCalloutMock.class, new HttpBankSMockCalloutMock());
            EX_ConsumableUtil.checkBankAccountUtil('020', '1234567890', 'receiverName',new List<Object>{new Map<String, Object>{'Json' => 'Json'}});
            
            Test.setMock(HttpCalloutMock.class, new HttpBankFMockCalloutMock());
            EX_ConsumableUtil.checkBankAccountUtil('020', '1134567890', 'receiverName',new List<Object>{new Map<String, Object>{'Json' => 'Json'}});
        }catch(Exception e){
            System.debug(e.getLineNumber() + ', ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void test_cancelUtil() {
        insert new PaymentAPISetting_cs__c[]{
                new PaymentAPISetting_cs__c(Name = 'CancelApproval', ApiKey__c = 'ApiKey', EndPoint__c = 'EndPoint'),
                new PaymentAPISetting_cs__c(Name = 'SpendOrCancelPoint', ApiKey__c = 'ApiKey', EndPoint__c = 'EndPoint'),
                new PaymentAPISetting_cs__c(Name = 'CancelCardUrl', ApiKey__c = 'ApiKey', EndPoint__c = 'EndPoint'),
                new PaymentAPISetting_cs__c(Name = 'RefundCashFromVirtualAccount', ApiKey__c = 'ApiKey', EndPoint__c = 'EndPoint')
        };
        ProductRequestLineItem lineItem = EX_TestDataUtil.getProductRequestLineItem(true);
        insert new SR_SMARTRO_PAYMENT_REQUEST__c(SMARTRO_PAYMENT_REQUEST_PK__c = '1', MOID__c = 'MOID', PAYMENT_TYPE__c = 'PG_URL');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCancelMockCalloutMock());
        EX_TestDataUtil.getDept(true, 'PH8002');
        EX_TestDataUtil.getUser(true).DEPT_CODE__c = 'PH8002';
        update new User(Id = UserInfo.getUserId(), DEPT_CODE__c = 'PH8002');
        Payment_Gateway__c pg = new Payment_Gateway__c(SM_DEPT__c = EX_TestDataUtil.dept.Id, DIV_CODE__c = 'PG카드_내부단말기', MID__c = 'mid', SIGN_KEY__c = 'key');

        ProductRequestLineItem line = [SELECT Order_Number__c FROM ProductRequestLineItem LIMIT 1];
        SR_PRE_PAYMENT_HEADER__c header = EX_TestDataUtil.getPrePaymentHeader(false);
        header.BASIS_NO__c = line.Order_Number__c;
        insert header;
        SR_PRE_PAYMENT_DETAIL__c detail = EX_TestDataUtil.getPrePaymentDetail(false);
        detail.DEPOSIT_TYPE__c = 'D';
        detail.SR_PRE_PAYMENT_HEADER_ID__r = header;
        detail.PAY_CUST_NAME__c ='이승현';
        detail.CERTIFY_KEY__c ='01031447479';
        insert detail;

        List<SM_DEPT__c> sm = new List<SM_DEPT__c>();
        sm = [SELECT Id FROM SM_DEPT__c WHERE DEPT_CODE__c = 'PH8002' LIMIT 1];
        if(sm.isEmpty()){
            SM_DEPT__c sd = EX_TestDataUtil.getDept(true,'PH8002');
            sm.add(sd);
        }
        Payment_Gateway__c pg2 = new Payment_Gateway__c();
        pg2.DIV_CODE__c = 'PG카드_출장MCS';
        pg2.MID__c = 'tlgsmp002m';
        pg2.SIGN_KEY__c = 'vVW3zt63C2ywwIygEUtUUM3yWzC73KX0xT1JwoC+x6yz8bOOiKK+sjFM0vfJChqtijkiqURZ8yCTJ2k3wYev7A==';
        pg2.SM_DEPT__c = sm[0].Id;
        insert pg2;

        Payment_Gateway__c pg3 = new Payment_Gateway__c();
        pg3.DIV_CODE__c = 'PG카드_URL/가상계좌';
        pg3.MID__c = 'tlgsmp001m';
        pg3.SIGN_KEY__c = 'IGp3k/3j2e3toqdnizlGFZIE9YKLQ15TDqTVP+f3uy3iOPt3hxhXfywDDC7cde1f5YrrxfV3wZxVVR8zuL2fbw==';
        pg3.SM_DEPT__c = sm[0].Id;
        insert pg3;        

        String deptCode = 'PH8002';
        EX_ConsumableUtil.getDepartmentName(deptCode);
        Set<String> deptCodeSet = new Set<String>();
        deptCodeSet.add(deptCode);
        EX_ConsumableUtil.getDepartmentNameMap(deptCodeSet);

        List<User> usr = [SELECT Id FROM User WHERE DEPT_CODE__c = 'PH8002' LIMIT 1];

        SR_SMARTRO_PAYMENT_REQUEST__c srp = new SR_SMARTRO_PAYMENT_REQUEST__c();
        srp.MID__c = 'MID';
        srp.MOID__c = 'MOID';
        srp.TID__c = 'TID';
        srp.APPR_AMT__c = 500;
        srp.APPR_BALANCE__c = 0;
        srp.PAYMETHOD__c = 'CARD';
        srp.PAYMENT_TYPE__c = 'PG_URL';
        srp.SMARTRO_PAYMENT_REQUEST_PK__c = '3';
        insert srp;

        try{
            System.runAs(usr[0]) {
                EX_ConsumableUtil.cancelUtil('strCaseId', 'remark', new List<Object>{
                        new Map<String, Object>{
                                'SalesNumber' => 'SalesNumber', 'RSRV_Number' => 'RSRV_Number', 'DiscountType' => 'DiscountType', 'CancelQuantity' => 1,
                                'QuantityRequested' => 1000, 'PointAmount' => 1000, 'OrderStatus' => '결제요청', 'PayMethod' => '현금입금', 'QuantityRequested' => 1000, 'Id' => lineItem.Id, 'OrderNumber' => line.Order_Number__c
                        }
                    }, new List<Object>{
                        new Map<String, Object>{
                                'QuantityRequested' => 1000, 'Id' => lineItem.Id
                        }
                    }, new List<Object>{
                        new Map<String, Object>{
                                'OrderChannel' => '소모품택배', 'MOID' => 'MOID',
                                'OrderNumber' => line.Order_Number__c,
                                'PaymentMethod' => '현금입금'
                        }
                    }, '', '', '');

                EX_ConsumableUtil.cancelUtil('strCaseId', 'remark', new List<Object>{
                        new Map<String, Object>{
                                'DiscountType' => 'DiscountType', 'CancelQuantity' => 1, 'QuantityRequested' => 1000, 'PointAmount' => 1000, 'OrderStatus' => '결제요청', 'PayMethod' => '카드URL', 'QuantityRequested' => 1000, 'Id' => lineItem.Id
                        }
                }, new List<Object>{
                        new Map<String, Object>{
                                'QuantityRequested' => 1000, 'Id' => lineItem.Id
                        }
                }, new List<Object>{
                        new Map<String, Object>{
                                'OrderChannel' => '소모품택배', 'MOID' => 'MOID',  'OrderNumber' => line.Order_Number__c, 'PaymentMethod' => '카드URL'
                        }
                }, '', '', '');

                EX_ConsumableUtil.cancelUtil('strCaseId', 'remark', new List<Object>{
                        new Map<String, Object>{
                                'DiscountType' => 'DiscountType', 'CancelQuantity' => 1, 'QuantityRequested' => 1000, 'PointAmount' => 1000, 'OrderStatus' => '결제요청', 'PayMethod' => '포인트', 'QuantityRequested' => 1000, 'Id' => lineItem.Id
                        }
                }, new List<Object>{
                        new Map<String, Object>{
                                'QuantityRequested' => 1000, 'Id' => lineItem.Id
                        }
                }, new List<Object>{
                        new Map<String, Object>{
                                'OrderChannel' => '소모품택배', 'MOID' => 'MOID', 'OrderNumber' => line.Order_Number__c, 'PaymentMethod' => '포인트'
                        }
                }, '', '', '');

                EX_ConsumableUtil.cancelUtil('strCaseId', 'remark', new List<Object>{
                        new Map<String, Object>{
                                'DiscountType' => 'DiscountType', 'CancelQuantity' => 1, 'QuantityRequested' => 1000, 'PointAmount' => 1000, 'OrderStatus' => '상품준비중', 'PayMethod' => '현금입금', 'QuantityRequested' => 1000, 'Id' => lineItem.Id
                        }
                }, new List<Object>{
                        new Map<String, Object>{
                                'QuantityRequested' => 1000, 'Id' => lineItem.Id
                        }
                }, new List<Object>{
                        new Map<String, Object>{
                                'OrderChannel' => '소모품택배', 'MOID' => 'MOID', 'OrderNumber' => line.Order_Number__c, 'PaymentMethod' => '현금입금'
                        }
                }, '', '', '');

            EX_ConsumableUtil.cancelUtil('strCaseId', 'remark', new List<Object>{
                        new Map<String, Object>{
                                'DiscountType' => 'DiscountType', 'CancelQuantity' => 1, 'QuantityRequested' => 1000, 'PointAmount' => 1000, 'OrderStatus' => '상품준비중', 'PayMethod' => '카드', 'QuantityRequested' => 1000, 'Id' => lineItem.Id
                        }
                }, new List<Object>{
                        new Map<String, Object>{
                                'QuantityRequested' => 1000, 'Id' => lineItem.Id
                        }
                }, new List<Object>{
                        new Map<String, Object>{
                                'OrderChannel' => '소모품택배', 'MOID' => 'MOID', 'OrderNumber' => line.Order_Number__c, 'PaymentMethod' => '카드'
                        }
                }, '', '', '');


                EX_ConsumableUtil.cancelUtil('strCaseId', 'remark', new List<Object>{
                        new Map<String, Object>{
                                'DiscountType' => 'DiscountType', 'CancelQuantity' => 1, 'QuantityRequested' => 1000, 'PointAmount' => 1000, 'OrderStatus' => '상품준비중', 'PayMethod' => '포인트', 'QuantityRequested' => 1000, 'Id' => lineItem.Id
                        }
                }, new List<Object>{
                        new Map<String, Object>{
                                'QuantityRequested' => 1000, 'Id' => lineItem.Id
                        }
                }, new List<Object>{
                        new Map<String, Object>{
                                'OrderChannel' => '소모품택배', 'MOID' => 'MOID', 'OrderNumber' => line.Order_Number__c, 'PaymentMethod' => '포인트'
                        }
                }, '', '', '');

            EX_ConsumableUtil.cancelUtil('strCaseId', 'remark', new List<Object>{
                    new Map<String, Object>{
                            'DiscountType' => 'DiscountType', 'CancelQuantity' => 1, 'QuantityRequested' => 1000, 'PointAmount' => 500, 'CardAmount' => 500, 'OrderStatus' => '상품준비중', 'PayMethod' => '포인트', 'QuantityRequested' => 1000, 'Id' => lineItem.Id
                    }
            }, new List<Object>{
                    new Map<String, Object>{
                            'QuantityRequested' => 1000, 'Id' => lineItem.Id
                    }
            }, new List<Object>{
                    new Map<String, Object>{
                            'OrderChannel' => '소모품택배', 'MOID' => 'MOID', 'TID' => 'TID', 'OrderNumber' => line.Order_Number__c, 'PaymentMethod' => '결제URL'
                    }
            }, '', '', '');

            EX_ConsumableUtil.cancelUtil('strCaseId', 'remark', new List<Object>{
                    new Map<String, Object>{
                            'DiscountType' => 'DiscountType', 'CancelQuantity' => 1, 'QuantityRequested' => 1000, 'PointAmount' => 500, 'CardAmount' => 500, 'OrderStatus' => '결제완료', 'PayMethod' => '포인트', 'QuantityRequested' => 1000, 'Id' => lineItem.Id
                    }
            }, new List<Object>{
                    new Map<String, Object>{
                            'QuantityRequested' => 1000, 'Id' => lineItem.Id
                    }
            }, new List<Object>{
                    new Map<String, Object>{
                            'OrderChannel' => '소모품택배', 'MOID' => 'MOID', 'TID' => 'TID', 'OrderNumber' => line.Order_Number__c, 'PaymentMethod' => '결제URL'
                    }
            }, '', '', '');
            }
        }catch (Exception e){
            System.debug('line : ' + e.getLineNumber() + ', msg : ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void test_generateRandomString() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCancelMockCalloutMock());
        EX_ConsumableUtil.generateRandomString(20);
        Test.stopTest();
    }

    @IsTest
    static void test_getSubNumberMap() {
        ReturnOrderLineItem orderItem = EX_TestDataUtil.getReturnOrderLineItem(true);
        orderItem.SUB_Order_Number__c = 'O3-443-243-3000';
        orderItem.Consumables_Order_YN__c = true;
        orderItem.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
        update orderItem;
        ProductRequestLineItem lineItem1 = EX_TestDataUtil.baseProductRequestLineItem.clone();
        lineItem1.BASIS_Order_Item_Id__c = EX_TestDataUtil.baseProductRequestLineItem.Id;
        lineItem1.Order_SEQ__c = 3000;
        lineItem1.Order_Number__c = 'O3-443-243';
        insert lineItem1;

        ProductRequest pr = EX_TestDataUtil.getProductRequest(false).clone();
        pr.Consumables_Order_USE_YN__c = true;
        insert pr;
        ProductRequestLineItem lineItem2 = EX_TestDataUtil.baseProductRequestLineItem.clone();
        lineItem2.Consumables_Order_YN__c = TRUE;
        lineItem2.SUB_Order_Number__c = 'O3-443-243-3000';
        lineItem2.RecordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
        lineItem2.ParentId = pr.Id;
        lineItem2.Consumables_Order_Class_Code__c = 'General';
        insert lineItem2;



        Test.startTest();
        EX_ConsumableUtil.getSubNumberMap(new List<sObject>{lineItem1,lineItem2});
        Test.stopTest();
    }

    @IsTest
    static void test_getSubNumber_01() {
        ProductRequestLineItem lineItem = EX_TestDataUtil.getProductRequestLineItem(true);
        Map<String, Integer> subNumberMap = new Map<String, Integer>{'O3443243-001' => 1000};
        Test.startTest();
        EX_ConsumableUtil.getSubNumber(subNumberMap, lineItem);
        Test.stopTest();
    }

    @IsTest
    static void test_doSaveSales2_01() {
        SR_RESRV_PART__c srrp = new SR_RESRV_PART__c();
        insert srrp;

        ProductRequestLineItem lineItem = EX_TestDataUtil.getProductRequestLineItem(true);
        lineItem.RecordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
        lineItem.SR_RESRV_PART_Id__c = srrp.Id;
        lineItem.ENDP_RSV_Quantity__c = 1;
        lineItem.QuantityRequested = 2;
        update lineItem;


        ProductRequest pr = EX_TestDataUtil.baseProductRequest;
        pr.SR_RSRV_PART_Id__c = srrp.Id;
        pr.Consumables_Business_Type_Code__c = 'Order';
        update pr;
        
        Schema.Location loc = EX_TestDataUtil.getLocation(true, 'Location', 'PH0300');
        EX_TestDataUtil.getPrePaymentDetail(true);
        
        EX_TestDataUtil.smartroPaymentRequest.CANCEL_AMT__c = 0;
        update EX_TestDataUtil.smartroPaymentRequest;

        Test.startTest();
        List<ProductRequest> prList = new List<ProductRequest>();
        prList.add(pr);

        List<ProductRequestLineItem> prliList = new List<ProductRequestLineItem>();
        lineItem.payment_amount__c = 10000;
        prliList.add(lineItem);

        SM_CODE_MASTER__c smcm = EX_TestDataUtil.getSmCodeMaster(true);
        smcm.Name = 'UD009';
        update smcm;

        SM_CODE__c smc = EX_TestDataUtil.getSmCode(false);
        smc.CLASS_CODE__c = smcm.Id;
        smc.USE_YN__c = 'Y';
        insert smc;

        Map<String, List<ProductRequestLineItem>> orderNumberPrLiMap = new Map<String, List<ProductRequestLineItem>>();
        orderNumberPrLiMap.put(pr.Order_Number__c, prliList);

        Map<String, Decimal> orderNumberPaymentAmtMap = new Map<String, Decimal>();
        Map<String, Decimal> orderNumberDiscountAmtMap = new Map<String, Decimal>();

        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('caller','notScreen');
        paramMap.put('prLiList',prliList);
        paramMap.put('orderNumberPrLiMap',orderNumberPrLiMap);
        List<String> orderNumberList = new List<String>{'O3443243'};
        paramMap.put('orderNumberList',orderNumberList);

        List<String> salesFailOrderNumberList = new List<String>();
        paramMap.put('salesFailOrderNumberList',salesFailOrderNumberList);

        paramMap.put('orderNumberPaymentAmtMap', orderNumberPaymentAmtMap);
        paramMap.put('orderNumberDiscountAmtMap', orderNumberDiscountAmtMap);
        try{
            EX_ConsumableUtil.doSaveSales2(paramMap, prList);
        }catch(Exception e){System.debug(e.getMessage());}
        Test.stopTest();
    }
    @IsTest
    static void test_doSaveSales2_02() {
        ProductRequestLineItem lineItem = EX_TestDataUtil.getProductRequestLineItem(true);
        // ProductRequest pr = EX_TestDataUtil.getProductRequest(false);
        EX_TestDataUtil.baseProductRequest.Order_CHNL_TYPE_Code__c = 'BestShop';
        EX_TestDataUtil.baseProductRequest.CASH_PAYMENT_Amount__c = 1000;
        EX_TestDataUtil.baseProductRequest.CARD_PAYMENT_Amount__c = 0;
        EX_TestDataUtil.baseProductRequestLineItem.CASH_PAYMENT_Amount__c = 1000;
        EX_TestDataUtil.baseProductRequestLineItem.CARD_PAYMENT_Amount__c = 0;
        update EX_TestDataUtil.baseProductRequest;
        update EX_TestDataUtil.baseProductRequestLineItem;
        SR_RESRV_PART__c srrp = new SR_RESRV_PART__c();
        insert srrp;
        ProductRequest pr = EX_TestDataUtil.baseProductRequest;
        pr.SR_RSRV_PART_Id__c = srrp.Id;
        EX_TestDataUtil.getDept(true, 'PH0300');
        Schema.Location loc = EX_TestDataUtil.getLocation(true, 'Location', 'PH0300');
        EX_TestDataUtil.getPrePaymentDetail(true);
        
        EX_TestDataUtil.smartroPaymentRequest.CANCEL_AMT__c = 0;
        update EX_TestDataUtil.smartroPaymentRequest;
                
        Test.startTest();
        
        List<ProductRequest> prList = new List<ProductRequest>();
        prList.add(pr);
        List<ProductRequestLineItem> prliList = new List<ProductRequestLineItem>();
        lineItem.payment_amount__c = 10000;
        prliList.add(lineItem);

        Map<String, List<ProductRequestLineItem>> orderNumberPrLiMap = new Map<String, List<ProductRequestLineItem>>();
        orderNumberPrLiMap.put(pr.Order_Number__c, prliList);

        Map<String, Decimal> orderNumberPaymentAmtMap = new Map<String, Decimal>();
        Map<String, Decimal> orderNumberDiscountAmtMap = new Map<String, Decimal>();

        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('caller','notScreen');
        paramMap.put('prLiList',prliList);
        paramMap.put('orderNumberPrLiMap',orderNumberPrLiMap);
        List<String> orderNumberList = new List<String>{'O3443243'};
        paramMap.put('orderNumberList',orderNumberList);

        List<String> salesFailOrderNumberList = new List<String>();
        paramMap.put('salesFailOrderNumberList',salesFailOrderNumberList);

        paramMap.put('orderNumberPaymentAmtMap', orderNumberPaymentAmtMap);
        paramMap.put('orderNumberDiscountAmtMap', orderNumberDiscountAmtMap);
        try{
            EX_ConsumableUtil.doSaveSales2(paramMap, prList);
        }catch(Exception e){System.debug(e.getMessage());}
        Test.stopTest();
    }
    @IsTest
    static void test_doSaveSales2_03() {
        ProductRequestLineItem lineItem = EX_TestDataUtil.getProductRequestLineItem(true);
        EX_TestDataUtil.baseProductRequest.Order_CHNL_TYPE_Code__c = 'B';
        EX_TestDataUtil.baseProductRequest.CASH_PAYMENT_Amount__c = 1000;
        EX_TestDataUtil.baseProductRequest.CARD_PAYMENT_Amount__c = 0;
        EX_TestDataUtil.baseProductRequestLineItem.CASH_PAYMENT_Amount__c = 1000;
        EX_TestDataUtil.baseProductRequestLineItem.CARD_PAYMENT_Amount__c = 0;
        update EX_TestDataUtil.baseProductRequest;
        update EX_TestDataUtil.baseProductRequestLineItem;
        SR_RESRV_PART__c srrp = new SR_RESRV_PART__c();
        insert srrp;
        ProductRequest pr = EX_TestDataUtil.baseProductRequest;
        pr.SR_RSRV_PART_Id__c = srrp.Id;
        EX_TestDataUtil.getDept(true, 'PH0300');
        Schema.Location loc = EX_TestDataUtil.getLocation(true, 'Location', 'PH0300');
        EX_TestDataUtil.getPrePaymentDetail(true);
        
        EX_TestDataUtil.smartroPaymentRequest.CANCEL_AMT__c = 0;
        update EX_TestDataUtil.smartroPaymentRequest;
                
        Test.startTest();
        
        List<ProductRequest> prList = new List<ProductRequest>();
        prList.add(pr);
        List<ProductRequestLineItem> prliList = new List<ProductRequestLineItem>();
        lineItem.payment_amount__c = 10000;
        prliList.add(lineItem);

        Map<String, List<ProductRequestLineItem>> orderNumberPrLiMap = new Map<String, List<ProductRequestLineItem>>();
        orderNumberPrLiMap.put(pr.Order_Number__c, prliList);

        Map<String, Decimal> orderNumberPaymentAmtMap = new Map<String, Decimal>();
        Map<String, Decimal> orderNumberDiscountAmtMap = new Map<String, Decimal>();

        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('caller','notScreen');
        paramMap.put('prLiList',prliList);
        paramMap.put('orderNumberPrLiMap',orderNumberPrLiMap);
        List<String> orderNumberList = new List<String>{'O3443243'};
        paramMap.put('orderNumberList',orderNumberList);

        List<String> salesFailOrderNumberList = new List<String>();
        paramMap.put('salesFailOrderNumberList',salesFailOrderNumberList);

        paramMap.put('orderNumberPaymentAmtMap', orderNumberPaymentAmtMap);
        paramMap.put('orderNumberDiscountAmtMap', orderNumberDiscountAmtMap);
        try{
            EX_ConsumableUtil.doSaveSales2(paramMap, prList);
        }catch(Exception e){System.debug(e.getMessage());}
        Test.stopTest();
    }
    @IsTest
    static void test_doSaveSales2_04() {
        ProductRequestLineItem lineItem = EX_TestDataUtil.getProductRequestLineItem(true);
        EX_TestDataUtil.baseProductRequest.Order_CHNL_TYPE_Code__c = 'S';
        EX_TestDataUtil.baseProductRequest.CASH_PAYMENT_Amount__c = 1000;
        EX_TestDataUtil.baseProductRequest.CARD_PAYMENT_Amount__c = 0;
        EX_TestDataUtil.baseProductRequestLineItem.CASH_PAYMENT_Amount__c = 1000;
        EX_TestDataUtil.baseProductRequestLineItem.CARD_PAYMENT_Amount__c = 0;
        update EX_TestDataUtil.baseProductRequest;
        update EX_TestDataUtil.baseProductRequestLineItem;
        SR_RESRV_PART__c srrp = new SR_RESRV_PART__c();
        insert srrp;
        ProductRequest pr = EX_TestDataUtil.baseProductRequest;
        pr.SR_RSRV_PART_Id__c = srrp.Id;
        EX_TestDataUtil.getDept(true, 'PH0300');
        Schema.Location loc = EX_TestDataUtil.getLocation(true, 'Location', 'PH0300');
        EX_TestDataUtil.getPrePaymentDetail(true);
        
        EX_TestDataUtil.smartroPaymentRequest.CANCEL_AMT__c = 0;
        update EX_TestDataUtil.smartroPaymentRequest;
                
        Test.startTest();
        
        List<ProductRequest> prList = new List<ProductRequest>();
        prList.add(pr);
        List<ProductRequestLineItem> prliList = new List<ProductRequestLineItem>();
        lineItem.payment_amount__c = 10000;
        prliList.add(lineItem);

        Map<String, List<ProductRequestLineItem>> orderNumberPrLiMap = new Map<String, List<ProductRequestLineItem>>();
        orderNumberPrLiMap.put(pr.Order_Number__c, prliList);

        Map<String, Decimal> orderNumberPaymentAmtMap = new Map<String, Decimal>();
        Map<String, Decimal> orderNumberDiscountAmtMap = new Map<String, Decimal>();

        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('caller','notScreen');
        paramMap.put('prLiList',prliList);
        paramMap.put('orderNumberPrLiMap',orderNumberPrLiMap);
        List<String> orderNumberList = new List<String>{'O3443243'};
        paramMap.put('orderNumberList',orderNumberList);

        List<String> salesFailOrderNumberList = new List<String>();
        paramMap.put('salesFailOrderNumberList',salesFailOrderNumberList);

        paramMap.put('orderNumberPaymentAmtMap', orderNumberPaymentAmtMap);
        paramMap.put('orderNumberDiscountAmtMap', orderNumberDiscountAmtMap);
        try{
            EX_ConsumableUtil.doSaveSales2(paramMap, prList);
        }catch(Exception e){System.debug(e.getMessage());}
        Test.stopTest();
    }
    @IsTest
    static void test_doSaveSales2_05() {
        ProductRequestLineItem lineItem = EX_TestDataUtil.getProductRequestLineItem(true);

        EX_TestDataUtil.baseProductRequest.Order_CHNL_TYPE_Code__c = 'V';
        EX_TestDataUtil.baseProductRequest.CASH_PAYMENT_Amount__c = 1000;
        EX_TestDataUtil.baseProductRequest.CARD_PAYMENT_Amount__c = 0;
        EX_TestDataUtil.baseProductRequestLineItem.CASH_PAYMENT_Amount__c = 1000;
        EX_TestDataUtil.baseProductRequestLineItem.CARD_PAYMENT_Amount__c = 0;
        update EX_TestDataUtil.baseProductRequest;
        update EX_TestDataUtil.baseProductRequestLineItem;
        SR_RESRV_PART__c srrp = new SR_RESRV_PART__c();
        insert srrp;
        ProductRequest pr = EX_TestDataUtil.baseProductRequest;
        pr.SR_RSRV_PART_Id__c = srrp.Id;
        EX_TestDataUtil.getDept(true, 'PH0300');
        Schema.Location loc = EX_TestDataUtil.getLocation(true, 'Location', 'PH0300');
        EX_TestDataUtil.getPrePaymentDetail(true);
        
        EX_TestDataUtil.smartroPaymentRequest.CANCEL_AMT__c = 0;
        update EX_TestDataUtil.smartroPaymentRequest;
                
        Test.startTest();
        
        List<ProductRequest> prList = new List<ProductRequest>();
        prList.add(pr);
        List<ProductRequestLineItem> prliList = new List<ProductRequestLineItem>();
        lineItem.payment_amount__c = 10000;

        prliList.add(lineItem);

        Map<String, List<ProductRequestLineItem>> orderNumberPrLiMap = new Map<String, List<ProductRequestLineItem>>();
        orderNumberPrLiMap.put(pr.Order_Number__c, prliList);

        Map<String, Decimal> orderNumberPaymentAmtMap = new Map<String, Decimal>();
        Map<String, Decimal> orderNumberDiscountAmtMap = new Map<String, Decimal>();

        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('caller','notScreen');
        paramMap.put('prLiList',prliList);
        paramMap.put('orderNumberPrLiMap',orderNumberPrLiMap);
        List<String> orderNumberList = new List<String>{'O3443243'};
        paramMap.put('orderNumberList',orderNumberList);

        List<String> salesFailOrderNumberList = new List<String>();
        paramMap.put('salesFailOrderNumberList',salesFailOrderNumberList);

        paramMap.put('orderNumberPaymentAmtMap', orderNumberPaymentAmtMap);
        paramMap.put('orderNumberDiscountAmtMap', orderNumberDiscountAmtMap);
        try{
            EX_ConsumableUtil.doSaveSales2(paramMap, prList);
        }catch(Exception e){System.debug(e.getMessage());}
        Test.stopTest();
    }

    @IsTest
    static void test_doSaveSales2_06_exchangeOrder() {
        Test.startTest();
        TriggerHandler.bypass('ProductRequestLineItem_tr');
    
        ProductRequestLineItem lineItem = EX_TestDataUtil.getProductRequestLineItem(true);
        EX_TestDataUtil.baseProductRequest.Order_CHNL_TYPE_Code__c = 'V';
        EX_TestDataUtil.baseProductRequest.CASH_PAYMENT_Amount__c = 1000;
        EX_TestDataUtil.baseProductRequest.CARD_PAYMENT_Amount__c = 0;
        lineItem.CASH_PAYMENT_Amount__c = 1000;
        lineItem.CARD_PAYMENT_Amount__c = 0;
        lineItem.Payment_Amount__c = 1000;
        lineItem.Consumables_Order_Status__c = '070';
        lineItem.SALE_Quantity__c = 1;
        update EX_TestDataUtil.baseProductRequest;
        update lineItem;

        lineItem.CASH_PAYMENT_Amount__c = 1000;
        lineItem.CARD_PAYMENT_Amount__c = 0;
        lineItem.Payment_Amount__c = 1000;
        update lineItem;   

        SR_RESRV_PART__c srrp = new SR_RESRV_PART__c();
        insert srrp;
        ProductRequest pr = EX_TestDataUtil.baseProductRequest;
        pr.SR_RSRV_PART_Id__c = srrp.Id;
        EX_TestDataUtil.getDept(true, 'PH0300');
        Schema.Location loc = EX_TestDataUtil.getLocation(true, 'Location', 'PH0300');
        EX_TestDataUtil.getPrePaymentDetail(true);

        EX_TestDataUtil.smartroPaymentRequest.CANCEL_AMT__c = 0;
        update EX_TestDataUtil.smartroPaymentRequest;

        productrequestlineitem lineItem2 = EX_TestDataUtil.getProductRequestLineItem2(true);
        EX_TestDataUtil.baseProductRequest2.Order_CHNL_TYPE_Code__c = 'V';
        EX_TestDataUtil.baseProductRequest2.CASH_PAYMENT_Amount__c = 1000;
        EX_TestDataUtil.baseProductRequest2.CARD_PAYMENT_Amount__c = 0;
        EX_TestDataUtil.baseProductRequest2.Order_Number__c = 'O3443244';
        lineItem2.CASH_PAYMENT_Amount__c = 1000;
        lineItem2.CARD_PAYMENT_Amount__c = 0;
        lineItem2.BASIS_Order_Item_Id__c = lineItem.Id;
        lineItem2.Order_Number__c = 'O3443244';
        lineItem2.Consumables_Order_Status__c = '070';
        lineItem2.QuantityRequested = 1;
        update EX_TestDataUtil.baseProductRequest2;
        update lineItem2;

        lineItem2.CASH_PAYMENT_Amount__c = 1000;
        lineItem2.CARD_PAYMENT_Amount__c = 0;
        lineItem2.BASIS_Order_Item_Id__c = lineItem.Id;
        update lineItem2;        
        
        ProductRequest pr2 = EX_TestDataUtil.baseProductRequest2;

        
        
        List<ProductRequest> prList = new List<ProductRequest>();
        prList.add(pr2);
        List<ProductRequestLineItem> prliList = new List<ProductRequestLineItem>();
        lineItem2.payment_amount__c = 10000;
        prliList.add(lineItem2);

        Map<String, List<ProductRequestLineItem>> orderNumberPrLiMap = new Map<String, List<ProductRequestLineItem>>();
        orderNumberPrLiMap.put(pr2.Order_Number__c, prliList);

        EX_TestDataUtil.srSale.Order_Number__c = 'O3443243';
        update EX_TestDataUtil.srSale;

        SR_PAYMENT_BASIS__c basis = new SR_PAYMENT_BASIS__c(SR_SALE_ID__c = EX_TestDataUtil.srSale.Id, BASIS_NO__c = EX_TestDataUtil.baseProductRequest.Order_Number__c, RED_BLACK__c = 'B', BASIS_DT__c = Date.newInstance(2023, 1, 25), SETTLE_AMT__c = 1000, BIZ_ORIGIN_TYPE__c = 'C');
        insert basis;
        insert new SR_AR_CONFIRM__c(SR_PAYMENT_BASIS_ID__c = basis.Id, DEPOSIT_TYPE__c = 'A', INVOICE_ISSUE_TYPE__c = 'B', DEPOSIT_AMT__c = 1000);

        Map<String, Decimal> orderNumberPaymentAmtMap = new Map<String, Decimal>();
        Map<String, Decimal> orderNumberDiscountAmtMap = new Map<String, Decimal>();

        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('caller','notScreen');
        paramMap.put('prLiList',prliList);
        paramMap.put('orderNumberPrLiMap',orderNumberPrLiMap);
        List<String> orderNumberList = new List<String>{'O3443244'};
        paramMap.put('orderNumberList',orderNumberList);

        List<String> salesFailOrderNumberList = new List<String>();
        paramMap.put('salesFailOrderNumberList',salesFailOrderNumberList);

        paramMap.put('orderNumberPaymentAmtMap', orderNumberPaymentAmtMap);
        paramMap.put('orderNumberDiscountAmtMap', orderNumberDiscountAmtMap);
        try{
            EX_ConsumableUtil.doSaveSales2(paramMap, prList);
        }catch(Exception e){System.debug(e.getMessage());}
        TriggerHandler.clearBypass('ProductRequestLineItem_tr');
        Test.stopTest();
    }

    @IsTest
    static void test_doSaveSales2_07() {
        ProductRequestLineItem lineItem = EX_TestDataUtil.getProductRequestLineItem(true);
        ProductRequestLineItem lineItem2 = EX_TestDataUtil.getProductRequestLineItem(false).clone();
        lineItem2.Payment_Amount__c = 1000;
        lineItem2.SALE_Quantity__c = 1;
        insert lineItem2;
        EX_TestDataUtil.baseProductRequest.Order_CHNL_TYPE_Code__c = 'V';
        EX_TestDataUtil.baseProductRequest.CASH_PAYMENT_Amount__c = 1000;
        EX_TestDataUtil.baseProductRequest.CARD_PAYMENT_Amount__c = 0;
        EX_TestDataUtil.baseProductRequestLineItem.CASH_PAYMENT_Amount__c = 1000;
        EX_TestDataUtil.baseProductRequestLineItem.CARD_PAYMENT_Amount__c = 0;
        EX_TestDataUtil.baseProductRequestLineItem.BASIS_Order_Item_Id__c = lineItem2.Id;
        EX_TestDataUtil.baseProductRequestLineItem.QuantityRequested = 1;
        EX_TestDataUtil.baseProductRequestLineItem.PAYMENT_COMPLETED_DTM__c = System.now();
        update EX_TestDataUtil.baseProductRequest;
        update EX_TestDataUtil.baseProductRequestLineItem;
        SR_RESRV_PART__c srrp = new SR_RESRV_PART__c();
        insert srrp;
        ProductRequest pr = EX_TestDataUtil.baseProductRequest;
        pr.SR_RSRV_PART_Id__c = srrp.Id;
        EX_TestDataUtil.getDept(true, 'PH0300');
        Schema.Location loc = EX_TestDataUtil.getLocation(true, 'Location', 'PH0300');
        EX_TestDataUtil.getPrePaymentDetail(true);
        
        EX_TestDataUtil.smartroPaymentRequest.CANCEL_AMT__c = 0;
        update EX_TestDataUtil.smartroPaymentRequest;
                
        Test.startTest();
        
        List<ProductRequest> prList = new List<ProductRequest>();
        prList.add(pr);
        List<ProductRequestLineItem> prliList = new List<ProductRequestLineItem>();
        lineItem.payment_amount__c = 1000;
        lineItem.RecordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();

        prliList.add(lineItem);

        Map<String, List<ProductRequestLineItem>> orderNumberPrLiMap = new Map<String, List<ProductRequestLineItem>>();
        orderNumberPrLiMap.put(pr.Order_Number__c, prliList);

        Map<String, Decimal> orderNumberPaymentAmtMap = new Map<String, Decimal>();
        Map<String, Decimal> orderNumberDiscountAmtMap = new Map<String, Decimal>();

        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('caller','notScreen');
        paramMap.put('prLiList',prliList);
        paramMap.put('orderNumberPrLiMap',orderNumberPrLiMap);
        List<String> orderNumberList = new List<String>{'O3443243'};
        paramMap.put('orderNumberList',orderNumberList);

        List<String> salesFailOrderNumberList = new List<String>();
        paramMap.put('salesFailOrderNumberList',salesFailOrderNumberList);

        paramMap.put('orderNumberPaymentAmtMap', orderNumberPaymentAmtMap);
        paramMap.put('orderNumberDiscountAmtMap', orderNumberDiscountAmtMap);
        try{
            EX_ConsumableUtil.doSaveSales2(paramMap, prList);
        }catch(Exception e){System.debug(e.getMessage());}
        Test.stopTest();
    }

    @IsTest
    static void test_doSaveSales2_08() {
    Test.startTest();
    TriggerHandler.bypass('productRequest_tr');
    
    ProductRequestLineItem lineItem = EX_TestDataUtil.getProductRequestLineItem(true);
    ProductRequestLineItem lineItem2 = EX_TestDataUtil.getProductRequestLineItem(false).clone();

    EX_TestDataUtil.baseProductRequest.Order_CHNL_TYPE_Code__c = 'B';
    EX_TestDataUtil.baseProductRequest.CASH_PAYMENT_Amount__c = 1000;
    EX_TestDataUtil.baseProductRequest.CARD_PAYMENT_Amount__c = 0;
    update EX_TestDataUtil.baseProductRequest;

    SR_RESRV_PART__c srrp = new SR_RESRV_PART__c();
    insert srrp;

    
    ProductRequest pr2 = EX_TestDataUtil.baseProductRequest.clone();
    pr2.SR_RSRV_PART_Id__c = srrp.Id;
    pr2.Order_CHNL_TYPE_Code__c = 'B';
    pr2.Consumables_Business_Type_Code__c = 'Order';
    insert pr2;
    System.debug('=> ??' + pr2.SR_RSRV_PART_Id__c);


    EX_TestDataUtil.getLocation(true, 'Location', 'PH0300');
    EX_TestDataUtil.getPrePaymentDetail(true);
    
    SR_PAYMENT_BASIS__c spb = new SR_PAYMENT_BASIS__c();
    spb.SR_SALE_ID__c = EX_TestDataUtil.srSale.Id;
    spb.BASIS_NO__c = EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c;
    insert spb;

    SR_AR_CONFIRM__c sac = new SR_AR_CONFIRM__c();
    sac.SR_PAYMENT_BASIS_ID__c = spb.Id;
    insert sac;


    lineItem.SALE_Number__c = 'test123';
    lineItem.Payment_Amount__c = 1000;
    lineItem.SALE_Quantity__c = 1;
    update lineItem;

    System.debug('lineItem.Id => ??' + lineItem.Id);
    System.debug('lineItem.Payment_Amount__c => ??' + lineItem.Payment_Amount__c);
    System.debug('lineItem.SALE_Quantity__c => ??' + lineItem.SALE_Quantity__c);

    EX_TestDataUtil.getProductTransfer(true);

    lineItem2.CASH_PAYMENT_Amount__c = 1000;
    lineItem2.CARD_PAYMENT_Amount__c = 0;
    lineItem2.BASIS_Order_Item_Id__c = lineItem.Id;
    lineItem2.QuantityRequested = 2;
    lineItem2.PAYMENT_COMPLETED_DTM__c = System.now();
    lineItem2.SR_RESRV_PART_Id__c = srrp.Id;
    lineItem2.Payment_Amount__c = 1000;
    lineItem2.SALE_Quantity__c = 1;
    lineItem2.ParentId = pr2.Id;
    lineItem2.ENDP_RSV_Quantity__c = 1;
    insert lineItem2;
    
    System.debug('BASIS ORDER ITEM ID => ??' + lineItem2.BASIS_Order_Item_Id__c);
    
    
    
    
    List<ProductRequest> prList = new List<ProductRequest>();
    prList.add(pr2);
    List<ProductRequestLineItem> prliList = new List<ProductRequestLineItem>();
    lineItem2.RecordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();

    prliList.add(lineItem2);

    Map<String, List<ProductRequestLineItem>> orderNumberPrLiMap = new Map<String, List<ProductRequestLineItem>>();
    orderNumberPrLiMap.put(pr2.Order_Number__c, prliList);

    Map<String, Decimal> orderNumberPaymentAmtMap = new Map<String, Decimal>();
    Map<String, Decimal> orderNumberDiscountAmtMap = new Map<String, Decimal>();

    Map<String, Object> paramMap = new Map<String, Object>();
    paramMap.put('caller','notScreen');
    paramMap.put('prLiList',prliList);
    paramMap.put('orderNumberPrLiMap',orderNumberPrLiMap);
    List<String> orderNumberList = new List<String>{'O3443243'};
    paramMap.put('orderNumberList',orderNumberList);

    List<String> salesFailOrderNumberList = new List<String>();
    paramMap.put('salesFailOrderNumberList',salesFailOrderNumberList);

    paramMap.put('orderNumberPaymentAmtMap', orderNumberPaymentAmtMap);
    paramMap.put('orderNumberDiscountAmtMap', orderNumberDiscountAmtMap);


    try{
        EX_ConsumableUtil.doSaveSales2(paramMap, prList);
    }catch(Exception e){System.debug(e.getMessage());}
    Test.stopTest();
}

    @IsTest
    static void test_preWorkSaveSales() {
        List<String> targetOrderNumberList = new List<String>();
        Test.startTest();
        ProductRequest pr = EX_TestDataUtil.getProductRequest(false);
        pr.SR_SALE__c = null;
        pr.SALE_Number__c = null;
        insert pr;
        ProductRequestLineItem prli = EX_TestDataUtil.getProductRequestLineItem(false);
        prli.Consumables_Business_Type_Code__c = 'Order';
        prli.Consumables_Order_Status__c = '030';
        prli.isMig__c = false;
        prli.ParentId = pr.Id;
        insert prli;
        targetOrderNumberList.add(pr.Order_Number__c);
        EX_ConsumableUtil.preWorkSaveSales(targetOrderNumberList);
        Test.stopTest();
    }

    @IsTest
    static void test_reCheckAvailableQty_01() {
        Test.startTest();
        EX_TestDataUtil.getProductRequestLineItem(true);
        EX_TestDataUtil.getProductItem2(true);

        EX_TestDataUtil.baseLocation2.name = System.Label.EX_Location;
        EX_TestDataUtil.baseLocation2.LocationType = 'Warehouse';
        update EX_TestDataUtil.baseLocation2;
        
        List<ProductItem> pi = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem WHERE QuantityOnHand != 0 LIMIT 1];
        List<EX_SuppliesController.ItemTable> standardOrderDataList = new List<EX_SuppliesController.ItemTable>();
        List<EX_SuppliesController.ItemTable> soldOutOrderDataList = new List<EX_SuppliesController.ItemTable>();

        List<ProductRequestLineItem> prli = [SELECT Id, Order_Number__c, BASIS_Number__c, ParentId FROM ProductRequestLineItem LIMIT 1];
        EX_SuppliesController.ItemTable it = new EX_SuppliesController.ItemTable();
        it.ProductCode = pi[0].Product2.ProductCode;
        it.sProductId = pi[0].Product2Id;
        it.sLocationId = pi[0].LocationId;
        it.QTY = 1;
        it.Price = 30000;
        it.PromotionPrice = 25000;
        it.ParentId = prli[0].ParentId;
        standardOrderDataList.add(it);

        //  EX_SuppliesController.ItemTable it3 = new EX_SuppliesController.ItemTable();
        //  it3.ProductCode = pi[0].Product2.ProductCode;
        //  it3.sProductId = pi[0].Product2Id;
        //  it3.sLocationId = pi[0].LocationId;
        //  it3.QTY = 1;
        //  it3.Price = 3000;
        //  it3.PromotionPrice = 250000;
        //  it3.DiscountAmount = 100;
        //  it3.discountType = '프로모션';
        //  standardOrderDataList.add(it3);
        //  soldOutOrderDataList.add(it3);

        try{
            EX_ConsumableUtil.reCheckAvailableQty(standardOrderDataList,soldOutOrderDataList);
        }catch(Exception e){System.debug(e.getMessage());}
        Test.stopTest();
    }


    @IsTest
    static void test_doReturnConfirm() {
        ReturnOrderLineItem orderItem = EX_TestDataUtil.getReturnOrderLineItem(false);
        orderItem.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
        orderItem.Consumables_Order_YN__c = TRUE;
        orderItem.Order_CUST_Id__c = EX_TestDataUtil.getContact(true).Id;
        insert orderItem;

        ReturnOrder returnOrder = [select id,Consumables_Order_YN__c from ReturnOrder Limit 1];
        returnOrder.Consumables_Order_YN__c = TRUE;
        returnOrder.RecordTypeId = Schema.SObjectType.ReturnOrder.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
        update returnOrder;

        ReturnOrderLineItem orderItem2 = EX_TestDataUtil.getReturnOrderLineItem(false);
        orderItem2.Id = null;
        orderItem2.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
        orderItem2.Consumables_Order_YN__c = TRUE;
        insert orderItem2;

        String returnOrderId = orderItem2.ReturnOrderId;

        ReturnOrder returnOrder2 = [select id,Consumables_Order_YN__c from ReturnOrder where id = :returnOrderId Limit 1];
        returnOrder2.Consumables_Order_YN__c = TRUE;
        returnOrder2.RecordTypeId = Schema.SObjectType.ReturnOrder.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
        returnORder2.RETURN_CARD_PAYMENT_Amount__c = 100;
        returnORder2.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c = 100;
        returnORder2.RETURN_POINT_Amount__c = 100;
        update returnOrder2;

        Schema.Location loc = EX_TestDataUtil.getLocation(true, 'Location', 'PH0300');
        EX_TestDataUtil.getPrePaymentDetail(true);
        Test.startTest();
        try{
            EX_ConsumableUtil.doReturnConfirm(new List<String>{orderItem.Id});
        }catch(Exception e){System.debug(e.getMessage());}
        Test.stopTest();
    }

    @IsTest
    static void test_doReturnConfirm_1() {
        Test.startTest();
        
        ReturnOrderLineItem orderItem = EX_TestDataUtil.getReturnOrderLineItem(false);
        orderItem.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
        orderItem.Consumables_Order_YN__c = TRUE;
        orderItem.Order_CUST_Id__c = EX_TestDataUtil.getContact(true).Id;
        orderItem.REFUND_Complete_YN__c = FALSE;
        orderItem.Order_CHNL_TYPE_Code__c = 'V';
        insert orderItem;

        SR_SALE__c ss = EX_TestDataUtil.getSrSale(true);
        SR_PAYMENT_BASIS__c spb = new SR_PAYMENT_BASIS__c();
        spb.SR_SALE_ID__c = ss.Id;
        spb.RED_BLACK__c = 'B';
        spb.BASIS_NO__c = EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c;
        insert spb;

        SR_AR_CONFIRM__c sac = new SR_AR_CONFIRM__c();
        sac.LAST_SR_AR_CONFIRM_ID__c = null;
        sac.SR_PAYMENT_BASIS_ID__c = spb.Id;
        insert sac;

        EX_TestDataUtil.baseProductRequest.SALE_Number__c = 'testNum123';
        EX_TestDataUtil.baseProductRequest.SR_SALE__c = ss.Id;
        update EX_TestDataUtil.baseProductRequest;
        EX_TestDataUtil.baseProductRequestLineItem.POINT_TRX_ID__c = '1000006623527';
        update EX_TestDataUtil.baseProductRequestLineItem;

        ReturnOrderLineItem roli = [SELECT Id, RecordType.Name, Consumables_Order_YN__c, REFUND_Complete_YN__c,Order_CHNL_TYPE_Code__c FROM ReturnOrderLineItem WHERE Id =: orderItem.Id];

        ReturnOrder returnOrder = [select id,Consumables_Order_YN__c from ReturnOrder Limit 1];
        returnOrder.Consumables_Order_YN__c = TRUE;
        returnOrder.RecordTypeId = Schema.SObjectType.ReturnOrder.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
        update returnOrder;

        ReturnOrderLineItem orderItem2 = EX_TestDataUtil.getReturnOrderLineItem(false);
        orderItem2.Id = null;
        orderItem2.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
        orderItem2.Consumables_Order_YN__c = TRUE;
        insert orderItem2;

        String returnOrderId = orderItem2.ReturnOrderId;

        ReturnOrder returnOrder2 = [select id,Consumables_Order_YN__c from ReturnOrder where id = :returnOrderId Limit 1];
        returnOrder2.Consumables_Order_YN__c = TRUE;
        returnOrder2.RecordTypeId = Schema.SObjectType.ReturnOrder.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
        returnORder2.RETURN_CARD_PAYMENT_Amount__c = 100;
        returnORder2.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c = 100;
        returnORder2.RETURN_POINT_Amount__c = 100;
        update returnOrder2;

        Schema.Location loc = EX_TestDataUtil.getLocation(true, 'Location', 'PH0300');
        EX_TestDataUtil.getPrePaymentDetail(true);

        
        try{
            EX_ConsumableUtil.doReturnConfirm(new List<String>{roli.Id});
        }catch(Exception e){System.debug(e.getMessage());}
        Test.stopTest();
    }

    @IsTest
    static void test_LineItemWrapper() {
        Test.startTest();
        ProductRequestLineItem lineItem = EX_TestDataUtil.getProductRequestLineItem(true);
        List<EX_ConsumableUtil.LineItemWrapper> line = new List<EX_ConsumableUtil.LineItemWrapper>{new EX_ConsumableUtil.LineItemWrapper(lineItem), new EX_ConsumableUtil.LineItemWrapper(lineItem)};
        try{
            line.sort();
        }catch(Exception e){System.debug(e.getMessage());}
        Test.stopTest();
    }

    @IsTest
    static void test_calculateWorkingDays() {
        Test.startTest();
        EX_ConsumableUtil.calculateWorkingDays('Code', Date.today(),10);
        Test.stopTest();
    }


    @IsTest
    static void test_getDateWithNull() {
        Test.startTest();
        EX_ConsumableUtil.getDateWithNull(System.today());
        Test.stopTest();
    }

    @IsTest
    static void test_getDatetimeWithNull() {
        Test.startTest();
        EX_ConsumableUtil.getDatetimeWithNull(System.now());
        Test.stopTest();
    }

    @IsTest
    static void test_getStringNotNull() {
        Test.startTest();
        EX_ConsumableUtil.getStringNotNull('string');
        Test.stopTest();
    }

    @IsTest
    static void test_getIntegerNotNull() {
        Test.startTest();
        EX_ConsumableUtil.getIntegerNotNull(1);
        Test.stopTest();
    }

    @IsTest
    static void test_getDoubleNotNull() {
        Test.startTest();
        EX_ConsumableUtil.getDoubleNotNull(1);
        Test.stopTest();
    }

    @IsTest
    static void test_getDecimalNotNull() {
        Test.startTest();
        EX_ConsumableUtil.getDecimalNotNull(1);
        Test.stopTest();
    }

    @IsTest
    static void test_getConsumableSiteId() {
        Test.startTest();
        EX_ConsumableUtil.getConsumableSiteId();
        EX_ConsumableUtil.getCarePlusWareSiteId();
        Test.stopTest();
    }

    @IsTest
    static void test_getUserInfo() {
        update new User(Id = UserInfo.getUserId(), DEPT_CODE__c = 'PH8002');
        SM_DEPT__c dept = EX_TestDataUtil.getDept(true,'PH8002');
        insert new ServiceResource(Name = UserInfo.getLastName()
                                , RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('CNSL').getRecordTypeId()
                                , RelatedRecordId = UserInfo.getUserId()
                                , IsActive = true
                                , SM_DEPT__c = dept.Id
                                , SM_DEPT_CENTER__c = dept.Id
                                , JOB_TYPE__c = 'A70');

        Test.startTest();
        EX_ConsumableUtil.getUserInfo(UserInfo.getUserId());
        Test.stopTest();
    }

    @IsTest
    static void test_strToCurrencyWon() {
        Test.startTest();
        EX_ConsumableUtil.strToCurrencyWon('1000000');
        Test.stopTest();
    }

    @IsTest
    static void test_convertDate_01() {
        Test.startTest();
        Datetime mon = DateTime.newInstance(2023, 12, 25, 3, 3, 3);
        EX_ConsumableUtil.convertDate(mon);
        Test.stopTest();
    }
    @IsTest
    static void test_convertDate_02() {
        Test.startTest();
        Datetime tue = DateTime.newInstance(2023, 12, 26, 3, 3, 3);
        EX_ConsumableUtil.convertDate(tue);
        Test.stopTest();
    }
    @IsTest
    static void test_convertDate_03() {
        Test.startTest();
        Datetime wed = DateTime.newInstance(2023, 12, 27, 3, 3, 3);
        EX_ConsumableUtil.convertDate(wed);
        Test.stopTest();
    }
    @IsTest
    static void test_convertDate_04() {
        Test.startTest();
        Datetime thu = DateTime.newInstance(2023, 12, 28, 3, 3, 3);
        EX_ConsumableUtil.convertDate(thu);
        Test.stopTest();
    }
    @IsTest
    static void test_convertDate_05() {
        Test.startTest();
        Datetime fri = DateTime.newInstance(2023, 12, 29, 3, 3, 3);
        EX_ConsumableUtil.convertDate(fri);
        Test.stopTest();
    }
    @IsTest
    static void test_convertDate_06() {
        Test.startTest();
        Datetime sat = DateTime.newInstance(2023, 12, 30, 3, 3, 3);
        EX_ConsumableUtil.convertDate(sat);
        Test.stopTest();
    }
    @IsTest
    static void test_convertDate_07() {
        Test.startTest();
        Datetime sun = DateTime.newInstance(2023, 12, 31, 3, 3, 3);
        EX_ConsumableUtil.convertDate(sun);
        Test.stopTest();
    }

    @IsTest
    static void test_getCarePlusWareHouseId() {
        Test.startTest();
        EX_ConsumableUtil.getCarePlusWareHouseId();
        Test.stopTest();
    }

    @IsTest
    static void test_getWorkingDays() {
        Test.startTest();
        EX_ConsumableUtil.getWorkingDays('deptCode', System.today(), 1);
        Test.stopTest();
    }

    @IsTest
    static void test_createNotExistProductItem() {
        EX_TestDataUtil.getLocation(false, 'Location', 'PH8002');
        EX_TestDataUtil.baseLocation.LocationType = 'Warehouse';
        EX_TestDataUtil.baseLocation.Name = System.Label.EX_Location;
        EX_TestDataUtil.baseLocation.DONG_No__c = '99';
        EX_TestDataUtil.baseLocation.RACK_NO__c = 'A';
        EX_TestDataUtil.baseLocation.ROW_NO__c = '9';
        EX_TestDataUtil.baseLocation.BOX_NO__c = '99';
        insert EX_TestDataUtil.baseLocation;

        Schema.Location loc = EX_TestDataUtil.baseLocation.clone();
        loc.RecordTypeId = SObjectType.Location.getRecordTypeInfosByDeveloperName().get('DIV').getRecordTypeId();
        loc.Name = '99A998';
        insert loc;

        EX_TestDataUtil.getProductItem(true);
        Test.startTest();
        EX_ConsumableUtil.createNotExistProductItem(new Set<String>{EX_TestDataUtil.baseProduct.Id});
        Test.stopTest();
    }

@IsTest(SeeAllData=true)
static void test_doSendChatterFeed() {
    
    List<CollaborationGroup> cgList = [SELECT Id FROM CollaborationGroup WHERE Name = '소모품 운영 담당'];
    system.debug('삭제전 cgList : '+cgList);
    delete cgList;
    system.debug('삭제후 쿼리 : '+[SELECT Id FROM CollaborationGroup WHERE Name = '소모품 운영 담당']);

    CollaborationGroup cg = new CollaborationGroup();
    cg.Name = '소모품 운영 담당';
    cg.Description = '소모품 운영 담당';
    cg.CollaborationType = 'Public';
    insert cg;

    SR_ONLINE_AUTO_SALE_EXC__c soase = new SR_ONLINE_AUTO_SALE_EXC__c();
    soase.ORDER_NO__c = 'test';
    soase.ErrorType__c = 'Reserve';
    soase.SourceRecordId__c = 'test';
    insert soase;

    Set<String> targetIds = new Set<String>();
    targetIds.add(soase.Id);
    Test.startTest();
    System.debug('이거 없어? :::' + targetIds);
    EX_ConsumableUtil.doSendChatterFeed(targetIds);
    Test.stopTest();
}

@isTest
static void test_preWorkReturnConfirm(){
    Test.startTest();
    EX_TestDataUtil.getReturnOrderLineItem(false);
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '120';
    EX_TestDataUtil.baseReturnOrderLineItem.COLLECTION_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrderLineItem.REFUND_Complete_YN__c = FALSE;
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Business_Type_Code__c = 'Return';
    EX_TestDataUtil.baseReturnOrderLineItem.Return_Order_CONFIRM_DTM__c = null;
    EX_TestDataUtil.baseReturnOrderLineItem.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
    EX_TestDataUtil.getReturnOrderLineItem(true);
    EX_TestDataUtil.baseReturnOrder.Consumables_Order_YN__c = TRUE;
    update EX_TestDataUtil.baseReturnOrder;

    EX_TestDataUtil.baseProductRequest.SR_SALE__c = EX_TestDataUtil.getSrSale(true).Id;
    EX_TestDataUtil.baseProductRequest.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseProductRequest.Consumables_Order_USE_YN__c = TRUE;
    EX_TestDataUtil.baseProductRequest.SALE_Number__c = EX_TestDataUtil.baseProductRequest.Order_Number__c;
    update EX_TestDataUtil.baseProductRequest;

    SR_PAYMENT_BASIS__c basis = new SR_PAYMENT_BASIS__c(SR_SALE_ID__c = EX_TestDataUtil.srSale.Id, BASIS_NO__c = EX_TestDataUtil.baseProductRequest.Order_Number__c, RED_BLACK__c = 'B', BASIS_DT__c = Date.newInstance(2023, 1, 25), SETTLE_AMT__c = 1000, BIZ_ORIGIN_TYPE__c = 'B');
    insert basis;
    insert new SR_AR_CONFIRM__c(SR_PAYMENT_BASIS_ID__c = basis.Id, DEPOSIT_TYPE__c = 'A', INVOICE_ISSUE_TYPE__c = 'B', DEPOSIT_AMT__c = 1000);
    EX_TestDataUtil.getPrePaymentDetail(true);    
    // Test.startTest();
    EX_ConsumableUtil.preWorkReturnConfirm(null);
    Test.stopTest();
}

@isTest
static void test_doReturnOrderConfirm2(){
    Test.startTest();

    EX_TestDataUtil.getReturnOrderLineItem(false);
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '120';
    EX_TestDataUtil.baseReturnOrderLineItem.COLLECTION_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrderLineItem.REFUND_Complete_YN__c = FALSE;
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Business_Type_Code__c = 'Return';
    EX_TestDataUtil.baseReturnOrderLineItem.Return_Order_CONFIRM_DTM__c = null;
    EX_TestDataUtil.baseReturnOrderLineItem.Order_CHNL_TYPE_Code__c = 'BestShop';
    EX_TestDataUtil.baseReturnOrderLineItem.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
    EX_TestDataUtil.getReturnOrderLineItem(true);
    EX_TestDataUtil.baseReturnOrder.Consumables_Order_YN__c = TRUE;
    update EX_TestDataUtil.baseReturnOrder;

    ProductRequest pr = new ProductRequest();
    pr.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    pr.Order_Number__c = 'O3443243';
    pr.Department_Code__c = EX_TestDataUtil.getDept(true, null).DEPT_CODE__c;
    insert pr;
    ProductRequestLineItem prli = new ProductRequestLineItem();
    prli.recordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    prli.Order_Number__c = 'O3443243';
    prli.parentid = pr.id;

    prli.AccountId = EX_TestDataUtil.getAccount(true).Id;
    prli.ASC_Price__c = 30000;
    prli.Order_SEQ__c = 1;
    prli.CANCEL_STATUS__c = false;
    prli.CASH_DEPOSIT_YN__c = false;
    prli.CASH_PAYMENT_Amount__c = 2000;
    prli.CARD_PAYMENT_Amount__c = 500;
    prli.POINT_Amount__c = 500;
    prli.CJ_SHIPPED_STOP_YN__c = false;
    prli.Consumables_Business_Type_Code__c = 'Order';
    prli.Consumables_Order_Status__c = '002';
    prli.Consumables_Order_Class_Code__c = 'PO';
    prli.Consumables_Order_YN__c = true;
    prli.CONSUMER_Price__c = 30000;
    prli.SALE_Amount__c = 30000;
    prli.Department_Code__c = pr.Department_Code__c;
    prli.ENDP_Code__c = 'DMZ';
    prli.RSRV_Number__c = '24423';
    prli.RSRV_SEQ__c = 1;
    prli.Exchange_Quantity__c = 0;
    prli.ENDP_RSV_Quantity__c = 1;
    prli.SALE_Quantity__c = 1;
    prli.QuantityRequested = 1;
    prli.Employees_Discount_Amount__c = 0;
    prli.VIP_Discount_Amount__c = 0;
    prli.COUPON_Discount_Amount__c = 50;
    prli.GSCS_Order_Number__c = '4231';
    prli.Order_CHNL_TYPE_Code__c = 'B';
    prli.Product2Id = EX_TestDataUtil.createProduct().Id;
    prli.PART_NO__c = EX_TestDataUtil.createProduct().Name;
    prli.BASIS_Parts_Number__c = EX_TestDataUtil.createProduct().ProductCode;
    prli.DestinationLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;
    prli.SourceLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;

    insert prli;

    EX_TestDataUtil.baseProductRequest.SR_SALE__c = EX_TestDataUtil.getSrSale(true).Id;
    EX_TestDataUtil.srSale.SALE_Number__c = 'A000999999';

    update EX_TestDataUtil.srSale;
    
    

    EX_TestDataUtil.baseProductRequest.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseProductRequest.Consumables_Order_USE_YN__c = TRUE;
    EX_TestDataUtil.baseProductRequest.SALE_Number__c = 'A000999999';
    update EX_TestDataUtil.baseProductRequest;

    SR_PAYMENT_BASIS__c basis = new SR_PAYMENT_BASIS__c(SR_SALE_ID__c = EX_TestDataUtil.srSale.Id, BASIS_NO__c = EX_TestDataUtil.baseProductRequest.Order_Number__c, RED_BLACK__c = 'B', BASIS_DT__c = Date.newInstance(2023, 1, 25), SETTLE_AMT__c = 1000, BIZ_ORIGIN_TYPE__c = 'B');
    insert basis;

    insert new SR_AR_CONFIRM__c(SR_PAYMENT_BASIS_ID__c = basis.Id, DEPOSIT_TYPE__c = 'A', INVOICE_ISSUE_TYPE__c = 'B', DEPOSIT_AMT__c = 1000);
    EX_TestDataUtil.getPrePaymentDetail(true);
    Map<String, Object> paramMap2 = new Map<String, Object>();
    paramMap2 = EX_ConsumableUtil.preWorkReturnConfirm(null);
    
    List<ReturnOrder> roList = (List<ReturnOrder>)paramMap2.get('roList');
    Test.stopTest();
}

@isTest
static void test_doReturnOrderConfirm2_02(){
    Test.startTest();

    EX_TestDataUtil.getReturnOrderLineItem(false);
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '120';
    EX_TestDataUtil.baseReturnOrderLineItem.COLLECTION_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrderLineItem.REFUND_Complete_YN__c = FALSE;
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Business_Type_Code__c = 'Return';
    EX_TestDataUtil.baseReturnOrderLineItem.Return_Order_CONFIRM_DTM__c = null;
    EX_TestDataUtil.baseReturnOrderLineItem.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
    EX_TestDataUtil.getReturnOrderLineItem(true);
    EX_TestDataUtil.baseReturnOrder.Consumables_Order_YN__c = TRUE;
    update EX_TestDataUtil.baseReturnOrder;

    ProductRequest pr = new ProductRequest();
    pr.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    pr.Order_Number__c = 'O3443243';
    pr.Department_Code__c = EX_TestDataUtil.getDept(true, null).DEPT_CODE__c;
    insert pr;
    ProductRequestLineItem prli = new ProductRequestLineItem();
    prli.recordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    prli.Order_Number__c = 'O3443243';
    prli.parentid = pr.id;

    prli.AccountId = EX_TestDataUtil.getAccount(true).Id;
    prli.ASC_Price__c = 30000;
    prli.Order_SEQ__c = 1;
    prli.CANCEL_STATUS__c = false;
    prli.CASH_DEPOSIT_YN__c = true;
    prli.CASH_PAYMENT_Amount__c = 2500;
    prli.CARD_PAYMENT_Amount__c = 0;
    prli.POINT_Amount__c = 500;
    prli.CJ_SHIPPED_STOP_YN__c = false;
    prli.Consumables_Business_Type_Code__c = 'Order';
    prli.Consumables_Order_Status__c = '002';
    prli.Consumables_Order_Class_Code__c = 'PO';
    prli.Consumables_Order_YN__c = true;
    prli.CONSUMER_Price__c = 30000;
    prli.SALE_Amount__c = 30000;
    prli.Department_Code__c = pr.Department_Code__c;
    prli.ENDP_Code__c = 'DMZ';
    prli.RSRV_Number__c = '24423';
    prli.RSRV_SEQ__c = 1;
    prli.Exchange_Quantity__c = 0;
    prli.ENDP_RSV_Quantity__c = 1;
    prli.SALE_Quantity__c = 1;
    prli.QuantityRequested = 1;
    prli.Employees_Discount_Amount__c = 0;
    prli.VIP_Discount_Amount__c = 0;
    prli.COUPON_Discount_Amount__c = 50;
    prli.GSCS_Order_Number__c = '4231';
    prli.Order_CHNL_TYPE_Code__c = 'B';
    prli.Product2Id = EX_TestDataUtil.createProduct().Id;
    prli.PART_NO__c = EX_TestDataUtil.createProduct().Name;
    prli.BASIS_Parts_Number__c = EX_TestDataUtil.createProduct().ProductCode;
    prli.DestinationLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;
    prli.SourceLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;
    prli.POINT_TRX_ID__c = '1000006623527';

    insert prli;

    EX_TestDataUtil.baseProductRequest.SR_SALE__c = EX_TestDataUtil.getSrSale(true).Id;
    EX_TestDataUtil.srSale.SALE_Number__c = 'A000999999';

    update EX_TestDataUtil.srSale;
    
    

    EX_TestDataUtil.baseProductRequest.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseProductRequest.Consumables_Order_USE_YN__c = TRUE;
    EX_TestDataUtil.baseProductRequest.SALE_Number__c = 'A000999999';
    update EX_TestDataUtil.baseProductRequest;

    SR_PAYMENT_BASIS__c basis = new SR_PAYMENT_BASIS__c(SR_SALE_ID__c = EX_TestDataUtil.srSale.Id, BASIS_NO__c = EX_TestDataUtil.baseProductRequest.Order_Number__c, RED_BLACK__c = 'B', BASIS_DT__c = Date.newInstance(2023, 1, 25), SETTLE_AMT__c = 1000, BIZ_ORIGIN_TYPE__c = 'B');
    insert basis;

    insert new SR_AR_CONFIRM__c(SR_PAYMENT_BASIS_ID__c = basis.Id, DEPOSIT_TYPE__c = 'A', INVOICE_ISSUE_TYPE__c = 'B', DEPOSIT_AMT__c = 1000);
    EX_TestDataUtil.getPrePaymentDetail(true);
    Map<String, Object> paramMap2 = new Map<String, Object>();
    paramMap2 = EX_ConsumableUtil.preWorkReturnConfirm(null);
    
    List<ReturnOrder> roList = (List<ReturnOrder>)paramMap2.get('roList');
    EX_ConsumableUtil.doReturnOrderConfirm2(paramMap2,roList);
    Test.stopTest();
}

@isTest
static void test_doReturnOrderConfirm2_03(){
    Test.startTest();

    EX_TestDataUtil.getReturnOrderLineItem(false);
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '120';
    EX_TestDataUtil.baseReturnOrderLineItem.COLLECTION_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrderLineItem.REFUND_Complete_YN__c = FALSE;
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Business_Type_Code__c = 'ExchangeReturn';
    EX_TestDataUtil.baseReturnOrderLineItem.Return_Order_CONFIRM_DTM__c = null;
    EX_TestDataUtil.baseReturnOrderLineItem.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
    EX_TestDataUtil.getReturnOrderLineItem(true);
    EX_TestDataUtil.baseReturnOrderLineItem.Order_CUST_Id__c = EX_TestDataUtil.getContact(true).Id;
    EX_TestDataUtil.baseReturnOrder.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrder.Consumables_Business_Type_Code__c = 'ExchangeReturn';
    update EX_TestDataUtil.baseReturnOrder;
    update EX_TestDataUtil.baseReturnOrderLineItem;

    ProductRequest pr = new ProductRequest();
    pr.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    pr.Order_Number__c = 'O3443243';
    pr.Department_Code__c = EX_TestDataUtil.getDept(true, null).DEPT_CODE__c;
    insert pr;
    ProductRequestLineItem prli = new ProductRequestLineItem();
    prli.recordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    prli.Order_Number__c = 'O3443243';
    prli.parentid = pr.id;

    prli.AccountId = EX_TestDataUtil.getAccount(true).Id;
    prli.ASC_Price__c = 30000;
    prli.Order_SEQ__c = 1;
    prli.CANCEL_STATUS__c = false;
    prli.CASH_DEPOSIT_YN__c = true;
    prli.CASH_PAYMENT_Amount__c = 2500;
    prli.CARD_PAYMENT_Amount__c = 0;
    prli.POINT_Amount__c = 500;
    prli.CJ_SHIPPED_STOP_YN__c = false;
    prli.Consumables_Business_Type_Code__c = 'Order';
    prli.Consumables_Order_Status__c = '002';
    prli.Consumables_Order_Class_Code__c = 'PO';
    prli.Consumables_Order_YN__c = true;
    prli.CONSUMER_Price__c = 30000;
    prli.SALE_Amount__c = 30000;
    prli.Department_Code__c = pr.Department_Code__c;
    prli.ENDP_Code__c = 'DMZ';
    prli.RSRV_Number__c = '24423';
    prli.RSRV_SEQ__c = 1;
    prli.Exchange_Quantity__c = 0;
    prli.ENDP_RSV_Quantity__c = 1;
    prli.SALE_Quantity__c = 1;
    prli.QuantityRequested = 1;
    prli.Employees_Discount_Amount__c = 0;
    prli.VIP_Discount_Amount__c = 0;
    prli.COUPON_Discount_Amount__c = 50;
    prli.GSCS_Order_Number__c = '4231';
    prli.Order_CHNL_TYPE_Code__c = 'B';
    prli.Product2Id = EX_TestDataUtil.createProduct().Id;
    prli.PART_NO__c = EX_TestDataUtil.createProduct().Name;
    prli.BASIS_Parts_Number__c = EX_TestDataUtil.createProduct().ProductCode;
    prli.DestinationLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;
    prli.SourceLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;
    prli.POINT_TRX_ID__c = '1000006623527';

    insert prli;

    EX_TestDataUtil.baseProductRequest.SR_SALE__c = EX_TestDataUtil.getSrSale(true).Id;
    EX_TestDataUtil.srSale.SALE_Number__c = 'A000999999';

    update EX_TestDataUtil.srSale;
    
    

    EX_TestDataUtil.baseProductRequest.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseProductRequest.Consumables_Order_USE_YN__c = TRUE;
    EX_TestDataUtil.baseProductRequest.SALE_Number__c = 'A000999999';
    update EX_TestDataUtil.baseProductRequest;

    SR_PAYMENT_BASIS__c basis = new SR_PAYMENT_BASIS__c(SR_SALE_ID__c = EX_TestDataUtil.srSale.Id, BASIS_NO__c = EX_TestDataUtil.baseProductRequest.Order_Number__c, RED_BLACK__c = 'B', BASIS_DT__c = Date.newInstance(2023, 1, 25), SETTLE_AMT__c = 1000, BIZ_ORIGIN_TYPE__c = 'B');
    insert basis;

    insert new SR_AR_CONFIRM__c(SR_PAYMENT_BASIS_ID__c = basis.Id, DEPOSIT_TYPE__c = 'A', INVOICE_ISSUE_TYPE__c = 'B', DEPOSIT_AMT__c = 1000);
    EX_TestDataUtil.getPrePaymentDetail(true);
    Map<String, Object> paramMap2 = new Map<String, Object>();
    paramMap2 = EX_ConsumableUtil.preWorkReturnConfirm(null);
    
    List<ReturnOrder> roList = (List<ReturnOrder>)paramMap2.get('roList');
    EX_ConsumableUtil.doReturnOrderConfirm2(paramMap2,roList);
    Test.stopTest();
}


@isTest
static void test_doReturnOrderConfirm2_03_exChannelRed(){
    Test.startTest();

    EX_TestDataUtil.getReturnOrderLineItem(false);
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '120';
    EX_TestDataUtil.baseReturnOrderLineItem.COLLECTION_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrderLineItem.REFUND_Complete_YN__c = FALSE;
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Business_Type_Code__c = 'ExchangeReturn';
    EX_TestDataUtil.baseReturnOrderLineItem.Return_Order_CONFIRM_DTM__c = null;
    EX_TestDataUtil.baseReturnOrderLineItem.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
    EX_TestDataUtil.getReturnOrderLineItem(true);
    EX_TestDataUtil.baseReturnOrderLineItem.Order_CUST_Id__c = EX_TestDataUtil.getContact(true).Id;
    EX_TestDataUtil.baseReturnOrder.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrder.Consumables_Business_Type_Code__c = 'ExchangeReturn';
    update EX_TestDataUtil.baseReturnOrder;
    update EX_TestDataUtil.baseReturnOrderLineItem;

    ProductRequest pr = new ProductRequest();
    pr.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    pr.Order_Number__c = 'O3443243';
    pr.Department_Code__c = EX_TestDataUtil.getDept(true, null).DEPT_CODE__c;
    insert pr;
    ProductRequestLineItem prli = new ProductRequestLineItem();
    prli.recordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    prli.Order_Number__c = 'O3443243';
    prli.parentid = pr.id;

    prli.AccountId = EX_TestDataUtil.getAccount(true).Id;
    prli.ASC_Price__c = 30000;
    prli.Order_SEQ__c = 1;
    prli.CANCEL_STATUS__c = false;
    prli.CASH_DEPOSIT_YN__c = true;
    prli.CASH_PAYMENT_Amount__c = 2500;
    prli.CARD_PAYMENT_Amount__c = 0;
    prli.POINT_Amount__c = 500;
    prli.CJ_SHIPPED_STOP_YN__c = false;
    prli.Consumables_Business_Type_Code__c = 'Order';
    prli.Consumables_Order_Status__c = '002';
    prli.Consumables_Order_Class_Code__c = 'PO';
    prli.Consumables_Order_YN__c = true;
    prli.CONSUMER_Price__c = 30000;
    prli.SALE_Amount__c = 30000;
    prli.Department_Code__c = pr.Department_Code__c;
    prli.ENDP_Code__c = 'DMZ';
    prli.RSRV_Number__c = '24423';
    prli.RSRV_SEQ__c = 1;
    prli.Exchange_Quantity__c = 0;
    prli.ENDP_RSV_Quantity__c = 1;
    prli.SALE_Quantity__c = 1;
    prli.QuantityRequested = 1;
    prli.Employees_Discount_Amount__c = 0;
    prli.VIP_Discount_Amount__c = 0;
    prli.COUPON_Discount_Amount__c = 50;
    prli.GSCS_Order_Number__c = '4231';
    prli.Order_CHNL_TYPE_Code__c = 'B';
    prli.Product2Id = EX_TestDataUtil.createProduct().Id;
    prli.PART_NO__c = EX_TestDataUtil.createProduct().Name;
    prli.BASIS_Parts_Number__c = EX_TestDataUtil.createProduct().ProductCode;
    prli.DestinationLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;
    prli.SourceLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;
    prli.POINT_TRX_ID__c = '1000006623527';

    insert prli;

    EX_TestDataUtil.baseProductRequest.SR_SALE__c = EX_TestDataUtil.getSrSale(true).Id;
    EX_TestDataUtil.srSale.SALE_Number__c = 'A000999999';
    EX_TestDataUtil.srSale.Order_Number__c = 'O3443243';

    update EX_TestDataUtil.srSale;

    EX_TestDataUtil.baseProductRequestLineItem.sr_sale__c = EX_TestDataUtil.getSrSale(true).Id;
    EX_TestDataUtil.baseProductRequestLineItem.SALE_Number__c = 'A000999999'; 
    EX_TestDataUtil.baseProductRequestLineItem.CASH_PAYMENT_Amount__c = 2500;
    EX_TestDataUtil.baseProductRequestLineItem.CARD_PAYMENT_Amount__c = 0;
    EX_TestDataUtil.baseProductRequestLineItem.POINT_Amount__c = 500;

    update EX_TestDataUtil.baseProductRequestLineItem;

    EX_TestDataUtil.baseProductRequest.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseProductRequest.Consumables_Order_USE_YN__c = TRUE;
    EX_TestDataUtil.baseProductRequest.SALE_Number__c = 'A000999999';
    EX_TestDataUtil.baseProductRequest.CASH_PAYMENT_Amount__c = 2500;
    EX_TestDataUtil.baseProductRequest.CARD_PAYMENT_Amount__c = 2500;
    EX_TestDataUtil.baseProductRequest.POINT_Amount__c = 2500;     
    update EX_TestDataUtil.baseProductRequest;

    SR_PAYMENT_BASIS__c basis = new SR_PAYMENT_BASIS__c(SR_SALE_ID__c = EX_TestDataUtil.srSale.Id, BASIS_NO__c = EX_TestDataUtil.srSale.SALE_Number__c, RED_BLACK__c = 'B', BASIS_DT__c = Date.newInstance(2023, 1, 25), SETTLE_AMT__c = 3000, BIZ_ORIGIN_TYPE__c = 'C');
    insert basis;

    insert new SR_AR_CONFIRM__c(SR_PAYMENT_BASIS_ID__c = basis.Id, DEPOSIT_TYPE__c = 'A', INVOICE_ISSUE_TYPE__c = 'B', DEPOSIT_AMT__c = 2500);
    insert new SR_AR_CONFIRM__c(SR_PAYMENT_BASIS_ID__c = basis.Id, DEPOSIT_TYPE__c = 'D', INVOICE_ISSUE_TYPE__c = 'C', DEPOSIT_AMT__c = 2500);
    insert new SR_AR_CONFIRM__c(SR_PAYMENT_BASIS_ID__c = basis.Id, DEPOSIT_TYPE__c = 'B', INVOICE_ISSUE_TYPE__c = 'D', DEPOSIT_AMT__c = 2500);
    EX_TestDataUtil.getPrePaymentDetail(true);
    Map<String, Object> paramMap2 = new Map<String, Object>();

    Set<String> tempIdSet = new Set<String>();
    tempIdSet.add(EX_TestDataUtil.baseReturnOrderLineItem.Id);
    EX_ConsumableUtil.exChannelRed(tempIdSet);
    Test.stopTest();
}

@isTest
static void test_doReturnOrderConfirm2_04_exChannelRed(){
    Test.startTest();

    EX_TestDataUtil.getReturnOrderLineItem(false);
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '120';
    EX_TestDataUtil.baseReturnOrderLineItem.COLLECTION_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrderLineItem.REFUND_Complete_YN__c = FALSE;
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Business_Type_Code__c = 'Return';
    EX_TestDataUtil.baseReturnOrderLineItem.Return_Order_CONFIRM_DTM__c = null;
    EX_TestDataUtil.baseReturnOrderLineItem.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
    EX_TestDataUtil.getReturnOrderLineItem(true);
    EX_TestDataUtil.baseReturnOrderLineItem.Order_CUST_Id__c = EX_TestDataUtil.getContact(true).Id;
    EX_TestDataUtil.baseReturnOrder.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrder.Consumables_Business_Type_Code__c = 'Return';
    update EX_TestDataUtil.baseReturnOrder;
    update EX_TestDataUtil.baseReturnOrderLineItem;

    ProductRequest pr = new ProductRequest();
    pr.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    pr.Order_Number__c = 'O3443243';
    pr.Department_Code__c = EX_TestDataUtil.getDept(true, null).DEPT_CODE__c;
    insert pr;
    ProductRequestLineItem prli = new ProductRequestLineItem();
    prli.recordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    prli.Order_Number__c = 'O3443243';
    prli.parentid = pr.id;

    prli.AccountId = EX_TestDataUtil.getAccount(true).Id;
    prli.ASC_Price__c = 30000;
    prli.Order_SEQ__c = 1;
    prli.CANCEL_STATUS__c = false;
    prli.CASH_DEPOSIT_YN__c = true;
    prli.CASH_PAYMENT_Amount__c = 2500;
    prli.CARD_PAYMENT_Amount__c = 0;
    prli.POINT_Amount__c = 500;
    prli.CJ_SHIPPED_STOP_YN__c = false;
    prli.Consumables_Business_Type_Code__c = 'Order';
    prli.Consumables_Order_Status__c = '002';
    prli.Consumables_Order_Class_Code__c = 'PO';
    prli.Consumables_Order_YN__c = true;
    prli.CONSUMER_Price__c = 30000;
    prli.SALE_Amount__c = 30000;
    prli.Department_Code__c = pr.Department_Code__c;
    prli.ENDP_Code__c = 'DMZ';
    prli.RSRV_Number__c = '24423';
    prli.RSRV_SEQ__c = 1;
    prli.Exchange_Quantity__c = 0;
    prli.ENDP_RSV_Quantity__c = 1;
    prli.SALE_Quantity__c = 1;
    prli.QuantityRequested = 1;
    prli.Employees_Discount_Amount__c = 0;
    prli.VIP_Discount_Amount__c = 0;
    prli.COUPON_Discount_Amount__c = 50;
    prli.GSCS_Order_Number__c = '4231';
    prli.Order_CHNL_TYPE_Code__c = 'B';
    prli.Product2Id = EX_TestDataUtil.createProduct().Id;
    prli.PART_NO__c = EX_TestDataUtil.createProduct().Name;
    prli.BASIS_Parts_Number__c = EX_TestDataUtil.createProduct().ProductCode;
    prli.DestinationLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;
    prli.SourceLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;
    prli.POINT_TRX_ID__c = '1000006623527';

    insert prli;

    EX_TestDataUtil.baseProductRequest.SR_SALE__c = EX_TestDataUtil.getSrSale(true).Id;
    EX_TestDataUtil.srSale.SALE_Number__c = 'A000999999';
    EX_TestDataUtil.srSale.Order_Number__c = 'O3443243';

    update EX_TestDataUtil.srSale;

    EX_TestDataUtil.baseProductRequestLineItem.sr_sale__c = EX_TestDataUtil.getSrSale(true).Id;
    EX_TestDataUtil.baseProductRequestLineItem.SALE_Number__c = 'A000999999'; 
    EX_TestDataUtil.baseProductRequestLineItem.CASH_PAYMENT_Amount__c = 2500;
    EX_TestDataUtil.baseProductRequestLineItem.CARD_PAYMENT_Amount__c = 0;
    EX_TestDataUtil.baseProductRequestLineItem.POINT_Amount__c = 500;

    update EX_TestDataUtil.baseProductRequestLineItem;

    EX_TestDataUtil.baseProductRequest.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseProductRequest.Consumables_Order_USE_YN__c = TRUE;
    EX_TestDataUtil.baseProductRequest.SALE_Number__c = 'A000999999';
    EX_TestDataUtil.baseProductRequest.CASH_PAYMENT_Amount__c = 2500;
    EX_TestDataUtil.baseProductRequest.CARD_PAYMENT_Amount__c = 2500;
    EX_TestDataUtil.baseProductRequest.POINT_Amount__c = 2500;     
    update EX_TestDataUtil.baseProductRequest;

    SR_PAYMENT_BASIS__c basis = new SR_PAYMENT_BASIS__c(SR_SALE_ID__c = EX_TestDataUtil.srSale.Id, BASIS_NO__c = EX_TestDataUtil.srSale.SALE_Number__c, RED_BLACK__c = 'B', BASIS_DT__c = Date.newInstance(2023, 1, 25), SETTLE_AMT__c = 3000, BIZ_ORIGIN_TYPE__c = 'C');
    insert basis;

    insert new SR_AR_CONFIRM__c(SR_PAYMENT_BASIS_ID__c = basis.Id, DEPOSIT_TYPE__c = 'A', INVOICE_ISSUE_TYPE__c = 'B', DEPOSIT_AMT__c = 2500);
    insert new SR_AR_CONFIRM__c(SR_PAYMENT_BASIS_ID__c = basis.Id, DEPOSIT_TYPE__c = 'D', INVOICE_ISSUE_TYPE__c = 'C', DEPOSIT_AMT__c = 2500);
    insert new SR_AR_CONFIRM__c(SR_PAYMENT_BASIS_ID__c = basis.Id, DEPOSIT_TYPE__c = 'B', INVOICE_ISSUE_TYPE__c = 'D', DEPOSIT_AMT__c = 2500);
    EX_TestDataUtil.getPrePaymentDetail(true);
    Map<String, Object> paramMap2 = new Map<String, Object>();

    Set<String> tempIdSet = new Set<String>();
    tempIdSet.add(EX_TestDataUtil.baseReturnOrderLineItem.Id);
    EX_ConsumableUtil.exChannelRed(tempIdSet);
    Test.stopTest();
}          
@isTest
static void exChannelRed_03(){
    Test.startTest();

    EX_TestDataUtil.getReturnOrderLineItem(false);
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '120';
    EX_TestDataUtil.baseReturnOrderLineItem.COLLECTION_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrderLineItem.REFUND_Complete_YN__c = FALSE;
    EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Business_Type_Code__c = 'Return';
    EX_TestDataUtil.baseReturnOrderLineItem.Return_Order_CONFIRM_DTM__c = null;
    EX_TestDataUtil.baseReturnOrderLineItem.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
    EX_TestDataUtil.getReturnOrderLineItem(true);
    EX_TestDataUtil.baseReturnOrderLineItem.Order_CUST_Id__c = EX_TestDataUtil.getContact(true).Id;
    EX_TestDataUtil.baseReturnOrderLineItem.Order_CHNL_TYPE_Code__c = 'BestShop';

    EX_TestDataUtil.baseReturnOrder.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseReturnOrder.Consumables_Business_Type_Code__c = 'Return';
    EX_TestDataUtil.baseReturnOrder.RETURN_PAYMENT_Amount__c = 30000;
    EX_TestDataUtil.baseReturnOrder.RETURN_CARD_PAYMENT_Amount__c = 10000;
    EX_TestDataUtil.baseReturnOrder.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c = 10000;
    EX_TestDataUtil.baseReturnOrder.RETURN_POINT_Amount__c = 10000;
    update EX_TestDataUtil.baseReturnOrder;
    update EX_TestDataUtil.baseReturnOrderLineItem;

    EX_TestDataUtil.dept.DEPT_CODE__c = 'PH0300';
    update EX_TestDataUtil.dept;

    ProductRequest pr = new ProductRequest();
    pr.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    pr.Order_Number__c = 'O3443243';
    pr.Department_Code__c = EX_TestDataUtil.getDept(true, null).DEPT_CODE__c;
    insert pr;
    ProductRequestLineItem prli = new ProductRequestLineItem();
    prli.recordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    prli.Order_Number__c = 'O3443243';
    prli.parentid = pr.id;

    prli.AccountId = EX_TestDataUtil.getAccount(true).Id;
    prli.ASC_Price__c = 30000;
    prli.Order_SEQ__c = 1;
    prli.CANCEL_STATUS__c = false;
    prli.CASH_DEPOSIT_YN__c = true;
    prli.CASH_PAYMENT_Amount__c = 2500;
    prli.CARD_PAYMENT_Amount__c = 0;
    prli.POINT_Amount__c = 500;
    prli.CJ_SHIPPED_STOP_YN__c = false;
    prli.Consumables_Business_Type_Code__c = 'Order';
    prli.Consumables_Order_Status__c = '002';
    prli.Consumables_Order_Class_Code__c = 'PO';
    prli.Consumables_Order_YN__c = true;
    prli.CONSUMER_Price__c = 30000;
    prli.SALE_Amount__c = 30000;
    prli.Department_Code__c = pr.Department_Code__c;
    prli.ENDP_Code__c = 'DMZ';
    prli.RSRV_Number__c = '24423';
    prli.RSRV_SEQ__c = 1;
    prli.Exchange_Quantity__c = 0;
    prli.ENDP_RSV_Quantity__c = 1;
    prli.SALE_Quantity__c = 1;
    prli.QuantityRequested = 1;
    prli.Employees_Discount_Amount__c = 0;
    prli.VIP_Discount_Amount__c = 0;
    prli.COUPON_Discount_Amount__c = 50;
    prli.GSCS_Order_Number__c = '4231';
    prli.Order_CHNL_TYPE_Code__c = 'B';
    prli.Product2Id = EX_TestDataUtil.createProduct().Id;
    prli.PART_NO__c = EX_TestDataUtil.createProduct().Name;
    prli.BASIS_Parts_Number__c = EX_TestDataUtil.createProduct().ProductCode;
    prli.DestinationLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;
    prli.SourceLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;
    prli.POINT_TRX_ID__c = '1000006623527';

    insert prli;

    EX_TestDataUtil.baseProductRequest.SR_SALE__c = EX_TestDataUtil.getSrSale(true).Id;
    EX_TestDataUtil.srSale.SALE_Number__c = 'A000999999';
    EX_TestDataUtil.srSale.Order_Number__c = 'O3443243';

    update EX_TestDataUtil.srSale;

    EX_TestDataUtil.baseProductRequestLineItem.sr_sale__c = EX_TestDataUtil.getSrSale(true).Id;
    EX_TestDataUtil.baseProductRequestLineItem.SALE_Number__c = 'A000999999'; 
    EX_TestDataUtil.baseProductRequestLineItem.CASH_PAYMENT_Amount__c = 2500;
    EX_TestDataUtil.baseProductRequestLineItem.CARD_PAYMENT_Amount__c = 0;
    EX_TestDataUtil.baseProductRequestLineItem.POINT_Amount__c = 500;

    update EX_TestDataUtil.baseProductRequestLineItem;

    EX_TestDataUtil.baseProductRequest.Consumables_Order_YN__c = TRUE;
    EX_TestDataUtil.baseProductRequest.Consumables_Order_USE_YN__c = TRUE;
    EX_TestDataUtil.baseProductRequest.SALE_Number__c = 'A000999999';
    EX_TestDataUtil.baseProductRequest.CASH_PAYMENT_Amount__c = 2500;
    EX_TestDataUtil.baseProductRequest.CARD_PAYMENT_Amount__c = 2500;
    EX_TestDataUtil.baseProductRequest.POINT_Amount__c = 2500;     
    update EX_TestDataUtil.baseProductRequest;

    SR_PAYMENT_BASIS__c basis = new SR_PAYMENT_BASIS__c(SR_SALE_ID__c = EX_TestDataUtil.srSale.Id, BASIS_NO__c = EX_TestDataUtil.srSale.SALE_Number__c, RED_BLACK__c = 'B', BASIS_DT__c = Date.newInstance(2023, 1, 25), SETTLE_AMT__c = 3000, BIZ_ORIGIN_TYPE__c = 'C');
    insert basis;

    insert new SR_AR_CONFIRM__c(SR_PAYMENT_BASIS_ID__c = basis.Id, DEPOSIT_TYPE__c = 'A', INVOICE_ISSUE_TYPE__c = 'B', DEPOSIT_AMT__c = 2500);
    insert new SR_AR_CONFIRM__c(SR_PAYMENT_BASIS_ID__c = basis.Id, DEPOSIT_TYPE__c = 'D', INVOICE_ISSUE_TYPE__c = 'C', DEPOSIT_AMT__c = 2500);
    insert new SR_AR_CONFIRM__c(SR_PAYMENT_BASIS_ID__c = basis.Id, DEPOSIT_TYPE__c = 'B', INVOICE_ISSUE_TYPE__c = 'D', DEPOSIT_AMT__c = 2500);
    EX_TestDataUtil.getPrePaymentDetail(true);
    Map<String, Object> paramMap2 = new Map<String, Object>();

    Set<String> tempIdSet = new Set<String>();
    tempIdSet.add(EX_TestDataUtil.baseReturnOrderLineItem.Id);
    EX_ConsumableUtil.exChannelRed(tempIdSet);
    Test.stopTest();
}          


@isTest
static void test_updatePrliPtid_01(){
    ProductRequest pr = new ProductRequest();
    pr.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    pr.Order_Number__c = 'O3443243';
    pr.Department_Code__c = EX_TestDataUtil.getDept(true, null).DEPT_CODE__c;
    insert pr;
    ProductRequestLineItem prli = new ProductRequestLineItem();
    prli.recordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    prli.Order_Number__c = 'O3443243';
    prli.parentid = pr.id;

    prli.AccountId = EX_TestDataUtil.getAccount(true).Id;
    prli.ASC_Price__c = 30000;
    prli.Order_SEQ__c = 1;
    prli.CANCEL_STATUS__c = false;
    prli.CASH_DEPOSIT_YN__c = false;
    prli.CASH_PAYMENT_Amount__c = 2000;
    prli.CARD_PAYMENT_Amount__c = 500;
    prli.POINT_Amount__c = 500;
    prli.CJ_SHIPPED_STOP_YN__c = false;
    prli.Consumables_Business_Type_Code__c = 'Order';
    prli.Consumables_Order_Status__c = '002';
    prli.Consumables_Order_Class_Code__c = 'PO';
    prli.Consumables_Order_YN__c = true;
    prli.CONSUMER_Price__c = 30000;
    prli.SALE_Amount__c = 30000;
    prli.Department_Code__c = pr.Department_Code__c;
    prli.ENDP_Code__c = 'DMZ';
    prli.RSRV_Number__c = '24423';
    prli.RSRV_SEQ__c = 1;
    prli.Exchange_Quantity__c = 0;
    prli.ENDP_RSV_Quantity__c = 1;
    prli.SALE_Quantity__c = 1;
    prli.QuantityRequested = 1;
    prli.Employees_Discount_Amount__c = 0;
    prli.VIP_Discount_Amount__c = 0;
    prli.COUPON_Discount_Amount__c = 50;
    prli.GSCS_Order_Number__c = '4231';
    prli.Order_CHNL_TYPE_Code__c = 'B';
    prli.Product2Id = EX_TestDataUtil.createProduct().Id;
    prli.PART_NO__c = EX_TestDataUtil.createProduct().Name;
    prli.BASIS_Parts_Number__c = EX_TestDataUtil.createProduct().ProductCode;
    prli.DestinationLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;
    prli.SourceLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;
    prli.RETURN_PAYMENT_PTID__c = '';
    prli.TID__c = 'TID';

    insert prli;

    
    SR_SMARTRO_PAYMENT_REQUEST__c srp = new SR_SMARTRO_PAYMENT_REQUEST__c();
    srp.MID__c = 'MID';
    srp.MOID__c = 'MOID';
    srp.TID__c = 'TID';
    srp.APPR_AMT__c = 500;
    srp.APPR_BALANCE__c = 0;
    srp.PAYMETHOD__c = 'CARD';
    srp.PAYMENT_TYPE__c = 'PG_URL';
    srp.SMARTRO_PAYMENT_REQUEST_PK__c = '3';
    insert srp;
    
    SR_SMARTRO_PAYMENT_CANCEL__c srpCancel = new SR_SMARTRO_PAYMENT_CANCEL__c();
    srpCancel.PTID__c = 'PTID';
    srpCancel.SR_SMARTRO_PAYMENT_REQUEST_ID__c = srp.Id;
    insert srpCancel;

    Test.startTest();
    EX_ConsumableUtil.updatePrliPtid(prli.Id);
    Test.stopTest();
    
}

@isTest
static void test_checkFail_02(){
    Test.startTest();
    List<SObject> targetList = new List<SObject>();
    List<String> salesFailOrderNumberList = new List<String>();
    String errorMsg = 'nono';

    productrequest temp = EX_TestDataUtil.getProductRequest(false);
    temp.PAYMENT_YN__c = true;
    targetList.add(temp);

    EX_ConsumableUtil.checkFail(targetList,salesFailOrderNumberList,errorMsg);
    
    Test.stopTest();
}   

@isTest
static void test_setCarePlusBackIFData(){

    ProductRequest pr = new ProductRequest();
    pr.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    pr.Order_Number__c = 'O3443243';
    pr.Department_Code__c = EX_TestDataUtil.getDept(true, null).DEPT_CODE__c;
    pr.Order_Date__c = System.today();
    pr.BILL_TO_CODE__c = 'a123123123';
    insert pr;

    ProductRequestLineItem prli = new ProductRequestLineItem();
    prli.recordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    prli.Order_Number__c = 'O3443243';
    prli.parentid = pr.id;
    prli.AccountId = EX_TestDataUtil.getAccount(true).Id;
    prli.ASC_Price__c = 30000;
    prli.Order_SEQ__c = 1;
    prli.CANCEL_STATUS__c = false;
    prli.CASH_DEPOSIT_YN__c = true;
    prli.CASH_PAYMENT_Amount__c = 2500;
    prli.CARD_PAYMENT_Amount__c = 0;
    prli.POINT_Amount__c = 500;
    prli.CJ_SHIPPED_STOP_YN__c = false;
    prli.Consumables_Business_Type_Code__c = 'Order';
    prli.Consumables_Order_Status__c = '002';
    prli.Consumables_Order_Class_Code__c = 'PO';
    prli.Consumables_Order_YN__c = true;
    prli.CONSUMER_Price__c = 30000;
    prli.SALE_Amount__c = 30000;
    prli.Department_Code__c = pr.Department_Code__c;
    prli.ENDP_Code__c = 'DMZ';
    prli.RSRV_Number__c = '24423';
    prli.RSRV_SEQ__c = 1;
    prli.Exchange_Quantity__c = 0;
    prli.ENDP_RSV_Quantity__c = 1;
    prli.SALE_Quantity__c = 1;
    prli.QuantityRequested = 1;
    prli.Employees_Discount_Amount__c = 0;
    prli.VIP_Discount_Amount__c = 0;
    prli.COUPON_Discount_Amount__c = 50;
    prli.GSCS_Order_Number__c = '4231';
    prli.Order_CHNL_TYPE_Code__c = 'B';
    prli.Product2Id = EX_TestDataUtil.createProduct().Id;
    prli.PART_NO__c = EX_TestDataUtil.createProduct().Name;
    prli.BASIS_Parts_Number__c = EX_TestDataUtil.createProduct().ProductCode;
    prli.DestinationLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;
    prli.SourceLocationId = EX_TestDataUtil.getLocation(true, 'Center', null).Id;
    prli.POINT_TRX_ID__c = '1000006623527';
    prli.QuantityRequested = 10;
    prli.UnitPrice__c = 100;
    prli.SALE_Number__c = 'a123456789';
    insert prli;

    

    Test.startTest();
    List<ProductRequestLineItem> prlis = [
                                    SELECT Id, Order_Number__c, ParentId, Parent.Order_Date__c, Parent.BILL_TO_CODE__c, Parent.SHIP_TO_CODE__c
                                            , Product2.Name, Product2.DIV_CODE__c, MODEL_Code__c, QuantityRequested, SHIP_QTY__c
                                            , CANCEL_Quantity__c, UnitPrice__c, CONSIGNEE_Name__c, CONSIGNEE_PostalCode__c, CONSIGNEE_Address__c
                                            , CONSIGNEE_Address_DETAIL__c, CONSIGNEE_TPNO_1__c, Parent.Description, Parent.CAREPLUS_Order_Requester_Class_Code__c
                                            , SALE_Number__c
                                    FROM   ProductRequestLineItem 
                                    LIMIT  1
    ];
    EX_ConsumableUtil.setCarePlusBackIFData(prlis[0], 'a123456789', 10, 10, '');
    Test.stopTest();
}

    private class HttpCancelMockCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(300);
            String responseBody = 'OK';
            response.setBody(responseBody);
            return response;
        }
    }

    private class HttpBankSMockCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            String responseBody = '{"status_code":"OK", "message":"Success", "ResultCode": "4200"}';
            response.setBody(responseBody);
            return response;
        }
    }

    private class HttpBankFMockCalloutMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setStatusCode(200);
            String responseBody = '{"status_code":"OK", "message":"Fail", "ResultCode": "400"}';
            response.setBody(responseBody);
            return response;
        }
    }
}