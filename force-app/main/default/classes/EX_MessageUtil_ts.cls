/**
 * Created by MS on 2023-04-21.
 */

@IsTest
private class EX_MessageUtil_ts {
    @IsTest
    static void testBehavior() {
        Test.startTest();

        TemplateMgmt__c tmgt = new TemplateMgmt__c();
        tmgt.Content_c__c = 'teststests';
        tmgt.Title__c = 'testsetse';
        // tmgt.TemplateCode__c = 'SVC_LGE_MACN_011';
        tmgt.TemplateCode__c = 'SVC_LGE_MACN_011_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정

        TemplateMgmt__c tmgt2 = tmgt.clone();
        tmgt2.TemplateCode__c = 'SVC_LGE_MACN_014';

        insert new List<TemplateMgmt__c> {tmgt, tmgt2};

        TemplateParams__c tprm = new TemplateParams__c();
        tprm.TemplateMgmt__c = tmgt.Id;
        insert new List<TemplateParams__c>{ new TemplateParams__c(TemplateMgmt__c = tmgt.Id), new TemplateParams__c(TemplateMgmt__c = tmgt2.Id) };

        EX_Message__c exMessage = new EX_Message__c();
        exMessage.Label1__c = 'test';
        insert exMessage;


        EX_MessageUtil.getRelatedData(tmgt.TemplateCode__c,exMessage.Id);
        try{
            EX_MessageUtil.sendKaKaoMessage(tmgt2.TemplateCode__c,exMessage.Id, '01012345678');
        }catch(Exception e){
            System.debug(e);
        }
        try{
            EX_MessageUtil.sendKaKaoMessage(tmgt.TemplateCode__c,exMessage.Id, '01012345678');
        }catch(Exception e){
            System.debug(e);
        }
        EX_MessageUtil.isBusinessHours();
        EX_MessageUtil.getNearSendDatetime();

        Map<String,String> errorMap = new Map<String,String>();

        errorMap.put('className', 'testClass');
        errorMap.put('tempErrorMsg','test error msg');

        EX_MessageUtil.sendSMSandEmail(errorMap);


        Test.stopTest();
    }
}