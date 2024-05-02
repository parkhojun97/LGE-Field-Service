/**
 * Created by I2MAX.SEUNGHUNAN on 2023-05-11.
 */

public without sharing class EX_SaveSales_ba implements Database.Batchable<SObject>, Database.Stateful {
    public Map<String, Object> paramMap = new Map<String, Object>();
    public List<ProductRequest> prList = new List<productRequest>();
    public Set<String> headerIds = new Set<String>(); //24 03 11 hyungoh.chun 성공한 headerId(소모품택배채권생성 배치 실행)
    public Iterable<SObject> start(Database.BatchableContext param1) {
        System.debug('batch start : ' + System.now());
        // LIMIT 고려

        AsyncApexJob curJob = [
                SELECT Id, ApexClass.Name, Status
                FROM AsyncApexJob
                WHERE Id=:param1.getJobId()
        ][0];
        String batchClassName = curJob.ApexClass.Name;
        List<AsyncApexJob> apexJobList = [
                SELECT Id, Status
                FROM AsyncApexJob
                WHERE Id !=: param1.getJobId()
                AND ApexClass.Name =: batchClassName
        ];

        // 같은 이름의 클래스가 최소 큐에 들어갔는지 Check
        for (AsyncApexJob apexJob : apexJobList) {
            String otherJobStatus = apexJob.Status;
            if (otherJobStatus.equals('Holding')
                    && otherJobStatus.equals('Queued')
                    && otherJobStatus.equals('Preparing')
                    && otherJobStatus.equals('Processing')) {
                return null;
            }
        }
        paramMap = EX_ConsumableUtil.preWorkSaveSales(null);

        prList = (List<ProductRequest>)paramMap.get('prList');

        return prList;
    }

    public void execute(Database.BatchableContext param1, List<ProductRequest> prList) {
        if(prList.size()>0){
            EX_ConsumableUtil.doSaveSales2(paramMap, prList);
            //24 03 11 hyungoh.chun 성공한 headerId(소모품택배채권생성 배치 실행)
            Set<String> tempHeadIdSet = (Set<String>)paramMap.get('headerIds');
            if(tempHeadIdSet.size()>0){
                for(String item : tempHeadIdSet){
                    headerIds.add(item);
                }
            }
        }
    }

    public void finish(Database.BatchableContext param1) {
        //23 12 04 hyungho.chun EX_ConsumableUtil.doSaveSales2안에 화면/배치 구분하는부분 그냥 다 묶어서 실행해야할수도!?
        // if(prList.size()>0){
        //     FNManager.BlackRecorder recorder = (FNManager.BlackRecorder) paramMap.get('blackRecorder');
        //     if(!Test.isRunningTest()) recorder.record();
        // }
        //24 03 11 hyungoh.chun 성공한 headerId(소모품택배채권생성 배치 실행)
        if(headerIds.size()>0){
            FNManager.BlackRecorder recorder = FNManager.black();
            for(String item : headerIds){
                recorder.append(item);
            }
            if(!Test.isRunningTest()) recorder.record();
        }


    }
}