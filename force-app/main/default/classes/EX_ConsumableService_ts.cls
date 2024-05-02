/**
 * Created by MS on 2023-04-18.
 */

@IsTest
private class EX_ConsumableService_ts {
    @IsTest
    static void testBehavior() {
        Test.startTest();
        EX_ConsumableService.getUserInfo();
        EX_ConsumableService.doGetConsumableAmountLimit();
        EX_ConsumableService.doGetConsumableParcelFeeLimit();
        EX_ConsumableService.doGetManagerInfo();
        EX_ConsumableService.getAllFields('Account');
        EX_ConsumableService.ConsumableOrderWrapper wrapper = new EX_ConsumableService.ConsumableOrderWrapper();
        wrapper.Id = 'TEST';
        wrapper.ContactId = 'TEST';
        wrapper.IsSameOrderContact = true;
        wrapper.ConsigneeName = 'TEST';
        wrapper.ConsigneePhone1 = 'TEST';
        wrapper.ConsigneePhone2 = 'TEST';
        wrapper.ConsigneeAddress1 = 'TEST';
        wrapper.ConsigneeAddress2 = 'TEST';
        wrapper.ConsigneeAddress3 = 'TEST';
        wrapper.ConsigneeRequestTerm = 'TEST';
        wrapper.SpecialNote = 'TEST';
        wrapper.OrderClass = 'TEST';
        wrapper.OrderChannelCode = 'TEST';
        wrapper.BusinessType = 'TEST';
        wrapper.DeliveryMessageContent = 'TEST';
        
        Test.stopTest();
    }
}