/**
 * Created by I2MAX.SEOKHOLEE on 2023-03-15.
 */

@RestResource(UrlMapping='/v1/api/ma/heroku/ReturnOrderConfirm')
global with sharing class EX_ReturnOrderConfirm {
    /**
    * @AUTHOR I2MAX.SEOKHOLEE
    * @date  2023-03-15
    * @param
    * @description 반품 확정 수신
    * @return
    */
    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;

        // todo: 로직 구현 후, Util Method 로 이동 예정
        // 케어용품은 반품 확정 관련 확인 필요
        // 반품 확정 대상 : 반품 상태가 '배송완료' 이고, 반품 확정이 되지 않은 대상 (반품요청상태 : 반품확정(임은정 책임님과 협의))


        // 1. 반품 데이터(Return Order, Return Order Line Item) 확정 처리
        // 1-1). 화면단에서 처리 시 반품완료이고 확정되지 않은 대상 기준으로 처리 하여야 함.
        // 1-2). Heroku 에서 호출 시 이미 확정된 대상 기준 처리 로직 구현

        // 2. 반품의 원 주문 데이터(Product Request Line Item) Update 처리 / 반품 수량 Update
        // 3. 환불 처리(Only CIC) + 적자정보 생성
        // 4. 수불 처리(Product Transfer, ProductItem / Transaction)

        // todo: 반품확정 시 환불 처리의 경우 Async 로 단건씩 처리

        doReturnOrderConfirm();
    }

    public static Map<String, Object> doReturnOrderConfirm(Set<String> roliIdSet) {
        Map<String, Object> infoMap = new Map<String, Object>();
        infoMap.put('isSuccess', true);

        Savepoint sp = Database.setSavepoint();

        infoMap.putAll(doCheckSaleNumber(roliIdSet));
        if(infoMap.get('errMsg') != null) {
            infoMap.put('isSuccess', false);
            infoMap.put('error', infoMap.get('errMsg'));
            return infoMap;
        }

        infoMap.putAll(doConfirm(roliIdSet));
        infoMap.putAll(doOriginDataUpdate(infoMap));
        infoMap.putAll(doRefund(infoMap));
        infoMap.putAll(doApplyProductItem(infoMap));

        System.debug('==================== infoMap ====================');
        System.debug(infoMap.get('isSuccess'));
        System.debug(infoMap.get('error'));
        System.debug(infoMap.get('errMsg'));
        System.debug('============================================');

        if(infoMap.get('errMsg') != null && infoMap.get('errMsg') != '') {
            infoMap.put('error', infoMap.get('errMsg'));
        }

        if(!(Boolean) infoMap.get('isSuccess')) {
            Database.rollback(sp);
        }
        return infoMap;
    }

    public static Map<String, Object> doReturnOrderConfirm() {
        Map<String, Object> infoMap = new Map<String, Object>();
        infoMap.put('isSuccess', true);

        Savepoint sp = Database.setSavepoint();
        infoMap.putAll(doConfirm(null));
        infoMap.putAll(doOriginDataUpdate(infoMap));
        infoMap = doRefund(infoMap);
        infoMap.putAll(doApplyProductItem(infoMap));

        System.debug('==================== infoMap ====================');
        System.debug(infoMap.get('isSuccess'));
        System.debug(infoMap.get('error'));
        System.debug(infoMap.get('errMsg'));
        System.debug('============================================');

        if(infoMap.get('errMsg') != null && infoMap.get('errMsg') != '') {
            infoMap.put('error', infoMap.get('errMsg'));
        }

        if(!(Boolean) infoMap.get('isSuccess')) {
            Database.rollback(sp);
        }
        return infoMap;
    }

    /**
     * @description 1. 반품 데이터(Return Order, Return Order Line Item) 확정 처리
     * @return
     */
    public static Map<String, Object> doConfirm(Set<String> roliIdSet) {
        Map<String, Object> infomap = new Map<String, Object>();

        // 반품 확정 대상 : 배송완료 && 반품확정일시 가 비어 있는 경우

        String returnOrderQuery;
        returnOrderQuery = ' SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrderLineItem');
        returnOrderQuery += ', Product2.DIV_CODE__c, ProductRequestLineItem.MODEL_Code__c, ProductRequestLineItem.QuantityRequested, ProductRequestLineItem.Product2Id  ';
        returnOrderQuery += ', ProductRequestLineItem.SHIP_QTY__c, ProductRequestLineItem.CANCEL_Quantity__c, ProductRequestLineItem.fm_UnitPrice__c ' +
                ', ProductRequest__r.Order_Number__c, Product2.Name, ProductRequest__r.Order_Date__c, ProductRequest__r.BILL_TO_CODE__c' +
                ', ProductRequest__r.SHIP_TO_CODE__c, ProductRequest__r.Description' ;
        returnOrderQuery += ', ProductRequestLineItem.Parent.SR_SALE__c, ProductRequestLineItem.Parent.Order_Number__c';
        // Part
        returnOrderQuery += ', Product2.PART_DESC_KOR__c ';
        returnOrderQuery += ', Product2.CUST_PRICE__c ';


        // FROM
        returnOrderQuery += ' FROM ' + 'ReturnOrderLineItem';

        // WHERE
        returnOrderQuery += ' WHERE RecordType.DeveloperName IN (\'Consumable\', \'CareSupplies\')';

        // 소모품 주문 여부
        returnOrderQuery += ' AND Consumables_Order_YN__c = TRUE ';
        // 소모품 요청 구분
        returnOrderQuery += ' AND Consumables_Business_Type_Code__c IN (\'Return\', \'ExchangeReturn\')';

        if(roliIdSet != null) {
            returnOrderQuery += ' AND Id IN :roliIdSet ';
//            // 주문 상태
//            returnOrderQuery += ' AND Consumables_Order_Status__c = \'121\'';
//
//            // 수거 여부
//            returnOrderQuery += ' AND COLLECTION_YN__c = true ';

        } else {
            // 주문 상태
            returnOrderQuery += ' AND Consumables_Order_Status__c = \'120\'';
            // 반품 확정일자
            returnOrderQuery += ' AND Return_Order_CONFIRM_DTM__c != NULL ';
            // 수거 여부
            //returnOrderQuery += ' AND COLLECTION_YN__c = true ';
        }
        returnOrderQuery += ' ORDER BY CreatedDate ASC';

        System.debug('returnOrderQuery => ' + returnOrderQuery);

        Set<String> originPrliIdSet = new Set<String>();
        Map<String, List<ReturnOrderLineItem>> prliIdReturnOrderListMap = new Map<String, List<ReturnOrderLineItem>>();
        List<ReturnOrderLineItem> confirmReturnOrderLineItems = Database.query(returnOrderQuery);




        try {

            List<ReturnOrderLineItem> bestShopRoliList = new List<ReturnOrderLineItem>();
            for (ReturnOrderLineItem roli : confirmReturnOrderLineItems) {
                System.debug('roli -> ' + roli);
                // 0. 반품 확정시 반품 확정 대상의 판매저장 처리가 안되어 있는 경우 Skip
                if(roli.ProductRequestLineItem.Parent.SR_SALE__c == null) continue;

                // 반품 확정 수량
                roli.Actual_Return_Quantity__c = roli.Expected_Return_Quantity__c;
                // 반품 확정 일시
                roli.Return_Order_CONFIRM_DTM__c = System.now();

                // 반품 수거여부
                roli.COLLECTION_YN__c = true;

                // 주문 상태
                roli.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_120;

                // 반품예정수량 초기화
                roli.Expected_Return_Quantity__c = 0;

                originPrliIdSet.add(roli.ProductRequestLineItemId);
                originPrliIdSet.add(roli.Exchange_Order_Item_Id__c);

                if (!prliIdReturnOrderListMap.containsKey(roli.ProductRequestLineItemId)) {
                    prliIdReturnOrderListMap.put(roli.ProductRequestLineItemId, new List<ReturnOrderLineItem>{
                            roli
                    });
                } else {
                    prliIdReturnOrderListMap.get(roli.ProductRequestLineItemId).add(roli);
                }

                if (!prliIdReturnOrderListMap.containsKey(roli.Exchange_Order_Item_Id__c)) {
                    prliIdReturnOrderListMap.put(roli.Exchange_Order_Item_Id__c, new List<ReturnOrderLineItem>{
                            roli
                    });
                } else {
                    prliIdReturnOrderListMap.get(roli.Exchange_Order_Item_Id__c).add(roli);
                }

                // 케어용품(베스트샵) 인 대상 추출
                if (roli.Order_CHNL_TYPE_Code__c == EX_ConsumableUtil.CONSUMABLE_BESTSHOP) {
                    bestShopRoliList.add(roli);
                }
            }

            // 케어용품 반품확정 처리 시
            List<SI_CAREPLUS_BACKIF__c> backIFList = new List<SI_CAREPLUS_BACKIF__c>();

            if(!bestShopRoliList.isEmpty()) {
//                AggregateResult[] maxNumberResults = [
//                        SELECT MAX(INTERFACE_ID__c) maxNumber
//                        FROM SI_CAREPLUS_BACKIF__c
//                ];
//                Decimal maxNum = 1;
//                for (AggregateResult ar : maxNumberResults) {
//                    if (ar.get('maxNumber') == null) {
//                        maxNum = 1;
//                    } else {
//                        maxNum = (Decimal) ar.get('maxNumber') + 1;
//                    }
//                }
                Decimal maxNum = 0;
                List<SI_CAREPLUS_BACKIF__c> getMaxList = new List<SI_CAREPLUS_BACKIF__c>();
                getMaxList = [SELECT INTERFACE_ID__c FROM SI_CAREPLUS_BACKIF__c ORDER BY INTERFACE_ID__c DESC LIMIT 1];
                if(!getMaxList.isEmpty()){
                    SI_CAREPLUS_BACKIF__c getMax = getMaxList[0];
                    if(getMax.INTERFACE_ID__c != null && getMax.INTERFACE_ID__c > 0){
                        maxNum = getMax.INTERFACE_ID__c + 1;
                    }
                }

                Decimal maxSubNum = 1;

                for (ReturnOrderLineItem bestShopRoli : bestShopRoliList) {
                    Map<String, Object> ifDataInfoMap = EX_ReturnOrderManagementController.setCarePlusBackIFData(bestShopRoli, maxNum, maxSubNum,'RETURNED');
                    SI_CAREPLUS_BACKIF__c backIF = (SI_CAREPLUS_BACKIF__c) ifDataInfoMap.get('backIF');
                    maxNum = (Decimal) ifDataInfoMap.get('maxNum');
                    maxSubNum = (Decimal) ifDataInfoMap.get('maxSubnum');
                    backIFList.add(backIF);
                }
            }
            try {
                if(!backIFList.isEmpty()) {
                    insert backIFList;
                    System.debug('backIFList insert 완료 : ' + backIFList.size());
                }

                update confirmReturnOrderLineItems;
                System.debug('confirmReturnOrderLineItems Update 완료 : ' + confirmReturnOrderLineItems.size());

            } catch (DmlException e) {
                infoMap.put('isSuccess', false);
                infoMap.put('error', e.getLineNumber() + 'line : ' + e.getMessage());
            }

        } catch (Exception e) {
            System.debug('[Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage());
        }



        infoMap.put('productRequestLineItemIdSet', originPrliIdSet);
        infoMap.put('prliIdReturnOrderListMap', prliIdReturnOrderListMap);

        infoMap.put('confirmReturnOrderLineItems', confirmReturnOrderLineItems);

        return infoMap;
    }

    /**
     * @description 2. 반품의 Source 주문 데이터(Product Request Line Item) Update 처리 / 반품 수량 Update
     * @return
     */
    public static Map<String, Object> doOriginDataUpdate(Map<String, Object> infoMap) {

        Map<String, List<ReturnOrderLineItem>> prliIdReturnOrderListMap = (Map<String, List<ReturnOrderLineItem>>) infoMap.get('prliIdReturnOrderListMap');
        List<ProductRequestLineItem> originPrliList = [
                SELECT Id, Consumables_Order_Status__c, Return_Order_Quantity__c, Consumables_Order_Detail__c
                fROM ProductRequestLineItem
                WHERE Id IN :prliIdReturnOrderListMap.keySet()
        ];

        for (ProductRequestLineItem prli : originPrliList) {
            Integer totalReturnQuantity = 0;
            if (prliIdReturnOrderListMap.containsKey(prli.Id)) {
                for (ReturnOrderLineItem roli : prliIdReturnOrderListMap.get(prli.Id)) {
                    totalReturnQuantity += roli.Actual_Return_Quantity__c.intValue();
                }
            }
            prli.Return_Order_Quantity__c = totalReturnQuantity;
            prli.Consumables_Order_Detail__c = '';
        }
        try {
            // todo : DML 처리 필요
            update originPrliList;
        } catch (Exception e) {
            infoMap.put('isSuccess', false);
            infoMap.put('error', e.getLineNumber() + 'line : ' + e.getMessage());
        }


        return infoMap;
    }

    /**
     * @description 3. 환불 처리(Only CIC) + 적자정보 생성
     * @return
     */
    public static Map<String, Object> doRefund(Map<String, Object> infoMap) {
        List<ReturnOrderLineItem> confirmReturnOrderLineItems = (List<ReturnOrderLineItem>) infoMap.get('confirmReturnOrderLineItems');
        if(!confirmReturnOrderLineItems.isEmpty()){
            List<String> roliIdList = new List<String>();
            for (ReturnOrderLineItem roli : confirmReturnOrderLineItems) {
                roliIdList.add(roli.Id);
            }
            if(!roliIdList.isEmpty()){
                EX_ConsumableUtil.doReturnConfirm(roliIdList);
            }
        }
        return infoMap;
    }

    /**
     * @description 4. 수불 처리(Product Transfer, ProductItem / Transaction)
     * @return
     */
    public static Map<String, Object> doApplyProductItem(Map<String, Object> infoMap) {
        List<Map<String, Object>> pListMapRequestInfo = new List<Map<String, Object>>();
        Map<String, Object> mapRequestInfo;
        Set<String> partIdSet = new Set<String>();
        Set<String> locationIdSet = new Set<String>();

        List<ProductTransfer> upsertPrTrList = new List<ProductTransfer>();
        Set<String> piKeySet = new Set<String>();

        List<ReturnOrderLineItem> confirmReturnOrderLineItems = (List<ReturnOrderLineItem>) infoMap.get('confirmReturnOrderLineItems');
        for (ReturnOrderLineItem roli : confirmReturnOrderLineItems) {

            System.debug('start====================');
            System.debug(roli.ProductRequestLineItem.Product2Id);
            System.debug(roli.Product2Id);
            System.debug('end====================');
            ProductTransfer upsertPrTr = new ProductTransfer();
            //upsertPrTr.RecordTypeId = Schema.SObjectType.ProductTransfer.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
            upsertPrTr.DestinationLocationId = roli.DestinationLocationId;

            upsertPrTr.Product2Id = roli.ProductRequestLineItem.Product2Id;

            // 수불 처리용
            String piKey = roli.DestinationLocationId + '^' + roli.ProductRequestLineItem.Product2Id;
            System.debug('piKey -> ' + piKey);

            piKeySet.add(piKey);

            // ProductRequestLineItem 저장시 ProductRequestId 확인
            upsertPrTr.ProductRequestLineItemId = roli.ProductRequestLineItemId;
            upsertPrTr.ReturnOrderLineItemId = roli.Id;
            upsertPrTr.SourceProductItemId = roli.ProductItemId;
            upsertPrTr.Product2Id = roli.ProductRequestLineItem.Product2Id;
            upsertPrTr.QuantitySent = roli.Actual_Return_Quantity__c;
            upsertPrTr.Status = '5';
            upsertPrTr.QuantityReceived = roli.Actual_Return_Quantity__c;
            upsertPrTr.IsReceived = true;

            upsertPrTrList.add(upsertPrTr);

            mapRequestInfo = new Map<String, Object>();

            mapRequestInfo.put('product2Id', upsertPrTr.Product2Id);
            mapRequestInfo.put('requestQTY', upsertPrTr.QuantitySent);
            mapRequestInfo.put('productTransfer', upsertPrTr);

            mapRequestInfo.put('sourceLocationId', upsertPrTr.SourceLocationId);
            mapRequestInfo.put('destinationLocationId', upsertPrTr.DestinationLocationId);
            mapRequestInfo.put('requestType', 'AH');

            mapRequestInfo.put('productRequestLineItem', null);
            mapRequestInfo.put('returnOrderLineItem', roli);
            mapRequestInfo.put('productTransfer', upsertPrTr);

            partIdSet.add(roli.product2Id);
            locationIdSet.add(roli.SourceLocationId);
            locationIdSet.add(roli.DestinationLocationId);

            pListMapRequestInfo.add(mapRequestInfo);
        }

        try {
            upsert upsertPrTrList;
        } catch (Exception e) {
            infoMap.put('isSuccess', false);
            infoMap.put('error', e.getLineNumber() + 'line : ' + e.getMessage());
        }

        Map<String, ProductItem> pMapProductItemByKey = new Map<String, ProductItem>();
        String stqProductItemQry = '';
        stqProductItemQry += 'SELECT ' + String.join(EX_SuppliesController.getAllFields('ProductItem'), ',');
        stqProductItemQry += '  FROM ProductItem';
        stqProductItemQry += ' WHERE Product2Id IN :partIdSet AND LocationId IN :locationIdSet';

        List<ProductItem> productItems = Database.query(stqProductItemQry);
        // Key :  {!sourceLocationId} + '^' + {!Product2Id}
        String strKeyPI = '';
        for (ProductItem productItem : productItems) {
            strKeyPI = productItem.LocationId + '^' + productItem.Product2Id;
            pMapProductItemByKey.put(strKeyPI, productItem);
        }

        try {
            infoMap.putAll(FS_MaterialUtil.applyProductItem(pListMapRequestInfo, pMapProductItemByKey));
        } catch (Exception e) {
            infoMap.put('isSuccess', false);
            infoMap.put('error', e.getLineNumber() + 'line : ' + e.getMessage());
        }

        return infoMap;
    }

    /**
    * @description 0. 반품 확정시 반품 확정 대상의 판매저장 처리가 안되어 있는 경우 Validation
    * @return
    */
    public static Map<String, Object> doCheckSaleNumber(Set<String> roliIdSet) {
        List<ReturnOrderLineItem> targetRoliList = [
                SELECT Id, ReturnOrderId, ProductRequestLineItem.Parent.SR_SALE__c, ProductRequestLineItem.Parent.Order_Number__c
                FROM ReturnOrderLineItem
                WHERE Id IN :roliIdSet
        ];

        String errMsg = null;

        Set<String> filteredRoliIdSet = new Set<String>();
        for (ReturnOrderLineItem roli : targetRoliList) {
            if(roli.ProductRequestLineItem.Parent.SR_SALE__c == null) {
                if(errMsg == null) {
                    errMsg = roli.ProductRequestLineItem.Parent.Order_Number__c;
                } else {
                    errMsg += ', '+ roli.ProductRequestLineItem.Parent.Order_Number__c;
                }
            } else {
                filteredRoliIdSet.add(roli.Id);
            }
        }
        Map<String, Object> infoMap = new Map<String, Object>();
        if(errMsg != null) {
            errMsg = '주문번호 ' + errMsg + ' 의 판매정보가 존재하지 않습니다.';
        }
        infoMap.put('errMsg', errMsg);
        infoMap.put('filteredRoliIdSet', filteredRoliIdSet);


        return infoMap;
    }
}