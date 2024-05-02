/**
 * Created by A80598 on 2023-05-16.
 */

public with sharing class EX_OnlineInstockNotice_ba implements Database.Batchable<sObject>{

    public Database.QueryLocator start(Database.BatchableContext param1) {
        String strQuery = '';
        strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('SI_ONLINE_INSTOCK_NOTICE__c');
        strQuery += ' FROM SI_ONLINE_INSTOCK_NOTICE__c ';
        strQuery += ' WHERE BACK_IF_TRANSFER_FLAG__c = \'N\' '; //SMILE Back Interface 위한 Transfer Flag
        strQuery += ' AND ((RESRV_REQUEST_FLAG__c = \'N\' AND WORK_YN__c = \'N\') OR (RESRV_REQUEST_FLAG__c = \'Y\' AND WORK_YN__c = \'Y\')) ';

        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext param1, List<SI_ONLINE_INSTOCK_NOTICE__c> siOnlineInstockNoticeList) {
        String deptCode = 'PH8002';
        Savepoint sp = Database.setSavepoint();
        try {
            if(!siOnlineInstockNoticeList.isEmpty()){
                System.debug('SI_ONLINE_INSTOCK_NOTICE__c Total : ' + siOnlineInstockNoticeList.size());
                Integer nn = 0;
                Integer yy = 0;
                Integer yyAdjust = 0;
                Integer nothing = 0;

                List<String> gscsOrderNoList = new List<String>();
                for(SI_ONLINE_INSTOCK_NOTICE__c siIN : siOnlineInstockNoticeList){
                    if(siIN.NOTICE_ID__c != null && !siIN.NOTICE_ID__c.equals('')){
                        gscsOrderNoList.add(String.valueOf(siIN.NOTICE_ID__c));
                    }
                }

                List<ProductRequestLineItem> lineItemList = new List<ProductRequestLineItem>();
                if(!gscsOrderNoList.isEmpty()){
                    String query = '';
                    query += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
                    query += ' ,Product2.Name, Product2.PART_DESC_KOR__c ';
                    query += ' FROM ProductRequestLineItem ';
                    query += ' WHERE GSCS_Order_Number__c IN (';
                    Integer z = 0;
                    for(String gscsOrderNo : gscsOrderNoList){
                        if(z == 0){
                            query += '\'' + gscsOrderNo + '\'';
                        }else{
                            query += ',\'' + gscsOrderNo + '\'';
                        }
                        z++;
                    }
                    query += ') ';

                    lineItemList = Database.query(query);
                }

                List<SI_ONLINE_INSTOCK_NOTICE__c> listUpdateSiNotice = new List<SI_ONLINE_INSTOCK_NOTICE__c>();
                List<Map<String, Object>> rsrvCancelMapList = new List<Map<String, Object>>();
                List<Map<String, Object>> mapItemList = new List<Map<String, Object>>();

                for (SI_ONLINE_INSTOCK_NOTICE__c lData : siOnlineInstockNoticeList) {
                    Map<String, Object> rsrvCancelMap = new Map<String, Object>();
                    if (lData.RESRV_REQUEST_FLAG__c != null && lData.RESRV_REQUEST_FLAG__c.equals('N') && lData.WORK_YN__c != null && lData.WORK_YN__c.equals('N')) {
                        nn++;
                        //예약 생성 요청 Flag = 'N' & 배치 작업 여부 = 'N'
                        //FS_RequestPartsController > doReserveRent 참고

                        Map<String, Object> rtnMap = new Map<String, Object>();
                        Map<String, Object> mapItem = new Map<String, Object>();
                        mapItem.put('oriPrId', ''); //원주문 ProductRequestId
                        mapItem.put('oriPrliId', ''); //원주문 ProductRequestLineItemId
                        mapItem.put('deptCode', deptCode);
                        mapItem.put('partNo', lData.PART_NO__c);
                        mapItem.put('req_qty', lData.REQ_QTY__c);
                        mapItem.put('div_code', lData.DIV_CODE__c);
                        mapItemList.add(mapItem);

                        /** 재입고알림 서비스 실행여부 업데이트 */
                        //RESRV_REQUEST_FLAG__c(예약 생성 요청 Flag) 재입고일람 수신하여 재입고알림 서비스 호출 여부, 재입고알림 서비스 호출시 값이 "N"인 것이 있으면 호출
                        //WORK_YN__c(배치작업 여부) 재입고알림 서비스 실행 여부
                        SI_ONLINE_INSTOCK_NOTICE__c siNotice = new SI_ONLINE_INSTOCK_NOTICE__c();
                        siNotice.Id = lData.Id;
                        siNotice.RESRV_REQUEST_FLAG__c = 'Y';
                        siNotice.RESRV_REQUEST_DATE__c = System.now();
                        siNotice.WORK_YN__c = 'Y';
                        siNotice.WORK_DATE__c = System.now();
                        listUpdateSiNotice.add(siNotice);
                    } else if (lData.RESRV_REQUEST_FLAG__c != null && lData.RESRV_REQUEST_FLAG__c.equals('Y') && lData.WORK_YN__c != null && lData.WORK_YN__c.equals('Y')) {
                        yy++;
                        //예약 생성 요청 Flag = 'Y' & 배치 작업 여부 = 'Y'
                        if(lData.NOTICE_ID__c != null && !lData.NOTICE_ID__c.equals('')){
                            /** 모두입고 여부 */
                            List<ProductRequestLineItem> prliList = new List<ProductRequestLineItem>();
                            if(!lineItemList.isEmpty()){
                                for(ProductRequestLineItem prli : lineItemList){
                                    if(lData.NOTICE_ID__c.equals(prli.GSCS_Order_Number__c)){
                                        prliList.add(prli);
                                    }
                                }
                            }

                            for (ProductRequestLineItem prli : prliList) {
                                //사업부입고수량 = 요청수량 확인 ProductRequestLineItem > ENDP_RSV_Quantity__c = QuantityRequested
                                if (prli.ENDP_RSV_Quantity__c != null && prli.QuantityRequested != null && prli.ENDP_RSV_Quantity__c == prli.QuantityRequested) {
                                    yyAdjust++;
                                    /** 약속취소(예약취소)(약속정리) */
                                    //EX_RsrvUtil.CANCEL_RESRV(prli, 'AE'); //'AE' : 사업부약속취소(재입고알림)
                                    rsrvCancelMap.put('ProductRequestLineItem',prli);
                                    rsrvCancelMap.put('code','AE');
                                    rsrvCancelMapList.add(rsrvCancelMap);
                                    /** 입고완료여부 업데이트 */
//                                    update new SI_ONLINE_INSTOCK_NOTICE__c(
//                                            Id = lData.Id,
//                                            SMILE_INSTOCK_FLAG__c = 'Y',
//                                            SMILE_INSTOCK_DATE__c = System.now()
//                                    );
                                    SI_ONLINE_INSTOCK_NOTICE__c siNotice = new SI_ONLINE_INSTOCK_NOTICE__c();
                                    siNotice.Id = lData.Id;
                                    siNotice.SMILE_INSTOCK_FLAG__c = 'Y';
                                    siNotice.SMILE_INSTOCK_DATE__c = System.now();
                                    listUpdateSiNotice.add(siNotice);

                                    /** 입고완료건 확인 (Heroku) */
                                    /** 입고일시 송신 (Heroku) */
                                    /** 고객 알림톡 전송 (OBS: 재입고 알림) (Heroku) */
                                }
                            } //for(ProductRequestLineItem)
                        }
                    }else {
                        nothing++;
                    } //예약 생성 요청 Flag  & 배치 작업 여부 확인
                }//for(SI_ONLINE_INSTOCK_NOTICE__c)
                EX_RsrvUtil.RESRV_MODULE(mapItemList);
                if(!rsrvCancelMapList.isEmpty()){
                    EX_RsrvUtil.CANCEL_RESRV_MULTI(rsrvCancelMapList);
                }
                if(!listUpdateSiNotice.isEmpty()){
                    update listUpdateSiNotice;
                    System.debug('Update SI_ONLINE_INSTOCK_NOTICE__c TOTAL : ' + listUpdateSiNotice.size());
                }

                System.debug('약속생성건 Total : ' + nn);
                System.debug('전량입고확인건 Total : ' + yy);
                System.debug('전량입고 후 약속정리건 Total : ' + yyAdjust);
                System.debug('작업불필요건 Total : ' + nothing);
            }
        }catch (JSONException je){
            System.debug('*** je.getMessage: ' + je.getMessage());
            System.debug('*** je.getLine -> ' + je.getLineNumber());
            Database.rollback(sp);
        } catch (NullPointerException ne){
            System.debug('*** ne.getMessage: ' + ne.getMessage());
            System.debug('*** ne.getLine -> ' + ne.getLineNumber());
            Database.rollback(sp);
        } catch (Exception e) {
            System.debug('*** e.getMessage: ' + e.getMessage());
            System.debug('*** e.getLine -> ' + e.getLineNumber());
            Database.rollback(sp);
        }
    }

    public void finish(Database.BatchableContext param1) {
        System.debug('EX_OnlineInstockNotice_ba finish');
    }


}