/**
 * @description       : 
 * @author            : hyungho.chun@dkbmc.com
 * @group             : 
 * @last modified on  : 12-14-2023
 * @last modified by  : hyungho.chun@dkbmc.com
**/
@IsTest
public with sharing class EX_OrderReceivingAlarm_ba_ts {

    public EX_OrderReceivingAlarm_ba_ts() {

    }

    @IsTest
    static void test_01() {
        Test.startTest();

        TemplateMgmt__c tmgt = new TemplateMgmt__c();
        tmgt.Content_c__c = 'teststests';
        tmgt.Title__c = 'testsetse';
        tmgt.TemplateCode__c = 'SVC_LGE_MACN_S020';

        insert new List<TemplateMgmt__c> {tmgt};


        EX_Message__c exMessage = new EX_Message__c();
        exMessage.Label1__c = 'test';
        insert exMessage;

        String templateCode = 'SVC_LGE_MACN_S020';
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

        TemplateMgmt__c templateTemp = template.clone();

        Map<String, Object> populateMap = exMessage.getPopulatedFieldsAsMap();

        IF_CM_SFDC_KAKAO.InputParam inputParam = 
        EX_MessageUtil.getInputParamForKaKao(templateTemp, templateParamList, populateMap);
        inputParam.smsTitle = '소모품 입고';
        inputParam.smsMsg = inputParam.kakaoMsg;   

        SM_DEPT__c dept = EX_TestDataUtil.getDept(true,'PH8002');

        insert new ServiceResource(Name = UserInfo.getLastName()
                                , RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('CNSL').getRecordTypeId()
                                , RelatedRecordId = UserInfo.getUserId()
                                , IsActive = true
                                , SM_DEPT__c = dept.Id
                                , SM_DEPT_CENTER__c = dept.Id
                                , JOB_TYPE__c = 'A70');

        ServiceResource sr = [SELECT Id FROM ServiceResource LIMIT 1];


        EX_Message__c alarm = new EX_Message__c();
        alarm.Label1__c = inputParam.templateCode;
        alarm.Label2__c = inputParam.kakaoMsg;
        alarm.Label3__c = inputParam.kakaoTitle;
        alarm.Label4__c = inputParam.smsMsg;
        alarm.Label5__c = inputParam.smsTitle;
        alarm.Label6__c = '010-8321-2428';
        alarm.Label7__c = String.valueOf(inputParam.sendAt); //신규 셋팅 필요
        alarm.Label8__c = 'EX_OrderReceiving_ba';
        alarm.Label9__c = 'N';
        alarm.Label10__c = UserInfo.getUserId();

        insert alarm;

        Database.executeBatch(new EX_OrderReceivingAlarm_ba(), 10);

        Test.stopTest();
    }
}