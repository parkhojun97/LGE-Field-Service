/**
 * Created by I2MAX.JAEYEONLEE on 2023-03-17.
 */

public without sharing class EX_PaymentUtil {
    Static String bankType = '가상계좌';
    
    @AuraEnabled
    public static void setBankPaymentType(Map<String,String> paramMap){
        System.debug('bType :' + paramMap.get('aType'));
        String prId = paramMap.get('prId');
        ProductRequest kRequest = (ProductRequest) SUtil.oneOrNull([SELECT PAYMENT_TYPE__c, Id ,CONSIGNEE_Name__c,Order_Number__c,SALE_Amount__c,CONSIGNEE_TPNO_1__c,CONSIGNEE_TPNO_2__c FROM ProductRequest WHERE Id =: prId LIMIT 1]);
        if(paramMap.get('aType') == 'PG_VBANK1'){ kRequest.PAYMENT_TYPE__c = 'CASH'; }
        else{ kRequest.PAYMENT_TYPE__c = 'VBANK'; }
        update kRequest;
    }

    @AuraEnabled
    public static String checkPhoneVal(String phoneNumber){
        System.debug('phoneNumber ??? '  + phoneNumber );
        
        try{
            CM_CommonUtil cmUtil = new CM_CommonUtil();
            String checkTelNoValidMessage = cmUtil.checkValidTelNo(phoneNumber);
            if(!String.isEmpty(checkTelNoValidMessage)) {
                // 전화번호가 유호 하지 않는 경우 처리 케이스.
                return checkTelNoValidMessage;
            }
        } catch (Exception e){
            System.debug(e.getLineNumber() + ' Line || ' + e.getMessage());
            throw new AuraHandledException(e.getLineNumber() + ' Line || ' + e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static IF_CM_SFDC_KAKAO.Result ExSendMessage(String aPhone, String aType, Id aOriginId, Id aDeptId, SR_PRE_PAYMENT_DETAIL__c aContext, String aProductName, Date aDate, Decimal aAmount) {
        String kCode = getMessageCode(aType, aOriginId, aContext);
        return sendKakao(aPhone, kCode, fetchSubstitutes(aType, aOriginId, aDeptId, aContext, aProductName, aDate, aAmount));
    }
    @AuraEnabled
    public static String getMessageCode(String aType,Id aOriginId, SR_PRE_PAYMENT_DETAIL__c aContext) {
        String kCode = null;
        ProductRequest kRequest = (ProductRequest) SUtil.oneOrNull([SELECT PAYMENT_TYPE__c, Id ,CONSIGNEE_Name__c,Order_Number__c,SALE_Amount__c,CONSIGNEE_TPNO_1__c,CONSIGNEE_TPNO_2__c FROM ProductRequest WHERE Id =: aOriginId LIMIT 1]);
        System.debug('bankType : ' + bankType);
        //service resource여부로 가상계좌,현금대리입금등 나눠서 사용하게
        if ('pgVBank' == aType) {
            // if(kRequest.PAYMENT_TYPE__c == 'VBANK') { kCode = 'SVC_LGE_MACN_012_01';
            if(kRequest.PAYMENT_TYPE__c == 'VBANK') { kCode = 'SVC_LGE_MACN_012_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
            }
            else{
                kCode = 'SVC_LGE_MACN_S012';
            }
        }
        else if ('pgVBank-CANCEL' == aType) { kCode = NULL;
//              kCode = '10258';
        }
        else if ('pgUrl' == aType) {
            // kCode = 'SVC_LGE_MACN_011'; // todo 템플릿 없음
            kCode = 'SVC_LGE_MACN_011_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
        }
        else if ('pgUrl-CANCEL' == aType) { kCode = NULL;

//              kCode = '10260';
        }
        kRequest.PAYMENT_TYPE__c = null;
        return kCode;
    }
    @AuraEnabled
    public static Map<String, String> fetchSubstitutes(String aType, Id aOriginId, Id aDeptId, SR_PRE_PAYMENT_DETAIL__c aContext, String aProductName, Date aDate, Decimal aAmount) {
        String kCode = getMessageCode(aType, aOriginId, aContext);
        Map<String, String> kParams = new Map<String, String>();
        ProductRequest kRequest = (ProductRequest) SUtil.oneOrNull([SELECT PAYMENT_TYPE__c, Id,CONSIGNEE_Name__c,Order_CUST_Name__c,Order_Number__c,SALE_Amount__c,CONSIGNEE_TPNO_1__c,CONSIGNEE_TPNO_2__c FROM ProductRequest WHERE Id =: aOriginId LIMIT 1]); //24 01 12 hyungho.chun CONSIGNEE_Name__c -> Order_CUST_Name__c 알림톡내용
        List<ProductRequestLineItem> kRequestLineItems =  [SELECT fm_ProductName__c, fm_Consumables_PART_DESC_KOR__c FROM ProductRequestLineItem WHERE Parent.Id =:kRequest.Id];
        String productName = '';
        if(kRequestLineItems !=null)
            productName = kRequestLineItems[0].fm_Consumables_PART_DESC_KOR__c;
        if(kRequestLineItems.size() >=2){ Integer listSize = kRequestLineItems.size()-1; productName += '외 '+  listSize +' 건';
        }
        if (null != kCode) {
            EX_Message__c msg = new EX_Message__c();
            msg.ProductRequest__c = kRequest.Id;
            if ('pgVBank' == aType) {
//         #{은행명} #{가상계좌번호} #{예금주}
                SR_SMARTRO_PAYMENT_REQUEST__c kSmartro = fetchRequestHistory(aContext.MOID__c);
                List<FNCommon.PickListDetail> kDetails = FNCommon.getGlobalPickListValues('smartro_virtual_bank');
                Map<String, String> kBankNameByCode = (Map<String, String>) SMapper.toMap(String.class, kDetails, 'value', 'label');

                if (null != kSmartro) {
                    if(kRequest.PAYMENT_TYPE__c == 'VBANK') {
                        // kParams.put('Label1__c', kRequest.CONSIGNEE_Name__c);
                        kParams.put('Label1__c', kRequest.Order_CUST_Name__c); //24 01 12 hyungho.chun
                        kParams.put('Label2__c', kRequest.Order_Number__c);
                        kParams.put('Label3__c', productName);
                        kParams.put('Label4__c', strToCurrencyWon(String.valueOf(aAmount)));
                        kParams.put('Label5__c', aContext?.VIRTUAL_ACCT_NUMBER__c);
                        kParams.put('Label6__c', kBankNameByCode.get(kSmartro?.BANK_CODE__c));
                        kParams.put('Label7__c', convertDate(System.today() + 1));

                        // msg.Label1__c =  kRequest.CONSIGNEE_Name__c;
                        msg.Label1__c =  kRequest.Order_CUST_Name__c; //24 01 12 hyungho.chun
                        msg.Label2__c =  kRequest.Order_Number__c;
                        msg.Label3__c =  productName;
                        msg.Label4__c =  strToCurrencyWon(String.valueOf((aAmount)));
                        msg.Label5__c =  aContext?.VIRTUAL_ACCT_NUMBER__c;
                        msg.Label6__c =  kBankNameByCode.get(kSmartro?.BANK_CODE__c);
                        msg.Label7__c =  convertDate(System.today() + 1);
                    }
                    else{
                        // kParams.put('Label1__c', kRequest.CONSIGNEE_Name__c);
                        kParams.put('Label1__c', kRequest.Order_CUST_Name__c); //24 01 12 hyungho.chun
                        kParams.put('Label2__c', strToCurrencyWon(String.valueOf(aAmount)));
                        kParams.put('Label3__c', aContext?.VIRTUAL_ACCT_NUMBER__c);
                        kParams.put('Label4__c', kBankNameByCode.get(kSmartro?.BANK_CODE__c));

                        // msg.Label1__c =  kRequest.CONSIGNEE_Name__c;
                        msg.Label1__c =  kRequest.Order_CUST_Name__c; //24 01 12 hyungho.chun
                        msg.Label2__c =  strToCurrencyWon(String.valueOf(aAmount));
                        msg.Label3__c =  aContext?.VIRTUAL_ACCT_NUMBER__c;
                        msg.Label4__c =  kBankNameByCode.get(kSmartro?.BANK_CODE__c);
                    }


                }
            } else if ('pgVBank-CANCEL' == aType) {
                system.debug('pgVBank-CANCEL');
            } else if ('pgUrl' == aType) {
                // kParams.put('Label1__c', kRequest.CONSIGNEE_Name__c);
                kParams.put('Label1__c', kRequest.Order_CUST_Name__c); //24 01 12 hyungho.chun
                kParams.put('Label2__c', kRequest.Order_Number__c);
                kParams.put('Label3__c', productName);
                kParams.put('Label4__c', strToCurrencyWon(String.valueOf((aAmount))));
                kParams.put('Label5__c', convertDate(System.today() + 1));
                kParams.put('Label6__c', aContext?.CARD_URL__c);
                // msg.Label1__c =  kRequest.CONSIGNEE_Name__c;
                msg.Label1__c =  kRequest.Order_CUST_Name__c; //24 01 12 hyungho.chun
                msg.Label2__c =  kRequest.Order_Number__c;
                msg.Label3__c =  productName;
                msg.Label4__c =  strToCurrencyWon(String.valueOf(aAmount));

                msg.Label5__c =  convertDate(System.today() + 1);
                msg.Label6__c =  String.valueOf(aContext?.CARD_URL__c);

            } else if ('pgUrl-CANCEL' == aType) { system.debug('pgUrl-CANCEL'); }

            kParams.put('제품명', aProductName);
            kParams.put('서비스유형', 'pgUrl' == aType ? '결제url' : '가상계좌');
            // kParams.put('고객명', kRequest.CONSIGNEE_Name__c);
            kParams.put('고객명', kRequest.Order_CUST_Name__c); //24 01 12 hyungho.chun
            kParams.put('접수번호', kRequest.Order_Number__c);
            kParams.put('서비스일자', ((Datetime)aDate)?.format('yyyy-MM-dd'));
            kParams.put('서비스금액', aAmount.format());




            Map<String, String> kMap = FNPayment2.createOrigin(aOriginId).getMessageParams();
            if (null != kMap) { kParams.putAll(kMap); }
        }

        //insert msg;
        return kParams;
    }
    @AuraEnabled
    public static String ExfetchMessage(String aType, Id aOriginId, Id aDeptId, SR_PRE_PAYMENT_DETAIL__c aContext, String aProductName, Date aDate, Decimal aAmount) {
        String kCode = getMessageCode(aType, aOriginId, aContext);
        if (null != kCode) {
            Map<String, String> kParams = fetchSubstitutes(aType, aOriginId, aDeptId, aContext, aProductName, aDate, aAmount);
            return FN_KakaoMessenger.getPopulatedKakaoMsg(kCode, kParams);
        } return '';
    }
    public static SR_SMARTRO_PAYMENT_REQUEST__c fetchRequestHistory(String aMoid) {
        if (String.isBlank(aMoid)) { throw new FNException('MOID 가 없습니다. 관리자에게 문의하세요.');
        }
        SR_SMARTRO_PAYMENT_REQUEST__c kSmartro = (SR_SMARTRO_PAYMENT_REQUEST__c) SUtil.oneOrNull([
                SELECT Id, PAYMENT_YN__c, MOID__c, TID__c, APPR_AMT__c, CUST_NAME__c, BANK_CODE__c
                FROM SR_SMARTRO_PAYMENT_REQUEST__c
                WHERE MOID__c = :aMoid
        ]);
        if (null == kSmartro) { throw new FNException('해당하는 요청 객체가 없습니다. 관리자에게 문의하세요.');
        }
        return kSmartro;
    }
    @AuraEnabled
    public static IF_CM_SFDC_KAKAO.Result sendKakao(String aPhoneNumber, String aCode, Map<String, String> aSubstitutes) {
        System.debug(aCode);
        System.debug(aSubstitutes);

        System.debug('aSubstitutes :: '+ JSON.serialize(aSubstitutes));

        return sendKakaoMessage(aCode, aPhoneNumber, aSubstitutes);
    }
    public static IF_CM_SFDC_KAKAO.Result sendKakaoMessage(String aTemplateCode, String aPhone, Map<String, String> aSubstituteMap ){

        if(String.isEmpty(aPhone)) return null;

        String kPhone = aPhone.replaceAll('[^0-9]+', '');

        String kContent = FN_KakaoMessenger.getPopulatedKakaoMsg(aTemplateCode, aSubstituteMap);
        if(String.isEmpty(kContent)){ throw new FNException('결제 취소');
        }
        kContent = kContent.replaceAll('\\r','');//== replace('\r','')
        IF_CM_SFDC_KAKAO.InputParam inputParam = new IF_CM_SFDC_KAKAO.InputParam();
        // if(aTemplateCode == 'SVC_LGE_MACN_011'){
        if(aTemplateCode == 'SVC_LGE_MACN_011_1'){ //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
            IF_CM_SFDC_KAKAO.Button kakaoButton = new IF_CM_SFDC_KAKAO.Button();
            List<IF_CM_SFDC_KAKAO.Button> listKakaoButton = new List<IF_CM_SFDC_KAKAO.Button>();

            kakaoButton.buttonText = '결제하기';
            kakaoButton.type = 'URL';
            kakaoButton.buttonUrlMobile = String.valueOf(aSubstituteMap.get('Label6__c'));
            kakaoButton.buttonUrlPc = String.valueOf(aSubstituteMap.get('Label6__c'));
            listKakaoButton.add(kakaoButton);

            inputParam.listKakaoButton = listKakaoButton;
        }


//        inputParam.kakaoTitle = 'LG 알림';
//        kPhone = '01042879397';//for test
        inputParam.setPhoneNumber = new Set<String>{kPhone};
        inputParam.templateCode = aTemplateCode;
//        inputParam.smsTitle = '카카오 발송 실패';
        inputParam.smsMsg = kContent;
        inputParam.kakaoMsg = kContent;
        System.debug('sendKakaoMessage === '+inputParam);
        Map<String, Object> mapResult = IF_CM_SFDC_KAKAO.doSendKakao(inputParam);
        System.debug('sendKakaoMessage result ==='+mapResult);

        IF_CM_SFDC_KAKAO.Result kResult = (IF_CM_SFDC_KAKAO.Result)mapResult.get('resultWrapper');
        if(kResult == null){ kResult = (IF_CM_SFDC_KAKAO.Result)mapResult.get('result');
        }

        saveKakaoResult(inputParam, kResult);

        if(!kResult.isSuccess && !Test.isRunningTest()){ throw new FNException('Kakao 알림을 보내지 못했습니다.');
        }
        return kResult;
    }

    private static void saveKakaoResult(IF_CM_SFDC_KAKAO.InputParam inputParam, IF_CM_SFDC_KAKAO.Result aResult ) {

        SR_SMS_SEND_INFO__c kInfo = new SR_SMS_SEND_INFO__c();
        kInfo.External_id__c = 'SMS_'+ inputParam.templateCode + Datetime.now().getTime() ;
        KInfo.InputDate__c = Datetime.now();
//        kInfo.messageId__c = aResult.messageId;
//        KInfo.InputUserId__c = UserInfo.getUserId();//?
        kInfo.Message__c = inputParam.kakaoMsg;
        for(String kPhone:inputParam.setPhoneNumber){
            if(String.isEmpty(kInfo.RcvTelNo__c)){
                kInfo.RcvTelNo__c = kPhone;
            }else{ kInfo.RcvTelNo__c += ',' + kPhone;
            }
        }
        kInfo.SendDt__c = Datetime.now().format('yyyyMMdd');
        kInfo.SendHm__c = Datetime.now().format('HHmm');
        kInfo.SendStat__c = (aResult.isSuccess) ? 'S':'F';
        if('F'.equalsIgnoreCase(kInfo.SendStat__c)){ kInfo.ErrorMsg__c = aResult.errorMsg;
        }
        kInfo.SendType__c = 'Kakao';
        kInfo.MsgNo__c = inputParam.templateCode.left(14);
//        if(aResult.responseWrapper?.message != null){
//            Map<String, Object> kMap = (Map<String, Object>)Json.deserializeUntyped(aResult.responseWrapper?.message);
//            if(kMap.containsKey('messages')){
//                List<Object> kMessages = (List<Object>)kMap.get('messages');
//                Map<String, Object> kMessage = (Map<String, Object>)kMessages[0];
//                kInfo.MsgNo__c = (String)kMessage.get('messageId');
//            }
//
//        }
        kInfo.TemplateCode__c = inputParam.templateCode;
        insert kInfo;
    }



    //트리거 pg사 결제시 실행
    @AuraEnabled
    public static void updateProductRequest(List<SI_SMARTRO_TOTAL_PAYMENT__c> listNew){
        try{
            Map<String,SI_SMARTRO_TOTAL_PAYMENT__c> oidSet = new Map<String,SI_SMARTRO_TOTAL_PAYMENT__c>();
            System.debug('oid : ' + listNew);

            DateTime deliveryDate = getDeliveryDate(); // 정상배송일
            List<String> OIDpaymentResult = new List<String>(); //24 01 09 hyungho.chun 중복체크용 키값
            List<String> OIDpaymentResultCard = new List<String>(); //24 03 09 hyungho.chun 중복체크용 키값
            for(SI_SMARTRO_TOTAL_PAYMENT__c paymentInfo : listNew){
                oidSet.put(paymentInfo.OID__c, paymentInfo);
                System.debug('oid : ' + paymentInfo.OID__c);

                if(paymentInfo.PAYMETHOD__c == 'VBANK' && paymentInfo.RESULT_CODE__c == '4100'){
                    OIDpaymentResult.add(paymentInfo.OID__c+'_'+paymentInfo.PAYMETHOD__c+'_'+paymentInfo.RESULT_CODE__c);
                }
                if(paymentInfo.PAYMETHOD__c == 'CARD' && paymentInfo.RESULT_CODE__c == '3001'){
                    OIDpaymentResultCard.add(paymentInfo.OID__c+'_'+paymentInfo.PAYMETHOD__c+'_'+paymentInfo.RESULT_CODE__c);
                }
            }
            List<SI_SMARTRO_TOTAL_PAYMENT__c> tempTotalPay = [SELECT Id FROM SI_SMARTRO_TOTAL_PAYMENT__c WHERE OID__c IN: oidSet.keySet() AND PAYMETHOD__c =: 'VBANK' AND RESULT_CODE__c =: '4100'];
            List<SI_SMARTRO_TOTAL_PAYMENT__c> tempTotalPayCard = [SELECT Id FROM SI_SMARTRO_TOTAL_PAYMENT__c WHERE OID__c IN: oidSet.keySet() AND PAYMETHOD__c =: 'CARD' AND RESULT_CODE__c =: '3001'];
            Boolean isDupTotalPay = tempTotalPay.size() > OIDpaymentResult.size() ? true : false; //24 01 09 hyungho.chun 결제URL->가상계좌 알림톡1번만 보내기위한 중복체크
            Boolean isDupTotalPayCard = tempTotalPayCard.size() > OIDpaymentResultCard.size() ? true : false; //24 03 09 hyungho.chun 현장카드 알림톡1번만 보내기위한 중복체크

            List<SI_SMARTRO_TOTAL_PAYMENT__c> oidList = listNew;
            System.debug('oids : ' + listNew[0].OID__c);

            String phone = '';
            Decimal totalAmount =0;
            Boolean isPay = false;
            Boolean isUpdateVBANK = false; //24 01 08 hyungho.chun
            Boolean isActualCard = false; //24 03 08 hyungho.chun 현장카드 사용여부
        
            Map<String, SR_PRE_PAYMENT_DETAIL__c> paymentMap = new Map<String, SR_PRE_PAYMENT_DETAIL__c>();
            List<SR_PRE_PAYMENT_DETAIL__c> detailslist =  [
                //23 10 22 hyungho.chun 가상계좌 고객명 필드 쿼리 추가 PAY_CUST_NAME__c
                    SELECT  TID__c,CARD_URL__c, UPAD_DETAIL_TYPE__c, MOID__c,DEPOSIT_TYPE__c, SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c, SR_PRE_PAYMENT_HEADER_ID__r.ATTR_RECORD_ID__c, SR_PRE_PAYMENT_HEADER_ID__r.BIZ_ORIGIN_TYPE__c, PAY_CUST_PHONE__c, PAY_CUST_NAME__c 
                    FROM SR_PRE_PAYMENT_DETAIL__c
                    WHERE (MOID__c = :listNew[0].OID__c) or (UPAD_DETAIL_TYPE__c !='PG_URL' AND TID__c =:listNew[0].TID__c )
                    //24 03 08 hyungho.chunwhere 절 뒤에 or 부분추가(현장카드는 oid값이 detail moid값과 다르다) 
            ];
            System.debug('detailslist :: '+detailslist);
            System.debug('detailslist.size() :: '+detailslist.size());
            for(SR_PRE_PAYMENT_DETAIL__c detail : detailslist){
                

                paymentMap.put(detail.TID__c,detail); //24 03 08 hyungho.chun 현장카드용 맵 추가
                paymentMap.put(detail.MOID__c,detail);
                
            }
            List<SR_PRE_PAYMENT_DETAIL__c> paymentList = paymentMap.values();
            Set<String> orderNumberSet = new Set<String>();
            phone = paymentList[0].PAY_CUST_PHONE__c;
            for (SR_PRE_PAYMENT_DETAIL__c paymentDetail : paymentList) {
                orderNumberSet.add(paymentDetail.SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c);
            }

            List<SM_DIV__c> smList = [SELECT Id, DIV_CODE__c FROM SM_DIV__c];
            Map<Id,String> smMap = new Map<Id,String>();
            for(SM_DIV__c item : smList){ smMap.put(item.Id, item.DIV_CODE__c);
            }
            //23 08 24 hyungho.chun PAYMENT_TYPE__c 필드조회추가 (현금입금은 현금입금으로 나눠야해서)
            Map<String, ProductRequest> prMap = new Map<String, ProductRequest>(
            [
                    SELECT Order_Number__c, Id, APPR_NUM__c, APPR_DT__c, ACQUIRE_NAME__c,PAYMENT_Amount__c, ACQUIRE_INFO__c, CASH_PAYMENT_Amount__c, CARD_PAYMENT_Amount__c,
                            MOID__c, VBANK_NUM__c, TID__c, RSRV_Number__c, PAYMENT_Method_Code__c,RESRV_Number__c,PAYMENT_YN__c, PAYMENT_COMPLETED_DTM__c,
                            CASH_DEPOSIT_YN__c,PAYMENT_TYPE__c,Order_CUST_Name__c, Order_CUST_TPNO_1__c 
                    FROM ProductRequest

                    WHERE Order_Number__c IN :orderNumberSet AND Consumables_Order_YN__c = true AND RecordType.DeveloperName = 'Consumable'
            ]);

            // //23.10.20 PHJ
            // Set<String> detailsListPhones = new Set<String>();
            // for(SR_PRE_PAYMENT_DETAIL__c srppd : detailsList){
            //     detailsListPhones.add(srppd.PAY_CUST_PHONE__c);
            // }
            // Contact c = [SELECT Name FROM Contact WHERE MobilePhone =: detailsListPhones];

//            Set<String> resrv_Number = new Set<String>();
//            if (prMap == null)
//                return;

//            for (ProductRequest pr : prMap.values()) {
//                if(pr.RESRV_Number__c != null)
//                    resrv_Number.add(pr.RESRV_Number__c.substring(1));
//            }
//            List<SR_RESRV_PART__c> resrvPartList = NEW List<SR_RESRV_PART__c>();
//            if(resrv_Number != null)
//                 resrvPartList = [SELECT Status__c FROM SR_RESRV_PART__c WHERE RSRV_Number__c = :resrv_Number];

            Map<String, ProductRequestLineItem> prlMap = new Map<String, ProductRequestLineItem>(
                    //23.11.24 gw.lee
                    //예약 상태일 경우 '상품준비중' => '결제완료' 요청으로 변경 로직 추가
                    [SELECT Consumables_Order_Class_Code__c,RSRV_Number__c, SHIPPED_Department_Code__c, POINT_Amount__c, Parent.SR_RSRV_PART_Id__c, Parent.SR_RSRV_PART_Id__r.Status__c, Order_Number__c, Id, CASH_PAYMENT_Amount__c, CARD_PAYMENT_Amount__c, PAYMENT_Amount__c, MOID__c, TID__c, Approval_Number__c, Approval_Date__c, Appointment_Status__c,Consumables_Order_Status__c FROM ProductRequestLineItem WHERE Order_Number__c IN :orderNumberSet AND Consumables_Order_YN__c = true AND RecordType.DeveloperName = 'Consumable']
            );
            Map<String,ProductRequest> prOrderMap = new Map<String,ProductRequest>();
            Map<Id,ProductRequestLineItem> prlIdMap = new Map<Id,ProductRequestLineItem>();
            Map<Id,SR_PRE_PAYMENT_DETAIL__c> detailMap = new Map<Id,SR_PRE_PAYMENT_DETAIL__c>();

            List<ProductRequest> prList = new List<ProductRequest>();
            List<ProductRequestLineItem> prlList = new List<ProductRequestLineItem>();
            List<SR_PRE_PAYMENT_DETAIL__c> detailList = new List<SR_PRE_PAYMENT_DETAIL__c>();
            List<EX_Message__c> msgList = new List<EX_Message__c>();
            Map<String, Object> emIdMap = new Map<String, Object>(); //24 01 09 hyungho.chun
            //  가상계좌 RESULT_CODE__c - 4110: 승인(입금), 4100: 발급, 2001: 발급취소  ???:환불
            //  카드 & 카드 URL - 3001: 승인, 2001: 취소
            List<String> cancelList = new List<String>{'003', '004', '005','010'}; //24 03 09 hyungho.chun 혹시 배송준비중인경우 대비 방어로 '010' 추가
            for (ProductRequestLineItem prlData : prlMap.values()) {
                for (SI_SMARTRO_TOTAL_PAYMENT__c aTotalPay : oidSet.values()) {

                    isActualCard = !paymentMap.containsKey(aTotalPay.OID__c); //24 03 08 hyungho.chun

                    if ('CARD'.equalsIgnoreCase(aTotalPay.PAYMETHOD__c)) {
                        if ('3001' == aTotalPay.RESULT_CODE__c) { // 승인
                            //카드url일때 카드 가격 line에 추가
                            //prlData.PAYMENT_Amount__c += aTotalPay.AMT__c;
                            //23.11.24 gw.lee
                            //예약 상태일 경우 '상품준비중' => '결제완료' 요청으로 변경 로직 추가
                            prlData.CARD_PAYMENT_Amount__c = Math.abs(prlData.PAYMENT_Amount__c - prlData.POINT_Amount__c);
                            if(!isActualCard){
                                prlData.MOID__c = aTotalPay.OID__c;
                            }
                            
                            prlData.TID__c = aTotalPay.TID__c;
                            prlData.Approval_Number__c = aTotalPay.AUTH_CODE__c;
                            prlData.Approval_Date__c = SUtil.toDate(SUtil.toDatetimeStr('20' + aTotalPay.AUTH_DATE__c));
                            prlData.fm_deliveryTerm__c = deliveryDate;

                            if (prlData.Appointment_Status__c == '요청') {
                                prlData.Consumables_Order_Status__c = '002';
                            } else if (prlData.RSRV_Number__c == null && prlData.SHIPPED_Department_Code__c == 'PH8002' && !cancelList.contains(prlData.Consumables_Order_Status__c)) {
                                prlData.Consumables_Order_Status__c = '006';
                            } else if(prlData.RSRV_Number__c != null || prlData.Consumables_Order_Class_Code__c == 'Sold Out' && !cancelList.contains(prlData.Consumables_Order_Status__c)) {
                                prlData.Consumables_Order_Status__c = '006';
                            } else {
                                prlData.Consumables_Order_Status__c = '002';
                            }
                            prlIdMap.put(prlData.Id,prlData);
                        }
                        else if ('2001' == aTotalPay.RESULT_CODE__c) {
                            prlData.Consumables_Order_Status__c = '004';
                            /**
                             * fixme: 재연님 이것은 위험해요.
                             * 석호님 보기전에 얼른 수정해야해요.
                             * 취소했는데 수불처리도 없다? 상태값만 바뀌고 죽어버려요.
                             */
//                            prlList.add(prlData);
                            prlIdMap.put(prlData.Id,prlData);

                        }
                    } else if ('VBANK'.equalsIgnoreCase(aTotalPay.PAYMETHOD__c)) {
                        if ('4110' == aTotalPay.RESULT_CODE__c) { // 승인(입금)
                            //카드url일때 카드 가격 line에 추가
                            prlData.VIRTUAL_ACCT_PAYMENT_Amount__c = Math.abs(prlData.PAYMENT_Amount__c - prlData.POINT_Amount__c) ;
//                            prlData.PAYMENT_Amount__c += aTotalPay.AMT__c;
                            prlData.CASH_PAYMENT_Amount__c = Math.abs(prlData.PAYMENT_Amount__c - prlData.POINT_Amount__c) ;
                            prlData.MOID__c = aTotalPay.OID__c;
                            prlData.TID__c = aTotalPay.TID__c;
                            prlData.Approval_Number__c = aTotalPay.AUTH_CODE__c;
                            prlData.Approval_Date__c = SUtil.toDate(SUtil.toDatetimeStr('20' + aTotalPay.AUTH_DATE__c));
                            prlData.fm_deliveryTerm__c = deliveryDate;
                            
                            if (prlData.Appointment_Status__c == '요청') {
                                prlData.Consumables_Order_Status__c = '002';
                            } else if (prlData.RSRV_Number__c == null && prlData.SHIPPED_Department_Code__c == 'PH8002' && !cancelList.contains(prlData.Consumables_Order_Status__c)) {
                                prlData.Consumables_Order_Status__c = '006';
                            }  else if(prlData.RSRV_Number__c != null || prlData.Consumables_Order_Class_Code__c == 'Sold Out' && !cancelList.contains(prlData.Consumables_Order_Status__c)) {
                                prlData.Consumables_Order_Status__c = '006';
                            }  else {
                                prlData.Consumables_Order_Status__c = '002';
                            }
//                            prlList.add(prlData);
                            prlIdMap.put(prlData.Id,prlData);

                        }
                        else if ('2001' == aTotalPay.RESULT_CODE__c) {
                            prlData.Consumables_Order_Status__c = '004';
//                            prlList.add(prlData);
                            prlIdMap.put(prlData.Id,prlData);

                        }

                    }

                }
            }
            for (ProductRequest prData : prMap.values()) {
                EX_Message__c message = new EX_Message__c();
                Boolean isPayment = false;

                for (SI_SMARTRO_TOTAL_PAYMENT__c aTotalPay : oidSet.values()) {

                    if ('CARD'.equalsIgnoreCase(aTotalPay.PAYMETHOD__c)) {
                        if ('3001' == aTotalPay.RESULT_CODE__c) { // 승인
                            if(prData.APPR_NUM__c != null){
                                break;
                            }
                            //카드url일때 카드 가격 line에 추가
                            if(prData.PAYMENT_YN__c == false){ isPayment = true;
                            }else{ isPayment = false;
                            }
                            prData.APPR_NUM__c = aTotalPay.AUTH_CODE__c;
                            prData.APPR_DT__c = SUtil.toDate(SUtil.toDatetimeStr('20' + aTotalPay.AUTH_DATE__c));
                            prData.ACQUIRE_NAME__c = aTotalPay.FN_NAME__c;
                            prData.ACQUIRE_INFO__c = aTotalPay.FN_CD__c;
                            prData.CARD_PAYMENT_Amount__c = aTotalPay.AMT__c;
//                            prData.PAYMENT_Amount__c += aTotalPay.AMT__c;
                            if(!isActualCard){ //24 03 09 hyungho.chun 기존 현장카드때는 안타던부분이라 괜히 데이터 꼬일수있으니 이미 잘 들어가는 값들은 현장카드건의경우 업데이트 안함
                                prData.MOID__c = aTotalPay.OID__c;
                            }
                            prData.VBANK_NUM__c = aTotalPay.VBANK_NUM__c;
                            prData.TID__c = aTotalPay.TID__c;
                            prData.PAYMENT_Method_Code__c = 'CARD';
                            // prData.PAYMENT_TYPE__c = 'URL';
                            prData.PAYMENT_TYPE__c = isActualCard ? 'CARD' : 'URL'; //24 03 08 hyungho.chun 현장카드일때도 고려해야함
                            prData.PAYMENT_YN__c = true;
                            prData.PAYMENT_COMPLETED_DTM__c = system.now();

                            //카드url일때 카드 가격 line에 추가
//                            prList.add(prData);
                            prOrderMap.put(prData.Order_Number__c , prData);

                            totalAmount += aTotalPay.AMT__c;

                            // SR_PRE_PAYMENT_DETAIL__c detail = paymentMap.get(aTotalPay.OID__c);
                            SR_PRE_PAYMENT_DETAIL__c detail = isActualCard ? paymentMap.get(aTotalPay.TID__c) : paymentMap.get(aTotalPay.OID__c); //24 03 08 hyungho.chun 현장카드일떈 다르게 맵핑해야함
                            System.debug('ddddddddd: ' + aTotalPay.OID__c);

                            System.debug('ddddddddd: ' + detail);
                            isPay = true;
                            detail.INVOICE_ISSUE_TYPE__c  = 'D';
                            detail.DEPOSIT_TYPE__c = 'B';
                            detail.CARD_URL__c = '';
                            detail.UPAD_DETAIL_TYPE__c = '';
                            detailMap.put(detail.Id,detail);

                            message.Label1__c = strToCurrencyWon(String.valueOf(aTotalPay.AMT__c));
                            //23 10 22 hyungho.chun 고객명 detail에서 받음 PAY_CUST_NAME__c
                            message.Label2__c = isActualCard ? prData.Order_CUST_Name__c : detail.PAY_CUST_NAME__c; //24 03 08 hyungho.chun 현장카드일떄랑 아닐떄랑 받는 이름 출저 다름  (paymentMap.containsKey(aTotalPay.OID__c) -> url / 아닐시 현장카드)
                            
                            // //23.10.19 PHJ
                            // message.Label2__c = c.Name != null ? c.Name : '';
                        }
                        //                else if ('2001' == aTotalPay.RESULT_CODE__c) {
                        //
                        //                }

                    } else if ('VBANK'.equalsIgnoreCase(aTotalPay.PAYMETHOD__c)) {
                        if ('4110' == aTotalPay.RESULT_CODE__c) { // 승인(입금)
                            if(prData.APPR_NUM__c != null){
                                break;
                            }
                            prData.APPR_NUM__c = aTotalPay.AUTH_CODE__c;
                            prData.APPR_DT__c = SUtil.toDate(SUtil.toDatetimeStr('20' + aTotalPay.AUTH_DATE__c));
                            prData.ACQUIRE_NAME__c = aTotalPay.FN_NAME__c;
                            prData.ACQUIRE_INFO__c = aTotalPay.FN_CD__c;
                            prData.CASH_PAYMENT_Amount__c = aTotalPay.AMT__c;
//                            prData.PAYMENT_Amount__c += aTotalPay.AMT__c;
                            prData.MOID__c = aTotalPay.OID__c;
                            prData.VBANK_NUM__c = aTotalPay.VBANK_NUM__c;
                            prData.TID__c = aTotalPay.TID__c;
                            prData.PAYMENT_Method_Code__c = 'VBANK';
                            //23 08 24 hyungho.chun 현금입금은 '가상계좌'로 변경안하고 '현금입금'으로 유지
                            // if(prData.PAYMENT_TYPE__c != 'CASH'){
                            //     prData.PAYMENT_TYPE__c = 'URL';    
                            // }
                            // prData.PAYMENT_TYPE__c = 'URL';
                            prData.PAYMENT_YN__c = true;
                            prData.PAYMENT_COMPLETED_DTM__c = system.now();
                            prData.CASH_DEPOSIT_YN__c = 'A';
                            System.debug('들어온 pr : ' + prData);
                            isPay = true;
//                            prList.add(prData);
                            prOrderMap.put(prData.Order_Number__c , prData);

                            totalAmount += aTotalPay.AMT__c;
                            isPayment = true;
                            message.Label1__c = strToCurrencyWon(String.valueOf(aTotalPay.AMT__c));
                            
                            SR_PRE_PAYMENT_DETAIL__c detail = paymentMap.get(aTotalPay.OID__c);
                            System.debug('ddddddddd: ' + aTotalPay.OID__c);

                            System.debug('ddddddddd: ' + detail);                            
                            //23 10 22 hyungho.chun 고객명 detail에서 받음 PAY_CUST_NAME__c
                            message.Label2__c = detail.PAY_CUST_NAME__c;                            
                            // //23.10.19 PHJ
                            // message.Label2__c = c.Name != null ? c.Name : '';


                            //카드url일때 카드 가격 line에 추가

                        }else if('4100' == aTotalPay.RESULT_CODE__c){//24 01 08 hyungho.chun 가상계좌발급 성공시 은행코드, 은행명 및 가상계좌번호 업데이트 로직 추가
                            isUpdateVBANK = true;

                            prData.MOID__c = aTotalPay.OID__c;//24 02 13 hyungho.chun 돈안내도 일단 연결됐으니 moid값 기입(자동주문취소때 필요)

                            prData.ACQUIRE_INFO__c = aTotalPay.BANK_CODE__c;
                            prData.ACQUIRE_NAME__c = aTotalPay.BANK_NAME__c;
                            prData.VBANK_NUM__c = aTotalPay.VBANK_NUM__c;
                            prOrderMap.put(prData.Order_Number__c , prData);


                            //24 01 09 hyungho.chun 결제url -> 가상계좌용 알림톡 데이터 생성
                            SR_PRE_PAYMENT_DETAIL__c detail = paymentMap.get(aTotalPay.OID__c);
                            if(detail.UPAD_DETAIL_TYPE__c == 'PG_URL' && !isDupTotalPay){
                                Map<String, Object> paramMap = new Map<String,Object>();
                                
                                Map<Object, Object> paramMapTemp = new Map<Object,Object>();
                                paramMapTemp.put('payment',detail.UPAD_DETAIL_TYPE__c);
                                paramMapTemp.put('receiverName',detail.PAY_CUST_NAME__c);
                                paramMapTemp.put('virtualBankAccountNo',aTotalPay.VBANK_NUM__c);
                                paramMapTemp.put('bank',aTotalPay.BANK_NAME__c);
                                paramMapTemp.put('amount',aTotalPay.AMT__c);

                                paramMap.put('param',paramMapTemp);
                                paramMap.put('prId',prData.Id);
                                paramMap.put('Pass','N');
                                String temp = createExMessage(paramMap); //24 01 09 hyungho.chun insert가있긴하지만 이 트리거 자체가 대량으로 들어오지않는다 전부 단건
                                Map<String,String> tempMap = new Map<String,String>();
                                tempMap.put('emType','가상계좌');
                                tempMap.put('receiverNumber',detail.PAY_CUST_PHONE__c);
                                tempMap.put('prId',prData.Id);

                                emIdMap.put(temp,tempMap);
                            }
                            
                            
                        }
                        SR_PRE_PAYMENT_DETAIL__c detail = paymentMap.get(aTotalPay.OID__c);

                        //23 11 28 hyungho.chun 가상계좌 INVOICE_ISSUE_TYPE__c 현금영수증('B') 넣어줘서 채권생성시 account연결 (재경요청)
                        detail.INVOICE_ISSUE_TYPE__c  = 'B';

                        detail.DEPOSIT_TYPE__c = 'A';
                        detailMap.put(detail.Id,detail);
                    }

                }
                if((isPayment && !isActualCard) || (isActualCard && !isDupTotalPayCard) ){//24 03 09 hyungho.chun 현금카드건 알림톡 로직 추가반영
                    try {
                        String jsonStr = JSON.serialize(message);
                        System.debug('json : ' +jsonStr);
                        String phoneNum = isActualCard ? prData.Order_CUST_TPNO_1__c : detailslist[0].PAY_CUST_PHONE__c;
                        //23.10.18 PHJ
                        // if(isPayment){ sendPaymentKakao('SVC_LGE_MACN_013_1', jsonStr, detailslist[0].PAY_CUST_PHONE__c); }
                        // if(isPayment){
                        if((isPayment && !isActualCard) || (isActualCard && !isDupTotalPayCard) ){//24 03 09 hyungho.chun 현금카드건 알림톡 로직 추가반영
                             sendPaymentKakao('SVC_LGE_MACN_013_1', jsonStr, phoneNum); 
                        }
                        msgList.add(message);
                    }
                    catch(Exception e){ System.debug(e); }
                }
                System.debug('업데이트 데이터 pr : ' + prOrderMap.values());
                System.debug('업데이트 데이터 prl : ' + prlIdMap.values());
//                if(totalAmount != 0 ){
//                    EX_Message__c message = new EX_Message__c();
//                    message.Label1__c = String.valueOf(totalAmount);
//                    sendKaKaoMessage('SVC_LGE_MACN_013', message, phone);
//                    System.debug('알림톡 발송');
//                    insert message;
//                }

            }
            if (isPay) { // 승인(입금)
                update detailMap.values();
                update prlIdMap.values();
                update prOrderMap.values();
            }
            if(isUpdateVBANK){ //24 01 08 hyungho.chun 
                update prOrderMap.values();
                if(emIdMap.size()>0){
                    for(String key : emIdMap.keySet()){ //24 01 09 hyungho.chun
                        Map<String, String> params = (Map<String, String>) emIdMap.get(key);
                        // sendExMessage(key,params.get('emType'),params.get('receiverNumber'),params.get('prId')); //트리거에서 callout금지
                        
                        String notiType = '알림톡';
                        // String templateCode = 'SVC_LGE_MACN_012_01';
                        String templateCode = 'SVC_LGE_MACN_012_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정

                        Map<String, Object> relatedData = EX_MessageUtil.getRelatedData(templateCode, key);
                        TemplateMgmt__c template = (TemplateMgmt__c) relatedData.get('template');
                        List<TemplateParams__c> templateParamList = (List<TemplateParams__c>) relatedData.get('templateParamList');
                        EX_Message__c messageObject = (EX_Message__c) relatedData.get('messageObject');
            
                        Map<String, Object> populateMap = messageObject.getPopulatedFieldsAsMap();

                        IF_CM_SFDC_KAKAO.InputParam inputParam = EX_MessageUtil.getInputParamForKaKao(template, templateParamList, populateMap);
                        inputParam.smsTitle = '소모품 주문 안내';
                        inputParam.smsMsg = inputParam.kakaoMsg;

                        System.debug('Input params :::::' + inputParam);
                        
                        //24 02 26 hyungho.chun 전화번호 set 형태로 변경
                        Set<String> phoneSet = new Set<String>();
                        phoneSet.add(params.get('receiverNumber'));
                        System.enqueueJob(new EX_OrderReceiving_qa(JSON.serialize(inputParam), phoneSet));                        

                        // System.enqueueJob(new EX_OrderReceiving_qa(JSON.serialize(inputParam), params.get('receiverNumber')));                        
                    }
                }

            }
            System.debug('소모품 결제 Trigger');
        }catch (Exception e){ System.debug(e);
        }


    }
    //        kContent = kContent.replaceAll('\\r','');//== replace('\r','')
    public static Map<String, Object> getRelatedData(String templateCode, EX_Message__c message) {
        Map<String, Object> returnMap = new Map<String, Object>();
        try {
            TemplateMgmt__c template = [SELECT Id, Content_c__c, Title__c, TemplateCode__c
            FROM TemplateMgmt__c
            WHERE TemplateCode__c=:templateCode][0];
            List<TemplateParams__c> templateParamList = [SELECT Id, Name, FieldApi__c
            FROM TemplateParams__c
            WHERE TemplateMgmt__c=:template.Id];


            returnMap.put('isSuccess', true);
            returnMap.put('template', template);
            returnMap.put('templateParamList', templateParamList);
            returnMap.put('messageObject', message);
        } catch(Exception e) { System.debug(e.getLineNumber() + ' || ' + e.getMessage());
        }

        return returnMap;
    }
    /**
     * @description 카카오 알림톡 발신 전 데이터 세팅
     * @param TemplateMgmt__c template : 알림톡 템플릿
     * @param List<TemplateParams__c> templateParamList : Template에 있는 변수 리스트
     * @param Map<String, Object> populateMap : 소모품 메시지 오브젝트 값을 가진 변수
     * @return IF_CM_SFDC_KAKAO.InputParam
     * @author 23.03.29 / I2MAX.SEUNGHUNAN
     */
    public static IF_CM_SFDC_KAKAO.InputParam getInputParamForKaKao(TemplateMgmt__c template, List<TemplateParams__c> templateParamList, Map<String, Object> populateMap) {
        IF_CM_SFDC_KAKAO.InputParam inputParam = null;
        try {
            for (TemplateParams__c param : templateParamList) {
                if (populateMap.containsKey(param.FieldApi__c)) {
                    template.Content_c__c = template.Content_c__c.replace('#{' + param.FieldApi__c + '}'
                            , (String)populateMap.get(param.FieldApi__c));
                }
            }
            inputParam = new IF_CM_SFDC_KAKAO.InputParam();

            inputParam.templateCode = template.TemplateCode__c;
//            inputParam.kakaoTitle = template.Title__c;
            inputParam.kakaoMsg = template.Content_c__c.replaceAll('\\r', '');
            // inputParam.setPhoneNumber = new Set<String>{phoneNumber};
        } catch(Exception e) { System.debug(e.getLineNumber() + ' || ' + e.getMessage());
        }
        return inputParam;
    }
    /**
     * @description 카카오 알림톡 발신
     * @param String templateCode : 알림톡 템플릿 코드
     * @param String objectId : 소모품 메시지 Object Id
     * @param String phoneNumber : 알림톡을 수신할 번호
     * @return IF_CM_SFDC_KAKAO.Result
     * @author 23.03.29 / I2MAX.SEUNGHUNAN
     */
    public static IF_CM_SFDC_KAKAO.Result sendKaKaoMessage(String templateCode, EX_Message__c message, String phoneNumber) {
        Map<String, Object> relatedData = getRelatedData(templateCode, message);
        TemplateMgmt__c template = (TemplateMgmt__c) relatedData.get('template');
        List<TemplateParams__c> templateParamList = (List<TemplateParams__c>) relatedData.get('templateParamList');
        EX_Message__c messageObject = (EX_Message__c) relatedData.get('messageObject');

        Map<String, Object> populateMap = messageObject.getPopulatedFieldsAsMap();

        IF_CM_SFDC_KAKAO.InputParam inputParam = getInputParamForKaKao(template, templateParamList, populateMap);
        if (phoneNumber == null || phoneNumber.equals('')) return null;
        inputParam.smsTitle = '테스트 입니다.';
        inputParam.smsMsg = '카카오 발송 실패!';
        inputParam.setPhoneNumber = new Set<String>{phoneNumber};

        System.debug('inputParam : ' + inputParam);

        Map<String, Object> mapResult = IF_CM_SFDC_KAKAO.doSendKakao(inputParam);

        IF_CM_SFDC_KAKAO.Result kakaoResult = (IF_CM_SFDC_KAKAO.Result) mapResult.get('resultWrapper');
        if (kakaoResult == null) { kakaoResult = (IF_CM_SFDC_KAKAO.Result)mapResult.get('result');
        }

        if (!kakaoResult.isSuccess && !Test.isRunningTest()) { throw new FNException('KaKao 발신 실패');
        }

        return kakaoResult;
    }
    public static FN_PaymentModel.T_RES_SpendOrCancelPoint[] requestSpendPoint(String aMbsId, Decimal aAmount, String aDeptCode, String aDeptName, String originId) {
        System.debug('속도측정 -------------------------------------------------- EX_PaymentUtil.requestSpendPoint (start):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        ProductRequestLineItem[] kItems = [
                SELECT Id,SALE_Amount__c,PAYMENT_Amount__c,POINT_Amount__c,Consumables_Order_Status__c,RSRV_Number__c
                FROM ProductRequestLineItem
                WHERE Parent.Id = :originId
                ORDER BY PAYMENT_Amount__c ASC
        ];
        ProductRequest pItem = [
                SELECT Id,POINT_Amount__c
                FROM ProductRequest
                WHERE Id = :originId
                 LIMIT 1
        ];
        System.debug('aMbsId :::: ' + aMbsId);
        System.debug('aAmount :::: ' + aAmount);
        System.debug('originId :::: ' + originId);
        System.debug('kItems :::: ' + kItems);
        System.debug('속도측정 -------------------------------------------------- EX_PaymentUtil.requestSpendPoint (query):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        Decimal kTotalAmount = 0;
        for(ProductRequestLineItem item : kItems){
            kTotalAmount += item.PAYMENT_Amount__c;
        }
        List<Decimal> amountList = new List<Decimal>();
        Decimal maxAmount = -1;
        Decimal sumAmount = 0;
        Decimal pointSum = 0;
        Integer idx = 0;

        //포인트 1종 결제인 경우
        if (aAmount == kTotalAmount) {
            for (Integer i = 0; i < kItems.size(); i++) {
                System.debug('kItems.get(i).PAYMENT_Amount__c :::: ' + kItems.get(i).PAYMENT_Amount__c);
                Decimal amount = kItems.get(i).PAYMENT_Amount__c;
                sumAmount += amount;
                if (amount > maxAmount) {
                    maxAmount = amount;
                    idx = i;
                }
                pointSum += kItems.get(i).POINT_Amount__c;
            }
            for (Integer i = 0; i < kItems.size(); i++) {
                Decimal amount = kItems.get(i).PAYMENT_Amount__c;
                kItems.get(i).POINT_Amount__c = amount;
    
                if (i != idx) {
                    amountList.add(amount);
                }
            }
            amountList.add((aAmount - sumAmount) + kItems.get(idx).POINT_Amount__c);
            kItems.get(idx).POINT_Amount__c = (aAmount - sumAmount) + kItems.get(idx).POINT_Amount__c;
    
            amountList.sort();
        } else {
            for (Integer i = 0; i < kItems.size(); i++) {
                Decimal amount = Math.floor(aAmount * (kItems.get(i).PAYMENT_Amount__c/kTotalAmount));
                sumAmount += amount;
                if (amount > maxAmount) {
                    maxAmount = amount;
                    idx = i;
                }
                pointSum += kItems.get(i).POINT_Amount__c;
            }
            for (Integer i = 0; i < kItems.size(); i++) {
                System.debug('aAmount :::: ' + aAmount);
                System.debug('kItems.get(i).PAYMENT_Amount__c :::: ' + kItems.get(i).PAYMENT_Amount__c);
                System.debug('kTotalAmount :::: ' + kTotalAmount);
                System.debug('kItems.get(i).PAYMENT_Amount__c/kTotalAmount ::: ' + kItems.get(i).PAYMENT_Amount__c/kTotalAmount);
                System.debug('Math.floor(aAmount * (kItems.get(i).PAYMENT_Amount__c/kTotalAmount)) :::: ' + Math.floor(aAmount * (kItems.get(i).PAYMENT_Amount__c/kTotalAmount)));
    
                Decimal amount = Math.floor(aAmount * (kItems.get(i).PAYMENT_Amount__c/kTotalAmount));
                kItems.get(i).POINT_Amount__c = amount;
    
                if (i != idx) {
                    amountList.add(amount);
    
                }
            }
            amountList.add((aAmount - sumAmount) + kItems.get(idx).POINT_Amount__c);
            kItems.get(idx).POINT_Amount__c = (aAmount - sumAmount) + kItems.get(idx).POINT_Amount__c;
    
            amountList.sort();
        }

        FN_PaymentModel.T_RES_SpendOrCancelPoint[] kResponses = FN_PaymentAgent.requestSpendPoint(aMbsId, amountList, aDeptCode, aDeptName);
        System.debug('속도측정 -------------------------------------------------- EX_PaymentUtil.requestSpendPoint (response):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        for(Integer i=0; i<kItems.size(); i++){
            kItems[i].POINT_TRX_ID__c = kResponses[i].ACCUM_BRKDN_ID;
            System.debug(kResponses[i].ACCUM_BRKDN_ID);
        }
        System.debug('pointSum ' + pointSum);
        System.debug('aAmount ' + aAmount);

        if(pointSum == aAmount){
            for (Integer i = 0; i < kItems.size(); i++) {
                if(kItems.get(i).RSRV_Number__c == null){
                    kItems.get(i).Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006;
                }else{
                    kItems.get(i).Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_002;
                }
                System.debug(' kItems.get(i).Consumables_Order_Status__c ' + kItems.get(i).Consumables_Order_Status__c);

            }
        }
        pItem.POINT_Amount__c = aAmount;
        System.debug(' kResponses ' + kResponses);
        System.debug('속도측정 -------------------------------------------------- EX_PaymentUtil.requestSpendPoint (update before):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        update pItem;
        System.debug('속도측정 -------------------------------------------------- EX_PaymentUtil.requestSpendPoint (update pItem):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        update kItems;
        System.debug('속도측정 -------------------------------------------------- EX_PaymentUtil.requestSpendPoint (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        return kResponses;

    }

    public static FN_PaymentModel.T_RES_SpendOrCancelPoint[] requestCancelPoint(String aMbsId, String aTrxId, Decimal aAmount, String aDeptCode, String aDeptName, String originId) {
        ProductRequestLineItem[] kItems = [
                SELECT Id,POINT_Amount__c,POINT_TRX_ID__c
                FROM ProductRequestLineItem
                WHERE Parent.Id = :originId
        ];

        String[] kTrxIds = new String[]{};
        Decimal[] kAmounts = new Decimal[]{};
        for (ProductRequestLineItem kItem : kItems) {
            kTrxIds.add(kItem.POINT_TRX_ID__c);
            kAmounts.add(kItem.POINT_Amount__c);
        }

        FN_PaymentModel.T_RES_SpendOrCancelPoint[] kResponses = FN_PaymentAgent.requestCancelPoint(aMbsId, kTrxIds, kAmounts, aDeptCode, aDeptName);
        // POINT_TRX_ID__c 업데이트
        Map<String, ProductRequestLineItem> kItemByMoids
                = (Map<String, ProductRequestLineItem>) SMapper.toMap(ProductRequestLineItem.class, kItems, 'POINT_TRX_ID__c');

        for (FN_PaymentModel.T_RES_SpendOrCancelPoint kRes : kResponses) {
            ProductRequestLineItem kItem = kItemByMoids.get(kRes.ORIG_ACCUM_BRKDN_ID);
            if (null != kItem) { kItem.POINT_TRX_ID__c = null; kItem.POINT_Amount__c = 0; }
        }
        update kItems;

        if (kItems.size() == kResponses.size()) { return kResponses; }
        throw new FNException('포인트 취소 실패 - 취소 수: ' + kResponses.size() + '/' + kItems.size());
    }
    @Future(Callout=true)
    public static void sendPaymentKakao(String templateCode,String message,String phone) {
        EX_Message__c exMessage = (EX_Message__c) JSON.deserialize(message,EX_Message__c.class);
        sendKaKaoMessage(templateCode, exMessage, phone);
        insert exMessage;
    }
    /**
 * @description 문자열을 원화로 콤마 추가하여 파싱
 * @param String str
 * @author I2MAX.SEUNGHUNAN
 * @return String returnStr
 */
    public static String strToCurrencyWon(String str) {
        String returnStr = '';
        for (Integer i = 0; i < str.reverse().length(); i++) {
            if (i != 0 && Math.mod(i, 3) == 0) returnStr += ',';
            returnStr += str.reverse().substring(i, i+1);
        }
        return returnStr.reverse();
    }
    /**
    * @description 알림톡 date MM월/dd일 형식으로 변환
    * @param String str
    * @author I2MAX.JAEYEONLEE
    * @return String returnStr
    */

    //sj.yang 2023.08.14
    public static Datetime getDeliveryDate() {

        Datetime deliveryDate = System.now(); // 정상배송완료일
        Integer stateYear = deliveryDate.year(); // 현재년도
        Integer countWDay = 0; // 평일 카운트
        Date stateDate = Date.newInstance(deliveryDate.year(), deliveryDate.month(), deliveryDate.day()+1); // 기준날짜
        Integer dTHour = deliveryDate.hour(); // 현재시간
        System.debug('현재시간 : ' + dTHour);
        
        if(dTHour < 19) { // 19시 이후 기준날짜 + 1
            stateDate = Date.newInstance(deliveryDate.year(), deliveryDate.month(), deliveryDate.day());
            System.debug('기준날짜 바뀜 : ' + stateDate);
        }
        
        
        List<SM_HOLIDAY_MASTER__c> HOLIDAYItems =  [SELECT 	Id, DIV_CODE__c, HOLI_END_DT__c, HOLI_START_DT__c, HOLI_TYPE__c, HOLY_REASON__c
        FROM SM_HOLIDAY_MASTER__c
        WHERE HOLI_TYPE__c IN('A', 'B', 'D', 'Z')
        AND HOLI_APPLY_TY__c = 'C'
        AND CALENDAR_YEAR(HOLI_START_DT__c) IN(:stateYear, :stateYear+1)
        AND HOLI_START_DT__c >= TODAY
        ORDER BY HOLI_START_DT__c ASC];
        
        
        for(SM_HOLIDAY_MASTER__c sm : HOLIDAYItems) {
            if(countWDay == 2) {               
                break;
            } else if(countWDay == 0) {
                if(Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+1) == sm.HOLI_START_DT__c) {
                    stateDate = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+1);                    
                } else if(Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+2) == sm.HOLI_START_DT__c) {
                    stateDate = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+2);
                    countWDay++;                    
                } else {
                    stateDate = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+2);
                    break;                    
                }
            } else if(countWDay == 1) {
                if(Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+1) == sm.HOLI_START_DT__c) {
                    stateDate = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+1);                    
                } else {
                    stateDate = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+1);
                    countWDay++;           
                }
            }      
        }        
        deliveryDate = Datetime.newInstance(stateDate.year(), stateDate.month(), stateDate.day(), 23, 59, 59);
        System.debug('정상배송완료일 : ' + deliveryDate);
        return deliveryDate;
    }

    public static String convertDate(Datetime msgDate) {
        String convertDate = msgDate.format('MM월 dd일(E)');
        String dayOfWeek = convertDate.substring(convertDate.length() - 5, convertDate.length());
        String koreanDayOfWeek;
        System.debug('dayOfWeek : ' + dayOfWeek);
        switch on  dayOfWeek {
            when '(Sun)' { koreanDayOfWeek = '(일)';
            }
            when '(Mon)' { koreanDayOfWeek = '(월)';
            }
            when '(Tue)' { koreanDayOfWeek = '(화)';
            }
            when '(Wed)' { koreanDayOfWeek = '(수)';
            }
            when '(Thu)' { koreanDayOfWeek = '(목)';
            }
            when '(Fri)' { koreanDayOfWeek = '(금)';
            }
            when '(Sat)' { koreanDayOfWeek = '(토)';
            }
        }
        System.debug('koreanDayOfWeek : ' + koreanDayOfWeek);
        convertDate = convertDate.replace(dayOfWeek, koreanDayOfWeek);
        return convertDate;
    }

    /**
    * @description 콜센터 직원 현금영수증 출력 미표시
    * @param String str
    * @author DKBMC.gw.lee
    * @return Boolean
    */
    @AuraEnabled
    public static Boolean getUserProfile() {
        Boolean isCenterUser = false;

        String profileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].Profile.Name;

        if (profileName.contains('콜센터')) {
            isCenterUser = true;
        }

        return isCenterUser;
    }

    @AuraEnabled
    public static string createExMessage(Map<String, Object> paramMap){
        try {
            String returnValue = 'Pass';

            if (paramMap == null) {
                return returnValue;
            } else if (String.valueOf(paramMap.get('Pass')) != 'Y') {
                //Object paramValue = (Map<String, Object>)JSON.serialize(paramMap);
                
                System.debug('paramData :::: ' + paramMap);

                Map<Object, Object> params = (Map<Object, Object>) paramMap.get('param');


                String bankValue = (String) params.get('payment');

                EX_Message__c insertObj = new EX_Message__c();
                //가상계좌
                if (bankValue == 'PG_VBANK' || bankValue == 'PG_URL') { //24 01 09 hyungho.chun 결제URL->가상계좌용 조건 추가

                    String prId = (String) paramMap.get('prId');
                    // List<ProductRequestLineItem> prliIdList = [SELECT ID, Order_Number__c, fm_Consumables_PART_DESC_KOR__c, ParentId,Parent.LIMIT_TM__c FROM ProductRequestLineItem WHERE ParentId = :prId AND Order_CHNL_TYPE_Code__c != null];
                    //24 01 25 hyungho.chun 카카오톡 가상계좌 최초발송 및 결제URL가상계좌 최초전송 템플릿도 재전송때와 같게 수정하기위해 쿼리 수정
                    List<ProductRequestLineItem> prliIdList = [SELECT Id, Order_Number__c,ParentId,Parent.LIMIT_TM__c, PART_DESC_KOR__c, Product2.PART_DESC_KOR__c, fm_ProductName__c, Product2.PART_DESC__c FROM ProductRequestLineItem WHERE ParentId = :prId AND Order_CHNL_TYPE_Code__c != null];
                    System.debug('prliIdList :::: ' + prliIdList);
                    //List<ProductRequestLineItem> pridList;
                    ProductRequestLineItem selectedPrlist = prliIdList[0];
                    String partName = '';
                    if (prliIdList.size() > 0) {
                        if (selectedPrlist.PART_DESC_KOR__c != null && !selectedPrlist.PART_DESC_KOR__c.equals('')) {
                            partName = selectedPrlist.PART_DESC_KOR__c;
                        } else if (selectedPrlist.Product2.PART_DESC_KOR__c != null && !selectedPrlist.Product2.PART_DESC_KOR__c.equals('')) {
                            partName = selectedPrlist.Product2.PART_DESC_KOR__c;
                        } else if (selectedPrlist.fm_ProductName__c != null && !selectedPrlist.fm_ProductName__c.equals('')) {
                            partName = selectedPrlist.fm_ProductName__c;
                        } else {
                            partName = selectedPrlist.Product2.PART_DESC__c;
                        }

                        // for (ProductRequestLineItem tempObj : prliIdList) {
                        //     partName = partName + tempObj.fm_Consumables_PART_DESC_KOR__c + ', ';
                        // }

                        // partName = partName.removeEnd(', ');
                        partName = partName + (prliIdList.size() > 1 ? ' 외 ' + (prliIdList.size() - 1 + '') + '건' : '');

                        

                        if (partName.length() > 255) {
                            partName = partName.subString(0, 252) + '...';
                        }
                    }

                    if (prliIdList.size() > 0) {
                        Decimal amount =(Decimal) params.get('amount');

                        insertObj.Label1__c = (String) params.get('receiverName'); //주문자
                        insertObj.Label2__c = prliIdList[0].Order_Number__c; //주문 번호
                        insertObj.Label3__c = partName; //상품명
                        //23 11 30 hyungho.chun 금액에 3자리마다 콤마 추가
                        insertObj.Label4__c = String.valueOf(Math.abs(amount).format()); //금액
                        // insertObj.Label4__c = String.valueOf(amount); //금액
                        insertObj.Label5__c = (String) params.get('virtualBankAccountNo'); //가상계좌
                        insertObj.Label6__c = (String) params.get('bank'); //은행
                        //23 11 30 hyungho.chun 날짜에 월,일(요일)붙어야함
                        // insertObj.Label7__c = EX_ConsumableUtil.convertDate(prliIdList[0].Parent.LIMIT_TM__c); //기한일자
                        // insertObj.Label7__c = (String) params.get('depositDueDate'); //기한일자


                        //24 02 08 hyungho.chun LIMIT_TM__c가 아직 안들어간경우 (품절주문->입고완료->결제요청->가상계좌발행)을위해 없는경우 기한날짜 게산후 기입
                        Datetime target = Datetime.newInstance(
                            Date.today().addDays(1),
                            Time.newInstance(23, 59, 0, 0)
                        );                      
                        DateTime dtTemp = prliIdList[0].Parent.LIMIT_TM__c != null ? prliIdList[0].Parent.LIMIT_TM__c : target;
                        insertObj.Label7__c = EX_ConsumableUtil.convertDate(dtTemp); //기한일자
                    }

                //현금
                } else if (bankvAlue == 'PG_VBANK1') {
                    Decimal amount = (Decimal) params.get('amount');

                    insertObj.Label1__c = String.valueOf(params.get('receiverName')); //주문자
                    insertObj.Label2__c = String.valueOf(amount); //금액
                    insertObj.Label3__c = String.valueOf(params.get('virtualBankAccountNo')); //가상계좌
                    insertObj.Label4__c = String.valueOf(params.get('bank')); //은행
                }

                if (insertObj != null) {
                    System.debug('insertOBj :::: ' + insertObj);
                    insert insertObj;

                    return String.valueOf(insertObj.Id);
                } else {
                    return 'Pass';
                }

            }

            return 'Pass';
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> sendExMessage(String emId, String templateType, String receiverNumber, String prId){
        System.debug('속도측정 -------------------------------------------------- EX_PaymentUtil.sendExMessage (시작부분):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        // Map<String, String> returnMap;
        //23 11 16 hyungho.chun return값 받아서 아우라에 넘김
        Map<String, Object> returnMap;
        // try {

            //String templateCode = templateType == '가상계좌' ? 'SVC_LGE_MACN_012_01' : 'SVC_LGE_MACN_S012';
            String templateCode = templateType == '가상계좌' ? '가상계좌재전송' : 'SMS재전송';

            Map<String, Object> prMap = new Map<String, Object>{
                'ParentId' => prId
            };

            // EX_ConsumablesOrderManagementController.doResend(emId, templateCode, JSON.serialize(prMap), receiverNumber);
            returnMap = EX_ConsumablesOrderManagementController.doResend(emId, templateCode, JSON.serialize(prMap), receiverNumber);
            

            System.debug('속도측정 -------------------------------------------------- EX_PaymentUtil.sendExMessage (끝부분/성공):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

            return returnMap;


            // return returnMap = new Map<String, String>{
            //     'STATUS' => 'S',
            //     'MESSAGE' => 'SUCCESs'
            // };
            
        // } catch (Exception e) {
        //     System.debug('속도측정 -------------------------------------------------- EX_PaymentUtil.sendExMessage (끝부분/실패):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        //     return returnMap = new Map<String, String>{
        //         'STATUS' => 'E',
        //         'MESSAGE' => e.getMessage()
        //     };
        // }
        
    }
    
    //23 12 04 hyungho.chun 포인트인증했다가 닫기했을때 point_amount 리셋하는 메소드 추가
    @AuraEnabled
    public static Map<String, Object> resetPointAmount(List<String> prIds){
        Map<String,Object> returnMap = new Map<String,Object>();
        try {
            List<ProductRequest> prList = [SELECT Id, POINT_Amount__c FROM ProductRequest WHERE Id IN : prIds];
            for(ProductRequest pr : prList){
                pr.POINT_Amount__c = 0;
            }
            update prList;
            returnMap.put('isSuccess',true);
            return returnMap;
        } catch (Exception e) {
            // throw new AuraHandledException(e.getMessage());
            returnMap.put('isSuccess',false);
            return returnMap;
        }
    }
}