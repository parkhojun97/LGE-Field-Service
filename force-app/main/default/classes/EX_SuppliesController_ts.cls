/**
 * Created by MS on 2023-05-08.
 */

@IsTest
private class EX_SuppliesController_ts {

    @TestSetup
    static void setup() {
        Test.startTest();

        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        EX_TestDataUtil.getUser(false).DEPT_CODE__c = 'PH8002';
        insert EX_TestDataUtil.objUser;

        List<PermissionSetGroup> psg = [SELECT Id FROM PermissionSetGroup WHERE DeveloperName = 'Consumables_FS' LIMIT 1];
        if (!psg.isEmpty()) {
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = EX_TestDataUtil.objUser.Id;
            psa.PermissionSetGroupId = psg[0].Id;

            insert psa;
        }

        System.runAs(EX_TestDataUtil.objUser) {
            EX_TestDataUtil.getDept(false, 'PH8002').DEPT_TYPE_SECOND__c = 'E';
//        EX_TestDataUtil.getDept(false, 'PH8002').DEPT_TYPE_FIRST__c = 'M';
            SM_DEPT__c highDept = EX_TestDataUtil.dept.clone(false);
            highDept.Name = '889988';
            highDept.DEPT_CODE__c = 'PH0002';
            insert highDept;
            EX_TestDataUtil.dept.HIGH_DEPT_CODE__c = highDept.Id;
            insert EX_TestDataUtil.dept;

            ServiceResource sr = new ServiceResource();
            sr.Name = 'test ccc';
            sr.RelatedRecordId = EX_TestDataUtil.objUser.Id;
            sr.IsActive = true;
            sr.SM_DEPT__c = EX_TestDataUtil.getDept(true, null).Id;
            sr.JOB_TYPE__c = 'A10';
            sr.RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('SE').getRecordTypeId();
            insert sr;

            // ServiceResource sr2 = new ServiceResource();
            // sr2.Name = 'test ccc2';
            // sr2.RelatedRecordId = EX_TestDataUtil.objUser.Id;
            // sr2.IsActive = true;
            // sr2.SM_DEPT__c = EX_TestDataUtil.getDept(true, null).Id;
            // sr2.RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('CNSL').getRecordTypeId();
            // sr2.SIGNATURE_SVC_YN__c = 'Y';
            // insert sr2;




            EX_TestDataUtil.getLocation(false, 'Center', 'PH8002').LocationType = 'Warehouse';
            EX_TestDataUtil.getLocation(false, 'Center', 'PH8002').Name = '99A999';
            insert EX_TestDataUtil.baseLocation;
            Schema.Location childLocation = EX_TestDataUtil.baseLocation.clone(false, true);
            childLocation.DEPT_CODE__c = 'PH0002';
            childLocation.LocationType = 'Warehouse';
            childLocation.Name = '99A999';
            childLocation.ParentLocationId = EX_TestDataUtil.baseLocation.Id;
            insert childLocation;

            EX_SuppliesController.getLocation(EX_TestDataUtil.dept.Id);

            List<BusinessHours> bzHours = [SELECT Id FROM BusinessHours LIMIT 1];
            if (!bzHours.isEmpty()) {
                Case nCase = new Case();
                nCase.BusinessHoursId = bzHours[0].Id;
                nCase.ContactId = EX_TestDataUtil.getContact(true).Id;
                insert nCase;

                EX_SuppliesController.doGetContactInfoByCaseId(nCase.Id);
                EX_SuppliesController.doConInfoByCase(nCase.Id);

                EX_SuppliesController.doGetContactInfoByContactId(nCase.ContactId);
            }

            try {
                EX_SuppliesController.getOrderData(new List<String>{
                        EX_TestDataUtil.getProductItem(true).Id
                }, 'test', EX_TestDataUtil.baseLocation.Id);

            } catch (Exception e) {
                System.debug(e.getMessage());
            }

            // String  strOrgName = 'Prd';
            // String  strMyHost = System.Url.getSalesforceBaseUrl().getHost();
            // //Virsualforce Url에 --c 문자가 들어가는 문제로 Replace 처리함.
            // strMyHost = strMyHost.replace('--c', '');
            // Integer nStartIndex = strMyHost.indexOf('--') + 2;
            // if(nStartIndex != 1){   // because if prod then -1 is returned, 
            //     Integer nEndIndex = strMyHost.indexOf('.');
            //     strOrgName = strMyHost.mid(nStartIndex, nEndIndex - nStartIndex);
            // }
            // System.debug( 'strOrgName::::' + strOrgName);
            // String strIfConfigName = 'ConsumableCommon' + '_'+ strOrgName;
            // System.debug( 'strIfConfigName::::' + strIfConfigName);

            
            EX_TestDataUtil.getHolidays(true, '1');
            

            


            EX_TestDataUtil.getProductItem(true);
            EX_TestDataUtil.getProductItem_sold(true);
            

            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_CIC;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443244';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(true);
            
            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);

            //OBS
            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_OBS;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443245';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(false).CONSUMER_Price__c = 1000;
            EX_TestDataUtil.getProductRequestLineItem(true);

            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'D';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);


            //ThinQ
            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_THINQ;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443246';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(true);

            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
            EX_TestDataUtil.getPrePaymentDetail(true);

            EX_TestDataUtil.getSmCode(true);


            //BestShop
            EX_TestDataUtil.getProductRequest(false).Order_CHNL_TYPE_Code__c = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;
            EX_TestDataUtil.getProductRequest(false).Order_Number__c = 'O3443246';
            EX_TestDataUtil.getProductRequest(true);

            EX_TestDataUtil.getProductRequestLineItem(false).ProductItem__c = EX_TestDataUtil.baseProductItem.Id;
            EX_TestDataUtil.getProductRequestLineItem(true);

            EX_TestDataUtil.getPrePaymentDetail(false).CARD_URL__c = 'testsafs';
            EX_TestDataUtil.getPrePaymentDetail(false).DEPOSIT_TYPE__c = 'E';
            EX_TestDataUtil.getPrePaymentDetail(true);
            
            EX_TestDataUtil.getReturnOrderLineItem(true);

            EX_TestDataUtil.getSmCode(true);

        
            

            // Schema.Location lo = new Schema.Location();
            // // lo.DEPT_CODE__c = EX_TestDataUtil.getDept(true, null).DEPT_CODE__c;
            // lo.DEPT_CODE__c = 'PH8002';
            // lo.DIV_CODE__c = 'DMZ';
            // // lo.Name = EX_TestDataUtil.getDept(true, null).Name;
            // lo.Name = '99A999';
            // lo.IsInventoryLocation = true;
            // // lo.RecordTypeId = SObjectType.Location.getRecordTypeInfosByDeveloperName().get('Center').getRecordTypeId();
            // lo.RecordTypeId = '0126D000002rQ4wQAE';
            // lo.Name = '99A999';
            
            // lo.DONG_NO__c = '99';
            // lo.RACK_NO__c = 'A';
            // lo.ROW_NO__c = '9';
            // lo.BOX_NO__c = '99';
            
            // lo.LocationType = 'Warehouse';
            // lo.RecordType.DeveloperName = 'DIV';
            // insert lo;

            

            // EX_TestDataUtil.getLocation(false).DEPT_CODE__c = 'PH8002';
            // EX_TestDataUtil.getLocation(false).LocationType = 'Warehouse';
            // EX_TestDataUtil.getLocation(false).Name = '99A999';
            // EX_TestDataUtil.getLocation(false).RecordType.DeveloperName = 'DIV';
            
            // EX_TestDataUtil.getLocation(false, 'Center', 'PH8002').LocationType =  'Warehouse';
            // EX_TestDataUtil.getLocation(false, 'Center', 'PH8002').RecordType.DeveloperName = 'DIV';
            // EX_TestDataUtil.getLocation(true, 'Center', 'PH8002');
            

            // EX_TestDataUtil.getProductItem(false).LocationId = EX_TestDataUtil.getLocation(true, 'Center', 'PH8002').Id;


        

        
        

//            Consumables_PARCEL_FEE_LIMIT_Amount__mdt limitMDT = new Consumables_PARCEL_FEE_LIMIT_Amount__mdt();
//            limitMDT.DeveloperName = EX_ConsumableService.CONSUMABLE_PARCEL_FEE_LIMIT_AMOUNT;
//            limitMDT.PARCEL_FEE_LIMIT_Amount__c = 1000000;
//            insert limitMDT;
//
//            Consumables_PARCEL_Amount_LIMIT__mdt amountMDT = new Consumables_PARCEL_Amount_LIMIT__mdt();
//            amountMDT.DeveloperName = EX_ConsumableService.CONSUMABLE_PARCEL_LIMIT_AMOUNT;
//            amountMDT.PARCEL_LIMIT_Amount__c = 10000;
//            insert amountMDT;
//
//            ApiCalloutInfo__mdt calloutInfo = new ApiCalloutInfo__mdt();
//            calloutInfo.DeveloperName = 'kakao';
//            calloutInfo.settingParamClass__c = 'CM_MsgApiInfo';
//            calloutInfo.x_apikey__c = 'B2uxz2Isi4drpvJUixXDLaHAfCDx2dJQ';
//            calloutInfo.endPointProd__c = 'https://eapi.singlex.com/scs/msg/api/v1/talk';
//            calloutInfo.endPointDev__c = 'https://eapi-dev.singlex.com/scs/msg/api/v1/talk';
//            insert calloutInfo;

            ContentVersion contentVersion = new ContentVersion(
                    Title = '사업자등록증',
                    PathOnClient = 'test.pdf',
                    VersionData = Blob.valueOf('Test Content'),
                    IsMajorVersion = true);

            ContentVersion contentVersion2 = contentVersion.clone(false);
            contentVersion2.Title = '통장 사본';
            contentVersion2.VersionData = Blob.valueOf('Test Content');

            insert new List<ContentVersion>{
                    contentVersion, contentVersion2
            };

            // ContentVersion doc = new ContentVersion();
            // string before = 'Testing base 64 encode'; 
            // Blob beforeblob = Blob.valueOf(before);
            // doc.Title = title;
            // doc.PathOnClient = 'xyz';
            // doc.VersionData = beforeblob;
            // insert doc;
    
            contentVersion = [select ContentDocumentId from ContentVersion where id = :contentVersion.id];
            contentVersion2 = [select ContentDocumentId from ContentVersion where id = :contentVersion2.id];

            ContentWorkspace testWorkspace = new ContentWorkspace(Name='testCW', DeveloperName='TEST_CLASS');
            insert testWorkspace;

            ContentWorkspace shareWorkspace = [select id from ContentWorkspace 
                    where name = 'testCW' limit 1];
    
            // ContentWorkspaceDoc docLink = new ContentWorkspaceDoc();
            // docLink.ContentDocumentId = contentVersion.ContentDocumentId;
            // docLink.ContentWorkspaceId = shareWorkspace.id;
            // insert docLink;

            // ContentWorkspaceDoc docLink2 = new ContentWorkspaceDoc();
            // docLink2.ContentDocumentId = contentVersion2.ContentDocumentId;
            // docLink2.ContentWorkspaceId = shareWorkspace.id;
            // insert docLink2;

            

            IF_Master__c ifMaster = new IF_Master__c();
            ifMaster.IfId__c = 'kakao';
            ifMaster.Name = 'MSG 카카오톡';
            ifMaster.Type__c = 'Outbound';
            ifMaster.WebServiceType__c = 'REST';
            ifMaster.Method__c = 'POST';
            ifMaster.ContentType__c = 'application/json';
            ifMaster.Endpoint__c = 'https://eapi.singlex.com/scs/msg/api/v1/talk';
            ifMaster.ParaAddHeader__c = '{\n' +
                    '"charset": "UTF-8",\n' +
                    '"Accept" : "application/json"\n' +
                    '}';
            ifMaster.APIKeyName__c = 'x-apikey';
            ifMaster.APIKeyValue__c = 'B2uxz2Isi4drpvJUixXDLaHAfCDx2dJQ';
            ifMaster.IsSendParameter__c = false;
            ifMaster.isLogInsert__c = true;

            insert ifMaster;

            TemplateMgmt__c tp1 = new TemplateMgmt__c();
            tp1.Content_c__c = 'teststests';
            tp1.Title__c = 'testsetse';
            tp1.TemplateCode__c = 'SVC_LGE_MA_101';
            TemplateMgmt__c tp2 = tp1.clone(false);
            // tp2.TemplateCode__c = 'SVC_LGE_MACN_014_02';
            tp2.TemplateCode__c = 'SVC_LGE_MACN_014_03'; //24 03 13 hyungho.chun 템플릿 금액 뒤에 '원' 추가

            insert new List<TemplateMgmt__c>{
                    tp1, tp2
            };

        }


        Test.stopTest();
    }

    @IsTest
    static void test00() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];

        System.runAs(usr[0]) {
            EX_SuppliesController.getResourceLocation();
            EX_SuppliesController.doGetServiceResource();
            EX_SuppliesController.getCenterList();
            EX_SuppliesController.getsbomList2('Id', true, '', 'test', 'test', 'test', 'test');
            // EX_SuppliesController.getPartData(new List<String>{
            //         EX_TestDataUtil.createProduct().Id
            // });
            EX_SuppliesController.doGetBulkOrderManager();
            EX_SuppliesController.doGetCostLimitManager();
            EX_SuppliesController.doGetEmpInfo();
        }
        Test.stopTest();
    }

    @IsTest
    static void test01() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        try {
            List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
            List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT Id, TID__c, MOID__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
            List<ProductItem> pi = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem WHERE QuantityOnHand != 0 LIMIT 1];
            // List<ProductItem> pi_sold = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem WHERE Location.DEPT_CODE__c = 'PH8002' LIMIT 1];
            List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
            List<ProductRequest> pr = [SELECT Id, Order_Number__c FROM ProductRequest LIMIT 1];

            if (!usr.isEmpty() && !paymentDetails.isEmpty() && !pi.isEmpty() && !contacts.isEmpty() && !pr.isEmpty()) {
                SI_SMARTRO_TOTAL_PAYMENT__c payment = new SI_SMARTRO_TOTAL_PAYMENT__c();
                payment.TID__c = paymentDetails[0].TID__c;
                payment.OID__c = paymentDetails[0].MOID__c;
                payment.PAYMETHOD__c = 'CARD';
                payment.RESULT_CODE__c = '4100';
                payment.AMT__c = 30000;
                payment.AUTH_CODE__c = '32dfas2432';
                payment.AUTH_DATE__c = '20230502123030';
                insert payment;

                List<EX_SuppliesController.ItemTable> standardOrderDataList = new List<EX_SuppliesController.ItemTable>();
                List<EX_SuppliesController.ItemTable> soldOutOrderDataList = new List<EX_SuppliesController.ItemTable>();

                for (Integer i = 0; i < 3; i++) {
                    EX_SuppliesController.ItemTable item = new EX_SuppliesController.ItemTable();
                    item.Id = 'testId' + i;
                    item.price = 1000;
                    item.ParentId = pr[0].Id;
                    soldOutOrderDataList.add(item);
                }



                EX_SuppliesController.ItemTable it = new EX_SuppliesController.ItemTable();
                it.ProductCode = pi[0].Product2.ProductCode;
                it.sProductId = pi[0].Product2Id;
                it.sLocationId = pi[0].LocationId;
                it.QTY = 1;
                it.Price = 30000;
                it.PromotionPrice = 25000;
                it.DiscountAmount = 5000;
                it.discountType = '임직원';
                it.ParentId = pr[0].Id;
                standardOrderDataList.add(it);

                Map<String, Object> mapParams = new Map<String, Object>();
                mapParams.put('contactId', contacts[0].Id);
                mapParams.put('consigneeName', 'test');
                mapParams.put('IbCallNo', '01012345678');
                mapParams.put('newAddress', 'test');
                mapParams.put('detailAddress', 'test');
                mapParams.put('requestedTerm', 'test');
                mapParams.put('remark', 'test');
                mapParams.put('isContactSame', false);
                mapParams.put('strCaseId', '');
                mapParams.put('zoneCode', '3242');
                mapParams.put('discountType', '임직원');
                mapParams.put('managerNote', 'test');
                mapParams.put('stdConsumableOrderId', pr[0].Id);
                

        mapParams.put('soldOutConsumableOrderId', pr[0].Id);
                mapParams.put('poId', pi[0].Product2Id);
                mapParams.put('stdOrderTotalPaymentAmount', 30000);
        mapParams.put('soldOutOrderTotalPaymentAmount', 30000);
                mapParams.put('stdOrderTotalSalesAmount', 30000);
        mapParams.put('soldOutOrderTotalSalesAmount', 30000);
                mapParams.put('stdOrderTotalDiscountAmount', 500);
        mapParams.put('soldOutOrderTotalDiscountAmount', 500);
                mapParams.put('standardOrderData', JSON.serialize(standardOrderDataList));
                mapParams.put('soldOutOrderData', JSON.serialize(soldOutOrderDataList));
                mapParams.put('isTemporary', true);
                mapParams.put('isManagement', false);
                mapParams.put('ContactVIP', 10);

                /*System.runAs(usr[0]){
                    EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                    SR_PRE_PAYMENT_DETAIL__c paymentDetail = [select id,DEPOSIT_TYPE__c from SR_PRE_PAYMENT_DETAIL__c Limit 1];
                    paymentDetail.DEPOSIT_TYPE__c = 'A';
                    update paymentDetail;
                    EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                    paymentDetail.DEPOSIT_TYPE__c = 'B';
                    update paymentDetail;
                    EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                    paymentDetail.DEPOSIT_TYPE__c = 'D';
                    update paymentDetail;
                    EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                }*/

                ContentWorkspace CW = [SELECT Id FROM ContentWorkspace LIMIT 1];

                insert new ContentVersion(
                        Title = 'test pdf',
                        PathOnClient = 'test.pdf',
                        VersionData = Blob.valueOf('Test Content'),
                        IsMajorVersion = true);

                SR_ONLINE_SALE_ESTIMATE__c estimate = new SR_ONLINE_SALE_ESTIMATE__c();
                estimate.Order_Number__c = pr[0].Id;
                estimate.Order_User__c = contacts[0].Id;
                estimate.OrderNumber__c = pr[0].Order_Number__c;
                estimate.Quote_YN__c = 'Y';
                estimate.Invoice_YN__c = 'Y';
                estimate.Business_Registration_YN__c = 'Y';
                estimate.BankBookCopy_YN__c = 'Y';
                insert estimate;
                EX_SuppliesController.getHistoryData(mapParams);

                mapParams.put('orderNumber', pr[0].Order_Number__c);
                EX_SuppliesController.getOrderDataList(mapParams);

                List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 2];
                if (!documents.isEmpty() && documents.size() > 1) {
                    mapParams.put('documentId', documents[0].Id);
                    mapParams.put('invoiceTempId', documents[1].Id);
                }
                estimate.DocumentID__c = documents[0].Id;
                update estimate;
                mapParams.put('contactId', contacts[0].Id);
                mapParams.put('value', JSON.serialize(new List<String>()));
                mapParams.put('RCVRName', '3242');
                mapParams.put('RCVREmail', 'abcdef@naver.com');
                mapParams.put('stdConsumableOrderId', estimate.Order_Number__c);
                mapParams.put('soldOutConsumableOrderId', estimate.Order_Number__c);
                mapParams.put('isManagement', true);
                mapParams.put('orderNumber', estimate.OrderNumber__c);
                mapParams.put('historyId', estimate.Id);
                mapParams.put('ContactVIP', 100);

                try {
                    EX_SuppliesController.doSendPDF(mapParams);
                } catch (Exception e) {
                    System.debug(e);
                }

                contacts[0].CUSTOMER_GRADE__c = 'E1';
                update contacts;
                EX_SuppliesController.doGetContactVIP(contacts[0].Id);
                contacts[0].CUSTOMER_GRADE__c = 'I1';
                update contacts;
                EX_SuppliesController.doGetContactVIP(contacts[0].Id);
                contacts[0].CUSTOMER_GRADE__c = 'I2';
                update contacts;
                EX_SuppliesController.doGetContactVIP(contacts[0].Id);
                contacts[0].CUSTOMER_GRADE__c = 'I3';
                update contacts;
                EX_SuppliesController.doGetContactVIP(contacts[0].Id);

                mapParams.put('partId', pi[0].Product2Id);
                mapParams.put('productCode', pi[0].Product2.ProductCode);
                mapParams.put('locationId', pi[0].LocationId);
                mapParams.put('divCode', pi[0].Product2.DIV_CODE__c);

                try {
                    EX_SuppliesController.getInitData(JSON.serialize(mapParams));
                } catch (Exception e) {
                    System.debug(e);
                }
                try {
                    EX_SuppliesController.getMinimumCost();
                } catch (Exception e) {
                    System.debug(e);
                }
                try {
                    EX_SuppliesController.getMaximumAmount();
                } catch (Exception e) {
                    System.debug(e);
                }

                EX_SuppliesController.doGetOrderInfo(mapParams);

                EX_SuppliesController.exSuppliesCreateOrderGroup(mapParams);

                List<String> divCodeList = new List<String>();
                EX_SuppliesController.getShipmentName(divCodeList);
                divCodeList.add('CNZ');
                divCodeList.add('PH8002');
                EX_SuppliesController.getShipmentName(divCodeList);

                
            

            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void test02() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        try {
            EX_SuppliesController.doSendKakaoMessage(null);
        } catch (Exception e) {
            System.debug(e);
        }

        ProductRequestLineItem prli = [SELECT Id, Product2Id, ProductItem__c FROM ProductRequestLineItem LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        Product2 product =[SELECT Id, PART_TYPE__c, PARCEL_YN__c FROM Product2 LIMIT 1][0];
        product.PART_TYPE__c = 'D';
        product.PARCEL_YN__c = 'Y';
        update product;

        Map<String, Object> objMap = new Map<String, Object>();
        objMap.put('Id', prli.Id);
        objMap.put('ContactId', contacts[0].Id);
        EX_SuppliesController.doGetExchangeOrderData(new List<Map<String, Object>>{
                objMap
        });
        prli.ProductItem__c = null;
        update prli;

        objMap.put('contactId', contacts[0].Id);
        // Map<String,Object> a = new Map<String,Object>();
        // a.put('Product2Id',prli.Product2Id);
        // a.put('Quantity',2);
        // List<Object> b = new List<Object>();
        // b.add(a);
        // objMap.put('productIds', b);
        objMap.put('productIds', new List<String>{
                prli.Product2Id
        });
        
        try {
            EX_SuppliesController.doGetDataByMaterialPortal(objMap);
            // EX_SuppliesController.doGetDataByMaterialPortal2(objMap);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
    @IsTest
    static void test02_2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        try {
            EX_SuppliesController.doSendKakaoMessage(null);
        } catch (Exception e) {
            System.debug(e);
        }

        ProductRequestLineItem prli = [SELECT Id, Product2Id, ProductItem__c FROM ProductRequestLineItem LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        Product2 product =[SELECT Id, PART_TYPE__c, PARCEL_YN__c FROM Product2 LIMIT 1][0];
        product.PART_TYPE__c = 'D';
        product.PARCEL_YN__c = 'Y';
        update product;

        Map<String, Object> objMap = new Map<String, Object>();
        objMap.put('Id', prli.Id);
        objMap.put('ContactId', contacts[0].Id);
        EX_SuppliesController.doGetExchangeOrderData(new List<Map<String, Object>>{
                objMap
        });
        prli.ProductItem__c = null;
        update prli;

        objMap.put('contactId', contacts[0].Id);
        Map<String,Object> a = new Map<String,Object>();
        a.put('Product2Id',prli.Product2Id);
        a.put('Quantity',2);
        List<Object> b = new List<Object>();
        b.add(a);
        objMap.put('productIds', b);
        // objMap.put('productIds', new List<String>{
        //         prli.Product2Id
        // });
        
        try {
            // EX_SuppliesController.doGetDataByMaterialPortal(objMap);
            EX_SuppliesController.doGetDataByMaterialPortal2(objMap);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }


    @IsTest
    static void test03() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        try {

            List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
            List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT Id, TID__c, MOID__c, SR_PRE_PAYMENT_HEADER_ID__c, SR_SMARTRO_PAYMENT_REQUEST_ID__c, SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
            List<ProductItem> pi = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem WHERE Location.DEPT_CODE__c != 'PH8002'  LIMIT 1];
            List<ProductItem> pi_sold = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem WHERE Location.DEPT_CODE__c = 'PH8002' LIMIT 1];
            List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];

            
            List<ProductRequest> pr = [SELECT Id, Order_Number__c FROM ProductRequest LIMIT 1];

            if (!usr.isEmpty() && !paymentDetails.isEmpty() && !pi.isEmpty() && !contacts.isEmpty() && !pr.isEmpty()) {
                EX_TestDataUtil.prePaymentHeader = new SR_PRE_PAYMENT_HEADER__c(Id = paymentDetails[0].SR_PRE_PAYMENT_HEADER_ID__c);
                EX_TestDataUtil.getSmartroPaymentRequest(false).TID__c = '834321111';
                EX_TestDataUtil.getPrePaymentDetail(true);

                SI_SMARTRO_TOTAL_PAYMENT__c payment = new SI_SMARTRO_TOTAL_PAYMENT__c();
                payment.TID__c = paymentDetails[0].TID__c;
                payment.OID__c = paymentDetails[0].MOID__c;
                payment.PAYMETHOD__c = 'CARD';
                payment.RESULT_CODE__c = '4100';
                payment.AMT__c = 20000;
                payment.AUTH_CODE__c = '32dfas2432';
                payment.AUTH_DATE__c = '20230502123030';

                SI_SMARTRO_TOTAL_PAYMENT__c payment2 = payment.clone();
                payment2.TID__c = EX_TestDataUtil.prePaymentDetail.TID__c;
                payment2.AMT__c = 10000;
                insert new List<SI_SMARTRO_TOTAL_PAYMENT__c>{
                        payment, payment2
                };
                
                List<EX_SuppliesController.ItemTable> standardOrderDataList = new List<EX_SuppliesController.ItemTable>();
                List<EX_SuppliesController.ItemTable> soldOutOrderDataList = new List<EX_SuppliesController.ItemTable>();
                EX_SuppliesController.ItemTable it = new EX_SuppliesController.ItemTable();
                EX_SuppliesController.ItemTable it_sold = new EX_SuppliesController.ItemTable();
                it.ProductCode = pi[0].Product2.ProductCode;
                it.sProductId = pi[0].Product2Id;
                it.sLocationId = pi[0].LocationId;
                it.QTY = 1;
                it.Price = 30000;
                it.PromotionPrice = 25000;
                it_sold.ProductCode = pi_sold[0].Product2.ProductCode;
                it_sold.sProductId = pi_sold[0].Product2Id;
                it_sold.sLocationId = pi_sold[0].LocationId;
                it_sold.QTY = 1;
                it_sold.Price = 30000;
                it_sold.PromotionPrice = 25000;
                standardOrderDataList.add(it);
                soldOutOrderDataList.add(it_sold);


                Map<String, Object> mapParams = new Map<String, Object>();
                mapParams.put('contactId', contacts[0].Id);
                mapParams.put('consigneeName', 'test');
                mapParams.put('IbCallNo', '01012345678');
                mapParams.put('newAddress', 'test');
                mapParams.put('detailAddress', 'test');
                mapParams.put('requestedTerm', 'test');
                mapParams.put('remark', 'test');
                mapParams.put('isContactSame', true);
                mapParams.put('strCaseId', '');
                mapParams.put('zoneCode', '3242');
                mapParams.put('discountType', '임직원');
                mapParams.put('managerNote', 'test');
                mapParams.put('stdConsumableOrderId', pr[0].Id);
                mapParams.put('soldOutConsumableOrderId', pr[0].Id);
                mapParams.put('poId', pi[0].Product2Id);
//            mapParams.put('stdOrderTotalPaymentAmount',30000);
                // mapParams.put('soldOutOrderTotalPaymentAmount', 30000);
//            mapParams.put('stdOrderTotalSalesAmount', 30000);
                // mapParams.put('soldOutOrderTotalSalesAmount', 30000);
//            mapParams.put('stdOrderTotalDiscountAmount', 500);
                // mapParams.put('soldOutOrderTotalDiscountAmount', 500);
                mapParams.put('standardOrderData', JSON.serialize(standardOrderDataList));
                mapParams.put('soldOutOrderData', JSON.serialize(soldOutOrderDataList));
                mapParams.put('isTemporary', false);
                mapParams.put('isExchangeOrder', true);
                mapParams.put('ContactVIP', 1777);

                mapParams.put('isManagement', true);


            

                
                System.runAs(usr[0]) {
                    try {
                        EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                        EX_SuppliesController.doSaveConsumableOrder(mapParams);

                        System.debug('test03 성공');
                    } catch (Exception e) {
                    System.debug('test03 실패');
                        System.debug(e);
                    }
    
                }
                
                mapParams.put('ProductCode', '3424');
                mapParams.put('ProductName', 'dfasfasd');
                mapParams.put('ContactVIP', 1777);

                EX_SuppliesController.insertExMessageObj(JSON.serialize(mapParams), 'SVC_LGE_MA_101');

                pr[0].PAYMENT_TYPE__c = 'VBANK';

                update new SR_SMARTRO_PAYMENT_REQUEST__c(Id = paymentDetails[0].SR_SMARTRO_PAYMENT_REQUEST_ID__c, PAYMETHOD__c = 'VBANK', PAYMENT_YN__c = true);

                paymentDetails[0].BANK_CODE__c = '005';
                paymentDetails[0].VIRTUAL_ACCT_NUMBER__c = '032432405';
                paymentDetails[0].PAYMENT_AREA_NO__c = 2;
                update paymentDetails;

                EX_SuppliesController.doSetPaymentData(new Set<String>{
                        paymentDetails[0].SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c
                }, JSON.serialize(pr[0]));

            }

        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        Test.stopTest();
    }

    @IsTest
    static void test03_01() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
    

            List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
            List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT Id, TID__c, MOID__c, SR_PRE_PAYMENT_HEADER_ID__c, SR_SMARTRO_PAYMENT_REQUEST_ID__c, SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
            List<ProductItem> pi = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem WHERE Location.DEPT_CODE__c != 'PH8002'  LIMIT 1];
            List<ProductItem> pi_sold = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem WHERE Location.DEPT_CODE__c = 'PH8002' LIMIT 1];
            List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];

            
            List<ProductRequest> pr = [SELECT Id, Order_Number__c FROM ProductRequest LIMIT 1];

                Map<String, Object> mapParams = new Map<String, Object>();

                mapParams.put('stdConsumableOrderId', pr[0].Id);
                mapParams.put('soldOutConsumableOrderId', pr[0].Id);


            

                
                System.runAs(usr[0]) {
                    try {
                        // EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                        // EX_SuppliesController.doSaveConsumableOrder(mapParams);

                        EX_SuppliesController.doOrderDeleteInfo(mapParams);
                    } catch (Exception e) {
                        System.debug(e);
                    }
    
                }
                



        Test.stopTest();
    }    

    @IsTest
    static void test03_1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        try {

            List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
            List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT Id, TID__c, MOID__c, SR_PRE_PAYMENT_HEADER_ID__c, SR_SMARTRO_PAYMENT_REQUEST_ID__c, SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
            List<ProductItem> pi = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem WHERE Location.DEPT_CODE__c != 'PH8002'  LIMIT 1];
            List<ProductItem> pi_sold = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem WHERE Location.DEPT_CODE__c = 'PH8002' LIMIT 1];
            List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
            List<ProductRequest> pr = [SELECT Id, Order_Number__c FROM ProductRequest LIMIT 1];

            if (!usr.isEmpty() && !paymentDetails.isEmpty() && !pi.isEmpty() && !contacts.isEmpty() && !pr.isEmpty()) {
                EX_TestDataUtil.prePaymentHeader = new SR_PRE_PAYMENT_HEADER__c(Id = paymentDetails[0].SR_PRE_PAYMENT_HEADER_ID__c);
                EX_TestDataUtil.getSmartroPaymentRequest(false).TID__c = '834321111';
                EX_TestDataUtil.getPrePaymentDetail(true);

                SI_SMARTRO_TOTAL_PAYMENT__c payment = new SI_SMARTRO_TOTAL_PAYMENT__c();
                payment.TID__c = paymentDetails[0].TID__c;
                payment.OID__c = paymentDetails[0].MOID__c;
                payment.PAYMETHOD__c = 'CARD';
                payment.RESULT_CODE__c = '4100';
                payment.AMT__c = 20000;
                payment.AUTH_CODE__c = '32dfas2432';
                payment.AUTH_DATE__c = '20230502123030';

                SI_SMARTRO_TOTAL_PAYMENT__c payment2 = payment.clone();
                payment2.TID__c = EX_TestDataUtil.prePaymentDetail.TID__c;
                payment2.AMT__c = 10000;
                insert new List<SI_SMARTRO_TOTAL_PAYMENT__c>{
                        payment, payment2
                };

                List<EX_SuppliesController.ItemTable> standardOrderDataList = new List<EX_SuppliesController.ItemTable>();
                List<EX_SuppliesController.ItemTable> soldOutOrderDataList = new List<EX_SuppliesController.ItemTable>();
                EX_SuppliesController.ItemTable it = new EX_SuppliesController.ItemTable();
                EX_SuppliesController.ItemTable it_sold = new EX_SuppliesController.ItemTable();
                it.ProductCode = pi[0].Product2.ProductCode;
                it.sProductId = pi[0].Product2Id;
                it.sLocationId = pi[0].LocationId;
                it.QTY = 1;
                it.Price = 30000;
                it.PromotionPrice = 25000;
                it_sold.ProductCode = pi_sold[0].Product2.ProductCode;
                it_sold.sProductId = pi_sold[0].Product2Id;
                it_sold.sLocationId = pi_sold[0].LocationId;
                it_sold.QTY = 1;
                it_sold.Price = 30000;
                it_sold.PromotionPrice = 25000;
                standardOrderDataList.add(it);
                soldOutOrderDataList.add(it_sold);

                

                Map<String, Object> mapParams = new Map<String, Object>();
                mapParams.put('contactId', contacts[0].Id);
                mapParams.put('consigneeName', 'test');
                mapParams.put('IbCallNo', '01012345678');
                mapParams.put('newAddress', 'test');
                mapParams.put('detailAddress', 'test');
                mapParams.put('requestedTerm', 'test');
                mapParams.put('remark', 'test');
                // mapParams.put('isContactSame', true);
                mapParams.put('isContactSame', false);
                mapParams.put('strCaseId', '');
                mapParams.put('zoneCode', '3242');
                mapParams.put('discountType', '임직원');
                mapParams.put('managerNote', 'test');
                mapParams.put('stdConsumableOrderId', pr[0].Id);
                mapParams.put('soldOutConsumableOrderId', pr[0].Id);
                mapParams.put('poId', pi[0].Product2Id);
//            mapParams.put('stdOrderTotalPaymentAmount',30000);
                // mapParams.put('soldOutOrderTotalPaymentAmount', 30000);
//            mapParams.put('stdOrderTotalSalesAmount', 30000);
                // mapParams.put('soldOutOrderTotalSalesAmount', 30000);
//            mapParams.put('stdOrderTotalDiscountAmount', 500);
                // mapParams.put('soldOutOrderTotalDiscountAmount', 500);
                mapParams.put('standardOrderData', JSON.serialize(standardOrderDataList));
                mapParams.put('soldOutOrderData', JSON.serialize(soldOutOrderDataList));
                // mapParams.put('isTemporary', false);
                mapParams.put('isTemporary', true);
                // mapParams.put('isExchangeOrder', true);
                mapParams.put('isExchangeOrder', false);
                mapParams.put('ContactVIP', 100);


                
                System.runAs(usr[0]) {
                    try {
                        EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);

                        EX_SuppliesController.doSaveConsumableOrder(mapParams);
                    System.debug('test03_1 성공');                         
                    } catch (Exception e) {
                        System.debug(e);
                        System.debug('test03_1 실패');
                    }
    
                }
    
                
            
                mapParams.put('ProductCode', '3424');
                mapParams.put('ProductName', 'dfasfasd');
                mapParams.put('ContactVIP', 1777);

                EX_SuppliesController.insertExMessageObj(JSON.serialize(mapParams), 'SVC_LGE_MA_101');

                pr[0].PAYMENT_TYPE__c = 'VBANK';

                update new SR_SMARTRO_PAYMENT_REQUEST__c(Id = paymentDetails[0].SR_SMARTRO_PAYMENT_REQUEST_ID__c, PAYMETHOD__c = 'VBANK');

                paymentDetails[0].BANK_CODE__c = '005';
                paymentDetails[0].VIRTUAL_ACCT_NUMBER__c = '032432405';
                paymentDetails[0].PAYMENT_AREA_NO__c = 2;
                update paymentDetails;

                EX_SuppliesController.doSetPaymentData(new Set<String>{
                        paymentDetails[0].SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c
                }, JSON.serialize(pr[0]));

            }

        } catch (Exception e) {
            System.debug(e.getMessage());
        }

        Test.stopTest();
    }


    @IsTest
    static void test04() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
        List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT Id, TID__c, MOID__c, SR_PRE_PAYMENT_HEADER_ID__r.ATTR_RECORD_ID__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
        List<ProductItem> pi = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        List<ProductRequestLineItem> prli = [SELECT Id, Order_Number__c, BASIS_Number__c, ParentId FROM ProductRequestLineItem LIMIT 1];

        if (!usr.isEmpty() && !paymentDetails.isEmpty() && !pi.isEmpty() && !contacts.isEmpty() && !prli.isEmpty()) {
            SI_SMARTRO_TOTAL_PAYMENT__c payment = new SI_SMARTRO_TOTAL_PAYMENT__c();
            payment.TID__c = paymentDetails[0].TID__c;
            payment.OID__c = paymentDetails[0].MOID__c;
            payment.PAYMETHOD__c = 'CARD';
            payment.RESULT_CODE__c = '4100';
            payment.AMT__c = 30000;
            payment.AUTH_CODE__c = '32dfas2432';
            payment.AUTH_DATE__c = '20230502123030';
            insert payment;

            List<EX_SuppliesController.ItemTable> standardOrderDataList = new List<EX_SuppliesController.ItemTable>();
            EX_SuppliesController.ItemTable it = new EX_SuppliesController.ItemTable();
            it.ProductCode = pi[0].Product2.ProductCode;
            it.sProductId = pi[0].Product2Id;
            it.sLocationId = pi[0].LocationId;
            it.QTY = 1;
            it.Price = 30000;
            it.PromotionPrice = 25000;
            it.ParentId = prli[0].ParentId;
            standardOrderDataList.add(it);

            Map<String, Object> mapParams = new Map<String, Object>();
            Map<String, Object> exchangeReturnData = new Map<String, Object>();
            exchangeReturnData.put('Id', prli[0].Id);
            exchangeReturnData.put('RequestedReturnQuantity', 1);
            exchangeReturnData.put('Price', 1);
            exchangeReturnData.put('DIVCODE', pi[0].Product2.DIV_CODE__c);
            exchangeReturnData.put('ProductCode', it.ProductCode);
            exchangeReturnData.put('sProductId', it.sProductId);
            exchangeReturnData.put('sProductId', it.sProductId);
            exchangeReturnData.put('ParentId', prli[0].ParentId);

            mapParams.put('contactId', contacts[0].Id);
            mapParams.put('consigneeName', 'test');
            mapParams.put('IbCallNo', '01012345678');
            mapParams.put('newAddress', 'test');
            mapParams.put('detailAddress', 'test');
            mapParams.put('requestedTerm', 'test');
            mapParams.put('remark', 'test');
            mapParams.put('isContactSame', false);
            mapParams.put('strCaseId', '');
            mapParams.put('zoneCode', '3242');
            mapParams.put('channelType', '소모품택배');
            mapParams.put('basisOrderNumber', prli[0].BASIS_Number__c);
            mapParams.put('standardOrderData', JSON.serialize(standardOrderDataList));
            mapParams.put('stdConsumableOrderId', prli[0].ParentId);
            mapParams.put('ContactVIP', 100);
            mapParams.put('soldOutOrderData', JSON.serialize(new List<EX_SuppliesController.ItemTable>()));
            mapParams.put('exchangeReturnData', new List<Map<String, Object>>{
                    exchangeReturnData
            });

            System.runAs(usr[0]) {
                try {
                    EX_SuppliesController.createExchangeRequest(mapParams);
                } catch (Exception e) {
                    System.debug(e);
                }

            }

            mapParams.put('standardOrderData', JSON.serialize(new List<EX_SuppliesController.ItemTable>()));
            mapParams.put('soldOutOrderData', JSON.serialize(standardOrderDataList));
            mapParams.put('channelType', 'LGE.COM');
            mapParams.put('ContactVIP', 10);
            mapParams.put('isContactSame', true);

            System.runAs(usr[0]) {
                EX_SuppliesController.doGetContactDept();
                try {
                    EX_SuppliesController.createExchangeRequest(mapParams);
                } catch (Exception e) {
                    System.debug(e);
                }
            }

            ProductRequestLineItem lineItem = [select id, Order_Number__c from ProductRequestLineItem Limit 1];
            List<EX_SuppliesController.ItemTable> table = new List<EX_SuppliesController.ItemTable>();
            EX_SuppliesController.ItemTable item = new EX_SuppliesController.ItemTable();
            item.Id = prli[0].Id;
            item.OrderNumber = prli[0].Order_Number__c;
            item.QTY = 1000;
            item.ASCPrice = 1000;
            item.Price = 1000;
            table.add(item);

            mapParams.put('orderNumber', prli[0].Order_Number__c);
            mapParams.put('chkEmployeeName', '임직원');
            mapParams.put('chkEmployeeNum', '임직원');
            mapParams.put('chkCompanyName', [select id from SM_CODE__c LIMIT 1].Id);
            mapParams.put('chkEmployeeRelationShip', '임직원');
            mapParams.put('stdOrderTotalSalesAmount', 3000);
            mapParams.put('stdOrderTotalDiscountAmount', 1000);
            mapParams.put('ContactVIP', 100);
            //mapParams.put('standardOrderDataList', JSON.serialize(table));
            mapParams.put('soldOutOrderDataList', JSON.serialize(table));
            try {
                EX_SuppliesController.setEmpData(mapParams);
            } catch (Exception e) {
                System.debug(e.getMessage());
            }


            mapParams.put('prId', paymentDetails[0].SR_PRE_PAYMENT_HEADER_ID__r.ATTR_RECORD_ID__c);
            EX_SuppliesController.doGetPaymentAmount(mapParams);

            paymentDetails[0].DEPOSIT_TYPE__c = 'B';
            update paymentDetails;
            EX_SuppliesController.doGetPaymentAmount(mapParams);

            paymentDetails[0].DEPOSIT_TYPE__c = 'D';
            update paymentDetails;
            EX_SuppliesController.doGetPaymentAmount(mapParams);

            paymentDetails[0].DEPOSIT_TYPE__c = 'E';
            paymentDetails[0].UPAD_DETAIL_TYPE__c = 'PG_VBANK';
            update paymentDetails;
            EX_SuppliesController.doGetPaymentAmount(mapParams);

            mapParams.put('ProductCode', 'test');
            mapParams.put('PartNameKor', 'test');
            mapParams.put('Price', '30000');
            mapParams.put('TEST', 'TESTSTETS');

            EX_SuppliesController.saveMessageObject(JSON.serialize(mapParams), 'TEST','testName');

        }

        EX_TestDataUtil.getSmCodeMaster(false).Name = 'UD009';
        insert EX_TestDataUtil.objSmCodeMaster;
        EX_TestDataUtil.getSmCode(true);

        EX_SuppliesController.getCompanyList();

        try {
            try {
                EX_SuppliesController.identityCheckInternal('test', 'test', EX_TestDataUtil.getSmCodeMaster(true).Id);
            } catch (Exception e) {
                System.debug(e);
            }

            EX_SuppliesController.generateAuth('0102345678');

            List<ContentDocument> cd = [SELECT Id FROM ContentDocument LIMIT 1];
            if (!cd.isEmpty()) {
                EX_SuppliesController.doRemoveFile(cd[0].Id);
            }


        } catch (Exception e) {
            System.debug(e);
        }


        Test.stopTest();
    }

    @IsTest
    static void test05() {
        insert new ContentVersion(Title = 'test pdf', PathOnClient = 'test.pdf', VersionData = Blob.valueOf('Test Content'), IsMajorVersion = true);
        EX_Message__c exMessage = new EX_Message__c(Label1__c = 'test');
        insert exMessage;
        insert new IF_Master__c(Method__c = 'POST', Endpoint__c = 'www.test.com', APIKeyName__c = 'test', APIKeyValue__c = 'test', IfId__c = 'infobip_kakao', isLogInsert__c = true);

        ContentDocument documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument LIMIT 1];
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        Test.startTest();
        EX_SuppliesController.doRemoveFile(documents.Id);
        EX_SuppliesController.ItemTable sup = new EX_SuppliesController.ItemTable('TTT TTT');
        try {
            // EX_SuppliesController.sendKaKao('SVC_LGE_MACN_014_02', exMessage.Id, '01012345678');
            EX_SuppliesController.sendKaKao('SVC_LGE_MACN_014_03', exMessage.Id, '01012345678'); //24 03 13 hyungho.chun 템플릿 금액 뒤에 '원' 추가
        } catch (Exception e) {
            System.debug(e);
        }
        try {
            EX_SuppliesController.identityCheck('test', 'test', EX_TestDataUtil.getSmCode(true).Id);
        } catch (Exception e) {
            System.debug(e);
        }
        Test.stopTest();
    }


    @IsTest
    static void test_TemporarySaveConsumableOrder1() {
        try {
            List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
            Map<String, Object> mapParams = mapParam();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
            System.runAs(usr[0]) {
                EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                EX_SuppliesController.doSaveConsumableOrder(mapParams);
                SR_PRE_PAYMENT_DETAIL__c paymentDetail = [select id, PAY_CUST_PHONE__c, CERTIFY_KEY__c, UPAD_DETAIL_TYPE__c, DEPOSIT_TYPE__c from SR_PRE_PAYMENT_DETAIL__c Limit 1];
                paymentDetail.PAY_CUST_PHONE__c = '000';
                paymentDetail.CERTIFY_KEY__c = '000';
                paymentDetail.UPAD_DETAIL_TYPE__c = 'PG_VBANK';
                update paymentDetail;
                EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                EX_SuppliesController.doSaveConsumableOrder(mapParams);
                paymentDetail.DEPOSIT_TYPE__c = 'A';
                update paymentDetail;
                //EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
            }
            System.debug('test_TemporarySaveConsumableOrder1 성공');
        } catch (Exception e) {
        System.debug('test_TemporarySaveConsumableOrder1 실패');
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void test_TemporarySaveConsumableOrder1_11() {
        try {
            List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
            Map<String, Object> mapParams = mapParam();
            mapParams.put('isContactSame', true);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
            System.runAs(usr[0]) {
                EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                EX_SuppliesController.doSaveConsumableOrder(mapParams);
                SR_PRE_PAYMENT_DETAIL__c paymentDetail = [select id, PAY_CUST_PHONE__c, CERTIFY_KEY__c, UPAD_DETAIL_TYPE__c, DEPOSIT_TYPE__c from SR_PRE_PAYMENT_DETAIL__c Limit 1];
                paymentDetail.PAY_CUST_PHONE__c = '012';
                paymentDetail.CERTIFY_KEY__c = '000';
                paymentDetail.UPAD_DETAIL_TYPE__c = 'PG_VBANK';
                paymentDetail.DEPOSIT_TYPE__c = 'D';
                update paymentDetail;
                EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                EX_SuppliesController.doSaveConsumableOrder(mapParams);
                
                //EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
            }
            System.debug('test_TemporarySaveConsumableOrder1_11 성공');
        } catch (Exception e) {
        System.debug('test_TemporarySaveConsumableOrder1_11 실패');
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }


    // @IsTest
    // static void test_TemporarySaveConsumableOrder2() {
    //     List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
    //     Map<String, Object> mapParams = mapParam();
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
    //     System.runAs(usr[0]) {
    //         SR_PRE_PAYMENT_DETAIL__c paymentDetail = [select id, PAY_CUST_PHONE__c, CERTIFY_KEY__c, UPAD_DETAIL_TYPE__c, DEPOSIT_TYPE__c from SR_PRE_PAYMENT_DETAIL__c Limit 1];
    //         List<ProductItem> pi_sold = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem WHERE Location.DEPT_CODE__c = 'PH8002' LIMIT 1];
            
    //         mapParams.put('poId', pi_sold[0].Product2Id);


    //         paymentDetail.DEPOSIT_TYPE__c = 'B';
    //         update paymentDetail;
    //         EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
    //         paymentDetail.DEPOSIT_TYPE__c = 'D';
    //         update paymentDetail;
    //         EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
    //     }
    //     Test.stopTest();
    // }

    @IsTest
    static void test_TemporarySaveConsumableOrder3() {
        List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
        ProductRequest pr = [SELECT Order_Number__c FROM ProductRequest  LIMIT 1];
        Map<String, Object> mapParams = mapParam();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        System.runAs(usr[0]) {
            try {

            SR_PRE_PAYMENT_DETAIL__c paymentDetail1 = [select id, ALLOC_MONTH__c,APPR_DT__c,APPR_DTTM__c,APPR_NUM__c,BIZ_LICENSE_YN__c,CERTIFY_CLASS__c,CERTIFY_KEY__c,CERTIFY_TYPE__c,DEPOSIT_AMT__c,DEPOSIT_TYPE__c,INPUT_TYPE__c,INVOICE_ISSUE_TYPE__c,PAY_CUST_NAME__c,PAY_CUST_PHONE__c,PAYMENT_AREA_NO__c,POINT_TRX_ID__c,VOLUNTARY_YN__c,MOID__c,BANK_CODE__c,SR_PRE_PAYMENT_HEADER_ID__c,TID_CASH__c,SR_SMARTRO_PAYMENT_REQUEST_ID__c,UPAD_DETAIL_TYPE__c,TID__c from SR_PRE_PAYMENT_DETAIL__c Limit 1];
            SR_PRE_PAYMENT_DETAIL__c paymentDetail2 = paymentDetail1.clone();
            insert paymentDetail2;
            EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
            EX_SuppliesController.doSaveConsumableOrder(mapParams);
            paymentDetail1.DEPOSIT_TYPE__c = 'A';
            update paymentDetail1;
            EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
            EX_SuppliesController.doSaveConsumableOrder(mapParams);
            ProductRequest proReq = [SELECT Id,SALE_Amount__c,Discount_Amount__c FROM ProductRequest LIMIT 1];
            proReq.SALE_Amount__c = 1000;
            proReq.Discount_Amount__c = 1000;
            update proReq;
            paymentDetail1.DEPOSIT_TYPE__c = 'B';
            update paymentDetail1;
            EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
            EX_SuppliesController.doSaveConsumableOrder(mapParams);
            EX_SuppliesController.getAddressByOrderNumber(String.valueOf(pr.Order_Number__c));
            System.debug('test_TemporarySaveConsumableOrder3 성공');
            } catch (Exception e) {
            System.debug('test_TemporarySaveConsumableOrder3 실패');
                System.debug(e.getMessage());
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void test_identityCheck() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        try {
            EX_SuppliesController.identityCheck('employeeName', 'employeeNum', [select id from SM_CODE__c LIMIT 1].Id);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void test_doGetProductRequestCustInfo() {
        ProductRequest proReq = [SELECT Id,SALE_Amount__c,Discount_Amount__c FROM ProductRequest LIMIT 1];
        ProductRequest pr = [SELECT Order_Number__c FROM ProductRequest  LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        EX_SuppliesController.doGetProductRequestCustInfo(proReq.Id);
                EX_SuppliesController.getAddressByOrderNumber(String.valueOf(pr.Order_Number__c));
        Test.stopTest();
    }

    

    
    

    private static Map<String, Object> mapParam() {
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        List<ProductRequest> pr = [SELECT Id, Order_Number__c FROM ProductRequest LIMIT 1];        
        List<ProductItem> pi = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem WHERE QuantityOnHand != 0 LIMIT 1];
        List<ProductItem> pi_sold = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem WHERE Location.DEPT_CODE__c = 'PH8002' LIMIT 1];

        List<EX_SuppliesController.ItemTable> standardOrderDataList = new List<EX_SuppliesController.ItemTable>();
        List<EX_SuppliesController.ItemTable> soldOutOrderDataList = new List<EX_SuppliesController.ItemTable>();
        EX_SuppliesController.ItemTable it_sold = new EX_SuppliesController.ItemTable();
        
        EX_SuppliesController.ItemTable it = new EX_SuppliesController.ItemTable();
        it.ProductCode = pi[0].Product2.ProductCode;
        it.sProductId = pi[0].Product2Id;
        it.sLocationId = pi[0].LocationId;
        it.QTY = 1;
        it.Price = 30000;
        it.PromotionPrice = 25000;
        it.discountType = '임직원';
        it.ParentId = pr[0].Id;
        it.DIVCODE = 'PH8002';
        standardOrderDataList.add(it);

    

        EX_SuppliesController.ItemTable it2 = new EX_SuppliesController.ItemTable();
        it2.ProductCode = pi[0].Product2.ProductCode;
        it2.sProductId = pi[0].Product2Id;
        it2.sLocationId = pi[0].LocationId;
        it2.QTY = 1;
        it2.Price = 30000;
        it2.PromotionPrice = 25000;
        it2.discountType = 'VIP';
        it2.ParentId = pr[0].Id;
        it2.DIVCODE = 'PH8002';
        standardOrderDataList.add(it2);

        EX_SuppliesController.ItemTable it3 = new EX_SuppliesController.ItemTable();
        it3.ProductCode = pi[0].Product2.ProductCode;
        it3.sProductId = pi[0].Product2Id;
        it3.sLocationId = pi[0].LocationId;
        it3.QTY = 1;
        it3.Price = 30000;
        it3.PromotionPrice = 25000;
        it3.DiscountAmount = 100;
        it3.discountType = '프로모션';
        it3.ParentId = pr[0].Id;
        it3.DIVCODE = 'PH8002';
        standardOrderDataList.add(it3);

        it3.ProductCode = pi[0].Product2.ProductCode;
        it3.sProductId = pi[0].Product2Id;
        it3.sLocationId = pi[0].LocationId;
        it3.QTY = 1;
        it3.Price = 3000;
        it3.PromotionPrice = 250000;
        it3.DiscountAmount = 100;
        it3.discountType = '프로모션';
        standardOrderDataList.add(it3);
        soldOutOrderDataList.add(it3);

        it3.ProductCode = pi[0].Product2.ProductCode;
        it3.sProductId = pi[0].Product2Id;
        it3.sLocationId = pi[0].LocationId;
        it3.QTY = 1;
        it3.Price = 3000;
        it3.DiscountAmount = 100;
        it3.PromotionPrice = 0;
        it3.discountType = '프로모션';
        it3.ParentId = pr[0].Id;
        standardOrderDataList.add(it3);
        it3.QTY = 1;
        soldOutOrderDataList.add(it3);

        it_sold.ProductCode = pi_sold[0].Product2.ProductCode;
        it_sold.sProductId = pi_sold[0].Product2Id;
        it_sold.sLocationId = pi_sold[0].LocationId;
        it_sold.QTY = 1;
        it_sold.Price = 30000;
        it_sold.PromotionPrice = 25000;
        it_sold.ParentId = pr[0].Id;
        it_sold.DIVCODE = 'PH8002';
        soldOutOrderDataList.add(it_sold);


        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('contactId', contacts[0].Id);
        mapParams.put('consigneeName', 'test');
        mapParams.put('IbCallNo', '01012345678');
        mapParams.put('newAddress', 'test');
        mapParams.put('detailAddress', 'test');
        mapParams.put('requestedTerm', 'test');
        mapParams.put('remark', 'test');
        mapParams.put('isContactSame', false);
        mapParams.put('strCaseId', '');
        mapParams.put('zoneCode', '3242');
        mapParams.put('discountType', '임직원');
        mapParams.put('managerNote', 'test');
        mapParams.put('stdConsumableOrderId', pr[0].Id);
        mapParams.put('soldOutConsumableOrderId', pr[0].Id);
        
        mapParams.put('poId', pi[0].Product2Id);
        mapParams.put('stdOrderTotalPaymentAmount', 30000);
        mapParams.put('stdOrderTotalSalesAmount', 30000);
        mapParams.put('stdOrderTotalDiscountAmount', 500);
        mapParams.put('standardOrderData', JSON.serialize(standardOrderDataList));
        mapParams.put('soldOutOrderData', JSON.serialize(soldOutOrderDataList));
        mapParams.put('standardOrderDataList', JSON.serialize(standardOrderDataList));
        mapParams.put('soldOutOrderDataList', JSON.serialize(soldOutOrderDataList));
        mapParams.put('isTemporary', true);
        mapParams.put('isManagement', false);
        mapParams.put('isExchangeOrder', false);
        mapParams.put('ContactVIP', 10);
        mapParams.put('discountType', '임직원');
        
        return mapParams;
    }

//  private static Map<String, Object> mapParam2() {
//     List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
//     List<ProductRequest> pr = [SELECT Id, Order_Number__c FROM ProductRequest LIMIT 1]; 
    
//     SR_PRE_PAYMENT_DETAIL__c prePaymentDetail;
//     prePaymentDetail = new SR_PRE_PAYMENT_DETAIL__c();
//     prePaymentDetail.ALLOC_MONTH__c = '0';
//     prePaymentDetail.APPR_DT__c = tDate;
//     prePaymentDetail.APPR_DTTM__c = tDateTime;
//     prePaymentDetail.APPR_NUM__c = APPR_NUM;
//     prePaymentDetail.BIZ_LICENSE_YN__c = false;
//     prePaymentDetail.CERTIFY_CLASS__c = 'B';
//     prePaymentDetail.CERTIFY_KEY__c = '010-1234-5678';
//     prePaymentDetail.CERTIFY_TYPE__c = '1';
//     prePaymentDetail.DEPOSIT_AMT__c = 500;
//     prePaymentDetail.DEPOSIT_TYPE__c = 'A';
//     prePaymentDetail.INPUT_TYPE__c = 'N';
//     prePaymentDetail.INVOICE_ISSUE_TYPE__c = 'B';
//     prePaymentDetail.PAY_CUST_NAME__c = 'TEST_NAME';
//     prePaymentDetail.PAY_CUST_PHONE__c = '010-3144-7479';
//     prePaymentDetail.PAYMENT_AREA_NO__c = 1;
//     prePaymentDetail.POINT_TRX_ID__c = '1000006623527';
//     prePaymentDetail.VOLUNTARY_YN__c = false;
//     prePaymentDetail.MOID__c = MID;
//     prePaymentDetail.BANK_CODE__c = 'KB000';
//     prePaymentDetail.SR_PRE_PAYMENT_HEADER_ID__c = getPrePaymentHeader(true).Id;
//     prePaymentDetail.TID_CASH__c = '325324242';
//     prePaymentDetail.SR_SMARTRO_PAYMENT_REQUEST_ID__c = getSmartroPaymentRequest(true).Id;
//     prePaymentDetail.TID__c = getSmartroPaymentRequest(true).TID__c;
//     insert prePaymentDetail;

//     List<ProductItem> pi = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem WHERE QuantityOnHand != 0 LIMIT 1];
//     List<ProductItem> pi_sold = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem WHERE Location.DEPT_CODE__c = 'PH8002' LIMIT 1];

//     List<EX_SuppliesController.ItemTable> standardOrderDataList = new List<EX_SuppliesController.ItemTable>();
//     List<EX_SuppliesController.ItemTable> soldOutOrderDataList = new List<EX_SuppliesController.ItemTable>();
//     EX_SuppliesController.ItemTable it_sold = new EX_SuppliesController.ItemTable();
    
//     EX_SuppliesController.ItemTable it = new EX_SuppliesController.ItemTable();
//     it.ProductCode = pi[0].Product2.ProductCode;
//     it.sProductId = pi[0].Product2Id;
//     it.sLocationId = pi[0].LocationId;
//     it.QTY = 1;
//     it.Price = 30000;
//     it.PromotionPrice = 25000;
//     it.discountType = '임직원';
//     it.ParentId = pr[0].Id;
//     standardOrderDataList.add(it);



//     EX_SuppliesController.ItemTable it2 = new EX_SuppliesController.ItemTable();
//     it2.ProductCode = pi[0].Product2.ProductCode;
//     it2.sProductId = pi[0].Product2Id;
//     it2.sLocationId = pi[0].LocationId;
//     it2.QTY = 1;
//     it2.Price = 30000;
//     it2.PromotionPrice = 25000;
//     it2.discountType = 'VIP';
//     it2.ParentId = pr[0].Id;
//     standardOrderDataList.add(it2);

//     EX_SuppliesController.ItemTable it3 = new EX_SuppliesController.ItemTable();
//     it3.ProductCode = pi[0].Product2.ProductCode;
//     it3.sProductId = pi[0].Product2Id;
//     it3.sLocationId = pi[0].LocationId;
//     it3.QTY = 1;
//     it3.Price = 30000;
//     it3.PromotionPrice = 25000;
//     it3.DiscountAmount = 100;
//     it3.discountType = '프로모션';
//     it3.ParentId = pr[0].Id;
//     standardOrderDataList.add(it3);

//     it3.ProductCode = pi[0].Product2.ProductCode;
//     it3.sProductId = pi[0].Product2Id;
//     it3.sLocationId = pi[0].LocationId;
//     it3.QTY = 1;
//     it3.Price = 3000;
//     it3.PromotionPrice = 250000;
//     it3.DiscountAmount = 100;
//     it3.discountType = '프로모션';
//     standardOrderDataList.add(it3);
//     soldOutOrderDataList.add(it3);

//     it3.ProductCode = pi[0].Product2.ProductCode;
//     it3.sProductId = pi[0].Product2Id;
//     it3.sLocationId = pi[0].LocationId;
//     it3.QTY = 1;
//     it3.Price = 3000;
//     it3.DiscountAmount = 100;
//     it3.PromotionPrice = 0;
//     it3.discountType = '프로모션';
//     it3.ParentId = pr[0].Id;
//     standardOrderDataList.add(it3);
//     it3.QTY = 1;
//     soldOutOrderDataList.add(it3);

//     it_sold.ProductCode = pi_sold[0].Product2.ProductCode;
//     it_sold.sProductId = pi_sold[0].Product2Id;
//     it_sold.sLocationId = pi_sold[0].LocationId;
//     it_sold.QTY = 1;
//     it_sold.Price = 30000;
//     it_sold.PromotionPrice = 25000;
//     it_sold.ParentId = pr[0].Id;
//     soldOutOrderDataList.add(it_sold);


//     Map<String, Object> mapParams = new Map<String, Object>();
//     mapParams.put('contactId', contacts[0].Id);
//     mapParams.put('consigneeName', 'test');
//     mapParams.put('IbCallNo', '01012345678');
//     mapParams.put('newAddress', 'test');
//     mapParams.put('detailAddress', 'test');
//     mapParams.put('requestedTerm', 'test');
//     mapParams.put('remark', 'test');
//     mapParams.put('isContactSame', false);
//     mapParams.put('strCaseId', '');
//     mapParams.put('zoneCode', '3242');
//     mapParams.put('discountType', '임직원');
//     mapParams.put('managerNote', 'test');
//     mapParams.put('stdConsumableOrderId', pr[0].Id);
//     mapParams.put('soldOutConsumableOrderId', pr[0].Id);
    
//     mapParams.put('poId', pi[0].Product2Id);
//     mapParams.put('stdOrderTotalPaymentAmount', 30000);
//     mapParams.put('stdOrderTotalSalesAmount', 30000);
//     mapParams.put('stdOrderTotalDiscountAmount', 500);
//     mapParams.put('standardOrderData', JSON.serialize(standardOrderDataList));
//     mapParams.put('soldOutOrderData', JSON.serialize(soldOutOrderDataList));
//     mapParams.put('standardOrderDataList', JSON.serialize(standardOrderDataList));
//     mapParams.put('soldOutOrderDataList', JSON.serialize(soldOutOrderDataList));
//     mapParams.put('isTemporary', true);
//     mapParams.put('isManagement', false);
//     mapParams.put('isExchangeOrder', false);
//     mapParams.put('ContactVIP', 10);
//     mapParams.put('discountType', '임직원');
    
//     return mapParams;
// }     

    @IsTest
    static void test_updateSoldOutOrderDataList() {
        List<ProductRequestLineItem> prList = [SELECT Id, Order_Number__c FROM ProductRequestLineItem LIMIT 1];

        List<ProductRequestLineItem> prList1 = [SELECT Id, Order_Number__c FROM ProductRequestLineItem WHERE CONSUMER_Price__c = 1000 LIMIT 1];
        List<String> prLiIdSet1 = new List<String>();
        for (ProductRequestLineItem pr : prList1) {
            prLiIdSet1.add(pr.Id);
        }

        List<String> prLiIdSet = new List<String>();
        Map<String,Object> temp = new Map<String,Object>();
        Map<String,Object> temp2 = new Map<String,Object>();
        Map<String,Object> temp3 = new Map<String,Object>();
        
        for (ProductRequestLineItem pr : prList) {
            map<String,Object> innerTemp = new Map<string,Object>();
            innerTemp.put('Price',2000);
            innerTemp.put('QTY',2);
            innerTemp.put('discountType','임직원');
            innerTemp.put('DiscountAmount',500);

            prLiIdSet.add(pr.Id);
            temp.put(pr.Id,innerTemp);

            map<String,Object> innerTemp2 = new Map<string,Object>();
            innerTemp2.put('Price',2000);
            innerTemp2.put('QTY',2);
            innerTemp2.put('discountType','VIP');
            innerTemp2.put('DiscountAmount',500);

            prLiIdSet.add(pr.Id);
            temp2.put(pr.Id,innerTemp2);

            map<String,Object> innerTemp3 = new Map<string,Object>();
            innerTemp3.put('Price',2000);
            innerTemp3.put('QTY',2);
            innerTemp3.put('discountType','프로모션');
            innerTemp3.put('DiscountAmount',500);

            prLiIdSet.add(pr.Id);
            temp3.put(pr.Id,innerTemp3);
        }

        String inputValue = JSON.serialize(temp);
        String inputValue2 = JSON.serialize(temp2);
        String inputValue3 = JSON.serialize(temp3);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        
        // EX_SuppliesController.updateSoldOutOrderDataList(prLiIdSet);
        EX_SuppliesController.updateSoldOutOrderDataList(inputValue);

        EX_SuppliesController.updateSoldOutOrderDataList(inputValue2);
        EX_SuppliesController.updateSoldOutOrderDataList(inputValue3);

        List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT ID, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c FROM SR_PRE_PAYMENT_DETAIL__c WHERE SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = :prList[0].Order_Number__c order by PAYMENT_AREA_NO__c];
        paymentDetails[0].DEPOSIT_TYPE__c = 'A';
        update paymentDetails;

        // EX_SuppliesController.updateSoldOutOrderDataList(prLiIdSet);
        EX_SuppliesController.updateSoldOutOrderDataList(inputValue);
        
        paymentDetails[0].DEPOSIT_TYPE__c = 'B';
        update paymentDetails;

        // EX_SuppliesController.updateSoldOutOrderDataList(prLiIdSet);
        EX_SuppliesController.updateSoldOutOrderDataList(inputValue);
        paymentDetails[0].DEPOSIT_TYPE__c = 'D';
        update paymentDetails;

        // EX_SuppliesController.updateSoldOutOrderDataList(prLiIdSet);
        EX_SuppliesController.updateSoldOutOrderDataList(inputValue);
        paymentDetails[0].DEPOSIT_TYPE__c = 'E';
        paymentDetails[0].UPAD_DETAIL_TYPE__c = 'PG_VBANK';
        update paymentDetails;

        // EX_SuppliesController.updateSoldOutOrderDataList(prLiIdSet);
        EX_SuppliesController.updateSoldOutOrderDataList(inputValue);
        List<SR_PRE_PAYMENT_HEADER__c> headerList = [SELECT ID, BASIS_NO__c FROM SR_PRE_PAYMENT_HEADER__c];

        SR_PRE_PAYMENT_DETAIL__c paymentDetail = new SR_PRE_PAYMENT_DETAIL__c();
        paymentDetail.DEPOSIT_TYPE__c = 'E';
        paymentDetail.SR_PRE_PAYMENT_HEADER_ID__c = headerList[0].Id;
        paymentDetail.DEPOSIT_AMT__c = 1000;
        paymentDetail.PAYMENT_AREA_NO__c = 2;
        paymentDetail.MOID__c = '1234';
        insert paymentDetail;
        // EX_SuppliesController.updateSoldOutOrderDataList(prLiIdSet);
        EX_SuppliesController.updateSoldOutOrderDataList(inputValue);

        SR_SMARTRO_PAYMENT_REQUEST__c paymentRequest = new SR_SMARTRO_PAYMENT_REQUEST__c();
        paymentRequest.BANK_CODE__c = 'VBANK';
        paymentRequest.MOID__c = '1234';
        paymentRequest.CANCEL_FLAG__c = false;
        paymentRequest.PAYMENT_YN__c = false;
        paymentRequest.SMARTRO_PAYMENT_REQUEST_PK__c = 'unique1234';
        insert paymentRequest;

        ProductRequest prObj = [SELECT ID, Order_Number__c FROM ProductRequest LIMIT 1][0];
        prObj.PAYMENT_TYPE__c = 'VBANK';
        update prObj;
        EX_SuppliesController.doSetPaymentData(new Set<String>{prObj.Order_Number__c}, JSON.serialize(prObj));

        prObj.PAYMENT_TYPE__c = 'CASH';
        update prObj;
        EX_SuppliesController.doSetPaymentData(new Set<String>{prObj.Order_Number__c}, JSON.serialize(prObj));

        // EX_SuppliesController.updateSoldOutOrderDataList(prLiIdSet1);

        ProductRequest pr = [SELECT Order_Number__c FROM ProductRequest  LIMIT 1];
        EX_SuppliesController.getAddressByOrderNumber(String.valueOf(pr.Order_Number__c));

        Test.stopTest();
    }
    @IsTest
    static void test_updateSoldOutOrderDataList2() {
        List<ProductRequestLineItem> prList = [SELECT Id, Order_Number__c FROM ProductRequestLineItem LIMIT 1];

        List<ProductRequestLineItem> prList1 = [SELECT Id, Order_Number__c FROM ProductRequestLineItem WHERE CONSUMER_Price__c = 1000 LIMIT 1];
        List<String> prLiIdSet1 = new List<String>();
        for (ProductRequestLineItem pr : prList1) {
            prLiIdSet1.add(pr.Id);
        }

        List<String> prLiIdSet = new List<String>();
        Map<String,Object> temp = new Map<String,Object>();
        Map<String,Object> temp2 = new Map<String,Object>();
        Map<String,Object> temp3 = new Map<String,Object>();
        
        for (ProductRequestLineItem pr : prList) {
            map<String,Object> innerTemp = new Map<string,Object>();
            innerTemp.put('Price',2000);
            innerTemp.put('QTY',2);
            innerTemp.put('discountType','임직원');
            innerTemp.put('DiscountAmount',500);

            prLiIdSet.add(pr.Id);
            temp.put(pr.Id,innerTemp);

            map<String,Object> innerTemp2 = new Map<string,Object>();
            innerTemp2.put('Price',2000);
            innerTemp2.put('QTY',2);
            innerTemp2.put('discountType','VIP');
            innerTemp2.put('DiscountAmount',500);

            prLiIdSet.add(pr.Id);
            temp2.put(pr.Id,innerTemp2);

            map<String,Object> innerTemp3 = new Map<string,Object>();
            innerTemp3.put('Price',2000);
            innerTemp3.put('QTY',2);
            innerTemp3.put('discountType','프로모션');
            innerTemp3.put('DiscountAmount',500);

            prLiIdSet.add(pr.Id);
            temp3.put(pr.Id,innerTemp3);
        }

        String inputValue = JSON.serialize(temp);
        String inputValue2 = JSON.serialize(temp2);
        String inputValue3 = JSON.serialize(temp3);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        
        // EX_SuppliesController.updateSoldOutOrderDataList(prLiIdSet);
        EX_SuppliesController.updateSoldOutOrderDataList(inputValue);

        EX_SuppliesController.updateSoldOutOrderDataList(inputValue2);
        EX_SuppliesController.updateSoldOutOrderDataList(inputValue3);

        List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT ID, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c FROM SR_PRE_PAYMENT_DETAIL__c WHERE SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = :prList[0].Order_Number__c order by PAYMENT_AREA_NO__c];
        paymentDetails[0].DEPOSIT_TYPE__c = 'A';
        update paymentDetails;

        // EX_SuppliesController.updateSoldOutOrderDataList(prLiIdSet);
        EX_SuppliesController.updateSoldOutOrderDataList(inputValue);
        
        paymentDetails[0].DEPOSIT_TYPE__c = 'B';
        update paymentDetails;

        // EX_SuppliesController.updateSoldOutOrderDataList(prLiIdSet);
        EX_SuppliesController.updateSoldOutOrderDataList(inputValue);
        paymentDetails[0].DEPOSIT_TYPE__c = 'D';
        update paymentDetails;

        // EX_SuppliesController.updateSoldOutOrderDataList(prLiIdSet);
        EX_SuppliesController.updateSoldOutOrderDataList(inputValue);
        paymentDetails[0].DEPOSIT_TYPE__c = 'E';
        paymentDetails[0].UPAD_DETAIL_TYPE__c = 'PG_VBANK';
        update paymentDetails;

        // EX_SuppliesController.updateSoldOutOrderDataList(prLiIdSet);
        EX_SuppliesController.updateSoldOutOrderDataList(inputValue);
        SR_PRE_PAYMENT_HEADER__c spph = EX_TestDataUtil.getPrePaymentHeader(false).clone();
        insert spph;
        List<SR_PRE_PAYMENT_HEADER__c> headerList = [SELECT ID, BASIS_NO__c FROM SR_PRE_PAYMENT_HEADER__c];

        SR_PRE_PAYMENT_DETAIL__c paymentDetail = new SR_PRE_PAYMENT_DETAIL__c();
        paymentDetail.DEPOSIT_TYPE__c = 'E';
        paymentDetail.SR_PRE_PAYMENT_HEADER_ID__c = headerList[0].Id;
        paymentDetail.DEPOSIT_AMT__c = 1000;
        paymentDetail.PAYMENT_AREA_NO__c = 2;
        paymentDetail.MOID__c = '1234';
        insert paymentDetail;

        SR_PRE_PAYMENT_DETAIL__c paymentDetail2 = new SR_PRE_PAYMENT_DETAIL__c();
        paymentDetail2.DEPOSIT_TYPE__c = 'D';
        paymentDetail2.SR_PRE_PAYMENT_HEADER_ID__c = spph.Id;
        paymentDetail2.DEPOSIT_AMT__c = 1000;
        paymentDetail2.PAYMENT_AREA_NO__c = 2;
        paymentDetail2.MOID__c = '1234';
        insert paymentDetail2;
        // EX_SuppliesController.updateSoldOutOrderDataList(prLiIdSet);
        EX_SuppliesController.updateSoldOutOrderDataList(inputValue);

        SR_SMARTRO_PAYMENT_REQUEST__c paymentRequest = new SR_SMARTRO_PAYMENT_REQUEST__c();
        paymentRequest.BANK_CODE__c = 'VBANK';
        paymentRequest.MOID__c = '1234';
        paymentRequest.CANCEL_FLAG__c = false;
        paymentRequest.PAYMENT_YN__c = false;
        paymentRequest.SMARTRO_PAYMENT_REQUEST_PK__c = 'unique1234';
        insert paymentRequest;

        ProductRequest prObj = [SELECT ID, Order_Number__c FROM ProductRequest LIMIT 1][0];
        prObj.PAYMENT_TYPE__c = 'VBANK';
        update prObj;
        EX_SuppliesController.doSetPaymentData(new Set<String>{prObj.Order_Number__c}, JSON.serialize(prObj));

        prObj.PAYMENT_TYPE__c = 'CASH';
        update prObj;
        EX_SuppliesController.doSetPaymentData(new Set<String>{prObj.Order_Number__c}, JSON.serialize(prObj));

        // EX_SuppliesController.updateSoldOutOrderDataList(prLiIdSet1);

        ProductRequest pr = [SELECT Order_Number__c FROM ProductRequest  LIMIT 1];
        EX_SuppliesController.getAddressByOrderNumber(String.valueOf(pr.Order_Number__c));

        Test.stopTest();
    }


    
    // StatusCode=200 Mock
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = newResponse(200, req.getEndpoint());
            return res;
        }
    }

    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode, String endpoint) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        if (endpoint.startsWith('https://eapi.singlex.com/lg/cic/ws/empinfo/search')) {
            res.setBody('{  }');
        } else if (endpoint.equalsIgnoreCase('https://eapi.singlex.com/scs/msg/api/v1/talk')) {
            res.setBody('{ "resultCount" : "1", "result" : "success", "message":"Success"}');
        } else if (endpoint.contains('www.test.com')) {
            res.setBody('{ "resultCount" : "1", "result" : "success", "message":"Success"}');
        } else if (endpoint.contains('/tooling/query/?q=Select+Metadata,Id+FROM+GlobalValueSet+WHERE+DeveloperName=%27')) {
            res.setBody('{ "records" : [ { "Metadata" : { "customValue" : [ { "isActive" : true, "label" : "005", "valueName" : "005"} ] } } ] }');
        } else {
            res.setBody('{ "Header" : {"rstType" : "test", "rstMsg" : "test" } , "Body" : { "data" : [ { "partNo" : "test", "divCode" : "test","PartNameKor" : "test","ObsSalesYN" : "Y", "ObsImageURL" : "testt","ObsSalesURL" : "test", "ObsMemberPrice" : 3000 } ] } } ');
        }

        return res;
    }




    @IsTest
    static void test_TemporarySaveConsumableOrder4() {
        try {
            List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];

            ProductRequest pr = [SELECT Order_Number__c FROM ProductRequest  LIMIT 1];


            Map<String, Object> mapParams = mapParam();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
            System.runAs(usr[0]) {
                // mapParams.put('isTemporary', true);
                mapParams.put('discountType', 'VIP');
            
                mapParams.put('isTemporary', false);
                mapParams.put('isExchangeOrder', true);
                EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                EX_SuppliesController.doSaveConsumableOrder(mapParams);
                SR_PRE_PAYMENT_DETAIL__c paymentDetail = [select id, PAY_CUST_PHONE__c, CERTIFY_KEY__c, UPAD_DETAIL_TYPE__c, DEPOSIT_TYPE__c from SR_PRE_PAYMENT_DETAIL__c Limit 1];
                paymentDetail.SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = 'O3443244';
                paymentDetail.PAY_CUST_PHONE__c = '001';
                paymentDetail.CERTIFY_KEY__c = '000';
                paymentDetail.UPAD_DETAIL_TYPE__c = 'PG_VBANK';
                paymentDetail.DEPOSIT_TYPE__c = 'A';

                update paymentDetail;
                
                EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);    
                EX_SuppliesController.doSaveConsumableOrder(mapParams);

                EX_SuppliesController.doSendPDF(mapParams);

                EX_SuppliesController.getHistoryData(mapParams);

                
                EX_SuppliesController.getAddressByOrderNumber(String.valueOf(pr.Order_Number__c));
            }
            System.debug('test_TemporarySaveConsumableOrder4 성공');
        } catch (Exception e) {
        System.debug('test_TemporarySaveConsumableOrder4 실패');
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void test_TemporarySaveConsumableOrder4_11() {
        try {
            List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];

            ProductRequest pr = [SELECT Order_Number__c FROM ProductRequest  LIMIT 1];
            Map<String, Object> mapParams = mapParam();
        
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
            System.runAs(usr[0]) {
                // mapParams.put('isTemporary', true);
                mapParams.put('discountType', 'VIP');
                mapParams.put('isContactSame', true);
                mapParams.put('isTemporary', false);
                mapParams.put('isExchangeOrder', true);
                EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                EX_SuppliesController.doSaveConsumableOrder(mapParams);
                SR_PRE_PAYMENT_DETAIL__c paymentDetail = [select id, PAY_CUST_PHONE__c, CERTIFY_KEY__c, UPAD_DETAIL_TYPE__c, DEPOSIT_TYPE__c from SR_PRE_PAYMENT_DETAIL__c Limit 1];
                paymentDetail.SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = 'O3443244';
                paymentDetail.PAY_CUST_PHONE__c = '001';
                paymentDetail.CERTIFY_KEY__c = '000';
                paymentDetail.UPAD_DETAIL_TYPE__c = 'PG_VBANK';
                paymentDetail.DEPOSIT_TYPE__c = 'D';

                update paymentDetail;
                
                // EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);

                // EX_SuppliesController.doSendPDF(mapParams);

                // EX_SuppliesController.getHistoryData(mapParams);

                
                // EX_SuppliesController.getAddressByOrderNumber(String.valueOf(pr.Order_Number__c));
            }
            System.debug('test_TemporarySaveConsumableOrder4_11 성공');
        } catch (Exception e) {
        System.debug('test_TemporarySaveConsumableOrder4_11 실패');
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
    @IsTest
    static void test_TemporarySaveConsumableOrder5() {
        try {
            List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
            Map<String, Object> mapParams = mapParam();
            
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
            System.runAs(usr[0]) {
                // mapParams.put('isManagement', false);
                mapParams.put('isManagement', true);
                mapParams.put('discountType', '프로모션');

                EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                EX_SuppliesController.doSaveConsumableOrder(mapParams);
                SR_PRE_PAYMENT_DETAIL__c paymentDetail = [select id, PAY_CUST_PHONE__c, CERTIFY_KEY__c, UPAD_DETAIL_TYPE__c, DEPOSIT_TYPE__c from SR_PRE_PAYMENT_DETAIL__c Limit 1];
                paymentDetail.SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = 'O3443244';
                paymentDetail.PAY_CUST_PHONE__c = '000';
                paymentDetail.CERTIFY_KEY__c = '000';
                paymentDetail.UPAD_DETAIL_TYPE__c = 'PG_URL';
                paymentDetail.DEPOSIT_TYPE__c = 'O';
                update paymentDetail;
                EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                EX_SuppliesController.doSaveConsumableOrder(mapParams);
            }
            System.debug('test_TemporarySaveConsumableOrder5 성공');
        } catch (Exception e) {
        System.debug('test_TemporarySaveConsumableOrder5 실패');
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
    @IsTest
    static void test_TemporarySaveConsumableOrder6() {
        try {
            List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
            List<ProductItem> pi_sold = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem WHERE Location.DEPT_CODE__c = 'PH8002' LIMIT 1];
            Map<String, Object> mapParams = mapParam();
            mapParams.put('poId', pi_sold[0].Product2Id);
            mapParams.put('isExchangeOrder', true);
                            
        
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
            System.runAs(usr[0]) {
                
                // mapParams.put('isTemporary' , false);
                EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                EX_SuppliesController.doSaveConsumableOrder(mapParams);
                SR_PRE_PAYMENT_DETAIL__c paymentDetail = [select id, PAY_CUST_PHONE__c, CERTIFY_KEY__c, UPAD_DETAIL_TYPE__c, DEPOSIT_TYPE__c from SR_PRE_PAYMENT_DETAIL__c Limit 1];
                paymentDetail.SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = 'O3443244';
                paymentDetail.PAY_CUST_PHONE__c = '000';
                paymentDetail.CERTIFY_KEY__c = '000';
                paymentDetail.UPAD_DETAIL_TYPE__c = 'PG_VBANK';
                paymentDetail.DEPOSIT_TYPE__c = 'D';
                update paymentDetail;
                EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                EX_SuppliesController.doSaveConsumableOrder(mapParams);
            }
            System.debug('test_TemporarySaveConsumableOrder6 성공');
        } catch (Exception e) {
        System.debug('test_TemporarySaveConsumableOrder6 실패');
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
    @IsTest
    static void test_TemporarySaveConsumableOrder7() {
        try {
            List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
            Map<String, Object> mapParams = mapParam();
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
            System.runAs(usr[0]) {
                mapParams.put('isExchangeOrder' , false);
                mapParams.put('isContactSame', true);
                EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                EX_SuppliesController.doSaveConsumableOrder(mapParams);
            
                SR_PRE_PAYMENT_DETAIL__c paymentDetail = [select id, PAY_CUST_PHONE__c, CERTIFY_KEY__c, UPAD_DETAIL_TYPE__c, DEPOSIT_TYPE__c from SR_PRE_PAYMENT_DETAIL__c Limit 1];
                paymentDetail.SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = 'O3443244';
                paymentDetail.PAY_CUST_PHONE__c = '000';
                paymentDetail.CERTIFY_KEY__c = '000';
                paymentDetail.UPAD_DETAIL_TYPE__c = 'PG_VBANK';
                paymentDetail.DEPOSIT_TYPE__c = 'B';
                update paymentDetail;
                EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
                EX_SuppliesController.doSaveConsumableOrder(mapParams);

                EX_SuppliesController.doSendPDF(mapParams);

                EX_SuppliesController.getHistoryData(mapParams);
            
            }
            System.debug('test_TemporarySaveConsumableOrder7 성공');
        } catch (Exception e) {
        System.debug('test_TemporarySaveConsumableOrder7 실패');
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void checkEmpData1() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
        List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT Id, TID__c, MOID__c, SR_PRE_PAYMENT_HEADER_ID__r.ATTR_RECORD_ID__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
        List<ProductItem> pi = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        List<ProductRequestLineItem> prli = [SELECT Id, Order_Number__c, BASIS_Number__c, ParentId FROM ProductRequestLineItem LIMIT 1];

        if (!usr.isEmpty() && !paymentDetails.isEmpty() && !pi.isEmpty() && !contacts.isEmpty() && !prli.isEmpty()) {
            SI_SMARTRO_TOTAL_PAYMENT__c payment = new SI_SMARTRO_TOTAL_PAYMENT__c();
            payment.TID__c = paymentDetails[0].TID__c;
            payment.OID__c = paymentDetails[0].MOID__c;
            payment.PAYMETHOD__c = 'CARD';
            payment.RESULT_CODE__c = '4100';
            payment.AMT__c = 30000;
            payment.AUTH_CODE__c = '32dfas2432';
            payment.AUTH_DATE__c = '20230502123030';
            insert payment;

            List<EX_SuppliesController.ItemTable> standardOrderDataList = new List<EX_SuppliesController.ItemTable>();
            EX_SuppliesController.ItemTable it = new EX_SuppliesController.ItemTable();
            it.ProductCode = pi[0].Product2.ProductCode;
            it.sProductId = pi[0].Product2Id;
            it.sLocationId = pi[0].LocationId;
            it.QTY = 1;
            it.Price = 30000;
            it.PromotionPrice = 25000;
            it.ParentId = prli[0].ParentId;
            standardOrderDataList.add(it);

            Map<String, Object> mapParams = new Map<String, Object>();
            Map<String, Object> exchangeReturnData = new Map<String, Object>();
            exchangeReturnData.put('Id', prli[0].Id);
            exchangeReturnData.put('RequestedReturnQuantity', 1);
            exchangeReturnData.put('DIVCODE', pi[0].Product2.DIV_CODE__c);
            exchangeReturnData.put('ProductCode', it.ProductCode);
            exchangeReturnData.put('sProductId', it.sProductId);
            exchangeReturnData.put('sProductId', it.sProductId);
            exchangeReturnData.put('ParentId', prli[0].ParentId);

            mapParams.put('contactId', contacts[0].Id);
            mapParams.put('consigneeName', 'test');
            mapParams.put('ContactVIP', 1000);
            mapParams.put('IbCallNo', '01012345678');
            mapParams.put('newAddress', 'test');
            mapParams.put('detailAddress', 'test');
            mapParams.put('requestedTerm', 'test');
            mapParams.put('remark', 'test');
            mapParams.put('isContactSame', false);
            mapParams.put('strCaseId', '');
            mapParams.put('zoneCode', '3242');
            mapParams.put('channelType', '소모품택배');
            mapParams.put('basisOrderNumber', prli[0].BASIS_Number__c);
            mapParams.put('standardOrderData', JSON.serialize(standardOrderDataList));
            mapParams.put('stdConsumableOrderId', prli[0].ParentId);
            mapParams.put('soldOutOrderData', JSON.serialize(new List<EX_SuppliesController.ItemTable>()));
            mapParams.put('exchangeReturnData', new List<Map<String, Object>>{
                    exchangeReturnData
            });

            System.runAs(usr[0]) {
                try {
                    EX_SuppliesController.createExchangeRequest(mapParams);
                } catch (Exception e) {
                    System.debug(e);
                }

            }

            mapParams.put('standardOrderData', JSON.serialize(new List<EX_SuppliesController.ItemTable>()));
            mapParams.put('soldOutOrderData', JSON.serialize(standardOrderDataList));
            mapParams.put('channelType', 'LGE.COM');
            mapParams.put('isContactSame', true);
            mapParams.put('ContactVIP' , 1000);

            System.runAs(usr[0]) {
                EX_SuppliesController.doGetContactDept();
                try {
                    EX_SuppliesController.createExchangeRequest(mapParams);
                } catch (Exception e) {
                    System.debug(e);
                }
            }
            ProductRequestLineItem lineItem = [select id, Order_Number__c from ProductRequestLineItem Limit 1];
            List<EX_SuppliesController.ItemTable> table = new List<EX_SuppliesController.ItemTable>();
            EX_SuppliesController.ItemTable item = new EX_SuppliesController.ItemTable();
            item.Id = prli[0].Id;
            item.OrderNumber = prli[0].Order_Number__c;
            item.QTY = 1000;
            item.ASCPrice = 1000;
            item.Price = 1000;
            item.PromotionPrice = 0;
            table.add(item);

            List<EX_SuppliesController.ItemTable> table2 = new List<EX_SuppliesController.ItemTable>();


            mapParams.put('orderNumber', prli[0].Order_Number__c);
            mapParams.put('chkEmployeeName', '임직원');
            mapParams.put('chkEmployeeNum', '임직원');
            mapParams.put('chkCompanyName', [select id from SM_CODE__c LIMIT 1].Id);
            mapParams.put('chkEmployeeRelationShip', '임직원');
            mapParams.put('stdOrderTotalSalesAmount', 3000);
            mapParams.put('stdOrderTotalDiscountAmount', 1000);
            mapParams.put('standardOrderDataList', JSON.serialize(table));
            mapParams.put('soldOutOrderDataList', JSON.serialize(table2));
            mapParams.put('ContactVIP' , 1000);
        
            
            try {
                EX_SuppliesController.setEmpData(mapParams);
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }
    @IsTest
    static void checkEmpData2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
        List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT Id, TID__c, MOID__c, SR_PRE_PAYMENT_HEADER_ID__r.ATTR_RECORD_ID__c FROM SR_PRE_PAYMENT_DETAIL__c LIMIT 1];
        List<ProductItem> pi = [SELECT Id, Product2Id, Product2.ProductCode, Product2.DIV_CODE__c, LocationId FROM ProductItem LIMIT 1];
        List<Contact> contacts = [SELECT Id FROM Contact LIMIT 1];
        List<ProductRequestLineItem> prli = [SELECT Id, Order_Number__c, BASIS_Number__c, ParentId FROM ProductRequestLineItem LIMIT 1];

        if (!usr.isEmpty() && !paymentDetails.isEmpty() && !pi.isEmpty() && !contacts.isEmpty() && !prli.isEmpty()) {
            SI_SMARTRO_TOTAL_PAYMENT__c payment = new SI_SMARTRO_TOTAL_PAYMENT__c();
            payment.TID__c = paymentDetails[0].TID__c;
            payment.OID__c = paymentDetails[0].MOID__c;
            payment.PAYMETHOD__c = 'CARD';
            payment.RESULT_CODE__c = '4100';
            payment.AMT__c = 30000;
            payment.AUTH_CODE__c = '32dfas2432';
            payment.AUTH_DATE__c = '20230502123030';
            insert payment;

            List<EX_SuppliesController.ItemTable> standardOrderDataList = new List<EX_SuppliesController.ItemTable>();
            EX_SuppliesController.ItemTable it = new EX_SuppliesController.ItemTable();
            it.ProductCode = pi[0].Product2.ProductCode;
            it.sProductId = pi[0].Product2Id;
            it.sLocationId = pi[0].LocationId;
            it.QTY = 1;
            it.Price = 30000;
            it.PromotionPrice = 25000;
            standardOrderDataList.add(it);

            Map<String, Object> mapParams = new Map<String, Object>();
            Map<String, Object> exchangeReturnData = new Map<String, Object>();
            exchangeReturnData.put('Id', prli[0].Id);
            exchangeReturnData.put('RequestedReturnQuantity', 1);
            exchangeReturnData.put('DIVCODE', pi[0].Product2.DIV_CODE__c);
            exchangeReturnData.put('ProductCode', it.ProductCode);
            exchangeReturnData.put('sProductId', it.sProductId);
            exchangeReturnData.put('sProductId', it.sProductId);
            exchangeReturnData.put('ParentId', prli[0].ParentId);

            mapParams.put('contactId', contacts[0].Id);
            mapParams.put('consigneeName', 'test');
            mapParams.put('IbCallNo', '01012345678');
            mapParams.put('newAddress', 'test');
            mapParams.put('detailAddress', 'test');
            mapParams.put('requestedTerm', 'test');
            mapParams.put('remark', 'test');
            mapParams.put('isContactSame', false);
            mapParams.put('ContactVIP', 1000);
            mapParams.put('strCaseId', '');
            mapParams.put('zoneCode', '3242');
            mapParams.put('channelType', '소모품택배');
            mapParams.put('basisOrderNumber', prli[0].BASIS_Number__c);
            mapParams.put('standardOrderData', JSON.serialize(standardOrderDataList));
            mapParams.put('stdConsumableOrderId', prli[0].ParentId);
            mapParams.put('soldOutOrderData', JSON.serialize(new List<EX_SuppliesController.ItemTable>()));
            mapParams.put('exchangeReturnData', new List<Map<String, Object>>{
                    exchangeReturnData
            });

            System.runAs(usr[0]) {
                try {
                    EX_SuppliesController.createExchangeRequest(mapParams);
                } catch (Exception e) {
                    System.debug(e);
                }

            }

            mapParams.put('standardOrderData', JSON.serialize(new List<EX_SuppliesController.ItemTable>()));
            mapParams.put('soldOutOrderData', JSON.serialize(standardOrderDataList));
            mapParams.put('channelType', 'LGE.COM');
            mapParams.put('isContactSame', true);

            System.runAs(usr[0]) {
                EX_SuppliesController.doGetContactDept();
                try {
                    EX_SuppliesController.createExchangeRequest(mapParams);
                } catch (Exception e) {
                    System.debug(e);
                }
            }
            ProductRequestLineItem lineItem = [select id, Order_Number__c from ProductRequestLineItem Limit 1];
            lineItem.Consumables_Order_Class_Code__c = 'Sold Out';
            update lineItem;
            List<EX_SuppliesController.ItemTable> table = new List<EX_SuppliesController.ItemTable>();
            EX_SuppliesController.ItemTable item = new EX_SuppliesController.ItemTable();
            item.Id = lineItem.Id;
            item.OrderNumber = lineItem.Order_Number__c;
            item.QTY = 1000;
            item.ASCPrice = 1000;
            item.Price = 1000;
            item.PromotionPrice = 0;
            table.add(item);

            List<EX_SuppliesController.ItemTable> table2 = new List<EX_SuppliesController.ItemTable>();


            mapParams.put('orderNumber', prli[0].Order_Number__c);
            mapParams.put('chkEmployeeName', '임직원');
            mapParams.put('chkEmployeeNum', '임직원');
            mapParams.put('chkCompanyName', [select id from SM_CODE__c LIMIT 1].Id);
            mapParams.put('chkEmployeeRelationShip', '임직원');
            mapParams.put('stdOrderTotalSalesAmount', 3000);
            mapParams.put('stdOrderTotalDiscountAmount', 1000);
            mapParams.put('standardOrderDataList', JSON.serialize(table2));
            mapParams.put('soldOutOrderDataList', JSON.serialize(table));
            try {
                EX_SuppliesController.setEmpData(mapParams);
            } catch (Exception e) {
                System.debug(e.getMessage());
            }
        }
    }


    @IsTest
    static void codeCheck() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        EX_SuppliesController.ItemTable itemTable = new EX_SuppliesController.ItemTable('원', 'divCode', 'objPI.Product2.ProductCode', 'TECH_GRADE_PROD_CODE__c', 'productName', 'PART_SPEC__c', 1.1, 1.1, 1.1, '', 'Product2Id', 'objPI.Id', 'LocationId', 'DisplayUrl', 'Description', 'disabledType', 'partType', 'thinQItem', 'parcelYN', 1.1, 1.1, '', 0, 0, 0, 0, 'model', 'modelId', '', 0, 0);
                                                                                    // (, , , , , , , , Decimal, , , , , , , , , , , , , , , , , , String, String, String, Integer, Integer)

        TemplateMgmt__c  tm =   [SELECT Id, TemplateCode__c FROM TemplateMgmt__c LIMIT 1];

        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('ProductCode', '3424');
        mapParams.put('ProductName', 'dfasfasd');
        mapParams.put('ContactVIP', 1777);

        EX_SuppliesController.insertExMessageObj(JSON.serialize(mapParams), tm.TemplateCode__c);

        EX_SuppliesController.getResvResponse getResv = new EX_SuppliesController.getResvResponse();
        getResv.authText = 'test';
        getResv.identityCheck = false;
        getResv.companyName = 'test';
        Test.stopTest();

    }

    // @IsTest
    // static void sendSoldOutKakao() {
    //     Test.startTest();
    //     Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());

    //     List<EX_Message__c> messages = [SELECT Id, Label1__c, Label2__c FROM EX_Message__c LIMIT 1];
    //     List<ProductRequestLineItem> lineItems = [SELECT Id, ParentId FROM ProductRequestLineItem LIMIT 1];
    //     List<SM_DEPT__c> depts = [SELECT Id, Name FROM SM_DEPT__c LIMIT 1];
    //     if (!messages.isEmpty()) {

    //         EX_SuppliesController.sendSoldOutKakao('SVC_LGE_MACN_012_01', JSON.serialize(messages[0]), '01012345678');
    //     }

    //     Test.stopTest();
    // }

    @isTest
    static void codeCheck2() {
        List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        try{
        System.runAs(usr[0]) {
            List<ProductRequest> pr = [SELECT ID, Consumables_Order_Class_Code__c FROM ProductRequest];
            List<ProductRequestLineItem> prli = [SELECT ID, Consumables_Order_Class_Code__c FROM ProductRequestLineItem WHERE ParentId = :pr[0].Id];
            pr[0].Consumables_Order_Class_Code__c = 'Sold Out';
            prli[0].Consumables_Order_Class_Code__c = 'Sold Out';
            update pr;
            update prli;

            List<ProductItem> test = [SELECT ID, DIV_CODE__c, Product2Id FROM ProductItem];
    
            Map<String, Object> mapParams = mapParam();
            mapParams.put('DIVCODE', test[0].div_code__c);
            mapParams.put('sProductId', test[0].Product2Id);

            Schema.Location baseLocation = EX_TestDataUtil.getLocation_sold3(true, 'Location', 'PH8002');
            
            ProductItem baseProductItem = new ProductItem();
            baseProductItem.LocationId = baseLocation.Id;
            baseProductItem.Product2Id = test[0].Product2Id;
            baseProductItem.QuantityOnHand = 11;
            baseProductItem.DIV_CODE__c = 'DMZ';
            baseProductItem.ORDER_QTY__c = 100;
            insert baseProductItem;

            List<EX_SuppliesController.ItemTable> sell = (List<EX_SuppliesController.ItemTable>) JSON.deserialize((String) mapParams.get('standardOrderDataList'), List<EX_SuppliesController.ItemTable>.class);
            List<EX_SuppliesController.ItemTable> sold = (List<EX_SuppliesController.ItemTable>) JSON.deserialize((String) mapParams.get('soldOutOrderDataList'), List<EX_SuppliesController.ItemTable>.class);

            for (EX_SuppliesController.ItemTable sellObj : sell) {
                sellObj.DIVCODE = 'DMZ';
                sellObj.sProductId = test[0].Product2Id;
                sellObj.QTY = 9999;
            }

            for (EX_SuppliesController.ItemTable soldObj : sold) {
                soldObj.DIVCODE = 'DMZ';
                soldObj.sProductId = test[0].Product2Id;
                soldObj.QTY = 9999;
            }
            mapParams.put('standardOrderData', JSON.serialize(sold));
            mapParams.put('soldOutOrderData', JSON.serialize(sell));

            mapParams.put('ContactVIP' , 1000);

            EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
            EX_SuppliesController.doSaveConsumableOrder(mapParams);
        }            
        System.debug('codeCheck2 성공');
        }catch(Exception e){
        System.debug('codeCheck2 실패');
        }

        Test.stopTest();
    }

    
    @isTest
    static void codeCheck3() {
        List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        try{
        System.runAs(usr[0]) {
            List<ProductRequest> pr = [SELECT ID, Consumables_Order_Class_Code__c FROM ProductRequest];
            List<ProductRequestLineItem> prli = [SELECT ID, Consumables_Order_Class_Code__c FROM ProductRequestLineItem WHERE ParentId = :pr[0].Id];
            pr[0].Consumables_Order_Class_Code__c = 'Sold Out';
            prli[0].Consumables_Order_Class_Code__c = 'Sold Out';
            update pr;
            update prli;

            List<ProductItem> test = [SELECT ID, DIV_CODE__c, Product2Id FROM ProductItem];
    
            Map<String, Object> mapParams = mapParam();
            mapParams.put('DIVCODE', test[0].div_code__c);
            mapParams.put('sProductId', test[0].Product2Id);

            Schema.Location baseLocation = EX_TestDataUtil.getLocation_sold3(true, 'Location', 'PH8002');
            
            ProductItem baseProductItem = new ProductItem();
            baseProductItem.LocationId = baseLocation.Id;
            baseProductItem.Product2Id = test[0].Product2Id;
            baseProductItem.QuantityOnHand = 11;
            baseProductItem.DIV_CODE__c = 'DMZ';
            baseProductItem.ORDER_QTY__c = 100;
            insert baseProductItem;

            List<EX_SuppliesController.ItemTable> sell = (List<EX_SuppliesController.ItemTable>) JSON.deserialize((String) mapParams.get('standardOrderDataList'), List<EX_SuppliesController.ItemTable>.class);
            List<EX_SuppliesController.ItemTable> sold = (List<EX_SuppliesController.ItemTable>) JSON.deserialize((String) mapParams.get('soldOutOrderDataList'), List<EX_SuppliesController.ItemTable>.class);

            for (EX_SuppliesController.ItemTable sellObj : sell) {
                sellObj.DIVCODE = 'DMZ';
                sellObj.sProductId = test[0].Product2Id;
                sellObj.PromotionPrice = 10000;
                sellObj.Price = 1;
                sellObj.QTY = 9999;
            }

            for (EX_SuppliesController.ItemTable soldObj : sold) {
                soldObj.DIVCODE = 'DMZ';
                soldObj.sProductId = test[0].Product2Id;
                soldObj.QTY = 9999;
            }
            mapParams.put('standardOrderData', JSON.serialize(sold));
            mapParams.put('soldOutOrderData', JSON.serialize(sell));
            mapParams.put('isContactSame', true);
            mapParams.put('ContactVIP' , 1000);



            EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
            EX_SuppliesController.doSaveConsumableOrder(mapParams);
        }            
        System.debug('codeCheck3 성공');
        }catch(Exception e){
        System.debug('codeCheck3 실패');
        }

        Test.stopTest();
    }

    @isTest
    static void codeCheck4() {
        List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        try{
        System.runAs(usr[0]) {
            List<ProductRequest> pr = [SELECT ID, Consumables_Order_Class_Code__c FROM ProductRequest];
            List<ProductRequestLineItem> prli = [SELECT ID, Consumables_Order_Class_Code__c FROM ProductRequestLineItem WHERE ParentId = :pr[0].Id];
            pr[0].Consumables_Order_Class_Code__c = 'General';
            prli[0].Consumables_Order_Class_Code__c = 'General';
            update pr;
            update prli;

            List<ProductItem> test = [SELECT ID, DIV_CODE__c, Product2Id FROM ProductItem];
    
            Map<String, Object> mapParams = mapParam();
            mapParams.put('DIVCODE', test[0].div_code__c);
            mapParams.put('sProductId', test[0].Product2Id);

            Schema.Location baseLocation = EX_TestDataUtil.getLocation_sold3(true, 'Location', 'PH8002');
            
            ProductItem baseProductItem = new ProductItem();
            baseProductItem.LocationId = baseLocation.Id;
            baseProductItem.Product2Id = test[0].Product2Id;
            baseProductItem.QuantityOnHand = 11;
            baseProductItem.DIV_CODE__c = 'DMZ';
            baseProductItem.ORDER_QTY__c = 100;
            insert baseProductItem;

            List<EX_SuppliesController.ItemTable> sell = (List<EX_SuppliesController.ItemTable>) JSON.deserialize((String) mapParams.get('standardOrderDataList'), List<EX_SuppliesController.ItemTable>.class);
            List<EX_SuppliesController.ItemTable> sold = (List<EX_SuppliesController.ItemTable>) JSON.deserialize((String) mapParams.get('soldOutOrderDataList'), List<EX_SuppliesController.ItemTable>.class);

            for (EX_SuppliesController.ItemTable sellObj : sell) {
                sellObj.DIVCODE = 'DMZ';
                sellObj.sProductId = test[0].Product2Id;
                sellObj.PromotionPrice = 10000;
                sellObj.Price = 1;
                sellObj.QTY = 9999;
            }

            for (EX_SuppliesController.ItemTable soldObj : sold) {
                soldObj.DIVCODE = 'DMZ';
                soldObj.sProductId = test[0].Product2Id;
                soldObj.QTY = 9999;
            }
            mapParams.put('standardOrderData', JSON.serialize(sold));
            mapParams.put('soldOutOrderData', JSON.serialize(sell));
            mapParams.put('ContactVIP' , 1000);



            EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
            EX_SuppliesController.doSaveConsumableOrder(mapParams);
        }
        System.debug('codeCheck4 성공');
        }catch(Exception e){
        System.debug('codeCheck4 실패');
        }

        Test.stopTest();
    }
    @isTest
    static void codeCheck5() {
        List<User> usr = [SELECT Id FROM User WHERE LastName = 'testUser_ex' LIMIT 1];
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        try{
        System.runAs(usr[0]) {
            List<ProductRequest> pr = [SELECT ID, Consumables_Order_Class_Code__c,Order_Number__c FROM ProductRequest];
            List<ProductRequestLineItem> prli = [SELECT ID, Consumables_Order_Class_Code__c FROM ProductRequestLineItem WHERE ParentId = :pr[0].Id];
            pr[0].Consumables_Order_Class_Code__c = 'General';
            prli[0].Consumables_Order_Class_Code__c = 'General';
            update pr;
            update prli;

            List<SR_PRE_PAYMENT_HEADER__c> prePaymentHeader = [SELECT id FROM SR_PRE_PAYMENT_HEADER__c WHERE BASIS_NO__c =: pr[0].Order_Number__c];
            List<SR_SMARTRO_PAYMENT_REQUEST__c> smartroPaymentRequest = [SELECT Id,TID__c FROM SR_SMARTRO_PAYMENT_REQUEST__c];

            SR_PRE_PAYMENT_DETAIL__c  prePaymentDetail;
            prePaymentDetail = new SR_PRE_PAYMENT_DETAIL__c();
            prePaymentDetail.ALLOC_MONTH__c = '0';
            prePaymentDetail.APPR_DT__c = Date.today();
            prePaymentDetail.APPR_DTTM__c = Datetime.now();
            prePaymentDetail.APPR_NUM__c = '033497230';
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
            prePaymentDetail.MOID__c = 'tlgsmp001m';
            prePaymentDetail.BANK_CODE__c = 'KB000';
            prePaymentDetail.SR_PRE_PAYMENT_HEADER_ID__c = prePaymentHeader[0].Id;
            prePaymentDetail.TID_CASH__c = '325324242';
            prePaymentDetail.SR_SMARTRO_PAYMENT_REQUEST_ID__c = smartroPaymentRequest[0].Id;
            prePaymentDetail.TID__c = smartroPaymentRequest[0].TID__c;  
            insert prePaymentDetail;              

            List<ProductItem> test = [SELECT ID, DIV_CODE__c, Product2Id FROM ProductItem];
    
            Map<String, Object> mapParams = mapParam();
            mapParams.put('DIVCODE', test[0].div_code__c);
            mapParams.put('sProductId', test[0].Product2Id);

            Schema.Location baseLocation = EX_TestDataUtil.getLocation_sold3(true, 'Location', 'PH8002');
            
            ProductItem baseProductItem = new ProductItem();
            baseProductItem.LocationId = baseLocation.Id;
            baseProductItem.Product2Id = test[0].Product2Id;
            baseProductItem.QuantityOnHand = 11;
            baseProductItem.DIV_CODE__c = 'DMZ';
            baseProductItem.ORDER_QTY__c = 100;
            insert baseProductItem;

            List<EX_SuppliesController.ItemTable> sell = (List<EX_SuppliesController.ItemTable>) JSON.deserialize((String) mapParams.get('standardOrderDataList'), List<EX_SuppliesController.ItemTable>.class);
            List<EX_SuppliesController.ItemTable> sold = (List<EX_SuppliesController.ItemTable>) JSON.deserialize((String) mapParams.get('soldOutOrderDataList'), List<EX_SuppliesController.ItemTable>.class);

            for (EX_SuppliesController.ItemTable sellObj : sell) {
                sellObj.DIVCODE = 'DMZ';
                sellObj.sProductId = test[0].Product2Id;
                sellObj.PromotionPrice = 10000;
                sellObj.Price = 1;
                sellObj.QTY = 9999;
            }

            for (EX_SuppliesController.ItemTable soldObj : sold) {
                soldObj.DIVCODE = 'DMZ';
                soldObj.sProductId = test[0].Product2Id;
                soldObj.QTY = 9999;
            }
            mapParams.put('standardOrderData', JSON.serialize(sold));
            mapParams.put('soldOutOrderData', JSON.serialize(sell));
            mapParams.put('ContactVIP' , 1000);

            mapParams.put('isTemporary', false);

            // EX_SuppliesController.doTemporarySaveConsumableOrder(mapParams);
            EX_SuppliesController.doSaveConsumableOrder(mapParams);
        }
        System.debug('codeCheck5 성공');
        }catch(Exception e){
        System.debug('codeCheck5 실패');
        }

        Test.stopTest();
    }

    @isTest
    static void test_getInitSetting(){
        List<User> usr = [SELECT Id FROM User LIMIT 1];

        Test.startTest();
        SM_BIZ_MANAGER__c bizManager = new SM_BIZ_MANAGER__c();
        bizManager.User__c = usr[0].Id;
        bizManager.BIZ_MANAGER_TYPE__c = '43';
        insert bizManager;

        EX_SuppliesController.getInitSetting();
        Test.stopTest();
    }

    @isTest
    static void doGetOrderInfo_test_02(){
        Map<String, Object> paramMap = new Map<String, Object>();

        ProductRequest pr = EX_TestDataUtil.getProductRequest(true);
        paramMap.put('stdConsumableOrderId', pr.Id);

        Test.startTest();
        EX_SuppliesController.doGetOrderInfo(paramMap);
        Test.stopTest();

    }

    @isTest
    static void test_exSuppliesCreateOrderGroup(){
        Map<String, Object> paramMap = new Map<String, Object>();

        ProductRequest pr = EX_TestDataUtil.getProductRequest(true);
        paramMap.put('stdConsumableOrderId', pr.Id);

        Test.startTest();
        EX_SuppliesController.exSuppliesCreateOrderGroup(paramMap);
        Test.stopTest();

    }


    @isTest
    static void getPartData_test_01(){
        List<String> listId = new List<String>();
        Product2 p = EX_TestDataUtil.createProduct();
        listId.add(p.Id);
        
        Test.startTest();
        EX_SuppliesController.getPartData(listId);
        Test.stopTest();
    }

    // @isTest
    // static void getInitData_test_01(){
    //     String params = '1';
    //     Test.startTest();
    //     EX_SuppliesController.getInitData(params);
    //     Test.stopTest();
    // }

    @isTest
    static void getMaximumAmount_test_01(){
        Test.startTest();
        EX_SuppliesController.getMaximumAmount();
        Test.stopTest();
    }

    @isTest
    static void getShipmentName_test_01(){
        List<String> divCodeList = new List<String>();
        divCodeList.add('PH8002');


        Test.startTest();
        EX_SuppliesController.getShipmentName(divCodeList);
        Test.stopTest();
    }
    @isTest
    static void getShipmentName_test_02(){
        List<String> divCodeList = new List<String>();
        divCodeList.add('PHPHPH');


        Test.startTest();
        EX_SuppliesController.getShipmentName(divCodeList);
        Test.stopTest();
    }

    @isTest
    static void sendOrderReceivingAlarm_test(){
        Test.startTest();
        ProductRequestLineItem prli1 = EX_TestDataUtil.getProductRequestLineItem(true);
        ProductRequestLineItem prli2 = EX_TestDataUtil.getProductRequestLineItem(false).clone();
        ProductTransfer pt1 = EX_TestDataUtil.getProductTransfer(true);
        Product2 prd = EX_TestDataUtil.baseProduct;

        prli2.Order_CHNL_TYPE_Code__c = 'V';
        insert prli2;

        SR_RESRV_PART__c srp = new SR_RESRV_PART__c();
        insert srp;

        prli1.SR_RESRV_PART_ID__c = srp.Id;
        prli1.Order_CHNL_TYPE_Code__c = 'V';
        update prli1;


        pt1.ProductRequestLineItem = prli1;
        update pt1;

        TemplateMgmt__c mgmt = new TemplateMgmt__c();
        mgmt.TemplateCode__c = 'SVC_LGE_MACN_S020';
        mgmt.Title__c = mgmt.TemplateCode__c;
        insert mgmt;

        List<ProductTransfer> listPT = new List<ProductTransfer>{pt1, new ProductTransfer(ProductRequestLineItem = prli1)};
        String ptString = JSON.serialize(listPT);

        EX_SuppliesController.sendOrderReceivingAlarm(ptString);
        Test.stopTest();
    }
}