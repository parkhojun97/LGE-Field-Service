/**
 * Created by A82371 on 2023-04-13.
 */

 @IsTest
 public class EX_TestDataUtil {
     public static Date tDate = Date.today();
     public static Datetime tDateTime = Datetime.now();
     public static SR_SALE__c srSale;
     public static SR_SMARTRO_PAYMENT_REQUEST__c smartroPaymentRequest;
     public static SR_PRE_PAYMENT_HEADER__c prePaymentHeader;
     public static SR_PRE_PAYMENT_DETAIL__c prePaymentDetail;
     public static Payment_Gateway__c paymentGateway;
     public static SI_ONLINE_INSTOCK_NOTICE__c onlineInStockNotice;
     public static SI_REQUEST__c siRequest;
     public static ProductRequest baseProductRequest;
     public static ProductRequest baseProductRequest2;
     public static ProductRequestLineItem baseProductRequestLineItem;
     public static ProductRequestLineItem baseProductRequestLineItem2;
     public static SM_DEPT__c dept;
     public static SM_ZIP__c zip;
     public static Product2 baseProduct;
     public static Product2 baseProduct2;
     public static Product2 modelMasterProduct;
     public static Account baseAccount;
     public static Contact baseContact;
     public static Contact baseCareContact;
     public static Schema.Location baseLocation;
     public static Schema.Location baseLocation2;
     public static Schema.Location baseLocation3;
     public static SM_DIV__c smDiv;
     public static SM_SVCBOM__c svcbom;
     public static SI_FULFILLMENT_RECEIVING__c fulfillmentReceiving;
     public static ProductItem baseProductItem;
     public static ProductItem baseProductItem2;
     public static ProductItem baseProductItem3;
     public static ProductTransfer baseProductTransfer;
     public static SI_CAREPLUS_ORDER__c careplusOrder;
     public static SI_CAREPLUS_ORDER__c careplusOrder1;
     public static SI_CAREPLUS_ORDER_COMPLETE__c careplusOrderComplete;
     public static ReturnOrder baseReturnOrder;
     public static ReturnOrder baseReturnOrder2;
     public static ReturnOrderLineItem baseReturnOrderLineItem;
     public static ReturnOrderLineItem baseReturnOrderLineItem2;
     public static User objUser;
     public static SM_CODE_MASTER__c objSmCodeMaster;
     public static SM_CODE__c objSmCode;
     public static SM_HOLIDAY_MASTER__c objHoliday;
 
     //public static String attribute10 = '0Tw0p0000004dVYCAY';
     public static String APPR_NUM = '033497230';
     public static String MID = 'tlgsmp001m';
     public static String DIV = 'DMZ';
 
     public static SM_DIV__c getDIV(boolean doInsert){
         if(smDiv == NULL){
             smDiv = new SM_DIV__c();
             smDiv.DIV_CODE__c = DIV;
             smDiv.EXT_DIV_FLAG__c = 'Y';
             smDiv.Name = 'TEST_SM_DIV';
             smDiv.SORT_ORDER__c = 1;
             if(doInsert) insert smDiv;
         }else if(smDiv != NULL && String.isBlank(smDiv.Id) && doInsert){
             insert smDiv;
         }
         return smDIv;
     }
 
     public static Contact getCareContact(Boolean doInsert){
         if(baseCareContact == null){
             baseCareContact = new Contact();
             baseCareContact.AccountId = EX_TestDataUtil.getAccount(true).Id;
             baseCareContact.Lastname = '엘지베스트샵';
             baseCareContact.SIGNATURE_YN__c = true;
             baseCareContact.B2B_CUSTOMER_YN__c = true;
             baseCareContact.SMS_RECEIVE__c = true;
             baseCareContact.SMS_RECEIVE__c = true;
             baseCareContact.IsMIG__c = true;
             baseCareContact.EXECUTIVE_YN__c = true;
             baseCareContact.THINQ_YN__c = true;
             baseCareContact.CARESHIP_YN__c = true;
             baseCareContact.HC_DENY_YN__c = true;
             baseCareContact.USE_FLAG__c = true;
             baseCareContact.isByPass__c = true;
             baseCareContact.MobilePhone = '02-1544-7777';
             baseCareContact.Phone = '02-1544-7777';
 //            baseCareContact.ADDRESS_REFINE_YN__c = true;
             if(doInsert)
             
             TriggerHandler.bypass('Contact_trHandler');
             insert baseCareContact;
             TriggerHandler.clearBypass('Contact_trHandler');
 
 
         }else if(baseCareContact != null && String.isBlank(baseCareContact.Id) && doInsert){
             TriggerHandler.bypass('Contact_trHandler');
             insert baseCareContact;
             TriggerHandler.clearBypass('Contact_trHandler');
         }
         return baseCareContact;
     }
 
 
     public static Contact getContact(Boolean doInsert){
         if(baseContact == null){
             baseContact = new Contact();
             baseContact.AccountId = EX_TestDataUtil.getAccount(true).Id;
             baseContact.Lastname = 'TESTfsfd';
             baseContact.SIGNATURE_YN__c = true;
             baseContact.B2B_CUSTOMER_YN__c = true;
             baseContact.SMS_RECEIVE__c = true;
             baseContact.SMS_RECEIVE__c = true;
             baseContact.IsMIG__c = true;
             baseContact.EXECUTIVE_YN__c = true;
             baseContact.THINQ_YN__c = true;
             baseContact.CARESHIP_YN__c = true;
             baseContact.HC_DENY_YN__c = true;
             baseContact.USE_FLAG__c = true;
             baseContact.isByPass__c = true;
             baseContact.MobilePhone = '01012345678';
             baseContact.Phone = '01012345678';
 //            baseContact.ADDRESS_REFINE_YN__c = true;
             if(doInsert)
             
             TriggerHandler.bypass('Contact_trHandler');
             insert baseContact;
             TriggerHandler.clearBypass('Contact_trHandler');
 
 
         }else if(baseContact != null && String.isBlank(baseContact.Id) && doInsert){
             TriggerHandler.bypass('Contact_trHandler');
             insert baseContact;
             TriggerHandler.clearBypass('Contact_trHandler');
         }
         return baseContact;
     }
 
     public static SM_DEPT__c getDept(Boolean doInsert, String deptCode){
         if(dept == null){
             dept = new SM_DEPT__c();
             zip = new SM_ZIP__c();
             insert zip;
             dept.CLOSE_YN__c = 'N';
             dept.DEPT_TYPE_FIRST__c = 'B';
             dept.DEPT_TYPE_SECOND__c = 'D';
             dept.DEPT_MATCH_CODE__c = 'IZ';
             dept.DEPT_CODE__c = String.isNotBlank(deptCode) ? deptCode : 'PH8002';
 
             system.debug('나는여길보고싶다');
             if(deptCode == 'PH0300'){
                 system.debug('정답1');
             }else{
                 system.debug('정답2');
             }
             dept.SM_ZIP__c = zip.Id;
             dept.Name = deptCode == 'PH0300' ? System.Label.EX_Location : 'DEPT34';
 
             system.debug('dept.Name :: '+dept.Name);
             //dept.Name = 'DEPT34';
            if(doInsert){
                TriggerHandler.bypass('SM_DEPT_trHandler');
                insert dept;
                TriggerHandler.clearBypass('SM_DEPT_trHandler');
            } 
         }else if(dept !=null && String.isBlank(dept.Id) && doInsert){
            TriggerHandler.bypass('SM_DEPT_trHandler');
             insert dept;
             TriggerHandler.clearBypass('SM_DEPT_trHandler');
         }
         return dept;
     }
     public static Account getAccount(Boolean doInsert){
         if(baseAccount == null){
             baseAccount = new Account();
             baseAccount.IsMIG__c = false;
             baseAccount.Name = 'TEST_ACC';
             baseAccount.AR_CODE__c = 'AR43543';
             baseAccount.PAYMENT_TERM__c = 'N0060FSN1010';
 
             if(doInsert) insert baseAccount;
         }else if(baseAccount != null && String.isBlank(baseAccount.Id) && doInsert){
             insert baseAccount;
         }
         return baseAccount;
     }
 
     public static Product2 getModelMasterProduct(){
         if(modelMasterProduct == null){
             modelMasterProduct = new Product2();
             modelMasterProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('SM_MODEL').getRecordTypeId();
             modelMasterProduct.Name = 'TEST MODEL_MASTER_PRODCUT';
             insert modelMasterProduct;
         }
         return modelMasterProduct;
     }
 
     public static Product2 createProduct(){
         if(baseProduct == null){
             baseProduct = new Product2();
             //baseProduct.DISABLED_DT__c = tDate;
             baseProduct.ACCESSORY_YN__c = 'Y';
             baseProduct.ASC_PRICE__c = 3000;
             baseProduct.AUTO_EX_YN__c = 'N';
             baseProduct.AVG_PRICE__c = 2000;
             baseProduct.MODEL_CODE__c = 'PFH9M1A.AKOR';
             baseProduct.MEASURE_UNIT__c = 'EA';
             baseProduct.NAME = 'ADQ75153413';
             baseProduct.CAREPLUS_MODEL_CODE__c = 'PFH9M1A.AKOR';
             baseProduct.CAREPLUS_AGENT_PRICE__c = 1000;
            //  baseProduct.CAREPLUS_PRODUCT_DETAIL__c = '8';
 //            baseProduct.CAREPLUS_PRODUCT_TYPE__c = 'A';
             baseProduct.CAREPLUS_YN__c = 'Y';
             //baseProduct.CLASS_CODE__c = 'ADQ0000';
             baseProduct.CORE_PART_TYPE__c = '1';
             baseProduct.COUNS_PART_YN__c = 'N';
             baseProduct.CUST_PRICE__c = 5000;
             baseProduct.DC_YN__c = 'N';
             baseProduct.INWTY_SUPPLY_YN__c = 'N';
             baseProduct.DISABLED_REL_DT__c = tDate;
             baseProduct.FIRST_RCV_DT__c = tDate;
             baseProduct.INPUT_DATE__c = tDatetime;
             baseProduct.DIV_INDEX_EX_YN__c = 'N';
             baseProduct.DIV_CODE__c = DIV;
             baseProduct.DISABLED_REL_DT__c = tDate;
             baseProduct.IsActive = true;
             baseProduct.isByPass__c = false;
             baseProduct.IsMIG__c = false;
             baseProduct.LAST_RCV_DT__c = tDate;
             baseProduct.LAST_RCV_PRICE__c = 4000;
             baseProduct.ProductCode = baseProduct.NAME;
             baseProduct.SALE_MODEL_CODE__c = 'EXS9342523';
             baseProduct.PART_DESC__c = 'TEST_PART_DESC';
             baseProduct.PART_SPEC__c = 'TEST_PART_SPEC';
             baseProduct.THINQ_ITEM_YN__c = 'Y';
             baseProduct.PART_TYPE__c = null;
             baseProduct.PARCEL_YN__c = null;
             baseProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('PART_NO').getRecordTypeId();
             insert baseProduct;
         }
         return baseProduct;
     }
 
     public static Product2 createProduct2(){
         if(baseProduct == null){
             baseProduct = new Product2();
             //baseProduct.DISABLED_DT__c = tDate;
             baseProduct.ACCESSORY_YN__c = 'Y';
             baseProduct.ASC_PRICE__c = 3000;
             baseProduct.AUTO_EX_YN__c = 'N';
             baseProduct.AVG_PRICE__c = 2000;
             baseProduct.MODEL_CODE__c = 'PFH9M1A.AKOR';
             baseProduct.MEASURE_UNIT__c = 'EA';
             baseProduct.NAME = 'EXS9342523';
             baseProduct.CAREPLUS_MODEL_CODE__c = 'PFH9M1A.AKOR';
             baseProduct.CAREPLUS_AGENT_PRICE__c = 1000;
            //  baseProduct.CAREPLUS_PRODUCT_DETAIL__c = '8';
 //            baseProduct.CAREPLUS_PRODUCT_TYPE__c = 'A';
             baseProduct.CAREPLUS_YN__c = 'Y';
             //baseProduct.CLASS_CODE__c = 'ADQ0000';
             baseProduct.CORE_PART_TYPE__c = '1';
             baseProduct.COUNS_PART_YN__c = 'N';
             baseProduct.CUST_PRICE__c = 5000;
             baseProduct.DC_YN__c = 'N';
             baseProduct.INWTY_SUPPLY_YN__c = 'N';
             baseProduct.DISABLED_REL_DT__c = tDate;
             baseProduct.FIRST_RCV_DT__c = tDate;
             baseProduct.INPUT_DATE__c = tDatetime;
             baseProduct.DIV_INDEX_EX_YN__c = 'N';
             baseProduct.DIV_CODE__c = DIV;
             baseProduct.DISABLED_REL_DT__c = tDate;
             baseProduct.IsActive = true;
             baseProduct.isByPass__c = false;
             baseProduct.IsMIG__c = false;
             baseProduct.LAST_RCV_DT__c = tDate;
             baseProduct.LAST_RCV_PRICE__c = 4000;
             baseProduct.ProductCode = baseProduct.NAME;
             baseProduct.SALE_MODEL_CODE__c = 'EXS9342523';
             baseProduct.PART_DESC__c = 'TEST_PART_DESC';
             baseProduct.PART_SPEC__c = 'TEST_PART_SPEC';
             baseProduct.THINQ_ITEM_YN__c = 'Y';
             baseProduct.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('PART_NO').getRecordTypeId();
             insert baseProduct;
         }
         return baseProduct;
     }
 
     public static Product2 createProduct3(){
         if(baseProduct2 == null){
             baseProduct2 = new Product2();
             //baseProduct2.DISABLED_DT__c = tDate;
             baseProduct2.ACCESSORY_YN__c = 'Y';
             baseProduct2.ASC_PRICE__c = 3000;
             baseProduct2.AUTO_EX_YN__c = 'N';
             baseProduct2.AVG_PRICE__c = 2000;
             baseProduct2.MODEL_CODE__c = 'PFH9M1A.AKOR';
             baseProduct2.MEASURE_UNIT__c = 'EA';
             baseProduct2.NAME = 'EXS9342523';
             baseProduct2.CAREPLUS_MODEL_CODE__c = 'PFH9M1A.AKOR';
             baseProduct2.CAREPLUS_AGENT_PRICE__c = 1000;
            //  baseProduct2.CAREPLUS_PRODUCT_DETAIL__c = '8';
 //            baseProduct2.CAREPLUS_PRODUCT_TYPE__c = 'A';
             baseProduct2.CAREPLUS_YN__c = 'Y';
             //baseProduct2.CLASS_CODE__c = 'ADQ0000';
             baseProduct2.CORE_PART_TYPE__c = '1';
             baseProduct2.COUNS_PART_YN__c = 'N';
             baseProduct2.CUST_PRICE__c = 5000;
             baseProduct2.DC_YN__c = 'N';
             baseProduct2.INWTY_SUPPLY_YN__c = 'N';
             baseProduct2.DISABLED_REL_DT__c = tDate;
             baseProduct2.FIRST_RCV_DT__c = tDate;
             baseProduct2.INPUT_DATE__c = tDatetime;
             baseProduct2.DIV_INDEX_EX_YN__c = 'N';
             baseProduct2.DIV_CODE__c = DIV;
             baseProduct2.DISABLED_REL_DT__c = tDate;
             baseProduct2.IsActive = true;
             baseProduct2.isByPass__c = false;
             baseProduct2.IsMIG__c = false;
             baseProduct2.LAST_RCV_DT__c = tDate;
             baseProduct2.LAST_RCV_PRICE__c = 4000;
             baseProduct2.ProductCode = baseProduct2.NAME;
             baseProduct2.SALE_MODEL_CODE__c = 'EXS9342523';
             baseProduct2.PART_DESC__c = 'TEST_PART_DESC';
             baseProduct2.PART_SPEC__c = 'TEST_PART_SPEC';
             baseProduct2.THINQ_ITEM_YN__c = 'Y';
             baseProduct2.RecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('PART_NO').getRecordTypeId();
             insert baseProduct2;
         }
         return baseProduct2;
     }
 
     public static ProductRequest getProductRequest(Boolean doInsert){
         if(baseProductRequest == null){
             baseProductRequest = new ProductRequest();
             baseProductRequest.Consumables_Order_YN__c = true;
             baseProductRequest.Consumables_Order_Class_Code__c = 'General';
             baseProductRequest.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
             baseProductRequest.APPR_NUM__c = APPR_NUM;
             baseProductRequest.CNSL_Department_Code__c = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
             baseProductRequest.Consumables_Order_USE_YN__c = true;
             baseProductRequest.Order_CHNL_TYPE_Code__c = 'V';
             baseProductRequest.Order_Number__c = 'O3443243';
             baseProductRequest.Order_CHNL_TYPE_Code__c = 'B';
             baseProductRequest.CASH_PAYMENT_Amount__c = 500;
             baseProductRequest.CARD_PAYMENT_Amount__c = 10000;
             baseProductRequest.POINT_Amount__c = 5000;
             baseProductRequest.Order_CUST_Id__c=  getContact(true).Id;
             baseProductRequest.Department_Id__c = getDept(true, null).Id;
             baseProductRequest.Department_Code__c = getDept(true, null).DEPT_CODE__c;
             baseProductRequest.Order_Date__c = tDate;
             baseProductRequest.PAYMENT_COMPLETED_DTM__c = tDate;
             if(doInsert) insert baseProductRequest;
         }else if(baseProductRequest != null && String.isBlank(baseProductRequest.Id) && doInsert){
            insert baseProductRequest;
         }
         return baseProductRequest;
     }
 
     public static ProductRequest getProductRequest2(Boolean doInsert){
         if(baseProductRequest2 == null){
             baseProductRequest2 = new ProductRequest();
             baseProductRequest2.Consumables_Order_YN__c = true;
             baseProductRequest2.Consumables_Order_Class_Code__c = 'General';
             baseProductRequest2.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
             baseProductRequest2.APPR_NUM__c = APPR_NUM;
             baseProductRequest2.CNSL_Department_Code__c = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
             baseProductRequest2.Consumables_Order_USE_YN__c = true;
             baseProductRequest2.Order_CHNL_TYPE_Code__c = 'V';
             baseProductRequest2.Order_Number__c = 'O3443243';
             baseProductRequest2.Order_CHNL_TYPE_Code__c = 'B';
             baseProductRequest2.CARD_PAYMENT_Amount__c = 10000;
             baseProductRequest2.POINT_Amount__c = 5000;
             baseProductRequest2.Order_CUST_Id__c=  getContact(true).Id;
             baseProductRequest2.Department_Id__c = getDept(true, null).Id;
             baseProductRequest2.Department_Code__c = getDept(true, null).DEPT_CODE__c;
             if(doInsert) insert baseProductRequest2;
         }else if(baseProductRequest2 != null && String.isBlank(baseProductRequest2.Id) && doInsert){
            insert baseProductRequest2;
         }
         return baseProductRequest2;
     }
 
     public static Schema.Location getLocation(Boolean doInsert, String recordTypeName, String deptCode){
         if(baseLocation == null){
             baseLocation = new Schema.Location();
             baseLocation.DEPT_CODE__c = getDept(true, deptCode).DEPT_CODE__c;
             baseLocation.DIV_CODE__c = DIV;
             baseLocation.Name = getDept(true, deptCode).Name;
             baseLocation.IsInventoryLocation = true;
             baseLocation.RecordTypeId = SObjectType.Location.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
             baseLocation.DONG_NO__c = '99';
             baseLocation.RACK_NO__c = 'A';
             baseLocation.ROW_NO__c = '9';
             baseLocation.BOX_NO__c = '99';
             if(doInsert) insert baseLocation;
         }else if(baseLocation != null && String.isBlank(baseLocation.Id) && doInsert){
             insert baseLocation;
         }
         return baseLocation;
     }
     public static Schema.Location getLocation2(Boolean doInsert, String recordTypeName, String deptCode){
         if(baseLocation3 == null){
             baseLocation3 = new Schema.Location();
             baseLocation3.DEPT_CODE__c = getDept(true, deptCode).DEPT_CODE__c;
             baseLocation3.DIV_CODE__c = DIV;
             baseLocation3.Name = '소모품센터';
             baseLocation3.IsInventoryLocation = true;
             baseLocation3.RecordTypeId = SObjectType.Location.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
             baseLocation3.DONG_NO__c = '99';
             baseLocation3.RACK_NO__c = 'A';
             baseLocation3.ROW_NO__c = '9';
             baseLocation3.BOX_NO__c = '99';
             if(doInsert) insert baseLocation3;
         }else if(baseLocation3 != null && String.isBlank(baseLocation3.Id) && doInsert){
             insert baseLocation3;
         }
         return baseLocation3;
     }
 
     public static Schema.Location getLocation_sold(Boolean doInsert, String recordTypeName, String deptCode){
         if(baseLocation == null){
             baseLocation = new Schema.Location();
             baseLocation.DEPT_CODE__c = getDept(true, deptCode).DEPT_CODE__c;
             baseLocation.DIV_CODE__c = DIV;
             baseLocation.Name = getDept(true, deptCode).Name;
             baseLocation.IsInventoryLocation = true;
             baseLocation.LocationType = 'Warehouse';
             baseLocation.RecordTypeId = SObjectType.Location.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
             if(doInsert) insert baseLocation;
         }else if(baseLocation != null && String.isBlank(baseLocation.Id) && doInsert){
             insert baseLocation;
         }
         return baseLocation;
     }
 
     public static Schema.Location getLocation_sold3(Boolean doInsert, String recordTypeName, String deptCode){
         if(baseLocation == null){
             baseLocation = new Schema.Location();
             baseLocation.DEPT_CODE__c = System.Label.EX_Location;
             baseLocation.DIV_CODE__c = 'DMZ';
             baseLocation.Name = System.Label.EX_Location;
             baseLocation.IsInventoryLocation = true;
             baseLocation.LocationType = 'Warehouse';
             baseLocation.RecordTypeId = SObjectType.Location.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
             baseLocation.DONG_NO__c = '99';
             baseLocation.RACK_NO__c = 'A';
             baseLocation.ROW_NO__c = '9';
             baseLocation.BOX_NO__c = '99';
             baseLocation.recordTypeId = Schema.SObjectType.Location.getRecordTypeInfosByName().get('사업부').getRecordTypeId();
             if(doInsert) insert baseLocation;
         }else if(baseLocation != null && String.isBlank(baseLocation.Id) && doInsert){
             insert baseLocation;
         }
         return baseLocation;
     }
     public static Schema.Location getLocation_sold4(Boolean doInsert, String recordTypeName, String deptCode){
         if(baseLocation2 == null){
             baseLocation2 = new Schema.Location();
             baseLocation2.DEPT_CODE__c = getDept(true, deptCode).DEPT_CODE__c;
             baseLocation2.DIV_CODE__c = DIV;
             baseLocation2.Name = getDept(true, deptCode).Name;
             baseLocation2.IsInventoryLocation = true;
             baseLocation2.RecordTypeId = SObjectType.Location.getRecordTypeInfosByDeveloperName().get(recordTypeName).getRecordTypeId();
             baseLocation2.DONG_NO__c = '99';
             baseLocation2.RACK_NO__c = 'A';
             baseLocation2.ROW_NO__c = '9';
             baseLocation2.BOX_NO__c = '99';
             if(doInsert) insert baseLocation2;
         }else if(baseLocation2 != null && String.isBlank(baseLocation2.Id) && doInsert){
             insert baseLocation2;
         }
         return baseLocation2;
     }
 
     public static ProductRequestLineItem getProductRequestLineItem(Boolean doInsert){
         if(baseProductRequestLineItem == null){
             baseProductRequestLineItem = new ProductRequestLineItem();
             baseProductRequestLineItem.RecordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
             baseProductRequestLineItem.ParentId = getProductRequest(true).Id;
             baseProductRequestLineItem.Order_CUST_Id__c = getProductRequest(true).Order_CUST_Id__c;
             baseProductRequestLineItem.Order_Number__c = getProductRequest(true).Order_Number__c;
             baseProductRequestLineItem.AccountId = getAccount(true).Id;
             baseProductRequestLineItem.ASC_Price__c = 30000;
             baseProductRequestLineItem.Order_SEQ__c = 1;
             baseProductRequestLineItem.CANCEL_STATUS__c = false;
             baseProductRequestLineItem.CASH_DEPOSIT_YN__c = false;
             baseProductRequestLineItem.CASH_PAYMENT_Amount__c = 2000;
             baseProductRequestLineItem.CARD_PAYMENT_Amount__c = 500;
             baseProductRequestLineItem.POINT_Amount__c = 500;
             baseProductRequestLineItem.CJ_SHIPPED_STOP_YN__c = false;
             baseProductRequestLineItem.Consumables_Business_Type_Code__c = 'Order';
             baseProductRequestLineItem.Consumables_Order_Status__c = '002';
             baseProductRequestLineItem.Consumables_Order_Class_Code__c = 'PO';
             baseProductRequestLineItem.Consumables_Order_YN__c = true;
             baseProductRequestLineItem.CONSUMER_Price__c = 30000;
             baseProductRequestLineItem.SALE_Amount__c = 30000;
             baseProductRequestLineItem.Department_Code__c = getProductRequest(true).Department_Code__c;
             baseProductRequestLineItem.ENDP_Code__c = DIV;
             baseProductRequestLineItem.RSRV_Number__c = '24423';
             baseProductRequestLineItem.RSRV_SEQ__c = 1;
             baseProductRequestLineItem.Exchange_Quantity__c = 0;
             baseProductRequestLineItem.ENDP_RSV_Quantity__c = 1;
             baseProductRequestLineItem.SALE_Quantity__c = 1;
             baseProductRequestLineItem.QuantityRequested = 1;
             baseProductRequestLineItem.Employees_Discount_Amount__c = 0;
             baseProductRequestLineItem.VIP_Discount_Amount__c = 0;
             baseProductRequestLineItem.COUPON_Discount_Amount__c = 50;
             baseProductRequestLineItem.GSCS_Order_Number__c = '4231';
             baseProductRequestLineItem.Order_CHNL_TYPE_Code__c = 'B';
             baseProductRequestLineItem.Product2Id = createProduct().Id;
             baseProductRequestLineItem.PART_NO__c = createProduct().Name;
             baseProductRequestLineItem.BASIS_Parts_Number__c = createProduct().ProductCode;
             baseProductRequestLineItem.DestinationLocationId = getLocation(true, 'Center', null).Id;
             baseProductRequestLineItem.SourceLocationId = getLocation(true, 'Center', null).Id;
             baseProductRequestLineItem.sr_sale__c = getSrSale(true).Id;
             baseProductRequestLineItem.UnitPrice__c = 10;
             if(doInsert) insert baseProductRequestLineItem;
         }else if(baseProductRequestLineItem != null && String.isBlank(baseProductRequestLineItem.Id) && doInsert){
             insert baseProductRequestLineItem;
         }
         return baseProductRequestLineItem;
     }
 
     public static ProductRequestLineItem getProductRequestLineItem2(Boolean doInsert){
         if(baseProductRequestLineItem2 == null){
             baseProductRequestLineItem2 = new ProductRequestLineItem();
             baseProductRequestLineItem2.RecordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
             baseProductRequestLineItem2.ParentId = getProductRequest2(true).Id;
             baseProductRequestLineItem2.Order_Number__c = getProductRequest2(true).Order_Number__c;
             baseProductRequestLineItem2.AccountId = getAccount(true).Id;
             baseProductRequestLineItem2.ASC_Price__c = 30000;
             baseProductRequestLineItem2.Order_SEQ__c = 1;
             baseProductRequestLineItem2.CANCEL_STATUS__c = false;
             baseProductRequestLineItem2.CASH_DEPOSIT_YN__c = false;
             baseProductRequestLineItem2.CASH_PAYMENT_Amount__c = 2000;
             baseProductRequestLineItem2.CARD_PAYMENT_Amount__c = 500;
             baseProductRequestLineItem2.POINT_Amount__c = 500;
             baseProductRequestLineItem2.CJ_SHIPPED_STOP_YN__c = false;
             baseProductRequestLineItem2.Consumables_Business_Type_Code__c = 'Order';
             baseProductRequestLineItem2.Consumables_Order_Status__c = '002';
             baseProductRequestLineItem2.Consumables_Order_Class_Code__c = 'PO';
             baseProductRequestLineItem2.Consumables_Order_YN__c = true;
             baseProductRequestLineItem2.CONSUMER_Price__c = 30000;
             baseProductRequestLineItem2.SALE_Amount__c = 30000;
             baseProductRequestLineItem2.Department_Code__c = getProductRequest2(true).Department_Code__c;
             baseProductRequestLineItem2.ENDP_Code__c = DIV;
             baseProductRequestLineItem2.RSRV_Number__c = '24423';
             baseProductRequestLineItem2.RSRV_SEQ__c = 1;
             baseProductRequestLineItem2.Exchange_Quantity__c = 0;
             baseProductRequestLineItem2.ENDP_RSV_Quantity__c = 1;
             baseProductRequestLineItem2.SALE_Quantity__c = 1;
             baseProductRequestLineItem2.QuantityRequested = 1;
             baseProductRequestLineItem2.Employees_Discount_Amount__c = 0;
             baseProductRequestLineItem2.VIP_Discount_Amount__c = 0;
             baseProductRequestLineItem2.COUPON_Discount_Amount__c = 50;
             baseProductRequestLineItem2.GSCS_Order_Number__c = '4231';
             baseProductRequestLineItem2.Order_CHNL_TYPE_Code__c = 'B';
             baseProductRequestLineItem2.Product2Id = createProduct2().Id;
             baseProductRequestLineItem2.PART_NO__c = createProduct2().Name;
             baseProductRequestLineItem2.BASIS_Parts_Number__c = createProduct2().ProductCode;
             baseProductRequestLineItem2.DestinationLocationId = getLocation(true, 'Center', null).Id;
             baseProductRequestLineItem2.SourceLocationId = getLocation(true, 'Center', null).Id;
             if(doInsert) insert baseProductRequestLineItem2;
         }else if(baseProductRequestLineItem2 != null && String.isBlank(baseProductRequestLineItem2.Id) && doInsert){
             insert baseProductRequestLineItem2;
         }
         return baseProductRequestLineItem2;
     }
 
 
     public static SI_ONLINE_INSTOCK_NOTICE__c getOnlineInStockNotice(Boolean doInsert){
         if(onlineInStockNotice == null){
             onlineInStockNotice = new SI_ONLINE_INSTOCK_NOTICE__c();
             onlineInStockNotice.BACK_IF_TRANSFER_DATE__c = tDateTime;
             onlineInStockNotice.BACK_IF_TRANSFER_FLAG__c = 'N';
             onlineInStockNotice.DIV_CODE__c = DIV;
             onlineInStockNotice.INTERFACE_ID__c = 169;
             onlineInStockNotice.NOTICE_ID__c = getProductRequestLineItem(true).GSCS_Order_Number__c;
             onlineInStockNotice.PART_NO__c = getProductRequestLineItem(true).PART_NO__c;
             onlineInStockNotice.REQ_QTY__c = 1;
             onlineInStockNotice.RESRV_REQUEST_DATE__c = tDateTime;
             onlineInStockNotice.RESRV_REQUEST_FLAG__c = 'N';
             onlineInStockNotice.SMILE_INSTOCK_FLAG__c = 'N';
             onlineInStockNotice.WORK_DATE__c = tDateTime;
             onlineInStockNotice.WORK_YN__c = 'N';
             onlineInStockNotice.ATTRIBUTE10__c = baseProductRequestLineItem.Id;
             if(doInsert) insert onlineInStockNotice;
         }else if(onlineInStockNotice != null & String.isBlank(onlineInStockNotice.Id) && doInsert){
             insert onlineInStockNotice;
         }
         return onlineInStockNotice;
     }
 
     public static SI_REQUEST__c getSIRequest(Boolean doInsert){
         if(siRequest == null){
             siRequest = new SI_REQUEST__c();
             siRequest.TRANS_FLAG__c = 'N';
             siRequest.RESV_NO__c = getProductRequestLineItem(true).RSRV_Number__c;
             siRequest.RESV_HANGNO__c = getProductRequestLineItem(true).RSRV_SEQ__c;
             if(doInsert) insert siRequest;
         }else if(siRequest != null & String.isBlank(siRequest.Id) && doInsert){
             insert siRequest;
         }
         return siRequest;
     }
 
     public static Payment_Gateway__c getPaymentGateway(Boolean doInsert){
         if(paymentGateway == null){
             paymentGateway = new Payment_Gateway__c();
             paymentGateway.DIV_CODE__c = 'PG카드_내부단말기';
             paymentGateway.MID__c = MID;
             paymentGateway.SIGN_KEY__c = 'sdfasdfasdfwerdfjgusdfg87674et7ertkhklhsdfhj';
             paymentGateway.SM_DEPT__c = getDept(true, null).Id;
             paymentGateway.VIRTUAL_ACCOUNT__c = '3333';
             if(doInsert) insert paymentGateway;
         }else if(paymentGateway != null & String.isBlank(paymentGateway.Id) & doInsert){
             insert paymentGateway;
         }
         return paymentGateway;
     }
 
     public static SR_SALE__c getSrSale(Boolean doInsert){
         if(srSale == null){
             srSale = new SR_SALE__c();
             srSale.Consumables_Order_YN__c = true;
             srSale.deficitCheck__c = false;
             srSale.paymentYN__c = false;
             srSale.createdDate = System.now();
             srSale.Order_Number__c = null;
             srSale.SALE_Number__c = 'A000104989';
             if(doInsert) insert srSale;
         }else if(srSale != null && String.isBlank(srSale.Id) && doInsert){
             insert srSale;
         }
         return srSale;
     }
 
     public static SR_PRE_PAYMENT_HEADER__c getPrePaymentHeader(Boolean doInsert){
         if(prePaymentHeader == null){
             prePaymentHeader = new SR_PRE_PAYMENT_HEADER__c();
             prePaymentHeader.ATTR_RECORD_ID__c = getSrSale(true).Id;
             prePaymentHeader.BASIS_DT__c = tDate;
             prePaymentHeader.BASIS_NO__c = getProductRequestLineItem(true).Order_Number__c;
             prePaymentHeader.BIZ_ORIGIN_TYPE__c = 'B';
             prePaymentHeader.BUNDLE__c = false;
             prePaymentHeader.Call_Reason__c = 'A';
             prePaymentHeader.OBJECT_NAME__c = 'ProductRequest';
             prePaymentHeader.PROGRESS_STATE__c = 'progressing';
             prePaymentHeader.SALE_AMT__c = 3000;
             prePaymentHeader.SETTLE_AMT__c = 3000;
             prePaymentHeader.SM_DEPT_CODE_ID__c = getDept(true, null).Id;
             if(doInsert) insert prePaymentHeader;
         }else if(prePaymentHeader != null && String.isBlank(prePaymentHeader.Id) && doInsert){
             insert prePaymentHeader;
         }
         return prePaymentHeader;
     }
 
     public static SR_PRE_PAYMENT_DETAIL__c getPrePaymentDetail(Boolean doInsert){
         if(prePaymentDetail == null){
             prePaymentDetail = new SR_PRE_PAYMENT_DETAIL__c();
             prePaymentDetail.ALLOC_MONTH__c = '0';
             prePaymentDetail.APPR_DT__c = tDate;
             prePaymentDetail.APPR_DTTM__c = tDateTime;
             prePaymentDetail.APPR_NUM__c = APPR_NUM;
             prePaymentDetail.BIZ_LICENSE_YN__c = false;
             prePaymentDetail.CERTIFY_CLASS__c = 'B';
             prePaymentDetail.CERTIFY_KEY__c = '010-1234-5678';
             prePaymentDetail.CERTIFY_TYPE__c = '1';
             prePaymentDetail.DEPOSIT_AMT__c = 500;
             prePaymentDetail.DEPOSIT_TYPE__c = 'A';
             prePaymentDetail.INPUT_TYPE__c = 'N';
             prePaymentDetail.INVOICE_ISSUE_TYPE__c = 'B';
             prePaymentDetail.PAY_CUST_NAME__c = 'TEST_NAME';
             prePaymentDetail.PAY_CUST_PHONE__c = '010-3144-7479';
             prePaymentDetail.PAYMENT_AREA_NO__c = 1;
             prePaymentDetail.POINT_TRX_ID__c = '1000006623527';
             prePaymentDetail.VOLUNTARY_YN__c = false;
             prePaymentDetail.MOID__c = MID;
             prePaymentDetail.BANK_CODE__c = 'KB000';
             prePaymentDetail.SR_PRE_PAYMENT_HEADER_ID__c = getPrePaymentHeader(true).Id;
             prePaymentDetail.TID_CASH__c = '325324242';
             prePaymentDetail.SR_SMARTRO_PAYMENT_REQUEST_ID__c = getSmartroPaymentRequest(true).Id;
             prePaymentDetail.TID__c = getSmartroPaymentRequest(true).TID__c;
             if(doInsert) insert prePaymentDetail;
         }else if(prePaymentDetail != null & String.isBlank(prePaymentDetail.Id) & doInsert){
             insert prePaymentDetail;
         }
         return prePaymentDetail;
     }
 
     public static SR_SMARTRO_PAYMENT_REQUEST__c getSmartroPaymentRequest(Boolean doInsert){
         if(smartroPaymentRequest == null){
             smartroPaymentRequest = new SR_SMARTRO_PAYMENT_REQUEST__c();
             smartroPaymentRequest.MOID__c = MID;
             smartroPaymentRequest.TID__c = '325324242' ;
             smartroPaymentRequest.APPR_NUM__c = APPR_NUM;
             smartroPaymentRequest.APPR_AMT__c = 3000;
             smartroPaymentRequest.SMARTRO_PAYMENT_REQUEST_PK__c = '999';
             if(doInsert) insert smartroPaymentRequest;
         }else if(smartroPaymentRequest != null && String.isBlank(smartroPaymentRequest.Id) && doInsert){
             insert smartroPaymentRequest;
         }
         return smartroPaymentRequest;
     }
 
     public static void getPaymentAPISetting(String name, String endPoint){
         insert new PaymentAPISetting_cs__c(Name = name, EndPoint__c = endPoint);
     }
 
     public static SM_SVCBOM__c getSVCBOM(Boolean doInsert){
         if(svcbom == null){
             svcbom = new SM_SVCBOM__c();
             svcbom.MODEL_CODE__c = getModelMasterProduct().Id;
             svcbom.DIV_CODE__c = DIV;
             svcbom.PART_NAME__c = createProduct().Id;
             if(doInsert) insert svcbom;
         }else if(svcbom !=null && String.isBlank(svcbom.Id) && doInsert){
             insert svcbom;
         }
         return svcbom;
     }
 
     public static ProductItem getProductItem(Boolean doInsert){
         if(baseProductItem == null){
             baseProductItem = new ProductItem();
             baseProductItem.LocationId = getLocation(true, 'Center', 'PH0300').Id;
             baseProductItem.Product2Id = createProduct().Id;
             baseProductItem.QuantityOnHand = 1000;
             baseProductItem.DIV_CODE__c = DIV;
             baseProductItem.QuantityUnitOfMeasure = 'Each';
             if(doInsert) insert baseProductItem;
         }else if(baseProductItem != null && String.isBlank(baseProductItem.Id) && doInsert){
             insert baseProductItem;
         }
         return baseProductItem;
     }
 
     public static ProductItem getProductItem2(Boolean doInsert){
         if(baseProductItem == null){
             baseProductItem = new ProductItem();
             baseProductItem.LocationId = getLocation_sold4(true, 'Location', 'PH8002').Id;
             baseProductItem.Product2Id = createProduct2().Id;
             baseProductItem.QuantityOnHand = 1000;
             baseProductItem.DIV_CODE__c = DIV;
             baseProductItem.QuantityUnitOfMeasure = 'Each';
             if(doInsert) insert baseProductItem;
         }else if(baseProductItem != null && String.isBlank(baseProductItem.Id) && doInsert){
             insert baseProductItem;
         }
         return baseProductItem;
     }
     public static ProductItem getProductItem3(Boolean doInsert){
         if(baseProductItem3 == null){
             baseProductItem3 = new ProductItem();
             baseProductItem3.QuantityOnHand = 10;
             baseProductItem3.DIV_CODE__c = DIV;
             baseProductItem3.Product2Id = createProduct3().Id;
             baseProductItem3.LocationId = getLocation2(true, 'Center', 'PH8002').Id;
             baseProductItem3.ALLOC_QTY__c = 1;
             baseProductItem3.AUTO_UNRCV_QTY__c = 1;
             baseProductItem3.COLLECT_QTY__c = 1;
             baseProductItem3.MOVE_QTY__c = 1;
             baseProductItem3.ORDER_QTY__c = 1;
             baseProductItem3.RENT_QTY__c = 1;
             baseProductItem3.RESRV_QTY__c = 1;
             baseProductItem3.RESRV_UNRCV_QTY__c = 1;
             baseProductItem3.RETURN_ALLOC_QTY__c = 1;
             baseProductItem3.JUNK_ALLOC_QTY__c = 1;
             baseProductItem3.PARTS_NUMBER__c = 'EX62428605';
             if(doInsert) insert baseProductItem3;
         }else if(baseProductItem3 != null && String.isBlank(baseProductItem3.Id) && doInsert){
             insert baseProductItem3;
         }
         return baseProductItem3;
     }
 
     public static ProductItem getProductItem_sold(Boolean doInsert){
         if(baseProductItem2 == null){
             baseProductItem2 = new ProductItem();
             baseProductItem2.LocationId = getLocation_sold(true, 'Location', 'PH8002').Id;
             baseProductItem2.Product2Id = createProduct3().Id;
             baseProductItem2.QuantityOnHand = 11;
             baseProductItem2.DIV_CODE__c = DIV;
             if(doInsert) insert baseProductItem2;
         }else if(baseProductItem2 != null && String.isBlank(baseProductItem2.Id) && doInsert){
             insert baseProductItem2;
         }
         return baseProductItem2;
     }
 
     public static ProductTransfer getProductTransfer(Boolean doInsert){
         if(baseProductTransfer == null){
             getProductItem(true);
             Schema.Location parentLoc = new Schema.Location();
             // parentLoc.DEPT_CODE__c = 'PH0300';
             parentLoc.DEPT_CODE__c = 'PH8002';
             parentLoc.DIV_CODE__c = DIV;
             parentLoc.Name = System.Label.EX_Location;
             parentLoc.USE_STATUS_Code__c = '재고유';
             parentLoc.RecordTypeId = SObjectType.Location.getRecordTypeInfosByDeveloperName().get('Location').getRecordTypeId();
             parentLoc.IsInventoryLocation = true;
             parentLoc.USE_STATUS_Code__c = '재고유';
             parentLoc.DONG_NO__c = '99';
             parentLoc.RACK_NO__c = 'A';
             parentLoc.ROW_NO__c = '9';
             parentLoc.BOX_NO__c = '99';
             insert parentLoc;
             // Schema.ProductItem productItem2 = new ProductItem();
             // productItem2.LocationId = EX_TestDataUtil.baseLocation.Id;
             // productItem2.Product2Id = createProduct().Id;
             // productItem2.QuantityOnHand = 10;
             // productItem2.DIV_CODE__c = DIV;
             // insert productItem2;
 
             EX_TestDataUtil.baseLocation.ParentLocationId__c = parentLoc.Id;
             update EX_TestDataUtil.baseLocation;
 
             baseProductTransfer = new ProductTransfer();
             //baseProductTransfer.SHIPPED_Date__c = tDate;
             baseProductTransfer.QuantitySent = 1;
             baseProductTransfer.QuantityReceived = 1;
             baseProductTransfer.Product2Id = createProduct().Id;
             baseProductTransfer.Order_Number__c = getProductRequestLineItem(true).Order_Number__c;
             baseProductTransfer.ProductRequestLineItemId = getProductRequestLineItem(true).Id;
             baseProductTransfer.DestinationLocationId = EX_TestDataUtil.baseLocation.Id;
             baseProductTransfer.QuantityUnitOfMeasure = 'Each';
             // baseProductTransfer.DestinationLocationId = parentLoc.Id;
             baseProductTransfer.RecordTypeId = Schema.SObjectType.ProductTransfer.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
             if(doInsert) insert baseProductTransfer;
         }else if(baseProductTransfer != null && String.isBlank(baseProductTransfer.Id) && doInsert){
             insert baseProductTransfer;
         }
         return baseProductTransfer;
     }
 
     public static ProductTransfer getProductTransfer2(Boolean doInsert){
         if(baseProductTransfer == null){
             getProductItem2(true);
             Schema.Location parentLoc = new Schema.Location();
             // parentLoc.DEPT_CODE__c = 'PH0300';
             parentLoc.DEPT_CODE__c = 'PH8002';
             parentLoc.DIV_CODE__c = DIV;
             parentLoc.Name = System.Label.EX_Location;
             parentLoc.USE_STATUS_Code__c = '재고유';
             parentLoc.RecordTypeId = SObjectType.Location.getRecordTypeInfosByDeveloperName().get('Location').getRecordTypeId();
             parentLoc.IsInventoryLocation = true;
             parentLoc.USE_STATUS_Code__c = '재고유';
             parentLoc.DONG_NO__c = '99';
             parentLoc.RACK_NO__c = 'A';
             parentLoc.ROW_NO__c = '9';
             parentLoc.BOX_NO__c = '99';
             insert parentLoc;
             // Schema.ProductItem productItem2 = new ProductItem();
             // productItem2.LocationId = EX_TestDataUtil.baseLocation.Id;
             // productItem2.Product2Id = createProduct().Id;
             // productItem2.QuantityOnHand = 10;
             // productItem2.DIV_CODE__c = DIV;
             // insert productItem2;
             EX_TestDataUtil.baseLocation.ParentLocationId__c = baseLocation2.Id;
             // EX_TestDataUtil.baseLocation.ParentLocationId__c = parentLoc.Id;
             update EX_TestDataUtil.baseLocation;
 
             baseProductTransfer = new ProductTransfer();
             //baseProductTransfer.SHIPPED_Date__c = tDate;
             baseProductTransfer.QuantitySent = 1;
             baseProductTransfer.QuantityReceived = 1;
             baseProductTransfer.Product2Id = createProduct2().Id;
             baseProductTransfer.Order_Number__c = getProductRequestLineItem2(true).Order_Number__c;
             baseProductTransfer.ProductRequestLineItemId = getProductRequestLineItem2(true).Id;
             
             baseProductTransfer.DestinationLocationId = EX_TestDataUtil.baseLocation2.Id;
             baseProductTransfer.QuantityUnitOfMeasure = 'Each';
             // baseProductTransfer.DestinationLocationId = parentLoc.Id;
             baseProductTransfer.RecordTypeId = Schema.SObjectType.ProductTransfer.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
             if(doInsert) insert baseProductTransfer;
         }else if(baseProductTransfer != null && String.isBlank(baseProductTransfer.Id) && doInsert){
             insert baseProductTransfer;
         }
         return baseProductTransfer;
     }
 
     public static ProductTransfer getProductTransfer3(Boolean doInsert){
         if(baseProductTransfer == null){
             // getProductItem2(true);
             Schema.Location parentLoc = new Schema.Location();
             // parentLoc.DEPT_CODE__c = 'PH0300';
             parentLoc.DEPT_CODE__c = 'PH8002';
             parentLoc.DIV_CODE__c = DIV;
             parentLoc.Name = System.Label.EX_Location;
             parentLoc.USE_STATUS_Code__c = '재고유';
             parentLoc.RecordTypeId = SObjectType.Location.getRecordTypeInfosByDeveloperName().get('Location').getRecordTypeId();
             parentLoc.IsInventoryLocation = true;
             parentLoc.USE_STATUS_Code__c = '재고유';
             parentLoc.DONG_NO__c = '99';
             parentLoc.RACK_NO__c = 'A';
             parentLoc.ROW_NO__c = '9';
             parentLoc.BOX_NO__c = '99';
             insert parentLoc;
             // Schema.ProductItem productItem2 = new ProductItem();
             // productItem2.LocationId = EX_TestDataUtil.baseLocation.Id;
             // productItem2.Product2Id = createProduct().Id;
             // productItem2.QuantityOnHand = 10;
             // productItem2.DIV_CODE__c = DIV;
             // insert productItem2;
             // EX_TestDataUtil.baseLocation.ParentLocationId__c = baseLocation2.Id;
             // EX_TestDataUtil.baseLocation.ParentLocationId__c = parentLoc.Id;
             // update EX_TestDataUtil.baseLocation;
 
             baseProductTransfer = new ProductTransfer();
             //baseProductTransfer.SHIPPED_Date__c = tDate;
             baseProductTransfer.QuantitySent = 1;
             baseProductTransfer.QuantityReceived = 1;
             baseProductTransfer.Product2Id = createProduct().Id;
             baseProductTransfer.Order_Number__c = getProductRequestLineItem(true).Order_Number__c;
             baseProductTransfer.ProductRequestLineItemId = getProductRequestLineItem(true).Id;
             baseProductTransfer.ReturnOrderLineItemId = getReturnOrderLineItem(true).Id;
             // baseProductTransfer.DestinationLocationId = EX_TestDataUtil.baseLocation2.Id;
             // baseProductTransfer.DestinationLocationId = parentLoc.Id;
             baseProductTransfer.RecordTypeId = Schema.SObjectType.ProductTransfer.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
             if(doInsert) insert baseProductTransfer;
         }else if(baseProductTransfer != null && String.isBlank(baseProductTransfer.Id) && doInsert){
             insert baseProductTransfer;
         }
         return baseProductTransfer;
     }
 
     public static SI_FULFILLMENT_RECEIVING__c getFulfillmentReceiving(Boolean doInsert){
         if(fulfillmentReceiving == null){
             getDept(false, 'PH0300').Name = System.Label.EX_Location;
             getLocation(true, 'Location', 'PH0300');
             getProductRequest(false).Order_CUST_Id__c = getContact(true).Id;
             fulfillmentReceiving = new SI_FULFILLMENT_RECEIVING__c();
             fulfillmentReceiving.Product_Transfer_Id__c = getProductTransfer(true).Id;
             fulfillmentReceiving.DEPT_CODE__c = getDept(true, null).DEPT_CODE__c;
             fulfillmentReceiving.ORDER_NO__c = getProductRequestLineItem(true).Order_Number__c;
             fulfillmentReceiving.ORDER_SEQ__c = getProductRequestLineItem(true).ORDER_SEQ__c;
             fulfillmentReceiving.ORDER_SUB_SEQ__c = 1;
             fulfillmentReceiving.SHIP_DEPT_CODE__c = 'd324';
             fulfillmentReceiving.DIV_CODE__c = DIV;
             fulfillmentReceiving.PART_NO__c = 'EXS9342523';
             fulfillmentReceiving.RCV_QTY__c = 1;
             fulfillmentReceiving.IF_SEND_YN__c ='Y';
             fulfillmentReceiving.RCV_CONFIRM_YN__c ='N';
             fulfillmentReceiving.IF_RESPONSE_YN__c ='Y';
             fulfillmentReceiving.SFDC_CONFIRM__c ='E';
             fulfillmentReceiving.CUSTR_PO_NO__c ='5253';
             if(doInsert) insert fulfillmentReceiving;
         }else if(fulfillmentReceiving!=null && String.isBlank(fulfillmentReceiving.Id) && doInsert){
             insert fulfillmentReceiving;
         }
         return fulfillmentReceiving;
     }
 
     public static SI_FULFILLMENT_RECEIVING__c getFulfillmentReceiving2(Boolean doInsert){
         if(fulfillmentReceiving == null){
             getDept(false, 'PH0300').Name = System.Label.EX_Location;
             getLocation(true, 'Location', 'PH0300');
             getProductRequest2(false).Order_CUST_Id__c = getContact(true).Id;
             fulfillmentReceiving = new SI_FULFILLMENT_RECEIVING__c();
             fulfillmentReceiving.Product_Transfer_Id__c = getProductTransfer2(true).Id;
             fulfillmentReceiving.DEPT_CODE__c = getDept(true, null).DEPT_CODE__c;
             fulfillmentReceiving.ORDER_NO__c = getProductRequestLineItem2(true).Order_Number__c;
             fulfillmentReceiving.ORDER_SEQ__c = getProductRequestLineItem2(true).ORDER_SEQ__c;
             fulfillmentReceiving.ORDER_SUB_SEQ__c = 1;
             fulfillmentReceiving.SHIP_DEPT_CODE__c = 'd324';
             fulfillmentReceiving.DIV_CODE__c = DIV;
             fulfillmentReceiving.PART_NO__c = 'EXS9342523';
             fulfillmentReceiving.RCV_QTY__c = 1;
             fulfillmentReceiving.IF_SEND_YN__c ='Y';
             fulfillmentReceiving.RCV_CONFIRM_YN__c ='N';
             fulfillmentReceiving.IF_RESPONSE_YN__c ='Y';
             fulfillmentReceiving.SFDC_CONFIRM__c ='E';
             fulfillmentReceiving.CUSTR_PO_NO__c ='5253';
             if(doInsert) insert fulfillmentReceiving;
         }else if(fulfillmentReceiving!=null && String.isBlank(fulfillmentReceiving.Id) && doInsert){
             insert fulfillmentReceiving;
         }
         return fulfillmentReceiving;
     }
 
     
     public static SI_FULFILLMENT_RECEIVING__c getFulfillmentReceiving3(Boolean doInsert){
         if(fulfillmentReceiving == null){
             getDept(false, 'PH0300').Name = System.Label.EX_Location;
             getLocation(true, 'Location', 'PH0300');
             getProductRequest(false).Order_CUST_Id__c = getContact(true).Id;
             fulfillmentReceiving = new SI_FULFILLMENT_RECEIVING__c();
             fulfillmentReceiving.Product_Transfer_Id__c = getProductTransfer3(true).Id;
             fulfillmentReceiving.DEPT_CODE__c = getDept(true, null).DEPT_CODE__c;
             fulfillmentReceiving.ORDER_NO__c = getProductRequestLineItem(true).Order_Number__c;
             fulfillmentReceiving.ORDER_SEQ__c = getProductRequestLineItem(true).ORDER_SEQ__c;
             fulfillmentReceiving.ORDER_SUB_SEQ__c = 1;
             fulfillmentReceiving.SHIP_DEPT_CODE__c = 'd324';
             fulfillmentReceiving.DIV_CODE__c = DIV;
             fulfillmentReceiving.PART_NO__c = 'EXS9342523';
             fulfillmentReceiving.RCV_QTY__c = 1;
             fulfillmentReceiving.IF_SEND_YN__c ='Y';
             fulfillmentReceiving.RCV_CONFIRM_YN__c ='N';
             fulfillmentReceiving.IF_RESPONSE_YN__c ='Y';
             fulfillmentReceiving.SFDC_CONFIRM__c ='F';
             fulfillmentReceiving.CUSTR_PO_NO__c ='5253';
             if(doInsert) insert fulfillmentReceiving;
         }else if(fulfillmentReceiving!=null && String.isBlank(fulfillmentReceiving.Id) && doInsert){
             insert fulfillmentReceiving;
         }
         return fulfillmentReceiving;
     }
 
     public static SI_CAREPLUS_ORDER__c getCarePlusOrder(Boolean doInsert){
         if(careplusOrder == null){
             getProductItem(true);
             getProductRequest(false);
             baseProductRequest.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
             baseProductRequest.Order_CHNL_TYPE_Code__c = 'BestShop';
             insert baseProductRequest;
             getProductRequestLineItem(false);
             baseProductRequestLineItem.RecordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
             baseProductRequestLineItem.Order_CHNL_TYPE_Code__c = 'BestShop';
             insert baseProductRequestLineItem;
 
             careplusOrder = new SI_CAREPLUS_ORDER__c();
             careplusOrder.DIV_CODE__c = DIV;
             careplusOrder.INTERFACE_ID__c = 1;
             careplusOrder.ORDER_QTY__c = 1;
             careplusOrder.ORDER_NO__c = baseProductRequestLineItem.Order_Number__c;
             careplusOrder.TRANS_TYPE__c = 'O';
             careplusOrder.WORK_FLAG__c = 'N';
             careplusOrder.PART_NO__c = baseProductRequestLineItem.PART_NO__c;
             careplusOrder.BILL_TO_CODE__c = getAccount(true).AR_CODE__c;
             careplusOrder.SHIP_TO_CODE__c = 'KR034984003-S';
             careplusOrder.MODEL_CODE__c = 'ModelCode';
             careplusOrder.ORDER_DATE__c = tDateTime;
             careplusOrder.CANCEL_DATE__c = tDateTime;
             
             if(doInsert) insert careplusOrder;
         }else if(doInsert && careplusOrder != null && String.isBlank(careplusOrder.Id)){
             insert careplusOrder;
         }
         return careplusOrder;
     }
 
     public static SI_CAREPLUS_ORDER__c getCarePlusOrder1(Boolean doInsert){
         if(careplusOrder1 == null){
             // getProductItem(true);
             // getProductRequest(false);
             // baseProductRequest.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
             // baseProductRequest.Order_CHNL_TYPE_Code__c = 'BestShop';
             // insert baseProductRequest;
             // getProductRequestLineItem(false);
             // baseProductRequestLineItem.RecordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
             // baseProductRequestLineItem.Order_CHNL_TYPE_Code__c = 'BestShop';
             // insert baseProductRequestLineItem;
 
             careplusOrder1 = new SI_CAREPLUS_ORDER__c();
             careplusOrder1.DIV_CODE__c = DIV;
             careplusOrder1.INTERFACE_ID__c = 1;
             careplusOrder1.ORDER_QTY__c = 1;
             careplusOrder1.ORDER_NO__c = baseProductRequestLineItem.Order_Number__c;
             careplusOrder1.TRANS_TYPE__c = 'O';
             careplusOrder1.WORK_FLAG__c = 'N';
             careplusOrder1.PART_NO__c = baseProductRequestLineItem.PART_NO__c;
             careplusOrder1.BILL_TO_CODE__c = getAccount(true).AR_CODE__c;
             careplusOrder1.SHIP_TO_CODE__c = 'KR034984003-S';
             careplusOrder1.MODEL_CODE__c = 'ModelCode';
             
             
             if(doInsert) insert careplusOrder1;
         }else if(doInsert && careplusOrder1 != null && String.isBlank(careplusOrder1.Id)){
             insert careplusOrder1;
         }
         return careplusOrder1;
     }
 
 
     
     public static SI_CAREPLUS_ORDER_COMPLETE__c getCareplusOrderComplete(Boolean doInsert){
         if(careplusOrderComplete == null){
             careplusOrderComplete = new SI_CAREPLUS_ORDER_COMPLETE__c();
             careplusOrderComplete.INTERFACE_ID__c = getCarePlusOrder(true).INTERFACE_ID__c;
             careplusOrderComplete.ORG_ID__c = 34142;
             careplusOrderComplete.ORIG_SYS_DOCUMENT_REF__c = getProductRequestLineItem(true).Order_Number__c;
             careplusOrderComplete.ITEM_NO__c = getProductRequestLineItem(true).PART_NO__c;
             careplusOrderComplete.ORDER_TYPE__c = 'PO';
             careplusOrderComplete.LINE_STATUS_CODE__c = 'OVERDUE_HOLD';
             if(doInsert) insert careplusOrderComplete;
         }else if(doInsert && careplusOrderComplete !=null && String.isBlank(careplusOrderComplete.Id)){
             insert careplusOrderComplete;
         }
         return careplusOrderComplete;
     }
 
     public static ReturnOrder getReturnOrder(Boolean doInsert){
         if(baseReturnOrder == null){
             baseReturnOrder = new ReturnOrder();
             baseReturnOrder.Order_Number__c = getProductRequestLineItem(true).Order_Number__c;
             baseReturnOrder.ProductRequestId = getProductRequest(true).Id;
             baseReturnOrder.Order_CHNL_TYPE_Code__c = 'B';
             baseReturnOrder.CONSIGNEE_Name__c = '테스트유저';
             baseReturnOrder.RecordTypeId = Schema.SObjectType.ReturnOrder.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
             if(doInsert) insert baseReturnOrder;
         }else if(doInsert && baseReturnOrder !=null && String.isBlank(baseReturnOrder.Id)){
             insert baseReturnOrder;
         }
         return baseReturnOrder;
     }
     public static ReturnOrder getReturnOrder2(Boolean doInsert){
        if(baseReturnOrder2 == null){
            baseReturnOrder2 = new ReturnOrder();
            baseReturnOrder2.Order_Number__c = getProductRequestLineItem2(true).Order_Number__c;
            baseReturnOrder2.ProductRequestId = getProductRequest(true).Id;
            baseReturnOrder2.Order_CHNL_TYPE_Code__c = 'BestShop';
            baseReturnOrder2.CONSIGNEE_Name__c = '테스트유저';
            baseReturnOrder2.RecordTypeId = Schema.SObjectType.ReturnOrder.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
            if(doInsert) insert baseReturnOrder2;
        }else if(doInsert && baseReturnOrder2 !=null && String.isBlank(baseReturnOrder2.Id)){
            insert baseReturnOrder2;
        }
        return baseReturnOrder2;
    }
 
     public static ReturnOrderLineItem getReturnOrderLineItem(Boolean doInsert){
         if(baseReturnOrderLineItem == null){
             baseReturnOrderLineItem = new ReturnOrderLineItem();
             baseReturnOrderLineItem.Order_Number__c = getReturnOrder(true).Order_Number__c;
             baseReturnOrderLineItem.Order_CHNL_TYPE_Code__c = 'B';
             baseReturnOrderLineItem.QuantityReturned = 1;
             baseReturnOrderLineItem.ReturnOrderId = getReturnOrder(true).Id;
             baseReturnOrderLineItem.Product2Id = createProduct().Id;
             baseReturnOrderLineItem.ProductRequestLineItemId = getProductRequestLineItem(true).Id;
             baseReturnOrderLineItem.REFUND_BANK_CODE__c =null;
             baseReturnOrderLineItem.ENC_REFUND_ACCT_Number__c = null;
             baseReturnOrderLineItem.REFUND_DPSR_Name__c = null;
             if(doInsert) insert baseReturnOrderLineItem;
         }else if(doInsert && baseReturnOrderLineItem !=null && String.isBlank(baseReturnOrderLineItem.Id)){
             insert baseReturnOrderLineItem;
         }
         return baseReturnOrderLineItem;
     }

     public static ReturnOrderLineItem getReturnOrderLineItem2(Boolean doInsert){
        if(baseReturnOrderLineItem2 == null){
            baseReturnOrderLineItem2 = new ReturnOrderLineItem();
            baseReturnOrderLineItem2.Order_Number__c = getReturnOrder2(true).Order_Number__c;
            baseReturnOrderLineItem2.Order_CHNL_TYPE_Code__c = 'BestShop';
            baseReturnOrderLineItem2.QuantityReturned = 1;
            baseReturnOrderLineItem2.ReturnOrderId = getReturnOrder2(true).Id;
            baseReturnOrderLineItem2.Product2Id = createProduct().Id;
            baseReturnOrderLineItem2.ProductRequestLineItemId = getProductRequestLineItem(true).Id;
            baseReturnOrderLineItem2.REFUND_BANK_CODE__c =null;
            baseReturnOrderLineItem2.ENC_REFUND_ACCT_Number__c = null;
            baseReturnOrderLineItem2.REFUND_DPSR_Name__c = null;
            if(doInsert) insert baseReturnOrderLineItem2;
        }else if(doInsert && baseReturnOrderLineItem2 !=null && String.isBlank(baseReturnOrderLineItem2.Id)){
            insert baseReturnOrderLineItem2;
        }
        return baseReturnOrderLineItem2;
    }
 
     public static User getUser(Boolean isInsert) {
         if(objUser==null) {
             objUser = new User();
             objUser.ProfileId           = UserInfo.getProfileId();
             objUser.LastName            = 'testUser_ex';
             objUser.EmployeeNumber      = '123456';
             objUser.Phone               = '010-1234-5678';
             objUser.Username            = 'test@lge.com'+Math.floor(Math.random() * 1000);
             objUser.Email               = 'test@lge.com.invalid';
             objUser.JOB_TYPE__c         = 'A10';
             objUser.Alias               = 'testUser';
             objUser.LocaleSidKey        = 'ko';
             objUser.LanguageLocaleKey   = 'ko';
             objUser.EmailEncodingKey    = 'ks_c_5601-1987';
             objUser.TimeZoneSidKey      = 'Asia/Seoul';
             objUser.IsActive            = true;
             objUser.DEPT_CODE__c        = 'PH8002';
             if(isInsert) insert objUser;
         }
         return objUser;
     }
 
     public static SM_CODE_MASTER__c getSmCodeMaster(Boolean isInsert) {
         if(objSmCodeMaster ==null) {
             objSmCodeMaster = new SM_CODE_MASTER__c();
             objSmCodeMaster.Name                = 'SB025';
             objSmCodeMaster.CLASS_CODE_NAME__c  = 'AR확정관리 마감상태';
             objSmCodeMaster.USE_YN__c           = 'Y';
             if(isInsert) insert objSmCodeMaster;
         }
         return objSmCodeMaster;
     }
 
     public static SM_CODE__c getSmCode(Boolean isInsert) {
         if(objSmCode ==null) {
             if(objSmCodeMaster==null) getSmCodeMaster(true);
             objSmCode = new SM_CODE__c();
             objSmCode.CLASS_CODE__c = objSmCodeMaster.Id;
             objSmCode.Name          = 'CLOSE';
             objSmCode.CODE_NAME__c  = objSmCodeMaster.CLASS_CODE_NAME__c;
             objSmCode.ATTRIBUTE1__c = Datetime.now().format('yyyy-MM-dd');
             objSmCode.ATTRIBUTE2__c = Datetime.now().format('yyyy-MM-dd');
             objSmCode.ATTRIBUTE3__c = Datetime.now().format('yyyy-MM-dd');
             if(isInsert) insert objSmCode;
         }
         return objSmCode;
     }
 
     public static SM_HOLIDAY_MASTER__c getHolidays(Boolean isInsert, String type) {
         Datetime stateDate = System.now();
         Integer dTHour = stateDate.hour();
         Integer c = 0;
         if(dTHour >= 19) {
             c = 1;
         }
 
         List<Integer> dataList = new List<Integer>{c+1, c+3, c+4, c+6, c+8};
         
         if(type == '1') {  
             for(Integer i : dataList) {
                 SM_HOLIDAY_MASTER__c objHoliday = new SM_HOLIDAY_MASTER__c();
                 objHoliday.RecordTypeId = Schema.SObjectType.SM_HOLIDAY_MASTER__c.getRecordTypeInfosByDeveloperName().get('HOLIDAY').getRecordTypeId();
                 objHoliday.HOLI_APPLY_TY__c	  = 'C';
                 objHoliday.HOLI_TYPE__c  = 'A';
                 objHoliday.HOLY_REASON__c  = '휴일대행료-공휴일';
                 objHoliday.isOfficeHoursDIsplay__c  = false;
                 objHoliday.HOLI_END_DT__c = Date.newInstance(stateDate.year()+1, stateDate.month(), stateDate.day()+i);
                 objHoliday.HOLI_START_DT__c = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+i);
                 if(isInsert) insert objHoliday;
             }      
         } else if(type == '0') {
             SM_HOLIDAY_MASTER__c objHoliday = new SM_HOLIDAY_MASTER__c();
             objHoliday.RecordTypeId = Schema.SObjectType.SM_HOLIDAY_MASTER__c.getRecordTypeInfosByDeveloperName().get('HOLIDAY').getRecordTypeId();
             objHoliday.HOLI_APPLY_TY__c	  = 'C';
             objHoliday.HOLI_TYPE__c  = 'A';           
             objHoliday.HOLY_REASON__c  = '휴일대행료-공휴일';
             objHoliday.isOfficeHoursDIsplay__c  = false;
             objHoliday.HOLI_END_DT__c = Date.newInstance(stateDate.year()+1, stateDate.month(), stateDate.day()+10);
             objHoliday.HOLI_START_DT__c = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+10);
             if(isInsert) insert objHoliday;
         }
 
         return objHoliday;
     }
 
 }