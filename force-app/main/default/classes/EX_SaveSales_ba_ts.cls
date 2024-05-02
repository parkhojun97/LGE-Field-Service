/****************************************************************************************
 * @filename      : EX_SaveSales_ba_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-25 오후 2:11
 * @group         :
 * @group-content :
 * @description   : EX_SaveSales_ba Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-25       I2max               Create
 ****************************************************************************************/

@IsTest
private class EX_SaveSales_ba_ts {
    @TestSetup
    static void setup(){
        SR_RESRV_PART__c part = new SR_RESRV_PART__c();
        insert part;
        EX_TestDataUtil.getProductRequestLineItem(false);
        EX_TestDataUtil.baseProductRequestLineItem.SourceLocationId = EX_TestDataUtil.baseLocation.Id;
        EX_TestDataUtil.baseProductRequestLineItem.Consumables_Order_Status__c = '030';
        EX_TestDataUtil.baseProductRequestLineItem.Order_Number__c = 'O900001654';
        EX_TestDataUtil.baseProductRequestLineItem.SUB_Order_Number__c = '%-01%';
        EX_TestDataUtil.getProductRequestLineItem(true);
        EX_TestDataUtil.baseProductRequest.Order_Number__c = 'O900001654';
        EX_TestDataUtil.baseProductRequest.SR_RSRV_PART_Id__c = part.Id;
        EX_TestDataUtil.baseProductRequest.PAYMENT_Amount__c = 3;
        EX_TestDataUtil.baseProductRequest.CARD_PAYMENT_Amount__c = 1;
        EX_TestDataUtil.baseProductRequest.CASH_PAYMENT_Amount__c = 1;
        EX_TestDataUtil.baseProductRequest.POINT_Amount__c = 1;
        EX_TestDataUtil.baseProductRequest.Order_CUST_Id__c = EX_TestDataUtil.getContact(true).Id;
//        EX_TestDataUtil.baseProductRequest.CARD_PAYMENT_Amount__c = 1000;
        update EX_TestDataUtil.baseProductRequest;

            
        SR_SMARTRO_PAYMENT_REQUEST__c srp = new SR_SMARTRO_PAYMENT_REQUEST__c();
        srp.MID__c = 'MID';
        srp.MOID__c = 'MOID';
        srp.TID__c = 'TID';
        srp.APPR_AMT__c = 500;
        srp.APPR_BALANCE__c = 0;
        srp.PAYMETHOD__c = 'CARD';
        srp.PAYMENT_TYPE__c = 'PG_URL';
        srp.SMARTRO_PAYMENT_REQUEST_PK__c = '3';
        srp.CANCEL_AMT__c = 0;
        insert srp;  

        ProductRequestLineItem line = [SELECT Order_Number__c FROM ProductRequestLineItem LIMIT 1];
        SR_PRE_PAYMENT_HEADER__c header = EX_TestDataUtil.getPrePaymentHeader(false);
        header.BASIS_NO__c = line.Order_Number__c;
        insert header;
        SR_PRE_PAYMENT_DETAIL__c detail = EX_TestDataUtil.getPrePaymentDetail(false);
        detail.DEPOSIT_TYPE__c = 'D';
        detail.SR_PRE_PAYMENT_HEADER_ID__r = header;
        detail.PAY_CUST_NAME__c ='이승현';
        detail.CERTIFY_KEY__c ='01031447479';
        detail.SR_SMARTRO_PAYMENT_REQUEST_ID__c = srp.Id;
        insert detail; 
        
      
    }

    @IsTest
    static void test_batch() {
        Test.startTest();
        try{
            Database.executeBatch(new EX_SaveSales_ba(), 1);
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
}