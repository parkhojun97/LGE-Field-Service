/**
 * @description       : 
 * @author            : hyungho.chun@dkbmc.com
 * @group             : 
 * @last modified on  : 11-09-2023
 * @last modified by  : hyungho.chun@dkbmc.com
**/
@isTest
public class EX_ContactMapping_qa_ts {
   
   
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

        update EX_TestDataUtil.baseProductRequest;

        EX_TestDataUtil.getReturnOrder(true);
        EX_TestDataUtil.baseReturnOrder.ContactId = null;
        EX_TestDataUtil.baseReturnOrder.isMig__c = true;
        EX_TestDataUtil.baseReturnOrder.Order_CUST_Name__c = 'TEST';
        EX_TestDataUtil.baseReturnOrder.Order_CUST_TPNO_1__c = '010-1234-1234';

        update EX_TestDataUtil.baseReturnOrder;
    }

    @IsTest
    static void testBehavior() {
        Map<String, Map<String, Object>> paramMapList = new Map<String, Map<String, Object>>();
        Map<String, Object> paramMap = new Map<String, Object>();
                    // List<String> itemList = itemSet[k].split('\\^');
        paramMap.put('contactName' , 'TEST');
        paramMap.put('inboundNo' , '010-1234-1234');
        paramMap.put('inboundNo2' , '010-2345-1234');
        paramMap.put('fAddress' , '강서구 마곡동 사이언스파크');
        paramMap.put('detailAddress' , '테스트');
        paramMap.put('zipNo' , '12344');
        
        List<ProductRequest> sObjects = [SELECT id, Order_CUST_Name__c, Order_CUST_TPNO_1__c FROM ProductRequest LIMIT 1];
        paramMapList.put(sObjects[0].Id,paramMap);

        
        // EX_ContactMapping_ba contactMappingBa = new EX_ContactMapping_ba();
        // Database.executeBatch(contactMappingBa);
        EX_ContactMapping_qa q = new EX_ContactMapping_qa(paramMapList, sObjects);
        System.enqueueJob(q);

    }
}