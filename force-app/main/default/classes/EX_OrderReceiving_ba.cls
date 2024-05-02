/**
 * @description       : 소모품 입고 확정 배치
 * @author            : 이석호 (I2MAX)
 * @last modified on  : 03-09-2024
 * @last modified by  : hyungho.chun@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2023-05-01   이석호                         Initial Version
 * 1.1   2024-02-25   gunting2000@cnspartner.com    Adjust Quantity 수량 증가 로직 (부품 예약관리 표출 사유 (안태진 대리 확인)), 대치부품 ProductdItem 로직 수정 (판매저장 시, 재고수불 해당 컬럼 바라봄)
 * 1.2   2024-03-05   gunting2000@cnspartner.com    Product2 미스매칭건 발생, Product2 - 사업부별로 존재, 수신받은 Transfer의 사업부 Product2로 재고 수불되게끔 조치
 * 1.3   2024-03-06   gunting2000@cnspartner.com    센터 => 적치장소 이동 시, SHIPPED DATE 주석 조치 - 예약관리화면에서 조회 안됨
 * 1.3   2024-03-06   gutning2000@cnspartner.com    결제화면에서 리프레쉬 후, 사업부 요청 되었을 때 입고 완료 후 취소건이 결제 요청상태로 바뀌지않는 조건 추가
 * 1.4   2024-03-18   gunting2000@cnspartner.com    교환주문이 입고완료 되었을 때, 결제요청 상태로 바뀌지 않게끔 조치
**/

public with sharing class EX_OrderReceiving_ba implements Database.Batchable<sObject>, DataBase.stateful, DataBase.AllowsCallouts {

    //23 11 15 hyuoghn.chun 성공건들 로그작업
    String successOrderRecevingId = 'Success SI_FULFILLMENT_RECEIVING ID : ';
            
    public Database.QueryLocator start(Database.BatchableContext param1) {
        String strQuery = '';
        strQuery += ' SELECT  ' + SObjectUtil.getFieldForQuery('SI_FULFILLMENT_RECEIVING__c');
        strQuery += ' FROM SI_FULFILLMENT_RECEIVING__c ';
        strQuery += ' WHERE IF_SEND_YN__c = \'Y\' '; //CJ전송여부
        strQuery += ' AND RCV_CONFIRM_YN__c = \'N\' '; //입고확정여부
        strQuery += ' AND IF_RESPONSE_YN__c = \'Y\' '; //수신여부(입고확정수신)
        strQuery += ' AND SFDC_CONFIRM__c IN (\'N\',\'E\') '; //SFDC입고확정처리  'Y'처리완료, 'N'미처리, 'E'에러(재실행), 'F'에러(데이터문제)
        strQuery += ' AND Product_Transfer_Id__r.RSV_CONFIRM_DATE__c = null ';
        // strQuery += ' AND Id = \'a4o6D000000Hy5gQAC\' ';
        // strQuery += ' AND ID IN (\'a4o6D000000Hy5hQAC\')';
        
        //임시
        //strQuery += ' AND Product_Transfer_id__r.Order_Number__c IN (\'CNO8N3R102\', \'CNO8N3R103\',\'CNO8N3R104\')  ';
        //strQuery += ' AND Product_Transfer_id__r.Order_Number__c IN (\'O230001290312\', \'O230001290318\', \'O230001290314\', \'O230001290309\')  ';

        return Database.getQueryLocator(strQuery);
    }

    public void execute(Database.BatchableContext param1, List<SI_FULFILLMENT_RECEIVING__c> siFulfillmentReceivingList) {
        Savepoint sp = Database.setSavepoint();

        System.debug('START ::: siFulfillmentReceivingList TOTAL : ' + siFulfillmentReceivingList.size());

        //23 11 15 hyungho.chun 실패용 로그작업
        Map<String,String> errorMap = new Map<String,String>();

        try{
            if(!siFulfillmentReceivingList.isEmpty()) {
                System.debug('siFulfillmentReceivingList TOTAL : ' + siFulfillmentReceivingList.size());
                List<String> transferIdList;
                transferIdList = new List<String>();
                List<String> orderNoList;
                orderNoList = new List<String>();
                List<String> partNoList;
                partNoList = new List<String>();
                for (sObject rcvConfirmData : siFulfillmentReceivingList) {
                    String transferId;
                    transferId = getStringNotNull(rcvConfirmData.get('Product_Transfer_Id__c'));
                    String orderNo;
                    orderNo = getStringNotNull(rcvConfirmData.get('ORDER_NO__c'));
                    String partNo;
                    
                    if(transferId != null && !transferId.equals('')){
                        transferIdList.add(transferId);
                    }
                    if(orderNo != null && !orderNo.equals('')){
                        orderNoList.add(orderNo);
                    }
                    if(partNo != null && !partNo.equals('')){
                        // partNoList.add(partNo);
                    }
                }

                List<String> exTransferIdList = new List<String>();
                

                System.debug('transferIdList TOTAL : ' + transferIdList.size());
                System.debug('orderNoList TOTAL : ' + orderNoList.size());
                
                
                //2023.08.14 gw.lee
                //기존 요청 : 소모품 세터 요청한 ProductTransfer 기준으로 데이터 진행
                //변경 요청 : 사업부 출하 완료된 ProductTransfer 기준으로 데이터 진행
                //변경 사항 : 현재 소스는 소모품 센터 요청한 ProductTransfer 기준으로 작업되어있음, 사업부 출하 완료된 ProductTransfer -> 기존 센터 요청한 ProductTransfer 변경

                //에약 ProductRequest
                List<ProductRequest> prListTotal = [SELECT id, RecordType.DeveloperName, Order_Number__c, Order_CUST_Id__c, DestinationLocationId, DestinationLocation.ServiceResource__c, RSRV_Number__c
                                                        FROM ProductRequest 
                                                        WHERE Order_Number__c IN :orderNoList];
                if (prListTotal.size () == 0) {
                    List<ProductRequestLineItem> prliListTotal = [SELECT ID, Parent.Order_Number__c FROM ProductRequestLineItem WHERE Order_Number__c = :orderNoList];

                    prListTotal = [SELECT id, RecordType.DeveloperName, Order_Number__c, Order_CUST_Id__c, DestinationLocationId, DestinationLocation.ServiceResource__c, RSRV_Number__c
                                                        FROM ProductRequest
                                                        WHERE Order_Number__c = :prliListTotal[0].Parent.Order_Number__c];
                }
          
                //사업부 출하 ProductTransfer
                List<ProductTransfer> ptTotalList = [
                    SELECT 
                        Id, 
                        RecordTypeId, 
                        RecordType.DeveloperName, 
                        ProductRequestId, 
                        ProductRequestLineItemId, 
                        DestinationLocationId, 
                        SourceLocationId, 
                        DestinationLocation.Name, 
                        SourceLocation.Name, 
                        QuantityReceived, 
                        Return_Order_Quantity__c, 
                        SHIPPED_Date__c, 
                        MOVE_Type_Code__c, 
                        ReturnOrderLineItemId, 
                        Product2Id, 
                        fm_PART_NO__c, 
                        CARTON__c, 
                        RSV_Quantity__c , 
                        ProductRequest.Order_Number__c,
                        ProductRequestLineItem.Order_Number__c,
                        ProductRequestLineItem.Order_SEQ__c
                    FROM 
                        ProductTransfer 
                    WHERE 
                        Id IN :transferIdList
                ];

                Map<String, String> fsMap = new Map<String, String>(); //사업부 출하 ProductTransfer Map
                Map<String, String> syncMap = new Map<String, String>(); //사업부 출하, 소모품 요청 ProductTransfer Map

                Map<Id, ProductTransfer>  allMap = new Map<Id, ProductTransfer>([SELECT Id, isReceived, ProductRequest.Order_Number__c, ProductRequestLineItem.Order_Number__c, ProductRequestLineItem.Order_SEQ__c
                FROM ProductTransfer 
                WHERE ProductRequestLineItem.Order_Number__c IN :orderNoList]);

                Map<String, Object> ptMap;
                ptMap = new Map<String, Object>();
                //사업부 출하 완료된 ProductTransfer
                for (ProductTransfer ptObj : ptTotalList) {
                    fsMap.put(ptObj.ProductRequestLineItem.Order_Number__c + '_' + ptObj.ProductRequestLineItem.Order_SEQ__c, ptObj.Id);

                    ptObj.RSV_CONFIRM_Date__c = System.today();
                    partNoList.add(ptObj.Product2Id);

                    //24.03.11 gw.lee
                    //센터로 내려받은 수량 기준으로 데이터 셋팅 조치
                    if (ptObj.SHIPPED_Date__c != null) {
                        ptMap.put('SHIPPED_Date__c',ptObj.SHIPPED_Date__c); //SHIPPED_Date__c
                    }
                    if (ptObj.QuantityReceived != null) {
                        ptMap.put('QuantityReceived',ptObj.QuantityReceived); //QuantityReceived
                    }
                    if (ptObj.Return_Order_Quantity__c != null) {
                        ptMap.put('quantityReturned',ptObj.Return_Order_Quantity__c); //quantityReturned
                    }
                    if (ptObj.RSV_Quantity__c != null) {
                        // 230726 소모품센터의 RSV_Quantity__c 수량 만큼 소모품 적치장소의 QuantityReceived 로 증가 시켜주고 IsReceived 가 true 가 되어야 실제 전산재고(보유량)이 증가하게 하기 위한 Map Put
                        ptMap.put('RSV_Quantity__c', ptObj.RSV_Quantity__c);
                    }
                }

                System.debug('ptMap :::: ' + ptMap);
                System.debug('allMap :::: ' + allMap);
                System.debug('fsMap :::: ' + fsMap.keySet());

                //사업부 출하 완료 -> 소모품 센터 요청 Product Transfer Mapping
                for (ProductTransfer pObj : allMap.values()) {
                    System.debug('pObj :::: ' + pObj.ProductRequestLineItem.Order_Number__c);
                    System.debug('pObj :::: ' + pObj.ProductRequestLineItem.Order_SEQ__c);
                    if (fsMap.containsKey(pObj.ProductRequestLineItem.Order_Number__c + '_' + pObj.ProductRequestLineItem.Order_SEQ__c)) {
                        if (pObj.isReceived == false) {
                            syncMap.put(fsMap.get(pObj.ProductRequestLineItem.Order_Number__c + '_' + pObj.ProductRequestLineItem.Order_SEQ__c), pObj.Id);
                        }
                    }
                }

                System.debug('Before ptTotalList :::: ' + ptTotalList);

                //SHIPPED_Date__c,
                List<ProductTransfer> ptRequestList = [
                    SELECT id, RecordTypeId, RecordType.DeveloperName, ProductRequestId, ProductRequestLineItemId, DestinationLocationId, SourceLocationId, DestinationLocation.Name, SourceLocation.Name, QuantityReceived, Return_Order_Quantity__c
                    , MOVE_Type_Code__c, ReturnOrderLineItemId, Product2Id, fm_PART_NO__c, CARTON__c, RSV_Quantity__c, SHIPPED_Date__c, Order_Number__c, Order_SEQ__c
                    FROM ProductTransfer 
                    WHERE Id IN :syncMap.values()
                ];

                System.debug('after ptRequestList :::: ' + ptRequestList);

                String strPartNoRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('PART_NO').getRecordTypeId();
                List<Product2> productTotal = [ 
                    SELECT ID, name 
                    FROM Product2 
                    WHERE ID IN :partNoList 
                    AND RecordTypeId = :strPartNoRecordTypeId
                    ];
                System.debug('syncMap :::: ' + syncMap);
                // System.debug('ptTotalList:'+ptTotalList[0].Id +'/'+ptTotalList[0].DestinationLocationId);
                List<Map<String, Object>> listPT;
                listPT = new List<Map<String, Object>>();

                for (sObject rcvConfirmData : siFulfillmentReceivingList) {
                    if(!''.equals(getStringNotNull(rcvConfirmData.get('CUSTR_PO_NO__c')))){ //CJ연동번호
                        String orderNo = getStringNotNull(rcvConfirmData.get('ORDER_NO__c'));
                        //Integer orderSeq = getIntegerNotNull(rcvConfirmData.get('ORDER_SEQ__c'));
                        String partNo = getStringNotNull(rcvConfirmData.get('PART_NO__c'));
                        //String cartonNo = getStringNotNull(rcvConfirmData.get('CARTON_NO__c')); //카톤넘버
                        
                        System.debug('Before ProductTransfer :::: ' + rcvConfirmData.get('Product_Transfer_Id__c'));
                        System.debug('After ProductTransfer :::: ' + getStringNotNull(syncMap.get(getStringNotNull(rcvConfirmData.get('Product_Transfer_Id__c')))));
                        String transferId = getStringNotNull(syncMap.get(getStringNotNull(rcvConfirmData.get('Product_Transfer_Id__c'))));
                        //String transferId = getStringNotNull(rcvConfirmData.get('Product_Transfer_Id__c'));

                        ptMap.put('SI_FULFILLMENT_RECEIVING_ID',rcvConfirmData.get('Id'));
                        ptMap.put('ENDP_Code__c',getStringNotNull(rcvConfirmData.get('DIV_CODE__c'))); //ENDP_Code__c //사업부
                        ptMap.put('CARTON_Number__c',getStringNotNull(rcvConfirmData.get('CARTON_NO__c'))); //CARTON_Number__c //카툰번호

                        List<ProductTransfer> ptList;
                        ptList = new List<ProductTransfer>();
                        if(!ptRequestList.isEmpty()){
                            for(ProductTransfer pt : ptRequestList){
                                if(pt.Id == transferId){
                                    ptList.add(pt);
                                }
                            }
                        }
                        System.debug('productTotal :::: ' + productTotal);
                        System.debug('partNo :::: ' + partNo);
                        String product2Id = '';
                        if(!productTotal.isEmpty()){
                            for(Product2 p2 : productTotal){
                                if(p2.Name == partNo){
                                    product2Id = p2.Id;
                                }
                            }
                        }

                        if(!ptList.isEmpty()){
                            ptMap.put('Id',ptList[0].Id); //Id
                            //2024.02.23 seung yoon heo gu과장님 요청 Order_Number, Order_seq추가 Order_Number__c, Order_SEQ__c 
                            ptMap.put('Order_Number__c',ptList[0].Order_Number__c); //Order_Number__c
                            ptMap.put('Order_SEQ__c',ptList[0].Order_SEQ__c); //Order_SEQ__c


                            ptMap.put('ProductRequestId',ptList[0].ProductRequestId); //ProductRequestId
                            ptMap.put('ProductRequestLineItemId',ptList[0].ProductRequestLineItemId); //ProductRequestLineItemId
                            ptMap.put('DestinationLocationId',ptList[0].DestinationLocationId); //DestinationLocationId
                            ptMap.put('stockPlace',ptList[0].DestinationLocation.Name); //stockPlace (입고하려는 적치장소 Location Name)
                            // ((Map<Object, Object>)mapPT.get('RecordType')).get('DeveloperName')
                            ptMap.put('RecordTypeId',ptList[0].RecordTypeId); //RecordType
                            //ptMap.put('QuantityReceived',ptList[0].QuantityReceived); //QuantityReceived
                            //ptMap.put('quantityReturned',ptList[0].Return_Order_Quantity__c); //quantityReturned

                            // 230726 소모품센터의 RSV_Quantity__c 수량 만큼 소모품 적치장소의 QuantityReceived 로 증가 시켜주고 IsReceived 가 true 가 되어야 실제 전산재고(보유량)이 증가하게 하기 위한 Map Put
                            //ptMap.put('RSV_Quantity__c', ptList[0].RSV_Quantity__c);

                            //ptMap.put('SHIPPED_Date__c',ptList[0].SHIPPED_Date__c); //SHIPPED_Date__c
                            ptMap.put('MOVE_Type_Code__c',ptList[0].MOVE_Type_Code__c); //MOVE_Type_Code__c
                            ptMap.put('ReturnOrderLineItemId',ptList[0].ReturnOrderLineItemId);
                            //ptMap.put('Product2Id',ptList[0].Product2Id);
                            ptMap.put('Product2Id',product2Id);
                            ptMap.put('requestProduct2Id', ptList[0].Product2Id);
                            ptMap.put('CARTON__c',ptList[0].CARTON__c); // CARTON__c //카툰아이디
                            //ptMap.put('CARTON__c',cartonNo); // CARTON__c //카툰아이디

                            //ProductRequest pr = [ SELECT id, RecordType.DeveloperName, Order_CUST_Id__c, DestinationLocationId FROM ProductRequest WHERE Order_Number__c = :orderNo LIMIT 1 ];
                            ProductRequest pr;
                            pr = new ProductRequest();
                            List<ProductRequest> prList;
                            prList = new List<ProductRequest>();
                            if(!prListTotal.isEmpty()){
                                for(ProductRequest ppr : prListTotal){
                                    if(ppr.Order_Number__c.equals(orderNo)){
                                        prList.add(ppr);
                                    }
                                }
                            }
                            if(!prList.isEmpty()){
                                pr = prList[0];
                                ptMap.put('ProductRequest', pr);
                            }
                            listPT.add(ptMap);
                        } //ptList.isEmpty()
                    }//CUSTR_PO_NO__c null
                }//for siFulfillmentReceivingList
                /** 입고확정 */
                //FS_ReceivingMngtController > doSaveReceivingItems 참고
                //FulfillmentWsBiz > cudFulfillmentRcvConfirm 입고대상정보
                //PartReceivingBiz > cudRcvMngListBiz 입고관리 확정처리
                /*
                2. 약속 입고 케이스
                    약속 데이터 업데이트 : 사업부입고수량 = 사업부 입고수량 + $입고수량
                    재고수량 업데이트 : 약속(+), 약속미입고(-), 보유량(+)
                3. 약속 외 입고 케이스
                    재고수량 업데이트 : 약속미입고(-), 보유량(+)
                4. 자재 입고처리 상태 변경
                    대상 오브젝트/필드 정보 – 자재 문의(정지인수석)
                5. 약속 입고 케이스 - 주문 정보 업데이트 : 사업부입고수량 == 요청수량 ENDP_RSV_Quantity__c
                    약속상태 업데이트 : 입고완료
                    주문상태 업데이트 : 상품준비중
                 */
                system.debug('listPT : '+listPT);

                List<ProductTransfer> listInsertPT = doSaveReceivingItems(listPT);

                if(!siFulfillmentReceivingList.isEmpty()){
                    for(SI_FULFILLMENT_RECEIVING__c sif : siFulfillmentReceivingList){
                        sif.RCV_CONFIRM_YN__c = 'Y';
                        sif.RCV_CONFIRM_DATE__c = System.now();
                        if(sif.SFDC_CONFIRM__c == 'E'){
                            sif.SFDC_CONFIRM__c = 'F'; //일단 모두 ERROR로 세팅
                        }else{
                            sif.SFDC_CONFIRM__c = 'E'; //일단 모두 ERROR로 세팅
                        }

                    }
                }

                if(!siFulfillmentReceivingList.isEmpty() && !listPT.isEmpty()){
                    for(SI_FULFILLMENT_RECEIVING__c sif : siFulfillmentReceivingList){
                        for(Map<String, Object> m : listPT){
                            if(m.get('SI_FULFILLMENT_RECEIVING_ID') != null){
                                String sifId = getStringNotNull(sif.Id);
                                String mId = getStringNotNull(m.get('SI_FULFILLMENT_RECEIVING_ID'));
                                if(sifId.equals(mId)){
                                    sif.SFDC_CONFIRM__c = 'Y';
                                }
                            }
                        }
                    }
                }

                System.debug('before update siFulfillmentReceivingList');
                update siFulfillmentReceivingList;
                update ptTotalList;
                successOrderRecevingId += String.valueOf(siFulfillmentReceivingList[0].Id) + ' ';
            }
        } catch (Exception e) {
            //23 11 15 hyungho.chun 로그 작업
            String ptId = siFulfillmentReceivingList[0].Product_Transfer_Id__c != null ? siFulfillmentReceivingList[0].Product_Transfer_Id__c : 'No Product Transfer Id contained ';
            String tempMsg = '[Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage() +', Product Transfer Id : ' + ptId;

            System.debug('*** e.getMessage: ' + e.getMessage());
            System.debug('*** e.getLine -> ' + e.getLineNumber());
            Database.rollback(sp);

            siFulfillmentReceivingList[0].RCV_CONFIRM_YN__c = 'E';
            update siFulfillmentReceivingList;

            // errorMap.put('orderNum',roLiList[0].Order_Number__c);
            // errorMap.put('orderChannel',roLiList[0].Order_CHNL_TYPE_Code__c);
            // errorMap.put('errorType','ReturnConfirm');
            errorMap.put('recordId',siFulfillmentReceivingList[0].Id);
            errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
            errorMap.put('isSuccess', 'N');
            errorMap.put('requestMsg', '[SUCCESS] : 0 \n[FAIL] : 1');
            errorMap.put('className', 'EX_OrderReceiving_ba');
            System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
            EX_ConsumableUtil.saveSaleExc(errorMap);
        }
        // catch (JSONException je){
        //     System.debug('*** je.getMessage: ' + je.getMessage());
        //     System.debug('*** je.getLine -> ' + je.getLineNumber());
        //     Database.rollback(sp);
        // } catch (NullPointerException ne){
        //     System.debug('*** ne.getMessage: ' + ne.getMessage());
        //     System.debug('*** ne.getLine -> ' + ne.getLineNumber());
        //     Database.rollback(sp);
        // } 
    }

    public void finish(Database.BatchableContext param1) {
        //23 11 15 hyungho.chun 성공케이스 로그작업
        Map<String,String> successMap = new Map<String,String>();
        //successMap.put('tempErrorMsg', 'EX_OrderReceiving_ba 성공한 케이스 recordId 모음');
        successMap.put('isSuccess', 'Y');
        successMap.put('className', 'EX_OrderReceiving_ba');
        successMap.put('requestMsg', '[SUCCESS] : 1 \n[FAIL] : 0');
        EX_ConsumableUtil.saveSaleExc(successMap);
        system.debug('EX_OrderReceiving_ba Finish');   
    }

    /**
     * @description   대상이 입고대상인 조회 목록 중 선택된 목록을 입고확정 시키는 작업 실행
     *                센터 -> 적치장소로 보내는 ProductTransfer Object 생성
     * @param  listPT 선택된 목록의 ProductTransfer ID, SourceLocation ID, DestinationLocation ID가 담겨진 List
     * @return void
     */
    public static List<ProductTransfer> doSaveReceivingItems(List<Map<String, Object>> listPT){
        system.debug('doSaveReceivingItems');
        System.debug('listpt :::: ' + listPT);
        
        // try{ //23 11 15 hyungho.chun exception 작업 상위에서 호출하는 부분으로 몰아넣음
            List<ProductTransfer> listUpdatePT;
            listUpdatePT = new List<ProductTransfer>();
            List<ProductTransfer> listInsertPT;
            listInsertPT = new List<ProductTransfer>();
            List<ProductItem> listUpsertPItem;
            listUpsertPItem = new List<ProductItem>();

            Set<Id> setProduct2Id;
            setProduct2Id = new Set<Id>();
            Set<Id> setDestinationLocationId;
            setDestinationLocationId = new Set<Id>();
            //Set<String> setStockPlace = new Set<String>();
            String requestProduct2Id = '';

            for(Map<String, Object> mapPT : listPT){
                if(mapPT.get('Id') != null){
                    String mapId = getStringNotNull(mapPT.get('Id'));
                    ProductTransfer objAddPT = new ProductTransfer();
                    objAddPT.Id = mapId;
                    //objAddPT.RSV_CONFIRM_Date__c = system.today();
                    system.debug('objAddPT for update :: ' + objAddPT);
                    listUpdatePT.add(objAddPT);
                }

                if(mapPT.get('Product2Id') != null){
                    String p2Id = getStringNotNull(mapPT.get('Product2Id'));
                    setProduct2Id.add(p2Id);
                    system.debug('setProduct2Id ::'+setProduct2Id);
                }
                if(mapPT.get('DestinationLocationId') != null){
                    String dId = getStringNotNull(mapPT.get('DestinationLocationId'));
                    setDestinationLocationId.add(dId);
                    system.debug('setDestinationLocationId ::'+setDestinationLocationId);
                }
                if(mapPT.get('requestProduct2Id') != null) {
                    requestProduct2Id = getStringNotNull(mapPT.get('requestProduct2Id'));
                }
                /*if(mapPT.get('stockPlace') != null){
                    String sId = getStringNotNull(mapPT.get('stockPlace'));
                    setStockPlace.add(sId);
                }*/
            }

            update listUpdatePT;

            List<ProductItem> listPItem = new List<ProductItem>();
            //23.12.02 gw.lee
            //Center Move Qty 수량 차감 (센터로 완전히 입고 되었기때문에)
            ProductItem centerItem = new ProductItem();

            // 입고하려는 센터 내 재고 조회
            listPItem = [
                    SELECT Id
                            , Product2Id
                            , LocationId
                            , DEPT_CODE__c
                            , MOVE_QTY__c
                    FROM ProductItem
                    WHERE Product2Id IN :setProduct2Id
                    AND LocationId IN :setDestinationLocationId
                    AND IsDeleted__c = false
                    FOR UPDATE
            ];

            centerItem = listPItem[0];

            Map<String, ProductItem> mapProduct2IdAndLocationId_objPItem = new Map<String, ProductItem>();
            List<String> deptCodeList = new List<String>();

            if(!listPItem.isEmpty()){
                for(ProductItem objPItem : listPItem){
                    mapProduct2IdAndLocationId_objPItem.put(String.valueOf(objPItem.Product2Id) + String.valueOf(objPItem.LocationId), objPItem); //Id, Product2Id, LocationId
                    deptCodeList.add(String.valueOf(objPItem.DEPT_CODE__c));
                }
                system.debug('deptCodeList ::'+deptCodeList);
            }

            // 입고하려는 적치장소 조회
            List<Schema.Location> listLocation = new List<Schema.Location>();
            listLocation = [
                    SELECT Id
                            , Name
                            , ParentLocationId__c
                            , DEPT_CODE__c
                    FROM Location
                    WHERE DEPT_CODE__c IN :deptCodeList
                    AND USE_STATUS_Code__c != '삭제됨'
                    AND Name = :System.Label.EX_Location
                    AND RecordType.DeveloperName = 'Location'
            ];

            Map<String, Schema.Location> mapParentLocationIdAndStockPlace_objLocation = new Map<String, Schema.Location>();

            if(!listLocation.isEmpty()){
                for(Schema.Location objLocation : listLocation){
                    mapParentLocationIdAndStockPlace_objLocation.put(String.valueOf(objLocation.ParentLocationId__c) + String.valueOf(objLocation.Name), objLocation);//Id, Name, ParentLocationId__c
                }
                system.debug('mapParentLocationIdAndStockPlace_objLocation ::'+mapParentLocationIdAndStockPlace_objLocation  );
            }

            // Carton 구성 목록 개수만큼 ProductTransfer 생성
            System.debug('Carton 구성 목록 개수만큼 ProductTransfer 생성 listPT size : ' + listPT.size());
            for(Map<String, Object> mapPT : listPT){
                //SELECT id, RecordTypeId, RecordType.DeveloperName, ProductRequestId, ProductRequestLineItemId, DestinationLocationId, SourceLocationId, DestinationLocation.Name, SourceLocation.Name, QuantityReceived, Return_Order_Quantity__c, SHIPPED_Date__c, MOVE_Type_Code__c, ReturnOrderLineItemId, Product2Id, fm_PART_NO__c, CARTON__c
                ProductTransfer objAddPT = new ProductTransfer();
                objAddPT.RecordTypeId = getStringNotNull(mapPT.get('RecordTypeId'));
                //objAddPT.ProductRequestId = getStringNotNull(mapPT.get('ProductRequestId'));          // 제품요청
                objAddPT.ProductRequestLineItemId = getStringNotNull(mapPT.get('ProductRequestLineItemId'));    // 제품요청행항목
                if(mapPT.get('ReturnOrderLineItemId') != null && mapPT.get('ReturnOrderLineItemId') != ''){
                    objAddPT.ReturnOrderLineItemId = getStringNotNull(mapPT.get('ReturnOrderLineItemId'));          // 반품요청행항목
                }
                objAddPT.Product2Id = getStringNotNull(mapPT.get('Product2Id'));                                // 제품

                if(mapProduct2IdAndLocationId_objPItem.get(getStringNotNull(mapPT.get('Product2Id')) + getStringNotNull(mapPT.get('DestinationLocationId'))) != null){
                    ProductItem objProductItem = mapProduct2IdAndLocationId_objPItem.get(getStringNotNull(mapPT.get('Product2Id')) + getStringNotNull(mapPT.get('DestinationLocationId')));
                    system.debug('objProductItem :: ' + objProductItem);
                    objAddPT.SourceProductItemId = objProductItem.Id; // 재고
                }
                //if(mapParentLocationIdAndStockPlace_objLocation.get(getStringNotNull(mapPT.get('DestinationLocationId')) + getStringNotNull(mapPT.get('stockPlace'))) != null){
                if(mapParentLocationIdAndStockPlace_objLocation.get(getStringNotNull(mapPT.get('DestinationLocationId')) + System.Label.EX_Location) != null){
                    //Schema.Location objLocation = mapParentLocationIdAndStockPlace_objLocation.get(getStringNotNull(mapPT.get('DestinationLocationId')) + getStringNotNull(mapPT.get('stockPlace')));
                    Schema.Location objLocation = mapParentLocationIdAndStockPlace_objLocation.get(getStringNotNull(mapPT.get('DestinationLocationId')) + System.Label.EX_Location);
                    system.debug('objLocation :: ' + objLocation);
                    objAddPT.DestinationLocationId = objLocation.Id; // 적치장소
                }else{
                    system.debug('존재하지 않거나 유효하지 않은 적치장소입니다. 적치장소는 01A01A 형식으로 입력하셔야 합니다.');
                    /*AuraHandledException e = new AuraHandledException('존재하지 않거나 유효하지 않은 적치장소입니다. 적치장소는 01A01A 형식으로 입력하셔야 합니다.');
                    throw e;*/
                }

                objAddPT.SourceLocationId = getStringNotNull(mapPT.get('DestinationLocationId'));  // 요청센터
                objAddPT.ENDP_Code__c = getStringNotNull(mapPT.get('ENDP_Code__c'));               // 사업부
                objAddPT.QuantitySent = getDecimalNotNull(mapPT.get('QuantityReceived'));
                //objAddPT.QuantityReceived = getDecimalNotNull(mapPT.get('QuantityReceived'));
                //objAddPT.QuantityReceived = getDecimalNotNull(mapPT.get('QuantityReceived'));

                // 230726 소모품센터의 RSV_Quantity__c 수량 만큼 소모품 적치장소의 QuantityReceived 로 증가 시켜주고 IsReceived 가 true 가 되어야 실제 전산재고(보유량)이 증가하게 됨
                objAddPT.QuantityReceived = getDecimalNotNull(mapPT.get('RSV_Quantity__c'));
                centerItem.Move_QTY__c = centerItem.Move_QTY__c - getDecimalNotNull(mapPT.get('RSV_Quantity__c'));
                objAddPT.IsReceived = true; //센터 -> 적치장소 true 세팅시 Standard 오류 (센터의 재고가 0이라 오류)
                //objAddPT.IsReceived = false;

                objAddPT.Return_Order_Quantity__c = getDecimalNotNull(mapPT.get('quantityReturned')); // 반품수량
                // objAddPT.IsSent = true;
                objAddPT.Status = '5';
                
                // objAddPT.RSV_Quantity__c = 
                // (mapPT.get('quantityReturned') != null) ?  getDecimalNotNull(mapPT.get('QuantityReceived')) + getDecimalNotNull(mapPT.get('quantityReturned')) :  getDecimalNotNull(mapPT.get('QuantityReceived')); // 입고수량
                //objAddPT.RSV_CONFIRM_Date__c = system.today();                          // 입고확정일자
                // objAddPT.CONFIRM_User_Code__c = ;                                    // 확정자코드
                objAddPT.CONFIRM_User__c = UserInfo.getUserId();                        // 확정자
                objAddPT.MOVE_Type_Code__c = getStringNotNull(mapPT.get('MOVE_Type_Code__c'));    // 이동유형
                objAddPT.CARTON_Number__c = getStringNotNull(mapPT.get('CARTON_Number__c'));      // Carton No
                if(mapPT.get('CARTON__c') != null && mapPT.get('CARTON__c') != ''){
                    objAddPT.CARTON__c = getStringNotNull(mapPT.get('CARTON__c'));                    // Carton ID
                }
                // objAddPT.SMS_Send_YN__c = ;                                          // TODO :: SMS발송여부
                objAddPT.Last_Completion_YN__c = 'Y';                               // 최종완료여부
                //gw.lee 23.12.22
                //입고 완료 날짜 및 입고 수량
                objAddPT.RSV_CONFIRM_Date__c = System.today();
                objAddPT.RSV_Quantity__c = getDecimalNotNull(mapPT.get('RSV_Quantity__c'));

                //24.01.04 gw.lee
                //출하 완료 날짜 및 입고 날짜 추가 입력
                objAddPT.RSV_Date__c = getDateWithNull(mapPT.get('SHIPPED_Date__c'));
                //24.03.06 gw.lee
                //예약관리 shippeddate 없어야 표출
                //objAddPT.SHIPPED_Date__c = getDateWithNull(mapPT.get('SHIPPED_Date__c'));

                // seung yoon heo Order_Number__c, Order_SEQ__c 추가 
                objAddPT.Order_Number__c = getStringNotNull(mapPT.get('Order_Number__c'));
                objAddPT.Order_SEQ__c = getDecimalNotNull(mapPT.get('Order_SEQ__c'));
                system.debug('objAddPT for insert :: ' + objAddPT);

                listInsertPT.add(objAddPT);
            }

            system.debug('before insert ProductTransfer');
            System.debug ('centerItem :::: ' + centerItem);
            System.debug ('listInsertPT :::: ' + listInsertPT);
            update centerItem;
            insert listInsertPT;

            // 입고 확정된 부품이 적치장소로 보낼 때
            // 1. 센터 재고의 이동수량 차감(소모품X)
            // 2. 해당 부품이 예약 부품인 경우 적치장소 재고의 약속수량 증감

            Set<Id> setProductItemId = new Set<Id>();
            setProduct2Id = new Set<Id>();
            Set<Id> setLocationId = new Set<Id>();
            Set<Id> setProductRequestLineItemId_RESV = new Set<Id>();

            for(Map<String, Object> mapPT : listPT){
                if(mapPT.get('ReturnOrderLineItemId') != null){
                    continue;
                }

                if(mapPT.get('ProductRequest') != null){
                    ProductRequest pr = (ProductRequest) mapPT.get('ProductRequest');
                    //if(pr.DestinationLocation.ServiceResource__c != null || pr.Order_CUST_Id__c != null){
                        if(mapPT.get('ProductRequestLineItemId') != null){
                            setProductRequestLineItemId_RESV.add(getStringNotNull(mapPT.get('ProductRequestLineItemId')));
                        }
                    //}
                }
            }

            if(!listInsertPT.isEmpty()){
                for(ProductTransfer objPT : listInsertPT){
                    if(objPT.ProductRequestLineItemId != null){
                        if(setProductRequestLineItemId_RESV.contains(objPT.ProductRequestLineItemId)){
                            if(objPT.Product2Id != null){
                                setProduct2Id.add(objPT.Product2Id);
                            }
                            if(objPT.DestinationLocationId != null){
                                setLocationId.add(objPT.DestinationLocationId);
                            }
                        }
                        if(objPT.SourceProductItemId != null){
                            setProductItemId.add(objPT.SourceProductItemId);
                        }
                    }
                }
            }

            listPItem = new List<ProductItem>();

            // 센터에서 재고의 이동수량 차감하기
    //        if(!setProductItemId.isEmpty()){
    //            listPItem = [
    //                    SELECT Id, RESRV_QTY__c, MOVE_QTY__c, LocationId, Product2Id
    //                    FROM ProductItem
    //                    WHERE Id IN :setProductItemId
    //                    AND IsDeleted__c = false
    //            ];
    //        }
    //
    //        Map<Id, ProductItem> map_PItemId_objPItem = new Map<Id, ProductItem>();
    //
    //        if(!listPItem.isEmpty()){
    //            system.debug('센터 재고 :: ' + listPItem);
    //            for(ProductItem objPItem : listPItem){
    //                map_PItemId_objPItem.put(objPItem.Id, objPItem);
    //            }
    //        }
    //
    //        system.debug('map_PItemId_objPItem :: ' + map_PItemId_objPItem);
    //
    //        if(!listInsertPT.isEmpty()){
    //            for(ProductTransfer objPT : listInsertPT){
    //                if(objPT.SourceProductItemId != null){
    //                    Id mapKey = objPT.SourceProductItemId;
    //                    if(map_PItemId_objPItem.get(mapKey) != null){
    //                        ProductItem objProductItem = map_PItemId_objPItem.get(mapKey);
    //
    //                        if(objProductItem != null){
    //                            objProductItem.MOVE_QTY__c -= objPT.QuantityReceived;
    //
    //                            system.debug('objProductItem :: ' + objProductItem);
    //
    //                            map_PItemId_objPItem.put(mapKey, objProductItem);
    //                        }
    //                    }
    //                }
    //            }
    //        }
    //
    //        for(Id mapKey : map_PItemId_objPItem.keySet()){
    //            if(map_PItemId_objPItem.get(mapKey) != null){
    //                listUpsertPItem.add(map_PItemId_objPItem.get(mapKey));
    //            }
    //        }

            // 예약 부품이 아닌 경우
            // 적치장소에 그대로 전송하기, 따로 처리하는 로직 없음
            System.debug('listPItem:'+ +'/'+setLocationId);
            // 예약 부품인 경우
            // 적치장소에서 받은 재고의 약속수량 더하기
            if(!setProduct2Id.isEmpty() && !setLocationId.isEmpty()){
                listPItem = [
                        SELECT Id, RESRV_QTY__c, LocationId, Product2Id, QuantityOnHand
                        FROM ProductItem
                        WHERE Product2Id IN :setProduct2Id
                        AND LocationId IN :setLocationId
                        AND IsDeleted__c = false FOR UPDATE
                ];
            }
            System.debug('listPItem :::'+listPItem);

            if (listPItem.isEmpty()) {
                System.debug('적치장소 재고 :: X ');
                List<Schema.Location> locationList = [SELECT DEPT_CODE__c FROM Location WHERE ID = :setLocationId LIMIT 1];
                if(locationList.size()>0){
                    String locationCode = [SELECT DEPT_CODE__c FROM Location WHERE ID = :setLocationId LIMIT 1].DEPT_CODE__c;
                    Set<String> idStrs = (Set<String>)JSON.deserialize(JSON.serialize(setProduct2Id), Set<String>.class);

                    EX_ConsumableUtil.createNotExistProductItem(idStrs, locationCode);
        
                    listPItem = [SELECT Id, RESRV_QTY__c, LocationId, Product2Id, QuantityOnHand FROM ProductItem WHERE Product2Id IN :setProduct2Id AND LocationId IN :setLocationId AND IsDeleted__c = false FOR UPDATE];
                }
            }


            Map<String, ProductItem> map_PItemId_objPItem_RESV;
            map_PItemId_objPItem_RESV = new Map<String, ProductItem>();

            if(!listPItem.isEmpty()){
                system.debug('적치장소 재고 :: ' + listPItem);
                for(ProductItem objPItem : listPItem){
                    if(objPItem.Product2Id != null 
                        && objPItem.LocationId != null){
                        map_PItemId_objPItem_RESV.put(getStringNotNull(objPItem.Product2Id) + getStringNotNull(objPItem.LocationId), objPItem);
                    }
                }
            }
            system.debug('map_PItemId_objPItem_RESV :: ' + map_PItemId_objPItem_RESV);
            system.debug('listInsertPT size : ' + listInsertPT.size());
            if(!listInsertPT.isEmpty()){
                List<ProductRequestLineItem> updatePrliList;
                updatePrliList = new List<ProductRequestLineItem>();
                List<String> prliIdList;
                prliIdList = new List<String>();
                for(ProductTransfer objPT : listInsertPT){
                    if(objPT.ProductRequestLineItemId != null){
                        prliIdList.add(objPT.ProductRequestLineItemId);
                    }
                }

                List<ProductRequestLineItem> prliListTotal;
                prliListTotal = new List<ProductRequestLineItem>();
                if(!prliIdList.isEmpty()){
                    //prliListTotal = [SELECT Id, QuantityRequested, ENDP_RSV_Quantity__c, RSRV_Number__c FROM ProductRequestLineItem WHERE id IN :prliIdList];
                    String strQuery = '';
                    strQuery += ' SELECT RecordType.DeveloperName, ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
                    strQuery += ' FROM ProductRequestLineItem ';
                    strQuery += ' WHERE Id IN (';
                    Integer i = 0;
                    for(String prliId : prliIdList){
                        if(i == 0){
                            strQuery += '\'' + prliId + '\'';
                        }else{
                            strQuery += ',\'' + prliId + '\'';
                        }
                        i++;
                    }
                    strQuery += ') ';

                    prliListTotal = Database.query(strQuery);
                }

                //23.12.01 gw.lee
                //rsrv no => SR_PART_ID로 변경
                List<String> partIdList = new List<String>();
                if(!prliListTotal.isEmpty()){
                    for(ProductRequestLineItem getprli : prliListTotal){
                        if (getprli.SR_RESRV_PART_Id__c != null) {
                            partIdList.add(getprli.SR_RESRV_PART_Id__c);
                        }
                    }
                }

                //원주문정보 찾기
                List<ProductRequestLineItem> oriPrliListTotal;
                oriPrliListTotal = new List<ProductRequestLineItem>();
                if(!partIdList.isEmpty() && String.isNotEmpty(requestProduct2Id)){
                    oriPrliListTotal = [
                        SELECT Id, ParentId, Order_Number__c, Appointment_Status__c,RSRV_Number__c, SR_RESRV_PART_Id__c, RSRV_SEQ__c, BASIS_Parts_Number__c, Consumables_Order_Class_Code__c, Order_CHNL_TYPE_Code__c, 
                                RecordType.DeveloperName, consumables_business_type_code__c, consumables_order_status__c, soldoutreceivingalarmdate__c, Parent.Order_CUST_TPNO_1__c, RSV_Quantity__c, Payment_Amount__c, CreatedById,
                                Parent.Payment_YN__c, CASH_PAYMENT_Amount__c, VIRTUAL_ACCT_PAYMENT_Amount__c, CARD_PAYMENT_Amount__c, SALE_Discount_Type_Code__c, VIP_Discount_Amount__c
                        FROM ProductRequestLineItem 
                        WHERE (RecordType.DeveloperName = 'Consumable' 
                        OR RecordType.DeveloperName = 'CareSupplies') 
                        AND SR_RESRV_PART_Id__c IN :partIdList
                        AND Product2Id = :requestProduct2Id
                        ];
                } else if (!partIdList.isEmpty()) {
                    oriPrliListTotal = [
                        SELECT Id, ParentId, Order_Number__c, Appointment_Status__c,RSRV_Number__c, SR_RESRV_PART_Id__c, RSRV_SEQ__c, BASIS_Parts_Number__c, Consumables_Order_Class_Code__c, Order_CHNL_TYPE_Code__c, 
                                RecordType.DeveloperName, consumables_business_type_code__c, consumables_order_status__c, soldoutreceivingalarmdate__c, Parent.Order_CUST_TPNO_1__c, RSV_Quantity__c, Payment_Amount__c, CreatedById,
                                Parent.Payment_YN__c, CASH_PAYMENT_Amount__c, VIRTUAL_ACCT_PAYMENT_Amount__c, CARD_PAYMENT_Amount__c, SALE_Discount_Type_Code__c, VIP_Discount_Amount__c
                        FROM ProductRequestLineItem 
                        WHERE (RecordType.DeveloperName = 'Consumable' 
                        OR RecordType.DeveloperName = 'CareSupplies') 
                        AND SR_RESRV_PART_Id__c IN :partIdList
                        ];
                }

                List<ProductRequestLineItem> prliListforExe;
                prliListforExe = new List<ProductRequestLineItem>();
                
                List<ProductTransfer> ptList;
                ptList = new List<ProductTransfer>();
                if(!listInsertPT.isEmpty()){
                    List<String> liptIdList;
                    liptIdList = new List<String>();
                    for(ProductTransfer pt : listInsertPT){
                        liptIdList.add(pt.Id);
                    }
                    System.debug('liptIdList :::: ' + liptIdList);
                    String strQ = '';
                    strQ += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductTransfer');
                    strQ += ' FROM ProductTransfer ';
                    strQ += ' WHERE Id IN (';
                    Integer i = 0;
                    for(String ptId : liptIdList){
                        if(i == 0){
                            strQ += '\'' + ptId + '\'';
                        }else{
                            strQ += ',\'' + ptId + '\'';
                        }
                        i++;
                    }
                    strQ += ') ';

                    ptList = Database.query(strQ);
                }
                System.debug('ptList :::: ' + ptList);
                List<Map<String,Object>> kakaoMapList = new List<Map<String, Object>>();
                
                Boolean isSoldOut = false;
                String parentId;
                String childId;
                for(ProductTransfer objPT : ptList){
                    System.debug('lgw objPT :::: ' + objPT);
                    String mapKey = '';
                    if(objPT.Product2Id != null 
                        && objPT.DestinationLocationId != null){
                        mapKey = getStringNotNull(objPT.Product2Id) + getStringNotNull(objPT.DestinationLocationId);
                    }
                    system.debug('mapKey : ' + mapKey);
                    if(!mapKey.equals('')){
                        system.debug('map_PItemId_objPItem_RESV.get(mapKey) : ' + map_PItemId_objPItem_RESV.get(mapKey));
                        if(map_PItemId_objPItem_RESV.get(mapKey) != null){
                            ProductItem objProductItem = map_PItemId_objPItem_RESV.get(mapKey);
                            //List<ProductRequestLineItem> prliList = [SELECT Id, QuantityRequested, ENDP_RSV_Quantity__c, RSRV_Number__c FROM ProductRequestLineItem WHERE id = :objPT.ProductRequestLineItemId];
                            List<ProductRequestLineItem> prliList = new List<ProductRequestLineItem>();
                            if(!prliListTotal.isEmpty()){
                                for(ProductRequestLineItem nprli : prliListTotal){
                                    if(nprli.Id == objPT.ProductRequestLineItemId){
                                        prliList.add(nprli);
                                    }
                                }
                            }
                            ProductRequestLineItem prli = new ProductRequestLineItem();
                            system.debug('prliList size : ' + prliList.size());
                            if(!prliList.isEmpty()){
                                prli = prliList[0];
                            }
                            system.debug('objPT.ProductRequestLineItemId : ' + objPT.ProductRequestLineItemId);
                            //List<ProductRequestLineItem> oriPrliList = [SELECT Id, Appointment_Status__c FROM ProductRequestLineItem WHERE (RecordType.DeveloperName = 'Consumable' OR RecordType.DeveloperName = 'CareSupplies') AND RSRV_Number__c = :prli.RSRV_Number__c];
                            List<ProductRequestLineItem> oriPrliList = new List<ProductRequestLineItem>();
                            if(!oriPrliListTotal.isEmpty()){
                                for(ProductRequestLineItem tprli : oriPrliListTotal){
                                    System.debug('tprli :::: ' + tprli);
                                    System.debug('prli :::: ' + prli);
                                    if (tprli.SR_RESRV_PART_Id__c == prli.SR_RESRV_PART_Id__c){
                                        oriPrliList.add(tprli);
                                    }
                                }
                            }
                            ProductRequestLineItem oriPrli = new ProductRequestLineItem();
                            if(!oriPrliList.isEmpty()){
                                oriPrli = oriPrliList[0];
                            }

                            system.debug('objProductItem : ' + objProductItem);
                            if(objProductItem != null){
                                if(objProductItem.RESRV_QTY__c == null){
                                    objProductItem.RESRV_QTY__c = 0;
                                }

                                //23.12.22 gw.lee
                                //주문 취소일 경우, 예약 수량 미증가 로직 추가
                                if (oriPrli.Consumables_Order_Status__c != '003' && oriPrli.Consumables_Order_Status__c != '004' && oriPrli.Consumables_Order_Status__c != '005' && prli.RecordType.DeveloperName != 'REGULAR') {
                                    objProductItem.RESRV_QTY__c += getIntegerNotNull(objPT.QuantityReceived);
                                }
                                //objProductItem.QuantityOnHand += getIntegerNotNull(objPT.QuantityReceived);


                                /*if(objProductItem.RESRV_UNRCV_QTY__c == null){
                                    objProductItem.RESRV_UNRCV_QTY__c = 0;
                                }

                                //사업부약속취소(미입고상태) 약속미입고(-)
                                //EX_RsrvUtil.execApplyProductItem(objPT.QuantityReceived, 'BD', prli); //사업부약속취소(미입고상태) 약속미입고(-)
                                if(objProductItem.RESRV_UNRCV_QTY__c > getIntegerNotNull(objPT.QuantityReceived)){
                                    objProductItem.RESRV_UNRCV_QTY__c -= getIntegerNotNull(objPT.QuantityReceived);
                                }else{
                                    objProductItem.RESRV_UNRCV_QTY__c = 0;
                                }*/
                                System.debug('prli.QuantityRequested :' + prli.QuantityRequested);
                                System.debug('prli.Product2Id :' + prli.Product2Id);
                                /** 센터의 약속미입고(-) */
                                //EX_RsrvUtil.execApplyProductItem(prli.QuantityRequested, 'AD', prli);
                                //gw.lee 23.09.23
                                //정기 입고건은 미입고 대상이 아니기에 패스 처리
                                if (prli.RecordType.DeveloperName != 'REGULAR') {
                                    prliListforExe.add(prli);
                                }


                                //system.debug('objProductItem :: ' + objProductItem);

                                map_PItemId_objPItem_RESV.put(mapKey, objProductItem);

                                /** 사업부입고수량 증가 */
                                /** 약속 입고 케이스 - 주문 정보 업데이트 : 사업부입고수량 == 요청수량 ENDP_RSV_Quantity__c
                                약속상태 업데이트 : 입고완료
                                주문상태 업데이트 : 상품준비중 (일반예약주문일때만. 품절주문은 결재 시 트리거에서 update)*/
                                //23 07 26 getIntegerNotNull(prli.ENDP_RSV_Quantity__c) 지워야할수도있음 hyungho.chun
                                //23 08 23 삭제 getIntegerNotNull(prli.ENDP_RSV_Quantity__c) +
                                Decimal endpRsvQ = getIntegerNotNull(objPT.QuantityReceived);
                                //if(getIntegerNotNull(prli.ENDP_RSV_Quantity__c) != getIntegerNotNull(objPT.QuantityReceived)) {
                                /** 대치부품 처리 */
                                System.debug('objPT.fm_PART_NO__c -> ' + objPT.fm_PART_NO__c);
                                System.debug('oriPrli -> ' + oriPrli);
                                System.debug('oriPrli.BASIS_Parts_Number__c -> ' + oriPrli.BASIS_Parts_Number__c);

                                if(objPT.fm_PART_NO__c != null 
                                    && oriPrli.BASIS_Parts_Number__c != null 
                                        && objPT.fm_PART_NO__c != oriPrli.BASIS_Parts_Number__c){ //대치부품일때
                                    String appStatus = '';
                                    String orderStatus = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006; //상품준비중
                                    
                                    Decimal endpRsvQTY = getIntegerNotNull(prli.ENDP_RSV_Quantity__c);
                                    Decimal qtyRequested = getIntegerNotNull(prli.QuantityRequested);

                                    if (qtyRequested <= endpRsvQTY + endpRsvQ) {
                                        System.debug('입고완료');
                                        appStatus = '입고완료';
                                        endpRsvQ = prli.QuantityRequested-endpRsvQTY; //24 02 21 hyungho.chun 부분입고 수량조정
                                        if(oriPrli.Order_CHNL_TYPE_Code__c == 'V'
                                                && oriPrli.RecordType.DeveloperName == 'Consumable'
                                                && oriPrli.Consumables_Order_Status__c == '000'
                                                && oriPrli.consumables_business_type_code__c == 'Order'
                                                && oriPrli.soldoutreceivingalarmdate__c == null){
                                            Map<String,Object> kakaoMap = new Map<String, Object>();
                                            kakaoMap.put('orderNo',oriPrli.Order_Number__c);
                                            kakaoMap.put('partNo',objPT.fm_PART_NO__c);
                                            kakaoMap.put('phoneNo',oriPrli.Parent.Order_CUST_TPNO_1__c);
                                            kakaoMap.put('parentId', oriPrli.ParentId);
                                            kakaoMap.put('originId', oriPrli.Id);
                                            kakaoMap.put('createdById', oriPrli.CreatedById);

                                            if (oriPrli.PAYMENT_Amount__c > 0) {
                                                kakaoMapList.add(kakaoMap);
                                                orderStatus = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_001; //결제요청
                                            }
                                        //24.03.06 gw.lee
                                        //결제화면에서 주문 생성하였을 경우, 리프레쉬 하였을때 사업부주문이 요청이되는 케이스 제외로직
                                        } else if (oriPrli.Parent.Payment_YN__c == false && oriPrli.CASH_PAYMENT_Amount__c == 0 && oriPrli.VIRTUAL_ACCT_PAYMENT_Amount__c == 0 && oriPrli.CARD_PAYMENT_Amount__c == 0) {
                                            //24.03.18 gw.lee
                                            //교환주문일 경우, 무조건 상품준비중이 되어야함
                                            if (oriPrli.Consumables_Business_Type_Code__c != 'ExchangeOrder') {
                                                //50% VIP인 경우, 할인유형이 VIP가 아닌 경우는 모두 결제 요청상태로 변경
                                                if ((oriPrli.SALE_Discount_Type_Code__c == 'V' && oriPrli.VIP_Discount_Amount__c != oriPrli.Payment_Amount__c) || oriPrli.SALE_Discount_Type_Code__c != 'V' ) {
                                                    orderStatus = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_001; //결제요청
                                                }
                                            }
                                        }

                                        if (oriPrli.Consumables_Order_Status__c == '000' && oriPrli.Order_CHNL_TYPE_Code__c != 'BestShop') {
                                            isSoldOut = true;
                                            parentId = oriPrli.ParentId;
                                            childId = oriPrli.Id;
                                        }
                                    } else if (qtyRequested > endpRsvQTY + endpRsvQ) {
                                        //appStatus = '일부입고';
                                        System.debug('대치부품 일부입고');
                                    }
                                    System.debug('objPT.ProductRequestLineItemId : ' + objPT.ProductRequestLineItemId);
                                    System.debug('oriPrli.Id : ' + oriPrli.Id);

                                    //예약
                                    ProductRequestLineItem uprli1 = new ProductRequestLineItem();
                                    uprli1.Id = objPT.ProductRequestLineItemId;
                                    uprli1.ENDP_RSV_Quantity__c = endpRsvQTY + endpRsvQ;
                                    //24.02.25 gw.lee
                                    //확정수량 추가
                                    //uprli1.Adjust_Quantity__c = endpRsvQTY + endpRsvQ;
                                    //24.02.025 gw.lee
                                    //예약관리화면에서 예약주문의 경우, 원주문은 Product2로 봄
                                    //uprli1.Product2Id = objPT.Product2Id;
                                    if (map_PItemId_objPItem_RESV.get(mapKey) != null) {
                                        uprli1.ProductItem__c = map_PItemId_objPItem_RESV.get(mapKey).Id;
                                    }
                                    // 230726 / 원 예약건 업데이트 주석 처리.
                                    // uprli1.ENDP_Code__c = objPT.ENDP_Code__c;

                                    //24 02 21 hyungho.chun 예약주문도 Appointment_Status__c에 이제 '요청' 넣어줌으로 모든수량 입고된 후 '입고완료' 기입
                                    if(appStatus != null && !appStatus.equals('')){
                                        uprli1.Appointment_Status__c = appStatus;
                                    }                                    
                                    
                                    // uprli1.Product2Id = objPT.Product2Id;
                                    // uprli1.PART_NO__c = objPT.fm_PART_NO__c;
                                    updatePrliList.add(uprli1);

                                    //원주문
                                    
                                    ProductRequestLineItem uprli2 = new ProductRequestLineItem();
                                    uprli2.Id = oriPrli.Id;
                                    uprli2.ENDP_RSV_Quantity__c = endpRsvQTY + endpRsvQ;
                                    //확정수량 추가
                                    //uprli2.Adjust_Quantity__c = endpRsvQTY + endpRsvQ;
                                    uprli2.ENDP_Code__c = objPT.ENDP_Code__c;
                                    uprli2.Product2Id = objPT.Product2Id;
                                    if (map_PItemId_objPItem_RESV.get(mapKey) != null) {
                                        uprli2.ProductItem__c = map_PItemId_objPItem_RESV.get(mapKey).Id;
                                    }
                                    uprli2.PART_NO__c = objPT.fm_PART_NO__c;
                                    if(appStatus != null && !appStatus.equals('')){
                                        uprli2.Appointment_Status__c = appStatus;
                                    }

                                    //23.12.22 gw.lee
                                    //주문 취소일 경우, 주문 상태 미변경 로직 추가
                                    if(oriPrli.Consumables_Order_Class_Code__c != null 
                                        && oriPrli.Consumables_Order_Class_Code__c == 'General' && appStatus == '입고완료' && (oriPrli.Consumables_Order_Status__c != '003' && oriPrli.Consumables_Order_Status__c != '004' && oriPrli.Consumables_Order_Status__c != '005')){
                                        //일반주문일때만 처리
                                        uprli2.Consumables_Order_Status__c = orderStatus;
                                    }else if(oriPrli.Consumables_Order_Class_Code__c != null 
                                                && oriPrli.Consumables_Order_Class_Code__c == 'Sold Out' && appStatus == '입고완료' && (oriPrli.Consumables_Order_Status__c != '003' && oriPrli.Consumables_Order_Status__c != '004' && oriPrli.Consumables_Order_Status__c != '005')) {
                                        //품절주문일때도 처리
                                        uprli2.Consumables_Order_Status__c = orderStatus;
                                    }

                                    updatePrliList.add(uprli2);
                                    

                                } else { //대치부품이 아닐때
                                    System.debug('objPT.ProductRequestLineItemId : ' + objPT.ProductRequestLineItemId);
                                    System.debug('oriPrli.Id : ' + oriPrli.Id);
                                    String appStatus = '';
                                    String orderStatus = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006; //상품준비중
                                    Decimal endpRsvQTY = getIntegerNotNull(prli.ENDP_RSV_Quantity__c);
                                    Decimal qtyRequested = getIntegerNotNull(prli.QuantityRequested);

                                    if(qtyRequested <= endpRsvQTY + endpRsvQ){
                                        appStatus = '입고완료';
                                        endpRsvQ = prli.QuantityRequested-endpRsvQTY; //24 02 21 hyungho.chun 부분입고 수량조정

                                        if(oriPrli.Order_CHNL_TYPE_Code__c == 'V'
                                                && oriPrli.RecordType.DeveloperName == 'Consumable'
                                                && oriPrli.Consumables_Order_Status__c == '000'
                                                && oriPrli.consumables_business_type_code__c == 'Order'
                                                && oriPrli.soldoutreceivingalarmdate__c == null
                                                && (oriPrli.Consumables_Order_Status__c != '003' && oriPrli.Consumables_Order_Status__c != '004' && oriPrli.Consumables_Order_Status__c != '005')){
                                            Map<String,Object> kakaoMap = new Map<String, Object>();
                                            kakaoMap.put('orderNo',oriPrli.Order_Number__c);
                                            kakaoMap.put('partNo',oriPrli.BASIS_Parts_Number__c);
                                            kakaoMap.put('phoneNo',oriPrli.Parent.Order_CUST_TPNO_1__c);
                                            kakaoMap.put('parentId', oriPrli.ParentId);
                                            kakaoMap.put('originId', oriPrli.Id);
                                            kakaoMap.put('createdById', oriPrli.CreatedById);

                                            if (oriPrli.PAYMENT_Amount__c > 0) {
                                                kakaoMapList.add(kakaoMap);
                                                orderStatus = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_001; //결제요청
                                            }
                                        //24.03.06 gw.lee
                                        //결제화면에서 주문 생성하였을 경우, 리프레쉬 하였을때 사업부주문이 요청이되는 케이스 제외로직
                                        } else if (oriPrli.Parent.Payment_YN__c == false && oriPrli.CASH_PAYMENT_Amount__c == 0 && oriPrli.VIRTUAL_ACCT_PAYMENT_Amount__c == 0 && oriPrli.CARD_PAYMENT_Amount__c == 0) {
                                            //24.03.18 gw.lee
                                            //교환주문일 경우, 무조건 상품준비중이 되어야함
                                            if (oriPrli.Consumables_Business_Type_Code__c != 'ExchangeOrder') {
                                                //50% VIP인 경우, 할인유형이 VIP가 아닌 경우는 모두 결제 요청상태로 변경
                                                if ((oriPrli.SALE_Discount_Type_Code__c == 'V' && oriPrli.VIP_Discount_Amount__c != oriPrli.Payment_Amount__c) || oriPrli.SALE_Discount_Type_Code__c != 'V') {
                                                    orderStatus = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_001; //결제요청
                                                }
                                            }
                                        }

                                        //24.03.09 gw.lee
                                        //품절주문 일괄 업데이트 조치
                                        if (oriPrli.Consumables_Order_Status__c == '000' && oriPrli.Order_CHNL_TYPE_Code__c != 'BestShop') {
                                            isSoldOut = true;
                                            parentId = oriPrli.ParentId;
                                            childId = oriPrli.Id;
                                        }
                                    } else if (qtyRequested <= endpRsvQTY + endpRsvQ) {
                                        //appStatus = '일부입고';
                                        System.debug('일부입고');
                                    }
                                    ProductRequestLineItem uprli1 = new ProductRequestLineItem();
                                    uprli1.Id = objPT.ProductRequestLineItemId;
                                    uprli1.ENDP_RSV_Quantity__c = endpRsvQTY + endpRsvQ;
                                    //uprli1.Adjust_Quantity__c = endpRsvQTY + endpRsvQ;
                                    uprli1.ENDP_Code__c = objPT.ENDP_Code__c;
                                    //24 02 21 hyungho.chun 예약주문도 Appointment_Status__c에 이제 '요청' 넣어줌으로 모든수량 입고된 후 '입고완료' 기입
                                    if(appStatus != null && !appStatus.equals('')){
                                        uprli1.Appointment_Status__c = appStatus;
                                    }                                          
                                    updatePrliList.add(uprli1);

                                    
                                    ProductRequestLineItem uprli2 = new ProductRequestLineItem();
                                    uprli2.Id = oriPrli.Id;
                                    uprli2.ENDP_RSV_Quantity__c = endpRsvQTY + endpRsvQ;
                                    //uprli2.Adjust_Quantity__c = endpRsvQTY + endpRsvQ;
                                    uprli2.ENDP_Code__c = objPT.ENDP_Code__c;
                                    if(appStatus != null && !appStatus.equals('')){
                                        uprli2.Appointment_Status__c = appStatus;
                                    }
                                    if(oriPrli.Consumables_Order_Class_Code__c != null 
                                        && oriPrli.Consumables_Order_Class_Code__c == 'General' && appStatus == '입고완료' && (oriPrli.Consumables_Order_Status__c != '003' && oriPrli.Consumables_Order_Status__c != '004' && oriPrli.Consumables_Order_Status__c != '005')){
                                        //일반주문일때만 처리
                                        uprli2.Consumables_Order_Status__c = orderStatus;
                                    }else if(oriPrli.Consumables_Order_Class_Code__c != null 
                                                && oriPrli.Consumables_Order_Class_Code__c == 'Sold Out' && appStatus == '입고완료' && (oriPrli.Consumables_Order_Status__c != '003' && oriPrli.Consumables_Order_Status__c != '004' && oriPrli.Consumables_Order_Status__c != '005')){
                                        //품절주문일때도 처리
                                        uprli2.Consumables_Order_Status__c = orderStatus;
                                    }
                                    updatePrliList.add(uprli2);
                                }//대치부품 if
                            }//재고 if
                        }
                    }
                }// for PT
                system.debug('Before update updatePrliList');
                System.debug('updatePrliList ::: ' + updatePrliList);
                if(!updatePrliList.isEmpty()){
                    List<ProductRequestLineItem> updateOrderList = new List<ProductRequestLineItem>();
                    for (ProductRequestLineItem prliObj : updatePrliList) {
                        if (prliObj.Id != null) {
                            updateOrderList.add(prliObj);
                        }
                    }
                    System.debug('updateOrderList :::: ' + updateOrderList);
                    if (updateOrderList.size() > 0) {
                        if(!Test.isRunningTest()) update updateOrderList;
                        if (isSoldOut && String.isNotEmpty(parentId) && String.isNotEmpty(childId)) {
                            updateSoldoutStatus(parentId, childId);
                        }
                    }
                }
                // if(!prliListforExe.isEmpty()){
                //     EX_RsrvUtil.execApplyProductItemMulti('AD', prliListforExe); //센터 약속미입고(-)
                // }
                if(!kakaoMapList.isEmpty()){
                    System.debug('입고완료 알림톡 송신건 : ' + kakaoMapList.size());
                    try {
                        sendKaKao(kakaoMapList);
                    }catch(Exception e){
                        System.debug('입고 알림톡 에러 line : ' + e.getLineNumber() + ', msg : ' + e.getMessage());
                    }
                }
            }

            for(String mapKey : map_PItemId_objPItem_RESV.keySet()){
                if(map_PItemId_objPItem_RESV.get(mapKey) != null){
                    listUpsertPItem.add(map_PItemId_objPItem_RESV.get(mapKey));
                }
            }

            if(!listUpsertPItem.isEmpty()){
                upsert listUpsertPItem;
            }

            return listInsertPT;

        //23 11 15 hyungho.chun exception 작업 상위에서 호출하는 부분으로 몰아넣음
        // } catch (Exception e) {
        //     System.debug('*** e.getMessage: ' + e.getMessage());
        //     System.debug('*** e.getLine -> ' + e.getLineNumber());
        //     return null;
        // }

    }

    /**
    * 알림톡 전송
    */
    @AuraEnabled
    public static void sendKaKao(List<Map<String,Object>> kakaoMapList){
        //24.01.29 gw.lee
        //kakao 알림톡 전체 입고 완료되었을 경우만 전송 로직 추가
        List<String> parentList = new List<String>();
        //현재 돌린 대상 품목 ID, update되기 전 Param 정보를 보내줘서 필요
        String prliId;
        String orderNo;
        for(Map<String,Object> kakaoMap : kakaoMapList){
            parentList.add(String.valueOf(kakaoMap.get('parentId')));
            prliId = String.valueOf(kakaoMap.get('originId')); 
            orderNo = String.valueOf(kakaoMap.get('orderNo'));
        }

        //전체 품목 검색
        List<ProductRequestLineItem> prliList = [SELECT Id, Appointment_Status__c, Order_Number__c
                                                    FROM ProductRequestLineItem 
                                                    WHERE ParentId = :parentList AND RecordType.DeveloperName = 'Consumable' AND Consumables_Order_Status__c NOT IN ('003', '004', '005')];
        Map<String, Boolean> kakaoCheckMap = new Map<String, Boolean>();
		
        Integer prliSize = prliList.size();
        //입고완료된 주문의 품목들이 모두 입고 완료일 경우만 전송
        for (ProductRequestLineItem pObj : prliList) {
            System.debug('pObj :::: ' + pObj);
            if (kakaoCheckMap.containsKey(pObj.Order_Number__c)) {
                //현재 전송여부인 케이스
                if (kakaoCheckMap.get(pObj.Order_Number__c) && pObj.Appointment_Status__c != '입고완료' && pObj.Id != prliId) {
                    kakaoCheckMap.put(pObj.Order_Number__c, false);
                }
            } else {
                Boolean statusCheck = pObj.Appointment_Status__c == '입고완료' || pObj.Id == prliId ? true : false;
                kakaoCheckMap.put(pObj.Order_Number__c, statusCheck);
            }
        }
		
        if (kakaoCheckMap.size() > 0) {
            if (kakaoCheckMap.get(orderNo)) {
                Map<String,EX_Message__c> etmMap = new Map<String, EX_Message__c>();
                List<String> dupKey = new List<String>();
                for(Map<String,Object> kakaoMap : kakaoMapList){
                    String orderNoStr = String.valueOf(kakaoMap.get('orderNo'));
                    String partNoStr = String.valueOf(kakaoMap.get('partNo'));
                    String phoneNoStr = String.valueOf(kakaoMap.get('phoneNo'));
                    Boolean needKakao = true;
                    String key = orderNoStr+partNoStr+PhoneNoStr;
                    if(!dupKey.isEmpty()){
                        for(String dupStr : dupKey){
                            if(dupStr == key){
                                needKakao = false;
                            }
                        }
                    }
                    if(needKakao){
                        dupKey.add(key);
                        EX_Message__c etm = new EX_Message__c();
                        etm.Label1__c = orderNoStr;
                        //주문단위로 알림톡 발송을 하기때문에 총 품목의 개수 기재
                        if (prliSize > 1) {
                            partNoStr = partNoStr + '외 ' + String.valueOf(prliSize-1) + '건';
                        }
                        etm.Label2__c = partNoStr;
                        etmMap.put(key, etm);
                    }
                }
        
                List<Map<String,Object>> etmMapList = new List<Map<String,Object>>();
                for(Map<String,Object> kakaoMap : kakaoMapList){
                    Map<String,Object> etmMap2 = new Map<String, Object>();
                    String orderNoStr = String.valueOf(kakaoMap.get('orderNo'));
                    String partNoStr = String.valueOf(kakaoMap.get('partNo'));
                    String phoneNoStr = String.valueOf(kakaoMap.get('phoneNo'));
                    String createdById = String.valueOf(kakaoMap.get('createdById'));
                    String key = orderNoStr+partNoStr+PhoneNoStr;
                    etmMap2.put('exm',etmMap.get(key));
                    etmMap2.put('phoneNo',phoneNoStr);
                    etmMap2.put('createdById', createdById);
                    etmMapList.add(etmMAp2);
                }
                System.debug('etmMapList : ' + etmMapList);
        
                //품절예약주문 생성 후 해당 소모품 입고될 경우 컨설턴트/SM 담당자에게 알림(요청번호 : N20221208_01078)
                String templateCode = 'SVC_LGE_MACN_S020';
                TemplateMgmt__c template = [
                        SELECT Id, Content_c__c, Title__c, TemplateCode__c
                        FROM TemplateMgmt__c
                        WHERE TemplateCode__c=:templateCode
                ][0];
                List<TemplateParams__c> templateParamList = [
                        SELECT Id, Name, FieldApi__c
                        FROM TemplateParams__c
                        WHERE TemplateMgmt__c=:template.Id
                ];
        
                List<EX_Message__c> alarmList = new List<EX_Message__c>();
        
                for(Map<String,Object> emMap : etmMapList){
                    EX_Message__c em = (EX_Message__c)emMap.get('exm');
                    system.debug('em : ' + em);
                    String phoneNoStr = String.valueOf(emMap.get('phoneNo'));
                    //24.02.15 gw.lee
                    //법인폰 유무 체크를 위한 주문 생성자 (최초 주문자) ID 전달
                    String createdById = String.valueOf(emMap.get('createdById'));
                    Map<String, Object> populateMap = em.getPopulatedFieldsAsMap();
                    TemplateMgmt__c templateTemp = template.clone();
                    IF_CM_SFDC_KAKAO.InputParam inputParam = 
                    EX_MessageUtil.getInputParamForKaKao(templateTemp, templateParamList, populateMap);
                    inputParam.smsTitle = '소모품 입고';
                    inputParam.smsMsg = inputParam.kakaoMsg;
        
                    Map<String, Object> mapResult = IF_CM_SFDC_KAKAO.doSendKakao(inputParam);
                    System.debug('phoneNoStr : ' + phoneNoStr);
                    System.debug('kakaoMsg : ' + inputParam.kakaoMsg);
        
                    //배치 알림톡 리스트
                    EX_Message__c alarm = new EX_Message__c();
                    alarm.Label1__c = inputParam.templateCode;
                    alarm.Label2__c = em.Label1__c;
                    alarm.Label3__c = inputParam.kakaoTitle;
                    alarm.Label4__c = em.Label2__c;
                    alarm.Label5__c = inputParam.smsTitle;
                    alarm.Label6__c = phoneNoStr;
                    alarm.Label7__c = String.valueOf(inputParam.sendAt); //신규 셋팅 필요
                    alarm.Label8__c = 'EX_OrderReceiving_ba';
                    alarm.Label9__c = 'N';
                    alarm.Label10__c = createdById;
        
                    alarmList.add(alarm);
                }
        
                //2024.01.015 gw.lee
                //Batch를 통해서만 알림 발송 로직 추가
                if (alarmList.size() > 0) {
                    insert alarmList;
                }
            }
        }
        
    }

    @AuraEnabled
    public static void updateSoldoutStatus(String parentId, String childId){
        List<ProductRequestLineItem> checkList = [SELECT Id, Consumables_Order_Status__c, Appointment_Status__c FROM ProductRequestLineItem WHERE ParentId = :parentId AND RecordType.DeveloperName IN ('Consumable', 'CareSupplies')];

        if (checkList.size() > 0 ) {
            Boolean isUpdate = true;
            for (ProductRequestLineItem checkObj : checkList) {
                if (checkObj.Appointment_Status__c != '입고완료') {
                    isUpdate = false;

                    break;
                } else if (checkObj.Appointment_Status__c == '입고완료') {
                    checkObj.Consumables_Order_Status__c = '001';
                }
            }

            if (isUpdate) {
                update checkList;
            } else {
                ProductRequestLineItem childObj = [SELECT ID, Consumables_Order_Status__c FROM ProductRequestLineItem WHERE Id = :childId LIMIT 1];
                childObj.Consumables_Order_Status__c = '000';

                update childObj;
            }
        }
    }

    @future(callout=true)
    public static void sendCalloutKakao(String templateCode, String kakaoMsg, String kakaoTitle, String smsMsg, String smsTitle, String phoneNoStr, Datetime sendAt){
        IF_CM_SFDC_KAKAO.InputParam inputParam = new IF_CM_SFDC_KAKAO.InputParam();
        inputParam.templateCode = templateCode;
        inputParam.kakaoMsg = kakaoMsg;
        inputParam.kakaoTitle = kakaoTitle;
        inputParam.smsMsg = smsMsg;
        inputParam.smsTitle = smsTitle;
        Set<String> setPhoneNumber = new Set<String>{
                phoneNoStr
        };
        inputParam.setPhoneNumber = setPhoneNumber;
        inputParam.sendAt = sendAt;
        IF_CM_SFDC_KAKAO.doSendKakao(inputParam);
    }

    /**
     * 화면에서 강제 입고처리 시 소모품용 예약처리 호출
     * @param
     *  ProductRequestLineItem Id
     * @return
     *  resultStat = 'SUCCESS' or 'FAIL'
     *  resultMessage
     */
    @AuraEnabled
    public static Map<String, Object> ConsumableOrderReceive(List<String> prliIdList){
        Map<String, Object> returnMap;
        returnMap = new Map<String, Object>();
        String resultStat = 'SUCCESS';
        String resultMessage = '';

        if(!prliIdList.isEmpty()){
            //23 11 15 hyungho.chun 오류로그
            Map<String,String> errorMap = new Map<String,String>();
            Savepoint sp = Database.setSavepoint();
            try {
                List<ProductRequestLineItem> prliTotalList = [
                    SELECT Id, QuantityRequested, BASIS_Parts_Number__c, ENDP_RSV_Quantity__c, RSRV_Number__c, SR_RESRV_PART_Id__c 
                    FROM ProductRequestLineItem 
                    WHERE id IN :prliIdList
                    ];

                List<ProductRequestLineItem> listUpdatePrli;
                listUpdatePrli = new List<ProductRequestLineItem>();
                for (String prliId : prliIdList) {
                    List<ProductRequestLineItem> prliList;
                    prliList = new List<ProductRequestLineItem>();
                    if(!prliTotalList.isEmpty()){
                        for(ProductRequestLineItem prli : prliTotalList){
                            if(prliId == prli.Id){
                                prliList.add(prli);
                            }
                        }
                    }
                    ProductRequestLineItem prli;
                    prli = new ProductRequestLineItem();
                    if (!prliList.isEmpty()) {
                        prli = prliList[0];
                        List<ProductRequestLineItem> oriPrliList = [
                            SELECT Id, BASIS_Parts_Number__c, Appointment_Status__c 
                            FROM ProductRequestLineItem 
                            WHERE RecordType.DeveloperName IN ('Consumable', 'CareSupplies') 
                            AND SR_RESRV_PART_Id__c = :prli.SR_RESRV_PART_Id__c
                            ];
                        ProductRequestLineItem oriPrli;
                        oriPrli = new ProductRequestLineItem();
                        if (!oriPrliList.isEmpty()) {
                            oriPrli = oriPrliList[0];
                        }

                        List<ProductTransfer> objPTList = [
                            SELECT Id, QuantityReceived, fm_PART_NO__c, ENDP_Code__c, Product2Id  
                            FROM ProductTransfer 
                            WHERE ProductRequestLineItemId = :prliId 
                            ORDER BY RSV_SEQ__c desc 
                            LIMIT 1
                            ];
                        ProductTransfer objPT;
                        objPT = new ProductTransfer();
                        if (!objPTList.isEmpty()) {
                            objPT = objPTList[0];
                        }

                        /** 사업부입고수량 증가 */
                        /** 약속 입고 케이스 - 주문 정보 업데이트 : 사업부입고수량 == 요청수량 ENDP_RSV_Quantity__c
                        약속상태 업데이트 : 입고완료
                        주문상태 업데이트 : 상품준비중 */

                        //23 08 23 hyungho.chun 삭제 getIntegerNotNull(prli.ENDP_RSV_Quantity__c) +
                        Decimal endpRsvQ =  getIntegerNotNull(objPT.QuantityReceived);
                        //if (getIntegerNotNull(prli.ENDP_RSV_Quantity__c) != getIntegerNotNull(objPT.QuantityReceived)) {
                        /** 대치부품 처리 */
                        if (objPT.fm_PART_NO__c != oriPrli.BASIS_Parts_Number__c) { //대치부품일때
                            String appStatus = '';
                            if (prli.QuantityRequested <= endpRsvQ) {
                                appStatus = '입고완료';
                                endpRsvQ = prli.QuantityRequested;
                            } else {
                                //appStatus = '일부입고';
                                system.debug('대치부품 일부입고');
                            }
                            ProductRequestLineItem uprli;
                            uprli = new ProductRequestLineItem();
                            uprli.Id = prliId;
                            uprli.ENDP_RSV_Quantity__c = endpRsvQ;
                            uprli.ENDP_Code__c = objPT.ENDP_Code__c;
                            uprli.Product2Id = objPT.Product2Id;
                            uprli.PART_NO__c = objPT.fm_PART_NO__c;
                            listUpdatePrli.add(uprli);

                            ProductRequestLineItem oriUprli;
                            oriUprli = new ProductRequestLineItem();
                            oriUprli.Id = oriPrli.Id;
                            if(appStatus != null && !appStatus.equals('')){
                                oriUprli.Appointment_Status__c = appStatus;
                            }
                            oriUprli.ENDP_RSV_Quantity__c = endpRsvQ;
                            oriUprli.ENDP_Code__c = objPT.ENDP_Code__c;
                            oriUprli.Product2Id = objPT.Product2Id;
                            oriUprli.PART_NO__c = objPT.fm_PART_NO__c;
                            listUpdatePrli.add(oriUprli);

                        } else { //대치부품이 아닐때
                            String appStatus = '';
                            if (prli.QuantityRequested <= endpRsvQ) {
                                appStatus = '입고완료';
                                endpRsvQ = prli.QuantityRequested;
                            } else {
                                //appStatus = '일부입고';
                                system.debug('일부입고');
                            }
                            ProductRequestLineItem uprli;
                            uprli = new ProductRequestLineItem();
                            uprli.Id = prliId;
                            uprli.ENDP_RSV_Quantity__c = endpRsvQ;
                            uprli.ENDP_Code__c = objPT.ENDP_Code__c;
                            listUpdatePrli.add(uprli);

                            ProductRequestLineItem oriUprli;
                            oriUprli = new ProductRequestLineItem();
                            oriUprli.Id = oriPrli.Id;
                            if(appStatus != null && !appStatus.equals('')){
                                oriUprli.Appointment_Status__c = appStatus;
                            }
                            oriUprli.ENDP_RSV_Quantity__c = endpRsvQ;
                            oriUprli.ENDP_Code__c = objPT.ENDP_Code__c;
                            listUpdatePrli.add(oriUprli);
                        }
                        //}
                    }
                }
                System.debug('listUpdatePrli :: '+listUpdatePrli);
                update listUpdatePrli;
            }catch (Exception e) {
                resultStat = 'FAIL';
                resultMessage = e.getMessage();
                Database.rollback(sp);

                String tempMsg = '[Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage() + 'ConsumableOrderReceive 호출중 에러';
                errorMap.put('isSuccess','N'); //24 02 25 hyungho.chun 성공 실패 여부 추가 (이메일 및 실패시 메세지 전송용)
                errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
                System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
                EX_ConsumableUtil.saveSaleExc(errorMap);                
            }
            // catch (JSONException je){
            //     resultStat = 'FAIL';
            //     resultMessage = je.getMessage();
            //     Database.rollback(sp);
            // } catch (NullPointerException ne){
            //     resultStat = 'FAIL';
            //     resultMessage = ne.getMessage();
            //     Database.rollback(sp);
            // } 
            
        }

        returnMap.put('resultStat', resultStat);
        returnMap.put('resultMessage', resultMessage);
        return returnMap;
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
    public static Decimal getDecimalNotNull(Object obj) {
        Decimal d = 0;
        if(obj != null){
            d = Decimal.valueOf(Double.valueOf(obj));
        }
        return d;
    }

}