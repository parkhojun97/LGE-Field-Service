/****************************************************************************************
 * @filename      : EX_OnlineInstockNotice_ba_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-16 오후 1:17
 * @group         :
 * @group-content :
 * @description   : EX_OnlineInstockNotice_ba Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-16       I2max               Create
 ****************************************************************************************/

@IsTest
private class EX_OnlineInstockNotice_ba_ts {
    @TestSetup
    static void setup() {
        TriggerHandler.clearAllBypasses();
        TriggerHandler.bypass('SM_DIV_trHandler');
        EX_TestDataUtil.getDIV(true);
        EX_TestDataUtil.getOnlineInStockNotice(true);
        EX_TestDataUtil.getLocation(true, 'DIV', EX_TestDataUtil.dept.DEPT_CODE__c);
    }

    @IsTest
    static void test_batch01() {
        SI_ONLINE_INSTOCK_NOTICE__c notice = [select id,WORK_YN__c,RESRV_REQUEST_FLAG__c from SI_ONLINE_INSTOCK_NOTICE__c LIMIT 1];
        notice.WORK_YN__c = 'Y';
        notice.RESRV_REQUEST_FLAG__c = 'Y';
        update notice;
        Test.startTest();
        Database.executeBatch(new EX_OnlineInstockNotice_ba(), 1);
        Test.stopTest();
    }

    @IsTest
    static void test_batch02() {
        SI_ONLINE_INSTOCK_NOTICE__c notice = [select id,WORK_YN__c,RESRV_REQUEST_FLAG__c from SI_ONLINE_INSTOCK_NOTICE__c LIMIT 1];
        notice.WORK_YN__c = 'N';
        notice.RESRV_REQUEST_FLAG__c = 'N';
        update notice;
        Test.startTest();
        Database.executeBatch(new EX_OnlineInstockNotice_ba(), 1);
        Test.stopTest();
    }
}