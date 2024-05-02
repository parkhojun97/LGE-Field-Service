/**
 * Created by I2MAX.SEUNGHUNAN on 2023-03-17.
 * Description: 소모품에서 사용하는 알림톡, SMS 등 알림 관련 유틸
 * ------------------------------------------------------------------------------------------------------
 * SVC_LGE_MACN_010 : 품절일 경우 고객이 요구할 경우 컨설턴트/SM 담당자 품절예약 주문 생성 후 고객에 주문정보 알림
 * SVC_LGE_MACN_011 : 소모품택배 주문 결제방식 고객이 결제URL 요청할 경우 해당정보 발송
 * SVC_LGE_MACN_012_01 : 소모품택배 주문 결제방식 고객이 가상계좌 요청할 경우 해당정보 발송
 * SVC_LGE_MACN_013 : 소모품택배 주문완료(결제완료) 후 해당 주문정보 알림
 * SVC_LGE_MACN_014 : 택배 주문 생성 화면에서 고객 요청시 OBS 제품페이지 or 대표이미지 URL고객 알림
 * SVC_LGE_MACN_020 : 결제 미완료로 기한 당일 고객에게 해당 소모품 택배 주문 사전취소 안내 알림
 * SVC_LGE_MACN_021 : 결제 미완료로 기한 초과 다음 날 고객에게 소모품 택배 주문 자동취소 안내 알림
 * SVC_LGE_MACN_030 : 소모품 구매 후 배송완료 이후 고객이 반품요청 시 정상 접수 안내 알림
 * SVC_LGE_MACN_040 : 소모품 택배 주문 생성 이후 되었지만 영업일 기준3日 지나도 배송중으로 변경 안될송장번호가 생성되어 배송시작되었음을 고객에게 알림
 * SVC_LGE_MACN_041 : 주문생성 후 결제가 완료 경우 고객 알림
 * ------------------------------------------------------------------------------------------------------
 */

public without sharing class EX_MessageUtil {
    /**
     * @description 카카오 알림톡 발신 전 데이터 세팅
     * @param String templateCode : 알림톡 템플릿 코드
     * @param String objectId : 소모품 메시지 Object Id
     * @return Map<String, Object>=
     * @author 23.03.29 / I2MAX.SEUNGHUNAN
     */
    public static Map<String, Object> getRelatedData(String templateCode, String objectId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        try {
            TemplateMgmt__c template = [
                    SELECT Id, Content_c__c, Title__c, TemplateCode__c
                    FROM TemplateMgmt__c
                    WHERE TemplateCode__c=:templateCode
            ][0];
            List<TemplateParams__c> templateParamList = [
                    SELECT Id, Name, FieldApi__c
                    FROM TemplateParams__c
                    WHERE TemplateMgmt__c=:template.Id
            ];
            EX_Message__c messageObject = [
                    SELECT Id, Label1__c, Label2__c, Label3__c, Label4__c, Label5__c,
                            Label6__c, Label7__c, Label8__c, Label9__c, Label10__c
                    FROM EX_Message__c
                    WHERE Id=:objectId
            ];

            returnMap.put('isSuccess', true);
            returnMap.put('template', template);
            returnMap.put('templateParamList', templateParamList);
            returnMap.put('messageObject', messageObject);
        } catch(Exception e) {
            System.debug(e.getLineNumber() + ' || ' + e.getMessage());
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
        System.debug('template '+template);
        System.debug('templateParamList '+templateParamList);
        System.debug('populateMap '+populateMap);
        try {
            for (TemplateParams__c param : templateParamList) {
                if (populateMap.containsKey(param.FieldApi__c)) {
                    template.Content_c__c = template.Content_c__c.replace('#{' + param.FieldApi__c + '}'
                            , (String)populateMap.get(param.FieldApi__c));
                }
            }
            inputParam = new IF_CM_SFDC_KAKAO.InputParam();

            inputParam.templateCode = template.TemplateCode__c;
            // inputParam.kakaoTitle = template.Title__c;
            inputParam.kakaoMsg = template.Content_c__c.replaceAll('\\r', '');
            // inputParam.setPhoneNumber = new Set<String>{phoneNumber};
        } catch(Exception e) {
            System.debug(e.getLineNumber() + ' || ' + e.getMessage());
        }
        return inputParam;
    }
    /**
     * @description 카카오 알림톡 발신 // 예약건은 TemplateCode에 Delimiter (^) 추가해서 호출
     * @param String templateCode : 알림톡 템플릿 코드
     * @param String objectId : 소모품 메시지 Object Id
     * @param String phoneNumber : 알림톡을 수신할 번호
     * @return IF_CM_SFDC_KAKAO.Result
     * @author 23.03.29 / I2MAX.SEUNGHUNAN
     */
    public static IF_CM_SFDC_KAKAO.Result sendKaKaoMessage(String templateCode, String objectId, String phoneNumber) {
        System.debug(templateCode + ' ' + objectId +' ' + phoneNumber);
        // 예약건 체크
        Datetime reserveSendDatetime = null;
        boolean isReserveSend = templateCode.split('\\^').size() > 1;

        if (isReserveSend) {
            reserveSendDatetime = Datetime.newInstance(Long.valueOf(templateCode.split('\\^')[1]));
        }

        templateCode = isReserveSend ? templateCode.split('\\^')[0] : templateCode;

        System.debug('templateCode : ' + templateCode);

        Map<String, Object> relatedData = getRelatedData(templateCode, objectId);
        TemplateMgmt__c template = (TemplateMgmt__c) relatedData.get('template');
        List<TemplateParams__c> templateParamList = (List<TemplateParams__c>) relatedData.get('templateParamList');
        EX_Message__c messageObject = (EX_Message__c) relatedData.get('messageObject');

        Map<String, Object> populateMap = messageObject.getPopulatedFieldsAsMap();

        IF_CM_SFDC_KAKAO.InputParam inputParam = getInputParamForKaKao(template, templateParamList, populateMap);
        if (phoneNumber == null || phoneNumber.equals('')) return null;

        // if (templateCode.equals('SVC_LGE_MACN_011')) {
        if (templateCode.equals('SVC_LGE_MACN_011_1')) { //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
            IF_CM_SFDC_KAKAO.Button kakaoButton = new IF_CM_SFDC_KAKAO.Button();
            List<IF_CM_SFDC_KAKAO.Button> listKakaoButton = new List<IF_CM_SFDC_KAKAO.Button>();

            kakaoButton.buttonText = '결제하기';
            kakaoButton.type = 'URL';
            kakaoButton.buttonUrlMobile = messageObject.Label6__c;
            kakaoButton.buttonUrlPc = messageObject.Label6__c;
            listKakaoButton.add(kakaoButton);

            inputParam.listKakaoButton = listKakaoButton;
        }
        // else if (templateCode.equals('SVC_LGE_MACN_014_02')) {
        else if (templateCode.equals('SVC_LGE_MACN_014_03')) { //24 03 13 hyungho.chun 템플릿 금액 뒤에 '원' 추가
            IF_CM_SFDC_KAKAO.Button kakaoButton = new IF_CM_SFDC_KAKAO.Button();
            List<IF_CM_SFDC_KAKAO.Button> listKakaoButton = new List<IF_CM_SFDC_KAKAO.Button>();

            kakaoButton.buttonText = '상세한 상품 정보 확인';
            kakaoButton.type = 'URL';
            kakaoButton.buttonUrlMobile = messageObject.Label4__c;
            kakaoButton.buttonUrlPc = messageObject.Label4__c;
            listKakaoButton.add(kakaoButton);

            inputParam.listKakaoButton = listKakaoButton;
        }
//        inputParam.smsTitle = '테스트 입니다.';
//        inputParam.smsMsg = '카카오 발송 실패!';
        inputParam.setPhoneNumber = new Set<String>{phoneNumber};

        // 예약건 TemplateCode + '^' + keyword
        if (isReserveSend) {
            inputParam.sendAt = reserveSendDatetime;
        }

        System.debug('inputParam : ' + inputParam);

        Map<String, Object> mapResult = IF_CM_SFDC_KAKAO.doSendKakao(inputParam);

        IF_CM_SFDC_KAKAO.Result kakaoResult = (IF_CM_SFDC_KAKAO.Result) mapResult.get('resultWrapper');
        if (kakaoResult == null) {
            kakaoResult = (IF_CM_SFDC_KAKAO.Result)mapResult.get('result');
        }

        if (!kakaoResult.isSuccess) {
            throw new FNException('KaKao 발신 실패');
        }

        return kakaoResult;
    }

    /**
     * @description 현재 시간이 영업시간 (09:00 ~ 21:00) 인지 판단
     * @return Boolean
     * @author 23.06.02 / I2MAX.SEUNGHUNAN
     */
    public static Boolean isBusinessHours() {
        Time curTime = System.now().time();
        Time startTime = Time.newInstance(9, 0, 0, 0);
        Time endTime = Time.newInstance(21, 0, 0, 0);

        return startTime <= curTime && curTime <= endTime;
    }

    /**
     * @description 현재 시간을 기준으로 당일 09시에 메세지를 전송할지, 익일 09시에 메세지 전송할지 결정
     * curDatetimeDiff와 nextDatetimeDiff는 영업시간이 아닐 때 같은 값일 수 없다.
     * @return Datetime
     * @author 23.06.02 / I2MAX.SEUNGHUNAN
     */
    public static Datetime getNearSendDatetime() {
        Datetime nowDatetime = System.now();
        Time sendTime = Time.newInstance(09, 0, 0, 0);
        Datetime curDatetime = Datetime.newInstance(nowDatetime.date(), sendTime);
        Datetime nextDatetime = Datetime.newInstance(nowDatetime.date().addDays(1), sendTime);
        Long curDatetimeDiff = Math.abs(nowDatetime.getTime() - curDatetime.getTime());
        Long nextDatetimeDiff = Math.abs(nowDatetime.getTime() - nextDatetime.getTime());

        return curDatetimeDiff < nextDatetimeDiff ? curDatetime : nextDatetime;
    }

    //24 02 24 hyungho.chun 
    //배치실행후 오류발생시 담당자(커스텀라벨로관리)에게 이메일 및 SMS전송
    // @future(callout=true) 
    public static void sendSMSandEmail(Map<String,String> errorMap){
        // System.Label.EX_logReceiverMail 이메일주소,이메일주소,이메일주소 형태
        // System.Label.EX_logReceiverPhone 전화번호(-없이),전화번호,전화번호 형태
        
        IF_CM_SFDC_KAKAO.InputParam inputParam = new IF_CM_SFDC_KAKAO.InputParam();
        DateTime nowTime = System.now().addMinutes(1);

        String className = errorMap.containsKey('className') ? errorMap.get('className') : '';
        String errorMsg = errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') : '';

        String kakaoMsg = '';
        kakaoMsg += '배치 오류 알림 발송 \n';
        kakaoMsg += '\n';
        kakaoMsg += '클래스 : ' + className + '\n';
        kakaoMsg += '\n';
        kakaoMsg += '오류내용 : ' + errorMsg + '\n';

        inputParam.templateCode = 'SVC_LGE_MACN_S020'; //24 02 24 hyungho.chun 어차피 팅겨낼것
        inputParam.kakaoMsg = kakaoMsg; //24 02 24 hyungho.chun 어차피 팅겨낼것
        inputParam.kakaoTitle = '소모품 입고'; //24 02 24 hyungho.chun 어차피 팅겨낼것

        inputParam.smsMsg = kakaoMsg; 
        inputParam.smsTitle = '배치 오류 알림 발송';

        Set<String> tempPhoneSet = new Set<String>();
        List<String> tempPhoneList = System.Label.EX_logReceiverPhone.split(',');
        for(String item : tempPhoneList){
            tempPhoneSet.add(item);
        }

        // tempPhoneSet.add('01083212428');
        // tempPhoneSet.add('01041276588');
        // inputParam.setPhoneNumber = tempPhoneSet;

        inputParam.sendAt = nowTime;

        //24 02 26 hyungho.chun i/f pending error 로 queue로 알림톡발송 따로 뻄
        if(!Test.isRunningTest()) System.enqueueJob(new EX_OrderReceiving_qa(JSON.serialize(inputParam), tempPhoneSet));  

        // inputParam.isSaveResponse = true;

        // Map<String, Object> mapResult = IF_CM_SFDC_KAKAO.doSendKakao(inputParam);
                        
        // System.debug(mapResult);

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Set<String> tempEmailSet = new Set<String>();
        List<String> tempEmailList = System.Label.EX_logReceiverMail.split(',');
        for(String item : tempEmailList){
            tempEmailSet.add(item);
        }

        mail.setToAddresses(tempEmailList);

        OrgWideEmailAddress addr = [SELECT Id, Address, DisplayName, Purpose FROM OrgWideEmailAddress WHERE Address = 'smileplus@lge.com' LIMIT 1];
        mail.setOrgWideEmailAddressId(addr.Id);

        
        //mail.setSenderDisplayName('테스트 LG 전자 서울센터 테스트'); // setOrgWideEmailAddressId 이거 설정하면 못씀
        // Set the subject line for your email address.
        mail.setSubject('배치 오류 알림 발송');

        // You can set this to true if you want to BCC yourself on the email
        mail.setBccSender(false);
        // You can specify your plain text here
        // mail.setPlainTextBody();

        //Specify any html - for example this will display a link in the email
        
        // mail.setHtmlBody(kakaoMsg);

        String htmlValue = '';
        htmlValue += '<html>\n';
        htmlValue += '<head>\n';
        htmlValue += '    <title></title>\n';
        htmlValue += '    <style class="darkreader darkreader--sync" media="screen" type="text/css">\n';
        htmlValue += '    </style>\n';
        htmlValue += '    <style class="darkreader darkreader--sync" media="screen" type="text/css">\n';    
        htmlValue += '    </style>\n';    
        htmlValue += '</head>\n';
        htmlValue += '\n';
        htmlValue += '<body style="height: auto; min-height: auto;"><br />\n';
        htmlValue += '<br />\n';
        htmlValue += '&nbsp;\n';
        htmlValue += '<p> 배치 오류 알림 발송<br />\n';
        htmlValue += '<br />\n';
        htmlValue += '<p> 클래스 : '+className +'<br />\n';
        htmlValue += '<br />\n';
        htmlValue += '<p> 오류내용 : '+errorMsg +'<br />\n';
        htmlValue += '<br />\n';
        htmlValue += '<br />\n';
        htmlValue += '</body>\n';
        htmlValue += '</html>\n';
        
 
        mail.setHtmlBody(htmlValue);
        

        // mail.setFileAttachments(efas);
        // Send the email
        if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
            

    }    
}