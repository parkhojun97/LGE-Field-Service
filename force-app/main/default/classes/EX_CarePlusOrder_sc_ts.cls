/****************************************************************************************
 * @filename      : EX_CarePlusOrder_sc_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-16 오후 1:17
 * @group         :
 * @group-content :
 * @description   : EX_CarePlusOrder_sc Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-16       I2max               Create
 ****************************************************************************************/

@IsTest
private class EX_CarePlusOrder_sc_ts {
    @IsTest
    static void test_sc() {
        Test.startTest();
        System.schedule('JOB', '0 30 1 * * ?', new EX_CarePlusOrder_sc());
        try{
            EX_CarePlusOrder_sc.runSchedule(null);
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        EX_CarePlusOrder_sc.abortSchedule();
        Test.stopTest();
    }
}