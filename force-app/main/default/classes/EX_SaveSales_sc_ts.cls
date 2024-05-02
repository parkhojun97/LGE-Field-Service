/****************************************************************************************
 * @filename      : EX_SaveSales_sc_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-25 오후 2:11
 * @group         :
 * @group-content :
 * @description   : EX_SaveSales_sc Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-25       I2max               Create
 ****************************************************************************************/

@IsTest
private class EX_SaveSales_sc_ts {

    @IsTest
    static void test_sc() {
        Test.startTest();
        System.schedule('JOB', '0 30 1 * * ?', new EX_SaveSales_sc());
        EX_SaveSales_sc.runSchedule();
        EX_SaveSales_sc.abortSchedule();
        Test.stopTest();
    }
}