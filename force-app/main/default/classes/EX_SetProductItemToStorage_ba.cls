/**
 * @description       : ProductTransfer없이 소모품센터에 남아있는 재고 99A999로 이동 배치
 * @author            : hyungho.chun@dkbmc.com
 * @group             : 
 * @last modified on  : 09-15-2023
 * @last modified by  : hyungho.chun@dkbmc.com
**/

//참고할것@@@@@
//ptlist에서 조회된 SourceProductItemId의 productItem에서 QuantityReceived만큼은 제외하고 계산해야한다.
//piList location.Name 이 '99A999'인것으로 넣어줘야하고 없는경우엔 productitem을 하나 만들어줘야한다. //setProductItem 메소드 뺴서 처리했음
//SR_ONLINE_AUTO_SALE_EXC__c에 productItem 이동 로그 남길것!@@@
//가능하면 productItem Transcation에도 남겨줄것~



public with sharing class EX_SetProductItemToStorage_ba implements Database.Batchable<SObject>, Database.Stateful {

    public static String get99A999Id = [SELECT Id FROM Location WHERE Name = :System.Label.EX_Location][0].Id;

    public EX_SetProductItemToStorage_ba() {

    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('속도측정 -------------------------------------------------- EX_SetProductItemToStorage_ba 시작 '+ System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

        String query = '';
        query += 'SELECT Id, Product2Id, product2.PART_TYPE__c, QuantityOnHand, fm_Available_Quantity__c,ALLOC_QTY__c,AUTO_UNRCV_QTY__c,COLLECT_QTY__c,MOVE_QTY__c,ORDER_QTY__c,RENT_QTY__c, ';
        query += 'RESRV_QTY__c,RESRV_UNRCV_QTY__c,RETURN_ALLOC_QTY__c,JUNK_ALLOC_QTY__c,PARTS_NUMBER__c, LocationId, Location.name FROM ProductItem ';
        query += 'WHERE Product2.PART_TYPE__c = \'D\' AND Location.Name = \'소모품센터\' ';


        //테스트로 파트넘버 하나만넣고 돌려봄
        //테스트하려면 111줄 purePiList에도 수정해줘야함 ( 코드 이쁘게 수정하면 좋을듯 )
        query += 'AND PARTS_NUMBER__c = \'EX62428605\' ';

        System.debug('query :: '+query);

        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext bc, List<ProductItem> piList) {
        System.debug('배치 시작부분 piList  :: '+piList);

        Set<String> productId = new Set<String>();
        for(ProductItem item : piList){
            productId.add(item.Product2Id);
        }
        //대상이되는 product2Id이지만 적치장소 99A999의 product Item이 없는 경우 생성
        setProductItem(productId);

        //CJ로 보내서 정상적으로 이동할 건들은 제외시키기위한 Product Trnasfer 쿼리
        List<ProductTransfer> ptList = [SELECT SourceProductItemId, Product2Id, QuantityReceived, SourceLocationId, DestinationLocationId FROM ProductTransfer 
                                        WHERE
                                            IsReceived = true AND 
                                            Fulfillment_IF_YN__c = null AND 
                                            MOVE_Type_Code__c IN ('A','B','R') AND
                                            SourceLocationId != null AND
                                            DestinationLocation.DEPT_CODE__c IN ('PH8002','PH0300') AND
                                            RecordType.DeveloperName IN ('Regular' , 'RESV') and
                                            DestinationLocation.RecordType.DeveloperName ='Center'
                                    ];
        System.debug('ptList :: '+ptList);

        

        //처음제외시킬 piList
        List<String> productAndLocation = new List<String>();
        //제외시킨건들 재고수량 계산 및 맵핑용
        Map<String,Double> pdLocAndQty = new Map<String,Double>();
        for(productTransfer item : ptList){
            Double currQty = item.QuantityReceived;
            productAndLocation.add(String.valueOf(item.Product2Id)+'^'+String.valueOf(item.DestinationLocationId));
            if(pdLocAndQty.containsKey(String.valueOf(item.Product2Id)+'^'+String.valueOf(item.DestinationLocationId))){
                pdLocAndQty.put(String.valueOf(item.Product2Id)+'^'+String.valueOf(item.DestinationLocationId), pdLocAndQty.get(String.valueOf(item.Product2Id)+'^'+String.valueOf(item.DestinationLocationId))+currQty);
            }else{
                pdLocAndQty.put(String.valueOf(item.Product2Id)+'^'+String.valueOf(item.DestinationLocationId), currQty);    
            }
        }
        String strQry = '';
        List<ProductItem> checkPiList = null;
        List<String> checkPiIdList = new List<String>();
        if(ptList.size()>0){
            strQry += 'SELECT Id, fm_Available_Quantity__c, Product2Id, locationId, QuantityOnHand FROM ProductItem WHERE ';

            for(Integer i =0; i<productAndLocation.size();i++){
                strQry += '(Product2Id = \''+productAndLocation[i].substringBefore('^')+'\' AND LocationId = \''+productAndLocation[i].substringAfter('^')+'\') ';
                if(i != productAndLocation.size()-1 ){
                    strQry += 'OR ';
                }
            }

            //PT에 있어서 1차로 걸러진 productItem들 (나중에 수량계산해서 수정해줘야함)
            System.debug('strQry :: '+strQry);
            checkPiList = Database.query(strQry);
            System.debug('checkPiList :: '+checkPiList);
            if(checkPiList.size()>0){
                for(ProductItem item : checkPiList){
                    checkPiIdList.add(item.Id);
                }
                System.debug('checkPiIdList :: '+checkPiIdList);
            }
        }
        

        List<ProductItem> purePiList = null;

        if(checkPiList != null){
            purePiList = [SELECT Id, Product2Id, product2.PART_TYPE__c, QuantityOnHand, fm_Available_Quantity__c,ALLOC_QTY__c,AUTO_UNRCV_QTY__c,COLLECT_QTY__c,MOVE_QTY__c,ORDER_QTY__c,RENT_QTY__c,
                                        RESRV_QTY__c,RESRV_UNRCV_QTY__c,RETURN_ALLOC_QTY__c,JUNK_ALLOC_QTY__c,PARTS_NUMBER__c, LocationId, Location.name FROM ProductItem 
                                    WHERE Product2.PART_TYPE__c = 'D'  AND Location.Name IN ('소모품센터') AND PARTS_NUMBER__c = 'EX62428605' AND 
                                    Id NOT IN: checkPiIdList
                        ];
            System.debug('purePiList case1:: '+purePiList);
        }else{
            purePiList = piList;
            System.debug('purePiList case2:: '+purePiList);
        }

        
        Map<String,Double> pdAndQty = new Map<String,Double>();
        for(productItem item : purePiList){
            Double fmAvaQty = item.fm_Available_Quantity__c;
            item.QuantityOnHand -= fmAvaQty;
            pdAndQty.put(item.Product2Id, fmAvaQty);
        }

        List<productItem> updatePurePiList = [SELECT Id, QuantityOnHand, Product2Id FROM productItem WHERE Product2Id IN: pdAndQty.keySet() AND locationId =: get99A999Id];
        for(productItem item : updatePurePiList){
            item.QuantityOnHand += pdAndQty.get(item.Product2Id);
        }

        System.debug('right before update purePiList :: '+purePiList);
        System.debug('right before update updatePurePiList :: '+updatePurePiList);

        update purePiList;
        update updatePurePiList;

        if(checkPiList != null){
            Map<String,Double> pdAndQty2 = new Map<String,Double>();
            for(productItem item : checkPiList){
                Double fmAvaQty = item.fm_Available_Quantity__c;
                //productTransfer로 곧 재고 처리될예정건은 빼주고
                fmAvaQty -= pdLocAndQty.get(item.Product2Id+'^'+item.locationId);
                item.QuantityOnHand -= fmAvaQty;
                pdAndQty2.put(item.product2Id,fmAvaQty);
            }

            List<productItem> updateCheckPiList = [SELECT Id, QuantityOnHand, Product2Id FROM productItem WHERE Product2Id IN: pdAndQty2.keySet() AND locationId =: get99A999Id];
            for(productItem item : updateCheckPiList){
                item.QuantityOnHand += pdAndQty2.get(item.Product2Id);
            }   


            System.debug('right before update checkPiList :: '+checkPiList);
            System.debug('right before update updateCheckPiList :: '+updateCheckPiList);

            update checkPiList;
            update updateCheckPiList;
        }



    }

    public void finish(Database.BatchableContext bc) {
        System.debug('속도측정 -------------------------------------------------- EX_SetProductItemToStorage_ba 끝 '+ System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
    }


    //Product2Id Set으로 받아서 product2Id와 적치장소 99A999가 상응하는 Product Item이 없는 경우 insert 해주는 method
    public void setProductItem(Set<String> productId){
        // String get99A999Id = [SELECT Id FROM Location WHERE Name = '99A999'][0].Id;
        System.debug('get99A999Id :: '+get99A999Id);

        List<productItem> piList = [SELECT Id, product2Id FROM productItem WHERE product2Id IN: productId AND locationId =: get99A999Id];
        System.debug('piList 이미있어서 insert안할리스트 :: '+piList);

        for(productItem item : piList){
            productId.remove(item.product2Id);
        }
        
        List<ProductItem> insertPi = new List<ProductItem>();
        if(!Test.isRunningTest()){
            if(productId.size()>0){
                for(String pdid : productId){
                    ProductItem tempPi;
                    tempPi.isMig__c = false;
                    tempPi.QuantityOnHand = 0;
                    tempPi.locationId = get99A999Id;
                    tempPi.Product2Id = pdid;
                    insertPi.add(tempPi);
                }
            }
            insert insertPi;
        }

        System.debug('새로추가된 Product Item :: '+insertPi);

    }    
}