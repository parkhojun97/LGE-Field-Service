/**
 * Created by MS on 2023-04-28.
 */

 @IsTest
 private class EX_ReturnConfirmQueueable_ts {
 
     @TestSetup
     static void setup(){
         Test.startTest();
         IF_Master__c listIFMaster = new IF_Master__c();
         listIFMaster.Method__c = 'POST';
         listIFMaster.Endpoint__c ='https://apigw-ext.lge.com:7211/gateway/singlexsvc/api2db/gerp/RequestToBank';
         listIFMaster.APIKeyName__c ='x-Gateway-APIKey';
         listIFMaster.APIKeyValue__c = 'e783d29a-a6f0-41c2-a853-e88e2f6c7109';
         listIFMaster.IfId__c = 'IF_FS_SFDC_GERP_NEW_784';
         insert listIFMaster;
 
 
         EX_TestDataUtil.getProductRequest(false).SR_SALE__c = EX_TestDataUtil.getSrSale(true).Id;
         EX_TestDataUtil.getReturnOrderLineItem(true);
         EX_TestDataUtil.getSmartroPaymentRequest(false).PAYMETHOD__c = 'CARD';
         EX_TestDataUtil.srSale.Order_Number__c = EX_TestDataUtil.baseProductRequest.Order_Number__c;
         update EX_TestDataUtil.srSale;
         
         SR_PAYMENT_BASIS__c basis = new SR_PAYMENT_BASIS__c();
         basis.BASIS_NO__c = EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c;
         basis.SR_SALE_ID__c = EX_TestDataUtil.srSale.Id;
         insert basis;
         SR_AR_CONFIRM__c confirm = new SR_AR_CONFIRM__c();
         confirm.SR_PAYMENT_BASIS_ID__c = basis.Id;
         confirm.DEPOSIT_TYPE__c = 'B';
         confirm.INVOICE_ISSUE_TYPE__c = 'B';
         confirm.DEPOSIT_AMT__c = 30000;
         confirm.TID__c = EX_TestDataUtil.getSmartroPaymentRequest(true).TID__c;
         EX_TestDataUtil.getPaymentGateway(false).DIV_CODE__c = 'PG카드_URL/가상계좌';
         EX_TestDataUtil.getPaymentGateway(false).SM_DEPT__c = EX_TestDataUtil.baseProductRequest.Department_Id__c;
         EX_TestDataUtil.getPaymentGateway(true);
         insert confirm;
 
         SR_AR_CONFIRM__c confirm2 = new SR_AR_CONFIRM__c();
         confirm2.SR_PAYMENT_BASIS_ID__c = basis.Id;
         confirm2.DEPOSIT_TYPE__c = 'B';
         confirm2.INVOICE_ISSUE_TYPE__c = 'B';
         confirm2.DEPOSIT_AMT__c = -30000;
         confirm2.TID__c = EX_TestDataUtil.getSmartroPaymentRequest(true).TID__c;
         EX_TestDataUtil.getPaymentGateway(false).DIV_CODE__c = 'PG카드_URL/가상계좌';
         EX_TestDataUtil.getPaymentGateway(false).SM_DEPT__c = EX_TestDataUtil.baseProductRequest.Department_Id__c;
         EX_TestDataUtil.getPaymentGateway(true);
         insert confirm2;
         
         EX_TestDataUtil.getPrePaymentDetail(true);
 
         PaymentAPISetting_cs__c apiSetting1 = new PaymentAPISetting_cs__c();
         apiSetting1.Name = 'CancelApproval';
         apiSetting1.EndPoint__c = 'https://tapproval.smartropay.co.kr/payment/approval/cancel.do';
 
         PaymentAPISetting_cs__c apiSetting2 = new PaymentAPISetting_cs__c();
         apiSetting2.Name = 'SpendOrCancelPoint';
         apiSetting2.EndPoint__c = 'https://dev-apigw-ext.lge.com:7221/gateway/newbest/api2api/mbsmgt/reqMbsPointUse.do';
         apiSetting2.ApiKey__c = 'h0wqRGYN2xb3zTexiNDLYwelBxmB6JceZoFP3BokrGp8=';
         apiSetting2.xGatewayAPIKey__c = 'e783d29a-a6f0-41c2-a853-e88e2f6c7109=';
 
         PaymentAPISetting_cs__c apiSetting3 =new PaymentAPISetting_cs__c(Name = 'CheckRefundAccount', EndPoint__c = 'https://tapproval.smartropay.co.kr/payment/approval/accntNameSearch.do');
         PaymentAPISetting_cs__c apiSetting4 =new PaymentAPISetting_cs__c(Name = 'RefundCashFromVirtualAccount', EndPoint__c = 'https://tapproval.smartropay.co.kr/payment/approval/unionRefund.do');
         insert new List<PaymentAPISetting_cs__c>{apiSetting2, apiSetting1, apiSetting3, apiSetting4};
 
         ReturnOrder ro = [SELECT Id FROM ReturnOrder LIMIT 1];
         ro.Order_CHNL_TYPE_Code__c = 'V';
         ro.CONSIGNEE_Name__c = '테스트유저';
         update ro;
         // SR_AR_CONFIRM__c confirm1 = [SELECT ID FROM SR_AR_CONFIRM__c LIMIT 1];
         // confirm1.AR_INVOICE_NO__c = '3600a2f6D000000WTbDQAW';
         // update confirm1;
 
 
         Test.stopTest();
     }
 
     @IsTest
     static void test01() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         List<ReturnOrder> returnOrders = [SELECT Id, RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c, ProductRequest.SR_SALE__c, ProductRequest.Department_Id__c, ProductRequest.Department_Code__c ,(SELECT Id, POINT_REFUND_Complete_YN__c,ETC_REFUND_Complete_YN__c,Order_Number__c FROM ReturnOrderLineItems),CONSIGNEE_Name__c,Order_Number__c FROM ReturnOrder LIMIT 1];
         List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id ,IsMIG__c, POINT_TRX_ID__c, AR_INVOICE_NO__c, DEPOSIT_TYPE__c, TID__c,DEPOSIT_AMT__c ,UPAD_DETAIL_TYPE__c,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,SR_PAYMENT_BASIS_ID__c,FM_Order_Number__c, MBS_CUST_ID__c FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];
         List<SR_PRE_PAYMENT_DETAIL__c> srPrePaymentDetail = [SELECT Id,Moid__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
         List<ReturnOrderLineItem> roli = [SELECT Id, REFUND_BANK_CODE__c, ENC_REFUND_ACCT_Number__c,REFUND_DPSR_Name__c FROM ReturnOrderLineItem LIMIT 1];
         
         roli[0].REFUND_BANK_CODE__c ='088';
         roli[0].ENC_REFUND_ACCT_Number__c = '1234567890';
         roli[0].REFUND_DPSR_Name__c = '홍길동테스트';
         update roli[0];
 
         System.debug('ro dpt id> '  + returnOrders[0].ProductRequest.Department_Id__c);
         System.debug('ro dpt code> '  + returnOrders[0].ProductRequest.Department_Code__c);
 
         if(!returnOrders.isEmpty() && !srArConfirms.isEmpty()){
             srArConfirms[0].DEPOSIT_TYPE__c = 'A';
             srArConfirms[0].UPAD_DETAIL_TYPE__c = 'PG_VBANK';
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
 
             Map<String, String> saleNumberMOIDMap = new Map<String, String>();
             saleNumberMOIDMap.put(srArConfirms[0].SR_PAYMENT_BASIS_ID__r.Basis_no__c, srPrePaymentDetail[0].Moid__c);
 
             Map<String, Object> paramMap = new Map<String, Object>();
             paramMap.put('orderNumberMOIDMap', orderNumberMOIDMap);
             paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
             paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
             paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
             paramMap.put('kTrxIdRoLiMap', kTrxIdRoLiMap);
             paramMap.put('deptCodeMap', deptCodeMap);
             paramMap.put('saleNumberMOIDMap',saleNumberMOIDMap);
             Map<String, Decimal> roIdReturnQuantityMap = new Map<String, Decimal>();
             roIdReturnQuantityMap.put(returnOrders[0].Id,1);
             Map<String, String> roIdReturnGoodsNameMap = new Map<String, String>();
             roIdReturnGoodsNameMap.put(returnOrders[0].Id,'TEST');
             paramMap.put('roIdReturnQuantityMap', roIdReturnQuantityMap);
             paramMap.put('roIdReturnGoodsNameMap', roIdReturnGoodsNameMap);
 
             EX_ReturnConfirmQueueable q = new EX_ReturnConfirmQueueable(returnOrders[0], srArConfirms[0], paramMap,null);
             System.enqueueJob(q);
         }
 
         Test.stopTest();
     }

     @IsTest
     static void test01_0() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         List<ReturnOrder> returnOrders = [SELECT Id, RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c, ProductRequest.SR_SALE__c, ProductRequest.Department_Id__c, ProductRequest.Department_Code__c ,(SELECT Id, POINT_REFUND_Complete_YN__c,ETC_REFUND_Complete_YN__c,Order_Number__c FROM ReturnOrderLineItems),CONSIGNEE_Name__c,Order_Number__c FROM ReturnOrder LIMIT 1];
         List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id ,IsMIG__c,POINT_TRX_ID__c, AR_INVOICE_NO__c, DEPOSIT_TYPE__c, TID__c,DEPOSIT_AMT__c ,UPAD_DETAIL_TYPE__c,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,SR_PAYMENT_BASIS_ID__c,FM_Order_Number__c, MBS_CUST_ID__c FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];
         List<SR_PRE_PAYMENT_DETAIL__c> srPrePaymentDetail = [SELECT Id,Moid__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
         List<ReturnOrderLineItem> roli = [SELECT Id, REFUND_BANK_CODE__c, ENC_REFUND_ACCT_Number__c,REFUND_DPSR_Name__c FROM ReturnOrderLineItem LIMIT 1];
         
         roli[0].REFUND_BANK_CODE__c ='088';
         roli[0].ENC_REFUND_ACCT_Number__c = '1234567890';
         roli[0].REFUND_DPSR_Name__c = '홍길동테스트';
         update roli[0];

         returnOrders[0].CONSIGNEE_Name__c = null;
         update returnOrders;
        
        //  List<ProductRequestLineItem> prliList = [SELECT id,MOID__c FROM ProductRequestLineItem LIMIT 1];
        //  prliList[0].MOID__c = null;

        //  update prliList;

         System.debug('ro dpt id> '  + returnOrders[0].ProductRequest.Department_Id__c);
         System.debug('ro dpt code> '  + returnOrders[0].ProductRequest.Department_Code__c);
 
         if(!returnOrders.isEmpty() && !srArConfirms.isEmpty()){
             srArConfirms[0].DEPOSIT_TYPE__c = 'A';
             srArConfirms[0].UPAD_DETAIL_TYPE__c = 'PG_VBANK';
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
 
             Map<String, String> saleNumberMOIDMap = new Map<String, String>();
             saleNumberMOIDMap.put(srArConfirms[0].SR_PAYMENT_BASIS_ID__r.Basis_no__c, srPrePaymentDetail[0].Moid__c);
 
             Map<String, Object> paramMap = new Map<String, Object>();
             paramMap.put('orderNumberMOIDMap', orderNumberMOIDMap);
             paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
             paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
             paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
             paramMap.put('kTrxIdRoLiMap', kTrxIdRoLiMap);
             paramMap.put('deptCodeMap', deptCodeMap);
             paramMap.put('saleNumberMOIDMap',saleNumberMOIDMap);
             Map<String, Decimal> roIdReturnQuantityMap = new Map<String, Decimal>();
             roIdReturnQuantityMap.put(returnOrders[0].Id,1);
             Map<String, String> roIdReturnGoodsNameMap = new Map<String, String>();
             roIdReturnGoodsNameMap.put(returnOrders[0].Id,'TEST');
             paramMap.put('roIdReturnQuantityMap', roIdReturnQuantityMap);
             paramMap.put('roIdReturnGoodsNameMap', roIdReturnGoodsNameMap);
 
             EX_ReturnConfirmQueueable q = new EX_ReturnConfirmQueueable(returnOrders[0], srArConfirms[0], paramMap,null);
             System.enqueueJob(q);
         }
 
         Test.stopTest();
     }     

     //23 12 19 hyungho.chun mock 실패
     @IsTest
     static void test01_00() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockFail());
         List<ReturnOrder> returnOrders = [SELECT Id, RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c, ProductRequest.SR_SALE__c, ProductRequest.Department_Id__c, ProductRequest.Department_Code__c ,(SELECT Id, POINT_REFUND_Complete_YN__c,ETC_REFUND_Complete_YN__c,Order_Number__c FROM ReturnOrderLineItems),CONSIGNEE_Name__c,Order_Number__c FROM ReturnOrder LIMIT 1];
         List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id ,IsMIG__c,POINT_TRX_ID__c, AR_INVOICE_NO__c, DEPOSIT_TYPE__c, TID__c,DEPOSIT_AMT__c ,UPAD_DETAIL_TYPE__c,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,SR_PAYMENT_BASIS_ID__c,FM_Order_Number__c, MBS_CUST_ID__c FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];
         List<SR_PRE_PAYMENT_DETAIL__c> srPrePaymentDetail = [SELECT Id,Moid__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
         List<ReturnOrderLineItem> roli = [SELECT Id, REFUND_BANK_CODE__c, ENC_REFUND_ACCT_Number__c,REFUND_DPSR_Name__c FROM ReturnOrderLineItem LIMIT 1];
         
         roli[0].REFUND_BANK_CODE__c ='088';
         roli[0].ENC_REFUND_ACCT_Number__c = '1234567890';
         roli[0].REFUND_DPSR_Name__c = '홍길동테스트';
         update roli[0];
 
         System.debug('ro dpt id> '  + returnOrders[0].ProductRequest.Department_Id__c);
         System.debug('ro dpt code> '  + returnOrders[0].ProductRequest.Department_Code__c);
 
         if(!returnOrders.isEmpty() && !srArConfirms.isEmpty()){
             srArConfirms[0].DEPOSIT_TYPE__c = 'A';
             srArConfirms[0].UPAD_DETAIL_TYPE__c = 'PG_VBANK';
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
 
             Map<String, String> saleNumberMOIDMap = new Map<String, String>();
             saleNumberMOIDMap.put(srArConfirms[0].SR_PAYMENT_BASIS_ID__r.Basis_no__c, srPrePaymentDetail[0].Moid__c);
 
             Map<String, Object> paramMap = new Map<String, Object>();
             paramMap.put('orderNumberMOIDMap', orderNumberMOIDMap);
             paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
             paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
             paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
             paramMap.put('kTrxIdRoLiMap', kTrxIdRoLiMap);
             paramMap.put('deptCodeMap', deptCodeMap);
             paramMap.put('saleNumberMOIDMap',saleNumberMOIDMap);
             Map<String, Decimal> roIdReturnQuantityMap = new Map<String, Decimal>();
             roIdReturnQuantityMap.put(returnOrders[0].Id,1);
             Map<String, String> roIdReturnGoodsNameMap = new Map<String, String>();
             roIdReturnGoodsNameMap.put(returnOrders[0].Id,'TEST');
             paramMap.put('roIdReturnQuantityMap', roIdReturnQuantityMap);
             paramMap.put('roIdReturnGoodsNameMap', roIdReturnGoodsNameMap);
 
             EX_ReturnConfirmQueueable q = new EX_ReturnConfirmQueueable(returnOrders[0], srArConfirms[0], paramMap,null);
             System.enqueueJob(q);
         }
 
         Test.stopTest();
     }     
 
     @IsTest
     static void test01_01() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         List<ReturnOrder> returnOrders = [SELECT Id, RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c, ProductRequest.SR_SALE__c, ProductRequest.Department_Id__c, ProductRequest.Department_Code__c ,(SELECT Id, POINT_REFUND_Complete_YN__c,ETC_REFUND_Complete_YN__c,Order_Number__c FROM ReturnOrderLineItems),CONSIGNEE_Name__c,Order_Number__c FROM ReturnOrder LIMIT 1];
         List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id ,IsMIG__c,POINT_TRX_ID__c, AR_INVOICE_NO__c, DEPOSIT_TYPE__c, TID__c,DEPOSIT_AMT__c ,UPAD_DETAIL_TYPE__c,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,SR_PAYMENT_BASIS_ID__c,FM_Order_Number__c, MBS_CUST_ID__c FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];
         List<SR_PRE_PAYMENT_DETAIL__c> srPrePaymentDetail = [SELECT Id,Moid__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
         List<ReturnOrderLineItem> roli = [SELECT Id, REFUND_BANK_CODE__c, ENC_REFUND_ACCT_Number__c,REFUND_DPSR_Name__c FROM ReturnOrderLineItem LIMIT 1];
         
         roli[0].REFUND_BANK_CODE__c ='088';
         roli[0].ENC_REFUND_ACCT_Number__c = '1234567890';
         roli[0].REFUND_DPSR_Name__c = '홍길동테스트';
         update roli[0];
 
         System.debug('ro dpt id> '  + returnOrders[0].ProductRequest.Department_Id__c);
         System.debug('ro dpt code> '  + returnOrders[0].ProductRequest.Department_Code__c);
 
         if(!returnOrders.isEmpty() && !srArConfirms.isEmpty()){
             srArConfirms[0].DEPOSIT_TYPE__c = 'A';
             srArConfirms[0].UPAD_DETAIL_TYPE__c = 'PG_VBANK';
             srArConfirms[0].AR_INVOICE_NO__c = '^o^';
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
 
             Map<String, String> saleNumberMOIDMap = new Map<String, String>();
             saleNumberMOIDMap.put(srArConfirms[0].SR_PAYMENT_BASIS_ID__r.Basis_no__c, srPrePaymentDetail[0].Moid__c);
 
             Map<String, Object> paramMap = new Map<String, Object>();
             paramMap.put('orderNumberMOIDMap', orderNumberMOIDMap);
             paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
             paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
             paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
             paramMap.put('kTrxIdRoLiMap', kTrxIdRoLiMap);
             paramMap.put('deptCodeMap', deptCodeMap);
             paramMap.put('saleNumberMOIDMap',saleNumberMOIDMap);
             Map<String, Decimal> roIdReturnQuantityMap = new Map<String, Decimal>();
             roIdReturnQuantityMap.put(returnOrders[0].Id,1);
             Map<String, String> roIdReturnGoodsNameMap = new Map<String, String>();
             roIdReturnGoodsNameMap.put(returnOrders[0].Id,'TEST');
             paramMap.put('roIdReturnQuantityMap', roIdReturnQuantityMap);
             paramMap.put('roIdReturnGoodsNameMap', roIdReturnGoodsNameMap);
 
             EX_ReturnConfirmQueueable q = new EX_ReturnConfirmQueueable(returnOrders[0], srArConfirms[0], paramMap,null);
             System.enqueueJob(q);
         }
 
         Test.stopTest();
     }    
 
     @IsTest
     static void test01_02() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         List<ReturnOrder> returnOrders = [SELECT Id, RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c, ProductRequest.SR_SALE__c, ProductRequest.Department_Id__c, ProductRequest.Department_Code__c ,(SELECT Id, POINT_REFUND_Complete_YN__c,ETC_REFUND_Complete_YN__c,Order_Number__c FROM ReturnOrderLineItems),CONSIGNEE_Name__c,Order_Number__c FROM ReturnOrder LIMIT 1];
         List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id ,IsMIG__c,POINT_TRX_ID__c, AR_INVOICE_NO__c, DEPOSIT_TYPE__c, TID__c,DEPOSIT_AMT__c ,UPAD_DETAIL_TYPE__c,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,SR_PAYMENT_BASIS_ID__c,FM_Order_Number__c, MBS_CUST_ID__c FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];
         List<SR_PRE_PAYMENT_DETAIL__c> srPrePaymentDetail = [SELECT Id,Moid__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
         List<ReturnOrderLineItem> roli = [SELECT Id, REFUND_BANK_CODE__c, ENC_REFUND_ACCT_Number__c,REFUND_DPSR_Name__c FROM ReturnOrderLineItem LIMIT 1];
         
         roli[0].REFUND_BANK_CODE__c =null;
         roli[0].ENC_REFUND_ACCT_Number__c = '1234567890';
         roli[0].REFUND_DPSR_Name__c = '홍길동테스트';
         update roli[0];
 
         System.debug('ro dpt id> '  + returnOrders[0].ProductRequest.Department_Id__c);
         System.debug('ro dpt code> '  + returnOrders[0].ProductRequest.Department_Code__c);
 
         if(!returnOrders.isEmpty() && !srArConfirms.isEmpty()){
             srArConfirms[0].DEPOSIT_TYPE__c = 'A';
             srArConfirms[0].UPAD_DETAIL_TYPE__c = 'PG_VBANK';
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
 
             Map<String, String> saleNumberMOIDMap = new Map<String, String>();
             saleNumberMOIDMap.put(srArConfirms[0].SR_PAYMENT_BASIS_ID__r.Basis_no__c, srPrePaymentDetail[0].Moid__c);
 
             Map<String, Object> paramMap = new Map<String, Object>();
             paramMap.put('orderNumberMOIDMap', orderNumberMOIDMap);
             paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
             paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
             paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
             paramMap.put('kTrxIdRoLiMap', kTrxIdRoLiMap);
             paramMap.put('deptCodeMap', deptCodeMap);
             paramMap.put('saleNumberMOIDMap',saleNumberMOIDMap);
             Map<String, Decimal> roIdReturnQuantityMap = new Map<String, Decimal>();
             roIdReturnQuantityMap.put(returnOrders[0].Id,1);
             Map<String, String> roIdReturnGoodsNameMap = new Map<String, String>();
             roIdReturnGoodsNameMap.put(returnOrders[0].Id,'TEST');
             paramMap.put('roIdReturnQuantityMap', roIdReturnQuantityMap);
             paramMap.put('roIdReturnGoodsNameMap', roIdReturnGoodsNameMap);
 
             EX_ReturnConfirmQueueable q = new EX_ReturnConfirmQueueable(returnOrders[0], srArConfirms[0], paramMap,null);
             System.enqueueJob(q);
         }
 
         Test.stopTest();
     }
 
     @IsTest
     static void test01_03() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         List<ReturnOrder> returnOrders = [SELECT Id, RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c, ProductRequest.SR_SALE__c, ProductRequest.Department_Id__c, ProductRequest.Department_Code__c ,(SELECT Id, POINT_REFUND_Complete_YN__c,ETC_REFUND_Complete_YN__c,Order_Number__c FROM ReturnOrderLineItems),CONSIGNEE_Name__c,Order_Number__c FROM ReturnOrder LIMIT 1];
         List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id ,IsMIG__c,POINT_TRX_ID__c, AR_INVOICE_NO__c, DEPOSIT_TYPE__c, TID__c,DEPOSIT_AMT__c ,UPAD_DETAIL_TYPE__c,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,SR_PAYMENT_BASIS_ID__c,FM_Order_Number__c, MBS_CUST_ID__c FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];
         List<SR_PRE_PAYMENT_DETAIL__c> srPrePaymentDetail = [SELECT Id,Moid__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
         List<ReturnOrderLineItem> roli = [SELECT Id, REFUND_BANK_CODE__c, ENC_REFUND_ACCT_Number__c,REFUND_DPSR_Name__c FROM ReturnOrderLineItem LIMIT 1];
         
         roli[0].REFUND_BANK_CODE__c ='088';
         roli[0].ENC_REFUND_ACCT_Number__c = '123456';
         roli[0].REFUND_DPSR_Name__c = '홍길동틀렸다';
         update roli[0];
 
         System.debug('ro dpt id> '  + returnOrders[0].ProductRequest.Department_Id__c);
         System.debug('ro dpt code> '  + returnOrders[0].ProductRequest.Department_Code__c);
 
         if(!returnOrders.isEmpty() && !srArConfirms.isEmpty()){
             srArConfirms[0].DEPOSIT_TYPE__c = 'A';
             srArConfirms[0].UPAD_DETAIL_TYPE__c = 'PG_VBANK';
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
 
             Map<String, String> saleNumberMOIDMap = new Map<String, String>();
             saleNumberMOIDMap.put(srArConfirms[0].SR_PAYMENT_BASIS_ID__r.Basis_no__c, srPrePaymentDetail[0].Moid__c);
 
             Map<String, Object> paramMap = new Map<String, Object>();
             paramMap.put('orderNumberMOIDMap', orderNumberMOIDMap);
             paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
             paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
             paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
             paramMap.put('kTrxIdRoLiMap', kTrxIdRoLiMap);
             paramMap.put('deptCodeMap', deptCodeMap);
             paramMap.put('saleNumberMOIDMap',saleNumberMOIDMap);
             Map<String, Decimal> roIdReturnQuantityMap = new Map<String, Decimal>();
             roIdReturnQuantityMap.put(returnOrders[0].Id,1);
             Map<String, String> roIdReturnGoodsNameMap = new Map<String, String>();
             roIdReturnGoodsNameMap.put(returnOrders[0].Id,'TEST');
             paramMap.put('roIdReturnQuantityMap', roIdReturnQuantityMap);
             paramMap.put('roIdReturnGoodsNameMap', roIdReturnGoodsNameMap);
 
             EX_ReturnConfirmQueueable q = new EX_ReturnConfirmQueueable(returnOrders[0], srArConfirms[0], paramMap,null);
             System.enqueueJob(q);
         }
 
         Test.stopTest();
     }    
 
     @IsTest
     static void test02() {
         Test.startTest();
         // Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         Test.setMock(HttpCalloutMock.class, new HttpCalloutResponseMock());
         insert new PaymentAPISetting_cs__c(Name = 'CheckPoint', ApiKey__c = 'a', EndPoint__c = 'b');
         List<ReturnOrder> returnOrders = [SELECT Id, RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c, ProductRequest.SR_SALE__c, ProductRequest.Department_Id__c, ProductRequest.Department_Code__c, (SELECT Id, POINT_REFUND_Complete_YN__c,ETC_REFUND_Complete_YN__c,RED_POINT_TRX_ID__c,Order_Number__c FROM ReturnOrderLineItems),CONSIGNEE_Name__c,Order_Number__c FROM ReturnOrder LIMIT 1];
         // List<ReturnOrderLineItem> returnOrderLineitems = [SELECT Id, POINT_REFUND_Complete_YN__c,ETC_REFUND_Complete_YN__c,RED_POINT_TRX_ID__c FROM ReturnOrderLineItems WHERE ReturnOrderId =: returnOrders[0].Id];
         List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id,IsMIG__c, POINT_TRX_ID__c,AR_INVOICE_NO__c, DEPOSIT_AMT__c, DEPOSIT_TYPE__c , TID__c, UPAD_DETAIL_TYPE__c ,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,SR_PAYMENT_BASIS_ID__c,FM_Order_Number__c,PAY_CUST_NAME__c, PAY_CUST_PHONE__c, MBS_CUST_ID__c FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];
         List<SR_PRE_PAYMENT_DETAIL__c> srPrePaymentDetail = [SELECT Id,POINT_TRX_ID__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
         srArConfirms[0].POINT_TRX_ID__c = srPrePaymentDetail[0].POINT_TRX_ID__c;
         srArConfirms[0].PAY_CUST_NAME__c = '홍길동';
         srArConfirms[0].PAY_CUST_PHONE__c = '01011112222';
 
         List<ProductRequestLineItem> prli = [SELECT Id, POINT_TRX_ID__c FROM ProductRequestLineItem LIMIT 1]; 
         prli[0].POINT_TRX_ID__c = srPrePaymentDetail[0].POINT_TRX_ID__c;
         update srArConfirms[0];
         update prli[0];
         
         if(!returnOrders.isEmpty() && !srArConfirms.isEmpty()){
             srArConfirms[0].DEPOSIT_TYPE__c = 'D';
             Map<String, String> orderNumberMOIDMap = new Map<String, String>();
             Map<String, String> confirmIdTrxIdMap = new Map<String, String>();
             confirmIdTrxIdMap.put(srArConfirms[0].Id, srPrePaymentDetail[0].POINT_TRX_ID__c );
             Map<String, Set<String>> roIdTrxIdSetMap = new Map<String, Set<String>>();
             Set<String> trxIdSet = new Set<String>();
             trxIdSet.add(srPrePaymentDetail[0].POINT_TRX_ID__c);
             roIdTrxIdSetMap.put(returnOrders[0].Id, trxIdSet);
             Map<String, List<ReturnOrderLineItem>> roIdRoLiListMap = new Map<String, List<ReturnOrderLineItem>>();
             roIdRoLiListMap.put(returnOrders[0].Id, returnOrders[0].ReturnOrderLineItems);
             Map<String, ReturnOrderLineItem> kTrxIdRoLiMap = new Map<String, ReturnOrderLineItem>();
             // kTrxIdRoLiMap.put(srPrePaymentDetail[0].POINT_TRX_ID__c, returnOrderLineitems[0]);
             kTrxIdRoLiMap.put(srPrePaymentDetail[0].POINT_TRX_ID__c, returnOrders[0].ReturnOrderLineItems[0]);
             Map<String, SM_DEPT__c> deptCodeMap = new Map<String, SM_DEPT__c>();
             for(SM_DEPT__c dep : [SELECT Id, DEPT_CODE__c , DEPT_NAME__c FROM SM_DEPT__c]){
                 deptCodeMap.put(dep.DEPT_CODE__c, dep);
             }
 
             Map<String, String> saleNumberMOIDMap = new Map<String, String>();
 
             Map<String, Object> paramMap = new Map<String, Object>();
             paramMap.put('orderNumberMOIDMap', orderNumberMOIDMap);
             paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
             paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
             paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
             paramMap.put('kTrxIdRoLiMap', kTrxIdRoLiMap);
             paramMap.put('deptCodeMap', deptCodeMap);
             paramMap.put('saleNumberMOIDMap',saleNumberMOIDMap);
             Map<String, Decimal> roIdReturnQuantityMap = new Map<String, Decimal>();
             Map<String, String> roIdReturnGoodsNameMap = new Map<String, String>();
             paramMap.put('roIdReturnQuantityMap', roIdReturnQuantityMap);
             paramMap.put('roIdReturnGoodsNameMap', roIdReturnGoodsNameMap);
 
             EX_ReturnConfirmQueueable q = new EX_ReturnConfirmQueueable(returnOrders[0], srArConfirms[0], paramMap,null);
             System.enqueueJob(q);
         }
 
 
         Test.stopTest();
     }

     @IsTest
     static void test02_00() {
         Test.startTest();
         // Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         Test.setMock(HttpCalloutMock.class, new HttpCalloutResponseMockFail());
         insert new PaymentAPISetting_cs__c(Name = 'CheckPoint', ApiKey__c = 'a', EndPoint__c = 'b');
         List<ReturnOrder> returnOrders = [SELECT Id, RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c, ProductRequest.SR_SALE__c, ProductRequest.Department_Id__c, ProductRequest.Department_Code__c, (SELECT Id, POINT_REFUND_Complete_YN__c,ETC_REFUND_Complete_YN__c,RED_POINT_TRX_ID__c,Order_Number__c FROM ReturnOrderLineItems),CONSIGNEE_Name__c,Order_Number__c FROM ReturnOrder LIMIT 1];
         // List<ReturnOrderLineItem> returnOrderLineitems = [SELECT Id, POINT_REFUND_Complete_YN__c,ETC_REFUND_Complete_YN__c,RED_POINT_TRX_ID__c FROM ReturnOrderLineItems WHERE ReturnOrderId =: returnOrders[0].Id];
         List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id, IsMIG__c,POINT_TRX_ID__c,AR_INVOICE_NO__c, DEPOSIT_AMT__c, DEPOSIT_TYPE__c , TID__c, UPAD_DETAIL_TYPE__c ,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,SR_PAYMENT_BASIS_ID__c,FM_Order_Number__c,PAY_CUST_NAME__c, PAY_CUST_PHONE__c, MBS_CUST_ID__c FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];
         List<SR_PRE_PAYMENT_DETAIL__c> srPrePaymentDetail = [SELECT Id,POINT_TRX_ID__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
         srArConfirms[0].POINT_TRX_ID__c = srPrePaymentDetail[0].POINT_TRX_ID__c;
         srArConfirms[0].PAY_CUST_NAME__c = '홍길동';
         srArConfirms[0].PAY_CUST_PHONE__c = '01011112222';
 
         List<ProductRequestLineItem> prli = [SELECT Id, POINT_TRX_ID__c FROM ProductRequestLineItem LIMIT 1]; 
         prli[0].POINT_TRX_ID__c = srPrePaymentDetail[0].POINT_TRX_ID__c;
         update srArConfirms[0];
         update prli[0];
         
         if(!returnOrders.isEmpty() && !srArConfirms.isEmpty()){
             srArConfirms[0].DEPOSIT_TYPE__c = 'D';
             Map<String, String> orderNumberMOIDMap = new Map<String, String>();
             Map<String, String> confirmIdTrxIdMap = new Map<String, String>();
             confirmIdTrxIdMap.put(srArConfirms[0].Id, srPrePaymentDetail[0].POINT_TRX_ID__c );
             Map<String, Set<String>> roIdTrxIdSetMap = new Map<String, Set<String>>();
             Set<String> trxIdSet = new Set<String>();
             trxIdSet.add(srPrePaymentDetail[0].POINT_TRX_ID__c);
             roIdTrxIdSetMap.put(returnOrders[0].Id, trxIdSet);
             Map<String, List<ReturnOrderLineItem>> roIdRoLiListMap = new Map<String, List<ReturnOrderLineItem>>();
             roIdRoLiListMap.put(returnOrders[0].Id, returnOrders[0].ReturnOrderLineItems);
             Map<String, ReturnOrderLineItem> kTrxIdRoLiMap = new Map<String, ReturnOrderLineItem>();
             // kTrxIdRoLiMap.put(srPrePaymentDetail[0].POINT_TRX_ID__c, returnOrderLineitems[0]);
             kTrxIdRoLiMap.put(srPrePaymentDetail[0].POINT_TRX_ID__c, returnOrders[0].ReturnOrderLineItems[0]);
             Map<String, SM_DEPT__c> deptCodeMap = new Map<String, SM_DEPT__c>();
             for(SM_DEPT__c dep : [SELECT Id, DEPT_CODE__c , DEPT_NAME__c FROM SM_DEPT__c]){
                 deptCodeMap.put(dep.DEPT_CODE__c, dep);
             }
 
             Map<String, String> saleNumberMOIDMap = new Map<String, String>();
 
             Map<String, Object> paramMap = new Map<String, Object>();
             paramMap.put('orderNumberMOIDMap', orderNumberMOIDMap);
             paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
             paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
             paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
             paramMap.put('kTrxIdRoLiMap', kTrxIdRoLiMap);
             paramMap.put('deptCodeMap', deptCodeMap);
             paramMap.put('saleNumberMOIDMap',saleNumberMOIDMap);
             Map<String, Decimal> roIdReturnQuantityMap = new Map<String, Decimal>();
             Map<String, String> roIdReturnGoodsNameMap = new Map<String, String>();
             paramMap.put('roIdReturnQuantityMap', roIdReturnQuantityMap);
             paramMap.put('roIdReturnGoodsNameMap', roIdReturnGoodsNameMap);
 
             EX_ReturnConfirmQueueable q = new EX_ReturnConfirmQueueable(returnOrders[0], srArConfirms[0], paramMap,null);
             System.enqueueJob(q);
         }
 
 
         Test.stopTest();
     }


     @IsTest
     static void test03() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         ReturnOrder ro = [SELECT Id FROM ReturnOrder LIMIT 1];
         ro.Order_CHNL_TYPE_Code__c = 'B';
         update ro;
         List<ReturnOrder> returnOrders = [SELECT Id, RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c, ProductRequest.SR_SALE__c, ProductRequest.Department_Id__c, ProductRequest.Department_Code__c, (SELECT Id , POINT_REFUND_Complete_YN__c, ETC_REFUND_Complete_YN__c,Order_Number__c FROM ReturnOrderLineItems),CONSIGNEE_Name__c,Order_Number__c FROM ReturnOrder LIMIT 1];
         List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id, IsMIG__c,POINT_TRX_ID__c,AR_INVOICE_NO__c, DEPOSIT_AMT__c, DEPOSIT_TYPE__c , TID__c, UPAD_DETAIL_TYPE__c ,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,SR_PAYMENT_BASIS_ID__c,FM_Order_Number__c,PAY_CUST_NAME__c,PAY_CUST_PHONE__c, MBS_CUST_ID__c  FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];
         List<SR_SMARTRO_PAYMENT_REQUEST__c> requests = [SELECT Id, MOID__c FROM SR_SMARTRO_PAYMENT_REQUEST__c];
         update srArConfirms;
         if(!returnOrders.isEmpty() && !srArConfirms.isEmpty() && !requests.isEmpty()){
             srArConfirms[0].DEPOSIT_TYPE__c = 'E';
             srArConfirms[0].UPAD_DETAIL_TYPE__c = 'PG_VBANK';
             Map<String, String> orderNumberMOIDMap = new Map<String, String>();
             orderNumberMOIDMap.put(srArConfirms[0].SR_PAYMENT_BASIS_ID__r.BASIS_NO__c, requests[0].MOID__c);
             Map<String, String> confirmIdTrxIdMap = new Map<String, String>();
             confirmIdTrxIdMap.put(srArConfirms[0].Id, 'TRX_ID_TEST' );
             Map<String, Set<String>> roIdTrxIdSetMap = new Map<String, Set<String>>();
             Set<String> trxIdSet = new Set<String>();
             trxIdSet.add('TRX_ID_TEST');
             roIdTrxIdSetMap.put(returnOrders[0].Id, trxIdSet);
             Map<String, List<ReturnOrderLineItem>> roIdRoLiListMap = new Map<String, List<ReturnOrderLineItem>>();
             roIdRoLiListMap.put(returnOrders[0].Id, returnOrders[0].ReturnOrderLineItems);
             Map<String, ReturnOrderLineItem> kTrxIdRoLiMap = new Map<String, ReturnOrderLineItem>();
             kTrxIdRoLiMap.put(returnOrders[0].Id, returnOrders[0].ReturnOrderLineItems[0]);
             Map<String, SM_DEPT__c> deptCodeMap = new Map<String, SM_DEPT__c>();
             for(SM_DEPT__c dep : [SELECT Id, DEPT_CODE__c , DEPT_NAME__c FROM SM_DEPT__c]){
                 deptCodeMap.put(dep.DEPT_CODE__c, dep);
             }
 
             Map<String, String> saleNumberMOIDMap = new Map<String, String>();
 
             Map<String, Object> paramMap = new Map<String, Object>();
             paramMap.put('orderNumberMOIDMap', orderNumberMOIDMap);
             paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
             paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
             paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
             paramMap.put('kTrxIdRoLiMap', kTrxIdRoLiMap);
             paramMap.put('deptCodeMap', deptCodeMap);
             paramMap.put('saleNumberMOIDMap',saleNumberMOIDMap);
             Map<String, Decimal> roIdReturnQuantityMap = new Map<String, Decimal>();
             Map<String, String> roIdReturnGoodsNameMap = new Map<String, String>();
             paramMap.put('roIdReturnQuantityMap', roIdReturnQuantityMap);
             paramMap.put('roIdReturnGoodsNameMap', roIdReturnGoodsNameMap);
 
             EX_ReturnConfirmQueueable q = new EX_ReturnConfirmQueueable(returnOrders[0], srArConfirms[0], paramMap,null);
             System.enqueueJob(q);
             
 
         }
 
 
         Test.stopTest();
     }

     @IsTest
     static void test03_00() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMockFail());
         ReturnOrder ro = [SELECT Id FROM ReturnOrder LIMIT 1];
         ro.Order_CHNL_TYPE_Code__c = 'B';
         update ro;
         List<ReturnOrder> returnOrders = [SELECT Id, RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c, ProductRequest.SR_SALE__c, ProductRequest.Department_Id__c, ProductRequest.Department_Code__c, (SELECT Id , POINT_REFUND_Complete_YN__c, ETC_REFUND_Complete_YN__c,Order_Number__c FROM ReturnOrderLineItems),CONSIGNEE_Name__c,Order_Number__c FROM ReturnOrder LIMIT 1];
         List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id,IsMIG__c, POINT_TRX_ID__c,AR_INVOICE_NO__c, DEPOSIT_AMT__c, DEPOSIT_TYPE__c , TID__c, UPAD_DETAIL_TYPE__c ,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,SR_PAYMENT_BASIS_ID__c,FM_Order_Number__c,PAY_CUST_NAME__c,PAY_CUST_PHONE__c, MBS_CUST_ID__c  FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];
         List<SR_SMARTRO_PAYMENT_REQUEST__c> requests = [SELECT Id, MOID__c FROM SR_SMARTRO_PAYMENT_REQUEST__c];
         update srArConfirms;
         if(!returnOrders.isEmpty() && !srArConfirms.isEmpty() && !requests.isEmpty()){
             srArConfirms[0].DEPOSIT_TYPE__c = 'E';
             srArConfirms[0].UPAD_DETAIL_TYPE__c = 'PG_VBANK';
             Map<String, String> orderNumberMOIDMap = new Map<String, String>();
             orderNumberMOIDMap.put(srArConfirms[0].SR_PAYMENT_BASIS_ID__r.BASIS_NO__c, requests[0].MOID__c);
             Map<String, String> confirmIdTrxIdMap = new Map<String, String>();
             confirmIdTrxIdMap.put(srArConfirms[0].Id, 'TRX_ID_TEST' );
             Map<String, Set<String>> roIdTrxIdSetMap = new Map<String, Set<String>>();
             Set<String> trxIdSet = new Set<String>();
             trxIdSet.add('TRX_ID_TEST');
             roIdTrxIdSetMap.put(returnOrders[0].Id, trxIdSet);
             Map<String, List<ReturnOrderLineItem>> roIdRoLiListMap = new Map<String, List<ReturnOrderLineItem>>();
             roIdRoLiListMap.put(returnOrders[0].Id, returnOrders[0].ReturnOrderLineItems);
             Map<String, ReturnOrderLineItem> kTrxIdRoLiMap = new Map<String, ReturnOrderLineItem>();
             kTrxIdRoLiMap.put(returnOrders[0].Id, returnOrders[0].ReturnOrderLineItems[0]);
             Map<String, SM_DEPT__c> deptCodeMap = new Map<String, SM_DEPT__c>();
             for(SM_DEPT__c dep : [SELECT Id, DEPT_CODE__c , DEPT_NAME__c FROM SM_DEPT__c]){
                 deptCodeMap.put(dep.DEPT_CODE__c, dep);
             }
 
             Map<String, String> saleNumberMOIDMap = new Map<String, String>();
 
             Map<String, Object> paramMap = new Map<String, Object>();
             paramMap.put('orderNumberMOIDMap', orderNumberMOIDMap);
             paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
             paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
             paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
             paramMap.put('kTrxIdRoLiMap', kTrxIdRoLiMap);
             paramMap.put('deptCodeMap', deptCodeMap);
             paramMap.put('saleNumberMOIDMap',saleNumberMOIDMap);
             Map<String, Decimal> roIdReturnQuantityMap = new Map<String, Decimal>();
             Map<String, String> roIdReturnGoodsNameMap = new Map<String, String>();
             paramMap.put('roIdReturnQuantityMap', roIdReturnQuantityMap);
             paramMap.put('roIdReturnGoodsNameMap', roIdReturnGoodsNameMap);
 
             EX_ReturnConfirmQueueable q = new EX_ReturnConfirmQueueable(returnOrders[0], srArConfirms[0], paramMap,null);
             System.enqueueJob(q);
             
 
         }
 
 
         Test.stopTest();
     }



     //23 12 12 hyungho.chun test03_02 catch문 error띄우는용도임
     @IsTest
     static void test03_02() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         ReturnOrder ro = [SELECT Id FROM ReturnOrder LIMIT 1];
         ro.Order_CHNL_TYPE_Code__c = 'V';
         update ro;
         List<ReturnOrder> returnOrders = [SELECT Id, RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c,ProductRequest.TID__c, ProductRequest.SR_SALE__c, ProductRequest.Department_Id__c, ProductRequest.Department_Code__c, (SELECT Id , POINT_REFUND_Complete_YN__c, ETC_REFUND_Complete_YN__c,Order_Number__c FROM ReturnOrderLineItems),CONSIGNEE_Name__c,Order_Number__c FROM ReturnOrder LIMIT 1];
         List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id, IsMIG__c,POINT_TRX_ID__c,AR_INVOICE_NO__c, DEPOSIT_AMT__c, DEPOSIT_TYPE__c , TID__c, UPAD_DETAIL_TYPE__c ,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,SR_PAYMENT_BASIS_ID__c,FM_Order_Number__c,PAY_CUST_NAME__c,PAY_CUST_PHONE__c, MBS_CUST_ID__c  FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];
         List<SR_SMARTRO_PAYMENT_REQUEST__c> requests = [SELECT Id, MID__c, MOID__c, TID__c, APPR_AMT__c FROM SR_SMARTRO_PAYMENT_REQUEST__c];
         List<ProductRequest> pr = [SELECT id, TID__c FROM ProductRequest LIMIT 1];
         for(SR_SMARTRO_PAYMENT_REQUEST__c item : requests){
             item.PAYMETHOD__c = 'CARD';
             item.TID__c = srArConfirms[0].TID__c; 
         }
         update requests;
         pr[0].TID__c = srArConfirms[0].TID__c;
         update pr;
         update srArConfirms;
         if(!returnOrders.isEmpty() && !srArConfirms.isEmpty() && !requests.isEmpty()){
             srArConfirms[0].DEPOSIT_TYPE__c = 'B';
             // srArConfirms[0].UPAD_DETAIL_TYPE__c = 'PG_VBANK';
             Map<String, String> orderNumberMOIDMap = new Map<String, String>();
             orderNumberMOIDMap.put(srArConfirms[0].SR_PAYMENT_BASIS_ID__r.BASIS_NO__c, requests[0].MOID__c);
             Map<String, String> confirmIdTrxIdMap = new Map<String, String>();
             confirmIdTrxIdMap.put(srArConfirms[0].Id, 'TRX_ID_TEST' );
             Map<String, Set<String>> roIdTrxIdSetMap = new Map<String, Set<String>>();
             Set<String> trxIdSet = new Set<String>();
             trxIdSet.add('TRX_ID_TEST');
             roIdTrxIdSetMap.put(returnOrders[0].Id, trxIdSet);
             Map<String, List<ReturnOrderLineItem>> roIdRoLiListMap = new Map<String, List<ReturnOrderLineItem>>();
             roIdRoLiListMap.put(returnOrders[0].Id, returnOrders[0].ReturnOrderLineItems);
             Map<String, ReturnOrderLineItem> kTrxIdRoLiMap = new Map<String, ReturnOrderLineItem>();
             kTrxIdRoLiMap.put(returnOrders[0].Id, returnOrders[0].ReturnOrderLineItems[0]);
             Map<String, SM_DEPT__c> deptCodeMap = new Map<String, SM_DEPT__c>();
             for(SM_DEPT__c dep : [SELECT Id, DEPT_CODE__c , DEPT_NAME__c FROM SM_DEPT__c]){
                 deptCodeMap.put(dep.DEPT_CODE__c, dep);
             }
 
             Map<String, String> saleNumberMOIDMap = new Map<String, String>();
 
             Map<String, Object> paramMap = new Map<String, Object>();
             paramMap.put('orderNumberMOIDMap', orderNumberMOIDMap);
             paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
             paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
             paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
             paramMap.put('kTrxIdRoLiMap', kTrxIdRoLiMap);
             paramMap.put('deptCodeMap', deptCodeMap);
             paramMap.put('saleNumberMOIDMap',saleNumberMOIDMap);
             Map<String, Decimal> roIdReturnQuantityMap = new Map<String, Decimal>();
             Map<String, String> roIdReturnGoodsNameMap = new Map<String, String>();
             paramMap.put('roIdReturnQuantityMap', roIdReturnQuantityMap);
             paramMap.put('roIdReturnGoodsNameMap', roIdReturnGoodsNameMap);
 
             EX_ReturnConfirmQueueable q = new EX_ReturnConfirmQueueable(returnOrders[0], srArConfirms[0], paramMap,null);
             System.enqueueJob(q);
             
 
         }
 
 
         Test.stopTest();
     }
     
     //23 12 12 hyungho.chun test03_03 catch문 error띄우는용도임
     @IsTest
     static void test03_03() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         ReturnOrder ro = [SELECT Id FROM ReturnOrder LIMIT 1];
         ro.Order_CHNL_TYPE_Code__c = 'V';
         update ro;
         List<ReturnOrder> returnOrders = [SELECT Id, RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c,ProductRequest.TID__c, ProductRequest.SR_SALE__c, ProductRequest.Department_Id__c, ProductRequest.Department_Code__c, (SELECT Id , POINT_REFUND_Complete_YN__c, ETC_REFUND_Complete_YN__c,Order_Number__c FROM ReturnOrderLineItems),CONSIGNEE_Name__c,Order_Number__c FROM ReturnOrder LIMIT 1];
         List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id,IsMIG__c, POINT_TRX_ID__c,AR_INVOICE_NO__c, DEPOSIT_AMT__c, DEPOSIT_TYPE__c , TID__c, UPAD_DETAIL_TYPE__c ,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,SR_PAYMENT_BASIS_ID__c,FM_Order_Number__c,PAY_CUST_NAME__c,PAY_CUST_PHONE__c, MBS_CUST_ID__c  FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];
         List<SR_SMARTRO_PAYMENT_REQUEST__c> requests = [SELECT Id, MID__c, MOID__c, TID__c, APPR_AMT__c FROM SR_SMARTRO_PAYMENT_REQUEST__c];
         List<ProductRequest> pr = [SELECT id, TID__c FROM ProductRequest LIMIT 1];
         for(SR_SMARTRO_PAYMENT_REQUEST__c item : requests){
             item.PAYMETHOD__c = 'CARD';
             item.TID__c = srArConfirms[0].TID__c; 
         }
         update requests;
         pr[0].TID__c = srArConfirms[0].TID__c;
         update pr;
         update srArConfirms;
         if(!returnOrders.isEmpty() && !srArConfirms.isEmpty() && !requests.isEmpty()){
             srArConfirms[0].DEPOSIT_TYPE__c = 'E';
             // srArConfirms[0].UPAD_DETAIL_TYPE__c = 'PG_VBANK';
             Map<String, String> orderNumberMOIDMap = new Map<String, String>();
             orderNumberMOIDMap.put(srArConfirms[0].SR_PAYMENT_BASIS_ID__r.BASIS_NO__c, requests[0].MOID__c);
             Map<String, String> confirmIdTrxIdMap = new Map<String, String>();
             confirmIdTrxIdMap.put(srArConfirms[0].Id, 'TRX_ID_TEST' );
             Map<String, Set<String>> roIdTrxIdSetMap = new Map<String, Set<String>>();
             Set<String> trxIdSet = new Set<String>();
             trxIdSet.add('TRX_ID_TEST');
             roIdTrxIdSetMap.put(returnOrders[0].Id, trxIdSet);
             Map<String, List<ReturnOrderLineItem>> roIdRoLiListMap = new Map<String, List<ReturnOrderLineItem>>();
             roIdRoLiListMap.put(returnOrders[0].Id, returnOrders[0].ReturnOrderLineItems);
             Map<String, ReturnOrderLineItem> kTrxIdRoLiMap = new Map<String, ReturnOrderLineItem>();
             kTrxIdRoLiMap.put(returnOrders[0].Id, returnOrders[0].ReturnOrderLineItems[0]);
             Map<String, SM_DEPT__c> deptCodeMap = new Map<String, SM_DEPT__c>();
             for(SM_DEPT__c dep : [SELECT Id, DEPT_CODE__c , DEPT_NAME__c FROM SM_DEPT__c]){
                 deptCodeMap.put(dep.DEPT_CODE__c, dep);
             }
 
             Map<String, String> saleNumberMOIDMap = new Map<String, String>();
 
             Map<String, Object> paramMap = new Map<String, Object>();
             paramMap.put('orderNumberMOIDMap', orderNumberMOIDMap);
             paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
             paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
             paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
             paramMap.put('kTrxIdRoLiMap', kTrxIdRoLiMap);
             paramMap.put('deptCodeMap', deptCodeMap);
             paramMap.put('saleNumberMOIDMap',saleNumberMOIDMap);
             Map<String, Decimal> roIdReturnQuantityMap = new Map<String, Decimal>();
             Map<String, String> roIdReturnGoodsNameMap = new Map<String, String>();
             paramMap.put('roIdReturnQuantityMap', roIdReturnQuantityMap);
             paramMap.put('roIdReturnGoodsNameMap', roIdReturnGoodsNameMap);
 
             EX_ReturnConfirmQueueable q = new EX_ReturnConfirmQueueable(returnOrders[0], srArConfirms[0], paramMap,null);
             System.enqueueJob(q);
             
 
         }
 
 
         Test.stopTest();
     }         
 
     @IsTest
     static void test04() {
         Test.startTest();
         List<ReturnOrderLineItem> roli = [SELECT Id,ProductRequestLineItem.TID__c,ProductRequestLineItem.MOID__c,ProductRequestLineItem.POINT_TRX_ID__c FROM ReturnOrderLineItem];
         List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id,IsMIG__c, POINT_TRX_ID__c,AR_INVOICE_NO__c, DEPOSIT_AMT__c, DEPOSIT_TYPE__c , TID__c, UPAD_DETAIL_TYPE__c ,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,SR_PAYMENT_BASIS_ID__c,FM_Order_Number__c,PAY_CUST_NAME__c,PAY_CUST_PHONE__c, MBS_CUST_ID__c  FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];
 
         EX_ReturnConfirmQueueable.updateRoliPtid(srArConfirms[0].DEPOSIT_TYPE__c,roli); 
 
 
 
 
         Test.stopTest();
     }
 
     @IsTest
     static void test05() {
         Test.startTest();
         List<ReturnOrderLineItem> roLiList = [SELECT Id,ProductRequestLineItem.TID__c, Order_Number__c, ProductRequestLineItem.Order_Number__c  FROM ReturnOrderLineItem];
 
         // List<SR_AR_CONFIRM__c> srArConfirms = [SELECT Id, POINT_TRX_ID__c,AR_INVOICE_NO__c, DEPOSIT_AMT__c, DEPOSIT_TYPE__c , TID__c, UPAD_DETAIL_TYPE__c ,SR_PAYMENT_BASIS_ID__r.BASIS_NO__c,INVOICE_ISSUE_TYPE__c,APPR_NUM__c,TID_CASH__c,SR_PAYMENT_BASIS_ID__c,FM_Order_Number__c  FROM SR_AR_CONFIRM__c ORDER BY DEPOSIT_AMT__c DESC];
 
         EX_ReturnConfirmQueueable.updateRoliSDPN(roLiList); 
 
 
 
 
         Test.stopTest();
     }
 
     private static Map<String, String> apiMap;
     private static Map<String, String> getApiMap(){
         if(apiMap == null){
             apiMap = new Map<String, String>();
             for(PaymentAPISetting_cs__c apiSetting : [SELECT Name, EndPoint__c FROM PaymentAPISetting_cs__c]){
                 apiMap.put(apiSetting.Name, apiSetting.EndPoint__c);
             }
         }
         return apiMap;
     }
     // StatusCode=200 Mock
     private class HttpCalloutSuccessMock implements HttpCalloutMock {
         public HTTPResponse respond(HTTPRequest req) {
             HttpResponse res = newResponse(200, req.getEndpoint());
 
             return res;
         }
     }

     private class HttpCalloutSuccessMockFail implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = newResponse(500, req.getEndpoint());

            return res;
        }
    }

     // HTTPResponse 객체 생성
     private static HTTPResponse newResponse(Integer statusCode, String endpoint) {
         HttpResponse res = new HttpResponse();
         res.setHeader('Content-Type', 'application/json');
         res.setStatusCode(statusCode);
         if(endpoint.equalsIgnoreCase(getApiMap().get('CancelApproval'))){
             res.setBody('{ "ResultCode" : "2001", "CancelAmt" : "20000", "PTid" : "325324242" }');
         }else if(endpoint.equalsIgnoreCase(getApiMap().get('SpendOrCancelPoint'))){
             Blob INIT_VECTOR_FOR_POINT = Blob.valueOf('\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000\u0000');
             Blob SECRET_KEY_FOR_POINT = Blob.valueOf('SFDCSEVICECENTER');
             Blob encrypted = Crypto.encrypt('AES128', SECRET_KEY_FOR_POINT, INIT_VECTOR_FOR_POINT, Blob.valueOf('{ "RTN_CD":"S", "RTN_MSG":"정상처리되었습니다"}'));
             res.setBody(EncodingUtil.base64Encode(encrypted));
         }else if(endpoint.equalsIgnoreCase(getApiMap().get('CheckRefundAccount'))){
             res.setBody('{ "ResultCode" : "4200", "PayMethod" : "ACCN", "Mid" : "tlgsmp001m", "Tid" : "325324242" }');
         }else if(endpoint.equalsIgnoreCase(getApiMap().get('RefundCashFromVirtualAccount'))){
             res.setBody('{ "ResultCode" : "4311", "MOID" : "VBANK000000000004", "Mid" : "tlgsmp001m", "Tid" : "325324242", "Amt": "30000" }');
         }
 
         return res;
     }
 
     private class HttpCalloutResponseMock implements HttpCalloutMock {
         /**
          * @description respond
          * @param request HttpRequest
          * @return HttpResponse
          */
         public HttpResponse respond(HttpRequest request) {
             HttpResponse response = new HttpResponse();
             response.setStatusCode(200);
             response.setBody(FN_PaymentAgent.getEncryptedParamForPoint('{\n' +
                     '  "OutResult": [\n' +
                     '    {\n' +
                     '      "MBS_CUST_ID": "1000294683",\n' +
                     '      "REMAIN_POINT": 100000000\n' +
                     '    }\n' +
                     '  ],\n' +
                     '  "RTN_CD": "S",\n' +
                     '  "RTN_MSG": "정상 조회되었습니다.(1건)"\n' +
                     '}'));
             return response;
         }
     }
 

     private class HttpCalloutResponseMockFail implements HttpCalloutMock {
        /**
         * @description respond
         * @param request HttpRequest
         * @return HttpResponse
         */
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(500);
            response.setBody(FN_PaymentAgent.getEncryptedParamForPoint('{\n' +
                    '  "OutResult": [\n' +
                    '    {\n' +
                    '      "MBS_CUST_ID": "1000294683",\n' +
                    '      "REMAIN_POINT": 100000000\n' +
                    '    }\n' +
                    '  ],\n' +
                    '  "RTN_CD": "F",\n' +
                    '  "RTN_MSG": "실패 (1건)"\n' +
                    '}'));
            return response;
        }
    }
 
 }