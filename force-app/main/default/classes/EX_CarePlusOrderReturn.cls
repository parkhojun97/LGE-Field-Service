/**
 * Created by A80598 on 2023-03-02.
 */

@RestResource(UrlMapping='/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0012')
global with sharing class EX_CarePlusOrderReturn {
    // /services/apexrest/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0013
    // {"Body":{"data":{"inputData":"test"}}}

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

    public static String F_ST_DEPT_CODE = 'PH0300';
    public static String F_ST_DEPT_NAME = '케어용품센터';

    /**
     * @AUTHOR I2MAX.SANGHUNYEO
     * @date  2023-03-02
     * @param
     * @description 케어플러스 인터페이스 후처리 (케어플러스 반품요청)
     * @return
     */
    @HttpPost
    global static Output doPost() {
        Output objOutput = new Output();
        Input objInput = new Input();
        Savepoint sp = Database.setSavepoint();
        try{
            RestRequest request = RestContext.request;
            /*String requestBody = request.requestBody.toString();

            if(requestBody != null && requestBody !='') {
                objInput = (Input) JSON.deserializeStrict(requestBody, Input.class);
                String temp = objInput.Body.data.inputData;
            }*/

            objOutput.code = '200';
            objOutput.message = '케어플러스 반품 성공.';

            /**
             * Step2. 케어플러스 반품요청 정보 조회 (다른클래스로 별도 분리 예정)
             */

            sObject paramLData = new SI_CAREPLUS_ORDER__c();
            paramLData.put('TRANS_TYPE__c','R');
            paramLData.put('ORDER_NO__c','');

            String strQuery = '';
            strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('SI_CAREPLUS_ORDER__c');
            strQuery += ' FROM SI_CAREPLUS_ORDER__c ';
            strQuery += ' WHERE TRANS_TYPE__c = \'R\' ';
            strQuery += ' AND WORK_FLAG__c IN ( \'N\',\'\') ';
            strQuery += ' ORDER BY LAST_UPDATE_DATE__c ASC ';
            //strQuery += ' LIMIT 6 ';
            //System.debug('strQuery >>> ' + strQuery);

            List<sObject> siCarePlusOrderList = Database.query(strQuery);

            if(!siCarePlusOrderList.isEmpty()){
                System.debug('케어플러스 반품 수신 데이터 Total : ' + siCarePlusOrderList.size());
                List<String> sPartNoList = new List<String>();
                List<String> billToCodeList = new List<String>();
                List<String> orderNoList = new List<String>();
                List<Integer> ifIdList = new List<Integer>();
                for (sObject lData : siCarePlusOrderList) {
                    String partNo = getStringNotNull(lData.get('PART_NO__c'));
                    String billToCode = getStringNotNull(lData.get('BILL_TO_CODE__c'));
                    String orderNo = getStringNotNull(lData.get('ORDER_NO__c'));
                    Integer ifId = getIntegerNotNull(lData.get('INTERFACE_ID__c'));
                    if(!partNo.equals('')){
                        sPartNoList.add(partNo); //파트넘버 리스트
                    }
                    if(!billToCode.equals('')){
                        billToCodeList.add(billToCode); //billToCode 리스트
                    }
                    if(!orderNo.equals('')){
                        orderNoList.add(orderNo); //orderNo 리스트
                    }
                    ifIdList.add(ifId);
                }

                List<product2> mPartDataList = new List<product2>();
                if(!sPartNoList.isEmpty()){
                    mPartDataList = [SELECT Id, DISABLED_DT__c, Name FROM product2 WHERE Name IN :sPartNoList AND CAREPLUS_YN__c = 'Y'];
                    system.debug('케어용품 단종여부 체크 TOTAL : ' + sPartNoList.size() + ', result : ' + mPartDataList);
                }

                /** BillToCode 체크 */
                List<Account> billtoCodeDataList = new List<Account>();
                if(!billToCodeList.isEmpty()){
                    billtoCodeDataList = [SELECT Id, AR_CODE__c FROM ACCOUNT WHERE AR_CODE__c IN :billToCodeList]; //AR_CODE__c 로 체크
                }

                /** ReturnOrder 체크 */
                List<ReturnOrder> returnOrderList = new List<ReturnOrder>();
                if(!orderNoList.isEmpty()){
                    strQuery = '';
                    strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrder');
                    strQuery += ' FROM ReturnOrder ';
                    strQuery += ' WHERE Order_Number__c IN (';
                    Integer i = 0;
                    for(String orderNo : orderNoList){
                        if(i == 0){
                            strQuery += '\'' + orderNo + '\'';
                        }else{
                            strQuery += ',\'' + orderNo + '\'';
                        }
                        i++;
                    }
                    strQuery += ') ';
                    strQuery += ' AND Order_CHNL_TYPE_Code__c = \'BestShop\' ';
                    strQuery += ' AND RecordTypeId = \'' + EX_ConsumableUtil.RO_CARE_SUPPLIES_RECORDTYPE_ID + '\' ';
                    returnOrderList = Database.query(strQuery);
                }

                /** ReturnOrderLineItem 체크 */
                List<ReturnOrderLineItem> returnOrderLineItemList = new List<ReturnOrderLineItem>();
                if(!returnOrderList.isEmpty()){
                    List<String> roIdList = new List<String>();
                    for(ReturnOrder ro : returnOrderList){
                        roIdList.add(ro.Id);
                    }
                    if(!roIdList.isEmpty()){
                        strQuery = '';
                        strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrderLineItem');
                        strQuery += ' FROM ReturnOrderLineItem ';
                        strQuery += ' WHERE ReturnOrderId IN (';
                        Integer i = 0;
                        for(String roId : roIdList){
                            if(i == 0){
                                strQuery += '\'' + roId + '\'';
                            }else{
                                strQuery += ',\'' + roId + '\'';
                            }
                            i++;
                        }
                        strQuery += ') ';
                        returnOrderLineItemList = Database.query(strQuery);
                    }
                }

                List<ProductRequest> productRequestList = new List<ProductRequest>();
                if(!orderNoList.isEmpty()){
                    strQuery = '';
                    strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequest');
                    strQuery += ' FROM ProductRequest ';
                    strQuery += ' WHERE Order_Number__c IN (';
                    Integer i = 0;
                    for(String orderNo : orderNoList){
                        if(i == 0){
                            strQuery += '\'' + orderNo + '\'';
                        }else{
                            strQuery += ',\'' + orderNo + '\'';
                        }
                        i++;
                    }
                    strQuery += ') ';
                    strQuery += ' AND Order_CHNL_TYPE_Code__c = \'BestShop\' ';
                    strQuery += ' AND RecordTypeId = \'' + EX_ConsumableUtil.PR_CARE_SUPPLIES_RECORDTYPE_ID + '\' ';
                    productRequestList = Database.query(strQuery);
                }

                List<ProductRequestLineItem> productRequestLineItemList = new List<ProductRequestLineItem>();
                if(!orderNoList.isEmpty() && !sPartNoList.isEmpty()){
                    strQuery = '';
                    strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
                    strQuery += ' FROM ProductRequestLineItem ';
                    strQuery += ' WHERE Order_Number__c IN (';
                    Integer i = 0;
                    for(String orderNo : orderNoList){
                        if(i == 0){
                            strQuery += '\'' + orderNo + '\'';
                        }else{
                            strQuery += ',\'' + orderNo + '\'';
                        }
                        i++;
                    }
                    strQuery += ') ';
                    strQuery += ' AND PART_NO__c IN (';
                    Integer j = 0;
                    for(String partsNo : sPartNoList){
                        if(j == 0){
                            strQuery += '\'' + partsNo + '\'';
                        }else{
                            strQuery += ',\'' + partsNo + '\'';
                        }
                        j++;
                    }
                    strQuery += ') ';
                    strQuery += ' AND Order_CHNL_TYPE_Code__c = \'BestShop\' ';
                    strQuery += ' AND RecordTypeId = \'' + EX_ConsumableUtil.PRLI_CARE_SUPPLIES_RECORDTYPE_ID + '\' ';
                    productRequestLineItemList = Database.query(strQuery);
                }

                /** 케어플러스 max backif */
                List<SI_CAREPLUS_BACKIF__c> getBackIfMaxList = [SELECT INTERFACE_ID__c FROM SI_CAREPLUS_BACKIF__c ORDER BY INTERFACE_ID__c DESC LIMIT 1];
                Integer backIfMaxInterfaceId = 0;
                if(!getBackIfMaxList.isEmpty()){
                    backIfMaxInterfaceId = getIntegerNotNull(getBackIfMaxList[0].INTERFACE_ID__c);
                }

                /** 케어플러스 subMax backif */
                List<SI_CAREPLUS_BACKIF__c> getBackIfSubMaxList = [SELECT BACK_SUB_SEQ__c, INTERFACE_ID__c, ORDER_NO__c FROM SI_CAREPLUS_BACKIF__c
                WHERE INTERFACE_ID__c IN :ifIdList
                AND TRANS_TYPE__c = 'R'
                AND ORDER_NO__c IN :orderNoList
                ORDER BY BACK_SUB_SEQ__c DESC LIMIT 1];

                List<SI_CAREPLUS_ORDER__c> UpdateSiCareplusOrderList = new List<SI_CAREPLUS_ORDER__c>();
                List<SI_CAREPLUS_BACKIF__c> listInsertSiBackIf = new List<SI_CAREPLUS_BACKIF__c>();
                List<ReturnOrder> listUpsertRO = new List<ReturnOrder>();
                List<ReturnOrderLineItem> listUpsertROLI = new List<ReturnOrderLineItem>();
                List<ReturnOrderLineItem> listUpdateROLI = new List<ReturnOrderLineItem>();
                Integer loopCnt = 1;
                List<ReturnOrder> insertRoList = new List<ReturnOrder>();
                List<ReturnOrderLineItem> insertRoliList = new List<ReturnOrderLineItem>();

                for (sObject lData : siCarePlusOrderList) {

                    String result = 'SUCCESS';

                    /** ORDER_NO */
                    String carePlustOrderNo = getStringNotNull(lData.get('ORDER_NO__c'));
                    /** TRANS_TYPE */
                    String sTransType = getStringNotNull(lData.get('TRANS_TYPE__c'));
                    /* PART_NO */
                    String sPartNo = getStringNotNull(lData.get('PART_NO__c'));
                    /** ATTRIBUTE1 */
                    String sAttribute1 = '';
                    /** WROK FLAG */
                    String workFlag = '';
                    /** 현재 WORK FLAG */
                    String nowWorkFlag = getStringNotNull(lData.get('WORK_FLAG__c'));
                    if(nowWorkFlag.equals('')){nowWorkFlag = 'N';}
                    /** billtocode */
                    String billToCode = getStringNotNull(lData.get('BILL_TO_CODE__c'));
                    /** billtoCheck */
                    boolean bBilltoCheckPass = true;
                    /** BACK_IF_STATUS 상태값 */
                    String backIfStatus = '';

                    paramLData.clear();
                    paramLData.put('TRANS_TYPE__c', 'O');
                    paramLData.put('ORDER_NO__c', carePlustOrderNo);

                    /** BillToCode 체크 */
                    List<Account> billtoCodeData = new List<Account>();
                    //List<Account> billtoCodeData = [SELECT Id, AR_CODE__c FROM ACCOUNT WHERE AR_CODE__c = :billToCode]; //AR_CODE__c 로 체크
                    for(Account ac : billtoCodeDataList){
                        if(billToCode.equals(ac.AR_CODE__c)){
                            billtoCodeData.add(ac);
                        }
                    }

                    if(billtoCodeData.isEmpty()){
                        bBilltoCheckPass = false;
                    }

                    List<Product2> mPartData = new List<Product2>();
                    for(Product2 pd : mPartDataList){
                        if(sPartNo.equals(pd.Name)){
                            mPartData.add(pd);
                        }
                    }

                    if (bBilltoCheckPass) {
                        workFlag = 'W';
                        backIfStatus = 'AWAITING_RETURN';
                    } else {
                        workFlag = 'E';
                        backIfStatus = 'ERROR';
                        sAttribute1 = sAttribute1 + ' BILLTOCODE : ' + billToCode + ' 미존재';
                    }

                    Integer backIfSubMaxInterfaceId = 0;
                    if(!getBackIfSubMaxList.isEmpty()){
                        for(SI_CAREPLUS_BACKIF__c scb : getBackIfSubMaxList){
                            if(scb.INTERFACE_ID__c == getDecimalNotNull(lData.get('INTERFACE_ID__c')) && scb.ORDER_NO__c == carePlustOrderNo){
                                backIfSubMaxInterfaceId = getIntegerNotNull(getBackIfSubMaxList[0].BACK_SUB_SEQ__c);
                            }
                        }
                    }

                    lData.put('CANCEL_FLAG__c', '');

                    /** SI_CARE_PLUS_ORDER 테이블 WORK_FLAG 업데이트 */
                    lData.put('WORK_FLAG__c', workFlag);
                    lData.put('ATTRIBUTE1__c', sAttribute1);
                    //lData.put('BACK_IF_SEND_YN__c', 'Y');

                    SI_CAREPLUS_ORDER__c siCareplusOrder = new SI_CAREPLUS_ORDER__c();
                    siCareplusOrder = updateSiCarePlusOrderWorkFlag(lData);
                    UpdateSiCareplusOrderList.add(siCareplusOrder);

                    /** SR_CARE_PLUS_ORDER 테이블에 데이터 MERGE */
                    //lData.put('SHIP_QTY__c', 0);
                    lData.put('CANCEL_QTY__c', 0);

                    List<ReturnOrder> roList = new List<ReturnOrder>();
                    List<ReturnOrderLineItem> roliList = new List<ReturnOrderLineItem>();

                    /** ReturnOrder, ReturnOrderLineItem Upsert */
//                        strQuery = '';
//                        strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrder');
//                        strQuery += ' FROM ReturnOrder ';
//                        strQuery += ' WHERE Order_Number__c = \'' + carePlustOrderNo + '\' ';
//                        strQuery += ' AND Order_CHNL_TYPE_Code__c = \'BestShop\' ';
//                        strQuery += ' AND RecordTypeId = \'' + EX_ConsumableUtil.RO_CARE_SUPPLIES_RECORDTYPE_ID + '\' ';
//                        roList = Database.query(strQuery);
                    if(!returnOrderList.isEmpty()){
                        for(ReturnOrder ro : returnOrderList){
                            if(carePlustOrderNo.equals(ro.Order_Number__c)){
                                roList.add(ro);
                            }
                        }
                    }
                    String prId = '';
                    if(!productRequestList.isEmpty()){
                        for(ProductRequest pr : productRequestList){
                            if(carePlustOrderNo.equals(pr.Order_Number__c)){
                                prId = pr.Id;
                            }
                        }
                    }
                    String prliId = '';
                    if(!productRequestLineItemList.isEmpty()){
                        for(ProductRequestLineItem prli : productRequestLineItemList){
                            if(carePlustOrderNo.equals(prli.Order_Number__c) && sPartNo.equals(prli.PART_NO__c)){
                                prliId = prli.Id;
                            }
                        }
                    }
                    if(roList.isEmpty()){ //Insert
                        /** ReturnOrder */
                        ReturnOrder ro = new ReturnOrder();
                        ro = setReturnOrder(lData, ro, prId, false);
                        //roList.add(ro);
                        //insert ro;
                        insertRoList.add(ro);
                        /** ReturnOrderLineItem */
                        ReturnOrderLineItem roli = new ReturnOrderLineItem();
                        roli = setReturnOrderLineItem(lData, ro, roli, mPartData, prliId, false);
                        //roliList.add(roli);
                        //insert roli;
                        insertRoliList.add(roli);
                    }else{ //Update
                        for(ReturnOrder ro : roList){
                            /** ReturnOrder */
                            ro = setReturnOrder(lData, ro, prId, true);
                            listUpsertRO.add(ro);
                            /** ReturnOrderLineItem */
//                                strQuery = '';
//                                strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrderLineItem');
//                                strQuery += ' FROM ReturnOrderLineItem ';
//                                strQuery += ' WHERE ReturnOrderId = \'' + getStringNotNull(ro.get('Id')) + '\' ';
//                                List<ReturnOrderLineItem> existRoliList = Database.query(strQuery);
                            List<ReturnOrderLineItem> existRoliList = new List<ReturnOrderLineItem>();
                            if(!returnOrderLineItemList.isEmpty()){
                                for(ReturnOrderLineItem roli : returnOrderLineItemList){
                                    if(getStringNotNull(ro.get('Id')).equals(roli.ReturnOrderId)){
                                        existRoliList.add(roli);
                                    }
                                }
                            }
                            if(existRoliList.isEmpty()){ //기존 ReturnOrderLineItem 없으면
                                ReturnOrderLineItem roli = new ReturnOrderLineItem();
                                //roli도 기존 것 검사
                                roli = setReturnOrderLineItem(lData, ro, roli, mPartData, prliId, false);
                                roliList.add(roli);
                                listUpsertROLI.add(roli);
                            }else{ //기존 ReturnOrderLineItem 있으면
                                for(ReturnOrderLineItem roli : existRoliList){
                                    roli = setReturnOrderLineItem(lData, ro, roli, mPartData, prliId, true);
                                    roliList.add(roli);
                                    listUpsertROLI.add(roli);
                                }
                            }
                        }
                        System.debug('Upsert ReturnOrder : ' + roList);
                        //upsert roList;
                        System.debug('Upsert ReturnOrderLineItem : ' + roliList);
                        //upsert roliList;
                    }

                    /** SI_CAREPLUS_BACKIF 테이블에 저장 */
                    /** 출고수량 */
                    //lData.put('SHIPPED_QTY__c', 0);
                    /** SMILE 판매금액 */
                    //lData.put('SHIP_AMT__c', 0);
                    /** BACK_IF_STATUS */
                    //lData.put('BACK_IF_STATUS__c', backIfStatus);
                    /** TRANSFER_FLAG */
                    lData.put('TRANSFER_FLAG__c', 'N');
                    /** TRANSFER_DATE */
                    //lData.put('TRANSFER_DATE__c', '');
                    /** BACK_IF_ERROR_DESC */
                    //lData.put('BACK_IF_ERROR_DESC__c', sAttribute1);
                    lData.put('ATTRIBUTE1__c', '');

                    /** SI_CAREPLUS_BACKIF 테이블에 저장 */
                    //APPROVE 상태로 한번만 송신

                    if ('SUCCESS'.equals(result)) {
                        /** 반품자동승인 */
                        lData.put('WORK_FLAG__c', 'R');

                        /**	SR_CAREPLUS_ORDER 상태값 변경	*/
                        //roli.Return_Request_Status__c = 'C'; (요청중 : N, 반품확정 : C, 반품완료 : Y, 반품반려 : X)
                        //roli.CONSUMABLE_ORDER_STATUS_120 = '120'; // 반품확정
                        //roli.CONFIRM_YN__c = 'Y'; // 반품 확정 여부
                        for(ReturnOrderLineItem roli : roliList){
                            /*update new ReturnOrderLineItem(
                                    Id = roli.Id,
                                    Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_120,
                                    Return_Request_Status__c = 'C',
                                    CONFIRM_YN__c = 'Y'
                            );*/
                            ReturnOrderLineItem roli_u = new ReturnOrderLineItem();
                            roli_u.Id = roli.Id;
                            roli_u.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_120;
                            roli_u.Return_Request_Status__c = 'C';
                            roli_u.CONFIRM_YN__c = 'Y';
                            listUpdateROLI.add(roli_u);
                        }

                        backIfStatus = 'APPROVED';
                        //lData.put('BACK_IF_STATUS__c', backIfStatus);

                        /** SI_CAREPLUS_BACKIF 데이터 생성	*/
                        System.debug('InsertCareplusBackIf Status: ' + backIfStatus + ', data : ' + lData);
                        SI_CAREPLUS_BACKIF__c siB = new SI_CAREPLUS_BACKIF__c();
                        siB = EX_CarePlusOrder.insertCareplusBackIf(lData, backIfStatus, sAttribute1, 0, 0, loopCnt, backIfMaxInterfaceId, backIfSubMaxInterfaceId);
                        listInsertSiBackIf.add(siB);
                        result = 'SUCCESS';
                        loopCnt++;
                    }
                }//for siCarePlusOrderList


                if(!insertRoList.isEmpty()){
                    insert insertRoList;
                    system.debug('INSERT RO TOTAL : ' + insertRoList.size());

                    if(!insertRoliList.isEmpty()) {
                        for (ReturnOrderLineItem roli : insertRoliList) {
                            for (ReturnOrder ro : insertRoList) {
                                if (roli.Order_Number__c == ro.Order_Number__c) {
                                    roli.ReturnOrderId = ro.Id;
                                    break;
                                }
                            }
                        }
                        insert insertRoliList;
                        system.debug('INSERT ProductRequest TOTAL : ' + insertRoliList.size());
                    }
                }
                if(!UpdateSiCareplusOrderList.isEmpty()){
                    update UpdateSiCareplusOrderList;
                    system.debug('UPDATE SI_CAREPLUS_ORDER__c TOTAL : ' + UpdateSiCareplusOrderList.size());
                }
                if(!listUpsertRO.isEmpty()){
                    upsert listUpsertRO;
                    system.debug('UPSERT ReturnOrder TOTAL : ' + listUpsertRO.size());
                }
                if(!listUpsertROLI.isEmpty()){
                    upsert listUpsertROLI;
                    system.debug('UPSERT ReturnOrderLineItem TOTAL : ' + listUpsertROLI.size());
                }
                if(!listUpdateROLI.isEmpty()){
                    update listUpdateROLI;
                    system.debug('UPDATE ReturnOrderLineItem TOTAL : ' + listUpdateROLI.size());
                }
                if(!listInsertSiBackIf.isEmpty()){
                    Insert listInsertSiBackIf;
                    system.debug('INSERT SI_CAREPLUS_BACKIF__c TOTAL : ' + listInsertSiBackIf.size());
                }

            }else{
                objOutput.code = '500';
                objOutput.message = '케어플러스 반품수신 실패. SI_CAREPLUS_ORDER__c 데이터 없음.';
                Database.rollback(sp);
            }//siCarePlusOrderList isEmpty
        }catch (JSONException je){
            System.debug('*** je.getMessage: ' + je.getMessage());
            System.debug('*** je.getLine -> ' + je.getLineNumber());
            objOutput.code = '500';
            objOutput.message = 'reason:'+je.getMessage();
            Database.rollback(sp);
        } catch (NullPointerException ne){
            System.debug('*** ne.getMessage: ' + ne.getMessage());
            System.debug('*** ne.getLine -> ' + ne.getLineNumber());
            objOutput.code = '500';
            objOutput.message = ' 조회된 값이 없습니다.  '+ ne.getMessage();
            Database.rollback(sp);
        } catch (Exception e) {
            System.debug('*** e.getMessage: ' + e.getMessage());
            System.debug('*** e.getLine -> ' + e.getLineNumber());
            objOutput.code = '500';
            objOutput.message =  e.getMessage();
            Database.rollback(sp);
        }

        return objOutput;
    }

    @AuraEnabled
    public static ReturnOrder setReturnOrder(sObject lData, ReturnOrder ro, Id prId, Boolean existRo) {

        String carePlustOrderNo = getStringNotNull(lData.get('ORDER_NO__c'));

        ro.RecordTypeId = EX_ConsumableUtil.RO_CARE_SUPPLIES_RECORDTYPE_ID;

        if(!existRo){
            ro.ProductRequestId = prId;
        }

        // 주문 고객 Contact Id
        //ro.Order_CUST_Id__c = contactId;//////////////////////////////////////////////////////
        // 소모품 주문 여부
        ro.Consumables_Order_YN__c = true;
        // 소모품 주문 구분 /  일반 주문 : General, 품절 주문 : Sold Out
        ro.Consumables_Order_Class_Code__c = 'General';
        // [소모품 업무 유형] 주문 : Order, 주문취소 : Cancel, 반품 : Return, 교환 : Exchange, PO(요청) : PO
        ro.Consumables_Business_Type_Code__c = 'Return';
        // [주문 채널] 대표 사이트 : B, ThinQ : S, CIC소모품택배 : V, 베스트샵 : BestShop
        ro.Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;
        //주문번호
        ro.Order_Number__c = carePlustOrderNo; //P로 시작해야함(BestShop)

        // 수취인 명
        ro.CONSIGNEE_Name__c = getStringNotNull(lData.get('RECEIVER_NAME__c'));
        // 수취인 전화번호1
        ro.CONSIGNEE_TPNO_1__c = getStringNotNull(lData.get('RECEIVER_PHONE_NO__c'));
        // 수취인 주소
        ro.CONSIGNEE_Address__c = getStringNotNull(lData.get('BASIC_ADDRESS__c'));
        // 수취인 상세 주소
        ro.CONSIGNEE_Address_DETAIL__c = getStringNotNull(lData.get('DETAIL_ADDRESS__c'));

//        반품판매금액(RETURN_SALE_Amount__c) - Currency(18, 0)
//        반품할인금액(RETURN_Last_Discount_Amount__c) - Currency(18, 0)
//        반품결제금액(RETURN_PAYMENT_Amount__c) - Currency(18, 0)
//        반품가상계좌결제금액(RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c) - Currency(18, 0)
//        반품카드결제금액(RETURN_CARD_PAYMENT_Amount__c) - Currency(18, 0)
//        반품포인트금액(RETURN_POINT_Amount__c) - Currency(18, 0)
//        OBS반품주문번호(OBS_RETURN_Order_Number__c) - Text(20)

        return ro;
    }

    @AuraEnabled
    public static ReturnOrderLineItem setReturnOrderLineItem(sObject lData, ReturnOrder ro, ReturnOrderLineItem roli, List<Product2> p2List, Id prliId, Boolean existRoli) {
        /* 주문수량 */
        Integer orderQty = getIntegerNotNull(lData.get('ORDER_QTY__c'));
        /* 사업부코드 */
        String sDivCode = getStringNotNull(lData.get('DIV_CODE__c'));
        /* PART_NO */
        String sPartNo = getStringNotNull(lData.get('PART_NO__c'));
        //주문항번
        Decimal orderSeq = getDecimalNotNull(lData.get('ATTRIBUTE4__c'));

        String workflag = getStringNotNull(lData.get('WORK_FLAG__c'));


        if(!existRoli){ //기존 ReturnOrder 데이터 없으면
            roli.Order_SEQ__c = 1; // 주문 항번
            List<Product2> listProduct2 = new List<Product2>();
            listProduct2 = p2List;
            Id productId;
            if(!listProduct2.isEmpty()){
                for(Product2 p : listProduct2){
                    productId = p.Id;
                }
                // 소모품 주문 품목의 파트 Id
                roli.Product2Id = productId;
                roli.BASIS_COLLECT_Parts__c = productId;
            }
            roli.SUB_Order_Number__c = ro.Order_Number__c + '-001-02'; //케어용품 주문건은 1개품목 만 주문되어서, '주문번호-001-02' 고정.
            //roli.ReturnOrderId = ro.Id;
        }else{
            if(roli.SUB_Order_Number__c != null && !roli.SUB_Order_Number__c.equals('')){
                Integer no = Integer.valueOf(roli.SUB_Order_Number__c.right(2));
                no++;
                String sno = String.valueOf(no).leftPad(2,'0');
                roli.SUB_Order_Number__c = ro.Order_Number__c + '-001-' + sno;
            }
        }

        roli.RecordTypeId = EX_ConsumableUtil.ROLI_CARE_SUPPLIES_RECORDTYPE_ID;

        // 소모품 주문 번호
        roli.Order_Number__c = ro.Order_Number__c;
        roli.Order_SEQ__c = orderSeq;
        // 소모품 주문 여부
        roli.Consumables_Order_YN__c = true;
        // 소모품 주문 구분
        roli.Consumables_Order_Class_Code__c = 'General';
        // 소모품 업무 유형
        roli.Consumables_Business_Type_Code__c = 'Return';
        // 소모품 주문 채널
        roli.Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;

        if(workflag.equals('E')){
            roli.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_102; //반품대기
            String att1 = getStringNotNull(lData.get('ATTRIBUTE1__c'));
            roli.CONSUMABLES_ERROR__c = '반품오류 : ' + att1;

        }else{
            roli.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_100; //반품요청
        }
        // 소모품 주문 고객 Contact Id
        //roli.Order_CUST_Id__c = contactId;
        // 소모품 주문 품목의 사업부 코드
        roli.ENDP_Code__c = sDivCode;

        // 소모품 주문 품목의 파트 넘버
        roli.Parts_Number__c = sPartNo;

        roli.BASIS_Number__c = ro.Order_Number__c;
        roli.Order_Number__c = ro.Order_Number__c;

        if(!existRoli){
            roli.ProductRequestLineItemId = prliId;
        }
        // 반품 요청 수량
        roli.QuantityReturned = orderQty;

        // 반품 요청 일시
        roli.Return_Order_Request_DTM__c = getDatetimeWithNull(lData.get('ORDER_DATE__c'));
        // 반품 요청자
        //consumableReturnOrderLineItem.Return_Requester_Id_c__c = UserInfo.getUserId();

        // 반품 요청 상태
        // 요청중 : N, 반품확정 : C, 반품완료 : Y, 반품반려 : X
        roli.Return_Request_Status__c = 'N';

        // 원 주문 고객/결제자 Id
        //consumableReturnOrderLineItem.Order_CUST_Id__c = consumableReturnOrderTable.ContactId;

        // 반품 수취인 정보
        roli.CONSIGNEE_Name__c = getStringNotNull(lData.get('RECEIVER_NAME__c'));
        // 반품 수취인 전화번호
        roli.CONSIGNEE_TPNO__c = getStringNotNull(lData.get('RECEIVER_PHONE_NO__c'));
        // 반품 수취인 주소
        roli.CONSIGNEE_Address__c = getStringNotNull(lData.get('BASIC_ADDRESS__c'));
        // 반품 수취인 상세 주소
        roli.CONSIGNEE_Address_DETAIL__c = getStringNotNull(lData.get('DETAIL_ADDRESS__c'));

        roli.DestinationLocationId = EX_ConsumableUtil.getCarePlusWareHouseId();

        // 반품 수거 여부
        roli.COLLECTION_YN__c = false;
        // 반품 확정 여부
        roli.CONFIRM_YN__c = 'N';

//        환불완료여부(REFUND_Complete_YN__c) - Checkbox
//        RED_POINT_TRX_ID__c(RED_POINT_TRX_ID) - Text(20)
//        PG취소결제번호(RETURN_PAYMENT_NO__c) - Text(30)
//        PG취소번호(RETURN_PAYMENT_PTID__c) - Text(30)
//        단가(UnitPrice__c) - Currency(18, 0)
//        소비자가(CONSUMER_Price__c) - Number(18, 0)
//        반품판매금액(RETURN_SALE_Amount__c) - Currency(18, 0)
//        반품할인금액(RETURN_Last_Discount_Amount__c) - Currency(18, 0)
//        반품결제금액(RETURN_PAYMENT_Amount__c) - Currency(18, 0)
//        반품가상계좌결제금액(RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c) - Currency(18, 0)
//        반품카드결제금액(RETURN_CARD_PAYMENT_Amount__c) - Currency(18, 0)
//        반품포인트금액(RETURN_POINT_Amount__c) - Currency(18, 0)
//        OBS반품주문번호(OBS_RETURN_Order_Number__c) - Text(20)


        return roli;
    }

    @AuraEnabled
    public static SI_CAREPLUS_ORDER__c updateSiCarePlusOrderWorkFlag(sObject plData){
        /** SI_CAREPLUS_ORDER 테이블 WORK_FLAG 업데이트 */
        String result = 'SUCCESS';

        String sWorkFlag = getStringNotNull(plData.get('WORK_FLAG__c'));
        String sAttribute1 = getStringNotNull(plData.get('ATTRIBUTE1__c'));
        String sAttribute2 = getStringNotNull(plData.get('ATTRIBUTE2__c'));
        String sAttribute3 = getStringNotNull(plData.get('ATTRIBUTE3__c'));
        String sAttribute4 = getStringNotNull(plData.get('ATTRIBUTE4__c'));
        String sAttribute10 = getStringNotNull(plData.get('ATTRIBUTE10__c'));

        SI_CAREPLUS_ORDER__c siCareplusOrder = new SI_CAREPLUS_ORDER__c();
        siCareplusOrder.Id = Id.valueOf(getStringNotNull(plData.get('Id')));
        siCareplusOrder.WORK_FLAG__c = sWorkFlag;
        siCareplusOrder.ATTRIBUTE1__c = sAttribute1;
        if(!sAttribute2.equals('')){siCareplusOrder.ATTRIBUTE2__c = sAttribute2;}
        if(!sAttribute3.equals('')){siCareplusOrder.ATTRIBUTE3__c = sAttribute3;}
        if(!sAttribute4.equals('')){siCareplusOrder.ATTRIBUTE4__c = sAttribute4;}
        if(!sAttribute10.equals('')){siCareplusOrder.ATTRIBUTE10__c = sAttribute10;}

        System.debug('Update SI_CAREPLUS_ORDER__c Id : ' + siCareplusOrder.Id + ', WORK_FLAG__c : ' + siCareplusOrder.WORK_FLAG__c + ', att1 : ' + sAttribute1);
        //update siCareplusOrder;

        return siCareplusOrder;
    }

    @AuraEnabled
    public static Date getDateWithNull(Object obj) {
        Date dt = null;
        if(obj != null){
            dt = Date.valueOf(obj);
        }
        return dt;
    }

    @AuraEnabled
    public static Datetime getDatetimeWithNull(Object obj) {
        Datetime dt = null;
        if(obj != null){
            dt = Datetime.valueOf(obj);
        }
        return dt;
    }

    @AuraEnabled
    public static String getStringNotNull(Object obj) {
        String str = '';
        if(obj != null){
            str = String.valueOf(obj);
        }
        return str;
    }

    @AuraEnabled
    public static Integer getIntegerNotNull(Object obj) {
        Integer i = 0;
        if(obj != null){
            i = Integer.valueOf(obj);
        }
        return i;
    }

    @AuraEnabled
    public static Double getDoubleNotNull(Object obj) {
        Double d = 0;
        if(obj != null){
            d = Double.valueOf(obj);
        }
        return d;
    }

    @AuraEnabled
    public static Decimal getDecimalNotNull(Object obj) {
        Decimal d = 0;
        if(obj != null){
            d = Decimal.valueOf(Double.valueOf(obj));
        }
        return d;
    }
}