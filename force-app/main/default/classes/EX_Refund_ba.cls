/**
 * Created by I2MAX.SEUNGHUNAN on 2023-06-18.
 */

public with sharing class EX_Refund_ba implements Database.Batchable<EX_ConsumableUtil.RefundWrapper>, Database.Stateful {
    private final List<ReturnOrder> roList = null;
    private final Map<String, Object> paramMap = null;

    public EX_Refund_ba(List<ReturnOrder> roList, Map<String, Object> paramMap) {
        this.roList = roList;
        this.paramMap = paramMap;
    }
    public Iterable<EX_ConsumableUtil.RefundWrapper> start(Database.BatchableContext param1) {
         Map<String, List<SR_AR_CONFIRM__c>> saleIdArConfirmMap = (Map<String, List<SR_AR_CONFIRM__c>>) paramMap.get('saleIdArConfirmMap');
        // 최종 흑자건
//        SR_AR_CONFIRM__c[] kBlacks = (SR_AR_CONFIRM__c[]) paramMap.get('kBlacks');
        Map<String, List<SR_AR_CONFIRM__c>> saleNoConfirmListMap = new Map<String, List<SR_AR_CONFIRM__c>>();
        List<EX_ConsumableUtil.RefundWrapper> refundWrapperList = new List<EX_ConsumableUtil.RefundWrapper>();
//        List<SR_AR_CONFIRM__c> tmpConfirmList = null;

//        String basisNo = null;
//
//        for (SR_AR_CONFIRM__c arConfirm : kBlacks) {
//            basisNo = arConfirm.SR_PAYMENT_BASIS_ID__r.BASIS_NO__c;
//
//            tmpConfirmList = saleNoConfirmListMap.containsKey(basisNo)
//                    ? saleNoConfirmListMap.get(basisNo)
//                    : new List<SR_AR_CONFIRM__c>();
//
//            tmpConfirmList.add(arConfirm);
//        }
//
//        for (ReturnOrder ro : roList) {
//
//        }

        System.debug('refund RoList : ' + roList);
        System.debug('arConfirm List :: ');

        
        Set<String> roIdSet = new Set<String>();
        Map<String, List<ReturnOrderLineItem>> roIdRoLiListMap = (Map<String, List<ReturnOrderLineItem>>) paramMap.get('roIdRoLiListMap');
        
        try{
            for (ReturnOrder ro : roList) {
                if (ro.ProductRequest.SR_SALE__c != null && saleIdArConfirmMap != null && !saleIdArConfirmMap.isEmpty() && !saleIdArConfirmMap.containsKey(ro.ProductRequest.SR_SALE__c)) {
                    //23 10 31 hyungho.chun 오류 로그 저장
                    throw new FNException('주문번호 : '+ro.Order_Number__c + 'SR_PAYMENT_BASIS_ID__r.SR_SALE_ID__c 가 ' +ro.ProductRequest.SR_SALE__c + ' 인 흑자채권(SR_AR_CONFIRM__c)가 없습니다.');
                }
                if(saleIdArConfirmMap != null && ro.ProductRequest.SR_SALE__c != null && ro.ProductRequest.SALE_Amount__c > ro.ProductRequest.Discount_Amount__c){ //24 01 11 hyungho.chun SALE_Amount__c> Discount_Amount__c 조건추가( 100% 할인은 채권생성안함)
                    List<ReturnOrderLineItem> roLiList = roIdRoLiListMap.get(ro.Id);
                    for (SR_AR_CONFIRM__c arConfirm : saleIdArConfirmMap.get(ro.ProductRequest.SR_SALE__c)) {
                        if(arConfirm.isMig__c && arConfirm.DEPOSIT_TYPE__c == 'D'){ //마이그인경우 하나의 포인트 arConfirm으로 환불로직을 roli갯수만큼 태워야한다
                            for(ReturnOrderLineItem item : roLiList){
                                refundWrapperList.add(new EX_ConsumableUtil.RefundWrapper(ro, arConfirm, item.Order_SEQ__c));    
                            }
                        }else{
                            refundWrapperList.add(new EX_ConsumableUtil.RefundWrapper(ro, arConfirm, null));
                        }
                        
                    }
                }
            }
        }catch(Exception e){
            Map<String,String> errorMap = new Map<String,String>();
            String tempMsg = ' [Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage();
            System.debug('[Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage());

            //23 10 31 hyungho.chun 오류 로그 저장
            errorMap.put('orderNum',roList[0].Order_Number__c);
            //23 12 18 hyungho.chun
            // errorMap.put('orderChannel',roList[0].Order_CHNL_TYPE_Code__c);
            errorMap.put('requestMsg', '[Fail] : 1 건'); // 23 12 18 hyungho.chun 환불 늘 1건씩
            errorMap.put('isSuccess','N');
            errorMap.put('className','EX_Refund_ba');            
            errorMap.put('errorType','ReturnConfirm');
            errorMap.put('recordId',roList[0].Id);
            errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);

            System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
            EX_ConsumableUtil.saveSaleExc(errorMap);
        }

        return refundWrapperList;
    }
    public void execute(Database.BatchableContext param1, List<EX_ConsumableUtil.RefundWrapper> param2) {
        EX_ConsumableUtil.RefundWrapper rw = param2.get(0);
        ReturnOrder ro = rw.getReturnOrder();
        SR_AR_CONFIRM__c arConfirm = rw.getArConfirm();
        Decimal orderSeq = rw.getOrderSeq();

        // List<ReturnOrderLineItem> roliList = [SELECT ProductRequestLineItem.fm_Consumables_PART_DESC_KOR__c FROM ReturnOrderLineItem WHERE ReturnOrderId = :ro.Id];
        // List<EX_Message__c> msgList = new List<EX_Message__c>();
        // List<String> exObjIdList = new List<String>();

        // for (ReturnOrderLineItem roli : roliList) {
        //     EX_Message__c msg = new EX_Message__c();

        //     msg.Label1__c = ro.CONSIGNEE_Name__c;
        //     msg.Label2__c = ro.Order_Number__c;
        //     msg.Label3__c = roli.ProductRequestLineItem.fm_Consumables_PART_DESC_KOR__c;
        //     msgList.add(msg);
        // }

        // insert msgList;

        // for (EX_Message__c msg : msgList) {
        //     exObjIdList.add(msg.Id);
        // }

        // paramMap.put('exObjIdList' , exObjIdList);


        // System.debug('paramMap :: ' + paramMap);
        // System.debug('exObjIdList :: ' + exObjIdList);



        if (arConfirm != null || ro != null) {
            // todo: 적자채권 생성 테스트용 INVOICE_NO
            arConfirm.AR_INVOICE_NO__c = '^d^';
            if(arConfirm.isMig__c && arConfirm.DEPOSIT_TYPE__c == 'D'){ //24 02 29 hyungho.chun 마이그 포인트 흑자채권데이터가 prli(trx) 별로 쪼개져있지않아서 환불호출을 여러번해서 queueable에서 trx및 금액 찾아서 환불
                System.enqueueJob(new EX_ReturnConfirmQueueable(ro, arConfirm, paramMap, orderSeq)); //24 02 29 RefundWrapper를 같은 ro와 같은 arConfirm(마이그 포인트)를 orderSeq별로 여러번호출
            }else{
                System.enqueueJob(new EX_ReturnConfirmQueueable(ro, arConfirm, paramMap, null));
            }            
            
        }
    }

    public void finish(Database.BatchableContext param1) {
    }

}