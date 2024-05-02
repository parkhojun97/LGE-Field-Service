/**
 * Created by A80598 on 2023-03-02.
 */

@RestResource(UrlMapping='/v1/api/ma/heroku/InstockNotice')
global with sharing class EX_OnlineInstockNotice {

    /**
     * @AUTHOR I2MAX.SANGHUNYEO
     * @date  2023-03-02
     * @param
     * @description OBS 재입고 알림 요청 수신 및 입고 결과 송신 데이터 관리
     * @return
     */

    global class Input {
        public InputBody Body;
        public Input(){
            Body = new InputBody();
        }
    }

    global class InputBody {
        public InputDetail data;
        public InputBody(){
            data = new InputDetail();
        }
    }

    global class InputDetail{
        public String inputData;
    }

    global class Output {
        public String code;
        public String message;
    }

    @HttpPost
    global static Output doPost() {
        Output objOutput = new Output();
        Input objInput = new Input();
        Savepoint sp = Database.setSavepoint();

        try {
//            RestRequest request = RestContext.request;
//            String requestBody = request.requestBody.toString();
//
//            if (requestBody != null && requestBody != '') {
//                objInput = (Input) JSON.deserializeStrict(requestBody, Input.class);
//                String temp = objInput.Body.data.inputData;
//            }

            objOutput.code = '200';
            objOutput.message = '재입고알림배치 성공.';

            String deptCode = 'PH8002';

            String strQuery = '';
            strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('SI_ONLINE_INSTOCK_NOTICE__c');
            strQuery += ' FROM SI_ONLINE_INSTOCK_NOTICE__c ';
            strQuery += ' WHERE BACK_IF_TRANSFER_FLAG__c = \'N\' '; //SMILE Back Interface 위한 Transfer Flag
            strQuery += ' AND ((RESRV_REQUEST_FLAG__c = \'N\' AND WORK_YN__c = \'N\') OR (RESRV_REQUEST_FLAG__c = \'Y\' AND WORK_YN__c = \'Y\')) ';
            //SELECT 후 조건문에서 처리

            /*strQuery += ' WHERE (RESRV_REQUEST_FLAG__c = \'N\' '; //예약 생성 요청 Flag (재입고알림 서비스 호출 여부)
            strQuery += ' AND WORK_YN__c = \'N\') '; //배치 작업 여부
            strQuery += ' OR (RESRV_REQUEST_FLAG__c = \'Y\' '; //예약 생성 요청 Flag (재입고알림 서비스 호출 여부)
            strQuery += ' AND WORK_YN__c = \'Y\' '; //배치 작업 여부
            strQuery += ' AND SMILE_INSTOCK_FLAG__c != \'Y\') '; //SMILE 입고여부*/

            //RESRV_REQUEST_FLAG__c 예약 생성 요청 Flag : 재입고일람 수신하여 재입고알림 서비스 호출 여부, 재입고알림 서비스 호출시 값이 "N"인 것이 있으면 호출
            //WORK_YN__c 배치 작업 여부 : 재입고알림 서비스 실행 여부
            //SMILE_INSTOCK_FLAG__c SMILE 입고여부 : 사업부 PO에 대한 입고 여부, 요청수량 = 사업부입고수량 이면 "Y"
            //BACK_IF_TRANSFER_FLAG__c SMILE Back Interface 위한 Transfer Flag : 입고 완료 건의 OBS 전송 여부, 전송시 업데이트, 전송대상은 SMILE_INSTOCK_FLAG__c = 'Y' & BACK_IF_TRANSFER_FLAG__c = 'N'

            //System.debug('strQuery >>> ' + strQuery);

            System.debug('strQuery : ' + strQuery);

            List<SI_ONLINE_INSTOCK_NOTICE__c> siOnlineInstockNoticeList = Database.query(strQuery);

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
            }else{//empty check
                objOutput.code = '500';
                objOutput.message = 'reason : 조건에 맞는 SI_ONLINE_INSTOCK_NOTICE__c 값 없습니다.';
                Database.rollback(sp);
            }
        } catch (JSONException je) {
            objOutput.code = '500';
            objOutput.message = 'reason:' + je.getMessage();
            Database.rollback(sp);
        } catch (NullPointerException ne) {
            objOutput.code = '500';
            objOutput.message = ' 조회된 값이 없습니다.  ' + ne.getMessage();
            Database.rollback(sp);
        } catch (Exception e) {
            objOutput.code = '500';
            objOutput.message = e.getMessage();
            Database.rollback(sp);
        }
        return objOutput;
    }
}