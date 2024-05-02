/**
 * Created by A78909 on 2023-05-16.
 */

@IsTest
private class EX_ContactMapping_ba_ts {

    @TestSetup
    static void setData(){
        EX_TestDataUtil.getProductRequest(true);
        EX_TestDataUtil.baseProductRequest.Order_CUST_Id__c = null;
        EX_TestDataUtil.baseProductRequest.isMig__c = true;
        EX_TestDataUtil.baseProductRequest.Order_CUST_Name__c = 'TEST';
        EX_TestDataUtil.baseProductRequest.Order_CUST_TPNO_1__c = '010-1234-1234';
        EX_TestDataUtil.baseProductRequest.Order_CUST_TPNO_2__c = '010-2345-1234';
        EX_TestDataUtil.baseProductRequest.Order_CUST_Address__c = '강서구 마곡동 사이언스파크';
        EX_TestDataUtil.baseProductRequest.Order_CUST_Address_DETAIL__c = '테스트';
        EX_TestDataUtil.baseProductRequest.Order_CUST_PostalCode__c = '12344';
        EX_TestDataUtil.baseProductRequest.Order_Date__c = Datetime.now();

        update EX_TestDataUtil.baseProductRequest;

        EX_TestDataUtil.getReturnOrder(true);
        EX_TestDataUtil.baseReturnOrder.ContactId = null;
        EX_TestDataUtil.baseReturnOrder.isMig__c = true;
        EX_TestDataUtil.baseReturnOrder.Order_CUST_Name__c = 'TEST';
        EX_TestDataUtil.baseReturnOrder.Order_CUST_TPNO_1__c = '010-1234-1234';
        EX_TestDataUtil.baseReturnOrder.Order_CUST_TPNO_2__c = '010-1234-1234';
        EX_TestDataUtil.baseReturnOrder.Order_CUST_Address__c = '강서구 마곡동 사이언스파크';
        EX_TestDataUtil.baseReturnOrder.Order_CUST_Address_DETAIL__c = '테스트';
        EX_TestDataUtil.baseReturnOrder.Order_CUST_PostalCode__c = '12344';
        EX_TestDataUtil.baseReturnOrder.RecordTypeId = Schema.SObjectType.ReturnOrder.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();

        update EX_TestDataUtil.baseReturnOrder;
    }

    @IsTest
    static void testBehavior_01() {
        Test.startTest();

        Database.executeBatch(new EX_ContactMapping_ba('ProductRequest',true,500,null),1);

        Test.stopTest();

    }
    @IsTest
    static void testBehavior_02() {
        Test.startTest();
        List<ProductRequest> prList = [SELECT Id,Order_CUST_PostalCode__c FROM ProductRequest LIMIT 1];
        prList[0].Order_CUST_PostalCode__c = null;
        update prList;
        Database.executeBatch(new EX_ContactMapping_ba('ProductRequest',true,500,null),1);

        Test.stopTest();

    }
    @IsTest
    static void testBehavior_03() {
        Test.startTest();
        List<ReturnOrder> roList = [SELECT Id, Order_CUST_TPNO_1__c, Order_CUST_PostalCode__c,ProductRequestId FROM ReturnOrder LIMIT 1];
        List<ProductRequest> prList = [SELECT Id,Order_Date__c FROM ProductRequest LIMIT 1];
        roList[0].Order_CUST_TPNO_1__c = null;
        roList[0].ProductRequestId = prList[0].Id;
        update roList;
        
        Database.executeBatch(new EX_ContactMapping_ba('ReturnOrder',true,500,null),1);

        Test.stopTest();

    }
    @IsTest
    static void testBehavior_04() {
        Test.startTest();
        List<ReturnOrder> roList = [SELECT Id, Order_CUST_TPNO_1__c, Order_CUST_PostalCode__c,ProductRequestId FROM ReturnOrder LIMIT 1];
        List<ProductRequest> prList = [SELECT Id,Order_Date__c FROM ProductRequest LIMIT 1];
        roList[0].Order_CUST_TPNO_1__c = null;
        roList[0].Order_CUST_PostalCode__c = null;
        roList[0].ProductRequestId = prList[0].Id;
        update roList;

        Database.executeBatch(new EX_ContactMapping_ba('ReturnOrder',true,500,null),1);

        Test.stopTest();

    }
}