/**
 * Created by I2MAX.SEOKHOLEE on 2022-11-13.
 */

 public without sharing class EX_SuppliesController extends EX_ConsumableService {

    public static String STANDARD_ORDER = 'STANDARD_ORDER';
    public static String SOLD_OUT_ORDER = 'SOLD_OUT_ORDER';
    public static String PO = 'PO';

    @AuraEnabled
    public static Map<String, Object> getCenterList() {
        Map<String, Map<String, Object>> mapSettingValue = new Map<String, Map<String, Object>>();
        Map<String, List<Map<String, String>>> mapCommPickLists = new Map<String, List<Map<String, String>>>();
        // 소모품 주문 상태 코드

        List<SM_DEPT__c> centerList = (List<SM_DEPT__c>) [
                SELECT Id, Name, DEPT_CODE__c
                FROM   SM_DEPT__c
                WHERE  CLOSE_YN__c != 'Y'
                AND    DEPT_TYPE_SECOND__c IN ('E', 'G', 'H') ];

        List<Map<String, String>> listMapCenter = new List<Map<String, String>>();
        
        for (SM_DEPT__c obj : centerList) {
            listMapCenter.add(new Map<String, String>{
                    'label' => obj.DEPT_CODE__c + '_' + obj.Name,
                    'value' => obj.DEPT_CODE__c
            });
        }

        mapCommPickLists.put('listMapCenter', listMapCenter);

        //리턴 값
        mapSettingValue.put('Comm', mapCommPickLists);

        Map<String, Object> mapReturn = new Map<String, Object>{
                'mapSettingValueOrigin' => mapSettingValue
        };

        return mapReturn;
    }

    @AuraEnabled //Get Account Records
    public static List<SM_SVCBOM__c> getsbomList2(String sortingField, Boolean isSortAsc, String modelId, String partDesc, String partSpec, String partNo, String enteredValue) {
        List<SM_SVCBOM__c> listReturn = new List<SM_SVCBOM__c>();
        //List<SM_SVCBOM__c> listReturn = FS_SearchSBOMController.getsbomList2(sortingField, isSortAsc, modelId, partDesc, partSpec, partNo, enteredValue);
        return listReturn;
    }

    @AuraEnabled
    public static Map<String, Object> getPartData(List<String> listId) {
        List<Product2> listProd = new List<Product2>();
        String strQuery = '';

        strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('Product2');
        strQuery += ' FROM Product2 ';
        strQuery += ' WHERE Id IN :listId ';

        listProd = Database.query(strQuery);

        Map<String, Object> mapReturn = new Map<String, Object>{
                'listProd' => listProd
        };
        return mapReturn;
    }

    @AuraEnabled
    public static String doGetServiceResource() {
        ServiceResource kResource = [
                SELECT Id, RecordType.DeveloperName
                FROM   ServiceResource
                WHERE  RelatedRecordId = :UserInfo.getUserId()
                AND   ( RecordType.DeveloperName = 'SE' OR RecordType.DeveloperName = 'CNSL' ) 
                AND    IsActive = true 
        ][0];
        return kResource.RecordType.DeveloperName;
    }

    /*전국 조회에 사용될 location반환*/
    @AuraEnabled
    public static Map<String, Object> getResourceLocation() {
        Map<String, Object> returnMap = new Map<String, Object>();
        
        Boolean isConsultant = false;
        String currentLocation = '';
        ServiceResource objSR = new ServiceResource();

        //23.12.12 seung yoon heo 프로필 체크
        Map<Id, Profile> profileMap = new Map<Id, Profile>([SELECT Id FROM Profile WHERE Name LIKE '%SVC(HiT, LGE)%']);
        Set<Id> profileSet = new Set<Id>(profileMap.keySet());

 


        Schema.Location phLocation = [
                SELECT Id, DEPT_CODE__c, fm_RecordType__c
                FROM   Location
                WHERE  DEPT_CODE__c = 'PH8002' AND fm_RecordType__c = 'center'
        ][0];

        User currentUser = [
                SELECT Id, DEPT_CODE__c
                FROM   User
                WHERE  Id =: userInfo.getUserId()
        ][0];

        try{
            if(profileSet.contains(userInfo.getProfileId())){
                Schema.Location getCenterId = [
                    SELECT Id, Name 
                    FROM   Location
                    WHERE  (SM_DEPT_Id__r.DEPT_CODE__c =: currentUser.DEPT_CODE__c OR DEPT_CODE__c =: currentUser.DEPT_CODE__c) AND RecordType.DeveloperName = 'Center'
                    ][0];
                    
                    returnMap.put('serviceCenterId' , getCenterId.Id);
                    returnMap.put('serviceCenterLabel' , getCenterId.Name);

            }
        }catch(Exception e){
            System.debug(e);
        }
    

        try {
            objSR = [
                    SELECT Id, Name, JOB_TYPE__c, RecordType.DeveloperName, LocationId
                    FROM   ServiceResource
                    WHERE  RelatedRecordId = :UserInfo.getUserId()
                    AND    IsActive = TRUE
            ][0];
        } catch (Exception e) {
            // throw new AuraHandledException('사용자 이름의 서비스자원(ServiceResource) 데이터가 없습니다.');
            System.debug(e);
        }

        SM_DEPT__c objSmDept = new SM_DEPT__c();
        try {
            objSmDept = [
                    SELECT Id, Name, DEPT_CODE__c, HIGH_DEPT_CODE__c, DEPT_TYPE_SECOND__c, HIGH_DEPT_CODE__r.DEPT_CODE__c, AGENCY_DC_RATE__c
                    FROM   SM_DEPT__c
                    WHERE  DEPT_CODE__c =: currentUser.DEPT_CODE__c
            ];
        } catch (Exception e) {
            throw new AuraHandledException('사용자 소속의 조직(SM_DEPT__c) 데이터가 없습니다.');
        }

        Set<String> setDeptTypeSecond = new Set<String>{
                'I', 'J', 'Q', 'M'
        };
        String strCenterCode = currentUser.DEPT_CODE__c;



        if (setDeptTypeSecond.contains(objSmDept.DEPT_TYPE_SECOND__c)) {
            strCenterCode = objSmDept.HIGH_DEPT_CODE__r.DEPT_CODE__c;
        }

        if (objSR.RecordType.DeveloperName == 'CNSL') {
            currentLocation = String.valueOf(phLocation.Id);
        } 
        else if (objSR.RecordType.DeveloperName != null) {
            if (objSR.LocationId != null)
                currentLocation = String.valueOf(objSR.LocationId);
            else
                currentLocation = String.valueOf(phLocation.Id);
        } else {
            currentLocation = String.valueOf(phLocation.Id);
        }
        // Schema.Location objLocation = new Schema.Location();
        // if(!isConsultant) {
        //     try {
        //         objLocation = [
        //                 SELECT Id, Name
        //                 FROM Location
        //                 WHERE DEPT_CODE__c = :strCenterCode
        //                 AND RecordType.DeveloperName = 'Center'
        //         ];
        //     } catch (Exception e) {
        //         throw new AuraHandledException('사용자 소속의 센터(Location) 데이터가 없습니다.');
        //     }
        //     System.debug('objLocation: ' + objLocation);
        // }
        returnMap.put('currentLocation' , currentLocation);
        return returnMap;
    }

    /*센터의 Location Id 추출*/
    @AuraEnabled
    public static String getLocation(String smdeptId) {
        String locationId = '';

        List<Schema.Location> listLo = [
                SELECT Id
                FROM   Location
                WHERE  SM_DEPT_Id__c =: smdeptId
        ];

        if (!listLo.isEmpty()) {
            locationId = listLo[0].Id;
        }

        return locationId;
    }

    @AuraEnabled
    public static Map<String, Object> doGetContactInfoByCaseId(String strCaseId) {
        Map<String, Object> rerturnMap = new Map<String, Object>();
        Contact c;
        if (strCaseId != null && strCaseId != '') {
            Case objCase = [SELECT ContactId FROM Case WHERE Id =: strCaseId];
            if (objCase.ContactId == null) {
                return null;
            }

            // 2023.09.20 seung yoon heo Case에 TRANSFER_REASON2__c 추가
            c = [
                    SELECT Id, ADDRESS_NEW__c, ADDRESS_OLD__c, ADDRESS_DETAIL__c, POSTAL_CODE__c, LATITUDE__c, LONGITUDE__c, Name, Phone, MobilePhone, fm_ADDRESS_NEW__c, Email, fm_ADDRESS_OLD__c, CUSTOMER_GRADE__c, (SELECT Id, Description, CaseNumber, ModelName__c, ModelName__r.Name, Contact.Name, Contact.Phone, Contact.MobilePhone, TRANSFER_REASON2__c FROM Cases WHERE Id = :strCaseId)
                    FROM   Contact
                    WHERE  Id =: objCase.ContactId
            ];
        }
        Decimal percent = null;
        System.debug('????' + c.CUSTOMER_GRADE__c);
        if (c.CUSTOMER_GRADE__c != null) {
            String getDCPercent = [
                    SELECT Id, CLASS_CODE__c, USE_YN__c, ATTRIBUTE3__c
                    FROM   SM_CODE__c
                    WHERE  CLASS_CODE__r.Name = 'CU007'
                    AND    USE_YN__c = 'Y'
                    AND    Name =: c.CUSTOMER_GRADE__c
                ].ATTRIBUTE3__c;
            
            percent = Integer.valueOf(getDCPercent) * 0.01;
        } else {
            percent = 0;
        }



        if (c.MobilePhone == null)
            c.MobilePhone = c.Phone;
        if (c.Phone == null)
            c.Phone = c.MobilePhone;
            System.debug('percent ?? ' + percent);

            rerturnMap.put('objCon' , c);
            rerturnMap.put('contactVIP' , percent);

        return rerturnMap;
    }

    @AuraEnabled
    public static Contact doConInfoByCase(String strCaseId) {
        Contact c;
        if (strCaseId != null && strCaseId != '') {
            Case objCase = [SELECT ContactId FROM Case WHERE Id =: strCaseId];

            if (objCase.ContactId == null) {
                return null;
            }

            // 2023.09.20 seung yoon heo Case에 TRANSFER_REASON2__c 추가
            c = [
                    SELECT Id, ADDRESS_NEW__c, ADDRESS_OLD__c, ADDRESS_DETAIL__c, POSTAL_CODE__c, LATITUDE__c, LONGITUDE__c, Name, Phone, MobilePhone, fm_ADDRESS_NEW__c, Email, fm_ADDRESS_OLD__c, (SELECT Id, Description, CaseNumber, ModelName__c, ModelName__r.Name, Contact.Name, Contact.Phone, Contact.MobilePhone, TRANSFER_REASON2__c FROM Cases WHERE Id = :strCaseId)
                    FROM   Contact
                    WHERE  Id =: objCase.ContactId
            ];
        }

        if (c.MobilePhone == null)
            c.MobilePhone = c.Phone;
        if (c.Phone == null)
            c.Phone = c.MobilePhone;
            
        return c;
    }

    @AuraEnabled
    public static Map<String, Object> doGetContactInfoByContactId(String strContactId) {
        Map<String, Object> rerturnMap = new Map<String, Object>();
        Contact c = [
                SELECT Id, Email, ADDRESS_NEW__c, ADDRESS_OLD__c, ADDRESS_DETAIL__c, POSTAL_CODE__c, LATITUDE__c, LONGITUDE__c, Name, Phone, MobilePhone, fm_ADDRESS_NEW__c, fm_ADDRESS_OLD__c, CUSTOMER_GRADE__c
                FROM   Contact
                WHERE  Id =: strContactId
        ];

        // 2024.01.16 seung yoon heo vip계산 통합
        Decimal percent = null;
        if (c.CUSTOMER_GRADE__c != null) {
            String getDCPercent = [
                    SELECT Id, CLASS_CODE__c, USE_YN__c, ATTRIBUTE3__c
                    FROM   SM_CODE__c
                    WHERE  CLASS_CODE__r.Name = 'CU007'
                    AND    USE_YN__c = 'Y'
                    AND    Name =: c.CUSTOMER_GRADE__c
                ].ATTRIBUTE3__c;
            
            percent = Integer.valueOf(getDCPercent) * 0.01;
        } else {
            percent = 0;
        }


        if (c.MobilePhone == null)
            c.MobilePhone = c.Phone;
        if (c.Phone == null)
            c.Phone = c.MobilePhone;

            rerturnMap.put('objCon' , c);
            rerturnMap.put('contactVIP' , percent);

        return rerturnMap;
    }

    @AuraEnabled
    public static Map<String, Object> getInitSetting(){
        Map<String, Object> returnMap = new Map<String, Object>();
        try {
            Decimal minCost = getMinimumCost();
            Boolean bulkManager = false;
            Boolean costManager = false;
            //23 09 20 hyungho.chun
            // User currentUser = [SELECT Id, EmployeeNumber__c,Name,Phone,DEPT_CODE__c from User where id = :UserInfo.getUserId()];

            // List<SM_BIZ_MANAGER__c> bizManager = [SELECT Id from SM_BIZ_MANAGER__c WHERE ((MANAGER_ID__c = :currentUser.EmployeeNumber__c and MANAGER_ID__c != NULL ) OR User__c = :currentUser.Id) AND (BIZ_MANAGER_TYPE__c = :'43' OR BIZ_MANAGER_TYPE__c = :'44')];
            // if (bizManager.size() > 0) {
            //     for (SM_BIZ_MANAGER__c bObj : bizManager) {
            //         if (bObj.BIZ_MANAGER_TYPE__c == '43') {
            //             bulkManager = true;
            //         } else if (bObj.BIZ_MANAGER_TYPE__c == '44') {
            //             costManager = true;
            //         }
            //     }
            // }

            bulkManager = doGetBulkOrderManager();
            costManager = doGetCostLimitManager();

            return returnMap = new Map<String, Object>{
                'STATUS' => 'S',
                'minCost' => minCost,
                'bulk' => bulkManager,
                'cost' => costManager
            };
            
        } catch (Exception e) {
            return returnMap = new Map<String, Object>{
                'STATUS' => 'E',
                'MESSAGE' => e.getMessage()
            };
        }
    }

    @AuraEnabled
    public static Boolean doGetBulkOrderManager() {
        Boolean returnBoolean = false;
        //23 10 06 hyungho.chun 최소주문수량 프로필만 조회하는거로 수정
        // User currentUser = EX_ConsumableService.doGetManagerInfo();
        //업무 담당자에 생성되있는지 체크(임시로 Manager_type 7 : Staff_품질 )
        // List<SM_BIZ_MANAGER__c> bizManager = [SELECT Id from SM_BIZ_MANAGER__c WHERE ((MANAGER_ID__c = :currentUser.EmployeeNumber__c and MANAGER_ID__c != NULL ) OR User__c = :currentUser.Id) AND BIZ_MANAGER_TYPE__c = :'43'];

        // returnBoolean = bizManager.isEmpty() ? false : true;
        
        // if (!returnBoolean) {
        //     returnBoolean = doGetExcepManager();
        // }

        returnBoolean = doGetExcepManager();

        // if (currentUser.EmployeeNumber__c == null && currentUser.Id == null) {
        //     return false;
        // }
        return returnBoolean;
    }

    @AuraEnabled
    public static Boolean doGetCostLimitManager() {
        Boolean returnBoolean = false;
        //23 10 06 hyungho.chun 최소주문금액 프로필만 조회하는거로 수정
        // User currentUser = EX_ConsumableService.doGetManagerInfo();
        //업무 담당자에 생성되있는지 체크(임시로 Manager_type 8 : Staff_자재 )
        // List<SM_BIZ_MANAGER__c> bizManager = [SELECT Id from SM_BIZ_MANAGER__c WHERE ((MANAGER_ID__c = :currentUser.EmployeeNumber__c and MANAGER_ID__c != NULL ) OR User__c = :currentUser.Id) AND BIZ_MANAGER_TYPE__c = :'44'];
        // if (currentUser.EmployeeNumber__c == null && currentUser.Id == null) {
            // return false;
        // }
        // returnBoolean = bizManager.isEmpty() ? false : true;

        // if (!returnBoolean) {
            // returnBoolean = doGetExcepManager();
        // }

        returnBoolean = doGetExcepManager();

        return returnBoolean;
    }

    //gw.lee 2023.08.19
    //이용석 책임님 추가 요청, Profile 콜센터/팀장일 경우, 예외 로직 추가
    public static Boolean doGetExcepManager() {
        Boolean isManager = false;
        User currentUser = [SELECT Profile.Name FROM User WHERE Id =: UserInfo.getUserID()];

        //23 09 20 hyungho.chun 프로필name 라벨작업
        //23 12 09 EX_partTeamLeader 추가 ( SVC(HiT, LGE)_상황/지원/파트장 )
        if (currentUser.Profile.Name == System.Label.EX_callCenterChief || currentUser.Profile.Name == System.Label.EX_consumableCenter || currentUser.Profile.Name == System.Label.EX_consumableStaff || currentUser.Profile.Name == System.Label.EX_partTeamLeader) {
            isManager = true;
        }

        return isManager;
    }

    // @AuraEnabled
    // public static List<SM_BIZ_MANAGER__c> doGetWorkManager() {
        // User currentUser = EX_ConsumableService.doGetManagerInfo();
        // List<SM_BIZ_MANAGER__c> bizManager = [SELECT BIZ_MANAGER_TYPE__c from SM_BIZ_MANAGER__c WHERE MANAGER_ID__c = :currentUser.EmployeeNumber__c];
        // return bizManager;
    // }

    @AuraEnabled
    public static Map<String, Map<String, Object>> exSuppliesCreateOrderGroup(Map<String, Object> paramMap){
        Map<String, Map<String, Object>> resultMap = new Map<String, Map<String, Object>>();
        try {
            resultMap.put('STATUS', new Map<String, Object>{
                'result' => 'S'
            });
            resultMap.put('doGetOrderInfo',doGetOrderInfo(paramMap));
            resultMap.put('doGetEmpInfo' , new Map<String, Object>{
                'result' => doGetEmpInfo()
            });
            resultMap.put('doGetContactDept', new Map<String, Object>{
                'result' => doGetContactDept()
            });
            resultMap.put('doGetServiceResource', new Map<String, Object>{
                'result' => doGetServiceResource()
            });

            return resultMap;
        } catch (Exception e) {
            return resultMap = new Map<String, Map<String, Object>>{
                'STAUTS' => new Map<String, Object>{
                    'result' => 'E'
                },
                'error' => new Map<String, Object>{
                    'result' => e.getMessage()
                }
            };
        }
    }

    // 2023 10 01 택배주문에 주문취소 삭제 delete -> 상태값 update으로 변경
    @AuraEnabled
    public static Map<String, Object> doOrderDeleteInfo(Map<String, Object> paramMap){
        // try {
            // System.debug('paramMap /// ' + paramMap);
            // EX_SuppliesOrderDelete_qa orderDeleteQa = new EX_SuppliesOrderDelete_qa(paramMap);
            // System.enqueueJob(orderDeleteQa);
        // } catch (Exception e) {
            // System.debug(e.getLineNumber() + ' Line || ' + e.getMessage());
            // throw new AuraHandledException(e.getLineNumber() + ' Line || ' + e.getMessage());
        // }

        Map<String, Object> returnMap = new Map<String, Object>();
        Map<String, String> orderTypeMap = new Map<String, String>();

        String stdConsumableOrderId = (String) paramMap.get('stdConsumableOrderId') != null ? (String) paramMap.get('stdConsumableOrderId') : '';
        String soldOutConsumableOrderId = (String) paramMap.get('soldOutConsumableOrderId') != null ? (String) paramMap.get('soldOutConsumableOrderId') : '';

        orderTypeMap.put(stdConsumableOrderId , '일반주문');
        orderTypeMap.put(soldOutConsumableOrderId , '품절주문');

        System.debug('stdConsumableOrderId' + stdConsumableOrderId);
        System.debug('soldOutConsumableOrderId' + soldOutConsumableOrderId);

        Set<String> orderIdSet = new Set<String>();
        if(stdConsumableOrderId != '' && soldOutConsumableOrderId != ''){
            orderIdSet.add(stdConsumableOrderId);
            orderIdSet.add(soldOutConsumableOrderId);
            //  = '(\'' + stdConsumableOrderId + '\' , \'' + soldOutConsumableOrderId + '\')'; 
        } else {
            if(stdConsumableOrderId != ''){
                // prId = '('+stdConsumableOrderId+')';
                orderIdSet.add(stdConsumableOrderId);
            } else if(soldOutConsumableOrderId != ''){
                // prId = '('+soldOutConsumableOrderId+')';
                orderIdSet.add(soldOutConsumableOrderId);
            }
        }

        System.debug('orderIdSet' + orderIdSet);

        if(orderIdSet.size() > 0){
            // ProductRequest deleteOrderList = [SELECT Id, Order_Number__c FROM ProductRequest WHERE Id =: soldOutConsumableOrderId];

            // ProductRequestLineItem deleteOrderItem = [SELECT SR_RESRV_PART_Id__r.RSRV_Number__c FROM ProductRequestLineItem WHERE ParentId =: soldOutConsumableOrderId];
            List<ProductRequestLineItem> deleteOrderItem = [SELECT Id,ParentId, QuantityRequested, Order_Number__c, CANCEL_Reason__c, RSRV_Number__c ,SALE_Quantity__c
                                                                  ,tolabel(Parent.Order_CHNL_TYPE_Code__c), tolabel(Consumables_Order_Status__c), SR_RESRV_PART_Id__r.RSRV_Number__c 
                                                            FROM   ProductRequestLineItem WHERE ParentId IN: orderIdSet];

            System.debug('deleteOrderItem' + deleteOrderItem);
            
            if(soldOutConsumableOrderId != ''){
                for(ProductRequestLineItem pr : deleteOrderItem){
                    if (pr.SR_RESRV_PART_Id__r.RSRV_Number__c == null && orderTypeMap.get(pr.ParentId) == '품절주문') {
                        returnMap.put('status', 'e');
                        returnMap.put('message', '주문취소가 정상적으로 이루어지지 않았습니다. 다시시도 해주시기 바랍니다.');
                        // break; 
                        return returnMap;
                    }
                }
                // String RESRV_Number = deleteOrderItem[0].SR_RESRV_PART_Id__r.RSRV_Number__c;
                // System.debug('RESRV_Number' + RESRV_Number);
            }
            
            // List<ProductRequestLineItem> soldOrderItemList = [SELECT Id,ParentId, QuantityRequested, Order_Number__c, CANCEL_Reason__c, RSRV_Number__c ,SALE_Quantity__c, tolabel(Parent.Order_CHNL_TYPE_Code__c), tolabel(Consumables_Order_Status__c) FROM ProductRequestLineItem WHERE SR_RESRV_PART_Id__r.RSRV_Number__c =: RESRV_Number];

            // System.debug('soldOrderItemList' + soldOrderItemList);

            List<EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable> conItemTableList = new List<EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable>();

            for(ProductRequestLineItem pr : deleteOrderItem){
                EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable conItemTable = new EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable();
                conItemTable.Id = pr.Id;
                conItemTable.QuantityRequested = pr.QuantityRequested;
                conItemTable.OrderNumber = pr.Order_Number__c;
                conItemTable.CancelQuantity = pr.QuantityRequested;
                conItemTable.CancelRequestReason = pr.CANCEL_Reason__c;
                conItemTable.RSRV_Number = pr.RSRV_Number__c != null ? pr.RSRV_Number__c : '';
                conItemTable.OrderType = orderTypeMap.get(pr.ParentId);
                conItemTable.SalesQuantity = pr.SALE_Quantity__c;
                conItemTable.OrderChannel = pr.Parent.Order_CHNL_TYPE_Code__c;
                conItemTable.OrderStatus = pr.Consumables_Order_Status__c;
                conItemTableList.add(conItemTable);
            }
            System.debug('데이터 확인' + conItemTableList);

            // returnMap = EX_ConsumableUtil.cancelUtil(null, null, selectedRows, draftValues, selectedMasterData, bankCode, bankAccountNo, receiverName);
            returnMap = EX_ConsumableUtil.cancelUtil('', '', (List<Object>)conItemTableList, (List<Object>)conItemTableList, (List<Object>)conItemTableList, '', '', '');
           
            if (returnMap.get('resultStat') == 'SUCCESS') {
                System.debug('취소 재고조회 성공' + returnMap);
            }
            returnMap.put('resultStat', returnMap.get('resultStat'));
            returnMap.put('resultMessage', returnMap.get('resultMessage'));
        }

        // if(orderIdSet.size() > 0){
            // List<ProductRequestLineItem> deleteOrderList = [SELECT CANCEL_Date__c, Consumables_Order_Status__c, CANCEL_Quantity__c, QuantityRequested, CANCEL_UserId__c, CANCEL_User__c, CANCEL_Reason__c FROM ProductRequestLineItem WHERE ParentId IN: orderIdSet];
            
            // for (ProductRequestLineItem dPrli : deleteOrderList) {
                // dPrli.Consumables_Order_Status__c = '004';
                // dPrli.CANCEL_Quantity__c = dPrli.QuantityRequested;
                // dprli.CANCEL_UserId__c = UserInfo.getUserId();
                // dprli.CANCEL_User__c = UserInfo.getName();
                // dprli.CANCEL_Reason__c = '주문 생성 취소';
                // dprli.CANCEL_Date__c = Date.today();
            // }
            // update deleteOrderList;
        // }

        returnMap.put('status', 's');
        returnMap.put('message', '주문 취소 성공');
        return returnMap;
    }

    @AuraEnabled
    public static User doGetEmpInfo() {
        User currentUser = EX_ConsumableService.doGetManagerInfo();
        // permissonId = [
        // SELECT PermissionSetId ,AssigneeId,Assignee.name
        // FROM PermissionSetAssignment
        // WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.label = '자재관리자'
        // ];
        // serviceResource
        return currentUser;
    }

    @AuraEnabled
    public static Map<String, Object> getOrderData(List<String> listProdItems, String modelId, String locationId) {
        List<ProductItem> listProductItems = new List<ProductItem>();
        Id parentLocationId = [SELECT Id FROM Location WHERE DEPT_CODE__c = 'PH8002' AND LocationType = 'Site'].Id;
        listProductItems = new List<ProductItem>([
                SELECT Id, LocationId, Location.Name, QuantityOnHand, ProductName, DIV_CODE__c, Product2Id
                        , Product2.Name
                        , Product2.ProductCode
                        , Product2.PART_SPEC__c
                        , Product2.MODEL_CODE__c
                        , Product2.CUST_PRICE__c
                        , Product2.ASC_PRICE__c
                        , Product2.TECH_GRADE_PROD_CODE__c
                        , Product2.TECH_PART_YN__c
                        , Product2.DisplayUrl
                        , Product2.Description
                FROM  ProductItem
                WHERE Id in :listProdItems
                AND (
                        Location.ParentLocationId__c =: locationId
                        OR Location.ParentLocationId__c =: parentLocationId
                    )
                AND Location.LocationType = 'Warehouse'
        ]);

        // strQuery += '         ) ';
        // strQuery += '        , ( ';
        // strQuery += '              SELECT Id, Name, toLabel(SUBSTITUTE_TYPE__c), SUBSTITUTE_PART_NO__c ';
        // strQuery += '                FROM SM_SUBSTITUTE_PART_Product_PART__r ';
        // strQuery += '           ) ';
        // strQuery += '    FROM  Product2 ';
        // strQuery += '   WHERE  Id = :modelId ';

        // system.debug('strQuery :: ' +strQuery);
        // listProductItems = Database.query(strQuery);

        Map<String, Object> mapReturn = new Map<String, Object>{
                'listProductItems' => listProductItems
        };
        return mapReturn;
    }

    @AuraEnabled
    public static Map<String, Object> getInitData(String params) {
        return EX_SearchPartsController.getInitData(params);
    }

    @AuraEnabled
    public static Decimal getMinimumCost() {
        Decimal cost = EX_ConsumableService.doGetConsumableParcelFeeLimit();
        return cost;
    }

    @AuraEnabled
    public static Decimal getMaximumAmount() {
        Decimal amount = EX_ConsumableService.doGetConsumableAmountLimit();
        return amount;
    }

    /**
     * @description 소모품 주문 임시 저장
     * @author 22.12.20 / I2MAX.SEOKHOLEE
     * @return ''
     */
    @AuraEnabled
    public static Map<String, Object> doTemporarySaveConsumableOrder(Map<String, Object> paramMap) {
        System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveTemporaryOrder (start):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        //Map<String, Object> rtnMap = doSaveConsumableOrder(paramMap);
        Map<String, Object> rtnMap = doSaveTemporaryOrder(paramMap);
        System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveTemporaryOrder (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        rtnMap.put('isSuccess', true);
        return rtnMap;
    }

    @AuraEnabled
    public static Map<String, Object> doSaveTemporaryOrder (Map<String, Object> paramMap){
        Map<String, Object> returnMap = new Map<String, Object>();
        try{
            String checkNo = (String) paramMap.get('IbCallNo');
            CM_CommonUtil cmUtil = new CM_CommonUtil();
            String checkTelNoValidMessage = cmUtil.checkValidTelNo(checkNo);
            if(!String.isEmpty(checkTelNoValidMessage)) {
                // 전화번호가 유호 하지 않는 경우 처리 케이스.
                returnMap.put('isPhoneVal' , checkTelNoValidMessage);
                return returnMap;
            }
        } catch (Exception e){
            System.debug(e.getLineNumber() + ' Line || ' + e.getMessage());
            throw new AuraHandledException(e.getLineNumber() + ' Line || ' + e.getMessage());
        }

        // 주문채널
        String orderChannelType = paramMap.containsKey('orderChannelType') ? (String) paramMap.get('orderChannelType') : 'V';
        
        Boolean isContactSame = (Boolean) paramMap.get('isContactSame');
        String strCaseId = (String) paramMap.get('strCaseId');
        String contactId = (String) paramMap.get('contactId');
        String consigneeName = (String) paramMap.get('consigneeName');
        String IbCallNo = (String) paramMap.get('IbCallNo');
        String newAddress = (String) paramMap.get('newAddress');
        String detailAddress = (String) paramMap.get('detailAddress');

        System.debug(' strCaseId ?? ' + strCaseId);
        if (strCaseId != '' && strCaseId != null) {
            Case getCaseCon = [SELECT ContactId, Contact.MobilePhone, Contact.Name, Contact.ADDRESS_NEW__c, Contact.ADDRESS_DETAIL__c  FROM Case WHERE Id = : strCaseId];
            contactId = getCaseCon.ContactId;
            if (isContactSame) {
                consigneeName = getCaseCon.Contact.Name;
                IbCallNo = getCaseCon.Contact.MobilePhone;
                newAddress = getCaseCon.Contact.ADDRESS_NEW__c;
                detailAddress = getCaseCon.Contact.ADDRESS_DETAIL__c;
            }
        }

        System.debug(' contactId ?? ' + contactId);

        String requestedTerm = (String) paramMap.get('requestedTerm');
        String remark = (String) paramMap.get('remark');
        String zoneCode = (String) paramMap.get('zoneCode');
        String discountType = (String) paramMap.get('discountType');
        Decimal ContactVIP = (paramMap.get('ContactVIP') != null ? (Decimal) paramMap.get('ContactVIP') : 0);

        Boolean isManagement = (Boolean) paramMap.get('isManagement') != null ? (Boolean) paramMap.get('isManagement') : false;

        String managerNote = (String) paramMap.get('managerNote');

        // 품절 예약 선결제 여부
        Boolean isBeforePaymentYN = paramMap.containsKey('isBeforePaymentYN') ? (Boolean) paramMap.get('isBeforePaymentYN') : false;

        // 임시 저장 여부
        // 23.05.01 / todo 기존의 임시저장 여부로 사용하던 isTemporary 명을 변경

        Boolean isTemporary = paramMap.containsKey('isTemporary') ? (Boolean) paramMap.get('isTemporary') : false;
        Boolean isExchangeOrder = paramMap.containsKey('isExchangeOrder') ? (Boolean) paramMap.get('isExchangeOrder') : false;

        String stdConsumableOrderId = paramMap.containsKey('stdConsumableOrderId') ? (String) paramMap.get('stdConsumableOrderId') : null;
        String soldOutConsumableOrderId = paramMap.containsKey('soldOutConsumableOrderId') ? (String) paramMap.get('soldOutConsumableOrderId') : null;
        String poId = paramMap.containsKey('poId') ? (String) paramMap.get('poId') : null;
        Decimal stdOrderTotalPaymentAmount = paramMap.containsKey('stdOrderTotalPaymentAmount') ? (Decimal) paramMap.get('stdOrderTotalPaymentAmount') : 0;
        Decimal soldOutOrderTotalPaymentAmount = paramMap.containsKey('soldOutOrderTotalPaymentAmount') ? (Decimal) paramMap.get('soldOutOrderTotalPaymentAmount') : 0;

        Decimal stdOrderTotalSalesAmount = paramMap.containsKey('stdOrderTotalSalesAmount') ? (Decimal) paramMap.get('stdOrderTotalSalesAmount') : 0;
        Decimal soldOutOrderTotalSalesAmount = paramMap.containsKey('soldOutOrderTotalSalesAmount') ? (Decimal) paramMap.get('soldOutOrderTotalSalesAmount') : 0;


        Decimal stdOrderTotalDiscountAmount = paramMap.get('stdOrderTotalDiscountAmount') != null ? (Decimal) paramMap.get('stdOrderTotalDiscountAmount') : 0;
        Decimal soldOutOrderTotalDiscountAmount = paramMap.get('soldOutOrderTotalDiscountAmount') != null ? (Decimal) paramMap.get('soldOutOrderTotalDiscountAmount') : 0;

        // 주문전 재고가 감소해 일반이 품절로 변경된 경우
        Boolean isOrderChange = false;


        // 교환 주문 고객정보
        String customerName = paramMap.containsKey('customerName') ? (String) paramMap.get('customerName') : null;
        String customerPhone = paramMap.containsKey('customerPhone') ? (String) paramMap.get('customerPhone') : null;
        String customerPhone2 = paramMap.containsKey('customerPhone2') ? (String) paramMap.get('customerPhone2') : null;
        String customerAddress = paramMap.containsKey('customerAddress') ? (String) paramMap.get('customerAddress') : null;
        String customerDetailAddress = paramMap.containsKey('customerDetailAddress') ? (String) paramMap.get('customerDetailAddress') : null;
        String customerPostalCode = paramMap.containsKey('customerPostalCode') ? (String) paramMap.get('customerPostalCode') : null;

        System.debug('contactId -> ' + contactId);
        List<ItemTable> standardOrderDataList = (List<ItemTable>) JSON.deserialize((String) paramMap.get('standardOrderData'), List<ItemTable>.class);
        List<ItemTable> soldOutOrderDataList = (List<ItemTable>) JSON.deserialize((String) paramMap.get('soldOutOrderData'), List<ItemTable>.class);
        Map<String, Object> parentMap = new Map<String, Object>(); // 일반 -- 품절일 경우
        
        Set<String> sLocationIdSet = new Set<String>();
        Set<String> sProductIdSet = new Set<String>();

        // 5.8 BASIS Order_INFO 추가
        Set<String> kBasisOrderIdSet = new Set<String>();

        if (isTemporary) {
            if (isManagement == false) {
                System.debug('soldOutOrderDataList : ' + soldOutOrderDataList);
                Map<String, Object> checkMap = EX_ConsumableUtil.reCheckAvailableQty(standardOrderDataList, soldOutOrderDataList);
                System.debug('((List<ItemTable>)checkMap.get(\'soldOutOrderDataList\')) : ' + ((List<ItemTable>) checkMap.get('soldOutOrderDataList')));
                if (((List<ItemTable>) checkMap.get('soldOutOrderDataList')).equals(soldOutOrderDataList) == false) {
                    isOrderChange = true;
                }
                standardOrderDataList = (List<ItemTable>) checkMap.get('standardOrderDataList');
                soldOutOrderDataList = (List<ItemTable>) checkMap.get('soldOutOrderDataList');
                stdOrderTotalPaymentAmount = (Decimal) checkMap.get('stdOrderTotalPaymentAmount');
                soldOutOrderTotalPaymentAmount = (Decimal) checkMap.get('soldOutOrderTotalPaymentAmount');
                parentMap = (Map<String, Object>) checkMap.get('parentMap');
                System.debug('parentMap :::: ' + parentMap);
            }
            System.debug('stdOrderTotalSalesAmount :' + stdOrderTotalSalesAmount);
            System.debug('soldOutOrderTotalSalesAmount :' + soldOutOrderTotalSalesAmount);

            for (ItemTable item : standardOrderDataList) {
                if (item.PromotionPrice == null) {
                    item.PromotionPrice = 0;
                }
                if (((item.PromotionPrice < item.Price * ContactVIP && item.PromotionPrice != 0) || (ContactVIP == 0 && item.PromotionPrice != 0))) {
                    item.DiscountAmount = (Integer) (item.Price * item.QTY - item.PromotionPrice * item.QTY);
                } else {
                    item.DiscountAmount = (Integer) (item.Price * ContactVIP * item.QTY);
                }
                sLocationIdSet.add(item.sLocationId);
                sProductIdSet.add(item.sProductId);
                kBasisOrderIdSet.add(item.productRequestLineItemId);
                stdOrderTotalDiscountAmount += item.DiscountAmount != null ? item.DiscountAmount : 0;
            }
            for (ItemTable item : soldOutOrderDataList) {
                if (item.PromotionPrice == null) {
                    item.PromotionPrice = 0;
                }
                if (((item.PromotionPrice < item.Price * ContactVIP && item.PromotionPrice != 0) || (ContactVIP == 0 && item.PromotionPrice != 0))) {
                    item.DiscountAmount = (Integer) (item.Price * item.QTY - item.PromotionPrice * item.QTY);
                } else {
                    item.DiscountAmount = (Integer) (item.Price * ContactVIP * item.QTY);
                }
                sLocationIdSet.add(item.sLocationId);
                sProductIdSet.add(item.sProductId);
                kBasisOrderIdSet.add(item.productRequestLineItemId);
                soldOutOrderTotalDiscountAmount += item.DiscountAmount != null ? item.DiscountAmount : 0;
                soldOutOrderTotalSalesAmount += item.Price * item.QTY;
            }
        }       
        
        Map<String, String> sProductItemMap = new Map<String, String>();
        Map<String, Decimal> kBasisOrderIdOrderSeqMap = new Map<String, Decimal>();
        
        List<ProductRequestLineItem> basisPrLiList = [SELECT Id, Order_SEQ__c FROM ProductRequestLineItem WHERE Id = :kBasisOrderIdSet];
        for (ProductRequestLineItem prLi : basisPrLiList) {
            if (!kBasisOrderIdOrderSeqMap.containsKey(prLi.Id)) {
                kBasisOrderIdOrderSeqMap.put(prLi.Id, prLi.Order_SEQ__c);
            }
        }

        List<ProductItem> prItemList = [SELECT Id, LocationId, Product2Id, DEPT_CODE__c, ALLOC_QTY__c FROM ProductItem WHERE LocationId IN :sLocationIdSet AND Product2Id IN :sProductIdSet];

        for (ProductItem prItem : prItemList) {
            sProductItemMap.put(prItem.LocationId + '^' + prItem.Product2Id, prItem.Id);
        }
           
        String mapString = '';
        for (Integer i = 0; i < standardOrderDataList.size(); i++) {
            mapString = standardOrderDataList.get(i).sLocationId + '^' + standardOrderDataList.get(i).sProductId;
            if (sProductItemMap.containsKey(mapString)) {
                standardOrderDataList.get(i).sProductItemId = sProductItemMap.get(mapString);
            }
        }
        for (Integer i = 0; i < soldOutOrderDataList.size(); i++) {
            mapString = soldOutOrderDataList.get(i).sLocationId + '^' + soldOutOrderDataList.get(i).sProductId;
            if (sProductItemMap.containsKey(mapString)) {
                soldOutOrderDataList.get(i).sProductItemId = sProductItemMap.get(mapString);
            }
        }

        // 23.03.04 교환 주문 에서의 교환 주문 여부
        String basisOrderNumber = (String) paramMap.get('basisOrderNumber');

        String chkEmployeeName = (String) paramMap.get('chkEmployeeName') != null ? (String) paramMap.get('chkEmployeeName') : '';
        String chkEmployeeNum = (String) paramMap.get('chkEmployeeNum') != null ? (String) paramMap.get('chkEmployeeNum') : '';
        String chkCompanyName = (String) paramMap.get('chkCompanyName') != null ? (String) paramMap.get('chkCompanyName') : '';
        String chkEmployeeRelationShip = (String) paramMap.get('chkEmployeeRelationShip') != null ? (String) paramMap.get('chkEmployeeRelationShip') : '';

        if (chkCompanyName != '') {
            SM_Code__c companyList = [SELECT Id, ATTRIBUTE1__c, CODE_NAME__c From SM_Code__c WHERE Id = :chkCompanyName LIMIT 1];
            chkCompanyName = companyList.ATTRIBUTE1__c;
        }
        Set<String> consumableOrderSetId = new Set<String>();
        if (stdConsumableOrderId != null) consumableOrderSetId.add(stdConsumableOrderId);
        if (soldOutConsumableOrderId != null) consumableOrderSetId.add(soldOutConsumableOrderId);
        List<ProductRequest> prList = [SELECT Order_Number__c, Id FROM ProductRequest WHERE Id = :consumableOrderSetId];
        Map<String, Id> stdOrderNumberMap = new Map<String, Id>();
        Map<String, Id> soldOutOrderNumberMap = new Map<String, Id>();
        for (ProductRequest pr : prList) {
            if (stdConsumableOrderId == pr.Id) stdOrderNumberMap.put(pr.Order_Number__c, pr.Id);
            if (soldOutConsumableOrderId == pr.Id) soldOutOrderNumberMap.put(pr.Order_Number__c, pr.Id);
        }
        // 23.02.20 서브번호 채번 추가
        List<SObject> lineItemList = new List<SObject>();

        // 소모품센터 SM_DEPT
        SM_DEPT__c consumableCenter = [
                SELECT Id, Name, DEPT_CODE__c
                FROM   SM_DEPT__c
                WHERE  DEPT_CODE__c = 'PH8002'
                LIMIT  1
        ];
        
        String consumableSiteId = EX_ConsumableUtil.getConsumableSiteId();
        String consumableWareHouseId = EX_ConsumableUtil.getConsumableWareHouseId();
        Contact orderContact;
        
        orderContact = [
                SELECT Id, Name, fm_ADDRESS_NEW__c, Phone, MobilePhone, POSTAL_CODE__c, ADDRESS_DETAIL__c, ADDRESS_NEW__c, AccountId, Account.AR_CODE__c, Account.BEST_AR_CODE__c, LastName, ADDRESS_ROAD_ETC__c,
                        fm_ADDRESS_OLD__c, Address_OLD__c
                FROM   Contact
                WHERE  Id =: contactId
                LIMIT  1
        ];

        // 2024.01.02 seung yoon heo ServiceResource >> User의 DEPT_CODE로 변경
        // 생성한 유저의 소속 조직 코드
        // List<ServiceResource> objSR = [
        //         SELECT Id, Name, SM_DEPT__c, SM_DEPT__r.DEPT_CODE__c, SM_DEPT__r.DEPT_TYPE_SECOND__c, SM_DEPT__r.HIGH_DEPT_CODE__c, SM_DEPT__r.HIGH_DEPT_CODE__r.DEPT_CODE__c, fm_DEPT_CODE__c
        //         FROM   ServiceResource
        //         WHERE  RelatedRecordId =: Userinfo.getUserId()
        // ];

        User currentUser = EX_ConsumableService.doGetManagerInfo();

        String deptCode = '';
        // String deptId = '';
        
        // if (!currentUser.isEmpty()) {
        deptCode = currentUser.DEPT_CODE__c;
            
        //      deptId = objSR[0].SM_DEPT__r.HIGH_DEPT_CODE__r.Id;
        // } 
        // else {
        //     List<SM_BIZ_MANAGER__c> bizManager = [
        //             SELECT DEPT_CODE__r.HIGH_DEPT_CODE__r.Id
        //             FROM   SM_BIZ_MANAGER__c
        //             WHERE  MANAGER_ID__c =: currentUser.EmployeeNumber__c 
        //             AND    BIZ_MANAGER_TYPE__c =: '46'
        //     ];

        //     if (!bizManager.isEmpty()) {
        //         deptCode = currentUser.DEPT_CODE__c;
        //         deptId = bizManager[0].DEPT_CODE__r.HIGH_DEPT_CODE__r.Id;
        //     }
        // }


        // Map<String, Object> userInfoMap = EX_ConsumableUtil.getUserInfo(UserInfo.getUserId());
        Map<String, Object> userInfoMap = EX_ConsumableUtil.getDeptInfo(deptCode);
        
        Map<String, ProductRequest> consumableOrderMap = new Map<String, ProductRequest>();
        ProductRequest PO_ConsumableOrder;

        try {
            // 일반 주문 품목이 존재 할 때
            if (standardOrderDataList.size() > 0) {
                ProductRequest stdConsumableOrder;
                system.debug('isTemporary :::: '+ isTemporary);
                system.debug('isExchangeOrder :::: '+ isExchangeOrder);
                system.debug('stdConsumableOrderId :::: '+stdConsumableOrderId);
                system.debug('standardOrderDataList :::: '+standardOrderDataList);
                Datetime orderDate;
                
                stdConsumableOrder = new ProductRequest();

                system.debug('stdConsumableOrder :::: '+stdConsumableOrder);

                // todo : 소모품 레코드 타입 추가 필요
                stdConsumableOrder.RecordTypeId = EX_ConsumableUtil.PR_CONSUMABLE_RECORDTYPE_ID;
                // 주문 고객 Contact Id
                stdConsumableOrder.Order_CUST_Id__c = contactId;
                // 소모품 주문 여부
                stdConsumableOrder.Consumables_Order_YN__c = true;
                // 소모품 주문 구분 /  일반 주문 : General, 품절 주문 : Sold Out
                
                stdConsumableOrder.Consumables_Order_Class_Code__c = 'General';
                // 소모품 업무 유형
                // 주문 : Order, 주문취소 : Cancel
                // 반품 : Return, 교환반품 : ExchangeReturn, 교환주문 : ExchangeOrder
                // PO(요청) : PO

                //현금입금여부
                stdConsumableOrder.CASH_DEPOSIT_YN__c = 'B';
                // 주문 일 때
                if (!isExchangeOrder) {
                    stdConsumableOrder.Consumables_Business_Type_Code__c = 'Order';
                } else {
                    // 교환 주문 일 때
                    stdConsumableOrder.Consumables_Business_Type_Code__c = 'ExchangeOrder';

                }


                // 주문 채널
                // 대표 사이트 : B, ThinQ : S, CIC소모품택배 : V, New BEST : New BEST
                stdConsumableOrder.Order_CHNL_TYPE_Code__c = orderChannelType;

                if (isTemporary) {
                    // 관리자 메모
                    stdConsumableOrder.Description = managerNote != null ? managerNote : null;

                    Datetime target = Datetime.newInstance(
                            Date.today().addDays(1),
                            Time.newInstance(23, 59, 0, 0)
                    );
                    stdConsumableOrder.LIMIT_TM__c = target;
                    stdConsumableOrder.SALE_Amount__c = stdOrderTotalPaymentAmount;
                    stdConsumableOrder.PAYMENT_Amount__c = stdOrderTotalPaymentAmount - stdOrderTotalDiscountAmount;
                    stdConsumableOrder.Discount_Amount__c = stdOrderTotalDiscountAmount;
                }

                EX_Message__c message = new EX_Message__c();
                ProductRequest pr = new ProductRequest();
                
                if (stdConsumableOrderId != null) {
                    pr = [SELECT PAYMENT_TYPE__c FROM ProductRequest WHERE Id =: stdConsumableOrderId limit 1];
                }
                
                // 고객 명
                stdConsumableOrder.Order_CUST_Name__c = orderContact.Name != null ? orderContact.Name : orderContact.LastName;
                // 고객 전화번호1
                stdConsumableOrder.Order_CUST_TPNO_1__c = orderContact.MobilePhone;
                // 고객 전화번호2
                stdConsumableOrder.Order_CUST_TPNO_2__c = orderContact.Phone;
                // 고객 주소
                stdConsumableOrder.Order_CUST_Address__c = orderContact.ADDRESS_NEW__c != null ? orderContact.ADDRESS_NEW__c : orderContact.ADDRESS_OLD__c;
                // 고객 상세 주소
                // stdConsumableOrder.Order_CUST_Address_DETAIL__c = orderContact.ADDRESS_DETAIL__c;
                stdConsumableOrder.Order_CUST_Address_DETAIL__c = orderContact.ADDRESS_NEW__c != null ? orderContact.ADDRESS_ROAD_ETC__c : orderContact.ADDRESS_DETAIL__c; //24 02 01 hyungho.chun 상세주소 신주소일시 불러오는 필드 다름
                stdConsumableOrder.Delivery_Message_CONTENT__c = requestedTerm;
                // 고객 우편번호
                stdConsumableOrder.Order_CUST_PostalCode__c = orderContact.POSTAL_CODE__c;

                System.debug('##############');
                System.debug(LoggingLevel.ERROR, 'isContactSame -> ' + isContactSame);
                System.debug('stdConsumableOrder.Order_CUST_PostalCode__ -> ' + stdConsumableOrder.Order_CUST_PostalCode__c);
                System.debug('##############');

                // 수취인 주소
                if (!isContactSame) {
                    // 수취인 명
                    stdConsumableOrder.CONSIGNEE_Name__c = consigneeName;
                    // 수취인 전화번호1
                    stdConsumableOrder.CONSIGNEE_TPNO_1__c = IbCallNo;
                    // 수취인 전화번호2
                    stdConsumableOrder.CONSIGNEE_TPNO_2__c = IbCallNo;
                    // 수취인 주소
                    //stdConsumableOrder.CONSIGNEE_Address__c = newAddress + ' ' + detailAddress;
                    stdConsumableOrder.CONSIGNEE_Address__c = newAddress;
                    // 수취인 상세 주소
                    //24.01.31 gw.lee 수취인 상세주소 null체크 변경
                    stdConsumableOrder.CONSIGNEE_Address_DETAIL__c = String.isEmpty(detailAddress) ? '( )' : detailAddress;

                    stdConsumableOrder.Delivery_Message_CONTENT__c = requestedTerm;
                    // if(isExchangeOrder) {
                    //     stdConsumableOrder.CONSIGNEE_PostalCode__c = orderContact.POSTAL_CODE__c;
                    // } else {
                    //     stdConsumableOrder.CONSIGNEE_PostalCode__c = zoneCode;
                    // }
                    //2024.02.01 seung yoon heo 교환
                    stdConsumableOrder.CONSIGNEE_PostalCode__c = zoneCode;
                } 
                else {
                    // 수취인 명
                    stdConsumableOrder.CONSIGNEE_Name__c = orderContact.Name != null ? orderContact.Name : orderContact.LastName;
                    // 수취인 전화번호1
                    stdConsumableOrder.CONSIGNEE_TPNO_1__c = orderContact.MobilePhone;
                    // 수취인 전화번호2
                    stdConsumableOrder.CONSIGNEE_TPNO_2__c = orderContact.Phone;
                    // 수취인 주소
                    //24.01.31 gw.lee 수취인 상세주소 null체크 변경
                    stdConsumableOrder.CONSIGNEE_Address__c = orderContact.ADDRESS_NEW__c != null ? orderContact.ADDRESS_NEW__c : orderContact.ADDRESS_OLD__c;
                    stdConsumableOrder.CONSIGNEE_Address_DETAIL__c = orderContact.ADDRESS_NEW__c != null ? (String.isEmpty(orderContact.ADDRESS_ROAD_ETC__c) ? '( )' : orderContact.ADDRESS_ROAD_ETC__c ) : (String.isEmpty(orderContact.ADDRESS_DETAIL__c) ? '( )' : orderContact.ADDRESS_DETAIL__c); //24 02 01 hyungho.chun 상세주소 신주소일시 불러오는 필드 다름
                    stdConsumableOrder.Delivery_Message_CONTENT__c = requestedTerm;
                    // 우편번호
                    stdConsumableOrder.CONSIGNEE_PostalCode__c = stdConsumableOrder.Order_CUST_PostalCode__c;
                }

                // 수취인 우편번호. zoneCode 인입 시
                // 고객=수취인 -> Contact.POSTAL_CODE__c
                // 고객!=수취인 -> 주소검색 시 인입 된 우편번호 설정 되어있음
                // 일반주문 ProductRequest에 CaseId 추가
                System.debug('isManagement@@@@@@ ' + isManagement);
                if(isManagement == false) {
                    if (strCaseId != '') {
                        stdConsumableOrder.CaseId = strCaseId;
                        System.debug('case Id Set 확인 : ' + stdConsumableOrder.CaseId);
                    }
                }

                // 소모품 주문 실제 사용 여부
                stdConsumableOrder.Consumables_Order_USE_YN__c = isTemporary ? false : true;
                // 판매 금액

                // 23.04.11 추가
                // 상담부서 코드
                // 상담부서 Id
                if (userInfoMap.containsKey('DEPT')) {
                    SM_DEPT__c dept = (SM_DEPT__c) userInfoMap.get('DEPT');
                    stdConsumableOrder.CNSL_Department_Id__c = dept.Id;
                    stdConsumableOrder.CNSL_Department_Code__c = dept.DEPT_CODE__c;
                }

                // 주문 일시
                system.debug('stdConsumableOrder.Order_Date__c   : ' + stdConsumableOrder.Order_Date__c);
                //23 07 17 hyungho.chun 업데이트시 기존 orderDate 값 추가
                stdConsumableOrder.Order_Date__c = orderDate;
                if (stdConsumableOrder.Order_Date__c == null) {
                    stdConsumableOrder.Order_Date__c = System.now();
                }
                
                consumableOrderMap.put(STANDARD_ORDER, stdConsumableOrder);
            }

            // 품절 주문 품목이 존재 할 때
            if (soldOutOrderDataList.size() > 0) {
                ProductRequest soldOutConsumableOrder;
                Datetime orderDate;
                
                soldOutConsumableOrder = new ProductRequest();

                // todo : 소모품 레코드 타입 추가 필요
                soldOutConsumableOrder.RecordTypeId = EX_ConsumableUtil.PR_CONSUMABLE_RECORDTYPE_ID;
                
                // 23.04.11 추가
                // 상담부서 코드
                // 상담부서 Id
                if (userInfoMap.containsKey('DEPT')) {
                    SM_DEPT__c dept = (SM_DEPT__c) userInfoMap.get('DEPT');
                    soldOutConsumableOrder.CNSL_Department_Id__c = dept.Id;
                    soldOutConsumableOrder.CNSL_Department_Code__c = dept.DEPT_CODE__c;
                }

                // 주문 일시
                //23 07 17 hyungho.chun 업데이트시 기존 orderDate 값 추가
                soldOutConsumableOrder.Order_Date__c = orderDate;
                if (soldOutConsumableOrder.Order_Date__c == null) {
                    soldOutConsumableOrder.Order_Date__c = System.now();
                }

                // 주문 고객 Contact Id
                soldOutConsumableOrder.Order_CUST_Id__c = contactId;
                // 고객 우편번호
                soldOutConsumableOrder.Order_CUST_PostalCode__c = orderContact.POSTAL_CODE__c;
                // 소모품 주문 여부
                soldOutConsumableOrder.Consumables_Order_YN__c = true;
                // 소모품 주문 구분 /  일반 주문 : General, 품절 주문 : Sold Out
                soldOutConsumableOrder.Consumables_Order_Class_Code__c = 'Sold Out';

                soldOutConsumableOrder.CONSIGNEE_PostalCode__c = zoneCode == null ? null : zoneCode;

                // 소모품 업무 유형
                // 주문 : Order, 주문취소 : Cancel
                // 반품 : Return, 교환반품 : ExchangeReturn, 교환주문 : ExchangeOrder
                // PO(요청) : PO

                // 주문 채널
                // 대표 사이트 : B, ThinQ : S, CIC소모품택배 : V, New BEST : New BEST
                soldOutConsumableOrder.Order_CHNL_TYPE_Code__c = orderChannelType;

                if (!isExchangeOrder) {
                    soldOutConsumableOrder.Consumables_Business_Type_Code__c = 'Order';
                }
                // 고객 명
                soldOutConsumableOrder.Order_CUST_Name__c = orderContact.Name != null ? orderContact.Name : orderContact.LastName;
                // 고객 전화번호1
                soldOutConsumableOrder.Order_CUST_TPNO_1__c = orderContact.MobilePhone;
                // 고객 전화번호2
                soldOutConsumableOrder.Order_CUST_TPNO_2__c = orderContact.Phone;
                // 고객 주소
                soldOutConsumableOrder.Order_CUST_Address__c = orderContact.ADDRESS_NEW__c != null ? orderContact.ADDRESS_NEW__c : orderContact.ADDRESS_OLD__c;
                // 고객 상세 주소
                // soldOutConsumableOrder.Order_CUST_Address_DETAIL__c = orderContact.ADDRESS_DETAIL__c;
                soldOutConsumableOrder.Order_CUST_Address_DETAIL__c = orderContact.ADDRESS_NEW__c != null ? orderContact.ADDRESS_ROAD_ETC__c : orderContact.ADDRESS_DETAIL__c; //24 02 01 hyungho.chun 상세주소 신주소일시 불러오는 필드 다름
                
                soldOutConsumableOrder.Delivery_Message_CONTENT__c = requestedTerm;

                // 수취인 주소
                if (!isContactSame) {
                    // 수취인 명
                    soldOutConsumableOrder.CONSIGNEE_Name__c = consigneeName;
                    // 수취인 전화번호1
                    soldOutConsumableOrder.CONSIGNEE_TPNO_1__c = IbCallNo;
                    // 수취인 전화번호2
                    soldOutConsumableOrder.CONSIGNEE_TPNO_2__c = IbCallNo;

                    // 수취인 주소
                    //soldOutConsumableOrder.CONSIGNEE_Address__c = newAddress + ' ' + detailAddress;
                    soldOutConsumableOrder.CONSIGNEE_Address__c = newAddress;
                    // 수취인 상세 주소
                    soldOutConsumableOrder.CONSIGNEE_Address_DETAIL__c = String.isEmpty(detailAddress) ? '( )' : detailAddress;
                    soldOutConsumableOrder.Delivery_Message_CONTENT__c = requestedTerm;
                } 
                else {
                    // 수취인 명
                    soldOutConsumableOrder.CONSIGNEE_Name__c = orderContact.Name != null ? orderContact.Name : orderContact.LastName;
                    // 수취인 전화번호1
                    soldOutConsumableOrder.CONSIGNEE_TPNO_1__c = orderContact.MobilePhone;
                    // 수취인 전화번호2
                    soldOutConsumableOrder.CONSIGNEE_TPNO_2__c = orderContact.Phone;
                    // 수취인 주소
                    soldOutConsumableOrder.CONSIGNEE_Address__c = orderContact.ADDRESS_NEW__c != null ? orderContact.ADDRESS_NEW__c : orderContact.ADDRESS_OLD__c;
                    // soldOutConsumableOrder.CONSIGNEE_Address_DETAIL__c = String.isEmpty(orderContact.ADDRESS_DETAIL__c) ? '( )' : orderContact.ADDRESS_DETAIL__c;
                    soldOutConsumableOrder.CONSIGNEE_Address_DETAIL__c = orderContact.ADDRESS_NEW__c != null ? (String.isEmpty(orderContact.ADDRESS_ROAD_ETC__c) ? '( )' : orderContact.ADDRESS_ROAD_ETC__c ) : (String.isEmpty(orderContact.ADDRESS_DETAIL__c) ? '( )' : orderContact.ADDRESS_DETAIL__c); //24 02 01 hyungho.chun 상세주소 신주소일시 불러오는 필드 다름

                    soldOutConsumableOrder.Delivery_Message_CONTENT__c = requestedTerm;
                }

                // 수취인 우편번호. zoneCode 인입 시
                // 고객=수취인 -> Contact.POSTAL_CODE__c
                // 고객!=수취인 -> 주소검색 시 인입 된 우편번호 설정 되어있음
                soldOutConsumableOrder.CONSIGNEE_PostalCode__c = zoneCode;

                // 품절주문 ProductRequest에 CaseId 추가
                System.debug('isManagement@@@@@@' + isManagement);
                if(!isManagement) {
                    if (strCaseId != '') {
                        soldOutConsumableOrder.CaseId = strCaseId;
                        System.debug('soldOutConsumableOrder Case Id Set 확인 : ' + soldOutConsumableOrder.CaseId);
                    }
                }

                // 소모품 주문 실제 사용 여부
                soldOutConsumableOrder.Consumables_Order_USE_YN__c = isTemporary ? false : true;

                // 판매 금액
                soldOutConsumableOrder.SALE_Amount__c = soldOutOrderTotalSalesAmount;
                // 할인 금액
                soldOutConsumableOrder.Discount_Amount__c = soldOutOrderTotalDiscountAmount;
                // 결제 금액
                soldOutConsumableOrder.PAYMENT_Amount__c = soldOutOrderTotalSalesAmount - soldOutOrderTotalDiscountAmount;
                consumableOrderMap.put(SOLD_OUT_ORDER, soldOutConsumableOrder);
            }

            System.debug('consumableOrderMap.get(STANDARD_ORDER) :: ' + consumableOrderMap.get(STANDARD_ORDER));
            System.debug('isTemporary :: ' + isTemporary);
            System.debug('isExchangeOrder :: ' + isExchangeOrder);

            if (consumableOrderMap.get(STANDARD_ORDER) != null && isTemporary == false && !isExchangeOrder) {
                String jsonStr = JSON.serialize(consumableOrderMap.get(STANDARD_ORDER));

                doSetPaymentData(stdOrderNumberMap.keySet(), jsonStr);
            }

            if (isManagement == false) {
                System.debug('consumableOrderMap.values() 값 비교용 :::' + consumableOrderMap.values());
                System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (upsert consumableOrderMap)전:' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                TriggerHandler.bypass('ProductRequest_tr');
                upsert consumableOrderMap.values();
                TriggerHandler.clearBypass('ProductRequest_tr');
                System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (upsert consumableOrderMap)후:' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            }

            /** 2023-05-18 ysh 주문번호 채번 로직 변경 (AutoNumber 이용) */
            List<String> prIdList = new List<String>();
            for (ProductRequest pr : consumableOrderMap.values()) {
                prIdList.add(pr.Id);
            }

            /** 2023-05-20 교환 주문시 타 채널(OBS, ThinQ)의 경우 주문번호 원주문-E1 로 채번 */
            String originProductRequestId = null;
            String originOrderNumber = null;
            
            List<ProductRequest> updatePrList = new List<ProductRequest>();
            Map<String, ProductRequest> afterDMLConsumableOrderMap = new Map<String, ProductRequest>();
            if (!prIdList.isEmpty()) {
                updatePrList = [SELECT Id, Order_Number__c, Consumables_Order_Number__c, Order_CHNL_TYPE_Code__c, Consumables_Order_Class_Code__c, caseId FROM ProductRequest WHERE Id IN: prIdList];
                if (!updatePrList.isEmpty()) {
                    String year = String.valueOf(system.today().year()).right(2);
                    for (ProductRequest upr : updatePrList) {
                        if (upr.Order_CHNL_TYPE_Code__c == EX_ConsumableUtil.CONSUMABLE_CIC) {
                            upr.Order_Number__c = 'O' + year + upr.Consumables_Order_Number__c;
                        }

                        if (upr.Consumables_Order_Class_Code__c == 'General') {
                            afterDMLConsumableOrderMap.put(STANDARD_ORDER, upr);
                        } else if (upr.Consumables_Order_Class_Code__c == 'Sold Out') {
                            afterDMLConsumableOrderMap.put(SOLD_OUT_ORDER, upr);
                        } else if (upr.Consumables_Order_Class_Code__c == PO) {
                            afterDMLConsumableOrderMap.put(PO, upr);
                        }
                        if(isManagement == true && soldOutConsumableOrderId != null){
                            afterDMLConsumableOrderMap.put(SOLD_OUT_ORDER, upr);
                        }
                    }
                    update updatePrList;
                }
            }

            // 일반 주문 품목이 존재 할 때
            ProductRequest stdPr;
            List<ProductRequestLineItem> consumableOrderItems = new List<ProductRequestLineItem>();
            List<ProductRequestLineItem> consumablePOItems = new List<ProductRequestLineItem>();
            boolean paymentYN;

            List<SM_DIV__c> smList = [SELECT Id, DIV_CODE__c FROM SM_DIV__c];
            Map<Id, String> smMap = new Map<Id, String>();
            for (SM_DIV__c item : smList) {
                smMap.put(item.Id, item.DIV_CODE__c);
            }

            System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (standardOrderDataList.size()-' + standardOrderDataList.size() + '):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            if (standardOrderDataList.size() > 0) {
                // 주문 항번
                Integer ORDER_SEQ = 0;
                if(isManagement == true && soldOutConsumableOrderId != null) {
                    System.debug('00000'+afterDMLConsumableOrderMap);
                    stdPr = afterDMLConsumableOrderMap.get(SOLD_OUT_ORDER);
                } 
                else{
                    stdPr = afterDMLConsumableOrderMap.get(STANDARD_ORDER);
                }

                System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (query SR_PRE_PAYMENT_HEADER__c):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                ProductRequestLineItem stdConsumableOrderItem;

                //23.08.10 gw.lee
                //Transaction PMD 간소화
                DateTime deliveryDate = getDeliveryDate();

                for (ItemTable item : standardOrderDataList) {
                    if (isTemporary == false && isExchangeOrder == false) {
                        stdConsumableOrderItem = new ProductRequestLineItem(Id = item.Id);
                        if (item.ResrvNumber != null) {
                            stdConsumableOrderItem.RSRV_Number__c = item.ResrvNumber;
                        }
                        System.debug('예약 : ' + item.ResrvNumber);
                    } 
                    else {
                        stdConsumableOrderItem = new ProductRequestLineItem();
                        // 소모품 주문 Id
                        stdConsumableOrderItem.ParentId = stdPr.Id;
                    }

                    // todo : 소모품 레코드 타입 추가 필요
                    stdConsumableOrderItem.RecordTypeId = EX_ConsumableUtil.PRLI_CONSUMABLE_RECORDTYPE_ID;
                    if (kBasisOrderIdOrderSeqMap.containsKey(item.productRequestLineItemId)) {
                        stdConsumableOrderItem.Order_SEQ__c = kBasisOrderIdOrderSeqMap.get(item.productRequestLineItemId);
                    } 
                    else {
                        stdConsumableOrderItem.Order_SEQ__c = ++ORDER_SEQ;
                    }

                    // ProductRequest LineItem에 ProductRequest의 CaseId 추가
                    if (stdPr.CaseId != null) {
                        stdConsumableOrderItem.CaseId = stdPr.CaseId;
                        System.debug('stdConsumableOrderItem Case Id 확인 : ' + stdConsumableOrderItem.CaseId);
                    }

                    // 소모품 주문 번호
                    stdConsumableOrderItem.Order_Number__c = stdPr.Order_Number__c;

                    // 소모품 주문 여부
                    stdConsumableOrderItem.Consumables_Order_YN__c = true;
                    // 소모품 주문 구분
                    stdConsumableOrderItem.Consumables_Order_Class_Code__c = 'General';
                    stdConsumableOrderItem.Online_SALE_Url__c = item.ObsSalesURL;
                    stdConsumableOrderItem.Online_SALE_YN__c = item.OBS_ITEM_YN == 'Y' ? true : false;
                    // 부서 코드
                    stdConsumableOrderItem.Department_Code__c = 'PH8002';
                    // 소모품 업무 유형
                    if (!isExchangeOrder) {
                        stdConsumableOrderItem.Consumables_Business_Type_Code__c = 'Order';
                    }

                    // 소모품 주문 채널
                    stdConsumableOrderItem.Order_CHNL_TYPE_Code__c = orderChannelType;
                    // 소모품 주문 고객 Contact Id
                    stdConsumableOrderItem.Order_CUST_Id__c = contactId;

                    stdConsumableOrderItem.SourceLocationId = consumableWareHouseId;
                    // 소모품 주문 품목의 사업부 코드
                    stdConsumableOrderItem.ENDP_Code__c = item.DIVCODE;
                    //출고부서코드
                    if (item.ShipmentCode != null) {
                        stdConsumableOrderItem.SHIPPED_Department_Code__c = item.ShipmentCode;
                    }
                    // Product
                    // 소모품 주문 품목의 파트 Id
                    stdConsumableOrderItem.Product2Id = item.sProductId;
                    // 소모품 주문 품목이 재고 Id
                    stdConsumableOrderItem.ProductItem__c = item.sProductItemId;

                    // 소모품 주문 품목의 파트 넘버 요청 Part No
                    stdConsumableOrderItem.BASIS_Parts_Number__c = item.ProductCode;
                    // 소모품 주문 품목의 파트 넘버
                    stdConsumableOrderItem.PART_NO__c = item.ProductCode;

                    // 소모품 주문 품목의 요청 수량
                    stdConsumableOrderItem.QuantityRequested = item.QTY;
                    // 소모품 주문 품목의 판매 수량
                    stdConsumableOrderItem.SALE_Quantity__c = item.QTY;
                    // 소모품 주문 품목의 소비자가
                    stdConsumableOrderItem.CONSUMER_Price__c = item.Price;
                    // 소모품 주문 품목의 지점정가
                    stdConsumableOrderItem.ASC_Price__c = item.ASCPrice;
                    //23.12.04 gw.lee 재경 요청 UnitPrice 필요 //23 12 07 hyungho.chun UnitPrice__c 판매저장때 계산해서넣어줌
                    // stdConsumableOrderItem.UnitPrice__c = item.Price;                    
                    // 주문 생성시 기본 상태 주문요청
                    if(isTemporary){
                        stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_001;
                    }
                    // 소모품 주문 품목의 모델 Id
                    if (item.ModelId != null) {
                        stdConsumableOrderItem.MODEL__c = item.ModelId;
                    }
                    stdConsumableOrderItem.MODEL_Code__c = item.Model; // PHJ 24 02 23

                    // Location
                    // 소모품 주문 품목의 대상 위치 Id
                    //consumableOrderItem.DestinationLocationId = item.sLocationId;
                    // 소모품 주문 품목의 소스 위치 Id
                    if (item.sLocationId != null) {
                        stdConsumableOrderItem.SourceLocationId = consumableWareHouseId;
                    }

                    if (item.PromotionPrice == null) item.PromotionPrice = 0;

                    if (!isExchangeOrder) {
                        // 판매 금액
                        if (ContactVIP != 0) {
                            stdConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;

                            if (item.PromotionPrice != null && item.PromotionPrice != 0) {
                                if (item.Price * item.QTY * ContactVIP < item.PromotionPrice * item.QTY) {
                                    stdConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.Price * item.QTY * ContactVIP;
                                    stdConsumableOrderItem.VIP_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                                    stdConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                                    stdConsumableOrderItem.SALE_Discount_Type_Code__c = 'V';
                                    stdConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;
                                } 
                                else {
                                    stdConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                                    stdConsumableOrderItem.PROMOTION_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                                    stdConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                                    stdConsumableOrderItem.SALE_Discount_Type_Code__c = 'P';
                                    stdConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;
                                }
                            } 
                            else {
                                stdConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.Price * item.QTY * ContactVIP;
                                stdConsumableOrderItem.VIP_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                                stdConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                                stdConsumableOrderItem.SALE_Discount_Type_Code__c = 'V';
                                stdConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;
                            }
                        } 
                        else if (item.PromotionPrice != 0) {
                            stdConsumableOrderItem.PAYMENT_Amount__c = item.PromotionPrice * item.QTY;
                            stdConsumableOrderItem.PROMOTION_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                            stdConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                            stdConsumableOrderItem.SALE_Discount_Type_Code__c = 'P';
                            stdConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;
                        } 
                        else {
                            stdConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY ;
                            stdConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY;
                        }
                        // 결제 금액
                    } 
                    else {
                        // 교환주문 인 경우
                        stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006;
                        stdConsumableOrderItem.Appointment_Status__c = '입고완료';

                        stdConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;
                    }

                    // 소모품 결제 Id
                    //stdConsumableOrderItem.MOID__c = paymentDetail.MOID__c != null ? paymentDetail.MOID__c : '';
                    //stdConsumableOrderItem.TID__c = paymentDetail.TID__c != null ? paymentDetail.TID__c : '';
                    // 소모품 요청자의 소속 부서 코드
                    stdConsumableOrderItem.Requester_Department_Code__c = deptCode;
                    if (item.discountType != null) {
                        if (item.discountType == '임직원') {
                            stdConsumableOrderItem.SALE_Discount_Type_Code__c = 'E';
                            stdConsumableOrderItem.Employees_Discount_Amount__c = item.DiscountAmount;
                            stdConsumableOrderItem.Last_Discount_Amount__c = item.DiscountAmount;
                            stdConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.DiscountAmount;
                        } 
                        else if (item.discountType == 'VIP') {
                            stdConsumableOrderItem.SALE_Discount_Type_Code__c = 'V';
                            stdConsumableOrderItem.VIP_Discount_Amount__c = item.DiscountAmount;
                            stdConsumableOrderItem.Last_Discount_Amount__c = item.DiscountAmount;
                            stdConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.DiscountAmount;
                        } 
                        else if (item.discountType == '프로모션' && item.DiscountAmount != 0) {
                            stdConsumableOrderItem.SALE_Discount_Type_Code__c = 'P';
                            stdConsumableOrderItem.PROMOTION_Discount_Amount__c = item.DiscountAmount;
                            stdConsumableOrderItem.Last_Discount_Amount__c = item.DiscountAmount;
                            stdConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.DiscountAmount;
                        }
                    }

                    if (!isExchangeOrder) {
                        System.debug('123123 '+consumableOrderMap.get(STANDARD_ORDER));
                        if (consumableOrderMap.get(STANDARD_ORDER).PAYMENT_YN__c == true || paymentYN == true) {
                            if (item.ShipmentCode != null) {
                                if (smMap.values().contains(item.ShipmentCode)) {
                                    stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_002;
                                } 
                                else {
                                    stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006;
                                    stdConsumableOrderItem.Appointment_Status__c = '입고완료';
                                }
                            } 
                            else {
                                stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006;
                                stdConsumableOrderItem.Appointment_Status__c = '입고완료';
                            }
                        } 
                        else {
                            if (item.ShipmentCode == 'PH8002') {
                                stdConsumableOrderItem.Appointment_Status__c = '입고완료';
                            }
                        }
                    } 
                    else {
                        if (item.ShipmentCode != null) {
                            if (smMap.values().contains(item.ShipmentCode)) {
                                stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_002;
                            } 
                            else {
                                stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006;
                                stdConsumableOrderItem.Appointment_Status__c = '입고완료';
                            }
                        } 
                        else {
                            stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006;
                            stdConsumableOrderItem.Appointment_Status__c = '입고완료';
                        }
                    }

                    consumableOrderItems.add(stdConsumableOrderItem);

                    // 서브번호 채번을 위해 일반주문 레코드 저장
                    lineItemList.add(stdConsumableOrderItem);
                }
            }

            // 품절 주문 품목이 존재 할 때
            ProductRequest soPr;
            ProductRequest POPr;
            System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (soldOutOrderDataList.size()-' + soldOutOrderDataList.size() + '):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            if (soldOutOrderDataList.size() > 0) {
                soPr = afterDMLConsumableOrderMap.get(SOLD_OUT_ORDER);
                ProductRequestLineItem soConsumableOrderItem;
                ProductRequestLineItem consumablePOItem;

                // 예약 항번
                Integer RSRV_SEQ = 0;
                // 주문 항번
                Integer ORDER_SEQ = 0;
                for (ItemTable item : soldOutOrderDataList) {
                    System.debug('isTemporary -> ' + isTemporary);
                    System.debug('isExchangeOrder -> ' + isExchangeOrder);

                    if (isTemporary == false && isExchangeOrder == false) {
                        soConsumableOrderItem = new ProductRequestLineItem(Id = item.Id);
                    } else {
                        System.debug('soPr ->>>>>>> ' + soPr);
                        soConsumableOrderItem = new ProductRequestLineItem();
                        // 소모품 주문 Id
                        soConsumableOrderItem.ParentId = soPr.Id;
                    }

                    // todo : 소모품 레코드 타입 추가 필요
                    soConsumableOrderItem.RecordTypeId = EX_ConsumableUtil.PRLI_CONSUMABLE_RECORDTYPE_ID;
                    if (kBasisOrderIdOrderSeqMap.containsKey(item.productRequestLineItemId)) {
                        soConsumableOrderItem.Order_SEQ__c = kBasisOrderIdOrderSeqMap.get(item.productRequestLineItemId);
                    } else {
                        soConsumableOrderItem.Order_SEQ__c = ++ORDER_SEQ;
                    }

                    // soConsumableOrderItem.Order_SEQ__c = ++ORDER_SEQ;

                    // ProductRequest LineItem에 ProductRequest의 CaseId 추가
                    if (soPr.CaseId != null) {
                        soConsumableOrderItem.CaseId = soPr.CaseId;
                        System.debug('soConsumableOrderItem.CaseId 확인 : ' + soConsumableOrderItem.CaseId);
                    }

                    // 소모품 주문 번호
                    soConsumableOrderItem.Order_Number__c = soPr.Order_Number__c;

                    // 소모품 주문 여부
                    soConsumableOrderItem.Consumables_Order_YN__c = true;
                    // 소모품 주문 구분
                    soConsumableOrderItem.Consumables_Order_Class_Code__c = 'Sold Out';
                    // 부서 코드
                    soConsumableOrderItem.Department_Code__c = 'PH8002';
                    
                    // 소모품 업무 유형
                    // 소모품 업무 유형
                    if (!isExchangeOrder) {
                        soConsumableOrderItem.Consumables_Business_Type_Code__c = 'Order';
                    } 
                    else {
                        // 교환 주문 일 때
                        soConsumableOrderItem.Consumables_Business_Type_Code__c = 'ExchangeOrder';
                        soConsumableOrderItem.BASIS_Order_Item_Id__c = item.productRequestLineItemId;
                        // 교환요청부서코드
                        soConsumableOrderItem.Exchange_Request_Department_Code__c = deptCode;
                        // 교환요청일시
                        soConsumableOrderItem.Exchange_Request_DTM__c = System.now();
                        // 교환요청자ID
                        soConsumableOrderItem.Exchange_Requester_Id__c = UserInfo.getUserId();
                        // 교환 수량
                        soConsumableOrderItem.Exchange_Quantity__c = item.QTY;
                    }
                    // 소모품 주문 채널
                    soConsumableOrderItem.Order_CHNL_TYPE_Code__c = orderChannelType;

                    // 품절주문 예약 상태
                    if (soConsumableOrderItem.Appointment_Status__c == null) {
                        soConsumableOrderItem.Appointment_Status__c = '요청';
                    }

                    // 소모품 주문 상태
                    soConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_000;
                    // 소모품 주문 고객 Contact Id
                    soConsumableOrderItem.Order_CUST_Id__c = contactId;
                    // 소모품 주문 품목의 사업부 코드
                    soConsumableOrderItem.ENDP_Code__c = item.DIVCODE;
                    //출고부서코드
                    if (item.ShipmentCode != null) {
                        soConsumableOrderItem.SHIPPED_Department_Code__c = item.ShipmentCode;
                    }
                    // Product
                    // 소모품 주문 품목의 파트 Id
                    soConsumableOrderItem.Product2Id = item.sProductId;
                    // 소모품 주문 품목이 재고 Id
                    soConsumableOrderItem.ProductItem__c = item.sProductItemId;

                    // 소모품 주문 품목의 파트 넘버 요청 Part No
                    soConsumableOrderItem.BASIS_Parts_Number__c = item.ProductCode;
                    // 소모품 주문 품목의 파트 넘버
                    soConsumableOrderItem.PART_NO__c = item.ProductCode;
                    // 소모품 주문 품목의 요청 수량
                    soConsumableOrderItem.QuantityRequested = Item.QTY;
                    // 소모품 주문 품목의 판매 수량
                    soConsumableOrderItem.SALE_Quantity__c = item.QTY;
                    // 소모품 주문 품목의 소비자가
                    soConsumableOrderItem.CONSUMER_Price__c = item.Price;
                    soConsumableOrderItem.ASC_Price__c = item.ASCPrice;
                    //23.12.04 gw.lee 재경 요청 UnitPrice 필요 //23 12 07 hyungho.chun UnitPrice__c 판매저장때 계산해서넣어줌
                    // soConsumableOrderItem.UnitPrice__c = item.Price;

                    // 소모품 주문 품목의 모델 Id
                    soConsumableOrderItem.MODEL__c = item.ModelId;
                    soConsumableOrderItem.MODEL_Code__c = item.Model; // PHJ 24 02 23

                    // Location
                    // 소모품 주문 품목의 대상 위치 Id
                    //soConsumableOrderItem.DestinationLocationId = item.sLocationId;
                    // 소모품 주문 품목의 소스 위치 Id
                    System.debug('item.sLocationId -> ');
                    System.debug(item.sLocationId);
                    soConsumableOrderItem.SourceLocationId = consumableWareHouseId;

                    // 소모품 주문 품목의 현금,카드,포인트 결제 값
                    if (!isExchangeOrder) {
                        // 결제 금액
                        // 매핑 필요
                        soConsumableOrderItem.PAYMENT_Amount__c = item.QTY * item.Price - (item.DiscountAmount != null ? item.DiscountAmount : 0);
                        soConsumableOrderItem.Last_Discount_Amount__c = item.DiscountAmount != null ? item.DiscountAmount : 0;
                    }

                    // 판매 금액
                    soConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;
                    if (item.PromotionPrice == null) item.PromotionPrice = 0;

                    if (ContactVIP != 0) {
                        soConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;

                        if (item.PromotionPrice != null && item.PromotionPrice != 0) {
                            if (item.Price * item.QTY * ContactVIP < item.PromotionPrice * item.QTY) {
                                soConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.Price * item.QTY * ContactVIP;
                                soConsumableOrderItem.VIP_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                                soConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                                soConsumableOrderItem.SALE_Discount_Type_Code__c = 'V';
                                soConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;
                            } 
                            else {
                                soConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                                soConsumableOrderItem.PROMOTION_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                                soConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                                soConsumableOrderItem.SALE_Discount_Type_Code__c = 'P';
                                soConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;
                            }
                        } 
                        else {
                            soConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.Price * item.QTY * ContactVIP;
                            soConsumableOrderItem.VIP_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                            soConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                            soConsumableOrderItem.SALE_Discount_Type_Code__c = 'V';
                            soConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;
                        }
                    } 
                    else if (item.PromotionPrice != 0) {
                        soConsumableOrderItem.PAYMENT_Amount__c = item.PromotionPrice * item.QTY;
                        soConsumableOrderItem.PROMOTION_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                        soConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                        soConsumableOrderItem.SALE_Discount_Type_Code__c = 'P';
                        soConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;
                    } 
                    else {
                        soConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY ;
                        soConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY;
                    }

                    System.debug('item.discountType : ' + item.discountType);
                    if (item.discountType != null) {
                        if (item.discountType == '임직원') {
                            soConsumableOrderItem.SALE_Discount_Type_Code__c = 'E';
                            soConsumableOrderItem.Employees_Discount_Amount__c = item.DiscountAmount;
                            soConsumableOrderItem.PAYMENT_Amount__c -= item.DiscountAmount;
                        } else if (item.discountType == 'VIP') {
                            soConsumableOrderItem.SALE_Discount_Type_Code__c = 'V';
                            soConsumableOrderItem.VIP_Discount_Amount__c = item.DiscountAmount;
                        } else if (item.discountType == '프로모션') {
                            soConsumableOrderItem.SALE_Discount_Type_Code__c = 'P';
                            soConsumableOrderItem.PROMOTION_Discount_Amount__c = item.DiscountAmount;
                        }
                    }

                    if (soConsumableOrderItem.PAYMENT_TYPE__c != 'URL')
                        // 소모품 주문 품목의 선 결제 여부
                        soConsumableOrderItem.PAYMENT_YN__c = isBeforePaymentYN ? true : false;
                    else
                        soConsumableOrderItem.PAYMENT_YN__c = false;

                    // 소모품 요청자의 소속 부서 코드
                    soConsumableOrderItem.Requester_Department_Code__c = deptCode;


                    // 택배 수취인 관련 정보
                    if (!isContactSame) {
                        // 수취인 명
                        soConsumableOrderItem.CONSIGNEE_Name__c = consigneeName;
                        // 수취인 전화번호1
                        soConsumableOrderItem.CONSIGNEE_TPNO_1__c = IbCallNo;
                        // 수취인 전화번호2
                        soConsumableOrderItem.CONSIGNEE_TPNO_2__c = IbCallNo;
                        // 수취인 주소
                        soConsumableOrderItem.CONSIGNEE_Address__c = newAddress;
                        soConsumableOrderItem.CONSIGNEE_Address_DETAIL__c = String.isEmpty(detailAddress) ? '( )' : detailAddress;
                        soConsumableOrderItem.Delivery_Message_CONTENT__c = requestedTerm;
                    } 
                    else {
                        // 수취인 명
                        soConsumableOrderItem.CONSIGNEE_Name__c = orderContact.Name != null ? orderContact.Name : orderContact.LastName;
                        // 수취인 전화번호1
                        soConsumableOrderItem.CONSIGNEE_TPNO_1__c = orderContact.MobilePhone;
                        // 수취인 전화번호2
                        soConsumableOrderItem.CONSIGNEE_TPNO_2__c = orderContact.Phone;
                        // 수취인 주소
                        soConsumableOrderItem.CONSIGNEE_Address__c = orderContact.ADDRESS_NEW__c;
                        // soConsumableOrderItem.CONSIGNEE_Address_DETAIL__c = String.isEmpty(orderContact.ADDRESS_DETAIL__c) ? '( )' : orderContact.ADDRESS_DETAIL__c ;
                        soConsumableOrderItem.CONSIGNEE_Address_DETAIL__c = orderContact.ADDRESS_NEW__c != null ? (String.isEmpty(orderContact.ADDRESS_ROAD_ETC__c) ? '( )' : orderContact.ADDRESS_ROAD_ETC__c ) : (String.isEmpty(orderContact.ADDRESS_DETAIL__c) ? '( )' : orderContact.ADDRESS_DETAIL__c); //24 02 01 hyungho.chun 상세주소 신주소일시 불러오는 필드 다름
                        soConsumableOrderItem.Delivery_Message_CONTENT__c = requestedTerm;
                    }

                    consumableOrderItems.add(soConsumableOrderItem);
                    // 서브번호 채번을 위해 일반주문 레코드 저장
                    lineItemList.add(soConsumableOrderItem);
                }
            }

            System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (standardOrderDataList.size()-' + standardOrderDataList.size() + '):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
           
            System.debug('start====================');
            System.debug('afterDMLConsumableOrderMap');
            System.debug(afterDMLConsumableOrderMap);
            System.debug('end====================');

            System.debug('lineItemList : ' + lineItemList);

            Map<String, String> proNameKoMap = new Map<String,String>();
            if (isTemporary || isExchangeOrder) {
                // 23.02.20 서브번호 채번
                Map<String, Integer> subNumberMap = EX_ConsumableUtil.getSubNumberMap(lineItemList);

                System.debug('subNumberMap : ' + subNumberMap);
                for (ProductRequestLineItem prLi : consumableOrderItems) {
                    // 서브번호 채번
                    System.debug('prLi : ' + prLi);
                    if (prLi.RecordType.DeveloperName != 'RESV_SALE') {
                        prLi.SUB_Order_Number__c = EX_ConsumableUtil.getSubNumber(subNumberMap, prLi);
                    }
                }
                if (isTemporary) {
                    for (ItemTable stdData : standardOrderDataList) {
                        proNameKoMap.put(stdData.Id, stdData.productName);
                        if (discountType == 'VIP') {
                            stdOrderTotalSalesAmount = stdData.QTY * stdData.Price * ContactVIP;
                        } else if (discountType == '프로모션') {
                            stdOrderTotalSalesAmount = stdData.QTY * stdData.PromotionPrice;
                        }
                    }
                    System.debug('stdOrderTotalSalesAmount : ' + stdOrderTotalSalesAmount);

                    for (ItemTable soldData : soldOutOrderDataList) {
                        proNameKoMap.put(soldData.Id, soldData.productName);
                        if (discountType == 'VIP') {
                            soldOutOrderTotalSalesAmount = soldData.QTY * soldData.Price * ContactVIP;
                        } else if (discountType == '프로모션') {
                            soldOutOrderTotalSalesAmount = soldData.QTY * soldData.PromotionPrice;
                        }
                    }
                    System.debug('soldOutOrderTotalSalesAmount : ' + soldOutOrderTotalSalesAmount);
                }
            }

            if (!consumablePOItems.isEmpty()) consumableOrderItems.addAll(consumablePOItems);

            // 2023.11.06 seung yoon heo
            // Set<String> prLiIdSet = new Set<String>();
            // System.debug('prLiIdSet ??? ' + prLiIdSet );
            // List<ProductRequestLineItem> prLiList = [SELECT Id, SUB_Order_Number__c FROM ProductRequestLineItem WHERE Id IN :prLiIdSet];
            // System.debug('prLiList ??? ' + prLiIdSet );
            // System.debug('prLiIdSet ???? ' + prLiIdSet );

            // TODO : Bypass 풀 것
            System.debug('consumableOrderItems : ' + consumableOrderItems);
            upsert consumableOrderItems;
            System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (upsert consumableOrderItems):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

            // 2023.11.06 seung yoon heo
            // prLiList = [SELECT Id, SUB_Order_Number__c FROM ProductRequestLineItem WHERE Id IN :prLiIdSet];
            // System.debug('prLiList ????? ' + prLiList );
            // System.debug('prLiIdSet ????? ' + prLiIdSet );
            
            Set<String> partIdSet = new Set<String>();
            Set<String> locationIdSet = new Set<String>();

            // 2023.11.06 seung yoon heo
            // Set<String> insertConsumableOrderItemIdSet = new Set<String>();
            // for (ProductRequestLineItem productRequestLineItem : consumableOrderItems) {
            //     insertConsumableOrderItemIdSet.add(productRequestLineItem.Id);
            // }

            Set<String> insertConsumableOrderItemIdSet = new Map<String, productRequestLineItem>(consumableOrderItems).keySet();

            // 자재쪽 재고 수불 Method 호출
            List<Map<String, Object>> pListMapRequestInfo = new List<Map<String, Object>>();
            Map<String, Object> mapRequestInfo;

            String strProductRequestLineItemQry = '';
            strProductRequestLineItemQry += 'SELECT Id, ParentId, Order_Number__c, Order_SEQ__c, QuantityRequested, Consumables_Order_Class_Code__c, SHIPPED_Department_Code__c, fm_Consumables_PART_DESC_KOR__c, ';
            strProductRequestLineItemQry += 'BASIS_Order_Item_Id__c,  SourceLocationId, ENDP_Code__c, Product2Id, ProductItem__c, PART_NO__c, RSRV_Number__c, ';
            strProductRequestLineItemQry += 'ASC_Price__c, CONSUMER_Price__c, PROMOTION_Discount_Amount__c, Last_Discount_Amount__c, Consumables_Business_Type_Code__c, SALE_AMOUNT__c ';
            strProductRequestLineItemQry += ' ,Product2.Name, Product2.ProductCode, Product2.PART_DESC_KOR__c, Product2.DIV_CODE__c ';
            strProductRequestLineItemQry += ' ,Product2.Description, Parent.Order_CUST_TPNO_1__c, Parent.Order_CUST_Name__c, Parent.Order_Number__c, MODEL__c, MODEL_Code__c ' +
                    ' ,Parent.Discount_Amount__c, Parent.Sale_Amount__c ';

            strProductRequestLineItemQry += '  FROM ProductRequestLineItem';
            strProductRequestLineItemQry += ' WHERE Id IN :insertConsumableOrderItemIdSet';

            List<ProductRequestLineItem> afterDMLConsumableOrderItems = Database.query(strProductRequestLineItemQry);

            System.debug('afterDMLConsumableOrderItems :: => :: ' + afterDMLConsumableOrderItems);
            
            Set<String> shippedDeptCodeSet = new Set<String>();
            for (ProductRequestLineItem prli : afterDMLConsumableOrderItems) {
                shippedDeptCodeSet.add(prli.SHIPPED_Department_Code__c);
            }

            List<SM_DIV__c> divList = [
                    SELECT Id, DIV_CODE__c
                    FROM   SM_DIV__c
                    WHERE  DIV_CODE__c IN: shippedDeptCodeSet
            ];

            System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (query SM_DIV__c):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            Map<String, SM_DIV__c> divMap = new Map<String, SM_DIV__c>();
            for (SM_DIV__c smDiv : divList) {
                divMap.put(smDiv.DIV_Code__c, smDiv);
            }
           
            // 23.05.01 / 재고 수불 처리 시점 변경
            // 일반 주문(예약 X) 의 경우 결제 전 재고 할당 처리

            // 23.08.30 gw.lee
            // 일반 주문 - 예약 주문 O, 적치장소 + 소모품 센터 재고 (-) 처리
            if ((isTemporary == true && !isExchangeOrder) || isExchangeOrder) {

                List<Map<String, Object>> mapList = new List<Map<String, Object>>();

                for (ProductRequestLineItem consumableOrderItem : afterDMLConsumableOrderItems) {
                    if (consumableOrderItem.Consumables_Order_Class_Code__c == 'General' ) {
                        mapRequestInfo = new Map<String, Object>();
                        mapRequestInfo.put('product2Id', consumableOrderItem.Product2Id);
                        mapRequestInfo.put('sourceLocationId', consumableOrderItem.SourceLocationId);
                        mapRequestInfo.put('destinationLocationId', null);
                        mapRequestInfo.put('requestType', 'AA');
                        
                        mapRequestInfo.put('productRequestLineItem', consumableOrderItem);
                        mapRequestInfo.put('returnOrderLineItem', null);
                        mapRequestInfo.put('productTransfer', null);
                        
                        // locationIdSet.add(consumableOrderItem.DestinationLocationId);
                        
                        //일반 주문 (예약 X)
                        if (!divMap.containsKey(consumableOrderItem.SHIPPED_Department_Code__c)) {
                            mapRequestInfo.put('requestQTY', consumableOrderItem.QuantityRequested);
    
                            partIdSet.add(consumableOrderItem.product2Id);
                            locationIdSet.add(consumableOrderItem.SourceLocationId);
                            pListMapRequestInfo.add(mapRequestInfo);
                        } 
                        //일반 주문 (예약 o)
                        else if (divMap.containsKey(consumableOrderItem.SHIPPED_Department_Code__c)) {

                            //센터 및 적치장소 재고 감소 처리
                            Map<String, String> childMap = new Map<String, String>();
                            childMap = (Map<String, String>) parentMap.get(consumableOrderItem.Product2Id);
                            if (parentMap != null) {
                                mapRequestInfo.put('requestQTY', Integer.valueOf(childMap.get('stdQuantity')));
        
                                partIdSet.add(consumableOrderItem.product2Id);
                                locationIdSet.add(consumableOrderItem.SourceLocationId);
                                pListMapRequestInfo.add(mapRequestInfo);
                            }

                            Map<String, Object> mapItem = new Map<String, Object>();
                            mapItem.put('oriPrId', consumableOrderItem.ParentId); //원주문 ProductRequestId
                            mapItem.put('oriPrliId', consumableOrderItem.Id); //원주문 ProductRequestLineItemId
                            mapItem.put('oriOrderNo', consumableOrderItem.Order_Number__c); //원주문번호
                            mapItem.put('oriOrderSeq', consumableOrderItem.Order_SEQ__c); //원주문Seq
                            mapItem.put('deptCode', EX_ConsumableUtil.PH8002); //부서코드
                            // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                            // mapItem.put('partNo', consumableOrderItem.Product2.ProductCode); //파트넘버
                            mapItem.put('partNo', consumableOrderItem.Product2.Name); //파트넘버

                            if (childMap.get('resrvQuantity') != null) {
                                mapItem.put('req_qty', Integer.valueOf(childMap.get('resrvQuantity'))); //요청수량
                            } 
                            else {
                                mapItem.put('req_qty', consumableOrderItem.QuantityRequested); //요청수량
                            }

                            mapItem.put('div_code', consumableOrderItem.Product2.DIV_CODE__c); //사업부
                            mapList.add(mapItem);
                        }
                    } 
                    else if (consumableOrderItem.Consumables_Order_Class_Code__c == 'Sold Out') {
                        Map<String, Object> mapItem = new Map<String, Object>();
                        mapItem.put('oriPrId', consumableOrderItem.ParentId); //원주문 ProductRequestId
                        mapItem.put('oriPrliId', consumableOrderItem.Id); //원주문 ProductRequestLineItemId
                        mapItem.put('oriOrderNo', consumableOrderItem.Order_Number__c); //원주문번호
                        mapItem.put('oriOrderSeq', consumableOrderItem.Order_SEQ__c); //원주문Seq
                        mapItem.put('deptCode', EX_ConsumableUtil.PH8002); //부서코드
                        // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                        // mapItem.put('partNo', consumableOrderItem.Product2.ProductCode); //파트넘버
                        mapItem.put('partNo', consumableOrderItem.Product2.Name); //파트넘버
                        mapItem.put('req_qty', consumableOrderItem.QuantityRequested); //요청수량
                        mapItem.put('div_code', consumableOrderItem.Product2.DIV_CODE__c); //사업부
                        mapList.add(mapItem);
                    } 
                }

                /** 약속모듈 호출 */
                if (!mapList.isEmpty()) {
                    //23.11.07 modify
                    try {
                        String rsrvJsonString = JSON.serialize(mapList);
                        System.debug('JSON Serial >>>' + rsrvJsonString);
                        System.debug('JSON deSerial >>>' + JSON.deserializeUntyped(rsrvJsonString));
                        EX_SuppliesController.rsrvModule(rsrvJsonString);
                        // Map<String, Object> rtnMap = new Map<String, Object>();
                        // rtnMap = EX_RsrvUtil.RESRV_MODULE(mapList);
                        // 230530 비동기 전환
                        // EX_RsrvModule_qa rsrvModuleQa = new EX_RsrvModule_qa(mapList);
                        // System.enqueueJob(rsrvModuleQa);
                    } catch (Exception e) {
                        System.debug(e.getLineNumber() + ' Line || ' + e.getMessage());
                        throw new AuraHandledException(e.getLineNumber() + ' Line || ' + e.getMessage());
                    }

                }

                //23.11.07 modify
                Map<String, ProductItem> pMapProductItemByKey = new Map<String, ProductItem>();
                String strKeyPI = '';
                for (ProductItem productItem : prItemList) {
                    strKeyPI = productItem.LocationId + '^' + productItem.Product2Id;
                    pMapProductItemByKey.put(strKeyPI, productItem);
                }
                // Map<String, ProductItem> pMapProductItemByKey = new Map<String, ProductItem>();
                // String stqProductItemQry = '';
                // stqProductItemQry += 'SELECT LocationId, Product2Id, DEPT_CODE__c, ALLOC_QTY__c ' ;
                // stqProductItemQry += '  FROM ProductItem';
                // stqProductItemQry += ' WHERE Product2Id IN :partIdSet AND LocationId IN :locationIdSet';

                // List<ProductItem> productItems = Database.query(stqProductItemQry);
                // // Key :  {!sourceLocationId} + '^' + {!Product2Id}
                // String strKeyPI = '';
                // for (ProductItem productItem : productItems) {
                //     strKeyPI = productItem.LocationId + '^' + productItem.Product2Id;
                //     pMapProductItemByKey.put(strKeyPI, productItem);
                // }

                System.debug('start====================');
                System.debug('pListMapRequestInfo');
                System.debug(pListMapRequestInfo);
                System.debug('end====================');
                System.debug('pMapProductItemByKey');
                System.debug(pMapProductItemByKey);
                Map<String, Object> rtnMap = new Map<String, Object>();

                rtnMap = FS_MaterialUtil.applyProductItem(pListMapRequestInfo, pMapProductItemByKey);
                System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (FS_MaterialUtil.applyProductItem):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                System.debug('start====================');
                System.debug('rtnMap');
                System.debug(JSON.serializePretty(rtnMap));
                System.debug(rtnMap);
                System.debug('end====================');
            }

            if (afterDMLConsumableOrderMap.containsKey(STANDARD_ORDER)) {
                returnMap.put(STANDARD_ORDER, afterDMLConsumableOrderMap.get(STANDARD_ORDER));
            } 
            else {
                returnMap.put(STANDARD_ORDER, null);
            }

            if (afterDMLConsumableOrderMap.containsKey(SOLD_OUT_ORDER)) {
                returnMap.put(SOLD_OUT_ORDER, afterDMLConsumableOrderMap.get(SOLD_OUT_ORDER));
            } 
            else {
                returnMap.put(SOLD_OUT_ORDER, null);
            }

            if (afterDMLConsumableOrderMap.containsKey(PO)) {
                returnMap.put(PO, afterDMLConsumableOrderMap.get(PO));
            } 
            else {
                returnMap.put(PO, null);
            }

            List<ItemTable> standardOrderItemTables = new List<ItemTable>();
            ItemTable standardOrderItem;

            List<ItemTable> soldOutOrderItemTables = new List<ItemTable>();
            ItemTable soldOutOrderItem;

            Set<String> exchangeOrderIdSet = new Set<String>();
            Map<String, Decimal> exchangeOrderQtyMap = new Map<String, Decimal>();

            // 품절 예약 시 품절예약주문 Message Send
            EX_Message__c soldOutOrderMessage = new EX_Message__c();
            String soldOutContactName = '';
            String orderNumber = '';
            String productName = '';
            Integer productCnt = 0;
            Decimal amount = 0;
            String soldOutContactPhone = '';

            //List<ProductRequestLineItem> afterDMLConsumableOrderItems2 = Database.query(strProductRequestLineItemQry);
            
            System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (query ProductRequestLineItem):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            for (ProductRequestLineItem afterDMLConsumableOrderineItem : afterDMLConsumableOrderItems) {
                if (afterDMLConsumableOrderineItem.Consumables_Business_Type_Code__c == 'ExchangeOrder') {
                    exchangeOrderIdSet.add(afterDMLConsumableOrderineItem.BASIS_Order_Item_Id__c);
                    exchangeOrderQtyMap.put(afterDMLConsumableOrderineItem.BASIS_Order_Item_Id__c, afterDMLConsumableOrderineItem.QuantityRequested);
                }

                if (afterDMLConsumableOrderineItem.Consumables_Order_Class_Code__c == 'General') {
                    standardOrderItem = new ItemTable();
                    standardOrderItem.Id = afterDMLConsumableOrderineItem.Id;
                    standardOrderItem.ParentId = afterDMLConsumableOrderMap.get(STANDARD_ORDER).Id;
                    standardOrderItem.sLocationId = afterDMLConsumableOrderineItem.SourceLocationId;
                    standardOrderItem.DIVCODE = afterDMLConsumableOrderineItem.ENDP_Code__c;
                    standardOrderItem.sProductId = afterDMLConsumableOrderineItem.Product2Id;
                    standardOrderItem.sProductItemId = afterDMLConsumableOrderineItem.ProductItem__c;
                    standardOrderItem.ProductCode = afterDMLConsumableOrderineItem.PART_NO__c;
                    standardOrderItem.QTY = afterDMLConsumableOrderineItem.QuantityRequested;
                    standardOrderItem.ResrvNumber = afterDMLConsumableOrderineItem.RSRV_Number__c;
                    standardOrderItem.ShipmentCode = afterDMLConsumableOrderineItem.SHIPPED_Department_Code__c;
                    // PHJ 24 02 23
                    standardOrderItem.ModelId = afterDMLConsumableOrderineItem.MODEL__c;
                    standardOrderItem.Model = afterDMLConsumableOrderineItem.MODEL_Code__c;
                    System.debug('standardOrderItem.ModelId => ' + standardOrderItem.ModelId);
                    System.debug('standardOrderItem.Model => ' + standardOrderItem.Model);

                    if (afterDMLConsumableOrderineItem.ASC_Price__c != null) {
                        standardOrderItem.ASCPrice = afterDMLConsumableOrderineItem.ASC_Price__c;
                    }

                    standardOrderItem.Price = afterDMLConsumableOrderineItem.CONSUMER_Price__c;
                    
                    if (afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c != null && afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c != 0) {
                        if (isManagement) {
                            standardOrderItem.PromotionPrice = afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c;
                        } else {
                            standardOrderItem.PromotionPrice = standardOrderItem.Price - afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c / standardOrderItem.QTY;
                        }
                    }
                    //0223.04.14
                    standardOrderItem.OrderNumber = afterDMLConsumableOrderineItem.Order_Number__c;
                    standardOrderItem.ProductName = proNameKoMap.get(afterDMLConsumableOrderineItem.Product2Id) != null ? proNameKoMap.get(afterDMLConsumableOrderineItem.Product2Id) : afterDMLConsumableOrderineItem.fm_Consumables_PART_DESC_KOR__c;

                    standardOrderItemTables.add(standardOrderItem);

                } 
                else if (afterDMLConsumableOrderineItem.Consumables_Order_Class_Code__c == 'Sold Out') {
                    soldOutOrderItem = new ItemTable();
                    soldOutOrderItem.Id = afterDMLConsumableOrderineItem.Id;
                    soldOutOrderItem.ParentId = afterDMLConsumableOrderMap.get(SOLD_OUT_ORDER).Id;
                    soldOutOrderItem.sLocationId = afterDMLConsumableOrderineItem.SourceLocationId;
                    soldOutOrderItem.DIVCODE = afterDMLConsumableOrderineItem.ENDP_Code__c;
                    soldOutOrderItem.sProductId = afterDMLConsumableOrderineItem.Product2Id;
                    soldOutOrderItem.sProductItemId = afterDMLConsumableOrderineItem.ProductItem__c;
                    soldOutOrderItem.ProductCode = afterDMLConsumableOrderineItem.PART_NO__c;
                    soldOutOrderItem.QTY = afterDMLConsumableOrderineItem.QuantityRequested;

                    // PHJ 24 02 23
                    soldOutOrderItem.ModelId = afterDMLConsumableOrderineItem.MODEL__c;
                    soldOutOrderItem.Model = afterDMLConsumableOrderineItem.MODEL_Code__c;
                    
                    if (afterDMLConsumableOrderineItem.ASC_Price__c != null) {
                        soldOutOrderItem.ASCPrice = afterDMLConsumableOrderineItem.ASC_Price__c;
                    }

                    soldOutOrderItem.Price = afterDMLConsumableOrderineItem.CONSUMER_Price__c;
                    
                    if (afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c != null && afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c != 0) {
                        if (isManagement) {
                            soldOutOrderItem.PromotionPrice = afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c;
                        } else {
                            soldOutOrderItem.PromotionPrice = soldOutOrderItem.Price - afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c / soldOutOrderItem.QTY;
                        }
                    }

                    //0223.04.14
                    soldOutOrderItem.OrderNumber = afterDMLConsumableOrderineItem.parent.Order_Number__c;
                    soldOutOrderItem.ProductName = proNameKoMap.get(afterDMLConsumableOrderineItem.Product2Id) != null ? proNameKoMap.get(afterDMLConsumableOrderineItem.Product2Id) : afterDMLConsumableOrderineItem.fm_Consumables_PART_DESC_KOR__c;

                    soldOutContactPhone = afterDMLConsumableOrderineItem.Parent.Order_CUST_TPNO_1__c;
                    soldOutContactName = afterDMLConsumableOrderineItem.Parent.Order_CUST_Name__c;
                    orderNumber = afterDMLConsumableOrderineItem.Parent.Order_Number__c;
                    productName = proNameKoMap.get(afterDMLConsumableOrderineItem.Product2Id) != null ? proNameKoMap.get(afterDMLConsumableOrderineItem.Product2Id) : afterDMLConsumableOrderineItem.fm_Consumables_PART_DESC_KOR__c;
                    productCnt += 1;
                    amount += afterDMLConsumableOrderineItem.SALE_Amount__c - afterDMLConsumableOrderineItem.Last_Discount_Amount__c;

                    soldOutOrderItemTables.add(soldOutOrderItem);
                }
            }

            returnMap.put('standardOrderItemTables', standardOrderItemTables);
            returnMap.put('soldOutOrderItemTables', soldOutOrderItemTables);
            returnMap.put('isOrderChange', isOrderChange);

            System.debug('rtnMap soIt : ' + standardOrderItemTables);
            System.debug('rtnMap souIt : ' + soldOutOrderItemTables);
            
        } catch (Exception e) {
            System.debug(e.getLineNumber() + 'Line || ' + e.getMessage());
            throw new AuraHandledException(e.getLineNumber() + 'Line || ' + e.getMessage());
        }
        System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        return returnMap;
    }

    //23.11.07 PHJ
    @Future
    public static void rsrvModule(String mapListJsonString) {
        List<Object> jsonMapList = (List<Object>) JSON.deserializeUntyped(mapListJsonString);
        List<Map<String, Object>> mapList = new List<Map<String, Object>>();

        for(Object jsonObject : jsonMapList){
            Map<String, Object> jsonMap = (Map<String, Object>) jsonObject;
            mapList.add(jsonMap);
        }
        
        EX_RsrvModule_qa rsrvModuleQa = new EX_RsrvModule_qa(mapList);
        System.enqueueJob(rsrvModuleQa);
    }

    /**
     * @description 소모품 주문 저장
     * @author 22.12.27 / I2MAX.SEOKHOLEE
     * @return Map
     *
     */
    @AuraEnabled
    public static Map<String, Object> doSaveConsumableOrder(Map<String, Object> paramMap) {
        System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (start):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        Map<String, Object> returnMap = new Map<String, Object>();

        // 주문채널
        String orderChannelType = paramMap.containsKey('orderChannelType') ? (String) paramMap.get('orderChannelType') : 'V';

        Boolean isContactSame = (Boolean) paramMap.get('isContactSame');
        String strCaseId = (String) paramMap.get('strCaseId');
        String contactId = (String) paramMap.get('contactId');
        String consigneeName = (String) paramMap.get('consigneeName');
        String IbCallNo = (String) paramMap.get('IbCallNo');
        String newAddress = (String) paramMap.get('newAddress');
        String detailAddress = (String) paramMap.get('detailAddress');

        System.debug(' strCaseId ?? ' + strCaseId);
        if (strCaseId != '' && strCaseId != null) {
            Case getCaseCon = [SELECT ContactId, Contact.MobilePhone, Contact.Name, Contact.ADDRESS_NEW__c, Contact.ADDRESS_DETAIL__c  FROM Case WHERE Id = : strCaseId];
            contactId = getCaseCon.ContactId;
            if (isContactSame) {
                consigneeName = getCaseCon.Contact.Name;
                IbCallNo = getCaseCon.Contact.MobilePhone;
                newAddress = getCaseCon.Contact.ADDRESS_NEW__c;
                detailAddress = getCaseCon.Contact.ADDRESS_DETAIL__c;
            }
        }

        

        
        
        
        String requestedTerm = (String) paramMap.get('requestedTerm');
        String remark = (String) paramMap.get('remark');
        
        
        String zoneCode = (String) paramMap.get('zoneCode');
        String discountType = (String) paramMap.get('discountType');
        Decimal ContactVIP = (paramMap.get('ContactVIP') != null ? (Decimal) paramMap.get('ContactVIP') : 0);

        Boolean isManagement = (Boolean) paramMap.get('isManagement') != null ? (Boolean) paramMap.get('isManagement') : false;

        String managerNote = (String) paramMap.get('managerNote');

        // 품절 예약 선결제 여부
        Boolean isBeforePaymentYN = paramMap.containsKey('isBeforePaymentYN') ? (Boolean) paramMap.get('isBeforePaymentYN') : false;

        // 임시 저장 여부
        // 23.05.01 / todo 기존의 임시저장 여부로 사용하던 isTemporary 명을 변경

        Boolean isTemporary = paramMap.containsKey('isTemporary') ? (Boolean) paramMap.get('isTemporary') : false;
        Boolean isExchangeOrder = paramMap.containsKey('isExchangeOrder') ? (Boolean) paramMap.get('isExchangeOrder') : false;

        String stdConsumableOrderId = paramMap.containsKey('stdConsumableOrderId') ? (String) paramMap.get('stdConsumableOrderId') : null;
        String soldOutConsumableOrderId = paramMap.containsKey('soldOutConsumableOrderId') ? (String) paramMap.get('soldOutConsumableOrderId') : null;
        String poId = paramMap.containsKey('poId') ? (String) paramMap.get('poId') : null;
        Decimal stdOrderTotalPaymentAmount = paramMap.containsKey('stdOrderTotalPaymentAmount') ? (Decimal) paramMap.get('stdOrderTotalPaymentAmount') : 0;
        Decimal soldOutOrderTotalPaymentAmount = paramMap.containsKey('soldOutOrderTotalPaymentAmount') ? (Decimal) paramMap.get('soldOutOrderTotalPaymentAmount') : 0;

        Decimal stdOrderTotalSalesAmount = paramMap.containsKey('stdOrderTotalSalesAmount') ? (Decimal) paramMap.get('stdOrderTotalSalesAmount') : 0;
        Decimal soldOutOrderTotalSalesAmount = paramMap.containsKey('soldOutOrderTotalSalesAmount') ? (Decimal) paramMap.get('soldOutOrderTotalSalesAmount') : 0;

        Decimal stdOrderTotalDiscountAmount = paramMap.get('stdOrderTotalDiscountAmount') != null ? (Decimal) paramMap.get('stdOrderTotalDiscountAmount') : 0;
        Decimal soldOutOrderTotalDiscountAmount = paramMap.get('soldOutOrderTotalDiscountAmount') != null ? (Decimal) paramMap.get('soldOutOrderTotalDiscountAmount') : 0;

        // 주문전 재고가 감소해 일반이 품절로 변경된 경우
        Boolean isOrderChange = false;

        // 교환 주문 고객정보
        String customerName = paramMap.containsKey('customerName') ? (String) paramMap.get('customerName') : null;
        String customerPhone = paramMap.containsKey('customerPhone') ? (String) paramMap.get('customerPhone') : null;
        String customerPhone2 = paramMap.containsKey('customerPhone2') ? (String) paramMap.get('customerPhone2') : null;
        String customerAddress = paramMap.containsKey('customerAddress') ? (String) paramMap.get('customerAddress') : null;
        String customerDetailAddress = paramMap.containsKey('customerDetailAddress') ? (String) paramMap.get('customerDetailAddress') : null;
        String customerPostalCode = paramMap.containsKey('customerPostalCode') ? (String) paramMap.get('customerPostalCode') : null;

        System.debug('contactId -> ' + contactId);
        List<ItemTable> standardOrderDataList = (List<ItemTable>) JSON.deserialize((String) paramMap.get('standardOrderData'), List<ItemTable>.class);
        List<ItemTable> soldOutOrderDataList = (List<ItemTable>) JSON.deserialize((String) paramMap.get('soldOutOrderData'), List<ItemTable>.class);
        Map<String, Object> parentMap; // 일반 -- 품절일 경우
        
        // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (isTemporary-' + isTemporary + ',isManagement-' + isManagement + '):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        System.debug('soldOutOrderDataList :=> ' + soldOutOrderDataList);
        
        if (isTemporary || isExchangeOrder) { //24 01 12 hyungho.chun 교환주문도 타게 추가
            if (isManagement == false) {
                System.debug('soldOutOrderDataList : ' + soldOutOrderDataList);
                Map<String, Object> checkMap = EX_ConsumableUtil.reCheckAvailableQty(standardOrderDataList, soldOutOrderDataList);
                System.debug('((List<ItemTable>)checkMap.get(\'soldOutOrderDataList\')) : ' + ((List<ItemTable>) checkMap.get('soldOutOrderDataList')));
                
                if (((List<ItemTable>) checkMap.get('soldOutOrderDataList')).equals(soldOutOrderDataList) == false) {
                    isOrderChange = true;
                }
                
                standardOrderDataList = (List<ItemTable>) checkMap.get('standardOrderDataList');
                soldOutOrderDataList = (List<ItemTable>) checkMap.get('soldOutOrderDataList');
                stdOrderTotalPaymentAmount = (Decimal) checkMap.get('stdOrderTotalPaymentAmount');
                soldOutOrderTotalPaymentAmount = (Decimal) checkMap.get('soldOutOrderTotalPaymentAmount');
                parentMap = (Map<String, Object>) checkMap.get('parentMap');
                System.debug('parentMap :::: ' + parentMap);
            }
            System.debug('stdOrderTotalSalesAmount :' + stdOrderTotalSalesAmount);
            System.debug('soldOutOrderTotalSalesAmount :' + soldOutOrderTotalSalesAmount);

            for (ItemTable item : standardOrderDataList) {
                if (item.PromotionPrice == null) {
                    item.PromotionPrice = 0;
                }

                if (((item.PromotionPrice < item.Price * ContactVIP && item.PromotionPrice != 0) || (ContactVIP == 0 && item.PromotionPrice != 0))) {
                    item.DiscountAmount = (Integer) (item.Price * item.QTY - item.PromotionPrice * item.QTY);
                } else {
                    item.DiscountAmount = (Integer) (item.Price * ContactVIP * item.QTY);
                }

                stdOrderTotalDiscountAmount += item.DiscountAmount != null ? item.DiscountAmount : 0;
            }
            for (ItemTable item : soldOutOrderDataList) {
                if (item.PromotionPrice == null) {
                    item.PromotionPrice = 0;
                }

                if (((item.PromotionPrice < item.Price * ContactVIP && item.PromotionPrice != 0) || (ContactVIP == 0 && item.PromotionPrice != 0))) {
                    item.DiscountAmount = (Integer) (item.Price * item.QTY - item.PromotionPrice * item.QTY);
                } else {
                    item.DiscountAmount = (Integer) (item.Price * ContactVIP * item.QTY);
                }

                soldOutOrderTotalDiscountAmount += item.DiscountAmount != null ? item.DiscountAmount : 0;
                soldOutOrderTotalSalesAmount += item.Price * item.QTY;
            }
        }

        Set<String> sLocationIdSet = new Set<String>();
        Set<String> sProductIdSet = new Set<String>();

        // 5.8 BASIS Order_INFO 추가
        Set<String> kBasisOrderIdSet = new Set<String>();

        Map<String, String> sProductItemMap = new Map<String, String>();
        Map<String, Decimal> kBasisOrderIdOrderSeqMap = new Map<String, Decimal>();

        for (Integer i = 0; i < standardOrderDataList.size(); i++) {
            sLocationIdSet.add(standardOrderDataList.get(i).sLocationId);
            sProductIdSet.add(standardOrderDataList.get(i).sProductId);
            kBasisOrderIdSet.add(standardOrderDataList.get(i).productRequestLineItemId);
        }

        for (Integer i = 0; i < soldOutOrderDataList.size(); i++) {
            sLocationIdSet.add(soldOutOrderDataList.get(i).sLocationId);
            sProductIdSet.add(soldOutOrderDataList.get(i).sProductId);
            kBasisOrderIdSet.add(soldOutOrderDataList.get(i).productRequestLineItemId);
        }
        
        // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (before euqery ProductRequestLineItem):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        List<ProductRequestLineItem> basisPrLiList = [SELECT Id, Order_SEQ__c FROM ProductRequestLineItem WHERE Id =: kBasisOrderIdSet];
        for (ProductRequestLineItem prLi : basisPrLiList) {
            if (!kBasisOrderIdOrderSeqMap.containsKey(prLi.Id)) {
                kBasisOrderIdOrderSeqMap.put(prLi.Id, prLi.Order_SEQ__c);
            }
        }

        List<ProductItem> prItemList = [SELECT Id, LocationId, Product2Id FROM ProductItem WHERE LocationId IN :sLocationIdSet AND Product2Id IN: sProductIdSet];
        for (ProductItem prItem : prItemList) {
            sProductItemMap.put(prItem.LocationId + '^' + prItem.Product2Id, prItem.Id);
        }
        
        // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (map 구성):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        String mapString = '';
        for (Integer i = 0; i < standardOrderDataList.size(); i++) {
            mapString = standardOrderDataList.get(i).sLocationId + '^' + standardOrderDataList.get(i).sProductId;
            if (sProductItemMap.containsKey(mapString)) {
                standardOrderDataList.get(i).sProductItemId = sProductItemMap.get(mapString);
            }
        }

        for (Integer i = 0; i < soldOutOrderDataList.size(); i++) {
            mapString = soldOutOrderDataList.get(i).sLocationId + '^' + soldOutOrderDataList.get(i).sProductId;
            if (sProductItemMap.containsKey(mapString)) {
                soldOutOrderDataList.get(i).sProductItemId = sProductItemMap.get(mapString);
            }
        }

        // 23.03.04 교환 주문 에서의 교환 주문 여부
        String basisOrderNumber = (String) paramMap.get('basisOrderNumber');

        String chkEmployeeName = (String) paramMap.get('chkEmployeeName') != null ? (String) paramMap.get('chkEmployeeName') : '';
        String chkEmployeeNum = (String) paramMap.get('chkEmployeeNum') != null ? (String) paramMap.get('chkEmployeeNum') : '';
        String chkCompanyName = (String) paramMap.get('chkCompanyName') != null ? (String) paramMap.get('chkCompanyName') : '';
        String chkEmployeeRelationShip = (String) paramMap.get('chkEmployeeRelationShip') != null ? (String) paramMap.get('chkEmployeeRelationShip') : '';

        if (chkCompanyName != '') {
            SM_Code__c companyList = [SELECT Id, ATTRIBUTE1__c, CODE_NAME__c From SM_Code__c WHERE Id =: chkCompanyName LIMIT 1];
            chkCompanyName = companyList.ATTRIBUTE1__c;
        }
        Set<String> consumableOrderSetId = new Set<String>();
        if (stdConsumableOrderId != null) consumableOrderSetId.add(stdConsumableOrderId);
        if (soldOutConsumableOrderId != null) consumableOrderSetId.add(soldOutConsumableOrderId);
        List<ProductRequest> prList = [SELECT Order_Number__c, Id FROM ProductRequest WHERE Id =: consumableOrderSetId];
        Map<String, Id> stdOrderNumberMap = new Map<String, Id>();
        Map<String, Id> soldOutOrderNumberMap = new Map<String, Id>();
        for (ProductRequest pr : prList) {
            if (stdConsumableOrderId == pr.Id) stdOrderNumberMap.put(pr.Order_Number__c, pr.Id);
            if (soldOutConsumableOrderId == pr.Id) soldOutOrderNumberMap.put(pr.Order_Number__c, pr.Id);
        }
        // 23.02.20 서브번호 채번 추가
        List<SObject> lineItemList = new List<SObject>();

        if (isManagement) {
                for (ItemTable stdData : standardOrderDataList) {
                    stdOrderTotalSalesAmount += stdData.QTY * stdData.Price - stdData.DiscountAmount;
                    System.debug('stdOrderTotalSalesAmount :' + stdOrderTotalSalesAmount);
                    System.debug('isManagement :' + isManagement);
            }
                for (ItemTable soldData : soldOutOrderDataList) {
                    soldOutOrderTotalSalesAmount += soldData.QTY * soldData.Price - soldData.DiscountAmount;
                }
        }
        // 소모품센터 SM_DEPT
        SM_DEPT__c consumableCenter = [
                SELECT Id, Name, DEPT_CODE__c
                FROM   SM_DEPT__c
                WHERE  DEPT_CODE__c = 'PH8002'
                LIMIT  1
        ];
        
        // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (query SM_DEPT__c):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        String consumableSiteId = EX_ConsumableUtil.getConsumableSiteId();
        String consumableWareHouseId = EX_ConsumableUtil.getConsumableWareHouseId();
        Contact orderContact;
        if (isExchangeOrder) {
            orderContact = new Contact();
            orderContact.LastName = customerName;
            orderContact.MobilePhone = customerPhone;
            orderContact.Phone = customerPhone2;
            orderContact.ADDRESS_NEW__c = customerAddress;
            orderContact.ADDRESS_DETAIL__c = customerDetailAddress;
            orderContact.ADDRESS_ROAD_ETC__c = customerDetailAddress; //24 02 01 hyungho.chun 
            orderContact.POSTAL_CODE__c = customerPostalCode;
            System.debug('orderContact.POSTAL_CODE__c  -> ' + orderContact.POSTAL_CODE__c );
        } 
        else {
            orderContact = [
                    SELECT Id, Name, fm_ADDRESS_NEW__c, Phone, MobilePhone, POSTAL_CODE__c, ADDRESS_DETAIL__c, ADDRESS_NEW__c, AccountId, Account.AR_CODE__c, Account.BEST_AR_CODE__c, LastName,ADDRESS_ROAD_ETC__c,
                           fm_ADDRESS_OLD__c, Address_OLD__c
                    FROM   Contact
                    WHERE  Id =: contactId
                    LIMIT  1
            ];
        }


        // 2024.01.02 seung yoon heo ServiceResource >> User의 DEPT_CODE로 변경
        // 생성한 유저의 소속 조직 코드
        // List<ServiceResource> objSR = [
        //         SELECT Id, Name, SM_DEPT__c, SM_DEPT__r.DEPT_CODE__c, SM_DEPT__r.DEPT_TYPE_SECOND__c, SM_DEPT__r.HIGH_DEPT_CODE__c, SM_DEPT__r.HIGH_DEPT_CODE__r.DEPT_CODE__c, fm_DEPT_CODE__c
        //         FROM   ServiceResource
        //         WHERE  RelatedRecordId =: Userinfo.getUserId()
        // ];

        // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (query ServiceResource):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        String deptCode = '';
        // String deptId = '';
        User currentUser = EX_ConsumableService.doGetManagerInfo();
        
        // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (objSR.isEmpty()-' + objSR.isEmpty() + '):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        deptCode = currentUser.DEPT_CODE__c;
        // if (!objSR.isEmpty()) {
            //어떤 코드 사용 하여야 하는지 확인 필요
            // SM_DEPT__r.DEPT_TYPE_SECOND__c,
            // SM_DEPT__r.DEPT_CODE__c,
            // SM_DEPT__r.HIGH_DEPT_CODE__r.DEPT_CODE__c,
            // SM_DEPT__r.HIGH_DEPT_CODE__r.Name
        //     deptCode = objSR[0].fm_DEPT_CODE__c;
        //     deptId = objSR[0].SM_DEPT__r.HIGH_DEPT_CODE__r.Id;
        // } 
        // else {
        //     List<SM_BIZ_MANAGER__c> bizManager = [
        //             SELECT Id, DEPT_CODE__c, DEPT_CODE__r.DEPT_CODE__c, DEPT_CODE__r.DEPT_TYPE_SECOND__c, DEPT_CODE__r.HIGH_DEPT_CODE__c, DEPT_CODE__r.HIGH_DEPT_CODE__r.DEPT_CODE__c
        //             FROM   SM_BIZ_MANAGER__c
        //             WHERE  MANAGER_ID__c = :currentUser.EmployeeNumber__c AND BIZ_MANAGER_TYPE__c =: '46'
        //     ];
        //     if (!bizManager.isEmpty()) {
                //어떤 코드 사용 하여야 하는지 확인 필요
                // SM_DEPT__r.DEPT_TYPE_SECOND__c,
                // SM_DEPT__r.DEPT_CODE__c,
                // SM_DEPT__r.HIGH_DEPT_CODE__r.DEPT_CODE__c,
                // SM_DEPT__r.HIGH_DEPT_CODE__r.Name
        //         deptId = bizManager[0].DEPT_CODE__r.HIGH_DEPT_CODE__r.Id;
        //     }
        // }

        Map<String, Object> userInfoMap = EX_ConsumableUtil.getUserInfo(UserInfo.getUserId());
        
        // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (EX_ConsumableUtil.getUserInfo):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        Map<String, ProductRequest> consumableOrderMap = new Map<String, ProductRequest>();
        ProductRequest PO_ConsumableOrder;

        try {
            // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (일반주문이 존재할때 standardOrderDataList.size()-' + standardOrderDataList.size() + '):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            // 일반 주문 품목이 존재 할 때
            if (standardOrderDataList.size() > 0) {
                ProductRequest stdConsumableOrder;
                system.debug('isTemporary :::: '+ isTemporary);
                system.debug('isExchangeOrder :::: '+ isExchangeOrder);
                system.debug('stdConsumableOrderId :::: '+stdConsumableOrderId);
                system.debug('standardOrderDataList :::: '+standardOrderDataList);
                Datetime orderDate;

                if (isTemporary == false && isExchangeOrder == false) {
                    stdConsumableOrder = new ProductRequest(Id = stdConsumableOrderId);
                    //23 07 17 hyungho.chun 업데이트시 기존 orderDate 값 찾는 용도
                    orderDate = [SELECT Id, Order_Date__c FROM ProductRequest WHERE Id =: stdConsumableOrderId][0].Order_Date__c;
                } else {
                    stdConsumableOrder = new ProductRequest();
                }

                system.debug('stdConsumableOrder :::: '+stdConsumableOrder);

                // todo : 소모품 레코드 타입 추가 필요
                stdConsumableOrder.RecordTypeId = EX_ConsumableUtil.PR_CONSUMABLE_RECORDTYPE_ID;
                // 주문 고객 Contact Id
                stdConsumableOrder.Order_CUST_Id__c = contactId;
                // 소모품 주문 여부
                stdConsumableOrder.Consumables_Order_YN__c = true;
                // 소모품 주문 구분 /  일반 주문 : General, 품절 주문 : Sold Out
                if(soldOutConsumableOrderId != null && isManagement == true){
                    stdConsumableOrder.Consumables_Order_Class_Code__c = 'Sold Out';
                }else{
                    stdConsumableOrder.Consumables_Order_Class_Code__c = 'General';
                }
                // 소모품 업무 유형
                // 주문 : Order, 주문취소 : Cancel
                // 반품 : Return, 교환반품 : ExchangeReturn, 교환주문 : ExchangeOrder
                // PO(요청) : PO

                //현금입금여부
                stdConsumableOrder.CASH_DEPOSIT_YN__c = 'B';
                // 주문 일 때
                if (!isExchangeOrder) {
                    stdConsumableOrder.Consumables_Business_Type_Code__c = 'Order';
                } else {
                    // 교환 주문 일 때
                    stdConsumableOrder.Consumables_Business_Type_Code__c = 'ExchangeOrder';

                }

                // 주문 채널
                // 대표 사이트 : B, ThinQ : S, CIC소모품택배 : V, New BEST : New BEST
                stdConsumableOrder.Order_CHNL_TYPE_Code__c = orderChannelType;

                if (isTemporary || isExchangeOrder) {
                    // 관리자 메모
                    stdConsumableOrder.Description = managerNote != null ? managerNote : null;

                    Datetime target = Datetime.newInstance(
                            Date.today().addDays(1),
                            Time.newInstance(23, 59, 0, 0)
                    );
                    stdConsumableOrder.LIMIT_TM__c = target;
                    stdConsumableOrder.SALE_Amount__c = stdOrderTotalPaymentAmount;
                    stdConsumableOrder.PAYMENT_Amount__c = stdOrderTotalPaymentAmount - stdOrderTotalDiscountAmount;
                    stdConsumableOrder.Discount_Amount__c = stdOrderTotalDiscountAmount;
                }

                EX_Message__c message = new EX_Message__c();
                ProductRequest pr = new ProductRequest();
                
                System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (stdConsumableOrderId-' + stdConsumableOrderId + ',isExchangeOrder-' + isExchangeOrder + '):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                
                if (stdConsumableOrderId != null) {
                    pr = [SELECT PAYMENT_TYPE__c FROM ProductRequest WHERE Id = :stdConsumableOrderId limit 1];
                }
                if (!isExchangeOrder) {
                    List<SR_PRE_PAYMENT_HEADER__c> paymentHeaderList = [SELECT Id, BASIS_NO__c, SALE_AMT__c, (SELECT MOID__c, CARD_URL__c, ISSUE_CARD_INFO__c, ISSUE_CARD_NAME__c, INVOICE_ISSUE_TYPE__c, ID, PAY_CUST_PHONE__c, CERTIFY_KEY__c, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c, MID__c FROM SR_PAYMENT_HIST_DETAILS__r order by PAYMENT_AREA_NO__c) FROM SR_PRE_PAYMENT_HEADER__c WHERE BASIS_NO__c IN :stdOrderNumberMap.keySet()];
                    if (!paymentHeaderList.isEmpty()) {
                        SR_PRE_PAYMENT_HEADER__c paymentHeader = paymentHeaderList[0];
                        List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = new List<SR_PRE_PAYMENT_DETAIL__c>();
                        if (paymentHeaderList.size() == 1) {
                            for (SR_PRE_PAYMENT_HEADER__c header : paymentHeaderList) {
                                for (SR_PRE_PAYMENT_DETAIL__c detail : header.SR_PAYMENT_HIST_DETAILS__r) {
                                    paymentDetails.add(detail);
                                }
                            }
                        } else {
                            for (Integer i = 0; i < paymentHeaderList.size(); i++) {
                                paymentDetails.add(paymentHeaderList[i].SR_PAYMENT_HIST_DETAILS__r[0]);
                            }
                        }
                        System.debug('paymentDetails : ' + paymentDetails);
                        if (paymentHeader != null) {
                            stdConsumableOrder.Payment_URL__c = String.valueOf(paymentDetails[paymentDetails.size() - 1].CARD_URL__c);
                            if (paymentDetails.size() == 1) {
                                if (paymentDetails[0].DEPOSIT_TYPE__c == 'A') {
                                    stdConsumableOrder.PAYMENT_TYPE__c = 'VBANK';
                                    stdConsumableOrder.Status = '';

                                    stdConsumableOrder.INVOICE_ISSUE_TYPE__c = paymentDetails[0].INVOICE_ISSUE_TYPE__c;
                                } 
                                else if (paymentDetails[0].DEPOSIT_TYPE__c == 'B') {
                                    System.debug('paymentDetails[0].DEPOSIT_AMT__c :::: ' + paymentDetails[0].DEPOSIT_AMT__c);
                                    System.debug('paymentDetails[0].DEPOSIT_AMT__c :::: ' +  EX_ConsumableUtil.strToCurrencyWon(String.valueOf(paymentDetails[0].DEPOSIT_AMT__c)));
                                    stdConsumableOrder.PAYMENT_Method_Code__c = 'CARD';
                                    stdConsumableOrder.PAYMENT_TYPE__c = 'CARD';
                                    stdConsumableOrder.CARD_PAYMENT_Amount__c = Integer.valueOf(paymentDetails[0].DEPOSIT_AMT__c);
                                    stdConsumableOrder.PAYMENT_YN__c = true;
                                    stdConsumableOrder.PAYMENT_COMPLETED_DTM__c = system.now();
                                    message.Label1__c = EX_ConsumableUtil.strToCurrencyWon(String.valueOf(paymentDetails[0].DEPOSIT_AMT__c));
                                    //23.10.17 PHJ
                                    message.Label2__c = orderContact.Name != null ? orderContact.Name : '';
                                    
                                } 
                                else if (paymentDetails[0].DEPOSIT_TYPE__c == 'E') {
                                    DateTime currentDateTime = System.now();
                                    Integer daysToAdd = 1;

                                    Date currentDate = currentDateTime.date();
                                    Time currentTime = currentDateTime.time();

                                    // DateTime nextDayDateTime = DateTime.newInstance(currentDate.addDays(daysToAdd), currentTime);
                                    Datetime target = Datetime.newInstance(
                                            Date.today().addDays(1),
                                            Time.newInstance(23, 59, 0, 0)
                                    );
                                    stdConsumableOrder.LIMIT_TM__c = target;
                                    if ((paymentDetails[0].PAY_CUST_PHONE__c != paymentDetails[0].CERTIFY_KEY__c) && paymentDetails[0].UPAD_DETAIL_TYPE__c != 'PG_URL') {
                                        // stdConsumableOrder.PAYMENT_TYPE__c = 'CASH';
                                        stdConsumableOrder.CASH_DEPOSIT_YN__c = 'B';

                                        stdConsumableOrder.INVOICE_ISSUE_TYPE__c = paymentDetails[0].INVOICE_ISSUE_TYPE__c;
                                    } else {
                                        if (paymentDetails[0].UPAD_DETAIL_TYPE__c == 'PG_URL') {
                                            stdConsumableOrder.PAYMENT_TYPE__c = 'URL';
                                        } else {
                                            // stdConsumableOrder.PAYMENT_TYPE__c = 'VBANK';
                                            stdConsumableOrder.INVOICE_ISSUE_TYPE__c = paymentDetails[0].INVOICE_ISSUE_TYPE__c;
                                        }

                                    }
                                } 
                                else if (paymentDetails[0].DEPOSIT_TYPE__c == 'D') {
                                    stdConsumableOrder.PAYMENT_TYPE__c = null;
                                    stdConsumableOrder.PAYMENT_Method_Code__c = 'POINT';
                                    //23.08.04 gw.lee
                                    //카드결제값 들어가게 수정 처리
                                    // stdConsumableOrder.POINT_Amount__c = paymentHeader.SALE_AMT__c;
                                    //stdConsumableOrder.POINT_Amount__c = stdOrderTotalPaymentAmount;
                                    stdConsumableOrder.PAYMENT_YN__c = true;
                                    stdConsumableOrder.PAYMENT_COMPLETED_DTM__c = system.now();
                                    message.Label1__c = EX_ConsumableUtil.strToCurrencyWon(String.valueOf(paymentHeader.SALE_AMT__c));
                                    //23.10.17 PHJ
                                    message.Label2__c = orderContact.Name != null ? orderContact.Name : '';
                                }
                            } 
                            else {
                                if (paymentDetails[paymentDetails.size() - 1].DEPOSIT_TYPE__c == 'A') {
                                    // stdConsumableOrder.PAYMENT_TYPE__c = 'VBANK';
                                    stdConsumableOrder.INVOICE_ISSUE_TYPE__c = paymentDetails[paymentDetails.size() - 1].INVOICE_ISSUE_TYPE__c;
                                } 
                                else if (paymentDetails[paymentDetails.size() - 1].DEPOSIT_TYPE__c == 'B') {
                                    stdConsumableOrder.PAYMENT_Method_Code__c = 'CARD';
                                    stdConsumableOrder.PAYMENT_TYPE__c = 'CARD';

                                    //23 11 06 포인트+현장카드시 금액 및 결제완료여부 안들어가서 추가
                                    stdConsumableOrder.CARD_PAYMENT_Amount__c = Integer.valueOf(paymentDetails[paymentDetails.size() - 1].DEPOSIT_AMT__c);
                                    stdConsumableOrder.PAYMENT_YN__c = true;
                                    
                                    stdConsumableOrder.PAYMENT_COMPLETED_DTM__c = system.now();
                                    // message.Label1__c = EX_ConsumableUtil.strToCurrencyWon(String.valueOf(paymentDetails[0].DEPOSIT_AMT__c));
                                    message.Label1__c = EX_ConsumableUtil.strToCurrencyWon(String.valueOf(paymentHeader.SALE_AMT__c));//24 02 08 hyungho.chun 포인트+현장카드 시 알림톡 금액 오기 수정
                                    //23.10.17 PHJ
                                    message.Label2__c = orderContact.Name != null ? orderContact.Name : '';
                                } 
                                else if (paymentDetails[paymentDetails.size() - 1].DEPOSIT_TYPE__c == 'E') {
                                    //23 10 25 hyungho.chun 가상계좌전액신청했다가 닫기누르고 포인트전액할때 상황이 고려안되서 분기처리 추가함
                                    if(paymentDetails[paymentDetails.size() - 1].MOID__c != null){
                                        DateTime currentDateTime = System.now();
                                        Integer daysToAdd = 1;
                                        Date currentDate = currentDateTime.date();
                                        Time currentTime = currentDateTime.time();

                                        // DateTime nextDayDateTime = DateTime.newInstance(currentDate.addDays(daysToAdd), currentTime);
                                        Datetime target = Datetime.newInstance(
                                                Date.today().addDays(1),
                                                Time.newInstance(23, 59, 0, 0)
                                        );
                                        
                                        stdConsumableOrder.LIMIT_TM__c = target;
                                        if ((paymentDetails[paymentDetails.size() - 1].PAY_CUST_PHONE__c != paymentDetails[paymentDetails.size() - 1].CERTIFY_KEY__c) && paymentDetails[paymentDetails.size() - 1].UPAD_DETAIL_TYPE__c != 'PG_URL') {
                                            // stdConsumableOrder.PAYMENT_TYPE__c = 'CASH';
                                            stdConsumableOrder.CASH_DEPOSIT_YN__c = 'B';
                                            stdConsumableOrder.INVOICE_ISSUE_TYPE__c = paymentDetails[paymentDetails.size() - 1].INVOICE_ISSUE_TYPE__c;
                                        } else {
                                            if (paymentDetails[paymentDetails.size() - 1].UPAD_DETAIL_TYPE__c == 'PG_URL') {
                                                stdConsumableOrder.PAYMENT_TYPE__c = 'URL';
                                            } else {
                                                // stdConsumableOrder.PAYMENT_TYPE__c = 'VBANK';
                                                stdConsumableOrder.INVOICE_ISSUE_TYPE__c = paymentDetails[paymentDetails.size() - 1].INVOICE_ISSUE_TYPE__c;
                                            }
                                        }
                                    }
                                    else { //23 10 25 hyungho.chun 이 경우는 미수 E로남아있는게 취소건인거임moid없으니까! 
                                        stdConsumableOrder.PAYMENT_TYPE__c = null;
                                        stdConsumableOrder.PAYMENT_Method_Code__c = 'POINT';
                                        stdConsumableOrder.PAYMENT_YN__c = true;
                                        stdConsumableOrder.PAYMENT_COMPLETED_DTM__c = system.now();
                                        message.Label1__c = EX_ConsumableUtil.strToCurrencyWon(String.valueOf(paymentHeader.SALE_AMT__c));
                                        message.Label2__c = orderContact.Name != null ? orderContact.Name : '';
                                    }
                                }
                                // stdConsumableOrder.POINT_Amount__c = paymentDetails[0].DEPOSIT_AMT__c;
                            }

                            //0414 결제완료 알림톡발송 오류
                            try {
                                System.debug('mesg : ' + message);
                                // if (stdConsumableOrder.PAYMENT_Method_Code__c == 'POINT' || stdConsumableOrder.PAYMENT_TYPE__c == 'CARD') {
                                if (stdConsumableOrder.PAYMENT_Method_Code__c == 'POINT' ) {  //24 03 09 hyungho.chun 현장카드건 이제 si_smarto_total_payment트리거에서 승인처리 될 때 상태업데이트 및 결제완료 알림톡 발송으로 수정
                                    System.debug('1111 '+orderContact.Name);
                                    System.debug('1111 '+orderContact.MobilePhone);
                                    System.debug('1111 '+paymentDetails[0].PAY_CUST_PHONE__c);
                                    //23.10.18 PHJ
                                    EX_PaymentUtil.sendKaKaoMessage('SVC_LGE_MACN_013_1', message, orderContact.MobilePhone != null ? orderContact.MobilePhone : paymentDetails[0].PAY_CUST_PHONE__c);

                                    insert message;
                                }
                            } catch (Exception e) {
                                System.debug(e);
                            }
                            stdConsumableOrder.PAYMENT_REQUEST_DATE__c = paymentDetails[0].CreatedDate;
                        }
                        System.debug('결제 : ' + stdConsumableOrder.PAYMENT_TYPE__c);
                    } else {
                        System.debug('type cancel');
                    }
                }

                // 고객 명
                stdConsumableOrder.Order_CUST_Name__c = orderContact.Name != null ? orderContact.Name : orderContact.LastName;
                // 고객 전화번호1
                stdConsumableOrder.Order_CUST_TPNO_1__c = orderContact.MobilePhone;
                // 고객 전화번호2
                stdConsumableOrder.Order_CUST_TPNO_2__c = orderContact.Phone;
                // 고객 주소
                stdConsumableOrder.Order_CUST_Address__c = orderContact.ADDRESS_NEW__c != null ? orderContact.ADDRESS_NEW__c : orderContact.ADDRESS_OLD__c;
                // 고객 상세 주소
                // stdConsumableOrder.Order_CUST_Address_DETAIL__c = orderContact.ADDRESS_DETAIL__c;
                stdConsumableOrder.Order_CUST_Address_DETAIL__c = orderContact.ADDRESS_NEW__c != null ? orderContact.ADDRESS_ROAD_ETC__c : orderContact.ADDRESS_DETAIL__c; //24 02 01 hyungho.chun 상세주소 신주소일시 불러오는 필드 다름
                stdConsumableOrder.Delivery_Message_CONTENT__c = requestedTerm;
                // 고객 우편번호
                stdConsumableOrder.Order_CUST_PostalCode__c = orderContact.POSTAL_CODE__c;

                System.debug('##############');
                System.debug(LoggingLevel.ERROR, 'isContactSame -> ' + isContactSame);
                System.debug('stdConsumableOrder.Order_CUST_PostalCode__ -> ' + stdConsumableOrder.Order_CUST_PostalCode__c);
                System.debug('##############');
                System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (isContactSame-' + isContactSame + '):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                // 수취인 주소
                if (!isContactSame) {
                    // 수취인 명
                    stdConsumableOrder.CONSIGNEE_Name__c = consigneeName;
                    // 수취인 전화번호1
                    stdConsumableOrder.CONSIGNEE_TPNO_1__c = IbCallNo;
                    // 수취인 전화번호2
                    stdConsumableOrder.CONSIGNEE_TPNO_2__c = IbCallNo;
                    // 수취인 주소
                    //stdConsumableOrder.CONSIGNEE_Address__c = newAddress + ' ' + detailAddress;
                    stdConsumableOrder.CONSIGNEE_Address__c = newAddress;
                    // 수취인 상세 주소
                    stdConsumableOrder.CONSIGNEE_Address_DETAIL__c = String.isEmpty(detailAddress) ? '( )' : detailAddress;

                    stdConsumableOrder.Delivery_Message_CONTENT__c = requestedTerm;
                    // if(isExchangeOrder) {
                    //     stdConsumableOrder.CONSIGNEE_PostalCode__c = orderContact.POSTAL_CODE__c;
                    // } else {
                        //     stdConsumableOrder.CONSIGNEE_PostalCode__c = zoneCode;
                        // }
                    stdConsumableOrder.CONSIGNEE_PostalCode__c = zoneCode;

                } else {
                    // 수취인 명
                    stdConsumableOrder.CONSIGNEE_Name__c = orderContact.Name != null ? orderContact.Name : orderContact.LastName;
                    // 수취인 전화번호1
                    stdConsumableOrder.CONSIGNEE_TPNO_1__c = orderContact.MobilePhone;
                    // 수취인 전화번호2
                    stdConsumableOrder.CONSIGNEE_TPNO_2__c = orderContact.Phone;
                    // 수취인 주소
                    stdConsumableOrder.CONSIGNEE_Address__c = orderContact.ADDRESS_NEW__c != null ? orderContact.ADDRESS_NEW__c : orderContact.ADDRESS_OLD__c;
                    // stdConsumableOrder.CONSIGNEE_Address_DETAIL__c = String.isEmpty(orderContact.ADDRESS_DETAIL__c) ? '( )' : orderContact.ADDRESS_DETAIL__c;
                    stdConsumableOrder.CONSIGNEE_Address_DETAIL__c = orderContact.ADDRESS_NEW__c != null ? (String.isEmpty(orderContact.ADDRESS_ROAD_ETC__c) ? '( )' : orderContact.ADDRESS_ROAD_ETC__c ) : (String.isEmpty(orderContact.ADDRESS_DETAIL__c) ? '( )' : orderContact.ADDRESS_DETAIL__c); //24 02 01 hyungho.chun 상세주소 신주소일시 불러오는 필드 다름
                    stdConsumableOrder.Delivery_Message_CONTENT__c = requestedTerm;
                    // 우편번호
                    stdConsumableOrder.CONSIGNEE_PostalCode__c = stdConsumableOrder.Order_CUST_PostalCode__c;
                }
                // 수취인 우편번호. zoneCode 인입 시
                // 고객=수취인 -> Contact.POSTAL_CODE__c
                // 고객!=수취인 -> 주소검색 시 인입 된 우편번호 설정 되어있음
                // 일반주문 ProductRequest에 CaseId 추가
                System.debug('isManagement@@@@@@ ' + isManagement);
                if(isManagement == false) {
                    if (strCaseId != '') {
                        stdConsumableOrder.CaseId = strCaseId;
                        System.debug('case Id Set 확인 : ' + stdConsumableOrder.CaseId);
                    }
                }

                // 소모품 주문 실제 사용 여부
                stdConsumableOrder.Consumables_Order_USE_YN__c = isTemporary ? false : true;
                // 판매 금액


                // 23.04.11 추가
                // 상담부서 코드
                // 상담부서 Id
                if (userInfoMap.containsKey('DEPT')) {
                    SM_DEPT__c dept = (SM_DEPT__c) userInfoMap.get('DEPT');
                    stdConsumableOrder.CNSL_Department_Id__c = dept.Id;
                    stdConsumableOrder.CNSL_Department_Code__c = dept.DEPT_CODE__c;
                }
                // 주문 일시
                system.debug('stdConsumableOrder.Order_Date__c   : ' + stdConsumableOrder.Order_Date__c);
                //23 07 17 hyungho.chun 업데이트시 기존 orderDate 값 추가
                stdConsumableOrder.Order_Date__c = orderDate;
                if (stdConsumableOrder.Order_Date__c == null) {
                    stdConsumableOrder.Order_Date__c = System.now();
                }

                if (!isTemporary) {
                    if(isManagement){
                        stdConsumableOrder.SALE_Amount__c = stdOrderTotalSalesAmount + stdOrderTotalDiscountAmount;
                    }else{
                        stdConsumableOrder.SALE_Amount__c = stdOrderTotalSalesAmount;
                    }
                    if(isManagement) {
                        stdConsumableOrder.PAYMENT_Amount__c = stdOrderTotalSalesAmount;
                    }else{
                        stdConsumableOrder.PAYMENT_Amount__c = stdOrderTotalSalesAmount - stdOrderTotalDiscountAmount;
                    }
                    stdConsumableOrder.Discount_Amount__c = stdOrderTotalDiscountAmount != null ? stdOrderTotalDiscountAmount : 0;

                    // External Id
                    stdConsumableOrder.External_id__c = null;
                    // 부서 Id / PH8002, PH0300
                    stdConsumableOrder.Department_Id__c = consumableCenter.Id;
                    // 부서 코드
                    stdConsumableOrder.Department_Code__c = consumableCenter.DEPT_CODE__c;
                    // Source Location Id //  소모품센터
                    stdConsumableOrder.SourceLocationId = consumableWareHouseId;
                    // AccountId
                    stdConsumableOrder.AccountId = orderContact.AccountId;
                    // Biil To Code
                    // stdConsumableOrder.BILL_TO_CODE__c = orderContact.Account.BEST_AR_CODE__c != null ? orderContact.Account.BEST_AR_CODE__c : '';
                    // Ship to Code
                    // stdConsumableOrder.SHIP_TO_CODE__c = null;
                    //임직원 명
                    stdConsumableOrder.EMP_NAME__c = chkEmployeeName;
                    stdConsumableOrder.EMP_RELATION_CODE__c = chkEmployeeRelationShip;
                    stdConsumableOrder.EMP_NO__c = chkEmployeeNum;
                    stdConsumableOrder.EMP_COMPANY_CODE__c = chkCompanyName;

                    if ((stdConsumableOrder.SALE_Amount__c == stdConsumableOrder.Discount_Amount__c) && stdConsumableOrder.Discount_Amount__c != 0 && !isExchangeOrder) {
                        Datetime target = Datetime.newInstance(
                                Date.today().addDays(1),
                                Time.newInstance(23, 59, 0, 0)
                        );
                        
                        // stdConsumableOrder.LIMIT_TM__c = target;
                        stdConsumableOrder.PAYMENT_Method_Code__c = 'DISCOUNT';
                        stdConsumableOrder.PAYMENT_REQUEST_DATE__c = system.now();
                        stdConsumableOrder.PAYMENT_COMPLETED_DTM__c = system.now();
                        message.Label1__c = '0';
                        //23.10.17 PHJ
                        message.Label2__c = orderContact.Name != null ? orderContact.Name : '';
                        // 2024.01.09 seung yoon heo 카카오 try 처리
                        try {
                            EX_PaymentUtil.sendKaKaoMessage('SVC_LGE_MACN_013_1', message, orderContact.MobilePhone);
                            System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (EX_PaymentUtil.sendKaKaoMessage):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                            
                        } catch (Exception e) {
                            System.debug('=================');
                            System.debug(e.getMessage());
                            System.debug('=================');
                        }
                        // stdConsumableOrder.PAYMENT_YN__c = true;
                    }

                    //쿼리해서 전화번호 추가
                    // stdConsumableOrder.EMP_CEL_NO__c = chkEmployeeName;
                    // stdConsumableOrder.SALE_DC_TYPE__c
                }
                consumableOrderMap.put(STANDARD_ORDER, stdConsumableOrder);
            }
            
            // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (품절 주문 품목이 존재 soldOutOrderDataList.size()-' + soldOutOrderDataList.size() + ',isTemporary-' + isTemporary + '):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            // 품절 주문 품목이 존재 할 때
            if (soldOutOrderDataList.size() > 0) {
                ProductRequest soldOutConsumableOrder;
                Datetime orderDate;
                if (isTemporary == false) {
                    // 품절 예약 건에 대한 부품 예약 정보 생성
                    List<SR_RESRV_PART__c> insertSRRESrResrvParts = new List<SR_RESRV_PART__c>();
                    SR_RESRV_PART__c objSRP;
                    objSRP = new SR_RESRV_PART__c();
                    //objSRP.Location_Destination_Id__c = soldOutConsumableOrder.DestinationLocationId;
                    //objSRP.Location_Source_Id__c = soldOutConsumableOrder.SourceLocationId;
                    objSRP.Order_CUST_Id__c = contactId;
                    objSRP.Order_CHNL_TYPE_Code__c = orderChannelType;
                    objSRP.Consumables_Order_YN__c = true;

                    insertSRRESrResrvParts.add(objSRP);

                    List<SR_RESRV_PART__c> srResrvParts;

                    // if (!insertSRRESrResrvParts.isEmpty()) {
                    //     insert insertSRRESrResrvParts;
                    //     Set<String> resrvIdSet = new Set<String>();
                    //     for (SR_RESRV_PART__c srResrvPart : insertSRRESrResrvParts) {
                    //         resrvIdSet.add(srResrvPart.Id);
                    //     }
                    //     srResrvParts = [
                    //             SELECT Id, RSRV_Number__c
                    //             FROM SR_RESRV_PART__c
                    //             WHERE Id IN :resrvIdSet
                    //             LIMIT 1
                    //     ];
                    // }

                    //23 07 17 hyungho.chun 업데이트시 기존 orderDate 값 찾는 용도
                    orderDate = [SELECT Id, Order_Date__c FROM ProductRequest WHERE Id =: soldOutConsumableOrderId][0].Order_Date__c;
                    soldOutConsumableOrder = new ProductRequest(Id = soldOutConsumableOrderId);
                    // soldOutConsumableOrder.RSRV_Number__c = srResrvParts[0].RSRV_Number__c;
                    // soldOutConsumableOrder.SR_RSRV_PART_Id__c = srResrvParts[0].Id;
                } else {
                    soldOutConsumableOrder = new ProductRequest();
                }

                // todo : 소모품 레코드 타입 추가 필요
                soldOutConsumableOrder.RecordTypeId = EX_ConsumableUtil.PR_CONSUMABLE_RECORDTYPE_ID;
                
                // 23.04.11 추가
                // 상담부서 코드
                // 상담부서 Id
                if (userInfoMap.containsKey('DEPT')) {
                    SM_DEPT__c dept = (SM_DEPT__c) userInfoMap.get('DEPT');
                    soldOutConsumableOrder.CNSL_Department_Id__c = dept.Id;
                    soldOutConsumableOrder.CNSL_Department_Code__c = dept.DEPT_CODE__c;
                }

                // 주문 일시
                //23 07 17 hyungho.chun 업데이트시 기존 orderDate 값 추가
                soldOutConsumableOrder.Order_Date__c = orderDate;
                if (soldOutConsumableOrder.Order_Date__c == null) {
                    soldOutConsumableOrder.Order_Date__c = System.now();
                }

                // 주문 고객 Contact Id
                soldOutConsumableOrder.Order_CUST_Id__c = contactId;
                // 고객 우편번호
                soldOutConsumableOrder.Order_CUST_PostalCode__c = orderContact.POSTAL_CODE__c;
                // 소모품 주문 여부
                soldOutConsumableOrder.Consumables_Order_YN__c = true;
                // 소모품 주문 구분 /  일반 주문 : General, 품절 주문 : Sold Out
                soldOutConsumableOrder.Consumables_Order_Class_Code__c = 'Sold Out';

                soldOutConsumableOrder.CONSIGNEE_PostalCode__c = zoneCode == null ? null : zoneCode;

                // 소모품 업무 유형
                // 주문 : Order, 주문취소 : Cancel
                // 반품 : Return, 교환반품 : ExchangeReturn, 교환주문 : ExchangeOrder
                // PO(요청) : PO

                // 주문 채널
                // 대표 사이트 : B, ThinQ : S, CIC소모품택배 : V, New BEST : New BEST
                soldOutConsumableOrder.Order_CHNL_TYPE_Code__c = orderChannelType;

                if (!isExchangeOrder) {
                    soldOutConsumableOrder.Consumables_Business_Type_Code__c = 'Order';
                    if ([SELECT Id, BASIS_NO__c FROM SR_PRE_PAYMENT_HEADER__c WHERE BASIS_NO__c IN :soldOutOrderNumberMap.keySet()].size() != 0) {
                        SR_PRE_PAYMENT_HEADER__c paymentHeader = [SELECT Id, BASIS_NO__c FROM SR_PRE_PAYMENT_HEADER__c WHERE BASIS_NO__c IN :soldOutOrderNumberMap.keySet()][0];
                        List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT ID, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c FROM SR_PRE_PAYMENT_DETAIL__c WHERE SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c IN :soldOutOrderNumberMap.keySet() order by PAYMENT_AREA_NO__c];
                        
                        System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (query SR_PRE_PAYMENT_DETAIL__c):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                        
                        if (paymentHeader != null) {
                            if (paymentDetails.size() == 1) {

                                if (paymentDetails[0].DEPOSIT_TYPE__c == 'A') {
                                    soldOutConsumableOrder.Status = '';
                                } 
                                else if (paymentDetails[0].DEPOSIT_TYPE__c == 'B') {
                                    soldOutConsumableOrder.PAYMENT_Method_Code__c = 'CARD';
                                    if (soldOutConsumableOrder.PAYMENT_TYPE__c == null) {
                                        soldOutConsumableOrder.PAYMENT_TYPE__c = 'CARD';
                                    }
                                } 
                                else if (paymentDetails[0].DEPOSIT_TYPE__c == 'E') {
                                    
                                    if (paymentDetails[0].UPAD_DETAIL_TYPE__c == 'PG_VBANK')
                                        if (soldOutConsumableOrder.PAYMENT_TYPE__c != null) {
                                            if (soldOutConsumableOrder.PAYMENT_TYPE__c == null) {
                                                soldOutConsumableOrder.PAYMENT_TYPE__c = 'URL';
                                            }
                                        }
                                } 
                                else if (paymentDetails[0].DEPOSIT_TYPE__c == 'D') {
                                    soldOutConsumableOrder.PAYMENT_Method_Code__c = 'POINT';
                                }
                            } 
                            else {
                                if (paymentDetails[paymentDetails.size() - 1].DEPOSIT_TYPE__c == 'B') {
                                    soldOutConsumableOrder.PAYMENT_Method_Code__c = 'CARD';
                                    if (soldOutConsumableOrder.PAYMENT_TYPE__c == null) {
                                        soldOutConsumableOrder.PAYMENT_TYPE__c = 'CARD';
                                    }
                                } 
                                else if (paymentDetails[paymentDetails.size() - 1].DEPOSIT_TYPE__c == 'E') {
                                    if (paymentDetails[paymentDetails.size() - 1].UPAD_DETAIL_TYPE__c == 'PG_VBANK') {
                                        if (soldOutConsumableOrder.PAYMENT_TYPE__c != null) {
                                            if (soldOutConsumableOrder.PAYMENT_TYPE__c == null) {
                                                soldOutConsumableOrder.PAYMENT_TYPE__c = 'URL';
                                            }
                                        }
                                    }
                                } 
                                else if (paymentDetails[paymentDetails.size() - 1].DEPOSIT_TYPE__c == 'D') {
                                    soldOutConsumableOrder.PAYMENT_Method_Code__c = 'POINT';
                                }
                            }
                            soldOutConsumableOrder.PAYMENT_REQUEST_DATE__c = paymentDetails[0].CreatedDate;
                        }
                    }
                } 
                else {
                    // 교환 주문 일 때
                    soldOutConsumableOrder.Consumables_Business_Type_Code__c = 'ExchangeOrder';
                }

                // 고객 명
                soldOutConsumableOrder.Order_CUST_Name__c = orderContact.Name != null ? orderContact.Name : orderContact.LastName;
                // 고객 전화번호1
                soldOutConsumableOrder.Order_CUST_TPNO_1__c = orderContact.MobilePhone;
                // 고객 전화번호2
                soldOutConsumableOrder.Order_CUST_TPNO_2__c = orderContact.Phone;
                // 고객 주소
                soldOutConsumableOrder.Order_CUST_Address__c = orderContact.ADDRESS_NEW__c != null ? orderContact.ADDRESS_NEW__c : orderContact.ADDRESS_OLD__c;
                // 고객 상세 주소
                // soldOutConsumableOrder.Order_CUST_Address_DETAIL__c = orderContact.ADDRESS_DETAIL__c;
                soldOutConsumableOrder.Order_CUST_Address_DETAIL__c = orderContact.ADDRESS_NEW__c != null ? orderContact.ADDRESS_ROAD_ETC__c : orderContact.ADDRESS_DETAIL__c; //24 02 01 hyungho.chun 상세주소 신주소일시 불러오는 필드 다름
                soldOutConsumableOrder.Delivery_Message_CONTENT__c = requestedTerm;

                // 수취인 주소
                if (!isContactSame) {
                    // 수취인 명
                    soldOutConsumableOrder.CONSIGNEE_Name__c = consigneeName;
                    // 수취인 전화번호1
                    soldOutConsumableOrder.CONSIGNEE_TPNO_1__c = IbCallNo;
                    // 수취인 전화번호2
                    soldOutConsumableOrder.CONSIGNEE_TPNO_2__c = IbCallNo;

                    // 수취인 주소
                    //soldOutConsumableOrder.CONSIGNEE_Address__c = newAddress + ' ' + detailAddress;
                    soldOutConsumableOrder.CONSIGNEE_Address__c = newAddress;
                    // 수취인 상세 주소
                    soldOutConsumableOrder.CONSIGNEE_Address_DETAIL__c = String.isEmpty(detailAddress) ? '( )' : detailAddress;
                    soldOutConsumableOrder.Delivery_Message_CONTENT__c = requestedTerm;
                } 
                else {
                    // 수취인 명
                    soldOutConsumableOrder.CONSIGNEE_Name__c = orderContact.Name != null ? orderContact.Name : orderContact.LastName;
                    // 수취인 전화번호1
                    soldOutConsumableOrder.CONSIGNEE_TPNO_1__c = orderContact.MobilePhone;
                    // 수취인 전화번호2
                    soldOutConsumableOrder.CONSIGNEE_TPNO_2__c = orderContact.Phone;
                    // 수취인 주소
                    soldOutConsumableOrder.CONSIGNEE_Address__c = orderContact.ADDRESS_NEW__c != null ? orderContact.ADDRESS_NEW__c : orderContact.ADDRESS_OLD__c;
                    // soldOutConsumableOrder.CONSIGNEE_Address_DETAIL__c = String.isEmpty(orderContact.ADDRESS_DETAIL__c) ? '( )' : orderContact.ADDRESS_DETAIL__c;
                    soldOutConsumableOrder.CONSIGNEE_Address_DETAIL__c = orderContact.ADDRESS_NEW__c != null ? (String.isEmpty(orderContact.ADDRESS_ROAD_ETC__c) ? '( )' : orderContact.ADDRESS_ROAD_ETC__c ) : (String.isEmpty(orderContact.ADDRESS_DETAIL__c) ? '( )' : orderContact.ADDRESS_DETAIL__c); //24 02 01 hyungho.chun 상세주소 신주소일시 불러오는 필드 다름

                    soldOutConsumableOrder.Delivery_Message_CONTENT__c = requestedTerm;
                }

                // 수취인 우편번호. zoneCode 인입 시
                // 고객=수취인 -> Contact.POSTAL_CODE__c
                // 고객!=수취인 -> 주소검색 시 인입 된 우편번호 설정 되어있음
                soldOutConsumableOrder.CONSIGNEE_PostalCode__c = zoneCode;

                // 품절주문 ProductRequest에 CaseId 추가
                System.debug('isManagement@@@@@@' + isManagement);
                if(!isManagement) {
                    if (strCaseId != '') {
                        soldOutConsumableOrder.CaseId = strCaseId;
                        System.debug('soldOutConsumableOrder Case Id Set 확인 : ' + soldOutConsumableOrder.CaseId);
                    }
                }

                // 소모품 주문 실제 사용 여부
                soldOutConsumableOrder.Consumables_Order_USE_YN__c = isTemporary ? false : true;

                if (isManagement) {
                    // 판매 금액
                    soldOutConsumableOrder.SALE_Amount__c = soldOutOrderTotalPaymentAmount;
                    // 할인 금액
                    soldOutConsumableOrder.Discount_Amount__c = soldOutOrderTotalDiscountAmount;
                    // 결제 금액
                    soldOutConsumableOrder.PAYMENT_Amount__c = soldOutOrderTotalPaymentAmount - soldOutOrderTotalDiscountAmount;
                } else {
                    // 판매 금액
                    soldOutConsumableOrder.SALE_Amount__c = soldOutOrderTotalSalesAmount;
                    // 할인 금액
                    soldOutConsumableOrder.Discount_Amount__c = soldOutOrderTotalDiscountAmount;
                    // 결제 금액                    
                    soldOutConsumableOrder.PAYMENT_Amount__c = soldOutOrderTotalSalesAmount - soldOutOrderTotalDiscountAmount;
                }

                //24 01 25 hyungho.chun 품절+100%할인경우 결제방식에 VIP할인 넣음
                if ((soldOutConsumableOrder.SALE_Amount__c == soldOutConsumableOrder.Discount_Amount__c) && soldOutConsumableOrder.Discount_Amount__c != 0 && !isExchangeOrder) {
                    soldOutConsumableOrder.PAYMENT_Method_Code__c = 'DISCOUNT';
                    soldOutConsumableOrder.PAYMENT_REQUEST_DATE__c = system.now();
                    soldOutConsumableOrder.PAYMENT_COMPLETED_DTM__c = system.now();
                }

                //24 02 13 hyungho.chun 품절주문에도 Department_Code__c에 PH8002기입
                soldOutConsumableOrder.Department_Code__c = 'PH8002';
                //24 03 13 seung yoon heo 품절주문에도 Department_Id__c기입
                soldOutConsumableOrder.Department_Id__c = consumableCenter.Id;
                    
                                
                consumableOrderMap.put(SOLD_OUT_ORDER, soldOutConsumableOrder);
            }

            System.debug('consumableOrderMap.get(STANDARD_ORDER) :: ' + consumableOrderMap.get(STANDARD_ORDER));
            System.debug('isTemporary :: ' + isTemporary);
            System.debug('isExchangeOrder :: ' + isExchangeOrder);

            if (consumableOrderMap.get(STANDARD_ORDER) != null && isTemporary == false && !isExchangeOrder) {
                String jsonStr = JSON.serialize(consumableOrderMap.get(STANDARD_ORDER));

                doSetPaymentData(stdOrderNumberMap.keySet(), jsonStr);
                System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (doSetPaymentData):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

            }
            if (isManagement == false) {
                System.debug('consumableOrderMap.values() 값 비교용 :::' + consumableOrderMap.values());
                System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (upsert consumableOrderMap)전:' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                upsert consumableOrderMap.values();
                System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (upsert consumableOrderMap)후:' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            }

            /** 2023-05-18 ysh 주문번호 채번 로직 변경 (AutoNumber 이용) */
            List<String> prIdList = new List<String>();
            for (ProductRequest pr : consumableOrderMap.values()) {
                prIdList.add(pr.Id);
            }

            /** 2023-05-20 교환 주문시 타 채널(OBS, ThinQ)의 경우 주문번호 원주문-E1 로 채번 */
            String originProductRequestId = null;
            String originOrderNumber = null;

            if (isExchangeOrder) {
                originProductRequestId = (String) paramMap.get('originProductRequestId');
                List<ProductRequest> prs = [
                        SELECT Order_Number__c
                        FROM ProductRequest
                        WHERE Id = :originProductRequestId
                        LIMIT 1
                ];
                // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (query ProductRequest):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                originOrderNumber = prs[0].Order_Number__c;
            }

            List<ProductRequest> updatePrList = new List<ProductRequest>();
            if (!prIdList.isEmpty()) {
                //23 01 03 hyungho.chun 교환주문 채번로직 항상 E1에서 E+해당주문교환주문시퀀스
                Integer exchangeOrderCount = [SELECT Id FROM ProductRequestLineItem 
                                            WHERE Consumables_Business_Type_Code__c = 'ExchangeOrder' 
                                            AND RecordType.DeveloperName = 'Consumable' 
                                            AND BASIS_Order_Item_Id__r.Order_Number__c =: originOrderNumber].size();
                updatePrList = [SELECT Id, Order_Number__c, Consumables_Order_Number__c, Order_CHNL_TYPE_Code__c, Consumables_Order_Class_Code__c, caseId FROM ProductRequest WHERE Id IN :prIdList];
                if (!updatePrList.isEmpty()) {
                    String year = String.valueOf(system.today().year()).right(2);
                    for (ProductRequest upr : updatePrList) {
                        if (upr.Order_CHNL_TYPE_Code__c == EX_ConsumableUtil.CONSUMABLE_CIC) {
                            upr.Order_Number__c = 'O' + year + upr.Consumables_Order_Number__c;
                        } else {
                            upr.Order_Number__c = originOrderNumber + '-E'+String.valueOf(exchangeOrderCount+1); //23 01 03 hyungho.chun 교환주문 채번로직 항상 E1에서 E+해당주문교환주문시퀀스
                        }
                    }
                    update updatePrList;
                }
                // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (update updatePrList):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            }

            // Set<String> consumableOrderMapSet = new Set<String>();

            // for (ProductRequest productRequest : consumableOrderMap.values()) {
            //     consumableOrderMapSet.add(productRequest.Id);
            // }

            // String strQry = '';
            // strQry += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequest');
            // strQry += ' FROM ProductRequest ';
            // strQry += ' WHERE Id IN :consumableOrderMapSet ';

            // List<ProductRequest> productRequests = Database.query(strQry);
            
            // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (query ProductRequest2):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            System.debug('xxx'+productRequest.Consumables_Order_Class_Code__c);
            System.debug('yyyy'+soldOutConsumableOrderId);
            Map<String, ProductRequest> afterDMLConsumableOrderMap = new Map<String, ProductRequest>();
            if (updatePrList.size() > 0 ) {
                for (ProductRequest productRequest : updatePrList) {
                    if (productRequest.Consumables_Order_Class_Code__c == 'General') {
                        afterDMLConsumableOrderMap.put(STANDARD_ORDER, productRequest);
                    } else if (productRequest.Consumables_Order_Class_Code__c == 'Sold Out') {
                        afterDMLConsumableOrderMap.put(SOLD_OUT_ORDER, productRequest);
                    } else if (productRequest.Consumables_Order_Class_Code__c == PO) {
                        afterDMLConsumableOrderMap.put(PO, productRequest);
                    }
                    if(isManagement == true && soldOutConsumableOrderId != null){
                        afterDMLConsumableOrderMap.put(SOLD_OUT_ORDER, productRequest);
                    }
                }
            }

            // 일반 주문 품목이 존재 할 때
            ProductRequest stdPr;
            List<ProductRequestLineItem> consumableOrderItems = new List<ProductRequestLineItem>();
            List<ProductRequestLineItem> consumablePOItems = new List<ProductRequestLineItem>();
            boolean paymentYN;


            List<SM_DIV__c> smList = [SELECT Id, DIV_CODE__c FROM SM_DIV__c];
            Map<Id, String> smMap = new Map<Id, String>();
            for (SM_DIV__c item : smList) {
                smMap.put(item.Id, item.DIV_CODE__c);
            }

            // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (standardOrderDataList.size()-' + standardOrderDataList.size() + '):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            if (standardOrderDataList.size() > 0) {
                // 주문 항번
                Integer ORDER_SEQ = 0;
                if(isManagement == true && soldOutConsumableOrderId != null) {
                    System.debug('00000'+afterDMLConsumableOrderMap);
                    stdPr = afterDMLConsumableOrderMap.get(SOLD_OUT_ORDER);
                }else{
                    stdPr = afterDMLConsumableOrderMap.get(STANDARD_ORDER);
                }

                SR_PRE_PAYMENT_DETAIL__c paymentDetail = new SR_PRE_PAYMENT_DETAIL__c();
                if([SELECT ID, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c, POINT_TRX_ID__c FROM SR_PRE_PAYMENT_DETAIL__c WHERE SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = :stdPr.Order_Number__c and PAYMENT_AREA_NO__c = 2].size() != 0){
                    paymentDetail = [SELECT TID__c, ID, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c, POINT_TRX_ID__c, MOID__c FROM SR_PRE_PAYMENT_DETAIL__c WHERE SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = :stdPr.Order_Number__c and PAYMENT_AREA_NO__c = 2 LIMIT 1];
                }

                //20230707 for문밖으로 dml 빼냄
                List<SR_PRE_PAYMENT_HEADER__c> paymentHeaderList = [SELECT Id, BASIS_NO__c, (SELECT MOID__c, CARD_URL__c, ISSUE_CARD_INFO__c, ISSUE_CARD_NAME__c, INVOICE_ISSUE_TYPE__c, ID, PAY_CUST_PHONE__c, CERTIFY_KEY__c, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c, MID__c FROM SR_PAYMENT_HIST_DETAILS__r order by PAYMENT_AREA_NO__c) FROM SR_PRE_PAYMENT_HEADER__c WHERE BASIS_NO__c IN :stdOrderNumberMap.keySet() Limit 1];
                
                //23 08 07 hyungho.chun 현장카드+포인트시 현장카드금액추가용 쿼리
                List<String> tempPrliIdSet = new List<String>();
                for (Integer i = 0; i < standardOrderDataList.size(); i++) {
                    tempPrliIdSet.add(standardOrderDataList.get(i).Id);
                }
                Map<Id, ProductRequestLineItem> tempMap = new Map<Id,ProductRequestLineItem>([SELECT Id, POINT_Amount__c FROM ProductRequestLineItem WHERE Id IN :tempPrliIdSet]);

                // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (query SR_PRE_PAYMENT_HEADER__c):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                ProductRequestLineItem stdConsumableOrderItem;

                //23.08.10 gw.lee
                //Transaction PMD 간소화
                DateTime deliveryDate = getDeliveryDate();

                for (ItemTable item : standardOrderDataList) {
                    if (isTemporary == false && isExchangeOrder == false) {
                        stdConsumableOrderItem = new ProductRequestLineItem(Id = item.Id);
                        if (item.ResrvNumber != null) {
                            stdConsumableOrderItem.RSRV_Number__c = item.ResrvNumber;
                        }
                        System.debug('예약 : ' + item.ResrvNumber);

                    } else {
                        stdConsumableOrderItem = new ProductRequestLineItem();
                        // 소모품 주문 Id
                        stdConsumableOrderItem.ParentId = stdPr.Id;
                    }
                    // todo : 소모품 레코드 타입 추가 필요
                    stdConsumableOrderItem.RecordTypeId = EX_ConsumableUtil.PRLI_CONSUMABLE_RECORDTYPE_ID;
                    if (kBasisOrderIdOrderSeqMap.containsKey(item.productRequestLineItemId)) {
                        stdConsumableOrderItem.Order_SEQ__c = kBasisOrderIdOrderSeqMap.get(item.productRequestLineItemId);
                    } else {
                        stdConsumableOrderItem.Order_SEQ__c = ++ORDER_SEQ;
                    }

                    // ProductRequest LineItem에 ProductRequest의 CaseId 추가
                    if (stdPr.CaseId != null) {
                        stdConsumableOrderItem.CaseId = stdPr.CaseId;
                        System.debug('stdConsumableOrderItem Case Id 확인 : ' + stdConsumableOrderItem.CaseId);
                    }

                    // 소모품 주문 번호
                    stdConsumableOrderItem.Order_Number__c = stdPr.Order_Number__c;

                    // 소모품 주문 여부
                    stdConsumableOrderItem.Consumables_Order_YN__c = true;
                    // 소모품 주문 구분
                    stdConsumableOrderItem.Consumables_Order_Class_Code__c = 'General';
                    stdConsumableOrderItem.Online_SALE_Url__c = item.ObsSalesURL;
                    stdConsumableOrderItem.Online_SALE_YN__c = item.OBS_ITEM_YN == 'Y' ? true : false;
                            // 부서 코드
                    stdConsumableOrderItem.Department_Code__c = 'PH8002';
                    // 소모품 업무 유형
                    if (!isExchangeOrder) {
                        stdConsumableOrderItem.Consumables_Business_Type_Code__c = 'Order';
                    } else {
                        // 교환 주문 일 때
                        stdConsumableOrderItem.Consumables_Business_Type_Code__c = 'ExchangeOrder';
                        stdConsumableOrderItem.BASIS_Order_Item_Id__c = item.productRequestLineItemId;
                        // 교환요청부서코드
                        stdConsumableOrderItem.Exchange_Request_Department_Code__c = deptCode;
                        // 교환요청일시
                        stdConsumableOrderItem.Exchange_Request_DTM__c = System.now();
                        // 교환요청자ID
                        stdConsumableOrderItem.Exchange_Requester_Id__c = UserInfo.getUserId();
                        // 교환 수량
                        stdConsumableOrderItem.Exchange_Quantity__c = item.QTY;

                        // 23.05.22 / 교환요청시 최초 주문시의 단가 금액과 교환요청시 단가 금액이 다른 경우 잡이익 금액 세팅
                        // 잡이익금액

                        if (item.Price == null) item.Price = 0;
                        if (item.originConsumerPrice == null) item.originConsumerPrice = 0;

                        Decimal priceAmount = item.Price * item.QTY;
                        Decimal originPriceAmount = item.originConsumerPrice * item.QTY;

                        System.debug('originPriceAmount -> ' + originPriceAmount);
                        System.debug('priceAmount -> ' + priceAmount);

                        stdConsumableOrderItem.Extra_Profit_Amount__c = originPriceAmount - priceAmount;
                        System.debug('Extra_Profit_Amount__c -> ' + stdConsumableOrderItem.Extra_Profit_Amount__c);
                    }

                    // 소모품 주문 채널
                    stdConsumableOrderItem.Order_CHNL_TYPE_Code__c = orderChannelType;
                    // 소모품 주문 고객 Contact Id
                    stdConsumableOrderItem.Order_CUST_Id__c = contactId;

                    stdConsumableOrderItem.SourceLocationId = consumableWareHouseId;
                    // 소모품 주문 품목의 사업부 코드
                    stdConsumableOrderItem.ENDP_Code__c = item.DIVCODE;
                    //출고부서코드
                    if (item.ShipmentCode != null) {
                        stdConsumableOrderItem.SHIPPED_Department_Code__c = item.ShipmentCode;

                    }
                    // Product
                    // 소모품 주문 품목의 파트 Id
                    stdConsumableOrderItem.Product2Id = item.sProductId;
                    // 소모품 주문 품목이 재고 Id
                    stdConsumableOrderItem.ProductItem__c = item.sProductItemId;

                    // 소모품 주문 품목의 파트 넘버 요청 Part No
                    stdConsumableOrderItem.BASIS_Parts_Number__c = item.ProductCode;
                    // 소모품 주문 품목의 파트 넘버
                    stdConsumableOrderItem.PART_NO__c = item.ProductCode;

                    // 소모품 주문 품목의 요청 수량
                    stdConsumableOrderItem.QuantityRequested = item.QTY;
                    // 소모품 주문 품목의 판매 수량
                    stdConsumableOrderItem.SALE_Quantity__c = item.QTY;
                    // 소모품 주문 품목의 소비자가
                    stdConsumableOrderItem.CONSUMER_Price__c = item.Price;
                    // 소모품 주문 품목의 지점정가
                    stdConsumableOrderItem.ASC_Price__c = item.ASCPrice;
                    //23.12.04 gw.lee 재경 요청 UnitPrice 필요 //23 12 07 hyungho.chun UnitPrice__c 판매저장때 계산해서넣어줌
                    // stdConsumableOrderItem.UnitPrice__c = item.Price;                    
                    // 주문 생성시 기본 상태 주문요청
                    if(isTemporary){
                        stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_001;
                    }
                    // 소모품 주문 품목의 모델 Id
                    if (item.ModelId != null) {
                        stdConsumableOrderItem.MODEL__c = item.ModelId;
                    }
                    stdConsumableOrderItem.MODEL_CODE__c = item.Model; // 24 02 23 PHJ

                    // Location
                    // 소모품 주문 품목의 대상 위치 Id
                    //consumableOrderItem.DestinationLocationId = item.sLocationId;
                    // 소모품 주문 품목의 소스 위치 Id
                    if (item.sLocationId != null) {
                        stdConsumableOrderItem.SourceLocationId = consumableWareHouseId;
                    }

                    if (item.PromotionPrice == null) item.PromotionPrice = 0;

                    if (!isExchangeOrder) {
                        // 판매 금액
                        if (ContactVIP != 0) {
                            stdConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;

                            if (item.PromotionPrice != null && item.PromotionPrice != 0) {
                                if (item.Price * item.QTY * ContactVIP < item.PromotionPrice * item.QTY) {
                                    stdConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.Price * item.QTY * ContactVIP;
                                    stdConsumableOrderItem.VIP_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                                    stdConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                                    stdConsumableOrderItem.SALE_Discount_Type_Code__c = 'V';
                                    stdConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;

                                } else {
                                    stdConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                                    stdConsumableOrderItem.PROMOTION_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                                    stdConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                                    stdConsumableOrderItem.SALE_Discount_Type_Code__c = 'P';
                                    stdConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;

                                }
                            } else {
                                stdConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.Price * item.QTY * ContactVIP;
                                stdConsumableOrderItem.VIP_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                                stdConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                                stdConsumableOrderItem.SALE_Discount_Type_Code__c = 'V';
                                stdConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;

                            }
                        } else if (item.PromotionPrice != 0) {
                            stdConsumableOrderItem.PAYMENT_Amount__c = item.PromotionPrice * item.QTY;
                            stdConsumableOrderItem.PROMOTION_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                            stdConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                            stdConsumableOrderItem.SALE_Discount_Type_Code__c = 'P';
                            stdConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;


                        } else {
                            stdConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY ;
                            stdConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY;
                            // stdConsumableOrderItem.VIP_Discount_Amount__c = item.Price * item.QTY;
                        }

                        //20230707 DML for문 밖으로 이동
                        // 소모품 주문 품목의 현금,카드,포인트 결제 값
                        //List<SR_PRE_PAYMENT_HEADER__c> paymentHeaderList = [SELECT Id, BASIS_NO__c, (SELECT MOID__c, CARD_URL__c, ISSUE_CARD_INFO__c, ISSUE_CARD_NAME__c, INVOICE_ISSUE_TYPE__c, ID, PAY_CUST_PHONE__c, CERTIFY_KEY__c, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c, MID__c FROM SR_PAYMENT_HIST_DETAILS__r order by PAYMENT_AREA_NO__c) FROM SR_PRE_PAYMENT_HEADER__c WHERE BASIS_NO__c IN :stdOrderNumberMap.keySet() Limit 1];
                        
                        System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (paymentHeaderList.isEmpty()-' + paymentHeaderList.isEmpty() + '):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                        
                        if (!paymentHeaderList.isEmpty()) {
                            List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = new List<SR_PRE_PAYMENT_DETAIL__c>();
                            SR_PRE_PAYMENT_HEADER__c paymentHeader = paymentHeaderList[0];
                            if (paymentHeaderList[0].SR_PAYMENT_HIST_DETAILS__r.size() > 1) {
                                for (SR_PRE_PAYMENT_HEADER__c header : paymentHeaderList) {
                                    for (SR_PRE_PAYMENT_DETAIL__c detail : header.SR_PAYMENT_HIST_DETAILS__r) {
                                        paymentDetails.add(detail);
                                    }
                                }
                            } else {
                                for (SR_PRE_PAYMENT_HEADER__c header : paymentHeaderList) {
                                    paymentDetails.add(header.SR_PAYMENT_HIST_DETAILS__r[0]);
                                }
                            }
                            if (paymentHeader != null) {
                                if (paymentDetails.size() == 1) {
                                    // 현금대리입금
                                    if (paymentDetails[0].DEPOSIT_TYPE__c == 'A') {
                                        stdConsumableOrderItem.CASH_PAYMENT_Amount__c = paymentDetails[0].DEPOSIT_AMT__c;
                                    } else if (paymentDetails[0].DEPOSIT_TYPE__c == 'B') {
                                        //gw.lee 203.08.07
                                        //카드 단일 결제 및 카드 결제 이력이 있을 경우는 결제금액을 그대로 넣어줌
                                        stdConsumableOrderItem.CARD_PAYMENT_Amount__c = item.Price * item.QTY;
                                        stdConsumableOrderItem.PAYMENT_YN__c = true;
                                        paymentYN = true;
                                    } else if (paymentDetails[0].DEPOSIT_TYPE__c == 'E') {
                                        if (paymentDetails[0].UPAD_DETAIL_TYPE__c == 'PG_URL') {
                                            System.debug('item.Price : ' + item.Price + 'item.QTY : ' + item.QTY + 'item.DiscountAmount : ' + item.DiscountAmount);
                                            stdConsumableOrderItem.CARD_PAYMENT_Amount__c = 0;

                                        } else if (paymentDetails[0].UPAD_DETAIL_TYPE__c == 'PG_VBANK') {
                                            stdConsumableOrderItem.CASH_PAYMENT_Amount__c = 0;
                                        }
                                    } else if (paymentDetails[0].DEPOSIT_TYPE__c == 'D') {
                                        stdConsumableOrderItem.PAYMENT_YN__c = true;
                                        paymentYN = true;

			                            stdConsumableOrderItem.fm_deliveryTerm__c = deliveryDate; 
                                    }
                                } else if ((paymentDetails.size() == 2)) {
                                    // 현금대리입금
                                    if (paymentDetails[paymentDetails.size() - 1].DEPOSIT_TYPE__c == 'B') {
                                        //23 08 07 hyungho.chun 현장카드+포인트시 현장카드금액추가
                                        Decimal pointValue = tempMap.get(item.id).POINT_Amount__c;
                                        if(pointValue>0){
                                            stdConsumableOrderItem.CARD_PAYMENT_Amount__c = item.Price * item.QTY - pointValue;
                                            stdConsumableOrderItem.PAYMENT_YN__c = true;
                                        }
                                        //결제 URL
                                    }
                                    if (paymentDetails[0].DEPOSIT_TYPE__c == 'D') {
                                       
			                            stdConsumableOrderItem.fm_deliveryTerm__c = deliveryDate; 
                                    }
                                } else {
                                    stdConsumableOrderItem.SALE_Amount__c = 0;
                                    stdConsumableOrderItem.PAYMENT_Amount__c = 0;
                                    //할인 유형
                                    stdConsumableOrderItem.Discount_Type_Code__c = '직원할인';
                                }
                            }
                        }
                        // 결제 금액
                    } else {
                        // 교환주문 인 경우
                        stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006;
                        stdConsumableOrderItem.Appointment_Status__c = '입고완료';

                        stdConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;
                    }
                        // 소모품 결제 Id
                    stdConsumableOrderItem.MOID__c = paymentDetail.MOID__c != null ? paymentDetail.MOID__c : '';
                    stdConsumableOrderItem.TID__c = paymentDetail.TID__c != null ? paymentDetail.TID__c : '';
                    // 소모품 요청자의 소속 부서 코드
                    stdConsumableOrderItem.Requester_Department_Code__c = deptCode;
                    if (item.discountType != null) {
                        if (item.discountType == '임직원') {
                            stdConsumableOrderItem.SALE_Discount_Type_Code__c = 'E';
                            stdConsumableOrderItem.Employees_Discount_Amount__c = item.DiscountAmount;
                            stdConsumableOrderItem.Last_Discount_Amount__c = item.DiscountAmount;
                            stdConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.DiscountAmount;

                        } else if (item.discountType == 'VIP') {
                            stdConsumableOrderItem.SALE_Discount_Type_Code__c = 'V';
                            stdConsumableOrderItem.VIP_Discount_Amount__c = item.DiscountAmount;
                            stdConsumableOrderItem.Last_Discount_Amount__c = item.DiscountAmount;
                            stdConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.DiscountAmount;

                        } else if (item.discountType == '프로모션' && item.DiscountAmount != 0) {
                            stdConsumableOrderItem.SALE_Discount_Type_Code__c = 'P';
                            stdConsumableOrderItem.PROMOTION_Discount_Amount__c = item.DiscountAmount;
                            stdConsumableOrderItem.Last_Discount_Amount__c = item.DiscountAmount;
                            stdConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.DiscountAmount;

                        }
                    }
                    if (!isExchangeOrder) {
                        System.debug('123123 '+consumableOrderMap.get(STANDARD_ORDER));
                        // if (consumableOrderMap.get(STANDARD_ORDER).PAYMENT_YN__c == true || paymentYN == true) {
                        if ((consumableOrderMap.get(STANDARD_ORDER).PAYMENT_YN__c == true && consumableOrderMap.get(STANDARD_ORDER).PAYMENT_TYPE__c != 'CARD') || paymentYN == true //24 03 09 hyungho.chun consumableOrderMap.get(STANDARD_ORDER).PAYMENT_TYPE__c != 'CARD' 추가 (현장카드는 smartro_payment trigger에서 상태업데이트)
                         || (consumableOrderMap.get(STANDARD_ORDER).SALE_Amount__c == consumableOrderMap.get(STANDARD_ORDER).Discount_Amount__c && consumableOrderMap.get(STANDARD_ORDER).PAYMENT_Amount__c == 0 )) { //24 01 05 hyungho.chun 판매금액=할인금액 and 결제금액0 인경우도 (vip 100%할인) 태워야한다
                            if (item.ShipmentCode != null) {
                                if (smMap.values().contains(item.ShipmentCode)) {
                                    stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_002;
                                } else {
                                    stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006;
                                    stdConsumableOrderItem.Appointment_Status__c = '입고완료';
                                }
                            } else {
                                stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006;
                                stdConsumableOrderItem.Appointment_Status__c = '입고완료';
                            }
                        } else {
                            if (item.ShipmentCode == 'PH8002') {
                                stdConsumableOrderItem.Appointment_Status__c = '입고완료';
                            }
                        }
                    } else {
                        if (item.ShipmentCode != null) {
                            if (smMap.values().contains(item.ShipmentCode)) {
                                stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_002;
                            } else {
                                stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006;
                                stdConsumableOrderItem.Appointment_Status__c = '입고완료';
                            }
                        } else {
                            stdConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006;
                            stdConsumableOrderItem.Appointment_Status__c = '입고완료';
                        }
                    }
                    consumableOrderItems.add(stdConsumableOrderItem);

                    // 서브번호 채번을 위해 일반주문 레코드 저장
                    lineItemList.add(stdConsumableOrderItem);
                }
            }

            // 품절 주문 품목이 존재 할 때
            ProductRequest soPr;
            ProductRequest POPr;
            
            // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (soldOutOrderDataList.size()-' + soldOutOrderDataList.size() + '):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            if (soldOutOrderDataList.size() > 0) {
                soPr = afterDMLConsumableOrderMap.get(SOLD_OUT_ORDER);
                ProductRequestLineItem soConsumableOrderItem;
                ProductRequestLineItem consumablePOItem;

                // 예약 항번
                Integer RSRV_SEQ = 0;
                // 주문 항번
                Integer ORDER_SEQ = 0;
                for (ItemTable item : soldOutOrderDataList) {
                    System.debug('isTemporary -> ' + isTemporary);
                    System.debug('isExchangeOrder -> ' + isExchangeOrder);

                    if (isTemporary == false && isExchangeOrder == false) {
                        soConsumableOrderItem = new ProductRequestLineItem(Id = item.Id);
                    } else {
                        System.debug('soPr ->>>>>>> ' + soPr);
                        soConsumableOrderItem = new ProductRequestLineItem();
                        // 소모품 주문 Id
                        soConsumableOrderItem.ParentId = soPr.Id;
                    }

                    // todo : 소모품 레코드 타입 추가 필요
                    soConsumableOrderItem.RecordTypeId = EX_ConsumableUtil.PRLI_CONSUMABLE_RECORDTYPE_ID;
                    if (kBasisOrderIdOrderSeqMap.containsKey(item.productRequestLineItemId)) {
                        soConsumableOrderItem.Order_SEQ__c = kBasisOrderIdOrderSeqMap.get(item.productRequestLineItemId);
                    } else {
                        soConsumableOrderItem.Order_SEQ__c = ++ORDER_SEQ;
                    }
                    // soConsumableOrderItem.Order_SEQ__c = ++ORDER_SEQ;

                    // ProductRequest LineItem에 ProductRequest의 CaseId 추가
                    if (soPr.CaseId != null) {
                        soConsumableOrderItem.CaseId = soPr.CaseId;
                        System.debug('soConsumableOrderItem.CaseId 확인 : ' + soConsumableOrderItem.CaseId);
                    }

                    // 소모품 주문 번호
                    soConsumableOrderItem.Order_Number__c = soPr.Order_Number__c;

                    // 소모품 주문 여부
                    soConsumableOrderItem.Consumables_Order_YN__c = true;
                    // 소모품 주문 구분
                    soConsumableOrderItem.Consumables_Order_Class_Code__c = 'Sold Out';
                    // 부서 코드
                    soConsumableOrderItem.Department_Code__c = 'PH8002';

                    // 소모품 업무 유형
                    // 소모품 업무 유형
                    if (!isExchangeOrder) {
                        soConsumableOrderItem.Consumables_Business_Type_Code__c = 'Order';
                    } else {
                        // 교환 주문 일 때
                        soConsumableOrderItem.Consumables_Business_Type_Code__c = 'ExchangeOrder';
                        soConsumableOrderItem.BASIS_Order_Item_Id__c = item.productRequestLineItemId;
                        // 교환요청부서코드
                        soConsumableOrderItem.Exchange_Request_Department_Code__c = deptCode;
                        // 교환요청일시
                        soConsumableOrderItem.Exchange_Request_DTM__c = System.now();
                        // 교환요청자ID
                        soConsumableOrderItem.Exchange_Requester_Id__c = UserInfo.getUserId();
                        // 교환 수량
                        soConsumableOrderItem.Exchange_Quantity__c = item.QTY;
                    }
                    // 소모품 주문 채널
                    soConsumableOrderItem.Order_CHNL_TYPE_Code__c = orderChannelType;
                    // 품절주문 예약 상태
                    if (soConsumableOrderItem.Appointment_Status__c == null) {
                        soConsumableOrderItem.Appointment_Status__c = '요청';
                    }

                    // 소모품 주문 상태
                    soConsumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_000;
                    // 소모품 주문 고객 Contact Id
                    soConsumableOrderItem.Order_CUST_Id__c = contactId;
                    // 소모품 주문 품목의 사업부 코드
                    soConsumableOrderItem.ENDP_Code__c = item.DIVCODE;
                    //출고부서코드
                    if (item.ShipmentCode != null) {
                        soConsumableOrderItem.SHIPPED_Department_Code__c = item.ShipmentCode;
                    }
                    // Product
                    // 소모품 주문 품목의 파트 Id
                    soConsumableOrderItem.Product2Id = item.sProductId;
                    // 소모품 주문 품목이 재고 Id
                    soConsumableOrderItem.ProductItem__c = item.sProductItemId;

                    // 소모품 주문 품목의 파트 넘버 요청 Part No
                    soConsumableOrderItem.BASIS_Parts_Number__c = item.ProductCode;
                    // 소모품 주문 품목의 파트 넘버
                    soConsumableOrderItem.PART_NO__c = item.ProductCode;
                    // 소모품 주문 품목의 요청 수량
                    soConsumableOrderItem.QuantityRequested = Item.QTY;
                    // 소모품 주문 품목의 판매 수량
                    soConsumableOrderItem.SALE_Quantity__c = item.QTY;
                    // 소모품 주문 품목의 소비자가
                    soConsumableOrderItem.CONSUMER_Price__c = item.Price;
                    soConsumableOrderItem.ASC_Price__c = item.ASCPrice;
                    //23.12.04 gw.lee 재경 요청 UnitPrice 필요 //23 12 07 hyungho.chun UnitPrice__c 판매저장때 계산해서넣어줌
                    // soConsumableOrderItem.UnitPrice__c = item.Price;                    

                    // 소모품 주문 품목의 모델 Id
                    soConsumableOrderItem.MODEL__c = item.ModelId;
                    soConsumableOrderItem.MODEL_CODE__c = item.Model; // 24 02 23 PHJ
                    System.debug('item.ModelId -> ' + item.ModelId);
                    System.debug('item.Model -> ' + item.Model);

                    // Location
                    // 소모품 주문 품목의 대상 위치 Id
                    //soConsumableOrderItem.DestinationLocationId = item.sLocationId;
                    // 소모품 주문 품목의 소스 위치 Id
                    System.debug('item.sLocationId -> ');
                    System.debug(item.sLocationId);
                    soConsumableOrderItem.SourceLocationId = consumableWareHouseId;


                    // 소모품 주문 품목의 현금,카드,포인트 결제 값
                    if (!isExchangeOrder) {
                        // 결제 금액
                        // 매핑 필요
                        soConsumableOrderItem.PAYMENT_Amount__c = item.QTY * item.Price - (item.DiscountAmount != null ? item.DiscountAmount : 0);
                        soConsumableOrderItem.Last_Discount_Amount__c = item.DiscountAmount != null ? item.DiscountAmount : 0;
                    }

                    // 판매 금액
                    soConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;
                    // soConsumableOrderItem.Last_Discount_Amount__c = soldOutOrderTotalDiscountAmount;
                    if (item.PromotionPrice == null) item.PromotionPrice = 0;

                    //24 02 15 hyungho.chun doTemporarySaveOrder에서만 필요한로직
                    //doTemporarySaveOrder와 doSaveOrder가 쪼개졌으니 이부분은 불필요하다
                    // if (ContactVIP != 0) {
                    //     soConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;

                    //     if (item.PromotionPrice != null && item.PromotionPrice != 0) {
                    //         if (item.Price * item.QTY * ContactVIP < item.PromotionPrice * item.QTY) {
                    //             soConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.Price * item.QTY * ContactVIP;
                    //             soConsumableOrderItem.VIP_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                    //             soConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                    //             soConsumableOrderItem.SALE_Discount_Type_Code__c = 'V';
                    //             soConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;

                    //         } else {
                    //             soConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                    //             soConsumableOrderItem.PROMOTION_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                    //             soConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                    //             soConsumableOrderItem.SALE_Discount_Type_Code__c = 'P';
                    //             soConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;

                    //         }
                    //     } else {
                    //         soConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY - item.Price * item.QTY * ContactVIP;
                    //         soConsumableOrderItem.VIP_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                    //         soConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY * ContactVIP;
                    //         soConsumableOrderItem.SALE_Discount_Type_Code__c = 'V';
                    //         soConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;

                    //     }
                    // } else if (item.PromotionPrice != 0) {
                    //     soConsumableOrderItem.PAYMENT_Amount__c = item.PromotionPrice * item.QTY;
                    //     soConsumableOrderItem.PROMOTION_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                    //     soConsumableOrderItem.Last_Discount_Amount__c = item.Price * item.QTY - item.PromotionPrice * item.QTY;
                    //     soConsumableOrderItem.SALE_Discount_Type_Code__c = 'P';
                    //     soConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY;


                    // } else {
                    //     soConsumableOrderItem.SALE_Amount__c = item.Price * item.QTY ;
                    //     soConsumableOrderItem.PAYMENT_Amount__c = item.Price * item.QTY;
                    // }
                    
                    System.debug('item.discountType : ' + item.discountType);
                    // if (item.discountType != null) {
                    //     if (item.discountType == '임직원') {
                    //         soConsumableOrderItem.SALE_Discount_Type_Code__c = 'E';
                    //         soConsumableOrderItem.Employees_Discount_Amount__c = item.DiscountAmount;
                    //         soConsumableOrderItem.PAYMENT_Amount__c -= item.DiscountAmount;
                    //     } else if (item.discountType == 'VIP') {
                    //         soConsumableOrderItem.SALE_Discount_Type_Code__c = 'V';
                    //         soConsumableOrderItem.VIP_Discount_Amount__c = item.DiscountAmount;
                    //     } else if (item.discountType == '프로모션') {
                    //         soConsumableOrderItem.SALE_Discount_Type_Code__c = 'P';
                    //         soConsumableOrderItem.PROMOTION_Discount_Amount__c = item.DiscountAmount;
                    //     }
                    // }
                    //24 02 15 hyungho.chun doTemporarySaveOrder에서만 필요한로직

                    if (soConsumableOrderItem.PAYMENT_TYPE__c != 'URL')
                        // 소모품 주문 품목의 선 결제 여부
                        soConsumableOrderItem.PAYMENT_YN__c = isBeforePaymentYN ? true : false;
                    else
                            soConsumableOrderItem.PAYMENT_YN__c = false;


                    // 소모품 요청자의 소속 부서 코드
                    soConsumableOrderItem.Requester_Department_Code__c = deptCode;


                    // 택배 수취인 관련 정보
                    if (!isContactSame) {
                        // 수취인 명
                        soConsumableOrderItem.CONSIGNEE_Name__c = consigneeName;
                        // 수취인 전화번호1
                        soConsumableOrderItem.CONSIGNEE_TPNO_1__c = IbCallNo;
                        // 수취인 전화번호2
                        soConsumableOrderItem.CONSIGNEE_TPNO_2__c = IbCallNo;
                        // 수취인 주소
                        soConsumableOrderItem.CONSIGNEE_Address__c = newAddress;
                        soConsumableOrderItem.CONSIGNEE_Address_DETAIL__c = String.isEmpty(detailAddress) ? '( )' : detailAddress;

                        soConsumableOrderItem.Delivery_Message_CONTENT__c = requestedTerm;
                    } else {
                        // 수취인 명
                        soConsumableOrderItem.CONSIGNEE_Name__c = orderContact.Name != null ? orderContact.Name : orderContact.LastName;
                        // 수취인 전화번호1
                        soConsumableOrderItem.CONSIGNEE_TPNO_1__c = orderContact.MobilePhone;
                        // 수취인 전화번호2
                        soConsumableOrderItem.CONSIGNEE_TPNO_2__c = orderContact.Phone;
                        // 수취인 주소
                        soConsumableOrderItem.CONSIGNEE_Address__c = orderContact.ADDRESS_NEW__c != null ? orderContact.ADDRESS_NEW__c : orderContact.ADDRESS_OLD__c;
                        // soConsumableOrderItem.CONSIGNEE_Address_DETAIL__c = String.isEmpty(orderContact.ADDRESS_DETAIL__c) ? '( )' : orderContact.ADDRESS_DETAIL__c ;
                        soConsumableOrderItem.CONSIGNEE_Address_DETAIL__c = orderContact.ADDRESS_NEW__c != null ? (String.isEmpty(orderContact.ADDRESS_ROAD_ETC__c) ? '( )' : orderContact.ADDRESS_ROAD_ETC__c ) : (String.isEmpty(orderContact.ADDRESS_DETAIL__c) ? '( )' : orderContact.ADDRESS_DETAIL__c); //24 02 01 hyungho.chun 상세주소 신주소일시 불러오는 필드 다름

                        soConsumableOrderItem.Delivery_Message_CONTENT__c = requestedTerm;

                    }

                    consumableOrderItems.add(soConsumableOrderItem);
                    // 서브번호 채번을 위해 일반주문 레코드 저장
                    lineItemList.add(soConsumableOrderItem);
                }
            }
            // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (standardOrderDataList.size()-' + standardOrderDataList.size() + '):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            if(isTemporary == false && standardOrderDataList.size() != 0) {
                List<ProductRequestLineItem> prL = [SELECT POINT_TRX_ID__c, Order_Number__c, POINT_Amount__c FROM ProductRequestLineItem WHERE Order_Number__c =: stdPr.Order_Number__c];
                Map<String, String> trxOrderMap = new Map<String, String>();
               
                /**
                 *   Key : Order_Number__c   values : ProductRequestLineItem List
                 *   포인트 결제가 포함된 주문번호 별 ProductRequestLineItem 리스트
                 */
                Map<String, List<ProductRequestLineItem>> orderNumberPrLiMap = new Map<String, List<ProductRequestLineItem>>();
                // 하기 맵에 저장하기 위한 임시 리스트
                List<ProductRequestLineItem> orderNumberPrLiList = null;

                // TRX_ID가 있는 주문번호별 ProductRequestLineItem List
                for (ProductRequestLineItem prLi : prL) {
                    if (prLi.POINT_TRX_ID__c != null) {
                        trxOrderMap.put(prLi.POINT_TRX_ID__c, prLi.Order_Number__c);
                    } else if (prLi.POINT_TRX_ID__c == null) {
                    	continue;
                    }
                    orderNumberPrLiList = orderNumberPrLiMap.containsKey(prLi.Order_Number__c)
                            ? orderNumberPrLiMap.get(prLi.Order_Number__c)
                            : new List<ProductRequestLineItem>();
                    orderNumberPrLiList.add(prLi);
                    orderNumberPrLiMap.put(prLi.Order_Number__c, orderNumberPrLiList);
                }

                System.debug('trxAmountMap.keySet() : ' + trxOrderMap.keySet());

                /**
                 *  ProductRequestLineItem 품목 2개 생성 시 DETAIL에는 TRX_ID__c가 1개 (TRX A)가 생성된다.
                 *  하지만 품목(LineItem)에는 TRX_ID__c가 2개 (TRX A, TRX B)가 있으므로, TRX_ID 만으로는 생성된
                 *  DETAIL을 식별하기가 어려워 주문번호 별 DETAIL을 식별하는 Map을 생성한다.
                 */
                Map<String, SR_PRE_PAYMENT_DETAIL__c> detailMap = new Map<String, SR_PRE_PAYMENT_DETAIL__c>();
                
                List<SR_PRE_PAYMENT_DETAIL__c> detailList = [
                        SELECT SR_SMARTRO_PAYMENT_REQUEST_ID__c, POINT_TRX_ID__c, PAYMENT_AREA_NO__c, SR_PRE_PAYMENT_HEADER_ID__c, DEPOSIT_TYPE__c, INPUT_TYPE__c, INVOICE_ISSUE_TYPE__c, PAY_CUST_NAME__c, PAY_CUST_PHONE__c, SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c,MBS_CUST_ID__c
                        FROM   SR_PRE_PAYMENT_DETAIL__c
                        WHERE  POINT_TRX_ID__c =: trxOrderMap.keySet()
                ];

                List<SR_SMARTRO_PAYMENT_REQUEST__c> reqList = [
                        SELECT Id, MOID__c
                        FROM   SR_SMARTRO_PAYMENT_REQUEST__c
                        WHERE  MOID__c =: trxOrderMap.keySet()
                ];

                Map<String, Id> trxIdMap = new Map<String, Id>();

                // 원본의 DETAIL TRX_Id를 식별하기 위한 Set
                Set<String> preTrxIdSet = new Set<String>();
                for (SR_SMARTRO_PAYMENT_REQUEST__c req : reqList) {
                    trxIdMap.put(req.MOID__c, req.Id);
                }
                for (SR_PRE_PAYMENT_DETAIL__c detail : detailList) {
                    detailMap.put(detail.SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c, detail);
                    preTrxIdSet.add(detail.POINT_TRX_ID__c);
                }
                List<SR_PRE_PAYMENT_DETAIL__c> newDetailList = new List<SR_PRE_PAYMENT_DETAIL__c>();

                /**
                 *   TRX_ID__c가 있는 Order_Number__c, 즉 포인트가 포함된 주문 건
                 */
                for (String orderNumber : new Set<String>(trxOrderMap.values())) {
                    /**
                     *   POINT_TRX_ID__c는 품목별로 찢어지지만 재경쪽 결제를 거치면
                     *   TRX_ID__c가 단일로 통일되므로 그 건은 Continue를 통해 bypass
                     */
                    for (ProductRequestLineItem prLi : orderNumberPrLiMap.get(orderNumber)) {
                        SR_PRE_PAYMENT_DETAIL__c baseDetail = detailMap.get(orderNumber).clone();
                        if (preTrxIdSet.contains(prLi.POINT_TRX_ID__c)) {
                            baseDetail.DEPOSIT_AMT__c = prLi.POINT_Amount__c;
                        } else {
                            if (baseDetail.PAYMENT_AREA_NO__c == 1) {
                                baseDetail.PAYMENT_AREA_NO__c = 3;
                            } else {
                                baseDetail.PAYMENT_AREA_NO__c = newDetailList.size() + 1;
                            }
                            baseDetail.SR_SMARTRO_PAYMENT_REQUEST_ID__c = trxIdMap.get(prLi.POINT_TRX_ID__c);
                            baseDetail.POINT_TRX_ID__c = prLi.POINT_TRX_ID__c;
                            baseDetail.DEPOSIT_AMT__c = prLi.POINT_Amount__c;
                        }
                        newDetailList.add(baseDetail);
                    }
                }
                delete detailList;
                upsert newDetailList;
            }
            System.debug('start====================');
            System.debug('afterDMLConsumableOrderMap');
            System.debug(afterDMLConsumableOrderMap);
            System.debug('end====================');

            System.debug('lineItemList : ' + lineItemList);

            Map<String, String> proNameKoMap = new Map<String,String>();
            if (isTemporary || isExchangeOrder) {
                // 23.02.20 서브번호 채번
                Map<String, Integer> subNumberMap = EX_ConsumableUtil.getSubNumberMap(lineItemList);

                System.debug('subNumberMap : ' + subNumberMap);
                for (ProductRequestLineItem prLi : consumableOrderItems) {
                    // 서브번호 채번
                    System.debug('prLi : ' + prLi);
                    if (prLi.RecordType.DeveloperName != 'RESV_SALE') {
                        prLi.SUB_Order_Number__c = EX_ConsumableUtil.getSubNumber(subNumberMap, prLi);
                    }
                }
                if (isTemporary) {
                    for (ItemTable stdData : standardOrderDataList) {
                        proNameKoMap.put(stdData.Id, stdData.productName);
                        if (discountType == 'VIP') {
                            stdOrderTotalSalesAmount = stdData.QTY * stdData.Price * ContactVIP;
                        } else if (discountType == '프로모션') {
                            stdOrderTotalSalesAmount = stdData.QTY * stdData.PromotionPrice;
                        }
    
                    }
                    System.debug('stdOrderTotalSalesAmount : ' + stdOrderTotalSalesAmount);
                    for (ItemTable soldData : soldOutOrderDataList) {
                        proNameKoMap.put(soldData.Id, soldData.productName);
                        if (discountType == 'VIP') {
                            soldOutOrderTotalSalesAmount = soldData.QTY * soldData.Price * ContactVIP;
                        } else if (discountType == '프로모션') {
                            soldOutOrderTotalSalesAmount = soldData.QTY * soldData.PromotionPrice;
                        }
                    }
                    System.debug('soldOutOrderTotalSalesAmount : ' + soldOutOrderTotalSalesAmount);
    
                }
            }

            if (!consumablePOItems.isEmpty()) consumableOrderItems.addAll(consumablePOItems);

            Set<String> prLiIdSet = new Set<String>();
            List<ProductRequestLineItem> prLiList = [SELECT Id, SUB_Order_Number__c FROM ProductRequestLineItem WHERE Id IN :prLiIdSet];
            
            // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (query ProductRequestLineItem):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            // if (isManagement == false) {
                // TODO : Bypass 풀 것
            System.debug('consumableOrderItems : ' + consumableOrderItems);
            upsert consumableOrderItems;
            System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (upsert consumableOrderItems):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            // }
            prLiList = [SELECT Id, SUB_Order_Number__c FROM ProductRequestLineItem WHERE Id IN: prLiIdSet];
            
            // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (query ProductRequestLineItem):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

            Set<String> partIdSet = new Set<String>();
            Set<String> locationIdSet = new Set<String>();
            Set<String> insertConsumableOrderItemIdSet = new Set<String>();
            for (ProductRequestLineItem productRequestLineItem : consumableOrderItems) {
                insertConsumableOrderItemIdSet.add(productRequestLineItem.Id);
            }

            // 자재쪽 재고 수불 Method 호출
            List<Map<String, Object>> pListMapRequestInfo = new List<Map<String, Object>>();
            Map<String, Object> mapRequestInfo;

            String strProductRequestLineItemQry = '';
            strProductRequestLineItemQry += 'SELECT Id, ParentId, Order_Number__c, Order_SEQ__c, QuantityRequested, Consumables_Order_Class_Code__c, SHIPPED_Department_Code__c, fm_Consumables_PART_DESC_KOR__c, ';
            strProductRequestLineItemQry += 'BASIS_Order_Item_Id__c,  SourceLocationId, ENDP_Code__c, Product2Id, ProductItem__c, PART_NO__c, RSRV_Number__c, ';
            strProductRequestLineItemQry += 'ASC_Price__c, CONSUMER_Price__c, PROMOTION_Discount_Amount__c, Last_Discount_Amount__c, Consumables_Business_Type_Code__c, SALE_AMOUNT__c ';
            strProductRequestLineItemQry += ' ,Product2.Name, Product2.ProductCode, Product2.PART_DESC_KOR__c, Product2.DIV_CODE__c ';
            strProductRequestLineItemQry += ' ,Product2.Description, Parent.Order_CUST_TPNO_1__c, Parent.Order_CUST_Name__c, Parent.Order_Number__c, MODEL__c, MODEL_Code__c ' +
                    ' ,Parent.Discount_Amount__c, Parent.Sale_Amount__c ';

            strProductRequestLineItemQry += '  FROM ProductRequestLineItem';
            strProductRequestLineItemQry += ' WHERE Id IN :insertConsumableOrderItemIdSet';

            List<ProductRequestLineItem> afterDMLConsumableOrderItems = Database.query(strProductRequestLineItemQry);

            System.debug('afterDMLConsumableOrderItems2 :: => :: ' + afterDMLConsumableOrderItems);
            
            // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (query ProductRequestLineItem):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            Set<String> shippedDeptCodeSet = new Set<String>();
            for (ProductRequestLineItem prli : afterDMLConsumableOrderItems) {
                shippedDeptCodeSet.add(prli.SHIPPED_Department_Code__c);
            }

            List<SM_DIV__c> divList = [
                    SELECT Id, DIV_CODE__c
                    FROM   SM_DIV__c
                    WHERE  DIV_CODE__c IN: shippedDeptCodeSet
            ];

            // System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (query SM_DIV__c):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            Map<String, SM_DIV__c> divMap = new Map<String, SM_DIV__c>();
            for (SM_DIV__c smDiv : divList) {
                divMap.put(smDiv.DIV_Code__c, smDiv);
            }
            // 23.04.03 기존 PO 생성 -> 약속 공통 모듈 호출
            if ((isTemporary == true && !isExchangeOrder) || isExchangeOrder) {
                // List<Map<String, Object>> mapList = new List<Map<String, Object>>();
                // for (ProductRequestLineItem prli : afterDMLConsumableOrderItems) {
                    // if (prli.Consumables_Order_Class_Code__c == 'Sold Out') {
                    //     Map<String, Object> mapItem = new Map<String, Object>();
                    //     mapItem.put('oriPrId', prli.ParentId); //원주문 ProductRequestId
                    //     mapItem.put('oriPrliId', prli.Id); //원주문 ProductRequestLineItemId
                    //     mapItem.put('oriOrderNo', prli.Order_Number__c); //원주문번호
                    //     mapItem.put('oriOrderSeq', prli.Order_SEQ__c); //원주문Seq
                    //     mapItem.put('deptCode', EX_ConsumableUtil.PH8002); //부서코드
                    //     mapItem.put('partNo', prli.Product2.ProductCode); //파트넘버
                    //     mapItem.put('req_qty', prli.QuantityRequested); //요청수량
                    //     mapItem.put('div_code', prli.Product2.DIV_CODE__c); //사업부
                    //     mapList.add(mapItem);
                    // } else if (prli.Consumables_Order_Class_Code__c == 'General' && divMap.containsKey(prli.SHIPPED_Department_Code__c)) {
                    //     Map<String, Object> mapItem = new Map<String, Object>();
                    //     mapItem.put('oriPrId', prli.ParentId); //원주문 ProductRequestId
                    //     mapItem.put('oriPrliId', prli.Id); //원주문 ProductRequestLineItemId
                    //     mapItem.put('oriOrderNo', prli.Order_Number__c); //원주문번호
                    //     mapItem.put('oriOrderSeq', prli.Order_SEQ__c); //원주문Seq
                    //     mapItem.put('deptCode', EX_ConsumableUtil.PH8002); //부서코드
                    //     mapItem.put('partNo', prli.Product2.ProductCode); //파트넘버
                    //     if (reserveMap.get('resrvQuantity') != null) {
                    //         mapItem.put('req_qty', Integer.valueOf(reserveMap.get('resrvQuantity'))); //요청수량
                    //     } else {
                    //         mapItem.put('req_qty', prli.QuantityRequested); //요청수량
                    //     }
                    //     mapItem.put('div_code', prli.Product2.DIV_CODE__c); //사업부
                    //     mapList.add(mapItem);
                    // }
                }
                // /** 약속모듈 호출 */
                // if (!mapList.isEmpty()) {
                //     try {
                //         Map<String, Object> rtnMap = new Map<String, Object>();
                //         //rtnMap = EX_RsrvUtil.RESRV_MODULE(mapList);
                //         // 230530 비동기 전환
                //         EX_RsrvModule_qa rsrvModuleQa = new EX_RsrvModule_qa(mapList);
                //         System.enqueueJob(rsrvModuleQa);
                //     } catch (Exception e) {
                //         System.debug(e.getLineNumber() + ' Line || ' + e.getMessage());
                //         throw new AuraHandledException(e.getLineNumber() + ' Line || ' + e.getMessage());
                //     }

                // }
            // }

            // 23.05.01 / 재고 수불 처리 시점 변경
            // 일반 주문(예약 X) 의 경우 결제 전 재고 할당 처리

            // 23.08.30 gw.lee
            // 일반 주문 - 예약 주문 O, 적치장소 + 소모품 센터 재고 (-) 처리
            if ((isTemporary == true && !isExchangeOrder) || isExchangeOrder) {

                List<Map<String, Object>> mapList = new List<Map<String, Object>>();

                for (ProductRequestLineItem consumableOrderItem : afterDMLConsumableOrderItems) {
                    if (consumableOrderItem.Consumables_Order_Class_Code__c == 'General' ) {
                        mapRequestInfo = new Map<String, Object>();
                        mapRequestInfo.put('product2Id', consumableOrderItem.Product2Id);
                        mapRequestInfo.put('sourceLocationId', consumableOrderItem.SourceLocationId);
                        mapRequestInfo.put('destinationLocationId', null);
                        mapRequestInfo.put('requestType', 'AA');
                        
                        mapRequestInfo.put('productRequestLineItem', consumableOrderItem);
                        mapRequestInfo.put('returnOrderLineItem', null);
                        mapRequestInfo.put('productTransfer', null);
                        
                        //                    locationIdSet.add(consumableOrderItem.DestinationLocationId);
                        
                        //일반 주문 (예약 X)
                        if (!divMap.containsKey(consumableOrderItem.SHIPPED_Department_Code__c)) { //24 01 12 hyungho.chun reserveMap은 if 분기에서 뺌
                            mapRequestInfo.put('requestQTY', consumableOrderItem.QuantityRequested);
    
                            partIdSet.add(consumableOrderItem.product2Id);
                            locationIdSet.add(consumableOrderItem.SourceLocationId);
                            pListMapRequestInfo.add(mapRequestInfo);
                        //일반 주문 (예약 o)
                        } else if (divMap.containsKey(consumableOrderItem.SHIPPED_Department_Code__c)) {

                            Map<String, String> childMap = new Map<String, String>();
                            //센터 및 적치장소 재고 감소 처리
                            if (parentMap != null) {
                                childMap = (Map<string, String>)parentMap.get(consumableOrderItem.Product2Id);
                                System.debug('childMap :::: ' + childMap);
                                mapRequestInfo.put('requestQTY', Integer.valueOf(childMap.get('stdQuantity')));

                                partIdSet.add(consumableOrderItem.product2Id);
                                locationIdSet.add(consumableOrderItem.SourceLocationId);
                                pListMapRequestInfo.add(mapRequestInfo);
                            }

                            Map<String, Object> mapItem = new Map<String, Object>();
                            mapItem.put('oriPrId', consumableOrderItem.ParentId); //원주문 ProductRequestId
                            mapItem.put('oriPrliId', consumableOrderItem.Id); //원주문 ProductRequestLineItemId
                            mapItem.put('oriOrderNo', consumableOrderItem.Order_Number__c); //원주문번호
                            mapItem.put('oriOrderSeq', consumableOrderItem.Order_SEQ__c); //원주문Seq
                            mapItem.put('deptCode', EX_ConsumableUtil.PH8002); //부서코드
                            // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                            // mapItem.put('partNo', consumableOrderItem.Product2.ProductCode); //파트넘버
                            mapItem.put('partNo', consumableOrderItem.Product2.Name); //파트넘버
                            if (childMap.get('resrvQuantity') != null) {
                                mapItem.put('req_qty', Integer.valueOf(childMap.get('resrvQuantity'))); //요청수량
                            } else {
                                mapItem.put('req_qty', consumableOrderItem.QuantityRequested); //요청수량
                            }
                            mapItem.put('div_code', consumableOrderItem.Product2.DIV_CODE__c); //사업부
                            mapList.add(mapItem);
                        }
                    } else if (consumableOrderItem.Consumables_Order_Class_Code__c == 'Sold Out') {
                        Map<String, Object> mapItem = new Map<String, Object>();
                        mapItem.put('oriPrId', consumableOrderItem.ParentId); //원주문 ProductRequestId
                        mapItem.put('oriPrliId', consumableOrderItem.Id); //원주문 ProductRequestLineItemId
                        mapItem.put('oriOrderNo', consumableOrderItem.Order_Number__c); //원주문번호
                        mapItem.put('oriOrderSeq', consumableOrderItem.Order_SEQ__c); //원주문Seq
                        mapItem.put('deptCode', EX_ConsumableUtil.PH8002); //부서코드
                        // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                        // mapItem.put('partNo', consumableOrderItem.Product2.ProductCode); //파트넘버
                        mapItem.put('partNo', consumableOrderItem.Product2.Name); //파트넘버
                        mapItem.put('req_qty', consumableOrderItem.QuantityRequested); //요청수량
                        mapItem.put('div_code', consumableOrderItem.Product2.DIV_CODE__c); //사업부
                        mapList.add(mapItem);
                    } 
                }

                /** 약속모듈 호출 */
                if (!mapList.isEmpty()) {
                    try {
                        Map<String, Object> rtnMap = new Map<String, Object>();
                        //rtnMap = EX_RsrvUtil.RESRV_MODULE(mapList);
                        // 230530 비동기 전환
                        EX_RsrvModule_qa rsrvModuleQa = new EX_RsrvModule_qa(mapList);
                        System.enqueueJob(rsrvModuleQa);
                    } catch (Exception e) {
                        System.debug(e.getLineNumber() + ' Line || ' + e.getMessage());
                        throw new AuraHandledException(e.getLineNumber() + ' Line || ' + e.getMessage());
                    }

                }

                Map<String, ProductItem> pMapProductItemByKey = new Map<String, ProductItem>();
                String stqProductItemQry = '';
                stqProductItemQry += 'SELECT LocationId, Product2Id, DEPT_CODE__c, ALLOC_QTY__c ' ;
                stqProductItemQry += '  FROM ProductItem';
                stqProductItemQry += ' WHERE Product2Id IN :partIdSet AND LocationId IN :locationIdSet';

                List<ProductItem> productItems = Database.query(stqProductItemQry);
                // Key :  {!sourceLocationId} + '^' + {!Product2Id}
                String strKeyPI = '';
                for (ProductItem productItem : productItems) {
                    strKeyPI = productItem.LocationId + '^' + productItem.Product2Id;
                    pMapProductItemByKey.put(strKeyPI, productItem);
                }


                System.debug('start====================');
                System.debug('pListMapRequestInfo');
                System.debug(pListMapRequestInfo);
                System.debug('end====================');
                System.debug('pMapProductItemByKey');
                System.debug(pMapProductItemByKey);
                Map<String, Object> rtnMap = new Map<String, Object>();

                rtnMap = FS_MaterialUtil.applyProductItem(pListMapRequestInfo, pMapProductItemByKey);
                System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (FS_MaterialUtil.applyProductItem):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                System.debug('start====================');
                System.debug('rtnMap');
                System.debug(JSON.serializePretty(rtnMap));
                System.debug(rtnMap);
                System.debug('end====================');
            }

            if (afterDMLConsumableOrderMap.containsKey(STANDARD_ORDER)) {
                returnMap.put(STANDARD_ORDER, afterDMLConsumableOrderMap.get(STANDARD_ORDER));
            } else {
                returnMap.put(STANDARD_ORDER, null);
            }

            if (afterDMLConsumableOrderMap.containsKey(SOLD_OUT_ORDER)) {
                returnMap.put(SOLD_OUT_ORDER, afterDMLConsumableOrderMap.get(SOLD_OUT_ORDER));
            } else {
                returnMap.put(SOLD_OUT_ORDER, null);
            }

            if (afterDMLConsumableOrderMap.containsKey(PO)) {
                returnMap.put(PO, afterDMLConsumableOrderMap.get(PO));
            } else {
                returnMap.put(PO, null);
            }

            List<ItemTable> standardOrderItemTables = new List<ItemTable>();
            ItemTable standardOrderItem;

            List<ItemTable> soldOutOrderItemTables = new List<ItemTable>();
            ItemTable soldOutOrderItem;

            Set<String> exchangeOrderIdSet = new Set<String>();
            Map<String, Decimal> exchangeOrderQtyMap = new Map<String, Decimal>();

            // 품절 예약 시 품절예약주문 Message Send
            EX_Message__c soldOutOrderMessage = new EX_Message__c();
            String soldOutContactName = '';
            String orderNumber = '';
            String productName = '';
            Integer productCnt = 0;
            Decimal amount = 0;
            String soldOutContactPhone = '';

            //List<ProductRequestLineItem> afterDMLConsumableOrderItems2 = Database.query(strProductRequestLineItemQry);
            
            System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (query ProductRequestLineItem):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            for (ProductRequestLineItem afterDMLConsumableOrderineItem : afterDMLConsumableOrderItems) {
                if (afterDMLConsumableOrderineItem.Consumables_Business_Type_Code__c == 'ExchangeOrder') {
                    exchangeOrderIdSet.add(afterDMLConsumableOrderineItem.BASIS_Order_Item_Id__c);
                    exchangeOrderQtyMap.put(afterDMLConsumableOrderineItem.BASIS_Order_Item_Id__c, afterDMLConsumableOrderineItem.QuantityRequested);
                }

                if (afterDMLConsumableOrderineItem.Consumables_Order_Class_Code__c == 'General') {
                    standardOrderItem = new ItemTable();
                    standardOrderItem.Id = afterDMLConsumableOrderineItem.Id;
                    standardOrderItem.ParentId = afterDMLConsumableOrderMap.get(STANDARD_ORDER).Id;
                    standardOrderItem.sLocationId = afterDMLConsumableOrderineItem.SourceLocationId;
                    standardOrderItem.DIVCODE = afterDMLConsumableOrderineItem.ENDP_Code__c;
                    standardOrderItem.sProductId = afterDMLConsumableOrderineItem.Product2Id;
                    standardOrderItem.sProductItemId = afterDMLConsumableOrderineItem.ProductItem__c;
                    standardOrderItem.ProductCode = afterDMLConsumableOrderineItem.PART_NO__c;
                    standardOrderItem.QTY = afterDMLConsumableOrderineItem.QuantityRequested;
                    standardOrderItem.ResrvNumber = afterDMLConsumableOrderineItem.RSRV_Number__c;
                    standardOrderItem.ShipmentCode = afterDMLConsumableOrderineItem.SHIPPED_Department_Code__c;
                    standardOrderItem.ModelId = afterDMLConsumableOrderineItem.Model__c; // PHJ 24 02 23
                    standardOrderItem.Model = afterDMLConsumableOrderineItem.MODEL_Code__c; // PHJ 24 02 23

                    if (afterDMLConsumableOrderineItem.ASC_Price__c != null) {
                        standardOrderItem.ASCPrice = afterDMLConsumableOrderineItem.ASC_Price__c;
                    }
                    standardOrderItem.Price = afterDMLConsumableOrderineItem.CONSUMER_Price__c;
                    if (afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c != null && afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c != 0) {
                        if (isManagement) {
                            standardOrderItem.PromotionPrice = afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c;
                        } else {
                            standardOrderItem.PromotionPrice = standardOrderItem.Price - afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c / standardOrderItem.QTY;
                        }
                    }
                    //0223.04.14
                    standardOrderItem.OrderNumber = afterDMLConsumableOrderineItem.Order_Number__c;
                    standardOrderItem.ProductName = proNameKoMap.get(afterDMLConsumableOrderineItem.Product2Id) != null ? proNameKoMap.get(afterDMLConsumableOrderineItem.Product2Id) : afterDMLConsumableOrderineItem.fm_Consumables_PART_DESC_KOR__c;

                    // if (String.isNotBlank(afterDMLConsumableOrderineItem.PART_DESC_KOR__c)) {
                    //     standardOrderItem.ProductName = afterDMLConsumableOrderineItem.PART_DESC_KOR__c + '(' + afterDMLConsumableOrderineItem.Product2.Name + ')';
                    // } else {
                    //     standardOrderItem.ProductName = afterDMLConsumableOrderineItem.Product2.Name;
                    // }
                    standardOrderItemTables.add(standardOrderItem);

                } else if (afterDMLConsumableOrderineItem.Consumables_Order_Class_Code__c == 'Sold Out') {
                    soldOutOrderItem = new ItemTable();
                    soldOutOrderItem.Id = afterDMLConsumableOrderineItem.Id;
                    soldOutOrderItem.ParentId = afterDMLConsumableOrderMap.get(SOLD_OUT_ORDER).Id;
                    soldOutOrderItem.sLocationId = afterDMLConsumableOrderineItem.SourceLocationId;
                    soldOutOrderItem.DIVCODE = afterDMLConsumableOrderineItem.ENDP_Code__c;
                    soldOutOrderItem.sProductId = afterDMLConsumableOrderineItem.Product2Id;
                    soldOutOrderItem.sProductItemId = afterDMLConsumableOrderineItem.ProductItem__c;
                    soldOutOrderItem.ProductCode = afterDMLConsumableOrderineItem.PART_NO__c;
                    soldOutOrderItem.QTY = afterDMLConsumableOrderineItem.QuantityRequested;
                    soldOutOrderItem.ModelId = afterDMLConsumableOrderineItem.Model__c; // PHJ 24 02 23
                    soldOutOrderItem.Model = afterDMLConsumableOrderineItem.MODEL_Code__c; // PHJ 24 02 23
                    if (afterDMLConsumableOrderineItem.ASC_Price__c != null) {
                        soldOutOrderItem.ASCPrice = afterDMLConsumableOrderineItem.ASC_Price__c;
                    }
                    soldOutOrderItem.Price = afterDMLConsumableOrderineItem.CONSUMER_Price__c;
                    if (afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c != null && afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c != 0) {
                        if (isManagement) {
                            soldOutOrderItem.PromotionPrice = afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c;
                        } else {
                            soldOutOrderItem.PromotionPrice = soldOutOrderItem.Price - afterDMLConsumableOrderineItem.PROMOTION_Discount_Amount__c / soldOutOrderItem.QTY;
                        }
                    }
                    //0223.04.14
                    soldOutOrderItem.OrderNumber = afterDMLConsumableOrderineItem.parent.Order_Number__c;
                    soldOutOrderItem.ProductName = proNameKoMap.get(afterDMLConsumableOrderineItem.Product2Id) != null ? proNameKoMap.get(afterDMLConsumableOrderineItem.Product2Id) : afterDMLConsumableOrderineItem.fm_Consumables_PART_DESC_KOR__c;
                    // soldOutOrderItem.ProductName = afterDMLConsumableOrderineItem.fm_Consumables_PART_DESC_KOR__c;
                    // if (afterDMLConsumableOrderineItem.Product2.PART_DESC_KOR__c != null) {
                    //     soldOutOrderItem.ProductName = afterDMLConsumableOrderineItem.Product2.PART_DESC_KOR__c + '(' + afterDMLConsumableOrderineItem.fm_ProductName__c + ')';
                    // } else {
                    //     soldOutOrderItem.ProductName = afterDMLConsumableOrderineItem.fm_ProductName__c;
                    // }

                    soldOutContactPhone = afterDMLConsumableOrderineItem.Parent.Order_CUST_TPNO_1__c;
                    soldOutContactName = afterDMLConsumableOrderineItem.Parent.Order_CUST_Name__c;
                    orderNumber = afterDMLConsumableOrderineItem.Parent.Order_Number__c;
                    productName = proNameKoMap.get(afterDMLConsumableOrderineItem.Product2Id) != null ? proNameKoMap.get(afterDMLConsumableOrderineItem.Product2Id) : afterDMLConsumableOrderineItem.fm_Consumables_PART_DESC_KOR__c;
                    productCnt += 1;
                    amount += afterDMLConsumableOrderineItem.SALE_Amount__c - afterDMLConsumableOrderineItem.Last_Discount_Amount__c;

                    soldOutOrderItemTables.add(soldOutOrderItem);
                }
            }
            if (isTemporary == false) {

                soldOutOrderMessage.Label1__c = soldOutContactName;
                soldOutOrderMessage.Label2__c = orderNumber;
                if (productCnt > 1) {
                    productCnt = productCnt - 1;

                    soldOutOrderMessage.Label3__c = productName + ' 외 ' + productCnt + '건';
                } else {
                    soldOutOrderMessage.Label3__c = productName;
                }
                soldOutOrderMessage.Label4__c = EX_ConsumableUtil.strToCurrencyWon(String.valueOf(amount));

                // 품절주문예약 알림톡 Send
                try {
                    if (isTemporary == false && !isExchangeOrder) {
                        System.debug('soldOutOrderMessage');
                        System.debug(soldOutOrderMessage);
                        System.debug('soldOutContactPhone');
                        System.debug(soldOutContactPhone);
                        String jsonStr = JSON.serialize(soldOutOrderMessage);
                        // sendSoldOutKakao('SVC_LGE_MACN_010', jsonStr, soldOutContactPhone);
                        sendSoldOutKakao('SVC_LGE_MACN_010_1', jsonStr, soldOutContactPhone); //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
                    }
                } catch (Exception e) {
                    System.debug('=================');
                    System.debug(e.getMessage());
                    System.debug('=================');
                }
            }

            if (!exchangeOrderIdSet.isEmpty()) {
                List<ProductRequestLineItem> basisOrderRequestLineItems = [
                        SELECT Consumables_Order_DETAIL__c, Exchange_Quantity__c
                        FROM ProductRequestLineItem
                        WHERE Id IN :exchangeOrderIdSet
                ];
                for (ProductRequestLineItem prli : basisOrderRequestLineItems) {
                    // 교환요청
                    prli.Consumables_Order_DETAIL__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_130;
                    prli.Exchange_Quantity__c += exchangeOrderQtyMap.get(prli.Id); //24 01 03 hyungho.chun 교환요청한 lineitem에 교환주문을 또 거는 경우때문에 업데이트가아니고 교환수량 +로 로직으로 변경
                }
                update basisOrderRequestLineItems;
                
                System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (update basisOrderRequestLineItems):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            }

            returnMap.put('standardOrderItemTables', standardOrderItemTables);
            returnMap.put('soldOutOrderItemTables', soldOutOrderItemTables);
            returnMap.put('isOrderChange', isOrderChange);

            System.debug('rtnMap soIt : ' + standardOrderItemTables);
            System.debug('rtnMap souIt : ' + soldOutOrderItemTables);
            if (isTemporary == false && remark != null) {
                // Case Update SC_Common Utils 추가
                if(!isManagement) {
                    if (strCaseId != '') {
                        //Map<String, Object> mapResult = new Map<String, Object>();
                        Map<String, Object> mapResult = SC_CommonUtil.setCallCode(strCaseId, true, remark, true);

                        System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (SC_CommonUtil.setCallCode):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

                        if (mapResult.get('stat') == 'SUCCESS') {
                            System.debug('Case Update Success');
                        } else {
                            System.debug('Case Update Fail >> ' + mapResult.get('message'));
                            String errorMsg = (String) mapResult.get('message');
                            if (errorMsg != null) {
                                returnMap.put('caseUpdateFail', errorMsg.split(',')[1].replaceAll(':|\\[\\]', ''));
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e.getLineNumber() + 'Line || ' + e.getMessage());
            throw new AuraHandledException(e.getLineNumber() + 'Line || ' + e.getMessage());
        }
        System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        return returnMap;
    }

    @AuraEnabled
    public static Map<String, Object> doGetOrderInfo(Map<String, Object> paramMap) {
        Map<String, ProductRequest> consumableOrderMap = new Map<String, ProductRequest>();
        try {
            String stdConsumableOrderId = paramMap.containsKey('stdConsumableOrderId') ? (String) paramMap.get('stdConsumableOrderId') : null;
            String soldOutConsumableOrderId = paramMap.containsKey('soldOutConsumableOrderId') ? (String) paramMap.get('soldOutConsumableOrderId') : null;

            Set<String> consumableOrderIdSet = new Set<String>();

            consumableOrderIdSet.add(stdConsumableOrderId);
            consumableOrderIdSet.add(soldOutConsumableOrderId);

            String strQuery = '';
            // SELECT
            // strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequest');
            strQuery += ' SELECT ' + 'Id, Order_Number__c';

            // FROM
            strQuery += ' FROM ' + 'ProductRequest';
            // WHERE
            strQuery += ' WHERE ';
            strQuery += ' Id IN :consumableOrderIdSet ';

            if (stdConsumableOrderId != null) consumableOrderMap.put(stdConsumableOrderId, null);
            if (soldOutConsumableOrderId != null) consumableOrderMap.put(soldOutConsumableOrderId, null);

            for (ProductRequest consumableOrder : Database.query(strQuery)) {
                if (consumableOrderMap.containsKey(consumableOrder.Id)) {
                    consumableOrderMap.put(consumableOrder.Id, consumableOrder);
                }
            }

            System.debug('start====================');
            System.debug('consumableOrderMap >>>');
            System.debug(consumableOrderMap);
            System.debug('end====================');
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }

        return consumableOrderMap;
    }

    @AuraEnabled
    public static Map<String, Object> doSendKakaoMessage(Map<String, Object> pmap) {

        // Kakao Test 송신
        //Map<String, Object> data = new Map<String, Object>();
        Map<String, Object> data = CM_ApiCalloutFormConfig.setInputParam('kakao');
        //returnMap = CM_ApiServiceController.sendKakao('SVC0040', 'WorkOrder', '0WO0p0000002dplGAA', '01051573715', data);

        String retCode = '200';
        String retMessage = '정상적으로 처리되었습니다.';
        Map<String, Object> mapResult = new Map<String, Object>();

        // 메세지 조회
        // Map<String, String> temInfo = CM_TemplateMsgConfig.getTemParam(temCode, objApiName, RecordId);
        String completedMsg = '안녕하세요. 이석호 고객님\n' +
                'LG 전자 입니다.\n' +
                '\n' +
                'Part No : EXA62487505\n' +
                '품명 : AF에어컨필터(EX Allergy Filter)\n' +
                '소비자가 : 4000\n' +
                'https://www.lge.co.kr/care-accessories/tv/aan75829201';
        System.debug(completedMsg);

        String phoneNo = '01051573715';

        System.debug('Message ::: ' + completedMsg);
        System.debug('phoneNo ::: ' + phoneNo);

        // todo 임시 white list 추후 수정 예정
        List<String> phoneNoList = new List<String>{
                '01036106909',
                '01044875590',
                '01086734785',
                '01077656143',
                '01094663602',
                '01049056314',
                '01023035629',
                '01042879397',
                '01064105426',
                '01051573715'
        };

        try {
            if (phoneNoList.contains(phoneNo)) {
                // ====================================================
                // Set Input Param
                // ====================================================
                data.put('sendMessage', completedMsg);      // 카카오 알림톡 내용
                data.put('receiveMobileNo', phoneNo);       // 수신자 번호
                data.put('templateCode', 'SVC0040');          // 템플릿 코드

                // todo responseBody 에러처리
                // ====================================================
                // Callout Rest API
                // ====================================================
                CM_ApiCalloutFormConfig.RestCalloutResponse calloutResponse = CM_ApiCalloutService.callPostRestApi('kakao', data);
                mapResult.put('retCode', calloutResponse.statusCode);
            } else {
                System.debug('sendKakao impossible 등록되지 않은 번호 입니다.');
            }

            return mapResult;
        } catch (Exception e) {
            return mapResult;
        }
    }

    @AuraEnabled
    public static String doSendPDF(Map<String, object> paramMap) {
        //23.12.06 gw.lee
        //메일 발송 금지 셋팅으로 인한 행걸림 방지
        try {

            String selectedQuoteId = (String) paramMap.get('historyId');
            List <SR_ONLINE_SALE_ESTIMATE__c> quotes = new List <SR_ONLINE_SALE_ESTIMATE__c>([
                    SELECT Id, DocumentID__c, InvoiceId__c, RCVR_Email__c
                    FROM   SR_ONLINE_SALE_ESTIMATE__c
                    WHERE  Id =: selectedQuoteId
            ]);

            String documentId;
            if (quotes[0].DocumentID__c != null) {
                documentId = quotes[0].DocumentID__c;
            } else {
                System.debug('선택된 견적서 DocumentId__c가 없음');
            }

            String invoiceTempId = '';
            System.debug('quotes[0].InvoiceId__c :: ' + quotes[0].InvoiceId__c);
            if (quotes[0].InvoiceId__c != null) {
                invoiceTempId = quotes[0].InvoiceId__c;
            } else {
                System.debug('선택된 견적서 InvoiceId__c가 없음');
            }

            String contactId = (String) paramMap.get('contactId');
            System.debug(paramMap.get('value'));
            List<String> value = (List<String>) JSON.deserialize((String) paramMap.get('value'), List<String>.class);
            String RCVRName = (String) paramMap.get('RCVRName');

            String RCVREmail = (String) paramMap.get('RCVREmail');
            if (RCVREmail == null || RCVREmail.equals('')) {
                RCVREmail = quotes[0].RCVR_Email__c;
            }

            String stdConsumableOrderId = (String) paramMap.get('stdConsumableOrderId');
            String soldOutConsumableOrderId = (String) paramMap.get('soldOutConsumableOrderId');
            Boolean isManagement = (Boolean) paramMap.get('isManagement');
            String orderNumber = (String) paramMap.get('orderNumber');

            Map<String, String> imgMap = new Map<String, String>();

            // for (ContentDocument aa : [Select LatestPublishedVersionId, Title FROM ContentDocument WHERE ParentId in (SELECT Id from ContentWorkspace Where Name = '소모품')]) {
            //     imgMap.put(aa.Title, aa.LatestPublishedVersionId);
            // }
            String  strOrgName = 'Prd';
            String  strMyHost = System.Url.getSalesforceBaseUrl().getHost();
            //Virsualforce Url에 --c 문자가 들어가는 문제로 Replace 처리함.
            strMyHost = strMyHost.replace('--c', '');
            Integer nStartIndex = strMyHost.indexOf('--') + 2;
            if(nStartIndex != 1){   // because if prod then -1 is returned, 
                Integer nEndIndex = strMyHost.indexOf('.');
                //strOrgName = strMyHost.mid(nStartIndex, nEndIndex - nStartIndex);
            }
            System.debug( 'strOrgName::::' + strOrgName);
            String strIfConfigName = 'ConsumableCommon' + '_'+ strOrgName;
            System.debug( 'strIfConfigName::::' + strIfConfigName);
            List<ContentDocument> cwList = new List<ContentDocument>();
            if (!Test.isRunningTest()) {
                cwList = [Select LatestPublishedVersionId, Title FROM ContentDocument WHERE ParentId in (SELECT Id from ContentWorkspace Where DeveloperName = :strIfConfigName)];
            } else {
                cwList = [Select LatestPublishedVersionId, Title FROM ContentDocument];
            }
            
            // List<ContentDocument> cwList = [SELECT LatestPublishedVersionId, Title FROM ContentDocument WHERE Title IN ('사업자등록증', 'LG전자 마크', 'LG 마크', '통장 사본')];
            if (cwList != null) {
                if (cwList.size() > 0) {
                    for (ContentDocument aa : cwList) {
                        imgMap.put(aa.Title, aa.LatestPublishedVersionId);
                    }
                }
            }

            //System.debug('documentId : ' + documentId);
            //System.debug('invoiceTempId : ' + String.valueOf(invoiceTempId));
            System.debug('contactId : ' + contactId);
            System.debug('value : ' + value);
            System.debug('stdConsumableOrderId : ' + stdConsumableOrderId);
            System.debug('soldOutConsumableOrderId : ' + soldOutConsumableOrderId);
            System.debug('isManagement : ' + isManagement);
            System.debug('orderNumber : ' + orderNumber);

            String query = 'SELECT ID';
            query += ' , RCVR_Name__c';
            query += ' , RCVR_Email__c';
            query += ' , Send_YN__c';
            query += ' , BankBookCopy_YN__c';
            query += ' , Business_Registration_YN__c';
            query += ' , Invoice_YN__c';
            query += ' , Quote_YN__c';
            query += ' , Name';
            query += ' FROM SR_ONLINE_SALE_ESTIMATE__c';
            if (isManagement) {
                query += ' WHERE OrderNumber__c = :orderNumber';
            } else {
                query += ' WHERE Order_User__c = :contactId AND  (Order_Number__c = :stdConsumableOrderId or Order_Number__c = :soldOutConsumableOrderId) and Order_Number__c != NULL';
            }
            query += ' AND Id =:selectedQuoteId ';
            query += ' ORDER BY CreatedDate DESC LIMIT 1';
            List<SR_ONLINE_SALE_ESTIMATE__c> quoteHistory = (List<SR_ONLINE_SALE_ESTIMATE__c>) Database.query(query);
            
            // [
            //         SELECT RCVR_Name__c, RCVR_Email__c, Send_YN__c, BankBookCopy_YN__c,
            //                 Business_Registration_YN__c, Invoice_YN__c, Quote_YN__c, Name
            //         FROM SR_ONLINE_SALE_ESTIMATE__c
            //         WHERE Order_User__c = :contactId AND (Order_Number__c = :stdConsumableOrderId or Order_Number__c = :soldOutConsumableOrderId) and Order_Number__c != NULL
            // ];

            System.debug('quoteHistory' + quoteHistory);

            List<ContentVersion> regi = [
                    SELECT VersionData
                    FROM   ContentVersion
                    WHERE  Id =: imgMap.get('사업자등록증')
            ];
            List<ContentVersion> bank = [
                    SELECT VersionData
                    FROM   ContentVersion
                    WHERE  Id =: imgMap.get('통장 사본')
            ];

            List<ContentVersion> cv = [
                    SELECT Id, VersionData
                    FROM   ContentVersion
                    WHERE  ContentDocumentId =: documentId
            ];
            List<ContentVersion> iv = [
                    SELECT Id, VersionData
                    FROM   ContentVersion
                    WHERE  ContentDocumentId =: invoiceTempId
            ];

            blob WOCFbody = null;
            blob invoiceWOCFbody = null;
            if (!cv.isEmpty())
                WOCFbody = cv[0].VersionData;
            if (!iv.isEmpty())
                invoiceWOCFbody = iv[0].VersionData;
            blob regiWOCFbody = regi.isEmpty() ? null : regi[0].VersionData;
            blob bankWOCFbody = bank.isEmpty() ? null : bank[0].VersionData;

            List< Messaging.EmailFileAttachment> efas = new List< Messaging.EmailFileAttachment>();
            
            if (quoteHistory[0].Quote_YN__c == 'Y') {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setBody(WOCFbody);
                efa.setFileName('견적서.pdf');
                efas.add(efa);
            }
            if (quoteHistory[0].Invoice_YN__c == 'Y') {
                Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
                efa1.setBody(invoiceWOCFbody);
                efa1.setFileName('명세서.pdf');
                efas.add(efa1);
            }
            if (quoteHistory[0].Business_Registration_YN__c == 'Y' && regiWOCFbody != null) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();

                efa = new Messaging.EmailFileAttachment();

                efa.setBody(regiWOCFbody);
                efa.setFileName('사업자등록증.png');
                efas.add(efa);
            }
            if (quoteHistory[0].BankBookCopy_YN__c == 'Y' && bankWOCFbody != null) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();

                efa = new Messaging.EmailFileAttachment();

                efa.setBody(bankWOCFbody);
                efa.setFileName('통장사본.png');
                efas.add(efa);
            }

            List<SR_ONLINE_SALE_ESTIMATE__c> updatedList = new List<SR_ONLINE_SALE_ESTIMATE__c>();
            for (SR_ONLINE_SALE_ESTIMATE__c quote : quoteHistory) {
                quote.Send_YN__c = 'Y';
                updatedList.add(quote);
            }

            String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
            String strEndpointUserHome = baseURL + '/lightning/setup/ManageUsers/home/';

            Messaging.reserveSingleEmailCapacity(1);

            //We instantiate our single email message object
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

            // TODO 화이트리스트 검열. 운영에서는 제거 필요 -- 배포시 문제 없게 수정, 해당 데이터 메타데이터로 관리 - 2023-03-12 sungho.jo
            if(TEMP_Whitelist.isWhiteListCheck()){
                List<String> tempEmailWhiteList = TEMP_Whitelist.getWhiteListMailAddress();
                Set<String> emailSets = new Set<String>();

                Set<String> recipientEmailWhiteChk = new Set<String>(); // 화이트리스트 체크통과된 수신메일

                if(RCVREmail!= null) emailSets.add(RCVREmail);

                if(!emailSets.isEmpty()){
                    for( String emailAddr : emailSets){
                        /*if(!tempEmailWhiteList.contains(emailAddr)) {
                            resultWrapper = new ResultWrapper(false, 'error', '화이트리스트 대상 메일이 아닙니다. (MsgWhitelist__mdt 데이터 등록 바람.)');
                            mapResult.put('resultWrapper', resultWrapper);
                            return mapResult;
                        }*/
                        if(tempEmailWhiteList.contains(emailAddr)){
                            if(RCVREmail.contains(emailAddr)) recipientEmailWhiteChk.add(emailAddr);
                        }
                    }
                }
                if(recipientEmailWhiteChk.isEmpty()){
                    for (SR_ONLINE_SALE_ESTIMATE__c quote : quoteHistory) {
                        quote.Send_YN__c = 'N';
                        updatedList.add(quote);
                    }
                    return 'Validation';
                }
            }

            update updatedList;

            // Strings to hold the email addresses to which you are sending the email.
            //Assign the TO address to our mail object
            mail.setToAddresses(new List< String>{
                    RCVREmail
            });
            // mail.setToAddresses(toAddresses);

            // //List of ccAddress
            // String[] ccAddresses = new String[] {'sangjae@cnspartner.com'};
            // // Assign the CC addresses

            EmailTemplate template = [SELECT Subject, HtmlValue FROM EmailTemplate WHERE Name = '소모품 견적서'];
            Contact con = [SELECT Name FROM Contact WHERE id = :contactId];
            DateTime todaysDate = System.today();
            String todaysDateStr = todaysDate.format('yyyy년 MM월 dd일');
            
            //23.09.03 PHJ
            List<String> optionSet = new List<String>();
            if(quoteHistory[0].Quote_YN__c == 'Y') optionSet.add('견적서');
            if(quoteHistory[0].Invoice_YN__c == 'Y') optionSet.add('명세서');
            if(quoteHistory[0].Business_Registration_YN__c == 'Y') optionSet.add('사업자등록증');
            if(quoteHistory[0].BankBookCopy_YN__c == 'Y') optionSet.add('통장사본');
            String option = optionSet.toString();

            // String option = value.toString();

            //23.09.03 PHJ
            String option2 = option.replace(',','/');
            String option3 = option2.replace('(','');
            String option4 = option3.replace(')','');
            String option5 = option4.replace(' ','');

            //23.09.04 PHJ
            String rcvrNameInMail = (String) paramMap.get('RCVRName');

            String subject = template.Subject;
            String htmlvalue = template.HtmlValue;

            //23.09.03 PHJ
            subject = subject.replaceAll('#OPTION#', option5);
            // subject = subject.replaceAll('#DATE#', todaysDateStr);
            
            //23.09.05 PHJ
            subject = subject.replaceAll('#CONTACTNAME#', rcvrNameInMail);
            htmlvalue = htmlvalue.replaceAll('#CONTACTNAME#', rcvrNameInMail);
            // subject = subject.replaceAll('#CONTACTNAME#', con.Name);
            // htmlvalue = htmlvalue.replaceAll('#CONTACTNAME#', con.Name);

            htmlvalue = htmlvalue.replaceAll('#OPTION#', option);
            htmlvalue = htmlvalue.replaceAll('#DATE#', todaysDateStr);


            // Here we can set the address that will be used when a recipient replies to the email
            // mail.setReplyTo('smile@lge.com');

            // Specify the name used as the display name.

            
            //23.11.21 PHJ org wide setting // 오픈 후 partial code 삭제
            // OrgWideEmailAddress addr = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName ='소모품 발신자' limit 1];
            // mail.setOrgWideEmailAddressId(CM_OrgWideEmail.getOrgWideEmail().Id);
            // String urlvalue = URL.getSalesforceBaseUrl().toExternalForm();
            // System.debug('urlvalue ::::: ' + urlvalue);
            // if(urlvalue.contains('patial')){
            //     mail.setOrgWideEmailAddressId(CM_OrgWideEmail.getOrgWideEmail().Id);
            // }else{
                OrgWideEmailAddress addr = [SELECT Id, Address, DisplayName, Purpose FROM OrgWideEmailAddress WHERE Address = 'smileplus@lge.com' LIMIT 1];
                mail.setOrgWideEmailAddressId(addr.Id);
            // }

            // mail.setSenderDisplayName('LG 전자 서울센터');
            // Set the subject line for your email address.
            mail.setSubject(subject);

            // You can set this to true if you want to BCC yourself on the email
            mail.setBccSender(false);
            // You can specify your plain text here
            // mail.setPlainTextBody();

            //Specify any html - for example this will display a link in the email
            mail.setHtmlBody(htmlvalue);
            mail.setFileAttachments(efas);
            // Send the email
            if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                    mail
            });
            
            return '';
        } catch (System.NoAccessException e) {
            System.debug('e :::: ' + e);
            return 'Exception';
        }
    }

    /**
     * 택배주문시  견적서 생성이력 조회
     * */
    @AuraEnabled
    public static Map<String, Object> getHistoryData(Map<String, Object> paramMap) {
        System.debug('getHistoryData');
        String contactId = paramMap.get('contactId') != null ? (String) paramMap.get('contactId') : '';
        String stdConsumableOrderId = paramMap.get('stdConsumableOrderId') != null ? (String) paramMap.get('stdConsumableOrderId') : '';
        String soldOutConsumableOrderId = paramMap.get('soldOutConsumableOrderId') != null ? (String) paramMap.get('soldOutConsumableOrderId') : '';
        if (stdConsumableOrderId != null) {
            System.debug('stdConsumableOrderId : ' + stdConsumableOrderId);
        }
        if (soldOutConsumableOrderId != null) {
            System.debug('soldOutConsumableOrderId : ' + soldOutConsumableOrderId);
        }

        String orderNumber = paramMap.get('orderNumber') != null ? (String) paramMap.get('orderNumber') : '';
        Map<String, Object> mapResult = new Map<String, Object>();
        List<ItemHistoryTable> listResult = new List<ItemHistoryTable>();


        List<SR_ONLINE_SALE_ESTIMATE__c> listHistory = new List<SR_ONLINE_SALE_ESTIMATE__c>(
                // [
                //         SELECT
                //                 BankBookCopy_YN__c,
                //                 Business_Registration_YN__c,
                //                 CreatedDate,
                //                 Invoice_YN__c,
                //                 Name,
                //                 Order_Number__c,
                //                 Quote_Memo__c,
                //                 Quote_PDF_URL__c,
                //                 Quote_YN__c,
                //                 RCVR_Email__c,
                //                 RCVR_Name__c,
                //                 Send_YN__c,
                //                 QuoteNum__c,
                //                 OrderNumber__c,
                //                 Id           
                //         FROM SR_ONLINE_SALE_ESTIMATE__c
                //         //WHERE Order_User__c = :contactId AND (Order_Number__c = :stdConsumableOrderId != null ? stdConsumableOrderId : soldOutConsumableOrderId) AND Order_Number__c != null
                //         //WHERE Order_User__c = :contactId AND (Order_Number__c = :(stdConsumableOrderId != null && !stdConsumableOrderId.equals('')) ? stdConsumableOrderId : soldOutConsumableOrderId) AND Order_Number__c != null
                //         ORDER BY CreatedDate DESC
                // ]
        );

        String quoteHistoryQuery = '';
        quoteHistoryQuery += ' SELECT Id, BankBookCopy_YN__c, Business_Registration_YN__c, CreatedDate, Invoice_YN__c, Name, ';
        quoteHistoryQuery += ' Order_Number__c, Quote_Memo__c, Quote_PDF_URL__c,  Quote_YN__c, RCVR_Email__c,  RCVR_Name__c,  Send_YN__c, QuoteNum__c, OrderNumber__c ';
        quoteHistoryQuery += ' FROM SR_ONLINE_SALE_ESTIMATE__c ';
        
        //23.08.31 PHJ
        // quoteHistoryQuery += ' WHERE Order_User__c = \'' +contactId+ '\'';
        if (orderNumber != null && !orderNumber.equals('')){
            // quoteHistoryQuery += ' AND (OrderNumber__c = \'' + orderNumber + '\')' ;
            quoteHistoryQuery += ' WHERE (OrderNumber__c = \'' + orderNumber + '\')' ;
        }

        quoteHistoryQuery += ' ORDER BY CreatedDate ASC ';
        System.debug('quoteHistoryQuery :: ' + quoteHistoryQuery);
        listHistory = Database.query(quoteHistoryQuery);


        System.debug('err ' + listHistory);
        List<SR_ONLINE_SALE_ESTIMATE__c> esList = new List<SR_ONLINE_SALE_ESTIMATE__c>();
        Decimal num = 1;
        for (SR_ONLINE_SALE_ESTIMATE__c objPI : listHistory) {
            listResult.add(new ItemHistoryTable(num, objPI.OrderNumber__c, objPI.RCVR_Name__c, objPI.RCVR_Email__c, objPI.Quote_Memo__c, objPI.Quote_YN__c, objPI.Invoice_YN__c
                    , objPI.Business_Registration_YN__c, objPI.BankBookCopy_YN__c, objPI.Quote_PDF_URL__c, objPI.Send_YN__c, objPI.CreatedDate, objPI.Id));
            // objPI.Order_Number__c = orderNumber;
            if (String.isNotBlank(stdConsumableOrderId)) objPI.Order_Number__c = stdConsumableOrderId;
            if (String.isNotBlank(soldOutConsumableOrderId)) objPI.Order_Number__c = soldOutConsumableOrderId;
            esList.add(objPI);
            num++;
        }

        System.debug('listResult ' + listResult);

        /////23.04.14 contact
        if (String.isNotBlank(contactId)) {
            List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Id = :contactId LIMIT 1];
            if (!contacts.isEmpty()) {
                System.debug(contacts);
                mapResult.put('contactEmail', contacts[0].Email);
            }
        }

        mapResult.put('listResult', listResult);
        update esList;
        System.debug('mapResult > ' + mapResult);
        return mapResult;
    }

    /**
     * 소모품 주문관리의 견적/명세서 정보의 생성이력 조회
     * */
    @AuraEnabled
    public static Map<String, Object> getOrderDataList(Map<String, Object> paramMap) {

        String orderNumber = paramMap.get('orderNumber') != null ? (String) paramMap.get('orderNumber') : '';
        Map<String, Object> mapResult = new Map<String, Object>();
        List<ItemHistoryTable> listResult = new List<ItemHistoryTable>();


        List<SR_ONLINE_SALE_ESTIMATE__c> listHistory = new List<SR_ONLINE_SALE_ESTIMATE__c>([
                SELECT
                         BankBookCopy_YN__c,
                         Business_Registration_YN__c,
                         CreatedDate,
                         Invoice_YN__c,
                         Name,
                         Order_Number__c,
                         Quote_Memo__c,
                         Quote_PDF_URL__c,
                         Quote_YN__c,
                         RCVR_Email__c,
                         RCVR_Name__c,
                         Send_YN__c,
                         QuoteNum__c,
                         OrderNumber__c,
                         //23.04.29 추가
                         Id
                FROM     SR_ONLINE_SALE_ESTIMATE__c
                WHERE    OrderNumber__c = :orderNumber
                ORDER BY CreatedDate ASC
        ]);
        System.debug('err ' + listHistory);
        Decimal num = 1;
        for (SR_ONLINE_SALE_ESTIMATE__c objPI : listHistory) {
            listResult.add(new ItemHistoryTable(num, objPI.OrderNumber__c, objPI.RCVR_Name__c, objPI.RCVR_Email__c, objPI.Quote_Memo__c, objPI.Quote_YN__c, objPI.Invoice_YN__c
                    , objPI.Business_Registration_YN__c, objPI.BankBookCopy_YN__c, objPI.Quote_PDF_URL__c, objPI.Send_YN__c, objPI.CreatedDate, objPI.Id));
            // objPI.Order_Number__c = orderNumber;
            num++;
        }

        System.debug('listResult ' + listResult);
        if (listResult.size() != 0 & listResult != null) {
            mapResult.put('RCVRName', listResult[0].RCVR_Name);
            mapResult.put('RCVREmail', listResult[0].RCVR_Email);
        }

        mapResult.put('listResult', listResult);

        return mapResult;
    }

    @AuraEnabled
    public static Decimal doGetContactVIP(String contactId) {
        String vipType = '';
        String getDCPercent = '';
        Decimal percent = null;

        vipType = [
                SELECT CUSTOMER_GRADE__c, Id
                FROM   Contact
                WHERE  Id =: contactId
        ].CUSTOMER_GRADE__c;

        System.debug('vipType :: =>' + vipType);
        if (vipType != null) {
            
            // 24 01 04 PHJ
            getDCPercent = [
                            SELECT Id, CLASS_CODE__c, USE_YN__c, ATTRIBUTE3__c
                            FROM   SM_CODE__c
                            WHERE  CLASS_CODE__r.Name = 'CU007'
                            AND    USE_YN__c = 'Y'
                            AND    Name =: vipType
            ].ATTRIBUTE3__c;
    
            System.debug('getDCPercent :: =>' + getDCPercent);
    
            // percent = Integer.valueOf(getDCPercent) / 100;
            percent = Integer.valueOf(getDCPercent) * 0.01;
        } else {
            percent = 0;
        }

        // switch on vipType {

        //     when 'I1' {
        //         percent = 1;
        //     }
        //     when 'I2' {
        //         percent = 0.75;
        //     }
        //     when 'I3' {
        //         percent = 1;
        //     }
        //     when 'E1' {
        //         percent = 1;
        //     }
        //     when else {
        //         percent = 0;
        //     }
        // }

        System.debug('percent :: =>' + percent);

        return percent;
    }

    /**
     * @description 소모품 교환 주문 데이터 재조회
     * @author 23.02.28 / I2MAX.SEOKHOLEE
     * @return ''
     */
    @AuraEnabled
    public static Map<String, Object> doGetExchangeOrderData(List<Object> exchangeOrderData) {
        Map<String, Object> returnMap = new Map<String, Object>();
        Set<String> contactIdSet = new Set<String>();
        Set<String> prliSet = new Set<String>();

        for (Object obj : exchangeOrderData) {
            Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));

            String prliId = (String) objMap.get('Id');
            System.debug('productRequestLineItemId -> ' + prliId);
            prliSet.add(prliId);

            String contactId = (String) objMap.get('ContactId');
            contactIdSet.add(contactId);
        }

        List<Contact> contacts = [
                SELECT Id, Name, ADDRESS_NEW__c, ADDRESS_DETAIL__c, MobilePhone, Phone, fm_ADDRESS_NEW__c
                FROM   Contact
                WHERE  Id IN: contactIdSet
        ];

        System.debug(contacts);

        List<ProductRequestLineItem> productRequestLineItems = [
                SELECT Id, ParentId, SALE_Quantity__c, CONSUMER_Price__c, ASC_Price__c, Department_Code__c, Return_Order_Quantity__c,
                       ENDP_Code__c, Product2Id, Product2.DIV_CODE__c, Product2.Name, Product2.ProductCode, Product2.PART_DESC_KOR__c, Product2.CUST_PRICE__c, Product2.ASC_PRICE__c, MODEL__c, MODEL__r.Name, Product2.Model_CODE__c,
                       Order_CUST_Id__r.Name, Order_CUST_Id__r.Phone, Order_CUST_Id__r.MobilePhone, Order_CUST_Id__r.ADDRESS_NEW__c, Order_CUST_Id__r.ADDRESS_DETAIL__c,
                       SourceLocationId, Order_SEQ__c, Product2.PART_DESC__c, Order_CHNL_TYPE_Code__c, POINT_Amount__c
                FROM   ProductRequestLineItem
                WHERE  Id IN: prliSet
        ];

        Map<String, Decimal> basisOrderItemIdExpectedQuantityCountReturnQuantityMap = new Map<String, Decimal>();
        Decimal expectedQuantityCount;
        for (ReturnOrderLineItem roli : [SELECT QuantityExpected, Expected_Return_Quantity__c, QuantityReturned, Id, ProductRequestLineItemId FROM ReturnOrderLineItem WHERE ProductRequestLineItemId IN :prliSet]) {
            expectedQuantityCount = 0;

            if (basisOrderItemIdExpectedQuantityCountReturnQuantityMap.containsKey(roli.ProductRequestLineItemId)) {
                expectedQuantityCount = basisOrderItemIdExpectedQuantityCountReturnQuantityMap.get(roli.ProductRequestLineItemId);
                expectedQuantityCount += roli.Expected_Return_Quantity__c;

                basisOrderItemIdExpectedQuantityCountReturnQuantityMap.put(roli.ProductRequestLineItemId, expectedQuantityCount);
            } else {
                expectedQuantityCount = roli.Expected_Return_Quantity__c;

                basisOrderItemIdExpectedQuantityCountReturnQuantityMap.put(roli.ProductRequestLineItemId, expectedQuantityCount);
            }
        }

        List<ItemTable> itemTables = new List<ItemTable>();
        ItemTable itemTable;
        // 교환 주문시 재조회용 Id
        String productRequestId = null;

        // 포인트 여부
        Boolean hasPointAmount = false;
        //2023.08.28 seung yoon heo 반품요청 수량 OBS 채널 추가
         Boolean hasOBSCHNL = false;
        for (ProductRequestLineItem item : productRequestLineItems) {
            itemTable = new ItemTable();
            itemTable.Id = item.Id;
            // 교환시 원 주문의 Item Id
            itemTable.productRequestLineItemId = item.Id;
            itemTable.OrderSeq = item.Order_SEQ__c;

            itemTable.ParentId = item.ParentId;

            itemTable.DIVCODE = item.Product2.DIV_CODE__c;
            itemTable.sProductId = item.Product2Id;
            // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
            // itemTable.ProductCode = item.Product2.ProductCode;
            itemTable.ProductCode = item.Product2.Name;
            if (item.Product2.PART_DESC__c != null) {
                itemTable.ProductName = item.Product2.PART_DESC__c + '(' + item.Product2.Name + ')';
            } else {
                itemTable.ProductName = item.Product2.Name;
            }
            itemTable.SUBSTITUTE = '원';
            itemTable.Model = item.Product2.MODEL_CODE__c;
            itemTable.ModelId = item.MODEL__c;


            // 반품 예정 수량
            if (basisOrderItemIdExpectedQuantityCountReturnQuantityMap.containsKey(item.Id)) {
                itemTable.ExpectedReturnQuantity = basisOrderItemIdExpectedQuantityCountReturnQuantityMap.get(item.Id);
            } else {
                itemTable.ExpectedReturnQuantity = 0;
            }
            // 주문 / 판매 수량
            itemTable.SalesQuantity = item.SALE_Quantity__c;
            // 반품 수량
            itemTable.ReturnQuantity = item.Return_Order_Quantity__c != null ? item.Return_Order_Quantity__c : 0;

            //2023.08.28 seung yoon heo 반품요청 수량 OBS 채널 추가
            if (item.Order_CHNL_TYPE_Code__c == 'B') {
                hasOBSCHNL = true;
            }


            if (item.POINT_Amount__c > 0 && hasPointAmount == false) {
                hasPointAmount = true;
            }


            // 반품요청 수량
            //2023-07-19 gw.lee 수정
            //chnltypecode == 'v' : 반품 요청 수량 '0' 요청
            if((item.Order_CHNL_TYPE_Code__c == 'V' && hasPointAmount) || hasOBSCHNL) {
                itemTable.RequestedReturnQuantity = itemTable.SalesQuantity - (itemTable.ReturnQuantity + itemTable.ExpectedReturnQuantity);
            } else {
                itemTable.RequestedReturnQuantity = 0;
            }
            //itemTable.RequestedReturnQuantity = itemTable.SalesQuantity - (itemTable.ReturnQuantity + itemTable.ExpectedReturnQuantity);

            // 230526 원 주문 단가로 변경
            itemTable.Price = item.CONSUMER_Price__c;
            // 230522 원 주문 단가 추가
            itemTable.originConsumerPrice = item.CONSUMER_Price__c;

            itemTable.ASCPrice = item.Product2.ASC_PRICE__c;
            itemTable.sLocationId = item.SourceLocationId;

            itemTable.ChannelTypeCode = item.Order_CHNL_TYPE_Code__c;

            // Column Color Setting
            itemTable.DeliveryColor = 'bg_color_delivery';
            itemTable.CancelColor = 'bg_color_cancel';
            itemTable.ReturnColor = 'bg_color_return';
            itemTable.ExchangeColor = 'bg_color_exchange';
            System.debug('itemTable -> ' + itemTable);


            //2023-07-19 gw.lee 수정
            //chnltypecode == 'v' : 반품 요청 수량 '0' 요청
            if (itemTable.RequestedReturnQuantity > 0 || item.Order_CHNL_TYPE_Code__c == 'V') {
                itemTables.add(itemTable);
            }
            productRequestId = item.ParentId;
           
        }

        returnMap.put('itemTables', itemTables);
        if (!contacts.isEmpty()) {
            returnMap.put('contact', contacts[0]);
        } else {
            returnMap.put('contact', null);
        }
        returnMap.put('ChannelTypeCode', itemTables[0].ChannelTypeCode);
        returnMap.put('productRequestId', productRequestId);
        returnMap.put('hasPointAmount', hasPointAmount);
        returnMap.put('hasOBSCHNL', hasOBSCHNL);


        System.debug('start====================');
        System.debug(JSON.serializePretty(returnMap));
        System.debug('end====================');

        return returnMap;
    }

    /**
     * @description 자재 포탈에서 인입된 고객 정보 및 품목 정보 기준으로 데이터 재조회
     * @author 23.02.28 / I2MAX.SEOKHOLEE
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> doGetDataByMaterialPortal(Map<String, Object> paramMap) {
        Map<String, Object> mapResult = new Map<String, Object>();
        System.debug('paramMap ::: ' + paramMap);

        String contactId = (String) paramMap.get('contactId');

        Set<String> productIds = new Set<String>();
        if (paramMap.containsKey('productIds') && paramMap.get('productIds') != null) {
            for (Object productId : (List<Object>) paramMap.get('productIds')) {
                System.debug(productId);
                if (productId != null) {
                    productIds.add(String.valueOf(productId));
                }
                // Map<String, Object> testMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(productId));
                // if (productId != null) {
                //     productIds.add(String.valueOf(testMap.get('Product2Id')));
                // }
            }
        }

        System.debug(contactId);
        System.debug(productIds);


        if (!Test.isRunningTest()) EX_ConsumableUtil.createNotExistProductItem(productIds);

        List<Contact> contacts = new List<Contact>();
        if (contactId != null) {
            contacts = [
                    SELECT Name, MobilePhone, Phone, ADDRESS_NEW__c, ADDRESS_DETAIL__c, fm_ADDRESS_NEW__c, fm_ADDRESS_OLD__c
                    FROM   Contact
                    WHERE  Id =: contactId
                    LIMIT  1
            ];
        }
        Id consumableCenterId = EX_ConsumableUtil.getConsumableWareHouseId();

        List<ItemTable> listResult = new List<ItemTable>();
        List<Product2> productList;
        ItemTable itemTable;
        Boolean isDelivery = false;

        if (!productIds.isEmpty()) {
            productList = new List<Product2>([
                    SELECT Id, PART_SPEC__c, ProductCode, Name, MODEL_CODE__c, CUST_PRICE__c, ASC_PRICE__c, TECH_GRADE_PROD_CODE__c, TECH_PART_YN__c, DIV_CODE__c, DisplayUrl, Description, PART_DESC_KOR__c, Disabled_Type__c, PART_TYPE__c, DISABLED_DT__c, DISABLED_REL_DT__c, THINQ_ITEM_YN__c, PARCEL_YN__c, lu_MODEL_CODE__c, (
                            SELECT Id, LocationId, Location.Name, fm_Available_Quantity__c, ProductName, DIV_CODE__c, Product2Id, fm_Computerized_Quantity__c, RESRV_QTY__c, ALLOC_QTY__c
                                    , Product2.Name
                                    , Product2.ProductCode
                                    , Product2.PART_SPEC__c
                                    , Product2.MODEL_CODE__c
                                    , Product2.CUST_PRICE__c
                                    , Product2.ASC_PRICE__c
                                    , Product2.TECH_GRADE_PROD_CODE__c
                                    , Product2.TECH_PART_YN__c
                                    , Product2.DisplayUrl
                                    , Product2.Description
                                    , Product2.PART_DESC_KOR__c
                                    , Product2.PART_DESC__c
                                    , Product2.DISABLED_TYPE__c
                                    , Product2.PART_TYPE__c
                                    , Product2.THINQ_ITEM_YN__c
                                    , Product2.DISABLED_DT__c
                                    , Product2.DISABLED_REL_DT__c
                                    , Product2.PARCEL_YN__c
                                    , Product2.lu_MODEL_CODE__c

                            FROM  ProductItems
                            WHERE ((Product2.PART_TYPE__c = 'D' AND LocationId = :consumableCenterId)
                            OR(
                                Product2.PART_TYPE__c != 'D' AND Product2Id IN :productIds 
                                AND Location.RecordType.DeveloperName = 'DIV' 
                                AND (Location.LocationType = 'Warehouse' OR Location.LocationType = 'Site')

                            ))
                            //23 12 27 hyungho.chun PART_TYPE__c 소모품아닌것도 보여주게 productitems where에 OR 조건 추가
                            //AND fm_Available_Quantity__c > 0 //단종이지만 주문 가능 여부
                    ), (
                            SELECT Id, Name, toLabel(SUBSTITUTE_TYPE__c), SUBSTITUTE_PART_NO__c, PART_NO__r.lu_MODEL_CODE__c
                            FROM   SM_SUBSTITUTE_PART_Product_PART__r
                    )
                    FROM  Product2
                    WHERE Id IN: productIds
                    // AND   PART_TYPE__c = 'D' //23 12 27 hyungho.chun 소모품께아닌것도 화면에 보이게 해준다
                    //AND PARCEL_YN__c = 'Y' //택배가능여부
                    //AND SOLD_PART_YN__c = 'N' //품절부품여부
            ]);

            if (!productList.isEmpty()) {
                List<ProductItem> listPI;
                System.debug('productList -> ' + productList.size());
                for (Product2 obj : productList) {
                    // 원부품
                    System.debug('productList -> ' + obj);
                    System.debug('productList -> ' + obj.ProductItems);
                    System.debug('productList -> ' + !obj.ProductItems.isEmpty());
                    String divCode = obj.DIV_CODE__c;
                    if (!obj.ProductItems.isEmpty()) {
                        listPI = obj.ProductItems;

                        System.debug('listPI -> ' + listPI);
                        for (ProductItem objPI : listPI) {
                            String productName = objPI.ProductName;
                            String disabledType = 'N';
                            String partType = 'N';
                            String thinQItem = 'N';
                            String parcelYN = 'N';
                            String model = '';
                            String modelId = null;
                            if (objPI.Product2.PART_DESC_KOR__c != NULL) {
                                productName = objPI.Product2.PART_DESC_KOR__c + '(' + objPI.ProductName + ')';
                            //230909 gw.lee 로직 추가
                            //한글품명 없을 경우, 영어품명만 표출
                            } else if (objPI.Product2.PART_DESC__c  != NULL) {
                                productName = objPI.Product2.PART_DESC__c;
                            }
                            // if (objPI.Product2.DISABLED_DT__c != null && objPI.Product2.DISABLED_REL_DT__c == null) {
                            if (objPI.Product2.DISABLED_TYPE__c != null) {      //24 01 23 hyungho.chun 단종여부기준은 DISABLED_TYPE__c != null 로만 체크한다                                
                                disabledType = 'Y';
                            }
                            if (objPI.Product2.PART_TYPE__c == 'D') {
                                partType = 'Y';
                            }
                            if (objPI.Product2.THINQ_ITEM_YN__c == 'Y') {
                                thinQItem = 'Y';
                            }
                            if (objPI.Product2.PARCEL_YN__c == 'Y') {
                                parcelYN = 'Y'; 
                            } else {
                                parcelYN = 'N'; 
                            }

                            if (obj.MODEL_CODE__c != null) {
                                model = obj.MODEL_CODE__c;
                            }
                            if (obj.lu_MODEL_CODE__c != null) {
                                modelId = obj.lu_MODEL_CODE__c;
                            }
                            // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                            // itemTable = new ItemTable('원', divCode, objPI.Product2.ProductCode, objPI.Product2.TECH_GRADE_PROD_CODE__c, productName, objPI.Product2.PART_SPEC__c, objPI.fm_Available_Quantity__c > 0 ? objPI.fm_Available_Quantity__c : 0, objPI.Product2.CUST_PRICE__c, objPI.Product2.ASC_PRICE__c, '', objPI.Product2Id, objPI.Id, objPI.LocationId, objPI.Product2.DisplayUrl, objPI.Product2.Description, disabledType, partType, thinQItem, parcelYN, objPI.fm_Computerized_Quantity__c, objPI.ALLOC_QTY__c, '', 0, 0, 0, 0, model, modelId, '', 0, 0);
                            itemTable = new ItemTable('원', divCode, objPI.Product2.Name, objPI.Product2.TECH_GRADE_PROD_CODE__c, productName, objPI.Product2.PART_SPEC__c, objPI.fm_Available_Quantity__c > 0 ? objPI.fm_Available_Quantity__c : 0, objPI.Product2.CUST_PRICE__c, objPI.Product2.ASC_PRICE__c, '', objPI.Product2Id, objPI.Id, objPI.LocationId, objPI.Product2.DisplayUrl, objPI.Product2.Description, disabledType, partType, thinQItem, parcelYN, objPI.fm_Computerized_Quantity__c, objPI.ALLOC_QTY__c, '', 0, 0, 0, 0, model, modelId, '', 0, 0);
                            //23.08.02 gw.lee
                            //1로 셋팅 후 추가하면 2로 변환되는 케이스가 있어서, QTY 0으로 수정
                            itemTable.QTY = 0;

                            // 최초 자재포탈 인입시 Cell Color 세팅
                            itemTable.cellColor = 'bg_color';
                            // 최초 자재포탈 인입시 N 세팅, 이후 정상 조회 처리 시 null or 'Y' 처리
                            itemTable.isForMaterialPortalValid = 'N';
                            itemTable.Note = '재고 조회 필요';

                            //gw.lee 23.09.15 
                            //택배가능여부만 추가
                            //23 12 19 hyungho.chun 현장판매건도 이젠 내려오게합니다 (parcelYN == 'N' 추가)
                            if (parcelYN == 'Y' || parcelYN == 'N') {
                                listResult.add(itemTable);
                            } else if (!isDelivery){
                                isDelivery = true;
                            }
                        }
                    }
                }
            }
        }

        mapResult.put('listResult', listResult);
        mapResult.put('isDelivery', isDelivery);
        if(contacts != null && contactId != null) {
            mapResult.put('contact', contacts[0]);
        }

        system.debug(listResult);

        return mapResult;
    }

    @AuraEnabled
    public static Map<String, Object> doGetDataByMaterialPortal2(Map<String, Object> paramMap) {
        Map<String, Object> mapResult = new Map<String, Object>();
        System.debug('paramMap ::: ' + paramMap);

        String contactId = (String) paramMap.get('contactId');

        Set<String> productIds = new Set<String>();
        if (paramMap.containsKey('productIds') && paramMap.get('productIds') != null) {
            for (Object productId : (List<Object>) paramMap.get('productIds')) {
                System.debug(productId);
                // if (productId != null) {
                //     productIds.add(String.valueOf(productId));
                // }
                Map<String, Object> testMap = (Map<String, Object>)JSON.deserializeUntyped(JSON.serialize(productId));
                if (productId != null) {
                    productIds.add(String.valueOf(testMap.get('Product2Id')));
                }
            }
        }

        System.debug(contactId);
        System.debug(productIds);

        if (!Test.isRunningTest()) EX_ConsumableUtil.createNotExistProductItem(productIds);

        List<Contact> contacts = new List<Contact>();
        if (contactId != null) {
            contacts = [
                    SELECT Name, MobilePhone, Phone, ADDRESS_NEW__c, ADDRESS_DETAIL__c, fm_ADDRESS_NEW__c, fm_ADDRESS_OLD__c
                    FROM   Contact
                    WHERE  Id =: contactId
                    LIMIT  1
            ];
        }
        Id consumableCenterId = EX_ConsumableUtil.getConsumableWareHouseId();

        List<ItemTable> listResult = new List<ItemTable>();
        List<Product2> productList;
        ItemTable itemTable;
        Boolean isDelivery = false;

        if (!productIds.isEmpty()) {
            productList = new List<Product2>([
                    SELECT Id, PART_SPEC__c, ProductCode, Name, MODEL_CODE__c, CUST_PRICE__c, ASC_PRICE__c, TECH_GRADE_PROD_CODE__c, TECH_PART_YN__c, DIV_CODE__c, DisplayUrl, Description, PART_DESC_KOR__c, Disabled_Type__c, PART_TYPE__c, DISABLED_DT__c, DISABLED_REL_DT__c, THINQ_ITEM_YN__c, PARCEL_YN__c, lu_MODEL_CODE__c, (
                            SELECT Id, LocationId, Location.Name, fm_Available_Quantity__c, ProductName, DIV_CODE__c, Product2Id, fm_Computerized_Quantity__c, RESRV_QTY__c, ALLOC_QTY__c
                                    , Product2.Name
                                    , Product2.ProductCode
                                    , Product2.PART_SPEC__c
                                    , Product2.MODEL_CODE__c
                                    , Product2.CUST_PRICE__c
                                    , Product2.ASC_PRICE__c
                                    , Product2.TECH_GRADE_PROD_CODE__c
                                    , Product2.TECH_PART_YN__c
                                    , Product2.DisplayUrl
                                    , Product2.Description
                                    , Product2.PART_DESC_KOR__c
                                    , Product2.PART_DESC__c
                                    , Product2.DISABLED_TYPE__c
                                    , Product2.PART_TYPE__c
                                    , Product2.THINQ_ITEM_YN__c
                                    , Product2.DISABLED_DT__c
                                    , Product2.DISABLED_REL_DT__c
                                    , Product2.PARCEL_YN__c
                                    , Product2.lu_MODEL_CODE__c

                            FROM  ProductItems
                            WHERE ((Product2.PART_TYPE__c = 'D' AND LocationId = :consumableCenterId)
                            OR(
                                Product2.PART_TYPE__c != 'D' AND Product2Id IN :productIds 
                                AND Location.RecordType.DeveloperName = 'DIV' 
                                AND (Location.LocationType = 'Warehouse' OR Location.LocationType = 'Site')

                            ))
                            //23 12 27 hyungho.chun PART_TYPE__c 소모품아닌것도 보여주게 productitems where에 OR 조건 추가
                            //AND fm_Available_Quantity__c > 0 //단종이지만 주문 가능 여부
                    ), (
                            SELECT Id, Name, toLabel(SUBSTITUTE_TYPE__c), SUBSTITUTE_PART_NO__c, PART_NO__r.lu_MODEL_CODE__c
                            FROM   SM_SUBSTITUTE_PART_Product_PART__r
                    )
                    FROM  Product2
                    WHERE Id IN: productIds
                    // AND   PART_TYPE__c = 'D' //23 12 27 hyungho.chun 소모품께아닌것도 화면에 보이게 해준다
                    //AND PARCEL_YN__c = 'Y' //택배가능여부
                    //AND SOLD_PART_YN__c = 'N' //품절부품여부
            ]);

            if (!productList.isEmpty()) {
                List<ProductItem> listPI;
                System.debug('productList -> ' + productList.size());
                for (Product2 obj : productList) {
                    // 원부품
                    System.debug('productList -> ' + obj);
                    System.debug('productList -> ' + obj.ProductItems);
                    System.debug('productList -> ' + !obj.ProductItems.isEmpty());
                    String divCode = obj.DIV_CODE__c;
                    if (!obj.ProductItems.isEmpty()) {
                        listPI = obj.ProductItems;

                        System.debug('listPI -> ' + listPI);
                        for (ProductItem objPI : listPI) {
                            String productName = objPI.ProductName;
                            String disabledType = 'N';
                            String partType = 'N';
                            String thinQItem = 'N';
                            String parcelYN = 'N';
                            String model = '';
                            String modelId = null;
                            if (objPI.Product2.PART_DESC_KOR__c != NULL) {
                                productName = objPI.Product2.PART_DESC_KOR__c + '(' + objPI.ProductName + ')';
                            //230909 gw.lee 로직 추가
                            //한글품명 없을 경우, 영어품명만 표출
                            } else if (objPI.Product2.PART_DESC__c  != NULL) {
                                productName = objPI.Product2.PART_DESC__c;
                            }
                            // if (objPI.Product2.DISABLED_DT__c != null && objPI.Product2.DISABLED_REL_DT__c == null) {
                            if (objPI.Product2.DISABLED_TYPE__c != null) {      //24 01 23 hyungho.chun 단종여부기준은 DISABLED_TYPE__c != null 로만 체크한다
                                disabledType = 'Y';
                            }
                            if (objPI.Product2.PART_TYPE__c == 'D') {
                                partType = 'Y';
                            }
                            if (objPI.Product2.THINQ_ITEM_YN__c == 'Y') {
                                thinQItem = 'Y';
                            }
                            if (objPI.Product2.PARCEL_YN__c == 'Y') {
                                parcelYN = 'Y'; 
                            } else {
                                parcelYN = 'N'; 
                            }

                            if (obj.MODEL_CODE__c != null) {
                                model = obj.MODEL_CODE__c;
                            }
                            if (obj.lu_MODEL_CODE__c != null) {
                                modelId = obj.lu_MODEL_CODE__c;
                            }
                            itemTable = new ItemTable('원', divCode, objPI.Product2.Name, objPI.Product2.TECH_GRADE_PROD_CODE__c, productName, objPI.Product2.PART_SPEC__c, objPI.fm_Available_Quantity__c > 0 ? objPI.fm_Available_Quantity__c : 0, objPI.Product2.CUST_PRICE__c, objPI.Product2.ASC_PRICE__c, '', objPI.Product2Id, objPI.Id, objPI.LocationId, objPI.Product2.DisplayUrl, objPI.Product2.Description, disabledType, partType, thinQItem, parcelYN, objPI.fm_Computerized_Quantity__c, objPI.ALLOC_QTY__c, '', 0, 0, 0, 0, model, modelId, '', 0, 0);
                            //23.08.02 gw.lee
                            //1로 셋팅 후 추가하면 2로 변환되는 케이스가 있어서, QTY 0으로 수정
                            itemTable.QTY = 0;

                            // 최초 자재포탈 인입시 Cell Color 세팅
                            itemTable.cellColor = 'bg_color';
                            // 최초 자재포탈 인입시 N 세팅, 이후 정상 조회 처리 시 null or 'Y' 처리
                            itemTable.isForMaterialPortalValid = 'N';
                            itemTable.Note = '재고 조회 필요';

                            //gw.lee 23.09.15 
                            //택배가능여부만 추가
                            if (parcelYN == 'Y' || parcelYN == 'N') { //23 12 27 hyungho.chun 택배안되는건 소모품주문버튼 누를때 막음 
                                listResult.add(itemTable);
                            } else if (!isDelivery){
                                isDelivery = true;
                            }
                        }
                    }
                }
            }
        }

        mapResult.put('listResult', listResult);
        mapResult.put('isDelivery', isDelivery);
        if(contacts != null && contactId != null) {
            mapResult.put('contact', contacts[0]);
        }

        system.debug(listResult);

        return mapResult;
    }

    public class ItemHistoryTable {
        @AuraEnabled public Decimal Seq;
        @AuraEnabled public String OrderNUmber;
        @AuraEnabled public String RCVR_Name;
        @AuraEnabled public String RCVR_Email;
        @AuraEnabled public String Quote_Memo;
        @AuraEnabled public String Quote_YN;
        @AuraEnabled public String Invoice_YN;
        @AuraEnabled public String Business_Registration_YN;
        @AuraEnabled public String BankBookCopy_YN;
        @AuraEnabled public String Pdf_Url;
        @AuraEnabled public String Send_YN;
        @AuraEnabled public Datetime CreatedDate;
        //23.04.29 추가
        @AuraEnabled public Id id;

        public ItemHistoryTable(Decimal Seq, String OrderNUmber, String RCVR_Name, String RCVR_Email, String Quote_Memo, String Quote_YN, String Invoice_YN, String Business_Registration_YN
                                , String BankBookCopy_YN, String Pdf_Url, String Send_YN, Datetime CreatedDate, Id id) {
            this.Seq = Seq;
            this.OrderNUmber = OrderNUmber;
            this.RCVR_Name = RCVR_Name;
            this.RCVR_Email = RCVR_Email;
            this.Quote_Memo = Quote_Memo;
            this.Quote_YN = Quote_YN;
            this.Invoice_YN = Invoice_YN;
            this.Business_Registration_YN = Business_Registration_YN;
            this.BankBookCopy_YN = BankBookCopy_YN;
            this.Pdf_Url = Pdf_Url;
            this.Send_YN = Send_YN;
            this.CreatedDate = CreatedDate;
            this.id = id;
            System.debug('this : ' + this);
        }
    }
	
    /**
     * @description 소모품 교환 요청
     * @author 23.03.03 / I2MAX.SEOKHOLEE
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> createExchangeRequest(Map<String, Object> paramMap) {
        System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.createExchangeRequest (start):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        System.debug('소모품 교환 요청');
        System.debug(JSON.serializePretty(paramMap));
        // 주문채널
        String contactId = (String) paramMap.get('contactId');
        String consigneeName = (String) paramMap.get('consigneeName');
        String IbCallNo = (String) paramMap.get('IbCallNo');
        String newAddress = (String) paramMap.get('newAddress');
        String detailAddress = (String) paramMap.get('detailAddress');
        String zoneCode = (String) paramMap.get('zoneCode');

        System.debug('contactId -> ' + contactId);
        System.debug('consigneeName -> ' + consigneeName);
        System.debug('IbCallNo -> ' + IbCallNo);
        System.debug('newAddress -> ' + newAddress);
        System.debug('detailAddress -> ' + detailAddress);
        System.debug('zoneCode -> ' + zoneCode);

        String requestedTerm = (String) paramMap.get('requestedTerm');
        String remark = (String) paramMap.get('remark');
        Boolean isContactSame = (Boolean) paramMap.get('isContactSame');
        String strCaseId = (String) paramMap.get('strCaseId');
        //23.11.01 gw.lee
        //매니저 노트 추가
        String managerNote = (String) paramMap.get('managerNote');
        List<Object> exchangeReturnDataList = (List<Object>) paramMap.get('exchangeReturnData');
        List<ItemTable> standardOrderDataList = paramMap.containsKey('standardOrderData') ? (List<ItemTable>) JSON.deserialize((String) paramMap.get('standardOrderData'), List<ItemTable>.class) : null;
        List<ItemTable> soldOutOrderDataList = paramMap.containsKey('soldOutOrderData') ? (List<ItemTable>) JSON.deserialize((String) paramMap.get('soldOutOrderData'), List<ItemTable>.class) : null;
        Map<String, ItemTable> standardOrderDataMap = new Map<String, ItemTable>();

        if (exchangeReturnDataList.size() != (standardOrderDataList.size() + soldOutOrderDataList.size())) {
            throw new AuraHandledException('교환요청 할 부품 정보를 다시 확인 바랍니다.');
        }

        String productRequestLineItemId = null;
        String channelType;
        for (Object obj : exchangeReturnDataList) {
            Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));

            String objId = (String) objMap.get('Id');
            Integer requestedReturnQuantity = Integer.valueOf(objMap.get('RequestedReturnQuantity'));
            String divCode = (String) objMap.get('DIVCODE');
            String productCode = (String) objMap.get('ProductCode');

            System.debug('objId => ' + objId);
            System.debug('requestedReturnQuantity => ' + requestedReturnQuantity);

            for (ItemTable stdData : standardOrderDataList) {
                System.debug('stdData.productRequestLineItemId = ' + stdData.productRequestLineItemId);
                System.debug('stdData.QTY = ' + stdData.QTY);
                // if (objId == stdData.productRequestLineItemId && requestedReturnQuantity != stdData.QTY) {
                //     throw new AuraHandledException(divCode + ' / ' + productCode + ' / ' + '교환반품 수량과 교환주문 수량은 동일해야 합니다.');
                // }

                if(stdData.QTY == 0) {
                    throw new AuraHandledException('교환 주문 수량은 0 이 될 수 없습니다.');
                }
            }
            for (ItemTable sodData : soldOutOrderDataList) {
                System.debug('sodData.productRequestLineItemId = ' + sodData.productRequestLineItemId);
                System.debug('sodData.QTY = ' + sodData.QTY);
                if (objId == sodData.productRequestLineItemId && requestedReturnQuantity != sodData.QTY) {
                    throw new AuraHandledException(divCode + ' / ' + productCode + ' / ' + '교환반품 수량과 교환주문 수량은 동일해야 합니다.');
                }
            }
            productRequestLineItemId = objId;
            channelType = (String) objMap.get('ChannelTypeCode');
            paramMap.put('orderChannelType', channelType);
        }


        // if (paramMap.containsKey('channelType')) {
        //     switch on (String) paramMap.get('channelType') {
        //         when '소모품택배' {
        //             channelType = EX_ConsumableUtil.CONSUMABLE_CIC;
        //         }
        //         when 'LGE.COM' {
        //             channelType = EX_ConsumableUtil.CONSUMABLE_OBS;
        //         }
        //         when 'ThinQ' {
        //             channelType = EX_ConsumableUtil.CONSUMABLE_THINQ;
        //         }
        //         when '베스트샵' {
        //             channelType = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;
        //         }
        //     }
        // }
        
        System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.createExchangeRequest (validate):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        // 230520 / 교환주문의 주문 재 채번하기 위한 Parent Id Get
        List<ProductRequestLineItem> prlis = [
                SELECT ParentId, Parent.Order_CUST_Id__c, Parent.Description, 
                       Parent.Order_CUST_Name__c, Parent.Order_CUST_Address__c, Parent.Order_CUST_Address_DETAIL__c, Parent.Order_CUST_PostalCode__c, Parent.Order_CUST_TPNO_1__c, Parent.Order_CUST_TPNO_2__c,
                       CONSUMER_Price__c, Payment_Amount__c, SALE_Quantity__c
                FROM   ProductRequestLineItem
                WHERE  Id =: productRequestLineItemId
        ];

        System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.createExchangeRequest (query ProductRequestLineItem):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        if (!prlis.isEmpty()) {
            if (contactId == null || contactId == '') {
                contactId = prlis[0].Parent.Order_CUST_Id__c;
                paramMap.put('contactId',contactId); //24 02 01 hyungho.chun 교환주문에도 order_cust_id넣어줌
            }
            paramMap.put('originProductRequestId', prlis[0].ParentId);
        }

        //23.11.01 gw.lee 
        //교환주문의 원주문건 관리자메모 추가
        if (prlis[0].ParentId != null && managerNote != null) {
            ProductRequest obj = new ProductRequest(Id = prlis[0].ParentId);
            obj.Description = prlis[0].Parent.Description != null ? prlis[0].Parent.Description + '\n' + managerNote : managerNote;
            
            update obj;
        }

        try {
            System.debug('=====================================');
            System.debug('exchangeReturnData');
            System.debug(paramMap.get('exchangeReturnData'));

            System.debug('exchangeOrderData ');
            System.debug(paramMap.get('exchangeOrderData'));
            System.debug('=====================================');

            List<Contact> conInfo = [SELECT Phone, fm_ADDRESS_NEW__c, ADDRESS_NEW__c, ADDRESS_DETAIL__c, MobilePhone, Name, POSTAL_CODE__c FROM Contact WHERE Id = :contactId LIMIT 1];
            System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.createExchangeRequest (query Contact):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            String customerName = null;
            String customerPhone = null;
            String customerPhone2 = null;
            String customerAddress = null;
            String customerDetailAddress = null;
            String customerPostalCode = null;

            // if (!conInfo.isEmpty()) {
            //     customerName = conInfo[0].Name;
            //     customerPhone = conInfo[0].MobilePhone;
            //     customerPhone2 = conInfo[0].Phone;
            //     customerAddress = conInfo[0].ADDRESS_NEW__c;
            //     customerDetailAddress = conInfo[0].ADDRESS_DETAIL__c;
            //     customerPostalCode = conInfo[0].POSTAL_CODE__c;
            // } else {
            //     List<ProductRequestLineItem> prliList = [
            //             SELECT ParentId, Parent.Order_CUST_Name__c, Parent.Order_CUST_TPNO_1__c, Parent.Order_CUST_TPNO_2__c,
            //                     Parent.Order_CUST_Address__c, Parent.Order_CUST_Address_DETAIL__c, Parent.Order_CUST_PostalCode__c
            //             FROM ProductRequestLineItem
            //             WHERE Id = :productRequestLineItemId
            //             LIMIT 1
            //     ];
            //     customerName = prliList[0].Parent.Order_CUST_Name__c;
            //     customerPhone = prliList[0].Parent.Order_CUST_TPNO_1__c;
            //     customerPhone2 = prliList[0].Parent.Order_CUST_TPNO_2__c;
            //     customerAddress = prliList[0].Parent.Order_CUST_Address__c;
            //     customerDetailAddress = prliList[0].Parent.Order_CUST_Address_DETAIL__c;
            //     customerPostalCode = prliList[0].Parent.Order_CUST_PostalCode__c;
            // }

            customerName = prlis[0].Parent.Order_CUST_Name__c;
            customerPhone = prlis[0].Parent.Order_CUST_TPNO_1__c;
            customerPhone2 = prlis[0].Parent.Order_CUST_TPNO_2__c;
            customerAddress = prlis[0].Parent.Order_CUST_Address__c;
            customerDetailAddress = prlis[0].Parent.Order_CUST_Address_DETAIL__c;
            customerPostalCode = prlis[0].Parent.Order_CUST_PostalCode__c;

            paramMap.put('customerName', customerName);
            paramMap.put('customerPhone', customerPhone);
            paramMap.put('customerPhone2', customerPhone2);
            paramMap.put('customerAddress', customerAddress);
            paramMap.put('customerDetailAddress', customerDetailAddress);
            paramMap.put('customerPostalCode', customerPostalCode);

            
            //23 08 28 hyungho.chun 교환요청 총금액
            Decimal totalReturnAmt = prlis[0].Payment_Amount__c;
            Decimal divider = prlis[0].SALE_Quantity__c;

            String basisOrderNumber = (String) paramMap.get('basisOrderNumber');
            System.debug(' basis Order Number => ' + basisOrderNumber);
            // 소모품 교환반품, 교환주문 공통 고객정보
            Map<Object, Object> contactConsigneeInfoMap;

            // 1. 교환 반품 처리 Start
            List<Map<String, Object>> pListMapReturnRequestInfo = new List<Map<String, Object>>();
            EX_ConsumableUtil.ConsumableReturnOrderTable consumableReturnOrderTable = new EX_ConsumableUtil.ConsumableReturnOrderTable();
            EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable exchangeReturnItemTable;
            List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable> exchangeReturnItemTables = new List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable>();

            String productRequestId = null;
            
            System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.createExchangeRequest (before exchangeReturnItemTables):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            for (Object obj : exchangeReturnDataList) {
                Map<String, Object> objMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(obj));
                exchangeReturnItemTable = new EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable();
                exchangeReturnItemTable.Id = (String) objMap.get('Id');

                exchangeReturnItemTable.OrderNumber = basisOrderNumber;
                exchangeReturnItemTable.Product2Id = (String) objMap.get('sProductId');
                exchangeReturnItemTable.OrderSeq = (Decimal) objMap.get('OrderSeq');

                exchangeReturnItemTable.OrderStatus = '반품요청';
                exchangeReturnItemTable.DIV = (String) objMap.get('DIVCODE');
                exchangeReturnItemTable.RequestedPartNo = (String) objMap.get('ProductCode');

                exchangeReturnItemTable.RequestedReturnQuantity = Integer.valueOf(objMap.get('RequestedReturnQuantity'));
                exchangeReturnItemTable.ReturnRequestReason = '교환요청에 의한 교환반품';
                exchangeReturnItemTable.Product2Id = (String) objMap.get('sProductId');

                // 원 회수 부품
                exchangeReturnItemTable.BASIS_COLLECT_Parts = (String) objMap.get('sProductId');

                System.debug('Price :::: ' + (Decimal) objMap.get('Price'));
                System.debug('Price :::: ' + (Integer) objMap.get('RequestedReturnQuantity'));
                Decimal price = (Decimal) objMap.get('Price');
                Decimal qty = (Decimal) objMap.get('RequestedReturnQuantity');

                //23 08 29 hyungho.chun 부분교환용 금액 세팅
                //현재 이 for문은 화면상에서 lineitem을 하나만 고를수있어서 늘 한번만 돔
                totalReturnAmt = totalReturnAmt/( divider / qty );

                exchangeReturnItemTable.PaymentAmount = totalReturnAmt;
                exchangeReturnItemTable.ReturnPaymentAmount = totalReturnAmt;

                //소비자가
                exchangeReturnItemTable.CustomerPrice = price;
                //반품판매금액
                exchangeReturnItemTable.SaleAmount = price * qty;

                System.debug('exchangeReturnItemTable ::: ' + exchangeReturnItemTable);
                exchangeReturnItemTables.add(exchangeReturnItemTable);
            }

            consumableReturnOrderTable.ConsumableReturnOrderLineItemTables = exchangeReturnItemTables;

            consumableReturnOrderTable.OriginOrderNumber = basisOrderNumber;

            consumableReturnOrderTable.OriginOrderId = productRequestId;
            System.debug('OriginOrderId -> ' + consumableReturnOrderTable.OriginOrderId);

            consumableReturnOrderTable.ContactId = contactId;

            consumableReturnOrderTable.CustomerName = customerName;
            consumableReturnOrderTable.CustomerPhone = customerPhone;
            consumableReturnOrderTable.CustomerPhone2 = customerPhone2;

            consumableReturnOrderTable.CustomerAddress = customerAddress;
            consumableReturnOrderTable.CustomerDetailAddress = customerDetailAddress;
            consumableReturnOrderTable.CustomerPostalCode = customerPostalCode;

            if (isContactSame) {
                consumableReturnOrderTable.CONSIGNEE_Name = customerName;
                consumableReturnOrderTable.CONSIGNEE_Phone = customerPhone != null ? customerPhone : customerPhone2;
                consumableReturnOrderTable.CONSIGNEE_Address = customerAddress;
                consumableReturnOrderTable.CONSIGNEE_DetailAddress = customerDetailAddress;
                consumableReturnOrderTable.CONSIGNEE_PostalCode = customerPostalCode;
            } else {
                consumableReturnOrderTable.CONSIGNEE_Name = consigneeName;
                consumableReturnOrderTable.CONSIGNEE_Phone = IbCallNo;
                consumableReturnOrderTable.CONSIGNEE_Address = newAddress;
                consumableReturnOrderTable.CONSIGNEE_DetailAddress = detailAddress.trim() != '' ? detailAddress : '( )'; // 24 02 01 PHJ
                consumableReturnOrderTable.CONSIGNEE_PostalCode = zoneCode;
            }
            consumableReturnOrderTable.CaseDescription = remark;
            consumableReturnOrderTable.CaseId = strCaseId;
            consumableReturnOrderTable.DeliveryMessageContent = requestedTerm;

            //23 08 28 hyungho.chun 교환요청 총금액
            consumableReturnOrderTable.PaymentAmount = totalReturnAmt;
            consumableReturnOrderTable.ReturnPaymentAmount = totalReturnAmt;

            Map<String, Object> mapRequestInfo = new Map<String, Object>();
            mapRequestInfo.put('consumableReturnOrderTable', consumableReturnOrderTable);
            pListMapReturnRequestInfo.add(mapRequestInfo);
            
            System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.createExchangeRequest (after exchangeReturnItemTables):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            
            EX_ConsumableUtil.createReturnRequest(pListMapReturnRequestInfo, channelType, 'ExchangeReturn');
            System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.createExchangeRequest (EX_ConsumableUtil.createReturnRequest):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            // 1. 교환 반품 처리 End

            // 2. 교환 주문 처리 Start

            Decimal stdOrderTotalPaymentAmount = prlis[0].CONSUMER_Price__c * standardOrderDataList[0].QTY;
            System.debug('stdOrderTotalPaymentAmount ::: ' + stdOrderTotalPaymentAmount);
            paramMap.put('stdOrderTotalPaymentAmount', stdOrderTotalPaymentAmount);
            //속도측정 - 임시조치
            // if(UserInfo.getUserId()!='0056D000006LNrJQAW') {
            doSaveConsumableOrder(paramMap);
            // }
            // else {
            //     if(LABEL.IsTempNew=='N') doSaveConsumableOrder(paramMap);
            //     else new EX_ExchangeRequest(paramMap).doSaveConsumableOrder();
            // }
            
            // 2. 교환 주문 처리 End
            
            System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.createExchangeRequest (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        } catch (Exception e) {
            System.debug(e.getLineNumber() + 'Line || ' + e.getMessage());
            throw new AuraHandledException(e.getLineNumber() + 'Line || ' + e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static Map<String, Decimal> doGetPaymentAmount(Map<String, Object> paramMap) {
        String prId = (String) paramMap.get('prId');
        Id headerId = [SELECT Id FROM SR_PRE_PAYMENT_HEADER__c WHERE ATTR_RECORD_ID__c = :prId][0].Id;
        List<SR_PRE_PAYMENT_DETAIL__c> detailList = [SELECT DEPOSIT_TYPE__c, DEPOSIT_AMT__c, UPAD_DETAIL_TYPE__c FROM SR_PRE_PAYMENT_DETAIL__c WHERE SR_PRE_PAYMENT_HEADER_ID__c = :headerId];
        Map<String, Decimal> paymentMap = new Map<String, Decimal>();

        for (SR_PRE_PAYMENT_DETAIL__c detail : detailList) {
            if (detail.DEPOSIT_TYPE__c == 'A') {
                //현금
                paymentMap.put('cash', detail.DEPOSIT_AMT__c);
            } else if (detail.DEPOSIT_TYPE__c == 'B') {
                //카드
                paymentMap.put('card', detail.DEPOSIT_AMT__c);

            } else if (detail.DEPOSIT_TYPE__c == 'D') {
                //포인트
                paymentMap.put('point', detail.DEPOSIT_AMT__c);

            } else if (detail.DEPOSIT_TYPE__c == 'E') {
                if (detail.UPAD_DETAIL_TYPE__c == 'PG_URL') {
                    paymentMap.put('pgURL', detail.DEPOSIT_AMT__c);
                } 
                else if (detail.UPAD_DETAIL_TYPE__c == 'PG_VBANK') {
                    paymentMap.put('pgVBANK', detail.DEPOSIT_AMT__c);
                }
            }
        }
        return paymentMap;
    }

    public static Id getClassCodeId(String strMasterCode) {
        SM_CODE_MASTER__c codeMaster = [SELECT Id, Name, CLASS_CODE_NAME__c FROM SM_CODE_MASTER__c WHERE Name =: strMasterCode];
        return codeMaster?.Id;
    }

    @AuraEnabled
    public static getResvResponse identityCheck(String employeeName, String employeeNum, String listcompany) {

        SM_Code__c companyList = [SELECT Id, ATTRIBUTE1__c, CODE_NAME__c From SM_Code__c WHERE Id =: listcompany];


        FS_MCSCallout fmc = new FS_MCSCallout();
        Boolean Response = fmc.isEmployee(companyList.ATTRIBUTE1__c, employeeNum, employeeName, null, null);
        System.debug(Response + '리스폰스 :: identityCheck ');


        getResvResponse gp = new getResvResponse();
        gp.identityCheck = Response;
        gp.companyName = companyList.CODE_NAME__c;

        return gp;
    }

    @AuraEnabled
    public static getResvResponse identityCheckInternal(String employeeName, String employeeNum, String listcompany) {
        //employeeName, employeeNum, listcompany
        // Contact ctc = [select id from contact];
        // String strCode = getClassCodeId('UD009');
        // SM_Code__c companyList = [SELECT Id,ATTRIBUTE1__c,CODE_NAME__c From SM_Code__c WHERE Id = :listcompany];

        // FS_MCSCallout fmc = new FS_MCSCallout();
        // Boolean Response = fmc.isEmployee(listcompany, employeeNum, employeeName, null, null);
        // System.debug(Response + '리스폰스 :: identityCheck ');
        getResvResponse gp = new getResvResponse();
        //gp.identityCheck = Response;

        return gp;
    }

    // 2023.12.07 seung yoon heo 출고부서 추가
    @AuraEnabled
    public static Map<String, Object> getShipmentName(List<String> divCodeList){
        Map<String, Object> returnMap = new Map<String, Object>();

        List<SM_DEPT__c> deptList = [SELECT Name, DEPT_CODE__c FROM SM_DEPT__c WHERE DEPT_CODE__c IN : divCodeList ];

        if(deptList.size() > 0){
            for (SM_DEPT__c dept : deptList) {
                returnMap.put(dept.DEPT_CODE__c, dept.Name);
            }
        } else {
            for (String dept : divCodeList){
                returnMap.put(dept, dept);
            }
        }

       return returnMap;
    }

    //authText
    @AuraEnabled
    public static getResvResponse generateAuth(String phonenumber) {
        Integer authNo = (Integer) (Math.random() * (99999 - 10000 + 1)) + 10000;

        getResvResponse gp = new getResvResponse();
        gp.authText = String.valueof(authNo);

        phonenumber = phonenumber.replaceAll('-', '');
        doSendKakao(String.valueof(authNo), phonenumber);

        //SVC_LGE_MA_101

        /*
        Map<String, Object> data =  IFUtil.setInputParam('kakao');
        String msgContent='';
        /*
        msgContent +='[임직원 인증]\n';
        msgContent +='인증번호는 '+String.valueof(authNo)+'입\n';
        msgContent +='니다.\n';
        msgContent +='인증번호를 담당자에게 알려\n';
        msgContent +='주세요.';

        msgContent +='[임직원 인증]\n';
        msgContent +='인증번호는 '+String.valueof(authNo)+'입니다.\n';
        msgContent +='인증번호를 담당자에게 알려주세요.';

        System.debug(msgContent);
        //향후 바꾸기 a3E0p00000041AvEAI
        // Set<String> setReceiveMobileNo = new Set<String>{'01042371008'};
        Set<String> setReceiveMobileNo = new Set<String>{'01042371008'};
        IF_CM_BizBase.sendKakaoWithoutTemplate('SVC_LGE_MA_101', msgContent, setReceiveMobileNo, data);

        */

        return gp;
    }

    @Future(callout=true)
    public static void doSendKakao(String encryptednumber, String phonenumber) {
        Map<String, Object> data = IFUtil.setInputParam('kakao');
        String msgContent = '';
        /*
        msgContent +='[임직원 인증]\n';
        msgContent +='인증번호는 '+String.valueof(authNo)+'입\n';
        msgContent +='니다.\n';
        msgContent +='인증번호를 담당자에게 알려\n';
        msgContent +='주세요.';
        */
        msgContent += '[임직원 인증]\n';
        msgContent += '인증번호는 ' + encryptednumber + '입니다.\n';
        msgContent += '인증번호를 담당자에게 알려주세요.';

        System.debug(msgContent);
        //향후 바꾸기 a3E0p00000041AvEAI
        // Set<String> setReceiveMobileNo = new Set<String>{'01042371008'};
        Set<String> setReceiveMobileNo = new Set<String>{
                phonenumber
        };
        //IF_CM_BizBase.sendKakaoWithoutTemplate('SVC_LGE_MA_101', msgContent, setReceiveMobileNo, data);


        IF_CM_SFDC_KAKAO.InputParam inputParam = new IF_CM_SFDC_KAKAO.InputParam();
        inputParam.setPhoneNumber = new Set<String>{ phonenumber };
        inputParam.templateCode = 'SVC_LGE_MA_101';
        inputParam.smsTitle = 'LG전자 서비스 알림';
        inputParam.smsMsg = msgContent;
        inputParam.kakaoMsg = msgContent;
        inputParam.sendAt = Datetime.now();

        Map<String, Object> mapResult = IF_CM_SFDC_KAKAO.doSendKakao(inputParam);
        System.debug(LoggingLevel.DEBUG, 'sendKakaoMessage result ===' + mapResult);

        IF_CM_SFDC_KAKAO.Result kResult = (IF_CM_SFDC_KAKAO.Result) mapResult.get('resultWrapper');
        if (kResult == null) {
            kResult = (IF_CM_SFDC_KAKAO.Result) mapResult.get('result');
        }

        //saveKakaoResult(inputParam, kResult);

    }

    @AuraEnabled
    public static List<Map<String, String>> getCompanyList() {
        List<Map<String, String>> returnDataList = new List<Map<String, String>> ();
        try {
            String strCode = getClassCodeId('UD009');
            List<SM_Code__c> companyList = [
                                            SELECT Id
                                                   , CODE_NAME__c
                                                   , ATTRIBUTE1__c 
                                                   , USE_YN__c
                                            FROM   SM_Code__c 
                                            WHERE  CLASS_CODE__c = :strCode
                                            AND    USE_YN__c = 'Y'
                                            LIMIT  100];

            for (SM_Code__c companyRows : companyList) {
                Map<String, String> returnData = new Map<String, String>();
                returnData.put('CP_ID', companyRows.Id);
                returnData.put('CP_NAME', companyRows.CODE_NAME__c);

                returnDataList.add(returnData);
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return returnDataList;
    }

    @AuraEnabled
    public static String doRemoveFile(String strDocumentId) {
        String strMsg = 'SUCCESS';

        if (strDocumentId != null && strDocumentId != '') {
            List<ContentDocument> listDelContentDocument = new List<ContentDocument>();
            listDelContentDocument = [
                    SELECT Id
                    FROM ContentDocument
                    WHERE Id = :strDocumentId
            ];

            if (!listDelContentDocument.isEmpty()) {
                try {
                    System.debug('성공');
                    Database.delete(listDelContentDocument[0].Id);
                } catch (Exception e) {
                    System.debug('에러');
                    strMsg = 'ERROR';
                }
            }
        }

        return strMsg;
    }

    /**
     * @description 택배 주문화면의 Alarm톡 발송 전 메시지 Object 저장
     * @author 23.04.19 / I2MAX.SEUNGHUNAHN
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> saveMessageObject(String jsonString, String urlBranch, String contName) {
        Map<String, Object> paramMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        EX_Message__c etm = new EX_Message__c();
        Map<String, Object> returnMap = new Map<String, Object>();
        // final String templateCode = 'SVC_LGE_MACN_014_02';
        final String templateCode = 'SVC_LGE_MACN_014_03'; //24 03 13 hyungho.chun 템플릿 금액 뒤에 '원' 추가

        etm.Label1__c = paramMap.containsKey('ProductCode')
                ? (String) paramMap.get('ProductCode') : '';
        etm.Label2__c = paramMap.containsKey('PartNameKor')
                ? (String) paramMap.get('PartNameKor') : '';
        etm.Label3__c = paramMap.containsKey('Price')
                ? EX_ConsumableUtil.strToCurrencyWon(String.valueOf(paramMap.get('Price')))
                : '';
        etm.Label4__c = paramMap.containsKey(urlBranch)
                ? (String) paramMap.get(urlBranch) : '';

        //23.10.13 PHJ
        etm.Label5__c = contName != null ? contName : '';

        insert etm;

        returnMap.put('exObjId', Id.valueOf(etm.Id));

        Map<String, Object> relatedData = EX_MessageUtil.getRelatedData(templateCode, Id.valueOf(etm.Id));
        TemplateMgmt__c template = (TemplateMgmt__c) relatedData.get('template');
        List<TemplateParams__c> templateParamList = (List<TemplateParams__c>) relatedData.get('templateParamList');
        EX_Message__c messageObject = (EX_Message__c) relatedData.get('messageObject');
        Map<String, Object> populateMap = messageObject.getPopulatedFieldsAsMap();

        IF_CM_SFDC_KAKAO.InputParam inputParam = EX_MessageUtil.getInputParamForKaKao(template, templateParamList, populateMap);
        String smsMsg = inputParam.kakaoMsg;

        returnMap.put('receiverMsg', smsMsg);

        return returnMap;
    }

    /**
     * @description 임직원 인증 임시저장
     * @author 23.04.20 / I2MAX.JAEYEONLEE
     * @return
     */
    @AuraEnabled
    public static void setEmpData(Map<String, Object> paramMap) {
        //paramMap이 안넘어옴
        System.debug(' paramMap ' + paramMap.keySet());
        String orderNumber = (String) paramMap.get('orderNumber');

        String chkEmployeeName = (String) paramMap.get('chkEmployeeName');
        String chkEmployeeNum = (String) paramMap.get('chkEmployeeNum');
        String chkCompanyName = (String) paramMap.get('chkCompanyName');
        if (chkCompanyName != '임직원') {
            SM_Code__c companyList = [SELECT Id, ATTRIBUTE1__c, CODE_NAME__c From SM_Code__c WHERE Id = :chkCompanyName LIMIT 1];
            chkCompanyName = companyList.ATTRIBUTE1__c;
        }
        String chkEmployeeRelationShip = (String) paramMap.get('chkEmployeeRelationShip');

        Decimal paymentAmount = 0;
        Decimal discountAmount = 0;

        Boolean empTF = false; // 임시 PHJ

        List<ItemTable> standardOrderDataList = (List<ItemTable>) JSON.deserialize((String) paramMap.get('standardOrderDataList'), List<ItemTable>.class);
        List<ItemTable> soldOutOrderDataList = (List<ItemTable>) JSON.deserialize((String) paramMap.get('soldOutOrderDataList'), List<ItemTable>.class);

        List<ProductRequest> updatedPrList = new List<ProductRequest>();
        List<ProductRequestLineItem> updatedPrlList = new List<ProductRequestLineItem>();

        Map<String, ItemTable> standardOrderDataMap = new Map<String, ItemTable>();
        Map<String, ItemTable> soldOutOrderDataMap = new Map<String, ItemTable>();

        for (ItemTable item : standardOrderDataList) {
            standardOrderDataMap.put(item.Id, item);
        }
        for (ItemTable item : soldOutOrderDataList) {
            soldOutOrderDataMap.put(item.Id, item);
        }
        // FS_MCSCallout fmc = new FS_MCSCallout();
        // Map<String, String> ResponseMap = fmc.requestSearchEmp(chkCompanyName, chkEmployeeNum, chkEmployeeName, null, null);
        // System.debug('wwwwwwwwwww : '+ResponseMap.values());

        if (soldOutOrderDataList.size() != 0) {
            List<ProductRequest> soprList = [
                    SELECT Order_Number__c, EMP_NAME__c, EMP_NO__c, EMP_COMPANY_CODE__c, EMP_CEL_NO__c, EMP_RELATION_CODE__c, SALE_DC_TYPE__c, SALE_Amount__c, Discount_Amount__c
                    FROM   ProductRequest
                    WHERE  Order_Number__c =: soldOutOrderDataList[0].OrderNumber 
                    AND    RecordType.DeveloperName = 'Consumable'
                    AND Consumables_Order_Class_Code__c = 'Sold Out'
            ];

            List<ProductRequestLineItem> soprlList = [
                    SELECT Id, PAYMENT_Amount__c, Last_Discount_Amount__c, VIP_Discount_Amount__c, SALE_Discount_Type_Code__c
                    FROM   ProductRequestLineItem
                    WHERE  Order_Number__c =: soldOutOrderDataList[0].OrderNumber
                    AND Consumables_Order_Class_Code__c = 'Sold Out'
            ];

            for (ProductRequestLineItem prlData : soprlList) {

                // 24 01 22 PHJ
                // prlData.PAYMENT_Amount__c = soldOutOrderDataMap.get(prlData.Id).QTY * soldOutOrderDataMap.get(prlData.Id).Price - soldOutOrderDataMap.get(prlData.Id).QTY * soldOutOrderDataMap.get(prlData.Id).ASCPrice;
                // prlData.Last_Discount_Amount__c = soldOutOrderDataMap.get(prlData.Id).QTY * soldOutOrderDataMap.get(prlData.Id).ASCPrice;
                // prlData.Employees_Discount_Amount__c = soldOutOrderDataMap.get(prlData.Id).QTY * soldOutOrderDataMap.get(prlData.Id).ASCPrice;
                // 2024.01.09 seung yoon heo 임직원 설정시 update 제거(프로모션으로 남아야하는 경우가 있음)
                // prlData.SALE_Discount_Type_Code__c = 'E';
                // if(soldOutOrderDataMap.get(prlData.Id).PromotionPrice == 0 || soldOutOrderDataMap.get(prlData.Id).PromotionPrice >= (soldOutOrderDataMap.get(prlData.Id).Price - soldOutOrderDataMap.get(prlData.Id).ASCPrice)){
                
                    //24 02 15 hyungho.chun ASCPrice = 지점정가 (할인가격아님)
                if(soldOutOrderDataMap.get(prlData.Id).PromotionPrice == 0 || soldOutOrderDataMap.get(prlData.Id).PromotionPrice > soldOutOrderDataMap.get(prlData.Id).ASCPrice){
                    // prlData.PAYMENT_Amount__c = soldOutOrderDataMap.get(prlData.Id).QTY * soldOutOrderDataMap.get(prlData.Id).Price - soldOutOrderDataMap.get(prlData.Id).QTY * soldOutOrderDataMap.get(prlData.Id).ASCPrice;
                    prlData.PAYMENT_Amount__c = soldOutOrderDataMap.get(prlData.Id).QTY * soldOutOrderDataMap.get(prlData.Id).ASCPrice;
                    // prlData.Last_Discount_Amount__c = soldOutOrderDataMap.get(prlData.Id).QTY * soldOutOrderDataMap.get(prlData.Id).ASCPrice;
                    prlData.Last_Discount_Amount__c = soldOutOrderDataMap.get(prlData.Id).QTY * (soldOutOrderDataMap.get(prlData.Id).Price - soldOutOrderDataMap.get(prlData.Id).ASCPrice);
                    prlData.SALE_Discount_Type_Code__c = 'E';
                    empTF = true;
                } 
                else {
                    // prlData.PAYMENT_Amount__c = soldOutOrderDataMap.get(prlData.Id).QTY * soldOutOrderDataMap.get(prlData.Id).Price - soldOutOrderDataMap.get(prlData.Id).QTY * (soldOutOrderDataMap.get(prlData.Id).Price - soldOutOrderDataMap.get(prlData.Id).PromotionPrice);
                    prlData.PAYMENT_Amount__c = soldOutOrderDataMap.get(prlData.Id).QTY * soldOutOrderDataMap.get(prlData.Id).PromotionPrice;
                    prlData.Last_Discount_Amount__c = soldOutOrderDataMap.get(prlData.Id).QTY * (soldOutOrderDataMap.get(prlData.Id).Price - soldOutOrderDataMap.get(prlData.Id).PromotionPrice);
                    prlData.SALE_Discount_Type_Code__c = 'P';
                }

                paymentAmount += prlData.PAYMENT_Amount__c;
                discountAmount += prlData.Last_Discount_Amount__c;
                updatedPrlList.add(prlData);
            }
            for (ProductRequest prData : soprList) {
                prData.EMP_NAME__c = chkEmployeeName;
                prData.EMP_NO__c = chkEmployeeNum;
                prData.EMP_CEL_NO__c = '';
                prData.EMP_COMPANY_CODE__c = chkCompanyName;
                prData.EMP_RELATION_CODE__c = chkEmployeeRelationShip;
                
                // 24 01 22 PHJ
                // 2024.01.09 seung yoon heo 임직원 설정시 update 제거(프로모션으로 남아야하는 경우가 있음)
                // prData.SALE_DC_TYPE__c = 'E';
                if(empTF){
                    prData.SALE_DC_TYPE__c = 'E';
                }else{
                    prData.SALE_DC_TYPE__c = 'P';
                }

                prData.SALE_Amount__c = paymentAmount + discountAmount;
                prData.Discount_Amount__c = discountAmount;
                prData.PAYMENT_Amount__c = paymentAmount;
                updatedPrList.add(prData);
            }
        }

        paymentAmount = 0;
        discountAmount = 0;
        System.debug(standardOrderDataMap);
        if (standardOrderDataList.size() != 0) {
            List<ProductRequest> prList = [
                    SELECT Order_Number__c, EMP_NAME__c, EMP_NO__c, EMP_COMPANY_CODE__c, EMP_CEL_NO__c, EMP_RELATION_CODE__c, SALE_DC_TYPE__c, SALE_Amount__c, Discount_Amount__c
                    FROM   ProductRequest
                    WHERE  Order_Number__c =: standardOrderDataList[0].OrderNumber 
                    AND    RecordType.DeveloperName = 'Consumable'
                    AND Consumables_Order_Class_Code__c = 'General'
            ];

            List<ProductRequestLineItem> prlList = [
                    SELECT Id, PAYMENT_Amount__c, Last_Discount_Amount__c, VIP_Discount_Amount__c, SALE_Discount_Type_Code__c
                    FROM   ProductRequestLineItem
                    WHERE  Order_Number__c =: standardOrderDataList[0].OrderNumber
                    AND Consumables_Order_Class_Code__c = 'General'
            ];

            for (ProductRequestLineItem prlData : prlList) {
                if (standardOrderDataMap.get(prlData.Id) != null) {
                    
                    // 24 01 22 PHJ
                    // prlData.PAYMENT_Amount__c = standardOrderDataMap.get(prlData.Id).QTY * standardOrderDataMap.get(prlData.Id).Price - standardOrderDataMap.get(prlData.Id).QTY * standardOrderDataMap.get(prlData.Id).ASCPrice;
                    // prlData.Last_Discount_Amount__c = standardOrderDataMap.get(prlData.Id).QTY * standardOrderDataMap.get(prlData.Id).ASCPrice;
                    // prlData.Employees_Discount_Amount__c = standardOrderDataMap.get(prlData.Id).QTY * standardOrderDataMap.get(prlData.Id).ASCPrice;
                    // prlData.SALE_Discount_Type_Code__c = 'E';
                    // if(standardOrderDataMap.get(prlData.Id).PromotionPrice == 0 || standardOrderDataMap.get(prlData.Id).PromotionPrice >= (standardOrderDataMap.get(prlData.Id).Price - standardOrderDataMap.get(prlData.Id).ASCPrice)){
                        //24 02 15 hyungho.chun ASCPrice = 지점정가 (할인가격아님)
                    if(standardOrderDataMap.get(prlData.Id).PromotionPrice == 0 || standardOrderDataMap.get(prlData.Id).PromotionPrice > standardOrderDataMap.get(prlData.Id).ASCPrice){
                        // prlData.PAYMENT_Amount__c = standardOrderDataMap.get(prlData.Id).QTY * standardOrderDataMap.get(prlData.Id).Price - standardOrderDataMap.get(prlData.Id).QTY * standardOrderDataMap.get(prlData.Id).ASCPrice;
                        prlData.PAYMENT_Amount__c = standardOrderDataMap.get(prlData.Id).QTY * standardOrderDataMap.get(prlData.Id).ASCPrice;
                        // prlData.Last_Discount_Amount__c = standardOrderDataMap.get(prlData.Id).QTY * standardOrderDataMap.get(prlData.Id).ASCPrice;
                        prlData.Last_Discount_Amount__c = standardOrderDataMap.get(prlData.Id).QTY * (standardOrderDataMap.get(prlData.Id).Price - standardOrderDataMap.get(prlData.Id).ASCPrice);
                        prlData.SALE_Discount_Type_Code__c = 'E';
                        empTF = true;
                    }
                    else {
                        // prlData.PAYMENT_Amount__c = standardOrderDataMap.get(prlData.Id).QTY * standardOrderDataMap.get(prlData.Id).Price - standardOrderDataMap.get(prlData.Id).QTY * (standardOrderDataMap.get(prlData.Id).Price - standardOrderDataMap.get(prlData.Id).PromotionPrice);
                        prlData.PAYMENT_Amount__c = standardOrderDataMap.get(prlData.Id).QTY * standardOrderDataMap.get(prlData.Id).PromotionPrice;
                        prlData.Last_Discount_Amount__c = standardOrderDataMap.get(prlData.Id).QTY * (standardOrderDataMap.get(prlData.Id).Price - standardOrderDataMap.get(prlData.Id).PromotionPrice);
                        prlData.SALE_Discount_Type_Code__c = 'P';
                    }

                }

                paymentAmount += prlData.PAYMENT_Amount__c;
                discountAmount += prlData.Last_Discount_Amount__c;

                updatedPrlList.add(prlData);
            }
            for (ProductRequest prData : prList) {
                prData.EMP_NAME__c = chkEmployeeName;
                prData.EMP_NO__c = chkEmployeeNum;
                prData.EMP_CEL_NO__c = '';
                prData.EMP_COMPANY_CODE__c = chkCompanyName;
                prData.EMP_RELATION_CODE__c = chkEmployeeRelationShip;

                // 24 01 22 PHJ
                // prData.SALE_DC_TYPE__c = 'E';
                if(empTF){
                    prData.SALE_DC_TYPE__c = 'E';
                }else{
                    prData.SALE_DC_TYPE__c = 'P';
                }

                prData.SALE_Amount__c = paymentAmount + discountAmount;
                prData.Discount_Amount__c = discountAmount;
                prData.PAYMENT_Amount__c = paymentAmount;
                updatedPrList.add(prData);
            }
        }

        update updatedPrlList;
        update updatedPrList;
    }

    @AuraEnabled
    public static String doGetContactDept() {
        User currentUser = [
                SELECT Id, DEPT_CODE__c
                FROM   User
                WHERE  Id =: userInfo.getUserId()
        ][0];

        SM_DEPT__c objSmDept = new SM_DEPT__c();
        try {
            objSmDept = [
                    SELECT Id, Name, DEPT_CODE__c, HIGH_DEPT_CODE__c, DEPT_TYPE_SECOND__c, HIGH_DEPT_CODE__r.DEPT_CODE__c, AGENCY_DC_RATE__c
                    FROM   SM_DEPT__c
                    WHERE  DEPT_CODE__c = 'PH8002'
            ];

            //:currentUser.DEPT_CODE__c
        } catch (Exception e) {
            throw new AuraHandledException('사용자 소속의 조직(SM_DEPT__c) 데이터가 없습니다.');
        }
        return objSmDept != null ? objSmDept.Id : null;
    }

    /**
     * @description 임직원인증시 주문업데이트
     * @author 23.04.20 / I2MAX.JAEYEONLEE
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> sendKaKao(String templateCode, String objectId, String phoneNumber) {
        IF_CM_SFDC_KAKAO.Result result = EX_MessageUtil.sendKaKaoMessage(templateCode, objectId, phoneNumber);
        Map<String, Object> returnMap = new Map<String, Object>();

        returnMap.put('isSuccess', result.isSuccess);
        returnMap.put('errorMsg', result.errorMsg);

        return returnMap;
    }


    public class getResvResponse {
        @AuraEnabled
        public String authText { get; set; }
        @AuraEnabled
        public boolean identityCheck { get; set; }
        @AuraEnabled
        public String companyName { get; set; }
    }

    @Future(Callout=true)
    public static void sendSoldOutKakao(String templateCode, String message, String phone) {
        EX_Message__c exMessage = (EX_Message__c) JSON.deserialize(message, EX_Message__c.class);

        EX_PaymentUtil.sendKaKaoMessage(templateCode, exMessage, phone);
        insert exMessage;
    }
    public class ItemTable {
        @AuraEnabled public String Id;
        @AuraEnabled public String ParentId;
        @AuraEnabled public String key;
        @AuraEnabled public String SUBSTITUTE;
        @AuraEnabled public String DIVCODE;
        @AuraEnabled public String ProductCode;
        @AuraEnabled public String Grade;
        @AuraEnabled public String ProductName;
        @AuraEnabled public String PART_SPEC;
        @AuraEnabled public Decimal fm_Available_Quantity;
        @AuraEnabled public Decimal Price;
        @AuraEnabled public Decimal ASCPrice;
        @AuraEnabled public String TECH_PART_YN;
        @AuraEnabled public String DISABLED_TYPE;
        @AuraEnabled public String PART_TYPE;
        @AuraEnabled public String sSubStitueId;
        @AuraEnabled public String sProductId;
        @AuraEnabled public String sProductItemId;
        @AuraEnabled public String sLocationId;
        @AuraEnabled public String sDisplayUrl;
        @AuraEnabled public String sDescription;
        @AuraEnabled public Boolean actionDisabled;
        @AuraEnabled public String OBS_ITEM_YN;
        @AuraEnabled public String PARCEL_YN;
        @AuraEnabled public Decimal Computerized_Quantity;
        @AuraEnabled public Decimal RESRV_QTY;

        @AuraEnabled public Decimal QTY;
        // 주문(판매 수량)
        @AuraEnabled public Decimal SalesQuantity;
        // 반품 요청 수량
        @AuraEnabled public Decimal RequestedReturnQuantity;
        // 반품 예정 수량
        @AuraEnabled public Decimal ExpectedReturnQuantity;
        // 반품 수량
        @AuraEnabled public Decimal ReturnQuantity;

        @AuraEnabled public String OriginalProduct;
        // 지점 총 재고
        @AuraEnabled public Decimal Total_Quantity;
        @AuraEnabled public Decimal CardAmount;
        @AuraEnabled public Decimal CashAmount;
        @AuraEnabled public Decimal PointAmount;
        @AuraEnabled public String Model;
        @AuraEnabled public String ModelId;
        @AuraEnabled public String SUB_Order_Number;
        @AuraEnabled public String cellColor;

        @AuraEnabled public Decimal SalesAmount;

        // Table Cell Color
        @AuraEnabled public String DeliveryColor;
        @AuraEnabled public String CancelColor;
        @AuraEnabled public String ReturnColor;
        @AuraEnabled public String ExchangeColor;

        @AuraEnabled public String ShipmentCode;
        @AuraEnabled public Integer DIVQuantity;
        @AuraEnabled public Integer EXQuantity;
        @AuraEnabled public Integer DiscountAmount;

        @AuraEnabled public String ZoneCode;
        // 교환 ProductRequestLineItemId
        @AuraEnabled public String productRequestLineItemId;

        // 23.04.14
        @AuraEnabled public String OrderNumber { get; set; }
        @AuraEnabled public String OrderStatus { get; set; }

        // 23.04.18 /  OBS 전시판매정보
        @AuraEnabled public String ObsImageUrl; // OBS 이미지 URL
        @AuraEnabled public String ObsSalesURL; // OBS 판매 전시 URL
        @AuraEnabled public String PartNameKor; // PartNameKor : 한글 품명
        @AuraEnabled public String ObsMemberPrice; // ObsMemberPrice : OBS 회원가

        // 23.04.28
        @AuraEnabled public Decimal PromotionPrice; // 프로모션가
        @AuraEnabled public String Note ; //견적서 메모

        // 23.05.01 / 자재 포탈 인입용 Valid 여부 : 최초 인입시 N
        @AuraEnabled public String isForMaterialPortalValid;

        // 23.05.02
        @AuraEnabled public Decimal OrderSeq; // 주문 항번
        // 23.05.08
        @AuraEnabled public String ChannelTypeCode; // 주문 채널 코드
        // 23.05.10
        @AuraEnabled public String ResrvNumber; // 주문 예약 번호

        @AuraEnabled public String discountType; // 할인 유형
        // 23.05.18
        @AuraEnabled public Decimal SaleAmount;
        @AuraEnabled public Decimal LastDiscountAmount;

        // 23.05.22 // 교환 주문 잡이익/손해금액 계산을 위한 정보
        @AuraEnabled public Decimal originConsumerPrice; // 원 주문의 주문 당시 단가
        @AuraEnabled public Decimal ExtraProfitAmount; // 잡이익/손해금액

        // 23.07.27 // 교환 주문 잡이익/손해금액 계산을 위한 정보
        @AuraEnabled public Boolean basicOrder; // 일반 true, 교환 false

        @AuraEnabled public String orderType;

        public ItemTable() {
            system.debug('ItemTable');
        }
        public ItemTable(String SUBSTITUTE, String DIVCODE, String ProductCode, String Grade, String ProductName, String PART_SPEC, Decimal fm_Available_Quantity, Decimal Price, 
                        Decimal ASCPrice, String sSubStitueId, String sProductId, String sProductItemId, String sLocationId, String sDisplayUrl, String sDescription, String DISABLED_TYPE,
                        String PART_TYPE, String OBS_ITEM_YN, String PARCEL_YN, Decimal Computerized_Quantity, Decimal ALLOC_QTY, String OriginalProduct,
                        Decimal Total_Quantity,
                        Decimal CardAmount, Decimal CashAmount, Decimal PointAmount, String Model, String ModelId, String SUB_Order_Number, Integer DIVQuantity, Integer EXQuantity) {
            this.key = sProductItemId == '' ? sProductId : sProductItemId;
            this.SUBSTITUTE = SUBSTITUTE;
            this.DIVCODE = DIVCODE;
            this.ProductCode = ProductCode;
            this.Grade = Grade;
            this.ProductName = ProductName;
            this.PART_SPEC = PART_SPEC;
            this.fm_Available_Quantity = fm_Available_Quantity;
            this.Price = Price;
            this.ASCPrice = ASCPrice;
            this.TECH_PART_YN = TECH_PART_YN;
            this.sSubStitueId = sSubStitueId;
            this.sProductId = sProductId;
            this.sProductItemId = sProductItemId;
            this.sLocationId = sLocationId;
            this.sDisplayUrl = sDisplayUrl;
            this.sDescription = sDescription;
            this.actionDisabled = TECH_PART_YN == 'Y' ? true : false;
            this.DISABLED_TYPE = DISABLED_TYPE;
            this.PART_TYPE = PART_TYPE;
            this.OBS_ITEM_YN = OBS_ITEM_YN;
            this.PARCEL_YN = PARCEL_YN;
            this.Computerized_Quantity = Computerized_Quantity;
            this.RESRV_QTY = ALLOC_QTY;
            this.OriginalProduct = OriginalProduct;
            this.Total_Quantity = Total_Quantity;
            this.CashAmount = CashAmount;
            this.CardAmount = CardAmount;
            this.PointAmount = PointAmount;
            this.Model = Model;
            this.ModelId = ModelId;
            this.SUB_Order_Number = SUB_Order_Number;
            this.DIVQuantity = DIVQuantity;
            this.EXQuantity = EXQuantity;

            System.debug('this : ' + this);
        }

        public ItemTable(Object selectedObject) {
            List<String> fieldSetList = new List<String>{
                    'ProductCode', 'ProductName', 'ASCPrice', 'sDisplayUrl'
            };
            String selectedObjectInfo = selectedObject.toString();

            System.debug(selectedObject);
            System.debug(selectedObjectInfo.split(' ').size());
            for (String objInfo : selectedObjectInfo.split(' ')) {
                System.debug(objInfo);

            }
        }
    }

    /**
     * @description OBS 알림톡 (SVC_LGE_MACN_014) 소모품 메시지 Object 저장
     * @param component
     * @author 22.03.29 / I2MAX.SEUNGHUNAN
     */
    @AuraEnabled
    public static String insertExMessageObj(String selectedObjectStr, String templateCode) {
        Map<String, Object> selectedObject = (Map<String, Object>) JSON.deserializeUntyped(selectedObjectStr);
        TemplateMgmt__c template = [SELECT Id FROM TemplateMgmt__c WHERE TemplateCode__c = :templateCode][0];
        EX_Message__c messageObj = new EX_Message__c();
        try {
            messageObj.Label1__c = String.valueOf(selectedObject.get('ProductCode'));
            messageObj.Label2__c = String.valueOf(selectedObject.get('ProductName'));
            messageObj.Label3__c = String.valueOf(selectedObject.get('Price'));
            messageObj.TemplateId__c = template.Id;

            insert messageObj;
        } catch (Exception e) {
            return 'ERROR: ' + e.getMessage();
        }

        return messageObj.Id;
    }


    @Future(callout=true)
    public static void doSetPaymentData(Set<String> orderNumbers, String prData) {
        ProductRequest prValue = (ProductRequest) JSON.deserialize(prData, ProductRequest.class);
        System.debug('pr : '+ prValue);

        List<FNCommon.PickListDetail> kDetails = FNCommon.getGlobalPickListValues('smartro_virtual_bank');
        Map<String, String> kBankNameByCode = (Map<String, String>) SMapper.toMap(String.class, kDetails, 'value', 'label');
        if ([SELECT ID, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c, POINT_TRX_ID__c FROM SR_PRE_PAYMENT_DETAIL__c WHERE SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c IN :orderNumbers and PAYMENT_AREA_NO__c = 2].size() != 0) {
            SR_PRE_PAYMENT_DETAIL__c paymentDetail = [SELECT TID__c, ID, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c, POINT_TRX_ID__c, MOID__c, CARD_URL__c, VIRTUAL_ACCT_NUMBER__c FROM SR_PRE_PAYMENT_DETAIL__c WHERE SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c IN :orderNumbers and PAYMENT_AREA_NO__c = 2][0];
            // 소모품 결제 Id
            SR_SMARTRO_PAYMENT_REQUEST__c paymentRequest = [SELECT VBANK_NUM__c, BANK_CODE__c, PAYMETHOD__c FROM SR_SMARTRO_PAYMENT_REQUEST__c WHERE MOID__c = :paymentDetail.MOID__c][0];
            ProductRequest prType = [SELECT PAYMENT_TYPE__c FROM ProductRequest WHERE Id =: prValue.Id limit 1];

            if (prType.PAYMENT_TYPE__c == 'VBANK') {
                prValue.VBANK_NUM__c = String.valueof(paymentDetail.VIRTUAL_ACCT_NUMBER__c);
                prValue.ACQUIRE_NAME__c = String.valueOf(kBankNameByCode.get(paymentRequest.BANK_CODE__c));
                prValue.ACQUIRE_INFO__c = paymentRequest.BANK_CODE__c;
            } else if (prType.PAYMENT_TYPE__c == 'CASH') {
                prValue.VBANK_NUM__c = String.valueof(paymentDetail.VIRTUAL_ACCT_NUMBER__c);
                prValue.ACQUIRE_NAME__c = String.valueOf(kBankNameByCode.get(paymentRequest.BANK_CODE__c));
                prValue.ACQUIRE_INFO__c = paymentRequest.BANK_CODE__c;
            }

            prValue.MOID__c = paymentDetail.MOID__c != null ? paymentDetail.MOID__c : '';
            prValue.TID__c = paymentDetail.TID__c != null ? paymentDetail.TID__c : '';
        }

        update prValue;
    }

    @AuraEnabled
    public static Map<String, Object> doGetProductRequestCustInfo(String productRequestId) {
        Map<String, Object> infoMap = new Map<String, Object>();
        ProductRequest pr = [
                SELECT Order_CUST_Id__c, Order_CUST_Name__c, Order_CUST_PostalCode__c, Order_CUST_Address__c, Order_CUST_Address_DETAIL__c, Order_CUST_TPNO_1__c
                       , CONSIGNEE_Address__c, CONSIGNEE_Address_DETAIL__c, CONSIGNEE_TPNO_1__c, CONSIGNEE_TPNO_2__c, CONSIGNEE_PostalCode__c, CONSIGNEE_Name__c 
                FROM   ProductRequest
                WHERE  Id =: productRequestId
        ];

        infoMap.put('orderCustName', pr.Order_CUST_Name__c);
        infoMap.put('orderCustPhone', pr.Order_CUST_TPNO_1__c);
        infoMap.put('orderCustPostalCode', pr.Order_CUST_PostalCode__c);
        infoMap.put('orderCustAddress', pr.Order_CUST_Address__c);
        infoMap.put('orderCustAddressDetail', pr.Order_CUST_Address_DETAIL__c);
        infoMap.put('consigneeInfo', pr);


        return infoMap;
    }

    @AuraEnabled
    // public static void updateSoldOutOrderDataList(List<String> prLiIdSet) { 
    public static void updateSoldOutOrderDataList(String paramMap2) {    //24 02 14 hyungho.chun 파람 값 수정(할인유형 품절주문입고후적용시 대비)    
        System.debug('updateSoldOutOrder call');
        Set<String> prIdSet = new Set<String>();
        ProductRequest pr = null;
        
        System.debug('paramMap :: '+paramMap2);

        Map<String,Object> paramMap = (Map<String,Object>) JSON.deserializeUntyped(paramMap2);

        List<ProductRequestLineItem> prLiList = [
                SELECT Id, Consumables_Order_Status__c, ParentId, SHIPPED_Department_Code__c,PAYMENT_YN__c, PAYMENT_Amount__c, POINT_Amount__c, POINT_TRX_ID__c,Order_Number__c
                FROM   ProductRequestLineItem
                // WHERE  Id IN: prLiIdSet
                WHERE  Id IN: paramMap.keySet()
        ];

        for (ProductRequestLineItem prLi : prLiList) {
            prIdSet.add(prLi.ParentId);
        }

        pr = [
                SELECT Id,Order_Number__c,Status,PAYMENT_TYPE__c,PAYMENT_Method_Code__c,SALE_Amount__c,PAYMENT_Amount__c,PAYMENT_YN__c, Order_CUST_Name__c, Order_CUST_TPNO_1__c 
                FROM   ProductRequest
                WHERE  Id IN: prIdSet
        ][0];
        DateTime deliveryDate = getDeliveryDate();

        //24 02 08 hyungho.chun 쿼리 for문 밖으로 이동
        List<SR_PRE_PAYMENT_HEADER__c> paymentHeader = [SELECT Id, BASIS_NO__c,SALE_AMT__c FROM SR_PRE_PAYMENT_HEADER__c WHERE BASIS_NO__c = :pr.Order_Number__c];
        List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT ID, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c, PAY_CUST_PHONE__c, CERTIFY_KEY__c, INVOICE_ISSUE_TYPE__c, MOID__c,TID__c,CARD_URL__c  FROM SR_PRE_PAYMENT_DETAIL__c WHERE SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = :pr.Order_Number__c ORDER BY PAYMENT_AREA_NO__c];        

        for (ProductRequestLineItem prLi : prLiList) {
            //24 02 14 hyungho.chun 품절주문 입고후 결제할때 할인적용시킬시 업데이트할 로직 추가 시작
            Decimal Price = null;
            Decimal QTY = null;
            String discountType = null;
            Decimal DiscountAmount = null;
            if(paramMap.containsKey(prLi.Id)){
                Map<String,Object> tempMap = (Map<String,Object>) paramMap.get(prLi.Id);
                Price = (Decimal) tempMap.get('Price');
                QTY = (Decimal) tempMap.get('QTY');
                if(tempMap.containsKey('discountType')){
                    discountType = (String) tempMap.get('discountType');
                    DiscountAmount = (Decimal) tempMap.get('DiscountAmount');
                }
            }
            if (discountType != null) {
                if (discountType == '임직원') {
                    prLi.SALE_Discount_Type_Code__c = 'E';
                    prLi.Employees_Discount_Amount__c = DiscountAmount;
                    prLi.Last_Discount_Amount__c = DiscountAmount;
                    prLi.PAYMENT_Amount__c = Price * QTY - DiscountAmount;

                } else if (discountType == 'VIP') {
                    prLi.SALE_Discount_Type_Code__c = 'V';
                    prLi.VIP_Discount_Amount__c = DiscountAmount;
                    prLi.Last_Discount_Amount__c = DiscountAmount;
                    prLi.PAYMENT_Amount__c = Price * QTY - DiscountAmount;

                } else if (discountType == '프로모션' && DiscountAmount != 0) {
                    prLi.SALE_Discount_Type_Code__c = 'P';
                    prLi.PROMOTION_Discount_Amount__c = DiscountAmount;
                    prLi.Last_Discount_Amount__c = DiscountAmount;
                    prLi.PAYMENT_Amount__c = Price * QTY - DiscountAmount;

                }
            }
            //24 02 14 hyungho.chun 품절주문 입고후 결제할때 할인적용시킬시 업데이트할 로직 추가 끝

            if (prLi.Consumables_Order_Status__c == '000') {
                prLi.Consumables_Order_Status__c = '001';
            }
            // if ([SELECT Id, BASIS_NO__c FROM SR_PRE_PAYMENT_HEADER__c WHERE BASIS_NO__c = :pr.Order_Number__c].size() != 0) {
            if (paymentHeader.size() != 0) {               
                //24 02 08 hyungho.chun 쿼리 for문 밖으로 이동
                // SR_PRE_PAYMENT_HEADER__c paymentHeader = [SELECT Id, BASIS_NO__c FROM SR_PRE_PAYMENT_HEADER__c WHERE BASIS_NO__c = :pr.Order_Number__c][0];
                // List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT ID, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c FROM SR_PRE_PAYMENT_DETAIL__c WHERE SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = :pr.Order_Number__c order by PAYMENT_AREA_NO__c];
                if(paymentDetails.size() == 1) {
                    if (paymentDetails[0].DEPOSIT_TYPE__c == 'D') {
                        prLi.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006;
                        prLi.fm_deliveryTerm__c = deliveryDate;
                    }else if(paymentDetails[0].DEPOSIT_TYPE__c == 'B'){
                        prLi.CARD_PAYMENT_Amount__c = prLi.PAYMENT_Amount__c;
                        
                        // prLi.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_002; //24 02 06 hyungho.chun 품절예약 입고후 결제 데이터 생성시 바로 결제완료가 아니고 결제요청이다
                        // System.debug('아직 결제요청 상태 paymentDetails.size() == 1');
                    }else{
                        System.debug('아직 결제요청 상태 paymentDetails.size() == 1');
                    }
                }else if(paymentDetails.size() == 2){
                    if (paymentDetails[paymentDetails.size() - 1].DEPOSIT_TYPE__c == 'B') {
                        //23 08 07 hyungho.chun 현장카드+포인트시 현장카드금액추가
                        Decimal pointValue = prLi.POINT_Amount__c;
                        if(pointValue>0){
                            prLi.CARD_PAYMENT_Amount__c = prLi.PAYMENT_Amount__c - pointValue;
                            prLi.PAYMENT_YN__c = true;
                        }

                    }
                    if (paymentDetails[0].DEPOSIT_TYPE__c == 'D') {
                       
                        prLi.fm_deliveryTerm__c = deliveryDate; 
                    }                    
                    // prLi.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_002; //24 02 06 hyungho.chun 품절예약 입고후 결제 데이터 생성시 바로 결제완료가 아니고 결제요청이다
                    System.debug('아직 결제요청 상태 paymentDetails.size() == 2');
                }else{
                    prLi.SALE_Amount__c = 0;
                    prLi.PAYMENT_Amount__c = 0;
                    //할인 유형
                    prLi.Discount_Type_Code__c = '직원할인';                    
                }


            }
            prIdSet.add(prLi.ParentId);
        }

        /**
         *  prLiList = SoldOutDataList, pr = ProductRequest
         *  fixme: 여기 금액, 결제 일시 등 채워주시면 돼요 재연님
         */

         EX_Message__c message = new EX_Message__c(); //24 02 08 hyungho.chun 품절주문 -> 입고완료 -> 결제요청 -> 결제완료(100%포인트 or 포인트+현장카드) 알림톡용


        Decimal totalAmount = 0;
        // if ([SELECT Id, BASIS_NO__c FROM SR_PRE_PAYMENT_HEADER__c WHERE BASIS_NO__c = :pr.Order_Number__c].size() != 0) {
        if (paymentHeader.size() != 0) {                  
            // SR_PRE_PAYMENT_HEADER__c paymentHeader = [SELECT Id, BASIS_NO__c,SALE_AMT__c FROM SR_PRE_PAYMENT_HEADER__c WHERE BASIS_NO__c = :pr.Order_Number__c][0];
            // List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT ID, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c, PAY_CUST_PHONE__c, CERTIFY_KEY__c, INVOICE_ISSUE_TYPE__c, MOID__c  FROM SR_PRE_PAYMENT_DETAIL__c WHERE SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = :pr.Order_Number__c ORDER BY PAYMENT_AREA_NO__c];

            System.debug('속도측정 -------------------------------------------------- EX_SuppliesController.doSaveConsumableOrder (query SR_PRE_PAYMENT_DETAIL__c):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

            // if (paymentHeader != null) {
            if (paymentHeader.size() != 0) {
                
                //24 02 13 hyungho.chun CARD_URL__c 값있는경우 추가
                pr.Payment_URL__c = String.valueOf(paymentDetails[paymentDetails.size() - 1].CARD_URL__c);

                if (paymentDetails.size() == 1) {
                    if (paymentDetails[0].DEPOSIT_TYPE__c == 'A') {
                        // if (soldOutConsumableOrder.PAYMENT_TYPE__c == null) {
                            // soldOutConsumableOrder.PAYMENT_TYPE__c = 'VBANK';
                        // }
                        pr.PAYMENT_TYPE__c = 'VBANK'; //24 02 08 hyungho.chun
                        pr.Status = '';
                    } 
                    else if (paymentDetails[0].DEPOSIT_TYPE__c == 'B') {
                        pr.PAYMENT_Method_Code__c = 'CARD';
                        //24 02 08 hyungho.chun 
                        pr.PAYMENT_TYPE__c = 'CARD';
                        pr.CARD_PAYMENT_Amount__c = Integer.valueOf(paymentDetails[0].DEPOSIT_AMT__c);
                        pr.PAYMENT_YN__c = true;
                        pr.PAYMENT_COMPLETED_DTM__c = system.now();
                        message.Label1__c = EX_ConsumableUtil.strToCurrencyWon(String.valueOf(paymentDetails[0].DEPOSIT_AMT__c));
                        message.Label2__c = pr.Order_CUST_Name__c != null ? pr.Order_CUST_Name__c : '';
                        // if (pr.PAYMENT_TYPE__c == null) {
                        //     pr.PAYMENT_TYPE__c = 'CARD';
                        // }
                    } 
                    else if (paymentDetails[0].DEPOSIT_TYPE__c == 'E') {

                        //24 02 08 hyungho.chun
                        if ((paymentDetails[0].PAY_CUST_PHONE__c != paymentDetails[0].CERTIFY_KEY__c) && paymentDetails[0].UPAD_DETAIL_TYPE__c != 'PG_URL') {
                            
                            pr.CASH_DEPOSIT_YN__c = 'B';

                            pr.INVOICE_ISSUE_TYPE__c = paymentDetails[0].INVOICE_ISSUE_TYPE__c;
                        } else {
                            if (paymentDetails[0].UPAD_DETAIL_TYPE__c == 'PG_URL') {
                                pr.PAYMENT_TYPE__c = 'URL';
                            } else {
                                pr.INVOICE_ISSUE_TYPE__c = paymentDetails[0].INVOICE_ISSUE_TYPE__c;
                            }

                        }

                        //24 02 08 hyungho.chun 위로직태우고 아랜 주석처리 ( 일반주문 결제때랑 동일하게 수정)
                        // if (paymentDetails[0].UPAD_DETAIL_TYPE__c == 'PG_VBANK')
                        //     if (pr.PAYMENT_TYPE__c != null) {
                        //         if (pr.PAYMENT_TYPE__c == null) {
                        //             pr.PAYMENT_TYPE__c = 'URL';
                        //         }
                        //     }
                        // // else {
                        // //     soldOutConsumableOrder.PAYMENT_TYPE__c = 'VBANK';
                        // // }
                    } else if (paymentDetails[0].DEPOSIT_TYPE__c == 'D') {
                        pr.PAYMENT_TYPE__c = null;
                        pr.PAYMENT_Method_Code__c = 'POINT';
                        pr.PAYMENT_YN__c = true;
                        pr.PAYMENT_COMPLETED_DTM__c = system.now();
                        message.Label1__c = EX_ConsumableUtil.strToCurrencyWon(String.valueOf(paymentHeader[0].SALE_AMT__c));
                        message.Label2__c = pr.Order_CUST_Name__c != null ? pr.Order_CUST_Name__c : '';
                    }
                    totalAmount = paymentDetails[0].DEPOSIT_AMT__c;
                    
                    pr.MOID__c = paymentDetails[0].MOID__c != null ? paymentDetails[0].MOID__c : '';
                    pr.TID__c = paymentDetails[0].TID__c != null ? paymentDetails[0].TID__c : '';
                } else {

                    if (paymentDetails[paymentDetails.size() - 1].DEPOSIT_TYPE__c == 'A') {
                        // if (soldOutConsumableOrder.PAYMENT_TYPE__c == null) {
                        //       soldOutConsumableOrder.PAYMENT_TYPE__c = 'VBANK';
                        // }
                        System.debug('DEPOSIT_TYPE__c A');
                        //24 02 08 hyungoh.chun
                        pr.INVOICE_ISSUE_TYPE__c = paymentDetails[paymentDetails.size() - 1].INVOICE_ISSUE_TYPE__c;
                    } else if (paymentDetails[paymentDetails.size() - 1].DEPOSIT_TYPE__c == 'B') {
                        pr.PAYMENT_Method_Code__c = 'CARD';
                        //24 02 08 hyungoh.chun
                        pr.PAYMENT_TYPE__c = 'CARD';
                        pr.CARD_PAYMENT_Amount__c = Integer.valueOf(paymentDetails[paymentDetails.size() - 1].DEPOSIT_AMT__c);
                        pr.PAYMENT_YN__c = true;
                        pr.PAYMENT_COMPLETED_DTM__c = system.now();
                        message.Label1__c = EX_ConsumableUtil.strToCurrencyWon(String.valueOf(paymentHeader[0].SALE_AMT__c));
                        message.Label2__c = pr.Order_CUST_Name__c != null ? pr.Order_CUST_Name__c : '';
                        // if (pr.PAYMENT_TYPE__c == null) {
                        //     pr.PAYMENT_TYPE__c = 'CARD';
                        // }
                    } else if (paymentDetails[paymentDetails.size() - 1].DEPOSIT_TYPE__c == 'E') {
                        
                        if(paymentDetails[paymentDetails.size() - 1].MOID__c != null){
                            if ((paymentDetails[paymentDetails.size() - 1].PAY_CUST_PHONE__c != paymentDetails[paymentDetails.size() - 1].CERTIFY_KEY__c) && paymentDetails[paymentDetails.size() - 1].UPAD_DETAIL_TYPE__c != 'PG_URL') {
                                
                                pr.CASH_DEPOSIT_YN__c = 'B';
                                pr.INVOICE_ISSUE_TYPE__c = paymentDetails[paymentDetails.size() - 1].INVOICE_ISSUE_TYPE__c;
                            } else {
                                if (paymentDetails[paymentDetails.size() - 1].UPAD_DETAIL_TYPE__c == 'PG_URL') {
                                    pr.PAYMENT_TYPE__c = 'URL';
                                } else {
                                    
                                    pr.INVOICE_ISSUE_TYPE__c = paymentDetails[paymentDetails.size() - 1].INVOICE_ISSUE_TYPE__c;
                                }
                            }
                        }
                        else { 
                            pr.PAYMENT_TYPE__c = null;
                            pr.PAYMENT_Method_Code__c = 'POINT';
                            pr.PAYMENT_YN__c = true;
                            pr.PAYMENT_COMPLETED_DTM__c = system.now();
                            message.Label1__c = EX_ConsumableUtil.strToCurrencyWon(String.valueOf(paymentHeader[0].SALE_AMT__c));
                            message.Label2__c = pr.Order_CUST_Name__c != null ? pr.Order_CUST_Name__c : '';
                        }


                        //24 02 08 hyungho.chun 위로직태우고 아랜 주석처리 ( 일반주문 결제때랑 동일하게 수정)
                        // if (paymentDetails[paymentDetails.size() - 1].UPAD_DETAIL_TYPE__c == 'PG_VBANK') {
                        //     if (pr.PAYMENT_TYPE__c != null) {
                        //         if (pr.PAYMENT_TYPE__c == null) {
                        //             pr.PAYMENT_TYPE__c = 'URL';
                        //         }
                        //     }
                        //     // else {
                        //     //       soldOutConsumableOrder.PAYMENT_TYPE__c = 'VBANK';
                        //     // }
                        // }

                    } else if (paymentDetails[paymentDetails.size() - 1].DEPOSIT_TYPE__c == 'D') {
                        pr.PAYMENT_Method_Code__c = 'POINT';
                        // soldOutConsumableOrder.POINT_Amount__c = paymentDetails[0].DEPOSIT_AMT__c;
                    }

                    pr.MOID__c = paymentDetails[paymentDetails.size() - 1].MOID__c != null ? paymentDetails[paymentDetails.size() - 1].MOID__c : '';
                    pr.TID__c = paymentDetails[paymentDetails.size() - 1].TID__c != null ? paymentDetails[paymentDetails.size() - 1].TID__c : '';

                    totalAmount = paymentDetails[0].DEPOSIT_AMT__c + paymentDetails[1].DEPOSIT_AMT__c;
                }
                pr.PAYMENT_REQUEST_DATE__c = paymentDetails[0].CreatedDate;
                
                //24 02 08 hyungho.chun 품절주문 ->입고완료 -> 바로결제완료(포인트전액 or 현장카드)
                try {
                    System.debug('mesg : ' + message);
                    // if (pr.PAYMENT_Method_Code__c == 'POINT' || pr.PAYMENT_TYPE__c == 'CARD') {
                    if (pr.PAYMENT_Method_Code__c == 'POINT') { //24 03 09 hyungho.chun 현장카드건 이제 si_smarto_total_payment트리거에서 승인처리 될 때 상태업데이트 및 결제완료 알림톡 발송으로 수정
                        System.debug('1111 '+pr.Order_CUST_Name__c );
                        System.debug('1111 '+pr.Order_CUST_TPNO_1__c);
                        System.debug('1111 '+paymentDetails[0].PAY_CUST_PHONE__c);
                        //23.10.18 PHJ
                        EX_PaymentUtil.sendKaKaoMessage('SVC_LGE_MACN_013_1', message, pr.Order_CUST_TPNO_1__c != null ? pr.Order_CUST_TPNO_1__c : paymentDetails[0].PAY_CUST_PHONE__c);

                        insert message;
                    }
                } catch (Exception e) {
                    System.debug(e);
                }

            }
            System.debug('결제 : ' + pr.PAYMENT_TYPE__c);

        } else {
            System.debug('type cancel');
        }
        pr.PAYMENT_Amount__c = totalAmount;
        pr.Discount_Amount__c = pr.SALE_Amount__c - totalAmount; //24 02 14 hyungho.chun 할인금액추가
        //24 02 06 hyungho.chun 품절예약 입고완료후 결제요청시 기한 날짜 추가
        Datetime target = Datetime.newInstance(
            Date.today().addDays(1),
            Time.newInstance(23, 59, 0, 0)
        );    
        pr.LIMIT_TM__c = target;
        
        Map<String, String> trxOrderMap = new Map<String, String>();
       
        /**
         *   Key : Order_Number__c   values : ProductRequestLineItem List
         *   포인트 결제가 포함된 주문번호 별 ProductRequestLineItem 리스트
         */
        Map<String, List<ProductRequestLineItem>> orderNumberPrLiMap = new Map<String, List<ProductRequestLineItem>>();
        // 하기 맵에 저장하기 위한 임시 리스트
        List<ProductRequestLineItem> orderNumberPrLiList = null;

        // TRX_ID가 있는 주문번호별 ProductRequestLineItem List
        for (ProductRequestLineItem prLi : prLiList) {
            if (prLi.POINT_TRX_ID__c != null) {
                trxOrderMap.put(prLi.POINT_TRX_ID__c, prLi.Order_Number__c);
            } else if (prLi.POINT_TRX_ID__c == null) {
                continue;
            }
            orderNumberPrLiList = orderNumberPrLiMap.containsKey(prLi.Order_Number__c)
                    ? orderNumberPrLiMap.get(prLi.Order_Number__c)
                    : new List<ProductRequestLineItem>();
            orderNumberPrLiList.add(prLi);
            orderNumberPrLiMap.put(prLi.Order_Number__c, orderNumberPrLiList);
        }

        System.debug('trxAmountMap.keySet() : ' + trxOrderMap.keySet());

        /**
         *  ProductRequestLineItem 품목 2개 생성 시 DETAIL에는 TRX_ID__c가 1개 (TRX A)가 생성된다.
         *  하지만 품목(LineItem)에는 TRX_ID__c가 2개 (TRX A, TRX B)가 있으므로, TRX_ID 만으로는 생성된
         *  DETAIL을 식별하기가 어려워 주문번호 별 DETAIL을 식별하는 Map을 생성한다.
         */
        Map<String, SR_PRE_PAYMENT_DETAIL__c> detailMap = new Map<String, SR_PRE_PAYMENT_DETAIL__c>();
        
        List<SR_PRE_PAYMENT_DETAIL__c> detailList = [
                SELECT SR_SMARTRO_PAYMENT_REQUEST_ID__c, POINT_TRX_ID__c, PAYMENT_AREA_NO__c, SR_PRE_PAYMENT_HEADER_ID__c, DEPOSIT_TYPE__c, INPUT_TYPE__c, INVOICE_ISSUE_TYPE__c, PAY_CUST_NAME__c, PAY_CUST_PHONE__c, SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c,MBS_CUST_ID__c
                FROM   SR_PRE_PAYMENT_DETAIL__c
                WHERE  POINT_TRX_ID__c =: trxOrderMap.keySet()
        ];

        List<SR_SMARTRO_PAYMENT_REQUEST__c> reqList = [
                SELECT Id, MOID__c
                FROM   SR_SMARTRO_PAYMENT_REQUEST__c
                WHERE  MOID__c =: trxOrderMap.keySet()
        ];

        Map<String, Id> trxIdMap = new Map<String, Id>();

        // 원본의 DETAIL TRX_Id를 식별하기 위한 Set
        Set<String> preTrxIdSet = new Set<String>();
        for (SR_SMARTRO_PAYMENT_REQUEST__c req : reqList) {
            trxIdMap.put(req.MOID__c, req.Id);
        }
        for (SR_PRE_PAYMENT_DETAIL__c detail : detailList) {
            detailMap.put(detail.SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c, detail);
            preTrxIdSet.add(detail.POINT_TRX_ID__c);
        }
        List<SR_PRE_PAYMENT_DETAIL__c> newDetailList = new List<SR_PRE_PAYMENT_DETAIL__c>();

        /**
         *   TRX_ID__c가 있는 Order_Number__c, 즉 포인트가 포함된 주문 건
         */
        for (String orderNumber : new Set<String>(trxOrderMap.values())) {
            /**
             *   POINT_TRX_ID__c는 품목별로 찢어지지만 재경쪽 결제를 거치면
             *   TRX_ID__c가 단일로 통일되므로 그 건은 Continue를 통해 bypass
             */
            for (ProductRequestLineItem prLi : orderNumberPrLiMap.get(orderNumber)) {
                SR_PRE_PAYMENT_DETAIL__c baseDetail = detailMap.get(orderNumber).clone();
                if (preTrxIdSet.contains(prLi.POINT_TRX_ID__c)) {
                    baseDetail.DEPOSIT_AMT__c = prLi.POINT_Amount__c;
                } else {
                    if (baseDetail.PAYMENT_AREA_NO__c == 1) {
                        baseDetail.PAYMENT_AREA_NO__c = 3;
                    } else {
                        baseDetail.PAYMENT_AREA_NO__c = newDetailList.size() + 1;
                    }
                    baseDetail.SR_SMARTRO_PAYMENT_REQUEST_ID__c = trxIdMap.get(prLi.POINT_TRX_ID__c);
                    baseDetail.POINT_TRX_ID__c = prLi.POINT_TRX_ID__c;
                    baseDetail.DEPOSIT_AMT__c = prLi.POINT_Amount__c;
                }
                newDetailList.add(baseDetail);
            }
        }
        delete detailList;
        upsert newDetailList;

        try {
            update prLiList;
            update pr;
        } catch(Exception e) {
            throw new FNException('품절주문 주문상태 업데이트 실패');
        }
    }

    //sj.yang 2023.08.11
    public static Datetime getDeliveryDate() {

        Datetime deliveryDate = System.now(); // 정상배송완료일
        Integer stateYear = deliveryDate.year(); // 현재년도
        Integer countWDay = 0; // 평일 카운트
        Date stateDate = Date.newInstance(deliveryDate.year(), deliveryDate.month(), deliveryDate.day()+1); // 기준날짜
        Integer dTHour = deliveryDate.hour(); // 현재시간
        System.debug('현재시간 : ' + dTHour);
        
        if(dTHour < 18) { // 18시 이후 기준날짜 + 1
            stateDate = Date.newInstance(deliveryDate.year(), deliveryDate.month(), deliveryDate.day());
            System.debug('기준날짜 바뀜 : ' + stateDate);
        }
        
        List<SM_HOLIDAY_MASTER__c> HOLIDAYItems =  [
                                                    SELECT 	 Id, DIV_CODE__c, HOLI_END_DT__c, HOLI_START_DT__c, HOLI_TYPE__c, HOLY_REASON__c
                                                    FROM     SM_HOLIDAY_MASTER__c
                                                    WHERE    HOLI_TYPE__c IN ('A', 'B', 'D', 'Z')
                                                    AND      HOLI_APPLY_TY__c = 'C'
                                                    AND      CALENDAR_YEAR(HOLI_START_DT__c) IN(:stateYear, :stateYear+1)
                                                    AND      HOLI_START_DT__c >= TODAY
                                                    ORDER BY HOLI_START_DT__c ASC
        ];
        
        for(SM_HOLIDAY_MASTER__c sm : HOLIDAYItems) {
            if(countWDay == 2) {               
                break;
            } else if(countWDay == 0) {
                if(Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+1) == sm.HOLI_START_DT__c) {
                    stateDate = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+1);                    
                } else if(Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+2) == sm.HOLI_START_DT__c) {
                    stateDate = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+2);
                    countWDay++;                    
                } else {
                    stateDate = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+2);
                    break;                    
                }
            } else if(countWDay == 1) {
                if(Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+1) == sm.HOLI_START_DT__c) {
                    stateDate = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+1);                    
                } else {
                    stateDate = Date.newInstance(stateDate.year(), stateDate.month(), stateDate.day()+1);
                    countWDay++;           
                }
            }     
        }        
        deliveryDate = Datetime.newInstance(stateDate.year(), stateDate.month(), stateDate.day(), 23, 59, 59);
        System.debug('정상배송완료일 : ' + deliveryDate);
        return deliveryDate;
    }

    //23 09 04 hyungho.chun 주문번호로 주문자주소 미리 불러오기 ( 명세서 주소 자동기입 용도)
    @AuraEnabled
    public static String getAddressByOrderNumber(String OrderNumber){
        String orderAddress ='';
        List<ProductRequest> prList = [
                                        SELECT Id, CONSIGNEE_Address__c, CONSIGNEE_Address_DETAIL__c , Order_CUST_Address__c, Order_CUST_Address_DETAIL__c
                                        FROM   ProductRequest 
                                        WHERE  RecordType.DeveloperName IN ('Consumable' , 'CareSupplies' ) 
                                        AND    Order_Number__c =: OrderNumber
        ];

        // 240124 PHJ 결재자 주소를 가져오는걸로 변경
        orderAddress += prList[0].Order_CUST_Address__c != null ? prList[0].Order_CUST_Address__c : '';
        orderAddress += ' ';
        orderAddress += prList[0].Order_CUST_Address_DETAIL__c != null ? prList[0].Order_CUST_Address_DETAIL__c : '';
        // orderAddress += prList[0].CONSIGNEE_Address__c != null ? prList[0].CONSIGNEE_Address__c : '';
        // orderAddress += ' ';
        // orderAddress += prList[0].CONSIGNEE_Address_DETAIL__c != null ? prList[0].CONSIGNEE_Address_DETAIL__c : '';

        return orderAddress;
    }

    /** 자재 수기로 입고완료처리 하였을 경우, 메세지 발송
    * @description 
    * @author gw.lee | 01-10-2024
    * @param String recordId 
    * @return Object
    **/
    @future(callout=true)
    public static void sendOrderReceivingAlarm(String ptString) {

        List<ProductTransfer> listPT = (List<ProductTransfer>) JSON.deserialize(ptString, List<ProductTransfer>.class);

        List<String> idList = new List<String>();
        for (ProductTransfer ptObj : listPT) {
            idList.add(ptObj.Id);
        }

        //입고 완료 처리한 PT재조회
        List<ProductTransfer> prlistResrvList = [SELECT Id, ProductRequestLineItem.SR_RESRV_PART_ID__c, ProductRequestLineItem.Order_Number__c FROM ProductTransfer WHERE Id = :idList];
        
        Set<String> resrvNumList = new Set<String>();
        for (ProductTransfer sendObj : prlistResrvList) {
            if (sendObj.ProductRequestLineItem.SR_RESRV_PART_ID__c != null) {
                resrvNumList.add(sendObj.ProductRequestLineItem.SR_RESRV_PART_ID__c);
            }
        }

        //원주문건 조회
        List<ProductRequestLineITem> originOrderList = [SELECT ID, Order_Number__c, BASIS_Parts_Number__c, Parent.Order_CUST_TPNO_1__c
                                                        FROM ProductRequestLineItem
                                                        WHERE SR_RESRV_PART_Id__c = :resrvNumList 
                                                            AND Order_CHNL_Type_Code__c = 'V'
                                                            AND RecordType.DeveloperName = 'Consumable'];

        if (originOrderList.size() > 0) {
            String templateCode = 'SVC_LGE_MACN_S020';
            TemplateMgmt__c template = [SELECT Id, Content_c__c, Title__c, TemplateCode__c
                                        FROM TemplateMgmt__c
                                        WHERE TemplateCode__c=:templateCode][0];
    
            List<TemplateParams__c> templateParamList = [SELECT Id, Name, FieldApi__c
                                                            FROM TemplateParams__c
                                                            WHERE TemplateMgmt__c=:template.Id];
            
            //생성 List
            List<EX_Message__c> alarmList = new List<EX_Message__c>();
    
            for (ProductRequestLineItem oObj : originOrderList) {
                String phoneNoStr = oObj.Parent.Order_CUST_TPNO_1__c;
                String partNo = oObj.BASIS_Parts_Number__c;
                String orderNumber = oObj.Order_Number__c;

                TemplateMgmt__c templateTemp = template.clone();

                EX_Message__c alarm = new EX_Message__c();
                Map<String, Object> populateMap = alarm.getPopulatedFieldsAsMap();

                IF_CM_SFDC_KAKAO.InputParam inputParam = EX_MessageUtil.getInputParamForKaKao(templateTemp, templateParamList, populateMap);


                alarm.Label1__c = inputParam.templateCode;
                alarm.Label2__c = inputParam.kakaoMsg;
                alarm.Label3__c = inputParam.kakaoTitle;
                alarm.Label4__c = inputParam.kakaoMsg;
                alarm.Label5__c = '소모품 입고';
                alarm.Label6__c = phoneNoStr;
                alarm.Label7__c = String.valueOf(inputParam.sendAt); //신규 셋팅 필요
                alarm.Label8__c = 'EX_OrderReceiving_ba';
                alarm.Label9__c = 'N';

                alarmList.add(alarm);
            }

            if (alarmList.size() > 0) {
                insert alarmList;
            }
        }
    }
}