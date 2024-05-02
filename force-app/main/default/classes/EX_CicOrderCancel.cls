/**
 * Created by A80598 on 2023-03-13.
 */

 @RestResource(UrlMapping='/v1/api/ma/heroku/CicOrderCancel')
 global with sharing class EX_CicOrderCancel {
 
     // =============================================================
     // 인터페이스 Id 값 설정 (SFDC에 ifId를 저장하여 사용)
     // =============================================================
     private static final String IFID    = 'CicOrderCancel';
     private static final String SUCCESS = 'SUCCESS';
     private static final String ERROR   = 'ERROR';
 
     global class Input {
         public InputBody request;
         public Input() {
             request = new InputBody();
         }
     }
 
     global class InputBody {
         public String ReqType;
         public List<InputData> params;
         public InputBody() {
             params = new List<InputData>();
         }
     }
 
     global class InputData {
         //public String orderNo; // Order_Number__c
         public String sfId; //ProductRequest.sfId
     }
 
     global class Output {
         public OutputBody response;
         public ResultMsg result;
     }
 
     global class OutputBody {
         public List<OutputData> records;
         public OutputBody() {
             records = new List<OutputData>();
         }
     }
 
     global class OutputData {
         public String orderNo;
     }
 
     global class ResultMsg {
         public String rstType; //처리결과
         public String rstMsg;
     }
 
     /**
      * @AUTHOR I2MAX.SANGHUNYEO
      * @date  2023-03-13
      * @param
      * @description 자동주문취소
      * input 주문번호리스트
      * output 결과 성공/실패
      */
     @HttpPost
     global static Output doPost() {
         Savepoint sp = Database.setSavepoint();
 
         String requestBody  = RestContext.request.requestBody.toString();
         String requestHeader = RestContext.request.headers.toString();
 
         // 로그 시작 (IF_Master에 등록되어 있으며, 로그 적재 여부가 true일 경우에만 쌓임)
         IFUtil ifUtil               = new IFUtil(IFID);
         IFUtil.LogWrapper log       = new IFUtil.LogWrapper(IFID, requestHeader, requestBody);
 
         Input objInput              = new Input();
         Output objOutput            = new Output();
         InputBody objInputBody      = new InputBody();
         OutputBody objOutputBody    = new OutputBody();
         ResultMsg result            = new ResultMsg();
 
         try {

             objInputBody = (InputBody) JSON.deserialize(requestBody, InputBody.class);
 
             if(!objInputBody.params.isEmpty()){ //데이터 존재 List<InputData> 주문번호리스트
                 //List<String> orderNoList = new List<String>();
                 List<String> sfIdList = new List<String>();
                 for(InputData inputData : objInputBody.params){
                     String sfId = inputData.sfId;
                     if(sfId != null && !sfId.equals('')){
                         sfIdList.add(inputData.sfId);
                     }
                 }
 
                 /** ProductRequest 조회 */
                 List<ProductRequest> prListTotal = new List<ProductRequest>();
                 prListTotal = [SELECT Id, Order_Number__c, PAYMENT_REQUEST_DATE__c, LIMIT_TM__c FROM ProductRequest WHERE Id IN :sfIdList];
                 System.debug('Input sfIdList로 ProductReqeust 조회 ' + prListTotal.size()  + '건  >> ' + prListTotal );
 
                 List<String> orderNoList = new List<String>();
                 if(!prListTotal.isEmpty()){
                     for(ProductRequest pr : prListTotal){
                         orderNoList.add(pr.Order_Number__c);
                     }
                 }
                 //23 10 06 hyungho.chun 포인트있는건 환불위해 payment detail 찾아놓기
                 //23 10 24 hyungho.chun MBS_CUST_ID__c 인터페이스안태우고 detail에서있으면 찾아넣는거로 변경됨
                 List<SR_PRE_PAYMENT_DETAIL__c> detailList = [SELECT PAY_CUST_NAME__c, PAY_CUST_PHONE__c, DEPOSIT_TYPE__c, SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c, MBS_CUST_ID__c  
                                                             FROM SR_PRE_PAYMENT_DETAIL__c 
                                                             WHERE SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c =: orderNoList  
                                                             AND DEPOSIT_TYPE__c = 'D' 
                                                             ];
                 //23 10 06 TRX ID랑 mbs_cust_id 값을 매핑시켜줘야함 or (주문번호 + mbs_cust_id)
                 Map<String, String> orderNo_MBSid = new Map<String, String>();
                 String mbs_cust_id = '';
                 if(detailList.size() >0 ){
                     for(SR_PRE_PAYMENT_DETAIL__c item : detailList){
                        //  FN_PaymentModel.T_RES_CheckPoint_Item getMembership = new FN_PaymentModel.T_RES_CheckPoint_Item();
                        //  getMembership = FN_PaymentAgent.requestRetrievePoint(item.PAY_CUST_NAME__c, item.PAY_CUST_PHONE__c); //MBS_CUST_ID 가져오기
                        //  System.debug('getMembership :: '+getMembership);
                        //  System.debug('mbs_cust_id :: '+getMembership.MBS_CUST_ID);

                        //23 10 24 hyungho.chun MBS_CUST_ID__c 인터페이스안태우고 detail에서있으면 찾아넣는거로 변경됨
                         mbs_cust_id = (item.MBS_CUST_ID__c != null && item.MBS_CUST_ID__c != '') ? item.MBS_CUST_ID__c : '';
                         orderNo_MBSid.put(item.SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c, mbs_cust_id);
                     }
                     System.debug('orderNo_MBSid :: '+orderNo_MBSid);
                 }
 
                 
 
                 System.debug('해당 productRequest의 OrderNolist' + orderNoList);
                 //List<String> parentIdList = new List<String>();
                 List<ProductRequestLineItem> prliListTotal = new List<ProductRequestLineItem>();
                 String strQuery = '';
                 strQuery += ' SELECT Order_CUST_Id__r.Name, Parent.fm_PAYMENT_TYPE__c, Parent.MOID__c, Parent.ACQUIRE_INFO__c,' +
                 //23 10 16 hyungho.chun soql error로 필드 추가 'SR_RESRV_PART_Id__r.RESRV_Number__c'
                             'Parent.VBANK_NUM__c, Parent.Order_CUST_Id__r.Name, Parent.PAYMENT_REQUEST_DATE__c, Parent.LIMIT_TM__c, SR_RESRV_PART_Id__r.RESRV_Number__c, ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
                 strQuery += ' FROM ProductRequestLineItem ';
                 strQuery += ' WHERE Order_Number__c IN :orderNoList AND Consumables_Order_Status__c != \'005\' ';
                 prliListTotal = Database.query(strQuery);
                 System.debug(' 해당 OrderNoList로 조회한 ProductReqeustLineItem >>prliListTotal:: ' +prliListTotal);
                 System.debug(' prliListTotal.size():: ' +prliListTotal.size());
 

 
                 //List<ProductRequest> prListTotal = new List<ProductRequest>();
                 //prListTotal = [SELECT Id, Order_Number__c FROM ProductRequest WHERE Id IN :parentIdList];
 
                 System.debug('============= UPDATE ============');
                 List<ProductRequestLineItem>updatePRLIList = new List<ProductRequestLineItem>();
                 List<ProductRequest> updatePRList = new List<ProductRequest>();
 
                 System.debug('param으로 조회된 ProductRequestLineItemList : ' +prliListTotal );
 
                 Payment_Gateway__c pg = [
                 SELECT
                         DIV_CODE__c,
                         MID__c,
                         Name,
                         SIGN_KEY__c,
                         SM_DEPT__c
                 FROM Payment_Gateway__c
                 WHERE SM_DEPT__c IN (SELECT Id FROM SM_DEPT__c Where DEPT_CODE__c = 'PH8002')
                 limit 1
                 ];

                //24.02.01 gw.lee
                //사업부 취소 관련 로직 추가 (사업부 요청했을 때, 취소가 가능한 케이스 및 불가능한 케이스 로직 추가)
                Set<String> rsrvList = new Set<String>(); //예약번호 List
                Map<String, ProductRequestLineItem> prliSaleMap = new Map<String, ProductRequestLineItem>();            
                for(productRequestLineItem prli : prliListTotal){
 
 
                    Date today = Date.valueOf(prli.Parent.LIMIT_TM__c.addDays(1));
                    Integer year = today.Year();
                    Integer month = today.Month();
                    Integer day = today.Day();

                    Datetime todayTime = Datetime.newInstance(year, month, day, 0, 0, 1);
                    System.debug(todayTime);

                    // 주문상태 (Consumables_Order_Status__c)= '005' --자동주문취소완료
                    prli.Consumables_Order_Status__c = '005';
                    // 주문 상세 상태 (Consumables_Order_DETAIL__c) = 'NULL'
                    prli.Consumables_Order_Detail__c = NULL;
                    // 취소수량 (CANCEL_Quantity__c) = prli.QuantityRequested(요청수량)
                    prli.CANCEL_Quantity__c = prli.QuantityRequested;
                    // 판매수량 (SALE_Quantity__c)= 0
                    prli.SALE_Quantity__c = 0;
                    // 취소일시(CANCEL_DATE__c) = 현재날짜
                    prli.CANCEL_Date__c = Date.today();
                    // 취소요청일시(CANCEL_Request_DTM__c) = 현재날짜
                    prli.CANCEL_Request_DTM__c = todayTime;
                    // 취소사유 (CANCEL_Reason__c)= '미결제건 자동주문취소'
                    prli.CANCEL_Reason__c = '미결제건 자동주문취소';
                    // 취소부서코드 (CANCEL_Department_Code__c) = prli.Department_Code__c//todo doubleCheck
                    prli.CANCEL_Department_Code__c = prli.Department_Code__c;
                    // 취소자 (CANCEL_User__c) = 'SYSTEM'
                    prli.CANCEL_User__c = 'SYSTEM';

                    updatePRLIList.add(prli);
                    if (String.isNotEmpty(prli.SR_RESRV_PART_Id__r.RESRV_Number__c)) {
                        rsrvList.add(prli.SR_RESRV_PART_Id__r.RESRV_Number__c);
                        prliSaleMap.put(prli.SR_RESRV_PART_Id__r.RESRV_Number__c + '_' + prli.RSRV_SEQ__c, prli);
                    }
                }

                //24 03 15 hyungho.chun 사업부요청수량 미리 맵핑용(이후 취소 수불 때 (주문수량-사업부요청수량)만큼 일반예약건에서 할당감소시키기위해 )
                Map<String, Integer> rsrvMap = new Map<String, Integer>();
                if(rsrvList.size()>0){
                    List<ProductRequestLineItem> rsrvPrList = [SELECT RSRV_Number__c, PART_NO__c, QuantityRequested FROM ProductRequestLineItem WHERE RecordType.Name = '판매예약' AND RSRV_NUMBER__c IN :rsrvList];
                    for (ProductRequestLineItem pObj : rsrvPrList) {
                        rsrvMap.put(pObj.RSRV_Number__c+'_'+pObj.PART_NO__c, Integer.valueOf(pObj.QuantityRequested));
                    }
                }
                

                //24.02.01 gw.lee
                //사업부 미요청건에 대한것만 추출
                Map<String, SI_REQUEST__c> divRequestMap = new Map<String, SI_REQUEST__c>(); //사업부 요청 List

                List<SI_REQUEST__c> divRequestList = [SELECT ID, TRANS_FLAG__c, RESV_NO__c FROM SI_REQUEST__c WHERE RESV_NO__c = :rsrvList AND TRANS_FLAG__c = 'N'];
                for (SI_REQUEST__c siObj : divRequestList) {
                    divRequestMap.put(siObj.RESV_NO__c, siObj);
                }
 
                for(ProductRequest pr : prListTotal){

                    // Date today = Date.valueOf(pr.PAYMENT_REQUEST_DATE__c.addDays(+2).addhours(9));
                    // 결제 재요청 시 기존 PAYMENT_REQUEST_DATE__c 값이 바뀌기 때문에 
                    // APPR_CANCEL_DATE__c 값이 정확하지 않음, 기준값을 LIMIT_TM__c으로 변경             
                    Date today = Date.valueOf(pr.LIMIT_TM__c.addDays(1));
                    Integer year = today.Year();
                    Integer month = today.Month();
                    Integer day = today.Day();

                    Datetime todayTime = Datetime.newInstance(year, month, day, 0, 0, 1);
                    System.debug(todayTime);

                    //자동결제취소일시 (APPR_CANCEL_DATE__c) = 현재시각
                    //pr.APPR_CANCEL_DATE__c = System.now();
                    //DateTime todayDate = Datetime.newInstance(System.today(), Time.newInstance(9,1,0,0));
                    
                    pr.APPR_CANCEL_DATE__c = todayTime;

                    // 23/07/12 자동주문취소 시간 변경

                    // 07/13 05:00 호출시 // -9시간 ,  07/12, 20:00 시 정도로 들어가 있음.
                    // APPR_CANCEL_DATE__c + (System.Today - 1 + 15:00:01(+9))

                    // 07/13 05시 호출 시
                    // (System.Today - 1 + 15:00:01(+9))
                    // => 화면 조회는 7월 13일 00:00:01

                    //자동결제취소대상여부 (APPR_CANCEL_YN__c) = 'N'
                    pr.APPR_CANCEL_YN__c = 'N';
                    updatePRList.add(pr);
                }
 
                 
 
 
                 System.debug('============= END ============');
 
 
 
                 List<Map<String, Object>> rsrvCancelMapList = new List<Map<String, Object>>();
                //  List<ProductRequestLineItem> prliForExec = new List<ProductRequestLineItem>(); 
                List<ProductRequestLineItem> execABList = new List<ProductRequestLineItem>(); // alloc_qty 수불용    // 24 03 15 hyungho.chun prliForExec 엔 할당 감소 수불용
                List<ProductRequestLineItem> execAEList = new List<ProductRequestLineItem>();  //24 03 15 hyungho.chun execAEList는 일반예약/품절주문건 RESRV_QTY__c 수불용
 
                 for(InputData inputData : objInputBody.params){

                     List<ProductRequest> prList = new List<ProductRequest>();
                     if(!prListTotal.isEmpty()){
                         for(ProductRequest pr : prListTotal){

                             if(pr.Id == inputData.sfId){
                                 prList.add(pr);
                             }
                         }
                     }
 
                     //추가조건 : APPR_CANCEL_YN__c = Y ??
                     if(!prList.isEmpty()){
                         for(ProductRequest pr : prList){ //ProductRequest
                             String prId = pr.Id;
                             List<ProductRequestLineItem> prliList = new List<ProductRequestLineItem>();
                             if(!prliListTotal.isEmpty()){
                                 for(ProductRequestLineItem prli : prliListTotal){
                                     if(prli.ParentId == prId){
                                         prliList.add(prli);
                                     }
                                 }
                             }
 
 
                             /*List<ProductRequestLineItem> prliList = [
                                 SELECT Id, RSRV_Number__c, QuantityRequested, ENDP_RSV_Quantity__c, CANCEL_Quantity__c
                                 FROM ProductRequestLineItem
                                 WHERE ParentId = :prId
                             ];*/
                             Boolean isPayment = false;
 
                             if(!prliList.isEmpty()){
                                 for(ProductRequestLineItem prli : prliList){ //ProductRequestLineItem
                                    System.debug('prli id:' + prli.Id);

                                    //24 03 15 hyungho.chun 예약주문약속취소 분기처리
                                    if(prli.SR_RESRV_PART_Id__c != null){ 
                                        // /** 1. 예약 취소 */
                                        System.debug('예약 취소 START');                                        
                                        //24.02.01 gw.lee
                                        //소모품택배 예약취소 로직 동일하게 변경
                                        Map<String, Object> rsrvCancelMap = new Map<String, Object>();
                                        if (divRequestMap.containsKey(prli.SR_RESRV_PART_Id__r.RESRV_Number__c)) {
            
                                            rsrvCancelMap.put('ProductRequestLineItem', prliSaleMap.get(prli.SR_RESRV_PART_Id__r.RESRV_Number__c + '_' + prli.RSRV_SEQ__c));
                                            rsrvCancelMap.put('code', 'AD');
                
                                            rsrvCancelMapList.add(rsrvCancelMap);
                                        } else {
                                            rsrvCancelMap.put('ProductRequestLineItem', prliSaleMap.get(prli.SR_RESRV_PART_Id__r.RESRV_Number__c + '_' + prli.RSRV_SEQ__c));
                                            // rsrvCancelMap.put('code', 'AM');
                                            //24 03 15 hyungho.chun
                                            //사업부 출하가 되던 안되던 사업부 주문수량 감소, 센터 약속 미입고 수량 감소 조치 (자재에서 전달 완료) (consumableUtil.cancelutil 약속취소관련 로직 따라감)
                                            rsrvCancelMap.put('code', 'AD');
                                                                                
                
                                            rsrvCancelMapList.add(rsrvCancelMap);
                                        }
                                        System.debug('예약 취소 END');

                                        //24 03 15 hyungho.chun 약속수량 수불용도 / 자동주문취소는 전부다 입고완료된상태의 주문이다
                                        //예약주문-> 모든 수량이 사업부에서 내려온경우
                                        if (prli.ENDP_RSV_Quantity__c != null && prli.QuantityRequested != null && prli.ENDP_RSV_Quantity__c == prli.QuantityRequested) {
                                            System.debug('주문수량 전체 약속수량감소 경우');
                                            execAEList.add(prli);
                                        }else if (prli.ENDP_RSV_Quantity__c != null && prli.QuantityRequested != null && prli.ENDP_RSV_Quantity__c < prli.QuantityRequested) { 
                                            System.debug('주문수량 일부 할당수량 / 일부 약속수량 감소 경우');     
                                            // prli.CANCEL_Quantity__c = prli.ENDP_RSV_Quantity__c;  //약속수량은 입고받은 수량만큼만 감소시키기위해 임시로 caccel_quantity에 넣어줌(EX_RsrvUtil 에처 차감때 CANCEL_Quantity__c 바라보니까)
                                            ProductRequestLineItem tempClonePrli1 = prli.clone();
                                            tempClonePrli1.CANCEL_Quantity__c = prli.ENDP_RSV_Quantity__c;
                                            execAEList.add(tempClonePrli1);
                                            // prli.CANCEL_Quantity__c = prli.QuantityRequested - rsrvMap.get(prli.SR_RESRV_PART_Id__r.RESRV_Number__c+'_'+prli.BASIS_Parts_Number__c); //할당수량은 (전체주문수량-입고받은수량)만큼만 감소시키기위해 임시로 caccel_quantity에 넣어줌(EX_RsrvUtil 에처 차감때 CANCEL_Quantity__c 바라보니까)
                                            ProductRequestLineItem tempClonePrli2 = prli.clone();
                                            tempClonePrli2.CANCEL_Quantity__c = prli.QuantityRequested - rsrvMap.get(prli.SR_RESRV_PART_Id__r.RESRV_Number__c+'_'+prli.BASIS_Parts_Number__c);
                                            execABList.add(tempClonePrli2); //할당수량감소
                                        }else{
                                            //24 03 15 hyungho.chun 이런경우는없는게 맞음
                                            System.debug('불가능한 경우!');
                                        }
                                    }else{
                                        System.debug('주문수량 전체 할당수량감소 경우');
                                        // prliForExec.add(prli);
                                        execABList.add(prli); //할당수량감소
                                    }



                                     /** 2. 재고 수불 처리 */
                                    //  System.debug('재고 수불 처리 START');
                                     //24 03 15 hyungho.chun 의미없는 코드 삭제
                                    //  Decimal CancelQuantity = 0;
                                    //  if(prli.CANCEL_Quantity__c != null){
                                    //      CancelQuantity = prli.CANCEL_Quantity__c;
                                    //  }
                                     //EX_RsrvUtil.execApplyProductItem(CancelQuantity, 'AB', prli); //AB 할당(-) 소모품주문취소
                                    //  prliForExec.add(prli);
                                    //  System.debug('재고 수불 처리 END');

                                




                                     /** 3. (구) 포인트 결제 취소 */
                                     System.debug('(구) 포인트 결제 취소 START');
                                     
                                     if (prli.Parent.fm_PAYMENT_TYPE__c == '결제URL') {
                                         FN_PaymentModel.T_REQ_CancelCardUrl kRequestModel = new FN_PaymentModel.T_REQ_CancelCardUrl();
 
                                         //res_bankAccount = FNPaymentCredit.checkBankAccount(aBody);
                                         String mid = prli.Parent.MOID__c;
                                         String prlId = prli.id;
                                         //23 10 06 hyungho.chun
                                         String prId2 = prli.ParentId;
                                         String cancelReason = prli.CANCEL_Reason__c;
                                         String tid = prli.TID__c;
 
                                         // kRequestModel.merchantKey = 'IGp3k/3j2e3toqdnizlGFZIE9YKLQ15TDqTVP+f3uy3iOPt3hxhXfywDDC7cde1f5YrrxfV3wZxVVR8zuL2fbw==';
                                         // kRequestModel.Mid = 'tlgsmp001m';
                                         //23 10 06 hyungho.chun
                                         kRequestModel.merchantKey = pg.SIGN_KEY__c;
                                         kRequestModel.Mid = pg.MID__c;
                                         kRequestModel.Tid = tid;
                                         kRequestModel.moid = mid;
 
                                         //카드취소 결제API 호출
                                         String jsonStr = JSON.serialize(kRequestModel);
                                         String jsonStrPoint = '';
                                         if(prli.POINT_Amount__c !=0 && prli.POINT_Amount__c !=null){
 
                                             FN_PaymentModel.T_REQ_SpendOrCancelPoint kRequestModelPoint = new FN_PaymentModel.T_REQ_SpendOrCancelPoint();
                                             // kRequestModelPoint.MBS_CUST_ID = '1000294683';
                                             kRequestModelPoint.MBS_CUST_ID = orderNo_MBSid.get(String.valueOf(prli.Order_Number__c));
                                             kRequestModelPoint.ORG_CD = '';
                                             kRequestModelPoint.ACCUM_FLAG = 'USED_CNCL';
                                             kRequestModelPoint.ACCUM_PNT = String.valueOf(prli.POINT_Amount__c);
                                             kRequestModelPoint.BILL_TO_CD = 'PH8002';
                                             kRequestModelPoint.BILL_TO_NM = '소모품센터';
                                             kRequestModelPoint.ORIG_ACCUM_BRKDN_ID = String.valueOf(prli.POINT_TRX_ID__c);
                                             jsonStrPoint = JSON.serialize(kRequestModelPoint);
                                             if(!Test.isRunningTest()) EX_ConsumableUtil.callout(jsonStrPoint, '', 'point',true, prId2, cancelReason,prlId);
                                         }
                                         if(isPayment == false){
                                             if(!Test.isRunningTest()) EX_ConsumableUtil.callout(jsonStr, mid, 'card',false, prId2, cancelReason,prlId);
                                         }
 
                                         // ResultCode=2014, ResultMsg=취소 불가능 거래, 이미 취소된 거래는 성공으로 표시
                                         // 2014 코드는 이미 취소한 경우와 입금이 완료된 경우, 이미 환불한 경우 발생한다.
                                         // 입금 완료는 이미 확인했으므로 여기에서는 이미 취소한 것으로 판단한다.
                                     //23 08 24 hyungho.chun 현금입금 인 경우도 있음
                                     //조건에 || prli.Parent.fm_PAYMENT_TYPE__c == '현금입금' 추가    
                                     } else if (prli.Parent.fm_PAYMENT_TYPE__c == '가상계좌' || prli.Parent.fm_PAYMENT_TYPE__c == '현금입금') {
                                         FN_PaymentModel.T_RES_BankAccount res_bankAccount = new FN_PaymentModel.T_RES_BankAccount();
 
                                         Map<String, Object> aBody = new Map<String, Object>();
                                         /* 은행코드 */
                                         aBody.put('bank', prli.Parent.ACQUIRE_INFO__c);
                                         /* 계좌번호 */
                                         aBody.put('bankAccountNo', prli.Parent.VBANK_NUM__c);
                                         /* 계좌예금주 */
                                         aBody.put('receiverName', prli.Parent.Order_CUST_Id__r.Name);
                                         FN_PaymentModel.T_REQ_CancelPayment kRequest = new FN_PaymentModel.T_REQ_CancelPayment();
 
                                         String mid = prli.Parent.MOID__c;
                                         String prlId = prli.id;
                                         //23 10 06 hyungho.chun
                                         String prId2 = prli.ParentId;
                                         //kRequestModel.PartialCancelCode = '1'; //현재 카드결제 [부분취소] 결제모듈파트에서 수정중. 부분취소여부( 0:전체, 1:부분)
 
 
                                         // kRequest.merchantKey = 'IGp3k/3j2e3toqdnizlGFZIE9YKLQ15TDqTVP+f3uy3iOPt3hxhXfywDDC7cde1f5YrrxfV3wZxVVR8zuL2fbw==';
                                         // kRequest.Mid = 'tlgsmp001m';
                                         //23 10 06 hyungho.chun
                                         kRequest.merchantKey = pg.SIGN_KEY__c;
                                         kRequest.Mid = pg.MID__c;
                                         String cancelReason = prli.CANCEL_Reason__c;
                                         SR_SMARTRO_PAYMENT_REQUEST__c kSmartro = EX_PaymentUtil.fetchRequestHistory(mid);
 
                                         kRequest.Tid = kSmartro.TID__c;
                                         kRequest.CancelAmt = String.valueOf(kSmartro.APPR_AMT__c);
                                         String jsonStr = JSON.serialize(kRequest);
                                         String jsonStrPoint = '';
                                         System.debug(kRequest);
 
                                         if(prli.POINT_Amount__c !=0 && prli.POINT_Amount__c !=null){
                                             FN_PaymentModel.T_REQ_SpendOrCancelPoint kRequestModelPoint = new FN_PaymentModel.T_REQ_SpendOrCancelPoint();
                                             // kRequestModelPoint.MBS_CUST_ID = '1000294683';
                                             kRequestModelPoint.MBS_CUST_ID = orderNo_MBSid.get(String.valueOf(prli.Order_Number__c));
                                             kRequestModelPoint.ORG_CD = '';
                                             kRequestModelPoint.ACCUM_FLAG = 'USED_CNCL';
                                             kRequestModelPoint.ACCUM_PNT = String.valueOf(prli.POINT_Amount__c);
                                             kRequestModelPoint.BILL_TO_CD = 'PH8002';
                                             kRequestModelPoint.BILL_TO_NM = '소모품센터';
                                             kRequestModelPoint.ORIG_ACCUM_BRKDN_ID = prli.POINT_TRX_ID__c;
                                             jsonStrPoint = JSON.serialize(kRequestModelPoint);
                                             if(!Test.isRunningTest()) EX_ConsumableUtil.callout(jsonStrPoint, '', 'point',true, prId2, cancelReason,prlId);
 
                                         }
                                         if(isPayment == false) {
                                             if(!Test.isRunningTest()) EX_ConsumableUtil.callout(jsonStr, kSmartro.MOID__c, 'vaccount', false, prId2, cancelReason,prlId);
                                         }
 
                                     }
                                     isPayment = true;
 
                                 }
                             }
                         }
                     }
                 }//for

                 if(!updatePRList.isEmpty()){
                    update updatePRList;
                }
                if(!updatePRLIList.isEmpty()){
                    update updatePRLIList;
                }
                
                 System.debug('inputdata for문 끝');
                 if(!rsrvCancelMapList.isEmpty()){
                     EX_RsrvUtil.CANCEL_RESRV_MULTI(rsrvCancelMapList);
                     System.debug('CABCEL_RESV MULTI 끝');
                 }
                //  if(!prliForExec.isEmpty()){
                //      EX_RsrvUtil.execApplyProductItemMulti('AB', prliForExec); //AB 할당(-) 소모품주문취소
                //  }
                if(!execABList.isEmpty()){
                    EX_RsrvUtil.execApplyProductItemMulti('AB',execABList);
                }                 
                 //24 03 15 hyungho.chun 약속수량 감소 로직 필요
                 if(!execAEList.isEmpty()){
                    EX_RsrvUtil.execApplyProductItemMulti('AE',execAEList);
                }                 
 
             }else{ //데이터 없음
                 result.rstType = 'ERROR';
                 result.rstMsg = 'No Input Data (OrderNumber List).';
             }
             System.debug('*** objOutput: ' + objOutput);
             result.rstType = 'SUCCESS';
         } catch (Exception e) {
             Database.rollback(sp);
             System.debug('*** e.getMessage: ' + e.getMessage());
             System.debug('*** e.getLine -> ' + e.getLineNumber());
             result.rstType = 'ERROR';
             result.rstMsg = e.getMessage()  + ' / ' +  e.getLineNumber();
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