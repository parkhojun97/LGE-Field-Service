/****************************************************************************************
 * @filename      : EX_CarePlusOrder_ba_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-16 오후 1:17
 * @group         :
 * @group-content :
 * @description   : EX_CarePlusOrder_ba Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-16       I2max               Create
 ****************************************************************************************/

@IsTest
private class EX_CarePlusOrder_ba_ts {
    @TestSetup
    static void setup(){
        Test.startTest();
        EX_TestDataUtil.getCareplusOrder(true);
//        SI_CAREPLUS_ORDER__c siCareplusOrder2 = EX_TestDataUtil.getCareplusOrder(false);
//        siCareplusOrder2.Id = null;
//        siCareplusOrder2.ORDER_NO__c = 'PTEST2';
//        insert siCareplusOrder2;

//'엘지베스트샵' AND MobilePhone ='02-1544-7777'
        EX_TestDataUtil.getContact(true);
        Contact lgC = new Contact();
        // lgC.AccountId = EX_TestDataUtil.getAccount(true).Id;
            lgC.Lastname = '엘지베스트샵';
            lgC.SIGNATURE_YN__c = true;
            lgC.B2B_CUSTOMER_YN__c = true;
            lgC.SMS_RECEIVE__c = true;
            lgC.SMS_RECEIVE__c = true;
            lgC.IsMIG__c = true;
            lgC.EXECUTIVE_YN__c = true;
            lgC.THINQ_YN__c = true;
            lgC.CARESHIP_YN__c = true;
            lgC.HC_DENY_YN__c = true;
            lgC.USE_FLAG__c = true;
            lgC.isByPass__c = true;
            lgC.MobilePhone = '02-1544-7777';
            lgC.Phone = '02-1544-7777';
            TriggerHandler.bypass('Contact_trHandler');
            insert lgC;
            TriggerHandler.clearBypass('Contact_trHandler');
        Test.stopTest();
    }

    @IsTest
    static void test_batch01() {
        Test.startTest();
        Database.executeBatch(new EX_CarePlusOrder_ba(null), 1);
        
        EX_CarePlusOrder_ba.getDateWithNull(Date.today());
        Test.stopTest();
    }

    @IsTest
    static void test_batch02() {
        Test.startTest();
        List<SI_CAREPLUS_ORDER__c> order = [SELECT Id, INTERFACE_ID__c, ORDER_NO__c, BILL_TO_CODE__c,ORDER_DATE__c,SHIP_TO_CODE__c,RECEIVER_NAME__c,RECEIVER_PHONE_NO__c,BASIC_ADDRESS__c,DETAIL_ADDRESS__c,ORDER_DESCRIPTION__c,POSTAL_CODE__c,ATTRIBUTE8__c,ORDER_AMT__c,ORDER_QTY__c,DIV_CODE__c,PART_NO__c,ATTRIBUTE4__c,WORK_FLAG__c,CANCEL_FLAG__c,CANCEL_DATE__c,CANCEL_QTY__c,MODEL_CODE__c,ORDER_PRICE__c FROM SI_CAREPLUS_ORDER__c];
        if(!order.isEmpty()){
            SR_ONLINE_AUTO_SALE_EXC__c soase = new SR_ONLINE_AUTO_SALE_EXC__c();
            insert soase;
            List<Contact> conList = [SELECT id FROM Contact WHERE name = '엘지베스트샵' AND MobilePhone ='02-1544-7777'];
            ProductRequest setPr = new ProductRequest();
            setPr = EX_CarePlusOrder_ba.setProductRequest(order[0], setPr);
            ProductRequestLineItem setPrli = new ProductRequestLineItem();
            List<Product2> p2List = new List<Product2>();
            List<ProductItem> piList = new List<ProductItem>();
            setPrli = EX_CarePlusOrder_ba.setProductRequestLineItem(order[0], setPr, setPrli, p2List, piList, false);
            //order[0].WORK_FLAG__c = 'H';
            order[0].WORK_FLAG__c = 'I';
            update order;
            SI_CAREPLUS_ORDER_COMPLETE__c careplusOrderComplete = new SI_CAREPLUS_ORDER_COMPLETE__c();
            careplusOrderComplete.INTERFACE_ID__c =order[0].INTERFACE_ID__c;
            careplusOrderComplete.ORG_ID__c = 34142;
            careplusOrderComplete.ORIG_SYS_DOCUMENT_REF__c = [SELECT Order_Number__c FROM ProductRequest][0].Order_Number__c;
            careplusOrderComplete.ITEM_NO__c = [SELECT PART_NO__c FROM ProductRequestLineItem][0].PART_NO__c;
            careplusOrderComplete.ORDER_TYPE__c = 'PO';
            //careplusOrderComplete.LINE_STATUS_CODE__c = 'SHIPPED';
            careplusOrderComplete.LINE_STATUS_CODE__c = 'AWAITING_SHIPPING';
            //careplusOrderComplete.LINE_STATUS_CODE__c = 'AWAITING_SHIPPING';
            careplusOrderComplete.WORK_FLAG__c = 'Y';
            insert careplusOrderComplete;
            Database.executeBatch(new EX_CarePlusOrder_ba(null), 1);

            order[0].WORK_FLAG__c = 'I';
            update order;
            ProductRequestLineItem lineItem = [SELECT Id, PART_NO__c, Order_Number__c FROM ProductRequestLineItem LIMIT 1];
            SI_CAREPLUS_ORDER_COMPLETE__c careplusOrderComplete2 = careplusOrderComplete.clone();
            careplusOrderComplete2.LINE_STATUS_CODE__c = 'NOT';
            careplusOrderComplete2.ORIG_SYS_DOCUMENT_REF__c = lineItem.Order_Number__c;
            careplusOrderComplete2.ITEM_NO__c = lineItem.PART_NO__c;
            careplusOrderComplete2.WORK_FLAG__c = 'N';
            insert careplusOrderComplete2;
            Database.executeBatch(new EX_CarePlusOrder_ba(null), 1);
        }
        Test.stopTest();
    }

    @IsTest
    static void test_batch03() {
        Test.startTest();
        List<Contact> conList = [SELECT id FROM Contact WHERE name = '엘지베스트샵' AND MobilePhone ='02-1544-7777'];
        SI_CAREPLUS_ORDER__c siCareplusOrder = [SELECT Id FROM SI_CAREPLUS_ORDER__c];
        delete siCareplusOrder;
        ProductRequestLineItem prli = [SELECT Id, PART_NO__c FROM ProductRequestLineItem LIMIT 1];
        Account ac = [SELECT Id, AR_CODE__c FROM Account LIMIT 1];
        SI_CAREPLUS_ORDER__c careplusOrder = new SI_CAREPLUS_ORDER__c();
        careplusOrder.DIV_CODE__c = EX_TestDataUtil.DIV;
        careplusOrder.INTERFACE_ID__c = 1;
        careplusOrder.ORDER_QTY__c = 1;
        careplusOrder.ORDER_NO__c = 'PTEST2';
        careplusOrder.TRANS_TYPE__c = 'O';
        careplusOrder.WORK_FLAG__c = 'N';
        careplusOrder.PART_NO__c = prli.PART_NO__c;
        careplusOrder.BILL_TO_CODE__c = ac.AR_CODE__c;
        insert careplusOrder;
        Database.executeBatch(new EX_CarePlusOrder_ba(null), 1);
        Test.stopTest();
    }

    @IsTest
    static void test_batch04() {
        Test.startTest();
        List<Contact> conList = [SELECT id FROM Contact WHERE name = '엘지베스트샵' AND MobilePhone ='02-1544-7777'];
        List<Product2> pd = [SELECT Id FROM Product2 WHERE DISABLED_DT__c != NULL];
        if(!pd.isEmpty()){
            pd[0].DISABLED_DT__c = NULL;
            update pd;

            delete [SELECT Id FROM ProductRequest];
            Database.executeBatch(new EX_CarePlusOrder_ba(null), 1);
        }
        Test.stopTest();
    }
}