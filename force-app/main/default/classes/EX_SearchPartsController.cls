/**
 * Created by I2MAX.SEOKHOLEE on 2022-11-13.
 */

 public with sharing class EX_SearchPartsController {
    @AuraEnabled
    public static Map<String, Object> getInitData(String params) {
        System.debug('EX_SearchPartsController getInitData');
        System.debug('속도측정 -------------------------------------------------- EX_SearchPartsController.getInitData (start):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        Map<String, Object> mapResult = new Map<String, Object>();
        //23.12.14 seung yoon 출고부서 Location.Name으로 대체
        Map<String, String> shipMentName = new Map<String, String>();
        Map<String, Object> mapParams = (Map<String, Object>) JSON.deserializeUntyped(params);
        String partRecordId = String.valueOf(mapParams.get('partId'));
        String productCode = String.valueOf(mapParams.get('productCode'));
        String locationId = String.valueOf(mapParams.get('locationId'));
        String divCode = String.valueOf(mapParams.get('divCode'));

        Boolean isSBOM = false;
        if (mapParams.containsKey('isSBOM')) {
            isSBOM = Boolean.valueOf(mapParams.get('isSBOM'));
            System.debug('isSBOM -> ' + isSBOM);

        }

        String warehouseLocationId = EX_ConsumableUtil.getConsumableWareHouseId();
        // todo : 23.04.15 / 전시판매정보 I/F 적용을 위한 파트 정보 추출 / 원 부품 + 대치 부품 정보 조회
        List<Product2> obsSalesInfoTargetParts = new List<Product2>();
        // SBOM 에서 인입 시
        if (isSbom || (partRecordId != null && partRecordId != '')) {
            obsSalesInfoTargetParts = [
                    SELECT Id, PART_SPEC__c, ProductCode, Name, MODEL_CODE__c, CUST_PRICE__c, ASC_PRICE__c, TECH_GRADE_PROD_CODE__c, TECH_PART_YN__c, DIV_CODE__c, DisplayUrl, Description, PART_DESC_KOR__c,
                            Disabled_Type__c, PART_TYPE__c, THINQ_ITEM_YN__c, PARCEL_YN__c, lu_MODEL_CODE__c, OBS_DISPLAY_YN__c, (
                            SELECT Id, Name, toLabel(SUBSTITUTE_TYPE__c), SUBSTITUTE_PART_NO__c, PART_NO__r.lu_MODEL_CODE__c,
                                    SUBSTITUTE_PART_NO__r.ProductCode, SUBSTITUTE_PART_NO__r.DIV_CODE__c, SUBSTITUTE_PART_NO__r.Name
                            FROM SM_SUBSTITUTE_PART_Product_PART__r
                    )
                    FROM Product2
                    WHERE Id = :partRecordId AND IsActive = true
            ];
        } else {
            // 2023.09.18 seung yoon heo WHERE절 ProductCode => Name으로 변경
            obsSalesInfoTargetParts = [
                    SELECT Id, PART_SPEC__c, ProductCode, Name, MODEL_CODE__c, CUST_PRICE__c, ASC_PRICE__c, TECH_GRADE_PROD_CODE__c, TECH_PART_YN__c, DIV_CODE__c, DisplayUrl, Description, PART_DESC_KOR__c,
                            Disabled_Type__c, PART_TYPE__c
                            , THINQ_ITEM_YN__c, PARCEL_YN__c, lu_MODEL_CODE__c, OBS_DISPLAY_YN__c, (

                            SELECT Id, Name, toLabel(SUBSTITUTE_TYPE__c), SUBSTITUTE_PART_NO__c, PART_NO__r.lu_MODEL_CODE__c,
                                    SUBSTITUTE_PART_NO__r.ProductCode, SUBSTITUTE_PART_NO__r.DIV_CODE__c, SUBSTITUTE_PART_NO__r.Name
                            FROM SM_SUBSTITUTE_PART_Product_PART__r
                    )
                    FROM Product2
                    WHERE Name = :productCode AND IsActive = true
            ];
        }

        // Product Code 로 검색 시
        if(!isSBOM) {
            if (obsSalesInfoTargetParts.isEmpty()) {
                throw new AuraHandledException('잘못 입력하였습니다. 부품번호 ' + productCode + ' 는 존재하지 않습니다.');
            }
        }

        Set<String> divCodePartNoKeySet = new Set<String>();
        Set<String> obsDivCodePartNoKeySet = new Set<String>();
        for (Product2 prod : obsSalesInfoTargetParts) {
            // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
            // String divCodePartNokey = prod.DIV_CODE__c + '_' + prod.ProductCode;
            String divCodePartNokey = prod.DIV_CODE__c + '_' + prod.Name;
            divCodePartNoKeySet.add(divCodePartNokey);
            for (SM_SUBSTITUTE_PART__c subPart : prod.SM_SUBSTITUTE_PART_Product_PART__r) {
                // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                // divCodePartNokey = subPart.SUBSTITUTE_PART_NO__r.DIV_CODE__c + '_' + subPart.SUBSTITUTE_PART_NO__r.ProductCode;
                divCodePartNokey = subPart.SUBSTITUTE_PART_NO__r.DIV_CODE__c + '_' + subPart.SUBSTITUTE_PART_NO__r.Name;
                divCodePartNoKeySet.add(divCodePartNokey);
            }

            //if (prod.THINQ_ITEM_YN__c == 'Y') {
            System.debug('divCodePartNokey -> ' + divCodePartNokey);
                // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                // divCodePartNokey = prod.DIV_CODE__c + '_' + prod.ProductCode;
                divCodePartNokey = prod.DIV_CODE__c + '_' + prod.Name;
                obsDivCodePartNoKeySet.add(divCodePartNokey);
                for (SM_SUBSTITUTE_PART__c subPart : prod.SM_SUBSTITUTE_PART_Product_PART__r) {
                    // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                    // divCodePartNokey = subPart.SUBSTITUTE_PART_NO__r.DIV_CODE__c + '_' + subPart.SUBSTITUTE_PART_NO__r.ProductCode;
                    divCodePartNokey = subPart.SUBSTITUTE_PART_NO__r.DIV_CODE__c + '_' + subPart.SUBSTITUTE_PART_NO__r.Name;
                    obsDivCodePartNoKeySet.add(divCodePartNokey);
                }
            //}

        }

        // 재고 생성을 위한 로직

        Map<String, Product2> exKeyMap = new Map<String, Product2>();
        Map<String, Schema.Location> divLocationMap = new Map<String, Schema.Location>();
        Map<String, Schema.Location> locationIdMap = new Map<String, Schema.Location>();

        //24 02 05 hyungho.chun 
        List<SM_DIV__c> activeDIVList = [SELECT Id, DIV_CODE__c FROM SM_DIV__c];
        List<String> divList = new List<String>();
        for(SM_DIV__c item : activeDIVList){
            divList.add(item.DIV_CODE__c);
        }

        for (Schema.Location lo : [SELECT Id, DIV_CODE__c FROM Location WHERE RecordType.DeveloperName = 'DIV']) {
            divLocationMap.put(lo.DIV_CODE__c, lo);
            locationIdMap.put(lo.Id, lo);
        }
        Set<String> productCodeSet = new Set<String>();
        Set<String> divCodeSet = new Set<String>();
        Map<String, Product2> partMasterMap = new Map<String, Product2>();

        for (Product2 prod2 : obsSalesInfoTargetParts) {
            productCodeSet.add(prod2.Name);
            divCodeSet.add(prod2.DIV_CODE__c);

            if (prod2.DIV_CODE__c != null && prod2.Name != null) {
                String productExternalKey = prod2.DIV_CODE__c + '_' + prod2.Name;
                partMasterMap.put(productExternalKey, prod2);
            }

            String custExternalKey = prod2.DIV_CODE__c + '_' + prod2.Name + '_' + warehouseLocationId;
            //24 02 05 hyungho.chun product가 소모품인경우에만 적치장소 pi 생성
            if(prod2.PART_TYPE__c =='D' && divList.contains(prod2.DIV_CODE__c)){
                exKeyMap.put(custExternalKey, prod2);
            }
            // exKeyMap.put(custExternalKey, prod2);

            
            // if(divLocationMap.containsKey(prod2.DIV_CODE__c)) {
            if(divLocationMap.containsKey(prod2.DIV_CODE__c) && divList.contains(prod2.DIV_CODE__c)) { //24 02 05 hyungho.chun  active인 사업부꺼만 보이게 로직 강화
                //24.02.07 gw.lee
                //사업부 재고 중 ProductItem.DIV_CODE__c와 Location.DIV_CODE__c 상이한 케이스 발생으로 방어로직 추가
                if (divLocationMap.get(prod2.DIV_CODE__c).DIV_CODE__c == prod2.DIV_CODE__c) {
                    custExternalKey = prod2.DIV_CODE__c + '_' + prod2.Name + '_' + divLocationMap.get(prod2.DIV_CODE__c).Id;
                    exKeyMap.put(custExternalKey, prod2);
                }
            }
        }

        Boolean isValidPart = false;
        System.debug('obsDivCodePartNoKeySet -> ' + obsDivCodePartNoKeySet.isEmpty());
        System.debug(obsDivCodePartNoKeySet);
        if (!obsDivCodePartNoKeySet.isEmpty()) {
            isValidPart = true;
        }

        Map<String, Map<String, Object>> obsSalesInfoMap = new Map<String, Map<String, Object>>();
        if (isValidPart) {
            //List<Map<String, String>> obsSalesInfoList = !Test.isRunningTest() ? IF_MACN_OBS_SFDC_0120.getObsSalesInfoList(obsDivCodePartNoKeySet) : new List<Map<String, String>>();
            System.debug('속도측정 -------------------------------------------------- EX_SearchPartsController.getInitData  IF_MACN_OBS_SFDC_0120 (start):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            List<Map<String, String>> obsSalesInfoList = IF_MACN_OBS_SFDC_0120.getObsSalesInfoList(obsDivCodePartNoKeySet);
            System.debug('속도측정 -------------------------------------------------- EX_SearchPartsController.getInitData  IF_MACN_OBS_SFDC_0120 (End):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            for (Map<String, String> obsSalesInfo : obsSalesInfoList) {
                String divCd = obsSalesInfo.get('divCode');
                String partNo = obsSalesInfo.get('partNo');
                // 사업부코드 + '_' + 파트넘버
                String divPartNoKey = divCd + '_' + partNo;
                obsSalesInfoMap.put(divPartNoKey, obsSalesInfo);
            }
            System.debug('==== obsSalesInfoMap ===');
            System.debug(obsSalesInfoMap);
            System.debug('========================');
        }

        // 재고 조회
        // 소모품 적치장소 + 사업부
        // 2023.09.18 seung yoon heo WHERE절 ProductCode => Name으로 변경 // 12.14 Location.Name 추가
        Map<String, ProductItem> productItemMap = new Map<String, ProductItem>([
                SELECT Id, QuantityOnHand, fm_Available_Quantity__c, fm_Computerized_Quantity__c, RESRV_QTY__c,
                        LocationId, Location.DEPT_CODE__c, Location.LocationType, Location.DIV_CODE__c,
                        ProductName, DIV_CODE__c, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, Product2.Name,
                        Location.RecordType.DeveloperName, Location.Name 
                FROM ProductItem
                WHERE Product2.Name IN :productCodeSet
                // AND Product2.PART_TYPE__c = 'D' //24 02 08 hyungho.chun 이미있는쿼리조회할때 part_Type이 'D'인건 적치장소인거만조회
                AND ((Location.DEPT_CODE__c = :EX_ConsumableUtil.PH8002 AND Location.LocationType = 'Warehouse' AND Location.Name = :System.Label.EX_Location AND Product2.PART_TYPE__c = 'D')
                OR (Location.RecordType.DeveloperName = 'DIV' AND Location.DIV_CODE__c IN :divCodeSet))
        ]);


        System.debug('productItemMap -> ' + productItemMap);

        Map<String, ProductItem> piMap = new Map<String, ProductItem>();
        for (ProductItem pi : productItemMap.values()) {
            String piKey = pi.Product2.DIV_CODE__c + '_' + pi.Product2.Name + '_' + pi.LocationId;
            piMap.put(piKey, pi);
        }

        System.debug(':::::::::::::::::::::::::::::::::::::::::');
        System.debug('piMap -> ' + piMap);
        System.debug('exKeyMap -> ' + exKeyMap);
        System.debug(':::::::::::::::::::::::::::::::::::::::::');
        Set<String> insertTarget = new Set<String>();
        for (String exKey : exKeyMap.keySet()) {
            System.debug(exKey + ' contains ? ' + piMap.containsKey(exKey));
            if(!piMap.containsKey(exKey)) {
                insertTarget.add(exKey);
            }
        }

        Map<String, ProductItem> insertProductItemMap = new Map<String, ProductItem>();
        ProductItem newPi;
        for (String key : insertTarget) {
            List<String> splitKeyList = key.split('_');

            String custExternalKey = splitKeyList[0] + '_' + splitKeyList[1];
            newPi = new ProductItem();
            // 조직코드_사업부코드_파트넘버_적치장소이름
            // PH0006_CNZ_AGF30366710_04U03A
            newPi.LocationId = splitKeyList[2];
            newPi.Product2Id = partMasterMap.get(custExternalKey).Id;

            //23 12 20 hyungho.chun productItem 생성시 DivCode찾아넣기
            newPi.DIV_CODE__c = partMasterMap.get(custExternalKey).DIV_CODE__c != null ? partMasterMap.get(custExternalKey).DIV_CODE__c : null;            

            newPi.QuantityOnHand = 0;

            insertProductItemMap.put(custExternalKey, newPi);
        }

        System.debug('insertProductItemMap => ' + insertProductItemMap);
        try {
            if(!Test.isRunningTest()) insert insertProductItemMap.values();
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        // 23.04.28 / 프로모션 조회
        Map<String, EX_Promotion__c> promotionInfoMap = EX_SearchPartsController.getPromotionInformation(divCodePartNoKeySet);


        Integer total = 0;
        // 소모품 적치장소 의 재고수량
        Integer EXQuantity = 0 ;
        // 사업부의 재고수량
        Integer DIVQuantity = 0;

        System.debug(' partRecordId -> ' + partRecordId);
        System.debug(' divCode -> ' + divCode);
        System.debug(' productCode -> ' + productCode);

        List<ProductItem> quantityList = new List<ProductItem>();

        if (isSbom || (partRecordId != null && partRecordId != '')) {
            quantityList = [
                    SELECT LocationId, fm_Available_Quantity__c, Location.Name, Location.ParentLocationId__r.DIV_CODE__c,
                            Location.ParentLocationId__r.DEPT_CODE__c, DIV_CODE__c, Location.DIV_CODE__c, QuantityOnHand, ORDER_QTY__c,
                            Product2.ProductCode, Product2.DIV_CODE__c , Product2.Name, Location.RecordType.DeveloperName  
                    FROM ProductItem
                    WHERE Product2Id = :partRecordId AND
                        (Location.RecordType.DeveloperName = 'DIV' OR Location.Name IN (:System.Label.EX_Location, '소모품센터'))
                        
            ];
        } else {
            // 2023.09.18 seung yoon heo WHERE절 ProductCode => Name으로 변경
            quantityList = [
                    SELECT LocationId, fm_Available_Quantity__c, Location.Name, Location.ParentLocationId__r.DIV_CODE__c,
                            Location.ParentLocationId__r.DEPT_CODE__c, DIV_CODE__c, Location.DIV_CODE__c, QuantityOnHand, ORDER_QTY__c,
                            Product2.Name, Product2.DIV_CODE__c, Location.RecordType.DeveloperName 
                    FROM ProductItem
                    WHERE Product2.Name = :productCode AND
                        (Location.RecordType.DeveloperName = 'DIV' OR Location.Name IN (:System.Label.EX_Location, '소모품센터'))
            ];
        }

        // 다건 조회 시(Product Code 가 동일하지만 DIV Code 가 다른 경우)
        Map<String, Map<String, Decimal>> locationDivCodePartNoQtyMap = new Map<String, Map<String, Decimal>>();
        Map<String, Decimal> qtyMap;
        String locationIdDivPartNoKey = '';
        for (ProductItem item : quantityList) {
            System.debug('item :::: ' + item);
            System.debug('item.Location.DIV_CODE__c :::: ' + item.Location.DIV_CODE__c);
            // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
            // locationIdDivPartNoKey = item.LocationId + '_' + item.Product2.DIV_CODE__c + '_' + item.Product2.ProductCode;
            locationIdDivPartNoKey = item.LocationId + '_' + item.Product2.DIV_CODE__c + '_' + item.Product2.Name;

            if (locationDivCodePartNoQtyMap.containsKey(locationIdDivPartNoKey)) {
                qtyMap = locationDivCodePartNoQtyMap.get(locationIdDivPartNoKey);
            } else {
                qtyMap = new Map<String, Decimal>();
            }

            if (item.fm_Available_Quantity__c > 0) {
                if (item.Location.ParentLocationId__r.DEPT_CODE__c == 'PH8002') {
                    EXQuantity = Integer.valueOf(item.fm_Available_Quantity__c);
                    if (qtyMap.containsKey('PH8002')) {
                        System.debug('qtyMap.contains 8002');
                    } else {
                        qtyMap.put('PH8002', EXQuantity);
                    }

                //gw.lee 23.09.21
                //사업부재고 수정
                //} else if (item.Location.DIV_CODE__c == divCode) {
                } else if (item.Location.RecordType.DeveloperName == 'DIV') {
                    System.debug('item.Location.DIV_CODE__c :::: ' + item.Location.DIV_CODE__c);
                    System.debug('divCode :::: ' + divCode);
                    System.debug('qtyMap :::: ' +   qtyMap);
                    if (item.QuantityOnHand == null) item.QuantityOnHand = 0;
                    if (item.ORDER_QTY__c == null) item.ORDER_QTY__c = 0;

                    DIVQuantity = (Integer.valueOf(item.QuantityOnHand) - Integer.valueOf(item.ORDER_QTY__c) < 0) ? 0 : Integer.valueOf(item.QuantityOnHand) - Integer.valueOf(item.ORDER_QTY__c);
                    //DIVQuantity = Integer.valueOf(item.fm_Available_Quantity__c);

                    if (qtyMap.containsKey('DIV')) {
                        System.debug('qtyMap.contains DIV');
                    } else {
                        qtyMap.put('DIV', DIVQuantity);
                    }
                } else if (item.Location.ParentLocationId__r.DEPT_CODE__c == 'PH0300') {
                    System.debug('DEPT_CODE__c PH0300');
                } else {
                    total += Integer.valueOf(item.fm_Available_Quantity__c);
                    if (qtyMap.containsKey('Total')) {
                        System.debug('qtyMap.contains Total');
                    } else {
                        qtyMap.put('Total', total);
                    }
                }
            }
            locationDivCodePartNoQtyMap.put(locationIdDivPartNoKey, qtyMap);
        }

        System.debug('::::::::::::::::::::::::::::::::::::::::');
        System.debug(locationDivCodePartNoQtyMap);
        System.debug(JSON.serializePretty(locationDivCodePartNoQtyMap));
        System.debug('::::::::::::::::::::::::::::::::::::::::');

        System.debug(' EXQuantity -> ' + EXQuantity);
        System.debug(' DIVQuantity -> ' + DIVQuantity);


        // 지점 총 재고
        List<AggregateResult> centerTotalSums = new List<AggregateResult>();
        if (isSbom || (partRecordId != null && partRecordId != '')) {
            centerTotalSums = [
                    SELECT SUM(fm_Available_Quantity__c) centerTotalSum
                    FROM ProductItem
                    WHERE Product2Id = :partRecordId
                    AND Location.RecordType.DeveloperName != 'DIV'
                    AND Location.ParentLocationId__r.SM_DEPT_Id__r.DEPT_CODE__c != 'PH8002'
                    AND Location.ParentLocationId__r.SM_DEPT_Id__r.DEPT_CODE__c != 'PH0300'
            ];
        } else {
            // 2023.09.18 seung yoon heo WHERE조건절 ProductCode => Name으로 변경
            centerTotalSums = [
                    SELECT SUM(fm_Available_Quantity__c) centerTotalSum
                    FROM ProductItem
                    WHERE Product2.Name = :productCode
                    AND Location.RecordType.DeveloperName != 'DIV'
                    AND Location.ParentLocationId__r.SM_DEPT_Id__r.DEPT_CODE__c != 'PH8002'
                    AND Location.ParentLocationId__r.SM_DEPT_Id__r.DEPT_CODE__c != 'PH0300'
            ];
        }

        System.debug(centerTotalSums[0].get('centerTotalSum'));

        Decimal centerTotalSum = 0;
        if (centerTotalSums[0].get('centerTotalSum') != null) {
            centerTotalSum = Decimal.valueOf(String.valueOf(centerTotalSums[0].get('centerTotalSum')));
        }

        // 소모폼의 재고 조회시 listProd 가 존재하지 않는 경우

        // 최초 재고 ProductItem 이 없는 경우 재고 생성
        Boolean productItemIsAllEmpty = false;
        // 사업부 재고
        Boolean hasProductItemDIV = false;
        // 소모품센터 재고
        Boolean hasProductItemConsumables = false;

        Boolean isConsumablePart = false;
        List<Product2> partProductItems = new List<Product2>();
        if (isSBOM || (partRecordId != null && partRecordId != '')) {
            //23 12 23 index용 필드 where절에 추가 product id를 sub query안에도 넣어줌
            partProductItems = new List<Product2>([
                    SELECT Id, PART_TYPE__c, DIV_CODE__c, (
                            SELECT Id, LocationId, Location.RecordType.DeveloperName, Location.LocationType, Location.Name, Location.ParentLocationId__r.SM_DEPT_Id__r.DEPT_CODE__c
                            FROM ProductItems
                            WHERE (
                                    
                                    Product2Id = :partRecordId 
                                    AND ((Location.ParentLocationId__r.SM_DEPT_Id__r.DEPT_CODE__c = 'PH8002'
                                    AND Location.LocationType = 'Warehouse'
                                    AND Location.Name = :System.Label.EX_Location)
                                    OR Location.RecordType.DeveloperName = 'DIV')
                            )
                    )
                    FROM Product2
                    WHERE Id = :partRecordId
                    // AND PART_TYPE__c = 'D' //23 12 27 hyungho.chun 소모품 아닌것도 내린다
            ]);
        } else {
            // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
            //23 12 23 index용 필드 where절에 추가 product name을 sub query안에도 넣어줌
            partProductItems = new List<Product2>([
                    SELECT Id, PART_TYPE__c, DIV_CODE__c, (
                            SELECT Id, LocationId, Location.RecordType.DeveloperName, Location.LocationType, Location.Name, Location.ParentLocationId__r.SM_DEPT_Id__r.DEPT_CODE__c
                            FROM ProductItems
                            WHERE (
                                    
                                    Product2.Name = :productCode 
                                    AND ((Location.ParentLocationId__r.SM_DEPT_Id__r.DEPT_CODE__c = 'PH8002'
                                    AND Location.LocationType = 'Warehouse'
                                    AND Location.Name = :System.Label.EX_Location)
                                    OR Location.RecordType.DeveloperName = 'DIV')
                            )
                    )
                    FROM Product2
                    WHERE Name = :productCode
                    // AND PART_TYPE__c = 'D' //23 12 27 hyungho.chun 소모품 아닌것도 내린다
            ]);
        }
        //23 12 20 hyungho.chun 사업부 productItem에 divCode넣어주는용도
        String divCodeTemp = null;

        System.debug('partProductItems => ' + partProductItems);
        if (partProductItems.isEmpty()) {
            productItemIsAllEmpty = true;
        } else {
            for (Product2 product2 : partProductItems) {
                if (product2.PART_TYPE__c == 'D') {
                    isConsumablePart = true;
                    divCodeTemp = product2.DIV_CODE__c != null ? product2.DIV_CODE__c : null;
                    if (product2.productItems.isEmpty()) {
                        productItemIsAllEmpty = true;
                    } else {
                        for (ProductItem pi : product2.productItems) {
                            if (pi.Location.RecordType.DeveloperName == 'DIV') {
                                hasProductItemDIV = true;
                            } else if (pi.Location.LocationType == 'Warehouse' && pi.Location.ParentLocationId__r.SM_DEPT_Id__r.DEPT_CODE__c == 'PH8002' && pi.Location.Name == System.Label.EX_Location) {
                                hasProductItemConsumables = true;
                            }
                        }
                    }
                }
            }
        }
        System.debug('productItemIsAllEmpty -> ' + productItemIsAllEmpty);
        System.debug('hasProductItemDIV -> ' + hasProductItemDIV);
        System.debug('hasProductItemConsumables -> ' + hasProductItemConsumables);


        String divLocationId = null;
        if (divCode != null && divCode != '') {
            divLocationId = [SELECT Id FROM Location WHERE RecordType.DeveloperName = 'DIV' AND SM_DIV_Id__r.DIV_CODE__c = :divCode LIMIT 1].Id;
        }

        // 조직코드_사업부코드_파트넘버_적치장소이름
        // PH0006_CNZ_AGF30366710_04U03A
        Map<String, ProductItem> upsertPiMap = new Map<String, ProductItem>();
        List<ProductItem> upsertPiList = new List<ProductItem>();
        ProductItem consumableWarehousePi;
        ProductItem divPi;

        System.debug('warehouseLocationId -> ' + warehouseLocationId);
        System.debug('divLocationId -> ' + divLocationId);

        if (partRecordId != null && partRecordId != '') {
            //23 12 20 hyungho.chun partRecordId로 해당 DIV_CODE__c 쿼리
            Product2 productTemp = [SELECT Id, DIV_CODE__c FROM Product2 WHERE Id =: partRecordId LIMIT 1];
            divCodeTemp = productTemp.DIV_CODE__c != null ? productTemp.DIV_CODE__c : null;
            if (isConsumablePart) {
                if (productItemIsAllEmpty == true) {
                    consumableWarehousePi = new ProductItem();
                    consumableWarehousePi.LocationId = warehouseLocationId;
                    consumableWarehousePi.Product2Id = partRecordId;
                    //23 12 20 hyungho.chun pi divCodeTemp
                    consumableWarehousePi.DIV_CODE__c = divCodeTemp;
                    consumableWarehousePi.QuantityOnHand = 0;
                    upsertPiList.add(consumableWarehousePi);

                    if (divLocationId != null) {
                        divPi = new ProductItem();
                        divPi.LocationId = divLocationId;
                        divPi.Product2Id = partRecordId;
                        //23 12 20 hyungho.chun pi divCodeTemp
                        divPi.DIV_CODE__c = divCodeTemp;
                        divPi.QuantityOnHand = 0;
                        upsertPiList.add(divPi);
                    }
                } else if (hasProductItemDIV == false) {
                    if (divLocationId != null) {
                        divPi = new ProductItem();
                        divPi.LocationId = divLocationId;
                        divPi.Product2Id = partRecordId;
                        //23 12 20 hyungho.chun pi divCodeTemp
                        divPi.DIV_CODE__c = divCodeTemp;
                        divPi.QuantityOnHand = 0;
                        upsertPiList.add(divPi);
                    }
                } else if (hasProductItemConsumables == false) {
                    consumableWarehousePi = new ProductItem();
                    consumableWarehousePi.LocationId = warehouseLocationId;
                    consumableWarehousePi.Product2Id = partRecordId;
                    //23 12 20 hyungho.chun pi divCodeTemp
                    consumableWarehousePi.DIV_CODE__c = divCodeTemp;
                    consumableWarehousePi.QuantityOnHand = 0;
                    upsertPiList.add(consumableWarehousePi);
                }
            }
        }
        System.debug(upsertPiList);
        if (!Test.isRunningTest() && !upsertPiList.isEmpty()) insert upsertPiList;


        List<Product2> listProd = new List<Product2>();
        if (isSBOM || (partRecordId != null && partRecordId != '')) {
            listProd = new List<Product2>([
                    SELECT Id, PART_SPEC__c, ProductCode, Name, MODEL_CODE__c, CUST_PRICE__c, ASC_PRICE__c, TECH_GRADE_PROD_CODE__c, TECH_PART_YN__c, DIV_CODE__c, DisplayUrl, Description, PART_DESC_KOR__c,
                            Disabled_Type__c, PART_TYPE__c, DISABLED_REL_DT__c, THINQ_ITEM_YN__c, PARCEL_YN__c, lu_MODEL_CODE__c, PART_DESC__c, (
                            SELECT Id, LocationId, Location.Name, Location.RecordTypeId, Location.RecordType.DeveloperName, Location.LocationType,
                                    fm_Available_Quantity__c, ProductName, QuantityOnHand, ORDER_QTY__c,
                                    DIV_CODE__c, Product2Id, fm_Computerized_Quantity__c, RESRV_QTY__c, ALLOC_QTY__c, Location.DIV_CODE__c
                                    , Product2.Name
                                    , Product2.ProductCode
                                    , Product2.PART_SPEC__c
                                    , Product2.MODEL_CODE__c
                                    , Product2.CUST_PRICE__c
                                    , Product2.ASC_PRICE__c
                                    , Product2.TECH_GRADE_PROD_CODE__c
                                    , Product2.TECH_PART_YN__c
                                    , Product2.DisplayUrl
                                    , Product2.Description
                                    , Product2.PART_DESC_KOR__c
                                    , Product2.DISABLED_TYPE__c
                                    , Product2.PART_TYPE__c
                                    , Product2.THINQ_ITEM_YN__c
                                    , Product2.DISABLED_REL_DT__c
                                    , Product2.PARCEL_YN__c
                                    , Product2.lu_MODEL_CODE__c
                                    , Product2.PART_DESC__c

                            FROM ProductItems
                            WHERE (
                                    Product2Id = :partRecordId 
                                    AND ((Location.ParentLocationId__r.SM_DEPT_Id__r.DEPT_CODE__c = 'PH8002'
                                    AND Location.LocationType = 'Warehouse'
                                    AND Location.Name = :System.Label.EX_Location)
                                    OR Location.RecordType.DeveloperName = 'DIV')
                            )
                            // OR (//24 01 12 hyungho.chun part_Type D던아니던 똑같이 조회
                            //         Product2.PART_TYPE__c != 'D' AND Product2Id = :partRecordId 
                            //         AND Location.RecordType.DeveloperName = 'DIV' 
                            //         AND (Location.LocationType = 'Warehouse' OR Location.LocationType = 'Site')

                            // )
                    ), (
                            SELECT Id, Name, SUBSTITUTE_PART_NO__c, PART_NO__r.lu_MODEL_CODE__c, SUBSTITUTE_TYPE__c
                            FROM SM_SUBSTITUTE_PART_Product_PART__r WHERE PART_NO__c = :partRecordId OR SUBSTITUTE_PART_NO__c = :partRecordId 
                    )
                    FROM Product2
                    WHERE Id = :partRecordId
                    ORDER BY PART_TYPE__c DESC
            ]);
        } else {
            // 2023.09.18 seung yoon heo WHERE절 ProductCode => Name으로 변경
            listProd = new List<Product2>([
                    SELECT Id, PART_SPEC__c, ProductCode, Name, MODEL_CODE__c, CUST_PRICE__c, ASC_PRICE__c, TECH_GRADE_PROD_CODE__c, TECH_PART_YN__c, DIV_CODE__c, DisplayUrl, Description, PART_DESC_KOR__c,
                            Disabled_Type__c, PART_TYPE__c, DISABLED_REL_DT__c, THINQ_ITEM_YN__c, PARCEL_YN__c, lu_MODEL_CODE__c, PART_DESC__c, (
                            SELECT Id, LocationId, Location.Name, Location.RecordTypeId, Location.RecordType.DeveloperName, Location.LocationType,
                                    fm_Available_Quantity__c, ProductName, QuantityOnHand, ORDER_QTY__c,
                                    DIV_CODE__c, Product2Id, fm_Computerized_Quantity__c, RESRV_QTY__c, ALLOC_QTY__c, Location.DIV_CODE__c
                                    , Product2.Name
                                    , Product2.ProductCode
                                    , Product2.PART_SPEC__c
                                    , Product2.MODEL_CODE__c
                                    , Product2.CUST_PRICE__c
                                    , Product2.ASC_PRICE__c
                                    , Product2.TECH_GRADE_PROD_CODE__c
                                    , Product2.TECH_PART_YN__c
                                    , Product2.DisplayUrl
                                    , Product2.Description
                                    , Product2.PART_DESC_KOR__c
                                    , Product2.DISABLED_TYPE__c
                                    , Product2.PART_TYPE__c
                                    , Product2.THINQ_ITEM_YN__c
                                    , Product2.DISABLED_REL_DT__c
                                    , Product2.PARCEL_YN__c
                                    , Product2.lu_MODEL_CODE__c
                                    , Product2.PART_DESC__c

                            FROM ProductItems
                            WHERE (
                                    Product2.Name = :productCode 
                                    AND ((Location.ParentLocationId__r.SM_DEPT_Id__r.DEPT_CODE__c = 'PH8002'
                                    AND Location.LocationType = 'Warehouse'
                                    AND Location.Name = :System.Label.EX_Location)
                                    OR Location.RecordType.DeveloperName = 'DIV')
                            )
                            // OR (//24 01 12 hyungho.chun part_Type D던아니던 똑같이 조회
                            //         Product2.PART_TYPE__c != 'D' AND Product2.Name = :productCode 
                            //         AND Location.RecordType.DeveloperName = 'DIV' 
                            //         AND (Location.LocationType = 'Warehouse' OR Location.LocationType = 'Site')

                            // )
                    ), (
                            SELECT Id, Name, SUBSTITUTE_PART_NO__c, PART_NO__r.lu_MODEL_CODE__c, SUBSTITUTE_TYPE__c
                            FROM SM_SUBSTITUTE_PART_Product_PART__r WHERE PART_NO__r.Name = :productCode OR SUBSTITUTE_PART_NO__r.Name = :productCode 
                    )
                    FROM Product2
                    WHERE Name = :productCode
                    ORDER BY PART_TYPE__c DESC
            ]);
        }
        System.debug('isSBOM -> ' + isSBOM);

        System.debug('productCode >> ' + productCode);
        System.debug('listProd.size >> ' + listProd.size());


        List<ProductItem> listPI = new List<ProductItem>();
        List<SM_SUBSTITUTE_PART__c> listSub = new List<SM_SUBSTITUTE_PART__c>();
        Set<Id> setSubIds = new Set<Id>();
        Map<String, String> mapSubstituteTypeById = new Map<String, String>();

        //23.11.23 gw.lee
        //사업부 재고 관리
        Map<String, Integer> divQuantityMap = new Map<String, Integer>();

        List<EX_SuppliesController.ItemTable> listResult = new List<EX_SuppliesController.ItemTable>();
        for (Product2 obj : listProd) {
            //원부품
            divCode = obj.DIV_CODE__c;

            // 소모품 인경우
            if (obj.PART_TYPE__c == 'D') {
                // 23.04.15 / OBS 전시판매정보 데이터 받아온 이후 세팅.
                // ObsImageUrl : OBS 이미지 URL
                // ObsSalesURL : OBS 판매 전시 URL
                // PartNameKor : 한글 품명
                // ObsMemberPrice : OBS 회원가

                if (!obj.ProductItems.isEmpty()) {
                    listPI = obj.ProductItems;
                    String productName = obj.PART_TYPE__c;
                    String disabledType = 'N';
                    String partType = 'N';
                    String thinQItem = 'N';
                    String parcelYN = 'N';
                    String model = '';
                    String modelId = null;
                    String consumableWarehouseId = '';
                    String consumableProductItemId = '';


                    // 소모품 전산수량 : 소모품 적치장소의 전산수량(fm_Computerized_Quantity__c + 사업부 보유량(QuantityOnHand)
                    // 소모품 가용수량 : 소모품 적치장소의 가용수량 + (사업부 보유량 - 사업부 주문수량)
                    Decimal totalQty = 0;
                    Decimal allocQty = 0;
                    Decimal totalComputerizedQty = 0 ;
                    Integer divQty = 0;
                    for (ProductItem objPI : listPI) {

                        System.debug('objPI.LocationId');
                        System.debug(objPI);
                        System.debug(objPI.LocationId);
                        // 사업부 재고인 경우
                        if (objPI.Location.RecordType.DeveloperName == 'DIV') {
                            //24 01 16 hyungho.chun 단종이 아닌 경우에만 사업부 수량을 조회한다
                            // (사업부 보유량 - 사업부 주문수량)
                            if (obj.DISABLED_TYPE__c == null){
                                if (objPI.ORDER_QTY__c == null) objPI.ORDER_QTY__c = 0;
                                // 0보다 작은 경우 0 처리
                                totalQty += (objPI.QuantityOnHand - objPI.ORDER_QTY__c < 0) ? 0 : objPI.QuantityOnHand - objPI.ORDER_QTY__c;
                                totalComputerizedQty += objPI.QuantityOnHand;
    
                                divQty += (objPI.QuantityOnHand - objPI.ORDER_QTY__c < 0) ? 0 : Integer.valueOf(objPI.QuantityOnHand - objPI.ORDER_QTY__c);
    
                                divQuantityMap = getDivQuantityMap(divQuantityMap, objPI.DIV_CODE__c, divQty);                                
                            }

                        } else {
                            // PH8002 재고 인 경우
                            consumableWarehouseId = objPI.LocationId;
                            consumableProductItemId = objPi.Id;

                            // 가용수량
                            totalQty += objPI.fm_Available_Quantity__c;
                            // 할당수량
                            allocQty = objPI.ALLOC_QTY__c;
                            // 전산수량
                            totalComputerizedQty += objPI.fm_Computerized_Quantity__c;
                        }

                        //23.12.14 seung yoon heo 출고부서
                        if (objPI.Location.DIV_CODE__c != null) {
                            shipMentName.put(objPI.Location.DIV_CODE__c, objPI.Location.Name);
                        }
                    }

                    if (obj.PART_DESC_KOR__c != NULL) {
                        productName = obj.PART_DESC_KOR__c + '(' + obj.PART_DESC__c + ')';
                    } else {
                        productName = obj.PART_DESC__c;
                    }
                    if (obj.DISABLED_TYPE__c != null) {
                        disabledType = 'Y';
                    }
                    if (obj.PART_TYPE__c == 'D') {
                        partType = 'Y';
                    }

                    if (obj.PARCEL_YN__c == 'Y') {
                        parcelYN = 'Y';
                    }
                    if (total < 0) {
                        total = 0;
                    }
                    if (obj.MODEL_CODE__c != null) {
                        model = obj.MODEL_CODE__c;
                    }
                    if (obj.lu_MODEL_CODE__c != null) {
                        modelId = obj.lu_MODEL_CODE__c;
                    }

                    // 가용수량이 0보다 작은 경우 -> 0 처리
                    if (totalQty < 0) totalQty = 0;


                    divQty = divQuantityMap.get(obj.DIV_CODE__c) != null ? divQuantityMap.get(obj.DIV_CODE__c) : 0;
                    // 소모품의 경우 센터 별이 아닌 소모품 적치장소 + 사업부의 재고를 합쳐서 보여 주어야 함.
                    // Loop 밖에서 해당 타겟 1개만 세팅
                    // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                    // EX_SuppliesController.ItemTable itemTable = new EX_SuppliesController.ItemTable('원', divCode, obj.ProductCode, obj.TECH_GRADE_PROD_CODE__c, productName,
                    EX_SuppliesController.ItemTable itemTable = new EX_SuppliesController.ItemTable('원', divCode, obj.Name, obj.TECH_GRADE_PROD_CODE__c, productName,
                            obj.PART_SPEC__c, totalQty, obj.CUST_PRICE__c, obj.ASC_PRICE__c, '',
                            obj.Id, consumableProductItemId, consumableWarehouseId, obj.DisplayUrl, obj.Description, disabledType, partType,
                            thinQItem, parcelYN, totalComputerizedQty, allocQty, '', centerTotalSum, 0, 0, 0, model, modelId, '', divQty, EXQuantity);
                    itemTable.Id = obj.Id;
                    itemTable.OBS_ITEM_YN = 'N';

                    // 23.04.18 // 전시판매정보
                    // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                    // String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.ProductCode;
                    String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.Name;
                    if (obsSalesInfoMap.containsKey(divProductCodeKey)) {
                        Map<String, String> obsSalesInfo = (Map<String, String>) obsSalesInfoMap.get(divProductCodeKey);
                        System.debug('@@@ obsSalesInfo @@@');
                        System.debug(obsSalesInfo);
                        itemTable.ObsMemberPrice = (String) obsSalesInfo.get('ObsMemberPrice');
                        itemTable.PartNameKor = (String) obsSalesInfo.get('PartNameKor');
                        if (itemTable.PartNameKor != null) {
                            itemTable.ProductName = itemTable.PartNameKor + '(' + itemTable.ProductName + ')';
                        }
                        itemTable.ObsImageUrl = 'https://' + (String) obsSalesInfo.get('ObsImageURL');
                        itemTable.ObsSalesURL = 'https://' + (String) obsSalesInfo.get('ObsSalesURL');
                        itemTable.OBS_ITEM_YN = 'Y';
                    }
                    if (promotionInfoMap.containsKey(divProductCodeKey)) {
                        itemTable.PromotionPrice = promotionInfoMap.get(divProductCodeKey).PromotionPrice__c;
                    }
                    System.debug('소모품 itemTable : ' + itemTable);

                    listResult.add(itemTable);
                }

            } else {
                // 소모품이 아닌 경우
                if (!obj.ProductItems.isEmpty()) {
                    //24 01 15 hyungho.chun 소모품아니여도 적치장소/사업부 재고 합쳐서 보여주게 소모품재고조회처럼 수정
                    listPI = obj.ProductItems;
                    String productName = obj.PART_TYPE__c;
                    String disabledType = 'N';
                    String partType = 'N';
                    String thinQItem = 'N';
                    String parcelYN = 'N';
                    String model = '';
                    String modelId = null;
                    String consumableWarehouseId = '';
                    String consumableProductItemId = '';


                    // 소모품 전산수량 : 소모품 적치장소의 전산수량(fm_Computerized_Quantity__c + 사업부 보유량(QuantityOnHand)
                    // 소모품 가용수량 : 소모품 적치장소의 가용수량 + (사업부 보유량 - 사업부 주문수량)
                    Decimal totalQty = 0;
                    Decimal allocQty = 0;
                    Decimal totalComputerizedQty = 0 ;
                    Integer divQty = 0;
                    for (ProductItem objPI : listPI) {

                        System.debug('objPI.LocationId');
                        System.debug(objPI);
                        System.debug(objPI.LocationId);
                        // 사업부 재고인 경우
                        if (objPI.Location.RecordType.DeveloperName == 'DIV') {
                            //24 01 16 hyungho.chun 단종이 아닌 경우에만 사업부 수량을 조회한다
                            if (obj.DISABLED_TYPE__c == null){
                                // (사업부 보유량 - 사업부 주문수량)
                                if (objPI.ORDER_QTY__c == null) objPI.ORDER_QTY__c = 0;
                                // 0보다 작은 경우 0 처리
                                totalQty += (objPI.QuantityOnHand - objPI.ORDER_QTY__c < 0) ? 0 : objPI.QuantityOnHand - objPI.ORDER_QTY__c;
                                totalComputerizedQty += objPI.QuantityOnHand;

                                divQty += (objPI.QuantityOnHand - objPI.ORDER_QTY__c < 0) ? 0 : Integer.valueOf(objPI.QuantityOnHand - objPI.ORDER_QTY__c);

                                divQuantityMap = getDivQuantityMap(divQuantityMap, objPI.DIV_CODE__c, divQty);
                            }

                        } else {
                            // PH8002 재고 인 경우
                            // consumableWarehouseId = objPI.LocationId; //24 01 22 hyungho.chun 소모품아닌경우엔 사업부재고던 아니던 productitem id도 화면에 보낸다
                            // consumableProductItemId = objPi.Id;

                            // 가용수량
                            totalQty += objPI.fm_Available_Quantity__c;
                            // 할당수량
                            allocQty = objPI.ALLOC_QTY__c;
                            // 전산수량
                            totalComputerizedQty += objPI.fm_Computerized_Quantity__c;
                        
                        }

                        consumableWarehouseId = objPI.LocationId; //24 01 22 hyungho.chun 소모품아닌경우엔 사업부재고던 아니던 productitem id도 화면에 보낸다
                        consumableProductItemId = objPi.Id;

                        //23.12.14 seung yoon heo 출고부서
                        if (objPI.Location.DIV_CODE__c != null) {
                            shipMentName.put(objPI.Location.DIV_CODE__c, objPI.Location.Name);
                        }
                    }

                    if (obj.PART_DESC_KOR__c != NULL) {
                        productName = obj.PART_DESC_KOR__c + '(' + obj.PART_DESC__c + ')';
                    } else {
                        productName = obj.PART_DESC__c;
                    }
                    if (obj.DISABLED_TYPE__c != null) {
                        disabledType = 'Y';
                    }
                    if (obj.PART_TYPE__c == 'D') {
                        partType = 'Y';
                    }

                    if (obj.PARCEL_YN__c == 'Y') {
                        parcelYN = 'Y';
                    }
                    if (total < 0) {
                        total = 0;
                    }
                    if (obj.MODEL_CODE__c != null) {
                        model = obj.MODEL_CODE__c;
                    }
                    if (obj.lu_MODEL_CODE__c != null) {
                        modelId = obj.lu_MODEL_CODE__c;
                    }

                    // 가용수량이 0보다 작은 경우 -> 0 처리
                    if (totalQty < 0) totalQty = 0;


                    divQty = divQuantityMap.get(obj.DIV_CODE__c) != null ? divQuantityMap.get(obj.DIV_CODE__c) : 0;
                    // 소모품의 경우 센터 별이 아닌 소모품 적치장소 + 사업부의 재고를 합쳐서 보여 주어야 함.
                    // Loop 밖에서 해당 타겟 1개만 세팅
                    // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                    // EX_SuppliesController.ItemTable itemTable = new EX_SuppliesController.ItemTable('원', divCode, obj.ProductCode, obj.TECH_GRADE_PROD_CODE__c, productName,
                    EX_SuppliesController.ItemTable itemTable = new EX_SuppliesController.ItemTable('원', divCode, obj.Name, obj.TECH_GRADE_PROD_CODE__c, productName,
                            obj.PART_SPEC__c, totalQty, obj.CUST_PRICE__c, obj.ASC_PRICE__c, '',
                            obj.Id, consumableProductItemId, consumableWarehouseId, obj.DisplayUrl, obj.Description, disabledType, partType,
                            thinQItem, parcelYN, totalComputerizedQty, allocQty, '', centerTotalSum, 0, 0, 0, model, modelId, '', divQty, EXQuantity);
                    itemTable.Id = obj.Id;
                    itemTable.OBS_ITEM_YN = 'N';

                    // 23.04.18 // 전시판매정보
                    // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                    // String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.ProductCode;
                    String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.Name;
                    if (obsSalesInfoMap.containsKey(divProductCodeKey)) {
                        Map<String, String> obsSalesInfo = (Map<String, String>) obsSalesInfoMap.get(divProductCodeKey);
                        System.debug('@@@ obsSalesInfo @@@');
                        System.debug(obsSalesInfo);
                        itemTable.ObsMemberPrice = (String) obsSalesInfo.get('ObsMemberPrice');
                        itemTable.PartNameKor = (String) obsSalesInfo.get('PartNameKor');
                        if (itemTable.PartNameKor != null) {
                            itemTable.ProductName = itemTable.PartNameKor + '(' + itemTable.ProductName + ')';
                        }
                        itemTable.ObsImageUrl = 'https://' + (String) obsSalesInfo.get('ObsImageURL');
                        itemTable.ObsSalesURL = 'https://' + (String) obsSalesInfo.get('ObsSalesURL');
                        itemTable.OBS_ITEM_YN = 'Y';
                    }
                    if (promotionInfoMap.containsKey(divProductCodeKey)) {
                        itemTable.PromotionPrice = promotionInfoMap.get(divProductCodeKey).PromotionPrice__c;
                    }
                    System.debug('소모품 itemTable : ' + itemTable);

                    listResult.add(itemTable);                    

                    //24 01 15 hyungho.chun 소모품아니여도 적치장소/사업부 재고 합쳐서 보여주게 소모품재고조회처럼 수정
                    // listPI = obj.ProductItems;
                    // System.debug('listPi Size => ' + listPI.size());
                    // Integer divQty = 0;
                    // for (ProductItem objPI : listPI) {
                    //     String productName = objPI.Product2.PART_DESC__c;
                    //     String disabledType = 'N';
                    //     String partType = 'N';
                    //     String thinQItem = 'N';
                    //     String parcelYN = 'N';
                    //     String model = '';
                    //     String modelId = null;
                    //     if (objPI.Product2.PART_DESC_KOR__c != NULL) {
                    //         productName = objPI.Product2.PART_DESC_KOR__c + '(' + objPI.Product2.PART_DESC__c + ')';
                    //     } else {
                    //         productName = objPI.Product2.PART_DESC__c;
                    //     }

                    //     if (objPI.Product2.DISABLED_TYPE__c != null) {
                    //         disabledType = 'Y';
                    //     }
                    //     if (objPI.Product2.PART_TYPE__c == 'D') {
                    //         partType = 'Y';
                    //     }

                    //     if (objPI.Product2.PARCEL_YN__c == 'Y') {
                    //         parcelYN = 'Y';
                    //     }
                    //     if (total < 0) {
                    //         total = 0;
                    //     }
                    //     if (obj.MODEL_CODE__c != null) {
                    //         model = obj.MODEL_CODE__c;
                    //     }
                    //     if (obj.lu_MODEL_CODE__c != null) {
                    //         modelId = obj.lu_MODEL_CODE__c;
                    //     }
                    //     Decimal totalQty = 0;
                    //     System.debug('objPI.LocationId');
                    //     System.debug(objPI.LocationId);

                    //    //23.12.14 seung yoon heo 출고부서
                    //     if (objPI.Location.DIV_CODE__c != null) {
                    //         shipMentName.put(objPI.Location.DIV_CODE__c, objPI.Location.Name);
                    //     }
                    //     if (objPI.Location.RecordType.DeveloperName == 'DIV') {
                    //         divQty = (objPI.QuantityOnHand - objPI.ORDER_QTY__c < 0) ? 0 : Integer.valueOf(objPI.QuantityOnHand - objPI.ORDER_QTY__c);
                    //         totalQty = divQty;
                    //     } else {
                    //         totalQty = objPI.fm_Available_Quantity__c < 0 ? 0 : objPI.fm_Available_Quantity__c;
                    //     }
                    //     // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                    //     // EX_SuppliesController.ItemTable itemTable = new EX_SuppliesController.ItemTable('원', divCode, objPI.Product2.ProductCode, objPI.Product2.TECH_GRADE_PROD_CODE__c, productName,
                    //     EX_SuppliesController.ItemTable itemTable = new EX_SuppliesController.ItemTable('원', divCode, objPI.Product2.Name, objPI.Product2.TECH_GRADE_PROD_CODE__c, productName,
                    //             objPI.Product2.PART_SPEC__c, totalQty, objPI.Product2.CUST_PRICE__c, objPI.Product2.ASC_PRICE__c, '',
                    //             objPI.Product2Id, objPI.Id, objPI.LocationId, objPI.Product2.DisplayUrl, objPI.Product2.Description, disabledType, partType,
                    //             thinQItem, parcelYN, objPi.fm_Computerized_Quantity__c, objPI.ALLOC_QTY__c, '', centerTotalSum, 0, 0, 0, model, modelId, '', divQty, EXQuantity);
                    //     itemTable.Id = obj.Id;

                    //     // 23.04.18 // 전시판매정보
                    //     // String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.ProductCode;
                    //     String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.Name;
                    //     if (obsSalesInfoMap.containsKey(divProductCodeKey)) {
                    //         Map<String, String> obsSalesInfo = (Map<String, String>) obsSalesInfoMap.get(divProductCodeKey);
                    //         System.debug('@@@ obsSalesInfo @@@');
                    //         System.debug(obsSalesInfo);
                    //         itemTable.ObsMemberPrice = (String) obsSalesInfo.get('ObsMemberPrice');
                    //         itemTable.PartNameKor = (String) obsSalesInfo.get('PartNameKor');
                    //         if (itemTable.PartNameKor != null) {
                    //             itemTable.ProductName = itemTable.PartNameKor + '(' + itemTable.ProductName + ')';
                    //         }
                    //         itemTable.ObsImageUrl = 'https://' + (String) obsSalesInfo.get('ObsImageURL');
                    //         itemTable.ObsSalesURL = 'https://' + (String) obsSalesInfo.get('ObsSalesURL');
                    //         itemTable.OBS_ITEM_YN = 'Y';
                    //     }

                    //     listResult.add(itemTable);
                    //     system.debug(listResult);
                    // }
                } else {
                    String productName = obj.PART_DESC__c;
                    String disabledType = 'N';
                    String partType = 'N';
                    String thinQItem = 'N';
                    String parcelYN = 'N';
                    String model = '';
                    String modelId = null;

                    if (obj.PART_DESC_KOR__c != NULL) {
                        productName = obj.PART_DESC_KOR__c + '(' + obj.PART_DESC__c + ')';
                    } else {
                        productName = obj.PART_DESC__c;
                    }
                    if (obj.DISABLED_TYPE__c != null) {
                        disabledType = 'Y';
                    }
                    if (obj.PART_TYPE__c == 'D') {
                        partType = 'Y';
                    }

                    if (obj.PARCEL_YN__c == 'Y') {
                        parcelYN = 'Y';
                    }
                    if (obj.MODEL_CODE__c != null) {
                        model = obj.MODEL_CODE__c;
                    }

                    if (obj.lu_MODEL_CODE__c != null) {
                        modelId = obj.lu_MODEL_CODE__c;
                    }

                    // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                    // EX_SuppliesController.ItemTable itemTable = new EX_SuppliesController.ItemTable('원', divCode, obj.ProductCode, obj.TECH_GRADE_PROD_CODE__c, productName, obj.PART_SPEC__c, 0, obj.CUST_PRICE__c,
                    EX_SuppliesController.ItemTable itemTable = new EX_SuppliesController.ItemTable('원', divCode, obj.Name, obj.TECH_GRADE_PROD_CODE__c, productName, obj.PART_SPEC__c, 0, obj.CUST_PRICE__c,
                            obj.ASC_PRICE__c, '', obj.Id, '', '', obj.DisplayUrl, obj.Description, disabledType, partType, thinQItem, parcelYN, 0,
                            0, '', centerTotalSum, 0, 0, 0, model, modelId, '', 0, 0);
                    itemTable.Id = obj.Id;
                    // 23.04.18 // 전시판매정보
                    // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                    // String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.ProductCode;
                    String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.Name;
                    if (obsSalesInfoMap.containsKey(divProductCodeKey)) {
                        Map<String, String> obsSalesInfo = (Map<String, String>) obsSalesInfoMap.get(divProductCodeKey);
                        System.debug('@@@ obsSalesInfo @@@');
                        System.debug(obsSalesInfo);
                        itemTable.ObsMemberPrice = (String) obsSalesInfo.get('ObsMemberPrice');
                        itemTable.PartNameKor = (String) obsSalesInfo.get('PartNameKor');
                        if (itemTable.PartNameKor != null) {
                            itemTable.ProductName = itemTable.PartNameKor + '(' + itemTable.ProductName + ')';
                        }
                        itemTable.ObsImageUrl = 'https://' + (String) obsSalesInfo.get('ObsImageURL');
                        itemTable.ObsSalesURL = 'https://' + (String) obsSalesInfo.get('ObsSalesURL');
                        itemTable.OBS_ITEM_YN = 'Y';
                    }

                    //24 02 06 hyungho.chun 활성화된 div의 부품만보이게
                    if(divList.contains(obj.DIV_CODE__c)){
                        listResult.add(itemTable);
                    }
                    // listResult.add(itemTable);
                }
            }

            //대치품 조회를 위해 Id담기

            if (!obj.SM_SUBSTITUTE_PART_Product_PART__r.isEmpty()) {
                listSub = obj.SM_SUBSTITUTE_PART_Product_PART__r;
                for (SM_SUBSTITUTE_PART__c objSub : obj.SM_SUBSTITUTE_PART_Product_PART__r) {
                    setSubIds.add(objSub.SUBSTITUTE_PART_NO__c);
                    mapSubstituteTypeById.put(objSub.SUBSTITUTE_PART_NO__c, objSub.SUBSTITUTE_TYPE__c);

                }
            }
        }

        System.debug('setSubIds');
        System.debug(setSubIds);
        System.debug(setSubIds.size());
        System.debug('productCode' + productCode);
        //대치품의 재고조회
        if (!setSubIds.isEmpty()) {
            //2023.11.01 seung yoon heo 쌍방대치 중복 제거
            List<Product2> listSubsiProd = new List<Product2>([
                    SELECT Id, PART_SPEC__c, ProductCode, Name, MODEL_CODE__c, CUST_PRICE__c, ASC_PRICE__c, TECH_GRADE_PROD_CODE__c, TECH_PART_YN__c, DIV_CODE__c, DisplayUrl, Description, PART_DESC_KOR__c,
                            Disabled_Type__c, PART_TYPE__c, DISABLED_REL_DT__c, THINQ_ITEM_YN__c, PARCEL_YN__c, lu_MODEL_CODE__c, PART_DESC__c, (
                            SELECT Id, LocationId, Location.Name, Location.RecordTypeId, Location.RecordType.DeveloperName, Location.LocationType,
                                    fm_Available_Quantity__c, ProductName, QuantityOnHand, ORDER_QTY__c,
                                    DIV_CODE__c, Product2Id, fm_Computerized_Quantity__c, RESRV_QTY__c, ALLOC_QTY__c, Location.DIV_CODE__c
                                    , Product2.Name
                                    , Product2.ProductCode
                                    , Product2.PART_SPEC__c
                                    , Product2.MODEL_CODE__c
                                    , Product2.CUST_PRICE__c
                                    , Product2.ASC_PRICE__c
                                    , Product2.TECH_GRADE_PROD_CODE__c
                                    , Product2.TECH_PART_YN__c
                                    , Product2.DisplayUrl
                                    , Product2.Description
                                    , Product2.PART_DESC_KOR__c
                                    , Product2.DISABLED_TYPE__c
                                    , Product2.PART_TYPE__c
                                    , Product2.THINQ_ITEM_YN__c
                                    , Product2.DISABLED_REL_DT__c
                                    , Product2.PARCEL_YN__c
                                    , Product2.lu_MODEL_CODE__c
                                    , Product2.PART_DESC__c

                            FROM ProductItems
                            WHERE (
                                    Product2Id = :setSubIds AND Product2.Name != :productCode 
                                    AND ((Location.ParentLocationId__r.SM_DEPT_Id__r.DEPT_CODE__c = 'PH8002'
                                    AND Location.LocationType = 'Warehouse'
                                    AND Location.Name = :System.Label.EX_Location)
                                    OR Location.RecordType.DeveloperName = 'DIV')
                            )
                            // OR (//24 01 12 hyungho.chun part_Type D던아니던 똑같이 조회
                            //         Product2.PART_TYPE__c != 'D' AND Product2Id = :setSubIds AND Product2.Name != :productCode 
                            //         AND Location.RecordType.DeveloperName = 'DIV' 
                            //         AND (Location.LocationType = 'Warehouse' OR Location.LocationType = 'Site')
                            // )
                    )
                    FROM Product2
                    WHERE Id IN :setSubIds AND Name != : productCode
            ]);

            listPI = new List<ProductItem>();
            total = 0;
            EXQuantity = 0 ;
            DIVQuantity = 0;
            quantityList = [
                    SELECT fm_Available_Quantity__c, Location.Name, Location.ParentLocationId__r.DIV_CODE__c,
                            Location.ParentLocationId__r.DEPT_CODE__c, DIV_CODE__c, QuantityOnHand, ORDER_QTY__c, Location.DIV_CODE__c,
                            Product2Id, Product2.PART_TYPE__c, Location.RecordTypeId, Location.RecordType.DeveloperName
                    FROM ProductItem
                    WHERE Product2Id = :setSubIds
            ];

            Map<String, Map<String, Decimal>> productIdSubsiQtyMap = new Map<String, Map<String, Decimal>>();
            for (ProductItem item : quantityList) {
                if (item.Product2.PART_TYPE__c == 'D') {

                    if (productIdSubsiQtyMap.containsKey(item.Product2Id)) {
                        productIdSubsiQtyMap.get(item.Product2Id);
                    } else {
                        productIdSubsiQtyMap.put(item.Product2Id, null);
                    }

                    if (item.fm_Available_Quantity__c > 0) {
                        if (item.Location.ParentLocationId__r.DEPT_CODE__c == 'PH8002') {
                            EXQuantity = Integer.valueOf(item.fm_Available_Quantity__c);

                        //gw.lee 23.09.21
                        //사업부재고 수정
                        //} else if (item.Location.DIV_CODE__c == divCode) {
                        } else if (item.Location.RecordType.DeveloperName == 'DIV') {

                            if (item.QuantityOnHand == null) item.QuantityOnHand = 0;
                            if (item.ORDER_QTY__c == null) item.ORDER_QTY__c = 0;

                            //DIVQuantity = Integer.valueOf(item.QuantityOnHand - item.ORDER_QTY__c);
                            DIVQuantity = (Integer.valueOf(item.QuantityOnHand) - Integer.valueOf(item.ORDER_QTY__c) < 0) ? 0 : Integer.valueOf(item.QuantityOnHand) - Integer.valueOf(item.ORDER_QTY__c);
                        } else if (item.Location.ParentLocationId__r.DEPT_CODE__c == 'PH0300') {
                            System.debug('DEPT_CODE PH0300');
                        } else {
                            total += Integer.valueOf(item.fm_Available_Quantity__c);
                        }
                    }
                }
                
            }
            Map<String, String> mapPickList = DN_CommonUtil.getPickListMap('SM_SUBSTITUTE_PART__c', 'SUBSTITUTE_TYPE__c');

            System.debug('listSubsiProd ???' + listSubsiProd.size());

            //23.11.23 gw.lee
            //사업부 재고 관리
            Map<String, Integer> divOtherQuantityMap = new Map<String, Integer>();

            for (Product2 obj : listSubsiProd) {
                // 대치 부품
                divCode = obj.DIV_CODE__c;

                // 소모품 인경우
                if (obj.PART_TYPE__c == 'D') {
                    // 23.04.15 / OBS 전시판매정보 데이터 받아온 이후 세팅.
                    // ObsImageUrl : OBS 이미지 URL
                    // ObsSalesURL : OBS 판매 전시 URL
                    // PartNameKor : 한글 품명
                    // ObsMemberPrice : OBS 회원가

                    if (!obj.ProductItems.isEmpty()) {
                        listPI = obj.ProductItems;
                        String productName = obj.PART_DESC__c;
                        String disabledType = 'N';
                        String partType = 'N';
                        String thinQItem = 'N';
                        String parcelYN = 'N';
                        String model = '';
                        String modelId = null;
                        String consumableWarehouseId = '';
                        String consumableProductItemId = '';

                        // 소모품 전산수량 : 소모품 적치장소의 전산수량(fm_Computerized_Quantity__c + 사업부 보유량(QuantityOnHand)
                        // 소모품 가용수량 : 소모품 적치장소의 가용수량 + (사업부 보유량 - 사업부 주문수량)
                        Decimal totalQty = 0;
                        Decimal allocQty = 0;
                        Decimal totalComputerizedQty = 0 ;
                        for (ProductItem objPI : listPI) {

                            //23.12.14 seung yoon heo 출고부서
                            if (objPI.Location.DIV_CODE__c != null) {
                                shipMentName.put(objPI.Location.DIV_CODE__c, objPI.Location.Name);
                            }
                            System.debug('objPI.LocationId');
                            System.debug(objPI.LocationId);
                            // 사업부 재고인 경우
                            if (objPI.Location.RecordType.DeveloperName == 'DIV') {
                                //24 01 16 hyungho.chun 단종이 아닌 경우에만 사업부 수량을 조회한다
                                if (obj.DISABLED_TYPE__c == null){
                                    // (사업부 보유량 - 사업부 주문수량)
                                    if (objPI.ORDER_QTY__c == null) objPI.ORDER_QTY__c = 0;
                                    // 0보다 작은 경우 0 처리
                                    Decimal currentTotalQty = 0;

                                    currentTotalQty = (objPI.QuantityOnHand - objPI.ORDER_QTY__c < 0) ? 0 : objPI.QuantityOnHand - objPI.ORDER_QTY__c;
                                    totalQty += currentTotalQty;
                                    totalComputerizedQty += objPI.QuantityOnHand;

                                    divOtherQuantityMap = getDivQuantityMap(divOtherQuantityMap, objPI.DIV_CODE__c, Integer.valueOf(currentTotalQty));
                                }

                            } else {
                                // PH8002 재고 인 경우
                                consumableWarehouseId = objPI.LocationId;
                                consumableProductItemId = objPi.Id;
                    
                                // 가용수량
                                totalQty += objPI.fm_Available_Quantity__c;
                                // 할당수량
                                allocQty = objPI.ALLOC_QTY__c;
                                // 전산수량
                                totalComputerizedQty += objPI.fm_Computerized_Quantity__c;
                            }

                            //23.12.14 seung yoon heo 출고부서
                            if (objPI.Location.DIV_CODE__c != null) {
                                shipMentName.put(objPI.Location.DIV_CODE__c, objPI.Location.Name);
                            }
                        }

                        if (obj.PART_DESC_KOR__c != NULL) {
                            productName = obj.PART_DESC_KOR__c + '(' + obj.PART_DESC__c + ')';
                        } else {
                            productName = obj.PART_DESC__c;
                        }
                        if (obj.DISABLED_TYPE__c != null) {
                            disabledType = 'Y';
                        }
                        if (obj.PART_TYPE__c == 'D') {
                            partType = 'Y';
                        }

                        if (obj.PARCEL_YN__c == 'Y') {
                            parcelYN = 'Y';
                        }
                        if (total < 0) {
                            total = 0;
                        }
                        if (obj.MODEL_CODE__c != null) {
                            model = obj.MODEL_CODE__c;
                        }
                        if (obj.lu_MODEL_CODE__c != null) {
                            modelId = obj.lu_MODEL_CODE__c;
                        }

                        // 가용수량이 0보다 작은 경우 -> 0 처리
                        if (totalQty < 0) totalQty = 0;

                        // 소모품의 경우 센터 별이 아닌 소모품 적치장소 + 사업부의 재고를 합쳐서 보여 주어야 함.
                        // Loop 밖에서 해당 타겟 1개만 세팅
                        // 2023.09.18 seung yoon heo ProductCode => Name으로 변경

                        Integer divOtherQty = 0;
                        divOtherQty = divOtherQuantityMap.get(obj.DIV_CODE__c) != null ? divOtherQuantityMap.get(obj.DIV_CODE__c) : 0;
                        EX_SuppliesController.ItemTable itemTable = new EX_SuppliesController.ItemTable(
                                mapPickList.get(mapSubstituteTypeById.get(obj.Id)),
                                divCode,
                                obj.Name,
                                obj.TECH_GRADE_PROD_CODE__c,
                                productName,
                                obj.PART_SPEC__c,
                                totalQty,
                                obj.CUST_PRICE__c,
                                obj.ASC_PRICE__c,
                                '',
                                obj.Id,
                                consumableProductItemId,
                                consumableWarehouseId,
                                obj.DisplayUrl,
                                obj.Description,
                                disabledType,
                                partType,
                                thinQItem,
                                parcelYN,
                                totalComputerizedQty,
                                allocQty,
                                '',
                                centerTotalSum,
                                0,
                                0,
                                0,
                                model,
                                modelId,
                                '',
                                divOtherQty,
                                EXQuantity);
                        itemTable.Id = obj.Id;


                        //
                        // 23.04.18 // 전시판매정보
                        // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                        // String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.ProductCode;
                        String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.Name;
                        if (obsSalesInfoMap.containsKey(divProductCodeKey)) {
                            Map<String, String> obsSalesInfo = (Map<String, String>) obsSalesInfoMap.get(divProductCodeKey);
                            System.debug('@@@ obsSalesInfo @@@');
                            System.debug(obsSalesInfo);
                            itemTable.ObsMemberPrice = (String) obsSalesInfo.get('ObsMemberPrice');
                            itemTable.PartNameKor = (String) obsSalesInfo.get('PartNameKor');
                            if (itemTable.PartNameKor != null) {
                                itemTable.ProductName = itemTable.PartNameKor + '(' + itemTable.ProductName + ')';
                            }
                            itemTable.ObsImageUrl = 'https://' + (String) obsSalesInfo.get('ObsImageURL');
                            itemTable.ObsSalesURL = 'https://' + (String) obsSalesInfo.get('ObsSalesURL');
                            itemTable.OBS_ITEM_YN = 'Y';
                        }

                        if (promotionInfoMap.containsKey(divProductCodeKey)) {
                            itemTable.PromotionPrice = promotionInfoMap.get(divProductCodeKey).PromotionPrice__c;
                        }


                        listResult.add(itemTable);
                    }

                } else {
                    // 소모품이 아닌 경우
                    Map<String, EX_SuppliesController.ItemTable> prNameMap = new Map<String, EX_SuppliesController.ItemTable>();
                    // Decimal totalQty = 0;
                    // Decimal allocQty = 0;
                    // Decimal totalComputerizedQty = 0 ;
                    if (!obj.ProductItems.isEmpty()) {

                        //24 01 15 hyungho.chun 소모품아닌경우도 적치장소까지 재고조회
                        listPI = obj.ProductItems;
                        String productName = obj.PART_DESC__c;
                        String disabledType = 'N';
                        String partType = 'N';
                        String thinQItem = 'N';
                        String parcelYN = 'N';
                        String model = '';
                        String modelId = null;
                        String consumableWarehouseId = '';
                        String consumableProductItemId = '';

                        // 소모품 전산수량 : 소모품 적치장소의 전산수량(fm_Computerized_Quantity__c + 사업부 보유량(QuantityOnHand)
                        // 소모품 가용수량 : 소모품 적치장소의 가용수량 + (사업부 보유량 - 사업부 주문수량)
                        Decimal totalQty = 0;
                        Decimal allocQty = 0;
                        Decimal totalComputerizedQty = 0 ;
                        for (ProductItem objPI : listPI) {

                            //23.12.14 seung yoon heo 출고부서
                            if (objPI.Location.DIV_CODE__c != null) {
                                shipMentName.put(objPI.Location.DIV_CODE__c, objPI.Location.Name);
                            }
                            System.debug('objPI.LocationId');
                            System.debug(objPI.LocationId);
                            // 사업부 재고인 경우
                            if (objPI.Location.RecordType.DeveloperName == 'DIV') {
                                //24 01 16 hyungho.chun 단종이 아닌 경우에만 사업부 수량을 조회한다
                                if (obj.DISABLED_TYPE__c == null) {     
                                    // (사업부 보유량 - 사업부 주문수량)
                                    if (objPI.ORDER_QTY__c == null) objPI.ORDER_QTY__c = 0;
                                    // 0보다 작은 경우 0 처리
                                    Decimal currentTotalQty = 0;

                                    currentTotalQty = (objPI.QuantityOnHand - objPI.ORDER_QTY__c < 0) ? 0 : objPI.QuantityOnHand - objPI.ORDER_QTY__c;
                                    totalQty += currentTotalQty;
                                    totalComputerizedQty += objPI.QuantityOnHand;

                                    divOtherQuantityMap = getDivQuantityMap(divOtherQuantityMap, objPI.DIV_CODE__c, Integer.valueOf(currentTotalQty));
                                }

                            } else {
                                // PH8002 재고 인 경우
                                // consumableWarehouseId = objPI.LocationId; //24 01 22 hyungho.chun 소모품아닌경우엔 사업부재고던 아니던 productitem id도 화면에 보낸다
                                // consumableProductItemId = objPi.Id;

                                // 가용수량
                                totalQty += objPI.fm_Available_Quantity__c;
                                // 할당수량
                                allocQty = objPI.ALLOC_QTY__c;
                                // 전산수량
                                totalComputerizedQty += objPI.fm_Computerized_Quantity__c;                                
                            }

                            consumableWarehouseId = objPI.LocationId; //24 01 22 hyungho.chun 소모품아닌경우엔 사업부재고던 아니던 productitem id도 화면에 보낸다
                            consumableProductItemId = objPi.Id;

                            //23.12.14 seung yoon heo 출고부서
                            if (objPI.Location.DIV_CODE__c != null) {
                                shipMentName.put(objPI.Location.DIV_CODE__c, objPI.Location.Name);
                            }
                        }

                        if (obj.PART_DESC_KOR__c != NULL) {
                            productName = obj.PART_DESC_KOR__c + '(' + obj.PART_DESC__c + ')';
                        } else {
                            productName = obj.PART_DESC__c;
                        }
                        if (obj.DISABLED_TYPE__c != null) {
                            disabledType = 'Y';
                        }
                        if (obj.PART_TYPE__c == 'D') {
                            partType = 'Y';
                        }

                        if (obj.PARCEL_YN__c == 'Y') {
                            parcelYN = 'Y';
                        }
                        if (total < 0) {
                            total = 0;
                        }
                        if (obj.MODEL_CODE__c != null) {
                            model = obj.MODEL_CODE__c;
                        }
                        if (obj.lu_MODEL_CODE__c != null) {
                            modelId = obj.lu_MODEL_CODE__c;
                        }

                        // 가용수량이 0보다 작은 경우 -> 0 처리
                        if (totalQty < 0) totalQty = 0;

                        // 소모품의 경우 센터 별이 아닌 소모품 적치장소 + 사업부의 재고를 합쳐서 보여 주어야 함.
                        // Loop 밖에서 해당 타겟 1개만 세팅
                        // 2023.09.18 seung yoon heo ProductCode => Name으로 변경

                        Integer divOtherQty = 0;
                        divOtherQty = divOtherQuantityMap.get(obj.DIV_CODE__c) != null ? divOtherQuantityMap.get(obj.DIV_CODE__c) : 0;
                        EX_SuppliesController.ItemTable itemTable = new EX_SuppliesController.ItemTable(
                                mapPickList.get(mapSubstituteTypeById.get(obj.Id)),
                                divCode,
                                obj.Name,
                                obj.TECH_GRADE_PROD_CODE__c,
                                productName,
                                obj.PART_SPEC__c,
                                totalQty,
                                obj.CUST_PRICE__c,
                                obj.ASC_PRICE__c,
                                '',
                                obj.Id,
                                consumableProductItemId,
                                consumableWarehouseId,
                                obj.DisplayUrl,
                                obj.Description,
                                disabledType,
                                partType,
                                thinQItem,
                                parcelYN,
                                totalComputerizedQty,
                                allocQty,
                                '',
                                centerTotalSum,
                                0,
                                0,
                                0,
                                model,
                                modelId,
                                '',
                                divOtherQty,
                                EXQuantity);
                        itemTable.Id = obj.Id;


                        //
                        // 23.04.18 // 전시판매정보
                        // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                        // String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.ProductCode;
                        String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.Name;
                        if (obsSalesInfoMap.containsKey(divProductCodeKey)) {
                            Map<String, String> obsSalesInfo = (Map<String, String>) obsSalesInfoMap.get(divProductCodeKey);
                            System.debug('@@@ obsSalesInfo @@@');
                            System.debug(obsSalesInfo);
                            itemTable.ObsMemberPrice = (String) obsSalesInfo.get('ObsMemberPrice');
                            itemTable.PartNameKor = (String) obsSalesInfo.get('PartNameKor');
                            if (itemTable.PartNameKor != null) {
                                itemTable.ProductName = itemTable.PartNameKor + '(' + itemTable.ProductName + ')';
                            }
                            itemTable.ObsImageUrl = 'https://' + (String) obsSalesInfo.get('ObsImageURL');
                            itemTable.ObsSalesURL = 'https://' + (String) obsSalesInfo.get('ObsSalesURL');
                            itemTable.OBS_ITEM_YN = 'Y';
                        }

                        if (promotionInfoMap.containsKey(divProductCodeKey)) {
                            itemTable.PromotionPrice = promotionInfoMap.get(divProductCodeKey).PromotionPrice__c;
                        }
                        prNameMap.put(itemTable.ProductName,itemTable);
                        // listResult.add(itemTable); //24 01 16 hyungho.chun 쌍방대치 중복표기로 제거


                        //24 01 15 hyungho.chun 소모품아닌경우도 재고조회 동일하게 적치장소까지
                        // listPI = obj.ProductItems;
                        // System.debug('listPi Size => ' + listPI.size());
                        // for (ProductItem objPI : listPI) {
                        //     //23.12.14 seung yoon heo 출고부서
                        //     if (objPI.Location.DIV_CODE__c != null) {
                        //         shipMentName.put(objPI.Location.DIV_CODE__c, objPI.Location.Name);
                        //     }
                        //     String productName = objPI.Product2.PART_DESC__c;
                        //     String disabledType = 'N';
                        //     String partType = 'N';
                        //     String thinQItem = 'N';
                        //     String parcelYN = 'N';
                        //     String model = '';
                        //     String modelId = null;
                        //     if (objPI.Product2.PART_DESC_KOR__c != NULL) {
                        //         productName = objPI.Product2.PART_DESC_KOR__c + '(' + objPI.Product2.PART_DESC__c + ')';
                        //     } else {
                        //         productName = objPI.Product2.PART_DESC__c;
                        //     }
                        //     if (objPI.Product2.DISABLED_TYPE__c != null) {
                        //         disabledType = 'Y';
                        //     }
                        //     if (objPI.Product2.PART_TYPE__c == 'D') {
                        //         partType = 'Y';
                        //     }

                        //     if (objPI.Product2.PARCEL_YN__c == 'Y') {
                        //         parcelYN = 'Y';
                        //     }
                        //     if (total < 0) {
                        //         total = 0;
                        //     }
                        //     if (obj.MODEL_CODE__c != null) {
                        //         model = obj.MODEL_CODE__c;
                        //     }
                        //     if (obj.lu_MODEL_CODE__c != null) {
                        //         modelId = obj.lu_MODEL_CODE__c;
                        //     }
                        //     Integer computerizedQty = 0;
                        //     System.debug('objPI.LocationId');
                        //     System.debug(objPI.LocationId);
                        //     if (objPI.Location.RecordType.DeveloperName == 'DIV') {
                        //         totalQty += objPI.QuantityOnHand - objPI.ORDER_QTY__c;
                        //     } else {
                        //         totalQty += objPI.fm_Available_Quantity__c;
                        //     }
                            
                        //     if (totalQty < 0) totalQty = 0;
                        //     // 할당수량
                        //     allocQty = objPI.ALLOC_QTY__c;
                        //     // 전산수량
                        //     totalComputerizedQty += objPI.fm_Computerized_Quantity__c;
                        //     // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                        //     EX_SuppliesController.ItemTable itemTable = new EX_SuppliesController.ItemTable(
                        //             mapPickList.get(mapSubstituteTypeById.get(obj.Id)),
                        //             divCode,
                        //             objPI.Product2.Name,
                        //             objPI.Product2.TECH_GRADE_PROD_CODE__c,
                        //             productName,
                        //             objPI.Product2.PART_SPEC__c,
                        //             totalQty,
                        //             objPI.Product2.CUST_PRICE__c,
                        //             objPI.Product2.ASC_PRICE__c,
                        //             '',
                        //             objPI.Product2Id,
                        //             objPI.Id,
                        //             objPI.LocationId,
                        //             objPI.Product2.DisplayUrl,
                        //             objPI.Product2.Description,
                        //             disabledType,
                        //             partType,
                        //             thinQItem,
                        //             parcelYN,
                        //             totalComputerizedQty,
                        //             allocQty,
                        //             '',
                        //             centerTotalSum,
                        //             0,
                        //             0,
                        //             0,
                        //             model,
                        //             modelId,
                        //             '',
                        //             DIVQuantity,
                        //             EXQuantity);

                        //     itemTable.Id = obj.Id;

                        //     // 23.04.18 // 전시판매정보
                        //     // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                        //     // String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.ProductCode;
                        //     String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.Name;
                        //     //23.12.14 seung yoon heo 출고부서
                        //     if (objPI.Location.DIV_CODE__c != null) {
                        //         shipMentName.put(objPI.Location.DIV_CODE__c, objPI.Location.Name);
                        //     }
                        //     if (obsSalesInfoMap.containsKey(divProductCodeKey)) {
                        //         Map<String, String> obsSalesInfo = (Map<String, String>) obsSalesInfoMap.get(divProductCodeKey);
                        //         System.debug('@@@ obsSalesInfo @@@');
                        //         System.debug(obsSalesInfo);
                        //         itemTable.ObsMemberPrice = (String) obsSalesInfo.get('ObsMemberPrice');
                        //         itemTable.PartNameKor = (String) obsSalesInfo.get('PartNameKor');
                        //         if (itemTable.PartNameKor != null) {
                        //             itemTable.ProductName = itemTable.PartNameKor + '(' + itemTable.ProductName + ')';
                        //         }
                        //         itemTable.ObsImageUrl = 'https://' + (String) obsSalesInfo.get('ObsImageURL');
                        //         itemTable.ObsSalesURL = 'https://' + (String) obsSalesInfo.get('ObsSalesURL');
                        //     }
                        //     prNameMap.put(objPI.ProductName,itemTable);

                        //     system.debug(listResult);
                        // }
                    } else {
                        String productName = obj.Name;
                        String disabledType = 'N';
                        String partType = 'N';
                        String thinQItem = 'N';
                        String parcelYN = 'N';
                        String model = '';
                        String modelId = null;

                        //23.10.01 PHJ
                        if (obj.PART_DESC_KOR__c != NULL) {
                            productName = obj.PART_DESC_KOR__c + '(' + obj.PART_DESC__c + ')';
                        } else {
                            productName = obj.PART_DESC__c;
                        }
                        // if (obj.PART_DESC_KOR__c != NULL) {
                        //     productName = obj.PART_DESC_KOR__c + '(' + obj.Name + ')';
                        // }


                        if (obj.DISABLED_TYPE__c != null) {
                            disabledType = 'Y';
                        }
                        if (obj.PART_TYPE__c == 'D') {
                            partType = 'Y';
                        }

                        if (obj.PARCEL_YN__c == 'Y') {
                            parcelYN = 'Y';
                        }
                        if (obj.MODEL_CODE__c != null) {
                            model = obj.MODEL_CODE__c;
                        }

                        if (obj.lu_MODEL_CODE__c != null) {
                            modelId = obj.lu_MODEL_CODE__c;
                        }
                        // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                        EX_SuppliesController.ItemTable itemTable = new EX_SuppliesController.ItemTable(
                                mapPickList.get(mapSubstituteTypeById.get(obj.Id)),
                                divCode,
                                obj.Name,
                                obj.TECH_GRADE_PROD_CODE__c,
                                productName,
                                obj.PART_SPEC__c,
                                0,
                                obj.CUST_PRICE__c,
                                obj.ASC_PRICE__c,
                                '',
                                obj.Id,
                                '',
                                '',
                                obj.DisplayUrl,
                                obj.Description,
                                disabledType,
                                partType,
                                thinQItem,
                                parcelYN,
                                0,
                                0,
                                '',
                                centerTotalSum,
                                0,
                                0,
                                0,
                                model,
                                modelId,
                                '',
                                0,
                                0);

                        itemTable.Id = obj.Id;
                        // 23.04.18 // 전시판매정보
                        // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                        // String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.ProductCode;
                        String divProductCodeKey = obj.DIV_CODE__c + '_' + obj.Name;
                        if (obsSalesInfoMap.containsKey(divProductCodeKey)) {
                            Map<String, String> obsSalesInfo = (Map<String, String>) obsSalesInfoMap.get(divProductCodeKey);
                            System.debug('@@@ obsSalesInfo @@@');
                            System.debug(obsSalesInfo);
                            itemTable.ObsMemberPrice = (String) obsSalesInfo.get('ObsMemberPrice');
                            itemTable.PartNameKor = (String) obsSalesInfo.get('PartNameKor');
                            if (itemTable.PartNameKor != null) {
                                itemTable.ProductName = itemTable.PartNameKor + '(' + itemTable.ProductName + ')';
                            }
                            itemTable.ObsImageUrl = 'https://' + (String) obsSalesInfo.get('ObsImageURL');
                            itemTable.ObsSalesURL = 'https://' + (String) obsSalesInfo.get('ObsSalesURL');
                            itemTable.OBS_ITEM_YN = 'Y';

                        }
                        prNameMap.put(itemTable.ProductName,itemTable);
                    }
                    EX_SuppliesController.ItemTable itemTable = prNameMap.values()[0];

                    //24 02 06 hyungho.chun 활성화된 div의 부품만보이게
                    if(divList.contains(obj.DIV_CODE__c)){
                        listResult.add(itemTable);
                    }
                    // listResult.add(itemTable);

                }
            }
        }

        //23.12.14 seung yoon heo 출고부서
        mapResult.put('shipMentName' , shipMentName); 
         
        mapResult.put('listResult', listResult);
        System.debug('속도측정 -------------------------------------------------- EX_SearchPartsController.getInitData (End):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

        return mapResult;
    }

    /**
     * @description 프로모션 정보 조회 /
      * 사용여부 Y/N, 예비속성2 : 할인 적용 출고센터코드, 예비속성4 : 프로모션시작일, 예비속성5 : 프로모션종료일
      *
     * @author 23.04.27 / I2MAX.SEOKHOLEE
     * @return
     */
    public static Map<String, EX_Promotion__c> getPromotionInformation(Set<String> divPartCodeSet) {

        String divCode = '';
        String partCode = '';

        Set<String> divCodeSet = new Set<String>();
        Set<String> partCodeSet = new Set<String>();

        for (String divPartCodeKey : divPartCodeSet) {
            List<String> divPartCodeList = divPartCodeKey.split('_');
            divCode = divPartCodeList[0];
            partCode = divPartCodeList[1];

            divCodeSet.add(divCode);
            partCodeSet.add(partCode);
        }

        // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
        List<EX_Promotion__c> promotionList = [
                SELECT Id, DIV_CODE__c, ProductId__r.Name, SHIPPED_Department_Code__c, PromotionStartDate__c, PromotionEndDate__c, PromotionPrice__c
                FROM EX_Promotion__c
                WHERE CLASS_CODE__r.Name = 'PT026'
                AND Promotion_USE_YN__c = 'Y'
                AND (SHIPPED_Department_Code__c = 'PH8002'
                OR SHIPPED_Department_Code__c = 'PH0300')
                AND (PromotionStartDate__c <= TODAY
                AND PromotionEndDate__c >= TODAY)

                AND DIV_CODE__c IN :divCodeSet
                AND ProductId__r.Name IN :partCodeSet
                ORDER BY PromotionPrice__c DESC
        ];

        // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
        Map<String, EX_Promotion__c> promotionInfoMap = new Map<String, EX_Promotion__c>();
        for (EX_Promotion__c exPromotion : promotionList) {
            if (exPromotion.DIV_CODE__c != null && exPromotion.ProductId__r.Name != null) {
                String divPartCodeKey = exPromotion.DIV_CODE__c + '_' + exPromotion.ProductId__r.Name;
                promotionInfoMap.put(divPartCodeKey, exPromotion);
            }
        }

        return promotionInfoMap;
    }

     /**
     * @description 
      * 사업부 가용 수량 체크
      *
     * @author 23.11.23 / gw.lee
     * @return
     */
    public static Map<String, Integer> getDivQuantityMap(Map<String, Integer> divQuantityMap, String divCode, Integer divQty) {
        if (divQuantityMap.containsKey(divCode)) {
            Integer totalQty = divQuantityMap.get(divCode);

            divQuantityMap.put(divCode, totalQty + divQty);
        } else {
            divQuantityMap.put(divCode, divQty);
        }

        return divQuantityMap;
    }
}