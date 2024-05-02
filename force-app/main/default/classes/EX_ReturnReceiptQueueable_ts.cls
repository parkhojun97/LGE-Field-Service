/****************************************************************************************
 * @filename      : EX_ReturnReceiptQueueable_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-25 오후 2:11
 * @group         :
 * @group-content :
 * @description   : EX_ReturnReceiptQueueable Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-25       I2max               Create
 ****************************************************************************************/

@IsTest
private class EX_ReturnReceiptQueueable_ts {
    @TestSetup
    static void testSetup() {
        EX_TestDataUtil.getReturnOrder(true);
        // insert new TemplateMgmt__c(Content_c__c = 'Content', Title__c = 'Title',TemplateCode__c = 'SVC_LGE_MACN_030');
        insert new TemplateMgmt__c(Content_c__c = 'Content', Title__c = 'Title',TemplateCode__c = 'SVC_LGE_MACN_030_1'); //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
        insert new EX_Message__c(Label1__c = 'TEST1234', Label2__c = '테스트 상품명', Label3__c = '3개', Label4__c = '010-7748-6993');
        String templateMgmtId = [SELECT Id FROM TemplateMgmt__c LIMIT 1].Id;
        insert new TemplateParams__c(TemplateMgmt__c = templateMgmtId);
    }

    @IsTest
    static void test_Queueable() {
        ReturnOrder returnOrder = [select id from ReturnOrder Limit 1];
        EX_Message__c messageObject = [SELECT Id, Label1__c, Label2__c, Label3__c, Label4__c FROM EX_Message__c];
        Map<String, List<EX_Message__c>> roIdKakaoMessageListMap = new Map<String, List<EX_Message__c>>{returnOrder.Id => new List<EX_Message__c>{messageObject}};
        List<ReturnOrder> roList = new List<ReturnOrder>();
        roList.add(returnOrder);

        
        Test.startTest();
        EX_ReturnReceiptQueueable q = new EX_ReturnReceiptQueueable(roList, roIdKakaoMessageListMap);
        System.enqueueJob(q);
        Test.stopTest();
    }
}