/**
 * Created by A80598 on 2023-03-14.
 */

@RestResource(UrlMapping='/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0011')
global with sharing class EX_CarePlusOrderCancel {
    // /services/apexrest/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0011
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
     * @date  2023-03-14
     * @param
     * @description 케어플러스 인터페이스 후처리 (케어플러스 취소요청)
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
                String inputData = objInput.Body.data.inputData;
            }*/

            objOutput.code = '200';
            objOutput.message = '케어플러스 주문취소 성공.';
            /**
             * Step1. 케어플러스 취소요청 정보 조회
             */

            sObject paramLData = new SI_CAREPLUS_ORDER__c();
            paramLData.put('TRANS_TYPE__c','C');
            paramLData.put('ORDER_NO__c','');

            String strQuery = '';
            strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('SI_CAREPLUS_ORDER__c');
            strQuery += ' FROM SI_CAREPLUS_ORDER__c ';
            strQuery += ' WHERE TRANS_TYPE__c = \'C\' ';
            strQuery += ' AND WORK_FLAG__c IN ( \'N\', \'W\',\'\') ';
            strQuery += ' ORDER BY LAST_UPDATE_DATE__c ASC ';
            //System.debug('strQuery >>> ' + strQuery);

            List<sObject> siCarePlusOrderList = Database.query(strQuery);

            if(!siCarePlusOrderList.isEmpty()){
                System.debug('CarePlus 취소요청 Total : ' + siCarePlusOrderList.size());
                List<String> sPartNoList = new List<String>();
                List<String> orderNoList = new List<String>();
                List<String> sDivCodeList = new List<String>();
                List<Integer> ifIdList = new List<Integer>();
                for (sObject lData : siCarePlusOrderList) {
                    String partNo = getStringNotNull(lData.get('PART_NO__c'));
                    String orderNo = getStringNotNull(lData.get('ORDER_NO__c'));
                    String sDivCode = getStringNotNull(lData.get('DIV_CODE__c'));
                    Integer ifId = getIntegerNotNull(lData.get('INTERFACE_ID__c'));
                    if(!partNo.equals('')){
                        sPartNoList.add(partNo); //파트넘버 리스트
                    }
                    if(!orderNo.equals('')){
                        orderNoList.add(orderNo); //orderNo 리스트
                    }
                    if(!sDivCode.equals('')){
                        sDivCodeList.add(sDivCode);
                    }
                    ifIdList.add(ifId);
                }

                /** ProductRequest 체크 */
                System.debug('ProductRequest 체크');
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

                System.debug('ProductRequestLineItem 체크');
                /** ProductRequestLineItem 체크 */
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
                    strQuery += ' AND Order_CHNL_TYPE_Code__c = \'BestShop\' ';
                    strQuery += ' AND PART_NO__c IN (';
                    Integer j = 0;
                    for(String sPartNo : sPartNoList){
                        if(j == 0){
                            strQuery += '\'' + sPartNo + '\'';
                        }else{
                            strQuery += ',\'' + sPartNo + '\'';
                        }
                        j++;
                    }
                    strQuery += ') ';
                    strQuery += ' AND RecordTypeId = \'' + EX_ConsumableUtil.PRLI_CARE_SUPPLIES_RECORDTYPE_ID + '\' ';
                    productRequestLineItemList = Database.query(strQuery);
                }

                /** ProductRequestLineItem 예약 체크 */
                List<ProductRequestLineItem> rsrvPrliList = new List<ProductRequestLineItem>();
                List<String> rsrvNoList = new List<String>();
                if(!productRequestLineItemList.isEmpty()){
                    for(ProductRequestLineItem oriPrli : productRequestLineItemList){
                        if(oriPrli.RSRV_Number__c != null){
                            rsrvNoList.add(String.valueOf(oriPrli.RSRV_Number__c));
                        }
                    }
                    if(!rsrvNoList.isEmpty()){
                        strQuery = '';
                        strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
                        strQuery += ' FROM ProductRequestLineItem ';
                        strQuery += ' WHERE RSRV_Number__c IN (';
                        Integer i = 0;
                        for(String rsrvNo : rsrvNoList){
                            if(i == 0){
                                strQuery += '\'' + rsrvNo + '\'';
                            }else{
                                strQuery += ',\'' + rsrvNo + '\'';
                            }
                            i++;
                        }
                        strQuery += ') ';
                        strQuery += ' AND Order_CHNL_TYPE_Code__c = \'BestShop\' ';
                        strQuery += ' AND RecordTypeId = \'' + EX_ConsumableUtil.PRLI_RESV_SALE_RECORDTYPE_ID + '\' ';
                        rsrvPrliList = Database.query(strQuery);
                    }
                }

                /** 케어용품 체크 */
                List<product2> mPartDataList = new List<product2>();
                if(!sPartNoList.isEmpty()){
                    mPartDataList = [SELECT Id, DISABLED_DT__c, Name FROM product2 WHERE Name IN :sPartNoList AND CAREPLUS_YN__c = 'Y'];
                    system.debug('케어용품 체크 TOTAL : ' + sPartNoList.size() + ', result : ' + mPartDataList);
                }

                /** 가용재고 조회 */
                System.debug('가용재고 조회');
                List<ProductItem> ProductItemList = [
                        SELECT Id, Product2Id, fm_Available_Quantity__c, DIV_CODE__c, fm_Parts_Number__c
                        FROM ProductItem
                        WHERE fm_Available_Quantity__c >= 0
                        AND fm_DEPT_CODE__c = :F_ST_DEPT_CODE
                        AND DIV_CODE__c IN :sDivCodeList
                        AND fm_Parts_Number__c IN :sPartNoList
                        AND Location.RecordType.DeveloperName = 'Location'
                        AND Location.Name = :System.Label.EX_Location
                ];

                /** 케어플러스 max request */
                List<SI_CAREPLUS_ORDER_REQUEST__c> getRequestMaxList = [SELECT SO_INTERFACE_ID__c FROM SI_CAREPLUS_ORDER_REQUEST__c ORDER BY SO_INTERFACE_ID__c DESC LIMIT 1];
                Integer requestMaxInterfaceId = 0;
                if(!getRequestMaxList.isEmpty()){
                    requestMaxInterfaceId = getIntegerNotNull(getRequestMaxList[0].SO_INTERFACE_ID__c);
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
                AND TRANS_TYPE__c = 'C'
                AND ORDER_NO__c IN :orderNoList
                ORDER BY BACK_SUB_SEQ__c DESC LIMIT 1];

                List<SI_CAREPLUS_BACKIF__c> listInsertSiBackIf = new List<SI_CAREPLUS_BACKIF__c>();
                List<SI_CAREPLUS_ORDER_REQUEST__c> listInsertSiRequest = new List<SI_CAREPLUS_ORDER_REQUEST__c>();
                List<SI_CAREPLUS_ORDER_COMPLETE__c> listUpdateComplete = new List<SI_CAREPLUS_ORDER_COMPLETE__c>();
                List<SI_CAREPLUS_ORDER__c> UpdateSiCareplusOrderList = new List<SI_CAREPLUS_ORDER__c>();
                List<ProductRequestLineItem> listUpdatePRLI1 = new List<ProductRequestLineItem>();
                List<ProductRequestLineItem> listUpdatePRLI = new List<ProductRequestLineItem>();
                List<ProductRequest> upsertPrList = new List<ProductRequest>();
                List<ProductRequestLineItem> upsertPrliList = new List<ProductRequestLineItem>();
                Integer loopCnt = 1;
                Integer loopCnt2 = 1;
                List<ProductRequestLineItem> prliListForExcT = new List<ProductRequestLineItem>();
                List<ProductRequestLineItem> prliListForExcS = new List<ProductRequestLineItem>();
                List<ProductRequestLineItem> prliListForExcAB = new List<ProductRequestLineItem>();

                for (sObject lData : siCarePlusOrderList) {
                    String result = 'SUCCESS';
                    String carePlustOrderNo = getStringNotNull(lData.get('ORDER_NO__c'));
                    String sDivCode = getStringNotNull(lData.get('DIV_CODE__c'));
                    /** ATTRIBUTE1 */
                    String sAttribute1 = '';
                    Integer shipQty = 0;
                    /** 취소수량 */
                    Integer cancelQty = getIntegerNotNull(lData.get('CANCEL_QTY__c'));
                    Datetime cancelDate = getDateWithNull(lData.get('CANCEL_DATE__c'));

                    /* PART_NO */
                    String sPartNo = getStringNotNull(lData.get('PART_NO__c'));

                    /** WROK FLAG */
                    String workFlag = '';
                    /** 현재 WORK FLAG */
                    String nowWorkFlag = getStringNotNull(lData.get('WORK_FLAG__c'));
                    if(nowWorkFlag.equals('')){nowWorkFlag = 'N';}
                    /** 주문취소 인지 반품취소인지 에러취소인지 구분자 */
                    String sCancelGubun = '';
                    /** BACK_IF_STATUS 상태값 */
                    String backIfStatus = '';
                    String sTransType = getStringNotNull(lData.get('TRANS_TYPE__c'));

                    String cancel_flag = getStringNotNull(lData.get('CANCEL_FLAG__c'));
                    String return_flag = getStringNotNull(lData.get('RETURN_FLAG__c'));

                    if(cancel_flag != null && return_flag != null && cancel_flag.equals('Y') && return_flag.equals('Y')){
                        System.debug('반품요청에 대한 취소 요청');
                        /** 반품요청에 대한 취소 요청 */
                        sCancelGubun = 'RC';
                        paramLData.clear();
                        paramLData.put('TRANS_TYPE__c','R');
                        paramLData.put('ORDER_NO__c',carePlustOrderNo);
                    }else if(cancel_flag != null && return_flag != null && cancel_flag.equals('Y') && (return_flag.equals('N') || return_flag.equals(''))) {
                        System.debug('순수 주문에 대한 취소 요청');
                        /** 순수 주문에 대한 취소 요청 */
                        sCancelGubun = 'C';
                        paramLData.clear();
                        paramLData.put('TRANS_TYPE__c','O');
                        paramLData.put('ORDER_NO__c',carePlustOrderNo);
                    }

                    // ProductRequest, ProductRequestLineItem 정보 조회 param: paramLData
                    /** ProductRequest, ProductRequestLineItem Upsert */
//                    strQuery = '';
//                    strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequest');
//                    strQuery += ' FROM ProductRequest ';
//                    strQuery += ' WHERE Order_Number__c = \'' + carePlustOrderNo + '\' ';
//                    strQuery += ' AND Order_CHNL_TYPE_Code__c = \'BestShop\' ';
//                    strQuery += ' AND RecordTypeId = \'' + EX_ConsumableUtil.PR_CARE_SUPPLIES_RECORDTYPE_ID + '\' ';
//                    List<SObject> prList = Database.query(strQuery);

                    List<ProductRequest> prList = new List<ProductRequest>();
                    if(!productRequestList.isEmpty()){
                        for(ProductRequest pr : productRequestList){
                            if(carePlustOrderNo.equals(pr.Order_Number__c)){
                                prList.add(pr);
                            }
                        }
                    }

                    Integer backIfSubMaxInterfaceId = 0;
                    if(!getBackIfSubMaxList.isEmpty()){
                        for(SI_CAREPLUS_BACKIF__c scb : getBackIfSubMaxList){
                            if(scb.INTERFACE_ID__c == getDecimalNotNull(lData.get('INTERFACE_ID__c')) && scb.ORDER_NO__c == carePlustOrderNo){
                                backIfSubMaxInterfaceId = getIntegerNotNull(getBackIfSubMaxList[0].BACK_SUB_SEQ__c);
                            }
                        }
                    }

                    /** 케어용품 체크 */
                    List<Product2> mPartData = new List<Product2>();
                    //List<ProductItem> mPartData = [SELECT Id, Product2.DISABLED_DT__c, fm_Parts_Number__c FROM ProductItem WHERE fm_Parts_Number__c = :sPartNo AND product2.CAREPLUS_YN__c = 'Y'];
                    for(Product2 pd : mPartDataList){
                        if(sPartNo.equals(pd.Name)){
                            mPartData.add(pd);
                        }
                    }

                    List<ProductItem> piforPrli = new List<ProductItem>();
                    if(!ProductItemList.isEmpty()){
                        for(ProductItem pi : ProductItemList){
                            if(pi.DIV_CODE__c.equals(sDivCode) && pi.fm_Parts_Number__c.equals(sPartNo)){
                                piforPrli.add(pi);
                            }
                        }
                    }

                    List<sObject> prliDataList = new List<sObject>();

                    if(prList.isEmpty()){
                        workFlag = 'C';
                        backIfStatus = 'CANCELLED';
                        result = 'SUCCESS';
                    }else{
                        for(sObject pr : prList){
                            /** ProductRequestLineItem */
//                            strQuery = '';
//                            strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
//                            strQuery += ' FROM ProductRequestLineItem ';
//                            strQuery += ' WHERE parentId = \'' + getStringNotNull(pr.get('Id')) + '\' ';
//                            List<sObject> existPrliList = Database.query(strQuery);
                            List<ProductRequestLineItem> existPrliList = new List<ProductRequestLineItem>();
                            if(!productRequestLineItemList.isEmpty()){
                                for(ProductRequestLineItem prli : productRequestLineItemList){
                                    if(carePlustOrderNo.equals(prli.Order_Number__c) && sPartNo.equals(prli.PART_NO__c)){
                                        existPrliList.add(prli);
                                    }
                                }
                            }
                            prliDataList = existPrliList;
                            for(sObject rtnLdata : existPrliList){
                                String consumablesOrderStatus = getStringNotNull(rtnLdata.get('Consumables_Order_Status__c'));
                                system.debug('consumablesOrderStatus : ' + consumablesOrderStatus);
                                Integer rCancelQty = getIntegerNotNull(rtnLData.get('QuantityRequested'));
                                if(cancelQty != null && rCancelQty != null && cancelQty == rCancelQty){ //원주문 주문수량 == 취소요청 취소수량
                                    if ('RC'.equals(sCancelGubun)) { //반품요청에 대한 취소 요청
                                        if (consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_100)){ //반품요청
                                            workFlag = 'C';
                                            backIfStatus = 'CANCELLED';
                                            result = 'SUCCESS';
                                        } else { //에러
                                            workFlag = 'E';
                                            backIfStatus = 'CANCEL_ERROR';
                                            result = 'SUCCESS';
                                        }
                                    }else if ('C'.equals(sCancelGubun)) { //순수 주문에 대한 취소 요청
                                        /** Y : 판매대기, S : 판매완료, R : 예약, E : 에러 */
                                        //String prliWorkFlag = getStringNotNull(rtnLData.get('WORK_FLAG__c')); //XXXX
                                        //if (consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006)){ //Y,S 상품준비중
                                        if (consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_010) || consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_030) || consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_070)){ //Y,S 배송준비중,배송중,배송완료
                                            workFlag = 'E';
                                            backIfStatus = 'CANCEL_ERROR';
                                            result = 'SUCCESS';
                                        } else if (consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_002)){ //R 결제완료, 예약
                                            if (!'W'.equals(nowWorkFlag)) {
                                                workFlag = 'C';
                                                backIfStatus = 'CANCELLED';

                                                Decimal orderQty = getDecimalNotNull(rtnLdata.get('QuantityRequested'));
                                                Decimal endpRsvQty = getDecimalNotNull(rtnLData.get('ENDP_RSV_Quantity__c'));

                                                ProductRequestLineItem prli_u = new ProductRequestLineItem();
                                                prli_u = cancelProductRequestLineItem(rtnLData, cancelQty, cancelDate, workFlag);
                                                listUpdatePRLI1.add(prli_u);
                                                result = 'SUCCESS';

                                                ProductRequestLineItem prli = (ProductRequestLineItem) rtnLData;
                                                if(orderQty == endpRsvQty){ //입고 : 요청수량 == 입고수량
                                                    System.debug('T 약속취소(입고상태)');
                                                    //EX_RsrvUtil.execApplyProductItem(cancelQty, 'T', prli); //T 약속취소(입고상태)
                                                    prliListForExcT.add(prli); //T 약속취소(입고상태)
//                                                    if(!rsrvPrliList.isEmpty()){
//                                                        ProductRequestLineItem rsrvPrli = new ProductRequestLineItem();
//                                                        for(ProductRequestLineItem rsrv : rsrvPrliList){
//                                                            if(prli.RSRV_Number__c != null && prli.RSRV_Number__c != null && rsrv.RSRV_Number__c == prli.RSRV_Number__c && rsrv.RSRV_SEQ__c == prli.RSRV_SEQ__c){
//                                                                rsrvPrli = rsrv;
//                                                            }
//                                                        }
//                                                        prliListForExcT.add(rsrvPrli); //T 약속취소(입고상태)
//                                                    }
                                                    workFlag = 'E';
                                                    backIfStatus = 'CANCEL_ERROR';
                                                }else{ //미출고
                                                    System.debug('S 약속취소(미출고)');
                                                    //EX_RsrvUtil.execApplyProductItem(cancelQty, 'S', prli); //S 약속취소(미출고)
                                                    prliListForExcS.add(prli); //S 약속취소(미출고)
//                                                    if(!rsrvPrliList.isEmpty()){
//                                                        ProductRequestLineItem rsrvPrli = new ProductRequestLineItem();
//                                                        for(ProductRequestLineItem rsrv : rsrvPrliList){
//                                                            if(prli.RSRV_Number__c != null && prli.RSRV_Number__c != null && rsrv.RSRV_Number__c == prli.RSRV_Number__c && rsrv.RSRV_SEQ__c == prli.RSRV_SEQ__c){
//                                                                rsrvPrli = rsrv;
//                                                            }
//                                                        }
//                                                        prliListForExcS.add(rsrvPrli); //S 약속취소(미출고)
//                                                    }
                                                }
                                            }
                                        } else if (consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006) || consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_001) || getDecimalNotNull(rtnLData.get('UnitPrice__c')) > 0) { //상품준비중 or H I O D 결제요청 or 단가 있으면
                                            result = 'SUCCESS';
                                            workFlag = 'C';
                                            backIfStatus = 'CANCELLED';

                                            ProductRequestLineItem prli_u = new ProductRequestLineItem();
                                            prli_u = cancelProductRequestLineItem(rtnLData, cancelQty, cancelDate, workFlag);
                                            listUpdatePRLI1.add(prli_u);

                                            ProductRequestLineItem prli = (ProductRequestLineItem) rtnLData;
                                            prliListForExcAB.add(prli); //AA 할당수량(-)
                                        }
                                    }// 반품, 순수주문 chk 끝
                                }else {
                                    workFlag = 'E';
                                    backIfStatus = 'CANCEL_ERROR';
                                    result = 'SUCCESS';
                                    sAttribute1 = sAttribute1 + '원주문 주문수량과 취소요청 취소수량이 다릅니다.';
                                }//원주문수량 취소수량 체크 끝
                            }//for ProductRequestLineItem
                        }//for ProductRequest
                    }//prList empty check

                    if (!'SUCCESS'.equals(result)) {
                        workFlag = 'E';
                        sAttribute1 = sAttribute1 + result;
                    }

                    if ('W'.equals(nowWorkFlag) && ''.equals(workFlag)) {
                        workFlag = nowWorkFlag;
                    }

                    String cancelFlag = '';

                    if ('C'.equals(workFlag)) {
                        cancelFlag = 'Y';
                    }

                    if (!nowWorkFlag.equals(workFlag)) {
                        if ('RC'.equals(sCancelGubun)) { //반품요청에 대한 원주문 취소 처리
                            System.debug('반품요청에 대한 원주문 취소 처리');
                            if(prList.isEmpty()){
                                if ('C'.equals(workFlag)) {
                                    lData.put('WORK_FLAG__c', workFlag);
                                    lData.put('TRANS_TYPE__c', 'R');
//                                    SI_CAREPLUS_ORDER__c siCareplusOrder = new SI_CAREPLUS_ORDER__c();
//                                    siCareplusOrder = updateSiCarePlusOrderWorkFlag(lData);
//                                    UpdateSiCareplusOrderList.add(siCareplusOrder);
                                    result = 'SUCCESS';
                                }
                            }else{
                                if ('C'.equals(workFlag)) {
                                    if ('SUCCESS'.equals(result)) {
//                                        paramLData.clear();
//                                        paramLData.put('WORK_FLAG__c', workFlag);
                                        if(!prliDataList.isEmpty()){
                                            for(sObject prliData : prliDataList){
                                                ProductRequestLineItem prli_u = new ProductRequestLineItem();
                                                prli_u = cancelProductRequestLineItem(prliData, cancelQty, cancelDate, workFlag);
                                                listUpdatePRLI.add(prli_u);
                                                result = 'SUCCESS';
                                            }
                                        }
                                        if ('SUCCESS'.equals(result)) {
//                                            paramLData.put('Id', Id.valueOf(getStringNotNull(lData.get('Id'))));
//                                            SI_CAREPLUS_ORDER__c siCareplusOrder = new SI_CAREPLUS_ORDER__c();
//                                            siCareplusOrder = updateSiCarePlusOrderWorkFlag(paramLData);
//                                            UpdateSiCareplusOrderList.add(siCareplusOrder);
                                            result = 'SUCCESS';
                                        }

                                    }
                                }
                            }
                        }else if ('C'.equals(sCancelGubun)) { // 정상주문에 대한 취소처리
                            System.debug('정상주문에 대한 취소처리');
                            if(prList.isEmpty()){
                                if ('C'.equals(workFlag)) {
                                    lData.put('WORK_FLAG__c', workFlag);
                                    lData.put('TRANS_TYPE__c', 'O');
//                                    SI_CAREPLUS_ORDER__c siCareplusOrder = new SI_CAREPLUS_ORDER__c();
//                                    siCareplusOrder = updateSiCarePlusOrderWorkFlag(lData);
//                                    UpdateSiCareplusOrderList.add(siCareplusOrder);
                                    result = 'SUCCESS';
                                    result = 'SUCCESS';
                                }
                            }else{
                                if ('C'.equals(workFlag) || 'W'.equals(workFlag)) {
                                    if ('SUCCESS'.equals(result)) {
//                                        paramLData.clear();
//                                        paramLData.put('WORK_FLAG__c', workFlag);
                                        if(!prliDataList.isEmpty()){
                                            for(sObject prliData : prliDataList){
                                                ProductRequestLineItem prli_u = new ProductRequestLineItem();
                                                prli_u = cancelProductRequestLineItem(prliData, cancelQty, cancelDate, workFlag);
                                                listUpdatePRLI.add(prli_u);
                                                result = 'SUCCESS';
                                            }
                                        }
//                                        if ('SUCCESS'.equals(result)) {
//                                            paramLData.put('Id', Id.valueOf(getStringNotNull(lData.get('Id'))));
//                                            SI_CAREPLUS_ORDER__c siCareplusOrder = new SI_CAREPLUS_ORDER__c();
//                                            siCareplusOrder = updateSiCarePlusOrderWorkFlag(paramLData);
//                                            UpdateSiCareplusOrderList.add(siCareplusOrder);
//                                            result = 'SUCCESS';
//                                        }
                                    }
                                }
                            }
                        } // 반품/정상주문에 대한 취소처리

                        if ('SUCCESS'.equals(result)) {
                            lData.put('CANCEL_FLAG__c', cancelFlag);
                            lData.put('TRANS_TYPE__c', 'C');
                            /** SI_CARE_PLUS_ORDER 테이블 WORK_FLAG 업데이트 */
                            lData.put('WORK_FLAG__c', workFlag);
                            lData.put('ATTRIBUTE1__c', sAttribute1);
                            //lData.put('BACK_IF_SEND_YN__c', 'Y');

                            SI_CAREPLUS_ORDER__c siCareplusOrder = new SI_CAREPLUS_ORDER__c();
                            siCareplusOrder = updateSiCarePlusOrderWorkFlag(lData);
                            UpdateSiCareplusOrderList.add(siCareplusOrder);
                            result = 'SUCCESS';

                            if (!'W'.equals(workFlag)) {
                                //lData.put('SHIP_QTY__c', shipQty);
                                lData.put('CANCEL_QTY__c', cancelQty);

                                if ('SUCCESS'.equals(result)) {

                                    if(prList.isEmpty()){ //Insert 없음
                                        /** ProductRequest */
//                                        ProductRequest pr = new ProductRequest();
//                                        pr = EX_CarePlusOrder.setProductRequest(lData, pr);
//                                        insert pr;

                                        /** ProductRequestLineItem */
//                                        ProductRequestLineItem prli = new ProductRequestLineItem();
//                                        prli = EX_CarePlusOrder.setProductRequestLineItem(lData, pr, prli, mPartData, piforPrli, false);
//                                        insert prli;
                                    }else{ //Update
//                                        for(ProductRequest pr : prList){
//                                            /** ProductRequest */
//                                            pr = EX_CarePlusOrder.setProductRequest(lData, pr);
//                                            /** ProductRequestLineItem */
//                                            if(prliDataList.isEmpty()){ //기존 ProductRequestLineItem 없으면
//                                                ProductRequestLineItem prli = new ProductRequestLineItem();
//                                                //prli도 기존 것 검사
//                                                prli = EX_CarePlusOrder.setProductRequestLineItem(lData, pr, prli, mPartData, piforPrli, false);
//                                                upsertPrliList.add(prli);
//                                            }else{ //기존 ProductRequestLineItem 있으면
//                                                for(sObject sOprli : prliDataList){
//                                                    ProductRequestLineItem prli = new ProductRequestLineItem();
//                                                    prli = (ProductRequestLineItem) sOprli;
//                                                    prli = EX_CarePlusOrder.setProductRequestLineItem(lData, pr, prli, mPartData, piforPrli, false);
//                                                    upsertPrliList.add(prli);
//                                                }
//                                            }
//                                        }
                                    }
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
                                if ('SUCCESS'.equals(result)) {
                                    SI_CAREPLUS_BACKIF__c siB = new SI_CAREPLUS_BACKIF__c();
                                    System.debug('CarePlus Back Interface 생성 시작');
                                    siB = EX_CarePlusOrder.insertCareplusBackIf(lData, backIfStatus, sAttribute1, shipQty, 0, loopCnt, backIfMaxInterfaceId, backIfSubMaxInterfaceId);
                                    listInsertSiBackIf.add(siB);
                                    result = 'SUCCESS';
                                    loopCnt++;
                                }

                                /**
                                 * CAREPLUS 3차 취소 일때  SMILE->ERP 주문취소 요청  I/F
                                 * 순수 원주문에 대한 취소 일때만 처리
                                 */
                                System.debug('CAREPLUS 3차 취소 일때  SMILE->ERP 주문취소 요청  I/F 작업시작');
                                if(!prliDataList.isEmpty()){
                                    for(sObject prli : prliDataList){
                                        if('C'.equals(sCancelGubun)){
                                            if ('SUCCESS'.equals(result)) {
                                                if('CANCELLED'.equals(backIfStatus)){
                                                    //String sPartNo = getStringNotNull(prli.get('PART_NO__c'));
                                                    /** ERP 주문생성 결과 조회 */
                                                    System.debug('ERP 주문생성 결과 조회');
                                                    List<SI_CAREPLUS_ORDER_COMPLETE__c> orderCompleteMDataList = EX_CarePlusOrder.getSiCareplusOrderComplete(carePlustOrderNo, sPartNo, '', 'CP');
                                                    if(!orderCompleteMDataList.isEmpty()){ //ERP 주문생성 결과 조회 있음
                                                        SObject orderRequestLData = ldata;
                                                        /** ERP 데이터 전송 (SI_CAREPLUS_ORDER_REQUEST__c) */
                                                        System.debug('ERP 데이터 전송 (SI_CAREPLUS_ORDER_REQUEST__c)');
                                                        SI_CAREPLUS_ORDER_REQUEST__c siR = new SI_CAREPLUS_ORDER_REQUEST__c();
                                                        siR = EX_CarePlusOrder.insertSiCareplusOrderRequest(orderRequestLData, false, orderCompleteMDataList[0].LINE_ID__c, loopCnt2, requestMaxInterfaceId);
                                                        listInsertSiRequest.add(siR);
                                                        result = 'SUCCESS';
                                                        loopCnt2++;

                                                        if('N'.equals(orderCompleteMDataList[0].WORK_FLAG__c)){
                                                            if ('SUCCESS'.equals(result)) {
                                                                SI_CAREPLUS_ORDER_COMPLETE__c orderCompleteMData = (SI_CAREPLUS_ORDER_COMPLETE__c) orderCompleteMDataList[0];
                                                                /*update new SI_CAREPLUS_ORDER_COMPLETE__c(
                                                                        Id = orderCompleteMData.Id,
                                                                        WORK_FLAG__c = 'Y',
                                                                        WORK_DATE__c = Date.today()
                                                                );*/

                                                                SI_CAREPLUS_ORDER_COMPLETE__c siC = new SI_CAREPLUS_ORDER_COMPLETE__c();
                                                                siC.Id = orderCompleteMData.Id;
                                                                siC.WORK_FLAG__c = 'Y';
                                                                siC.WORK_DATE__c = System.now();
                                                                listUpdateComplete.add(siC);
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    } //for prliDataList
                                }// prliDataList.isEmpty
                            }
                        }
                    }// !nowWorkFlag.equals(workFlag)
                }//for siCarePlusOrderList

                if(!listInsertSiRequest.isEmpty()){
                    Insert listInsertSiRequest;
                    system.debug('INSERT SI_CAREPLUS_ORDER_REQUEST TOTAL : ' + listInsertSiRequest.size());
                }
                if(!listUpdateComplete.isEmpty()){
                    update listUpdateComplete;
                    system.debug('UPDATE SI_CAREPLUS_ORDER_COMPLETE TOTAL : ' + listUpdateComplete.size());
                }
                if(!UpdateSiCareplusOrderList.isEmpty()){
                    update UpdateSiCareplusOrderList;
                    system.debug('UPDATE SI_CAREPLUS_ORDER__c TOTAL : ' + UpdateSiCareplusOrderList.size());
                }
                if(!listUpdatePRLI1.isEmpty()){
                    update listUpdatePRLI1;
                    system.debug('UPDATE ProductRequestLineItem 선행 TOTAL : ' + listUpdatePRLI1.size());
                }
                List<Map<String, Object>> rsrvCancelMapList = new List<Map<String, Object>>();
                if(!prliListForExcT.isEmpty()){
                    for(ProductRequestLineItem prliT : prliListForExcT){
                        Map<String, Object> rsrvCancelMap = new Map<String, Object>();
                        rsrvCancelMap.put('ProductRequestLineItem', prliT);
                        rsrvCancelMap.put('code', 'T');
                        rsrvCancelMapList.add(rsrvCancelMap);
                    }
                    //EX_RsrvUtil.execApplyProductItemMulti('T',prliListForExcT);
                }
                if(!prliListForExcS.isEmpty()){
                    for(ProductRequestLineItem prliS : prliListForExcS){
                        Map<String, Object> rsrvCancelMap = new Map<String, Object>();
                        rsrvCancelMap.put('ProductRequestLineItem', prliS);
                        rsrvCancelMap.put('code', 'S');
                        rsrvCancelMapList.add(rsrvCancelMap);
                    }
                    //EX_RsrvUtil.execApplyProductItemMulti('S',prliListForExcS);
                }
                if(!rsrvCancelMapList.isEmpty()){
                    EX_RsrvUtil.CANCEL_RESRV_MULTI(rsrvCancelMapList);
                }
                if(!prliListForExcAB.isEmpty()){
                    EX_RsrvUtil.execApplyProductItemMulti('AB',prliListForExcAB);
                }

                if(!listUpdatePRLI.isEmpty()){
                    update listUpdatePRLI;
                    system.debug('UPDATE ProductRequestLineItem 후행 TOTAL : ' + listUpdatePRLI.size());
                }
                if(!upsertPrList.isEmpty()){
                    upsert upsertPrList;
                    system.debug('UPSERT ProductRequest TOTAL : ' + upsertPrList.size());
                }
                if(!upsertPrliList.isEmpty()){
                    upsert upsertPrliList;
                    system.debug('UPSERT ProductRequestLineItem TOTAL : ' + upsertPrliList.size());
                }
                if(!listInsertSiBackIf.isEmpty()){
                    Insert listInsertSiBackIf;
                    system.debug('INSERT CarePlus Back Interface TOTAL : ' + listInsertSiBackIf.size());
                }
            }
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
    public static ProductRequestLineItem cancelProductRequestLineItem(sObject rtnLData, Integer cancelQty, Datetime cancelDate, String workFlag){
        system.debug('cancelProductRequestLineItem');
        /** 취소 */
        String result = 'SUCCESS';
        //판매수량 = 판매수량 - 취소수량
        Integer sq = getIntegerNotNull(rtnLData.get('SALE_Quantity__c')) - cancelQty;
        String status = '';
        ProductRequestLineItem  prli = new ProductRequestLineItem();
        prli.Id = Id.valueOf(getStringNotNull(rtnLData.get('Id')));
        if(workFlag.equals('W')){
            status = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_100; //반품요청
            //prli.Consumables_Order_Status__c = status;
            prli.Consumables_Order_Status__c = '100';
        }else{
            status = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_004; //주문취소
            //prli.Consumables_Order_Status__c = status;
            prli.Consumables_Order_Status__c = '004';
            prli.Adjust_Quantity__c = cancelQty;
            prli.SALE_Quantity__c = sq;
            prli.CANCEL_Quantity__c = cancelQty;
            if(cancelDate != null){
                prli.CANCEL_Date__c = cancelDate.date();
                prli.CANCEL_Request_DTM__c = cancelDate;
            }
            prli.CANCEL_User__c = 'SYSTEM';
            prli.CANCEL_UserId__c = UserInfo.getUserId();
            //prli.CANCEL_Reason__c = '케어플러스 주문 취소';
        }

        return prli;
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