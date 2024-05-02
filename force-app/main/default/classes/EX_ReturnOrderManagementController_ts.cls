/**
 * Created by MS on 2023-04-27.
 */

 @IsTest
 private class EX_ReturnOrderManagementController_ts {
     @IsTest
     static void test01() {
         Test.startTest();
 
         EX_TestDataUtil.getSrSale(false);
         EX_TestDataUtil.srSale.SALE_Number__c = 'A000104989';
         EX_TestDataUtil.getProductRequestLineItem(false);
         EX_TestDataUtil.baseProductRequestLineItem.SR_SALE__c = EX_TestDataUtil.getSrSale(true).Id;
 
         EX_ReturnOrderManagementController.doSendKakaoMessage();
 
         EX_TestDataUtil.getDept(false, null);
         EX_TestDataUtil.dept.CLOSE_YN__c = 'N';
         EX_TestDataUtil.dept.DEPT_TYPE_SECOND__c = 'D';
         EX_TestDataUtil.getDept(true, null);
 
         EX_ReturnOrderManagementController.doGetInitData();
        
 
         EX_TestDataUtil.getReturnOrderLineItem(false);
         EX_TestDataUtil.baseReturnOrderLineItem.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
         EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '101';
         EX_TestDataUtil.baseReturnOrderLineItem.Return_Order_Request_DTM__c = Datetime.now();
         EX_TestDataUtil.baseReturnOrderLineItem.CONSIGNEE_Name__c = 'test';
         EX_TestDataUtil.baseReturnOrderLineItem.CONSIGNEE_TPNO__c = '01012345678';
         EX_TestDataUtil.baseReturnOrderLineItem.COLLECTION_YN__c = true;
         EX_TestDataUtil.baseReturnOrderLineItem.SUB_Order_Number__c = '34243243131';
         
 
         Map<String, Object> mapSearchParam = new Map<String, Object>();
         mapSearchParam.put('orderNo', EX_TestDataUtil.getReturnOrderLineItem(true).Order_Number__c);
         mapSearchParam.put('recordLimit', 1);
         mapSearchParam.put('pageOffset', 0);
         mapSearchParam.put('isSearchBtnClick', true);
         EX_ReturnOrderManagementController.doGetSearchData(mapSearchParam, EX_TestDataUtil.getReturnOrderLineItem(true).COLLECTION_YN__c);
         mapSearchParam.remove('orderNo');
         mapSearchParam.put('orderChannel', EX_TestDataUtil.getReturnOrderLineItem(true).Order_CHNL_TYPE_Code__c);
         
         mapSearchParam.put('baseDateStart', Datetime.now());
         mapSearchParam.put('contactName', EX_TestDataUtil.getReturnOrderLineItem(true).CONSIGNEE_Name__c);
         mapSearchParam.put('contactPhone', EX_TestDataUtil.getReturnOrderLineItem(true).CONSIGNEE_TPNO__c);
         EX_ReturnOrderManagementController.doGetSearchData(mapSearchParam, EX_TestDataUtil.getReturnOrderLineItem(true).COLLECTION_YN__c);
 
         List<Map<String, Object>> input = new List<Map<String, Object>>();
 
         Map<String, Object> selectedRows = new Map<String, Object>();
         selectedRows.put('Id', EX_TestDataUtil.getReturnOrderLineItem(true).Id);
         input.add(selectedRows);
 
         EX_ReturnOrderManagementController.doCancelReturn(input);
         try {

  
             selectedRows.put('Good_Quality_Quantity', '1');
             selectedRows.put('Disposal_Quantity', '0');
             selectedRows.put('Disposal_Reason', 'test');
             EX_ReturnOrderManagementController.doHandleDisposal(input);
 
             selectedRows.put('Good_Quality_Quantity', '0');
             selectedRows.put('Disposal_Quantity', '1');
             EX_ReturnOrderManagementController.doHandleDisposal(input);

            
             List<Map<String, Object>> input2 = new List<Map<String, Object>>();
             
             EX_ReturnOrderManagementController.doHandleDisposal(input2);
 
         } catch (Exception e) {
             System.debug(e.getMessage());
         }
         EX_ReturnOrderManagementController.doGetConsigneeInfo(EX_TestDataUtil.getReturnOrder(false).Id);
 
         Test.stopTest();
     }
 
     @IsTest
     static void test02() {
         Test.startTest();
         EX_TestDataUtil.getCarePlusOrder(true);
         EX_TestDataUtil.careplusOrder.TRANS_TYPE__c = 'R';
         update EX_TestDataUtil.careplusOrder;

         EX_TestDataUtil.getSrSale(false);
         EX_TestDataUtil.srSale.SALE_Number__c = 'A000104989';
         EX_TestDataUtil.getProductRequestLineItem(false);
         EX_TestDataUtil.baseProductRequestLineItem.SR_SALE__c = EX_TestDataUtil.getSrSale(true).Id;
 
         EX_TestDataUtil.getReturnOrder(false);
         EX_TestDataUtil.baseReturnOrder.ProductRequestId = EX_TestDataUtil.getProductRequest(true).Id;
         
         EX_TestDataUtil.getReturnOrderLineItem(false);
         EX_TestDataUtil.baseReturnOrderLineItem.QuantityReturned = 3;
         EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '102';
         EX_TestDataUtil.baseReturnOrderLineItem.CONSUMABLES_ERROR__c = '반품오류';
         EX_TestDataUtil.baseReturnOrderLineItem.DestinationLocationId = EX_TestDataUtil.baseLocation.Id;
 
 
         SI_CAREPLUS_BACKIF__c backif = new SI_CAREPLUS_BACKIF__c();
         backif.INTERFACE_ID__c = 23;
         backif.TRANS_TYPE__c = 'C';
         backif.REQUEST_SEQ__c = 1;
         insert backif;
 
         List<Map<String, Object>> input = new List<Map<String, Object>>();
 
         Map<String, Object> selectedRows = new Map<String, Object>();
         selectedRows.put('Id', EX_TestDataUtil.getReturnOrderLineItem(true).Id);
         input.add(selectedRows);
        //  EX_TestDataUtil.getProductItem(false);
        //  EX_TestDataUtil.baseProductItem.Product2Id = EX_TestDataUtil.baseReturnOrderLineItem.Product2Id;
        //   ProductItem pItem = new ProductItem(QuantityOnHand = 50, DIV_CODE__c = EX_TestDataUtil.DIV, LocationId = EX_TestDataUtil.baseProductRequestLineItem.DestinationLocationId , Product2Id = EX_TestDataUtil.baseReturnOrderLineItem.Product2Id);
        //  insert  pItem;
         EX_ReturnOrderManagementController.doRefundDeclined(input);
 
         try {
             selectedRows.put('Good_Quality_Quantity', '1');
             selectedRows.put('Disposal_Quantity', '2');
             selectedRows.put('Disposal_Reason', 'test');
             selectedRows.put('collectionYN', true);
             EX_ReturnOrderManagementController.doHandleDisposal(input);

             selectedRows.put('Good_Quality_Quantity', '-1');
             selectedRows.put('Disposal_Quantity', '2');
             selectedRows.put('Disposal_Reason', 'test');
             selectedRows.put('collectionYN', true);
             EX_ReturnOrderManagementController.doHandleDisposal(input);
         } catch (Exception e) {
             System.debug(e.getMessage());
         }
 
         selectedRows.remove('Good_Quality_Quantity');
         selectedRows.remove('Disposal_Quantity');
         selectedRows.remove('Disposal_Reason');
 
         EX_ReturnOrderManagementController.doChangeAddress(EX_TestDataUtil.getReturnOrderLineItem(true).ReturnOrderId, 'test', '01093489243', '3424242', 'adfaf dfadfa', 'efdfasd', 'dafr24');
 
         EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '100';
         update EX_TestDataUtil.baseReturnOrderLineItem;
         EX_ReturnOrderManagementController.doChangeAddress(EX_TestDataUtil.getReturnOrderLineItem(true).ReturnOrderId, 'test', '01093489243', '3424242', 'adfaf dfadfa', 'efdfasd', 'dafr24');
         EX_ReturnOrderManagementController.doChangeAddress('', 'test', '0100348924223', '3424242', 'adfaf dfadfa', 'efdfasd', 'dafr24');
 
         selectedRows.remove('Id');
         selectedRows.put('returnOrderLineItemIdList', new List<Object>{
                 EX_TestDataUtil.getReturnOrderLineItem(true).Id
         });
         EX_ReturnOrderManagementController.doReturnOrderConfirm(selectedRows);
 
         List<ReturnOrderLineItem> items = [
                 SELECT Id, ProductRequest__r.Order_Number__c, Request_Number__c, Request_SEQ__c
                        , ProductRequest__r.Order_Date__c, ProductRequestLineItemId, ProductRequest__r.BILL_TO_CODE__c
                        , Product2.DIV_CODE__c, ProductRequestLineItem.MODEL_Code__c
                        , Product2.Name, ProductRequestLineItem.QuantityRequested, ProductRequestLineItem.SHIP_QTY__c
                        , ProductRequestLineItem.CANCEL_Quantity__c, ProductRequestLineItem.fm_UnitPrice__c
                        , ProductRequestLineItem.ASC_Price__c, ProductRequestLineItem.fm_Last_Discount_Amount__c
                        , CONSIGNEE_Name__c, ProductRequest__r.SHIP_TO_CODE__c, CONSIGNEE_PostalCode__c
                        , CONSIGNEE_Address__c, CONSIGNEE_Address_DETAIL__c, CONSIGNEE_TPNO__c
                        , ProductRequest__r.Description
                        , Order_Number__c
                        , ProductRequestLineItem.Parent.Order_Date__c
                        , ProductRequestLineItem.Parent.BILL_TO_CODE__c
                        , ProductRequestLineItem.Parent.SHIP_TO_CODE__c
                        , ProductRequestLineItem.Parent.Description
                        , ProductRequestLineItem.UnitPrice__c
                        , ProductRequestLineItem.CONSIGNEE_PostalCode__c
                        , ProductRequestLineItem.Parent.CAREPLUS_Order_Requester_Class_Code__c
                 FROM ReturnOrderLineItem
                 LIMIT 1
         ];
         if (!items.isEmpty()) {
             System.debug(' ASC_Price__c > ' + items[0].ProductRequestLineItem.ASC_Price__c);
             System.debug(' fm_Last_Discount_Amount__c > ' + items[0].ProductRequestLineItem.fm_Last_Discount_Amount__c);
             System.debug(' fm_UnitPrice__c > ' + items[0].ProductRequestLineItem.fm_UnitPrice__c);
             EX_ReturnOrderManagementController.setCarePlusBackIFData(items[0], 10, 5, '');
         }
 
 
         Test.stopTest();
     }

     @IsTest
     static void test02_2() {
         Test.startTest();
         EX_TestDataUtil.getCarePlusOrder(true);
         EX_TestDataUtil.careplusOrder.TRANS_TYPE__c = 'R';
         update EX_TestDataUtil.careplusOrder;

         EX_TestDataUtil.getSrSale(false);
         EX_TestDataUtil.srSale.SALE_Number__c = 'A000104989';
         EX_TestDataUtil.getProductRequestLineItem(false);
         EX_TestDataUtil.baseProductRequestLineItem.SR_SALE__c = EX_TestDataUtil.getSrSale(true).Id;
 
         EX_TestDataUtil.getReturnOrder(false);
         EX_TestDataUtil.baseReturnOrder.ProductRequestId = EX_TestDataUtil.getProductRequest(true).Id;
         
         EX_TestDataUtil.getReturnOrderLineItem(false);
         EX_TestDataUtil.baseReturnOrderLineItem.QuantityReturned = 3;
         EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '102';
         EX_TestDataUtil.baseReturnOrderLineItem.CONSUMABLES_ERROR__c = '반품오류';
         EX_TestDataUtil.baseReturnOrderLineItem.DestinationLocationId = EX_TestDataUtil.baseLocation.Id;
 
 
         SI_CAREPLUS_BACKIF__c backif = new SI_CAREPLUS_BACKIF__c();
         backif.INTERFACE_ID__c = 23;
         backif.TRANS_TYPE__c = 'C';
         backif.REQUEST_SEQ__c = 1;
         insert backif;
 
         List<Map<String, Object>> input = new List<Map<String, Object>>();
 
         Map<String, Object> selectedRows = new Map<String, Object>();
         selectedRows.put('Id', EX_TestDataUtil.getReturnOrderLineItem(true).Id);
         input.add(selectedRows);
        //  ProductItem pItem = new ProductItem(QuantityOnHand = 10, DIV_CODE__c = EX_TestDataUtil.DIV, LocationId = EX_TestDataUtil.baseLocation.Id, Product2Id = EX_TestDataUtil.baseReturnOrderLineItem.Product2Id);
        //  insert  pItem;
         EX_ReturnOrderManagementController.acceptRefund(input);
 
         try {
             selectedRows.put('Good_Quality_Quantity', '1');
             selectedRows.put('Disposal_Quantity', '2');
             selectedRows.put('Disposal_Reason', 'test');
             selectedRows.put('collectionYN', true);
             EX_ReturnOrderManagementController.doHandleDisposal(input);
         } catch (Exception e) {
             System.debug(e.getMessage());
         }
 
         selectedRows.remove('Good_Quality_Quantity');
         selectedRows.remove('Disposal_Quantity');
         selectedRows.remove('Disposal_Reason');
 
         EX_ReturnOrderManagementController.doChangeAddress(EX_TestDataUtil.getReturnOrderLineItem(true).ReturnOrderId, 'test', '01093489243', '3424242', 'adfaf dfadfa', 'efdfasd', 'dafr24');
 
         EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '100';
         update EX_TestDataUtil.baseReturnOrderLineItem;
         EX_ReturnOrderManagementController.doChangeAddress(EX_TestDataUtil.getReturnOrderLineItem(true).ReturnOrderId, 'test', '01093489243', '3424242', 'adfaf dfadfa', 'efdfasd', 'dafr24');
         
         EX_ReturnOrderManagementController.doChangeAddress(EX_TestDataUtil.getReturnOrderLineItem(true).ReturnOrderId, 'test', '0100348924223', '3424242', 'adfaf dfadfa', 'efdfasd', 'dafr24');

         selectedRows.remove('Id');
         selectedRows.put('returnOrderLineItemIdList', new List<Object>{
                 EX_TestDataUtil.getReturnOrderLineItem(true).Id
         });
         EX_ReturnOrderManagementController.doReturnOrderConfirm(selectedRows);
 
         List<ReturnOrderLineItem> items = [
                 SELECT Id, ProductRequest__r.Order_Number__c, Request_Number__c, Request_SEQ__c
                        , ProductRequest__r.Order_Date__c, ProductRequestLineItemId, ProductRequest__r.BILL_TO_CODE__c
                        , Product2.DIV_CODE__c, ProductRequestLineItem.MODEL_Code__c
                        , Product2.Name, ProductRequestLineItem.QuantityRequested, ProductRequestLineItem.SHIP_QTY__c
                        , ProductRequestLineItem.CANCEL_Quantity__c, ProductRequestLineItem.fm_UnitPrice__c
                        , ProductRequestLineItem.ASC_Price__c, ProductRequestLineItem.fm_Last_Discount_Amount__c
                        , CONSIGNEE_Name__c, ProductRequest__r.SHIP_TO_CODE__c, CONSIGNEE_PostalCode__c
                        , CONSIGNEE_Address__c, CONSIGNEE_Address_DETAIL__c, CONSIGNEE_TPNO__c
                        , ProductRequest__r.Description
                        , Order_Number__c
                        , ProductRequestLineItem.Parent.Order_Date__c
                        , ProductRequestLineItem.Parent.BILL_TO_CODE__c
                        , ProductRequestLineItem.Parent.SHIP_TO_CODE__c
                        , ProductRequestLineItem.Parent.Description
                        , ProductRequestLineItem.UnitPrice__c
                        , ProductRequestLineItem.CONSIGNEE_PostalCode__c
                        , ProductRequestLineItem.Parent.CAREPLUS_Order_Requester_Class_Code__c
                 FROM ReturnOrderLineItem
                 LIMIT 1
         ];
         if (!items.isEmpty()) {
             System.debug(' ASC_Price__c > ' + items[0].ProductRequestLineItem.ASC_Price__c);
             System.debug(' fm_Last_Discount_Amount__c > ' + items[0].ProductRequestLineItem.fm_Last_Discount_Amount__c);
             System.debug(' fm_UnitPrice__c > ' + items[0].ProductRequestLineItem.fm_UnitPrice__c);
             EX_ReturnOrderManagementController.setCarePlusBackIFData(items[0], 10, 5, '');
         }
 
 
         Test.stopTest();
     }     
 
     @IsTest
     static void test03() {
         Test.startTest();
 
         
         EX_TestDataUtil.getSrSale(false);
         EX_TestDataUtil.srSale.SALE_Number__c = 'A000104989';
         EX_TestDataUtil.getProductRequestLineItem(false);
         EX_TestDataUtil.baseProductRequestLineItem.SR_SALE__c = EX_TestDataUtil.getSrSale(true).Id;
 
         EX_ReturnOrderManagementController.doSendKakaoMessage();
 
         EX_TestDataUtil.getDept(false, null);
         EX_TestDataUtil.dept.CLOSE_YN__c = 'N';
         EX_TestDataUtil.dept.DEPT_TYPE_SECOND__c = 'D';
         EX_TestDataUtil.getDept(true, null);
 
         EX_ReturnOrderManagementController.doGetInitData();
 
         EX_TestDataUtil.getReturnOrderLineItem(false);
         EX_TestDataUtil.baseReturnOrderLineItem.RecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
         EX_TestDataUtil.baseReturnOrderLineItem.Consumables_Order_Status__c = '101';
         EX_TestDataUtil.baseReturnOrderLineItem.Return_Order_Request_DTM__c = Datetime.now();
         EX_TestDataUtil.baseReturnOrderLineItem.CONSIGNEE_Name__c = 'test';
         EX_TestDataUtil.baseReturnOrderLineItem.CONSIGNEE_TPNO__c = '01012345678';
         EX_TestDataUtil.baseReturnOrderLineItem.COLLECTION_YN__c = true;
         EX_TestDataUtil.baseReturnOrderLineItem.SUB_Order_Number__c = '34243243131';
         EX_TestDataUtil.baseReturnOrderLineItem.Order_CHNL_TYPE_Code__c = 'BestShop';
 
 
 
         Map<String, Object> mapSearchParam = new Map<String, Object>();
         mapSearchParam.put('orderNo', EX_TestDataUtil.getReturnOrderLineItem(true).Order_Number__c);
         mapSearchParam.put('recordLimit', 1);
         mapSearchParam.put('pageOffset', 0);
         mapSearchParam.put('isSearchBtnClick', true);
         EX_ReturnOrderManagementController.doGetSearchData(mapSearchParam, EX_TestDataUtil.getReturnOrderLineItem(true).COLLECTION_YN__c);
         mapSearchParam.remove('orderNo');
         mapSearchParam.put('orderChannel', EX_TestDataUtil.getReturnOrderLineItem(true).Order_CHNL_TYPE_Code__c);
         
         mapSearchParam.put('baseDateStart', Datetime.now());
         mapSearchParam.put('contactName', EX_TestDataUtil.getReturnOrderLineItem(true).CONSIGNEE_Name__c);
         mapSearchParam.put('contactPhone', EX_TestDataUtil.getReturnOrderLineItem(true).CONSIGNEE_TPNO__c);
         EX_ReturnOrderManagementController.doGetSearchData(mapSearchParam, EX_TestDataUtil.getReturnOrderLineItem(true).COLLECTION_YN__c);
 
         List<Map<String, Object>> input = new List<Map<String, Object>>();
 
         Map<String, Object> selectedRows = new Map<String, Object>();
         selectedRows.put('Id', EX_TestDataUtil.getReturnOrderLineItem(true).Id);
         input.add(selectedRows);
 
         EX_ReturnOrderManagementController.doCancelReturn(input);
         try {

            EX_TestDataUtil.baseProductRequestLineItem.Consumables_Order_Status__c = '090';
            update EX_TestDataUtil.baseProductRequestLineItem;

            EX_ReturnOrderManagementController.doCancelReturn(input);


             selectedRows.put('Good_Quality_Quantity', '0');
             selectedRows.put('Disposal_Quantity', '0');
             selectedRows.put('Disposal_Reason', 'test');
             EX_ReturnOrderManagementController.doHandleDisposal(input);
 
             selectedRows.put('Good_Quality_Quantity', '0');
             selectedRows.put('Disposal_Quantity', '0');
             EX_ReturnOrderManagementController.doHandleDisposal(input);

             Map<String, ProductItem> emptyMap = new Map<String, ProductItem>();

            EX_ReturnOrderManagementController.createPIT('', 10, '', EX_TestDataUtil.baseProductRequestLineItem, EX_TestDataUtil.baseReturnOrderLineItem, EX_TestDataUtil.baseProductTransfer, emptyMap );

 
         } catch (Exception e) {
             System.debug(e.getMessage());
         }
 
         Test.stopTest();
     }
 
     @IsTest
     static void moreLoadValid() {
         Test.startTest();
         EX_ReturnOrderManagementController.moreLoadValid(1,1,1);
         Test.stopTest();
     }
 }