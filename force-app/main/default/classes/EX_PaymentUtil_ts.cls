/**
 * Created by MS on 2023-05-02.
 */

 @IsTest
 private class EX_PaymentUtil_ts {
     @TestSetup
     static void setup() {
         Test.startTest();
         TemplateMgmt__c tmgt = new TemplateMgmt__c();
         tmgt.Content_c__c = 'teststests';
         tmgt.Title__c = 'testsetse';
        //  tmgt.recordTypeId = Schema.SObjectType.TemplateMgmt__c.getRecordTypeInfosByDeveloperName().get('KakaoTalk').getRecordTypeId(); [524]
        //  tmgt.TemplateCode__c = 'SVC_LGE_MACN_012_01';
        tmgt.TemplateCode__c = 'SVC_LGE_MACN_012_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
         TemplateMgmt__c tm2 = tmgt.clone(false);
        //  tm2.TemplateCode__c = 'SVC_LGE_MACN_011';
        tm2.TemplateCode__c = 'SVC_LGE_MACN_011_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
         TemplateMgmt__c tm3 = tmgt.clone(false);
        //  tm3.TemplateCode__c = 'SVC_LGE_MACN_030';
        tm3.TemplateCode__c = 'SVC_LGE_MACN_030_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
         TemplateMgmt__c tm4 = tmgt.clone(false);
        //  tm4.TemplateCode__c = 'SVC_LGE_MACN_031';
        tm4.TemplateCode__c = 'SVC_LGE_MACN_031_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
         TemplateMgmt__c tm5 = tmgt.clone(false);
         tm5.TemplateCode__c = 'SVC_LGE_MACN_S012';
         TemplateMgmt__c tm6 = tmgt.clone(false);
        //  tm6.TemplateCode__c = 'SVC_LGE_MACN_S011';
        tm6.TemplateCode__c = 'SVC_LGE_MACN_S011_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
         TemplateMgmt__c tm7 = tmgt.clone(false);
         tm7.TemplateCode__c = 'SVC_LGE_MACN_013_1';
         insert new List<TemplateMgmt__c>{
                 tmgt, tm2, tm3, tm4, tm5, tm6, tm7
         };
 
 
         TemplateParams__c tprm = new TemplateParams__c();
         tprm.FieldApi__c = 'Label1__c';
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
         TemplateParams__c tp7 = tprm.clone(false);
         insert new List<TemplateParams__c>{
                 tprm, tp2, tp3, tp4, tp5, tp6, tp7
         };
 
         EX_Message__c exMessage = new EX_Message__c();
         exMessage.Label1__c = 'test';
         exMessage.Label2__c = 'test';
         insert exMessage;
 
         IF_Master__c ifMaster = new IF_Master__c();
         ifMaster.IfId__c = 'infobip_kakao';
         ifMaster.Name = '[공통] 인포빕 카카오 알림톡 발송';
         ifMaster.Type__c = 'Outbound';
         ifMaster.WebServiceType__c = 'REST';
         ifMaster.Method__c = 'POST';
         ifMaster.ContentType__c = 'application/json';
         ifMaster.Endpoint__c = 'https://xrenll.api.infobip.com/omni/1/advanced';
         ifMaster.ParaAddHeader__c = '{"Host":"api.infobip.com"}';
         ifMaster.APIKeyName__c = 'Authorization';
         ifMaster.APIKeyValue__c = 'App d46fc6972158988ceb6e0fc6760cfb3d-d6104bab-1322-43aa-ac2a-3dba6461b3f3';
         ifMaster.ApexClass__c = 'AIF_CM_SFDC_KAKAO';
         ifMaster.IsSendParameter__c = false;
         ifMaster.isLogInsert__c = false;
 
         insert ifMaster;
 
         PaymentAPISetting_cs__c apiSetting1 = new PaymentAPISetting_cs__c();
         apiSetting1.Name = 'CancelApproval';
         apiSetting1.EndPoint__c = 'https://tapproval.smartropay.co.kr/payment/approval/cancel.do';
 
         PaymentAPISetting_cs__c apiSetting2 = new PaymentAPISetting_cs__c();
         apiSetting2.Name = 'SpendOrCancelPoint';
         apiSetting2.EndPoint__c = 'https://dev-apigw-ext.lge.com:7221/gateway/newbest/api2api/mbsmgt/reqMbsPointUse.do';
         apiSetting2.ApiKey__c = 'h0wqRGYN2xb3zTexiNDLYwelBxmB6JceZoFP3BokrGp8=';
         apiSetting2.xGatewayAPIKey__c = 'e783d29a-a6f0-41c2-a853-e88e2f6c7109=';
 
         insert new List<PaymentAPISetting_cs__c>{
                 apiSetting2, apiSetting1
         };
 
         EX_TestDataUtil.getProductRequestLineItem(true);
         EX_TestDataUtil.getPrePaymentDetail(true);
 
         Test.stopTest();
     }
 
     @IsTest
     static void test01() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         List<ProductRequestLineItem> lineItems = [SELECT Id, ParentId FROM ProductRequestLineItem LIMIT 1];
         List<SM_DEPT__c> depts = [SELECT Id FROM SM_DEPT__c LIMIT 1];
         List< SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT Id, BANK_CODE__c, MOID__c, VIRTUAL_ACCT_NUMBER__c, CARD_URL__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
         if (!lineItems.isEmpty() && !depts.isEmpty() && !paymentDetails.isEmpty()) {
 
             EX_PaymentUtil.ExfetchMessage('pgVBank'
                     , lineItems[0].ParentId
                     , depts[0].Id
                     , paymentDetails[0]
                     , 'test prod'
                     , Date.today()
                     , Decimal.valueOf(30000));
 
 
             EX_PaymentUtil.ExSendMessage('01012345678'
                     , 'pgVBank'
                     , lineItems[0].ParentId
                     , depts[0].Id
                     , paymentDetails[0]
                     , 'test prod'
                     , Date.today()
                     , Decimal.valueOf(30000));
 
 
         }
 
         Test.stopTest();
     }
    //  @IsTest
    //  static void test02() {
    //      Test.startTest();
    //      Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
    //      List<ProductRequestLineItem> lineItems = [SELECT Id, ParentId FROM ProductRequestLineItem LIMIT 1];
    //      List<SM_DEPT__c> depts = [SELECT Id FROM SM_DEPT__c LIMIT 1];
    //      List< SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT Id, BANK_CODE__c, MOID__c, VIRTUAL_ACCT_NUMBER__c, CARD_URL__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
    //      if (!lineItems.isEmpty() && !depts.isEmpty() && !paymentDetails.isEmpty()) {
 
    //          EX_PaymentUtil.ExSendMessage('01012345678'
    //                  , 'pgUrl'
    //                  , lineItems[0].ParentId
    //                  , depts[0].Id
    //                  , paymentDetails[0]
    //                  , 'test prod'
    //                  , Date.today()
    //                  , Decimal.valueOf(30000));
    //      }
 
    //      Test.stopTest();
    //  }
     @IsTest
     static void test03() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         List<ProductRequestLineItem> lineItems = [SELECT Id, ParentId FROM ProductRequestLineItem LIMIT 1];
         List<SM_DEPT__c> depts = [SELECT Id FROM SM_DEPT__c LIMIT 1];
         List< SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT Id, BANK_CODE__c, MOID__c, VIRTUAL_ACCT_NUMBER__c, CARD_URL__c, TID__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
 
         if (!lineItems.isEmpty() && !depts.isEmpty() && !paymentDetails.isEmpty()) {
             SI_SMARTRO_TOTAL_PAYMENT__c payment = new SI_SMARTRO_TOTAL_PAYMENT__c();
             payment.TID__c = paymentDetails[0].TID__c;
             payment.OID__c = paymentDetails[0].MOID__c;
             payment.PAYMETHOD__c = 'CARD';
             payment.RESULT_CODE__c = '3001';
             payment.AMT__c = 30000;
             payment.AUTH_CODE__c = '32dfas2432';
             payment.AUTH_DATE__c = '20230502123030';
             insert payment;
             List<SI_SMARTRO_TOTAL_PAYMENT__c> payments = new List<SI_SMARTRO_TOTAL_PAYMENT__c>{
                     payment
             };
 
             ProductRequest pr = [SELECT Id FROM ProductRequest LIMIT 1];
             pr.APPR_NUM__c = null;
             update pr;
             EX_PaymentUtil.updateProductRequest(payments);
 
             ProductRequest pr1 = [SELECT Id FROM ProductRequest LIMIT 1];
             pr1.APPR_NUM__c = null;
             update pr1;
 
             payment.RESULT_CODE__c = '2001';
             update payment;
             EX_PaymentUtil.updateProductRequest(payments);
 
             ProductRequest pr2 = [SELECT Id FROM ProductRequest LIMIT 1];
             pr2.APPR_NUM__c = null;
             update pr2;
 
             payment.PAYMETHOD__c = 'VBANK';
             payment.RESULT_CODE__c = '4110';
             update payment;
             EX_PaymentUtil.updateProductRequest(payments);

             payment.RESULT_CODE__c = '4100';
             update payment;
             EX_PaymentUtil.updateProductRequest(payments);
 
             payment.RESULT_CODE__c = '2001';
             update payment;
             EX_PaymentUtil.updateProductRequest(payments);
 
         }
 
         Test.stopTest();
     }
     @IsTest
     static void test07() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         List<ProductRequestLineItem> lineItems = [SELECT Id, ParentId FROM ProductRequestLineItem LIMIT 1];
         List<SM_DEPT__c> depts = [SELECT Id FROM SM_DEPT__c LIMIT 1];
         List< SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT Id, BANK_CODE__c, MOID__c, VIRTUAL_ACCT_NUMBER__c, CARD_URL__c, TID__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
 
         if (!lineItems.isEmpty() && !depts.isEmpty() && !paymentDetails.isEmpty()) {
             SI_SMARTRO_TOTAL_PAYMENT__c payment = new SI_SMARTRO_TOTAL_PAYMENT__c();
             payment.TID__c = paymentDetails[0].TID__c;
             payment.OID__c = paymentDetails[0].MOID__c;
             payment.PAYMETHOD__c = 'CARD';
             payment.RESULT_CODE__c = '4110';
             payment.AMT__c = 30000;
             payment.AUTH_CODE__c = '32dfas2432';
             payment.AUTH_DATE__c = '20230502123030';
             insert payment;
             List<SI_SMARTRO_TOTAL_PAYMENT__c> payments = new List<SI_SMARTRO_TOTAL_PAYMENT__c>{
                     payment
             };
 
             ProductRequest pr = [SELECT Id FROM ProductRequest LIMIT 1];
             pr.APPR_NUM__c = null;
             update pr;
             EX_PaymentUtil.updateProductRequest(payments);
 
             ProductRequest pr1 = [SELECT Id FROM ProductRequest LIMIT 1];
             pr1.APPR_NUM__c = null;
             update pr1;
 
             payment.RESULT_CODE__c = '2001';
             update payment;
             EX_PaymentUtil.updateProductRequest(payments);
 
             ProductRequest pr2 = [SELECT Id FROM ProductRequest LIMIT 1];
             pr2.APPR_NUM__c = null;
             update pr2;
 
             payment.PAYMETHOD__c = 'VBANK';
             payment.RESULT_CODE__c = '4110';
             update payment;
             EX_PaymentUtil.updateProductRequest(payments);

             payment.RESULT_CODE__c = '4100';
             update payment;
             EX_PaymentUtil.updateProductRequest(payments);
              
 
             payment.RESULT_CODE__c = '2001';
             update payment;
             EX_PaymentUtil.updateProductRequest(payments);
 
         }
 
         Test.stopTest();
     }
     @IsTest
     static void test04() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         List<EX_Message__c> messages = [SELECT Id, Label1__c, Label2__c FROM EX_Message__c LIMIT 1];
         List<ProductRequestLineItem> lineItems = [SELECT Id, ParentId FROM ProductRequestLineItem LIMIT 1];
         List<SM_DEPT__c> depts = [SELECT Id, Name FROM SM_DEPT__c LIMIT 1];
         if (!messages.isEmpty()) {
 
            //  EX_PaymentUtil.sendKaKaoMessage('SVC_LGE_MACN_012_01', messages[0], '01012345678');
            EX_PaymentUtil.sendKaKaoMessage('SVC_LGE_MACN_012_1', messages[0], '01012345678'); //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
         }
 
         Test.stopTest();
     }
 
     @IsTest
     static void test05() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         List<ProductRequestLineItem> lineItems = [SELECT Id, ParentId FROM ProductRequestLineItem LIMIT 1];
         lineItems[0].PAYMENT_Amount__c = 2000;
         update lineItems[0];
         List<SM_DEPT__c> depts = [SELECT Id, Name FROM SM_DEPT__c LIMIT 1];
 
         if (!lineItems.isEmpty() && !depts.isEmpty()) {
             try {
                 EX_PaymentUtil.requestSpendPoint('1000294683', Decimal.valueOf(2000), depts[0].Id, depts[0].Name, lineItems[0].ParentId);
 
                //  lineItems[0].PAYMENT_Amount__c = 0;
                //  update lineItems[0];
                //  EX_PaymentUtil.requestSpendPoint('1000294683', Decimal.valueOf(2000), depts[0].Id, depts[0].Name, lineItems[0].ParentId);
             } catch (Exception e) {
                 System.debug(e);
             }
 
         }
 
         Test.stopTest();
     }
     @IsTest
     static void test05_1() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         List<ProductRequestLineItem> lineItems = [SELECT Id, ParentId FROM ProductRequestLineItem LIMIT 1];
         lineItems[0].PAYMENT_Amount__c = 1;
         update lineItems[0];
         List<SM_DEPT__c> depts = [SELECT Id, Name FROM SM_DEPT__c LIMIT 1];
 
         if (!lineItems.isEmpty() && !depts.isEmpty()) {
             try {
                //  EX_PaymentUtil.requestSpendPoint('1000294683', Decimal.valueOf(2000), depts[0].Id, depts[0].Name, lineItems[0].ParentId);
 
                //  lineItems[0].PAYMENT_Amount__c = 0;
                //  update lineItems[0];
                 EX_PaymentUtil.requestSpendPoint('1000294683', Decimal.valueOf(2000), depts[0].Id, depts[0].Name, lineItems[0].ParentId);
             } catch (Exception e) {
                 System.debug(e);
             }
 
         }
 
         Test.stopTest();
     }
 
 
     @IsTest
     static void test06() {
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
         List<ProductRequestLineItem> lineItems = [SELECT Id, ParentId, POINT_TRX_ID__c FROM ProductRequestLineItem LIMIT 1];
         List<SM_DEPT__c> depts = [SELECT Id, Name FROM SM_DEPT__c LIMIT 1];
 
         if (!lineItems.isEmpty() && !depts.isEmpty()) {
             try {
                 EX_PaymentUtil.requestCancelPoint('1000294683', lineItems[0].POINT_TRX_ID__c, Decimal.valueOf(2000), depts[0].Id, depts[0].Name, lineItems[0].ParentId);
             } catch (Exception e) {
                 System.debug(e);
             }
 
         }
 
         Test.stopTest();
     }
 
     private static Map<String, String> apiMap;
     private static Map<String, String> getApiMap() {
         if (apiMap == null) {
             apiMap = new Map<String, String>();
             for (PaymentAPISetting_cs__c apiSetting : [SELECT Name, EndPoint__c FROM PaymentAPISetting_cs__c]) {
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
     // HTTPResponse 객체 생성
     private static HTTPResponse newResponse(Integer statusCode, String endpoint) {
         HttpResponse res = new HttpResponse();
         res.setHeader('Content-Type', 'application/json');
         res.setStatusCode(statusCode);
         if (String.isNotBlank(endpoint) && 'https://xrenll.api.infobip.com/omni/1/advanced'.equalsIgnoreCase(endpoint)) {
             res.setBody('{ "resultCount" : "success", "result" : "success" }');
         } else if (endpoint.equalsIgnoreCase(getApiMap().get('CancelApproval'))) {
             res.setBody('{ "ResultCode" : "2001" }');
         } else if (endpoint.equalsIgnoreCase(getApiMap().get('SpendOrCancelPoint'))) {
             res.setBody('{ ACCUM_BRKDN_ID=1000006628366, ORIG_ACCUM_BRKDN_ID=1000006628286, "RTN_CD"="S", RTN_MSG="정상처리되었습니다"}');
         } else {
             res.setBody('{ "records" : [ { "Metadata" : { "customValue" : [ { "isActive" : true, "label" : "KB000", "valueName" : "KB000"} ] } } ] }');
         }
 
         return res;
 
     }
 
     @IsTest
     static void test_setBankPaymentType() {
         Map<String,String> paramMap = new Map<String, String>();
         ProductRequest pr = new ProductRequest();
         pr = [SELECT Id FROM ProductRequest LIMIT 1];
         paramMap.put('aType','test');
         paramMap.put('prId',pr.Id);
         Test.startTest();
         EX_PaymentUtil.setBankPaymentType(paramMap);
         Test.stopTest();
     }
 
     @IsTest
     static void test_strToCurrencyWon() {
         Test.startTest();
         EX_PaymentUtil.strToCurrencyWon('1000000');
         Test.stopTest();
     }
 
     @IsTest
     static void test_convertDate() {
         Test.startTest();
         EX_PaymentUtil.convertDate(Datetime.now());
         Test.stopTest();
     }
 
     @IsTest
     static void test_getUserProfile() {
         EX_TestDataUtil.getUser(true);
         
         Test.startTest();
         EX_PaymentUtil.getUserProfile();
         Test.stopTest();
     }
 
     @IsTest
     static void test_createExMessage() {
         ProductRequest pr = [SELECT Id, LIMIT_TM__c FROM ProductRequest LIMIT 1];
         pr.LIMIT_TM__c = System.today();
         update pr;
         Test.startTest();
 
         Map<String, Object> paramMap1 = new Map<String, Object>();
         Map<Object, Object> paramMap = new Map<Object, Object>();
         paramMap.put('payment' , 'PG_VBANK');
         paramMap.put('amount' , 1000);
         paramMap.put('receiverName' , 'test');
         paramMap.put('virtualBankAccountNo' , '10-10000-10000');
         paramMap.put('bank' , '신한');
         paramMap.put('depositDueDate' , '2024-12-31');
         
         paramMap1.put('Pass' , 'N');
         paramMap1.put('prId' , pr.Id);
         paramMap1.put('param' , paramMap);
 
 
         EX_PaymentUtil.createExMessage(paramMap1);
         paramMap.put('payment' , 'PG_VBANK1');
         
         paramMap1.put('param' , paramMap);
 
         EX_PaymentUtil.createExMessage(paramMap1);
         Test.stopTest();
     }
 
 
 
 
     @IsTest
     static void codeCheck3() {
         EX_TestDataUtil.getHolidays(true, '1');
         EX_SuppliesController.getDeliveryDate();
         EX_PaymentUtil.getDeliveryDate();
         SM_HOLIDAY_MASTER__c[] TestList = [SELECT Id, Name FROM SM_HOLIDAY_MASTER__c ]; 
         try {
             delete TestList;
         } catch (DmlException e) {
             // Process exception here
         }
 
         EX_TestDataUtil.getHolidays(true, '0');
         EX_SuppliesController.getDeliveryDate();
         EX_PaymentUtil.getDeliveryDate();
     }


     @IsTest
     static void test_resetPointAmount() {
        ProductRequest pr = [SELECT Id, LIMIT_TM__c FROM ProductRequest LIMIT 1];
        List<String> prIds = new List<String>();
        prIds.add(pr.Id);
        
        Test.startTest();
         EX_PaymentUtil.resetPointAmount(prIds);
         EX_PaymentUtil.checkPhoneVal('010-4049-8115');
         EX_PaymentUtil.checkPhoneVal('010-0000-00000');
         Test.stopTest();
    }

 }