@IsTest
public class EX_SetProductItemToStorage_ba_ts {

    @TestSetup
    static void setup(){
        Product2 prd = EX_TestDataUtil.createProduct();
        prd.PART_TYPE__c = 'D';
        update prd;
        
        Product2 prd2 = EX_TestDataUtil.createProduct3();
        prd2.PART_TYPE__c = 'D';
        update prd2;

        ProductItem pi = EX_TestDataUtil.getProductItem(false);
        pi.Product2Id = prd.Id;
        pi.LocationId = EX_TestDataUtil.getLocation(true, 'Center', 'PH0300').Id;
        pi.ALLOC_QTY__c = 1;
        pi.AUTO_UNRCV_QTY__c = 1;
        pi.COLLECT_QTY__c = 1;
        pi.MOVE_QTY__c = 1;
        pi.ORDER_QTY__c = 1;
        pi.RENT_QTY__c = 1;
        pi.RESRV_QTY__c = 1;
        pi.RESRV_UNRCV_QTY__c = 1;
        pi.RETURN_ALLOC_QTY__c = 1;
        pi.JUNK_ALLOC_QTY__c = 1;
        pi.PARTS_NUMBER__c = 'EX62428605';
        insert pi;
        System.debug('pi 1 >>' + pi);
        
        ProductItem pi2 = EX_TestDataUtil.getProductItem3(false);
        pi2.Product2Id = prd2.Id;
        pi2.LocationId = EX_TestDataUtil.getLocation2(true, 'Center', 'PH8002').Id;
        pi2.ALLOC_QTY__c = 1;
        pi2.AUTO_UNRCV_QTY__c = 1;
        pi2.COLLECT_QTY__c = 1;
        pi2.MOVE_QTY__c = 1;
        pi2.ORDER_QTY__c = 1;
        pi2.RENT_QTY__c = 1;
        pi2.RESRV_QTY__c = 1;
        pi2.RESRV_UNRCV_QTY__c = 1;
        pi2.RETURN_ALLOC_QTY__c = 1;
        pi2.JUNK_ALLOC_QTY__c = 1;
        pi2.PARTS_NUMBER__c = 'EX62428605';
        insert pi2;
        System.debug('pi 2 >>' + pi2);
        
        ProductTransfer pt = EX_TestDataUtil.getProductTransfer(true);
        pt.IsReceived = true;
        pt.Fulfillment_IF_YN__c = null;
        pt.MOVE_Type_Code__c = 'A';
        pt.SourceLocationId = pi2.LocationId;
        pt.RecordTypeId = Schema.SObjectType.ProductTransfer.getRecordTypeInfosByDeveloperName().get('REGULAR').getRecordTypeId();
        update pt;
        System.debug('pt >>' + pt);
    }

    @IsTest
    static void test_batch() {
        Test.startTest();
        try{
            Database.executeBatch(new EX_SetProductItemToStorage_ba(), 1);
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

}