/**
 * @description       : 입고 배치 워킹데이 알림톡 전송
 * @author            : gunting2000@cnspartner.com
 * @last modified on  : 03-05-2024
 * @last modified by  : hyungho.chun@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2023-12-14   gunting2000@cnspartner.com    Initial Version
 * 1.1   2024-02-15   gunting2000@cnspartner.com    법인폰일 경우만, 전송 로직 및 노티알림 로직 추가
**/
public with sharing class EX_OrderReceivingAlarm_ba implements Database.Batchable<sObject>, DataBase.stateful, DataBase.AllowsCallouts, Schedulable {

    Boolean isValidDateTosend = true;
    String successIdGroup = 'Success Id Group : ';
    String failIdGroup = 'Fail Id Group : ';
    Boolean allSucces = true;
    Map<String,String> errorMap = new Map<String,String>();
    Map<String,String> errorMapForFail = new Map<String,String>();

    public Database.QueryLocator start(Database.BatchableContext param1) {
        String strQuery = '';
        strQuery += 'SELECT ID, Label1__c, Label2__c, Label3__c, Label4__c, Label5__c, Label6__c, Label7__c, Label8__c, Label9__c, Label10__c ';
        strQuery += 'FROM EX_Message__c ';
        strQuery += 'WHERE Label8__c = \'EX_OrderReceiving_ba\' AND Label9__c = \'N\' ';

        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext param1, List<EX_Message__c> exList) {

        //24.02.15 gw.lee
        //법인폰 고객에게만 알림톡 전송 로직 추가
        Set<String> userSet = new Set<String>();
        Map<String, String> corporateMap = new Map<String, String>();
        for (EX_Message__c eObj : exList) { 
            userSet.add(eObj.Label10__c);
        }

        List<ServiceResource> srList = [SELECT ID, RelatedRecordId, CORPORATION_PHONE_USE_YN__c, CORPORATION_PHONE_NUMBER__c FROM ServiceResource WHERE RelatedRecordId = :userSet];

        for (ServiceResource sObj : srList) {
            if (String.isNotEmpty(sObj.CORPORATION_PHONE_NUMBER__c)) {
                corporateMap.put(sObj.RelatedRecordId, sObj.CORPORATION_PHONE_NUMBER__c);
            }
        }


        DateTime todayTime = System.now().addHours(9);
        Date today = Date.valueOf(todayTime);
        Integer hours = todayTime.addHours(-9).hour();
        String weekOfDay = todayTime.format('E');

        // IF_CM_SFDC_KAKAO.BulkResult bulkResult;
        List<Map<String, Object>> mapList = new List<Map<String, Object>>();

        //휴일 조회 로직
        List<SM_HOLIDAY__c> holidayList = [SELECT HOLI_DT__c FROM SM_HOLIDAY__c WHERE HOLI_DT__c = :today];
        System.debug(holidayList.size());

        List<IF_CM_SFDC_KAKAO.InputParam> sendList = new List<IF_CM_SFDC_KAKAO.InputParam>();

        DateTime nowTime = System.now().addMinutes(1);
        
        List<FeedItem> feedList = new List<FeedItem>();
        //주말이 및 공휴일이 아닌 경우
        //09~18시까지 발송
        if ((weekOfDay != 'Sat' && weekOfDay != 'Sun' && holidayList.size() == 0 && hours > 8 && hours < 19) || Test.isRunningTest()) {
            for (EX_Message__c eObj : exList) {
                //오전 9시 ~ 오후 17시까지 업무 시간 확인
                // if (hours > 8 || hours < 18) {
                //업무 시간일 경우, 전송 조치
                IF_CM_SFDC_KAKAO.InputParam inputParam = new IF_CM_SFDC_KAKAO.InputParam();
                
                //24.02.07 gw.lee
                //메세지 보내는 방식 수기 기입으로 변경
                String kakaoMsg = '';
                kakaoMsg += '소모품 택배주문 건이 창고에 입고 되어 출하 가능합니다.\n';
                kakaoMsg += '\n';
                kakaoMsg += '- 주문번호 : ' + eObj.Label2__c + '\n';
                kakaoMsg += '- P/N : ' + eObj.Label4__c + '\n';
                kakaoMsg += '\n';
                kakaoMsg += '소모품택배주문관리 화면에서 상세 내용 확인부탁드리며, 고객님께 주문의향 확인 후 주문을 원하시는 고객님께는 결제 처리 부탁드리겠습니다.';
    
                inputParam.templateCode = eObj.Label1__c;
                inputParam.kakaoMsg = kakaoMsg;
                inputParam.kakaoTitle = eObj.Label3__c;
                inputParam.smsMsg = kakaoMsg;
                inputParam.smsTitle = eObj.Label5__c;
                
                if (corporateMap.containsKey(eObj.Label10__c)) {
                    Set<String> setPhoneNumber = new Set<String>{
                        corporateMap.get(eObj.Label10__c)
                    };
                    inputParam.setPhoneNumber = setPhoneNumber;
                } else {
                    Set<String> setPhoneNumber = new Set<String>{
                        ''
                    };
                    inputParam.setPhoneNumber = setPhoneNumber;
                }
                inputParam.sendAt = nowTime;
                inputParam.isSaveResponse = true;
    
                Map<String, Object> mapResult = IF_CM_SFDC_KAKAO.doSendKakao(inputParam);
                mapList.add(mapResult);
    
                // sendList.add(inputParam);
    
                // bulkResult = IF_CM_SFDC_KAKAO.doBulkSendKakao(sendList);
                // }
    
                eObj.Label9__c = 'Y';
    
                // successIdGroup += eObj.Id + ' ,';
                FeedItem feedObj = new FeedItem();
                feedObj.ParentId = eObj.Label10__c;
                feedObj.Title = '[소모품 입고 알림]';
                feedObj.Body = kakaoMsg;
    
                feedList.add(feedObj);
            } 
            // eObj.Label9__c = 'Y';
            // bulkResult = IF_CM_SFDC_KAKAO.doBulkSendKakao(sendList);
        }else{
            isValidDateTosend = false;
        }

        

        if (mapList.size() > 0) {
            for (Integer i = 0; i < mapList.size(); i++) {
                IF_CM_SFDC_KAKAO.Result kakaoResult = (IF_CM_SFDC_KAKAO.Result) mapList[i].get('result');
                System.debug('kakaoResult :::: ' + kakaoResult);
                if (kakaoResult != null) {
                    if (kakaoResult.isSuccess == true) {
                        successIdGroup += exList[i].Id + ' ,';
                    }else{
                        exList[i].Label9__c = 'E';
                        failIdGroup += exList[i].Id + ' ,';
                        allSucces = false;
                    }
                }
            }
        }

        if (feedList.size() > 0) {

            insert feedList;

            // CustomNotificationType notificationType = [SELECT Id, DeveloperName FROM CustomNotificationType WHERE DeveloperName='ChatterTransfer' LIMIT 1];
            // for (FeedItem fObj : feedList) {
            //     Messaging.CustomNotification notification = new Messaging.CustomNotification();
            //     Set<String> recipientsIds = new Set<String>();

            //     notification.setTitle('[소모품 입고 알림]');
            //     notification.setBody(fObj.Body);
            //     notification.setNotificationTypeId(notificationType.Id);
            //     // notification.setTargetPageRef(
            //     // '' +
            //     // '{' +
            //     // '       type: \'standard__recordPage\',' +
            //     // '       attributes: {' +
            //     // '           recordId: ' + fObj.Id + ' ,' +
            //     // '           objectApiName:  \'FeedItem\' , ' +
            //     // '           actionName: \'view\'' +
            //     // '       }' +
            //     // '}');
            //     notification.setSenderId(fObj.ParentId);
            //     notification.setTargetId(fObj.Id);
            //     recipientsIds.add(fObj.ParentId);            
            //     notification.send(recipientsIds);
            // }
        }

        update exList;

    }

    public void finish(Database.BatchableContext param1) {

        if(isValidDateTosend){
            errorMap.put('tempErrorMsg', '알림톡 전송 성공 및 실패 EX_Message ID 모음');
            if(allSucces){
                errorMap.put('requestMsg', successIdGroup);
                errorMap.put('isSuccess','Y'); //24 02 25 hyungho.chun 성공 실패 여부 추가 (이메일 및 실패시 메세지 전송용)
            }else{
                errorMap.put('requestMsg', successIdGroup + '  '+failIdGroup);
                errorMap.put('isSuccess','N'); //24 02 25 hyungho.chun 성공 실패 여부 추가 (이메일 및 실패시 메세지 전송용)
            }
            
            // if(!allSucces){
            //     errorMapForFail.put('tempErrorMsg', '알림톡 전송 실패 EX_Message ID 모음');
            //     errorMapForFail.put('requestMsg', failIdGroup);
                
            //     System.debug('Before Calling saveSaleExc // errorMapForFail :: '+errorMapForFail);
            //     EX_ConsumableUtil.saveSaleExc(errorMapForFail);                
            // }
        }else{
            String tempMsg = '주말 및 공휴일 제외 오전 9시 ~ 오후 5시 알림톡을 다시 전송합니다. ';
            errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
        }
        errorMap.put('className','EX_OrderReceivingAlarm_ba');
        System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
        EX_ConsumableUtil.saveSaleExc(errorMap);


    }


    public void execute(SchedulableContext sc) {
        Database.executeBatch(new EX_OrderReceivingAlarm_ba(), 1);
    }

}