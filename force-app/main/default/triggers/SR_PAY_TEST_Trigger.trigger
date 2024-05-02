/**
 * Created by A78916 on 2023-03-06.
 */

trigger SR_PAY_TEST_Trigger on SR_PAY_TEST__c (before insert, before update) {
    SR_PAY_TEST__c[] tests = (SR_PAY_TEST__c[]) Trigger.new;
    if (null != tests) {
        SR_PAY_TEST__c[] kStrippedWo = new SR_PAY_TEST__c[]{};
        SR_PAY_TEST__c[] kStrippedSale = new SR_PAY_TEST__c[]{};
        if (Trigger.isUpdate) {
            SR_PAY_TEST__c[] testOlds = (SR_PAY_TEST__c[]) Trigger.old;
            // 값이 변경된 것만 확인
            for (Integer i = 0 ; i < tests.size() ; ++i) {
                SR_PAY_TEST__c kTestOld = testOlds[i];
                SR_PAY_TEST__c kTest = tests[i];
                if (null != kTest.Work_Order_ID__c && kTestOld.Work_Order_ID__c != kTest.Work_Order_ID__c) {
                    kStrippedWo.add(kTest);
                }
                if (null != kTest.SR_SALE_ID__c && kTestOld.SR_SALE_ID__c != kTest.SR_SALE_ID__c) {
                    kStrippedSale.add(kTest);
                }
            }
        } else {
            kStrippedWo = tests;
            kStrippedSale = tests;
        }
        Set<Id> kWoIds = SMapper.toIdSet(kStrippedWo, SR_PAY_TEST__c.Work_Order_ID__c);
        Set<Id> kSaleIds = SMapper.toIdSet(kStrippedSale, SR_PAY_TEST__c.SR_SALE_ID__c);

        WorkOrder[] kWorkOrders = [
                SELECT Id
                FROM WorkOrder
                WHERE Id IN :kWoIds
                AND Id NOT IN (SELECT WORK_ORDER_ID__c FROM SR_PAYMENT_BASIS__c)
                AND Id NOT IN (SELECT Work_Order_ID__c FROM SR_PAY_TEST__c)
        ];
        if (kWorkOrders.size() != kWoIds.size()) {
            tests[0].addError('이미 사용 중인 WorkOrder 입니다.');
        }

        SR_SALE__c[] kSales = [
                SELECT Id
                FROM SR_SALE__c
                WHERE Id IN :kSaleIds
                AND Id NOT IN (SELECT SR_SALE_ID__c FROM SR_PAYMENT_BASIS__c)
                AND Id NOT IN (SELECT SR_SALE_ID__c FROM SR_PAY_TEST__c)
        ];
        if (kSales.size() != kSaleIds.size()) {
            tests[0].addError('이미 사용 중인 SALE 입니다.');
        }

    }
}