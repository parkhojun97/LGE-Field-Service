/**
 * Created by MS on 2023-04-27.
 */

@IsTest
private class EX_ConsumablesOrderManagementCntrlr_ts {




    @IsTest
    static void test01() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

        EX_TestDataUtil.getDept(false, null);
        EX_TestDataUtil.dept.CLOSE_YN__c = 'N';
        EX_TestDataUtil.dept.DEPT_TYPE_FIRST__c = 'B';
        EX_TestDataUtil.dept.DEPT_TYPE_SECOND__c = 'D';
        EX_TestDataUtil.getDept(true, null);

        EX_ConsumablesOrderManagementController.doGetInitData();

        ServiceResource sr = new ServiceResource();
        sr.Name = 'test ccc';
        sr.RelatedRecordId = UserInfo.getUserId();
        sr.SM_DEPT__c = EX_TestDataUtil.getDept(true, null).Id;
        sr.RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('SE').getRecordTypeId();
        sr.JOB_TYPE__c = 'A70';
        insert sr;

        try {
            EX_ConsumablesOrderManagementController.doGetServiceResource();
            EX_ConsumablesOrderManagementController.doGetEmpInfo();

        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        EX_TestDataUtil.getProductRequest(false);
        EX_TestDataUtil.baseProductRequest.Order_CHNL_TYPE_Code__c = 'V';
        EX_TestDataUtil.baseProductRequest.Order_Date__c = Datetime.now();
        EX_TestDataUtil.baseProductRequest.Order_CUST_Id__c = EX_TestDataUtil.getContact(true).Id;
        EX_TestDataUtil.baseProductRequest.CONSIGNEE_TPNO_1__c = '3242324';
        EX_TestDataUtil.baseProductRequest.CONSIGNEE_Name__c = 'test aa';
        EX_TestDataUtil.baseProductRequest.CNSL_Department_Code__c = 'test32';
        EX_TestDataUtil.baseProductRequest.PAYMENT_Method_Code__c = 'CARD';
        EX_TestDataUtil.baseProductRequest.CARD_PAYMENT_Amount__c = 0;
        EX_TestDataUtil.baseProductRequest.PAYMENT_TYPE__c ='URL';
        EX_TestDataUtil.getProductRequestLineItem(false).SUB_Order_Number__c = '01-33-32';
        EX_TestDataUtil.baseProductRequestLineItem.Consumables_Order_DETAIL__c = '003';
        Map<String, Object> mapSearchParam = new Map<String, Object>();
        mapSearchParam.put('orderNo', EX_TestDataUtil.getProductRequestLineItem(true).Order_Number__c);
        mapSearchParam.put('recordLimit',1);
        mapSearchParam.put('pageOffset', 0);
        mapSearchParam.put('isSearchBtnClick',true);
        EX_ConsumablesOrderManagementController.doGetSearchData(mapSearchParam);


        EX_TestDataUtil.baseProductRequest.Order_CHNL_TYPE_Code__c = 'B';
        EX_TestDataUtil.baseProductRequest.Consumables_Business_Type_Code__c = 'ExchangeOrder';
        EX_TestDataUtil.baseProductRequest.PAYMENT_TYPE__c = 'OBS-NB';
        update EX_TestDataUtil.baseProductRequest;
        mapSearchParam.remove('orderNo');
        mapSearchParam.put('orderChannel', 'B');
        mapSearchParam.put('orderStatus', '002');
        mapSearchParam.put('contactName', EX_TestDataUtil.getContact(true).LastName);
        mapSearchParam.put('contactPhone', EX_TestDataUtil.getContact(true).MobilePhone);
        mapSearchParam.put('consigneePhone', EX_TestDataUtil.baseProductRequest.CONSIGNEE_TPNO_1__c);
        mapSearchParam.put('consigneePhone', EX_TestDataUtil.baseProductRequest.CONSIGNEE_Name__c);
        mapSearchParam.put('partNo', EX_TestDataUtil.baseProductRequestLineItem.PART_NO__c);
        mapSearchParam.put('baseDateEnd', String.valueOf(Date.today().addDays(1)));
        mapSearchParam.put('baseDateStart', String.valueOf(Date.today().addDays(-1)));
        mapSearchParam.put('CNSLUser', UserInfo.getName());
        mapSearchParam.put('CNSLDiv',EX_TestDataUtil.baseProductRequest.CNSL_Department_Code__c );
        EX_ConsumablesOrderManagementController.doGetSearchData(mapSearchParam);

        EX_TestDataUtil.baseProductRequest.Order_CHNL_TYPE_Code__c = 'S';
        EX_TestDataUtil.baseProductRequest.Consumables_Business_Type_Code__c = 'Order';
        EX_TestDataUtil.baseProductRequest.PAYMENT_TYPE__c = 'THINQ-2';
        update EX_TestDataUtil.baseProductRequest;
        mapSearchParam.put('orderChannel', 'S');
        EX_ConsumablesOrderManagementController.doGetSearchData(mapSearchParam);

        EX_ConsumablesOrderManagementController.doGetOrderLineItemData(EX_TestDataUtil.baseProductRequest.Id ,true);
        EX_TestDataUtil.getReturnOrderLineItem(false).Consumables_Order_YN__c = TRUE;
        EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Business_Type_Code__c = 'Return';
        EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Class_Code__c = 'General';
        EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '030';
        EX_TestDataUtil.baseReturnOrderLineItem.FFMT_Order_Transfer_YN__c = true;
        EX_TestDataUtil.baseReturnOrderLineItem.SUB_Order_Number__c = '01-33-32';
        EX_TestDataUtil.getReturnOrderLineItem(true);
        EX_ConsumablesOrderManagementController.doGetOrderLineItemData(EX_TestDataUtil.baseReturnOrder.Id ,true);


        EX_TestDataUtil.baseProductRequest.PAYMENT_YN__c = TRUE;
        update EX_TestDataUtil.baseProductRequest;
        EX_TestDataUtil.baseProductRequestLineItem.Consumables_Order_Status__c = '121';
        EX_TestDataUtil.baseProductRequestLineItem.PAYMENT_YN__c = true;
        update EX_TestDataUtil.baseProductRequestLineItem;

        EX_ConsumablesOrderManagementController.doGetOrderLineItemData(EX_TestDataUtil.baseProductRequest.Id ,true);
        EX_ConsumablesOrderManagementController.doGetOrderLineItemData(EX_TestDataUtil.baseReturnOrder.Id ,true);

        EX_ConsumablesOrderManagementController.doGetConsumableOrderData(EX_TestDataUtil.baseProductRequest.Order_Number__c);

        List<BusinessHours> bzHours = [SELECT Id FROM BusinessHours LIMIT 1];
        if(!bzHours.isEmpty()){
            Case nCase = new Case();
            nCase.BusinessHoursId = bzHours[0].Id;
            insert nCase;
            EX_ConsumablesOrderManagementController.doGetCaseByCaseId(nCase.Id);

            mapSearchParam = new Map<String, Object>();
            mapSearchParam.put('Id', EX_TestDataUtil.baseProductRequest.Id);
            mapSearchParam.put('CONSIGNEE_Name__c', 'test aa');
            mapSearchParam.put('CONSIGNEE_TPNO_1__c', '03241412');
            mapSearchParam.put('CONSIGNEE_Address__c', 'test');
            mapSearchParam.put('CONSIGNEE_Address_DETAIL__c', 'test');
            mapSearchParam.put('Delivery_Message_CONTENT__c', 'test');
            mapSearchParam.put('Description', 'test');
            mapSearchParam.put('CaseId', nCase.Id);
            EX_ConsumablesOrderManagementController.doUpdateConsumableOrderData(mapSearchParam, 'test');
        }

        EX_TestDataUtil.baseProductRequest.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
        EX_TestDataUtil.baseProductRequest.Order_CHNL_TYPE_Code__c = 'V';
        EX_TestDataUtil.baseProductRequest.CASH_DEPOSIT_YN__c = 'A';
        EX_TestDataUtil.baseProductRequest.PAYMENT_Amount__c = 30000;
        EX_TestDataUtil.baseProductRequest.POINT_Amount__c = 500;
        EX_TestDataUtil.baseProductRequest.LIMIT_TM__c = Datetime.now();
        EX_TestDataUtil.baseProductRequest.CNSL_Department_Id__c = EX_TestDataUtil.getDept(true,null).Id;
        update EX_TestDataUtil.baseProductRequest;

        SM_DEPT__c highDept = EX_TestDataUtil.dept.clone(false);
        highDept.DEPT_CODE__c = 'PH0006';
        highDept.Name = System.Label.EX_Location;
        insert highDept;
        EX_TestDataUtil.dept.HIGH_DEPT_CODE__c = highDept.Id;
        EX_TestDataUtil.dept.DEPT_TYPE_SECOND__c = 'E';
        EX_TestDataUtil.dept.CLOSE_YN__c = 'N';
        update EX_TestDataUtil.dept;

        EX_ConsumablesOrderManagementController.getInitData();
        EX_ConsumablesOrderManagementController.getCenterData(highDept.Name);
        EX_ConsumablesOrderManagementController.getSEData(highDept.Name, EX_TestDataUtil.dept.Name);
        
        EX_ConsumablesOrderManagementController.doGetOrderLineItemDataByReturnRequest(EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c);

        Test.stopTest();
    }

    @IsTest
    static void test02() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        
        TemplateMgmt__c tmgt = new TemplateMgmt__c();
        tmgt.Content_c__c = 'teststests';
        tmgt.Title__c = 'testsetse';
        // tmgt.TemplateCode__c = 'SVC_LGE_MACN_012_01';
        tmgt.TemplateCode__c = 'SVC_LGE_MACN_012_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
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
        insert new List<TemplateMgmt__c>{tmgt, tm2, tm3, tm4, tm5,tm6};


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
        insert new List<TemplateParams__c>{tprm, tp2, tp3, tp4, tp5, tp6};

        EX_Message__c exMessage = new EX_Message__c();
        exMessage.Label1__c = 'test';
        exMessage.Label2__c = 'test';
        insert exMessage;

        Map<Object, Object> selectedCashDepositRows = new Map<Object, Object>();
        selectedCashDepositRows.put('Name', 'testaa');
        selectedCashDepositRows.put('DepositAmount', '30000');
        selectedCashDepositRows.put('VirtualBankNum', '324342343252');
        selectedCashDepositRows.put('BankName', 'shinhan');
        try {
            EX_ConsumablesOrderManagementController.doSendSms(selectedCashDepositRows);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        Map<String, Object> paramMap = new Map<String, Object>();
        EX_TestDataUtil.getProductRequest(false).Payment_URL__c = 'dfasdfdasfa';
        paramMap.put('ParentId',EX_TestDataUtil.getProductRequest(true).Id );
        
        EX_ConsumablesOrderManagementController.doResend(exMessage.Id,'가상계좌재전송',JSON.serialize(paramMap),'01012345678');
        EX_ConsumablesOrderManagementController.doResend(exMessage.Id,'결제URL재전송',JSON.serialize(paramMap),'01012345678');
    // EX_ConsumablesOrderManagementController.doResend(exMessage.Id,'반품요청',JSON.serialize(paramMap),'01012345678');
    //  EX_ConsumablesOrderManagementController.doResend(exMessage.Id,'주문 취소',JSON.serialize(paramMap),'01012345678');
    //  EX_ConsumablesOrderManagementController.doResend(exMessage.Id,'SMS재전송',JSON.serialize(paramMap),'01012345678');
        EX_ConsumablesOrderManagementController.doResendReturnRequest(new List<String>{exMessage.Id},'반품요청','','01012345678');
        EX_ConsumablesOrderManagementController.tmplCodeMapInit(new Map<String, String>());

        Map<String, Object> mapSearchParam = new Map<String, Object>();
        mapSearchParam.put('ParentId',EX_TestDataUtil.getProductRequest(true).Id);
        mapSearchParam.put('Id',EX_TestDataUtil.getProductRequestLineItem(true).Id);
        EX_ConsumablesOrderManagementController.doSaveTmpExMessageObj(JSON.serialize(mapSearchParam),'가상계좌재전송');
        EX_TestDataUtil.baseProductRequestLineItem.PART_DESC_KOR__c = 'dfasdf';
        update EX_TestDataUtil.baseProductRequestLineItem;
        EX_ConsumablesOrderManagementController.doSaveTmpExMessageObj(JSON.serialize(mapSearchParam),'결제URL재전송');
        EX_TestDataUtil.baseProduct.PART_DESC_KOR__c = 'dafdf';
        update EX_TestDataUtil.baseProduct;
        EX_ConsumablesOrderManagementController.doSaveTmpExMessageObj(JSON.serialize(mapSearchParam),'SMS재전송');
        EX_ConsumablesOrderManagementController.doSaveTmpExMessageObj(JSON.serialize(mapSearchParam),'주문 취소');

        Test.stopTest();
    }

    @IsTest
    static void test03(){
        Test.startTest();
        EX_TestDataUtil.getReturnOrderLineItem(false).Consumables_Order_Status__c = '030';
        EX_ConsumablesOrderManagementController.getRoliDeliveryNoList(EX_TestDataUtil.getReturnOrderLineItem(true));
        SR_ONLINE_DELIVERY_INFO__c deliveryInfo = new SR_ONLINE_DELIVERY_INFO__c();
        deliveryInfo.ProductRequestLineItem__c = EX_TestDataUtil.getProductRequestLineItem(true).Id;
        deliveryInfo.ReturnOrderLineItem__c = EX_TestDataUtil.getReturnOrderLineItem(true).Id;
        insert new List<SR_ONLINE_DELIVERY_INFO__c>{deliveryInfo, deliveryInfo.clone(false)};
        EX_ConsumablesOrderManagementController.getRoliDeliveryNoList(EX_TestDataUtil.getReturnOrderLineItem(true));

        EX_ConsumablesOrderManagementController.getDeliveryNoList(new List<String>{EX_TestDataUtil.getProductRequestLineItem(true).Id}, null);
        EX_ConsumablesOrderManagementController.getDeliveryNoList(null, new List<String>{EX_TestDataUtil.getReturnOrderLineItem(true).Id});

        EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Class_Code__c = 'General';
        EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Business_Type_Code__c = 'ExchangeReturn';
        EX_TestDataUtil.baseReturnOrderLineItem.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
        update EX_TestDataUtil.baseReturnOrderLineItem;
        
        EX_ConsumablesOrderManagementController.getreturnOrderLineItem(EX_TestDataUtil.getProductRequestLineItem(true));

        EX_ConsumablesOrderManagementController.getProliDeliveryNoListwithId(EX_TestDataUtil.getProductRequestLineItem(true).Id);

        EX_ConsumablesOrderManagementController.getProliDeliveryNoList(EX_TestDataUtil.getProductRequestLineItem(true));

        Map<String, Object> paramMap = new Map<String, Object>();
        List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable> table = new List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable>();
        EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable item = new EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable();
        item.PartNameKOR = 'dasf';
        item.OrderNumber = 'daadfdafsf';
        table.add(item);
        Map<Object, Object> contactConsigneeInfoMap = new Map<Object, Object>();
        contactConsigneeInfoMap.put('ContactName', 'testsedts');
        paramMap.put('productRequestLineItemsByReturnRequest', JSON.serialize(table));
        paramMap.put('contactConsigneeInfo', contactConsigneeInfoMap);
        paramMap.put('orderType', 'return');
        EX_ConsumablesOrderManagementController.doSendKakaoMessage(paramMap);

        EX_ConsumablesOrderManagementController.ConsumableOrderTable cot1 = new EX_ConsumablesOrderManagementController.ConsumableOrderTable();
        cot1.OrderDate = Datetime.now();
        EX_ConsumablesOrderManagementController.ConsumableOrderTable cot2 = new EX_ConsumablesOrderManagementController.ConsumableOrderTable();
        cot2.OrderDate = Datetime.newInstance(2022, 1, 1);
        cot1.compareTo(cot2);

        EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable colt1 = new EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable();
        colt1.SubNumber = '01-92';
        colt1.OrderDate = Datetime.now();
        colt1.CancelRequestedDate = Datetime.now();
        colt1.ExchangeRequestedDate = Datetime.now();
        colt1.CJOrderSendDate = Datetime.now();
        colt1.RequestedDate = Datetime.now();
        colt1.SalesDate = Datetime.now();
        colt1.PaymentDate = Datetime.now();
        colt1.ReturnApprovedDate = Datetime.now();
        colt1.DeliveryDate = Datetime.now();
        colt1.ShipmentDate = Datetime.now();
        colt1.ReturnRequestedDate = Datetime.now();

        colt1.ExchangeQuantity = 1;
        colt1.ExpectedReturnQuantity = 1;
        colt1.QuantityRequested = 1;
        colt1.EstimatedPaymentAmount = 1;
        colt1.CustomerPrice = 1;
        colt1.RequestedQuantity = 1;
        colt1.SalesQuantity = 1;
        colt1.SaleAmount = 1;
        colt1.PaymentAmount = 1;
        colt1.DiscountAmount = 1;
        colt1.CardAmount = 1;
        colt1.CashAmount = 1;
        colt1.PointAmount = 1;
        colt1.OrderSEQ = 1;
        colt1.CaseURL = 'test';
        colt1.CaseNumber = 'test';
        colt1.RSRV_Number = 'test';
        colt1.Location = 'test';
        colt1.ParentId = 'test';
        colt1.AppointmentStatus = 'test';
        colt1.CancelColor = 'test';
        colt1.ExchangeColor = 'test';
        colt1.ReturnColor = 'test';
        colt1.DeliveryColor = 'test';
        colt1.CancelDepartment = 'test';
        colt1.ExchangeRequesterDepartment = 'test';
        colt1.ExchangeRequester = 'test';
        colt1.CONSIGNEE_Phone = 'test';
        colt1.CONSIGNEE_Name = 'test';
        colt1.CustomerPhone = 'test';
        colt1.CustomerName = 'test';
        colt1.MOID = 'test';
        colt1.TID = 'test';
        colt1.POINT_TRX_ID = 'test';
        colt1.PartStatus = 'test';
        colt1.ReturnApprovedReason = 'test';
        colt1.ReturnApprover = 'test';
        colt1.ReturnRequestReason = 'test';
        colt1.ReturnRequester = 'test';
        colt1.ReturnRequesterEmployeeNumber = 'test';
        colt1.CancelRequesterEmployeeNumber = 'test';
        colt1.CancelRequester = 'test';
        colt1.CancelRequestReason = 'test';
        colt1.DeliveryCompany = 'test';
        colt1.DeliveryStatus = 'test';
        colt1.CJOrderSendYN = 'test';
        colt1.CJOrderNumber = 'test';
        colt1.SalesNumber = 'test';
        colt1.PayMethod = 'test';
        colt1.DiscountType = 'test';
        colt1.ShippedDepartment = 'test';
        colt1.RequestedPartNo = 'test';
        colt1.ReceivedPartNo = 'test';
        colt1.SubstituteYN = 'test';
        colt1.PartiallyReceived = 'test';
        colt1.AppointmentStatus = 'test';
        colt1.DIV = 'test';
        colt1.PartNameKOR = 'test';
        colt1.PartName = 'test';
        colt1.Model = 'test';
        colt1.ConsumablesBusinessTypeCode = 'test';
        colt1.OrderChannel = 'test';
        colt1.OrderNumber = 'test';
        colt1.OrderStatus = 'test';
        colt1.OrderStatusDetail = 'test';
        colt1.TrackingNumber = 'test';
        
        EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable colt2 = new EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable();
        colt2.SubNumber = '01-91';
        colt1.compareTo(colt2);

        EX_ConsumablesOrderManagementController.CashDepositTable cdt = new EX_ConsumablesOrderManagementController.CashDepositTable();
        cdt.OrderNumber = '34243';
        cdt.Name = '34243';
        cdt.BankName = '34243';
        cdt.ConsigneePhoneNum = '34243';
        cdt.VirtualBankNum = '34243';
        cdt.DepositStatus = '34243';
        cdt.DepositAmount = 1;
        cdt.DepositStatus = '34243';
        cdt.ApprovalNumber = '34243';
        cdt.DeptName = '34243';
        cdt.ChiefName = '34243';
        cdt.DepositDate = Datetime.now();
        cdt.CreatedDate = Datetime.now();
        Test.stopTest();
    }

    @IsTest
    static void test04() {
        EX_TestDataUtil.getProductRequestLineItem(true);
        EX_TestDataUtil.getReturnOrderLineItem(true);
        EX_TestDataUtil.getContact(true);
        SM_DEPT__c highDept = EX_TestDataUtil.dept.clone(false);
        highDept.DEPT_CODE__c = 'PH0006';
        highDept.Name = System.Label.EX_Location;
        highDept.DEPT_NAME__c = highDept.Name;
        insert highDept;

        EX_TestDataUtil.dept.HIGH_DEPT_CODE__c = highDept.Id;
        EX_TestDataUtil.dept.DEPT_NAME__c = EX_TestDataUtil.dept.Name;
        update EX_TestDataUtil.dept;

        EX_TestDataUtil.baseProductRequest.Order_CHNL_TYPE_Code__c  = 'V';
        EX_TestDataUtil.baseProductRequest.CNSL_Department_Id__c = EX_TestDataUtil.dept.Id;
        EX_TestDataUtil.baseProductRequest.Order_CUST_Id__c = EX_TestDataUtil.baseContact.Id;
        EX_TestDataUtil.baseProductRequest.CASH_DEPOSIT_YN__c = 'A';
        update EX_TestDataUtil.baseProductRequest;

        Map<String, Object> mapSearchParam = new Map<String, Object>();
        mapSearchParam.put('initialEDate', String.valueOf(Date.today().addDays(1)));
        mapSearchParam.put('initialSDate', String.valueOf(Date.today().addDays(-1)));
        mapSearchParam.put('teamName', highDept.Name);
        mapSearchParam.put('centerName', EX_TestDataUtil.dept.Name);
        mapSearchParam.put('SE', UserInfo.getName());
        mapSearchParam.put('payment', EX_TestDataUtil.baseContact.LastName);
        mapSearchParam.put('orderNo', EX_TestDataUtil.baseProductRequest.Order_Number__c);
        mapSearchParam.put('DepositY',true);
        mapSearchParam.put('DepositN',false);
        mapSearchParam.put('DepositNone',false);
        Test.startTest();
        EX_ConsumablesOrderManagementController.doSearchCashDepositRequests(mapSearchParam);
        EX_TestDataUtil.baseProductRequest.CASH_DEPOSIT_YN__c = 'B';
        update EX_TestDataUtil.baseProductRequest;
        EX_ConsumablesOrderManagementController.doSearchCashDepositRequests(mapSearchParam);
        EX_TestDataUtil.baseProductRequest.CASH_DEPOSIT_YN__c = 'C';
        update EX_TestDataUtil.baseProductRequest;
        EX_ConsumablesOrderManagementController.doSearchCashDepositRequests(mapSearchParam);
        Test.stopTest();
    }

    @IsTest
    static void test_doCancel() {
        insert new PaymentAPISetting_cs__c[]{
                new PaymentAPISetting_cs__c(Name = 'CancelApproval', ApiKey__c = 'ApiKey', EndPoint__c = 'EndPoint'),
                new PaymentAPISetting_cs__c(Name = 'SpendOrCancelPoint', ApiKey__c = 'ApiKey', EndPoint__c = 'EndPoint'),
                new PaymentAPISetting_cs__c(Name = 'CancelCardUrl', ApiKey__c = 'ApiKey', EndPoint__c = 'EndPoint'),
                new PaymentAPISetting_cs__c(Name = 'RefundCashFromVirtualAccount', ApiKey__c = 'ApiKey', EndPoint__c = 'EndPoint')
        };
        ProductRequestLineItem lineItem = EX_TestDataUtil.getProductRequestLineItem(true);
        insert new SR_SMARTRO_PAYMENT_REQUEST__c(SMARTRO_PAYMENT_REQUEST_PK__c = '1', MOID__c = 'MOID', PAYMENT_TYPE__c = 'PG_URL');

        Map<String, Object> jsonString = new Map<String, Object>();
        jsonString.put('Test','Test');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCancelMockCalloutMock());
        try{
            EX_ConsumablesOrderManagementController.doCancel('strCaseId','remark', new List<Object>{new Map<String, Object>{'SalesNumber' => 'SalesNumber', 'RSRV_Number' => 'RSRV_Number', 'DiscountType' => 'DiscountType', 'CancelQuantity' => 1, 'QuantityRequested' => 1000, 'PointAmount' => 1000, 'OrderStatus' => '결제요청', 'PayMethod' => '현금입금', 'QuantityRequested' => 1000, 'Id' => lineItem.Id}}, new List<Object>{new Map<String, Object>{'QuantityRequested' => 1000, 'Id' => lineItem.Id}}, new List<Object>{new Map<String, Object>{'OrderChannel' => '소모품택배', 'MOID' => 'MOID'}}, '','','',JSON.serialize(jsonString),'');
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }


    @IsTest
    static void test_doRequestReturnOrder() {
        Test.startTest();
        try{
            EX_ConsumablesOrderManagementController.doRequestReturnOrder(new Map<String, Object>{});
        }catch(Exception e){
            System.debug(e.getMessage());

        }
        Test.stopTest();
    }

    @IsTest
    static void test_doCheckBankAccount() {
        Test.startTest();
        try{
            EX_ConsumablesOrderManagementController.doCheckBankAccount('test','test','test',new List<Object>{});
        }catch(Exception e){
            System.debug(e.getMessage());

        }
        Test.stopTest();
    }

    @IsTest
    static void test_doGetPaymentAmount() {
        EX_TestDataUtil.getPrePaymentDetail(true);
        Test.startTest();
        EX_ConsumablesOrderManagementController.doGetPaymentAmount(new Map<String, Object>{'prId' => EX_TestDataUtil.prePaymentHeader.ATTR_RECORD_ID__c});
        EX_TestDataUtil.prePaymentDetail.DEPOSIT_TYPE__c = 'B';
        update EX_TestDataUtil.prePaymentDetail;
        EX_ConsumablesOrderManagementController.doGetPaymentAmount(new Map<String, Object>{'prId' => EX_TestDataUtil.prePaymentHeader.ATTR_RECORD_ID__c});
        EX_TestDataUtil.prePaymentDetail.DEPOSIT_TYPE__c = 'D';
        update EX_TestDataUtil.prePaymentDetail;
        EX_ConsumablesOrderManagementController.doGetPaymentAmount(new Map<String, Object>{'prId' => EX_TestDataUtil.prePaymentHeader.ATTR_RECORD_ID__c});
        EX_TestDataUtil.prePaymentDetail.DEPOSIT_TYPE__c = 'E';
        EX_TestDataUtil.prePaymentDetail.UPAD_DETAIL_TYPE__c = 'PG_URL';
        update EX_TestDataUtil.prePaymentDetail;
        EX_ConsumablesOrderManagementController.doGetPaymentAmount(new Map<String, Object>{'prId' => EX_TestDataUtil.prePaymentHeader.ATTR_RECORD_ID__c});

        Test.stopTest();
    }

    @IsTest
    static void test_fndoUpdate() {
        EX_TestDataUtil.getPrePaymentDetail(true);
        EX_TestDataUtil.getProductRequest(true);
        EX_TestDataUtil.getProductRequestLineItem(true);
        EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable table = new EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable();
        table.ParentId = EX_TestDataUtil.baseProductRequest.Id;
        table.Id = EX_TestDataUtil.baseProductRequestLineItem.Id;
        table.CardAmount = 1000;
        table.CashAmount = 1000;
        table.DIV = 'DLZ';
        table.DiscountType = 'test';

        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('orderDataList', JSON.serialize(new List<EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable>{table}));
        paramMap.put('standardOrderData', JSON.serialize(new List<EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable>{table}));
        EX_ConsumablesOrderManagementController.doGetManagementData(paramMap);
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCancelMockCalloutMock());
        try{
            TriggerHandler.bypass('ProductRequest_tr');
            EX_ConsumablesOrderManagementController.fndoUpdate(paramMap);
        }catch(Exception e){
            System.debug(e.getMessage());
        }

        SR_PRE_PAYMENT_DETAIL__c sr = [SELECT MOID__c, CARD_URL__c, ISSUE_CARD_INFO__c, ISSUE_CARD_NAME__c, INVOICE_ISSUE_TYPE__c, ID, PAY_CUST_PHONE__c, CERTIFY_KEY__c, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c, MID__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
        sr.DEPOSIT_TYPE__c = 'B';
        update sr;
        try{
            TriggerHandler.bypass('ProductRequest_tr');
            EX_ConsumablesOrderManagementController.fndoUpdate(paramMap);
        }catch(Exception e){
            System.debug(e.getMessage());
        }

        SR_PRE_PAYMENT_DETAIL__c sr2 = [SELECT MOID__c, CARD_URL__c, ISSUE_CARD_INFO__c, ISSUE_CARD_NAME__c, INVOICE_ISSUE_TYPE__c, ID, PAY_CUST_PHONE__c, CERTIFY_KEY__c, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c, MID__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
        sr2.DEPOSIT_TYPE__c = 'E';
        update sr2;
        try{
            TriggerHandler.bypass('ProductRequest_tr');
            EX_ConsumablesOrderManagementController.fndoUpdate(paramMap);
        }catch(Exception e){
            System.debug(e.getMessage());
        }

        SR_PRE_PAYMENT_DETAIL__c sr3 = [SELECT MOID__c, CARD_URL__c, ISSUE_CARD_INFO__c, ISSUE_CARD_NAME__c, INVOICE_ISSUE_TYPE__c, ID, PAY_CUST_PHONE__c, CERTIFY_KEY__c, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c, MID__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
        sr3.DEPOSIT_TYPE__c = 'D';
        update sr3;
        try{
            TriggerHandler.bypass('ProductRequest_tr');
            EX_ConsumablesOrderManagementController.fndoUpdate(paramMap);
        }catch(Exception e){
            System.debug(e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void test_fnGetContactInfo() {
        EX_TestDataUtil.getContact(true);
        Test.startTest();
        EX_ConsumablesOrderManagementController.fnGetContactInfo(EX_TestDataUtil.baseContact.Id);
        Test.stopTest();
    }


    @IsTest
    static void test_moreLoadValid() {
        EX_TestDataUtil.getContact(true);
        Test.startTest();
        EX_ConsumablesOrderManagementController.moreLoadValid(100,100,100);
        Test.stopTest();
    }

    @IsTest
    static void test_doGetManagementData() {
        Test.startTest();
        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('standardOrderData',null);
        try{
            EX_ConsumablesOrderManagementController.doGetManagementData(paramMap);
        }catch(Exception e){
            system.debug(e.getMessage());
        }
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

//  // 23.08.09 
//  private class TestHttpCalloutMock implements HttpCalloutMock {
//      private Integer statusCode;
//      private Boolean isSUCCESS;
//      private TestHttpCalloutMock(Integer statusCode, Boolean isSUCCESS) {
//          this.statusCode = statusCode;
//          this.isSUCCESS = isSUCCESS;
//      }
//      public HTTPResponse respond(HTTPRequest request) {
//          HttpResponse response = newResponse2(statusCode, isSUCCESS);
//          return response;
//      } 
//  }

//  private static HTTPResponse newResponse2(Integer statusCode, Boolean isSUCCESS) {
//      HttpResponse response = new HttpResponse();
//      response.setStatusCode(statusCode);
//      if(isSUCCESS) {
//          response.setBody('{"messages":[{"to":{"phoneNumber":"820100001111"},"status":{"groupId":1,"groupName":"testGroupName","id":7,"name":"testName","description":"Message sent to next instance"},"messageId":"testMessageId"}]}');   
//      } else {
//          response.setBody('fail');    
//      }
//      return response;
//  }
}