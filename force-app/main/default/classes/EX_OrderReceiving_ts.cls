/****************************************************************************************
 * @filename      : EX_OrderReceiving_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-04-20 오전 11:27
 * @group         :
 * @group-content :
 * @description   : EX_OrderReceiving Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-04-20       I2max               Create
 ****************************************************************************************/

@IsTest
private class EX_OrderReceiving_ts {
    @IsTest
    static void test_doPost_01() {
        Test.startTest();

        EX_TestDataUtil.getFulfillmentReceiving(true);
        Schema.Location loc = EX_TestDataUtil.baseLocation.clone();
        loc.RecordTypeId = Schema.SObjectType.Location.getRecordTypeInfosByDeveloperName().get('Center').getRecordTypeId();
        insert loc;

        Schema.Location ParentLocation = [select id,Name,DIV_CODE__c,IsInventoryLocation,RecordTypeId,DEPT_CODE__c,ParentLocationId__c from Location where Name = :System.Label.EX_Location AND RecordType.DeveloperName = 'Location' and DEPT_CODE__c = 'PH0300' Limit 1];
        ParentLocation.ParentLocationId__c = loc.Id;
        update ParentLocation;

        Schema.Location ChildLocation = loc.clone();
        ChildLocation.RecordTypeId = ParentLocation.RecordTypeId;
        ChildLocation.ParentLocationId__c = ParentLocation.Id;
        ChildLocation.Name = ParentLocation.Name;
        ChildLocation.DEPT_CODE__c = ParentLocation.DEPT_CODE__c;
        insert ChildLocation;

        ProductItem ptI = EX_TestDataUtil.baseProductItem.clone();
        ptI.LocationId = ChildLocation.Id;
        insert ptI;

        EX_TestDataUtil.baseProductTransfer.Return_Order_Quantity__c = 1;
        EX_TestDataUtil.baseProductTransfer.SHIPPED_Date__c = Date.today();
        EX_TestDataUtil.baseProductTransfer.MOVE_Type_Code__c = 'A';
        EX_TestDataUtil.baseProductTransfer.PART_NO__c = EX_TestDataUtil.baseProduct.Name;
        EX_TestDataUtil.baseProductTransfer.DestinationLocationId = ParentLocation.Id;

        update EX_TestDataUtil.baseProductTransfer;
        EX_TestDataUtil.fulfillmentReceiving.PART_NO__c = EX_TestDataUtil.baseProduct.Name;
        update EX_TestDataUtil.fulfillmentReceiving;

        ProductTransfer ptf = EX_TestDataUtil.baseProductTransfer.clone();
        ptf.DestinationLocationId = ChildLocation.Id;
        insert ptf;
        
        EX_OrderReceiving.doPost();
        Test.stopTest();
    }

    @IsTest
    static void test_doPost_02() {
        Test.startTest();

        EX_TestDataUtil.getFulfillmentReceiving(true);
        Schema.Location loc = EX_TestDataUtil.baseLocation.clone();
        loc.RecordTypeId = Schema.SObjectType.Location.getRecordTypeInfosByDeveloperName().get('Center').getRecordTypeId();
        insert loc;

        Schema.Location ParentLocation = [select id,Name,DIV_CODE__c,IsInventoryLocation,RecordTypeId,DEPT_CODE__c,ParentLocationId__c from Location where Name = :System.Label.EX_Location AND RecordType.DeveloperName = 'Location' and DEPT_CODE__c = 'PH0300' Limit 1];
        ParentLocation.ParentLocationId__c = loc.Id;
        update ParentLocation;

        Schema.Location ChildLocation = loc.clone();
        ChildLocation.RecordTypeId = ParentLocation.RecordTypeId;
        ChildLocation.ParentLocationId__c = ParentLocation.Id;
        ChildLocation.Name = ParentLocation.Name;
        ChildLocation.DEPT_CODE__c = ParentLocation.DEPT_CODE__c;
        insert ChildLocation;

        ProductItem ptI = EX_TestDataUtil.baseProductItem.clone();
        ptI.LocationId = ChildLocation.Id;
        insert ptI;

        EX_TestDataUtil.baseProductTransfer.Return_Order_Quantity__c = 1;
        EX_TestDataUtil.baseProductTransfer.SHIPPED_Date__c = Date.today();
        EX_TestDataUtil.baseProductTransfer.MOVE_Type_Code__c = 'A';
        EX_TestDataUtil.baseProductTransfer.PART_NO__c = EX_TestDataUtil.baseProduct.Name;
        EX_TestDataUtil.baseProductTransfer.DestinationLocationId = ParentLocation.Id;
        EX_TestDataUtil.baseProductTransfer.ReturnOrderLineItemId = EX_TestDataUtil.getReturnOrderLineItem(true).Id;

        update EX_TestDataUtil.baseProductTransfer;
        EX_TestDataUtil.fulfillmentReceiving.PART_NO__c = EX_TestDataUtil.baseProduct.Name;
        update EX_TestDataUtil.fulfillmentReceiving;

        ProductTransfer ptf = EX_TestDataUtil.baseProductTransfer.clone();
        ptf.DestinationLocationId = ChildLocation.Id;
        insert ptf;
        
        EX_OrderReceiving.doPost();
        Test.stopTest();
    }

    @IsTest
    static void test_ConsumableOrderReceive_01() {
        Test.startTest();

        EX_TestDataUtil.getFulfillmentReceiving(true);
        EX_TestDataUtil.getProductRequestLineItem(true);
        ProductRequestLineItem prli = EX_TestDataUtil.baseProductRequestLineItem;
        prli.Order_CHNL_TYPE_Code__c = 'V';
        update prli;

        EX_TestDataUtil.baseProductTransfer.QuantityReceived = 0;
        EX_TestDataUtil.baseProductTransfer.QuantitySent = 200;
        update EX_TestDataUtil.baseProductTransfer;
        
        String ptId = EX_TestDataUtil.baseProductTransfer.Id;

        TemplateMgmt__c tm = new TemplateMgmt__c();
        tm.TemplateCode__c = 'SVC_LGE_MACN_S020';
        tm.Content_c__c = 'test';
        tm.Title__c = 'test';
        insert tm;

        EX_OrderReceiving.ConsumableOrderReceive(new List<String>{ptId});
        Test.stopTest();
    }

    @IsTest
    static void test_ConsumableOrderReceive_02() {
        Test.startTest();

        EX_TestDataUtil.getFulfillmentReceiving(true);
        // EX_TestDataUtil.getProductRequestLineItem(true);
        Product2 p = EX_TestDataUtil.baseProduct.clone();
        p.ProductCode = 'TEST7515341';
        insert p;
        ProductRequestLineItem prli = EX_TestDataUtil.baseProductRequestLineItem;
        prli.Order_CHNL_TYPE_Code__c = 'V';
        prli.BASIS_Parts_Number__c = p.ProductCode;
        update prli;

        EX_TestDataUtil.baseProductTransfer.QuantityReceived = 0;
        EX_TestDataUtil.baseProductTransfer.QuantitySent = 200;
        update EX_TestDataUtil.baseProductTransfer;
        
        String ptId = EX_TestDataUtil.baseProductTransfer.Id;

        TemplateMgmt__c tm = new TemplateMgmt__c();
        tm.TemplateCode__c = 'SVC_LGE_MACN_S020';
        tm.Content_c__c = 'test';
        tm.Title__c = 'test';
        insert tm;

        EX_OrderReceiving.ConsumableOrderReceive(new List<String>{ptId});
        Test.stopTest();
    }

    @IsTest
    static void test_ConsumableOrderReceive_03() {
        Test.startTest();

        EX_TestDataUtil.getFulfillmentReceiving(true);
        Product2 p = EX_TestDataUtil.baseProduct.clone();
        
        p.ProductCode = 'TEST7515341';
        insert p;
        
        ProductRequestLineItem prli = EX_TestDataUtil.baseProductRequestLineItem;
        prli.Order_CHNL_TYPE_Code__c = 'V';
        prli.BASIS_Parts_Number__c = p.ProductCode;
        prli.ENDP_RSV_Quantity__c = 1;
        prli.Consumables_Order_Status__c = '002';
        prli.BASIS_Parts_Number__c = 'testPartNo';
        update prli;

        EX_TestDataUtil.baseProductTransfer.QuantityReceived = 0;
        EX_TestDataUtil.baseProductTransfer.QuantitySent = 200;
        update EX_TestDataUtil.baseProductTransfer;
        
        String ptId = EX_TestDataUtil.baseProductTransfer.Id;

        TemplateMgmt__c tm = new TemplateMgmt__c();
        tm.TemplateCode__c = 'SVC_LGE_MACN_S020';
        tm.Content_c__c = 'test';
        tm.Title__c = 'test';
        insert tm;

        EX_OrderReceiving.ConsumableOrderReceive(new List<String>{ptId});
        Test.stopTest();
    }

    @IsTest
    static void test_getDateWithNull() {
        Object obj = System.now();

        Test.startTest();
        EX_OrderReceiving.getDateWithNull(obj);
        Test.stopTest();
    }
}