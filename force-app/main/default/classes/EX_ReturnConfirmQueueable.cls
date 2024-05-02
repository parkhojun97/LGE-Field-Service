/**
 * Created by I2MAX.SEUNGHUNAN on 2023-04-11.
 */

public with sharing class EX_ReturnConfirmQueueable implements Queueable, Database.AllowsCallouts {
    private ReturnOrder ro;
    private SR_AR_CONFIRM__c arConfirm;
    private Map<String, Object> paramMap;
    private Decimal orderSeq;

    public EX_ReturnConfirmQueueable(ReturnOrder ro, SR_AR_CONFIRM__c arConfirm, Map<String, Object> paramMap, Decimal orderSeq) {
        this.ro = ro;
        this.arConfirm = arConfirm;
        this.paramMap = paramMap;
        this.orderSeq = orderSeq;
    }
    public void execute(QueueableContext context) {
        String moId = null, trxId = null, authCode = null, exDeptId = null, exDeptCode = null;
        Boolean isUpsertRoLi = false, isSuccess = false;
        ReturnOrderLineItem roLi = null;
        FNManager.RedRecorder recorder = FNManager.red(ro.ProductRequest.SR_SALE__c);
        Payment_Gateway__c kPg = null;
        SM_DEPT__c smDept = null;

        Decimal goalRoLiCount = 0, completeRoLiCount = 0;
        Decimal returnCardAmount = ro.RETURN_CARD_PAYMENT_Amount__c;
        // 포인트는 수량 취소 불가 TRX_ID 모두 환불(품목 별 전량)
        // Decimal returnPointAmount = ro.RETURN_POINT_Amount__c;
        Decimal returnVirtualAmount = ro.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c;
        Decimal refundAmt = 0;

        Map<String, String> saleNumberMOIDMap = (Map<String, String>) paramMap.get('saleNumberMOIDMap');
        // Map<String, String> confirmIdTrxIdMap = (Map<String, String>) paramMap.get('confirmIdTrxIdMap');
        Map<String, Set<String>> roIdTrxIdSetMap = (Map<String, Set<String>>) paramMap.get('roIdTrxIdSetMap');
        Map<String, List<ReturnOrderLineItem>> roIdRoLiListMap = (Map<String, List<ReturnOrderLineItem>>) paramMap.get('roIdRoLiListMap');
        Map<String, SM_DEPT__c> deptCodeMap = (Map<String, SM_DEPT__c>) paramMap.get('deptCodeMap');
        Map<String, Decimal> roIdReturnQuantityMap = (Map<String, Decimal>) paramMap.get('roIdReturnQuantityMap');
        Map<String, String> roIdReturnGoodsNameMap = (Map<String, String>) paramMap.get('roIdReturnGoodsNameMap');
        Map<String, ReturnOrderLineItem> kTrxIdRoLiMap = new Map<String, ReturnOrderLineItem>();

        Set<String> kTrxIdSet = roIdTrxIdSetMap.get(ro.Id);
        Set<String> kRoLiIdSet = new Set<String>();

        Map<Decimal, ReturnOrderLineItem> seqAndRoli = new Map<Decimal,ReturnOrderLineItem>(); //24 02 29 hyungho.chun 마이그건 대비 roli order seq당 원주문lineItem trxid저장

        // List<String> exObjIdList = (List<String>) paramMap.get('exObjIdList');

        System.debug('roIdRoLiListMap :: ' + roIdRoLiListMap);
        System.debug('kTrxIdRoLiMap : ' + kTrxIdRoLiMap);

        // System.debug('confirmId TrxIdMap : ' + confirmIdTrxIdMap);

        System.debug('roIdRoLiListMap : ' + roIdRoLiListMap);
        List<ReturnOrderLineItem> roLiList = roIdRoLiListMap.get(ro.Id);
        goalRoLiCount = roLiList.size() * 2;
        System.debug('roLiList :: ' + roLiList);
        System.debug('rLiList.size() : ' + roLiList.size());
        System.debug('goalRoLiCount : ' + goalRoLiCount);

        System.debug('returnOrder Id : ' + ro.Id);
        System.debug('arConfirm Id : ' +arConfirm.Id);


        // System.debug('exObjIdList Id : ' +exObjIdList);
        
        //23 09 12 hyungho.chun 현금영수증시 queue 2개호출문제로 체크해줌
        boolean isCashReceipt = false;
        
        
        exDeptCode = ro.ProductRequest.Department_Code__c;
        String deptId = [SELECT Id FROM SM_DEPT__c WHERE DEPT_CODE__c = 'PH8002' LIMIT 1].Id;
        //exDeptId = ro.ProductRequest.Department_Id__c;
        
        smDept = deptCodeMap.containsKey(exDeptCode) ? deptCodeMap.get(exDeptCode) : null;

        // 현재 ReturnOrder에 대한 LineItem 재쿼리
        roLiList = [
                SELECT Id, REFUND_Request_DTM__c, REFUND_Request_YN__c, REFUND_Requester_Id__c, ProductRequestLineItem.fm_Consumables_PART_DESC_KOR__c, Order_Number__c, CreatedDate, Order_CHNL_TYPE_Code__c,Order_SEQ__c,
                        ETC_REFUND_Complete_YN__c, RETURN_PAYMENT_NO__c, CASH_REM_YN__c, RETURN_POINT_Amount__c, 
                        POINT_REFUND_Complete_YN__c, RED_POINT_TRX_ID__c, Consumables_Business_Type_Code__c, REFUND_BANK_Code__c, ENC_REFUND_ACCT_Number__c, REFUND_DPSR_Name__c, 
                        ProductRequestLineItem.POINT_TRX_ID__c, ProductRequestLineItem.TID__c, ProductRequestLineItem.MOID__c, ProductRequestLineItem.Parent.fm_Payment_Type__c
                FROM ReturnOrderLineItem
                WHERE ReturnOrderId=:ro.Id ORDER BY CreatedDate DESC
        ];

        for (ReturnOrderLineItem roLineItem : roLiList) {
            kTrxIdRoLiMap.put(roLineItem.ProductRequestLineItem.POINT_TRX_ID__c, roLineItem);
            seqAndRoli.put(roLineItem.Order_SEQ__c, roLineItem);
        }

        Map<String,String> errorMap = new Map<String,String>();
        // Savepoint sp = Database.setSavepoint();


        //23 10 30 hyungho.chun 마이그데이터예상 예상 오류 로그
        errorMap.put('orderNum',roLiList[0].Order_Number__c);
        errorMap.put('orderChannel',roLiList[0].Order_CHNL_TYPE_Code__c);
        errorMap.put('errorType','ReturnConfirm');
        errorMap.put('recordId',roLiList[0].Id);

        //23 10 31 hyungho.chun 오류 로그 남기기 try-catch
        // Savepoint sp = Database.setSavepoint();
        try{
            // 환불처리는 소모품 택배건이면서 교환주문이 아닌 경우만
            if (ro.Order_CHNL_TYPE_Code__c.equals('V') && ro.Consumables_Business_Type_Code__c != 'ExchangeReturn') {
                //23 09 25 hyungho.chun 가상계좌 환불처리 환불계좌정보 미리 받기
                Map<String,String> refundBankInfoMap = new Map<String,String>();
                Boolean isVBankInfoOn = false;
                for (ReturnOrderLineItem kRoLi : roLiList) {
                    kRoLiIdSet.add(kRoLi.Id);
                    if(kRoLi.REFUND_BANK_CODE__c != null){
                        isVBankInfoOn = true;
                        refundBankInfoMap.put('BankCode', kRoLi.REFUND_BANK_Code__c);
                        refundBankInfoMap.put('BankAccount',kRoLi.ENC_REFUND_ACCT_Number__c);
                        refundBankInfoMap.put('BankAccountName',kRoLi.REFUND_DPSR_Name__c);
                    }
                    /**
                     *  환불요청일시(REFUND_Request_DTM__c)
                     *  환불요청여부(REFUND_Request_YN__c)
                     *  환불요청자Id(REFUND_Requester_Id__c)
                     *  환불요청을 실행할 것 이므로 하기 정보 업데이트
                     */
                    kRoLi.REFUND_Request_DTM__c = System.now();
                    kRoLi.REFUND_Request_YN__c = true;
                    kRoLi.REFUND_Requester_Id__c = UserInfo.getUserId();
                }
                switch on arConfirm.DEPOSIT_TYPE__c {
                    // A: 현금, B: 카드, D: 포인트, E: 미수
                    /**
                     * 소모품의 현금은 가상계좌
                     */
                    when 'A' {
                        //23 10 26 hyungho.chun arConfirm 마이그 데이터 UPAD_DETAIL_TYPE__c 안넣어줘서 뺌
                        // if (arConfirm.UPAD_DETAIL_TYPE__c != null) {
                            // 가상계좌 (결제 URL && 가상계좌 입금)
                            // if (arConfirm.UPAD_DETAIL_TYPE__c == 'PG_VBANK') {
                                // todo: 환불계좌 사용자 입력
                                // a1V0p000000SvDHEA0 => 소모품 PH8002
                                System.debug('결제방식 : 가상계좌 결제');
                                //kPg = FN_PaymentAgent.getMidKeyVirtualAccount(exDeptId);
                                kpg = FN_PaymentAgent.getMidKeyVirtualAccount(deptId);
                                System.debug('재경 모듈 Payment GateWay : ' + kpg);
                                FN_PaymentModel.T_REQ_BankAccount aParam = new FN_PaymentModel.T_REQ_BankAccount();
                                // 'tlgsmp001m'
                                aParam.Mid = kpg.MID__c;
                                // 'IGp3k/3j2e3toq`dnizlGFZIE9YKLQ15TDqTVP+f3uy3iOPt3hxhXfywDDC7cde1f5YrrxfV3wZxVVR8zuL2fbw==';
                                aParam.merchantKey = kpg.SIGN_KEY__c;
                                //23 09 25 hyungho.chun 가상계좌 환불처리 환불계좌정보 저장되어있다면 불러오기
                                if(isVBankInfoOn){
                                    aParam.BankCode = refundBankInfoMap.get('BankCode');
                                    aParam.BankAccount = refundBankInfoMap.get('BankAccount');
                                    aParam.BankAccountName = refundBankInfoMap.get('BankAccountName');
                                    System.debug('소모품 가상계좌 환불 정보 받았음');
                                }else{
                                    // aParam.BankCode = '088';
                                    // aParam.BankAccount = '0123456789';
                                    // aParam.BankAccountName = '홍길동테스트';
                                    System.debug('소모품 가상계좌 환불 정보 받지 않았음');
                                    // Database.rollback(sp);
                                    String tempMsg = '반품주문에 계좌정보가 비어있음, 흑자 SR_AR_CONFIRM Id : '+arConfirm.Id; 
                                    errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
                                    errorMap.put('requestMsg', '[Fail] : 1 건'); // 23 12 18 hyungho.chun 환불 늘 1건씩
                                    errorMap.put('isSuccess','N');
                                    errorMap.put('className','EX_ReturnConfirmQueueable');                            
                                    System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
                                    EX_ConsumableUtil.saveSaleExc(errorMap);
                                    System.debug('반품주문에 계좌정보가 비어있음');
                                    return;
                                    // throw new FNException('반품주문에 계좌정보가 비어있음');
                                }

                                System.debug('환불계좌 조회를 위한 Parameter : ' + aParam);
                                FN_PaymentModel.T_RES_BankAccount kResponse = FN_PaymentAgent.checkBankAccount(aParam);

                                System.debug('환불계좌 조회 결과 : ' + kResponse);
                                //24 03 19 hyungho.chun 간헐적으로나오는 가상계좌검증 response null인경우 대비
                                if(kResponse == null || kResponse.message == null){
                                    System.debug('간헐적나오는 가상계좌조회 null 로그처리');
                                    errorMap.put('requestMsg', 'aParam : '+ JSON.serialize(aParam) +', kResponse : ' + JSON.serialize(kResponse) );
                                }
                                if (!(kResponse.message.equals('Success') || kResponse.ResultCode.equals('4200'))) {
                                    // todo: 오류 정보 저장
                                    // Database.rollback(sp);
                                    String tempMsg = '환불계좌 조회 실패, 흑자 SR_AR_CONFIRM Id : '+arConfirm.Id; 
                                    errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
                                    errorMap.put('requestMsg', '[Fail] : 1 건'); // 23 12 18 hyungho.chun 환불 늘 1건씩
                                    errorMap.put('isSuccess','N');
                                    errorMap.put('className','EX_ReturnConfirmQueueable');                                    
                            
                                    System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
                                    EX_ConsumableUtil.saveSaleExc(errorMap);
                                    System.debug('환불계좌 조회 실패');
                                    return;
                                    // throw new FNException('환불계좌 조회 실패 : kResponse :: '+kResponse);
                                }

                                System.debug('환불계좌 조회 성공');
                                // roIdReturnQuantityMap, roIdReturnGoodsNameMap
                                Map<String, Object> aBody = new Map<String, Object>();
                                aBody.put('GOODS_NAME', roIdReturnGoodsNameMap.get(ro.Id));
                                aBody.put('GOODS_CNT', roIdReturnQuantityMap.get(ro.Id));
                                aBody.put('bank', aParam.BankCode);
                                aBody.put('bankAccountNo', aParam.BankAccount);
                                aBody.put('receiverName', aParam.BankAccountName);

                                // 소모품 PH8002 a1V0p000000SvDHEA0, merchantKey(aKey), moid(smartro)('a1V0p000000SvDHEA0');
                                system.debug('123paramMap :::'+paramMap);
                                system.debug('123saleNumberMOIDMap :::'+saleNumberMOIDMap);
                                moId = saleNumberMOIDMap.get(arConfirm.SR_PAYMENT_BASIS_ID__r.BASIS_NO__c);
                                System.debug('moId : ' + moId);
                                // 기취소건 어떻게 할지 고민 (같은 주문에서 arConfirm1, 2가 있을 때 1성공, 2실패라고 해도
                                // 최종 반품 확인을 위해서(goalRoLiCount)는 기존에 성공했던 1도 쿼리해야함.
                                // continue로 루프를 pass하느냐 재경모듈에서 실패해도 돌아가느냐 -> 기 취소건 일단 취소된 채권으로 모듈에서 튕김
                                System.debug('returnVirtualAmount ::::' +returnVirtualAmount);
                                FN_PaymentModel.T_RES_RefundCash response = FNAPI.refundBankAccountPartial(aBody, moId, returnVirtualAmount, kPg.MID__c, kpg.SIGN_KEY__c);
                                refundAmt = returnVirtualAmount;
                                System.debug('환불 response : ' + response);

                                // 결제 취소 성공
                                if (response.message == 'Success') {
                                    isSuccess = true;
                                    System.debug('가상계좌 환불 성공');
                                    System.debug('response : ' + response);
                                    authCode = response.AuthCode;
                                }
                                else {
                                    // todo: 오류 정보 저장
                                    // Database.rollback(sp);
                                    String tempMsg = '가상계좌 환불처리 실패, 흑자 SR_AR_CONFIRM Id : '+arConfirm.Id; 
                                    errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
                                    errorMap.put('requestMsg', '[Fail] : 1 건'); // 23 12 18 hyungho.chun 환불 늘 1건씩
                                    errorMap.put('isSuccess','N');
                                    errorMap.put('className','EX_ReturnConfirmQueueable');                            
                                    System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
                                    EX_ConsumableUtil.saveSaleExc(errorMap);
                                    System.debug('가상계좌 환불처리 실패');
                                    // throw new FNException('가상계좌 환불처리 실패 : Response :: '+response);
                                }

                                // 증빙유형 = 현금영수증 -> 현금영수증 취소
                                // INVOICE_ISSUE_TYPE__c
                                // A: 세금계산서, B: 현금영수증, C: 미발행, D: 카드
                                
                                //23 10 20 hyungho.chun 현금영수증중복발인되던거 취소용이라 이제 필요없음
    //                             if (arConfirm.INVOICE_ISSUE_TYPE__c == 'B') {
    //                                 System.debug('현금영수증 증빙유형 존재');
    //                                 System.debug('SR_PRE_PAYMENT_DETAIL__c 조회');
    //                                 SR_PRE_PAYMENT_DETAIL__c aContext = (SR_PRE_PAYMENT_DETAIL__c) SUtil.oneOrNull([
    //                                         SELECT Id, INVOICE_ISSUE_TYPE__c, TID_CASH__c, APPR_NUM__c, TID__c, POINT_TRX_ID__c
    //                                         FROM SR_PRE_PAYMENT_DETAIL__c
    //                                         WHERE TID_CASH__c =: arConfirm.TID_CASH__c AND APPR_NUM__c =: arConfirm.APPR_NUM__c
    //                                         LIMIT 1
    //                                 ]);
    //                                 System.debug('SR_PRE_PAYMENT_DETAIL__c : ' + aContext);
    //                                 if(!Test.isRunningTest()) kpg = FN_PaymentAgent.getMidKeyCashReceipt(exDeptId);
    //                                 System.debug('PaymentGateWay 조회 : ' + kpg);

    //                                 // CallOut Exception 으로 인해 현금영수증 취소 Async
    //                                 EX_CancelCashReceipt cancelCashReceipt = new EX_CancelCashReceipt(aContext, kPg, returnVirtualAmount, ro, roLiList);
    //                                 if (!Test.isRunningTest()) {
    //                                     isCashReceipt = true;
    //                                     System.enqueueJob(cancelCashReceipt);
    //                                 }
    // //                            FN_PaymentModel.T_RES_CancelPayment res = (FN_PaymentModel.T_RES_CancelPayment) FNPaymentCash.cancelCashReceiptApiPartial(aContext.TID_CASH__c, aContext.APPR_NUM__c, kAmountTest, kpg.MID__c, kpg.SIGN_KEY__c);
    // //                            if (res.message.equalsIgnoreCase('Success') || res.ErrorCode == '2013') {
    //                                 // 성공
    // //                                System.debug('현금영수증 취소 성공');
    // //                            }
    // //                            else {
    //                                 // todo: 오류 정보 저장
    //                                 // System.debug(res.ResultMsg);
    // //                                throw new FNException('현금영수증 취소 실패');
    // //                            }
    //                             }
                        //    }
                            // 센터수금계좌 소모품 X
    //                        else if (arConfirm.UPAD_DETAIL_TYPE__c == 'CM_VBANK') {
    //
    //                        }
                    //  }
                    }
                    when 'B' {
                        // a1V0p000000SvDHEA0 => 소모품 PH8002
                        System.debug('결제방식 : 카드 URL 결제');
                        // kpg = FN_PaymentAgent.getMidKeyCardUrl(exDeptId);
                        kPg = roLiList[0].ProductRequestLineItem.Parent.fm_Payment_Type__c == '현장카드' ? FN_PaymentAgent.getMidKeyPc(deptId) : FN_PaymentAgent.getMidKeyVirtualAccount(deptId);
                        System.debug('재경 모듈 PaymentGateway 조회 : ' + kpg);
                        System.debug('현재 결제 TID arConfirm출신 : ' + arConfirm.TID__c);
    //                FN_PaymentModel.T_RES_CancelPayment kResponse = FNPaymentCard.requestCancelCardPay(arConfirm.TID__c, kpg.MID__c, kpg.SIGN_KEY__c);
                        // FN_PaymentModel.T_RES_CancelPayment kResponse = FNPaymentCard.requestCancelCardPayPartial(arConfirm.TID__c, returnCardAmount, kpg.MID__c, kpg.SIGN_KEY__c);
                        
                        //23 10 23 hyungho.chun tid 이제 pr에서 찾음 (ar confirm 마이그 데이터에 tid없음)
                        System.debug('현재 결제 TID ProductRequest출신 : ' + ro.ProductRequest.TID__c);
                        FN_PaymentModel.T_RES_CancelPayment kResponse = FNPaymentCard.requestCancelCardPayPartial(ro.ProductRequest.TID__c, returnCardAmount, kpg.MID__c, kpg.SIGN_KEY__c);
                        if (!('Success'.equalsIgnoreCase(kResponse.message) || '2013' == kResponse.ResultCode)) {

                            // todo: 오류정보 저장
                            System.debug('kResponse : ' + kResponse);
                            // Database.rollback(sp);
                            String tempMsg = '카드 취소 실패, 흑자 SR_AR_CONFIRM Id : '+arConfirm.Id; 
                            errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
                            errorMap.put('requestMsg', '[Fail] : 1 건'); // 23 12 18 hyungho.chun 환불 늘 1건씩
                            errorMap.put('isSuccess','N');
                            errorMap.put('className','EX_ReturnConfirmQueueable');                    
                            System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
                            EX_ConsumableUtil.saveSaleExc(errorMap);
                            System.debug('카드 취소 실패');
                            // throw new FNException('카드 취소 실패 : kResponse :: '+kResponse);
                        }else{
                            isSuccess = true;
                            authCode = kResponse.PTid;
                            refundAmt = returnCardAmount;
                            System.debug('카드 취소 성공');
                            System.debug('카드 취소 결과 : ' + kResponse);
                        }

                    }
                    when 'D' {
                        System.debug('결제 방식 : 포인트 결제');
                        trxId = arConfirm.isMig__c ? seqAndRoli.get(orderSeq).ProductRequestLineItem.POINT_TRX_ID__c : arConfirm.POINT_TRX_ID__c; //24 02 29 hyungho.chun 마이그 데이터의 경우 trxid를 prli에서 받는다
                        // trxId = roLiList[0].ProductRequestLineItem.POINT_TRX_ID__c; //24 02 27 hyungho.chun 흑자채권arConfirm 포인트건 마이그 합쳐져서 나와서 lineitem에서 찾아서씀
                        System.debug('TRX_ID : ' + trxId);
                        if (!kTrxIdSet.contains(trxId)) {
                            System.debug('반품 품목이 아닌 TRX_ID : ' + trxId);
                            // Database.rollback(sp);
                            String tempMsg = 'SR_AR_CONFIRM__c POINT_TRX_ID__c 와 ProductRequestLineItem POINT_TRX_ID__c 불일치, 흑자 SR_AR_CONFIRM Id : '+arConfirm.Id; 
                            errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
                            errorMap.put('requestMsg', '[Fail] : 1 건'); // 23 12 18 hyungho.chun 환불 늘 1건씩
                            errorMap.put('isSuccess','N');
                            errorMap.put('className','EX_ReturnConfirmQueueable');
                            System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
                            EX_ConsumableUtil.saveSaleExc(errorMap);
                            // throw new FNException('SR_AR_CONFIRM__c POINT_TRX_ID__c 와 ProductRequestLineItem POINT_TRX_ID__c 가 같지 않습니다.');
                            return;
                        }
                        System.debug('환불 대상 TRX_ID');
                        /**
                         * 환불 로직 반품의 TRX와 arConfirm TRX 일치
                         * Id aOriginId, Map<String, Object> aBody, Boolean aCancel, SR_PRE_PAYMENT_DETAIL__c aContext
                         */

                        //23 09 25 hyungho.chun 이승현말고 sr_ar_confirm에서 이름/전화번호 조회해서 MBS_CUST_ID받아옴
                        //23 10 20 hyungho.chun MBS_CUST_ID는 이제 arConfirm에서 받는다
                        // FN_PaymentModel.T_RES_CheckPoint_Item getMembership = new FN_PaymentModel.T_RES_CheckPoint_Item();
                        // getMembership = FN_PaymentAgent.requestRetrievePoint(arConfirm.PAY_CUST_NAME__c, arConfirm.PAY_CUST_PHONE__c); //MBS_CUST_ID 가져오기
                        
                        FN_PaymentModel.T_REQ_SpendOrCancelPoint aParam = new FN_PaymentModel.T_REQ_SpendOrCancelPoint();
                        // 멤버십 Id 의미?
                        // aParam.MBS_CUST_ID = '1000294683'; //이승현
                        // aParam.MBS_CUST_ID = getMembership.MBS_CUST_ID;
                        aParam.MBS_CUST_ID = (arConfirm.MBS_CUST_ID__c != null && arConfirm.MBS_CUST_ID__c != '') ? arConfirm.MBS_CUST_ID__c : '';
                        
                        aParam.ORG_CD = '';
                        aParam.ACCUM_FLAG = 'USED_CNCL';
                        aParam.ACCUM_PNT = arConfirm.isMig__c ? String.valueOf(seqAndRoli.get(orderSeq).RETURN_POINT_Amount__c) : String.valueOf(arConfirm.DEPOSIT_AMT__c); //24 02 29h yungho.chun 마이그 데이터의경우 arConfirm이 합쳐져있어서 lineitem별로 금액을 찾아쓴다
                        aParam.BILL_TO_CD = smDept.DEPT_CODE__c; // PH8002
                        aParam.BILL_TO_NM = smDept.DEPT_NAME__c; // 소모품센터
                        aParam.ORIG_ACCUM_BRKDN_ID = trxId;
                        System.debug('포인트 취소를 위한 파라미터 : ' + aParam);
                        FN_PaymentModel.T_RES_SpendOrCancelPoint kResponse = FN_PaymentAgent.requestSpendOrCancelPoint(aParam);
                        refundAmt = arConfirm.DEPOSIT_AMT__c;
                        System.debug('포인트 취소 response : ' + kResponse);
                        if (kResponse.message.equalsIgnoreCase('Success')) {
                            System.debug('포인트 취소 성공');
                            isSuccess = true;
                        }
                        else {
                            // todo: 오류 정보 저장
                            // Database.rollback(sp);
                            String tempMsg = '포인트 취소 실패, 흑자 SR_AR_CONFIRM Id : '+arConfirm.Id; 
                            errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
                            errorMap.put('requestMsg', '[Fail] : 1 건'); // 23 12 18 hyungho.chun 환불 늘 1건씩
                            errorMap.put('isSuccess','N');
                            errorMap.put('className','EX_ReturnConfirmQueueable');
                            System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
                            EX_ConsumableUtil.saveSaleExc(errorMap);
                            System.debug('포인트 취소 실패');
                            // throw new FNException('포인트 취소 실패 : kResponse :: '+kResponse);
                        }
                    }
                    //23 12 19 hyungho.chun 미수없음 에러나면 아래서 로그남김
                    // when 'E' {
                    //     // 미수 상세 내역
                    //     // 미수 인데 상세내역이 없으면 Data Error
                    //     if (arConfirm.UPAD_DETAIL_TYPE__c != null) {
                    //         // todo: 오류정보 저장
                    //         // Database.rollback(sp);
                    //         String tempMsg = '미수건 상세내역없음, 흑자 SR_AR_CONFIRM Id : '+arConfirm.Id; 
                    //         errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
                    //         errorMap.put('requestMsg', '[Fail] : 1 건'); // 23 12 18 hyungho.chun 환불 늘 1건씩
                    //         errorMap.put('isSuccess','N');
                    //         errorMap.put('className','EX_ConsumableUtil.EX_ReturnConfirmQueueable');
                    //         System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
                    //         EX_ConsumableUtil.saveSaleExc(errorMap);
                    //         System.debug('Data Error');
                    //         // throw new FNException('Data Error');
                    //     }
                    // }
                }
                /**
             *  취소에 성공했다면
             *  포인트인 경우 포인트환불완료여부(POINT_REFUND_Complete_YN__c) 체크
             *  그 외의 경우 포인트외환불완료여부(ETC_REFUND_Complete_YN__c) 체크
             *  각 ReturnOrderLineItem은 반품 생성 때 결제 방식에 따라 하기 필드값 가지고 있음
             *  가상계좌인 경우에는 현금송금여부(CASH_REM_YN__c) 추가로 True
             */

            //23 12 12 hyungho.chun 가능한 모든 dml은 환불전으로 뺌
    //             if (isSuccess) {
    //                 // 포인트 건 (DEPOSIT_TYPE__c == D')
    //                 if (arConfirm.DEPOSIT_TYPE__c == 'D') {
    //                     System.debug('포인트건');
    //                     System.debug('trxId :'+trxId);
    //                     roLi = kTrxIdRoLiMap.get(trxId);
    //                     System.debug('before dml roLi : ' + roLi);
    //                     roLi.POINT_REFUND_Complete_YN__c = 'Y';
    //                     // todo: RED_POINT_TRX_ID__c 검토, response
    //                     // todo : 23 11 06 hyungho.chun RED_POINT_TRX_ID__c에는 적자로 생성된 trxId를 smartro_payment_cancel생성후 ptid에서 값을 받아와서 적자채권생성후에 넣어준다 ( 아래 updateRoliPtid 메소드 참조)
    //                     // roLi.RED_POINT_TRX_ID__c = trxId;
    //                     upsert roLi;
    //                     System.debug('after dml without reQuery roLi : ' + roLi);
    //                 }
    //                 // 카드 건 (DEPOSIT_TYPE__c == 'B'
    //                 // 가상계좌 건(결제URL포함) (DEPOSIT_TYPE__c == 'E' && UPAD_DETAIL_TYPE__c == 'PG_VBANK')
    //                 //23 08 01 hyungho.chun DEPOSIT_TYPE__c == E 미수건 사용안함 삭제처리
    //                 // else if ((arConfirm.DEPOSIT_TYPE__c == 'B') || (arConfirm.DEPOSIT_TYPE__c == 'E' && arConfirm.UPAD_DETAIL_TYPE__c == 'PG_VBANK')) {
    //                     //23 10 26 hyungho.chun UPAD_DETAIL_TYPE__c 마이그 대상 아님 -> DEPOSIT_TYPE__c 기준으로 수정
    //                 // else if ((arConfirm.DEPOSIT_TYPE__c == 'B') || (arConfirm.UPAD_DETAIL_TYPE__c == 'PG_VBANK')) {
    //                 else if ((arConfirm.DEPOSIT_TYPE__c == 'B') || (arConfirm.DEPOSIT_TYPE__c == 'A')) {
    //                     System.debug('결제 URL, 가상계좌건');
    //                     for (ReturnOrderLineItem roLineItem : roLiList) {
    //                         // roLineItem.REFUND_Complete_YN__c = true;
    //                         roLineItem.ETC_REFUND_Complete_YN__c = 'Y';
    //                         isUpsertRoLi = true;

    //                         // 카드: 취소승인번호, 가상계자: 환불승인여부 todo: 카드 취소 Response의 AuthCode 여부
    //                         roLineItem.RETURN_PAYMENT_NO__c = authCode;
    // //                    roLineItem.RETURN_PAYMENT_PTID__c = '';
    //                         //23 08 01 hyungho.chun DEPOSIT_TYPE__c == E 미수건 사용안함 삭제처리
    //                         // if (arConfirm.DEPOSIT_TYPE__c == 'E' && arConfirm.UPAD_DETAIL_TYPE__c == 'PG_VBANK') {
    //                         //23 10 26 hyungho.chun UPAD_DETAIL_TYPE__c 마이그 대상 아님 -> DEPOSIT_TYPE__c 기준으로 수정    
    //                         // if ( arConfirm.UPAD_DETAIL_TYPE__c == 'PG_VBANK') {
    //                         if ( arConfirm.DEPOSIT_TYPE__c == 'A') {
    //                             System.debug('CASH_REM_YN__c = Y 업데이트');
    //                             roLineItem.CASH_REM_YN__c = 'Y';
    //                         }
    //                     }
    //                 }
    //             }

    //             // roLiList = [SELECT Id, POINT_REFUND_Complete_YN__c, ETC_REFUND_Complete_YN__c FROM ReturnOrderLineItem WHERE Id IN :kRoLiIdSet];
    //             completeRoLiCount = 0;
    //             // todo: 쿼리 결과에 따른 List 확인 후 재쿼리 검토 (업데이트 값이 리얼타임 반영?)
    //             roLiList = [
    //                     SELECT Id,REFUND_Complete_YN__c, ETC_REFUND_Complete_YN__c, POINT_REFUND_Complete_YN__c , ProductRequestLineItem.TID__c, ProductRequestLineItem.fm_Consumables_PART_DESC_KOR__c, Order_Number__c, CreatedDate, Order_CHNL_TYPE_Code__c, ProductRequestLineItem.POINT_TRX_ID__c,  ProductRequestLineItem.MOID__c, ProductRequestLineItem.Order_Number__c  
    //                     FROM ReturnOrderLineItem
    //                     WHERE ReturnOrderId =: ro.Id FOR UPDATE
    //             ];
    //             for (ReturnOrderLineItem kRoLi : roLiList) {
    //                 System.debug('count kRoLi : ' + kRoLi);
    //                 if (kRoLi.POINT_REFUND_Complete_YN__c == 'Y'){
    //                     // kRoLi.REFUND_Complete_YN__c = true; 
    //                     completeRoLiCount++;
    //                 }
    //                 if (kRoLi.ETC_REFUND_Complete_YN__c == 'Y') {
    //                     // kRoLi.REFUND_Complete_YN__c = true;
    //                     completeRoLiCount++;
    //                 }
    //             }

    //             /**
    //              *  모든 반품 품목들의 환불처리에 성공했으므로 정보업데이트
    //              */
    //             System.debug('completeRoLiCount : ' + completeRoLiCount);
    //             if (completeRoLiCount == goalRoLiCount) {

    //                 System.debug('모든 반품 품목 환불 성공');
    //                 for (ReturnOrderLineItem kRoLi : roLiList) {
    //                     kRoLi.REFUND_Complete_YN__c = true;
    //                 }
    //                 isUpsertRoLi = true;
    //             }
    //             if (isUpsertRoLi) {
    //                 upsert roLiList;
    //             }
            }
        }catch(Exception e){
            String tempMsg = ' [Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage();
            System.debug('[Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage());
            // Database.rollback(sp);

            //23 10 30 hyungho.chun 마이그데이터예상 예상 오류 로그
            errorMap.put('orderNum',roLiList[0].Order_Number__c);
            // errorMap.put('orderChannel',roLiList[0].Order_CHNL_TYPE_Code__c);
            // errorMap.put('requestMsg', '[Fail] : 1 건'); // 23 12 18 hyungho.chun 환불 늘 1건씩
            errorMap.put('requestMsg', errorMap.containsKey('requestMsg') ? errorMap.get('requestMsg') + '[Fail] : 1 건' : '[Fail] : 1 건'); // 24 03 19 hyungho.chun 
            errorMap.put('isSuccess','N');
            errorMap.put('className','EX_ReturnConfirmQueueable');

            errorMap.put('errorType','ReturnConfirm');
            errorMap.put('recordId',roLiList[0].Id);
            errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);

            System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
            EX_ConsumableUtil.saveSaleExc(errorMap);
        }

        //교환주문건 금액은 여기에서 세팅 (적자채권 생성 위해)
        // else if (ro.Order_CHNL_TYPE_Code__c.equals('V') && ro.Consumables_Business_Type_Code__c == 'ExchangeReturn') {
        //     refundAmt = ro.RETURN_PAYMENT_Amount__c;
        // }

        // 소모품택배 적자채권 생성
        // 외부채널 교환주문건 적자채권은 EX_ConsumableUtil.exChannelRed(Set<String> roLiIdSet)
        // 각 케이스마다 INVOICE_NO를 확인해서 적자채권 정보 업데이트
        //23 10 31 hyungho.chun 환불성공건만 적자채권돌게끔 조치
        if(isSuccess){
            // Savepoint sp2 = Database.setSavepoint();
            // try {
                // 소모품택배
                if (ro.Order_CHNL_TYPE_Code__c.equals('V') && arConfirm.AR_INVOICE_NO__c != null && ro.Consumables_Business_Type_Code__c != 'ExchangeReturn') {
                    //23 12 12 hyungho.chun doReturnOrderConfirm2 에서 미리 해줌
                    // System.debug('적자채권 생성');
                    // System.debug('arConfirm :: '+arConfirm);
                    // System.debug('refundAmt :: '+refundAmt);
                    // recorder.append(arConfirm.Id, refundAmt).record();
                    
                    updateRoliPtid(arConfirm.DEPOSIT_TYPE__c,roLiList);
                }
                else {
                    System.debug('적자채권 생성 대상 아님 -> INVOICE_NO__c NULL');
                }
    
                // for (String exObjId : exObjIdList) {
                //     EX_ConsumablesOrderManagementController.doResend(exObjId, '주문 취소', '', String.valueOf(ro.CONSIGNEE_TPNO_1__c));
                // }
    
                //23 09 11 hyungho.chun roli SALE_DEFICIT_PAYMENT_Number__c에 적자 payment_basis id 넣어주기
                //23 12 12 hyungho.chun doReturnOrderConfirm2에서 미리 해줌
                // updateRoliSDPN(roLiList);
    
    
                //23 09 09 hyungho.chun 반품확정용 메세지 생성 후 새로운 queueable 호출
                //23 09 12 가상계좌 현금영수증 큐2개 호출문제로 분기처리
                //23 10 20 hyunho.chun 현금영수증중복발인 취소하던거 뺴서 분기처리 필요없음
                // if(!isCashReceipt){ 
                    List<EX_Message__c> msgList = new List<EX_Message__c>();
                    List<String> exObjIdList = new List<String>();
    
                    for (ReturnOrderLineItem roliItem : roliList) {
                        EX_Message__c msg = new EX_Message__c();
    
                        msg.Label1__c = ro.CONSIGNEE_Name__c;
                        msg.Label2__c = ro.Order_Number__c;
                        msg.Label3__c = roliItem.ProductRequestLineItem.fm_Consumables_PART_DESC_KOR__c;
                        msgList.add(msg);
                    }
    
                    insert msgList;
    
                    for (EX_Message__c msg : msgList) {
                        exObjIdList.add(msg.Id);
                    }
    
                    System.debug('exObjIdList :: ' + exObjIdList);
    
                    if(!Test.isRunningTest()) System.enqueueJob(new EX_ReturnConfirmQueueableMessage(ro, msgList));                     
    
                // }
           
    
    
            // } catch(Exception e) {
            //     String tempMsg = ' [Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage();
            //     System.debug('[Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage());
            //     Database.rollback(sp2);
    
            //     //23 10 30 hyungho.chun 마이그데이터예상 예상 오류 로그
            //     errorMap.put('orderNum',roLiList[0].Order_Number__c);
            //     // errorMap.put('orderChannel',roLiList[0].Order_CHNL_TYPE_Code__c);
            //     errorMap.put('requestMsg', '[Fail] : 1 건'); // 23 12 18 hyungho.chun 환불 늘 1건씩
            //     errorMap.put('isSuccess','N');
            //     errorMap.put('className','EX_ConsumableUtil.EX_ReturnConfirmQueueable');
            //     errorMap.put('errorType','ReturnConfirm');
            //     errorMap.put('recordId',roLiList[0].Id);
            //     errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
    
            //     System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
            //     EX_ConsumableUtil.saveSaleExc(errorMap);
            // }

            errorMap.put('requestMsg', '[Success] : 1 건'); // 23 12 18 hyungho.chun 환불 늘 1건씩
            errorMap.put('isSuccess','Y');
            errorMap.put('className','EX_ReturnConfirmQueueable');                            
            System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
            EX_ConsumableUtil.saveSaleExc(errorMap);
        }

    }

    public void finish(Database.BatchableContext param1) {
    }


    //23 08 16 hyungho.chun 반품확정 RETURN_PAYMENT_PTID__c 값 추가용 메소드
    public static void updateRoliPtid(String depositType, List<ReturnOrderLineItem> roLiList){
        Map<String, String> requestMap = new Map<String, String>();
        Map<String, String> requestMap2 = new Map<String, String>();
        List<String> roliMoidList = new List<String>();

        for (ReturnOrderLineItem roLiItem : roLiList) {
            //23 11 06 현재 AR confirm이 포인트가아닌경우엔 prli의 moid를  / 포인트의 경우엔 trxId를 넣어서 연관된 smartro_request를 찾는다
            if(depositType != 'D'){
                roliMoidList.add(roLiItem.ProductRequestLineItem.MOID__c);
            }else{
                roliMoidList.add(roLiItem.ProductRequestLineItem.POINT_TRX_ID__c);
            }
            
        }

        List<SR_SMARTRO_PAYMENT_REQUEST__c> srSmartoReqList = [SELECT Id, MOID__c FROM SR_SMARTRO_PAYMENT_REQUEST__c WHERE MOID__c IN :roliMoidList];
        for (SR_SMARTRO_PAYMENT_REQUEST__c tObj : srSmartoReqList) {
            requestMap.put(tObj.Id, tObj.MOID__c);
        }

        List<SR_SMARTRO_PAYMENT_CANCEL__c> srSmartoCacList = [SELECT Id, PTID__c,SR_SMARTRO_PAYMENT_REQUEST_ID__c FROM SR_SMARTRO_PAYMENT_CANCEL__c WHERE SR_SMARTRO_PAYMENT_REQUEST_ID__c IN :requestMap.keySet()];
        for (SR_SMARTRO_PAYMENT_CANCEL__c sspoObj : srSmartoCacList) {
            if(requestMap.containsKey(sspoObj.SR_SMARTRO_PAYMENT_REQUEST_ID__c)) {
                requestMap2.put(requestMap.get(sspoObj.SR_SMARTRO_PAYMENT_REQUEST_ID__c), sspoObj.PTID__c);
            }
        }

        for (ReturnOrderLineItem roLiItem : roLiList) {
            if(depositType != 'D'){
                if(requestMap2.containsKey(roLiItem.ProductRequestLineItem.MOID__c)){
                    roLiItem.RETURN_PAYMENT_PTID__c = requestMap2.get(roLiItem.ProductRequestLineItem.MOID__c);
                }
            }else{
                if(requestMap2.containsKey(roLiItem.ProductRequestLineItem.POINT_TRX_ID__c)){
                    roLiItem.RED_POINT_TRX_ID__c = requestMap2.get(roLiItem.ProductRequestLineItem.POINT_TRX_ID__c);
                }
            }

            
        }
        system.debug('tid_c 업데이트 !');
        update roLiList;        
    }


    //23 09 11 hyungho.chun 소모품 원 returnOrderLineItem의 SALE_DEFICIT_PAYMENT_Number__c에 적자 sr_payment_basis id값 넣어주기( 룩업필드로 변환시 들어가게)
    public static void updateRoliSDPN(List<ReturnOrderLineItem> roLiList){

        Set<String> roliOrderNumSet = new Set<String>();
        System.debug('roLiList :: '+roLiList);
        System.debug('roLiList.size() :: '+roLiList.size());
        for(ReturnOrderLineItem item : roLiList){
            //23 11 29 hyungho.chun 케어플러스 반품 주문번호 안맞아서 prli의 Order_number를 받음
            // roliOrderNumSet.add(item.Order_Number__c);
            roliOrderNumSet.add(item.ProductRequestLineItem.Order_Number__c);
            
        }

        List<SR_AR_CONFIRM__c> arConfirmList = [SELECT Id,SR_PAYMENT_BASIS_ID__c, CreatedDate FROM SR_AR_CONFIRM__c WHERE FM_Order_Number__c IN :roliOrderNumSet AND DEPOSIT_AMT__c <0 ORDER BY CreatedDate DESC];
        System.debug('arConfirmList :: '+arConfirmList);
        System.debug('arConfirmList.size() :: '+arConfirmList.size());

        //23 10 26 hyungho.chun deficit Type roli에도 SR_PAYMENT_BASIS__c 넣어달라는 재경요청
        //23 11 29 hyungho.chun order_number IN -> ProductRequestLineItem.Order_Number__c IN
        List<ReturnOrderLineItem> deficitRoLiList =[SELECT id,SR_PAYMENT_BASIS__c,CreatedDate,Order_Number__c,ProductRequestLineItem.Order_Number__c FROM ReturnOrderLineItem WHERE ProductRequestLineItem.Order_Number__c IN :roliOrderNumSet AND RecordType.DeveloperName ='SALE_DEFICIT' ORDER BY CreatedDate DESC];
        Map<String, ReturnOrderLineItem> deficitMap = new Map<String, ReturnOrderLineItem>();
        for(ReturnOrderLineItem item : deficitRoLiList){
            deficitMap.put(item.Order_Number__c, item);
        }
        List<ReturnOrderLineItem> updateRoLiList = new List<ReturnOrderLineItem>();

        for(Integer i =0; i<roLiList.size();i++){
            //23 09 11 hyungho.chun SALE_DEFICIT_PAYMENT_Number__c 가아직 string field고 최대길이가 10이라 일단10자만 자름
            // roLiList[i].SALE_DEFICIT_PAYMENT_Number__c = String.valueOf(arConfirmList[i].SR_PAYMENT_BASIS_ID__c).subString(0,10);
            roLiList[i].SALE_DEFICIT_PAYMENT_Number__c = String.valueOf(arConfirmList[0].SR_PAYMENT_BASIS_ID__c).subString(0,10);
            //23 10 22 hyungho.chun roli의 SR_PAYMENT_BASIS__c에 SR_PAYMENT_BASIS_ID__c 넣어달라는 재경측 요청
            // roLiList[i].SR_PAYMENT_BASIS__c = arConfirmList[i].SR_PAYMENT_BASIS_ID__c != null ? arConfirmList[i].SR_PAYMENT_BASIS_ID__c : null;
            roLiList[i].SR_PAYMENT_BASIS__c = arConfirmList[0].SR_PAYMENT_BASIS_ID__c != null ? arConfirmList[0].SR_PAYMENT_BASIS_ID__c : null;

            // updateRoLiList.add(roLiList[i]);
            if(!updateRoLiList.contains(roLiList[i])){
                updateRoLiList.add(roLiList[i]);
            }else{
                updateRoLiList.set( updateRoLiList.indexOf(roLiList[i]), roLiList[i]);
            }
            
            //23 10 26 hyungho.chun deficit Type roli에도 SR_PAYMENT_BASIS__c 넣어달라는 재경요청
            if(deficitMap.containsKey(roLiList[i].Order_Number__c)){
                // deficitMap.get(roLiList[i].Order_Number__c).SR_PAYMENT_BASIS__c = arConfirmList[i].SR_PAYMENT_BASIS_ID__c != null ? arConfirmList[i].SR_PAYMENT_BASIS_ID__c : null;
                deficitMap.get(roLiList[i].Order_Number__c).SR_PAYMENT_BASIS__c = arConfirmList[0].SR_PAYMENT_BASIS_ID__c != null ? arConfirmList[0].SR_PAYMENT_BASIS_ID__c : null;
                // updateRoLiList.add(deficitMap.get(roLiList[i].Order_Number__c));
                if(!updateRoLiList.contains(roLiList[i])){
                    updateRoLiList.add(roLiList[i]);
                }else{
                    updateRoLiList.set( updateRoLiList.indexOf(roLiList[i]), roLiList[i]);
                }
            }
            
        }
        update updateRoLiList;
        
    }

}