/**
 * Created by A80598 on 2023-05-16.
 */

 public with sharing class EX_CarePlusOrderReturn_ba implements Database.Batchable<sObject>, Database.Stateful {
    
    //23 11 15 hyuoghn.chun 성공건들 로그작업
    String successCareplusOrderId = 'Success SI_CAREPLUS_ORDER__c ID : ';     

    public Database.QueryLocator start(Database.BatchableContext param1) {
        String strQuery = '';
        strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('SI_CAREPLUS_ORDER__c');
        strQuery += ' FROM SI_CAREPLUS_ORDER__c ';
        strQuery += ' WHERE TRANS_TYPE__c = \'R\' ';
        strQuery += ' AND WORK_FLAG__c IN ( \'N\',\'\') ';
        //23 12 06 테스트 대비로 커스텀라벨이용해서 쿼리조회(운영엔 아래조건 주석처리로 배포중)
        if(System.Label.EX_carePlusOrderNum != 'none'){
            strQuery += 'AND ORDER_NO__C = \''+System.Label.EX_carePlusOrderNum+'\' ';
        }        
        // strQuery += ' AND DAY_ONLY(CreatedDate) > 2023-08-22 AND TRANS_TYPE__c = \'R\' ';
        // strQuery += ' AND ID = \'a3lJO00000000CvYAI\' ';
        //23 08 23 hyungho.chun 임시로 오더넘버 넣음
        // strQuery += ' AND ORDER_NO__c IN (\'P10000403074\') ';
        // strQuery += ' AND ORDER_NO__c IN (\'P10000403075\', \'P10000403076\',\'P10000403086\',\'P10000403087\') ';

        // strQuery += ' ORDER BY LAST_UPDATE_DATE__c ASC ';
        strQuery += ' ORDER BY ORDER_QTY__c DESC '; //24 01 29 hyungho.chun 수량많은반품건부터 체크

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
        paramLData.put('TRANS_TYPE__c','R');
        paramLData.put('ORDER_NO__c','');
        Savepoint sp = Database.setSavepoint();
        try {
            if(!siCarePlusOrderList.isEmpty()){
                System.debug('케어플러스 반품 수신 데이터 Total : ' + siCarePlusOrderList.size());
                Set<String> billToCodeList = new Set<String>();
                Set<String> shipToCodeList = new Set<String>();
                Set<Decimal> qtyList = new Set<Decimal>();
                Set<String> sPartNoList = new Set<String>();
                Set<String> modelNoList = new Set<String>();
                List<String> orderNoList = new List<String>();
                List<Decimal> orderPriceList = new List<Decimal>();
                List<Integer> ifIdList = new List<Integer>();

                List<String> divCodeList = new List<String>();

                //gw.lee 가장 최근의 값으로 찾기
                //Careplus key Data
                Map<String, List<SI_CAREPLUS_ORDER__c>> orderMap = new Map<String, List<SI_CAREPLUS_ORDER__c>>(); //ProductRequest 원주문
                Map<String, sObject> returnOrderMap = new Map<String, sObject>();//ReturnOrder 주문
                List<SI_CAREPLUS_ORDER__c> updateCancelList = new List<SI_CAREPLUS_ORDER__c>(); //ProductRequest 원주문 Cancel Update

                for (sObject lData : siCarePlusOrderList) {
                    String partNo = getStringNotNull(lData.get('PART_NO__c'));
                    String billToCode = getStringNotNull(lData.get('BILL_TO_CODE__c'));
                    String shipToCode = getStringNotNull(lData.get('SHIP_TO_CODE__c'));
                    Decimal orderQty = getDecimalNotNull(lData.get('ORDER_QTY__c'));
                    String modelNo = getStringNotNull(lData.get('MODEL_CODE__c'));
                    Decimal orderPrice = getDecimalNotNull(lData.get('ORDER_PRICE__c'));
                    String divCode = getStringNotNull(lData.get('DIV_CODE__c'));
                    
                    System.debug('orderPrice :::: ' + orderPrice);
                    Integer ifId = getIntegerNotNull(lData.get('INTERFACE_ID__c'));

                    if(!billToCode.equals('')){
                        billToCodeList.add(billToCode); //billToCode 리스트
                    }
                    if(!shipToCode.equals('')){
                        shipToCodeList.add(shipToCode); //billToCode 리스트
                    }
                    if (!partNo.equals('')) {
                        sPartNoList.add(partNo); //파트넘버 리스트
                    }
                    //gw.lee 23.12.07
                    //수량으로 추가 조치
                    if(orderQty != null){
                        qtyList.add(orderQty); //파트넘버 리스트
                    }
                    if(!modelNo.equals('')){
                        modelNoList.add(modelNo); //파트넘버 리스트
                    }
                    if(orderPrice != null){
                        orderPriceList.add(orderPrice); //금액정보 리스트
                    }
                    // if(!orderNo.equals('')){
                    //     orderNoList.add(orderNo); //orderNo 리스트
                    // }
                    if(!divCode.equals('')){ //24 01 29 hyungho.chun
                        divCodeList.add(divCode); //파트넘버 리스트
                    }                    

                    ifIdList.add(ifId);

                    System.debug('lData1 ::' + lData);
                    
                    // returnOrderMap.put(billToCode + '__' + shipToCode + '__' + String.valueOf(orderQty) + '__' + partNo + '__' + divCode + '__' + orderPrice + '___' + getStringNotNull(lData.get('Id')), lData);
                    // returnOrderMap.put(billToCode + '__' + shipToCode  + '__' + partNo + '__' + divCode  + '___' + getStringNotNull(lData.get('Id')), lData);
                    returnOrderMap.put(billToCode + '__' + partNo + '__' + divCode  + '___' + getStringNotNull(lData.get('Id')), lData); //24 02 07 hyungho.chun shiptToCode가 이제 필수 코드가 아님 //shoptocode가 안맞는경우도 체크함
                }

                System.debug('billToCodeList :::: ' + billToCodeList);
                System.debug('shipToCodeList :::: ' + shipToCodeList);
                System.debug('qtyList :::: ' + qtyList);
                System.debug('modelNoList:::: ' + modelNoList);
                System.debug('orderPriceList:::: ' + orderPriceList);

                //현재 들어온 반품건 기준 각 Key로 데이터 추출
                List<SI_CAREPLUS_ORDER__c> originList = [
                                                        SELECT   ID, ORDER_NO__c, BILL_TO_CODE__c, SHIP_TO_CODE__c, PART_NO__c, MODEL_CODE__c, ORDER_PRICE__c
                                                                 , ORDER_QTY__c, ORDER_AMT__c,TRANS_TYPE__c, CANCEL_FLAG__c, CreatedDate, NUM_ATT1__c, NUM_ATT2__c , DIV_CODE__c
                                                        FROM     SI_CAREPLUS_ORDER__c 
                                                        WHERE    BILL_TO_CODE__c IN :billToCodeList 
                                                        
                                                        AND      PART_NO__c      IN :sPartNoList 
                                                        AND      DIV_CODE__c   IN :divCodeList
                                                        AND      ORDER_QTY__c  != null 
                                                        AND      ORDER_PRICE__c  != null 
                                                        AND      TRANS_TYPE__c   = 'O' 
                                                        AND      CANCEL_FLAG__c  != 'Y' 
                                                        
                                                        
                                                        ORDER BY ORDER_QTY__c, ORDER_AMT__c, CreatedDate ASC 
                                                        LIMIT    10000 ];
                                                        //제거
                                                        // AND      ORDER_QTY__c    IN :qtyList
                                                        // AND      ORDER_PRICE__c    IN :orderPriceList

                                                        // AND      SHIP_TO_CODE__c IN :shipToCodeList  //02 07 hyungho.chun shiptoCode안맞는것도 이제 모수에서 찾음

                                                        //24 01 30 hyungho.chun 연계테스트위해 생성날짜오늘만 추가
                                                        //AND CreatedDate = TODAY 
            System.debug('originList:::: ' + originList);

            //같은 품목 원주문 정보 List 묶기
            for (SI_CAREPLUS_ORDER__c oObj : originList) {
                String billToCode = oObj.BILL_TO_CODE__c;
                String shipToCode = oObj.SHIP_TO_CODE__c;
                Decimal orderQty = getDecimalNotNull(oObj.ORDER_QTY__c);
                String partNo = oObj.PART_NO__c;
                String modelNo =  oObj.MODEL_CODE__c;
                String divCode = oObj.DIV_CODE__c;
                Decimal orderPrice = getDecimalNotNull(oObj.ORDER_PRICE__c);
                
                // String orderKey = billToCode + '__' + shipToCode + '__' + String.valueOf(orderQty) + '__' + partNo + '__' + modelNo + '__' + String.valueOf(orderPrice);
                // String orderKey = billToCode + '__' + shipToCode + '__' + String.valueOf(orderQty) + '__' + partNo + '__' + divCode + '__' + String.valueOf(orderPrice);
                // String orderKey = billToCode + '__' + shipToCode + '__' + partNo + '__' + divCode;
                String orderKey = billToCode + '__' + partNo + '__' + divCode; //24 02 07 hyungho.chun shiptocode가 더이상 필수가 아님
                System.debug('orderPrice1 :::: ' + orderPrice);
                System.debug('orderKey1 :::: ' + orderKey);
                if (orderMap.containsKey(orderKey)) {
                    List<SI_CAREPLUS_ORDER__c> tempList = orderMap.get(orderKey);
                    tempList.add(oObj);

                    orderMap.put(orderKey, tempList);
                } else {
                    orderMap.put(orderKey, new List<SI_CAREPLUS_ORDER__c>{oObj});
                }
            }


            Map<String, String> mergeMap = new Map<String, String>();

            System.debug('반품주문 모음 :::: ' + returnOrderMap);

                for (String reKey : returnOrderMap.keySet()) {
                    System.debug('reKey1 :: '+reKey);
                    String returnKey = reKey.split('___')[0];

                    System.debug('returnKey1 :::: ' + returnKey);
                    if (orderMap.containsKey(returnKey)) {
                        if (orderMap.get(returnKey).size() > 0) {
                                
                            List<SI_CAREPLUS_ORDER__c> orderList = orderMap.get(returnKey);

                            Boolean perfectFlag = false; //24 02 07 hyungho.chun -> bill ship 수량 금액 다 일치
                            Boolean similarFlag = false; //24 02 07 hyungho.chun -> bill ship 일치
                            Boolean existFlag = false; //24 02 07 hyunghoc.hun -> bill 수량 금액 일치

                            SI_CAREPLUS_ORDER__c saveObj = new SI_CAREPLUS_ORDER__c();

                            for (integer i = orderList.size() - 1; i > -1; i--) {
                                Decimal orderQTY = orderList[i].ORDER_QTY__c;
                                Decimal currentQTY = orderList[i].NUM_ATT1__c != null ? orderList[i].NUM_ATT1__c : 0;
                                Integer returnQTY = Integer.valueOf(returnOrderMap.get(reKey).get('ORDER_QTY__c'));
                                Decimal orderAmt = orderList[i].ORDER_AMT__c; 
                                Decimal currentAmt = orderList[i].NUM_ATT2__c != null ? orderList[i].NUM_ATT2__c : 0;
                                Integer returnOrderAmt = Integer.valueOf(returnOrderMap.get(reKey).get('ORDER_AMT__c'));

                                // if (orderQTY == returnQTY && currentQTY == 0 && currentAmt == 0) {   
                                if (orderQTY == returnQTY && currentQTY == 0 && currentAmt == 0 && orderList[i].SHIP_TO_CODE__c == getStringNotNull(returnOrderMap.get(reKey).get('SHIP_TO_CODE__c'))) { //24 02 07 hyungho.chun 원주문과 반품주문 shipTocode 일치 추가
                                
                                    if(orderList[i].NUM_ATT1__c != null){
                                        orderList[i].NUM_ATT1__c += returnQTY;  //24 01 29 hyungho.chun 원주문 num_att1에 반품주문수량 저장
                                    }else{
                                        orderList[i].NUM_ATT1__c = returnQTY;
                                    }
                                    if(orderList[i].NUM_ATT2__c != null){
                                        orderList[i].NUM_ATT2__c += returnOrderAmt;  //24 01 29 hyungho.chun 원주문 num_att2에 반품주문금액 저장
                                    }else{
                                        orderList[i].NUM_ATT2__c = returnOrderAmt;
                                    }                                    
                                    
                                    saveObj = getReforme(orderNoList, updateCancelList, orderList, saveObj, i);
                                    System.debug('reKey2 :: '+reKey);
                                    mergeMap.put(reKey, saveObj.ORDER_NO__c);
                                    orderMap.put(returnKey, orderList);
                                    perfectFlag = true; //24 01 29 hyungho.chun 원주문과 반품주문 수량 완전 동일
                                    break;
                                }

                            }
                            if(!perfectFlag){ //24 01 29 hyungho.chun 원주문과 반품주문 수량이 완전히 동일하지 않은 경우
                                for (integer i = orderList.size() - 1; i > -1; i--) {
                                    Decimal orderQTY = orderList[i].ORDER_QTY__c;
                                    Decimal currentQTY = orderList[i].NUM_ATT1__c != null ? orderList[i].NUM_ATT1__c : 0;
                                    Integer returnQTY = Integer.valueOf(returnOrderMap.get(reKey).get('ORDER_QTY__c'));
                                    Decimal orderAmt = orderList[i].ORDER_AMT__c; 
                                    Decimal currentAmt = orderList[i].NUM_ATT2__c != null ? orderList[i].NUM_ATT2__c : 0;
                                    Integer returnOrderAmt = Integer.valueOf(returnOrderMap.get(reKey).get('ORDER_AMT__c'));
    
                                    // if (orderQTY == returnQTY) {   
                                    // if(orderQTY - currentQTY >= returnQTY && orderAmt - currentAmt >= returnOrderAmt){    //24 01 29 hyungho.chun 개수 정확히일치하지않아도 금액 및 수량 비교하여 원주문 연결
                                    if(orderQTY - currentQTY >= returnQTY && orderAmt - currentAmt >= returnOrderAmt && orderList[i].SHIP_TO_CODE__c == getStringNotNull(returnOrderMap.get(reKey).get('SHIP_TO_CODE__c'))){   //24 02 07 hyungho.chun 원주문과 반품주문 shipTocode 일치 추가                                
                                        if(orderList[i].NUM_ATT1__c != null){
                                            orderList[i].NUM_ATT1__c += returnQTY;  //24 01 29 hyungho.chun 원주문 num_att1에 반품주문수량 저장
                                        }else{
                                            orderList[i].NUM_ATT1__c = returnQTY;
                                        }
                                        if(orderList[i].NUM_ATT2__c != null){
                                            orderList[i].NUM_ATT2__c += returnOrderAmt;  //24 01 29 hyungho.chun 원주문 num_att2에 반품주문금액 저장
                                        }else{
                                            orderList[i].NUM_ATT2__c = returnOrderAmt;
                                        }                                    
                                        
                                        saveObj = getReforme(orderNoList, updateCancelList, orderList, saveObj, i);
                                        System.debug('reKey3 :: '+reKey);
                                        mergeMap.put(reKey, saveObj.ORDER_NO__c);
                                        orderMap.put(returnKey, orderList);
                                        similarFlag = true; //24 02 07 hyungho.chun 
                                        break;
                                    }
    
                                    // if (!perfectFlag) {
                                    //     if (!similarFlag) {
                                    //         if (orderQTY >= returnQTY) {
                                    //             List<SI_CAREPLUS_ORDER__c> previousList = orderMap.get(returnKey);
                                    //             if (existFlag) { 
                                    //                 if (saveObj.ORDER_QTY__c > orderQty) {
                                    //                     getRestore(orderNoList, updateCancelList, orderList, saveObj);
                                                        
                                    //                     saveObj = getReforme(orderNoList, updateCancelList, orderList, saveObj, i);
                                    //                     mergeMap.put(reKey, saveObj.ORDER_NO__c);
                                    //                     orderMap.put(returnKey, orderList);
        
                                    //                     if (returnQTY  + 1 == orderQTY) {
                                    //                         similarFlag = true;
                                    //                     } else if (returnQTY  == orderQTY) {
                                    //                         perfectFlag = true;
                                    //                     }
                                    //                 }
                                    //             } else {
                                    //                 saveObj = getReforme(orderNoList, updateCancelList, orderList, saveObj, i);
                                    //                 mergeMap.put(reKey, saveObj.ORDER_NO__c);
                                    //                 orderMap.put(returnKey, orderList);
        
                                    //                 existFlag = true;
                                    //                 if (returnQTY  + 1 == orderQTY) {
                                    //                     similarFlag = true;
                                    //                 } else if (returnQTY  == orderQTY) {
                                    //                     perfectFlag = true;
                                    //                 }
                                    //             }
                                    //         } 
                                    //     } else if (orderQTY == returnQTY) {
                                    //         if (existFlag) {
                                    //             getRestore(orderNoList, updateCancelList, orderList, saveObj);
                                    //         }
        
                                    //         saveObj = getReforme(orderNoList, updateCancelList, orderList, saveObj, i);
                                    //         mergeMap.put(reKey, saveObj.ORDER_NO__c);
                                    //         orderMap.put(returnKey, orderList);
        
                                    //         break;
                                    //     }
                                    // }
                                }
                            }

                            if(!perfectFlag && !similarFlag){
                                for (integer i = orderList.size() - 1; i > -1; i--) {
                                    Decimal orderQTY = orderList[i].ORDER_QTY__c;
                                    Decimal currentQTY = orderList[i].NUM_ATT1__c != null ? orderList[i].NUM_ATT1__c : 0;
                                    Integer returnQTY = Integer.valueOf(returnOrderMap.get(reKey).get('ORDER_QTY__c'));
                                    Decimal orderAmt = orderList[i].ORDER_AMT__c; 
                                    Decimal currentAmt = orderList[i].NUM_ATT2__c != null ? orderList[i].NUM_ATT2__c : 0;
                                    Integer returnOrderAmt = Integer.valueOf(returnOrderMap.get(reKey).get('ORDER_AMT__c'));
    
                                    // if (orderQTY == returnQTY && currentQTY == 0 && currentAmt == 0) {   
                                    if (orderQTY == returnQTY && currentQTY == 0 && currentAmt == 0 && orderList[i].SHIP_TO_CODE__c != getStringNotNull(returnOrderMap.get(reKey).get('SHIP_TO_CODE__c'))) { //24 02 07 hyungho.chun 원주문과 반품주문 shipTocode 불일치건
                                    
                                        if(orderList[i].NUM_ATT1__c != null){
                                            orderList[i].NUM_ATT1__c += returnQTY;  //24 01 29 hyungho.chun 원주문 num_att1에 반품주문수량 저장
                                        }else{
                                            orderList[i].NUM_ATT1__c = returnQTY;
                                        }
                                        if(orderList[i].NUM_ATT2__c != null){
                                            orderList[i].NUM_ATT2__c += returnOrderAmt;  //24 01 29 hyungho.chun 원주문 num_att2에 반품주문금액 저장
                                        }else{
                                            orderList[i].NUM_ATT2__c = returnOrderAmt;
                                        }                                    
                                        
                                        saveObj = getReforme(orderNoList, updateCancelList, orderList, saveObj, i);
                                        System.debug('reKey2 :: '+reKey);
                                        mergeMap.put(reKey, saveObj.ORDER_NO__c);
                                        orderMap.put(returnKey, orderList);
                                        existFlag = true; //24 01 29 hyungho.chun 원주문과 반품주문 수량 완전 동일
                                        break;
                                    }
    
                                }                                
                            }

                            if(!perfectFlag && !similarFlag && !existFlag){
                                for (integer i = orderList.size() - 1; i > -1; i--) {
                                    Decimal orderQTY = orderList[i].ORDER_QTY__c;
                                    Decimal currentQTY = orderList[i].NUM_ATT1__c != null ? orderList[i].NUM_ATT1__c : 0;
                                    Integer returnQTY = Integer.valueOf(returnOrderMap.get(reKey).get('ORDER_QTY__c'));
                                    Decimal orderAmt = orderList[i].ORDER_AMT__c; 
                                    Decimal currentAmt = orderList[i].NUM_ATT2__c != null ? orderList[i].NUM_ATT2__c : 0;
                                    Integer returnOrderAmt = Integer.valueOf(returnOrderMap.get(reKey).get('ORDER_AMT__c'));
    
                                    // if (orderQTY == returnQTY) {   
                                    // if(orderQTY - currentQTY >= returnQTY && orderAmt - currentAmt >= returnOrderAmt){    //24 01 29 hyungho.chun 개수 정확히일치하지않아도 금액 및 수량 비교하여 원주문 연결
                                    if(orderQTY - currentQTY >= returnQTY && orderAmt - currentAmt >= returnOrderAmt && orderList[i].SHIP_TO_CODE__c != getStringNotNull(returnOrderMap.get(reKey).get('SHIP_TO_CODE__c'))){   //24 02 07 hyungho.chun 원주문과 반품주문 shipTocode 불일치건                                
                                        if(orderList[i].NUM_ATT1__c != null){
                                            orderList[i].NUM_ATT1__c += returnQTY;  //24 01 29 hyungho.chun 원주문 num_att1에 반품주문수량 저장
                                        }else{
                                            orderList[i].NUM_ATT1__c = returnQTY;
                                        }
                                        if(orderList[i].NUM_ATT2__c != null){
                                            orderList[i].NUM_ATT2__c += returnOrderAmt;  //24 01 29 hyungho.chun 원주문 num_att2에 반품주문금액 저장
                                        }else{
                                            orderList[i].NUM_ATT2__c = returnOrderAmt;
                                        }                                    
                                        
                                        saveObj = getReforme(orderNoList, updateCancelList, orderList, saveObj, i);
                                        System.debug('reKey3 :: '+reKey);
                                        mergeMap.put(reKey, saveObj.ORDER_NO__c);
                                        orderMap.put(returnKey, orderList);
                                        similarFlag = true; //24 02 07 hyungho.chun 
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }

                List<product2> mPartDataList = new List<product2>();
                if(!sPartNoList.isEmpty()){
                    // mPartDataList = [SELECT Id, DISABLED_DT__c, Name FROM product2 WHERE Name IN :sPartNoList AND CAREPLUS_YN__c = 'Y'];
                    mPartDataList = [SELECT Id, DISABLED_DT__c, Name FROM product2 WHERE Name IN :sPartNoList]; //24 02 23 hyungho.chun 단종체크 환입주문에들어온 파트넘버는 할 필요 없다
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
                System.debug('orderNoList.size() ::: ' + orderNoList.size()); //Total 25개
                System.debug('returnOrderList.size() ::: ' + returnOrderList.size()); //중복 3개
                
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

                System.debug('orderNoList.size() ::: ' + orderNoList.size());
                System.debug('orderNoList ::: ' + orderNoList);

                System.debug('productRequestList.size() ::: ' + productRequestList.size()); //22개 찾음

                List<ProductRequestLineItem> productRequestLineItemList = new List<ProductRequestLineItem>();
                if(!orderNoList.isEmpty() && !sPartNoList.isEmpty()){
                    strQuery = '';
                    strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
                    strQuery += ', parent.Order_Cust_Id__c ';
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
                System.debug('productRequestLineItemList ::: ' + productRequestLineItemList.size());

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
                List<ProductRequestLineItem> updatePrliList = new List<ProductRequestLineItem>();

                System.debug('mergeMap.keySet() :::: ' + mergeMap.keySet().size());
                System.debug('siCarePlusOrderList :::: ' + siCarePlusOrderList.size());

                for (String mKey : mergeMap.keySet()) {
                    System.debug('mKey :::: ' + mKey);
                    System.debug('values :::: ' + mergeMap.get(mKey));
                }
                
                for (sObject lData : siCarePlusOrderList) {

                    String result = 'SUCCESS';

                    /** billtocode */
                    String billToCode = getStringNotNull(lData.get('BILL_TO_CODE__c'));
                    /** shiptocode */
                    String shipToCode = getStringNotNull(lData.get('SHIP_TO_CODE__c'));
                    /* PART_NO */
                    String sPartNo = getStringNotNull(lData.get('PART_NO__c'));
                    /* PART_NO */
                    Decimal orderQty = getDecimalNotNull(lData.get('ORDER_QTY__c'));
                    
                    Integer shipQty = getIntegerNotNull(lData.get('ORDER_QTY__c')); //24 03 12 hyungho.chun shipQty 0 안넣고 order_Qty넣어줌
                    /* PART_NO */
                    String modelNo = getStringNotNull(lData.get('MODEL_CODE__c'));
                    /* ORDER_PRICE */
                    Decimal orderPrice = getDecimalNotNull(lData.get('ORDER_PRICE__c'));
                    /* Id */
                    String getId = getStringNotNull(lData.get('Id'));
                    /* divCode */
                    String divCode = getStringNotNull(lData.get('DIV_CODE__c'));

                    System.debug('lData2 ::' + lData);

                    // String returnKey = mergeMap.get(billToCode + '__' + shipToCode + '__' + orderQty + '__' + sPartNo + '__' + modelNo + '__' + String.valueOf(orderPrice) + '___' + getId);
                    // String returnKey = mergeMap.get(billToCode + '__' + shipToCode + '__' + orderQty + '__' + sPartNo + '__' + divCode + '__' + String.valueOf(orderPrice) + '___' + getId);
                    // String returnKey = mergeMap.get(billToCode + '__' + shipToCode + '__' + sPartNo + '__' + divCode + '___' + getId);
                    String returnKey = mergeMap.get(billToCode + '__' + sPartNo + '__' + divCode + '___' + getId); //24 02 07 hyungho.chun 더이상 shiptocode가 필수가 아님
                    System.debug('returnKey :::: ' + returnKey);

                    // if (returnKey != null) { //24 01 29 hyungho.chun 키없어도 일단만들고 잘만들어지면 roli에 prli연결 아닌경우 미연결
                        /** ORDER_NO */
                        //String carePlustOrderNo = getStringNotNull(lData.get('ORDER_NO__c'));
                        String carePlustOrderNo = returnKey;
                        /** TRANS_TYPE */
                        String sTransType = getStringNotNull(lData.get('TRANS_TYPE__c'));
                        /** ATTRIBUTE1 */ 
                        String sAttribute1 = '';
                        /** WROK FLAG */
                        String workFlag = '';
                        /** 현재 WORK FLAG */
                        String nowWorkFlag = getStringNotNull(lData.get('WORK_FLAG__c'));
                        if(nowWorkFlag.equals('')){nowWorkFlag = 'N';}
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
    
                        if(!returnOrderList.isEmpty()){
                            for(ReturnOrder ro : returnOrderList){
                                if(carePlustOrderNo.equals(ro.Order_Number__c)){
                                    roList.add(ro);
                                }
                            }
                        }
                        String prId = '';
                        ProductRequest oriPr = new ProductRequest();
                        if(!productRequestList.isEmpty()){
                            for(ProductRequest pr : productRequestList){
                                system.debug('carePlustOrderNo :: '+carePlustOrderNo);
                                system.debug('pr.Order_Number__c :: '+pr.Order_Number__c);
                                if(carePlustOrderNo != null && carePlustOrderNo.equals(pr.Order_Number__c)){
                                    prId = pr.Id;
                                    oriPr = pr;
                                }
                            }
                        }
                        system.debug('prId11 :: '+prId);
                        String prliId = '';
                        String orderCustId = '';
                        if(!productRequestLineItemList.isEmpty()){
                            for(ProductRequestLineItem prli : productRequestLineItemList){
                                if(carePlustOrderNo != null && carePlustOrderNo.equals(prli.Order_Number__c) && sPartNo.equals(prli.PART_NO__c)){
                                    prliId = prli.Id;
                                    orderCustId = prli.parent.Order_CUST_Id__c;
                                    // prli.Consumables_Order_Detail__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_100; 
                                    // prli.Consumables_Order_Detail__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_102; //24 01 24 hyungho.chun 원주문 상세 반품요청 -> 반품대기로 생성 //24 01 26 hyungho.chun 원주문 상세에 '반품대기'도 남길필요 없다
                                    
                                    
                                    //24 02 23 hyungho.chun 중복체크 필요
                                    if(!updatePrliList.contains(prli)){
                                        updatePrliList.add(prli);
                                    }
                                    
                                }
                            }
                        }
                        if(roList.isEmpty() && workFlag != 'E'){ //Insert //24 01 29 hyungho.chun 에러 즉 AR CODE만 있으면 일단 반품주문만든다
                            if( !(mPartData.size() > 0) ){ //24 01 29 hyungho.chun 케어용품인 파트넘버로 조회되지않는 경우 원주문 연결 하지않고 만든다 -> 추후반품반려만 가능
                                System.debug('반품요청한 파트넘버가 케어플러스용이 아님');
                                prId = '';
                                prliId = '';
                            }
                            /** ReturnOrder */
                            ReturnOrder ro = new ReturnOrder();
                            ro = setReturnOrder(lData, ro, prId, oriPr, false);
                            //roList.add(ro);
                            //insert ro;
                            insertRoList.add(ro);
                            /** ReturnOrderLineItem */
                            ReturnOrderLineItem roli = new ReturnOrderLineItem();
                            roli = setReturnOrderLineItem(lData, ro, roli, mPartData, prliId, orderCustId, false);
                            //roliList.add(roli);
                            //insert roli;
                            insertRoliList.add(roli);
                        }

                        lData.put('TRANSFER_FLAG__c', 'N');
                        lData.put('ATTRIBUTE1__c', '');

                        /** SI_CAREPLUS_BACKIF 테이블에 저장 */
                        //APPROVE 상태로 한번만 송신
    
                        if ('SUCCESS'.equals(result)) {
                            /** 반품자동승인 */
                            lData.put('WORK_FLAG__c', 'R');
    
                            /**   SR_CAREPLUS_ORDER 상태값 변경   */
                            //roli.Return_Request_Status__c = 'C'; (요청중 : N, 반품확정 : C, 반품완료 : Y, 반품반려 : X)
                            //roli.CONSUMABLE_ORDER_STATUS_120 = '120'; // 반품확정
                            //roli.CONFIRM_YN__c = 'Y'; // 반품 확정 여부
                            for(ReturnOrderLineItem roli : roliList){
    
                                ReturnOrderLineItem roli_u = new ReturnOrderLineItem();
                                roli_u.Id = roli.Id;
                                roli_u.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_120;
                                roli_u.CONFIRM_YN__c = 'Y';
                                listUpdateROLI.add(roli_u);
                            }
    
                            // backIfStatus = 'APPROVED';
                            // backIfStatus = 'APPROVED'; //24 01 24 hyungho.chun 배치돌면 이제 정상적인케이스 -> 위에서 지정해준 'AWAITING_RETURN'으로 들어간다
                            //lData.put('BACK_IF_STATUS__c', backIfStatus);
    
                            /** SI_CAREPLUS_BACKIF 데이터 생성   */
                            System.debug('InsertCareplusBackIf Status: ' + backIfStatus + ', data : ' + lData);
                            SI_CAREPLUS_BACKIF__c siB = new SI_CAREPLUS_BACKIF__c();
                            // siB = insertCareplusBackIf(lData, backIfStatus, sAttribute1, 0, 0, loopCnt, backIfMaxInterfaceId, backIfSubMaxInterfaceId);
                            siB = insertCareplusBackIf(lData, backIfStatus, sAttribute1, shipQty, 0, loopCnt, backIfMaxInterfaceId, backIfSubMaxInterfaceId);
                            listInsertSiBackIf.add(siB); 
                            result = 'SUCCESS';
                            loopCnt++;
                        }
                    // } else { //24 01 29 hyungho.chun 키없어도 일단만들고 잘만들어지면 roli에 prli연결 아닌경우 미연결
                    //     lData.put('WORK_FLAG__c', 'E');
                    //     lData.put('ATTRIBUTE1__c', 'ReturnOrder 미Match');
                    //     //lData.put('BACK_IF_SEND_YN__c', 'Y');
    
                    //     SI_CAREPLUS_ORDER__c siCareplusOrder = new SI_CAREPLUS_ORDER__c();
                    //     siCareplusOrder = updateSiCarePlusOrderWorkFlag(lData);
                    //     UpdateSiCareplusOrderList.add(siCareplusOrder);
                    // }


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
                        system.debug('INSERT ReturnOrderLineItem TOTAL : ' + insertRoliList.size());
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
                if(!updatePrliList.isEmpty()){
                    update updatePrliList;
                    system.debug('UPDATE ProductRequestLineItem TOTAL : ' + updatePrliList.size());
                }

                if (updateCancelList.size() > 0){
                    for (SI_CAREPLUS_ORDER__c uObj : updateCancelList) {
                        if(uObj.ORDER_QTY__c <= uObj.NUM_ATT1__c && uObj.ORDER_AMT__c <= uObj.NUM_ATT2__c ){
                            System.debug('원 careplus_order 모든품목 취소완료');
                            uObj.CANCEL_FLAG__c = 'Y';
                        }
                        
                    }

                    update updateCancelList;
                    system.debug('UPDATE updateCancelList TOTAL : ' + updateCancelList.size());
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
            errorMap.put('className','EX_CarePlusOrderReturn_ba.execute');
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
        successMap.put('className','EX_CarePlusOrderReturn_ba.finish');
        successMap.put('isSuccess','Y'); //24 02 25 hyungho.chun 성공 실패 여부 추가 (이메일 및 실패시 메세지 전송용)
        successMap.put('tempErrorMsg', 'EX_CarePlusOrderCancel_ba 성공한 케이스 recordId 모음');
        successMap.put('requestMsg', successCareplusOrderId);
        System.debug('Before Calling saveSaleExc // successMap :: '+successMap);
        EX_ConsumableUtil.saveSaleExc(successMap);

        System.debug('finish');
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

    //23.12.05 gw.lee
    //조건에 제외된 반품건 삭제
    public void getRestore(List<String> orderNoList, List<SI_CAREPLUS_ORDER__c> updateCancelList, List<SI_CAREPLUS_ORDER__c> orderList, SI_CAREPLUS_ORDER__c saveObj) {
        orderNoList.remove(orderNoList.size() - 1); //이전에 넣었던 건 삭제
        updateCancelList.remove(updateCancelList.size() - 1); //이전에 넣었던 건 삭제
        orderList.add(saveObj); //기존 원복건 추가
    }
    
    //23.12.05 gw.lee
    //조건에 맞는 반품건 재구성
    public static SI_CAREPLUS_ORDER__c getReforme(List<String> orderNoList, List<SI_CAREPLUS_ORDER__c> updateCancelList, List<SI_CAREPLUS_ORDER__c> orderList, SI_CAREPLUS_ORDER__c saveObj, Integer seq) {
        orderNoList.add(orderList[seq].ORDER_NO__c);//ReturnORder 및 ProductRequest찾는 역할

        //24 02 23 hyungho.chun 같은 모수안에 다른환입주문이 같은 원주문careplus order를 바라보는경우 update할 id값 중복오류로 로직 보완
        Boolean isDup = false;
        for(Integer i =0; i<updateCancelList.size(); i++){
            if(updateCancelList[i].Id == orderList[seq].Id){
                updateCancelList.set(i, orderList[seq]);
                isDup = true;
            }
        }
        if(!isDup){
            updateCancelList.add(orderList[seq]);//반품 사용한 원주문건 Update처리
        }
        
        saveObj = orderList[seq];
        // orderList.remove(seq); //24 01 29 hyungho.chun
    
        return saveObj;
    }


    @AuraEnabled
    public static ReturnOrder setReturnOrder(sObject lData, ReturnOrder ro, String prId, ProductRequest oriPr, Boolean existRo) {

        String carePlustOrderNo = getStringNotNull(lData.get('ORDER_NO__c'));

        ro.RecordTypeId = EX_ConsumableUtil.RO_CARE_SUPPLIES_RECORDTYPE_ID;

        if(!existRo && prId != null && prId != ''){ //24 01 29 hyungho.chun prId빈값으로 오면 연결안해준다 (매칭되는 원주문으 찾지못한경우 -> 차후 반품반려나 반품요청철회만 가능)
            system.debug('prId22 :: '+prId);
            ro.ProductRequestId = prId;
        }

        if(oriPr.AccountId != null && prId != null && prId != ''){ //24 01 29 hyungho.chun prId빈값으로 오면 연결안해준다 (매칭되는 원주문으 찾지못한경우 -> 차후 반품반려나 반품요청철회만 가능)
            ro.AccountId = oriPr.AccountId;
        }
        if(oriPr.Order_CUST_Id__c != null && prId != null && prId != ''){ //24 01 29 hyungho.chun prId빈값으로 오면 연결안해준다 (매칭되는 원주문으 찾지못한경우 -> 차후 반품반려나 반품요청철회만 가능)
            ro.ContactId = oriPr.Order_CUST_Id__c;
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
        // 수취인 우편번호
        ro.CONSIGNEE_PostalCode__c = getStringNotNull(lData.get('POSTAL_CODE__c'));
        //반품결제금액
        ro.RETURN_PAYMENT_Amount__c = getDecimalNotNull(lData.get('ORDER_AMT__c'));
        //반품판매금액
        ro.RETURN_SALE_Amount__c = getDecimalNotNull(lData.get('ORDER_AMT__c'));
        //케어플러스 현금결재금액
        ro.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c = getDecimalNotNull(lData.get('ORDER_AMT__c'));

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
    public static ReturnOrderLineItem setReturnOrderLineItem(sObject lData, ReturnOrder ro, ReturnOrderLineItem roli, List<Product2> p2List, String prliId, String orderCustId, Boolean existRoli) {
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
            // roli.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_100; //반품요청
            roli.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_102; //24 01 24 hyungho.chun 성공건도 이제 반품대기로 만든다
        }
        // 소모품 주문 고객 Contact Id
        if(orderCustId != null  && prliId != null && prliId != ''){ //24 01 29 hyungho.chun prliId빈값이 오면 연결안해준다 (매칭되는 원주문으 찾지못한경우 -> 차후 반품반려나 반품요청철회만 가능)
            roli.Order_CUST_Id__c = orderCustId;
        }

        //roli.Order_CUST_Id__c = contactId;
        // 소모품 주문 품목의 사업부 코드
        roli.ENDP_Code__c = sDivCode;

        // 소모품 주문 품목의 파트 넘버
        roli.Parts_Number__c = sPartNo;

        //roli.BASIS_Number__c = ro.Order_Number__c;
        roli.Order_Number__c = ro.Order_Number__c;

        if(!existRoli && prliId != null && prliId != ''){ //24 01 29 hyungho.chun prliId빈값이 오면 연결안해준다 (매칭되는 원주문으 찾지못한경우 -> 차후 반품반려나 반품요청철회만 가능)
            roli.ProductRequestLineItemId = prliId;
        }
        // 반품 요청 수량
        roli.QuantityReturned = orderQty;
        roli.Expected_Return_Quantity__c = orderQty;

        // 반품 요청 일시
        // roli.Return_Order_Request_DTM__c = getDatetimeWithNull(lData.get('ORDER_DATE__c'));
        //23 09 20 hyungho.chun 시간차이 -9시간
        // roli.Return_Order_Request_DTM__c = getDatetimeWithNull(lData.get('ORDER_DATE__c')).addHours(-9);
        roli.Return_Order_Request_DTM__c = getDatetimeWithNull(lData.get('ORDER_DATE__c')); //24 03 11 hyungho.chun 이제 히로쿠에서 9시간 차감해준후에 보내주기때문에 따로 로직제거
        // 반품 요청자
        //consumableReturnOrderLineItem.Return_Requester_Id_c__c = UserInfo.getUserId();



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