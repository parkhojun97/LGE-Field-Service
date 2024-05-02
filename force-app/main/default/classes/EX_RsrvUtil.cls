/**
 * Created by A80598 on 2023-03-06.
 * 소모품 예약관련 공통모듈
 */

 public with sharing class EX_RsrvUtil {

    /**
     * 자재쪽 공통모듈 호출 간소화
     *
     * @param requestQTY 수량
     * @param requestType 코드
     * @param prli ProductRequestLineItem
     *
     * 호출방법 : EX_RsrvUtil.execApplyProductItem(수량, 코드, ProductRequestLineItem);
     * 코드참고 : FS_MaterialUtil.applyProductItem 함수
     *
     * @return Map<String, Object>
     *     'isSuccess'
     *     'errMsg'
     */

    public static Map<String, Object> execApplyProductItem(Decimal requestQTY, String requestType, ProductRequestLineItem prli) {
        List<Map<String, Object>> pListMapRequestInfo = new List<Map<String, Object>>();
        Map<String, Object> mapRequestInfo;
        Set<String> partIdSet = new Set<String>();
        Set<String> locationIdSet = new Set<String>();

        mapRequestInfo = new Map<String, Object>();
        mapRequestInfo.put('product2Id', prli.Product2Id);
        mapRequestInfo.put('sourceLocationId', prli.SourceLocationId);
        mapRequestInfo.put('destinationLocationId', prli.DestinationLocationId);

        //모듈 수량, 코드 설정
        mapRequestInfo.put('requestQTY', requestQTY); //수량
        mapRequestInfo.put('requestType', requestType); // 코드

        mapRequestInfo.put('productRequestLineItem', prli);
        mapRequestInfo.put('returnOrderLineItem', null);
        mapRequestInfo.put('productTransfer', null);

        partIdSet.add(prli.product2Id);
        locationIdSet.add(prli.SourceLocationId);
        locationIdSet.add(prli.DestinationLocationId);

        pListMapRequestInfo.add(mapRequestInfo);

        Map<String, ProductItem> pMapProductItemByKey = new Map<String, ProductItem>();
        String stqProductItemQry = '';
        stqProductItemQry += 'SELECT ' + SObjectUtil.getFieldForQuery('ProductItem');
        stqProductItemQry += '  FROM ProductItem';
        stqProductItemQry += ' WHERE Product2Id IN :partIdSet AND LocationId IN :locationIdSet';

        List<ProductItem> productItems = Database.query(stqProductItemQry);
        // Key :  {!sourceLocationId} + '^' + {!Product2Id}
        String strKeyPI = '';
        for (ProductItem productItem : productItems) {
            strKeyPI = productItem.LocationId + '^' + productItem.Product2Id;
            pMapProductItemByKey.put(strKeyPI, productItem);
        }

        Map<String, Object> rtnMap = new Map<String, Object>();
        // 자재 호출
        rtnMap = FS_MaterialUtil.applyProductItem(pListMapRequestInfo, pMapProductItemByKey);

        return rtnMap;
    }

    /**
     * 자재쪽 공통모듈 호출 간소화(다건)
     */

    public static Map<String, Object> execApplyProductItemMulti(String requestType, List<ProductRequestLineItem> prliList) {
        List<Map<String, Object>> pListMapRequestInfo = new List<Map<String, Object>>();
        Set<String> partIdSet = new Set<String>();
        Set<String> locationIdSet = new Set<String>();
        if(!prliList.isEmpty()){
            for(ProductRequestLineItem prli : prliList){
                Map<String, Object> mapRequestInfo;
                mapRequestInfo = new Map<String, Object>();
                mapRequestInfo.put('product2Id', prli.Product2Id);
                mapRequestInfo.put('sourceLocationId', prli.SourceLocationId);
                mapRequestInfo.put('destinationLocationId', prli.DestinationLocationId);
                //모듈 수량, 코드 설정
                if(requestType != null && (requestType.equals('AB') || requestType.equals('AE'))){ //23 12 21 hyungho.chun AE 추가(취소시 RESRV_QTY__c)감소용
                    mapRequestInfo.put('requestQTY', prli.CANCEL_Quantity__c); //취소수량
                }else{
                    mapRequestInfo.put('requestQTY', prli.QuantityRequested); //수량
                }
                mapRequestInfo.put('requestType', requestType); // 코드
                mapRequestInfo.put('productRequestLineItem', prli);
                mapRequestInfo.put('returnOrderLineItem', null);
                mapRequestInfo.put('productTransfer', null);
                partIdSet.add(prli.product2Id);
                locationIdSet.add(prli.SourceLocationId);
                locationIdSet.add(prli.DestinationLocationId);
                pListMapRequestInfo.add(mapRequestInfo);
            }
        }

        Map<String, ProductItem> pMapProductItemByKey = new Map<String, ProductItem>();
        String stqProductItemQry = '';
        stqProductItemQry += 'SELECT ' + SObjectUtil.getFieldForQuery('ProductItem');
        stqProductItemQry += '  FROM ProductItem';
        stqProductItemQry += ' WHERE Product2Id IN :partIdSet AND LocationId IN :locationIdSet';

        List<ProductItem> productItems = Database.query(stqProductItemQry);
        // Key :  {!sourceLocationId} + '^' + {!Product2Id}
        String strKeyPI = '';
        for (ProductItem productItem : productItems) {
            strKeyPI = productItem.LocationId + '^' + productItem.Product2Id;
            pMapProductItemByKey.put(strKeyPI, productItem);
        }

        Map<String, Object> rtnMap = new Map<String, Object>();
        // 자재 호출
        rtnMap = FS_MaterialUtil.applyProductItem(pListMapRequestInfo, pMapProductItemByKey);

        return rtnMap;
    }

    /**
     * 약속관련 공통모듈(다건)
     *
     * 1. SR_RESRV_PART__c 약속생성
     * 2. ProductRequest 생성
     * 3. ProductRequestLineItem 생성
     * 4. SI_REQUEST 사업부PO요청 생성
     *
     * @param Map<String, Object>
     *     oriPrId 원주문 ProductRequestId
     *     oriPrliId 원주문 ProductRequestLineItemId
     *     oriOrderNo 원주문번호
     *     oriOrderSeq 원주문Seq
     *     deptCode 부서코드
     *     partNo 파트넘버
     *     req_qty 요청수량
     *     div_code 사업부
     *
     * @return Map<String, Object>
     *     'isSuccess'
     *     'errMsg'
     */
    public static Map<String, Object> RESRV_MODULE(List<Map<String, Object>> mapList) {
        Map<String, Object> finalRtnMap = new Map<String, Object>();
        Boolean boolIsSuccess = false;
        String strErrMsg = '';
        //String rsrvNo = ''; // TEXT C000000296
        String rsvPrliId = '';
        Integer rsrvSeq = 1;

        if(!mapList.isEmpty()) {
            List<String> deptCodeList = new List<String>();
            List<String> divCodeList = new List<String>();
            List<String> partNoList = new List<String>();
            List<String> oriOrderNoList = new List<String>();
            Map<String, String> locationMap = new Map<String, String>();

            for (Map<String, Object> m : mapList) {
                System.debug('m1:' + m.get('oriPrId'));
                System.debug('m2:' + m.get('oriPrliId'));
                System.debug('m3:' + m.get('oriOrderNo'));
                System.debug('m4:' + m.get('oriOrderSeq'));
                System.debug('m5:' + m.get('deptCode'));
                System.debug('m6:' + m.get('partNo'));
                System.debug('m7:' + m.get('req_qty'));
                System.debug('m8:' + m.get('div_code'));
                if (m.get('deptCode') != null && !m.get('deptCode').equals('')) {
                    String deptCode = String.valueOf(m.get('deptCode'));
                    deptCodeList.add(deptCode);
                }
                if (m.get('div_code') != null && !m.get('div_code').equals('')) {
                    String divCode = String.valueOf(m.get('div_code'));
                    divCodeList.add(divCode);
                }
                if (m.get('partNo') != null && !m.get('partNo').equals('')) {
                    String partNo = String.valueOf(m.get('partNo'));
                    partNoList.add(partNo);

                    String divCode = String.valueOf(m.get('div_code'));
                }
                if (m.get('oriOrderNo') != null && !m.get('oriOrderNo').equals('')) {
                    String oriOrderNo = String.valueOf(m.get('oriOrderNo'));
                    oriOrderNoList.add(oriOrderNo);
                }

            }

            Id idCenterLocation = SObjectType.Location.getRecordTypeInfosByDeveloperName().get('Center').getRecordTypeId();

            List<Schema.Location> objLocationList = new List<Schema.Location>();
            List<SM_DEPT__c> smdList = new List<SM_DEPT__c>();

            if (!deptCodeList.isEmpty()) {
                objLocationList = [SELECT Id, Name, DEPT_CODE__c FROM Location WHERE DEPT_CODE__c IN :deptCodeList AND RecordTypeId = :idCenterLocation];
                smdList = [SELECT Id, DEPT_CODE__c FROM SM_DEPT__c WHERE DEPT_CODE__c IN :deptCodeList];
            }

            List<Schema.Location> sourceLocationList = new List<Schema.Location>();
            if (!divCodeList.isEmpty()) {
                sourceLocationList = [SELECT Id, Name, DIV_CODE__c FROM Location WHERE DIV_CODE__c IN :divCodeList AND fm_RecordType__c = 'DIV'];

                for (Schema.Location lObj : sourceLocationList) {
                    locationMap.put(lObj.DIV_CODE__c, lObj.Id);
                }
            }

            List<ProductItem> productItemList = new List<ProductItem>();
            List<Product2> product2List = new List<Product2>();
            if (!partNoList.isEmpty() && !divCodeList.isEmpty()) {
                System.debug('partNoList : ' + partNoList);
                System.debug('divCodeList : ' + divCodeList);
                productItemList = [
                        SELECT Id, fm_Parts_Number__c, fm_DIV_CODE__c, Product2Id, Product2.DIV_CODE__c, Product2.MODEL_CODE__c, Product2.CUST_PRICE__c, Product2.ASC_PRICE__c, ORDER_QTY__c, Location.RecordType.DeveloperName, RESRV_UNRCV_QTY__c
                        FROM ProductItem
                        WHERE fm_Parts_Number__c IN :partNoList
                        AND fm_DIV_CODE__c IN :divCodeList
                        AND (Location.RecordType.DeveloperName = 'DIV' OR (Location.RecordType.DeveloperName = 'Location' AND Location.Name = :System.Label.EX_Location))
                ];
                product2List = [
                        SELECT Id, fm_PartNo__c, DIV_CODE__c, MODEL_CODE__c, CUST_PRICE__c, ASC_PRICE__c
                        FROM Product2
                        WHERE fm_PartNo__c IN :partNoList
                        AND DIV_CODE__C IN :divCodeList
                ];
            }
            List<ProductRequest> oriPrList = new List<ProductRequest>();
            if (!oriOrderNoList.isEmpty()) {
                oriPrList = [SELECT Order_Number__c, AccountId, Order_CUST_Id__c, Order_CHNL_TYPE_Code__c FROM ProductRequest WHERE Order_Number__c IN :oriOrderNoList AND (AccountId != null OR Order_CUST_Id__c != null)];
            }

            //SrResrvPart, ProductRequest 동일주문번호당 1건씩 생성
            List<String> insertedOrderNoList = new List<String>();
            List<Map<String, Object>> SrResrvPartMapList = new List<Map<String, Object>>();
            List<Map<String, Object>> ProductRequestMapList = new List<Map<String, Object>>();
            List<ProductItem> updatePiList = new List<ProductItem>();
            List<ProductRequest> updateOriPrList = new List<ProductRequest>();
            List<ProductRequestLineItem> updateOriPrliList = new List<ProductRequestLineItem>();

            Map<String, SR_RESRV_PART__c> insertSrResrvPartMap = new Map<String, SR_RESRV_PART__c>();
            List<ProductRequest> insertPrList = new List<ProductRequest>();
            List<ProductRequestLineItem> insertPrliList = new List<ProductRequestLineItem>();

            Integer onlineInstockCnt = 1;
            for (Map<String, Object> mapItem : mapList) {
                String deptCode = '';
                String divCode = '';
                String partNo = '';
                String oriPrId = '';
                String oriPrliId = '';
                String oriOrderNo = '';
                Integer oriOrderSeq = 1;
                Boolean isInstock = false;
                if (mapItem.get('deptCode') != null && !mapItem.get('deptCode').equals('')) {
                    deptCode = String.valueOf(mapItem.get('deptCode'));
                }
                if (mapItem.get('partNo') != null && !mapItem.get('partNo').equals('')) {

                    partNo = String.valueOf(mapItem.get('partNo'));
                }
                if (mapItem.get('div_code') != null && !mapItem.get('div_code').equals('')) {
                    divCode = String.valueOf(mapItem.get('div_code'));
                }
                if (mapItem.get('oriPrId') != null && !mapItem.get('oriPrId').equals('')) {
                    oriPrId = String.valueOf(mapItem.get('oriPrId'));
                } else {
                    isInstock = true;
                }
                if (mapItem.get('oriPrliId') != null && !mapItem.get('oriPrliId').equals('')) {
                    oriPrliId = String.valueOf(mapItem.get('oriPrliId'));
                }
                if (mapItem.get('oriOrderNo') != null && !mapItem.get('oriOrderNo').equals('')) {
                    oriOrderNo = String.valueOf(mapItem.get('oriOrderNo'));
                }
                if (mapItem.get('oriOrderSeq') != null && !mapItem.get('oriOrderSeq').equals('')) {
                    oriOrderSeq = Integer.valueOf(mapItem.get('oriOrderSeq'));
                }

                system.debug('deptCode : ' + deptCode + ', partNo : ' + partNo);

                Boolean needInsert = true; // SrResrvPart & ProductRequest 생성 필요 여부
                if (insertedOrderNoList.isEmpty()) {
                    needInsert = true;
                } else {
                    for (String ion : insertedOrderNoList) {
                        if (ion.equals(oriOrderNo)) {
                            needInsert = false;
                            rsrvSeq++;
                        }
                    }
                }
                if (needInsert) {
                    rsrvSeq = 1;
                }
                if (needInsert && !oriOrderNo.equals('')) {
                    insertedOrderNoList.add(oriOrderNo);
                }

                if (needInsert) { // SrResrvPart & ProductRequest 생성 필요 chk
                    /**  1. SR_RESRV_PART__c 약속생성 req_type = ‘S’ => SR_RESRV_PART__c*/
                    //sourceLocationList
                    String sourceId = '';
                    // if (!sourceLocationList.isEmpty()) {
                    //     for (Schema.Location lo : sourceLocationList) {
                    //         if (divCode.equals(lo.DIV_CODE__c)) {
                    //             sourceId = lo.Id;
                    //         }
                    //     }
                    // }
                    if (locationMap.get(divCode) != null) {
                        sourceId = locationMap.get(divCode);
                    }

                    String destinationId = '';
                    if (!objLocationList.isEmpty()) {
                        for (Schema.Location lo : objLocationList) {
                            System.debug('deptCode => ' + deptCode);
                            System.debug('lo.DEPT_CODE__c -> ' + lo.DEPT_CODE__c);
                            if (deptCode.equals(lo.DEPT_CODE__c)) {
                                destinationId = lo.Id;
                            }
                        }
                    }

                    String smdId = '';
                    if (!smdList.isEmpty()) {
                        for (SM_DEPT__c smd : smdList) {
                            if (deptCode.equals(smd.DEPT_CODE__c)) {
                                smdId = smd.Id;
                            }
                        }
                    }

                    Map<String, Object> rtnMap = new Map<String, Object>();
                    rtnMap = createSrResrvPart(destinationId);
                    if(rtnMap.get('isSuccess') != null && Boolean.valueOf(rtnMap.get('isSuccess'))) {
                        SR_RESRV_PART__c objSrResrvPart = (SR_RESRV_PART__c) rtnMap.get('objSrResrvPart');

                        if(oriOrderNo != null && !oriOrderNo.equals('')){
                            insertSrResrvPartMap.put(oriOrderNo,objSrResrvPart);
                        }else{ //재입고 처리 시
                            insertSrResrvPartMap.put(String.valueOf(onlineInstockCnt),objSrResrvPart);
                            onlineInstockCnt++;
                        }

                        //생성된 SrResrvPart 삽입
                        Map<String,Object> srResrvPartMap = new Map<String, Object>();
                        srResrvPartMap.put('objSrResrvPart', objSrResrvPart);
                        srResrvPartMap.put('oriOrderNo', oriOrderNo);
                        SrResrvPartMapList.add(srResrvPartMap);

                        /** Product Request INSERT*/
                        rtnMap = createProductRequest(deptCode, oriOrderNo, oriPrList, destinationId, sourceId, smdId, isInstock);
                        ProductRequest objInsertPR = (ProductRequest) rtnMap.get('objProductRequest');
                        insertPrList.add(objInsertPR);

                        //생성된 ProductRequest 삽입
                        Map<String, Object> objInsertPRMap = new Map<String, Object>();
                        objInsertPRMap.put('objInsertPR', objInsertPR);
                        objInsertPRMap.put('oriOrderNo', oriOrderNo);
                        ProductRequestMapList.add(objInsertPRMap);

                        /** 원주문 ProductRequest 업데이트 */
                        if (!oriPrId.equals('')) {
                            ProductRequest upr = new ProductRequest();
                            upr.Id = oriPrId;
                            upr.Order_Number__c = oriOrderNo;
                            //upr.RSRV_Number__c = objInsertPR.RSRV_Number__c;
                            //upr.SR_RSRV_PART_Id__c = objInsertPR.SR_RSRV_PART_Id__c;
                            updateOriPrList.add(upr);
                        }
                    }
                } // SrResrvPart & ProductRequest 생성 필요 chk

                /** Product Request Line Item INSERT*/
                SR_RESRV_PART__c objSrResrvPart = new SR_RESRV_PART__c();
                if(!SrResrvPartMapList.isEmpty()){
                    for(Map<String, Object> SrResrvPartMap : SrResrvPartMapList){
                        if(SrResrvPartMap.get('oriOrderNo').equals(oriOrderNo)){
                            objSrResrvPart = (SR_RESRV_PART__c) SrResrvPartMap.get('objSrResrvPart');
                            break;
                        }
                    }
                }

                ProductRequest objInsertPR = new ProductRequest();
                if (!ProductRequestMapList.isEmpty()) {
                    for (Map<String, Object> ProductRequestMap : ProductRequestMapList) {
                        if (ProductRequestMap.get('oriOrderNo').equals(oriOrderNo)) {
                            objInsertPR = (ProductRequest) ProductRequestMap.get('objInsertPR');
                            break;
                        }
                    }
                }

                Map<String, Object> rtnMap = new Map<String, Object>();
                List<ProductItem> newPiList = new List<ProductItem>();
                if (!productItemList.isEmpty()) {
                    for (ProductItem piFromList : productItemList) {
                        //SELECT Id, fm_Parts_Number__c, fm_DIV_CODE__c, Product2Id, Product2.DIV_CODE__c, Product2.MODEL_CODE__c, Product2.CUST_PRICE__c, Product2.ASC_PRICE__c, ORDER_QTY__c, Location.RecordType.DeveloperName, RESRV_UNRCV_QTY__c

                        String partsNo = piFromList.fm_Parts_Number__c;
                        String divCo = piFromList.fm_DIV_CODE__c;

                        System.debug('ProductItem.Id : ' + piFromList.Id);
                        System.debug('ProductItem.fm_Parts_Number__c : ' + piFromList.fm_Parts_Number__c);
                        System.debug('ProductItem.fm_DIV_CODE__c : ' + piFromList.fm_DIV_CODE__c);
                        System.debug('ProductItem.Product2Id : ' + piFromList.Product2Id);
                        // if (partsNo.equals(partNo) && divCo.equals(divCode)) {
                if (partsNo.equals(partNo) && divCo.equals(divCode) && piFromList.Location.RecordType.DeveloperName =='DIV') { //24 02 20 hyungho.chun 예약타입 주문은 productitem__c에 사업부pi가 연결되어야한다
                            newPiList.add(piFromList);
                        }
                    }
                }

                List<Product2> newP2List = new List<Product2>();
                if (!product2List.isEmpty()) {
                    for (Product2 p2FromList : product2List) {
                        String partsNo = p2FromList.fm_PartNo__c;
                        String divCo = p2FromList.DIV_CODE__c;
                        if (partsNo.equals(partNo) && divCo.equals(divCode)) {
                            newP2List.add(p2FromList);
                        }
                    }
                }
                String sourceIdTemp = locationMap.get(divCode);
                mapItem.put('sourceId', sourceIdTemp);
                rtnMap = createProductRequestLineItem(mapItem, deptCode, partNo, objInsertPR, oriOrderSeq, newPiList, newP2List, isInstock, rsrvSeq);
//                if (rtnMap.get('isSuccess') != null && Boolean.valueOf(rtnMap.get('isSuccess'))) {
                ProductRequestLineItem objProductRequestLineItem = (ProductRequestLineItem) rtnMap.get('objProductRequestLineItem');
                insertPrliList.add(objProductRequestLineItem);

                /** 원주문 ProductRequestLineItem 업데이트 */
                if (!oriPrliId.equals('')) {
                    ProductRequestLineItem uprli = new ProductRequestLineItem();
                    uprli.Id = oriPrliId;
                    uprli.Order_Number__c = oriOrderNo;
                    //uprli.RSRV_Number__c = objProductRequestLineItem.RSRV_Number__c;

                    uprli.RSRV_SEQ__c = objProductRequestLineItem.RSRV_SEQ__c;
                    //uprli.SR_RESRV_PART_Id__c	= objProductRequestLineItem.SR_RESRV_PART_Id__c;
                    //uprli.Order_SEQ__c = objProductRequestLineItem.RSRV_SEQ__c;
                    //uprli.Order_SEQ__c = objProductRequestLineItem.Order_SEQ__c;
//                    Decimal orderSeq = objProductRequestLineItem.Order_SEQ__c;
//                    if(orderSeq != null && orderSeq > 100){
//                        String strOrderSeq = String.valueOf(orderSeq).right(2);
//                        orderSeq = Decimal.valueOf(strOrderSeq);
//                    }
//                    uprli.Order_SEQ__c = objProductRequestLineItem.Order_SEQ__c;
                    uprli.Appointment_Status__c = '요청';
                    updateOriPrliList.add(uprli);
                }

                /** 사업부 PO 요청 생성 SI_REQUEST__c => 트리거 ProductRequestLineItem_tr > DN_CommonUtil.setSequancedRecords */
                //조건 ProductRequestLineItem의 SourceLocation.RecordType.DeveloperName == 'DIV' && Order_Number__c 가 null 이여야 함.

                if (mapItem.get('req_qty') != null && !mapItem.get('req_qty').equals('')) {
//                        system.debug('센터 (약속미입고(+)) 처리 START');
                    Integer req_qty = Integer.valueOf(mapItem.get('req_qty'));
                    /** 사업부 주문 (주문수량(+)) 처리 */
                    system.debug('사업부주문(주문수량(+)) 처리 START');
                    execApplyProductItem(req_qty, 'AL', objProductRequestLineItem); //사업부 주문 (주문수량(+))
                    if (objProductRequestLineItem.ProductItem__c != null) {
                        Integer productItemQty = 0;
                        if (rtnMap.get('productItemQty') != null) {
                            productItemQty = Integer.valueOf(rtnMap.get('productItemQty'));
                        }
                        Integer piOrderQty = productItemQty + req_qty;
                        system.debug('productItemQty : ' + productItemQty);
                        system.debug('piOrderQty : ' + piOrderQty);
                        if (rtnMap.get('divPiId') != null) {
                            if (!rtnMap.get('divPiId').equals('')) {
                                String devPiId = String.valueOf(rtnMap.get('divPiId'));
                                system.debug('ProductItem__c : ' + devPiId);
                                Boolean exist = false;
                                for(ProductItem ckpi : updatePiList){
                                    if(ckpi.Id == devPiId){
                                        exist = true;
                                        ckpi.ORDER_QTY__c += piOrderQty;
                                    }
                                }
                                if (exist == false && piOrderQty > 0) {
                                    ProductItem upi = new ProductItem();
                                    upi.Id = devPiId;
                                    upi.ORDER_QTY__c = piOrderQty;
                                    updatePiList.add(upi);
                                }
                            }
                        }
                    }
                }

                system.debug('사업부주문(주문수량(+)처리 END');

                boolIsSuccess = true;
                if(oriPrliId != null && !oriPrliId.equals('')){
                    finalRtnMap.put(oriPrliId, boolIsSuccess);
                }
            }//for (Map<String, Object> mapItem : mapList)

            System.debug('INSERT SR_RESRV_PART__c START ::: ');
            //SR_RSRV_PART_Id__c, ProductRequest = 1:1
//            Map<String, String> finalMap = new Map<String, String>();
            if(insertSrResrvPartMap != null && !insertSrResrvPartMap.values().isEmpty()) {
                insert insertSrResrvPartMap.values();

                List<String> srRPIds = new List<String>();
                for(SR_RESRV_PART__c srrp : insertSrResrvPartMap.values()){
                    srRPIds.add(srrp.Id);
                }

                List<SR_RESRV_PART__c> srRPList = [SELECT Id, RSRV_Number__c,RESRV_Number__c FROM SR_RESRV_PART__c WHERE Id IN :srRPIds];

                if(!insertPrList.isEmpty()){
                    Integer insertprCnt = 1;
                    for(ProductRequest ipr : insertPrList){
                        String orderNo = ipr.Order_Number__c;
                        System.debug('orderNo : ' + orderNo);
                        if(orderNo != null && !orderNo.equals('') && insertSrResrvPartMap.get(orderNo) != null){
                            ipr.SR_RSRV_PART_Id__c = insertSrResrvPartMap.get(ipr.Order_Number__c).id;
                        }else{//재입고
                            ipr.SR_RSRV_PART_Id__c = insertSrResrvPartMap.get(String.valueOf(insertprCnt)).id;
                            insertprCnt++;
                        }
                        for(SR_RESRV_PART__c srrp : srRPList){
                            if(srrp.Id == ipr.SR_RSRV_PART_Id__c){
                                //23 12 01 hyungho.chun RSRV_Number__c 말고 RESRV_Number__c 넣어줘야함
                                // ipr.RSRV_Number__c = 'C' + srrp.RSRV_Number__c;
                                ipr.RSRV_Number__c = srrp.RESRV_Number__c;
                            }
                        }
                        System.debug('ipr.RSRV_Number__c :: ' + ipr.RSRV_Number__c);
                        System.debug('SR_RSRV_PART_Id__c :: ' + ipr.SR_RSRV_PART_Id__c);
                    }
                    System.debug('INSERT ProductRequest START ::: ');
                    insert insertPrList;
                    System.debug('insertPrList TOTAL : ' + insertPrList.size());

//                /** OriOrderNumber와 RSRV_NUMBER를 매핑하기위한 작업 */
//                Map<String, String> oriOrderMap = new Map<String, String>();
//                for (ProductRequest prm : insertPrList) {
//                    oriOrderMap.put(prm.Id, prm.Order_Number__c);
//                }
//
//                List<String> prIdList = new List<String>();
//                for (ProductRequest pr : insertPrList) {
//                    prIdList.add(pr.Id);
//                }
//
//                List<ProductRequest> insertedProductRequestList = new List<ProductRequest>();
//                insertedProductRequestList = [SELECT Id, RSRV_Number__c FROM ProductRequest WHERE Id IN :prIdList];
//
//                if (!insertedProductRequestList.isEmpty()) {
//                    for (ProductRequest fpr : insertedProductRequestList) {
//                        if (oriOrderMap.get(fpr.Id) != null) {
//                            String oriOrderNumber = oriOrderMap.get(fpr.Id);
//                            finalMap.put(oriOrderNumber, fpr.RSRV_Number__c);
//                        }
//                    }
//                }

                    /** 원주문 ProductRequest UPDATE */
                    if (!updateOriPrList.isEmpty()) {
                        System.debug('UPDATE Ori ProductRequest START ::: ');
                        for (ProductRequest oriPr : updateOriPrList) {
//                            if (finalMap.get(oriPr.Order_Number__c) != null) {
//                                oriPr.RSRV_Number__c = finalMap.get(oriPr.Order_Number__c);
//                            }
                            oriPr.SR_RSRV_PART_Id__c = insertSrResrvPartMap.get(oriPr.Order_Number__c).id;
                            for(SR_RESRV_PART__c srrp : srRPList){
                                if(srrp.Id == oriPr.SR_RSRV_PART_Id__c){
                                    //23 12 01 hyungho.chun RSRV_Number__c 말고 RESRV_Number__c 넣어줘야함
                                    // oriPr.RSRV_Number__c = 'C' + srrp.RSRV_Number__c;
                                    oriPr.RSRV_Number__c = srrp.RESRV_Number__c;
                                }
                            }
                            System.debug('oriPr.RSRV_Number__c :: ' + oriPr.RSRV_Number__c);
                        }
                        update updateOriPrList;
                        System.debug('updateOriPrList TOTAL : ' + updateOriPrList.size());
                    }
                }
            }
            System.debug('INSERT(SR_RESRV_PART__c, ProductRequest), UPDATE(ProductRequest) END ::: ');

            System.debug('INSERT ProductRequestLineItem START ::: ');
            if (!insertPrliList.isEmpty()) {
                for (ProductRequestLineItem iprli : insertPrliList) {
                    if (!insertPrList.isEmpty()) {
                        for (ProductRequest insertedPr : insertPrList) {
                            String iprliOrderNo = iprli.Order_Number__c;
                            String insertedPrOrderNo = insertedPr.Order_Number__c;
                            if (insertedPrOrderNo != null && iprliOrderNo != null && insertedPrOrderNo.equals(iprliOrderNo)) {
                                iprli.ParentId = insertedPr.Id;
                                iprli.SR_RESRV_PART_Id__c = insertedPr.SR_RSRV_PART_Id__c;
                                iprli.RSRV_Number__c = insertedPr.RSRV_Number__c;
//                                iprli.RSRV_Number__c = finalMap.get(iprliOrderNo);
                                break;
                            }
                        }
                    }
                    System.debug('iprli.RSRV_Number__c :: ' + iprli.RSRV_Number__c);
                }
                for (ProductRequestLineItem iprli : insertPrliList) {
                    iprli.Order_Number__c = null; //다시 null 처리 해줘야함(트리거 위해서)
                }
                insert insertPrliList;
                System.debug('insertPrliList TOTAL : ' + insertPrliList.size());
                rsvPrliId = insertPrliList[0].Id;

                /** 원주문 ProductRequestLineItem UPDATE */
                if (!updateOriPrliList.isEmpty()) {
                    System.debug('UPDATE Ori ProductRequestLineItem START ::: ');
                    for (ProductRequestLineItem oriPrli : updateOriPrliList) {
                        if (!insertPrList.isEmpty()) {
                            for (ProductRequest insertedPr : insertPrList) {
                                String insertedPrOrderNo = insertedPr.Order_Number__c;
                                String oriPrliOrderNo = oriPrli.Order_Number__c;
                                System.debug('insertedPrOrderNo : ' + insertedPrOrderNo);
                                System.debug('oriPrliOrderNo : ' + oriPrliOrderNo);
                                if (insertedPrOrderNo != null && oriPrliOrderNo != null && insertedPrOrderNo.equals(oriPrliOrderNo)) {
//                                    oriPrli.RSRV_Number__c = finalMap.get(oriPrliOrderNo);
                                    oriPrli.SR_RESRV_PART_Id__c = insertedPr.SR_RSRV_PART_Id__c;
                                    oriPrli.RSRV_Number__c = insertedPr.RSRV_Number__c;
                                    break;
                                }
                            }
                        }
                        System.debug('oriPrli.RSRV_Number__c :: ' + oriPrli.RSRV_Number__c);
                    }
                    update updateOriPrliList;
                    System.debug('updateOriPrliList TOTAL : ' + updateOriPrliList.size());
                }

                /** 센터 (약속미입고(+)) 처리 */
                //24.01.23 gw.lee
                //'AL'로 요청 시, 사업부 주문 수량(+), 사업부 미입고 수량 (+)처리되어있음
                // system.debug('센터 (약속미입고(+)) 처리 START');
                // execApplyProductItemMulti('AC', insertPrliList); //센터 약속미입고(+)
                // system.debug('센터 (약속미입고(+)) 처리 END');
            }
            System.debug('INSERT ProductRequestLineItem END ::: ');

            if (!updatePiList.isEmpty()) {
                update updatePiList;
                System.debug('updatePiList TOTAL : ' + updatePiList.size());
            }
        }else{ //매개변수 없음
            boolIsSuccess = false;
            strErrMsg = '매개변수 없음';
        }

//        return new Map<String, Object>{
//            'isSuccess' => boolIsSuccess,
//            'errMsg' => strErrMsg,
//            'rsvPrliId' => rsvPrliId
//        };

        return finalRtnMap;
    }

    /**
     * 약속다건취소 (예약취소) (약속정리)
     * @param
     * List<Map<String, Object>> paramMapList
     * key : 'ProductRequestLineItem', value : ProductRequestLineItem
     * key : 'code',
     * value :
     *  'S' : 약속취소(미출고)
     *  'T' : 약속취소(입고상태)
     *  'AD' : 사업부약속취소(미입고상태)
     *  'AE' : 사업부약속취소(재입고알림)
     *
     * @return Map<String, Object>
     *     'isSuccess'
     *     'errMsg'
     */
    public static void CANCEL_RESRV_MULTI(List<Map<String, Object>> paramMapList) {
        if(!paramMapList.isEmpty()){
            List<ProductRequestLineItem> updatePRLIList = new List<ProductRequestLineItem>();
            List<ProductRequestLineItem> updateRsrvPRLIList = new List<ProductRequestLineItem>();

            List<String> resvNoList = new List<String>();
            List<Decimal> resvSeqList = new List<Decimal>();

            for(Map<String, Object> paramMap : paramMapList){
                ProductRequestLineItem prli = new ProductRequestLineItem();
                if(paramMap.get('ProductRequestLineItem') != null){
                    prli = (ProductRequestLineItem) paramMap.get('ProductRequestLineItem');
                    // resvNoList.add(prli.RSRV_Number__c);
                    //23 10 10 hyungho.chun
                    resvNoList.add(prli.SR_RESRV_PART_Id__r.RESRV_Number__c);
                    resvSeqList.add(prli.RSRV_SEQ__c);
                    System.debug('first loop prli.RSRV_Number__c : ' + prli.RSRV_Number__c + ', SEQ : ' + prli.RSRV_SEQ__c);
                }
            }

            List<ProductRequestLineItem> listRsrvPRLITotal = new List<ProductRequestLineItem>();
            listRsrvPRLITotal = [SELECT Id, Order_Number__c, Order_SEQ__c, QuantityRequested, Product2Id, SourceLocationId, DestinationLocationId, CreatedById, CreatedBy.EmployeeNumber__c, Order_CHNL_TYPE_Code__c, DestinationLocation.ServiceResource__r.fm_EmployeeNumber__c,RSRV_Number__c, RSRV_SEQ__c, Status, CANCEL_Reason__c FROM ProductRequestLineItem WHERE RSRV_Number__c IN :resvNoList AND Status != 'C' AND RecordType.DeveloperName = 'RESV_SALE'];

            //이미 예약취소 건은 예약취소 안타도록
            List<String> notCanceledResvNoList = new List<String>();
            if(!listRsrvPRLITotal.isEmpty()){
                for(ProductRequestLineItem fprli : listRsrvPRLITotal){
//                    if(fprli.Order_Number__c == null || fprli.Order_Number__c == ''){
//                        throw new AuraHandledException('사업부주문번호 배치전입니다. 잠시후 다시 취소 바랍니다.');
//                    }
                    notCanceledResvNoList.add(fprli.RSRV_Number__c);
                    
                }
            }

            List<SI_REQUEST__c> listSiRequestTotal = new List<SI_REQUEST__c>();
            listSiRequestTotal = [SELECT Id, TRANS_FLAG__c, REQUEST_NUMBER__c, SEQ__c, LGP_CODE__c, REQUEST_DATE__c, OBU_CODE__c, ITEM_CODE__c,RESV_NO__c,RESV_HANGNO__c FROM SI_REQUEST__c WHERE RESV_NO__c IN :notCanceledResvNoList AND RESV_HANGNO__c IN :resvSeqList];

            //23.11.30 gw.lee
            //SI POCANEL (사업부 취소) 로직 변경
            //기존 : 사업부 요청하지 않았을 경우, 생성
            //변경 : 사업부 요청 완료 + 사업부 출하 안했을 경우 생성
            List<SI_RECEIPT__c> listSiReceiptTotal = new List<SI_RECEIPT__c>();
            listSiReceiptTotal = [SELECT ID, REQUEST_NUMBER__c FROM SI_RECEIPT__c WHERE REQUEST_NUMBER__c IN :notCanceledResvNoList];
            
            Set<String> siReceiptSet = new Set<String>();
            if (listSiReceiptTotal.size() > 0) {
                for (SI_RECEIPT__c tObj : listSiReceiptTotal) {
                    siReceiptSet.add(tObj.REQUEST_NUMBER__c)  ;
                }
            }
            //23 12 21 hyungho.chun
            List<SI_REQUEST__c> updateSiRequestList = new List<SI_REQUEST__c>();
            List<SI_POCANCEL__c> insertPoCList = new List<SI_POCANCEL__c>();

            for (Map<String, Object> paramMap : paramMapList){
                ProductRequestLineItem prli = new ProductRequestLineItem();
                String code = '';
                if(paramMap.get('code') != null){
                    code = String.valueOf(paramMap.get('code'));
                }else{
                    return;
                }
                if(paramMap.get('ProductRequestLineItem') != null){
                    prli = (ProductRequestLineItem) paramMap.get('ProductRequestLineItem');
                    System.debug('mapprli id :' + prli.Id + ', prli.RSRV_Number__c : ' + prli.RSRV_Number__c + ', prli.RSRV_SEQ__c : ' + prli.RSRV_SEQ__c);
                }else{
                    return;
                }
                /** 약속정리 adj_type='C' (약속취소) */
                String cancelReason = '';
                if(code.equals('AE')){
                    cancelReason = '입고후 약속취소';
                }else if(code.equals('T')){
                    cancelReason = '입고후 약속취소';
                }else{
                    cancelReason = '약속취소';
                }
                
                //23 10 11 hyungho.chun 입고던 미입고던 '약속취소'로 기입
                // if(code != null && !code.equals('AE')){
                    // prli.Appointment_Status__c = 'PO Canceld';
                    prli.Appointment_Status__c = '약속취소';
                    prli.Adjust_Type__c = 'C'; //24 01 22 hyungho.chun 소모품에서 약속취소시 할상 정리유형 'C' (취소)
                    prli.CANCEL_Reason__c = prli.CANCEL_Reason__c == null ? '고객취소' : prli.CANCEL_Reason__c;

                    updatePRLIList.add(prli);
                // }

                String employeeNum = '';
                List<ProductRequestLineItem> rsv_prli_list = new List<ProductRequestLineItem>();
                //rsv_prli_list = [SELECT Id, QuantityRequested, Product2Id, SourceLocationId, DestinationLocationId, DestinationLocation.ServiceResource__r.fm_EmployeeNumber__c FROM ProductRequestLineItem WHERE RSRV_Number__c = :prli.RSRV_Number__c AND RecordType.DeveloperName = 'RESV_SALE'];
                if(!listRsrvPRLITotal.isEmpty()){
                    for(ProductRequestLineItem gprli :listRsrvPRLITotal){
                        system.debug('gprli id : ' + gprli.Id + ', gprli RSRV_Number__c : ' + gprli.RSRV_Number__c + ', prli.RSRV_Number__c : ' + prli.RSRV_Number__c + ', gprli.RSRV_SEQ__c : ' + gprli.RSRV_SEQ__c + ', prli.RSRV_SEQ__c : ' + prli.RSRV_SEQ__c);
                        // if(gprli.RSRV_Number__c == prli.RSRV_Number__c && gprli.RSRV_SEQ__c == prli.RSRV_SEQ__c){
                        //23 10 10 hyungho.chun
                        if(gprli.RSRV_Number__c == prli.SR_RESRV_PART_Id__r.RESRV_Number__c && gprli.RSRV_SEQ__c == prli.RSRV_SEQ__c){
                            system.debug('choosed gprli.Id : ' + gprli.Id + ', gprli.RSRV_Number__c : ' + gprli.RSRV_Number__c + ', gprli.RSRV_SEQ__c:'+gprli.RSRV_SEQ__c);
                            rsv_prli_list.add(gprli);
                        }
                    }
                }

                ProductRequestLineItem rsv_prli = new ProductRequestLineItem();
                if(!rsv_prli_list.isEmpty()){
                    rsv_prli = rsv_prli_list[0]; //무조건 단건
                    //for(ProductRequestLineItem rsv_prli : rsv_prli_list){
                        //23.11.30 gw.lee
                        //Cancel User ID 로직 변경
                        System.debug('rsv_prli Id : ' + rsv_prli.Id);
                        if (rsv_prli.Order_CHNL_TYPE_Code__c == 'BestShop') {
                            employeeNum = 'BestShop';
                        } else if (rsv_prli.Order_CHNL_TYPE_Code__c == 'B') {
                            employeeNum = 'LGE.COM';
                        } else {
                            employeeNum = rsv_prli.CreatedBy.EmployeeNumber__c != null ? rsv_prli.CreatedBy.EmployeeNumber__c : String.valueOf(rsv_prli.CreatedById).substring(0, 15);
                        }
                        //예약주문
                        rsv_prli.Status = 'C';
                        //2024.03.25 seung yoon heo
                        rsv_prli.Adjust_Type__c = 'D';
                        //2024.03.25 seung yoon heo 원주문의 QuantityRequested가 아닌 판매예약의 QuantityRequested값이 들어가야함
                        // rsv_prli.CANCEL_Quantity__c = prli.QuantityRequested;
                        rsv_prli.CANCEL_Quantity__c = rsv_prli.QuantityRequested;
                        rsv_prli.CANCEL_Date__c = Date.today();
                        // 230723 사업부 예약 취소 시 데이터 추가
                        rsv_prli.Last_Update_Date__c = Datetime.now();
                        rsv_prli.CANCEL_UserId__c = UserInfo.getUserId();
                        // rsv_prli.CANCEL_Reason__c = cancelReason;
                        rsv_prli.CANCEL_Reason__c = rsv_prli.CANCEL_Reason__c == null ? '고객취소' : prli.CANCEL_Reason__c; //24 01 22 hyungho.chun 
                        // rsv_prli.Adjust_Quantity__c = prli.Adjust_Quantity__c == null ? prli.CANCEL_Quantity__c : prli.Adjust_Quantity__c + prli.CANCEL_Quantity__c;
                        //23 10 10 hyungho.chun 전체수량 취소밖에없음
                        rsv_prli.Adjust_Quantity__c = rsv_prli.QuantityRequested;
                        //2024.03.25 seung yoon heo를 Y로 고정
                        // rsv_prli.RSRV_Completion_YN__c = prli.QuantityRequested == prli.Adjust_Quantity__c ? 'Y' : 'N';
                        rsv_prli.RSRV_Completion_YN__c =  'Y';
                        rsv_prli.CANCEL_User__c = 'SYSTEM';


                        //23 10 10 hyungho.chun 부품 예약관리화면에서 품절주문취소한건은 미처리->처리완료로 이동해야해서 status값을 'C' 로 업데이트침
                    // if(code != null && !code.equals('AE')){
                            updateRsrvPRLIList.add(rsv_prli);
                        // }
                    //}
                }

                /** SI_REQUEST__c 업데이트 */
                List<SI_REQUEST__c> siRequestList = new List<SI_REQUEST__c>();
                system.debug('SI_REQUEST__c 업데이트 시작');
                //siRequestList = [SELECT Id, TRANS_FLAG__c, REQUEST_NUMBER__c, SEQ__c, LGP_CODE__c, REQUEST_DATE__c, OBU_CODE__c, ITEM_CODE__c FROM SI_REQUEST__c WHERE RESV_NO__c = :prli.RSRV_Number__c AND RESV_HANGNO__c = :prli.RSRV_SEQ__c LIMIT 1];
                if(!listSiRequestTotal.isEmpty()){
                    for(SI_REQUEST__c sr : listSiRequestTotal){
                        if(sr.RESV_NO__c == prli.RSRV_Number__c && sr.RESV_HANGNO__c == prli.RSRV_SEQ__c){
                            siRequestList.add(sr);
                        }
                    }
                }

                //23.11.30 gw.lee
                //SI POCANEL (사업부 취소) 로직 변경
                //기존 : 사업부 요청하지 않았을 경우, 생성
                //변경 : 사업부 요청 완료 + 사업부 출하 안했을 경우 생성
                //23 12 21 hyungho.chun 
                //로직변경/ si_request는 그대로N냅두고  / si_pocancel를 생성한다  'C'는 혹시 모를 방어로직 / 정상이라면 이부분엔 N으로만 들어올것
                //24.01.24 gw.lee
                //11.30일 버전으로 변경 (자재측 가이드라인에 따른 수정)
                //아직 GERP로 전송 x => TRANS FLAG 변경, GERP 전송 O => PO CANCEL 생성
                if(!siRequestList.isEmpty()){
                    system.debug('SI_REQUEST__c TOTAL : ' + siRequestList.size());
                    for(SI_REQUEST__c siR : siRequestList){
                        system.debug('SI_REQUEST__c Id : ' + siR.Id);

                        
                        // if(siR.TRANS_FLAG__c != null && siR.TRANS_FLAG__c != 'C'){
                        //     /** SI_POCANCEL__c 생성 */

                        //     System.debug('siReceiptSet ::: ' + siReceiptSet);
                        //     System.debug('siR.RESV_NO__c :::: ' + siR.RESV_NO__c);
                        //     System.debug('siReceiptSet.contains(siR.RESV_NO__c) :::: ' + siReceiptSet.contains(siR.RESV_NO__c));
                        //     if (!siReceiptSet.contains(siR.RESV_NO__c)) {
                        //         SI_POCANCEL__c objSIP = new SI_POCANCEL__c();
                        //         objSIP.REQUEST_NUMBER__c = siR.REQUEST_NUMBER__c;
                        //         objSIP.SEQ__c = siR.SEQ__c;
                        //         objSIP.LGP_CODE__c = siR.LGP_CODE__c;
                        //         objSIP.REQUEST_DATE__c = siR.REQUEST_DATE__c;
                        //         objSIP.OBU_CODE__c = siR.OBU_CODE__c;
                        //         objSIP.ITEM_CODE__c = siR.ITEM_CODE__c;
                        //         objSIP.CAN_RESN__c = cancelReason;
                        //         objSIP.CANCEL_DATE__c = date.today();
                        //         objSIP.CANCEL_ID__c = employeeNum;
                        //         objSIP.TRANSFER_FLAG__c = 'N';
    
                                
                        //         insertPoCList.add(objSIP);
                                
                        //     }                            
                        // }

                        String tFlag = siR.TRANS_FLAG__c;

                        if(siR.TRANS_FLAG__c != null && tFlag.equals('N')){


                            //23 12 21 hyungho.chun 소포품취소로직에선 SI_REQUEST__c의 flag를 바꾸지않고 해당관련 si_pocancel를 생성한다
                            siR.TRANS_FLAG__c = 'C';

                            if(code != null && !code.equals('AE')){
                                updateSiRequestList.add(siR);
                            }
                        } else if (siR.TRANS_FLAG__c != null && tFlag.equals('Y')) {
                            /** SI_POCANCEL__c 생성 */

                            System.debug('siReceiptSet ::: ' + siReceiptSet);
                            System.debug('siR.RESV_NO__c :::: ' + siR.RESV_NO__c);
                            System.debug('siReceiptSet.contains(siR.RESV_NO__c) :::: ' + siReceiptSet.contains(siR.RESV_NO__c));
                            if (!siReceiptSet.contains(siR.RESV_NO__c)) {
                                SI_POCANCEL__c objSIP = new SI_POCANCEL__c();
                                objSIP.REQUEST_NUMBER__c = siR.REQUEST_NUMBER__c;
                                objSIP.SEQ__c = siR.SEQ__c;
                                objSIP.LGP_CODE__c = siR.LGP_CODE__c;
                                objSIP.REQUEST_DATE__c = siR.REQUEST_DATE__c;
                                objSIP.OBU_CODE__c = siR.OBU_CODE__c;
                                objSIP.ITEM_CODE__c = siR.ITEM_CODE__c;
                                objSIP.CAN_RESN__c = cancelReason;
                                objSIP.CANCEL_DATE__c = date.today();
                                objSIP.CANCEL_ID__c = employeeNum;
                                objSIP.TRANSFER_FLAG__c = 'N';
    
                                if(code != null && !code.equals('AE')){
                                    insertPoCList.add(objSIP);
                                }
                            }

                        }
                    }
                }else{
                    system.debug('Update할 SI_REQUEST__c 없음.');
                }

                /** 재고정리 */
                /** 약속수량 차감 */
                // if(!rsv_prli_list.isEmpty()){
                //     EX_RsrvUtil.execApplyProductItem(rsv_prli.QuantityRequested, code, rsv_prli);
                // }
                /** 사업부 주문취소 (주문수량(-)) 처리 > 처리안함 */
                
                //gw.lee 23.10.13
                //사업부 주문 취소 기존 : ORDER QTY 미차감, RSRV_QTY__c 차감
                //사업부 주문 취소 변경 : ORDER QTY 차감, RSRV_QTY__c 미차감

                //23 12 21 hyungho.chun 센터 RESRV_UNRCV_QTY__c / 사업부 Order_qty 재고감소는 si_pocancel로 관리함으로 소포품에서 취소로직때 차감하지않는다
                if(!rsv_prli_list.isEmpty()){
                    //24.02.26 gw.lee
                    //이미 사업부 출하가 완료되었으면 수불처리 미진행
                    List<SI_RECEIPT__c> siReceiptList = [SELECT ID FROM SI_RECEIPT__c WHERE REQUEST_NUMBER__c = :rsv_prli.Order_Number__c AND REQUEST_SEQ__c = :rsv_prli.Order_SEQ__c];

                    if (siReceiptList.size() == 0) {
                        if (code == 'AD') {
                            execApplyProductItem(rsv_prli.QuantityRequested, 'AD', rsv_prli); //센터 주문취소 (주문수량(-))
                            execApplyProductItem(rsv_prli.QuantityRequested, 'AM', rsv_prli); //사업부 주문취소 (주문수량(-))
                        }
                    }
                }
            }//for
            if(!updatePRLIList.isEmpty()){
                System.debug('updatePRLIList :::: ' + updatePRLIList);
                update updatePRLIList;
            }
            if(!updateRsrvPRLIList.isEmpty()){
                update updateRsrvPRLIList;
            }
            //23 12 21 hyungho.chun
            if(!updateSiRequestList.isEmpty()){
                update updateSiRequestList;
            }
            if(!insertPoCList.isEmpty()){
                insert insertPoCList;
                system.debug('SI_POCANCEL__c 생성 완료. TOTAL : ' + insertPoCList.size());
            }
        }
    }


    /**
     * 약속생성 ( SR_RESRV_PART__c )
     *
     * @param deptCode DEPT_CODE
     * @param partNo PART_NO
     *
     * @return Map<String, Object>
     */
    public static Map<String, Object> createSrResrvPart(Id destinationId) {
        Boolean boolIsSuccess = false;
        String strErrMsg = '';

        //SR_RESRV_PART__c 생성
        SR_RESRV_PART__c objSrResrvPart = new SR_RESRV_PART__c();

        objSrResrvPart.Location_Destination_Id__c = destinationId;

        try {
            //insert objSrResrvPart;
            boolIsSuccess = true;
        }catch (DmlException e){
            System.debug(e.getMessage());
            boolIsSuccess = false;
            strErrMsg = e.getMessage();
        }

        return new Map<String, Object>{
            'isSuccess' => boolIsSuccess,
            'errMsg' => strErrMsg,
            'objSrResrvPart' => objSrResrvPart
        };

    }

    /**
     * ProductRequest 생성
     *
     * @param deptCode DEPT_CODE
     * @param partNo PART_NO
     * @param SR_RESRV_PART__c objSrResrvPart
     *
     * @return Map<String, Object>
     */
    public static Map<String, Object> createProductRequest(String deptCode, String orderNo, List<ProductRequest> oriPrList, Id destinationId, Id sourceId, Id smdId, Boolean isInstock) {
        Boolean boolIsSuccess = false;
        String strErrMsg = '';

        ProductRequest objInsertPR = new ProductRequest();               // 제품 요청

        objInsertPR.Order_Date__c = System.now();
        objInsertPR.DestinationLocationId = destinationId; //"PH8002" or "PH0300" + 주문파트 중 1개 + '999999'
        objInsertPR.SourceLocationId = sourceId;
        objInsertPR.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('RESV_SALE').getRecordTypeId(); //판매예약(RESV_SALE)
        objInsertPR.Department_Id__c = smdId; //"PH8002"의 부서 ID
        objInsertPR.Department_Code__c = deptCode; //부서코드
        if(isInstock){ //재입고
            objInsertPR.Parts_INPUT_Type_Code__c = 'D'; //부품입력유형 소모품/케어용품 : "B", 재입고알림 : "D"
            objInsertPR.Request_Type_Code__c = 'R'; //요청유형 소모품/케어용품 : "S", 재입고알림 : "R"
        }else{
            objInsertPR.Parts_INPUT_Type_Code__c = 'B'; //부품입력유형 소모품/케어용품 : "B", 재입고알림 : "D"
            objInsertPR.Request_Type_Code__c = 'S'; //요청유형 소모품/케어용품 : "S", 재입고알림 : "R"
        }

//        if(deptCode.equals(EX_ConsumableUtil.PH0300)){
//            objInsertPR.Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;
//        }else{
//            objInsertPR.Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_CIC;
//        }

        objInsertPR.Consumables_Business_Type_Code__c = 'Order';
        // Consumables_Order_Class_Code = 'PO'
        objInsertPR.Consumables_Order_Class_Code__c = 'General';

        objInsertPR.Consumables_Order_YN__c = true; //소모품주문여부
        objInsertPR.Consumables_Order_USE_YN__c = true;
        /*if(objSrResrvPart != null && objSrResrvPart.RSRV_Number__c != null){
            objInsertPR.RSRV_Number__c = 'C' + objSrResrvPart.RSRV_Number__c; //예약번호로 사용 TEXT C000000296
            objInsertPR.SR_RSRV_PART_Id__c = objSrResrvPart.id; //예약부품정보
        }*/

        if(orderNo != null && !orderNo.equals('')){
            objInsertPR.Order_Number__c = orderNo;
            for(ProductRequest pr : oriPrList){
                String prOrderNo = pr.Order_Number__c;
                if(pr.Order_Number__c != null && prOrderNo.equals(orderNo)){
                    if(pr.AccountId != null){
                        objInsertPR.AccountId = pr.AccountId; // Contact의 Account
                    }
                    if(pr.Order_CUST_Id__c != null){
                        objInsertPR.Order_CUST_Id__c = pr.Order_CUST_Id__c; //주문고객ID Contact
                    }
                    if(pr.Order_CHNL_TYPE_Code__c != null){
                        objInsertPR.Order_CHNL_TYPE_Code__c = pr.Order_CHNL_TYPE_Code__c;
                    }
                }
            }
        }

        objInsertPR.Order_Req_Dept_Type_Code__c = 'C'; //주문요청부서유형

        try {
            //insert objInsertPR;
            boolIsSuccess = true;
        }catch (DmlException e){
            boolIsSuccess = false;
            strErrMsg = e.getMessage();
            System.debug(e.getMessage());
        }

        //ProductRequest pr = [SELECT Id FROM ProductRequest WHERE RecordTypeId != :objInsertPR.RecordTypeId AND ];

        return new Map<String, Object>{
            'isSuccess' => boolIsSuccess,
            'errMsg' => strErrMsg,
            'objProductRequest' => objInsertPR
        };
    }

    /**
     * ProductRequestLineItem 생성
     *
     * @return Map<String, Object>
     */
    public static Map<String, Object> createProductRequestLineItem(Map<String, Object> mapItem, String deptCode, String partNo, ProductRequest objInsertPR, Decimal orderSeq, List<ProductItem> newPiList, List<Product2> newP2List, Boolean isInstock, Integer rsrvSeq) {
        Boolean boolIsSuccess = false;
        String strErrMsg = '';
        String divCode = '';
        if(mapItem.get('div_code') != null){
            divCode = String.valueOf(mapItem.get('div_code'));
        }

        String product2_id = '';
        String modelCode = '';
        Decimal ascPrice;
        Decimal custPrice;
        Boolean existProduct = false;
        String productItemId = '';
        Decimal productItemQty;
        String divPiId = '';
        Decimal resrvUnrcvQty;

        system.debug('createProductRequestLineItem partNo : ' + partNo + ', divCode : ' + divCode);

        List<ProductItem> listProductItems = newPiList;

        /*listProductItems = [
                SELECT Id, Product2Id, Product2.DIV_CODE__c, Product2.MODEL_CODE__c, Product2.CUST_PRICE__c, Product2.ASC_PRICE__c, ORDER_QTY__c, Location.RecordType.DeveloperName, RESRV_UNRCV_QTY__c
                FROM ProductItem
                WHERE fm_Parts_Number__c = :partNo
                AND fm_DIV_CODE__c = :divCode
                AND (Location.RecordType.DeveloperName = 'DIV' OR (Location.RecordType.DeveloperName = 'Location' AND Location.Name = '99A999'))
        ];*/

        if(!listProductItems.isEmpty()){

            for(ProductItem pi : listProductItems){
                if(pi.Location.RecordType.DeveloperName == 'Location'){
                    system.debug('createProductRequestLineItem dvName Location');
                    existProduct = true;
                    productItemId = pi.Id;
                    product2_id = pi.Product2Id;
                    modelCode = pi.Product2.MODEL_CODE__c;
                    ascPrice = pi.Product2.ASC_PRICE__c;
                    custPrice = pi.Product2.CUST_PRICE__c;
                    resrvUnrcvQty = pi.RESRV_UNRCV_QTY__c;
                    system.debug('createProductRequestLineItem resrvUnrcvQty : ' + resrvUnrcvQty);
                }else{
                    divPiId = pi.Id;
                    productItemQty = pi.ORDER_QTY__c;
                    //20230517
                    productItemId = pi.Id;
                    product2_id = pi.Product2Id;
                    //gw.lee 24.02.25
                    //모델코드 추가 (sirequest 생성 시, 필수값)
                    modelCode = pi.Product2.MODEL_CODE__c;
                }
            }
        }else{
            List<Product2> listProduct2 = newP2List;

            if(!listProduct2.isEmpty()){
                existProduct = true;
                product2_id = listProduct2[0].Id;
                modelCode = listProduct2[0].MODEL_CODE__c;
                ascPrice = listProduct2[0].ASC_PRICE__c;
                custPrice = listProduct2[0].CUST_PRICE__c;
            }
        }

        //24.03.20 gw.lee
        //판매예약주문 - 원주문 lookup연결
        String originPrli = '';
        if (mapItem.get('oriPrliId') != null && !mapItem.get('oriPrliId').equals('')) {
            originPrli = String.valueOf(mapItem.get('oriPrliId'));
        }

        ProductRequestLineItem objInsertPRLI = new ProductRequestLineItem(); // 제품 요청 행 항목
        if (String.isNotEmpty(originPrli)) {
            objInsertPRLI.BASIS_Order_Item_Id__c = originPrli;
        }
        objInsertPRLI.AccountId = objInsertPR.AccountId;
        //objInsertPRLI.ParentId = objInsertPR.Id;
        //ProductRequestLintItem_tr 조건때문에 null => insert직전
        //insert 시 PR과 매칭을 위해 Order_Number 세팅. Insert 직전 null 처리.
        objInsertPRLI.Order_Number__c = objInsertPR.Order_Number__c;
        //objInsertPRLI.Order_SEQ__c = rsrvSeq;
        //20230705
        // order_seq를 rsrvSeq로 하면 안되는 이유 : 채번하는 사업부주문번호는 같고, 예약번호는 다르며, 예약항번은 모두 1인 경우가 있음
        Decimal dOrderSeq = orderSeq;
        if(dOrderSeq != null && dOrderSeq > 100){
            String strOrderSeq = String.valueOf(dOrderSeq).right(2);
            dOrderSeq = Decimal.valueOf(strOrderSeq);
        }
        objInsertPRLI.Order_SEQ__c = dOrderSeq;

        // objInsertPRLI.SourceLocationId = objInsertPR.SourceLocationId; 
        String sourceId = (String) mapItem.get('sourceId');
        objInsertPRLI.SourceLocationId = sourceId; 
        objInsertPRLI.DestinationLocationId = objInsertPR.DestinationLocationId; //"PH8002"+PART번호+"999999" 기준 Location ID
        //GSCS_Order_Number__c GSCS주문번호 [보류]
        objInsertPRLI.PART_NO__c = partNo; //SI_ONLINE_INSTOCK_NOTICE__c.PART_NO__c

        //20230517
        if(product2_id != null && !product2_id.equals('')){
            objInsertPRLI.Product2Id = product2_id; //DIV_CODE + PART_NO 기준 Product ID
        }
        if(existProduct){
            objInsertPRLI.Product2Id = product2_id; //DIV_CODE + PART_NO 기준 Product ID
            objInsertPRLI.UnitPrice__c = ascPrice; //단가 SM_PART.ASC_PRICE
            objInsertPRLI.ASC_Price__c = ascPrice; //단가 SM_PART.ASC_PRICE
            objInsertPRLI.CONSUMER_Price__c = custPrice; //제품.소비자가
        }
        if(!productItemId.equals('')){
            objInsertPRLI.ProductItem__c = productItemId;
        }
        if(mapItem.get('req_qty') != null && !mapItem.get('req_qty').equals('')){
            //objInsertPRLI.QuantityRequested = lData.REQ_QTY__c; // SI_ONLINE_INSTOCK_NOTICE__c.REQ_QTY__c
            objInsertPRLI.QuantityRequested = Decimal.valueOf(Double.valueOf(mapItem.get('req_qty'))); // SI_ONLINE_INSTOCK_NOTICE__c.REQ_QTY__c
        }
        objInsertPRLI.RecordTypeId =  EX_ConsumableUtil.PRLI_RESV_SALE_RECORDTYPE_ID;  //판매예약(RESV_SALE)
        //objInsertPRLI.RecordTypeId = objInsertPR.RecordTypeId; //판매예약(RESV_SALE)

        objInsertPRLI.ShipmentType = '서두름';


        if(modelCode != null && !modelCode.equals('')){
            objInsertPRLI.MODEL_Code__c = modelCode; //모델코드
        }

        //objInsertPRLI.SR_RESRV_PART_Id__c = objSrResrvPart.Id; // SR_RESRV_PART_Id
        if(isInstock){ //재입고
            objInsertPRLI.Parts_INPUT_Type_Code__c = 'D'; //부품입력유형 소모품/케어용품 : "B", 재입고알림 : "D"
            objInsertPRLI.Request_Type_Code__c = 'R'; //요청유형 소모품/케어용품 : "S", 재입고알림 : "R"
            objInsertPRLI.Description = '대표사이트 재입고 알림';
            objInsertPRLI.Remark__c = '대표사이트 재입고 알림';
            objInsertPRLI.RSRV_Reason_Type_Code__c = 'R'; //예약사유 유형 'S'소모품주문, 'R'재입고알림
        }else{
            objInsertPRLI.Parts_INPUT_Type_Code__c = 'B'; //부품입력유형 소모품/케어용품 : "B", 재입고알림 : "D"
            objInsertPRLI.Request_Type_Code__c = 'S'; //요청유형 소모품/케어용품 : "S", 재입고알림 : "R"
            objInsertPRLI.RSRV_Reason_Type_Code__c = 'S'; //예약사유 유형 'S'소모품주문, 'R'재입고알림
        }
        objInsertPRLI.MOVE_Type_Code__c = 'R';
        if(mapItem.get('div_code') != null && !mapItem.get('div_code').equals('')){
            //objInsertPRLI.ENDP_Code__c = lData.DIV_CODE__c; //사업부
            objInsertPRLI.ENDP_Code__c = String.valueOf(mapItem.get('div_code')); //사업부
        }
        //objInsertPRLI.ENDP_RSV_Quantity__c; //사업부 PO입고 시점에 입고수량 ADD업데이트
        objInsertPRLI.Consumables_Order_YN__c = true; //소모품주문여부
        objInsertPRLI.Status = 'Y';
        objInsertPRLI.Appointment_Status__c = '요청'; //원주문에 해야함 //24 02 21 hyungho.chun 예약주문에도 요청으로 남김
        //Appointment_Status__c 약속상태[보류]
        //Appointment_Quantity__c 약속수량[보류]
        //Appointment_DTM__c 약속일시[보류]
        //objInsertPRLI.RSRV_Number__c = objInsertPR.RSRV_Number__c; //예약번호
        objInsertPRLI.RSRV_Completion_YN__c = 'N'; //요청수량=정리수량 : 'Y'
        objInsertPRLI.RSRV_SEQ__c = rsrvSeq; //예약항번 : 예약 품목 개수 만큼 순차번호 부여 (1,2,3, …)

        //BASIS_Parts_Number__c 원PARTNO 보류
        //BASIS_ENDP_Code__c 원사업부코드 보류
        //MOVE_Type_Code__c 이동유형 보류

        // objInsertPRLI.LOCATED_PLACE_Number__c = '999999'; //적치장소번호 - "999999"  -- 요청한 센터의 Location
        objInsertPRLI.LOCATED_PLACE_Number__c = System.Label.EX_Location; //적치장소번호 - "99A999"  -- 요청한 센터의 Location //24 02 08 hyungho.chun 99999로잘못넣어주던거 99A999로 수정
        //RCPT_YY__c 접수년도 보류
        //RCPT_Number__c 접수번호 보류
        //objInsertPRLI.Adjust_Quantity__c; 정리수량 - 예약 정리 시점(취소, 판매)에 발생한 수량
        objInsertPRLI.Order_CUST_Id__c = objInsertPR.Order_CUST_Id__c; //주문고객ID or null(재입고알림)
        //objInsertPRLI.ASC_Price__c = ''; //SM_PART.ASC_PRICE
        //objInsertPRLI.SALE_Amount__c = 0; //판매금액 : 요청수량 * 단가
        //objInsertPRLI.SALE_Number__c = ''; //판매 확정 시점에 관련된 예약에 업데이트

        objInsertPRLI.Consumables_Business_Type_Code__c = 'Order';
        objInsertPRLI.Consumables_Order_Class_Code__c = 'PO';
        objInsertPRLI.Department_Code__c = deptCode; //부서코드
//        if(deptCode.equals(EX_ConsumableUtil.PH0300)){
//            objInsertPRLI.Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;
//        }else{
//            objInsertPRLI.Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_CIC;
//        }
        objInsertPRLI.Order_CHNL_TYPE_Code__c = objInsertPR.Order_CHNL_TYPE_Code__c;
        objInsertPRLI.Order_Req_Dept_Type_Code__c = 'C'; //주문요청부서유형
        objInsertPRLI.Other_Center_RENT_YN__c = 'N'; //타센터차용여부

        try {
            //insert objInsertPRLI;
            boolIsSuccess = true;
        }catch (DmlException e){
            boolIsSuccess = false;
            strErrMsg = e.getMessage();
            System.debug(e.getMessage());
        }

        if(productItemQty != null){
            return new Map<String, Object>{
                'isSuccess' => boolIsSuccess,
                'errMsg' => strErrMsg,
                'objProductRequestLineItem' => objInsertPRLI,
                'productItemQty' => productItemQty,
                'divPiId' => divPiId,
                'resrvUnrcvQty' => resrvUnrcvQty
            };
        }else{
            return new Map<String, Object>{
                'isSuccess' => boolIsSuccess,
                'errMsg' => strErrMsg,
                'objProductRequestLineItem' => objInsertPRLI,
                'divPiId' => divPiId,
                'resrvUnrcvQty' => resrvUnrcvQty
            };
        }
    }
}