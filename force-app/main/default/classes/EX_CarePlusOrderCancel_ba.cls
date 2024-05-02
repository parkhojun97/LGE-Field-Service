/**
 * Created by A80598 on 2023-05-16.
 */

public with sharing class EX_CarePlusOrderCancel_ba implements Database.Batchable<sObject>, Database.Stateful {
    public static String F_ST_DEPT_CODE = 'PH0300';
    public static Integer batchSize = 100;

    //23 11 15 hyuoghn.chun 성공건들 로그작업
    String successCareplusOrderId = 'Success SI_CAREPLUS_ORDER__c ID : ';    

    public EX_CarePlusOrderCancel_ba(Integer bSize){
        if(bSize != null){
            batchSize = bSize;
        }
    }

    public Database.QueryLocator start(Database.BatchableContext param1) {
        /**
         * Step1. 케어플러스 취소요청 정보 조회
         */
        String strQuery = '';
        strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('SI_CAREPLUS_ORDER__c');
        strQuery += ' FROM SI_CAREPLUS_ORDER__c ';
        strQuery += ' WHERE TRANS_TYPE__c = \'C\' ';
        strQuery += ' AND WORK_FLAG__c IN ( \'N\', \'W\',\'\') ';
        //23 12 06 테스트 대비로 커스텀라벨이용해서 쿼리조회(운영엔 아래조건 주석처리로 배포중)
        if(System.Label.EX_carePlusOrderNum != 'none'){
            strQuery += 'AND ORDER_NO__C = \''+System.Label.EX_carePlusOrderNum+'\' ';
        }        
        strQuery += ' ORDER BY LAST_UPDATE_DATE__c ASC ';

        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext param1, List<sObject> siCarePlusOrderList) {
        //23 11 15 hyungho.chun 실패용 로그작업
        Map<String,String> errorMap = new Map<String,String>();
        String recordIdGroup = '';
        if (!siCarePlusOrderList.isEmpty()) {
            for (sObject lData : siCarePlusOrderList) {
                recordIdGroup += 'Id : ' + getStringNotNull(lData.get('Id')) + ', ORDER_NO : '+ getStringNotNull(lData.get('ORDER_NO__c')) + ' ';
            }
        }

        String strQuery = '';
        sObject paramLData = new SI_CAREPLUS_ORDER__c();
        paramLData.put('TRANS_TYPE__c','C');
        paramLData.put('ORDER_NO__c','');
        Savepoint sp = Database.setSavepoint();
        try {
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
                    strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem')+ ', SR_RESRV_PART_Id__r.RESRV_Number__c ';
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
                    // strQuery += ' AND PART_NO__c IN (';
                    // Integer j = 0;
                    // for(String sPartNo : sPartNoList){
                    //     if(j == 0){
                    //         strQuery += '\'' + sPartNo + '\'';
                    //     }else{
                    //         strQuery += ',\'' + sPartNo + '\'';
                    //     }
                    //     j++;
                    // }
                    // strQuery += ') ';
                    strQuery += ' AND RecordTypeId = \'' + EX_ConsumableUtil.PRLI_CARE_SUPPLIES_RECORDTYPE_ID + '\' ';
                    productRequestLineItemList = Database.query(strQuery);
                }
                
                //24 01 26 hyungho.chun returnOrder는 주문번호 원주문과 매칭안되서 미리 조회
                System.debug('ReturnOrderLineItem 체크');
                /** ReturnOrderLineItem 체크 */
                List<ReturnOrderLineItem> returnOrderLineItemList = new List<ReturnOrderLineItem>();
                if(!orderNoList.isEmpty() && !sPartNoList.isEmpty()){
                    strQuery = '';
                    strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrderLineItem') + ', ReturnOrder.RETURN_PAYMENT_Amount__c, ProductRequestLineItem.Order_Number__c, ProductRequestLineItem.PART_NO__c ';
                    strQuery += ' FROM ReturnOrderLineItem ';
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
                    // strQuery += ' AND PART_NO__c IN (';
                    // Integer j = 0;
                    // for(String sPartNo : sPartNoList){
                    //     if(j == 0){
                    //         strQuery += '\'' + sPartNo + '\'';
                    //     }else{
                    //         strQuery += ',\'' + sPartNo + '\'';
                    //     }
                    //     j++;
                    // }
                    // strQuery += ') ';
                    strQuery += ' AND RecordTypeId = \'' + EX_ConsumableUtil.ROLI_CARE_SUPPLIES_RECORDTYPE_ID + '\' ';
                    returnOrderLineItemList = Database.query(strQuery);
                }
                // //24 01 26 hyungho.chun 반품요청철회가 가능한지 체크하기위한 prliid와 roli Map
                // Map<String, ReturnOrderLineItem> prliRoliMap = new Map<String, ReturnOrderLineItem>();
                // for(ReturnOrderLineItem item : returnOrderLineItemList){
                //     if(item.ProductRequestLineItemId != null){
                //         prliRoliMap.put(item.ProductRequestLineItemId, item);
                //     }
                // }
                // //24 02 05 hyungho.chun
                // List<ProductRequestLineItem> prliListFromRoliList = new List<ProductRequestLineItem>();
                // prliListFromRoliList = [SELECT Id, Consumables_Order_Detail__c  FROM ProductRequestLineItem WHERE Id IN: prliRoliMap.keySet()];

                // //24 02 05 hyungho.chun key : roli id / value : prli
                // Map<String, ProductRequestLineItem> roliIdAndprliMap = new Map<String, ProductRequestLineItem>();
                // for(ProductRequestLineItem item : prliListFromRoliList){
                //     if(prliRoliMap.containsKey(item.Id)){
                //         roliIdAndprliMap.put(prliRoliMap.get(item.Id).Id, item);
                //     }
                // }

                /** ProductRequestLineItem 예약 체크 */
                List<ProductRequestLineItem> rsrvPrliList = new List<ProductRequestLineItem>();
                List<String> rsrvNoList = new List<String>();
                Map<String, SI_REQUEST__c> divRequestMap = new Map<String, SI_REQUEST__c>(); //사업부 요청 List
                Map<String, ProductRequestLineItem> prliSaleMap = new Map<String, ProductRequestLineItem>();     
                if(!productRequestLineItemList.isEmpty()){
                    for(ProductRequestLineItem oriPrli : productRequestLineItemList){
                        if(oriPrli.RSRV_Number__c != null){
                            rsrvNoList.add(String.valueOf(oriPrli.RSRV_Number__c));
                        }
                    }
                    if(!rsrvNoList.isEmpty()){
                        strQuery = '';
                        strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem') + ',Product2.Name, Product2.PART_DESC_KOR__c, SR_RESRV_PART_Id__r.RESRV_Number__c  ';
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


                        //24 02 05 hyungho.chun si_request trans_flag에따라 rsrv module 호출 다름
                        //사업부 미요청건에 대한것만 추출 
                        List<SI_REQUEST__c> divRequestList = [SELECT ID, TRANS_FLAG__c, RESV_NO__c FROM SI_REQUEST__c WHERE RESV_NO__c = :rsrvNoList AND TRANS_FLAG__c = 'N'];
                        for (SI_REQUEST__c siObj : divRequestList) {
                            divRequestMap.put(siObj.RESV_NO__c, siObj);
                        }
                        
                        for (ProductRequestLineItem prliSale : rsrvPrliList) {
                            //23.10.19 gw.lee
                            //주문 예약번호 + 항번 추가 조치
                            prliSaleMap.put(prliSale.SR_RESRV_PART_Id__r.RESRV_Number__c + '_' + prliSale.RSRV_SEQ__c, prliSale);
                        }                        
                    }
                }

                /** ReturnOrderLineItem 예약 체크 */
                List<ReturnOrderLineItem> roliList = new List<ReturnOrderLineItem>();
                List<String> prliIdList = new List<String>();
                if(!productRequestLineItemList.isEmpty()) {
                    for (ProductRequestLineItem oriPrli : productRequestLineItemList) {
                        prliIdList.add(oriPrli.Id);
                    }
                    roliList = [SELECT Id, Expected_Return_Quantity__c, Consumables_Order_Status__c, ProductRequestLineItemId FROM ReturnOrderLineItem WHERE ProductRequestLineItemId IN :prliIdList];
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
                List<ReturnOrderLineItem> updateRoliList = new List<ReturnOrderLineItem>();
                Integer loopCnt = 1;
                Integer loopCnt2 = 1;
                List<ProductRequestLineItem> prliListForExcT = new List<ProductRequestLineItem>();
                List<ProductRequestLineItem> prliListForExcS = new List<ProductRequestLineItem>();
                List<ProductRequestLineItem> prliListForExcAE = new List<ProductRequestLineItem>(); //24 02 05 hyungho.chun
                List<ProductRequestLineItem> prliListForExcAB = new List<ProductRequestLineItem>();
                

                Map<String, List<Decimal>> orderNumAndQtyMap = new Map<String,List<Decimal>>(); //24 01 30 hyungho.chun 주문취소시 원careplusOrder cancel Flag 업데이트 및 반품요청철회시 cancel flag + num_att1,2 업데이트 하기위한 맵

                for (sObject lData : siCarePlusOrderList) {
                    String result = 'SUCCESS';
                    String carePlustOrderNo = getStringNotNull(lData.get('ORDER_NO__c'));
                    String carePlustOrderNoFromRoli = ''; //24 02 05 hyungho.chun 반품요청철회건과 연결된 원주문prli의 주문번호 저장할 용도 변수
                    String carePlustPartNoFromRoli = ''; //24 02 05 hyungho.chun 반품요청철회건과 연결된 원주문prli의 파트번호 저장할 용도 변수
                    String sDivCode = getStringNotNull(lData.get('DIV_CODE__c'));
                    /** ATTRIBUTE1 */
                    String sAttribute1 = '';
                    // Integer shipQty = 0;
                    Integer shipQty = getIntegerNotNull(lData.get('ORDER_QTY__c')); //24 03 12 hyungho.chun shipqty는 0을넣지않는다
                    
                    /** 취소수량 */
                    Integer cancelQty = getIntegerNotNull(lData.get('CANCEL_QTY__c'));
                    // Datetime cancelDate = getDateWithNull(lData.get('CANCEL_DATE__c'));
                    //23 09 20 hyungho.chun datetime이니까 datetime으로 받는다 + 시간차이로 -9시간
                    // Datetime cancelDate = getDatetimeWithNull(lData.get('CANCEL_DATE__c')).addHours(-9);
                    Datetime cancelDate = getDatetimeWithNull(lData.get('CANCEL_DATE__c')); //24 03 11 hyungho.chun 이제 히로쿠에서 9시간 차감해준후에 보내주기때문에 따로 로직제거

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

                    //24 02 05 hyungho.chun 반품요청철회건은 반품주문에서 찾아야한다 ( 없던 로직 추가 )
                    List<ReturnOrderLineItem> roliListTemp = new List<ReturnOrderLineItem>();
                    if(!returnOrderLineItemList.isEmpty()){
                        for(ReturnOrderLineItem roli : returnOrderLineItemList){
                            if(carePlustOrderNo.equals(roli.Order_Number__c)){
                                roliListTemp.add(roli);
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

                    List<sObject> prliDataList = new List<sObject>(); //24 02 05 hyungho.chun 이름은 prliDataList지만 반품요철철회땐 roli 타입이다

                    // if(prList.isEmpty()){
                    if((prList.isEmpty() && sCancelGubun == 'C') || (roliListTemp.isEmpty() && sCancelGubun == 'RC')){
                        // workFlag = 'C';
                        // backIfStatus = 'CANCELLED';
                        workFlag = 'E';
                        backIfStatus = 'CANCEL_ERROR'; //24 02 05 hyungho.chun 주문취소건인데 매칭되는 ProductRequest가 없음
                        result = 'SUCCESS';
                        sAttribute1 = sAttribute1 + '해당 주문번호에 매칭되는 원주문건이 없습니다.'; //24 02 05 hyungho.chun  att1 오류 메세지 추가
                    }else{
                        //24 02 05 hyungho.chun 주문취소건부분따로 반품요청철회건따로 태워야함
                        if(sCancelGubun == 'C'){ 
                            for(sObject pr : prList){
                                List<ProductRequestLineItem> existPrliList = new List<ProductRequestLineItem>();
                                if(!productRequestLineItemList.isEmpty()){
                                    for(ProductRequestLineItem prli : productRequestLineItemList){
                                        // if(carePlustOrderNo.equals(prli.Order_Number__c) && sPartNo.equals(prli.PART_NO__c)){
                                        if(carePlustOrderNo.equals(prli.Order_Number__c)){ //24 02 05 hyungho.chun PART_NO__c 비교안함
                                            existPrliList.add(prli);
                                        }
                                    }
                                }
                                prliDataList = existPrliList;
                                for(sObject rtnLdata : existPrliList){
                                    String consumablesOrderStatus = getStringNotNull(rtnLdata.get('Consumables_Order_Status__c'));
                                    Integer rCancelQty = getIntegerNotNull(rtnLData.get('QuantityRequested'));
                                    String appStatus = getStringNotNull(rtnLdata.get('Appointment_Status__c'));
                                    String rsrvId = getStringNotNull(rtnLdata.get('SR_RESRV_PART_Id__c'));
                                    if(cancelQty != null && rCancelQty != null && cancelQty == rCancelQty){ //원주문 주문수량 == 취소요청 취소수량
                                        // if ('RC'.equals(sCancelGubun)) { //반품요청에 대한 취소 요청
                                            // if (consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_100)){ //반품요청
                                            // String consumablesOrderDetail = getStringNotNull(rtnLdata.get('Consumables_Order_Detail__c'));
                                            // if (consumablesOrderDetail.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_102)){ //반품요청 //24 01 24 hyungho.chun prli.Consumables_Order_Status__c  로직오류 -> prli.Consumables_Order_Detail__c (반품대기만 가능)
                                            // String currentPrliId = getStringNotNull(rtnLdata.get('Id'));
                                            // if (prliRoliMap.containsKey(currentPrliId) && (prliRoliMap.get(currentPrliId).Consumables_Order_Status__c).equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_102)){ //24 01 26 hyungho.chun returnOrderLineItem의 Consumables_Order_Status__c가 반품대기 일때만
                                            //     workFlag = 'C';
                                            //     backIfStatus = 'CANCELLED';
                                            //     result = 'SUCCESS';
                                            // } else { //에러
                                            //     workFlag = 'E';
                                            //     backIfStatus = 'CANCEL_ERROR';
                                            //     result = 'SUCCESS';
                                            // }
                                        // }else if ('C'.equals(sCancelGubun)) { //순수 주문에 대한 취소 요청
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

                                                    //24 02 05 hyungho.chun
                                                    if (divRequestMap.containsKey(prli.SR_RESRV_PART_Id__r.RESRV_Number__c)) {
                                                        System.debug('AD 약속취소 Si_request 실행전');
                                                        prliListForExcT.add(prliSaleMap.get(getStringNotNull(prli.SR_RESRV_PART_Id__r.RESRV_Number__c) + '_' + getStringNotNull(rtnLdata.get('RSRV_SEQ__c'))));
                                                    }else{
                                                        System.debug('AM 약속취소 Si_request 실행후');
                                                        prliListForExcS.add(prliSaleMap.get(getStringNotNull(prli.SR_RESRV_PART_Id__r.RESRV_Number__c) + '_' + getStringNotNull(rtnLdata.get('RSRV_SEQ__c'))));
                                                    }

    
                                                    // ProductRequestLineItem prli = (ProductRequestLineItem) rtnLData;
                                                    if(orderQty != 0 && orderQty == endpRsvQty){ //입고 : 요청수량 == 입고수량
                                                        System.debug('T 약속취소(입고상태)');

                                                        prliListForExcAE.add(prli);//24 02 05 hyungho.chun

                                                    }else if(orderQty != 0 && endpRsvQty < orderQty){ //미출고
                                                        System.debug('S 약속취소(미출고)');
           
                                                        
                                                        prli.CANCEL_Quantity__c = prli.ENDP_RSV_Quantity__c; //약속수량만큼
                                                        prli.Status = 'C';
                                                        prliListForExcAE.add(prli);//24 02 05 hyungho.chun

                                                        //24 03 04 hyungoh.chun 일반예약으로 적치장소+사업부 인 주문은 케어플러스에없다 -> 전부 예약이거나 전부 할당에 잡히니까 이 로직은 불필요
                                                        // prli.CANCEL_Quantity__c = cancelQty - prli.ENDP_RSV_Quantity__c; //전체 - 약속수량 = 할당수량 만큼
                                                        // prliListForExcAB.add(prli);//24 02 05 hyungho.chun                   
    
                                                    }else{
                                                        System.debug('수량에 문제가있는 데이터');
                                                    }
                                                }
                                            // } else if (consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006) || consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_001) || getDecimalNotNull(rtnLData.get('UnitPrice__c')) > 0) { //상품준비중 or H I O D 결제요청 or 단가 있으면
                                            } else if (consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006) || consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_001) ) { //24 03 04 hyungho.chun 결제요청이나 단가있다고 수불하지않는다 ( 케어플러스는 결제요청일땐 할당이나 약속수량이 잡히기전이다)
                                                result = 'SUCCESS';
                                                workFlag = 'C';
                                                backIfStatus = 'CANCELLED';
    
                                                ProductRequestLineItem prli_u = new ProductRequestLineItem();
                                                prli_u = cancelProductRequestLineItem(rtnLData, cancelQty, cancelDate, workFlag);
                                                listUpdatePRLI1.add(prli_u);
                                   
                                                
                                                ProductRequestLineItem prli = (ProductRequestLineItem) rtnLData;
                                                // prliListForExcAB.add(prli); //AA 할당수량(-)
                                                //23 11 24 hyungho.chun 취소수량 기반으로 수불처리하므로 cancel_quantity가 증가한 prli_u를 받아서 수불처리해야합니다

                                                //24 03 04 hyungho.chun 약속건이면 약속수량/ 아니면 할당수량 감소
                                                if(consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006)){
                                                    if(rsrvId != ''){
                                                        prliListForExcAE.add(prli_u); //약속수량 (-)
                                                    }else{
                                                        prliListForExcAB.add(prli_u); //AA 할당수량(-)
                                                    }
                                                }

                                                
                                            }
                                            //24 01 30 hyungho.chun 주문취소시 careplus_order cancel_flag를 Y처리하여 추후 반품주문에서 찾는 원주문에서 걸러지게 처리
                                            if(backIfStatus == 'CANCELLED'){
                                                System.debug('CareplusOrder 주문취소건 cancel flag Y처리를위한 모수');
                                                String currentOrderNum = getStringNotNull(rtnLdata.get('Order_Number__c'));
                                                List<Decimal> qtyAmtList = new List<Decimal>();
                                                qtyAmtList.add(0);
                                                orderNumAndQtyMap.put(currentOrderNum, qtyAmtList);
                                            }
                                        // }// 반품, 순수주문 chk 끝 
                                    }else {
                                        workFlag = 'E';
                                        backIfStatus = 'CANCEL_ERROR';
                                        result = 'SUCCESS';
                                        sAttribute1 = sAttribute1 + '원주문 주문수량과 취소요청 취소수량이 다릅니다.';
                                    }//원주문수량 취소수량 체크 끝
                                }//for ProductRequestLineItem
                            }//for ProductRequest
                        //24 02 05 hyungho.chun 주문취소건 if절 끝    
                        }else if(sCancelGubun == 'RC'){ //24 02 05 hyungho.chun 반품요철철회
                            for(sObject roli : roliListTemp){
                                List<ReturnOrderLineItem> existRoliList = new List<ReturnOrderLineItem>();
                                if(!returnOrderLineItemList.isEmpty()){
                                    for(ReturnOrderLineItem item : returnOrderLineItemList){
                                        if(carePlustOrderNo.equals(item.Order_Number__c)){
                                            existRoliList.add(item);
                                        }
                                    }
                                }
                                prliDataList = existRoliList;
                                for(sObject rtnLdata : existRoliList){
                                    String consumablesOrderStatus = getStringNotNull(rtnLdata.get('Consumables_Order_Status__c'));
                                    Integer rCancelQty = getIntegerNotNull(rtnLData.get('QuantityReturned'));
                                    if(cancelQty != null && rCancelQty != null && cancelQty == rCancelQty){ //원주문 주문수량 == 취소요청 취소수량
                                        // if ('RC'.equals(sCancelGubun)) { //반품요청에 대한 취소 요청
                                            // if (consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_100)){ //반품요청
                                            // String consumablesOrderDetail = getStringNotNull(rtnLdata.get('Consumables_Order_Detail__c'));
                                            // if (consumablesOrderDetail.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_102)){ //반품요청 //24 01 24 hyungho.chun prli.Consumables_Order_Status__c  로직오류 -> prli.Consumables_Order_Detail__c (반품대기만 가능)
                                            // String currentPrliId = getStringNotNull(rtnLdata.get('Id'));
                                            // if (prliRoliMap.containsKey(currentPrliId) && (prliRoliMap.get(currentPrliId).Consumables_Order_Status__c).equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_102)){ //24 01 26 hyungho.chun returnOrderLineItem의 Consumables_Order_Status__c가 반품대기 일때만
                                              
                                            if (consumablesOrderStatus.equals(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_102)){ //24 02 05 hyungho.chun roli상태값으로 체크
                                                workFlag = 'C';
                                                backIfStatus = 'CANCELLED';
                                                result = 'SUCCESS';
                                                //24 02 05 hyungho.chun 반품요청철회는 수불없음
                                            } else { //에러
                                                workFlag = 'E';
                                                backIfStatus = 'CANCEL_ERROR';
                                                result = 'SUCCESS';
                                            }
                                        // }
                                    }else {
                                        workFlag = 'E';
                                        backIfStatus = 'CANCEL_ERROR';
                                        result = 'SUCCESS';
                                        sAttribute1 = sAttribute1 + '원주문 주문수량과 취소요청 취소수량이 다릅니다.';
                                    }//원주문수량 취소수량 체크 끝
                                }//for ProductRequestLineItem
                            }//for ProductRequest
                        }else{
                            //24 02 05 hyungho.chun 'C'도 'RC'도 아닌 cancel_flag나 return_flag가  careplusOrder에서 잘못 들어온경우
                            workFlag = 'E';
                            backIfStatus = 'CANCEL_ERROR'; //24 02 05 hyungho.chun 주문취소건인데 매칭되는 ProductRequest가 없음
                            result = 'SUCCESS';
                            sAttribute1 = sAttribute1 + 'cancel_flag 및 return_flag 값이 잘못 송신됨.'; //24 02 05 hyungho.chun  att1 오류 메세지 추가                            
                        } 

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
                        if ('RC'.equals(sCancelGubun)) { //반품요청에 대한 취소 처리
                            System.debug('반품요청에 대한 취소 처리');
                            if ('C'.equals(workFlag)) {
                                if ('SUCCESS'.equals(result)) {
                                    if(!prliDataList.isEmpty()){
                                        // for(ReturnOrderLineItem roli : roliList){ 
                                        for(ReturnOrderLineItem roli : returnOrderLineItemList){ //24 01 26 hyungho.chun 기준 roli찾는기준이 잘못되어있었음(ro도 pr과 같은 주문번호인거처럼 매칭중이였었음)
                                            //roliList = [SELECT Id, Expected_Return_Quantity__c, Consumables_Order_Status__c, ProductRequestLineItemId FROM ReturnOrderLineItem WHERE ProductRequestLineItemId IN :prliIdList];
                                            for(sObject prliData : prliDataList){
                                                // if(roli.ProductRequestLineItemId == prliData.Id){
                                                if(roli.Id == prliData.Id){  //24 02 05 hyungho.chun prliData가 'RC'에선 roli임
                                                    Decimal expectedQty = roli.Expected_Return_Quantity__c;
                                                    roli.Expected_Return_Quantity__c = 0;
                                                    roli.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_090; //반품요청철회
                                                    updateRoliList.add(roli);
                                                    //24 01 30 hyungho.chun 반품요청철회시 careplus_order cancel_flag Y일시 제거/  추후 반품주문에서 찾는 원주문에서 찾아지게 처리
                                                    System.debug('반품요청철회건 원 careplus order cancel flag 초기화 및 num_att1,2 계산');
                                                    List<Decimal> qtyAmtList = new List<Decimal>();
                                                    qtyAmtList.add(expectedQty);
                                                    qtyAmtList.add(roli.ReturnOrder.RETURN_PAYMENT_Amount__c);

                                                    ReturnOrderLineItem roliTemp = (ReturnOrderLineItem) prliData;
                                                    if(roli.ProductRequestLineItemId != null){ //24 02 05 hyungho.chun 원주문이 연결되었던것만 careplusOrder transType 'O'의 num att1,att2값을 차감시켜야한다
                                                        orderNumAndQtyMap.put(getStringNotNull(roliTemp.ProductRequestLineItem.Order_Number__c), qtyAmtList);
                                                        carePlustOrderNoFromRoli = getStringNotNull(roliTemp.ProductRequestLineItem.Order_Number__c);
                                                        carePlustPartNoFromRoli = getStringNotNull(roliTemp.ProductRequestLineItem.PART_NO__c);
                                                        
                                                        //24 02 05 hyungho.chun 어차피 원주문 prli Consumables_Order_Detail__c값은 아직 비어있다 
                                                        // ProductRequestLineItem prli_u = roliIdAndprliMap.get(roli.Id);
                                                        // prli_u.Consumables_Order_Detail__c = '';
                                                        // listUpdatePRLI.add(prli_u);
                                                    }
                                                    
                                                }
                                                // ProductRequestLineItem prli_u = new ProductRequestLineItem();
                                                // prli_u = (ProductRequestLineItem) prliData; 
                                                // prli_u.Consumables_Order_Detail__c = '';
                                                // listUpdatePRLI.add(prli_u);
                                            }
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

//                                if ('SUCCESS'.equals(result)) {
//                                    if(prList.isEmpty()){ //Insert 없음
//                                        /** ProductRequest */
////                                        ProductRequest pr = new ProductRequest();
////                                        pr = EX_CarePlusOrder.setProductRequest(lData, pr);
////                                        insert pr;
//
//                                        /** ProductRequestLineItem */
////                                        ProductRequestLineItem prli = new ProductRequestLineItem();
////                                        prli = EX_CarePlusOrder.setProductRequestLineItem(lData, pr, prli, mPartData, piforPrli, false);
////                                        insert prli;
//                                    }else{ //Update
////                                        for(ProductRequest pr : prList){
////                                            /** ProductRequest */
////                                            pr = EX_CarePlusOrder.setProductRequest(lData, pr);
////                                            /** ProductRequestLineItem */
////                                            if(prliDataList.isEmpty()){ //기존 ProductRequestLineItem 없으면
////                                                ProductRequestLineItem prli = new ProductRequestLineItem();
////                                                //prli도 기존 것 검사
////                                                prli = EX_CarePlusOrder.setProductRequestLineItem(lData, pr, prli, mPartData, piforPrli, false);
////                                                upsertPrliList.add(prli);
////                                            }else{ //기존 ProductRequestLineItem 있으면
////                                                for(sObject sOprli : prliDataList){
////                                                    ProductRequestLineItem prli = new ProductRequestLineItem();
////                                                    prli = (ProductRequestLineItem) sOprli;
////                                                    prli = EX_CarePlusOrder.setProductRequestLineItem(lData, pr, prli, mPartData, piforPrli, false);
////                                                    upsertPrliList.add(prli);
////                                                }
////                                            }
////                                        }
//                                    }
//                                }

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
                                    backIfStatus = (backIfStatus == null || backIfStatus == '') ? 'CANCEL_ERROR' : backIfStatus; //24 01 31 hyungho.chun 모종의 이유로 backIF가 빈값으로 오면 cancel_error( 예 주문취소로주는데 파트번호만 잘못온경우)
                                    siB = insertCareplusBackIf(lData, backIfStatus, sAttribute1, shipQty, 0, loopCnt, backIfMaxInterfaceId, backIfSubMaxInterfaceId);
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
                                                    //23 09 20 hyungho.chun 실제로 원주문에관련된 complete찾기
                                                    List<SI_CAREPLUS_ORDER_COMPLETE__c> orderCompleteMDataList = getSiCareplusOrderComplete(carePlustOrderNo, sPartNo, 'Y', 'PO');
                                                    if(!orderCompleteMDataList.isEmpty()){ //ERP 주문생성 결과 조회 있음
                                                        SObject orderRequestLData = lData;
                                                        /** ERP 데이터 전송 (SI_CAREPLUS_ORDER_REQUEST__c) */
                                                        System.debug('ERP 데이터 전송 (SI_CAREPLUS_ORDER_REQUEST__c)');
                                                        SI_CAREPLUS_ORDER_REQUEST__c siR = new SI_CAREPLUS_ORDER_REQUEST__c();
                                                        siR = insertSiCareplusOrderRequest(orderRequestLData, true, orderCompleteMDataList[0].LINE_ID__c, loopCnt2, requestMaxInterfaceId);
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
                                        //24 02 05 hyungho.chun 반품요청철회건에대한 careplus_order_request 생성 불필요
                                        // else if('RC'.equals(sCancelGubun)){ //24 02 05 hyungho.chun 반품요청철회 로직 추가
                                        //     if ('SUCCESS'.equals(result)) {
                                        //         if('CANCELLED'.equals(backIfStatus)){
                                        //             //String sPartNo = getStringNotNull(prli.get('PART_NO__c'));
                                        //             /** ERP 주문생성 결과 조회 */
                                        //             System.debug('ERP 주문생성 결과 조회');
                                        //             //23 09 20 hyungho.chun 실제로 원주문에관련된 complete찾기
                                        //             //24 02 05 hyunghochun carePlustOrderNoFromRoli (반품요청철회건의 원주문 prli의 주문번호)
                                        //             List<SI_CAREPLUS_ORDER_COMPLETE__c> orderCompleteMDataList = getSiCareplusOrderComplete(carePlustOrderNoFromRoli, carePlustPartNoFromRoli, 'Y', 'PO');
                                        //             if(!orderCompleteMDataList.isEmpty()){ //ERP 주문생성 결과 조회 있음
                                        //                 SObject orderRequestLData = lData;
                                        //                 /** ERP 데이터 전송 (SI_CAREPLUS_ORDER_REQUEST__c) */
                                        //                 System.debug('ERP 데이터 전송 (SI_CAREPLUS_ORDER_REQUEST__c)');
                                        //                 SI_CAREPLUS_ORDER_REQUEST__c siR = new SI_CAREPLUS_ORDER_REQUEST__c();
                                        //                 siR = insertSiCareplusOrderRequest(orderRequestLData, true, orderCompleteMDataList[0].LINE_ID__c, loopCnt2, requestMaxInterfaceId);
                                        //                 listInsertSiRequest.add(siR);
                                        //                 result = 'SUCCESS';
                                        //                 loopCnt2++;

                                        //                 if('N'.equals(orderCompleteMDataList[0].WORK_FLAG__c)){
                                        //                     if ('SUCCESS'.equals(result)) {
                                        //                         SI_CAREPLUS_ORDER_COMPLETE__c orderCompleteMData = (SI_CAREPLUS_ORDER_COMPLETE__c) orderCompleteMDataList[0];
                                        //                         /*update new SI_CAREPLUS_ORDER_COMPLETE__c(
                                        //                                 Id = orderCompleteMData.Id,
                                        //                                 WORK_FLAG__c = 'Y',
                                        //                                 WORK_DATE__c = Date.today()
                                        //                         );*/

                                        //                         SI_CAREPLUS_ORDER_COMPLETE__c siC = new SI_CAREPLUS_ORDER_COMPLETE__c();
                                        //                         siC.Id = orderCompleteMData.Id;
                                        //                         siC.WORK_FLAG__c = 'Y';
                                        //                         siC.WORK_DATE__c = System.now();
                                        //                         listUpdateComplete.add(siC);
                                        //                     }
                                        //                 }
                                        //             }
                                        //         }
                                        //     }
                                        // }
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
                        // rsrvCancelMap.put('code', 'T');
                        rsrvCancelMap.put('code', 'AD'); //24 02 05 hyungho.chun 
                        rsrvCancelMapList.add(rsrvCancelMap);
                    }
                    //EX_RsrvUtil.execApplyProductItemMulti('T',prliListForExcT);
                }
                if(!prliListForExcS.isEmpty()){
                    for(ProductRequestLineItem prliS : prliListForExcS){
                        Map<String, Object> rsrvCancelMap = new Map<String, Object>();
                        rsrvCancelMap.put('ProductRequestLineItem', prliS);
                        // rsrvCancelMap.put('code', 'S');
                        //24.02.16 gw.lee
                        //사업부 출하가 되던 안되던 사업부 주문수량 감소, 센터 약속 미입고 수량 감소 조치 (자재에서 전달 완료)
                        rsrvCancelMap.put('code', 'AD');
                        // rsrvCancelMap.put('code', 'AM');
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
                //24 02 05 hyungho.chun 적치장소 약속수량 감소 호출
                if(!prliListForExcAE.isEmpty()){
                    EX_RsrvUtil.execApplyProductItemMulti('AE',prliListForExcAE);
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
                if(!updateRoliList.isEmpty()){
                    update updateRoliList;
                    system.debug('UPDATE ReturnOrderLineItem TOTAL : ' + updateRoliList.size());
                }
                //24 01 30 hyungho.chun 업데이트쳐줄 TransType 'O'인 careplus order 건들 (주문취소 -> cancel_flag Y   // 반품요청철회 -> cancel flag null 및 num_att1,2 업데이트)
                if(!orderNumAndQtyMap.isEmpty()){
                    System.debug('원 careplus 업데이트 시작');
                    List<SI_CAREPLUS_ORDER__c> updateCareplusList = new List<SI_CAREPLUS_ORDER__c>();
                    updateCareplusList = [SELECT Id, TRANS_TYPE__c,ORDER_NO__c, CANCEL_FLAG__c, NUM_ATT1__c, NUM_ATT2__c FROM SI_CAREPLUS_ORDER__c WHERE ORDER_NO__c IN: orderNumAndQtyMap.keySet() AND TRANS_TYPE__c ='O'];
                    for(SI_CAREPLUS_ORDER__c order : updateCareplusList){
                        if(orderNumAndQtyMap.containsKey(order.ORDER_NO__c)){
                            System.debug('원주문 키값찾음');
                            if(orderNumAndQtyMap.get(order.ORDER_NO__c)[0] == 0){ //24 01 30 hyungho.chun value값으로 받은 integer list 첫번쨰가 0인경우 주문취소건이란뜻
                                System.debug('주문취소 cancel_flag Y처리');
                                order.CANCEL_FLAG__c ='Y';
                                order.WORK_FLAG__c ='Y'; //24 02 16 hyungho.chun 이미 work_flag가 Y까지 도달하지않았던건인데 주문취소된경우 다시 모수잡히지않게 원주문 work_Flag Y처리 추가( 예시 : 예약주문 결제완료 상태일때 해당주문번호로 주문취소한경우)
                            }else{ //24 01 30 hyungho.chun value값으로 받은 integer list 첫번쨰가 0이 아닌경우 반품요청철회건이란뜻
                                System.debug('반품주문건 cancel_flag null 및 num_att1,2 계산처리');
                                order.CANCEL_FLAG__c = null;
                                order.NUM_ATT1__c -= orderNumAndQtyMap.get(order.ORDER_NO__c)[0]; //반품요청수량
                                order.NUM_ATT2__c -= orderNumAndQtyMap.get(order.ORDER_NO__c)[1]; //반품주문총금액
                            }
                        }

                    }

                    update updateCareplusList;
                    System.debug('원 careplus 업데이트 끝');
                }
                //23 11 22 hyungho.chun 성공건들 id모음
                // for (sObject lData : siCarePlusOrderList) {
                    successCareplusOrderId += recordIdGroup;
                // }                    
            }
        // }catch (JSONException je){
        //     System.debug('*** je.getMessage: ' + je.getMessage());
        //     System.debug('*** je.getLine -> ' + je.getLineNumber());
        //     Database.rollback(sp);
        // } catch (NullPointerException ne){
        //     System.debug('*** ne.getMessage: ' + ne.getMessage());
        //     System.debug('*** ne.getLine -> ' + ne.getLineNumber());
        //     Database.rollback(sp);
        } catch (Exception e) {
            System.debug('*** e.getMessage: ' + e.getMessage());
            System.debug('*** e.getLine -> ' + e.getLineNumber());
            Database.rollback(sp);

            String tempMsg = '[Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage();
            errorMap.put('className','EX_CarePlusOrderCancel_ba.execute');
            errorMap.put('isSuccess','N'); //24 02 25 hyungho.chun 성공 실패 여부 추가 (이메일 및 실패시 메세지 전송용)
            errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
            errorMap.put('requestMsg', recordIdGroup);
            
            System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
            EX_ConsumableUtil.saveSaleExc(errorMap);            
        }
    }

    public void finish(Database.BatchableContext param1) {
        //23 11 15 hyungho.chun try 통과한 케이스 모음 로그
        Map<String,String> successMap = new Map<String,String>();
        successMap.put('className','EX_CarePlusOrderCancel_ba.finish');
        successMap.put('isSuccess','Y'); //24 02 25 hyungho.chun 성공 실패 여부 추가 (이메일 및 실패시 메세지 전송용)
        successMap.put('tempErrorMsg', 'EX_CarePlusOrderCancel_ba 성공한 케이스 recordId 모음');
        successMap.put('requestMsg', successCareplusOrderId);
        System.debug('Before Calling saveSaleExc // successMap :: '+successMap);
        EX_ConsumableUtil.saveSaleExc(successMap);

        Database.executeBatch(new EX_CarePlusOrderReturn_ba(), batchSize);
    }

    @AuraEnabled
    public static SI_CAREPLUS_BACKIF__c insertCareplusBackIf(sObject lData, String back_if_status, String back_if_error_desc, Integer shipQty, Double ShipAmt, Integer LoopCnt, Integer backIfMaxInterfaceId, Integer backIfSubMaxInterfaceId) {
        /** SI_CAREPLUS_BACKIF 테이블에 저장 */
        Decimal maxNum = backIfMaxInterfaceId + LoopCnt;
        /*List<SI_CAREPLUS_BACKIF__c> getMaxList = new List<SI_CAREPLUS_BACKIF__c>();
        getMaxList = [SELECT INTERFACE_ID__c FROM SI_CAREPLUS_BACKIF__c ORDER BY INTERFACE_ID__c DESC LIMIT 1];
        if(!getMaxList.isEmpty()){
            SI_CAREPLUS_BACKIF__c getMax = getMaxList[0];
            if(getMax.INTERFACE_ID__c != null && getMax.INTERFACE_ID__c > 0){
                maxNum = getMax.INTERFACE_ID__c + LoopCnt;
            }
        }*/

        Decimal ifId = getDecimalNotNull(lData.get('INTERFACE_ID__c'));
        String t_type = getStringNotNull(lData.get('TRANS_TYPE__c'));
        String oNo = getStringNotNull(lData.get('ORDER_NO__c'));

        Decimal maxSubNum = backIfSubMaxInterfaceId + 1;
        /*List<SI_CAREPLUS_BACKIF__c> getMaxSubList = new List<SI_CAREPLUS_BACKIF__c>();
        getMaxSubList = [SELECT BACK_SUB_SEQ__c FROM SI_CAREPLUS_BACKIF__c WHERE INTERFACE_ID__c = :ifId AND TRANS_TYPE__c = :t_type AND ORDER_NO__c = :oNo ORDER BY BACK_SUB_SEQ__c DESC LIMIT 1];
        if(!getMaxSubList.isEmpty()){
            SI_CAREPLUS_BACKIF__c getMaxSub = getMaxSubList[0];
            if(getMaxSub.BACK_SUB_SEQ__c != null && getMaxSub.BACK_SUB_SEQ__c > 0){
                maxSubNum = getMaxSub.BACK_SUB_SEQ__c + 1;
            }
        }*/

        SI_CAREPLUS_BACKIF__c siCareplusBackif = new SI_CAREPLUS_BACKIF__c();
        siCareplusBackif.INTERFACE_ID__c = maxNum;
        siCareplusBackif.TRANS_TYPE__c = t_type;
        siCareplusBackif.ORDER_NO__c = oNo;
        siCareplusBackif.REQUEST_NO__c = getStringNotNull(lData.get('REQUEST_NO__c'));
        siCareplusBackif.REQUEST_SEQ__c = getDecimalNotNull(lData.get('REQUEST_SEQ__c'));
        siCareplusBackif.BACK_SUB_SEQ__c = maxSubNum;
        siCareplusBackif.ORDER_DATE__c = getDatetimeWithNull(lData.get('ORDER_DATE__c'));
        siCareplusBackif.BILL_TO_CODE__c = getStringNotNull(lData.get('BILL_TO_CODE__c'));
        siCareplusBackif.DIV_CODE__c = getStringNotNull(lData.get('DIV_CODE__c'));
        siCareplusBackif.MODEL_CODE__c = getStringNotNull(lData.get('MODEL_CODE__c'));
        siCareplusBackif.PART_NO__c = getStringNotNull(lData.get('PART_NO__c'));
        siCareplusBackif.ORDER_QTY__c = getDecimalNotNull(lData.get('ORDER_QTY__c'));
        siCareplusBackif.SHIPPED_QTY__c = shipQty;
        siCareplusBackif.CANCEL_QTY__c = getDecimalNotNull(lData.get('CANCEL_QTY__c'));
        siCareplusBackif.ORDER_PRICE__c = getDecimalNotNull(lData.get('ORDER_PRICE__c'));
        siCareplusBackif.ORDER_AMT__c = getDecimalNotNull(lData.get('ORDER_AMT__c'));
        siCareplusBackif.SHIP_AMT__c = ShipAmt;
        siCareplusBackif.RECEIVER_NAME__c = getStringNotNull(lData.get('RECEIVER_NAME__c'));
        siCareplusBackif.SHIP_TO_CODE__c = getStringNotNull(lData.get('SHIP_TO_CODE__c'));
        siCareplusBackif.POSTAL_CODE__c = getStringNotNull(lData.get('POSTAL_CODE__c'));
        siCareplusBackif.BASIC_ADDRESS__c = getStringNotNull(lData.get('BASIC_ADDRESS__c'));
        siCareplusBackif.DETAIL_ADDRESS__c = getStringNotNull(lData.get('DETAIL_ADDRESS__c'));
        siCareplusBackif.RECEIVER_PHONE_NO__c = getStringNotNull(lData.get('RECEIVER_PHONE_NO__c'));
        siCareplusBackif.ORIGINAL_REQUEST_NO__c = getStringNotNull(lData.get('ORIGINAL_REQUEST_NO__c'));
        siCareplusBackif.ORIGINAL_REQUEST_SEQ__c = getDecimalNotNull(lData.get('ORIGINAL_REQUEST_SEQ__c'));
        //siCareplusBackif.BOOKED_FLAG__c = getStringNotNull(lData.BOOKED_FLAG__c);
        siCareplusBackif.CANCEL_FLAG__c = getStringNotNull(lData.get('CANCEL_FLAG__c'));
        if(lData.get('CANCEL_FLAG__c') != null && !lData.get('CANCEL_FLAG__c').equals('')){
            siCareplusBackif.CANCEL_DATE__c = getDatetimeWithNull(lData.get('CANCEL_DATE__c'));
        }
        siCareplusBackif.ORDER_DESCRIPTION__c = getStringNotNull(lData.get('ORDER_DESCRIPTION__c'));
        siCareplusBackif.BACK_IF_STATUS__c = back_if_status;
        siCareplusBackif.BACK_IF_ERROR_DESC__c = back_if_error_desc;
        siCareplusBackif.TRANSFER_FLAG__c = 'N';
        siCareplusBackif.ATTRIBUTE1__c = getStringNotNull(lData.get('ATTRIBUTE1__c'));
        siCareplusBackif.ATTRIBUTE2__c = getStringNotNull(lData.get('ATTRIBUTE2__c'));
        siCareplusBackif.ATTRIBUTE3__c = getStringNotNull(lData.get('ATTRIBUTE3__c'));
        siCareplusBackif.ATTRIBUTE4__c = getStringNotNull(lData.get('ATTRIBUTE4__c'));
        siCareplusBackif.ATTRIBUTE5__c = getStringNotNull(lData.get('ATTRIBUTE5__c'));
        siCareplusBackif.ATTRIBUTE6__c = getStringNotNull(lData.get('ATTRIBUTE6__c'));
        siCareplusBackif.ATTRIBUTE7__c = getStringNotNull(lData.get('ATTRIBUTE7__c'));
        siCareplusBackif.ATTRIBUTE8__c = getStringNotNull(lData.get('ATTRIBUTE8__c'));
        siCareplusBackif.ATTRIBUTE9__c = getStringNotNull(lData.get('ATTRIBUTE9__c'));
        siCareplusBackif.ATTRIBUTE10__c = getStringNotNull(lData.get('ATTRIBUTE10__c'));
        siCareplusBackif.NUM_ATT1__c = getDecimalNotNull(lData.get('NUM_ATT1__c'));
        siCareplusBackif.NUM_ATT2__c = getDecimalNotNull(lData.get('NUM_ATT2__c'));
        siCareplusBackif.NUM_ATT3__c = getDecimalNotNull(lData.get('NUM_ATT3__c'));
        siCareplusBackif.NUM_ATT4__c = getDecimalNotNull(lData.get('NUM_ATT4__c'));
        siCareplusBackif.NUM_ATT5__c = getDecimalNotNull(lData.get('NUM_ATT5__c'));
        siCareplusBackif.NUM_ATT6__c = getDecimalNotNull(lData.get('NUM_ATT6__c'));
        siCareplusBackif.NUM_ATT7__c = getDecimalNotNull(lData.get('NUM_ATT7__c'));
        siCareplusBackif.NUM_ATT8__c = getDecimalNotNull(lData.get('NUM_ATT8__c'));
        siCareplusBackif.NUM_ATT9__c = getDecimalNotNull(lData.get('NUM_ATT9__c'));
        siCareplusBackif.NUM_ATT10__c = getDecimalNotNull(lData.get('NUM_ATT10__c'));
        siCareplusBackif.DATE_ATT1__c = getDatetimeWithNull(lData.get('DATE_ATT1__c'));
        siCareplusBackif.DATE_ATT2__c = getDatetimeWithNull(lData.get('DATE_ATT2__c'));
        siCareplusBackif.DATE_ATT3__c = getDatetimeWithNull(lData.get('DATE_ATT3__c'));
        siCareplusBackif.DATE_ATT4__c = getDatetimeWithNull(lData.get('DATE_ATT4__c'));
        siCareplusBackif.DATE_ATT5__c = getDatetimeWithNull(lData.get('DATE_ATT5__c'));
        siCareplusBackif.CREATION_DATE__c = Date.today();
        siCareplusBackif.CREATED_BY__c = 'SYSTEM';
        siCareplusBackif.LAST_UPDATE_DATE__c = Date.today();
        siCareplusBackif.LAST_UPDATED_BY__c = 'SYSTEM';

        return siCareplusBackif;
    }

    @AuraEnabled
    public static SI_CAREPLUS_ORDER_REQUEST__c insertSiCareplusOrderRequest(sObject lData, Boolean isCancel, Decimal line_id, Integer loopCnt, Integer requestMaxInterfaceId) {
        /** ERP 데이터 전송 (SI_CAREPLUS_ORDER_REQUEST__c) */
        String result = 'SUCCESS';

        SI_CAREPLUS_ORDER_REQUEST__c siCareplusOrderRequest = new SI_CAREPLUS_ORDER_REQUEST__c();

        Decimal maxNum = requestMaxInterfaceId + loopCnt;
        siCareplusOrderRequest.SO_INTERFACE_ID__c = maxNum;
        siCareplusOrderRequest.CORPORATION_CODE__c = 'LGEKR'; /** 법인코드 */
        siCareplusOrderRequest.ORIG_SYS_DOCUMENT_REF__c = getStringNotNull(lData.get('ORDER_NO__c')); /** BEST 주문번호 */
        siCareplusOrderRequest.ORIG_SYS_LINE_REF__c = getStringNotNull(getIntegerNotNull(lData.get('REQUEST_SEQ__c'))); /** BEST 주문 시퀀스 */
        if(isCancel){
            siCareplusOrderRequest.ORDER_TYPE__c = 'CP'; /** 주문유형 (PO : PART ORDER, CP : CANCEL PART ORDER) */
            siCareplusOrderRequest.RETURN_CONTEXT__c = 'BESTSHOP 취소 요청'; /** 취소인경우 사유 */
            siCareplusOrderRequest.ORIGINAL_LINE_ID__c = line_id; /** 원주문 LINE ID(ERP LINE ID) */
        }else{
            siCareplusOrderRequest.ORDER_TYPE__c = 'PO'; /** 주문유형 (PO : PART ORDER, CP : CANCEL PART ORDER) */
            siCareplusOrderRequest.RETURN_CONTEXT__c = ''; /** 취소인경우 사유 */
        }

        siCareplusOrderRequest.SHIP_TO_CODE__c = getStringNotNull(lData.get('SHIP_TO_CODE__c')); /** SHIP_TO CODE */
        siCareplusOrderRequest.CUSTOMER_NAME__c = getStringNotNull(lData.get('RECEIVER_NAME__c')); /** SHIP_TO NAME */
        siCareplusOrderRequest.ITEM_NO__c = getStringNotNull(lData.get('PART_NO__c'));
        siCareplusOrderRequest.ORDER_QTY__c = getIntegerNotNull(lData.get('ORDER_QTY__c'));
        siCareplusOrderRequest.CREATION_DATE__c = Date.today();
        siCareplusOrderRequest.CREATED_BY__c = 1;
        siCareplusOrderRequest.LAST_UPDATE_DATE__c = Date.today();
        siCareplusOrderRequest.LAST_UPDATED_BY__c = 1;
        siCareplusOrderRequest.CUST_PO_NO__c = getStringNotNull(lData.get('ORDER_NO__c')); /** BEST 주문번호 */
        siCareplusOrderRequest.REPLACEMENT_MODEL_CODE__c = getStringNotNull(lData.get('MODEL_CODE__c')); /** BEST MODEL_CODE */
        siCareplusOrderRequest.ORDER_SOURCE_NAME__c = 'OMV_CSONE';
        siCareplusOrderRequest.ATTRIBUTE1__c = getStringNotNull(getIntegerNotNull(lData.get('ORDER_PRICE__c'))); //단가
        siCareplusOrderRequest.ATTRIBUTE2__c = getStringNotNull(lData.get('DIV_CODE__c')); //사업부코드
        siCareplusOrderRequest.TRANSFER_FLAG__c = 'N';
        siCareplusOrderRequest.AUTHORIZED_SERVICE_CENTER_CODE__c = F_ST_DEPT_CODE;
        //서인석 책임 요청 PROCESS_STATUS_CODE__c = 'I'
        siCareplusOrderRequest.PROCESS_STATUS_CODE__c = 'I';

        //24 02 15 hyungho.chun 혹시 REQUEST_DATE__c 값을 만약 넣는다면 꼭 YYYY-MM-DD HH24:MI:SS 형식으로 넣어야한다
        //sfdc에는 String이나 히로쿠에서 gerp로 송신때 Date형식으로 변환해주기때문에 미리 변환가능하게 형식만들어놔야함
        

        return siCareplusOrderRequest;
    }    
    
    @AuraEnabled
    public static List<SI_CAREPLUS_ORDER_COMPLETE__c> getSiCareplusOrderComplete(String carePlustOrderNo, String sPartNo, String workFlag, String orderType) {
        /** ERP 주문생성 결과 조회 (SI_CAREPLUS_ORDER_COMPLETE__c) */

        /** ERP 주문생성 결과 조회 */
        List<SI_CAREPLUS_ORDER_COMPLETE__c> orderCompleteMDataList = [SELECT Id, LINE_STATUS_CODE__c, LINE_ID__c,WORK_FLAG__c FROM SI_CAREPLUS_ORDER_COMPLETE__c
        WHERE ORIG_SYS_DOCUMENT_REF__c = :carePlustOrderNo
        //24 02 19 hyungho.chun 파트번호 달라도 찾아야함
        // AND ITEM_NO__c = :sPartNo
        AND LINE_STATUS_CODE__c NOT IN ('SHIPPED', 'CANCELLED', 'RETRUNED', 'PENDING_WORKFLOW', 'Not Defined')
        AND (WORK_FLAG__c = null OR WORK_FLAG__c = :workFlag)
        AND ORDER_TYPE__c = :orderType
        ORDER BY INTERFACE_ID__c DESC LIMIT 1
        ];

        return orderCompleteMDataList;
    }

    @AuraEnabled
    public static ProductRequestLineItem cancelProductRequestLineItem(sObject rtnLData, Integer cancelQty, Datetime cancelDate, String workFlag){
        /** 취소 */
        String result = 'SUCCESS';
        //판매수량 = 판매수량 - 취소수량
        Integer sq = getIntegerNotNull(rtnLData.get('SALE_Quantity__c')) - cancelQty;
        String status = '';
        ProductRequestLineItem  prli = new ProductRequestLineItem();
        prli.Id = Id.valueOf(getStringNotNull(rtnLData.get('Id')));
        if(workFlag.equals('W')){ //반품승인대기
            //status = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_100; //반품요청
            //prli.Consumables_Order_Status__c = status;
            workFlag = 'W';
        }else{
            status = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_004; //주문취소
            //prli.Consumables_Order_Status__c = status;
            prli.Consumables_Order_Status__c = status;
            prli.Adjust_Quantity__c = cancelQty;
            prli.SALE_Quantity__c = sq;
            prli.CANCEL_Quantity__c = cancelQty;
            if(cancelDate != null){
                prli.CANCEL_Date__c = cancelDate.date();
                prli.CANCEL_Request_DTM__c = cancelDate;
            }
            prli.CANCEL_User__c = 'SYSTEM';
            prli.CANCEL_UserId__c = UserInfo.getUserId();
            //24.31.11 gw.lee
            //송찬영님 요청, ETA화면 표출 시, 취소된건은 Staus == 'C' 조치 필요
            prli.Status = 'C';
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