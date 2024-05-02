/**
 * Created by MS on 2023-04-28.
 */

@IsTest
private class EX_IntegrationOrderManagementCtrlr_ts {
    @IsTest
    static void test01() {
        Test.startTest();

        EX_IntegrationOrderManagementController.doGetInitData();

        EX_TestDataUtil.getDept(false, null);
        EX_TestDataUtil.dept.DEPT_TYPE_SECOND__c = 'E';

        EX_TestDataUtil.createProduct().PART_DESC_KOR__c = 'test';
        update EX_TestDataUtil.baseProduct;

        EX_TestDataUtil.getContact(true);
        EX_TestDataUtil.getProductRequestLineItem(true);
        EX_TestDataUtil.getProductRequest(false).PAYMENT_Method_Code__c = 'CARD';
        EX_TestDataUtil.baseProductRequest.Order_CUST_Id__c = EX_TestDataUtil.baseContact.Id;
        EX_TestDataUtil.baseProductRequest.PAYMENT_TYPE__c = 'URL';
        EX_TestDataUtil.baseProductRequest.Order_Date__c = Date.today();
        EX_TestDataUtil.baseProductRequest.Order_CUST_Name__c = 'TESTfsfd';

        EX_TestDataUtil.getProductRequestLineItem(false).Appointment_Status__c = '이동중';
        EX_TestDataUtil.baseProductRequestLineItem.Order_CUST_Id__c = EX_TestDataUtil.baseContact.Id;
        EX_TestDataUtil.baseProductRequestLineItem.Consumables_Order_Status__c = '030';
        EX_TestDataUtil.baseProductRequestLineItem.SUB_Order_Number__c = '01-11-12';
        EX_TestDataUtil.baseProductRequestLineItem.Consumables_Order_Detail__c = '003';
        EX_TestDataUtil.baseProductRequestLineItem.SourceLocationId = EX_TestDataUtil.baseLocation.Id;

        System.debug('baseProductRequest :: ' + EX_TestDataUtil.baseProductRequest);
        System.debug(EX_TestDataUtil.baseProductRequest.Order_CUST_Name__c);
        System.debug(EX_TestDataUtil.baseProductRequest.Order_CUST_Id__c);
        System.debug(EX_TestDataUtil.baseProductRequest.Order_CUST_Id__r.MobilePhone);
        System.debug(EX_TestDataUtil.baseProductRequest.Order_CUST_Id__r.LastName);
        System.debug('baseProductRequestLineItem :: ' + EX_TestDataUtil.baseProductRequestLineItem);
        Map<String, Object> mapSearchParam = new Map<String, Object>();
        mapSearchParam.put('orderChannel', EX_TestDataUtil.getProductRequestLineItem(true).Order_CHNL_TYPE_Code__c);
        mapSearchParam.put('contactPhone', EX_TestDataUtil.getContact(false).MobilePhone);
        mapSearchParam.put('department', EX_TestDataUtil.getProductRequestLineItem(true).ENDP_Code__c);
        mapSearchParam.put('orderStatus', EX_TestDataUtil.getProductRequestLineItem(true).Consumables_Order_Status__c);
        mapSearchParam.put('contactName', EX_TestDataUtil.getContact(false).LastName);
        mapSearchParam.put('baseDateEnd', String.valueOf(Date.today().addDays(1)));
        mapSearchParam.put('baseDateStart', String.valueOf(Date.today().addDays(-1)));
        mapSearchParam.put('isSalesCompleteY', false);
        mapSearchParam.put('isSalesCompleteN', true);
        mapSearchParam.put('appointmentStatus', EX_TestDataUtil.getProductRequestLineItem(true).Appointment_Status__c);
        mapSearchParam.put('pageOffset', 0);
        mapSearchParam.put('recordLimit', 1);
        mapSearchParam.put('isSearchBtnClick', true);
        mapSearchParam.put('orderNo', EX_TestDataUtil.getProductRequestLineItem(true).Order_Number__c);
        SR_ONLINE_DELIVERY_INFO__c deliveryInfo = new SR_ONLINE_DELIVERY_INFO__c();
        deliveryInfo.ProductRequestLineItem__c = EX_TestDataUtil.getProductRequestLineItem(true).Id;
        insert deliveryInfo;

        EX_TestDataUtil.getReturnOrderLineItem(false).Consumables_Order_YN__c = true;
        EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Business_Type_Code__c = 'Return';
        EX_TestDataUtil.baseReturnOrderLineItem.SUB_Order_Number__c = EX_TestDataUtil.baseProductRequestLineItem.SUB_Order_Number__c;
        EX_TestDataUtil.baseReturnOrderLineItem.Expected_Return_Quantity__c = 1;
        EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '003';
        EX_TestDataUtil.baseReturnOrderLineItem.Order_Number__c = EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c;
        EX_TestDataUtil.baseReturnOrderLineItem.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
        EX_TestDataUtil.getReturnOrderLineItem(true);

        EX_IntegrationOrderManagementController.doGetSearchData(mapSearchParam);
        EX_IntegrationOrderManagementController.dogetCenterSearch();
        // EX_IntegrationOrderManagementController.doGetSearchData2(mapSearchParam);
        EX_IntegrationOrderManagementController.doGetOrderLineItemData(EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c, null);

        EX_TestDataUtil.baseProductRequestLineItem.PAYMENT_YN__c = true;
        EX_TestDataUtil.baseProductRequestLineItem.Order_CHNL_TYPE_Code__c = 'V';
        update EX_TestDataUtil.baseProductRequestLineItem;
        EX_TestDataUtil.baseProductRequestLineItem.PART_DESC_KOR__c = 'dafdf';
        update EX_TestDataUtil.baseProduct;
        EX_TestDataUtil.baseProductRequest.PAYMENT_Method_Code__c = 'VBANK';
        EX_TestDataUtil.baseProductRequest.PAYMENT_TYPE__c = 'URL';
        update EX_TestDataUtil.baseProductRequest;
        mapSearchParam.put('orderChannel', EX_TestDataUtil.getProductRequestLineItem(true).Order_CHNL_TYPE_Code__c);
        EX_IntegrationOrderManagementController.doGetSearchData(mapSearchParam);
        // EX_IntegrationOrderManagementController.doGetSearchData2(mapSearchParam);
        EX_IntegrationOrderManagementController.doGetOrderLineItemData(EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c, null);

        EX_IntegrationOrderManagementController.doGetTrackingNumberList('ss');

        EX_TestDataUtil.baseProductRequestLineItem.Consumables_Order_Status__c = '001';
        EX_TestDataUtil.baseProductRequestLineItem.PAYMENT_YN__c = false;
        EX_TestDataUtil.baseProductRequestLineItem.FFMT_Order_Transfer_YN__c = false;
        EX_TestDataUtil.baseProductRequestLineItem.FFMT_Order_Number__c = '32432';
        EX_TestDataUtil.baseProductRequestLineItem.PAYMENT_TYPE__c = 'CASH';
        update EX_TestDataUtil.baseProductRequestLineItem;
        mapSearchParam.put('CJOrderN', true);
        mapSearchParam.put('CJOrderY', false);
        mapSearchParam.put('CJOrderNo', EX_TestDataUtil.baseProductRequestLineItem.FFMT_Order_Number__c);
        EX_IntegrationOrderManagementController.doGetSearchOrderList(mapSearchParam);

        EX_IntegrationOrderManagementController.doGetConsigneeDetail(EX_TestDataUtil.baseProductRequest.Order_Number__c);


        mapSearchParam.put('Id', EX_TestDataUtil.baseProductRequest.Id);
        mapSearchParam.put('CONSIGNEE_Name__c', 'dfasfs');
        mapSearchParam.put('CONSIGNEE_TPNO_1__c', 'dfasfs');
        mapSearchParam.put('CONSIGNEE_Address__c', 'dfasfs');
        mapSearchParam.put('CONSIGNEE_Address_Detail__c', 'dfasfs');
        mapSearchParam.put('CONSIGNEE_PostalCode__c', 'dfasfs');
        EX_IntegrationOrderManagementController.doUpdateConsigneeData(mapSearchParam);


        mapSearchParam.put('id', EX_TestDataUtil.baseProductRequestLineItem.Id);
        mapSearchParam.put('newName', 'dfasfs');
        mapSearchParam.put('newPhone', 'dfasfs');
        mapSearchParam.put('newPostalCode', 'dfasfs');
        mapSearchParam.put('newAddress', 'dfasfs');
        mapSearchParam.put('newDetailAddress', 'dfasfs');
        EX_IntegrationOrderManagementController.doChangeConsignee(mapSearchParam);

        EX_IntegrationOrderManagementController.doGetOrderLineItemDataByReturnRequest(EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c);

        List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable> table = new List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable>();
        EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable item = new EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable();
        item.OrderNumber = EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c;
        item.ParentId = EX_TestDataUtil.baseProductRequest.Id;
        item.Id = EX_TestDataUtil.baseProductRequestLineItem.Id;
        item.OrderSEQ = 1;
        item.RequestedReturnQuantity = 1;
        item.CashAmount = 0;
        item.CardAmount = 0;
        item.PointAmount = 1000;
        item.PaymentAmount = 1000;
        item.ReturnSaleAmount = 10000;
        item.CustomerPrice = 10000;
        item.SalesQuantity = 1;
        item.DiscountAmount = 100;
        item.SaleAmount = 100;
        item.ReturnVBankPaymentAmount = 1001;
        item.ReturnPointAmount = 2000;
        item.ReturnCardPaymentAmount = 1000;
        table.add(item);
        Map<Object, Object> contactConsigneeInfoMap = new Map<Object, Object>();
        contactConsigneeInfoMap.put('ContactName', 'teedts');
        contactConsigneeInfoMap.put('ContactMobilePhone', 'tesdts');
        contactConsigneeInfoMap.put('ContactAddress', 'testts');
        contactConsigneeInfoMap.put('ContactDetailAddress', 'tesdts');
        contactConsigneeInfoMap.put('CustomerPostalCode', 'testss');
        contactConsigneeInfoMap.put('ConsigneeName', 'teedts');
        contactConsigneeInfoMap.put('ConsigneePhone', 'tesdts');
        contactConsigneeInfoMap.put('ConsigneeAddress', 'testts');
        contactConsigneeInfoMap.put('ConsigneeDetailAddress', 'teedts');
        contactConsigneeInfoMap.put('CONSIGNEE_PostalCode', 'teedts');
        contactConsigneeInfoMap.put('ContactId', EX_TestDataUtil.getContact(true).Id);
        mapSearchParam.put('productRequestLineItemsByReturnRequest', JSON.serialize(table));
        mapSearchParam.put('contactConsigneeInfo', contactConsigneeInfoMap);
        mapSearchParam.put('channelType', '소모품택배');
        mapSearchParam.put('caseInfo', '소모품택배');
        List<BusinessHours> bzHours = [SELECT Id FROM BusinessHours LIMIT 1];
        if (!bzHours.isEmpty()) {
            Case nCase = new Case();
            nCase.BusinessHoursId = bzHours[0].Id;
            insert nCase;
            Map<Object, Object> caseInfoMap = new Map<Object, Object>();
            caseInfoMap.put('CaseId', nCase.Id);
            mapSearchParam.put('appendRemarkByReturnRequest', 'test');
            mapSearchParam.put('bankCode', 'test');
            mapSearchParam.put('bankAccountNo', 'test');
            mapSearchParam.put('receiverName', 'test');
        }
        try {
            EX_IntegrationOrderManagementController.doRequestReturnOrder(mapSearchParam);
        } catch (Exception e) {
            System.debug(e);
        }

        List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable> iolit = new List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable>();
        EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable it = new EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable();
        it.Id = EX_TestDataUtil.baseProductRequestLineItem.Id;
        it.OrderNumber = EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c;
        it.UpdatedOrderStatus = '상품준비중';
        it.HandWorkReason = 'test';
        it.OrderStatusChangeHistory = 'test';
        it.OrderStatus = '배송준비중';
        it.OrderStatusChangeHistory = 'test';
        iolit.add(it);
        EX_IntegrationOrderManagementController.doUpdateOrderStatus(new List<String>{
                EX_TestDataUtil.baseProductRequestLineItem.Id
        }, JSON.serialize(iolit));

        List<Map<String, String>> pListMapRequestInfos = new List<Map<String, String>>();
        Map<String, String> pListMap = new Map<String, String>();
        pListMap.put('ParentLocationId', 'test');
        pListMap.put('subTotal', '3000');
        pListMapRequestInfos.add(pListMap);
        EX_IntegrationOrderManagementController.assignRequestInfos(pListMapRequestInfos, 'test');

        EX_IntegrationOrderManagementController.assignRequestInfos(pListMapRequestInfos, 'test1');

        try {
            EX_IntegrationOrderManagementController.doSaveSales(new List<String>{
                    EX_TestDataUtil.baseProductRequest.Order_Number__c
            });
            EX_IntegrationOrderManagementController.getDeliveryNumWithId(EX_TestDataUtil.getProductRequestLineItem(true).Id);

            EX_IntegrationOrderManagementController.doCheckBankAccount('test', 'test', 'test', null);
        } catch (Exception e) {
            System.debug(e);
        }


        Test.stopTest();
    }

    @IsTest
    static void test02() {
        Test.startTest();

        TemplateMgmt__c tmgt = new TemplateMgmt__c();
        tmgt.Content_c__c = 'teststests';
        tmgt.Title__c = 'testsetse';
        // tmgt.TemplateCode__c = 'SVC_LGE_MACN_012_01';
        tmgt.TemplateCode__c = 'SVC_LGE_MACN_012_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수
        TemplateMgmt__c tm2 = tmgt.clone(false);
        // tm2.TemplateCode__c = 'SVC_LGE_MACN_011';
        tm2.TemplateCode__c = 'SVC_LGE_MACN_011_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
        TemplateMgmt__c tm3 = tmgt.clone(false);
        // tm3.TemplateCode__c = 'SVC_LGE_MACN_030';
        tm3.TemplateCode__c = 'SVC_LGE_MACN_030_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
        TemplateMgmt__c tm4 = tmgt.clone(false);
        // tm4.TemplateCode__c = 'SVC_LGE_MACN_031';
        tm4.TemplateCode__c = 'SVC_LGE_MACN_031_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
        TemplateMgmt__c tm5 = tmgt.clone(false);
        tm5.TemplateCode__c = 'SVC_LGE_MACN_S012';
        TemplateMgmt__c tm6 = tmgt.clone(false);
        // tm6.TemplateCode__c = 'SVC_LGE_MACN_S011';
        tm6.TemplateCode__c = 'SVC_LGE_MACN_S011_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
        insert new List<TemplateMgmt__c>{
                tmgt, tm2, tm3, tm4, tm5, tm6
        };


        TemplateParams__c tprm = new TemplateParams__c();
        tprm.TemplateMgmt__c = tmgt.Id;
        TemplateParams__c tp2 = tprm.clone(false);
        tp2.TemplateMgmt__c = tm2.Id;
        TemplateParams__c tp3 = tprm.clone(false);
        tp3.TemplateMgmt__c = tm3.Id;
        TemplateParams__c tp4 = tprm.clone(false);
        tp4.TemplateMgmt__c = tm4.Id;
        TemplateParams__c tp5 = tprm.clone(false);
        tp5.TemplateMgmt__c = tm5.Id;
        TemplateParams__c tp6 = tprm.clone(false);
        tp6.TemplateMgmt__c = tm6.Id;
        insert new List<TemplateParams__c>{
                tprm, tp2, tp3, tp4, tp5, tp6
        };

        EX_Message__c exMessage = new EX_Message__c();
        exMessage.Label1__c = 'test';
        exMessage.Label2__c = 'test';
        insert exMessage;

        Map<String, Object> mapSearchParam = new Map<String, Object>();
        mapSearchParam.put('ParentId', EX_TestDataUtil.getProductRequest(true).Id);
        mapSearchParam.put('Id', EX_TestDataUtil.getProductRequestLineItem(true).Id);

        EX_IntegrationOrderManagementController.doResendKakao(exMessage.Id, '결제URL재전송', JSON.serialize(mapSearchParam), '01012345678');

        EX_IntegrationOrderManagementController.doSaveTmpExMessageObj(JSON.serialize(mapSearchParam), '가상계좌재전송');
        EX_IntegrationOrderManagementController.doResendReturnRequest(new List<String>{
                exMessage.Id
        }, '반품요청', '', '01012345678');

        Test.stopTest();
    }
}