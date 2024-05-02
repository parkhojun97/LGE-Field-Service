/**
 * Created by I2MAX.SEUNGHUNAN on 2023-06-25.
 */

@IsTest
private class EX_Refund_ba_ts {
    @TestSetup
    static void setData(){
        EX_TestDataUtil.getReturnOrderLineItem(true);
        
        EX_TestDataUtil.getSrSale(false);
        EX_TestDataUtil.srSale.Order_Number__c = EX_TestDataUtil.baseReturnOrderLineItem.Order_Number__c;
        EX_TestDataUtil.getSrSale(true);
    }


    @IsTest
    static void testBehavior() {
        Test.startTest();
        List<SR_SALE__c> srSales = [
                SELECT Id, Order_Number__c 
                FROM SR_SALE__c
                LIMIT 1
        ];
        List<ReturnOrder> roList =  [
                SELECT ProductRequest.SR_SALE__c, ProductRequestId, Order_Number__c,ProductRequest.SALE_Amount__c,ProductRequest.Discount_Amount__c 
                FROM ReturnOrder
                LIMIT 1
        ];
        String basePrId = roList[0].ProductRequestId;
        List<ProductRequest> prs = [
                SELECT Id, SR_SALE__c, Order_Number__c 
                FROM ProductRequest
                WHERE Id = :basePrId
        ];
        prs[0].SR_SALE__c = srSales[0].Id;
        prs[0].Sale_Amount__c = 10000;
        prs[0].Discount_Amount__c = 0;
        update prs;
        srSales[0].Order_Number__c = prs[0].Order_Number__c;
        // update srSales;



        System.debug('prs ->' + prs[0]);

        Map<String, List<SR_AR_CONFIRM__c>> saleIdArConfirmMap = new Map<String, List<SR_AR_CONFIRM__c>>();
        List<ReturnOrder> roList2 =  [
                SELECT Id, ProductRequest.SR_SALE__c, ProductRequestId, Order_Number__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c, RETURN_PAYMENT_Amount__c, RETURN_CARD_PAYMENT_Amount__c,RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c,ProductRequest.Department_Code__c, ProductRequest.Department_Id__c,CONSIGNEE_Name__c ,ProductRequest.SALE_Amount__c,ProductRequest.Discount_Amount__c 
                FROM ReturnOrder
                LIMIT 1
        ];
        roList2[0].CONSIGNEE_Name__c = '테스트유저';
        update roList2[0];

        System.debug('roList2 -> ' + roList2);
        SR_AR_CONFIRM__c arConfirm = FN_TestDataFactory.getSrArConfirm(true);
        arConfirm.DEPOSIT_TYPE__c = 'B';
        update arConfirm;

        TriggerHandler.bypass('FN_SrPaymentBasis_tr');
        FN_TestDataFactory.objSrPaymentBasis.SR_SALE_ID__c = srSales[0].Id;
        update FN_TestDataFactory.objSrPaymentBasis;

        SR_AR_CONFIRM__c confirm = new SR_AR_CONFIRM__c();
        confirm.SR_PAYMENT_BASIS_ID__c = FN_TestDataFactory.objSrPaymentBasis.Id;
        confirm.DEPOSIT_TYPE__c = 'B';
        confirm.INVOICE_ISSUE_TYPE__c = 'C';
        confirm.DEPOSIT_AMT__c = -1000;
        // confirm.TID__c = EX_TestDataUtil.getSmartroPaymentRequest(true).TID__c;
        // EX_TestDataUtil.getPaymentGateway(false).DIV_CODE__c = 'PG카드_URL/가상계좌';
        // EX_TestDataUtil.getPaymentGateway(false).SM_DEPT__c = EX_TestDataUtil.baseProductRequest.Department_Id__c;
        // EX_TestDataUtil.getPaymentGateway(true);
        insert confirm;

        // SR_AR_CONFIRM__c arConfirmRed = 
        // arConfirmRed.DEPOSIT_AMT__c = -1000;
        // insert arConfirmRed;

        saleIdArConfirmMap.put(roList2[0].ProductRequest.SR_SALE__c, new List<SR_AR_CONFIRM__c>{
                arConfirm
        });


        List<ReturnOrder> returnOrders = [SELECT Id, RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c, ProductRequest.SR_SALE__c, ProductRequest.Department_Id__c, ProductRequest.Department_Code__c ,(SELECT Id, POINT_REFUND_Complete_YN__c,ETC_REFUND_Complete_YN__c FROM ReturnOrderLineItems) FROM ReturnOrder LIMIT 1];
        List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id ,POINT_TRX_ID__c, AR_INVOICE_NO__c, DEPOSIT_TYPE__c, TID__c,DEPOSIT_AMT__c ,UPAD_DETAIL_TYPE__c,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,FM_Order_Number__c FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];

        System.debug('ro dpt id> '  + returnOrders[0].ProductRequest.Department_Id__c);
        System.debug('ro dpt code> '  + returnOrders[0].ProductRequest.Department_Code__c);

        if(!returnOrders.isEmpty() && !srArConfirms.isEmpty()){
            srArConfirms[0].DEPOSIT_TYPE__c = 'A';
            Map<String, String> orderNumberMOIDMap = new Map<String, String>();
            Map<String, String> confirmIdTrxIdMap = new Map<String, String>();
            Map<String, Set<String>> roIdTrxIdSetMap = new Map<String, Set<String>>();
            Map<String, List<ReturnOrderLineItem>> roIdRoLiListMap = new Map<String, List<ReturnOrderLineItem>>();
            roIdRoLiListMap.put(returnOrders[0].Id, returnOrders[0].ReturnOrderLineItems);
            Map<String, ReturnOrderLineItem> kTrxIdRoLiMap = new Map<String, ReturnOrderLineItem>();
            Map<String, SM_DEPT__c> deptCodeMap = new Map<String, SM_DEPT__c>();
            for(SM_DEPT__c dep : [SELECT Id, DEPT_CODE__c FROM SM_DEPT__c]){
                deptCodeMap.put(dep.DEPT_CODE__c, dep);
            }
            Map<String, Object> paramMap = new Map<String, Object>();
            paramMap.put('orderNumberMOIDMap', orderNumberMOIDMap);
            paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
            paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
            paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
            paramMap.put('kTrxIdRoLiMap', kTrxIdRoLiMap);
            paramMap.put('deptCodeMap', deptCodeMap);

            paramMap.put('saleIdArConfirmMap',saleIdArConfirmMap);

            EX_Refund_ba refundBa = new EX_Refund_ba(roList2, paramMap);

            try{
                Database.executeBatch(refundBa);
            }catch(Exception e){
                system.debug(e.getMessage());
            }

        }
        Test.stopTest();
    }

    @IsTest
    static void testBehavior_02() {
        Test.startTest();
        List<SR_SALE__c> srSales = [
                SELECT Id, Order_Number__c 
                FROM SR_SALE__c
                LIMIT 1
        ];
        List<ReturnOrder> roList =  [
                SELECT ProductRequest.SR_SALE__c, ProductRequestId, Order_Number__c,ProductRequest.SALE_Amount__c,ProductRequest.Discount_Amount__c 
                FROM ReturnOrder
                LIMIT 1
        ];
        String basePrId = roList[0].ProductRequestId;
        List<ProductRequest> prs = [
                SELECT Id, SR_SALE__c, Order_Number__c 
                FROM ProductRequest
                WHERE Id = :basePrId
        ];
        prs[0].SR_SALE__c = srSales[0].Id;
        prs[0].Sale_Amount__c = 10000;
        prs[0].Discount_Amount__c = 0;
        update prs;
        srSales[0].Order_Number__c = prs[0].Order_Number__c;
        // update srSales;



        System.debug('prs ->' + prs[0]);

        Map<String, List<SR_AR_CONFIRM__c>> saleIdArConfirmMap = new Map<String, List<SR_AR_CONFIRM__c>>();
        List<ReturnOrder> roList2 =  [
                SELECT Id, ProductRequest.SR_SALE__c, ProductRequestId, Order_Number__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c, RETURN_PAYMENT_Amount__c, RETURN_CARD_PAYMENT_Amount__c,RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c,ProductRequest.Department_Code__c, ProductRequest.Department_Id__c,CONSIGNEE_Name__c ,ProductRequest.SALE_Amount__c,ProductRequest.Discount_Amount__c 
                FROM ReturnOrder
                LIMIT 1
        ];
        roList2[0].CONSIGNEE_Name__c = '테스트유저';
        update roList2[0];

        System.debug('roList2 -> ' + roList2);
        SR_AR_CONFIRM__c arConfirm = FN_TestDataFactory.getSrArConfirm(true);
        arConfirm.DEPOSIT_TYPE__c = 'B';
        update arConfirm;

        TriggerHandler.bypass('FN_SrPaymentBasis_tr');
        FN_TestDataFactory.objSrPaymentBasis.SR_SALE_ID__c = srSales[0].Id;
        update FN_TestDataFactory.objSrPaymentBasis;

        SR_AR_CONFIRM__c confirm = new SR_AR_CONFIRM__c();
        confirm.SR_PAYMENT_BASIS_ID__c = FN_TestDataFactory.objSrPaymentBasis.Id;
        confirm.DEPOSIT_TYPE__c = 'B';
        confirm.INVOICE_ISSUE_TYPE__c = 'C';
        confirm.DEPOSIT_AMT__c = -1000;
        // confirm.TID__c = EX_TestDataUtil.getSmartroPaymentRequest(true).TID__c;
        // EX_TestDataUtil.getPaymentGateway(false).DIV_CODE__c = 'PG카드_URL/가상계좌';
        // EX_TestDataUtil.getPaymentGateway(false).SM_DEPT__c = EX_TestDataUtil.baseProductRequest.Department_Id__c;
        // EX_TestDataUtil.getPaymentGateway(true);
        insert confirm;

        // SR_AR_CONFIRM__c arConfirmRed = 
        // arConfirmRed.DEPOSIT_AMT__c = -1000;
        // insert arConfirmRed;

        saleIdArConfirmMap.put('errorInduced', new List<SR_AR_CONFIRM__c>{
                arConfirm
        });


        List<ReturnOrder> returnOrders = [SELECT Id, RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c, ProductRequest.SR_SALE__c, ProductRequest.Department_Id__c, ProductRequest.Department_Code__c ,(SELECT Id, POINT_REFUND_Complete_YN__c,ETC_REFUND_Complete_YN__c FROM ReturnOrderLineItems) FROM ReturnOrder LIMIT 1];
        List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id ,POINT_TRX_ID__c, AR_INVOICE_NO__c, DEPOSIT_TYPE__c, TID__c,DEPOSIT_AMT__c ,UPAD_DETAIL_TYPE__c,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,FM_Order_Number__c FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];

        System.debug('ro dpt id> '  + returnOrders[0].ProductRequest.Department_Id__c);
        System.debug('ro dpt code> '  + returnOrders[0].ProductRequest.Department_Code__c);

        if(!returnOrders.isEmpty() && !srArConfirms.isEmpty()){
            srArConfirms[0].DEPOSIT_TYPE__c = 'A';
            Map<String, String> orderNumberMOIDMap = new Map<String, String>();
            Map<String, String> confirmIdTrxIdMap = new Map<String, String>();
            Map<String, Set<String>> roIdTrxIdSetMap = new Map<String, Set<String>>();
            Map<String, List<ReturnOrderLineItem>> roIdRoLiListMap = new Map<String, List<ReturnOrderLineItem>>();
            roIdRoLiListMap.put(returnOrders[0].Id, returnOrders[0].ReturnOrderLineItems);
            Map<String, ReturnOrderLineItem> kTrxIdRoLiMap = new Map<String, ReturnOrderLineItem>();
            Map<String, SM_DEPT__c> deptCodeMap = new Map<String, SM_DEPT__c>();
            for(SM_DEPT__c dep : [SELECT Id, DEPT_CODE__c FROM SM_DEPT__c]){
                deptCodeMap.put(dep.DEPT_CODE__c, dep);
            }
            Map<String, Object> paramMap = new Map<String, Object>();
            paramMap.put('orderNumberMOIDMap', orderNumberMOIDMap);
            paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
            paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
            paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
            paramMap.put('kTrxIdRoLiMap', kTrxIdRoLiMap);
            paramMap.put('deptCodeMap', deptCodeMap);

            paramMap.put('saleIdArConfirmMap',saleIdArConfirmMap);

            EX_Refund_ba refundBa = new EX_Refund_ba(roList2, paramMap);

            try{
                Database.executeBatch(refundBa);
            }catch(Exception e){
                system.debug(e.getMessage());
            }

        }
        Test.stopTest();
    }    
}