/**
 * Created by A82371 on 2023-04-17.
 */

@IsTest
private class EX_OnlineInstockNotice_ts {


    @IsTest
    static void test01() {
        Test.startTest();
        TriggerHandler.bypass('SM_DIV_trHandler');
        EX_TestDataUtil.getDIV(true);
        TriggerHandler.clearAllBypasses();
        EX_TestDataUtil.getOnlineInStockNotice(true);
        String deptCode = EX_TestDataUtil.dept.DEPT_CODE__c;
        EX_TestDataUtil.baseLocation = null;
        EX_TestDataUtil.getLocation(true, 'DIV', deptCode);
        EX_OnlineInstockNotice.doPost();

        EX_TestDataUtil.onlineInStockNotice.WORK_YN__c = 'Y';
        EX_TestDataUtil.onlineInStockNotice.RESRV_REQUEST_FLAG__c = 'Y';
        update EX_TestDataUtil.onlineInStockNotice;
        EX_OnlineInstockNotice.doPost();
        Test.stopTest();
    }

}