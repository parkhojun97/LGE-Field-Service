/**
 * @description       : 
 * @author            : hyungho.chun@dkbmc.com
 * @group             : 
 * @last modified on  : 02-26-2024
 * @last modified by  : hyungho.chun@dkbmc.com
**/
public with sharing class EX_OrderReceiving_qa implements Queueable, Database.AllowsCallouts {

    IF_CM_SFDC_KAKAO.InputParam inputParam;
    // String phoneNumber;
    Set<String> phoneNumber; //24 02 26 hyungho.chun 기본 파람 set<string>으로 받음

    public EX_OrderReceiving_qa() {

    }

    // public EX_OrderReceiving_qa(String inputParam, String phoneNumber) {
    public EX_OrderReceiving_qa(String inputParam, Set<String> phoneNumber) {
        System.debug('inputParam ::: ' + inputParam);
        this.inputParam = (IF_CM_SFDC_KAKAO.InputParam) JSON.deserialize(inputParam, IF_CM_SFDC_KAKAO.InputParam.class);
        this.phoneNumber = phoneNumber;
    }

    @TestVisible
    public void execute(QueueableContext context) {
        IF_CM_SFDC_KAKAO.InputParam sendParam = new IF_CM_SFDC_KAKAO.InputParam();
        sendParam.templateCode = inputParam.templateCode;
        sendParam.kakaoMsg = inputParam.kakaoMsg;
        sendParam.kakaoTitle = inputParam.kakaoTitle;
        sendParam.smsMsg = inputParam.smsMsg;
        sendParam.smsTitle = inputParam.smsTitle;
        System.debug('phoneNumber :::: ' + phoneNumber);
        // Set<String> setPhoneNumber = new Set<String>{
        //     phoneNumber
        // };
        // sendParam.setPhoneNumber = setPhoneNumber;

        sendParam.setPhoneNumber = phoneNumber;
        sendParam.sendAt = inputParam.sendAt;
        System.debug('inputParam ::: ' + sendParam);
        IF_CM_SFDC_KAKAO.doSendKakao(sendParam);
    }
}