/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-03.
 */

public without sharing class EX_ConsumablesOrderManagementController {
    /**
    * @description Query String에 사용하기 위해 Set 데이터를 String으로 파싱
    * @author 23.02.27 / I2MAX현.SEUNGHUNAN
    * @return
    */
    static String setToString(Set<String> parentIdSet) {
        String str = '';
        for (Id prId : parentIdSet) {
            str += ('\'' + prId + '\'' + ', ');
        }
        return str.lastIndexOf(', ') != -1 ? '(' + str.substring(0, str.lastIndexOf(', ')) + ')' : '';
    }

    /**
    * @description 소모품 주문 관리 최초 조회 데이터
    *
    * @author 23.01.04 / I2MAX.SEOKHOLEE
    * @return
    */
    @AuraEnabled
    public static Map<String, Object> doGetInitData() {
        try {
            system.debug('doGetInitData');
            
            system.debug('currentUserId' + UserInfo.getUserId());
            User currentUser = [SELECT Id, DEPT_CODE__c, DEPT_NAME__c FROM User WHERE Id =: UserInfo.getUserId()];
            
            Map<String, Map<String, Object>> mapSettingValue = new Map<String, Map<String, Object>>();

            Map<String, List<Map<String, String>>> mapCommPickLists = new Map<String, List<Map<String, String>>>();
            // 소모품 주문 상태 코드
            //List<Map<String, String>> listOrderStatusCode = SObjectUtil.getPicklist('ProductRequestLineItem', 'Consumables_Order_Status_Code__c', false);
            List<Map<String, String>> listOrderStatusCode = EX_ConsumableUtil.getExOrderStatusList('ProductRequestLineItem', 'Order');

            mapCommPickLists.put('listOrderStatusCode', listOrderStatusCode);
            system.debug('listOrderStatusCode :: ' + listOrderStatusCode);


            // 주문 채널
            List<Map<String, String>> listOrderChannel = SObjectUtil.getPicklist('ProductRequestLineItem', 'Order_CHNL_TYPE_Code__c', false);
//            for (Map<String, String> orderChannel : listOrderChannel) {
////                for (String orderChannelKey : orderChannel.keySet()) {
////                    if (orderChannel.get(orderChannelKey) == EX_ConsumableUtil.CONSUMABLE_BESTSHOP) {
////                        orderChannel.remove(orderChannelKey);
////                    }
////                }
//            }


            mapCommPickLists.put('listOrderChannel', listOrderChannel);
            system.debug('listOrderChannel :: ' + listOrderChannel);


            // 상담 부서
            List<SM_DEPT__c> listConsultantCenter = new List<SM_DEPT__c>();

            //PHJ231208
            listConsultantCenter = [
                                    SELECT   Id
                                             , Name
                                             , DEPT_CODE__c
                                    FROM     SM_DEPT__c
                                    WHERE    CLOSE_YN__c != 'Y'
                                    AND      DEPT_TYPE_FIRST__c IN ('A', 'B')
                                    AND      DEPT_TYPE_SECOND__c IN ('D', 'E')
                                    AND      (NOT DEPT_CODE__c LIKE '124%')
                                    ORDER BY DEPT_TYPE_FIRST__c DESC
                                             , DEPT_TYPE_SECOND__c DESC
                                             , DEPT_NAME__c ASC
            ];
            // listConsultantCenter = [
            //         SELECT Id
            //                 , Name
            //                 , DEPT_CODE__c
            //         FROM SM_DEPT__c
            //         WHERE CLOSE_YN__c != 'Y'
            //         AND DEPT_TYPE_FIRST__c = 'B'
            //         AND DEPT_TYPE_SECOND__c = 'D'
            //         ORDER BY DEPT_TYPE_FIRST__c DESC
            //                 , DEPT_TYPE_SECOND__c DESC
            //                 , DEPT_NAME__c ASC
            // ];

            system.debug('listCenter :: ' + listConsultantCenter);

            //PHJ231208
            String currentUserDeptName;
            Map<String, String> deptMap = new Map<String, String>();
            List<Map<String, String>> listMapCenter = new List<Map<String, String>>();
            for (SM_DEPT__c obj : listConsultantCenter) {
                listMapCenter.add(new Map<String, String>{
                        // 'label' => obj.DEPT_CODE__c + '_' + obj.Name,
                        //23 12 09 hyungho.chun 조직코드는 빼달라는 요청
                        'label' => obj.Name,
                        'value' => obj.DEPT_CODE__c
                });
            }

            Boolean isSVC = isSVC(); //24 01 10 hyungho.chun 상담부서 자동완성 프로필기준도 체크후에 넣어줌
            for(Integer i=0; i<listMapCenter.size(); i++){
                //23 12 09 hyungho.chun 'label'에 이제 dept_code__c 포함아니라서 value기준으로 찾아서 보내줌
                if(listMapCenter[i].get('value').contains(currentUser.DEPT_CODE__c) && isSVC){
                    currentUserDeptName = listMapCenter[i].get('label');
                }
            }
            //END

            mapCommPickLists.put('listMapCenter', listMapCenter);

            //리턴 값
            mapSettingValue.put('Comm', mapCommPickLists);


            Map<String, Object> mapReturn = new Map<String, Object>{
                    'mapSettingValueOrigin' => mapSettingValue,
                    'currentUserDeptName' => currentUserDeptName //PHJ231208
            };

            return mapReturn;

        } catch (Exception e) {
            System.debug(e.getLineNumber() + 'Line || ' + e.getMessage());
            throw new AuraHandledException(e.getLineNumber() + 'Line || ' + e.getMessage());
        }
    }
    @AuraEnabled
    public static String doGetServiceResource() {
        ServiceResource kResource = [
                SELECT Id, RecordType.DeveloperName
                FROM ServiceResource
                WHERE RelatedRecordId = :UserInfo.getUserId()
                AND (RecordType.DeveloperName = 'SE' OR RecordType.DeveloperName = 'CNSL')
                AND IsActive = TRUE
        ][0];
        return kResource.RecordType.DeveloperName;
    }
    @AuraEnabled
    public static User doGetEmpInfo() {
        User currentUser = EX_ConsumableService.doGetManagerInfo();
//        permissonId = [
//                SELECT PermissionSetId ,AssigneeId,Assignee.name
//                FROM PermissionSetAssignment
//                WHERE AssigneeId= :UserInfo.getUserId() AND PermissionSet.label = '자재관리자'
//        ];
        // serviceResource
        return currentUser;

    }
    /**
    * @description 소모품 주문 관리 조회
    *
    * @author 23.01.04 / I2MAX.SEOKHOLEE
    * @return
    */
    @AuraEnabled
    public static Map<String, Object> doGetSearchData(Map<String, Object> mapSearchParam) {
        Map<String, Object> returnMap = new Map<String, Object>();
        try{




        System.debug('start====================');
        System.debug('mapSearchParam');
        System.debug(JSON.serializePretty(mapSearchParam));
        System.debug('end====================');

       


        List<ConsumableOrderTable> consumableOrderTables = new List<EX_ConsumablesOrderManagementController.ConsumableOrderTable>();
        ConsumableOrderTable consumableOrderTable;
        Integer orderSeq = 0, recordCount = 0;
        Decimal recordLimit = (Decimal) mapSearchParam.get('recordLimit');
        Decimal pageOffset = (Decimal) mapSearchParam.get('pageOffset');
        Boolean isSearchBtnClick = (Boolean) mapSearchParam.get('isSearchBtnClick');

        String strPRLIQuery = '';
        Set<String> productRequestIdSet = new Set<String>();
        System.debug('속도측정 -------------------------------------------------- 검색 (start):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        // SELECT
        strPRLIQuery += ' SELECT ' + ' ParentId';
        strPRLIQuery += ' , SUB_Order_Number__c ';
        strPRLIQuery += ' , Consumables_Order_Status__c ';
        strPRLIQuery += ' , Consumables_Business_Type_Code__c ';
        strPRLIQuery += ' , fm_Num_Consumable_status__c ';
        strPRLIQuery += ' , Appointment_Status__c ';
        strPRLIQuery += ' , BASIS_Order_Item_Id__r.Order_Number__c ';
        // strPRLIQuery += ' , CASH_PAYMENT_Amount__c ';
        // strPRLIQuery += ' , CARD_PAYMENT_Amount__c ';
        // strPRLIQuery += ' , POINT_Amount__c ';
        // strPRLIQuery += ' , PAYMENT_Method_Code__c ';

        // // 23.02.27 주문상태 추가
        // strPRLIQuery += ' , Consumables_Order_Status__c ';

        // strPRLIQuery += ' , Parent.APPR_NUM__c ';
        // strPRLIQuery += ' , Parent.CNSL_Department_Code__c ';
        // strPRLIQuery += ', Parent.CreatedDate ';
        // strPRLIQuery += ', Parent.CONSIGNEE_TPNO_1__c ';
        // strPRLIQuery += ', Parent.CONSIGNEE_Name__c ';
        // // Part
        // strPRLIQuery += ', Product2.PART_DESC_KOR__c ';
        // strPRLIQuery += ', Product2.Name ';
        // strPRLIQuery += ', Product2.CUST_PRICE__c ';

        // FROM
        strPRLIQuery += ' FROM ' + 'ProductRequestLineItem ';

        //////////////////////

        // WHERE
        strPRLIQuery += ' WHERE Id != null ';

        strPRLIQuery += ' AND Order_CHNL_TYPE_Code__c != NULL ';
        strPRLIQuery += ' AND RecordType.Name IN (\'소모품\', \'케어용품\' ) ';

                

        

        //주문번호가 있을때는 주문번호 우선 적용
        if (mapSearchParam.get('orderNo') != null && mapSearchParam.get('orderNo') != '') {
            String orderNo = (String) mapSearchParam.get('orderNo');
            strPRLIQuery += ' AND Parent.Order_Number__c = \'' + orderNo + '\'';
        }//2023.09.01 seung yoon heo CJ주문번호 추가 
        else if(mapSearchParam.get('CJorderNo') != null && mapSearchParam.get('CJorderNo') != ''){
            String orderNo = (String) mapSearchParam.get('CJorderNo');
            strPRLIQuery += ' AND FFMT_Order_Number__c = \'' + orderNo + '\'';
        } //23.11.22 PHJ 판매번호 필터추가
        else if(mapSearchParam.get('salesNo') != null && mapSearchParam.get('salesNo') != ''){
            String salesNo = (String) mapSearchParam.get('salesNo');
            // strPRLIQuery += ' AND SALE_Number__c = \'' + salesNo + '\'';
            strPRLIQuery += ' AND SR_SALE__r.SALE_Number__c = \'' + salesNo + '\'';
        } else {
            if (mapSearchParam.get('orderChannel') != null && mapSearchParam.get('orderChannel') != '' && mapSearchParam.get('orderChannel') != 'ALL') {
                // 소모품 주문 채널
                String orderChannel = (String) mapSearchParam.get('orderChannel');
                strPRLIQuery += ' AND Parent.Order_CHNL_TYPE_Code__c = \'' + orderChannel + '\'';
            }
            if (mapSearchParam.get('orderStatus') != null && mapSearchParam.get('orderStatus') != '' && mapSearchParam.get('orderStatus') != 'ALL') {
                // 소모품 주문 상태
                String orderStatus = (String) mapSearchParam.get('orderStatus');
                //strPRLIQuery += ' AND Consumables_Order_Status_Code__c = \'' + orderStatus + '\'';
                strPRLIQuery += ' AND Consumables_Order_Status__c = \'' + orderStatus + '\'';

            }
            if (mapSearchParam.get('baseDateStart') != null && mapSearchParam.get('baseDateEnd') != null
                    && mapSearchParam.get('baseDateStart') != '' && mapSearchParam.get('baseDateEnd') != '') {
                // // 소모품 주문 시작 기준 일자
                // strPRLIQuery += ' AND DAY_ONLY(convertTimezone(Parent.Order_Date__c)) >= ' + mapSearchParam.get('baseDateStart');
                // // 소모품 주문 종료 기준 일자
                // strPRLIQuery += ' AND DAY_ONLY(convertTimezone(Parent.Order_Date__c)) <= ' + mapSearchParam.get('baseDateEnd');

                //23 08 21 hyungho.chun day_only 제거
                String tempStr = String.valueOf(mapSearchParam.get('baseDateStart'));
                
                Date tempDate = Date.valueOf(tempStr);
                system.debug('tempDate before :: '+tempDate);
                Date tempDate2 = tempDate.addDays(-1);
                system.debug('tempDate after :: '+tempDate2);

                system.debug('tempStr before ::'+tempStr);
                tempStr = String.valueOf(tempDate2);
                system.debug('tempStr after :: '+tempStr);                

                // strPRLIQuery += ' parentId AND Parent.Order_Date__c >= ' + tempStr+'T15:00:00.000+0000';                        


                // 소모품 주문 종료 기준 일자
                // strPRLIQuery += ' AND Parent.Order_Date__c <= ' + mapSearchParam.get('baseDateEnd')+'T14:59:59.000+0000';

                strPRLIQuery += ' AND parentId IN (SELECT ID FROM ProductRequest WHERE Order_Date__c >= ' + tempStr+'T15:00:00.000+0000';                        


                // 소모품 주문 종료 기준 일자
                strPRLIQuery += ' AND Order_Date__c <= ' + mapSearchParam.get('baseDateEnd')+'T14:59:59.000+0000 ';
                strPRLIQuery += ' AND Order_CHNL_TYPE_Code__c != null )';
            }
            if (mapSearchParam.get('contactName') != null && mapSearchParam.get('contactName') != '') {
                // 소모품 주문 고객 명
                String contactName = (String) mapSearchParam.get('contactName');
                // strPRLIQuery += ' AND Parent.Order_CUST_Id__r.Name = \'' + contactName + '\'';
                //2023.09.07 seung yoon heo 주문 기준으로 고객명 조회
                strPRLIQuery += ' AND Parent.Order_CUST_Name__c = \'' + contactName + '\'';
            }
            if (mapSearchParam.get('contactPhone') != null && mapSearchParam.get('contactPhone') != '') {
                // 소모품 주문 고객 전화 번호
                String contactPhone = (String) mapSearchParam.get('contactPhone');
                // strPRLIQuery += ' AND Parent.Order_CUST_Id__r.MobilePhone = \'' + contactPhone + '\'';
                //2023.09.07 seung yoon heo 주문 기준으로 전화번호 조회
                strPRLIQuery += ' AND Parent.Order_CUST_TPNO_1__c = \'' + contactPhone + '\'';
            }
            if (mapSearchParam.get('consigneePhone') != null && mapSearchParam.get('consigneePhone') != '') {
                // 수취인 전화 번호
                String consigneePhone = (String) mapSearchParam.get('consigneePhone');
                strPRLIQuery += ' AND Parent.CONSIGNEE_TPNO_1__c = \'' + consigneePhone + '\'';
            }

            if (mapSearchParam.get('consigneeName') != null && mapSearchParam.get('consigneeName') != '') {
                // 수취인 주문 고객 명
                String consigneeName = (String) mapSearchParam.get('consigneeName');
                //대량 주문처리를 위해 LIKE 제거
                strPRLIQuery += ' AND Parent.CONSIGNEE_Name__c = \'' + consigneeName + '\'';
            }
            if (mapSearchParam.get('partNo') != null && mapSearchParam.get('partNo') != '') {
                // 소모품 주문 파트 넘버
                String partNo = (String) mapSearchParam.get('partNo');
                strPRLIQuery += ' AND fm_PART_NO__c LIKE \'' + '%' + partNo + '%' + '\'';

            }
            if (mapSearchParam.get('CNSLDiv') != null && mapSearchParam.get('CNSLDiv') != '' && mapSearchParam.get('CNSLDiv') != 'ALL') {
                // 소모품 주문 상담 부서?
                String CNSLDiv = (String) mapSearchParam.get('CNSLDiv');
                System.debug('CNSLDiv');
                System.debug(CNSLDiv);
                //strPRLIQuery += ' AND Requester_Department_Code__c = \'' + CNSLDiv + '\'';
                strPRLIQuery += ' AND Parent.CNSL_Department_Code__c = \'' + CNSLDiv + '\'';
            }
            if (mapSearchParam.get('CNSLUser') != null && mapSearchParam.get('CNSLUser') != '') {

                String CNSLUser = (String) mapSearchParam.get('CNSLUser');

                Set<String> CNSUserSet = new Set<String>();
        
        
                // 유저 Id 찾기
                System.debug('속도측정 -------------------------------------------------- 사용자 검색 (start):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                List<User> CNSuser = [SELECT Id FROM User WHERE Name =:(String) mapSearchParam.get('CNSLUser') ];
                System.debug('속도측정 -------------------------------------------------- 사용자 검색 (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                for (User cns : CNSuser) {
                    CNSUserSet.add(cns.Id);
                }
        
                
                // 소모품 주문 상담사
                
              
                System.debug('CNSUserSet');
                System.debug(CNSLUser);
                // strPRLIQuery += ' AND Parent.CreatedBy.Name LIKE \'' + '%' + CNSLUser + '%' + '\'';
                //test때문에 잠시 주석
                strPRLIQuery += ' AND (Parent.CreatedById__c IN :CNSUserSet)';
                // strPRLIQuery += ' AND Parent.OwnerId IN :CNSUserSet ';
            }

            //2023.09.01 seung yoon heo 결제완료 여부 조건 추가
            if (mapSearchParam.get('isPaymentY') != null && mapSearchParam.get('isPaymentN') != null) {
                if (mapSearchParam.get('isPaymentY') != mapSearchParam.get('isPaymentN')) {
                    if ((Boolean) mapSearchParam.get('isPaymentY')) {
                        strPRLIQuery += ' AND Parent.PAYMENT_YN__c = true ';
                    } else {
                        strPRLIQuery += ' AND Parent.PAYMENT_YN__c = false ';
                    }
                }
            }
        }

        //////////////////////


        // WHERE
//        strPRLIQuery += ' WHERE Id != null ';

        // 일반 원 주문, Order No 없을 경우, 원주문건만 검색되게끔 쿼리 내용 추가
        // 23 09 26 hyungho.chun mapSearchParam.get('orderNo') == null 뿐만아니라 mapSearchParam.get('orderNo') == ''일떄도 조건에 걸어야한다
        if (mapSearchParam.get('orderNo') == null || mapSearchParam.get('orderNo') == '') {
            strPRLIQuery += ' AND Consumables_Business_Type_Code__c = ' + '\'' + 'Order' + '\'';
        }
        
        // ORDER BY
        // strPRLIQuery += ' ORDER BY CreatedDate DESC ';
        
        System.debug('strPRLIQuery >>>');
        System.debug(strPRLIQuery);

        System.debug('속도측정 -------------------------------------------------- 검색 쿼리 전 (start):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        List<ProductRequestLineItem> productRequestLineItems = Database.query(strPRLIQuery);
        System.debug('속도측정 -------------------------------------------------- 검색 쿼리 후 (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        // 23.09.01 gw.lee
        //주문번호가 교환일 경우, 원주문 번호로 다시 재검색
        if (mapSearchParam.get('orderNo') != null) {
            if (productRequestLineItems.size() > 0) {
                if (productRequestLineItems[0].Consumables_Business_Type_Code__c == 'ExchangeOrder' && mapSearchParam.get('orderNo') != productRequestLineItems[0].BASIS_Order_Item_Id__r.Order_Number__c) {
                    System.debug('LGW TEst :::: ' + productRequestLineItems[0].BASIS_Order_Item_Id__r);
                    mapSearchParam.put('orderNo', productRequestLineItems[0].BASIS_Order_Item_Id__r.Order_Number__c);

                    returnMap = doGetSearchData(mapSearchParam);
                    System.debug('LGW TEST :::: ');
                    return returnMap;
                }
            }
        }
        System.debug('속도측정 -------------------------------------------------- Mapping Start (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        Map<String, String> consumableOrderStatusMap = new Map<String, String>();
        Map<String, String> consumableAppointmentStatusMap = new Map<String, String>();
        Map<String, Decimal> statusNumMap = new Map<String, Decimal>();
        Map<String, Integer> prliSizeMap = new Map<String, Integer>();

        for (ProductRequestLineItem prLi : ProductRequestLineItems) {
            productRequestIdSet.add(prLi.ParentId);
           
            if (prliSizeMap.containsKey(prLi.ParentId)) {
                Integer prliCount = prliSizeMap.get(prLi.ParentId);
                prliSizeMap.put(prLi.ParentId, prliCount + 1);
            } else {
                prliSizeMap.put(prLi.ParentId, 1);
            }


            if (prLi.SUB_Order_Number__c != null
                    && prLi.SUB_Order_Number__c.contains('-')
                    && prLi.SUB_Order_Number__c.split('-').size() > 2
                    && prLi.SUB_Order_Number__c.split('-')[prLi.SUB_Order_Number__c.split('-').size() - 1].equals('01')) {
                        consumableOrderStatusMap.put(prLi.ParentId, EX_ConsumableUtil.CONSUMABLE_STATUS_CODE_KOR_MAP.get(prLi.Consumables_Order_Status__c));
            }

            consumableAppointmentStatusMap.put(prLi.ParentId , prLi.Appointment_Status__c);
            // consumableOrderTable.AppointmentStatus = prLi.Appointment_Status__c;

            if (prli.fm_Num_Consumable_status__c != null && prli.fm_Num_Consumable_status__c > 0) {

                if (statusNumMap.containsKey(prLi.ParentId)) {
                    Decimal prliCount = statusNumMap.get(prLi.ParentId);
                    statusNumMap.put(prLi.ParentId, prliCount + prLi.fm_Num_Consumable_status__c);
                } else {
                    statusNumMap.put(prLi.ParentId, prLi.fm_Num_Consumable_status__c);
                }

            }

            

        }
        
        system.debug('productRequestIdSet::' + productRequestIdSet);

        // returnMap.put('productRequestLineItems', productRequestLineItems);

        if (!productRequestIdSet.isEmpty()) {
            // 실제 Query 시작
            String strQuery = '', whereClause = '';
            // SELECT
            //2023.08.17 seung yoon heo field 추출
            // strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequest');
            strQuery += ' SELECT Id ';
            strQuery += ' , toLabel(Order_CHNL_TYPE_Code__c) ';
            strQuery += ' , Order_Number__c ';
            strQuery += ' , Order_Date__c ';
            strQuery += ' , toLabel(Consumables_Order_Class_Code__c) ';
            strQuery += ' , toLabel(Consumables_Business_Type_Code__c) ';
            strQuery += ' , fm_IsMaskingTarget__c ';
            strQuery += ' , fm_ENC_CONSIGNEE_Name__c ';
            strQuery += ' , fm_ENC_CONSIGNEE_TPNO_1__c ';
            strQuery += ' , fm_ENC_CONSIGNEE_TPNO_2__c ';
            strQuery += ' , fm_ENC_Order_CUST_Name__c ';
            strQuery += ' , fm_ENC_Order_CUST_TPNO_1__c ';
            strQuery += ' , CONSIGNEE_Name__c ';
            strQuery += ' , CONSIGNEE_TPNO_1__c ';
            strQuery += ' , CONSIGNEE_TPNO_2__c ';
            strQuery += ' , Order_CUST_Name__c ';
            strQuery += ' , Order_CUST_TPNO_1__c ';
            strQuery += ' , PAYMENT_TYPE__c ';
            strQuery += ' , PAYMENT_YN__c ';
            strQuery += ' , fm_PAYMENT_TYPE__c ';
            strQuery += ' , PAYMENT_Method_Code__c ';
            strQuery += ' , SALE_Amount__c ';
            strQuery += ' , Discount_Amount__c ';
            strQuery += ' , PAYMENT_Amount__c ';
            strQuery += ' , fm_funnel__c ';
            strQuery += ' , CaseId ';
            strQuery += ' , fmURL_CaseNumber__c ';
            strQuery += ' , MOID__c ';
            strQuery += ' , TID__c ';
            strQuery += ' , APPR_DT__c ';
            strQuery += ' , Order_CUST_Id__c ';
            strQuery += ' , PAYMENT_REQUEST_DATE__c ';
            strQuery += ' , SALE_DC_TYPE__c ';
          
            strQuery += ' , Order_CUST_Id__r.Name';
            strQuery += ' , Order_CUST_Id__r.Phone';

            //////23.04.13 contact 추가
            strQuery += ' , Order_CUST_Id__r.Email';
            //////////
            strQuery += ' , CreatedBy.Name ';
            strQuery += ' , CreatedBy.EmployeeNumber__c ';
            strQuery += ' , CreatedById__r.Name ';
            strQuery += ' , CreatedById__r.EmployeeNumber__c ';
            strQuery += ' , Case.Description ';
            strQuery += ' , Case.Subject ';
            strQuery += ' , Case.CaseNumber ';
            strQuery += ' , CNSL_Department_Id__r.Name';
            //2023.09.12 seung yoon heo 결제완료일시 추가
            strQuery += ' , PAYMENT_COMPLETED_DTM__c';
            //23.09.22 PHJ
            strQuery += ' , Case.TRANSFER_REASON2__c';
            //24 01 10 hyungho.chun 가상계좌 채번 상태 확인용
            strQuery += ' , VBANK_NUM__c';

            // // 23.02.27 추가
            // strQuery += ', (SELECT SUB_Order_Number__c';
            // strQuery += ', Consumables_Order_Status__c';
            // strQuery += ', Consumables_Order_Class_Code__c';
            // strQuery += ', FFMT_Order_Transfer_YN__c';
            // strQuery += ', Appointment_Status__c';

            // strQuery += ', fm_Num_Consumable_status__c ';
            // strQuery += ' FROM ProductRequestLineItems ';
            // strQuery += ' WHERE ParentId IN ' + setToString(productRequestIdSet) + ')';

            // FROM
            strQuery += ' FROM ' + 'ProductRequest';

            // WHERE
            // strQuery += ' WHERE Id IN :productRequestIdSet';
            whereClause += ' WHERE Id IN :productRequestIdSet';

            whereClause += ' AND Request_Type_Code__c = NULL';

            // 소모품 주문 품목의 상태, 파트넘버 조회한 대상 / AND 조건으로 추가
            // if (!productRequestIdSet.isEmpty()) {
            //     // strQuery += ' AND Id IN :productRequestIdSet';
            //     whereClause += ' AND Id IN :productRequestIdSet';
            //     // System.debug('이 조건이 타는지 확인해야합니다. 안탈 확률 99.99%');
            // }

            strQuery += whereClause;

            // ORDER BY
            strQuery += ' ORDER BY Order_Date__c DESC ';

            // Pagination
            // strQuery += ' LIMIT ' + recordLimit + ' OFFSET ' + (pageOffset * recordLimit);

            System.debug('strQuery >>> ' + strQuery);

            List<ProductRequest> productRequests = Database.query(strQuery);
            System.debug('속도측정 -------------------------------------------------- 쿼리 (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            //23.09.07 PHJ js에서 count 적용
            // if (isSearchBtnClick) {
            //     recordCount = Database.countQuery('SELECT COUNT() FROM ProductRequest' + whereClause);
            //     returnMap.put('totalRecord', recordCount);
            // } else {
            //     returnMap.put('totalRecord', null);
            // }
            System.debug('속도측정 -------------------------------------------------- Mapping Start (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
            for (ProductRequest productRequest : productRequests) {
                consumableOrderTable = new ConsumableOrderTable();
                consumableOrderTable.Id = productRequest.Id;
                //consumableOrderTable.OrderSEQ = ++orderSeq;
                // switch on productRequest.Order_CHNL_TYPE_Code__c {
                //     when 'B' {
                //         consumableOrderTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_OBS_LABEL;
                //     }
                //     when 'S' {
                //         consumableOrderTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_THINQ_LABEL;
                //     }
                //     when 'V' {
                //         consumableOrderTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_CIC_LABEL;
                //     }
                //     when 'BestShop' {
                //         consumableOrderTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_BESTSHOP_LABEL;
                //     }
                //     //2023.08.16 seung yoon heo Order_CHNL_TYPE_Code__c == 'Y'  >> 소모품샵  추가
                //     when 'Y' {
                //         consumableOrderTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_CICSHOP_LABEL;
                //     }
                //     when else {
                //         consumableOrderTable.OrderChannel = '미지정';
                //     }
                // }

                consumableOrderTable.OrderChannel = productRequest.Order_CHNL_TYPE_Code__c;
                consumableOrderTable.OrderNumber = productRequest.Order_Number__c;
//                consumableOrderTable.OrderDate = productRequest.CreatedDate;
                consumableOrderTable.OrderDate = productRequest.Order_Date__c;
                System.debug('productRequest.Order_Date__c : ' + productRequest.Order_Date__c);


                consumableOrderTable.OrderType = productRequest.Consumables_Order_Class_Code__c;
                consumableOrderTable.OrderBusinessType = productRequest.Consumables_Business_Type_Code__c;
                // switch on productRequest.Consumables_Order_Class_Code__c {
                //     when 'General' {
                //         consumableOrderTable.OrderType = '일반주문';
                //     }
                //     when 'Sold Out' {
                //         consumableOrderTable.OrderType = '품절주문';
                //     }
                // }

                // switch on productRequest.Consumables_Business_Type_Code__c {
                //     when 'Order' {
                //         consumableOrderTable.OrderBusinessType = '주문';
                //     }
                //     when 'ExchangeOrder' {
                //         consumableOrderTable.OrderBusinessType = '교환주문';
                //     }
                // }

                // 23.02.27 추가
                /**
                 * 마스킹 처리 조건
                 * 1. 조회용 필드 :  주문상태=(003:결제취소,004:주문취소,005:자동주문취소완료,070:배송완료,110:반품반려,090:반품요청철회,120:반품확정)
                 * 2. & 최종수정일시 < 당일 - 14일
                 * 3. & 레코드타입=소모품
                 * */
                

                Decimal Ex_consumable_status_Num_SUM = statusNumMap.get(productRequest.Id) != null ? statusNumMap.get(productRequest.Id) : 0;

                System.debug('productRequest.fm_IsMaskingTarget__c ::: ' + productRequest.fm_IsMaskingTarget__c);
                System.debug('Ex_consumable_status_Num_SUM ::: ' + Ex_consumable_status_Num_SUM);
                System.debug('productRequest.ProductRequestLineItems.size() ::: ' + productRequest.ProductRequestLineItems.size() );


                // if (productRequest.fm_IsMaskingTarget__c && Ex_consumable_status_Num_SUM > 0 && productRequest.ProductRequestLineItems.size() == Ex_consumable_status_Num_SUM) {
                    consumableOrderTable.isMasking = productRequest.fm_IsMaskingTarget__c;
                if (productRequest.fm_IsMaskingTarget__c && Ex_consumable_status_Num_SUM > 0 && prliSizeMap.get(productRequest.Id) == Ex_consumable_status_Num_SUM) {
                    System.debug('@@@@@@@@@@@');
                    consumableOrderTable.CONSIGNEE_Name = productRequest.fm_ENC_CONSIGNEE_Name__c;
                    consumableOrderTable.CONSIGNEE_Phone = productRequest.fm_ENC_CONSIGNEE_TPNO_1__c != null ? productRequest.fm_ENC_CONSIGNEE_TPNO_1__c : productRequest.fm_ENC_CONSIGNEE_TPNO_2__c;
                    consumableOrderTable.CustomerName = productRequest.fm_ENC_Order_CUST_Name__c;
                    consumableOrderTable.ENC_CustomerPhone = productRequest.fm_ENC_Order_CUST_TPNO_1__c;

                } else {
                    System.debug('##############');
                    consumableOrderTable.CONSIGNEE_Name = productRequest.CONSIGNEE_Name__c;
                    consumableOrderTable.CONSIGNEE_Phone = productRequest.CONSIGNEE_TPNO_1__c != null ? productRequest.CONSIGNEE_TPNO_1__c : productRequest.CONSIGNEE_TPNO_2__c;
                    consumableOrderTable.CustomerName = productRequest.Order_CUST_Name__c;
                    consumableOrderTable.ENC_CustomerPhone = productRequest.Order_CUST_TPNO_1__c;

                    System.debug('###########');
                    System.debug(consumableOrderTable.CONSIGNEE_Name);
                    System.debug(consumableOrderTable.CONSIGNEE_Phone);
                    System.debug('###########');

                }

                consumableOrderTable.CustomerPhone = productRequest.Order_CUST_TPNO_1__c;

                consumableOrderTable.PaymentYN = 'N';

                consumableOrderTable.PaymentType = productRequest.PAYMENT_TYPE__c;

                //23.05.02 결제방식은 소모품결제방식(fm_PAYMENT_TYPE__c)으로 대체. 결제 여부도 PAYMENT_YN__c 필드로 대체
                if (productRequest.PAYMENT_YN__c) {
                    consumableOrderTable.PaymentYN = 'Y';
                } else {
                    consumableOrderTable.PaymentYN = 'N';
                }
                consumableOrderTable.PaymentMethod = productRequest.fm_PAYMENT_TYPE__c;

                //23 12 01 hyungho.chun PAYMENT_Method_Code__c 값 추가
                consumableOrderTable.PaymentMethodCode = productRequest.PAYMENT_Method_Code__c;

                if (productRequest.PAYMENT_Method_Code__c == 'DISCOUNT') {
                    consumableOrderTable.PaymentMethod = 'VIP할인';
                }

                consumableOrderTable.SaleAmount = productRequest.SALE_Amount__c == null ? 0 : productRequest.SALE_Amount__c;
                consumableOrderTable.DiscountAmount = productRequest.Discount_Amount__c == null ? 0 : productRequest.Discount_Amount__c;
                consumableOrderTable.PaymentAmount = productRequest.PAYMENT_Amount__c == null ? 0 : productRequest.PAYMENT_Amount__c;
                //MCS 는 'M' , ThinQ&OBS 는 'T'
                consumableOrderTable.MCS = productRequest.fm_funnel__c;
                //consumableOrderTable.ConsultantDIV = productRequest.Department_Code__c;
                //consumableOrderTable.ConsultantDIV = productRequest.CNSL_Department_Code__c;
                consumableOrderTable.ConsultantDIV = productRequest.CNSL_Department_Id__r.Name;

                //gw.lee 23.09.30
                //xplenty이름 변경
                //gw.lee 23.11.02
                //Mig대상 변경으로 CreatedById__c 커스텀 필드 보게끔 조치
                //consumableOrderTable.ConsultantEmployeeNumber = productRequest.CreatedBy.EmployeeNumber__c;
                

                //2023.08.01 seung yoon heo bestShop일 경우에도 상담사명 추가 안되게 수정
                //2023.11.02 gw.lee 상담사번도 포함
                if (productRequest.Order_CHNL_TYPE_Code__c == 'LGE.COM' || productRequest.Order_CHNL_TYPE_Code__c == '베스트샵') {
                    consumableOrderTable.ConsultantUser = '';
                    consumableOrderTable.ConsultantEmployeeNumber = '';
                } else {
                    consumableOrderTable.ConsultantUser = productRequest.CreatedById__r.Name;
                    consumableOrderTable.ConsultantEmployeeNumber = productRequest.CreatedById__r.EmployeeNumber__c;
                }
                // consumableOrderTable.ConsultantUser =  productRequest.Order_CHNL_TYPE_Code__c != 'B' ? productRequest.CreatedBy.Name : '';

                //23.09.22 PHJ
                // consumableOrderTable.CaseDescription = productRequest.Case.Description;
                consumableOrderTable.CaseDescription = productRequest.Case.TRANSFER_REASON2__c;

                consumableOrderTable.CaseNumber = productRequest.CaseId != Null ? productRequest.Case.Subject + ' ' + productRequest.Case.CaseNumber : '';
                consumableOrderTable.CaseURL = productRequest.fmURL_CaseNumber__c;

                consumableOrderTable.CaseId = productRequest.CaseId;
                consumableOrderTable.MOID = productRequest.MOID__c;
                consumableOrderTable.TID = productRequest.TID__c;
                consumableOrderTable.APPR_DT = productRequest.APPR_DT__c;

                ///23.04.13 contact 추가
                consumableOrderTable.contactId = productRequest.Order_CUST_Id__c;
                consumableOrderTable.contactName = productRequest.Order_CUST_Id__r.Name;
                consumableOrderTable.contactEmail = productRequest.Order_CUST_Id__r.Email;


                consumableOrderTable.PaymentRequestDT = productRequest.PAYMENT_REQUEST_DATE__c;
                
                //2023.09.12 seung yoon heo 결제완료일시 추가
                consumableOrderTable.PaymentCompletedDT = productRequest.PAYMENT_COMPLETED_DTM__c;
     
                if (productRequest.SALE_DC_TYPE__c != null && productRequest.SALE_DC_TYPE__c == 'E') {
                    consumableOrderTable.discountType = '임직원';
                } else if (productRequest.SALE_DC_TYPE__c != null && productRequest.SALE_DC_TYPE__c == 'V') {
                    consumableOrderTable.discountType = 'VIP할인';
                } else if (productRequest.SALE_DC_TYPE__c != null && productRequest.SALE_DC_TYPE__c == 'P') {
                    consumableOrderTable.discountType = '프로모션';
                }
                System.debug('소모품 주문내역 출력 확인 ');
                System.debug('productRequest.SALE_DC_TYPE__c  : ' + productRequest.SALE_DC_TYPE__c);

                consumableOrderTable.AppointmentStatus = consumableAppointmentStatusMap.get(productRequest.Id) != null ? consumableAppointmentStatusMap.get(productRequest.Id) : '';
                consumableOrderTable.OrderStatus = consumableOrderStatusMap.get(productRequest.Id) != null ? consumableOrderStatusMap.get(productRequest.Id) : '';

                //24 01 10 hyungho.chun
                consumableOrderTable.VbankNum = productRequest.VBANK_NUM__c;
                
                consumableOrderTables.add(consumableOrderTable);
            }
        }

        // 2023.09.20 seung yoon heo sort() 주석
        // consumableOrderTables.sort();

        for (ConsumableOrderTable cot : consumableOrderTables) {
            cot.OrderSEQ = ++orderSeq;
        }

        returnMap.put('STATUS' , 'S');
        returnMap.put('productRequests', consumableOrderTables);
        System.debug('속도측정 -------------------------------------------------- Mapping End (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

        


        
        }catch(Exception e){
            returnMap.put('STATUS' , 'E');
            returnMap.put('message' , 'LineNumber:' + e.getLineNumber() + ' :: ' + e.getMessage());
        }
        return returnMap;
    }

    /**
  * @description 소모품 주문 관리 조회 / 관련 주문 내역(ProductRequestLineItem + ReturnOrderLineItem) 조회
  *
  * @author 23.01.04 / I2MAX.SEOKHOLEE
  * @return
  */
    @AuraEnabled
    public static Map<String, Object> doGetOrderLineItemData(String recordId, Boolean isDownload) {
        Map<String, Object> returnMap = new Map<String, Object>();

        String sobjectType = String.valueOf(Id.valueOf(recordId).getSobjectType());
        String orderNumber = '';


        if (sobjectType.equals('ProductRequest')) {
            List<ProductRequest> productRequests = [
                    SELECT Id, Order_Number__c
                    FROM ProductRequest
                    WHERE Id = :recordId
                    LIMIT 1
            ];
            orderNumber = productRequests[0].Order_Number__c;

        } else if(sobjectType.equals('ReturnOrder')){
            List<ReturnOrder> returnOrders = [
                    SELECT Id, Order_Number__c
                    FROM ReturnOrder
                    WHERE Id = :recordId
                    LIMIT 1
            ];
            orderNumber = returnOrders[0].Order_Number__c;

        }else{
            //2023.09.16 seung yoon heo 주문관리 화면에서 ProductRequest, ReturnOrder를 기준으로 조회하는것이 아니면 반환
            return returnMap;
        }



        Map<String, Decimal> originItemExpectedReturnQtyMap = new Map<String, Decimal>();
        List<ProductRequestLineItem> productRequestLineItems = new List<ProductRequestLineItem>();
        try {

            if (sobjectType.equals('ProductRequest')) {
                String strQuery = '';
                // SELECT
                // 2023.08.17 seung yoon heo field 추출
                // strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
                strQuery += ' SELECT Id ';
                strQuery += ' , Consumables_Order_Status__c ';
                strQuery += ' , ParentId ';
                strQuery += ' , FFMT_Order_Transfer_YN__c ';
                strQuery += ' , Consumables_Business_Type_Code__c ';
                strQuery += ' , SUB_Order_Number__c ';
                strQuery += ' , Order_CHNL_TYPE_Code__c ';
                strQuery += ' , Order_Number__c ';
                strQuery += ' , Consumables_Order_DETAIL__c ';
                strQuery += ' , BASIS_Parts_Number__c ';
                strQuery += ' , PART_NO__c ';
                strQuery += ' , RSRV_Number__c ';
                strQuery += ' , Appointment_Status__c ';
                strQuery += ' , ENDP_Code__c ';
                strQuery += ' , fm_Consumables_PART_DESC_KOR__c ';
                strQuery += ' , SHIPPED_Department_Code__c ';
                strQuery += ' , UnitPrice__c ';
                strQuery += ' , CONSUMER_Price__c ';
                strQuery += ' , SALE_Quantity__c ';
                strQuery += ' , SALE_Amount__c ';
                strQuery += ' , PAYMENT_YN__c ';
                strQuery += ' , CARD_PAYMENT_Amount__c ';
                strQuery += ' , CASH_PAYMENT_Amount__c ';
                strQuery += ' , POINT_Amount__c ';
                strQuery += ' , VIRTUAL_ACCT_PAYMENT_Amount__c ';
                strQuery += ' , PAYMENT_Amount__c ';
                strQuery += ' , POINT_TRX_ID__c ';
                strQuery += ' , TID__c ';
                strQuery += ' , MOID__c ';
                strQuery += ' , Last_Discount_Amount__c ';
                strQuery += ' , SALE_Discount_Type_Code__c ';
                strQuery += ' , QuantityRequested ';
                strQuery += ' , CANCEL_Quantity__c ';
                strQuery += ' , Return_Order_Quantity__c ';
                strQuery += ' , Exchange_Quantity__c ';
                strQuery += ' , SALE_Number__c ';
                strQuery += ' , FFMT_Order_Number__c ';
                strQuery += ' , FFMT_Transfer_DTM__c ';
                strQuery += ' , DELIVERY_STATUS_CODE__c ';
                strQuery += ' , SHIP_DTM__c ';
                strQuery += ' , DELIVERY_CODE__c ';
                strQuery += ' , PARCEL_FEE_Amount__c ';
                strQuery += ' , CANCEL_Department_Code__c ';
                strQuery += ' , CANCEL_Request_DTM__c ';
                strQuery += ' , CANCEL_Reason__c ';
                strQuery += ' , Exchange_Request_Department_Code__c ';
                strQuery += ' , Exchange_Request_DTM__c ';
                strQuery += ' , CANCEL_User__c ';
                strQuery += ' , Delivery_DTM__c ';
                strQuery += ' , INVOICE_Number__c ';
      
                strQuery += ', Order_CUST_Id__r.Phone ';
                strQuery += ', Order_CUST_Id__r.Name ';
                strQuery += ', CreatedBy.Name ';
                strQuery += ', CreatedBy.EmployeeNumber__c ';
                strQuery += ', CreatedBy.DEPT_CODE__c ';
                strQuery += ', Exchange_Requester_Id__r.Name ' ;
                strQuery += ', Parent.CreatedDate ';
                strQuery += ', Parent.CONSIGNEE_TPNO_1__c ';
                strQuery += ', Parent.CONSIGNEE_Name__c ';
                strQuery += ', Parent.PAYMENT_Method_Code__c ';
                strQuery += ', Parent.PAYMENT_TYPE__c ';
                strQuery += ', Parent.PAYMENT_YN__c ';
                strQuery += ', Parent.PAYMENT_REQUEST_DATE__c ';
                //2023.09.12 seung yoon heo 결제완료일시 추가
                strQuery += ', Parent.PAYMENT_COMPLETED_DTM__c ';
                strQuery += ', Parent.Consumables_Order_Class_Code__c '; //주문형태
                //23 07 25 hyungho.chun 주문취소디테일에 결제방식 필드 데이터 추가
                strQuery += ', Parent.fm_PAYMENT_TYPE__c ';

                //바인딩 체크 컬럼 추가
                strQuery += ', Parent.Order_Date__c ';
                strQuery += ', Exchange_Requester_Id__r.EmployeeNumber__c ';
                strQuery += ', Parent.Case.Subject  ';
                strQuery += ', Parent.Case.CaseNumber  ';
                strQuery += ', Parent.fmURL_CaseNumber__c  ';
                strQuery += ', Parent.SALE_DC_TYPE__c ';
                strQuery += ', CANCEL_UserId__r.EmployeeNumber__c';


                // Part
                strQuery += ', Product2.PART_DESC_KOR__c ';
                strQuery += ', Product2.Name ';
                strQuery += ', Product2.CUST_PRICE__c ';
                strQuery += ', Product2.MODEL_CODE__c ';
                strQuery += ', Product2.PART_DESC__c ';

                //23.05.02 PRLI에서 ROLI의 반품예정수량을 구하기 위해 추가
                strQuery += ', (SELECT Expected_Return_Quantity__c, Consumables_Business_Type_Code__c FROM ReturnOrderLineItems ) ';


                // FROM
                strQuery += ' FROM ' + 'ProductRequestLineItem';
                // WHERE
                if (isDownload != null && isDownload == true) {
                    strQuery += ' WHERE ParentId = :recordId';
                } else {
                    //strQuery += ' WHERE ParentId =  \'' + recordId + '\'';
                    strQuery += ' WHERE (Order_Number__c=\'' + orderNumber + '\' OR BASIS_Order_Item_Id__r.Order_Number__c =\'' + orderNumber + '\')';
                }
                //strQuery += ' AND Consumables_Order_Class_Code__c != \'PO\'';
                strQuery += ' AND RecordType.DeveloperName != \'RESV_SALE\'';
                strQuery += ' AND RecordType.DeveloperName != \'SALE\'';
                strQuery += ' ORDER BY CreatedDate ASC ';

                productRequestLineItems = Database.query(strQuery);
            }


            /**
             * 23.02.20 / Return Order Line Item 추가
             * I2MAX.SEOKHOLEE
             */
            String returnOrderQuery;
            // 2023.08.17 seung yoon heo field 추출
            // returnOrderQuery = ' SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrderLineItem');
            returnOrderQuery = ' SELECT Id ';
            returnOrderQuery += ', Consumables_Order_Status__c ';
            returnOrderQuery += ', ReturnOrderId ';
            returnOrderQuery += ', FFMT_Order_Transfer_YN__c ';
            returnOrderQuery += ', Consumables_Business_Type_Code__c ';
            returnOrderQuery += ', SUB_Order_Number__c ';
            returnOrderQuery += ', Order_CHNL_TYPE_Code__c ';
            returnOrderQuery += ', Return_Order_Request_DTM__c ';
            returnOrderQuery += ', Order_Number__c ';
            returnOrderQuery += ', Parts_Number__c ';
            returnOrderQuery += ', ENDP_Code__c ';
            returnOrderQuery += ', RETURN_SALE_Amount__c ';
            returnOrderQuery += ', RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c ';
            returnOrderQuery += ', RETURN_CARD_PAYMENT_Amount__c ';
            returnOrderQuery += ', RETURN_POINT_Amount__c ';
            returnOrderQuery += ', RETURN_PAYMENT_Amount__c ';
            returnOrderQuery += ', Return_Last_Discount_Amount__c ';
            returnOrderQuery += ', QuantityReturned ';
            returnOrderQuery += ', Actual_Return_Quantity__c ';
            returnOrderQuery += ', ProductRequestLineItemId ';
            returnOrderQuery += ', Expected_Return_Quantity__c ';
            returnOrderQuery += ', FFMT_Order_Number__c ';
            returnOrderQuery += ', FFMT_Transfer_DTM__c ';
            returnOrderQuery += ', Return_Order_CONFIRM_DTM__c ';
            returnOrderQuery += ', Return_Order_Department_Code__c ';
            returnOrderQuery += ', Return_Requester_Reason__c ';
            returnOrderQuery += ', INVOICE_Number__c '; 
            
            returnOrderQuery += ', CreatedBy.Name ';
            returnOrderQuery += ', CreatedBy.DEPT_CODE__c ';
            returnOrderQuery += ', CreatedBy.EmployeeNumber__c ';

            returnOrderQuery += ', ReturnOrder.CreatedDate ';
            returnOrderQuery += ', ReturnOrder.Return_Order_Request_DTM__c ';
            //returnOrderQuery += ', ProductRequestLineItem.Consumables_Order_Status_Code__c ';
            returnOrderQuery += ', ProductRequestLineItem.Consumables_Order_Status__c ';

            returnOrderQuery += ', ProductRequest__r.CreatedDate ';
            returnOrderQuery += ', ProductRequestLineItem.Order_CUST_Id__r.Name ';
            returnOrderQuery += ', ProductRequestLineItem.Order_CUST_Id__r.MobilePhone ';
            returnOrderQuery += ', ProductRequestLineItem.SALE_Number__c ';
            returnOrderQuery += ', ProductRequestLineItem.SALE_Amount__c ';
            returnOrderQuery += ', ProductRequestLineItem.Last_Discount_Amount__c ';
            returnOrderQuery += ', ProductRequestLineItem.PAYMENT_Amount__c ';
            returnOrderQuery += ', ProductRequestLineItem.CARD_PAYMENT_Amount__c ';
            returnOrderQuery += ', ProductRequestLineItem.CASH_PAYMENT_Amount__c ';
            returnOrderQuery += ', ProductRequestLineItem.POINT_Amount__c ';
            returnOrderQuery += ', ProductRequestLineItem.fm_MODEL_Code__c ';
            returnOrderQuery += ', ProductRequestLineItem.CANCEL_Quantity__c ';
            returnOrderQuery += ', ProductRequestLineItem.Exchange_Quantity__c ';
            returnOrderQuery += ', ProductRequestLineItem.QuantityRequested ';
            returnOrderQuery += ', ProductRequestLineItem.INVOICE_Number__c ';
            returnOrderQuery += ', ProductRequestLineItem.fm_PART_NO__c ';
            returnOrderQuery += ', ProductRequestLineItem.ENDP_Code__c ';
            returnOrderQuery += ', ProductRequestLineItem.Product2.PART_DESC_KOR__c ';
            returnOrderQuery += ', ProductRequestLineItem.Product2.Name ';
            returnOrderQuery += ', ProductRequestLineItem.Product2.MODEL_CODE__c ';
            returnOrderQuery += ', ProductRequestLineItem.Product2.CUST_PRICE__c ';
            returnOrderQuery += ', ProductRequestLineItem.SALE_Quantity__c ';
            returnOrderQuery += ', ProductRequestLineItem.PAYMENT_YN__c ';
            returnOrderQuery += ', ProductRequestLineItem.Return_Order_Quantity__c ';
            returnOrderQuery += ', ProductRequestLineItem.Parent.Case.Subject ';
            //바인딩 추가 컬럼
            returnOrderQuery += ', ProductRequestLineItem.fm_ProductName__c ';
            returnOrderQuery += ', ProductRequestLineItem.Product2.PART_DESC__c ';
            returnOrderQuery += ', ProductRequestLineItem.UnitPrice__c ';
            returnOrderQuery += ', productRequestLineItem.CONSUMER_Price__c ';
            returnOrderQuery += ', Return_Requester_Id_c__r.EmployeeNumber__c';
            returnOrderQuery += ', Return_Requester_Id_c__r.Name';

            returnOrderQuery += ', ProductRequestLineItem.fm_Consumables_PART_DESC_KOR__c';


            returnOrderQuery += ', ProductRequestLineItem.CreatedDate ';

            // Part
            returnOrderQuery += ', Product2.PART_DESC_KOR__c ';
            returnOrderQuery += ', Product2.PART_DESC__c ';
            returnOrderQuery += ', Product2.MODEL_CODE__c ';
            returnOrderQuery += ', Product2.Name ';
            returnOrderQuery += ', Product2.CUST_PRICE__c ';
            // FROM
            returnOrderQuery += ' FROM ' + 'ReturnOrderLineItem';
            // WHERE
            if (sobjectType.equals('ReturnOrder')) {
                returnOrderQuery += ' WHERE ReturnOrderId =  \'' + recordId + '\'';
            } else {
                returnOrderQuery += ' WHERE ProductRequestLineItem.ParentId =  \'' + recordId + '\'';
            }
            // 소모품 주문 여부
            returnOrderQuery += ' AND Consumables_Order_YN__c = TRUE ';
            // 소모품 요청 구분
            returnOrderQuery += ' AND Consumables_Business_Type_Code__c IN (\'Return\', \'ExchangeReturn\')';

            // 반품요청철회 X
            returnOrderQuery += ' AND Consumables_Order_Status__c != ' + '\'090\'';
            // PO가 아닌 대상
            returnOrderQuery += ' AND Consumables_Order_Class_Code__c != \'PO\'';
            returnOrderQuery += ' ORDER BY CreatedDate ASC';
            List<ReturnOrderLineItem> returnOrderLineItems = Database.query(returnOrderQuery);

            List<ConsumableOrderLineItemTable> orderLineItemTables = new List<EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable>();
            ConsumableOrderLineItemTable consumableOrderLineItemTable;

            Boolean isPayment = false;
            Boolean isSale = false;
            Boolean isCJSend = false;

            //2023.12.07 seung yoon heo 출고부서 한글 제거
            // Set<String> deptCodeSet = new Set<String>();
            // 송장번호 DeliveryInfo 조회용 Id 세팅
            List<String> prliIdList = new List<String>();
            for (ProductRequestLineItem prli : productRequestLineItems) {
                if (prli.Consumables_Order_Status__c != null && (prli.Consumables_Order_Status__c.equals('030') || prli.Consumables_Order_Status__c.equals('070'))) {
                    prliIdList.add(prli.Id);
                }
                // deptCodeSet.add(prli.SHIPPED_Department_Code__c);
            }

            //2023.12.07 seung yoon heo 출고부서 조회 제거
            // List<SM_DEPT__c> smDeptList = [SELECT Name, DEPT_CODE__c FROM SM_DEPT__c WHERE DEPT_CODE__c IN: deptCodeSet];

            // Map<String, String> shipmentNameMap = new Map<String, String>();
            // for (SM_DEPT__c dept : smDeptList) {
            //     shipmentNameMap.put(dept.DEPT_CODE__c, dept.Name);
            // }

            //송장번호 조회
            // List<Map<String, String>> dMap_list = new List<Map<String, String>>();
            // if (!prliIdList.isEmpty()) {
            //     dMap_list = getDeliveryNoList(prliIdList, null);
            // }
            
            

            Integer orderSeq = 0;
            for (ProductRequestLineItem productRequestLineItem : productRequestLineItems) {
                consumableOrderLineItemTable = new ConsumableOrderLineItemTable();
                consumableOrderLineItemTable.Id = productRequestLineItem.Id;
                consumableOrderLineItemTable.ParentId = productRequestLineItem.ParentId;

                //isPayment = productRequestLineItem.Consumables_Order_Status_Code__c != '결제취소' || productRequestLineItem.Consumables_Order_Status_Code__c != '주문취소' ? true : false;
                isPayment = productRequestLineItem.Consumables_Order_Status__c != EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_003 || productRequestLineItem.Consumables_Order_Status__c != EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_004 ? true : false;
                //isSale = productRequestLineItem.Consumables_Order_Status_Code__c == '배송중' || productRequestLineItem.Consumables_Order_Status_Code__c == '배송완료' ? true : false;
                isSale = productRequestLineItem.Consumables_Order_Status__c == EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_030 || productRequestLineItem.Consumables_Order_Status__c == EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_070 ? true : false;

                isCJSend = productRequestLineItem.FFMT_Order_Transfer_YN__c;

                //23.09.15 gw.lee
                //송장번호 변경
                consumableOrderLineItemTable.TrackingNumber = isCJSend ? productRequestLineItem.INVOICE_Number__c : null;

                // 주문 구분
                switch on productRequestLineItem.Consumables_Business_Type_Code__c {
                    when 'Order' {
                        consumableOrderLineItemTable.ConsumablesBusinessTypeCode = '주문';
                    }
                    when 'Exchange' {
                        consumableOrderLineItemTable.ConsumablesBusinessTypeCode = '교환';
                    }
                    when 'Cancel' {
                        consumableOrderLineItemTable.ConsumablesBusinessTypeCode = '취소';
                    }
                    when 'Return' {
                        consumableOrderLineItemTable.ConsumablesBusinessTypeCode = '반품';
                    }
                    when 'ExchangeOrder' {
                        consumableOrderLineItemTable.ConsumablesBusinessTypeCode = '교환주문';
                    }
                    when 'ExchangeReturn' {
                        consumableOrderLineItemTable.ConsumablesBusinessTypeCode = '교환반품';
                    }
                    when else {
                        consumableOrderLineItemTable.ConsumablesBusinessTypeCode = ' ';
                    }
                }

                switch on ProductRequestlineItem.Parent.Consumables_Order_Class_Code__c {
                    when 'General' {
                        consumableOrderLineItemTable.OrderType = '일반주문';
                    }
                    when 'Sold Out' {
                        consumableOrderLineItemTable.OrderType = '품절주문';
                    }
                }

                // 주문 순번
                //consumableOrderLineItemTable.OrderSEQ = ++orderSeq;
                // Sub 번호
                String sn = productRequestLineItem.SUB_Order_Number__c;
                if (sn != null && sn.contains('-') && sn.split('-').size() > 2) {
                    Integer targetIndex = sn.split('-').size();
                    if (sn.split('-')[targetIndex - 1].equals('01')) {
                        consumableOrderLineItemTable.SubNumber = sn.split('-')[targetIndex - 2] + '-' + sn.split('-')[targetIndex - 1];
                    } else {
                        consumableOrderLineItemTable.SubNumber = 'ㄴ' + sn.split('-')[targetIndex - 2] + '-' + sn.split('-')[targetIndex - 1];
                    }
                } else {
                    consumableOrderLineItemTable.SubNumber = sn;
                }

                // 주문 채널
                switch on productRequestLineItem.Order_CHNL_TYPE_Code__c {
                    when 'B' {
                        consumableOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_OBS_LABEL;
                    }
                    when 'S' {
                        consumableOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_THINQ_LABEL;
                    }
                    when 'V' {
                        consumableOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_CIC_LABEL;
                    }
                    when 'BestShop' {
                        consumableOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_BESTSHOP_LABEL;
                    }
                       //2023.08.16 seung yoon heo Order_CHNL_TYPE_Code__c == 'Y'  >> 소모품샵  추가
                    when 'Y' {
                        consumableOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_CICSHOP_LABEL;
                    }
                    when else {
                        consumableOrderLineItemTable.OrderChannel = '미지정';
                    }
                }
                // 주문 일시
                consumableOrderLineItemTable.OrderDate = productRequestLineItem.Parent.Order_Date__c;
                // 주문 번호
                consumableOrderLineItemTable.OrderNumber = productRequestLineItem.Order_Number__c;
                // 주문 상태
                //consumableOrderLineItemTable.OrderStatus = productRequestLineItem.PAYMENT_YN__c ? productRequestL
                // ineItem.Consumables_Order_Status_Code__c : '품절예약완료';
                consumableOrderLineItemTable.OrderStatus = EX_ConsumableUtil.returnStatusKORMap(productRequestLineItem.Consumables_Order_Status__c);

                // 주문 상세 상태
                consumableOrderLineItemTable.OrderStatusDetail = EX_ConsumableUtil.returnStatusKORMap(productRequestLineItem.Consumables_Order_DETAIL__c);
                //송장번호
                // List<Map<String, String>> results = dMap_list;
                // if (!results.isEmpty()) {
                //     Integer matchCnt = 0;
                //     String tNum = '';
                //     for (Map<String, String> mp : results) {
                //         if (mp.get(String.valueOf(productRequestLineItem.id)) != null && !String.valueOf(mp.get(String.valueOf(productRequestLineItem.id))).equals('')) {
                //             matchCnt++;
                //             tNum = String.valueOf(mp.get(String.valueOf(productRequestLineItem.id)));
                //         }
                //     }
                //     if (matchCnt > 1) {
                //         consumableOrderLineItemTable.TrackingNumber = isCJSend ? tNum + '외 ' + (matchCnt - 1) + '건' : null;
                //     } else {
                //         consumableOrderLineItemTable.TrackingNumber = isCJSend ? tNum : null;
                //     }
                // }


                // 요청 Part No
                consumableOrderLineItemTable.RequestedPartNo = productRequestLineItem.BASIS_Parts_Number__c;
                // 입고 Part No
                consumableOrderLineItemTable.ReceivedPartNo = productRequestLineItem.PART_NO__c;
                // 대치
                // productRequestLineItem.BASIS_Parts__c 로 처리 검토
                // 요청PartNo 와 입고 PartNo가 같으면 '원', 다르면 '대치'
                if (productRequestLineItem.BASIS_Parts_Number__c != null && productRequestLineItem.PART_NO__c != null) {
                    if (productRequestLineItem.BASIS_Parts_Number__c == productRequestLineItem.PART_NO__c) {
                        consumableOrderLineItemTable.SubstituteYN = '원';
                    } else {
                        consumableOrderLineItemTable.SubstituteYN = '대치';
                    }
                } else {
                    consumableOrderLineItemTable.SubstituteYN = '';
                }

                // 부분 입고
                consumableOrderLineItemTable.PartiallyReceived = '';

                //부품예약번호가 없을때 약속상태를 자동으로 '입고완료' 표시 하고 취소상태의 품목은 취소로 표시한다
                if (productRequestLineItem.RSRV_Number__c != null && !productRequestLineItem.RSRV_Number__c.equals('')) {
                    consumableOrderLineItemTable.AppointmentStatus = productRequestLineItem.Appointment_Status__c;
                } else {
                    //gw.lee 23.08.26
                    //이미 입고완료된 건인 경우, 취소 상태 표시 X
                    if ((productRequestLineItem.Consumables_Order_Status__c == EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_003 ||
                            productRequestLineItem.Consumables_Order_Status__c == EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_004) && productRequestLineItem.Appointment_Status__c != '입고완료') {
                        // 2024.02.29 seung yoon heo 취소 => 약속취소로 변경
                        // consumableOrderLineItemTable.AppointmentStatus = '취소';
                        consumableOrderLineItemTable.AppointmentStatus = '약속취소';
                    } else {
                        consumableOrderLineItemTable.AppointmentStatus = productRequestLineItem.Appointment_Status__c;
                    }

                }

                if (productRequestLineItem.Appointment_Status__c != null && productRequestLineItem.Appointment_Status__c == 'PO Canceld') {
                    // 2024.02.29 seung yoon heo 취소 => 약속취소로 변경
                    // consumableOrderLineItemTable.AppointmentStatus = '취소';
                    consumableOrderLineItemTable.AppointmentStatus = '약속취소';
                }
                // 사업부
                consumableOrderLineItemTable.DIV = productRequestLineItem.ENDP_Code__c;

                consumableOrderLineItemTable.PartNameKOR = productRequestLineItem.fm_Consumables_PART_DESC_KOR__c;
                // 품명
                consumableOrderLineItemTable.PartName = productRequestLineItem.Product2.PART_DESC__c;

                // 모델
                consumableOrderLineItemTable.Model = productRequestLineItem.Product2.MODEL_CODE__c;

                // 출고부서
                // consumableOrderLineItemTable.ShippedDepartment = shipmentNameMap.get(productRequestLineItem.SHIPPED_Department_Code__c);
                consumableOrderLineItemTable.ShippedDepartment = productRequestLineItem.SHIPPED_Department_Code__c;
                // 소비자가
                // if (productRequestLineItem.UnitPrice__c > 0) {
                //     consumableOrderLineItemTable.CustomerPrice = productRequestLineItem.UnitPrice__c;
                // } else {
                    //23 12 27 hyungho.chun 화면에서는 늘 CONSUMER_Price__c를 바라보게 수정
                    consumableOrderLineItemTable.CustomerPrice = productRequestLineItem.CONSUMER_Price__c;
                // }

                // 판매수량
                consumableOrderLineItemTable.SalesQuantity = productRequestLineItem.SALE_Quantity__c;
                // 판매금액
                consumableOrderLineItemTable.SaleAmount = productRequestLineItem.SALE_Amount__c == null ? 0 : productRequestLineItem.SALE_Amount__c;
                // 결제금액

                // 결제 완료(선 결제)
                // 23.08.05 gw.lee
                // 카드 복합 결제건, 기존 재경 Method를 통해 타는것이 아닌 소모품 소스만 탐으로 강제로 금액 및 결재여부 넣어주는중 (SC_Supplies 1586 Lines)
                // 기존에는 Parent를 바라봤으나 해당 경우로 인하여 Item에도 결재여부 체크 (해당 처리 방식 문제없는것 확인)
                if (productRequestLineItem.parent.PAYMENT_YN__c == true || productRequestLineItem.PAYMENT_YN__c == true) {
                    if (productRequestLineItem.CARD_PAYMENT_Amount__c == null) productRequestLineItem.CARD_PAYMENT_Amount__c = 0;
                    if (productRequestLineItem.CASH_PAYMENT_Amount__c == null) productRequestLineItem.CASH_PAYMENT_Amount__c = 0;
                    if (productRequestLineItem.POINT_Amount__c == null) productRequestLineItem.POINT_Amount__c = 0;

                    // 현금결제
                    if (productRequestLineItem.CASH_PAYMENT_Amount__c > 0 && productRequestLineItem.CASH_PAYMENT_Amount__c != null) {
                        consumableOrderLineItemTable.CashAmount = Math.ceil(productRequestLineItem.VIRTUAL_ACCT_PAYMENT_Amount__c);
                    } else if (productRequestLineItem.VIRTUAL_ACCT_PAYMENT_Amount__c > 0 && productRequestLineITem.VIRTUAL_ACCT_PAYMENT_Amount__c != null) {
                        consumableOrderLineItemTable.CashAmount = Math.ceil(productRequestLineItem.VIRTUAL_ACCT_PAYMENT_Amount__c);
                    } else {
                        consumableOrderLineItemTable.CashAmount = 0;
                    }
                    // 카드결제
                    if (productRequestLineItem.CARD_PAYMENT_Amount__c != 0 && productRequestLineItem.CARD_PAYMENT_Amount__c != null) {
                        consumableOrderLineItemTable.CardAmount = Math.ceil(productRequestLineItem.CARD_PAYMENT_Amount__c);
                    } else {
                        consumableOrderLineItemTable.CardAmount = 0;
                    }
                    // 포인트결제
                    if (productRequestLineItem.POINT_Amount__c != 0 && productRequestLineItem.POINT_Amount__c != null) {
                        consumableOrderLineItemTable.PointAmount = Math.ceil(productRequestLineItem.POINT_Amount__c);
                    } else {
                        consumableOrderLineItemTable.PointAmount = 0;
                    }

                } else {
                    // 결제 미완료
                    if (productRequestLineItem.CARD_PAYMENT_Amount__c == null) productRequestLineItem.CARD_PAYMENT_Amount__c = 0;
                    if (productRequestLineItem.CASH_PAYMENT_Amount__c == null) productRequestLineItem.CASH_PAYMENT_Amount__c = 0;
                    if (productRequestLineItem.POINT_Amount__c == null) productRequestLineItem.POINT_Amount__c = 0;

                    // 카드결제
                    if (productRequestLineItem.CARD_PAYMENT_Amount__c != null) {
                        consumableOrderLineItemTable.CardAmount = 0;
                    }
                    // 현금결제
                    if (productRequestLineItem.CASH_PAYMENT_Amount__c != null) {
                        if (productRequestLineItem.VIRTUAL_ACCT_PAYMENT_Amount__c != null) {
                            consumableOrderLineItemTable.CashAmount = Math.ceil(productRequestLineItem.CASH_PAYMENT_Amount__c);
                        } else {
                            consumableOrderLineItemTable.CashAmount = Math.ceil(productRequestLineItem.CASH_PAYMENT_Amount__c);
                        }
//                        consumableOrderLineItemTable.CashAmount = 0;
                    }
                    // 포인트결제
                    if (productRequestLineItem.POINT_Amount__c != null) {
                        consumableOrderLineItemTable.PointAmount = Math.ceil(productRequestLineItem.POINT_Amount__c);
                    }

                    // 결제 예정 금액
                    consumableOrderLineItemTable.EstimatedPaymentAmount = productRequestLineItem.CARD_PAYMENT_Amount__c + productRequestLineItem.CASH_PAYMENT_Amount__c + productRequestLineItem.POINT_Amount__c;

                }
                //23 07 25 hyungho.chun 주문취소디테일에 결제방식 필드 데이터 추가
                consumableOrderLineItemTable.PayMethod = productRequestLineItem.parent.fm_PAYMENT_TYPE__c;

                consumableOrderLineItemTable.PaymentAmount = productRequestLineItem.PAYMENT_Amount__c;
                consumableOrderLineItemTable.POINT_TRX_ID = productRequestLineItem.POINT_TRX_ID__c;

                consumableOrderLineItemTable.TID = productRequestLineItem.TID__c;
                consumableOrderLineItemTable.MOID = productRequestLineItem.MOID__c;
                // 할인 금액
                consumableOrderLineItemTable.DiscountAmount = productRequestLineItem.Last_Discount_Amount__c;
                // 할인 유형
                if (productRequestLineItem.SALE_Discount_Type_Code__c == 'V') {
                    consumableOrderLineItemTable.DiscountType = 'VIP';
                } else if (productRequestLineItem.SALE_Discount_Type_Code__c == 'E') {
                    consumableOrderLineItemTable.DiscountType = '임직원';
                } else if (productRequestLineItem.SALE_Discount_Type_Code__c == 'P') {
                    consumableOrderLineItemTable.DiscountType = '프로모션';
                }
                // 2023.08.14 seung yoon heo 할인유형 추가 '쿠폰'의 경우 08.16일 보류로 전환
                 else if (productRequestLineItem.SALE_Discount_Type_Code__c == 'L') {
                    consumableOrderLineItemTable.DiscountType = '회원';
                } else if (productRequestLineItem.SALE_Discount_Type_Code__c == 'D') {
                    consumableOrderLineItemTable.DiscountType = '쿠폰';
                }

                // 취소금액 (취소수량 * 소비자가)
                if (consumableOrderLineItemTable.CancelQuantity != null && consumableOrderLineItemTable.CancelQuantity > 0 && consumableOrderLineItemTable.CustomerPrice != null && consumableOrderLineItemTable.CustomerPrice > 0) {
                    consumableOrderLineItemTable.CancelAmount = consumableOrderLineItemTable.CancelQuantity * consumableOrderLineItemTable.CustomerPrice;
                } else {
                    consumableOrderLineItemTable.CancelAmount = 0;
                }

                // 요청수량
                consumableOrderLineItemTable.RequestedQuantity = productRequestLineItem.QuantityRequested;
                // 취소수량
                consumableOrderLineItemTable.CancelQuantity = productRequestLineItem.CANCEL_Quantity__c;

                // 반품수량
                consumableOrderLineItemTable.ReturnQuantity = productRequestLineItem.Return_Order_Quantity__c;
                //23.10.20 PHJ -> 23 10 22 hyungho.chun 원복
                // consumableOrderLineItemTable.ReturnQuantity = 0;
                // 교환수량
                consumableOrderLineItemTable.ExchangeQuantity = productRequestLineItem.Exchange_Quantity__c;

                //23 08 29 hyungho.chun 교환주문 교환반품은 교환수량 0으로 표기
                if(productRequestLineItem.Consumables_Business_Type_Code__c == 'ExchangeOrder'){
                    consumableOrderLineItemTable.ExchangeQuantity = 0;
                }

                // 반품예정수량
                Decimal expectedTotal = 0;
                for (ReturnOrderLineItem roli : productRequestLineItem.ReturnOrderLineItems) {
                        if (roli.Consumables_Business_Type_Code__c != 'ExchangeReturn') {
                                if (roli.Expected_Return_Quantity__c != null && roli.Expected_Return_Quantity__c > 0) {
                                        expectedTotal += roli.Expected_Return_Quantity__c;
                                    }
                                }
                            }
                consumableOrderLineItemTable.ExpectedReturnQuantity = expectedTotal;

                // 배송 Section Start
                // 판매번호
                // SALE_Number__c
                consumableOrderLineItemTable.SalesNumber = productRequestLineItem.SALE_Number__c;
                // CJ 주문번호
                // FFMT_Order_Number__c
                consumableOrderLineItemTable.CJOrderNumber = isCJSend ? productRequestLineItem.FFMT_Order_Number__c : null;
                // CJ 주문 전송여부
                // FFMT_Order_Transfer_YN__c
                consumableOrderLineItemTable.CJOrderSendYN = isCJSend ? 'Y' : 'N';
                // CJ 주문 전송일시
                // FFMT_Transfer_DTM__c
                consumableOrderLineItemTable.CJOrderSendDate = isCJSend ? productRequestLineItem.FFMT_Transfer_DTM__c : null;

                // 배송 상태
                if (EX_ConsumableUtil.CONSUMABLE_DELIVERY_STATUS_CODE_KOR_MAP.containsKey(productRequestLineItem.DELIVERY_STATUS_CODE__c)) {
                    consumableOrderLineItemTable.DeliveryStatus = EX_ConsumableUtil.CONSUMABLE_DELIVERY_STATUS_CODE_KOR_MAP.get(productRequestLineItem.DELIVERY_STATUS_CODE__c);
                }

                // 출하일시
                // SHIP_DTM__c
                consumableOrderLineItemTable.ShipmentDate = isCJSend ? productRequestLineItem.SHIP_DTM__c : null;
                // 배송일시
                // Delivery_DTM__c
                consumableOrderLineItemTable.DeliveryDate = isCJSend && EX_ConsumableUtil.returnStatusKORMap(productRequestLineItem.Consumables_Order_Status__c) == '배송완료' ? productRequestLineItem.Delivery_DTM__c : null;
                // 택배사
                consumableOrderLineItemTable.DeliveryCompany = isCJSend ? productRequestLineItem.DELIVERY_CODE__c : null;
                // 택배비
                // PARCEL_FEE_Amount__c
                if (productRequestLineItem.PARCEL_FEE_Amount__c != null) {
                    consumableOrderLineItemTable.DeliveryFee = Math.ceil(productRequestLineItem.PARCEL_FEE_Amount__c) ;
                }

                // 배송 Section End

                // 취소 부서
                // CANCEL_Department_Code__c
                if (productRequestLineItem.CANCEL_Department_Code__c != null) {
                    consumableOrderLineItemTable.CancelDepartment = EX_ConsumableUtil.getDepartmentName(productRequestLineItem.CANCEL_Department_Code__c);
                }
                //gw.lee 23.09.30
                //xplenty이름 변경
                consumableOrderLineItemTable.CancelRequesterEmployeeNumber = productRequestLineItem.CANCEL_UserId__r.EmployeeNumber__c == 'xplenty' ? '' : productRequestLineItem.CANCEL_UserId__r.EmployeeNumber__c;

                // 취소자
                // CANCEL_User__c
                consumableOrderLineItemTable.CancelRequester = productRequestLineItem.Order_CHNL_TYPE_Code__c != 'B' ? productRequestLineItem.CANCEL_User__c : '';
                // 취소요청일시
                consumableOrderLineItemTable.CancelRequestedDate = productRequestLineItem.CANCEL_Request_DTM__c;
                // 취소사유
                // CANCEL_Reason__c
                consumableOrderLineItemTable.CancelRequestReason = productRequestLineItem.CANCEL_Reason__c;
                // 취소 Section End

                // 교환 Section Start
                // 교환요청부서
                // Exchange_Request_Department_Code__c
                if (productRequestLineItem.Exchange_Request_Department_Code__c != null) {
                    consumableOrderLineItemTable.ExchangeRequesterDepartment = EX_ConsumableUtil.getDepartmentName(productRequestLineItem.Exchange_Request_Department_Code__c);
                }
                // 교환요청자
                // Exchange_Requester_Id__c
                consumableOrderLineItemTable.ExchangeRequester = productRequestLineItem.Exchange_Requester_Id__r.Name;
                // 교환요청자사번 23.10.19 PHJ
                // Exchange_Requester_Id__c
                consumableOrderLineItemTable.ExchangeRequesterEmployeeNumber = productRequestLineItem.Exchange_Requester_Id__r.EmployeeNumber__c;
                // 교환요청일시
                // Exchange_Request_DTM__c
                consumableOrderLineItemTable.ExchangeRequestedDate = productRequestLineItem.Exchange_Request_DTM__c;
                // 교환 Section End

                // 상담 Case 번호
                // productRequestLineItem.Parent.CaseNumber;
                consumableOrderLineItemTable.CaseNumber = productRequestLineItem.Parent.Case.Subject +' '+productRequestLineItem.Parent.Case.CaseNumber;
                consumableOrderLineItemTable.CaseURL = productRequestLineItem.Parent.fmURL_CaseNumber__c;
                // 적치장소 (소모품 / 케어용품 창고)
                consumableOrderLineItemTable.Location = 'PH8002';

                //예약번호
                consumableOrderLineItemTable.RSRV_Number = productRequestLineItem.RSRV_Number__c;

                // Column Color Setting
                consumableOrderLineItemTable.DeliveryColor = 'bg_color_delivery';
                consumableOrderLineItemTable.CancelColor = 'bg_color_cancel';
                consumableOrderLineItemTable.ReturnColor = 'bg_color_return';
                consumableOrderLineItemTable.ExchangeColor = 'bg_color_exchange';
                consumableOrderLineItemTable.QuantityRequested = productRequestLineItem.QuantityRequested;
                consumableOrderLineItemTable.PaymentRequestDT = productRequestLineItem.Parent.PAYMENT_REQUEST_DATE__c;
                //2023.09.12 seung yoon heo 결제완료일시 추가
                consumableOrderLineItemTable.PaymentCompletedDT = productRequestLineItem.Parent.PAYMENT_COMPLETED_DTM__c;

                System.debug('🤔' + consumableOrderLineItemTable.ExpectedReturnQuantity);
                orderLineItemTables.add(consumableOrderLineItemTable);
            }

            /**
            * 23.02.20 / Return Order Line Item 추가
            * I2MAX.SEOKHOLEE
            */
            // 송장번호 DeliveryInfo 조회용 Id 세팅
            List<String> roliIdList = new List<String>();
            for (ReturnOrderLineItem roli : returnOrderLineItems) {
                if (roli.Consumables_Order_Status__c != null) {
                    roliIdList.add(roli.Id);
                }
            }

            //송장번호 조회
            // List<Map<String, String>> rodMap_list = new List<Map<String, String>>();
            // if (!roliIdList.isEmpty()) {
            //     rodMap_list = getDeliveryNoList(null, roliIdList);
            // }

            for (ReturnOrderLineItem returnOrderLineItem : returnOrderLineItems) {
                consumableOrderLineItemTable = new ConsumableOrderLineItemTable();
                consumableOrderLineItemTable.Id = returnOrderLineItem.Id;
                consumableOrderLineItemTable.ParentId = returnOrderLineItem.ReturnOrderId;

                isPayment = returnOrderLineItem.Consumables_Order_Status__c != EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_003 || returnOrderLineItem.Consumables_Order_Status__c != EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_004 ? true : false;
                isSale = returnOrderLineItem.Consumables_Order_Status__c == EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_030 || returnOrderLineItem.Consumables_Order_Status__c == EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_070 ? true : false;

                isCJSend = returnOrderLineItem.FFMT_Order_Transfer_YN__c;

                //23.09.15 gw.lee
                //송장번호 변경
                consumableOrderLineItemTable.TrackingNumber = isCJSend ? returnOrderLineItem.INVOICE_Number__c : null;

                // 주문 구분
                switch on returnOrderLineItem.Consumables_Business_Type_Code__c {
                    when 'Return' {
                        consumableOrderLineItemTable.ConsumablesBusinessTypeCode = '반품';
                    }
                    when 'ExchangeReturn' {
                        consumableOrderLineItemTable.ConsumablesBusinessTypeCode = '교환반품';
                    }
                    when else {
                        consumableOrderLineItemTable.ConsumablesBusinessTypeCode = ' ';
                    }
                }


                // 주문 순번
                //consumableOrderLineItemTable.OrderSEQ = ++orderSeq;
                // Sub 번호
                String sn = returnOrderLineItem.SUB_Order_Number__c;
                if (sn != null && sn.contains('-') && sn.split('-').size() > 2) {
                    Integer targetIndex = sn.split('-').size();
                    if (sn.split('-')[targetIndex - 1].equals('01')) {
                        consumableOrderLineItemTable.SubNumber = sn.split('-')[targetIndex - 2] + '-' + sn.split('-')[targetIndex - 1];
                    } else {
                        consumableOrderLineItemTable.SubNumber = 'ㄴ' + sn.split('-')[targetIndex - 2] + '-' + sn.split('-')[targetIndex - 1];
                    }
                } else {
                    consumableOrderLineItemTable.SubNumber = sn;
                }

                // consumableOrderLineItemTable.SubNumber = returnOrderLineItem.SUB_Order_Number__c;
                // 주문 채널
                switch on returnOrderLineItem.Order_CHNL_TYPE_Code__c {
                    when 'B' {
                        consumableOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_OBS_LABEL;
                    }
                    when 'S' {
                        consumableOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_THINQ_LABEL;
                    }
                    when 'V' {
                        consumableOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_CIC_LABEL;
                    }
                    when 'BestShop' {
                        consumableOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_BESTSHOP_LABEL;
                    }
                    //2023.08.16 seung yoon heo Order_CHNL_TYPE_Code__c == 'Y'  >> 소모품샵  추가
                    when 'Y' {
                        consumableOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_CICSHOP_LABEL;
                    }
                    when else {
                        consumableOrderLineItemTable.OrderChannel = '미지정';
                    }
                }
                // 주문 일시

                consumableOrderLineItemTable.OrderDate = returnOrderLineItem.Return_Order_Request_DTM__c;
                // 주문 번호
                consumableOrderLineItemTable.OrderNumber = returnOrderLineItem.Order_Number__c;
                // 주문 상태
                //consumableOrderLineItemTable.OrderStatus = productRequestLineItem.PAYMENT_YN__c ? productRequestL
                // ineItem.Consumables_Order_Status_Code__c : '품절예약완료';
                consumableOrderLineItemTable.OrderStatus = EX_ConsumableUtil.returnStatusKORMap(returnOrderLineItem.Consumables_Order_Status__c);

                // 주문 상세 상태
                //consumableOrderLineItemTable.OrderStatusDetail = returnOrderLineItem.Consumables_Order_DETAIL__c;

                //송장번호
                // List<Map<String, String>> results = dMap_list;
                // if (!results.isEmpty()) {
                //     Integer matchCnt = 0;
                //     String tNum = '';
                //     for (Map<String, String> mp : results) {
                //         if (mp.get(String.valueOf(returnOrderLineItem.id)) != null && !String.valueOf(mp.get(String.valueOf(returnOrderLineItem.id))).equals('')) {
                //             matchCnt++;
                //             tNum = String.valueOf(mp.get(String.valueOf(returnOrderLineItem.id)));
                //         }
                //     }
                //     if (matchCnt > 1) {
                //         consumableOrderLineItemTable.TrackingNumber = isCJSend ? tNum + '외 ' + (matchCnt - 1) + '건' : null;
                //     } else {
                //         consumableOrderLineItemTable.TrackingNumber = isCJSend ? tNum : null;
                //     }
                // }

                // 요청 Part No
                consumableOrderLineItemTable.RequestedPartNo = returnOrderLineItem.Parts_Number__c;
                // 입고 Part No
                consumableOrderLineItemTable.ReceivedPartNo = returnOrderLineItem.Parts_Number__c;
                // 사업부
                //consumableOrderLineItemTable.DIV = returnOrderLineItem.productRequestLineItem.ENDP_Code__c;
                consumableOrderLineItemTable.DIV = returnOrderLineItem.ENDP_Code__c;
                // 한글 품명
                consumableOrderLineItemTable.PartNameKOR = returnOrderLineItem.productRequestLineItem.fm_Consumables_PART_DESC_KOR__c;
                // 품명
                //consumableOrderLineItemTable.PartName = returnOrderLineItem.productRequestLineItem.Product2.Name;
                consumableOrderLineItemTable.PartName = returnOrderLineItem.ProductRequestLineItem.Product2.PART_DESC__c;
                // 모델
                //consumableOrderLineItemTable.Model = returnOrderLineItem.productRequestLineItem.Product2.MODEL_CODE__c;
                consumableOrderLineItemTable.Model = returnOrderLineItem.productRequestLineItem.Product2.MODEL_Code__c;
                
                // 출고부서
                //consumableOrderLineItemTable.ShippedDepartment  = 'PH8002';
                // 소비자가
                //consumableOrderLineItemTable.CustomerPrice = returnOrderLineItem.productRequestLineItem.Product2.CUST_PRICE__c;
                // if (returnOrderLineItem.productRequestLineItem.UnitPrice__c > 0) {
                //     consumableOrderLineItemTable.CustomerPrice = returnOrderLineItem.productRequestLineItem.UnitPrice__c;

                // } else {
                    //23 12 27 hyungho.chun 화면에서 늘 CONSUMER_Price__c 바라보게
                    consumableOrderLineItemTable.CustomerPrice = returnOrderLineItem.productRequestLineItem.CONSUMER_Price__c;
                // }
                // 판매수량 => 0으로 정의
                consumableOrderLineItemTable.SalesQuantity = 0;
                // 판매금액
                //consumableOrderLineItemTable.SaleAmount = 0;
                consumableOrderLineItemTable.SaleAmount = returnOrderLineItem.RETURN_SALE_Amount__c;
                // 결제금액


                // 230612 반품 결제금액 표시 관련 교환반품은 결제금액 표시하지 않음.
                if (returnOrderLineItem.Consumables_Business_Type_Code__c == 'Return') {
                        if (returnOrderLineItem.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c == null) returnOrderLineItem.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c = 0;
                        if (returnOrderLineItem.RETURN_CARD_PAYMENT_Amount__c == null) returnOrderLineItem.RETURN_CARD_PAYMENT_Amount__c = 0;
                        if (returnOrderLineItem.RETURN_POINT_Amount__c == null) returnOrderLineItem.RETURN_POINT_Amount__c = 0;

                        // 현금결제
                        if (returnOrderLineItem.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c != 0 && returnOrderLineItem.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c != null) {
                            consumableOrderLineItemTable.CASHAmount = Math.ceil(returnOrderLineItem.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c);
                        } else {
                            consumableOrderLineItemTable.CASHAmount = 0;
                        }
                        // 카드결제
                        if (returnOrderLineItem.RETURN_CARD_PAYMENT_Amount__c != 0 && returnOrderLineItem.RETURN_CARD_PAYMENT_Amount__c != null) {
                            consumableOrderLineItemTable.CardAmount = Math.ceil(returnOrderLineItem.RETURN_CARD_PAYMENT_Amount__c);
                        } else {
                            consumableOrderLineItemTable.CardAmount = 0;
                        }
                        // 포인트결제
                        if (returnOrderLineItem.RETURN_POINT_Amount__c != 0 && returnOrderLineItem.RETURN_POINT_Amount__c != null) {
                            consumableOrderLineItemTable.PointAmount = Math.ceil(returnOrderLineItem.RETURN_POINT_Amount__c);
                        } else {
                            consumableOrderLineItemTable.PointAmount = 0;
                        }

                        consumableOrderLineItemTable.PaymentAmount = returnOrderLineItem.RETURN_PAYMENT_Amount__c == null ? 0 : returnOrderLineItem.RETURN_PAYMENT_Amount__c;

                } else {
                    // 230612 반품 결제금액 표시 관련 교환반품은 결제금액 표시하지 않음.
                    consumableOrderLineItemTable.CASHAmount = 0;
                    consumableOrderLineItemTable.CardAmount = 0;
                    consumableOrderLineItemTable.PointAmount = 0;
                    consumableOrderLineItemTable.EstimatedPaymentAmount = 0;
                    consumableOrderLineItemTable.PaymentAmount = 0;
                }


                //결제 방식
                List<String> payMethodList = new List<String>();
                if (returnOrderLineItem.productRequestLineItem.CASH_PAYMENT_Amount__c != null && returnOrderLineItem.productRequestLineItem.CASH_PAYMENT_Amount__c != 0) {
                    //현금
                    payMethodList.add('현금입금');
                }
                if (returnOrderLineItem.productRequestLineItem.CARD_PAYMENT_Amount__c != null && returnOrderLineItem.productRequestLineItem.CARD_PAYMENT_Amount__c != 0) {
                    //카드
                    payMethodList.add('카드');
                }
                if (returnOrderLineItem.productRequestLineItem.POINT_Amount__c != null && returnOrderLineItem.productRequestLineItem.POINT_Amount__c != 0) {
                    //포인트
                    payMethodList.add('포인트');
                }
                if (!payMethodList.isEmpty()) {
                    consumableOrderLineItemTable.PayMethod = String.join(payMethodList, '+');
                } else {
                    consumableOrderLineItemTable.PayMethod = '';
                }


                // 할인 금액
                consumableOrderLineItemTable.DiscountAmount = returnOrderLineItem.Return_Last_Discount_Amount__c;
                // 할인 유형

                // 요청수량
                // gw.lee 23.08.26
                // 반품일 경우, 요청 수량 표기 X
                consumableOrderLineItemTable.RequestedQuantity = 0;
                //consumableOrderLineItemTable.RequestedQuantity = returnOrderLineItem.QuantityReturned;
                // 취소수량 => 0으로 정의
                consumableOrderLineItemTable.CancelQuantity = 0;
                // 반품수량
                //consumableOrderLineItemTable.ReturnQuantity = returnOrderLineItem.productRequestLineItem.Return_Order_Quantity__c;
                consumableOrderLineItemTable.ReturnQuantity = returnOrderLineItem.Actual_Return_Quantity__c;
                // 반품예정수량
                consumableOrderLineItemTable.ExpectedReturnQuantity = returnOrderLineItem.Consumables_Business_Type_Code__c == 'Return' || returnOrderLineItem.Consumables_Business_Type_Code__c == 'ExchangeReturn' ? returnOrderLineItem.Expected_Return_Quantity__c : 0;

                if (returnOrderLineItem.Consumables_Business_Type_Code__c == 'Return') {
                    if (originItemExpectedReturnQtyMap.containsKey(returnOrderLineItem.ProductRequestLineItemId)) {
                        originItemExpectedReturnQtyMap.put(returnOrderLineItem.ProductRequestLineItemId, originItemExpectedReturnQtyMap.get(returnOrderLineItem.ProductRequestLineItemId) + returnOrderLineItem.Expected_Return_Quantity__c);
                    } else {
                        originItemExpectedReturnQtyMap.put(returnOrderLineItem.ProductRequestLineItemId, returnOrderLineItem.Expected_Return_Quantity__c);
                    }
                }

                // 교환수량 => 0으로 정의
                consumableOrderLineItemTable.ExchangeQuantity = returnOrderLineItem.Consumables_Business_Type_Code__c == 'ExchangeReturn' ? returnOrderLineItem.QuantityReturned : 0;
                //23 08 29 hyungho.chun 교환반품 교환수량 0 표기
                if(returnOrderLineItem.Consumables_Business_Type_Code__c == 'ExchangeReturn'){
                    consumableOrderLineItemTable.ExchangeQuantity=0;
                }

                // 배송 Section Start
                // 판매번호
                // SALE_Number__c
                consumableOrderLineItemTable.SalesNumber = returnOrderLineItem.ProductRequestLineItem.SALE_Number__c;
                // CJ 주문번호
                // FFMT_Order_Number__c
                //consumableOrderLineItemTable.CJOrderNumber = isCJSend ? '0000001234' : null;
                consumableOrderLineItemTable.CJOrderNumber = isCJSend ? returnOrderLineItem.FFMT_Order_Number__c : null;
                // CJ 주문 전송여부
                // FFMT_Order_Transfer_YN__c
                consumableOrderLineItemTable.CJOrderSendYN = isCJSend ? 'Y' : 'N';
                // CJ 주문 전송일시
                // FFMT_Transfer_DTM__c
                consumableOrderLineItemTable.CJOrderSendDate = isCJSend ? returnOrderLineItem.FFMT_Transfer_DTM__c : null;

                // 230704 / 반품확정, 반품완료 인 경우 배송완료로 표시
                if (returnOrderLineItem.Consumables_Order_Status__c == '120' || returnOrderLineItem.Consumables_Order_Status__c == '121') {
                    consumableOrderLineItemTable.DeliveryStatus = '배송완료';
                }

                // 출하일시
                // SHIP_DTM__c
                //consumableOrderLineItemTable.ShipmentDate = isCJSend ? returnOrderLineItem.CreatedDate.addHours(4) : null;
                // 배송일시 // 23.08.03 park ho jun
                // Delivery_DTM__c
                //consumableOrderLineItemTable.DeliveryDate = isCJSend && EX_ConsumableUtil.returnStatusKORMap(returnOrderLineItem.Consumables_Order_Status__c) == '배송완료' ? returnOrderLineItem.CreatedDate.addDays(2) : null;
                consumableOrderLineItemTable.DeliveryDate = isCJSend && EX_ConsumableUtil.returnStatusKORMap(returnOrderLineItem.Consumables_Order_Status__c) == '반품확정' ? returnOrderLineItem.Return_Order_CONFIRM_DTM__c : null;

                // 택배사
                consumableOrderLineItemTable.DeliveryCompany = isCJSend ? 'CJGLS' : '';
                // 택배비
                // TODO 23.05.02 항목추가검토
                // PARCEL_FEE_Amount__c
                consumableOrderLineItemTable.DeliveryFee = isCJSend ? 0 : null;
                // 배송 Section End


                // 반품 Section Start
                // 반품부서명
                // ReturnOrderLineItem.Department_Code__c
                // 24 03 08 PHJ 수정
                // if (returnOrderLineItem.Order_CHNL_TYPE_Code__c == 'V' || returnOrderLineItem.Order_CHNL_TYPE_Code__c == 'S') {
                    if (returnOrderLineItem.Return_Order_Department_Code__c != null) {
                        consumableOrderLineItemTable.ReturnDepartment = returnOrderLineItem.Order_CHNL_TYPE_Code__c == 'B' && consumableOrderLineItemTable.ConsumablesBusinessTypeCode == '반품' ? '' : EX_ConsumableUtil.getDepartmentName(returnOrderLineItem.Return_Order_Department_Code__c);
                    }
                // }

                // 반품요청자사번
                //consumableOrderLineItemTable.ReturnRequesterEmployeeNumber = returnOrderLineItem.CreatedBy.EmployeeNumber__c;
                //gw.lee 23.09.30
                //xplenty이름 변경
                //consumableOrderLineItemTable.ReturnRequesterEmployeeNumber = returnOrderLineItem.Return_Requester_Id_c__r.EmployeeNumber__c;
                consumableOrderLineItemTable.ReturnRequesterEmployeeNumber = returnOrderLineItem.Return_Requester_Id_c__r.EmployeeNumber__c == 'xplenty' ? '' : returnOrderLineItem.Return_Requester_Id_c__r.EmployeeNumber__c;
                // 반품요청자명
                // 23-07-12 DKBMC 전형호
                // OBS주문 반품의 경우 'interface_ivr' -> 공란 처리
                // if(returnOrderLineItem.Order_CHNL_TYPE_Code__c != EX_ConsumableUtil.CONSUMABLE_OBS){
                //     consumableOrderLineItemTable.ReturnRequester = returnOrderLineItem.Return_Requester_Id_c__r.Name;
                // }
                
                consumableOrderLineItemTable.ReturnRequester = returnOrderLineItem.Return_Requester_Id_c__r.Name;

                // 반품요청일시
                // ReturnOrderLineItem.Return_Order_Request_DTM__c
                consumableOrderLineItemTable.ReturnRequestedDate = returnOrderLineItem.Return_Order_Request_DTM__c;
                // 반품요청사유
                // 매핑 필요
                consumableOrderLineItemTable.ReturnRequestReason = returnOrderLineItem.Return_Requester_Reason__c;

                // 반품승인일시
                // Return_Order_Approval_DTM__c
                consumableOrderLineItemTable.ReturnApprovedDate = returnOrderLineItem.Return_Order_CONFIRM_DTM__c;

                // Column Color Setting
                consumableOrderLineItemTable.DeliveryColor = 'bg_color_delivery';
                consumableOrderLineItemTable.CancelColor = 'bg_color_cancel';
                consumableOrderLineItemTable.ReturnColor = 'bg_color_return';
                consumableOrderLineItemTable.ExchangeColor = 'bg_color_exchange';

                //24 01 26 hyungho.chun 상태값이 null(목표는 반품반려)이거나 '반품대기'일때는 주문관리화면에 연결된 returnOrderLineitem 보이지 않게     
                if(consumableOrderLineItemTable.OrderStatus != null && consumableOrderLineItemTable.OrderStatus != '반품대기'){
                    orderLineItemTables.add(consumableOrderLineItemTable);
                }
                
                // orderLineItemTables.add(consumableOrderLineItemTable);
            }
            System.debug(JSON.serialize(orderLineItemTables));
            orderLineItemTables.sort();
            System.debug(JSON.serialize(orderLineItemTables));

            for (ConsumableOrderLineItemTable coli : orderLineItemTables) {
                coli.OrderSEQ = ++orderSeq;
                if (originItemExpectedReturnQtyMap.containsKey(coli.Id) && coli.ConsumablesBusinessTypeCode == '주문') {
                    //23.10.20 PHJ -> 23 10 22 hyungho.chun 원복
                    coli.ExpectedReturnQuantity = originItemExpectedReturnQtyMap.get(coli.Id);
                    // coli.ExpectedReturnQuantity = 0;
                }

            }
            returnMap.put('productRequestLineItems', orderLineItemTables);
        } catch (Exception e) {
            System.debug(e.getLineNumber() + 'Line || ' + e.getMessage());
            throw new AuraHandledException(e.getLineNumber() + 'Line || ' + e.getMessage());
        }

        return returnMap;
    }

    /**
      * @description 소모품 주문 정보 디테일 조회 /
      *
      * @author 23.01.05 / I2MAX.SEOKHOLEE
      * @return
      */
    @AuraEnabled
    public static Map<String, Object> doGetConsumableOrderData(String consumableOrderNumber) {
        Map<String, Object> returnMap = new Map<String, Object>();
        Map<String, Object> returnParentDataMap = new Map<String, Object>();


//        Set<String> editDeliveryStatusSet = new Set<String>{
//                '결제요청', '결제완료', '품절예약완료', '품절주문완료', '상품준비중'
//        };

        // 품절예약완료, 결제요청, 결제완료, 상품준비중
        Set<String> editDeliveryStatusSet = new Set<String>{    
                EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_000,
                EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_001,
                EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_002,
                EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006
        };
        Boolean isEditDeliveryInfo = false;

        String strQuery = '';
        // SELECT
        //2023.08.17 seung yoon heo field 추출
        // strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequest');
        strQuery += ' SELECT Id';
        strQuery += ' , CASH_PAYMENT_Amount__c ';
        strQuery += ' , CARD_PAYMENT_Amount__c ';
        strQuery += ' , POINT_Amount__c ';

        strQuery += ' , PAYMENT_Amount__c ';
        strQuery += ' , APPR_NUM__c ';
        strQuery += ' , ACQUIRE_NAME__c '; //24 01 08 hyungho.chun 은행명 추가
        strQuery += ' , VBANK_NUM__c ';
        strQuery += ' , Delivery_Message_CONTENT__c ';
        strQuery += ' , Description ';
        strQuery += ' , PAYMENT_REQUEST_DATE__c ';
        strQuery += ' , PAYMENT_COMPLETED_DTM__c ';

        strQuery += ' , fm_IsMaskingTarget__c ';
        strQuery += ' , Order_CUST_Name__c ';
        strQuery += ' , CONSIGNEE_Name__c ';
        strQuery += ' , fm_ENC_Order_CUST_Name__c ';
        strQuery += ' , fm_ENC_CONSIGNEE_Name__c ';
        strQuery += ' , Order_CUST_TPNO_1__c ';
        strQuery += ' , fm_ENC_Order_CUST_TPNO_1__c ';
        strQuery += ' , CONSIGNEE_TPNO_1__c ';
        strQuery += ' , fm_ENC_CONSIGNEE_TPNO_1__c ';
        strQuery += ' , CONSIGNEE_Address__c ';
        strQuery += ' , fm_ENC_CONSIGNEE_Address__c ';
        strQuery += ' , CONSIGNEE_Address_DETAIL__c ';
        strQuery += ' , fm_ENC_CONSIGNEE_Address_DETAIL__c ';
        strQuery += ' , CONSIGNEE_PostalCode__c ';
        strQuery += ' , fm_ENC_CONSIGNEE_PostalCode__c ';
        strQuery += ' , CONSIGNEE_TPNO_2__c ';
        strQuery += ' , fm_ENC_CONSIGNEE_TPNO_2__c ';
        strQuery += ' , Order_CUST_PostalCode__c ';
        strQuery += ' , fm_ENC_Order_CUST_PostalCode__c ';
        strQuery += ' , Order_CUST_Address__c ';
        strQuery += ' , fm_ENC_Order_CUST_Address__c ';
        strQuery += ' , Order_CUST_Address_DETAIL__c ';
        strQuery += ' , fm_ENC_Order_CUST_Address_DETAIL__c ';
        strQuery += ' , Order_CUST_TPNO_2__c ';
        strQuery += ' , fm_ENC_Order_CUST_TPNO_2__c ';
        strQuery += ' , EMP_CEL_NO__c ';
        
        strQuery += ' , Order_CUST_Id__r.Name';
        strQuery += ' , Order_CUST_Id__r.Phone';
        strQuery += ' , Case.Description ';
        strQuery += ' , Case.TRANSFER_REASON2__c ';
        strQuery += ' , CreatedBy.Name ';


        //결제정보를 위해 추가

        strQuery += ' , ( ';
        strQuery += '  SELECT Id , fm_Num_Consumable_status__c , Consumables_Order_Status__c ';
        strQuery += ' , CASH_PAYMENT_Amount__c ';
        strQuery += ' , CARD_PAYMENT_Amount__c ';
        strQuery += ' , POINT_Amount__c ';

        strQuery += ' FROM ProductRequestLineItems ';

        //strQuery += ' WHERE Consumables_Order_Status_Code__c NOT IN :editDeliveryStatusSet ';
//        strQuery += ' WHERE Consumables_Order_Status__c';

        strQuery += ' ) ';

        // FROM
        strQuery += ' FROM ' + 'ProductRequest';

        // WHERE
        strQuery += ' WHERE Order_Number__c =  \'' + consumableOrderNumber + '\'';
        // PO가 아닌 대상
        // strQuery += ' AND Consumables_Order_Class_Code__c != \'PO\'';
        //strQuery += ' AND RecordType.DeveloperName != \'RESV\'';
//        strQuery += ' AND RecordType.DeveloperName != \'RESV_SALE\'';
        strQuery += 'AND RecordType.DeveloperName IN (\'Consumable\',\'CareSupplies\')';


        System.debug('strQuery -> ' + strQuery);
        List<ProductRequest> productRequests = Database.query(strQuery);
        ProductRequest productRequest;
        if (!productRequests.isEmpty()) {
            productRequest = productRequests[0];
            returnParentDataMap.put('contactName', productRequest.Order_CUST_Id__r.Name);
            returnParentDataMap.put('contactPhone', productRequest.Order_CUST_Id__r.Phone);
            returnParentDataMap.put('createdByName', productRequest.CreatedBy.Name);
            // 2023.09.20 seung yoon heo 상담이력 Descruption => TRANSFER_REASON2__c 변경
            // returnParentDataMap.put('caseDescription', productRequest.Case.Description);
            returnParentDataMap.put('caseDescription', productRequest.Case.TRANSFER_REASON2__c);

            Decimal Ex_consumable_status_Num_SUM = 0;
            Decimal CashPaymentAmount = 0;
            Decimal CardPaymentAmount = 0;
            Decimal PointPaymentAmount = 0;

            if (productRequest.ProductRequestLineItems != null && !productRequest.ProductRequestLineItems.isEmpty()) {
                for (ProductRequestLineItem prli : productRequest.ProductRequestLineItems) {
                    if (prli.Consumables_Order_Status__c != null) {
                        if (prli.Consumables_Order_Status__c == '000' || prli.Consumables_Order_Status__c == '001' || prli.Consumables_Order_Status__c == '002' || prli.Consumables_Order_Status__c == '006') {
                            isEditDeliveryInfo = true;
                        }
                    }
                    if (prli.fm_Num_Consumable_status__c != null && prli.fm_Num_Consumable_status__c > 0) {
                        Ex_consumable_status_Num_SUM += prli.fm_Num_Consumable_status__c;
                    }

                    if(productRequest.CASH_PAYMENT_Amount__c == 0) {
                        CashPaymentAmount += prli.CASH_PAYMENT_Amount__c != null ? prli.CASH_PAYMENT_Amount__c : 0;
                    }
                    if(productRequest.CARD_PAYMENT_Amount__c == 0) {
                        CardPaymentAmount += prli.CARD_PAYMENT_Amount__c != null ? prli.CARD_PAYMENT_Amount__c : 0;
                    }
                    if(productRequest.POINT_Amount__c == 0) {
                        PointPaymentAmount += prli.POINT_Amount__c != null ? prli.POINT_Amount__c : 0;
                    }
                }
                //2023.08.05 gw.lee
                //nullexceptoin 추가
                if(CashPaymentAmount != 0 && CashPaymentAmount != null) {
                    productRequest.CASH_PAYMENT_Amount__c = CashPaymentAmount;
                }
                if(CardPaymentAmount != 0 && CardPaymentAmount != null) {
                    productRequest.CARD_PAYMENT_Amount__c = CardPaymentAmount;
                }
                if(PointPaymentAmount != 0 && PointPaymentAmount != null) {
                    productRequest.POINT_Amount__c = PointPaymentAmount;
                }
            }

            System.debug('productRequest.fm_IsMaskingTarget__c ::: ' + productRequest.fm_IsMaskingTarget__c);
            System.debug('Ex_consumable_status_Num_SUM ::: ' + Ex_consumable_status_Num_SUM);
            System.debug('productRequest.ProductRequestLineItems.size() ::: ' + productRequest.ProductRequestLineItems.size() );


            if (productRequest.fm_IsMaskingTarget__c && Ex_consumable_status_Num_SUM > 0 && productRequest.ProductRequestLineItems.size() == Ex_consumable_status_Num_SUM) {

                productRequest.Order_CUST_Name__c = productRequest.fm_ENC_Order_CUST_Name__c;
                productRequest.CONSIGNEE_Name__c = productRequest.fm_ENC_CONSIGNEE_Name__c;
                productRequest.Order_CUST_TPNO_1__c = productRequest.fm_ENC_Order_CUST_TPNO_1__c;
                productRequest.CONSIGNEE_TPNO_1__c = productRequest.fm_ENC_CONSIGNEE_TPNO_1__c;
                productRequest.CONSIGNEE_Address__c = productRequest.fm_ENC_CONSIGNEE_Address__c;
                productRequest.CONSIGNEE_Address_DETAIL__c = productRequest.fm_ENC_CONSIGNEE_Address_DETAIL__c;

                productRequest.CONSIGNEE_PostalCode__c = productRequest.fm_ENC_CONSIGNEE_PostalCode__c;
                productRequest.CONSIGNEE_TPNO_2__c = productRequest.fm_ENC_CONSIGNEE_TPNO_2__c;
                productRequest.Order_CUST_PostalCode__c = productRequest.fm_ENC_Order_CUST_PostalCode__c;
                productRequest.Order_CUST_Address__c = productRequest.fm_ENC_Order_CUST_Address__c;
                productRequest.Order_CUST_Address_DETAIL__c = productRequest.fm_ENC_Order_CUST_Address_DETAIL__c;
                productRequest.Order_CUST_TPNO_2__c = productRequest.fm_ENC_Order_CUST_TPNO_2__c;
                // productRequest.EMP_CEL_NO__c = productRequest.fm_ENC_EMP_CEL_NO__c;

            } else {

                productRequest.Order_CUST_Name__c = productRequest.Order_CUST_Name__c;
                productRequest.CONSIGNEE_Name__c = productRequest.CONSIGNEE_Name__c;
                productRequest.Order_CUST_TPNO_1__c = productRequest.Order_CUST_TPNO_1__c;
                productRequest.CONSIGNEE_TPNO_1__c = productRequest.CONSIGNEE_TPNO_1__c;
                productRequest.CONSIGNEE_Address__c = productRequest.CONSIGNEE_Address__c;
                productRequest.CONSIGNEE_Address_DETAIL__c = productRequest.CONSIGNEE_Address_DETAIL__c;

                productRequest.CONSIGNEE_PostalCode__c = productRequest.CONSIGNEE_PostalCode__c;
                productRequest.CONSIGNEE_TPNO_2__c = productRequest.CONSIGNEE_TPNO_2__c;
                productRequest.Order_CUST_PostalCode__c = productRequest.Order_CUST_PostalCode__c;
                productRequest.Order_CUST_Address__c = productRequest.Order_CUST_Address__c;
                productRequest.Order_CUST_Address_DETAIL__c = productRequest.Order_CUST_Address_DETAIL__c;
                productRequest.Order_CUST_TPNO_2__c = productRequest.Order_CUST_TPNO_2__c;
                productRequest.EMP_CEL_NO__c = productRequest.EMP_CEL_NO__c;

            }

        }
//        for (ProductRequest pr : productRequests) {
//            if (pr.ProductRequestLineItems.isEmpty()) isEditDeliveryInfo = true;
//        }


//        System.debug('doGetConsumableOrderData 배송완료에서 왜 디테일 조회안되는지 확인용 ');
//        System.debug('productRequest출력하기 ' + productRequest);
        returnMap.put('productRequest', productRequest);

        // todo 현재 유저가 상담사 인지 여부 판단 필요.
        returnMap.put('isEditDeliveryInfo', isEditDeliveryInfo);
        returnMap.put('parent', returnParentDataMap);
        return returnMap;
    }

    /**
      * @description 소모품 주문 정보 디테일 조회 /
      * @author 23.01.19 / I2MAX.SEUNGHUNAN
      * @param caseId
      * @return Case
      */
    @AuraEnabled
    public static Case doGetCaseByCaseId(String caseId) {
        Case c = [SELECT Id, Description FROM Case WHERE Id = :caseId];
        return c;
    }


    @AuraEnabled
    public static Map<String, String> checkUserCanEditCase() {
        String returnStr = '';
        Map<String, String> returnMap = new Map<String, String>();

        //에이전트 확인
        List<ServiceResource> kResourceList = [
                SELECT Id, ResourceType
                FROM ServiceResource
                WHERE RelatedRecordId = :UserInfo.getUserId()
                AND (ResourceType = 'A')
        ];

        //자재 관리자 확인
        List<PermissionSetAssignment> listPermissionSetAssignment = [
                SELECT PermissionSet.Name
                        , PermissionSetId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId()
        ];

        PermissionSetAssignment objPSA = new PermissionSetAssignment();
        if (!listPermissionSetAssignment.isEmpty()) {
            for (PermissionSetAssignment tempPSA : listPermissionSetAssignment) {
                //'FS_ProductItemAdmim' -- 자재관리자 Permission Set
                if (tempPSA.PermissionSet.Name == 'FS_ProductItemAdmin') {
                    objPSA = tempPSA;
                }
            }
        }
        if (objPSA != null && objPSA.PermissionSet.Name != null && !objPSA.PermissionSet.Name.equals('')) {
            returnStr = objPSA.PermissionSet.Name;
            returnMap.put('PermissionSetName', returnStr);
        }


        if (!kResourceList.isEmpty()) {
            returnStr = kResourceList[0].ResourceType;
            returnMap.put('ResourceType', returnStr);
        }
        return returnMap;
    }

    /**
      * @description 소모품 주문 정보 Update /
      *
      * @author 23.01.20 / I2MAX.SEOKHOLEE
      * @return
      */
    @AuraEnabled
    public static Map<String, Object> doUpdateConsumableOrderData(Map<String, Object> productRequest, String appendRemark) {
        Map<String, Object> returnMap = new Map<String, Object>();
        //자재관리자 이거나 서비스 리소스 ResourceType이 에이전트가 아닌 경우 상담 이력을 수정할 수 없음.
        //String currentUserserviceResourceType = doGetAgentServiceResource();
        Map<String, String> validMap = new Map<String, String>();
        validMap = checkUsercanEditCase();
        Boolean isSuccess = true;

        System.debug('checkUsercanEditCase  : ' + validMap);
        System.debug('validMap.get(\'ResourceType\') : ' + validMap.get('ResourceType'));
        System.debug('validMap.get(\'PermissionSetName\') : ' + validMap.get('PermissionSetName'));
        if (validMap != null && (validMap.get('ResourceType') != 'A' || validMap.get('PermissionSetName') == 'FS_ProductItemAdmin') && (appendRemark != null && !appendRemark.equals(''))) {

            System.debug('checkUserCanEditCase ::: ' + validMap);
            returnMap.put('caseUpdateFail', '상담이력을 수정할 수 없습니다.');
            isSuccess = false;
        } else {
            ProductRequest updateProductRequest;
            try {
                try{
                    String checkNo = (String) productRequest.get('CONSIGNEE_TPNO_1__c');
                    CM_CommonUtil cmUtil = new CM_CommonUtil();
                    String checkTelNoValidMessage = cmUtil.checkValidTelNo(checkNo);
                    if(!String.isEmpty(checkTelNoValidMessage)) {
                        // 전화번호가 유호 하지 않는 경우 처리 케이스.
                        //23 12 06 hyungho.chun 여기만 resultState로 받길래 isSuccess로 바꿈
                        // returnMap.put('resultState', 'ERROR');
                        returnMap.put('isSuccess', false);
                        // returnMap.put('isPhoneVal' , checkTelNoValidMessage);
                        checkTelNoValidMessage = '받는분(수취인) 전화번호가 유효하지 않습니다.';
                        returnMap.put('resultMessage' , checkTelNoValidMessage);
                        return returnMap;
                    }
                } catch (Exception e){
                    System.debug(e.getLineNumber() + ' Line || ' + e.getMessage());
                    // throw new AuraHandledException(e.getLineNumber() + ' Line || ' + e.getMessage());
                    returnMap.put('isSuccess', false);
                    // returnMap.put('isPhoneVal' , checkTelNoValidMessage);
                    
                    returnMap.put('resultMessage' , '받는분(수취인) 전화번호가 유효하지 않습니다.');
                    return returnMap;
                }

                System.debug(productRequest);
                updateProductRequest = new ProductRequest();
                updateProductRequest.Id = (Id) productRequest.get('Id');
                updateProductRequest.CONSIGNEE_Name__c = (String) productRequest.get('CONSIGNEE_Name__c');
                updateProductRequest.CONSIGNEE_TPNO_1__c = DN_CommonUtil.setTelnumFormat((String) productRequest.get('CONSIGNEE_TPNO_1__c'));
                updateProductRequest.CONSIGNEE_Address__c = (String) productRequest.get('CONSIGNEE_Address__c');
                updateProductRequest.CONSIGNEE_Address_DETAIL__c = (String) productRequest.get('CONSIGNEE_Address_DETAIL__c');
                updateProductRequest.CONSIGNEE_PostalCode__c = (String) productRequest.get('CONSIGNEE_PostalCode__c');
                updateProductRequest.Delivery_Message_CONTENT__c = (String) productRequest.get('Delivery_Message_CONTENT__c');
                updateProductRequest.Description = (String) productRequest.get('Description');

                update updateProductRequest;

                List<ProductRequestLineItem> updateItems = [
                        SELECT CONSIGNEE_Name__c, CONSIGNEE_TPNO_1__c, CONSIGNEE_Address__c, CONSIGNEE_Address_DETAIL__c, Delivery_Message_CONTENT__c,
                                Parent.CONSIGNEE_Name__c, Parent.CONSIGNEE_TPNO_1__c, Parent.CONSIGNEE_Address__c, Parent.CONSIGNEE_Address_DETAIL__c, Parent.Delivery_Message_CONTENT__c
                        FROM ProductRequestLineItem
                        WHERE ParentId = :updateProductRequest.Id
                ];

                for (ProductRequestLineItem productRequestLineItem : updateItems) {
                    productRequestLineItem.CONSIGNEE_Name__c = productRequestLineItem.Parent.CONSIGNEE_Name__c;
                    productRequestLineItem.CONSIGNEE_TPNO_1__c = productRequestLineItem.Parent.CONSIGNEE_TPNO_1__c;
                    productRequestLineItem.CONSIGNEE_Address__c = productRequestLineItem.Parent.CONSIGNEE_Address__c;
                    productRequestLineItem.CONSIGNEE_Address_DETAIL__c = productRequestLineItem.Parent.CONSIGNEE_Address_DETAIL__c;
                    productRequestLineItem.Delivery_Message_CONTENT__c = productRequestLineItem.Parent.Delivery_Message_CONTENT__c;
                }

                update updateItems;

                //23.09.18 PHJ
                // String caseId = (String) productRequest.get('CaseId');
                // if (caseId != null) {
                //     appendRemark = '\n' + appendRemark;

                    // Map<String, Object> mapResult = SC_CommonUtil.setCallCode(caseId, true, appendRemark, true);
                    // if (mapResult.get('stat') == 'SUCCESS') {
                    //     System.debug('Case Update Success');
                    // } else {

                    //     System.debug('Case Update Fail >> ' + mapResult.get('message'));
                    //     String errorMsg = (String) mapResult.get('message');
                    //     System.debug('errorMsg : ' + errorMsg);

                    //     //returnMap.put('caseUpdateFail', errorMsg.split(',')[1].replaceAll(':|\\[\\]', ''));
                    //     returnMap.put('caseUpdateFail', errorMsg.split(',')[1] + errorMsg.split(',')[2] + errorMsg.split(',')[3]);
                    // }
                // }

            } catch (Exception e) {
                System.debug(e.getMessage());
                isSuccess = false;
                returnMap.put('resultMessage' , 'Unknown error');

            }
        }
        returnMap.put('isSuccess', isSuccess);

        return returnMap;
    }

    /**
     * @description 현금입금대상 리스트에서 조건에 맞게 조회
     * @author 23.01.25 / I2MAX.D
     * @param Map<String,Object> mapSearchParam
     * @return Map<String, Object>
     */
    @AuraEnabled
    public static Map<String, Object> doSearchCashDepositRequests(Map<String, Object> mapSearchParam) {
        System.debug('현금 입금 대상자 로부터 mapSearchParam : ' + mapSearchParam);
        Map<String, Object> returnMap = new Map<String, Object>();
        String strQuery = '';

        // SELECT
        strQuery += ' SELECT Id, ' +
                'CONSIGNEE_TPNO_1__c, ' +
                'CreatedDate, ' +
                // 주문 번호
                'Order_Number__c, ' +
                // 주문일시
                'Order_Date__c, ' +

                // 주문자명
                'Order_CUST_Id__r.Name, ' +
                // 주문자전화번호
                'Order_CUST_Id__r.MobilePhone, ' +
                // 은행명
                'ACQUIRE_NAME__c, ' +
                // 가상계좌번호
                'VBANK_NUM__c, ' +
                // 입금여부
                'CASH_DEPOSIT_YN__c, ' +
                // 입금금액
                'PAYMENT_Amount__c , ' +
                'POINT_Amount__c, ' +
                'Order_CUST_TPNO_1__c,' +
                'Order_CUST_Name__c,' +
                // 입금일자
                'APPR_DT__c, ' +
                // 승인번호
                'APPR_NUM__c, ' +
                // 주문접수 부서
                'CNSL_Department_Id__r.DEPT_NAME__c, ' +
                // 주문접수자
                'CreatedBy.Name, CreatedBy.Phone, CreatedBy.MobilePhone, CreatedById__r.Name, ' +
                '( SELECT ID, PAYMENT_Amount__c, POINT_Amount__c, CASH_PAYMENT_Amount__c, Consumables_Order_Status__c FROM ProductRequestLineItems WHERE Consumables_Order_Status__c NOT IN (\'003\', \'004\', \'005\')  ), ' +
                'Department_Id__r.DEPT_NAME__c, ' +
                'Department_Id__r.CHIEF_NM__c '; // 주문자명 확실하지 않아서 임의로 CHIEF_NAME__c 로 설정함. --> 금액 부분이기에 각 센터장이 접수해야 된다고 판단 추후에 규모가 커지면 변경 고려
        //공백시 미배정으로

        // FROM
        strQuery += ' FROM ' + 'ProductRequest';

        // WHERE              // 현금 입금 대상 여부 삭제됨(CASH_DEPOSIT_Destination__c)   // 소모품 대상 여부
        strQuery += ' WHERE Id != null ';
        strQuery += ' AND RecordType.DeveloperName = \'Consumable\'';
        strQuery += ' AND Order_CHNL_TYPE_Code__c = \'V\'';
        strQuery += 'AND fm_PAYMENT_TYPE__c = \'현금입금\'';


        // 주문일시
        if (mapSearchParam.get('initialSDate') != null && mapSearchParam.get('initialEDate') != null
                && mapSearchParam.get('initialSDate') != '' && mapSearchParam.get('initialEDate') != '') {
            // 현금입금대상자 시작 기준 일자
            //23 09 18 hyungho.chun createdDate -> order_date__c
            // strQuery += ' AND DAY_ONLY(convertTimezone(CreatedDate)) >= ' + mapSearchParam.get('initialSDate');
            strQuery += ' AND DAY_ONLY(convertTimezone(order_date__c)) >= ' + mapSearchParam.get('initialSDate');
            // 현금입금대상자 종료 기준 일자
            //23 09 18 hyungho.chun createdDate -> order_date__c
            // strQuery += ' AND DAY_ONLY(convertTimezone(CreatedDate)) <= ' + mapSearchParam.get('initialEDate');
            strQuery += ' AND DAY_ONLY(convertTimezone(order_date__c)) <= ' + mapSearchParam.get('initialEDate');

        }
        // 팀명
        if (mapSearchParam.get('teamName') != null && mapSearchParam.get('teamName') != '') {
            String teamName = (String) mapSearchParam.get('teamName');
            strQuery += ' AND CNSL_Department_Id__r.fm_HIGH_DEPT_NAME__c = \'' + teamName + '\'';
        }
        // 센터명
        if (mapSearchParam.get('centerName') != null && mapSearchParam.get('centerName') != '' && mapSearchParam.get('centerName') != '전체') {
            String centerName = (String) mapSearchParam.get('centerName');
            strQuery += ' AND CNSL_Department_Id__r.DEPT_NAME__c = \'' + centerName + '\'';
        }
        // SE
        if (mapSearchParam.get('SE') != null && mapSearchParam.get('SE') != '' && mapSearchParam.get('SE') != '전체') {

            String SE = (String) mapSearchParam.get('SE');
            String SE1 = SE.substring(0,1);
            String SE2 = SE.substring(1);

            // strQuery += ' AND CreatedBy.Name LIKE \'' +  '%' + SE1 +  '%' +'\''; // SE 필드 맵핑 확인필요.
            // strQuery += ' AND CreatedBy.Name LIKE \'' +  '%' + SE2 +'\''; // SE 필드 맵핑 확인필요.
            strQuery += ' AND CreatedById__r.Name LIKE \'' +  '%' + SE1 +  '%' +'\''; // SE 필드 맵핑 확인필요.
            strQuery += ' AND CreatedById__r.Name LIKE \'' +  '%' + SE2 +'\''; // SE 필드 맵핑 확인필요.

        }
        // 결제자명
        if (mapSearchParam.get('payment') != null && mapSearchParam.get('payment') != '') {
            String payment = (String) mapSearchParam.get('payment');
            // contact.name
            strQuery += ' AND Order_CUST_Id__r.Name LIKE \'' + '%' + payment + '%' + '\'';
        }
        // 주문번호
        if (mapSearchParam.get('orderNo') != null && mapSearchParam.get('orderNo') != '') {
            String orderNo = (String) mapSearchParam.get('orderNo');
            strQuery += ' AND Order_Number__c LIKE \'' + '%' + orderNo + '%' + '\'';
        }
        // 입금여부
        Boolean DepositY;
        Boolean DepositN;
        Boolean DepositNone;

        if (mapSearchParam.get('DepositY') != null && mapSearchParam.get('DepositY') != '') {
            DepositY = (Boolean) mapSearchParam.get('DepositY');
        }
        if (mapSearchParam.get('DepositN') != null && mapSearchParam.get('DepositN') != '') {
            DepositN = (Boolean) mapSearchParam.get('DepositN');
        }
        if (mapSearchParam.get('DepositNone') != null && mapSearchParam.get('DepositNone') != '') {
            DepositNone = (Boolean) mapSearchParam.get('DepositNone');
        }
//        Set<String> cashDepositYN = new Set<String>{
//                '입금', '미입금', '취소'
//        };

        if (DepositY == true) {
            strQuery += ' AND ( CASH_DEPOSIT_YN__c =  \'' + 'A' + '\' ';
        }
        if (DepositN == true && DepositY == true) {
            strQuery += ' OR CASH_DEPOSIT_YN__c = \'' + 'B' + '\' ';
        } else if (DepositN == true && DepositY == false) {
            strQuery += ' AND ( CASH_DEPOSIT_YN__c = \'' + 'B' + '\' ';
        }
        if (DepositNone == true && (DepositN == true || DepositY == true)) {
            strQuery += ' OR  CASH_DEPOSIT_YN__c = \'' + 'C' + '\' ';
        } else if (DepositNone == true && DepositN == false && DepositY == false) {
            strQuery += ' AND ( CASH_DEPOSIT_YN__c = \'' + 'C' + '\' ';
        }
        strQuery += ')';

        // ORDER BY
        strQuery += ' ORDER BY CreatedDate DESC ';
        System.debug(strQuery);

        List<ProductRequest> productRequests = Database.query(strQuery);

//        Set<Id> SM_DEPTIds = new Set<Id>();
        System.debug(productRequests);
        //ProductRequest를 작성한 자의 serviceResouce를 통해 Name, Phone을 가져옴
//        Set<String> setName = new Set<String>();
//        String prName ;
//        for(ProductRequest pr : productRequests){
//            prName = pr.CreatedBy.Name;
//            setName.add(prName);
//        }
//
//        System.debug( 'setname :: ' + setName);
//
//        List<ServiceResource> resourceList = new List<ServiceResource>();
//        String resourceQuery = '';
//
//        resourceQuery += ' SELECT Id, Name, Phone__c, CORPORATION_PHONE_NUMBER__c  ';
//        resourceQuery += ' FROM ServiceResource  ';
//        //resourceQuery += ' WHERE Name IN :setName AND IsActive = true ' ;
//        resourceQuery += ' WHERE Name IN : setName  ' ;
//        resourceList = Database.query(resourceQuery);
//        System.debug( 'resourceList :: ' + resourceList);

        List<CashDepositTable> cashDepositTables = new List<CashDepositTable>();
//        return Integer.valueOf(result.substring(0,length));

        Map<String, String> bankMap = new Map<String, String>{
                '0' => '국민은행',
                '1' => '우리은행',
                '2' => '신한은행',
                '3' => '기업은행'
        };
        Integer totalAmount = 0;


        for (ProductRequest pr : productRequests) {

            Integer amount = 0;
            Integer amount2 = 0; //지은 test
            // amount2 = Integer.valueOf(pr.PAYMENT_Amount__c - pr.POINT_Amount__c);



            String result = '';
            while (result.length() < 12) {
                //Math.abs used to cast Crypto.getRandomLong() to a positive number
//            result += String.valueOf(Math.abs(Crypto.getRandomLong()));
                result += String.valueOf(Integer.valueOf(Math.random() * 10));
            }

            String ranNum = '00000000';
            while (ranNum.length() < 12) {
                ranNum += String.valueOf(Integer.valueOf((Math.random() * 9) + 1));
            }

            CashDepositTable cashDepositTable = new CashDepositTable();
            cashDepositTable.OrderNumber = pr.Order_Number__c;
            //cashDepositTable.CreatedDate = pr.CreatedDate;
            cashDepositTable.CreatedDate = pr.Order_Date__c;

//            if(!resourceList.isEmpty()){
//                if(resourceList[0].Name !=null || !resourceList[0].Name.equals('')) {
//                    System.debug('서비스 자원에서 들고온 Name');
//                    cashDepositTable.Name = resourceList[0].Name;
//                } else {
//                    System.debug('ProductRequest.CreatedBy의 Name');
            cashDepositTable.Name = pr.Order_CUST_Name__c;
//                }
//            }


            //cashDepositTable.ConsigneePhoneNum = pr.CONSIGNEE_TPNO_1__c;
            //cashDepositTable.ConsigneePhoneNum = pr.Order_CUST_Id__r.MobilePhone;
//            if(!resourceList.isEmpty()){
//                if(resourceList[0].Phone__c !=null || !resourceList[0].Phone__c.equals('')) {
//                    System.debug('서비스 자원에서 들고온 Phone__c');
//                    cashDepositTable.Name = resourceList[0].Name;
//                } else {
//                    System.debug('ProductRequest.CreatedBy의 Phone');
//            if (pr.CreatedBy.Phone != null) {
//                cashDepositTable.ConsigneePhoneNum = pr.CreatedBy.Phone;
//            }

            if (pr.Order_CUST_TPNO_1__c != null) {
                cashDepositTable.ConsigneePhoneNum = pr.CONSIGNEE_TPNO_1__c;
            } else if (pr.Order_CUST_Id__r.MobilePhone != null) {
                cashDepositTable.ConsigneePhoneNum = pr.Order_CUST_Id__r.MobilePhone;
            }
//                }
//            }

            cashDepositTable.BankName = pr.ACQUIRE_NAME__c;
            //cashDepositTable.BankName = String.valueOf(bankMap.get(String.valueOf(Integer.valueOf(Math.random() * 4))));
            //cashDepositTable.VirtualBankNum = result;
            cashDepositTable.VirtualBankNum = pr.VBANK_NUM__c;
            if (pr.CASH_DEPOSIT_YN__c == 'A')
                cashDepositTable.DepositStatus = '입금';
            else if (pr.CASH_DEPOSIT_YN__c == 'B')
                cashDepositTable.DepositStatus = '미입금';
            else if (pr.CASH_DEPOSIT_YN__c == 'C')
                cashDepositTable.DepositStatus = '대상아님';
            //cashDepositTable.DepositAmount = amount;


            // cashDepositTable.DepositAmount = amount2;
            //cashDepositTable.DepositAmount = amount2.format();
            //totalAmount += amount;
            // totalAmount += amount2;
//            cashDepositTable.DepositDate = pr.DepositDate;
            //cashDepositTable.DepositDate = pr.CreatedDate;
            cashDepositTable.DepositDate = pr.APPR_DT__c;
            if (pr.CASH_DEPOSIT_YN__c != null && pr.CASH_DEPOSIT_YN__c == 'A') {
                //cashDepositTable.ApprovalNumber = ranNum;
                cashDepositTable.ApprovalNumber = pr.APPR_NUM__c;
            }
            cashDepositTable.DeptName = pr.CNSL_Department_Id__r.DEPT_NAME__c;
            // 2023.11.03 seung yoon heo 주문접수자명 변경
            // cashDepositTable.ChiefName = pr.CreatedBy.Name;
            cashDepositTable.ChiefName = pr.CreatedById__r.Name;

            
            if (pr.ProductRequestLineItems != null) {
                Integer i = 0;
                for (ProductRequestLineItem prLineItems : pr.ProductRequestLineItems) {
                    if (prLineItems.Consumables_Order_Status__c != null) {
                        if (i == 0) {
                            //23.11.02 PHJ
                            System.debug('payment Amount !!' + prLineItems.PAYMENT_Amount__c);
                            System.debug('point Amount !!' + prLineItems.POINT_Amount__c);
                            amount2 += Integer.valueOf(pr.PAYMENT_Amount__c - pr.POINT_Amount__c);
                            System.debug('Amount !!' + amount2);
                            cashDepositTable.DepositAmount = amount2;
                            totalAmount += amount2;
                            System.debug('total Amount !!' + totalAmount);
                            
                            cashDepositTables.add(cashDepositTable);
                            i ++;
                        }
                    }
                }
            }


        }

//        returnMap.put('productRequests', productRequests);

        returnMap.put('cashDepositTables', cashDepositTables);
        returnMap.put('totalAmount', totalAmount);

        return returnMap;

    }


    /**
     * @description 현금입금대상 리스트에서 선택한 대상에 SMS 보내기
     * @author 23.01.25 / I2MAX.D
     * @param Map<Object,Object> selectedCashDepositRows
     * @return void
     */
    @AuraEnabled
    public static Map<String, Object> doSendSms(Map<Object, Object> selectedCashDepositRows) {
        System.debug('doSendSMS !!');
        System.debug('selectedCashDepositRows' + selectedCashDepositRows);


        String cdName = (String) selectedCashDepositRows.get('Name');
        String DepositAmount = String.valueOf(selectedCashDepositRows.get('DepositAmount'));
        String VBankNum = (String) selectedCashDepositRows.get('VirtualBankNum');
        String BankName = (String) selectedCashDepositRows.get('BankName');
        String OrderNumber = (String) selectedCashDepositRows.get('OrderNumber');

        ProductRequest pr = [SELECT Id, MOID__c FROM ProductRequest WHERE Order_Number__c = :OrderNumber AND RecordType.DeveloperName = 'Consumable' AND Order_CHNL_TYPE_Code__c = 'V' AND fm_PAYMENT_TYPE__c = '현금입금' LIMIT 1][0];

        SR_PRE_PAYMENT_DETAIL__c detail = [SELECT PAY_CUST_PHONE__c FROM SR_PRE_PAYMENT_DETAIL__c WHERE MOID__c = :pr.MOID__c LIMIT 1];
        System.debug('cdName: ' + cdName + 'DepositAmount : ' + DepositAmount + ' VBankNum : ' + VBankNum + 'BankName : ' + BankName);

        Map< String, Object> returnMap = new Map< String, Object>();

        EX_Message__c etm = new EX_Message__c();
        etm.Label1__c = cdName;
        //etm.Label2__c = DepositAmount;
        etm.Label2__c = Integer.valueOf(selectedCashDepositRows.get('DepositAmount')).format();

        etm.Label3__c = VBankNum;
        etm.Label4__c = BankName;
        insert etm;

        returnMap.put('exObjId', Id.valueOf(etm.Id));

        String templateCode = 'SVC_LGE_MACN_S012';

        Map< String, Object> relatedData = EX_MessageUtil.getRelatedData(templateCode, Id.valueOf(etm.Id));
        TemplateMgmt__c template = (TemplateMgmt__c) relatedData.get('template');
        List< TemplateParams__c> templateParamList = (List< TemplateParams__c>) relatedData.get('templateParamList');
        EX_Message__c messageObject = (EX_Message__c) relatedData.get('messageObject');

        Map< String, Object> populateMap = messageObject.getPopulatedFieldsAsMap();

        IF_CM_SFDC_KAKAO.InputParam inputParam = EX_MessageUtil.getInputParamForKaKao(template, templateParamList, populateMap);
        String smsMsg = inputParam.kakaoMsg;

        returnMap.put('receiverMsg', smsMsg);
        returnMap.put('BankName', BankName);
        returnMap.put('VBankNum', VBankNum);
        returnMap.put('receiverPhone', detail.PAY_CUST_PHONE__c);

        system.debug('receiverMsg : ' + smsMsg);

        return returnMap;

    }

    /**
     * @description 현금입금대상 리스트에서 팀명 목록 조회
     * @author 23.01.25 / I2MAX.D
     * @param
     * @return Map<String, List<String>>
     */
    @AuraEnabled
    public static Map<String, List<String>> getInitData() {

        Map<String, List<String>> selectMap = new Map<String, List<String>>();

       // List<SM_DEPT__c> organizations = [
        //         SELECT
        //                 Id,
        //                 HIGH_DEPT_CODE__r.Name,
        //                 fm_HIGH_DEPT_NAME__c
        //         FROM
        //                 SM_DEPT__c
        //         WHERE
        //                 CLOSE_YN__c != 'Y' AND DEPT_TYPE_SECOND__c = 'E'
        //             AND (NOT fm_HIGH_DEPT_NAME__c LIKE '%소모품%')
        //         ORDER BY
        //                 fm_HIGH_DEPT_NAME__c
        // ];
        List<SM_DEPT__c> organizations = [
            SELECT Id, HIGH_DEPT_CODE__r.Name, fm_HIGH_DEPT_NAME__c
            FROM SM_DEPT__c
            WHERE CLOSE_YN__c != 'Y'
            AND DEPT_TYPE_SECOND__c IN ('E', 'G', 'H','N')
            AND HIGH_DEPT_CODE__r.DEPT_TYPE_SECOND__c IN ('A','C')
            ORDER BY HIGH_DEPT_CODE__r.Name, HIGH_DEPT_CODE__r.DEPT_CODE__c
        ];

        List<String> listTeam = new List<String>();

        for (SM_DEPT__c obj : organizations) {

            if (!listTeam.contains(obj.fm_HIGH_DEPT_NAME__c)) {
                listTeam.add(obj.fm_HIGH_DEPT_NAME__c);
            }
        }

        selectMap.put('listTeam', listTeam);

        return selectMap;
    }

    /**
     * @description 현금입금대상 리스트에서 팀명에 따른 센터명 목록 조회
     * @author 23.01.25 / I2MAX.D
     * @param String selectedTeam
     * @return Map<String, List<String>>
     */
    @AuraEnabled
    public static Map<String, List<String>> getCenterData(String selectedTeam) {
        Map<String, List<String>> selectMap = new Map<String, List<String>>();
        // List<SM_DEPT__c> teams = [
        //         SELECT
        //                 Id,
        //                 fm_HIGH_DEPT_NAME__c
        //         FROM
        //                 SM_DEPT__c
        //         WHERE
        //                 CLOSE_YN__c != 'Y' AND DEPT_TYPE_SECOND__c = 'E'
        //                 AND (NOT fm_HIGH_DEPT_NAME__c LIKE '%소모품%')
        //         ORDER BY
        //                 fm_HIGH_DEPT_NAME__c
        // ];
        
        List<SM_DEPT__c> teams = [
            SELECT HIGH_DEPT_CODE__c,  HIGH_DEPT_CODE__r.Name, HIGH_DEPT_CODE__r.DEPT_CODE__c
            FROM SM_DEPT__c
            WHERE CLOSE_YN__c != 'Y'
            AND DEPT_TYPE_SECOND__c IN ('E', 'G', 'H','N')
            AND HIGH_DEPT_CODE__r.DEPT_TYPE_SECOND__c IN ('A','C')
            ORDER BY HIGH_DEPT_CODE__r.Name, HIGH_DEPT_CODE__r.DEPT_CODE__c
        ];

        
        

        List<String> listTeam = new LIst<String>();

        for (SM_DEPT__c obj : teams) {
            if (!listTeam.contains(obj.HIGH_DEPT_CODE__r.Name)) {
                listTeam.add(obj.HIGH_DEPT_CODE__r.Name);
            }
        }

        List<SM_DEPT__c> organizations = [
            SELECT      Id
                        ,DEPT_NAME__c 
                        ,Name
            FROM        SM_DEPT__c
            WHERE       (DEPT_TYPE_SECOND__c IN ('E','N','G','H') AND HIGH_DEPT_CODE__r.Name = :selectedTeam) or (HIGH_DEPT_CODE__r.HIGH_DEPT_CODE__r.Name = :selectedTeam and DEPT_TYPE_SECOND__c IN ('E','N','G','H')) or (
                (HIGH_DEPT_CODE__r.HIGH_DEPT_CODE__r.Name = :selectedTeam and DEPT_TYPE_SECOND__c IN ('E','N','G','H'))
                or(HIGH_DEPT_CODE__r.HIGH_DEPT_CODE__r.HIGH_DEPT_CODE__r.Name = :selectedTeam and DEPT_TYPE_SECOND__c IN ('E','N','G','H')))
            ORDER BY    Name
        ];

        List<String> listCenter = new List<String>();

        for (SM_DEPT__c obj : organizations) {
            if (!listCenter.contains(obj.DEPT_NAME__c)) {
                listCenter.add(obj.DEPT_NAME__c);
                if (obj.DEPT_NAME__c == null) {
                    listCenter.add(obj.Name);
                }
            }
        }

        selectMap.put('listCenter', listCenter);
        selectMap.put('listTeam', listTeam);

        System.debug('현금입금대상 리스트에서 팀명에 따른 센터명 목록 조회');
        System.debug('listCenter :: ' + listCenter);
        System.debug('listTeam :: ' + listTeam);

        return selectMap;
    }

    /**
     * @description 현금입금대상 리스트에서 센터명에 따른 SE 목록 조회
     * @author 23.01.25 / I2MAX.D
     * @param String selectedTeam, String selectedCenter
     * @return Map<String, List<String>>
     */
    @AuraEnabled
    public static Map<String, List<String>> getSEData(String selectedTeam, String selectedCenter) {
        Map<String, List<String>> selectMap = new Map<String, List<String>>();
        
        Set<String> kangwonChecks = new Set<String>{
            'PH0101','PH0014','PH0090','PH0052','PH0089','PH0048'
    };
        /*
            List<SM_DEPT__c> teams = [
                    SELECT
                            Id,
                            fm_HIGH_DEPT_NAME__c
                    FROM
                            SM_DEPT__c
                    WHERE
                            CLOSE_YN__c != 'Y' AND DEPT_TYPE_SECOND__c = 'E'
                    AND     (NOT fm_HIGH_DEPT_NAME__c LIKE '%소모품%')

                    ORDER BY
                            fm_HIGH_DEPT_NAME__c
            ];
        */
        // List<SM_DEPT__c> teams = [

        //     SELECT Id
        //         ,DEPT_NAME__c 
        //         ,HIGH_DEPT_CODE__c
        //     FROM SM_DEPT__c
        //     WHERE CLOSE_YN__c != 'Y'
        //     AND DEPT_TYPE_SECOND__c IN ('E', 'G', 'H','N')
        //     AND HIGH_DEPT_CODE__r.DEPT_TYPE_SECOND__c IN ('A','C')
        //     AND HIGH_DEPT_CODE__r.Name = :selectedTeam
        //     ORDER BY HIGH_DEPT_CODE__r.Name, HIGH_DEPT_CODE__r.DEPT_CODE__c 
          
        // ];

        // List<String> listTeam = new LIst<String>();

        /*
            for (SM_DEPT__c obj : teams) {
                if (!listTeam.contains(obj.fm_HIGH_DEPT_NAME__c)) {
                    listTeam.add(obj.fm_HIGH_DEPT_NAME__c);
                }
            }
        */
        
        // for (SM_DEPT__c obj : teams) {
        //     if (!listTeam.contains(obj.HIGH_DEPT_CODE__c)) {
        //         listTeam.add(obj.HIGH_DEPT_CODE__c);
        //     }
        // }

        /*
            List<SM_DEPT__c> organizations = [
                    SELECT
                            Id,
                            DEPT_NAME__c,
                            Name
                    FROM
                            SM_DEPT__c
                    WHERE
                            fm_HIGH_DEPT_NAME__c = :selectedTeam
                    ORDER BY
                            DEPT_NAME__c
            ];
        */
        List<SM_DEPT__c> organizations = [
            SELECT      Id
                            ,DEPT_NAME__c 
                            ,Name
            FROM        SM_DEPT__c
            WHERE       (DEPT_TYPE_SECOND__c IN ('E','N','G','H') AND HIGH_DEPT_CODE__r.Name = :selectedTeam) or (HIGH_DEPT_CODE__r.HIGH_DEPT_CODE__r.Name = :selectedTeam and DEPT_TYPE_SECOND__c IN ('E','N','G','H')) or (
                    (HIGH_DEPT_CODE__r.HIGH_DEPT_CODE__r.Name = :selectedTeam and DEPT_TYPE_SECOND__c IN ('E','N','G','H'))
                    or(HIGH_DEPT_CODE__r.HIGH_DEPT_CODE__r.HIGH_DEPT_CODE__r.Name = :selectedTeam and DEPT_TYPE_SECOND__c IN ('E','N','G','H')))
            ORDER BY    Name
        ];
        // List<SM_DEPT__c> organizations = [
        //     SELECT      Id
        //                 ,DEPT_NAME__c 
        //                 ,Name
        //     FROM        SM_DEPT__c
        //     WHERE       (DEPT_TYPE_SECOND__c IN ('E','N','G','H') AND HIGH_DEPT_CODE__r.Name = :selectedTeam) OR DEPT_CODE__c IN:kangwonChecks
        //     ORDER BY    Name ASC
        // ];

        List<String> listCenter = new List<String>();

        for (SM_DEPT__c obj : organizations) {
            if (!listCenter.contains(obj.DEPT_NAME__c)) {
                listCenter.add(obj.DEPT_NAME__c);
            }
        }

        List<SM_DEPT__c> SE = [
                SELECT
                        Id,
                        fm_HIGH_DEPT_NAME__c,
                        DEPT_NAME__c,
                        (
                                SELECT
                                        Id,
                                        Name
                                FROM
                                        Service_Resources1__r
                                ORDER BY
                                        Name
                        )
                FROM
                        SM_DEPT__c
                WHERE
                        fm_HIGH_DEPT_NAME__c = :selectedTeam
                        AND
                        (DEPT_NAME__c = :selectedCenter or Name = :selectedCenter)
        ];

        List<String> listSE = new List<String>();

        for (SM_DEPT__c obj : SE) {
            for (ServiceResource sr : obj.Service_Resources1__r) {
                if (!listSE.contains(sr.Name)) {
                    listSE.add(sr.Name);

                }
            }
        }

        selectMap.put('listCenter', listCenter);
        // selectMap.put('listTeam', listTeam);
        selectMap.put('listSE', listSE);

        return selectMap;
    }

    @AuraEnabled
    public static Map<String, Object> doCancel(String strCaseId, String remark, List<Object> selectedRows, List<Object> draftValues, List<Object> selectedMasterData, String bankCode, String bankAccountNo, String receiverName, String jsonString, String resendType) {
        /*주문취소*/
        Map<String, Object> returnMap = new Map<String, Object>();
        String resultStat = 'SUCCESS';
        String resultMessage = '';
        //23 10 01 hyungho.chun
        // Map<String, Object> selectedMasterMap = new Map<String, Object>();
        // selectedMasterMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(selectedMasterData[0]));
        // if(selectedMasterMap.get('OrderType') == '일반주문'){
        //     String mid = '';
        //     if (selectedMasterMap.get('MOID') != null) {
        //         mid = String.valueOf(selectedMasterMap.get('MOID'));
        //     }
        //     SR_SMARTRO_PAYMENT_REQUEST__c kSmartro = new SR_SMARTRO_PAYMENT_REQUEST__c();
        //     kSmartro = EX_PaymentUtil.fetchRequestHistory(mid);
        // }

        returnMap = EX_ConsumableUtil.cancelUtil(strCaseId, remark, selectedRows, draftValues, selectedMasterData, bankCode, bankAccountNo, receiverName);
        if (returnMap.get('resultStat') == 'SUCCESS') {
            Map<String, Object> paramMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            Integer selectedCnt = selectedRows.size();
            paramMap.put('selectedCnt', selectedCnt);
            jsonString = JSON.serialize(paramMap);
            Map<String, Object> msgMap = doSaveTmpExMessageObj(jsonString, resendType);
            returnMap.put('exObjId', msgMap.get('exObjId'));
            returnMap.put('receiverMsg', msgMap.get('receiverMsg'));
        }

        returnMap.put('resultStat', returnMap.get('resultStat'));
        returnMap.put('resultMessage', returnMap.get('resultMessage'));


        return returnMap;
    }

    /**
    * @description 소모품 알림(알림톡, SMS) 재전송
    *
    * @author 23.02.02 / I2MAX.SEUNGHUNAHN
    * @return Map<String, Object>
    */
    @AuraEnabled
    public static Map<String, Object> doResend(String exObjId, String resendType, String jsonString, String receiverNumber) {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<ProductRequest> pr = new List<ProductRequest>();
        if (jsonString != null && !jsonString.equals('')) {
            Map<String, Object> paramMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            pr = [SELECT Payment_URL__c, PAYMENT_TYPE__c, PAYMENT_REQUEST_DATE__c FROM ProductRequest WHERE Id = :(String) paramMap.get('ParentId') LIMIT 1];
            pr[0].PAYMENT_REQUEST_DATE__c = system.now();
            //update pr;
        }


        String receiverNo = receiverNumber.replaceAll('-', '');

        String notiType = '알림톡';
        String templateCode = '';

        if (resendType.equals('가상계좌재전송')) {
            // templateCode = 'SVC_LGE_MACN_012_01';
            templateCode = 'SVC_LGE_MACN_012_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
        } else if (resendType.equals('결제URL재전송')) {
            // templateCode = 'SVC_LGE_MACN_011';
            templateCode = 'SVC_LGE_MACN_011_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
        } else if (resendType.equals('SMS재전송')) {
            if (pr[0].PAYMENT_TYPE__c != 'CASH') {
                // templateCode = 'SVC_LGE_MACN_S011';
                templateCode = 'SVC_LGE_MACN_S011_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
            } else {
                templateCode = 'SVC_LGE_MACN_S012';
            }
            notiType = 'SMS';
        } else if (resendType.equals('반품요청')) {
            // templateCode = 'SVC_LGE_MACN_030';
            templateCode = 'SVC_LGE_MACN_030_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
        } else if (resendType.equals('SMS 발송')) { //현금입금대상 화면에서 전송
            templateCode = 'SVC_LGE_MACN_S012';
            notiType = 'SMS';
        } else if (resendType.equals('주문 취소')) {
            // templateCode = 'SVC_LGE_MACN_031';
            templateCode = 'SVC_LGE_MACN_031_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
        }

        IF_CM_SFDC_KAKAO.Result result;
        IF_CM_SFDC_MSG.Result smsResult;
        if (!templateCode.equals('') && notiType.equals('알림톡')) {
            //result = EX_MessageUtil.sendKaKaoMessage(templateCode, exObjId, '01091236537');
            //result = EX_MessageUtil.sendKaKaoMessage(templateCode, exObjId, (String) paramMap.get('CONSIGNEE_Phone'));


            System.debug(templateCode + ' ' + exObjId + ' ' + receiverNo);
            Map<String, Object> relatedData = EX_MessageUtil.getRelatedData(templateCode, exObjId);
            TemplateMgmt__c template = (TemplateMgmt__c) relatedData.get('template');
            List<TemplateParams__c> templateParamList = (List<TemplateParams__c>) relatedData.get('templateParamList');
            EX_Message__c messageObject = (EX_Message__c) relatedData.get('messageObject');

            Map<String, Object> populateMap = messageObject.getPopulatedFieldsAsMap();

            IF_CM_SFDC_KAKAO.InputParam inputParam = EX_MessageUtil.getInputParamForKaKao(template, templateParamList, populateMap);
            if (receiverNo == null || receiverNo.equals('')) return null;
            inputParam.smsTitle = '소모품 주문 안내';
            inputParam.smsMsg = inputParam.kakaoMsg;
            //inputParam.smsMsg = '카카오 발송 실패!';
            inputParam.setPhoneNumber = new Set<String>{
                    receiverNo
            };

            System.debug('inputParam : ' + inputParam);
            if(resendType.equals('주문 취소')){
                result = EX_MessageUtil.sendKaKaoMessage(templateCode, exObjId, receiverNo);
            } else if (resendType.equals('결제URL재전송') || resendType.equals('가상계좌재전송')) {

                if (resendType.equals('결제URL재전송')) {
                    List< IF_CM_SFDC_KAKAO.Button> listButton = new List< IF_CM_SFDC_KAKAO.Button>();
                    IF_CM_SFDC_KAKAO.Button button1 = new IF_CM_SFDC_KAKAO.Button();
                    button1.type = 'URL';
                    button1.buttonText = '결제하기';
                    button1.buttonUrlPc = pr[0].Payment_URL__c;
                    button1.buttonUrlMobile = pr[0].Payment_URL__c;
                    listButton.add(button1);
                    inputParam.listKakaoButton = listButton;
    
                    System.debug('pr ::: ' + pr);
                }


                System.debug('Input params :::::' + inputParam);
            
            Map<String, Object> mapResult = IF_CM_SFDC_KAKAO.doSendKakao(inputParam);

           
            IF_CM_SFDC_KAKAO.Result kakaoResult = (IF_CM_SFDC_KAKAO.Result) mapResult.get('resultWrapper');

            System.debug('MapResult :::: ' + kakaoResult);
            
            if (kakaoResult == null) {
                kakaoResult = (IF_CM_SFDC_KAKAO.Result) mapResult.get('result');
                System.debug('MapResult :::: ' + kakaoResult);
            }

            if (!kakaoResult.isSuccess && !Test.isRunningTest()) {
                throw new FNException('KaKao 발신 실패');
            }

            result = kakaoResult;
            }
            System.debug('test :::: ' + result);
            returnMap.put('isSuccess', result.isSuccess);
            returnMap.put('errorMsg', result.errorMsg);
        } else if (!templateCode.equals('') && notiType.equals('SMS')) {
            Map<String, Object> relatedData = EX_MessageUtil.getRelatedData(templateCode, exObjId);
            TemplateMgmt__c template = (TemplateMgmt__c) relatedData.get('template');
            List<TemplateParams__c> templateParamList = (List<TemplateParams__c>) relatedData.get('templateParamList');
            EX_Message__c messageObject = (EX_Message__c) relatedData.get('messageObject');

            Map<String, Object> populateMap = messageObject.getPopulatedFieldsAsMap();

            IF_CM_SFDC_KAKAO.InputParam inputParam = EX_MessageUtil.getInputParamForKaKao(template, templateParamList, populateMap);
            String smsMsg = inputParam.kakaoMsg;
            Set<String> rcvNoSet = new Set<String>();
            //rcvNoSet.add('01091236537');
            //rcvNoSet.add((String) paramMap.get('CONSIGNEE_Phone'));
            rcvNoSet.add(receiverNo);
            IF_CM_SFDC_MSG.InputParam inputP = new IF_CM_SFDC_MSG.InputParam();
            /*
            public String subject;
            public String backupMessage;
            public Set<String> setReceiveMobileNo;
            public Datetime sendReserveDate;
            public String requestId;
             */
            inputP.subject = '';
            inputP.backupMessage = smsMsg;
            inputP.setReceiveMobileNo = rcvNoSet;
            //inputP.sendReserveDate = System.now();
            //inputP.requestId = UserInfo.getUserId();
            Map<String, Object> smsResultMap = new Map<String, Object>();
            smsResultMap = IF_CM_SFDC_MSG.doSendMsg(inputP);
            smsResult = (IF_CM_SFDC_MSG.Result) smsResultMap.get('resultWrapper');
            if (smsResult == null) {
                smsResult = (IF_CM_SFDC_MSG.Result) smsResultMap.get('result');
            }
            returnMap.put('isSuccess', smsResult.isSuccess);
            returnMap.put('errorMsg', smsResult.errorMsg);
        }
        returnMap.put('notiType', notiType);
        if (pr.size() > 0) {
            update pr;
        }

        return returnMap;

//        Map<String, String> mapRecordIdByObjApiName = new Map<String, String>{
//                // 소모품 임시 메시지 api 변경
////                'EX_TemporaryMessage__c' => exObjId
//        };
//        Map<String, String> tmplCodeMap = new Map<String, String>();
//        tmplCodeMapInit(tmplCodeMap);
//
//        String ifId = resendType.equals('SMS재전송') ? 'message' : 'kakao';
//        String tmplCode = tmplCodeMap.get(resendType);
//        String notiType = resendType.equals('SMS재전송') ? 'SMS' : '알림톡';
//
//        Map<String, Object> data = IFUtil.setInputParam(ifId);
//        Set<String> setReceiveMobileNo = new Set<String>{
//                '01077486993'
//        };
//        Map<String, Object> returnMap = null;
////        Map<String, Object> returnMap = resendType.equals('SMS재전송')
////                ? IF_CM_BizBase.sendMsg(tmplCode, mapRecordIdByObjApiName, setReceiveMobileNo, data)
////                : IF_CM_BizBase.sendKakao(tmplCode, mapRecordIdByObjApiName, setReceiveMobileNo, data);
//
//        // todo : ResultWrapper 클래스 필드에 @AuraEnable Annotation 추가한 임시 클래스
////        ResultWrapperTest rwt = new ResultWrapperTest((IF_CM_SendMsgKakao.ResultWrapper) returnMap.get('resultWrapper'));
////        returnMap.put('resultWrapper', rwt);
//        // returnMap.put('notiType', notiType);
//
//        //   System.debug('returnMap :: ' + returnMap);
//
//        return returnMap;
    }


    /**
    * @description 소모품 알림 전송 / 반품 요청 - 다건
    *
    * @author 23.04.20 / I2MAX.SEOKHOLEE
    * @return Map<String, Object>
    */
    @AuraEnabled
    public static Map<String, Object> doResendReturnRequest(List<String> exObjIdList, String resendType, String jsonString, String receiverNumber) {
        System.debug('doResendReturnRequest');

        Map<String, Object> returnMap = new Map<String, Object>();
        //Map<String, Object> paramMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        String receiverNo = receiverNumber.replaceAll('-', '');
        String notiType = '알림톡';
        String templateCode = '';

        if (resendType.equals('반품요청')) {
            // templateCode = 'SVC_LGE_MACN_030';
            templateCode = 'SVC_LGE_MACN_030_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
        }

        IF_CM_SFDC_KAKAO.BulkResult result;
        IF_CM_SFDC_MSG.Result smsResult;
        if (!templateCode.equals('') && notiType.equals('알림톡')) {

            List< IF_CM_SFDC_KAKAO.InputParam> params = new List< IF_CM_SFDC_KAKAO.InputParam>();

            System.debug(templateCode + ' ' + exObjIdList + ' ' + receiverNo);

            for (String exObjId : exObjIdList) {
                Map<String, Object> relatedData = EX_MessageUtil.getRelatedData(templateCode, exObjId);
                TemplateMgmt__c template = (TemplateMgmt__c) relatedData.get('template');
                List<TemplateParams__c> templateParamList = (List<TemplateParams__c>) relatedData.get('templateParamList');
                EX_Message__c messageObject = (EX_Message__c) relatedData.get('messageObject');

                Map<String, Object> populateMap = messageObject.getPopulatedFieldsAsMap();

                IF_CM_SFDC_KAKAO.InputParam inputParam = EX_MessageUtil.getInputParamForKaKao(template, templateParamList, populateMap);
                if (receiverNo == null || receiverNo.equals('')) return null;
                inputParam.smsTitle = '소모품 주문 안내';
                inputParam.smsMsg = inputParam.kakaoMsg;
                //inputParam.smsMsg = '카카오 발송 실패!';
                inputParam.setPhoneNumber = new Set<String>{
                        receiverNo
                };

                System.debug('inputParam : ' + inputParam);
                params.add(inputParam);
            }

            IF_CM_SFDC_KAKAO.BulkResult kakaoBulkResult = IF_CM_SFDC_KAKAO.doBulkSendKakao(params);
            System.debug(kakaoBulkResult);
            result = kakaoBulkResult;

            System.debug(result);

            returnMap.put('isSuccess', result.result);
            returnMap.put('errorMsg', result.errorMsg);

            returnMap.put('notiType', notiType);
        }

        return returnMap;
    }

    /**
    * @description 소모품 알림 재전송 관련 메서드 템플릿 맵 초기화
    * 현재는 재전송 버튼 3가지(EX_ConsumableOrderList.cmp) 레이블로 구분
    * @author 23.02.04 / I2MAX.SEUNGHUNAHN
    */
    public static void tmplCodeMapInit(Map<String, String> tmplCodeMap) {
        tmplCodeMap.put('결제URL재전송', 'EX_0003');
        tmplCodeMap.put('가상계좌재전송', 'EX_0004');
        tmplCodeMap.put('SMS재전송', 'EX_0005');
    }

    /**
    * @description 소모품 알림 재전송 전 소모품 임시 Object 저장
    * 소모품 임시 메시지 오브젝트 DML을 위해 callout 메서드와 트랜잭션 분리
    * @author 23.02.04 / I2MAX.SEUNGHUNAHN
    * @return String
    */
    @AuraEnabled
    public static Map<String, Object> doSaveTmpExMessageObj(String jsonString, String resendType) {
        Map<String, Object> returnMap = new Map<String, Object>();

        Map<String, Object> paramMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        ProductRequest pr = [SELECT Id, Order_Number__c, Order_CUST_Id__r.Name, CreatedDate, PAYMENT_Amount__c, POINT_Amount__c, VBANK_NUM__c, ACQUIRE_NAME__c, Payment_URL__c, LIMIT_TM__c, PAYMENT_TYPE__c FROM ProductRequest WHERE Id = :(String) paramMap.get('ParentId')];
        List<ProductRequestLineItem> prLiList = [SELECT Id, PART_DESC_KOR__c, Product2.PART_DESC_KOR__c, fm_ProductName__c FROM ProductRequestLineItem WHERE ParentId = :pr.Id AND RecordType.DeveloperName = 'Consumable'];
        ProductRequestLineItem selectedPrlist = [SELECT Id, PART_DESC_KOR__c, Product2.PART_DESC_KOR__c, fm_ProductName__c, Product2.PART_DESC__c FROM ProductRequestLineItem WHERE Id = :(String) paramMap.get('Id')];

        //일자
        Datetime limitTm = pr.LIMIT_TM__c;
        Integer limitMon = 0;
        Integer limitDay = 0;
        String dayOfWeek = '';
        String dayofWeekKor = '';
        String limitFinal = '';
        String productName = '';
        if (limitTm != null) {
//            limitMon = limitTm.month();
//            limitDay = limitTm.day();
//            dayOfWeek = limitTm.format('E');
//            if (dayOfWeek.equals('Mon')) {
//                dayofWeekKor = '월';
//            } else if (dayOfWeek.equals('Tue')) {
//                dayofWeekKor = '화';
//            } else if (dayOfWeek.equals('Wed')) {
//                dayofWeekKor = '수';
//            } else if (dayOfWeek.equals('Thu')) {
//                dayofWeekKor = '목';
//            } else if (dayOfWeek.equals('Fri')) {
//                dayofWeekKor = '금';
//            } else if (dayOfWeek.equals('Sat')) {
//                dayofWeekKor = '토';
//            } else if (dayOfWeek.equals('Sun')) {
//                dayofWeekKor = '일';
//            }
//            limitFinal = String.valueOf(limitMon) + '월 ' + String.valueOf(limitDay) + '일(' + dayofWeekKor + ')';
            limitFinal = EX_ConsumableUtil.convertDate(limitTm);
        }

        //상품명
        if (selectedPrlist.PART_DESC_KOR__c != null && !selectedPrlist.PART_DESC_KOR__c.equals('')) {
            productName = selectedPrlist.PART_DESC_KOR__c;
        } else if (selectedPrlist.Product2.PART_DESC_KOR__c != null && !selectedPrlist.Product2.PART_DESC_KOR__c.equals('')) {
            productName = selectedPrlist.Product2.PART_DESC_KOR__c;
        } else if (selectedPrlist.fm_ProductName__c != null && !selectedPrlist.fm_ProductName__c.equals('')) {
            productName = selectedPrlist.fm_ProductName__c;
        } else {
            productName = selectedPrlist.Product2.PART_DESC__c;
        }

        //주문 취소 시 선택수량
        Integer selectedCnt = 1;
        if (resendType.equals('주문 취소')) {
            if (paramMap.get('selectedCnt') != null) {
                selectedCnt = Integer.valueOf(paramMap.get('selectedCnt'));
            }
        }

        EX_Message__c etm = new EX_Message__c();
        if (resendType.equals('SMS재전송') && pr.PAYMENT_TYPE__c == 'CASH') {
            etm.Label1__c = pr.Order_CUST_Id__r.Name;
            etm.Label2__c = Math.abs(pr.PAYMENT_Amount__c - pr.POINT_Amount__c).format();
            etm.Label3__c = pr.VBANK_NUM__c + '';
            etm.Label4__c = pr.ACQUIRE_NAME__c + '';
        } else {
            etm.Label1__c = pr.Order_CUST_Id__r.Name;
            etm.Label2__c = pr.Order_Number__c;
            if (resendType.equals('주문 취소')) {
                etm.Label3__c = productName
                        + (selectedCnt > 1 ? ' 외 ' + (selectedCnt - 1 + '') + '건' : '');
            } else {
                etm.Label3__c = productName
                        + (prLiList.size() > 1 ? ' 외 ' + (prLiList.size() - 1 + '') + '건' : '');
            }
            if (resendType.equals('가상계좌재전송')) {
                etm.Label4__c = Math.abs(pr.PAYMENT_Amount__c - pr.POINT_Amount__c).format();
                etm.Label5__c = pr.VBANK_NUM__c + '';
                etm.Label6__c = pr.ACQUIRE_NAME__c + '';
                etm.Label7__c = limitFinal;
            } else if (resendType.equals('결제URL재전송')) {
                etm.Label4__c = Math.abs(pr.PAYMENT_Amount__c - pr.POINT_Amount__c).format();
                etm.Label5__c = limitFinal;
            } else if (resendType.equals('SMS재전송')) {
                etm.Label4__c = Math.abs(pr.PAYMENT_Amount__c - pr.POINT_Amount__c).format();
                etm.Label5__c = limitFinal;
                etm.Label6__c = pr.Payment_URL__c;
            } else if (resendType.equals('주문 취소')) {
                //3번까지만 있음
            }
        }

        /**
         * 결제URL재전송           : paymentUrl
         * 가상계좌재전송, SMS재전송 : virtualAcct
         */
//        etm.Label5__c = resendType.equals('결제URL재전송') ? paymentUrl : virtualAcct;
        insert etm;

        returnMap.put('exObjId', Id.valueOf(etm.Id));

        String templateCode = '';

        if (resendType.equals('가상계좌재전송')) {
            // templateCode = 'SVC_LGE_MACN_012_01';
            templateCode = 'SVC_LGE_MACN_012_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
        } else if (resendType.equals('결제URL재전송')) {
            // templateCode = 'SVC_LGE_MACN_011';
            templateCode = 'SVC_LGE_MACN_011_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
        } else if (resendType.equals('SMS재전송')) {
            if (pr.PAYMENT_TYPE__c != 'CASH') {
                // templateCode = 'SVC_LGE_MACN_S011';
                templateCode = 'SVC_LGE_MACN_S011_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
            } else {
                templateCode = 'SVC_LGE_MACN_S012';
            }
        } else if (resendType.equals('주문 취소')) {
            // templateCode = 'SVC_LGE_MACN_031';
            templateCode = 'SVC_LGE_MACN_031_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
        }

        Map<String, Object> relatedData = EX_MessageUtil.getRelatedData(templateCode, Id.valueOf(etm.Id));
        TemplateMgmt__c template = (TemplateMgmt__c) relatedData.get('template');
        List<TemplateParams__c> templateParamList = (List<TemplateParams__c>) relatedData.get('templateParamList');
        EX_Message__c messageObject = (EX_Message__c) relatedData.get('messageObject');

        Map<String, Object> populateMap = messageObject.getPopulatedFieldsAsMap();

        IF_CM_SFDC_KAKAO.InputParam inputParam = EX_MessageUtil.getInputParamForKaKao(template, templateParamList, populateMap);
        String smsMsg = inputParam.kakaoMsg;

        returnMap.put('receiverMsg', smsMsg);

        system.debug('receiverMsg : ' + smsMsg);

        return returnMap;
    }

    /**
    * @description 반품요청에서의 반품 요청시 원 주문의 원 주문 내역(ProductRequestLineItem) 조회
    * @author 23.02.08 / I2MAX.SEOKHOLEE
    * @return returnMap
    */
    @AuraEnabled
    public static Map<String, Object> doGetOrderLineItemDataByReturnRequest(String orderNumber) {
        return EX_IntegrationOrderManagementController.doGetOrderLineItemDataByReturnRequest(orderNumber);
    }

    /**
     * @description 소모품 반품 요청
     * @author 23.02.09 / I2MAX.SEOKHOLEE
     * @return Map
     *
     */
    @AuraEnabled
    public static Map<String, Object> doRequestReturnOrder(Map<String, Object> paramMap) {
        return EX_IntegrationOrderManagementController.doRequestReturnOrder(paramMap);
    }

    /**
    * @description 계좌검증
    * @author 23.02.15 / I2MAX.SANGHUNYEO
    * @return returnMap
    */
    @AuraEnabled
    public static Map<String, Object> doCheckBankAccount(String bankCode, String bankAccountNo, String receiverName, List<Object> selectedMasterData) {
        System.debug('doCheckBankAccount Start@@');
        return EX_IntegrationOrderManagementController.doCheckBankAccount(bankCode, bankAccountNo, receiverName, selectedMasterData);
    }

    @AuraEnabled
    public static Map<String, Object> doSendKakaoMessage(Map<String, Object> paramMap) {
        EX_ConsumableUtil.ConsumableReturnOrderTable consumableReturnOrderTable = new EX_ConsumableUtil.ConsumableReturnOrderTable();
        List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable> itemTables;
        Map<Object, Object> contactConsigneeInfoMap;

        System.debug(paramMap.get('productRequestLineItemsByReturnRequest'));

        if (paramMap.containsKey('productRequestLineItemsByReturnRequest')) {
            itemTables = (List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable>) JSON.deserialize((String) paramMap.get('productRequestLineItemsByReturnRequest'), List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable>.class);
        }
        System.debug(paramMap.get('contactConsigneeInfo'));
        if (paramMap.containsKey('contactConsigneeInfo')) {
            contactConsigneeInfoMap = (Map<Object, Object>) paramMap.get('contactConsigneeInfo');
        }
        // Kakao Test 송신
        //Map<String, Object> data = new Map<String, Object>();
        Map<String, Object> data = CM_ApiCalloutFormConfig.setInputParam('kakao');
        //returnMap = CM_ApiServiceController.sendKakao('SVC0040', 'WorkOrder', '0WO0p0000002dplGAA', '01051573715', data);


        String retCode = '200';
        String retMessage = '정상적으로 처리되었습니다.';
        Map<String, Object> mapResult = new Map<String, Object>();
        String productName = itemTables[0].PartNameKOR;
        String orderType = paramMap.get('orderType') == 'return' ? '반품' : '취소';
        if (itemTables.size() > 1) {
            productName = itemTables[0].PartNameKOR + ' 외 ' + ((itemTables.size()) - 1) + '건';
        }
        // 메세지 조회
//        Map<String, String> temInfo = CM_TemplateMsgConfig.getTemParam(temCode, objApiName, RecordId);
        String completedMsg = '[주문 ' + orderType + ' 안내]\n' +
                '안녕하세요. LG전자 입니다.\n' +
                (String) contactConsigneeInfoMap.get('ContactName') + ' 고객님 주문하신 상품의 ' + orderType + '주문이 완료되었습니다.\n' +
                '▶ 주문번호 : ' + itemTables[0].OrderNumber + '\n' +
                '▶ 상품명 : ' + productName + '\n' +
                '환불 금액은 카드로 결제하신 경우, 카드사 사정에 따라 영업일 기준 약 1~5일 가량이 소요되며, 가상 계좌로 결제하였을 경우, 입력 계좌로 입금됩니다.\n' +
                '소모품 택배 주문 관련 상담 :\n' +
                '☎ 1544-6351 / 평일 09시~18시\n' +
                '(주말, 공휴일 휴무)';

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
                data.put('templateCode', 'EX_0007');          // 템플릿 코드
                data.put('receiveMobileNo', phoneNo);       // 수신자 번호
                data.put('backupMessage', completedMsg);// 문자 메시지
                // 90바이트 이상인 경우엔 LMS 발송
                if (completedMsg.length() > 90) {
                    data.put('backupProcessCode', '001');
                    data.put('subject', 'temName');
                }
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
    public static List<Map<String, String>> getProliDeliveryNoList(ProductRequestLineItem prli) {
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

                } else if (detail.UPAD_DETAIL_TYPE__c == 'PG_VBANK') {
                    paymentMap.put('pgVBANK', detail.DEPOSIT_AMT__c);

                }
            }
        }


        return paymentMap;
    }
    @AuraEnabled
    public static List<EX_SuppliesController.ItemTable> doGetManagementData(Map<String, Object> paramMap) {
        System.debug('aaaaaaa : ' + paramMap.get('standardOrderData'));
        List<EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable> standardOrderDataList = (List<EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable>) JSON.deserialize((String) paramMap.get('standardOrderData'), List<EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable>.class);
        Set<Id> prlIdSet = new Set<Id>();
        for (EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable cData : standardOrderDataList) {
            prlIdSet.add(cData.Id);
        }
        Map<Id, ProductRequestLineItem> idPrlMap = new Map<Id, ProductRequestLineItem>([
                SELECT Payment_Amount__c, SALE_Amount__c, SALE_Quantity__c, Last_Discount_Amount__c, SALE_Discount_Type_Code__c, Id, ASC_Price__c, ProductItem__r.fm_Computerized_Quantity__c, ParentId
                        , Product2.MODEL_CODE__c, UnitPrice__c, Product2.Id, Product2.Name, ProductItem__r.RESRV_QTY__c, SourceLocation.Id, PROMOTION_Discount_Amount__c, Consumables_Order_Class_Code__c
                FROM ProductRequestLineItem
                WHERE Id IN :prlIdSet
        ]);
        System.debug('idPrlMap :::: ' + idPrlMap);
        List<EX_SuppliesController.ItemTable> stdLiST = new List<EX_SuppliesController.ItemTable>();
        for (EX_ConsumablesOrderManagementController.ConsumableOrderLineItemTable cData : standardOrderDataList) {
            EX_SuppliesController.ItemTable stdData = new EX_SuppliesController.ItemTable();
            stdData.Id = cData.Id;
            // 2024.02.07 seung yoon heo 이미 suppliesOrderInfo쪽에서 해당 field의 값을 금액 - 할인금액의 용도로 사용중이므로 해당 필드의 의미를 바꿔서 return해야함
            stdData.ASCPrice = (Decimal) idPrlMap.get(cData.Id).SALE_Amount__c / idPrlMap.get(cData.Id).SALE_Quantity__c - idPrlMap.get(cData.Id).ASC_Price__c != null ? idPrlMap.get(cData.Id).ASC_Price__c : 0;
            stdData.CardAmount = cData.CashAmount;
            stdData.CashAmount = cData.CardAmount;
            stdData.Computerized_Quantity = (Decimal) (idPrlMap.get(cData.Id).ProductItem__r.fm_Computerized_Quantity__c);
            stdData.DIVCODE = cData.DIV;
            stdData.Model = idPrlMap.get(cData.Id).Product2.MODEL_CODE__c;
            stdData.discountType = cData.DiscountType;
            if (cData.DiscountType == '프로모션') {
                stdData.PromotionPrice = cData.CustomerPrice - (Integer) idPrlMap.get(cData.Id).Last_Discount_Amount__c / cData.SalesQuantity;
            }
            stdData.PointAmount = cData.PointAmount;
            stdData.Price = cData.CustomerPrice;
//            stdData.SalesQuantity = cData.;
            stdData.DiscountAmount = (Integer) idPrlMap.get(cData.Id).Last_Discount_Amount__c;
            //2023.09.18 seung yoon heo ProductCode => Name 으로 변경
            // stdData.ProductCode = idPrlMap.get(cData.Id).Product2.ProductCode;
            stdData.ProductCode = idPrlMap.get(cData.Id).Product2.Name;
            //23.08.30 PHJ
            stdData.ProductName = cData.PartNameKOR != null ? cData.PartNameKOR : cData.PartName;
            // stdData.ProductName = cData.PartNameKOR != null ? (cData.PartNameKOR+'('+cData.PartName+')') : cData.PartName;
            stdData.QTY = cData.SalesQuantity;
            stdData.RESRV_QTY = (Decimal) (idPrlMap.get(cData.Id).ProductItem__r.RESRV_QTY__c);
            stdData.SUBSTITUTE = '원';
            stdData.ShipmentCode = cData.ShippedDepartment;
//            stdData.Total_Quantity=0;
//            stdData.actionDisabled=false;
//            stdData.fm_Available_Quantity=985;
            stdData.sDescription = cData.PartName;
            stdData.sLocationId = (idPrlMap.get(cData.Id)).SourceLocation.Id;
            stdData.sProductId = (idPrlMap.get(cData.Id)).Product2.Id;
            stdData.sProductItemId = (idPrlMap.get(cData.Id)).Id;
            stdData.ParentId = (idPrlMap.get(cData.Id)).ParentId;
            stdData.orderType = (idPrlMap.get(cData.Id)).Consumables_Order_Class_Code__c;
            stdData.orderNumber = cData.orderNumber;
            stdData.OrderStatus = cData.OrderStatus;

            stdList.add(stdData);
        }

        return stdList;
    }
    @AuraEnabled
    public static void fndoUpdate(Map<String, Object> paramMap) {
        List<ConsumableOrderLineItemTable> orderList = (List<ConsumableOrderLineItemTable>) JSON.deserialize((String) paramMap.get('orderDataList'), List<ConsumableOrderLineItemTable>.class);
        String prId = orderList[0].ParentId;
        ProductRequest prData = [
                SELECT Order_Number__c, EMP_NAME__c, EMP_NO__c, EMP_COMPANY_CODE__c,
                        Employees_Company__c, EMP_CEL_NO__c, EMP_RELATION_CODE__c, SALE_DC_TYPE__c, MOID__c, TID__c,
                        PAYMENT_URL__c, VBANK_NUM__c, LIMIT_TM__c, LIMIT_DT__c, PAYMENT_TYPE__c, PAYMENT_REQUEST_DATE__c, PAYMENT_Method_Code__c,
                        PAYMENT_YN__c, PAYMENT_COMPLETED_DTM__c, APPR_NUM__c, APPR_DT__c, ACQUIRE_NAME__c, ACQUIRE_INFO__c, INVOICE_ISSUE_TYPE__c,
                        SALE_Amount__c, Discount_Amount__c, PAYMENT_Amount__c, CARD_PAYMENT_Amount__c, CASH_PAYMENT_Amount__c, POINT_Amount__c,
                        CASH_DEPOSIT_YN__c
                FROM ProductRequest
                WHERE Id = :prId
                LIMIT 1
        ];

        List<ProductRequestLineItem> prlList = [
                SELECT MOID__c, TID__c, Approval_Number__c, SETTLE_METHOD_REF_NO__c,
                        POINT_TRX_ID__c, SALE_Amount__c, Last_Discount_Amount__c, PAYMENT_Amount__c, PARCEL_FEE_Amount__c,
                        VIP_Discount_Amount__c, Employees_Discount_Amount__c,
                        COUPON_Discount_Amount__c, VIRTUAL_ACCT_PAYMENT_Amount__c, CARD_PAYMENT_Amount__c,
                        CASH_PAYMENT_Amount__c, POINT_Amount__c, Consumables_Order_Status__c, Consumables_Order_DETAIL__c
                FROM ProductRequestLineItem
                WHERE Parent.Id = :prId
        ];
        List<ProductRequestLineItem> updatedPrlList = new List<ProductRequestLineItem>();

        Datetime target = Datetime.newInstance(
                Date.today().addDays(1),
                Time.newInstance(23, 59, 0, 0)
        );
        prData.LIMIT_TM__c = target; //
        prData.PAYMENT_REQUEST_DATE__c = System.today(); //

        prData.PAYMENT_YN__c = false;
        prData.APPR_DT__c = System.today();
        prData.SALE_Amount__c = 0;
        prData.PAYMENT_Amount__c = 0;
        prData.CARD_PAYMENT_Amount__c = 0;
        prData.CASH_PAYMENT_Amount__c = 0;
        prData.POINT_Amount__c = 0;
        prData.CASH_DEPOSIT_YN__c = 'C';
        prData.MOID__c = '';
        prData.PAYMENT_URL__c = '';
        prData.VBANK_NUM__c = '';
        prData.ACQUIRE_NAME__c = '';
        prData.ACQUIRE_INFO__c = '';
        prData.TID__c = '';
        Set<String> orderNumbers = new Set<String>();
        orderNumbers.add(prData.Order_Number__c);
        String jsonStr = JSON.serialize(prData);

        EX_SuppliesController.doSetPaymentData(orderNumbers, jsonStr);
        if ([SELECT ID, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c, POINT_TRX_ID__c FROM SR_PRE_PAYMENT_DETAIL__c WHERE SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = :prData.Order_Number__c and PAYMENT_AREA_NO__c = 2].size() != 0) {
            SR_PRE_PAYMENT_DETAIL__c paymentDetail = [SELECT TID__c, ID, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c, POINT_TRX_ID__c, MOID__c FROM SR_PRE_PAYMENT_DETAIL__c WHERE SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = :prData.Order_Number__c and PAYMENT_AREA_NO__c = 2][0];
            // 소모품 결제 Id
            prData.MOID__c = paymentDetail.MOID__c != null ? paymentDetail.MOID__c : '';
            prData.TID__c = paymentDetail.TID__c != null ? paymentDetail.TID__c : '';
        }
        if ([SELECT Id, BASIS_NO__c FROM SR_PRE_PAYMENT_HEADER__c WHERE BASIS_NO__c = :prData.Order_Number__c].size() != 0) {
            SR_PRE_PAYMENT_HEADER__c paymentHeader = [SELECT Id, BASIS_NO__c, SALE_AMT__c FROM SR_PRE_PAYMENT_HEADER__c WHERE BASIS_NO__c = :prData.Order_Number__c][0];
            List<SR_PRE_PAYMENT_DETAIL__c> paymentDetails = [SELECT MOID__c, CARD_URL__c, ISSUE_CARD_INFO__c, ISSUE_CARD_NAME__c, INVOICE_ISSUE_TYPE__c, ID, PAY_CUST_PHONE__c, CERTIFY_KEY__c, DEPOSIT_TYPE__c, DEPOSIT_AMT__c, CreatedDate, UPAD_DETAIL_TYPE__c, MID__c FROM SR_PRE_PAYMENT_DETAIL__c WHERE SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = :prData.Order_Number__c order by PAYMENT_AREA_NO__c];
            SI_SMARTRO_TOTAL_PAYMENT__c totalPay = null;
            if ([SELECT BANK_CODE__c, FN_NAME__c, VBANK_NUM__c FROM SI_SMARTRO_TOTAL_PAYMENT__c WHERE OID__c = :paymentDetails[0].MOID__c and RESULT_CODE__c = '4100'].size() != 0)
                totalPay = [SELECT BANK_CODE__c, FN_CD__c, FN_NAME__c, VBANK_NUM__c FROM SI_SMARTRO_TOTAL_PAYMENT__c WHERE OID__c = :paymentDetails[0].MOID__c and RESULT_CODE__c = '4100'][0];

            if (paymentHeader != null) {
                prData.Payment_URL__c = String.valueOf(paymentDetails[0].CARD_URL__c);
                if (paymentDetails.size() == 1) {
                    if (paymentDetails[0].DEPOSIT_TYPE__c == 'A') {
                        prData.PAYMENT_TYPE__c = 'VBANK';
                        prData.Status = '';

                        prData.INVOICE_ISSUE_TYPE__c = paymentDetails[0].INVOICE_ISSUE_TYPE__c;
                    } else if (paymentDetails[0].DEPOSIT_TYPE__c == 'B') {
                        prData.PAYMENT_Method_Code__c = 'CARD';
                        prData.PAYMENT_TYPE__c = 'CARD';
                        prData.PAYMENT_YN__c = true;
                        prData.PAYMENT_COMPLETED_DTM__c = system.now();
                        prData.APPR_DT__c = system.today();
//                        message.Label1__c = EX_ConsumableUtil.strToCurrencyWon(String.valueOf(paymentDetails[0].DEPOSIT_AMT__c));
                    } else if (paymentDetails[0].DEPOSIT_TYPE__c == 'E') {
                        if ((paymentDetails[0].PAY_CUST_PHONE__c != paymentDetails[0].CERTIFY_KEY__c) && paymentDetails[0].UPAD_DETAIL_TYPE__c != 'PG_URL') {
                            prData.PAYMENT_TYPE__c = 'CASH';
                            prData.CASH_DEPOSIT_YN__c = 'B';

                            prData.INVOICE_ISSUE_TYPE__c = paymentDetails[0].INVOICE_ISSUE_TYPE__c;
                        } else {
                            if (paymentDetails[0].UPAD_DETAIL_TYPE__c == 'PG_URL') {
                                prData.PAYMENT_TYPE__c = 'URL';
                            } else {
                                prData.PAYMENT_TYPE__c = 'VBANK';

                                prData.INVOICE_ISSUE_TYPE__c = paymentDetails[0].INVOICE_ISSUE_TYPE__c;
                            }

                        }
                    } else if (paymentDetails[0].DEPOSIT_TYPE__c == 'D') {
                        prData.PAYMENT_Method_Code__c = 'POINT';
                        prData.POINT_Amount__c = paymentHeader.SALE_AMT__c;
                        prData.PAYMENT_YN__c = true;
                        prData.PAYMENT_COMPLETED_DTM__c = system.now();
                        prData.APPR_DT__c = system.today();
//                        message.Label1__c = EX_ConsumableUtil.strToCurrencyWon(String.valueOf(paymentHeader.SALE_AMT__c));

                    }
                } else {

                    if (paymentDetails[paymentDetails.size() - 1].DEPOSIT_TYPE__c == 'A') {
                        prData.PAYMENT_TYPE__c = 'VBANK';


                        prData.INVOICE_ISSUE_TYPE__c = paymentDetails[paymentDetails.size() - 1].INVOICE_ISSUE_TYPE__c;
                        // 결제 금액
                        //stdConsumableOrder.PAYMENT_Amount__c = stdOrderTotalPaymentAmount;
                    } else if (paymentDetails[paymentDetails.size() - 1].DEPOSIT_TYPE__c == 'B') {
                        prData.PAYMENT_Method_Code__c = 'CARD';
                        prData.PAYMENT_TYPE__c = 'CARD';
                        prData.PAYMENT_YN__c = true;
                        prData.PAYMENT_COMPLETED_DTM__c = system.now();
                        prData.APPR_DT__c = system.today();
//                        message.Label1__c = EX_ConsumableUtil.strToCurrencyWon(String.valueOf(paymentDetails[0].DEPOSIT_AMT__c));

                        // 결제 금액
                        //stdConsumableOrder.PAYMENT_Amount__c = stdOrderTotalPaymentAmount;
                    } else if (paymentDetails[paymentDetails.size() - 1].DEPOSIT_TYPE__c == 'E') {
                        if ((paymentDetails[paymentDetails.size() - 1].PAY_CUST_PHONE__c != paymentDetails[paymentDetails.size() - 1].CERTIFY_KEY__c) && paymentDetails[paymentDetails.size() - 1].UPAD_DETAIL_TYPE__c != 'PG_URL') {
                            prData.PAYMENT_TYPE__c = 'CASH';
                            prData.CASH_DEPOSIT_YN__c = 'B';
                            prData.INVOICE_ISSUE_TYPE__c = paymentDetails[paymentDetails.size() - 1].INVOICE_ISSUE_TYPE__c;
                        } else {
                            if (paymentDetails[paymentDetails.size() - 1].UPAD_DETAIL_TYPE__c == 'PG_URL') {
                                prData.PAYMENT_TYPE__c = 'URL';
                            } else {
                                prData.PAYMENT_TYPE__c = 'VBANK';
                                prData.INVOICE_ISSUE_TYPE__c = paymentDetails[paymentDetails.size() - 1].INVOICE_ISSUE_TYPE__c;
                            }
                        }

                    }
                    prData.POINT_Amount__c = paymentDetails[0].DEPOSIT_AMT__c;
                }


                //0414 결제완료 알림톡발송 오류
//                try {
//                    if (prData.PAYMENT_Method_Code__c == 'POINT' || prData.PAYMENT_TYPE__c == 'CARD') {
////                        EX_PaymentUtil.sendKaKaoMessage('SVC_LGE_MACN_013', message, orderContact.MobilePhone != null ? orderContact.MobilePhone : paymentDetails[0].PAY_CUST_PHONE__c);
//
//
////                        insert message;
//                    }
//                } catch (Exception e) {
//                    System.debug(e);
//                }

                prData.PAYMENT_REQUEST_DATE__c = paymentDetails[0].CreatedDate;
            }
            System.debug('결제 : ' + prData.PAYMENT_TYPE__c);

        } else {
            System.debug('type cancel');
        }


        for (ProductRequestLineItem prlData : prlList) {
            ProductRequestLineItem prl = new ProductRequestLineItem();
            prl.MOID__c = prlData.MOID__c;
            prl.TID__c = prlData.TID__c;
            prl.Approval_Number__c = prlData.Approval_Number__c;
            prl.SETTLE_METHOD_REF_NO__c = prlData.SETTLE_METHOD_REF_NO__c;
            prl.POINT_TRX_ID__c = prlData.POINT_TRX_ID__c;
            prl.SALE_Amount__c = prlData.SALE_Amount__c;
            prl.Last_Discount_Amount__c = prlData.Last_Discount_Amount__c;
            prl.PAYMENT_Amount__c = prlData.PAYMENT_Amount__c;
            prl.PARCEL_FEE_Amount__c = prlData.PARCEL_FEE_Amount__c;
            prl.VIP_Discount_Amount__c = prlData.VIP_Discount_Amount__c;
            prl.Employees_Discount_Amount__c = prlData.Employees_Discount_Amount__c;
            prl.COUPON_Discount_Amount__c = prlData.COUPON_Discount_Amount__c;
            prl.VIRTUAL_ACCT_PAYMENT_Amount__c = prlData.VIRTUAL_ACCT_PAYMENT_Amount__c;
            prl.CARD_PAYMENT_Amount__c = prlData.CARD_PAYMENT_Amount__c;
            prl.POINT_Amount__c = prlData.POINT_Amount__c;
            if (prData.PAYMENT_Method_Code__c == 'POINT' || prData.PAYMENT_TYPE__c == 'CARD') {
                if (prl.Consumables_Order_Status__c == '001') {
                    prl.Consumables_Order_Status__c = '006';
                } else {
                    prl.Consumables_Order_Status__c = '001';
                }
            }


            updatedPrlList.add(prl);
        }
        System.debug('pr update ' + prData);
        System.debug('prl update ' + updatedPrlList);
        update prData;
        update updatedPrlList;
    }
    //결제 요청시 주문고객 정보 전달
    @AuraEnabled
    public static Map<String,Object> fnGetContactInfo(String contactId) {
        Map<String, Object> rerturnMap = new Map<String, Object>();

        Contact currentContact = [
                SELECT
                        AccountId,
                        ADDRESS_DETAIL__c,
                        ADDRESS_NEW__c,
                        ADDRESS_OLD__c,
                        Content__c,
                        CUSTOMER_TYPE__c,
                        Email,
                        FirstName,
                        fm_ADDRESS_NEW__c,
                        fm_ADDRESS_OLD__c,
                        fm_LastName__c,
                        HomePhone,
                        Id,
                        LastName,
                        MobilePhone,
                        Name,
                        Phone,
                        PhotoUrl,
                        POSTAL_CODE__c,
                        THINQ_YN__c,
                        User__c,
                        VIP_CUST_TYPE__c,
                        VIP_END_DT__c,
                        VIP_Start_DT__c,
                        ZIP_ID__c,
                        CUSTOMER_GRADE__c
                FROM Contact
                WHERE id = :contactId
                LIMIT 1
        ];
        //24 02 14 hyungho.chun 주문관리화면 결제요청때도 VIP 할인율 확인
        Decimal percent = null;
        if (currentContact.CUSTOMER_GRADE__c != null) {
            String getDCPercent = [
                    SELECT Id, CLASS_CODE__c, USE_YN__c, ATTRIBUTE3__c
                    FROM   SM_CODE__c
                    WHERE  CLASS_CODE__r.Name = 'CU007'
                    AND    USE_YN__c = 'Y'
                    AND    Name =: currentContact.CUSTOMER_GRADE__c
                ].ATTRIBUTE3__c;
            
            percent = Integer.valueOf(getDCPercent) * 0.01;
        } else {
            percent = 0;
        }

        
        rerturnMap.put('objCon' , currentContact);
        rerturnMap.put('contactVIP' , percent);

        return rerturnMap;
        // return currentContact;
    }
    // 송장번호 모달창을 위해
    @AuraEnabled
    public static List<Map<String, String>> getProliDeliveryNoListwithId(String Id) {
        //23 09 19 운영데이터 history없고 info만 있는경우용 
        List<SR_ONLINE_DELIVERY_INFO__c> dInfos2 = new List<SR_ONLINE_DELIVERY_INFO__c>();
        List<SR_ONLINE_DELIVERY_INFO_HISTORY__c> dInfos = new List<SR_ONLINE_DELIVERY_INFO_HISTORY__c>();
        Map<String, ProductRequestLineItem> prMap = new Map<String, ProductRequestLineItem>();
        System.debug(' 송장번호 모달창을 위해ProductRequestLineItem :: ' + id);
        //23 09 02 hyungho.chun ProductRequestLineItem__r.PART_NO__c,ProductRequestLineItem__r.SALE_Quantity__c 추가
        //23 09 16 hyungho.chun 아래 쿼리 SR_ONLINE_DELIVERY_INFO__c 기준에서 SR_ONLINE_DELIVERY_INFO_HISTORY__c 기준(+DELIVERY_STATUS_CODE__c = '30' 추가) 수정 
        dInfos = [
                SELECT Id, ProductRequestLineItem__c, ReturnOrderLineItem__c, DELIVERY_NO__c, ProductRequestLineItem__r.Order_CHNL_TYPE_Code__c, ReturnOrderLineItem__r.Order_CHNL_TYPE_Code__c, ProductRequestLineItem__r.PART_NO__c,ProductRequestLineItem__r.SALE_Quantity__c,
                        ProductRequestLineItem__r.Order_Number__c, ReturnOrderLineItem__r.Order_Number__c, ProductRequestLineItem__r.Order_SEQ__c, DELIVERY_CODE__c, DELIVERY_QTY__c
                FROM SR_ONLINE_DELIVERY_INFO_HISTORY__c
                WHERE ProductRequestLineItem__c = :id AND DELIVERY_STATUS_CODE__c = '30' 
                ORDER BY CreatedDate DESC
        ];
        if (dInfos.size() == 0) {
            dInfos = [
                    SELECT Id, ProductRequestLineItem__c, ReturnOrderLineItem__c, DELIVERY_NO__c, ProductRequestLineItem__r.Order_CHNL_TYPE_Code__c, ProductRequestLineItem__r.PART_NO__c,ProductRequestLineItem__r.SALE_Quantity__c,
                            ProductRequestLineItem__r.Order_Number__c, ProductRequestLineItem__r.Order_SEQ__c, DELIVERY_CODE__c, ReturnOrderLineItem__r.Order_CHNL_TYPE_Code__c, DELIVERY_QTY__c, ReturnOrderLineItem__r.Parts_Number__c,
                            ReturnOrderLineItem__r.Order_Number__c, ReturnOrderLineItem__r.Order_SEQ__c
                    FROM SR_ONLINE_DELIVERY_INFO_HISTORY__c
                    WHERE ReturnOrderLineItem__c = :id
                    ORDER BY CreatedDate DESC
            ];
        }
        System.debug('dInfos :: ' + dInfos);
        List<Map<String, String>> dMap_list = new List<Map<String, String>>();

        if (!dInfos.isEmpty()) {
            //23.09.23 PHJ
            Integer idx = 0;

            for (SR_ONLINE_DELIVERY_INFO_HISTORY__c dInfo : dInfos) {
                Map<String, String> m1 = new Map<String, String>();
                if (dInfo.ProductRequestLineItem__r.Order_CHNL_TYPE_Code__c == 'V' || dInfo.ReturnOrderLineItem__r.Order_CHNL_TYPE_Code__c == 'V') {
                    m1.put('OrderChannel', '소모품택배');
                } else if (dInfo.ProductRequestLineItem__r.Order_CHNL_TYPE_Code__c == 'B' || dInfo.ReturnOrderLineItem__r.Order_CHNL_TYPE_Code__c == 'B') {
                    m1.put('OrderChannel', 'LGE.COM');
                } else if (dInfo.ProductRequestLineItem__r.Order_CHNL_TYPE_Code__c == 'BestShop' || dInfo.ReturnOrderLineItem__r.Order_CHNL_TYPE_Code__c == 'BestShop') {
                    m1.put('OrderChannel', '베스트샵');
                } 
                //2023.08.16 seung yoon heo Order_CHNL_TYPE_Code__c == 'Y'  >> 소모품샵  추가
                    else if (dInfo.ProductRequestLineItem__r.Order_CHNL_TYPE_Code__c == 'Y' || dInfo.ReturnOrderLineItem__r.Order_CHNL_TYPE_Code__c == 'Y'){
                    m1.put('OrderChannel', '소모품샵');
                    }
                    else if (dInfo.ProductRequestLineItem__r.Order_CHNL_TYPE_Code__c == 'S' || dInfo.ReturnOrderLineItem__r.Order_CHNL_TYPE_Code__c == 'S') {
                        m1.put('OrderChannel', 'ThinQ');
                    }   
                
                //23 10 01 seung yoon heo Order_CHNL_TYPE_Code__c == 'S'  >> ThinQ  추가
                
                
                if (dInfo.ProductRequestLineItem__r.Order_Number__c != null) {
                    m1.put('OrderNumber', dInfo.ProductRequestLineItem__r.Order_Number__c);
                } else {
                    m1.put('OrderNumber', dInfo.ReturnOrderLineItem__r.Order_Number__c);
                }
                if (dInfo.ProductRequestLineItem__r.Order_SEQ__c != null) {
                    m1.put('OrderSeq', String.valueOf(dInfo.ProductRequestLineItem__r.Order_SEQ__c));
                } else {
                    m1.put('OrderSeq', String.valueOf(dInfo.ReturnOrderLineItem__r.Order_SEQ__c));
                }
                m1.put('TrackingNumber', dInfo.DELIVERY_NO__c);
                m1.put('DeliveryCompany', dInfo.DELIVERY_CODE__c);
                m1.put('TrackingNumberURL', 'http://nplus.doortodoor.co.kr/web/detail.jsp?slipno=' + dInfo.DELIVERY_NO__c);
                //23 09 02 hyungho.chun 파트넘버/수량 추가
                //23 10 01 seung yoon heo 반품건일 경우 partNo 추가
                if (dInfo.ProductRequestLineItem__r.PART_NO__c != null) {
                    m1.put('PartNo',dInfo.ProductRequestLineItem__r.PART_NO__c);
                } else { 
                    m1.put('PartNo',dInfo.ReturnOrderLineItem__r.Parts_Number__c);
                }
                // 23 10 01 seung yoon heo SALE_Quantity__c => DELIVERY_QTY__c 로 변경
                // m1.put('SaleQty',String.valueOf(dInfo.ProductRequestLineItem__r.SALE_Quantity__c));
                m1.put('SaleQty',String.valueOf(dInfo.DELIVERY_QTY__c));

                //23.09.23 PHJ
                idx++;		
                m1.put('Index', String.valueOf(idx));
                
                dMap_list.add(m1);

            }
        }else{
            //23 09 19 운영데이터 history없고 info만 있는 경우 용
            //23 09 22 hyungho.chun 쿼리 DIVIDED_QTY__c 추가 (info가 찢어져서올경우 때문에)
            dInfos2 = [
                SELECT Id, ProductRequestLineItem__c, ReturnOrderLineItem__c, DELIVERY_NO__c, ProductRequestLineItem__r.Order_CHNL_TYPE_Code__c, ReturnOrderLineItem__r.Order_CHNL_TYPE_Code__c, ProductRequestLineItem__r.PART_NO__c,ProductRequestLineItem__r.SALE_Quantity__c,
                        ProductRequestLineItem__r.Order_Number__c, ReturnOrderLineItem__r.Order_Number__c, ProductRequestLineItem__r.Order_SEQ__c, DELIVERY_CODE__c, DIVIDED_QTY__c , DELIVERY_QTY__c
                FROM SR_ONLINE_DELIVERY_INFO__c
                WHERE ProductRequestLineItem__c = :id
                ORDER BY CreatedDate DESC
            ];
            if (dInfos2.size() == 0) {
                dInfos2 = [
                        SELECT Id, ProductRequestLineItem__c, ReturnOrderLineItem__c, DELIVERY_NO__c, ProductRequestLineItem__r.Order_CHNL_TYPE_Code__c, ProductRequestLineItem__r.PART_NO__c,ProductRequestLineItem__r.SALE_Quantity__c,
                                ProductRequestLineItem__r.Order_Number__c, ProductRequestLineItem__r.Order_SEQ__c, DELIVERY_CODE__c, ReturnOrderLineItem__r.Order_CHNL_TYPE_Code__c, DIVIDED_QTY__c, DELIVERY_QTY__c ,
                                ReturnOrderLineItem__r.Order_Number__c, ReturnOrderLineItem__r.Order_SEQ__c, ReturnOrderLineItem__r.Parts_Number__c
                        FROM SR_ONLINE_DELIVERY_INFO__c
                        WHERE ReturnOrderLineItem__c = :id
                        ORDER BY CreatedDate DESC
                ];
            }
            System.debug('dInfos2 :: ' + dInfos2);
            if (!dInfos2.isEmpty()) {
                Integer idx = 0;
                for (SR_ONLINE_DELIVERY_INFO__c dInfo : dInfos2) {
                    Map<String, String> m1 = new Map<String, String>();
                    if (dInfo.ProductRequestLineItem__r.Order_CHNL_TYPE_Code__c == 'V' || dInfo.ReturnOrderLineItem__r.Order_CHNL_TYPE_Code__c == 'V') {
                        m1.put('OrderChannel', '소모품택배');
                    } else if (dInfo.ProductRequestLineItem__r.Order_CHNL_TYPE_Code__c == 'B' || dInfo.ReturnOrderLineItem__r.Order_CHNL_TYPE_Code__c == 'B') {
                        m1.put('OrderChannel', 'LGE.COM');
                    } else if (dInfo.ProductRequestLineItem__r.Order_CHNL_TYPE_Code__c == 'BestShop' || dInfo.ReturnOrderLineItem__r.Order_CHNL_TYPE_Code__c == 'BestShop') {
                        m1.put('OrderChannel', '베스트샵');
                    } 
                    //2023.08.16 seung yoon heo Order_CHNL_TYPE_Code__c == 'Y'  >> 소모품샵  추가
                        else if (dInfo.ProductRequestLineItem__r.Order_CHNL_TYPE_Code__c == 'Y' || dInfo.ReturnOrderLineItem__r.Order_CHNL_TYPE_Code__c == 'Y'){
                        m1.put('OrderChannel', '소모품샵');
                    //23 10 01 seung yoon heo Order_CHNL_TYPE_Code__c == 'S'  >> ThinQ  추가
                        }else if (dInfo.ProductRequestLineItem__r.Order_CHNL_TYPE_Code__c == 'S' || dInfo.ReturnOrderLineItem__r.Order_CHNL_TYPE_Code__c == 'S') {
                        m1.put('OrderChannel', 'ThinQ');
                    }   
                    
                    
                    if (dInfo.ProductRequestLineItem__r.Order_Number__c != null) {
                        m1.put('OrderNumber', dInfo.ProductRequestLineItem__r.Order_Number__c);
                    } else {
                        m1.put('OrderNumber', dInfo.ReturnOrderLineItem__r.Order_Number__c);
                    }
                    if (dInfo.ProductRequestLineItem__r.Order_SEQ__c != null) {
                        m1.put('OrderSeq', String.valueOf(dInfo.ProductRequestLineItem__r.Order_SEQ__c));
                    } else {
                        m1.put('OrderSeq', String.valueOf(dInfo.ReturnOrderLineItem__r.Order_SEQ__c));
                    }
                    m1.put('TrackingNumber', dInfo.DELIVERY_NO__c);
                    m1.put('DeliveryCompany', dInfo.DELIVERY_CODE__c);
                    m1.put('TrackingNumberURL', 'http://nplus.doortodoor.co.kr/web/detail.jsp?slipno=' + dInfo.DELIVERY_NO__c);
                    //23 09 02 hyungho.chun 파트넘버/수량 추가
                    //23 10 01 seung yoon heo 반품건일 경우 partNo 추가
                    if (dInfo.ProductRequestLineItem__r.PART_NO__c != null) {
                        m1.put('PartNo',dInfo.ProductRequestLineItem__r.PART_NO__c);
                    } else { 
                        m1.put('PartNo',dInfo.ReturnOrderLineItem__r.Parts_Number__c);
                    }
                    
                    //23 09 22 hyungho.chun 운영 info 데이터 수량 찢어지는경우 대비
                    // m1.put('SaleQty',String.valueOf(dInfo.ProductRequestLineItem__r.SALE_Quantity__c));
                    
                    // 23 10 01 seung yoon heo DIVIDED_QTY__c => DELIVERY_QTY__c 로 변경
                    // m1.put('SaleQty',String.valueOf(dInfo.DIVIDED_QTY__c));
                    m1.put('SaleQty',String.valueOf(dInfo.DELIVERY_QTY__c));
                          //23.09.23 PHJ
                    idx++;		
                    m1.put('Index', String.valueOf(idx));
                    dMap_list.add(m1);
    
                }                
            }
        }

        System.debug('dMap_list :: ' + dMap_list);
        return dMap_list;
    }

    //todo 조건절 체크
    //반품예정수량을 조회하기 위해 productRequestLineItemId를가지고 ReturnOrderLineItem을조회하기
    public static ReturnOrderLineItem getreturnOrderLineItem(ProductRequestLineItem prli) {
        ReturnOrderLineItem roli = new ReturnOrderLineItem();

        String roliQuery = '';
        roliQuery += ' SELECT ID, ProductRequestlineItemId , Expected_Return_Quantity__c, Consumables_Business_Type_Code__c ';
        roliQuery += ' FROM ReturnOrderLineItem ';
        roliQuery += ' WHERE RecordType.DeveloperName IN (\'Consumable\', \'CareSupplies\') ';
        roliQuery += ' AND Consumables_Business_Type_Code__c IN (\'Return\', \'ExchangeReturn\')';
        // 반품요청철회 X
        roliQuery += ' AND Consumables_Order_Status__c != ' + '\'090\'';
        // PO가 아닌 대상
        roliQuery += ' AND Consumables_Order_Class_Code__c != \'PO\'';
        roliQuery += ' ORDER BY CreatedDate ASC  LIMIT 1';

        roli = Database.query(roliQuery);
        return roli;
    }

    // ProductRequestLineItem의 송장번호를 가져오기 위해 SR_DELIVERY_INFO__c 조회
    public static List<Map<String, String>> getDeliveryNoList(List<String> prliIdList, List<String> roliIdList) {
        List<Map<String, String>> dMap_list = new List<Map<String, String>>();
        List<SR_ONLINE_DELIVERY_INFO__c> srODIList = new List<SR_ONLINE_DELIVERY_INFO__c>();
        if (prliIdList != null && !prliIdList.isEmpty()) {
            srODIList = [
                    SELECT Id, ProductRequestLineItem__c, ReturnOrderLineItem__c, DELIVERY_NO__c
                    FROM SR_ONLINE_DELIVERY_INFO__c
                    WHERE ProductRequestLineItem__c IN :prliIdList
            ];
            if (!srODIList.isEmpty()) {
                for (SR_ONLINE_DELIVERY_INFO__c dInfo : srODIList) {
                    Map<String, String> m1 = new Map<String, String>();
                    m1.put(dInfo.ProductRequestLineItem__c, dInfo.DELIVERY_NO__c);
                    dMap_list.add(m1);
                }
            }
        } else if (roliIdList != null && !roliIdList.isEmpty()) {
            srODIList = [
                    SELECT Id, ProductRequestLineItem__c, ReturnOrderLineItem__c, DELIVERY_NO__c
                    FROM SR_ONLINE_DELIVERY_INFO__c
                    WHERE ReturnOrderLineItem__c IN :roliIdList
            ];
            if (!srODIList.isEmpty()) {
                for (SR_ONLINE_DELIVERY_INFO__c dInfo : srODIList) {
                    Map<String, String> m1 = new Map<String, String>();
                    m1.put(dInfo.ReturnOrderLineItem__c, dInfo.DELIVERY_NO__c);
                    dMap_list.add(m1);
                }
            }
        }
        return dMap_list;
    }

    // ProductRequestLineItem의 송장번호를 가져오기 위해 SR_DELIVERY_INFO__c 조회
    public static List<Map<String, String>> getRoliDeliveryNoList(ReturnorderLineItem roli) {
        List<Map<String, String>> dMap_list = new List<Map<String, String>>();
        if (roli.Consumables_Order_Status__c == '030' || roli.Status_Code__c == '070') {
            List<SR_ONLINE_DELIVERY_INFO__c> dInfos = new List<SR_ONLINE_DELIVERY_INFO__c>();
            System.debug('송장번호를 가져올 ReturnorderLineItem :: ' + roli);
            dInfos = [
                    SELECT Id, ProductRequestLineItem__c, ReturnOrderLineItem__c, DELIVERY_NO__c
                    FROM SR_ONLINE_DELIVERY_INFO__c
                    WHERE ReturnOrderLineItem__c = :roli.id
                    ORDER BY CreatedDate DESC
            ];
            System.debug('dInfos :: ' + dInfos);


            if (!dInfos.isEmpty()) {
                if (dInfos.size() > 1) {
                    for (SR_ONLINE_DELIVERY_INFO__c dInfo : dInfos) {
                        Map<String, String> m1 = new Map<String, String>();
                        m1.put(dInfo.ReturnOrderLineItem__c, dInfo.DELIVERY_NO__c);
                        dMap_list.add(m1);
                    }
                } else {
                    Map<String, String> m2 = new Map<String, String>();
                    m2.put(dInfos[0].ReturnOrderLineItem__c, dInfos[0].DELIVERY_NO__c);
                    dMap_list.add(m2);
                }
            }
        }


        return dMap_list;
    }

    /**
      * @description Infinite Loading 가능한지 여부 판단 return
      * @author 23.05.11 / I2MAX.SEUNGHUNAN
      * @param caseId
      * @return Boolean
      */
    @AuraEnabled
    public static Boolean moreLoadValid(Integer dataLength, Integer recordLimit, Integer totalRecord) {
        Integer nextDataLength = dataLength + recordLimit;
        if (nextDataLength <= totalRecord) return true;
        else {
            return (nextDataLength - totalRecord) <= recordLimit;
        }
    }
        //23.07.10 DKBMC 전형호 (명세서 체크박스 결함건)
        @AuraEnabled
    public static Boolean isSpecificationValid(String orderNumber){

        List<ProductRequestLineItem> PRLI = [SELECT Id, ParentId,Consumables_Order_Status__c
                                            FROM ProductRequestLineItem
                                            WHERE Order_Number__c =: orderNumber];

        List<String> returnValue = new List<String>();

        for(ProductRequestLineItem item : PRLI){
            returnValue.add(item.Consumables_Order_Status__c);
        }

        if(returnValue.contains(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_030)||returnValue.contains(EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_070)){
            return true;
        }else{
            return false;
        }
    }

    public class ConsumableOrderTable implements Comparable {
        @AuraEnabled public String Id;
        // 주문 순번
        @AuraEnabled public Integer OrderSEQ;
        // 주문 채널
        @AuraEnabled public String OrderChannel;
        // 주문 번호
        @AuraEnabled public String OrderNumber;
        // 주문 일시
        @AuraEnabled public DateTime OrderDate;
        // 주문 형태
        @AuraEnabled public String OrderType;
        // 업무 유형
        @AuraEnabled public String OrderBusinessType;
        // 결제자
        @AuraEnabled public String CustomerName;
        // 결제자전화번호
        @AuraEnabled public String CustomerPhone;
        //암호화된 결제자 전화번호 ( 화면용 )
        @AuraEnabled public String ENC_CustomerPhone;
        // 받는분
        @AuraEnabled public String CONSIGNEE_Name;
        // 받는분전화번호
        @AuraEnabled public String CONSIGNEE_Phone;
        // 결제방식
        @AuraEnabled public String PaymentMethod;
        // 결제방식 (결제방식formula와 매핑)
        @AuraEnabled public String fm_PaymentMethod;
        // 판매금액
        @AuraEnabled public Decimal SaleAmount;
        // 할인금액
        @AuraEnabled public Decimal DiscountAmount;
        // 결제금액
        @AuraEnabled public Decimal PaymentAmount;
        // 결제유형 Origin
        @AuraEnabled public String PaymentType;
        // 결제여부
        @AuraEnabled public String PaymentYN;
        // MCS
        @AuraEnabled public String MCS;
        // 부서명
        @AuraEnabled public String ConsultantDIV;
        // 상담사사번
        @AuraEnabled public String ConsultantEmployeeNumber;
        // 상담사
        @AuraEnabled public String ConsultantUser;
        // 상담내용
        @AuraEnabled public String CaseDescription;

        // 상담 Case 번호
        @AuraEnabled public String CaseNumber;
        // 상담 Case RecordURL
        @AuraEnabled public String CaseURL;


        // Case Id
        @AuraEnabled public String CaseId;
        // SMPAY 주문번호
        @AuraEnabled public String MOID;
        // 거래번호
        @AuraEnabled public String TID;
        // 승인일자
        @AuraEnabled public Datetime APPR_DT;

        // 23.02.27 주문상태 추가
        // 주문상태
        @AuraEnabled public String OrderStatus;
        // 약속상태
        @AuraEnabled public String AppointmentStatus;

        //결제전송일시 (결제요청일시와 매핑)
        @AuraEnabled public Datetime PaymentRequestDT;

        //2023.09.12 seung yoon heo 결제완료일시 추가
        @AuraEnabled public Datetime PaymentCompletedDT;

        // 23.04.13 contact 추가
        @AuraEnabled public String contactId;
        @AuraEnabled public String contactEmail;
        @AuraEnabled public String contactName;


        // 23.04.27
        @AuraEnabled public String discountType;

        //23.12.01 gw.lee Masking여부 추가
        @AuraEnabled public Boolean isMasking;

        //23 12 01 hyungho.chun PAYMENT_Method_Code__c 추가( 결제URL경우 VBANK인지 CARD인지 확인필요 )
        @AuraEnabled public String PaymentMethodCode;
        //24 01 10 hyungho.chun 가상계좌 채번시 필요
        @AuraEnabled public String VbankNum;

        public Integer compareTo(Object compareTo) {
            ConsumableOrderTable cmp = (ConsumableOrderTable) compareTo;
            return this.OrderDate >= cmp.OrderDate ? -1 : 1;
        }

    }

    public class ConsumableOrderLineItemTable implements Comparable {
        @AuraEnabled public String Id;
        @AuraEnabled public String ParentId;
        // 주문 형태 (주문, 교환, 주문 취소,,)
        @AuraEnabled public String ConsumablesBusinessTypeCode;
        //ProductRequest의 OrderType과 매핑
        @AuraEnabled public String OrderType;
        // 주문 순번
        @AuraEnabled public Integer OrderSEQ;
        // Sub 번호
        @AuraEnabled public String SubNumber;
        // 주문 채널
        @AuraEnabled public String OrderChannel;
        // 주문 일시
        @AuraEnabled public Datetime OrderDate;
        // 주문 번호
        @AuraEnabled public String OrderNumber;
        // 주문 상태
        @AuraEnabled public String OrderStatus;
        // 주문 상태 상세
        @AuraEnabled public String OrderStatusDetail;
        // 송장 번호
        @AuraEnabled public String TrackingNumber;

        // 요청 Part No
        @AuraEnabled public String RequestedPartNo;
        // 입고 Part No
        @AuraEnabled public String ReceivedPartNo;
        // 대치
        @AuraEnabled public String SubstituteYN;
        // 부분 입고
        @AuraEnabled public String PartiallyReceived;
        // 약속 상태
        @AuraEnabled public String AppointmentStatus;
        // 사업부
        @AuraEnabled public String DIV;
        // 한글 품명
        @AuraEnabled public String PartNameKOR;
        // 품명
        @AuraEnabled public String PartName;
        // 모델
        @AuraEnabled public String Model;


        // 출고 부서
        @AuraEnabled public String ShippedDepartment;
        // 소비자가
        @AuraEnabled public Decimal CustomerPrice;
        // 요청수량
        @AuraEnabled public Decimal RequestedQuantity;
        // 판매수량
        @AuraEnabled public Decimal SalesQuantity;
        // 판매금액
        @AuraEnabled public Decimal SaleAmount;
        // 결제금액
        @AuraEnabled public Decimal PaymentAmount;
        // 할인금액
        @AuraEnabled public Decimal DiscountAmount;
        // 할인유형
        @AuraEnabled public String DiscountType;
        // 카드결제
        @AuraEnabled public Decimal CardAmount;
        // 현금결제
        @AuraEnabled public Decimal CashAmount;
        // 포인트결제
        @AuraEnabled public Decimal PointAmount;
        // 결제방식
        @AuraEnabled public String PayMethod;

        // 취소수량
        @AuraEnabled public Decimal CancelQuantity;
        // 취소금액
        @AuraEnabled public Decimal CancelAmount;
        // 반품수량
        @AuraEnabled public Decimal ReturnQuantity;
        // 반품예정수량
        @AuraEnabled public Decimal ExpectedReturnQuantity;
        // 교환수량
        @AuraEnabled public Decimal ExchangeQuantity;


        // 배송 Section
        // 판매번호
        @AuraEnabled public String SalesNumber;
        // CJ 주문번호
        @AuraEnabled public String CJOrderNumber;
        // CJ 주문 전송여부
        @AuraEnabled public String CJOrderSendYN;
        // CJ 주문 전송일시
        @AuraEnabled public Datetime CJOrderSendDate;
        // 배송상태
        @AuraEnabled public String DeliveryStatus;
        // 출하일시
        @AuraEnabled public Datetime ShipmentDate;
        // 배송일시
        @AuraEnabled public Datetime DeliveryDate;
        // 택배사
        @AuraEnabled public String DeliveryCompany;
        // 택배비
        @AuraEnabled public Decimal DeliveryFee;
        // 배송 Section End

        // 취소 Section Start
        // 취소부서명
        @AuraEnabled public String CancelDepartment;
        // 취소자사번
        @AuraEnabled public String CancelRequesterEmployeeNumber;
        // 취소자명
        @AuraEnabled public String CancelRequester;
        // 취소일시
        @AuraEnabled public Datetime CancelRequestedDate;
        // 취소사유
        @AuraEnabled public String CancelRequestReason;
        // 취소 Section End

        // 반품 Section Start
        // 반품부서명
        @AuraEnabled public String ReturnDepartment;
        // 반품요청자사번
        @AuraEnabled public String ReturnRequesterEmployeeNumber;
        // 반품요청자명
        @AuraEnabled public String ReturnRequester;
        // 반품요청일시
        @AuraEnabled public Datetime ReturnRequestedDate;
        // 반품요청사유
        @AuraEnabled public String ReturnRequestReason;
        // 반품요청상태
        @AuraEnabled public String ReturnRequestStatus;
        // 반품승인일시
        @AuraEnabled public Datetime ReturnApprovedDate;
        // 반품승인자
        @AuraEnabled public String ReturnApprover;
        // 반품승인사유
        @AuraEnabled public String ReturnApprovedReason;
        // 부품상태
        @AuraEnabled public String PartStatus;
        // 반품 Section End

        // 교환 Section Start
        // 교환정보
        @AuraEnabled public String ExchangeInformation;
        // 교환대상
        @AuraEnabled public String ExchangeTarget;
        // 교환요청부서
        @AuraEnabled public String ExchangeRequesterDepartment;
        // 교환요청자
        @AuraEnabled public String ExchangeRequester;
        // 교환요청자사번
        @AuraEnabled public String ExchangeRequesterEmployeeNumber;
        // 교환요청일시
        @AuraEnabled public Datetime ExchangeRequestedDate;
        // 교환 Section End

        // 상담 Case 번호
        @AuraEnabled public String CaseNumber;
        @AuraEnabled public String CaseURL;


        // 적치장소 (소모품 / 케어용품 창고)
        @AuraEnabled public String Location;

        // 예약 번호
        @AuraEnabled public String RSRV_Number;

        // Table Cell Color
        @AuraEnabled public String DeliveryColor;
        @AuraEnabled public String CancelColor;
        @AuraEnabled public String ReturnColor;
        @AuraEnabled public String ExchangeColor;


        @AuraEnabled public Datetime PaymentDate;
        @AuraEnabled public String CustomerName;
        @AuraEnabled public String CustomerPhone;
        @AuraEnabled public String CONSIGNEE_Name;
        @AuraEnabled public String CONSIGNEE_Phone;
        @AuraEnabled public Datetime SalesDate;
        @AuraEnabled public Decimal QuantityRequested;
        @AuraEnabled public Decimal EstimatedPaymentAmount;

        @AuraEnabled public Datetime RequestedDate;
        @AuraEnabled public String RequestedUser;

        @AuraEnabled public String MOID;
        @AuraEnabled public String TID;
        @AuraEnabled public String POINT_TRX_ID;

        //결제요청 버튼 활성화여부 체크
        @AuraEnabled public DateTime PaymentRequestDT;

        //2023.09.12 seung yoon heo 결제완료일시 추가
        @AuraEnabled public Datetime PaymentCompletedDT;

        //결제 요청시 할인 필드
        @AuraEnabled public Decimal ContactVIP;
        @AuraEnabled public Decimal PromotionPrice;

        /**
        * @description SubOrderNumber를 정렬하기 위한 Custom Comparator
        * @author 23.01.27 / I2MAX.SEUNGHUNAN
        * @return Integer
        */
        public Integer compareTo(Object compareTo) {
            Integer res = 0;
            ConsumableOrderLineItemTable cmp = (ConsumableOrderLineItemTable) compareTo;
            if ((this.SubNumber == null || cmp.SubNumber == null) ||
                    ((!this.SubNumber.contains('-') || !cmp.SubNumber.contains('-')))) return res;

            String[] baseSubOrderNumbers = this.SubNumber.replace('ㄴ', '').split('-');
            String[] cmpSubOrderNumbers = cmp.SubNumber.replace('ㄴ', '').split('-');

            for (Integer i = 0; i < baseSubOrderNumbers.size(); i++) {
                res = baseSubOrderNumbers[i].compareTo(cmpSubOrderNumbers[i]);
                if (res != 0) return res;
            }
            return res;
        }
    }

    public class CashDepositTable {

        // 주문번호
        @AuraEnabled public String OrderNumber;
        // 주문일시
        @AuraEnabled public DateTime CreatedDate;
        // 주문자명
        @AuraEnabled public String Name;
        // 주문자전화번호
        @AuraEnabled public String ConsigneePhoneNum;
        // 은행명
        @AuraEnabled public String BankName;
        // 가상계좌번호
        @AuraEnabled public String VirtualBankNum;
        // 입금여부
        @AuraEnabled public String DepositStatus;
        // 입금금액
        @AuraEnabled public Integer DepositAmount;
//        @AuraEnabled public String DepositAmount;
        // 입금일자
        @AuraEnabled public DateTime DepositDate;
        // 승인번호
        @AuraEnabled public String ApprovalNumber;
        // 주문접수부서
        @AuraEnabled public String DeptName;
        // 주문접수자명
        @AuraEnabled public String ChiefName;

    }

//    public class OrderListWrapper {
//        @AuraEnabled public String CONSIGNEE_Name;
//        @AuraEnabled public String CONSIGNEE_Phone;
//        @AuraEnabled public String ConsultantDIV;
//        @AuraEnabled public String ConsultantEmployeeNumber;
//        @AuraEnabled public String ConsultantUser;
//        @AuraEnabled public String CustomerName;
//        @AuraEnabled public String CustomerPhone;
//        @AuraEnabled public String Id;
//        @AuraEnabled public String MCS;
//        @AuraEnabled public String OrderChannel;
//        @AuraEnabled public String OrderDate;
//        @AuraEnabled public String OrderNumber;
//        @AuraEnabled public String OrderSEQ;
//        @AuraEnabled public String OrderType;
//        @AuraEnabled public Integer PaymentAmount;
//        @AuraEnabled public String PaymentMethod;
//        @AuraEnabled public String PaymentYN;
//    }

//     public class ResultWrapperTest {
//         @AuraEnabled
//         public Boolean isSuccess { get; set; }        // 성공여부
//         @AuraEnabled
//         public String result { get; set; }            // success/error
//         @AuraEnabled
//         public String errorMsg { get; set; }       // 에러메시지
//         @AuraEnabled
//         public IFUtil.ResponseWrapper responseWrapper { get; set; }    // Response 결과

// //        public ResultWrapperTest() {
// //        }
// //        public ResultWrapperTest(IF_CM_SendMsgKakao.ResultWrapper icsRw) {
// //            this.errorMsg = icsRw.errorMsg;
// //            this.isSuccess = icsRw.isSuccess;
// //            this.responseWrapper = icsRw.responseWrapper;
// //            this.result = icsRw.result;
// //        }
//         public ResultWrapperTest(Boolean isSuccess, String result, String errorMsg, IFUtil.ResponseWrapper responseWrapper) {
//             this.isSuccess = isSuccess;
//             this.result = result;
//             this.errorMsg = errorMsg;
//             this.responseWrapper = responseWrapper;
//         }
//     }

    //23 08 30 hyungho.chun
    @AuraEnabled
    public static Boolean getUserProfile() {
        return EX_PaymentUtil.getUserProfile();
    }

    //23 08 31 hyungho.chun ProductRequest id기준 sr_Sale__c가 있는지 확인 -> PAYMENT_YN__c 체크로 변경
    //23 09 08 hyungho.chun ProductRequest id기준 sr_Sale__c가 있는지 확인 -> PAYMENT_YN__c 체크로 변경
    @AuraEnabled
    public static Boolean checkSrSale(String prId){
        //23 10 17 hyungho.chun 생성자의 프로필 기준 -> PR에 caseid 존재여부로 수정
        List<ProductRequest> prList = [SELECT Id, Order_CHNL_TYPE_Code__c, PAYMENT_YN__c, CreatedBy.Profile.name, CaseId FROM ProductRequest WHERE Id =: prId];
        List<ProductRequestLineItem> prliList = [SELECT Id, SALE_Quantity__c FROM ProductRequestLineItem WHERE parentId =: prList[0].Id];

        
        Decimal sumSaleQty = 0;
        for(ProductRequestLineItem prli : prliList){
            sumSaleQty += prli.SALE_Quantity__c;
        }
        //23 09 08 모든 prli이 반품되었다면 sumSaleQty가 0일 것임

        Boolean returnValue;
        //23 10 10 hyungho.chun 개선사항 컨설턴트가 생성한건 비활성화
        //23 10 17 hyungho.chun 생성자의 프로필 기준 -> PR에 caseid 존재여부로 수정
        // if(prList[0].PAYMENT_YN__c != true || prList[0].Order_CHNL_TYPE_Code__c != 'V' || sumSaleQty == 0 || prList[0].CreatedBy.Profile.name.contains('콜센터')){
        if(prList[0].PAYMENT_YN__c != true || prList[0].Order_CHNL_TYPE_Code__c != 'V' || sumSaleQty == 0 || prList[0].CaseId != null){
            returnValue = false;
        }else{
            returnValue = true;
        }
        return returnValue;
    }

    //23 12 26 hyungho.chun 현금입금대상 프로필기준 Boolean값 리턴
    @AuraEnabled
    public static Boolean isSVC(){

        User currentUser = [
            SELECT Id, Profile.Name
            FROM   User
            WHERE  Id =: userInfo.getUserId()
        ][0];

        System.debug('currentUser.Profile.Name :: '+currentUser.Profile.Name);

        return currentUser.Profile.Name.contains('SVC(HiT, LGE)') ? true : false;
    }


}