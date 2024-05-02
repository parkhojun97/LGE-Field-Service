/****************************************************************************************
 * @filename      : EX_SearchPartsController_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-09 오후 2:46
 * @group         :
 * @group-content :
 * @description   : EX_SearchPartsController Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-09       I2max               Create
 ****************************************************************************************/

 @IsTest
 private class EX_SearchPartsController_ts {
     @TestSetup
     static void setup() {
         EX_TestDataUtil.createProduct();
         Product2 prd = EX_TestDataUtil.baseProduct;
         prd.OBS_DISPLAY_YN__c = 'Y';
         prd.PART_TYPE__c = 'D';
         prd.PART_DESC_KOR__c = 'KOR';
         prd.DISABLED_DT__c = Date.today();
         prd.PARCEL_YN__c = 'Y';
         update prd;

         EX_TestDataUtil.createProduct3();
         Product2 prd2 = EX_TestDataUtil.baseProduct2;
         prd2.OBS_DISPLAY_YN__c = 'Y';
         prd2.PART_TYPE__c = 'D';
         prd2.PART_DESC_KOR__c = 'KOR';
         prd2.DISABLED_DT__c = Date.today();
         prd2.PARCEL_YN__c = 'Y';
         update prd2;

         TriggerHandler.bypass('SM_DIV_trHandler');
         TriggerHandler.bypass('SM_SUBSTITUTE_PART_trHandler');
         
         insert new SM_SUBSTITUTE_PART__c(PART_NO__c =  EX_TestDataUtil.baseProduct.Id, SUBSTITUTE_PART_NO__c = prd.Id);
         insert new SM_SUBSTITUTE_PART__c(PART_NO__c =  EX_TestDataUtil.baseProduct.Id, SUBSTITUTE_PART_NO__c = prd2.Id);
        //  insert new SM_SUBSTITUTE_PART__c(PART_NO__c =  EX_TestDataUtil.baseProduct2.Id, SUBSTITUTE_PART_NO__c = prd2.Id);
         Schema.Location loc = EX_TestDataUtil.getLocation(false, 'DIV', 'PH8002');
         loc.LocationType = 'Warehouse';
         loc.NAME = System.Label.EX_Location;
         loc.SM_DIV_Id__c = EX_TestDataUtil.getDIV(true).Id;
         insert loc;
 
         Schema.Location loc2 = loc.clone();
         loc2.RecordTypeId = SObjectType.Location.getRecordTypeInfosByDeveloperName().get('Center').getRecordTypeId();
         loc2.NAME = '99A991';
         loc2.ParentLocationId__c = loc.Id;
         insert loc2;
         insert new IF_Master__c(Method__c = 'POST', Endpoint__c = 'www.test.com', APIKeyName__c = 'test', APIKeyValue__c = 'test', IfId__c = 'IF-NEW-544', isLogInsert__c = true);
    
    }
 
     @IsTest
     static void test_getInitData1() {
         Map<String, Object> paramMap = getParamMap(true);
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpMockCalloutMock());
         EX_SearchPartsController.getInitData(JSON.serialize(paramMap));
         Test.stopTest();
     }
 
     @IsTest
     static void test_getInitData2() {
         Map<String, Object> paramMap = getParamMap(false);
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpMockCalloutMock());
         EX_SearchPartsController.getInitData(JSON.serialize(paramMap));
         Test.stopTest();
     }
 
     @IsTest
     static void test_getInitData3() {
         Product2 prd = [SELECT Id, PART_TYPE__c FROM Product2 LIMIT 1];
         Schema.Location loc = [SELECT Id FROM Location WHERE RecordType.DeveloperName = 'DIV' LIMIT 1];
         insert new ProductItem(LocationId = loc.Id,Product2Id = prd.Id,QuantityOnHand = 10,DIV_CODE__c = 'DMZ');
         Schema.Location loc2 = [SELECT Id FROM Location WHERE RecordType.DeveloperName = 'Center' LIMIT 1];
         insert new ProductItem(LocationId = loc2.Id,Product2Id = prd.Id,QuantityOnHand = 10,DIV_CODE__c = 'DMZ');
         
         Map<String, Object> paramMap = getParamMap(false);
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpMockCalloutMock());
         EX_SearchPartsController.getInitData(JSON.serialize(paramMap));
         prd.PART_TYPE__c = '';
         update prd;
         EX_SearchPartsController.getInitData(JSON.serialize(paramMap));
         Test.stopTest();
     }
 
     @IsTest
     static void test_getInitData3_2() {
         Product2 prd = [SELECT Id, PART_TYPE__c FROM Product2 LIMIT 1];
         Product2 prd2 = [SELECT Id, PART_TYPE__c FROM Product2 WHERE NAME = 'EXS9342523' LIMIT 1];
         Schema.Location loc = [SELECT Id FROM Location WHERE RecordType.DeveloperName = 'DIV' LIMIT 1];
         insert new ProductItem(LocationId = loc.Id, Product2Id = prd.Id,QuantityOnHand = 10, DIV_CODE__c = 'DMZ');
         insert new ProductItem(LocationId = loc.Id, Product2Id = prd2.Id,QuantityOnHand = 10, DIV_CODE__c = 'DMZ');
         Schema.Location loc2 = [SELECT Id FROM Location WHERE RecordType.DeveloperName = 'Center' LIMIT 1];
         insert new ProductItem(LocationId = loc2.Id,Product2Id = prd.Id,QuantityOnHand = 10,DIV_CODE__c = 'DMZ');
         
        //  insert new ProductItem(LocationId = loc.Id, Product2Id = prd.Id,QuantityOnHand = 10, DIV_CODE__c = 'DMZ');
        //  insert new ProductItem(LocationId = loc.Id, Product2Id = prd.Id,QuantityOnHand = 10, DIV_CODE__c = 'DMZ');
        //  insert new ProductItem(LocationId = loc.Id, Product2Id = prd.Id,QuantityOnHand = 10, DIV_CODE__c = 'DMZ');
         
         Map<String, Object> paramMap = getParamMap(false);
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpMockCalloutMock());
         EX_SearchPartsController.getInitData(JSON.serialize(paramMap));
         prd.PART_TYPE__c = '';
         prd2.PART_TYPE__c = '';
         update prd;
         update prd2;
         EX_SearchPartsController.getInitData(JSON.serialize(paramMap));
         ProductItem pritem = [SELECT Id FROM ProductItem WHERE LocationId =: loc.Id AND Product2Id =: prd2.Id AND DIV_CODE__c = 'DMZ' LIMIT 1];
         delete pritem;
         EX_SearchPartsController.getInitData(JSON.serialize(paramMap));
         Test.stopTest();
     }
 
     @IsTest
     static void test_getInitData4() {
         Product2 prd = [SELECT Id, PART_DESC_KOR__c, PART_TYPE__c FROM Product2 LIMIT 1];
         prd.PART_TYPE__c = '';
         prd.PART_DESC_KOR__c = '';
         update prd;
 
         Map<String, Object> paramMap = getParamMap(false);
         Test.startTest();
         Test.setMock(HttpCalloutMock.class, new HttpMockCalloutMock());
         EX_SearchPartsController.getInitData(JSON.serialize(paramMap));
         Test.stopTest();
     }
 
     private static Map<String, Object> getParamMap(Boolean isSBOM){
         Product2 prd = [SELECT Id, ProductCode FROM Product2 LIMIT 1];
         SM_SUBSTITUTE_PART__c part = [SELECT Id, SUBSTITUTE_PART_NO__r.DIV_CODE__c, SUBSTITUTE_PART_NO__r.ProductCode from SM_SUBSTITUTE_PART__c LIMIT 1];
         Map<String, Object> paramMap = new Map<String, Object>();
         paramMap.put('isSBOM', isSBOM);
         paramMap.put('partId', prd.Id);
         paramMap.put('productCode', prd.ProductCode);
         paramMap.put('locationId', 'locationId');
         paramMap.put('divCode', part.SUBSTITUTE_PART_NO__r.DIV_CODE__c);
         return paramMap;
     }
 
     private class HttpMockCalloutMock implements HttpCalloutMock {
         public HTTPResponse respond(HTTPRequest request) {
             SM_SUBSTITUTE_PART__c part = [SELECT Id, SUBSTITUTE_PART_NO__r.DIV_CODE__c, SUBSTITUTE_PART_NO__r.ProductCode from SM_SUBSTITUTE_PART__c LIMIT 1];
             HttpResponse response = new HttpResponse();
             response.setHeader('Content-Type', 'application/json');
             response.setStatusCode(200);
             String responseBody = '{ "Header" : {"rstType" : "test", "rstMsg" : "test" } , "Body" : { "data" : [ { "divCode" : "'+part.SUBSTITUTE_PART_NO__r.DIV_CODE__c+'", "partNo" : "'+part.SUBSTITUTE_PART_NO__r.ProductCode+'", "PartNameKor" : "PartNameKor", "ObsSalesYN" : "ObsSalesYN", "ObsSalesURL" : "ObsSalesURL", "ObsImageURL" : "ObsImageURL", "ObsMemberPrice" : 1000 } ] } } ';
             response.setBody(responseBody);
             return response;
         }
     }
 }