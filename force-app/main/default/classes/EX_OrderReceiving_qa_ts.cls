/**
 * @description       : 
 * @author            : hyungho.chun@dkbmc.com
 * @group             : 
 * @last modified on  : 02-26-2024
 * @last modified by  : hyungho.chun@dkbmc.com
**/
@IsTest
public with sharing class EX_OrderReceiving_qa_ts {
    public EX_OrderReceiving_qa_ts() {

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

        //24 02 26 hyungho.chun constructor 수정
        Set<String> phoneSet = new Set<String>();
        phoneSet.add('010-8321-2428');
        EX_OrderReceiving_qa q = new EX_OrderReceiving_qa(JSON.serialize(inputParam),phoneSet);
        // EX_OrderReceiving_qa q = new EX_OrderReceiving_qa(JSON.serialize(inputParam),'010-8321-2428');
        System.enqueueJob(q);

        Test.stopTest();
    }


}