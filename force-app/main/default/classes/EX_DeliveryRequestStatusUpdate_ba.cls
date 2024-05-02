// 라인아이템 중 결제완료에서 예약상태가 입고완료일 경우 상품준비중 상태로 변경되어야 하는데 안바뀐 애들이 있다면 상품준비중 상태로 업데이트
// 로그 남기기 : 대상건이 몇건이고 성공건 에러건이 몇건인지, 에러 발생 시 exception 기록 남기고 database.SaveResult로 초기로 돌림
// 1시간에 1번씩
public with sharing class EX_DeliveryRequestStatusUpdate_ba implements Database.Batchable<sObject>, Database.Stateful {

    public EX_DeliveryRequestStatusUpdate_ba() {}

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('속도측정 -------------------------------------------------- EX_DeliveryRequestStatusUpdate_ba 시작 '+ System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

        String query = '';

        query += 'SELECT Id, Order_Number__c, Consumables_Order_Status__c, Appointment_Status__c';
        query += ' FROM ProductRequestLineItem ';
        query += ' WHERE Appointment_Status__c = \'입고완료\' AND Consumables_Order_Status__c = \'002\' AND Order_CHNL_TYPE_Code__c = \'V\'';

        System.debug('query :: '+query);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<ProductRequestLineItem> prliList) {
        System.debug('배치 시작부분 piList  :: '+prliList);
        
        Map<String,String> orderMap = new Map<String,String>();
        List<ProductRequestLineItem> prliLists = new List<ProductRequestLineItem>();
        List<String> prliIds = new List<String>();

        if(prliList.size() > 0){
            for(ProductRequestLineItem prli : prliList){
                prli.Consumables_Order_Status__c = '006';
                orderMap.put(prli.Id, prli.Order_Number__c);
                prliIds.add(prli.Id);
                prliLists.add(prli);
            }
        }
        
        Database.SaveResult[] srList = Database.update(prliLists, false);
        
        SR_ONLINE_AUTO_SALE_EXC__c exc = new SR_ONLINE_AUTO_SALE_EXC__c();
        exc.RequestMessage__c = '';

        for(Database.SaveResult sr : srList){
            if (sr.isSuccess()) {
                System.debug('Successfully updated Consumables_Order_Status. ID: ' + sr.getId());
                exc.RequestMessage__c += 'OrderNumber : ' + orderMap.get(sr.getId()) + ' / ' + 'ProductRequestLineItem ID : ' + sr.getId() + '\n';
                exc.Input_date__c = System.now();
            }
            else {
                for(Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');                    
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    System.debug('error field: ' + err.getFields());
                }
            }
        }
        System.debug('exc >>>' + exc);
        insert exc;
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('속도측정 -------------------------------------------------- EX_DeliveryRequestStatusUpdate_ba 끝 '+ System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
    }
}