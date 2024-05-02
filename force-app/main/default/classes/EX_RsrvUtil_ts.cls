/**
 * Created by MS on 2023-04-18.
 */

 @IsTest
 private class EX_RsrvUtil_ts {
     @IsTest
     static void test01() {
         Test.startTest();
         EX_TestDataUtil.getSmCodeMaster(false).Name = 'UD019';
         insert EX_TestDataUtil.objSmCodeMaster;
         EX_TestDataUtil.getSmCode(true);
 
 
         TriggerHandler.bypass('SM_DIV_trHandler');
         EX_TestDataUtil.getDIV(true);
         TriggerHandler.clearAllBypasses();
         EX_TestDataUtil.getOnlineInStockNotice(true);
         String deptCode = EX_TestDataUtil.dept.DEPT_CODE__c;
         EX_TestDataUtil.baseLocation = null;
         EX_TestDataUtil.getLocation(true, 'DIV', deptCode);
         EX_OnlineInstockNotice.doPost();
 
         EX_TestDataUtil.onlineInStockNotice.WORK_YN__c = 'Y';
         EX_TestDataUtil.onlineInStockNotice.RESRV_REQUEST_FLAG__c = 'Y';
         update EX_TestDataUtil.onlineInStockNotice;
         EX_OnlineInstockNotice.doPost();
 
         List<Map<String, Object>> mapItemList = new List<Map<String, Object>>();
         Map<String, Object> mapItem = new Map<String, Object>();
         mapItem.put('oriPrId', EX_TestDataUtil.baseProductRequest.Id); //원주문 ProductRequestId
         mapItem.put('oriPrliId', EX_TestDataUtil.baseProductRequestLineItem.Id); //원주문 ProductRequestLineItemId
         mapItem.put('deptCode', deptCode);
         mapItem.put('partNo', EX_TestDataUtil.onlineInStockNotice.PART_NO__c);
         mapItem.put('req_qty', EX_TestDataUtil.onlineInStockNotice.REQ_QTY__c);
         mapItem.put('div_code', EX_TestDataUtil.onlineInStockNotice.DIV_CODE__c);
         mapItem.put('oriOrderNo', 'O32434');
         mapItem.put('oriOrderSeq', '1');
         mapItemList.add(mapItem);
         TriggerHandler.bypass('ProductRequestLineItem_tr');
         EX_RsrvUtil.RESRV_MODULE(mapItemList);
         List<Map<String, Object>> rsrvCancelMapList = new List<Map<String, Object>>();
         Map<String, Object> rsrvCancelMap = new Map<String, Object>();
         rsrvCancelMap.put('ProductRequestLineItem',EX_TestDataUtil.baseProductRequestLineItem);
         rsrvCancelMap.put('code','AE');
         rsrvCancelMapList.add(rsrvCancelMap);
         EX_RsrvUtil.CANCEL_RESRV_MULTI(rsrvCancelMapList);
         EX_RsrvUtil.execApplyProductItem(1, 'test',EX_TestDataUtil.baseProductRequestLineItem);
 
         Test.stopTest();
 
     }
 
     @IsTest
     static void test02() {
         Test.startTest();
         EX_TestDataUtil.getSmCodeMaster(false).Name = 'UD019';
         insert EX_TestDataUtil.objSmCodeMaster;
         EX_TestDataUtil.getSmCode(true);
 
         TriggerHandler.bypass('SM_DIV_trHandler');
         EX_TestDataUtil.getDIV(true);
         TriggerHandler.clearAllBypasses();
         EX_TestDataUtil.getDept(false, 'PH0300');
         EX_TestDataUtil.dept.Name = System.Label.EX_Location;
         EX_TestDataUtil.getOnlineInStockNotice(true);
         EX_TestDataUtil.baseLocation = null;
         Schema.Location a1 = EX_TestDataUtil.getLocation(false, 'Location', 'PH0300');
         EX_TestDataUtil.baseLocation = null;
         Schema.Location a2 = EX_TestDataUtil.getLocation(false, 'DIV', 'PH0300');
         insert new List<Schema.Location>{a1, a2};
         EX_OnlineInstockNotice.doPost();
         EX_TestDataUtil.onlineInStockNotice.WORK_YN__c = 'Y';
         EX_TestDataUtil.onlineInStockNotice.RESRV_REQUEST_FLAG__c = 'Y';
         update EX_TestDataUtil.onlineInStockNotice;
         EX_OnlineInstockNotice.doPost();
 
         EX_TestDataUtil.getProductItem(false).LocationId = a1.Id;
         EX_TestDataUtil.getProductItem(true);
 
         List<Map<String, Object>> mapItemList = new List<Map<String, Object>>();
         Map<String, Object> mapItem = new Map<String, Object>();
         mapItem.put('oriPrId', EX_TestDataUtil.baseProductRequest.Id); //원주문 ProductRequestId
         mapItem.put('oriPrliId', EX_TestDataUtil.baseProductRequestLineItem.Id); //원주문 ProductRequestLineItemId
         mapItem.put('deptCode', EX_TestDataUtil.dept.DEPT_CODE__c);
         mapItem.put('partNo', EX_TestDataUtil.onlineInStockNotice.PART_NO__c);
         mapItem.put('req_qty', EX_TestDataUtil.onlineInStockNotice.REQ_QTY__c);
         mapItem.put('div_code', EX_TestDataUtil.onlineInStockNotice.DIV_CODE__c);
         mapItem.put('oriOrderNo', 'O32434');
         mapItem.put('oriOrderSeq', '1');
         mapItemList.add(mapItem);
 
         TriggerHandler.bypass('ProductRequestLineItem_tr');
         EX_RsrvUtil.RESRV_MODULE(mapItemList);
 
         Test.stopTest();
 
     }
 
     @IsTest
     static void test03(){
         Test.startTest();
 
         ProductRequestLineItem a = EX_TestDataUtil.getProductRequestLineItem(true);
         EX_TestDataUtil.baseProductRequestLineItem = null;
         EX_TestDataUtil.getProductRequestLineItem(false);
         EX_TestDataUtil.baseProductRequestLineItem.RecordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('RESV_SALE').getRecordTypeId();
         EX_TestDataUtil.baseProductRequestLineItem.RSRV_Number__c = a.RSRV_Number__c;
         EX_TestDataUtil.getSIRequest(true);
         TriggerHandler.bypass('ProductRequestLineItem_tr');
         List<Map<String, Object>> rsrvCancelMapList = new List<Map<String, Object>>();
         Map<String, Object> rsrvCancelMap = new Map<String, Object>();
         rsrvCancelMap.put('ProductRequestLineItem',a);
         rsrvCancelMap.put('code','T');
         rsrvCancelMapList.add(rsrvCancelMap);
         EX_RsrvUtil.CANCEL_RESRV_MULTI(rsrvCancelMapList);
         
         List<ProductRequestLineItem> priList = new List<ProductRequestLineItem>();
         priList.add(a);
         EX_RsrvUtil.execApplyProductItemMulti('AC', priList);
 
         Test.stopTest();
     }
 }