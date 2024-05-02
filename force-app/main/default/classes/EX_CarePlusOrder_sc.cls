/**
 * Created by A80598 on 2023-05-16.
 */

public with sharing class EX_CarePlusOrder_sc implements Schedulable {
    // Schedule 등록 배치명
    private static String batchName = 'EX_CarePlusOrder_ba';
    // Schedule Cron Expression (매일 09시~18시 매시 10분/40분)
    private static String batchCron1 = '0 10 9-18 * * ? *';
    private static String batchCron2 = '0 40 9-18 * * ? *';
    // Batch 수행 Size
    private static Integer batchSize = 100;

    // public EX_CarePlusOrder_sc(Integer bSize){
    //     if(bSize != null){
    //         batchSize = bSize;
    //     }
    // }

    /**
     * 배치 Schedule 등록
     * EX_CarePlusOrder_sc.runSchedule();
     */
    public static void runSchedule(Integer batchSize) {
        // System.schedule(batchName+'10', batchCron1, new EX_CarePlusOrder_sc(batchSize));
        // System.schedule(batchName+'40', batchCron2, new EX_CarePlusOrder_sc(batchSize));
        System.schedule(batchName+'10', batchCron1, new EX_CarePlusOrder_sc());
        System.schedule(batchName+'40', batchCron2, new EX_CarePlusOrder_sc());
    }

    /**
     * 배치 실행 멤버 함수(override)
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new EX_CarePlusOrder_ba(batchSize), batchSize);
    }

    /**
     *  배치 Schedule 삭제
     *  EX_CarePlusOrder_sc.abortSchedule();
     */
    public static void abortSchedule() {
        List<String> batchNameList = new List<String>();
        batchNameList.add(batchName+'10');
        batchNameList.add(batchName+'40');
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name IN :batchNameList]) {
            if(!Test.isRunningTest())   System.abortJob(t.Id);
        }
    }
}