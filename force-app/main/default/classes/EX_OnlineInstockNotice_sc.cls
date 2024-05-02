/**
 * Created by A80598 on 2023-05-16.
 */

public with sharing class EX_OnlineInstockNotice_sc implements Schedulable {
    // Schedule 등록 배치명
    private static String batchName = 'EX_OnlineInstockNotice';
    // Schedule Cron Expression (매일 07시~20시 매시 10분) 실행
    private static String batchCron = '0 10 7-20 * * ? *';
    // Batch 수행 Size
    private static Integer batchSize = 100;

    /**
     * 배치 Schedule 등록
     * EX_OnlineInstockNotice_sc.runSchedule();
     */
    public static void runSchedule() {
        System.schedule(batchName, batchCron, new EX_OnlineInstockNotice_sc());
    }

    /**
     * 배치 실행 멤버 함수(override)
     *
     * @param SC : SchedulableContext
     */
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new EX_OnlineInstockNotice_ba(), batchSize);
    }

    /**
     *  배치 Schedule 삭제
     *  EX_OnlineInstockNotice_sc.abortSchedule();
     */
    public static void abortSchedule() {
        for (CronTrigger t : [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :batchName]) {
            if(!Test.isRunningTest())   System.abortJob(t.Id);
        }
    }
}