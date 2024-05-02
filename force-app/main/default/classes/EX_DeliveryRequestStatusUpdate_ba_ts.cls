@IsTest
public class EX_DeliveryRequestStatusUpdate_ba_ts {
    
    @TestSetup
    static void setupData(){
        ProductRequestLineItem prli =  EX_TestDataUtil.getProductRequestLineItem(true);
        prli.Appointment_Status__c = '입고완료';
        prli.Consumables_Order_Status__c = '002';
        prli.Order_CHNL_TYPE_Code__c = 'V';
        update prli;
    }

    @IsTest
    static void test_batch() {
        Test.startTest();
        try{
            Database.executeBatch(new EX_DeliveryRequestStatusUpdate_ba(), 1);
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
}