/**
 * Created by JIEUNSONG on 2023-05-16.
 * OBS 주문상태 전송 결과 업데이트
 * 파라미터 : status, orderNo, orderSeq
 *
 */

@RestResource(UrlMapping = '/v1/api/ma/heroku/obsUpdateIfSendDate')
global with sharing class EX_obsUpdateIfSendDate {
    // =============================================================
    // 인터페이스 Id 값 설정 (SFDC에 ifId를 저장하여 사용)
    // =============================================================
    private static final String IFID    = 'obsUpdateIfSendDate';
    private static final String SUCCESS = 'SUCCESS';
    private static final String ERROR   = 'ERROR';

//    global class Input{
//        public InputBody request;
//        public Input(){
//            request = new InputBody();
//        }
//    }

    global class InputBody{
        public List<InputData> data;
        public InputBody(){
            data = new List<InputData>();
        }
    }

    global class InputData{
        public String orderNo;  // 주문번호(OBS주문번호)
        public String orderSeq; // 주문시퀀스(OBS ITEM LINE ID)
        public String status; // 구분코드(shipment :출하완료, delivery : 배송완료, return:반품완료)
    }

    global class Output {
        //public OutputBody response;
        public ResultMsg result;
    }

//    global class OutputBody {
//        public List<OutputData> records;
//        public OutputBody() {
//            records = new List<OutputData>();
//        }
//    }

    global class OutputData {
        //리턴은 어떻게 해주면 될까
    }

    global class ResultMsg {
        public String rstType; //처리결과
        public String rstMsg;
    }

    @HttpPost
    global static Output doPost(){
        Savepoint sp = Database.setSavepoint();
        String requestBody = RestContext.request.requestBody.toString();
        String requestHeader = RestContext.request.headers.toString();

        // 로그 시작 (IF_Master에 등록되어 있으며, 로그 적재 여부가 true일 경우에만 쌓임)
        IFUtil ifUtil               = new IFUtil(IFID);
        IFUtil.LogWrapper log       = new IFUtil.LogWrapper(IFID, requestHeader, requestBody);

        System.debug('requestBody :: ' + requestBody);

        //Input objInput                  = new Input();
        Output objOutput                = new Output();
        InputBody objInputBody          = new InputBody();
        ResultMsg result                = new ResultMsg();

        try{
//            objInput = (Input)JSON.deserialize(requestBody, Input.class);
//            objInputBody = objInput.request;
            objInputBody = (InputBody)JSON.deserialize(requestBody, InputBody.class);
            String pOrderNo;
            Decimal pOrderSeq;
            String pStatus; //상태코드

            List<map<String, Object>> paramMapList = new List<Map<String, Object>>();

            if(!objInputBody.data.isEmpty()){
                for(InputData inputData : objInputBody.data){
                    Map<String, Object> paramMap = new Map<String, Object>();
                    if(inputData.orderNo!=null && !inputData.orderNo.equals('')){
                        pOrderNo = inputData.orderNo;
                        System.debug('pOrderNo :: ' + pOrderNo);
                        paramMap.put('pOrderNo',pOrderNo);
                    }
                    if(inputData.orderSeq!=null && !inputData.orderSeq.equals('')){
                        pOrderSeq = Integer.valueOf(inputData.orderSeq);
                        System.debug('pOrderSeq :: ' + pOrderSeq);
                        paramMap.put('pOrderSeq',pOrderSeq);
                    }
                    if(inputData.status!=null && !inputData.status.equals('')){
                        if(inputData.status=='shipment'){
                            // '030' -- 배송중
                            pStatus ='030';
                        } else if (inputData.status=='delivery'){
                            // '070' -- 배송완료
                            pStatus ='070';
                        } else if (inputData.status=='return') {
                            // '120' -- 반품확정
                            pStatus ='120';
                        }else{
                            pStatus ='';
                        }
                        if(pStatus != null && !pStatus.equals('')){
                            paramMap.put('pStatus',pStatus);
                        }
                        System.debug('pStatus :: ' + pStatus);
                    }
                    paramMapList.add(paramMap);
                }

                List<String> p030OrderNoList = new List<String>();
                List<Integer> p030OrderSeq = new List<Integer>();
                List<String> p070OrderNoList = new List<String>();
                List<Integer> p070OrderSeq = new List<Integer>();
                List<String> p120OrderNoList = new List<String>();
                List<Integer> p120OrderSeq = new List<Integer>();

                if(!paramMapList.isEmpty()){
                    for(Map<String, Object> paramMap : paramMapList){
                        if(paramMap.get('pOrderNo') != null && paramMap.get('pOrderSeq') != null && paramMap.get('pStatus') != null){
                            if(String.valueOf(paramMap.get('pStatus')) == '030'){
                                p030OrderNoList.add(String.valueOf(paramMap.get('pOrderNo')));
                                p030OrderSeq.add(Integer.valueOf(paramMap.get('pOrderSeq')));
                            }else if(String.valueOf(paramMap.get('pStatus')) == '070'){
                                p070OrderNoList.add(String.valueOf(paramMap.get('pOrderNo')));
                                p070OrderSeq.add(Integer.valueOf(paramMap.get('pOrderSeq')));
                            }else if(String.valueOf(paramMap.get('pStatus')) == '120'){
                                p120OrderNoList.add(String.valueOf(paramMap.get('pOrderNo')));
                                p120OrderSeq.add(Integer.valueOf(paramMap.get('pOrderSeq')));
                            }
                        }
                    }
                }

                if(!p030OrderNoList.isEmpty()){System.debug('p030OrderNoList : ' + p030OrderNoList);}
                if(!p030OrderSeq.isEmpty()){System.debug('p030OrderSeq : ' + p030OrderSeq);}
                if(!p070OrderNoList.isEmpty()){System.debug('p070OrderNoList : ' + p070OrderNoList);}
                if(!p070OrderSeq.isEmpty()){System.debug('p070OrderSeq : ' + p070OrderSeq);}
                if(!p120OrderNoList.isEmpty()){System.debug('p120OrderNoList : ' + p120OrderNoList);}
                if(!p120OrderSeq.isEmpty()){System.debug('p120OrderSeq : ' + p120OrderSeq);}

                List<ProductRequestLineitem> updatePRLIList030 = new List<ProductRequestLineItem>();
                List<ProductRequestLineitem> updatePRLIList070 = new List<ProductRequestLineItem>();
                List<ReturnOrderLineItem> updateROLIList120 = new List<ReturnOrderLineItem>();

                List<ProductRequestLineItem> prliList_030 = new List<ProductRequestLineItem>();
                String strPRLIquery ='';
                strPRLIquery += ' SELECT Id, Order_Number__c, Order_SEQ__c, Consumables_Order_Status__c, SHIPPED_IF_SEND_DATE__c, Order_CHNL_TYPE_Code__c ';
                strPRLIquery += ' FROM ProductRequestLineItem';
                strPRLIquery += ' WHERE Order_Number__c IN : p030OrderNoList ';
                strPRLIquery += ' AND Order_SEQ__c IN :p030OrderSeq ';
                strPRLIquery += ' AND Order_CHNL_TYPE_Code__c = \'B\' '; //--B LGE.COM
                strPRLIquery += ' AND Consumables_Order_Status__c = \'030\' ';
                strPRLIquery += ' AND SHIPPED_IF_SEND_DATE__c =NULL ';
                prliList_030 = Database.query(strPRLIquery);

                System.debug('조회된 030 ProductRequestLineItem :: ' + prliList_030);

                //출하완료(shipment)일 경우 => 출하완료전송일자 (SHIPPED_IF_SEND_DATE__c)를 현재시각으로 업데이트
                if(!prliList_030.isEmpty()){
                    for(productRequestLineItem prli : prliList_030){
                        if(!paramMapList.isEmpty()) {
                            for (Map<String, Object> paramMap : paramMapList) {
                                if(paramMap.get('pOrderNo') != null && paramMap.get('pOrderSeq') != null && paramMap.get('pStatus') != null){
                                    if(String.valueOf(paramMap.get('pStatus')) == '030' && String.valueOf(paramMap.get('pOrderNo')) == prli.Order_Number__c && Integer.valueOf(paramMap.get('pOrderSeq')) == prli.Order_SEQ__c){
                                        prli.SHIPPED_IF_SEND_DATE__c = System.now();
                                        updatePRLIList030.add(prli);
                                    }
                                }
                            }
                        }
                    }
                }

                List<ProductRequestLineItem> prliList070 = new List<ProductRequestLineItem>();
                strPRLIquery = '';
                strPRLIquery += ' SELECT Id, Order_Number__c, Order_SEQ__c, Consumables_Order_Status__c, SHIPPED_IF_SEND_DATE__c, Order_CHNL_TYPE_Code__c ';
                strPRLIquery += ' FROM ProductRequestLineItem';
                strPRLIquery += ' WHERE Order_Number__c IN :p070OrderNoList ';
                strPRLIquery += ' AND Order_SEQ__c IN :p070OrderSeq ';
                strPRLIquery += ' AND Order_CHNL_TYPE_Code__c = \'B\' '; //--B LGE.COM
                strPRLIquery += ' AND Consumables_Order_Status__c = \'070\' ';
                strPRLIquery += ' AND DELIVERY_IF_SEND_DATE__c =NULL ';

                prliList070 = Database.query(strPRLIquery);

                System.debug('조회된 070 ProductRequestLineItem :: ' + prliList070);

                //배송완료일 경우 => 배송완료전송일자 (DELIVERY_IF_SEND_DATE__c)를 현재시각으로 업데이트
                if(!prliList070.isEmpty()){
                    for(productRequestLineItem prli : prliList070){
                        if(!paramMapList.isEmpty()) {
                            for (Map<String, Object> paramMap : paramMapList) {
                                if(paramMap.get('pOrderNo') != null && paramMap.get('pOrderSeq') != null && paramMap.get('pStatus') != null){
                                    if(String.valueOf(paramMap.get('pStatus')) == '070' && String.valueOf(paramMap.get('pOrderNo')) == prli.Order_Number__c && Integer.valueOf(paramMap.get('pOrderSeq')) == prli.Order_SEQ__c){
                                        prli.DELIVERY_IF_SEND_DATE__c = System.now();
                                        updatePRLIList070.add(prli);
                                    }
                                }
                            }
                        }
                    }
                }

                List<ReturnOrderLineItem> roliList120 = new List<ReturnOrderLineItem>([
                        SELECT Id, Order_Number__c,request_number__c, Order_SEQ__c, Consumables_Order_Status__c, RETURN_IF_SEND_DATE__c,
                                Order_CHNL_TYPE_Code__c
                        FROM ReturnOrderLineItem
                        WHERE request_number__c IN :p120OrderNoList
                        AND Order_SEQ__c IN :p120OrderSeq
                        AND Consumables_Order_Status__c = '120'
                        AND Order_CHNL_TYPE_Code__c='B'
                        AND RETURN_IF_SEND_DATE__c =NULL
                ]);

                System.debug('조회된 120 ReturnOrderLineItem :: ' + roliList120);

                //반품완료일 경우 => 반품결과전송일자 (RETURN_IF_SEND_DATE__c)를 현재시각으로 업데이트
                if(!roliList120.isEmpty()){
                    for (ReturnOrderLineItem roli : roliList120) {
                        if(!paramMapList.isEmpty()) {
                            for (Map<String, Object> paramMap : paramMapList) {
                                if(paramMap.get('pOrderNo') != null && paramMap.get('pOrderSeq') != null && paramMap.get('pStatus') != null){
                                    if(String.valueOf(paramMap.get('pStatus')) == '120' && String.valueOf(paramMap.get('pOrderNo')) == roli.request_number__c && Integer.valueOf(paramMap.get('pOrderSeq')) == roli.Order_SEQ__c){
                                        roli.RETURN_IF_SEND_DATE__c = System.now();
                                        updateROLIList120.add(roli);
                                    }
                                }
                            }
                        }
                    }
                }

//
//
//                //상태가 배송중, 배송완료 인 경우 ProductRequestLineItem 조회
//                if( pStatus!=null && !pStatus.equals('') && (pStatus =='030' || pStatus =='070')){
//                    List<ProductRequestLineItem> prliList = new List<ProductRequestLineItem>();
//                    String strPRLIquery ='';
//                    strPRLIquery += ' SELECT Id, Order_Number__c, Order_SEQ__c, Consumables_Order_Status__c, SHIPPED_IF_SEND_DATE__c, Order_CHNL_TYPE_Code__c ';
//                    strPRLIquery += ' FROM ProductRequestLineItem';
//                    strPRLIquery += ' WHERE Order_Number__c = : pOrderNo ';
//                    strPRLIquery += ' AND Order_SEQ__c = :pOrderSeq ';
//                    strPRLIquery += ' AND Order_CHNL_TYPE_Code__c = \'B\' '; //--B LGE.COM
//                    strPRLIquery += ' AND Consumables_Order_Status__c = :pStatus ';
//                    if(pStatus =='030'){
//                        strPRLIquery += ' AND SHIPPED_IF_SEND_DATE__c =NULL ';
//                    } else if(pStatus =='070'){
//                        strPRLIquery += ' AND DELIVERY_IF_SEND_DATE__c =NULL ';
//                    }
//                    prliList = Database.query(strPRLIquery);
//
//                    System.debug('조회된 ProductRequestLineItem :: ' + prliList);
//
//
//                    //출하완료(shipment)일 경우 => 출하완료전송일자 (SHIPPED_IF_SEND_DATE__c)를 현재시각으로 업데이트
//                    if(pStatus=='030' && !prliList.isEmpty()){
//                        for(productRequestLineItem prli : prliList){
//                            prli.SHIPPED_IF_SEND_DATE__c = System.now();
//                            updatePRLIList.add(prli);
//                        }
//                    }
//                    //배송완료일 경우 => 배송완료전송일자 (DELIVERY_IF_SEND_DATE__c)를 현재시각으로 업데이트
//                    else if(pStatus=='070'&& !prliList.isEmpty()){
//                        for(productRequestLineItem prli : prliList){
//                            prli.DELIVERY_IF_SEND_DATE__c = System.now();
//                            updatePRLIList.add(prli);
//                        }
//                    }
//
//
//                //상태가 반품완료 인 경우 ReturnOrderLineItem 조회
//                } else if ( pStatus!=null && !pStatus.equals('') && pStatus =='120') {
//                    List<ReturnOrderLineItem> roliList = new List<ReturnOrderLineItem>([
//                            SELECT Id, Order_Number__c, Order_SEQ__c, Consumables_Order_Status__c, RETURN_IF_SEND_DATE__c,
//                                    Order_CHNL_TYPE_Code__c
//                            FROM ReturnOrderLineItem
//                            WHERE Order_Number__c = :pOrderNo
//                            AND Order_SEQ__c = :pOrderSeq
//                            AND Consumables_Order_Status__c = :pStatus
//                            AND Order_CHNL_TYPE_Code__c='B'
//                            AND RETURN_IF_SEND_DATE__c =NULL
//                    ]);
//
//                    //반품완료일 경우 => 반품결과전송일자 (RETURN_IF_SEND_DATE__c)를 현재시각으로 업데이트
//                    if(!roliList.isEmpty()){
//                        for (ReturnOrderLineItem roli : roliList) {
//                            roli.RETURN_IF_SEND_DATE__c = System.now();
//                            updateROLIList.add(roli);
//
//                        }
//                    }
//                }

                Integer ucount = 0;

                if(updatePRLIList030.size() > 0){
                    update updatePRLIList030;
                    System.debug('updatePRLIList :: ' + updatePRLIList030);
                    result.rstType = 'SUCCESS';
                    ucount += updatePRLIList030.size();
                    //result.rstMsg = '주문번호 ' + pOrderNo + '  업데이트 완료' ;
                }

                if(updatePRLIList070.size() > 0){
                    update updatePRLIList070;
                    System.debug('updatePRLIList :: ' + updatePRLIList070);
                    result.rstType = 'SUCCESS';
                    ucount += updatePRLIList070.size();
                    //result.rstMsg = '주문번호 ' + pOrderNo + '  업데이트 완료' ;
                }

                if(updateROLIList120.size() > 0){
                    update updateROLIList120;
                    System.debug('updateROLIList :: ' + updateROLIList120);
                    result.rstType = 'SUCCESS';
                    ucount += updateROLIList120.size();
                    //result.rstMsg = '주문번호 ' + pOrderNo + '  업데이트 완료' ;
                }
                if(ucount > 0){
                    result.rstType = 'SUCCESS';
                    result.rstMsg = '주문 ' + ucount + '건 업데이트 완료' ;
                }

                if(updatePRLIList030.isEmpty() && updatePRLIList070.isEmpty() && updateROLIList120.isEmpty()){
                    result.rstType = 'SUCCESS';
                    result.rstMsg = '조회된 항목이 없습니다.';
                }

            } else {
                result.rstType = 'ERROR';
                result.rstMsg = 'No Input Data .';
            }

        } catch (Exception e){
            Database.rollback(sp);
            System.debug('*** e.getMessage: ' + e.getMessage());
            System.debug('*** e.getLine -> ' + e.getLineNumber());
            result.rstType = 'ERROR';
            result.rstMsg = e.getMessage();
        }

        objOutput.result = result;

        // =============================================================
        // RESPONSE
        // =============================================================

        log.responseTime            = System.now();
        log.responseBody            = JSON.serialize(objOutput);
        log.status                  = result.rstType == 'SUCCESS' ? SUCCESS : ERROR;
        log.errorMessage            = result.rstMsg;
        ifUtil.insertLog(log);

        return objOutput;
    }

}