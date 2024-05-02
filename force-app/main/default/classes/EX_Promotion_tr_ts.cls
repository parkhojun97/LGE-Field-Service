/****************************************************************************************
 * @filename      : EX_Promotion_tr_ts
 * @project-name  :
 * @author        : I2max
 * @date          : 2023-05-22 오전 09:06
 * @group         :
 * @group-content :
 * @description   : EX_Promotion_tr Test Code
 * @reference     :
 * @release       : v1.0.0
 * @modification Log
 * ===============================================================
 * ver     date             author              description
 * ===============================================================
 * 1.0     2023-05-22       I2max               Create
 ****************************************************************************************/

 @IsTest
 private class EX_Promotion_tr_ts {
     @IsTest
     static void test_TriggerHandler01() {
         SM_CODE_MASTER__c code_Master = new SM_CODE_MASTER__c(External_id__c = 'PT026');
         insert code_Master;
         EX_TestDataUtil.createProduct();
         Product2 prd = EX_TestDataUtil.baseProduct;
         prd.PART_TYPE__c = 'D';
         update prd;
 
         SM_DEPT__c dept = new SM_DEPT__c(DEPT_CODE__c = 'PH8002');
         insert dept;
         
         Test.startTest();
         insert new EX_Promotion__c(
                                    CLASS_CODE__c              = code_Master.Id,
                                    DIV_CODE__c                = prd.DIV_CODE__c,
                                    Part_No__c                 = prd.Name, 
                                    Promotion_USE_YN__c        = 'Y', 
                                    SHIPPED_Department_Code__c = dept.DEPT_CODE__c,
                                    PromotionStartDate__c      = System.today()+1,
                                    PromotionEndDate__c        = System.today()+2
         );
         insert new EX_Promotion__c(
                                    CLASS_CODE__c              = code_Master.Id,
                                    DIV_CODE__c                = prd.DIV_CODE__c,
                                    Part_No__c                 = prd.Name, 
                                    Promotion_USE_YN__c        = 'N', 
                                    SHIPPED_Department_Code__c = dept.DEPT_CODE__c,
                                    PromotionStartDate__c      = System.today()+1,
                                    PromotionEndDate__c        = System.today()+2
         );
 
         Test.stopTest();
     }

     @IsTest
     static void test_TriggerHandler02() {
         SM_CODE_MASTER__c code_Master = new SM_CODE_MASTER__c(External_id__c = 'PT026');
         insert code_Master;
         EX_TestDataUtil.createProduct();
         Product2 prd = EX_TestDataUtil.baseProduct;
         prd.PART_TYPE__c = 'D';
         update prd;
 
         SM_DEPT__c dept = new SM_DEPT__c(DEPT_CODE__c = 'PH8002');
         insert dept;
         
         Test.startTest();
         insert new EX_Promotion__c(
                                    CLASS_CODE__c              = code_Master.Id,
                                    DIV_CODE__c                = prd.DIV_CODE__c,
                                    Promotion_USE_YN__c        = 'Y', 
                                    Department_Code__c = dept.DEPT_CODE__c,
                                    ProductId__c               = prd.Id,
                                    PromotionStartDate__c      = System.today()+1,
                                    PromotionEndDate__c        = System.today()+2
         );
         insert new EX_Promotion__c(
                                    CLASS_CODE__c              = code_Master.Id,
                                    DIV_CODE__c                = prd.DIV_CODE__c,
                                    Promotion_USE_YN__c        = 'N', 
                                    Department_Code__c = dept.DEPT_CODE__c,
                                    ProductId__c               = prd.Id,
                                    PromotionStartDate__c      = System.today()+1,
                                    PromotionEndDate__c        = System.today()+2
         );
 
         Test.stopTest();
     }

     @IsTest
     static void test_TriggerHandler03() {
         SM_CODE_MASTER__c code_Master = new SM_CODE_MASTER__c(External_id__c = 'PT026');
         insert code_Master;
         EX_TestDataUtil.createProduct();
         Product2 prd = EX_TestDataUtil.baseProduct;
         prd.PART_TYPE__c = 'D';
         update prd;
 
         SM_DEPT__c dept = new SM_DEPT__c(DEPT_CODE__c = 'PH8002');
         insert dept;
         
         Test.startTest();
         insert new EX_Promotion__c(
                                    CLASS_CODE__c              = code_Master.Id,
                                    DIV_CODE__c                = prd.DIV_CODE__c,
                                    Promotion_USE_YN__c        = 'Y', 
                                    Department_Code__c = dept.DEPT_CODE__c,
                                    ProductId__c               = prd.Id,
                                    PromotionStartDate__c      = System.today()+1,
                                    PromotionEndDate__c        = System.today()+2
         );
         insert new EX_Promotion__c(
                                    CLASS_CODE__c              = code_Master.Id,
                                    DIV_CODE__c                = prd.DIV_CODE__c,
                                    Promotion_USE_YN__c        = 'N', 
                                    Department_Code__c = dept.DEPT_CODE__c,
                                    ProductId__c               = prd.Id,
                                    PromotionStartDate__c      = System.today()+1,
                                    PromotionEndDate__c        = System.today()+2
         );

         List<EX_Promotion__c> promList = [SELECT Id, Promotion_USE_YN__c FROM EX_Promotion__c];
         for(EX_Promotion__c item : promList){
            item.Promotion_USE_YN__c = 'Y';
         }

         update promList;
 
         Test.stopTest();
     }

 }