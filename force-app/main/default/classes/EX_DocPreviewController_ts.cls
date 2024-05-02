/**
 * Created by MS on 2023-04-19.
 */

@IsTest
private class EX_DocPreviewController_ts {
    @TestSetup
    static void setup(){
        Test.startTest();

        TemplateMgmt__c tp1 = new TemplateMgmt__c();
        tp1.Content_c__c = 'teststests';
        tp1.Title__c = 'testsetse';
        tp1.TemplateCode__c = '소모품견적서';
        TemplateMgmt__c tp2 = tp1.clone();
        tp2.TemplateCode__c = '소모품명세서';
        insert new List<TemplateMgmt__c>{tp1, tp2};

        EX_TestDataUtil.getContact(true);
        ProductRequest pr = EX_TestDataUtil.getProductRequest(true);
        pr.CONSIGNEE_TPNO_1__c = '01012341234';
        pr.Order_CUST_TPNO_1__c = '01012341234';
        pr.CONSIGNEE_Address__c = 'Address';
        pr.CONSIGNEE_Address_DETAIL__c = 'AddressDetail';
        update pr;
        ProductRequestLineItem prli = EX_TestDataUtil.getProductRequestLineItem(true);

        SR_ONLINE_SALE_ESTIMATE__c onlineSaleEstimate = new SR_ONLINE_SALE_ESTIMATE__c();
        onlineSaleEstimate.Order_Number__c = pr.Id;
        insert onlineSaleEstimate;

        Test.stopTest();
    }

    @IsTest
    static void testBehavior() {
        Test.startTest();

        List<ProductRequestLineItem> prlis =[
                SELECT Order_Number__c, ParentId
                FROM ProductRequestLineItem
                LIMIt 1
        ];

        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('isManagement',true);
        paramMap.put('latePayment',false);
        paramMap.put('orderNumber',prlis[0].Order_Number__c);
        paramMap.put('parentId', prlis[0].ParentId);
        paramMap.put('value','["견적서","명세서","사업자등록증","통장사본"]');
        paramMap.put('RCVRName','test');
        paramMap.put('RCVREmail','test@test.com');
        paramMap.put('Note','teststs');

        try {
            EX_DocPreviewController.getTemplate(paramMap);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        paramMap.put('isManagement', false);
        paramMap.put('contactId', EX_TestDataUtil.getContact(true).Id);
        EX_SuppliesController.ItemTable it = new EX_SuppliesController.ItemTable(null, null, 'test', null, 'teststs', null, 1, 3000
        , 2000, null, null, null, null, null, null, null,
                null, null, null, 1, 1, null,
        1,
        0, 0, 3000 ,null, null, null, null, null);
        it.ParentId = prlis[0].ParentId;
        it.QTY = 1;
        paramMap.put('standardOrderData', JSON.serialize(new List<EX_SuppliesController.ItemTable>{it}));
        paramMap.put('soldOutOrderData', JSON.serialize(new List<EX_SuppliesController.ItemTable>{}));
        paramMap.put('stdConsumableOrderId', prlis[0].ParentId);
        paramMap.put('soldOutConsumableOrderId', '');
        paramMap.put('Note', 'daff');
        try {
            EX_DocPreviewController.getTemplate(paramMap);

        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        paramMap.put('latePayment', true);
        paramMap.put('IsPrint', true);
        paramMap.put('soldOutOrderData', paramMap.get('standardOrderData'));
        paramMap.put('standardOrderData', JSON.serialize(new List<EX_SuppliesController.ItemTable>{}));
        paramMap.put('soldOutConsumableOrderId', prlis[0].ParentId);
        paramMap.put('stdConsumableOrderId', null);

        try {
            EX_DocPreviewController.getTemplate(paramMap);

        } catch (Exception e) {
            System.debug(e.getMessage());
        }


//        EX_DocPreviewController.getQuoteHistory(it.ParentId);

        Map<String, Object> paramMap2 = new Map<String, Object>();
        paramMap2.put('recordId',EX_TestDataUtil.getContact(true).Id);
        paramMap2.put('orderNumber',prlis[0].ParentId);
        try {
            EX_DocPreviewController.cancelQuote(prlis[0].Order_Number__c);
            EX_DocPreviewController.getContactInfo(EX_TestDataUtil.getContact(true).Id);
            EX_DocPreviewController.saveQuote(paramMap2);

        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        Test.stopTest();
    }


    @IsTest
    static void testBehavior2() {
        Test.startTest();
        List<Contact> contacts = [
                SELECT Id
                FROM Contact
                LIMIT 1
        ];
        EX_DocPreviewController.getContactInfo(contacts[0].Id);
        Test.stopTest();
    }

    @IsTest
    static void testBehavior3() {
        List<ProductRequest> prs =[
                SELECT Order_Number__c
                FROM ProductRequest
                LIMIt 1
        ];
        List<SR_ONLINE_SALE_ESTIMATE__c> saleEstimates = [
                SELECT Id
                FROM SR_ONLINE_SALE_ESTIMATE__c
                LIMIT 1
        ];
        Test.startTest();
        EX_DocPreviewController.getQuoteHistory(prs[0].Id, saleEstimates[0].Id);
        Test.stopTest();
    }
}