/****************************************************************************************
 * @filename      : EX_SaveSales_sc
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-25 오후 2:11
 * @group         :
 * @group-content :
 * @description   : EX_SaveSales_sc
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-25       I2max               Create
 ****************************************************************************************/
  
public with sharing class EX_SaveSales_sc implements Schedulable {
    // Schedule 등록 배치명
    private static String batchName = 'EX_SaveSales';
    // Schedule Cron Expression(매시 30분)
    private static String batchCron = '0 15 * * * ? *';
    // Batch 수행 Size
    private static Integer batchSize = Integer.valueOf(System.Label.EX_saveSalesBatchSize); //24 03 05 hyungho.chun 사이즈 조절용 커스텀라벨

    /**
     * 배치 Schedule 등록
     * EX_SaveSales_sc.runSchedule();
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new EX_SaveSales_sc());
    }

    /**
     * 배치 실행 멤버 함수(override)
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new EX_SaveSales_ba(), batchSize);
    }

    /**
     *  배치 Schedule 삭제
     *  EX_SaveSales_sc.abortSchedule();
     */
    // 23.08.09 PHJ
    public static void abortSchedule() {
        List<CronTrigger> ctList = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName];
        
        if(ctList.size() != NULL){
            for (CronTrigger t : ctList) {
                if(!Test.isRunningTest())   System.abortJob(t.Id);
            }
        }
    }
    // public static void abortSchedule() {
    //     for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
    //         if(!Test.isRunningTest())   System.abortJob(t.Id);
    //     }
    // }
}