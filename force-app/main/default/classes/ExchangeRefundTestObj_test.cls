/**************************************************************************************** 
 * File Name    : ExchangeRefundTestObj_test.cls
 * Author       : Ebhan
 * Date         : 2022-12-27
 * Description  : ExchangeRefundTestObj 테스트 컨트롤러
 * Modification Log
 * =============================================================== 
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2022-12-27 	ebhan			Create
****************************************************************************************/
@IsTest
public with sharing class ExchangeRefundTestObj_test {

    @IsTest
    static void testSpecific(){
        Test.startTest();
 
        List<IF_Master__c> ifList = ExchangeRefundTestObj.ifList;
        List<IF_Master__c> ifBatchList = ExchangeRefundTestObj.ifBatchList;
        SM_CODE_MASTER__c codeMDR008 = ExchangeRefundTestObj.codeMDR008;
        SM_CODE__c codeDR008 = ExchangeRefundTestObj.codeDR008;
        SM_CODE_MASTER__c codeMDR013 = ExchangeRefundTestObj.codeMDR013;
        SM_CODE__c codeDR013 =ExchangeRefundTestObj.codeDR013;
        SM_CODE_MASTER__c codeMDR016 = ExchangeRefundTestObj.codeMDR016;
        SM_CODE__c codeDR016 =ExchangeRefundTestObj.codeDR016;
        SM_CODE_MASTER__c codeMRP017 = ExchangeRefundTestObj.codeMDR017;
        SM_CODE__c codeRP017 = ExchangeRefundTestObj.codeDR017;
        SM_CODE_MASTER__c codeMDR020 = ExchangeRefundTestObj.codeMDR020;
        SM_CODE__c codeDR020 = ExchangeRefundTestObj.codeDR020;
        SM_CODE_MASTER__c codeMDR027 = ExchangeRefundTestObj.codeMDR027;
        SM_CODE__c codeDR027 = ExchangeRefundTestObj.codeDR027;
        SM_CODE_MASTER__c codeMDR032 = ExchangeRefundTestObj.codeMDR032;
        SM_CODE__c codeDR032 = ExchangeRefundTestObj.codeDR032;
        SM_CODE_MASTER__c codeMDR035 = ExchangeRefundTestObj.codeMDR035;
        SM_CODE__c codeDR035 = ExchangeRefundTestObj.codeDR035;
        SM_CODE_MASTER__c codeMRP265 = ExchangeRefundTestObj.codeMRP265;
        SM_CODE__c codeRP265 = ExchangeRefundTestObj.codeRP265;


        WorkOrder workorder1 = ExchangeRefundTestObj.workorder1;
        WorkOrder workorder2 = ExchangeRefundTestObj.workorder2;
        Product2 product1 = ExchangeRefundTestObj.product1;
        Product2 product2 = ExchangeRefundTestObj.product2;
        SM_PRODUCT_LINE__c productLine = ExchangeRefundTestObj.productLine;
        SM_ZIP__c objSmZip = ExchangeRefundTestObj.objSmZip;
        SM_DEPT__c objSmDept = ExchangeRefundTestObj.objSmDept;
        SM_DEPT__c objSmDeptSvc = ExchangeRefundTestObj.objSmDeptSvc;

        ServiceTerritory st = ExchangeRefundTestObj.objServiceTerritory;

        ExchangeRefund__c exchange1 = ExchangeRefundTestObj.exchange1;
        ExchangeRefund__c exchange2 = ExchangeRefundTestObj.exchange2;
        ExchangeRefund__c exchange3 = ExchangeRefundTestObj.exchange3;
        ExchangeRefundLineItem__c lineItem = ExchangeRefundTestObj.lineItem;
        ExchangeRefundOrder__c orderItem = ExchangeRefundTestObj.orderItem;
        ExchangeRefundLineItem__c lineItem2 = ExchangeRefundTestObj.lineItem2;
        ExchangeRefundLineItem__c lineItem3 = ExchangeRefundTestObj.lineItem3;
        ExchangeRefundDeprec__c exDeprec = ExchangeRefundTestObj.exDeprec;
        ExchangeRefundDeprecAdujust__c exDeprecAduject = ExchangeRefundTestObj.exDeprecAduject;
        sm_nonlge_model_price__c nonlgePrice = ExchangeRefundTestObj.nonlgePrice;
        ExchangeRefundCashBack__c cashback = ExchangeRefundTestObj.cashback;
        ExchangeRefundMembership__c membership = ExchangeRefundTestObj.membership;
        ExchangeRefundMobile__c mobile = ExchangeRefundTestObj.mobile;

        SM_EXCHANGE_RESTRICT_MODEL__c restrictModelSrch = ExchangeRefundTestObj.restrictModelSrch;
        TemplateMgmt__c template =ExchangeRefundTestObj.template;

        List<ContentVersion> conversionList = ExchangeRefundTestObj.conversionList;
        //insert conversionList;
        //List<ExchangeFileInformation__c> fileList = ExchangeRefundTestObj.fileList;

        User user = ExchangeRefundTestObj.user;
        User userSvc = ExchangeRefundTestObj.userSvc;
        SM_DIV__C smDiv = ExchangeRefundTestObj.smDiv;
        Contact con = ExchangeRefundTestObj.con;

        TriggerHandler.bypass('ServiceResource_trHandler');
        ServiceResource objServiceResource = ExchangeRefundTestObj.objServiceResource;
        ServiceResource objServiceResourceSvc = ExchangeRefundTestObj.objServiceResourceSvc;
        ServiceTerritoryMember objServiceTerritoryMember = ExchangeRefundTestObj.objServiceTerritoryMember;
        TriggerHandler.clearBypass('ServiceResource_trHandler');
        
        Test.stopTest();
    }

}