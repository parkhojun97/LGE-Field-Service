/**
 * Created by A82371 on 2023-04-13.
 */

@IsTest
private class EX_CancelCashReceipt_ts
{
    @IsTest
    static void testBehavior(){
        Test.startTest();
        
        List<ReturnOrderLineItem> roliList = new List<ReturnOrderLineItem>();
        roliList.add(EX_TestDataUtil.getReturnOrderLineItem(true));

        SR_COLLECTION__c kCol0 = createCollection(FN_Consts.PAY_TYPE_PG_URL);
        SR_COLLECTION__c kCol1 = createCollection(FN_Consts.PAY_TYPE_PG_URL);
        SR_COLLECTION_BUNDLE__c kBundle = createCollectionBundle(FN_Consts.PAY_TYPE_PG_URL);
        kCol0.SR_COLLECTION_BUNDLE_ID__c = kBundle.Id;
        kCol1.SR_COLLECTION_BUNDLE_ID__c = kBundle.Id;
        update kCol0;
        update kCol1;


        SR_SMARTRO_PAYMENT_REQUEST__c kRequest = createRequestHistory(kCol0.SR_AR_CONFIRM_ID__c, FN_Consts.PAY_TYPE_CASHRCPT);
        Map<String, String> kArgMap = getArgMap();
        createPaymentAPISetting();


        // SR_SMARTRO_PAYMENT_REQUEST__c srp = EX_TestDataUtil.getSmartroPaymentRequest(true);
    
        // srp.APPR_BALANCE__c = 100;
        // update srp;

        SR_SMARTRO_PAYMENT_CANCEL__c srpCancel = new SR_SMARTRO_PAYMENT_CANCEL__c();
        srpCancel.PTID__c = 'PTID';
        srpCancel.SR_SMARTRO_PAYMENT_REQUEST_ID__c = kRequest.Id;
        insert srpCancel;


        try{
            Test.setMock(HttpCalloutMock.class, new HttpCalloutVBankCancelMock('sdfasdfasdfwerdfjgusdfg87674et7ertkhklhsdfhj', '0'));
            EX_TestDataUtil.getPaymentAPISetting('CancelApproval','https://tapproval.smartropay.co.kr/payment/approval/cancel.do');
            EX_CancelCashReceipt ccr = new EX_CancelCashReceipt(
                                                                EX_TestDataUtil.getPrePaymentDetail(true), 
                                                                EX_TestDataUtil.getPaymentGateway(true), 
                                                                2000,
                                                                EX_TestDataUtil.getReturnOrder(true),
                                                                roliList);
            System.enqueueJob(ccr);
        }catch(Exception e){
            System.debug(e);
        }
        Test.stopTest();
    }

    static FN_PaymentModel.T_REQ_CancelPayment getParamForCancelPayment() {
        FN_PaymentModel.T_REQ_CancelPayment kReq = new FN_PaymentModel.T_REQ_CancelPayment();
        kReq.Mid = 'mid';
        kReq.merchantKey = MERCHANT_KEY;

        kReq.Tid = 'tid';

        kReq.CancelAmt = '50000';
        return kReq;
    }

    
    private static void createPaymentAPISetting() {
        List<PaymentAPISetting_cs__c> kList = new List<PaymentAPISetting_cs__c>();

        kList.add(new PaymentAPISetting_cs__c(Name = 'VirtualAccount', ApiKey__c = 'a', EndPoint__c = 'b'));

        kList.add(new PaymentAPISetting_cs__c(Name = 'SpendOrCancelPoint', ApiKey__c = 'c', EndPoint__c = 'd'));

        kList.add(new PaymentAPISetting_cs__c(Name = 'CheckPoint', ApiKey__c = 'e', EndPoint__c = 'f'));

        kList.add(new PaymentAPISetting_cs__c(Name = 'CardUrl', ApiKey__c = 'ee', EndPoint__c = 'ff'));

        kList.add(new PaymentAPISetting_cs__c(Name = 'CancelCardUrl', ApiKey__c = 'eee', EndPoint__c = 'fff'));

        kList.add(new PaymentAPISetting_cs__c(Name = 'CancelApproval', ApiKey__c = 'eeee', EndPoint__c = 'ffff'));

        kList.add(new PaymentAPISetting_cs__c(Name = 'CheckRefundAccount', ApiKey__c = 'eeeee', EndPoint__c = 'fffff'));

        kList.add(new PaymentAPISetting_cs__c(Name = 'RequestCashReceipt', ApiKey__c = 'eeeeess', EndPoint__c = 'fffffss'));

        kList.add(new PaymentAPISetting_cs__c(Name = 'RefundCashFromVirtualAccount', ApiKey__c = 'eett', EndPoint__c = 'fftt'));

        insert kList;
    }



    // StatusCode=200 Mock
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = newResponse(200);
            return res;
        }
    }

    private static Map<String, String> getArgMap() {
        Map<String, String> kMap = new Map<String, String>();
        kMap.put('receiverName', '홍길동');
        kMap.put('receiverPhone', '01023456789');
        kMap.put('bankCode', '020');
        kMap.put('depositDueDate', Datetime.now().format('YYYY-MM-dd'));

        return kMap;
    }


    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody('{ "ResultCode" : "2001" , "CancelAmt" : "3000" }');
        return res;
    }

    private static SR_AR_CONFIRM__c createARConfirm(String aPayType) {
        SR_AR_CONFIRM__c kAR = new SR_AR_CONFIRM__c();
        kAR.SR_PAYMENT_BASIS_ID__c = createPaymentBasis().Id;
        kAR.UPAD_DETAIL_TYPE__c = aPayType;
        kAR.VIRTUAL_ACCT_NUMBER__c = 'VIRTUAL_ACCT_NUMBER__c';
        kAR.CARD_URL__c = 'http://cardUrl';
        insert kAR;
        return kAR;

    }


    private static SR_COLLECTION__c createCollection(String aPayType) {
        SR_AR_CONFIRM__c kAR = createARConfirm(aPayType);

        SR_COLLECTION__c kCol = new SR_COLLECTION__c();
        kCol.SM_DEPT_CODE_ID__c = createDept().Id;

        createGateway(kCol.SM_DEPT_CODE_ID__c);
        kCol.SR_AR_CONFIRM_ID__c = kAR.Id;


        insert kCol;
        return kCol;
    }

    private static SR_PAYMENT_BASIS__c createPaymentBasis() {
        SR_PAYMENT_BASIS__c basis = new SR_PAYMENT_BASIS__c();
        //basis.WORK_ORDER_ID__c = wo.Id;
        basis.BIZ_ORIGIN_TYPE__c = 'B';
        basis.BASIS_NO__c = 'bbbb';
        basis.RED_BLACK__c = 'B';
        basis.BASIS_DT__c = Date.newInstance(2023, 1, 25);
        basis.SETTLE_AMT__c = 10000;
        insert basis;
        return basis;
    }


    
    private static SM_DEPT__c createDept() {
        SM_DEPT__c dept = new SM_DEPT__c(ELEC_YN__c = 'N', KIOSK_YN__c = 'N', PC_YN__c = 'N', PHONE_YN__c = 'N');
        insert dept;
        return dept;
    }
    
    private final static String MERCHANT_KEY = 'IGp3k/3j2e3toqdnizlGFZIE9YKLQ15TDqTVP+f3uy3iOPt3hxhXfywDDC7cde1f5YrrxfV3wZxVVR8zuL2fbw==';

    private static Payment_Gateway__c createGateway(Id deptId) {

        Payment_Gateway__c pg = new Payment_Gateway__c(SM_DEPT__c = deptId, DIV_CODE__c = 'PG카드_URL/가상계좌', MID__c = 'mid', SIGN_KEY__c = MERCHANT_KEY);
        insert pg;
        return pg;
    }


    
    private static SR_COLLECTION_BUNDLE__c createCollectionBundle(String aPayType) {
        SR_COLLECTION_BUNDLE__c kBundle = new SR_COLLECTION_BUNDLE__c();
        kBundle.REQUEST_PAY_TYPE__c = aPayType;
        insert kBundle;
        return kBundle;
    }


    
    private static SR_SMARTRO_PAYMENT_REQUEST__c createRequestHistory(String aARId, String aPayType) {
        SR_SMARTRO_PAYMENT_REQUEST__c kRequest = new SR_SMARTRO_PAYMENT_REQUEST__c();
        kRequest.SMARTRO_PAYMENT_REQUEST_PK__c = 'pk' + SUtil.uuid(32);
        kRequest.SR_AR_CONFIRM_ID__c = aARId;
        kRequest.PAYMENT_TYPE__c = aPayType;
        kRequest.MID__c = 'moid';
        kRequest.TID__c = 'tid';
        kRequest.APPR_AMT__c = 10000;
        kRequest.CANCEL_AMT__c = 10000;
        insert kRequest;
        return kRequest;
    }

    class HttpCalloutVBankCancelMock implements HttpCalloutMock {
        private final String key;
        private final String ballance;

        HttpCalloutVBankCancelMock(String aKey, String aBallance) {
            key = aKey;
            ballance = aBallance;
        }
        /**
         * @description 응답 처리
         * @param request HttpRequest
         * @return HttpResponse
         */
        public HttpResponse respond(HttpRequest request) {
            Map<String, Object> kMap = (Map<String, Object>) JSON.deserializeUntyped(request.getBody());
            String enc = (String) kMap.get('EncData');
            Blob dec = Crypto.decrypt('AES256', Blob.valueOf(key.left(32)), Blob.valueOf(''.leftPad(16, '\u0000')), EncodingUtil.base64Decode(enc));
            FN_PaymentModel.T_REQ_CancelPayment req = (FN_PaymentModel.T_REQ_CancelPayment) JSON.deserialize(dec.toString(), FN_PaymentModel.T_REQ_CancelPayment.class);
            FN_PaymentModel.T_RES_CancelPayment kRes = new FN_PaymentModel.T_RES_CancelPayment();
            kRes.ResultCode = '2001';
            kRes.message = 'Success';
            kRes.CancelAmt = req.CancelAmt;
            kRes.RemainAmt = ballance;
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setBody(JSON.serialize(kRes));
            return response;
        }
    }


}