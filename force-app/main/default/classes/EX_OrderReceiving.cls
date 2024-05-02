/**
 * Created by A80598 on 2023-03-08.
 */

 @RestResource(UrlMapping='/vi/api/ma/heroku/OrderReceiving')
 global with sharing class EX_OrderReceiving {
     /**
      * @AUTHOR I2MAX.SANGHUNYEO
      * @date  2023-03-08
      * @param
      * @description 입고확정 대상 데이터
      * @return
      */
 
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
         public String custrPoNo;
     }
 
     global class Output {
         public String code;
         public String message;
     }
 
     @HttpPost
     global static Output doPost() {
 
         Output objOutput = new Output();
         Input objInput = new Input();
         Savepoint sp = Database.setSavepoint();
         try {
             RestRequest request = RestContext.request;
 
             objOutput.code = '200';
             objOutput.message = 'Success';
 
             /*
             [참고] SI_FULFILLMENT_RECEIVING__c
             CARTON번호	CARTON_NO__c	Text(22)		False
             CJ연동번호	CUSTR_PO_NO__c	Text(30)		False
             CJ전송 아이템항번	ITEM_SEQ__c	Number(18, 0)		False
             CJ전송여부	IF_SEND_YN__c	Text(1)		False
             CJ전송일시	IF_SEND_DATE__c	Date/Time		False
             Created By	CreatedById	Lookup(User)		False
             Last Modified By	LastModifiedById	Lookup(User)		False
             Name	Name	Text(80)		True
             Owner	OwnerId	Lookup(User,Group)		True
             부서코드	DEPT_CODE__c	Text(8)		False
             부품번호	PART_NO__c	Text(16)		False
             사업부코드	DIV_CODE__c	Text(3)		False
             수신여부(입고확정수신)	IF_RESPONSE_YN__c	Text(1)		False
             수신일시(입고확정일시)	IF_RESPONSE_DATE__c	Date/Time		False
             에러내용	ERROR_DESC__c	Long Text Area(1000)		False
             에러코드	ERROR_CODE__c	Text(2)		False
             외부 ID	External_id__c	Text(255) (External ID) (Unique Case Insensitive)		True
             입고수량	RCV_QTY__c	Number(5, 0)		False
             입고항번	ORDER_SUB_SEQ__c	Number(3, 0)		False
             입고확정여부	RCV_CONFIRM_YN__c	Text(1)
             입고확정일시	RCV_CONFIRM_DATE__c	Date/Time
             주문번호	ORDER_NO__c	Text(10)
             주문항번	ORDER_SEQ__c	Number(3, 0)
             출고부서	SHIP_DEPT_CODE__c	Text(8)
              */
 
             /** 기본은 Trigger로 동작.
              * EndPoint 호출 시 에러 건('E') 재처리
              * SFDC_CONFIRM__c  'Y'처리완료, 'N'미처리, 'E'에러(재실행), 'F'에러(데이터문제)*/
             /** 입고확정대상건 조회 */
             String strQuery = '';
             strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('SI_FULFILLMENT_RECEIVING__c');
             strQuery += ' FROM SI_FULFILLMENT_RECEIVING__c ';
             strQuery += ' WHERE IF_SEND_YN__c = \'Y\' '; //CJ전송여부
             strQuery += ' AND RCV_CONFIRM_YN__c = \'N\' '; //입고확정여부
             strQuery += ' AND IF_RESPONSE_YN__c = \'Y\' '; //수신여부(입고확정수신)
             strQuery += ' AND SFDC_CONFIRM__c IN (\'N\',\'E\') '; //SFDC입고확정처리  'Y'처리완료, 'N'미처리, 'E'에러(재실행), 'F'에러(데이터문제)
 
             List<SI_FULFILLMENT_RECEIVING__c> siFulfillmentReceivingList = Database.query(strQuery);
 
             if(!siFulfillmentReceivingList.isEmpty()) {
                 System.debug('siFulfillmentReceivingList TOTAL : ' + siFulfillmentReceivingList.size());
                 List<String> transferIdList = new List<String>();
                 List<String> orderNoList = new List<String>();
                 List<String> partNoList = new List<String>();
                 for (sObject rcvConfirmData : siFulfillmentReceivingList) {
                     String transferId = getStringNotNull(rcvConfirmData.get('Product_Transfer_Id__c'));
                     String orderNo = getStringNotNull(rcvConfirmData.get('ORDER_NO__c'));
                     String partNo = getStringNotNull(rcvConfirmData.get('PART_NO__c'));
                     if(transferId != null && !transferId.equals('')){
                         transferIdList.add(transferId);
                     }
                     if(orderNo != null && !orderNo.equals('')){
                         orderNoList.add(orderNo);
                     }
                     if(partNo != null && !partNo.equals('')){
                         partNoList.add(partNo);
                     }
                 }
 
                 System.debug('transferIdList TOTAL : ' + transferIdList.size());
                 System.debug('orderNoList TOTAL : ' + orderNoList.size());
                 //SHIPPED_Date__c,
                 List<ProductTransfer> ptTotalList = [ SELECT id, RecordTypeId, RecordType.DeveloperName, ProductRequestId, ProductRequestLineItemId, DestinationLocationId, SourceLocationId, DestinationLocation.Name, SourceLocation.Name, QuantityReceived, Return_Order_Quantity__c,  MOVE_Type_Code__c, ReturnOrderLineItemId, Product2Id, fm_PART_NO__c, CARTON__c FROM ProductTransfer WHERE Id IN :transferIdList];
                 List<ProductRequest> prListTotal = [ SELECT id, RecordType.DeveloperName, Order_Number__c, Order_CUST_Id__c, DestinationLocationId, DestinationLocation.ServiceResource__c FROM ProductRequest WHERE Order_Number__c IN :orderNoList];
                 String strPartNoRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('PART_NO').getRecordTypeId();
                 List<Product2> productTotal = [ SELECT id, name FROM Product2 WHERE Name IN :partNoList AND RecordTypeId = :strPartNoRecordTypeId];
 
                 List<Map<String, Object>> listPT = new List<Map<String, Object>>();
                 for (sObject rcvConfirmData : siFulfillmentReceivingList) {
                     if(!''.equals(getStringNotNull(rcvConfirmData.get('CUSTR_PO_NO__c')))){ //CJ연동번호
                         Map<String, Object> ptMap = new Map<String, Object>();
                         String orderNo = getStringNotNull(rcvConfirmData.get('ORDER_NO__c'));
                         //Integer orderSeq = getIntegerNotNull(rcvConfirmData.get('ORDER_SEQ__c'));
                         String partNo = getStringNotNull(rcvConfirmData.get('PART_NO__c'));
                         //String cartonNo = getStringNotNull(rcvConfirmData.get('CARTON_NO__c')); //카톤넘버
                         String transferId = getStringNotNull(rcvConfirmData.get('Product_Transfer_Id__c'));
 
                         System.debug('transferId : ' + transferId);
 
                         ptMap.put('SI_FULFILLMENT_RECEIVING_ID',rcvConfirmData.get('Id'));
                         ptMap.put('ENDP_Code__c',getStringNotNull(rcvConfirmData.get('DIV_CODE__c'))); //ENDP_Code__c //사업부
                         ptMap.put('CARTON_Number__c',getStringNotNull(rcvConfirmData.get('CARTON_NO__c'))); //CARTON_Number__c //카툰번호
 
                         List<ProductTransfer> ptList = new List<ProductTransfer>();
                         if(!ptTotalList.isEmpty()){
                             for(ProductTransfer pt : ptTotalList){
                                 if(pt.Id == transferId){
                                     ptList.add(pt);
                                 }
                             }
                         }
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
                             ptMap.put('ProductRequestId',ptList[0].ProductRequestId); //ProductRequestId
                             ptMap.put('ProductRequestLineItemId',ptList[0].ProductRequestLineItemId); //ProductRequestLineItemId
                             ptMap.put('DestinationLocationId',ptList[0].DestinationLocationId); //DestinationLocationId
                             ptMap.put('stockPlace',ptList[0].DestinationLocation.Name); //stockPlace (입고하려는 적치장소 Location Name)
                             // ((Map<Object, Object>)mapPT.get('RecordType')).get('DeveloperName')
                             ptMap.put('RecordTypeId',ptList[0].RecordTypeId); //RecordType
                             ptMap.put('QuantityReceived',ptList[0].QuantityReceived); //QuantityReceived
                             ptMap.put('quantityReturned',ptList[0].Return_Order_Quantity__c); //quantityReturned
                             //ptMap.put('SHIPPED_Date__c',ptList[0].SHIPPED_Date__c); //SHIPPED_Date__c
                             ptMap.put('MOVE_Type_Code__c',ptList[0].MOVE_Type_Code__c); //MOVE_Type_Code__c
                             ptMap.put('ReturnOrderLineItemId',ptList[0].ReturnOrderLineItemId);
                             //ptMap.put('Product2Id',ptList[0].Product2Id);
                             ptMap.put('Product2Id',product2Id);
                             ptMap.put('CARTON__c',ptList[0].CARTON__c); // CARTON__c //카툰아이디
                             //ptMap.put('CARTON__c',cartonNo); // CARTON__c //카툰아이디
 
                             //ProductRequest pr = [ SELECT id, RecordType.DeveloperName, Order_CUST_Id__c, DestinationLocationId FROM ProductRequest WHERE Order_Number__c = :orderNo LIMIT 1 ];
                             ProductRequest pr = new ProductRequest();
                             List<ProductRequest> prList = new List<ProductRequest>();
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
 
                 System.debug('befor update siFulfillmentReceivingList');
                 update siFulfillmentReceivingList;
 
             }else{ //siFulfillmentReceivingList.isEmpty
                 objOutput.code = '500';
                 objOutput.message = '입고확정대상 없음. SI_FULFILLMENT_RECEIVING__c';
                 Database.rollback(sp);
             }
         }catch (JSONException je){
             objOutput.code = '500';
             objOutput.message = 'reason:'+je.getMessage();
             Database.rollback(sp);
         } catch (NullPointerException ne){
             objOutput.code = '500';
             objOutput.message = ' 조회된 값이 없습니다.  '+ ne.getMessage();
             Database.rollback(sp);
         } catch (Exception e) {
             objOutput.code = '500';
             objOutput.message =  e.getMessage();
             Database.rollback(sp);
         }
 
         return objOutput;
     }
 
     /**
      * @description   대상이 입고대상인 조회 목록 중 선택된 목록을 입고확정 시키는 작업 실행
      *                센터 -> 적치장소로 보내는 ProductTransfer Object 생성
      * @param  listPT 선택된 목록의 ProductTransfer ID, SourceLocation ID, DestinationLocation ID가 담겨진 List
      * @return void
      */
     public static List<ProductTransfer> doSaveReceivingItems(List<Map<String, Object>> listPT){
         system.debug('doSaveReceivingItems');
 
         List<ProductTransfer> listUpdatePT = new List<ProductTransfer>();
         List<ProductTransfer> listInsertPT = new List<ProductTransfer>();
         List<ProductItem> listUpsertPItem = new List<ProductItem>();
 
         Set<Id> setProduct2Id = new Set<Id>();
         Set<Id> setDestinationLocationId = new Set<Id>();
         //Set<String> setStockPlace = new Set<String>();
 
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
             }
             if(mapPT.get('DestinationLocationId') != null){
                 String dId = getStringNotNull(mapPT.get('DestinationLocationId'));
                 setDestinationLocationId.add(dId);
             }
             /*if(mapPT.get('stockPlace') != null){
                 String sId = getStringNotNull(mapPT.get('stockPlace'));
                 setStockPlace.add(sId);
             }*/
         }
 
         update listUpdatePT;
 
         List<ProductItem> listPItem = new List<ProductItem>();
 
         // 입고하려는 센터 내 재고 조회
         listPItem = [
                 SELECT Id
                         , Product2Id
                         , LocationId
                         , DEPT_CODE__c
                 FROM ProductItem
                 WHERE Product2Id IN :setProduct2Id
                 AND LocationId IN :setDestinationLocationId
                 AND IsDeleted__c = false
         ];
 
         Map<String, ProductItem> mapProduct2IdAndLocationId_objPItem = new Map<String, ProductItem>();
         List<String> deptCodeList = new List<String>();
 
         if(!listPItem.isEmpty()){
             for(ProductItem objPItem : listPItem){
                 mapProduct2IdAndLocationId_objPItem.put(String.valueOf(objPItem.Product2Id) + String.valueOf(objPItem.LocationId), objPItem); //Id, Product2Id, LocationId
                 deptCodeList.add(String.valueOf(objPItem.DEPT_CODE__c));
             }
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
             objAddPT.QuantityReceived = getDecimalNotNull(mapPT.get('QuantityReceived'));
             objAddPT.Return_Order_Quantity__c = getDecimalNotNull(mapPT.get('quantityReturned')); // 반품수량
             // objAddPT.IsSent = true;
             //objAddPT.IsReceived = true; //센터 -> 적치장소 true 세팅시 Standard 오류 (센터의 재고가 0이라 오류)
             objAddPT.IsReceived = false;
             objAddPT.Status = '5';
             //objAddPT.RSV_Date__c = getDateWithNull(mapPT.get('SHIPPED_Date__c'));
             objAddPT.RSV_Quantity__c = (mapPT.get('quantityReturned') != null) ?  getDecimalNotNull(mapPT.get('QuantityReceived')) + getDecimalNotNull(mapPT.get('quantityReturned')) :  getDecimalNotNull(mapPT.get('QuantityReceived')); // 입고수량
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
 
             system.debug('objAddPT for insert :: ' + objAddPT);
 
             listInsertPT.add(objAddPT);
         }
 
         system.debug('before insert ProductTransfer');
 
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
                 if(pr.DestinationLocation.ServiceResource__c != null || pr.Order_CUST_Id__c != null){
                     if(mapPT.get('ProductRequestLineItemId') != null){
                         setProductRequestLineItemId_RESV.add(getStringNotNull(mapPT.get('ProductRequestLineItemId')));
                     }
                 }
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
 
         // 예약 부품인 경우
         // 적치장소에서 받은 재고의 약속수량 더하기
         if(!setProduct2Id.isEmpty() && !setLocationId.isEmpty()){
             listPItem = [
                     SELECT Id, RESRV_QTY__c, LocationId, Product2Id, QuantityOnHand
                     FROM ProductItem
                     WHERE Product2Id IN :setProduct2Id
                     AND LocationId IN :setLocationId
                     AND IsDeleted__c = false
             ];
         }
 
         Map<String, ProductItem> map_PItemId_objPItem_RESV = new Map<String, ProductItem>();
 
         if(!listPItem.isEmpty()){
             system.debug('적치장소 재고 :: ' + listPItem);
             for(ProductItem objPItem : listPItem){
                 if(objPItem.Product2Id != null && objPItem.LocationId != null){
                     map_PItemId_objPItem_RESV.put(getStringNotNull(objPItem.Product2Id) + getStringNotNull(objPItem.LocationId), objPItem);
                 }
             }
         }
         system.debug('map_PItemId_objPItem_RESV :: ' + map_PItemId_objPItem_RESV);
         system.debug('listInsertPT size : ' + listInsertPT.size());
         if(!listInsertPT.isEmpty()){
             List<ProductRequestLineItem> updatePrliList = new List<ProductRequestLineItem>();
             List<String> prliIdList = new List<String>();
             for(ProductTransfer objPT : listInsertPT){
                 if(objPT.ProductRequestLineItemId != null){
                     prliIdList.add(objPT.ProductRequestLineItemId);
                 }
             }
 
             List<ProductRequestLineItem> prliListTotal = new List<ProductRequestLineItem>();
             if(!prliIdList.isEmpty()){
                 //prliListTotal = [SELECT Id, QuantityRequested, ENDP_RSV_Quantity__c, RSRV_Number__c FROM ProductRequestLineItem WHERE id IN :prliIdList];
                 String strQuery = '';
                 strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
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
 
             List<String> rsrvNoList = new List<String>();
             if(!prliListTotal.isEmpty()){
                 for(ProductRequestLineItem getprli : prliListTotal){
                     rsrvNoList.add(getprli.RSRV_Number__c);
                 }
             }
 
             List<ProductRequestLineItem> oriPrliListTotal = new List<ProductRequestLineItem>();
             if(!rsrvNoList.isEmpty()){
                 oriPrliListTotal = [SELECT Id, Appointment_Status__c,RSRV_Number__c, BASIS_Parts_Number__c FROM ProductRequestLineItem WHERE (RecordType.DeveloperName = 'Consumable' OR RecordType.DeveloperName = 'CareSupplies') AND RSRV_Number__c IN :rsrvNoList];
             }
 
             List<ProductRequestLineItem> prliListforExe = new List<ProductRequestLineItem>();
 
             List<ProductTransfer> ptList = new List<ProductTransfer>();
             if(!listInsertPT.isEmpty()){
                 List<String> liptIdList = new List<String>();
                 for(ProductTransfer pt : listInsertPT){
                     liptIdList.add(pt.Id);
                 }
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
 
             for(ProductTransfer objPT : ptList){
                 String mapKey = '';
                 if(objPT.Product2Id != null && objPT.DestinationLocationId != null){
                     mapKey = getStringNotNull(objPT.Product2Id) + getStringNotNull(objPT.DestinationLocationId);
                 }
                 if(!mapKey.equals('')){
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
                                 if(tprli.RSRV_Number__c == prli.RSRV_Number__c){
                                     oriPrliList.add(tprli);
                                 }
                             }
                         }
                         ProductRequestLineItem oriPrli = new ProductRequestLineItem();
                         if(!oriPrliList.isEmpty()){
                             oriPrli = oriPrliList[0];
                         }
 
                         if(objProductItem != null){
                             if(objProductItem.RESRV_QTY__c == null){
                                 objProductItem.RESRV_QTY__c = 0;
                             }
                             objProductItem.RESRV_QTY__c += getIntegerNotNull(objPT.QuantityReceived);
                             objProductItem.QuantityOnHand += getIntegerNotNull(objPT.QuantityReceived);
 
 
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
                             prliListforExe.add(prli);
 
 
                             //system.debug('objProductItem :: ' + objProductItem);
 
                             map_PItemId_objPItem_RESV.put(mapKey, objProductItem);
 
                             /** 사업부입고수량 증가 */
                             /** 약속 입고 케이스 - 주문 정보 업데이트 : 사업부입고수량 == 요청수량 ENDP_RSV_Quantity__c
                                 약속상태 업데이트 : 입고완료
                                 주문상태 업데이트 : 상품준비중 */
                             Decimal endpRsvQ = getIntegerNotNull(prli.ENDP_RSV_Quantity__c) + getIntegerNotNull(objPT.QuantityReceived);
                             system.debug('prli.ENDP_RSV_Quantity__c : ' + getIntegerNotNull(prli.ENDP_RSV_Quantity__c));
                             system.debug('objPT.QuantityReceived : ' + getIntegerNotNull(objPT.QuantityReceived));
                             system.debug('endpRsvQ : ' + endpRsvQ);
                             //if(getIntegerNotNull(prli.ENDP_RSV_Quantity__c) != getIntegerNotNull(objPT.QuantityReceived)) {
                                 /** 대치부품 처리 */
                             system.debug('objPT.fm_PART_NO__c : ' + objPT.fm_PART_NO__c);
                             system.debug('prli.BASIS_Parts_Number__c : ' + oriPrli.BASIS_Parts_Number__c);
                                 if(objPT.fm_PART_NO__c != null && oriPrli.BASIS_Parts_Number__c != null && objPT.fm_PART_NO__c != oriPrli.BASIS_Parts_Number__c){ //대치부품일때
                                     System.debug('4444');
                                     String appStatus = '';
                                     if(prli.QuantityRequested <= endpRsvQ){
                                         appStatus = '입고완료';
                                         endpRsvQ = prli.QuantityRequested;
                                     }else{
                                         //appStatus = '일부입고';
                                     }
                                     ProductRequestLineItem uprli1 = new ProductRequestLineItem();
                                     uprli1.Id = objPT.ProductRequestLineItemId;
                                     uprli1.ENDP_RSV_Quantity__c = endpRsvQ;
                                     uprli1.ENDP_Code__c = objPT.ENDP_Code__c;
                                     uprli1.Product2Id = objPT.Product2Id;
                                     uprli1.PART_NO__c = objPT.fm_PART_NO__c;
                                     updatePrliList.add(uprli1);
 
                                     ProductRequestLineItem uprli2 = new ProductRequestLineItem();
                                     uprli2.Id = oriPrli.Id;
                                     uprli2.ENDP_RSV_Quantity__c = endpRsvQ;
                                     uprli2.ENDP_Code__c = objPT.ENDP_Code__c;
                                     uprli2.Product2Id = objPT.Product2Id;
                                     uprli2.PART_NO__c = objPT.fm_PART_NO__c;
                                     if(appStatus != null && !appStatus.equals('')){
                                         uprli2.Appointment_Status__c = appStatus;
                                     }
                                     updatePrliList.add(uprli2);
                                 }else{ //대치부품이 아닐때
                                     System.debug('6666');
                                     String appStatus = '';
                                     if(prli.QuantityRequested <= endpRsvQ){
                                         appStatus = '입고완료';
                                         endpRsvQ = prli.QuantityRequested;
                                     }else{
                                         //appStatus = '일부입고';
                                     }
                                     ProductRequestLineItem uprli1 = new ProductRequestLineItem();
                                     uprli1.Id = objPT.ProductRequestLineItemId;
                                     uprli1.ENDP_RSV_Quantity__c = endpRsvQ;
                                     uprli1.ENDP_Code__c = objPT.ENDP_Code__c;
                                     updatePrliList.add(uprli1);
 
                                     ProductRequestLineItem uprli2 = new ProductRequestLineItem();
                                     uprli2.Id = oriPrli.Id;
                                     uprli2.ENDP_RSV_Quantity__c = endpRsvQ;
                                     uprli2.ENDP_Code__c = objPT.ENDP_Code__c;
                                     if(appStatus != null && !appStatus.equals('')){
                                         uprli2.Appointment_Status__c = appStatus;
                                     }
                                     updatePrliList.add(uprli2);
                                 }
                             //}
                         }
                     }
                 }
             }
             system.debug('Before update updatePrliList');
             System.debug('updatePrliList :::: ' + updatePrliList);
             if(!updatePrliList.isEmpty()){
                 update updatePrliList;
             }
             if(!prliListforExe.isEmpty()){
                 EX_RsrvUtil.execApplyProductItemMulti('AD', prliListforExe); //센터 약속미입고(-)
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
     public static Map<String, Object> ConsumableOrderReceive(List<String> ptIdList){
         Map<String, Object> returnMap = new Map<String, Object>();
         String resultStat = 'SUCCESS';
         String resultMessage = '';
 
         if(!ptIdList.isEmpty()){
             Savepoint sp = Database.setSavepoint();
             try {
                 
                 //예약주문 맵
                 Map<String, ProductRequestLineItem> resrvMap = new Map<String, ProductRequestLineItem>();
                 //원주문 맵
                 Map<String, ProductRequestLineItem> originMap = new Map<String, ProductRequestLineItem>();
                 //업데이트 중복방지용 맵
                 Map<String, ProductRequestLineItem> updateMap = new Map<String, ProductRequestLineItem>();
                 //재고 set
                 Set<String> itemSet = new Set<STring>();
                 //재고 맵
                 Map<String, String> itemMap = new Map<String, String>();
 
                 //입고 수기처리한 재고수불 리스트
                 List<ProductTransfer> ptList = [SELECT Id, ProductRequestLineItem.RecordType.DeveloperName, Order_Number__c, Order_SEQ__c, QuantityReceived, fm_PART_NO__c, ENDP_Code__c, Product2Id, ProductRequestLineItemId, ProductRequestLineItem.SR_RESRV_PART_Id__c, ProductRequestLineItem.ENDP_RSV_Quantity__c, ProductRequestLineItem.fm_PART_NO__c , ProductRequestLineItem.QuantityRequested  FROM ProductTransfer WHERE Id = :ptIdList];
                 System.debug('ptList :::: ' + ptList.size());
                 System.debug('ptList :::: ' + ptList);
                 Set<String> resrvSet = new Set<String>();
                 //예약주문 리스트
                 for (ProductTransfer pObj : ptList) {
                     ProductRequestLineItem tempPrli = new ProductRequestLineItem();
                     tempPrli.Id = pObj.ProductRequestLineItemId;
                     tempPrli.ENDP_RSV_Quantity__c = pObj.ProductRequestLineItem.ENDP_RSV_Quantity__c;
                     tempPrli.QuantityRequested = pObj.ProductRequestLineItem.QuantityRequested;
 
                    if (pObj.ProductRequestLineItem.RecordType.DeveloperName != 'REGULAR') {
                        resrvSet.add(pObj.ProductRequestLineItem.SR_RESRV_PART_Id__c);
                        resrvMap.put(pObj.ProductRequestLineItem.SR_RESRV_PART_Id__c + '_' + pObj.ProductRequestLineItem.fm_PART_NO__c, tempPrli);
                    } else {
                        resrvMap.put(pObj.Order_Number__c + '_' + String.valueOf(pObj.Order_SEQ__c), tempPrli);
                    }
 
                     itemSet.add(pObj.Product2Id);
                 }
 
                 //원주문 리스트
                 List<ProductRequestLineItem> oriPrliList = new List<ProductRequestLineItem>();
                 if (resrvSet.size() > 0) {
                    oriPrliList = [SELECT Id, SR_RESRV_PART_Id__c, Appointment_Status__c, Order_CHNL_Type_Code__c, RecordType.DeveloperName, fm_PART_NO__c, 
                                            ParentId, Parent.Order_CUST_TPNO_1__c, BASIS_Parts_Number__c, Order_Number__c, QuantityRequested, CreatedById, ENDP_RSV_Quantity__c, Consumables_Order_Status__c 
                                    FROM ProductRequestLineItem 
                                    WHERE RecordType.DeveloperName IN ('Consumable', 'CareSupplies') AND SR_RESRV_PART_Id__c = :resrvSet];
                 }

                 System.debug('oriprliList :::: ' + oriPrliList);
                 if (oriPrliList.size() > 0) {
                     for (ProductRequestLineItem oObj : oriPrliList) {
                         originMap.put(oObj.SR_RESRV_PART_Id__c + '_' + oObj.fm_PART_NO__c, oObj);
                     }
                 }
 
                 List<ProductItem> piList = [SELECT ID,Product2Id, Product2.Name FROM ProductItem WHERE Product2Id = :itemSet AND Location.Name = :System.Label.EX_Location];
                 if (piList.size() > 0) {
                     for (ProductItem piObj : piList) {
                         itemMap.put(piObj.Product2Id, piObj.Id);
                     }
                 }
                 System.debug('resrvMap :::: ' + resrvMap);
                 System.debug('originMap :::: ' + originMap);

                 Map<String, Boolean> parentMap = new Map<String, Boolean>();
                 if (ptList.size() > 0) {
                     for (ProductTransfer pObj : ptList) {
 
                        ProductRequestLineItem originPrli;
                        ProductRequestLineItem resrvPrli;
                        String mapKey;
                        
                        if (pObj.ProductRequestLineItem.RecordType.DeveloperName != 'REGULAR') {
                            mapKey = pObj.ProductRequestLineItem.SR_RESRV_PART_Id__c + '_' + pObj.ProductRequestLineItem.fm_PART_NO__c;

                            if (originMap.containsKey(mapKey)) {
                                originPrli = originMap.get(mapKey);
                            }
                            if (resrvMap.containsKey(mapKey)) {
                                resrvPrli = resrvMap.get(mapKey);
                            }
                        } else {
                            mapKey = pObj.Order_Number__c + '_' + String.valueOf(pObj.Order_SEQ__c);

                            if (resrvMap.containsKey(mapKey)) {
                                resrvPrli = resrvMap.get(mapKey);
                            }
                        }
                            
                        //예약주문 및 원주문 모두 존재 할 경우 조치
                        if (pObj.ProductRequestLineItem.RecordType.DeveloperName != 'REGULAR') {

                            Decimal endpRsvQ = getIntegerNotNull(pObj.QuantityReceived);
                            Decimal endpRsvQTY = getIntegerNotNull(originPrli.ENDP_RSV_Quantity__c);
                            Decimal qtyRequested = getIntegerNotNull(originPrli.QuantityRequested);
                            Decimal resQtyRequested = getIntegerNotNull(resrvPrli.QuantityRequested);

                            //입고상태
                            String appStatus = '';
                            
                            System.debug('endpRsvQTY :::: ' + endpRsvQTY);
                            System.debug('endpRsvQ :::: ' + endpRsvQ);
                            System.debug('resQtyRequested :::: ' + resQtyRequested);

                            //24.02.07 gw.lee
                            //입고 완료되었을 때, 결제 완료 상태일 경우, 상품준비중으로 변경 로직 추가
                            if (resQtyRequested <= endpRsvQTY + endpRsvQ) {
                                originPrli.Appointment_Status__c = '입고완료';

                                endpRsvQ = resrvPrli.QuantityRequested - endpRsvQTY; 
                                if (originPrli.Consumables_Order_Status__c == '002') {
                                    originPrli.Consumables_Order_Status__c = '006';
                                } else if (originPrli.Consumables_Order_Status__c == '000') {
                                    parentMap.put(originPrli.parentId, true);
                                }
                            }

                            //원주문 및 예약주문 출하정보 업데이트
                            //사업부 출하 시, 대치품으로 들어왔을 경우
                            if (pObj.fm_PART_NO__c != originPrli.BASIS_Parts_Number__c) {
                                originPrli.Product2Id = pObj.Product2Id;
                                originPrli.PART_NO__c = pObj.fm_PART_NO__c;

                                if (itemMap.get(pObj.Product2Id) != null) {
                                    originPrli.ProductItem__c = itemMap.get(pObj.Product2Id);
                                }

                                //resrvPrli.Product2Id = pObj.Product2Id;
                                //resrvPrli.PART_NO__c = pObj.fm_PART_NO__c;
                            }

                            originPrli.ENDP_RSV_Quantity__c = endpRsvQTY + endpRsvQ;
                            // originPrli.Adjust_Quantity__c = endpRsvQTY + endpRsvQ;
                            originPrli.PART_NO__c = pObj.fm_PART_NO__c;

                            resrvPrli.ENDP_RSV_Quantity__c = endpRsvQTY + endpRsvQ;
                            // resrvPrli.Adjust_Quantity__c = endpRsvQTY + endpRsvQ;
                            resrvPrli.PART_NO__c = pObj.fm_PART_NO__c;
                        
                            //맵은 참조형이 아니므로 분할출고건 대비 데이터 변경 조치
                            originMap.put(mapKey, originPrli);
                            resrvMap.put(mapKey, resrvPrli);

                            //분할출고인 ProductTransfer 동시 수기입고처리되는 케이스 방지
                            updateMap.put(originPrli.Id, originPrli);
                            updateMap.put(resrvPrli.Id, resrvPrli);
                        //24.03.07 gw.lee
                        //정기입고건 예외 처리 추가  
                         } else if (pObj.ProductRequestLineItem.RecordType.DeveloperName == 'REGULAR') {
                                Decimal endpRsvQ = getIntegerNotNull(pObj.QuantityReceived);
                                Decimal endpRsvQTY = getIntegerNotNull(resrvPrli.ENDP_RSV_Quantity__c);
                                Decimal qtyRequested = getIntegerNotNull(resrvPrli.QuantityRequested);

                                if (resrvMap.containsKey(mapKey)) {
                                    resrvPrli = resrvMap.get(mapKey);
                                }

                                resrvPrli.ENDP_RSV_Quantity__c = endpRsvQTY + endpRsvQ;
                                // resrvPrli.Adjust_Quantity__c = endpRsvQTY + endpRsvQ;
                                resrvPrli.PART_NO__c = pObj.fm_PART_NO__c;

                                resrvMap.put(mapKey, resrvPrli);
                                updateMap.put(resrvPrli.Id, resrvPrli);
                         }
                     }
                 }
                 
                 System.debug('parentMap :::: ' + parentMap);
                 System.debug('updateMap :::: ' + updateMap);
                 if (updateMap.size() > 0) {
                     update updateMap.values();
                     
                     //생성 List
                     List<EX_Message__c> alarmList = new List<EX_Message__c>();
 
                     String templateCode = 'SVC_LGE_MACN_S020';
                     TemplateMgmt__c template = [SELECT Id, Content_c__c, Title__c, TemplateCode__c
                                                 FROM TemplateMgmt__c
                                                 WHERE TemplateCode__c=:templateCode][0];
             
                     List<TemplateParams__c> templateParamList = [SELECT Id, Name, FieldApi__c
                                                                     FROM TemplateParams__c
                                                                     WHERE TemplateMgmt__c=:template.Id];
 
                     //24.01.29 gw.lee
                     //알림톡 품목단위 전송 ==> 주문단위 전송 변경
                     Set<String> parentList = new Set<String>();
                     //입고완료된 주문정보 검색
                     for (ProductRequestLineItem prliObj : originMap.values()) {
                         parentList.add(prliObj.ParentId);
                     }
 
                     List<ProductRequest> prliList = [SELECT Id, (SELECT ID, Appointment_Status__c 
                                                                     FROM ProductRequestLineItems 
                                                                     WHERE Order_CHNL_Type_Code__c = 'V' AND Consumables_Order_Status__c NOT IN ('003', '004', '005')) 
                                                     FROM ProductRequest 
                                                     WHERE Id = :parentList AND RecordType.DeveloperName = 'Consumable'];
                     Map<String, Boolean> kakaoCheckMap = new Map<String, Boolean>(); //주문의 모든 품목 입고완료 체크
                     Map<String, Integer> kakaoSizeMap = new Map<String, Integer>(); //부품 수량 체크
                     Map<String, Boolean> kakaoSendMap = new Map<String, Boolean>(); //알림 전송 여부 체크
                     for (ProductRequest pObj : prliList) {
                         kakaoSizeMap.put(pObj.Id, pObj.ProductRequestLineItems.size());
                         kakaoSendMap.put(pObj.Id, false);
                         
                         if (pObj.ProductRequestLineItems != null) {
                             for (ProductRequestLineItem prObj : pObj.ProductRequestLineItems) {
                                 System.debug('prObj :::: ' + prObj);
                                 System.debug('prObj :::: ' + prObj.Appointment_Status__c);
                                 if (kakaoCheckMap.containsKey(pObj.Id) && prObj.Appointment_Status__c != '입고완료') {
                                     kakaoCheckMap.put(pObj.Id, false);
     
                                     break;
                                 } else {
                                     if (prObj.Appointment_Status__c == '입고완료') {
                                         kakaoCheckMap.put(pObj.Id, true);
                                     } else {
                                         kakaoCheckMap.put(pObj.Id, false);
     
                                         break;
                                     }
                                 }
                             }
                         } else {
                             kakaoCheckMap.put(pObj.Id, false);
                         }
                     }
                     //주석삭제
                     System.debug('kakaoCheckMap :::: ' + kakaoCheckMap);
                     System.debug('kakaoSendMap :::: ' + kakaoSendMap);
                     System.debug('kakaoSizeMap :::: ' + kakaoSizeMap);
                     for (ProductRequestLineItem prliObj : originMap.values()) {
                         //주석삭제
                         System.debug('prliObj.Order_CHNL_Type_Code__c :::: ' + prliObj.Order_CHNL_Type_Code__c);
                         System.debug('prliObj.RecordType.DeveloperName :::: ' + prliObj.RecordType.DeveloperName);
                         System.debug('prliObj.Appointment_Status__c :::: ' + prliObj.Appointment_Status__c);
                         if (prliObj.Order_CHNL_Type_Code__c == 'V' &&
                             prliObj.RecordType.DeveloperName == 'Consumable' &&
                             prliObj.Appointment_Status__c == '입고완료' &&
                             prliObj.Consumables_Order_Status__c == '000') {
                         
                            //  System.debug('kakaoCheckMap true :::: ' + kakaoCheckMap.get(prliObj.ParentId));
                            //  System.debug('kakaoSendMap true :::: ' + !kakaoSendMap.get(prliObj.ParentId));
                             if (kakaoCheckMap.get(prliObj.ParentId) != null && kakaoSendMap.get(prliObj.ParentId) != null) {
                                 if (kakaoCheckMap.get(prliObj.ParentId) && !kakaoSendMap.get(prliObj.ParentId)) {
                                     
                                     String phoneNoStr = prliObj.Parent.Order_CUST_TPNO_1__c;
                                     String partNo = prliObj.BASIS_Parts_Number__c;
                                     if (kakaoSizeMap.get(prliObj.ParentId) > 1) {
                                         partNo = partNo + ' 외 ' + String.valueOf(kakaoSizeMap.get(prliObj.ParentId) - 1) + '건';
                                     }
                                     String orderNumber = prliObj.Order_Number__c;
                                     
                                     TemplateMgmt__c templateTemp = template.clone();
                                     
                                     EX_Message__c sampleAlarm = new EX_Message__c();
                                     sampleAlarm.Label1__c = orderNumber;
                                     sampleAlarm.Label2__c = partNo;
                                     Map<String, Object> populateMap = sampleAlarm.getPopulatedFieldsAsMap();
     
                                     EX_Message__c alarm = new EX_Message__c();
     
                                     IF_CM_SFDC_KAKAO.InputParam inputParam = EX_MessageUtil.getInputParamForKaKao(templateTemp, templateParamList, populateMap);
                                     
                                     alarm.Label1__c = inputParam.templateCode;
                                     alarm.Label2__c = orderNumber;
                                     alarm.Label3__c = '소모품 입고';
                                     alarm.Label4__c = partNo;
                                     alarm.Label5__c = '소모품 입고';
                                     alarm.Label6__c = phoneNoStr;
                                     alarm.Label7__c = String.valueOf(inputParam.sendAt); //신규 셋팅 필요
                                     alarm.Label8__c = 'EX_OrderReceiving_ba';
                                     alarm.Label9__c = 'N';
                                     //24.02.15 gw.lee
                                     //법인폰 유무 체크를 위한 주문 생성자 (최초 주문자) ID 전달
                                     alarm.Label10__c = prliObj.CreatedById;
     
                                     alarmList.add(alarm);
                                     System.debug('alarm :::: ' + alarm);
                                     kakaoSendMap.put(prliObj.ParentId, true);
                                 }
                             }
                         }
                     }
 
                     if (alarmList.size() > 0) {
                         insert alarmList;
                     }
                 }


                 System.debug('parentMap.size()' + parentMap);
                 if (parentMap.size() > 0) {
                    List<ProductRequestLineItem> checkList = [SELECT ID, parentId, Consumables_Order_Status__c, Appointment_Status__c FROM ProductRequestLineItem WHERE parentId = :parentMap.keySet() AND RecordType.DeveloperName IN ('Consumable', 'CareSupplies')];

                    Map<String, List<String>> childMap = new Map<String, List<String>>();
                    for (ProductRequestLineItem pObj : checkList) {
                        if (pObj.Appointment_Status__c != '입고완료' || pObj.Consumables_Order_Status__c == '003' || pObj.Consumables_Order_Status__c == '004' || pObj.Consumables_Order_Status__c == '005') {
                            parentMap.put(pObj.parentId, false);
                        }
                    }

                    List<String> prList = new List<String>();
                    for (String parentId : parentMap.keySet()) {
                        if (parentMap.get(parentId) == true) {
                            prList.add(parentId);
                        }
                    }
                    System.debug('prList.size()' + prList);

                    if (prList.size() > 0)  {
                        List<ProductRequestLineItem> updateList = [SELECT ID, Consumables_Order_Status__c FROM ProductRequestLineItem WHERE parentId = :prList];
                        System.debug('updateList.size()' + updateList);
                        
                        for (ProductRequestLineItem uObj : updateList) {
                            uObj.Consumables_Order_Status__c = '001';
                        }
                        update updateList;
                    }

                 }
             }catch (JSONException je){
                 resultStat = 'FAIL';
                 resultMessage = je.getMessage();
                 Database.rollback(sp);
             } catch (NullPointerException ne){
                 resultStat = 'FAIL';
                 resultMessage = ne.getMessage();
                 Database.rollback(sp);
             } catch (Exception e) {
                 resultStat = 'FAIL';
                 resultMessage = e.getMessage();
                 Database.rollback(sp);
             }
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