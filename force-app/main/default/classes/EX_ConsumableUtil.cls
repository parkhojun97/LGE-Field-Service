/**
 * Created by I2MAX.SEOKHOLEE on 2023-01-26.
 */

 public without sharing class EX_ConsumableUtil {

    /**
     * 소모품 Global Constants
     */
    public static String PR_CONSUMABLE_RECORDTYPE_ID = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
    public static String PR_CARE_SUPPLIES_RECORDTYPE_ID = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
    public static String PR_RESV_RECORDTYPE_ID = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('RESV').getRecordTypeId();
    public static String PR_SALE_RECORDTYPE_ID = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    public static String PR_RESV_SALE_RECORDTYPE_ID = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('RESV_SALE').getRecordTypeId();

    public static String PRLI_CONSUMABLE_RECORDTYPE_ID = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
    public static String PRLI_CARE_SUPPLIES_RECORDTYPE_ID = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
    public static String PRLI_RESV_RECORDTYPE_ID = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('RESV').getRecordTypeId();
    public static String PRLI_SALE_RECORDTYPE_ID = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
    public static String PRLI_RESV_SALE_RECORDTYPE_ID = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('RESV_SALE').getRecordTypeId();


    public static String RO_CONSUMABLE_RECORDTYPE_ID = Schema.SObjectType.ReturnOrder.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
    public static String RO_CARE_SUPPLIES_RECORDTYPE_ID = Schema.SObjectType.ReturnOrder.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
    public static String RO_DISPOSAL_RECORDTYPE_ID = Schema.SObjectType.ReturnOrder.getRecordTypeInfosByDeveloperName().get('DISPOSAL').getRecordTypeId();

    public static String ROLI_CONSUMABLE_RECORDTYPE_ID = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('Consumable').getRecordTypeId();
    public static String ROLI_CARE_SUPPLIES_RECORDTYPE_ID = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('CareSupplies').getRecordTypeId();
    public static String ROLI_DISPOSAL_RECORDTYPE_ID = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('DISPOSAL').getRecordTypeId();

    public static String PH8002 = 'PH8002';
    public static String PH0300 = 'PH0300';
    public static Map<String, Map<String, Object>> workingDaysMap = new Map<String, Map<String, Object>>();
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
     * 소모품 주문 상태
     */
    // 품절예약완료
    public static String CONSUMABLE_ORDER_STATUS_000 = '000';
    // 결제요청
    public static String CONSUMABLE_ORDER_STATUS_001 = '001';
    // 결제완료
    public static String CONSUMABLE_ORDER_STATUS_002 = '002';
    // 결제취소
    public static String CONSUMABLE_ORDER_STATUS_003 = '003';
    // 주문취소
    public static String CONSUMABLE_ORDER_STATUS_004 = '004';
    // 자동주문취소
    public static String CONSUMABLE_ORDER_STATUS_005 = '005';
    // 상품준비중
    public static String CONSUMABLE_ORDER_STATUS_006 = '006';
    // 배송준비중
    public static String CONSUMABLE_ORDER_STATUS_010 = '010';
    // 배송중
    public static String CONSUMABLE_ORDER_STATUS_030 = '030';
    // 배송완료
    public static String CONSUMABLE_ORDER_STATUS_070 = '070';

    // 반품예약
    public static String CONSUMABLE_ORDER_STATUS_101 = '101';
    // 반품대기
    public static String CONSUMABLE_ORDER_STATUS_102 = '102';
    // 반품요청
    public static String CONSUMABLE_ORDER_STATUS_100 = '100';
    // 반품승인
    public static String CONSUMABLE_ORDER_STATUS_110 = '110';
    // 반품반려
    public static String CONSUMABLE_ORDER_STATUS_111 = '111';
    // 반품확정
    public static String CONSUMABLE_ORDER_STATUS_120 = '120';
    // 반품완료
    public static String CONSUMABLE_ORDER_STATUS_121 = '121';
    // 반품요청철회
    public static String CONSUMABLE_ORDER_STATUS_090 = '090';
    // 교환요청
    public static String CONSUMABLE_ORDER_STATUS_130 = '130';
    // 취소요청
    public static String CONSUMABLE_ORDER_STATUS_M001 = '-001';
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
     * 소모품 약속 상태
    */
    // 요청대기
    public static String CONSUMABLE_APPOINTMENT_STATUS_000 = '000';
    // 요청중
    public static String CONSUMABLE_APPOINTMENT_STATUS_001 = '001';
    // 입고완료
    public static String CONSUMABLE_APPOINTMENT_STATUS_002 = '002';
    // 취소
    public static String CONSUMABLE_APPOINTMENT_STATUS_010 = '010';
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
     * 소모품 배송 상태
    */
    // 송장수신
    public static String CONSUMABLE_DELIVERY_STATUS_10 = '10';
    // 집하예정
    public static String CONSUMABLE_DELIVERY_STATUS_27 = '27';
    // 미집하
    public static String CONSUMABLE_DELIVERY_STATUS_29 = '29';
    // 집하
    public static String CONSUMABLE_DELIVERY_STATUS_30 = '30';
    // 배송완료
    public static String CONSUMABLE_DELIVERY_STATUS_70 = '70';
    // 반송
    public static String CONSUMABLE_DELIVERY_STATUS_85 = '85';
    // 취소
    public static String CONSUMABLE_DELIVERY_STATUS_90 = '90';
    // 오류
    public static String CONSUMABLE_DELIVERY_STATUS_99 = '99';
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    // 소모품 배송 코드에 매핑되는 소모품 배송상태 한글 값
    public static Map<Object, String> CONSUMABLE_DELIVERY_STATUS_CODE_KOR_MAP = new Map<Object, String>{
            CONSUMABLE_DELIVERY_STATUS_10 => '송장수신',
            CONSUMABLE_DELIVERY_STATUS_27 => '집하예정',
            CONSUMABLE_DELIVERY_STATUS_29 => '미집하',
            CONSUMABLE_DELIVERY_STATUS_30 => '집하',
            CONSUMABLE_DELIVERY_STATUS_70 => '배송완료',
            CONSUMABLE_DELIVERY_STATUS_85 => '반송',
            CONSUMABLE_DELIVERY_STATUS_90 => '취소',
            CONSUMABLE_DELIVERY_STATUS_99 => '오류'
    };

    // 소모품 주문 코드에 매핑되는 소모품 주문 한글 값
    public static Map<Object, String> CONSUMABLE_STATUS_CODE_KOR_MAP = new Map<Object, String>{
            CONSUMABLE_ORDER_STATUS_000 => '품절예약완료',
            CONSUMABLE_ORDER_STATUS_001 => '결제요청',
            CONSUMABLE_ORDER_STATUS_002 => '결제완료',
            CONSUMABLE_ORDER_STATUS_003 => '결제취소',
            CONSUMABLE_ORDER_STATUS_004 => '주문취소',
            CONSUMABLE_ORDER_STATUS_005 => '자동주문취소',
            CONSUMABLE_ORDER_STATUS_006 => '상품준비중',
            CONSUMABLE_ORDER_STATUS_010 => '배송준비중',
            CONSUMABLE_ORDER_STATUS_030 => '배송중',
            CONSUMABLE_ORDER_STATUS_070 => '배송완료',
            CONSUMABLE_ORDER_STATUS_100 => '반품요청',
            CONSUMABLE_ORDER_STATUS_101 => '반품예약',
            CONSUMABLE_ORDER_STATUS_102 => '반품대기',
            CONSUMABLE_ORDER_STATUS_120 => '반품확정',
            CONSUMABLE_ORDER_STATUS_121 => '반품완료',
            CONSUMABLE_ORDER_STATUS_090 => '반품요청철회',
            CONSUMABLE_ORDER_STATUS_130 => '교환요청'
    };

    // 소모품 주문 한글 값 에 매핑되는 소모품 주문 코드
    public static Map<Object, String> CONSUMABLE_STATUS_KOR_CODE_MAP = new Map<Object, String>{
            '품절예약완료' => CONSUMABLE_ORDER_STATUS_000,
            '결제요청' => CONSUMABLE_ORDER_STATUS_001,
            '결제완료' => CONSUMABLE_ORDER_STATUS_002,
            '결제취소' => CONSUMABLE_ORDER_STATUS_003,
            '주문취소' => CONSUMABLE_ORDER_STATUS_004,
            '자동주문취소' => CONSUMABLE_ORDER_STATUS_005,
            '상품준비중' => CONSUMABLE_ORDER_STATUS_006,
            '배송준비중' => CONSUMABLE_ORDER_STATUS_010,
            '배송중' => CONSUMABLE_ORDER_STATUS_030,
            '배송완료' => CONSUMABLE_ORDER_STATUS_070,
            '반품요청' => CONSUMABLE_ORDER_STATUS_100,
            '반품예약' => CONSUMABLE_ORDER_STATUS_101,
            '반품대기' => CONSUMABLE_ORDER_STATUS_102,
            '반품확정' => CONSUMABLE_ORDER_STATUS_120,
            '반품완료' => CONSUMABLE_ORDER_STATUS_121,
            '반품요청철회' => CONSUMABLE_ORDER_STATUS_090,
            '교환요청' => CONSUMABLE_ORDER_STATUS_130
    };

    // 소모품 주문상태 리스트
    public static List<String> EX_ORDER_STATUS_LIST = new List<String>{
            CONSUMABLE_ORDER_STATUS_000,
            CONSUMABLE_ORDER_STATUS_001,
            CONSUMABLE_ORDER_STATUS_002,
            CONSUMABLE_ORDER_STATUS_003,
            CONSUMABLE_ORDER_STATUS_004,
            CONSUMABLE_ORDER_STATUS_005,
            CONSUMABLE_ORDER_STATUS_006,
            CONSUMABLE_ORDER_STATUS_010,
            CONSUMABLE_ORDER_STATUS_030,
            CONSUMABLE_ORDER_STATUS_070
    };

    // 소모품 반품상태 리스트
    public static List<String> EX_RETURN_ORDER_STATUS_LIST = new List<String>{
            CONSUMABLE_ORDER_STATUS_100,
            CONSUMABLE_ORDER_STATUS_102,
            CONSUMABLE_ORDER_STATUS_101,
            CONSUMABLE_ORDER_STATUS_120,
            CONSUMABLE_ORDER_STATUS_121,
            CONSUMABLE_ORDER_STATUS_090
    };


    // 소모품 주문 채널 CIC택배
    public static String CONSUMABLE_CIC = 'V';
    // 소모품 주문 채널 CIC LABEL
    public static String CONSUMABLE_CIC_LABEL = '소모품택배';

    // 소모품 주문 채널 OBS
    public static String CONSUMABLE_OBS = 'B';
    // 소모품 주문 채널 OBS LABEL
    public static String CONSUMABLE_OBS_LABEL = 'LGE.COM';

    // 소모품 주문 채널 ThinQ
    public static String CONSUMABLE_THINQ = 'S';
    // 소모품 주문 채널 ThinQ LABEL
    public static String CONSUMABLE_THINQ_LABEL = 'ThinQ';

    // 소모품 주문 채널 BestShop
    public static String CONSUMABLE_BESTSHOP = 'BestShop';
    // 소모품 주문 채널 New BEST LABEL
    public static String CONSUMABLE_BESTSHOP_LABEL = '베스트샵';

    //2023.08.16 seung yoon heo Order_CHNL_TYPE_Code__c == 'Y'  >> 소모품샵  추가
    // 소모품 주문 채널 CICSHOP
    public static String CONSUMABLE_CICSHOP = 'Y';
    // 소모품 주문 채널 CICSHOP LABEL
    public static String CONSUMABLE_CICSHOP_LABEL = '소모품샵';

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /**
     * 소모품 반품 요청 상태
    */

    // 요청중
    public static String CONSUMABLE_RETURN_REQUEST_STATUS_N = 'N';
    // 반품확정
    public static String CONSUMABLE_RETURN_REQUEST_STATUS_C = 'C';
    // 반품완료
    public static String CONSUMABLE_RETURN_REQUEST_STATUS_Y = 'Y';
    // 반품반려
    public static String CONSUMABLE_RETURN_REQUEST_STATUS_X = 'X';
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * 소모품 Global Method
    */

    /**
     * @AUTHOR I2MAX.SEOKHOLEE
     * @date  2023-02-11
     * @param consumableStatusCode 소모품 주문 코드
     * @return 소모품 주문 코드에 매핑되는 소모품 주문 한글 값
     */
    public static String returnStatusKORMap(Object consumableStatusCode) {
        return CONSUMABLE_STATUS_CODE_KOR_MAP.containsKey(consumableStatusCode) ? CONSUMABLE_STATUS_CODE_KOR_MAP.get(consumableStatusCode) : null;
    }

    /**
     * @AUTHOR I2MAX.SEOKHOLEE
     * @date  2023-02-11
     * @param consumableStatusCode 소모품 주문 한글 값
     * @return 소모품 주문 한글 값에 매핑되는 소모품 주문 코드 값
     */
    public static String returnStatusCodeMap(String consumableStatusCodeKOR) {
        return CONSUMABLE_STATUS_KOR_CODE_MAP.containsKey(consumableStatusCodeKOR) ? CONSUMABLE_STATUS_KOR_CODE_MAP.get(consumableStatusCodeKOR) : null;
    }

    /**
     * @AUTHOR I2MAX.SEUNGHUNAHN
     * @date  2023-03-16
     * @param String sObjectName sObject 이름
     * @param String orderType 주문 타입(주문, 반품)
     * @return List<Map<String, String>> listPickList 주문관리 화면에 사용될 주문상태 리스트
     */
    public static List<Map<String, String>> getExOrderStatusList(String sObjectName, String orderType) {
        Set<String> allFields = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap().keySet();
        List<Map<String, String>> listPickList = new List<Map<String, String>>();
        DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(sObjectName).getDescribe();
        String exOrderStatusField = 'Consumables_Order_Status__c'.toLowerCase();
        Schema.DescribeFieldResult field = describeResult.fields.getMap().get(exOrderStatusField).getDescribe();
        List<String> orderStatusList = null;

        // 주문상태 필드 없거나 type이 Order, Return 아닐시 빈 리스트 리턴
        if (!allFields.contains(exOrderStatusField)
                || !(orderType.equals('Order')
                || orderType.equals('Return'))) {
            return listPickList;
        }
        orderStatusList = orderType.equals('Order')
                ? EX_ORDER_STATUS_LIST
                : EX_RETURN_ORDER_STATUS_LIST;

        for (Schema.PicklistEntry entry : field.getPicklistValues()) {
            if (orderStatusList.contains(entry.getValue())) {
                listPickList.add(new Map<String, String>{
                        'label' => entry.getLabel(),
                        'value' => entry.getValue()
                });
            }
        }
        return listPickList;
    }


    /**
     * @AUTHOR I2MAX.SEOKHOLEE
     * @date  2023-02-07
     * @param pListMapRequestInfo
     * @description 소모품 반품 요청
     * @return Return Map
     */
    public static Map<String, Object> createReturnRequest(List<Map<String, Object>> pListMapRequestInfo, String channelType, String returnType) {
        System.debug('속도측정 -------------------------------------------------- EX_ConsumableUtil.createReturnRequest (start):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        Map<String, Object> rtnMap = new Map<String, Object>();
        if (channelType == null) channelType = 'V';
        Id consumableCenterId = null;
        if (consumableCenterId == null) {
            consumableCenterId = getConsumableWareHouseId();
        }
        String deptCode ='';
        User cUsr = null;
        cUsr = [
                SELECT DEPT_CODE__c
                        , Name
                        , EmployeeNumber
                        , Id
                FROM User
                WHERE Id = :UserInfo.getUserId()
        ];
        deptCode = cUsr.DEPT_CODE__c;

        // List<ServiceResource> objSR = [
        //         SELECT Id
        //                 , Name, SM_DEPT__c, SM_DEPT__r.DEPT_CODE__c, SM_DEPT__r.DEPT_TYPE_SECOND__c, SM_DEPT__r.HIGH_DEPT_CODE__c, SM_DEPT__r.HIGH_DEPT_CODE__r.DEPT_CODE__c, fm_DEPT_CODE__c
        //         FROM ServiceResource
        //         WHERE RelatedRecordId = :Userinfo.getUserId()
        // ];
        // if (!objSR.isEmpty()) {
        //     // 어떤 코드 사용 하여야 하는지 확인 필요
        //     //        SM_DEPT__r.DEPT_TYPE_SECOND__c,
        //     //        SM_DEPT__r.DEPT_CODE__c,           
        //     //        SM_DEPT__r.HIGH_DEPT_CODE__r.DEPT_CODE__c,
        //     //        SM_DEPT__r.HIGH_DEPT_CODE__r.Name
        //     deptCode = objSR[0].fm_DEPT_CODE__c;
        // } else {
        //     cUsr = [
        //             SELECT Id, DEPT_CODE__c
        //             FROM User
        //             WHERE Id = :UserInfo.getUserId()
        //             LIMIT 1
        //     ];
        //     deptCode = cUsr.DEPT_CODE__c;
        // }
        try {
            EX_ConsumableUtil.ConsumableReturnOrderTable consumableReturnOrderTable;
            ReturnOrder consumableReturnOrder;
            ReturnOrderLineItem consumableReturnOrderLineItem;

            List<ReturnOrderLineItem> requestedReturnOrderItems = new List<ReturnOrderLineItem>();

            // 소모품 주문 생성 전 Return Order 와 Return Order Line Item 매핑 용 임시 ExternalKey Nap
            Map<String, List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable>> tempReturnOrderExternalKeyItemTables = new Map<String, List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable>>();
            Map<String, ReturnOrder> tempKeyReturnOrderMap = new Map<String, ReturnOrder>();
            String externalKey = '';

            // 원 주문 행 항목 Id, 반품 Status Map
            Map<String, String> originLineItemIdStatusMap = new Map<String, String>();
            // 반품 생성 시 원 주문 행 항목의 주문 상세 Update 를 위한 Map
            Map<String, ProductRequestLineItem> updateOriginLineItemMap = new Map<String, ProductRequestLineItem>();
            ProductRequestLineItem updateOriginLineItem;

            List<Contact> contacts = new List<Contact>();

            List<String> contactIdList = new List<String>();
            for (Map<String, Object> mapRequestInfo : pListMapRequestInfo) {
                if (mapRequestInfo.containsKey('consumableReturnOrderTable')) {
                    consumableReturnOrderTable = (EX_ConsumableUtil.ConsumableReturnOrderTable) mapRequestInfo.get('consumableReturnOrderTable');
                    if (consumableReturnOrderTable.ContactId != null) {
                        contactIdList.add(consumableReturnOrderTable.ContactId);
                    }
                }
            }
            List<Contact> totalContactList = new List<Contact>();
            if(!contactIdList.isEmpty()){
                totalContactList = [SELECT Id, AccountId
                                    FROM Contact
                                    WHERE Id IN :contactIdList];
            }
            
            System.debug('속도측정 -------------------------------------------------- EX_ConsumableUtil.createReturnRequest (query totalContactList):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

            if (pListMapRequestInfo != null && !pListMapRequestInfo.isEmpty()) {
                for (Map<String, Object> mapRequestInfo : pListMapRequestInfo) {
                    if (mapRequestInfo.containsKey('consumableReturnOrderTable')) {
                        consumableReturnOrderTable = (EX_ConsumableUtil.ConsumableReturnOrderTable) mapRequestInfo.get('consumableReturnOrderTable');

                        if (consumableReturnOrderTable.ContactId != null) {
                            // contacts = [
                            //         SELECT Id, AccountId
                            //         FROM Contact
                            //         WHERE Id = :consumableReturnOrderTable.ContactId
                            // ];
                            if(!totalContactList.isEmpty()){
                                for(Contact c : totalContactList){
                                    if(c.Id == consumableReturnOrderTable.ContactId){
                                        contacts.add(c);
                                    }
                                }
                            }
                        }

                        consumableReturnOrder = new ReturnOrder();
                        // OBS 반품 주문번호
                        if (channelType == EX_ConsumableUtil.CONSUMABLE_OBS && consumableReturnOrderTable.OBSReturnOrderNumber != null) {
                            //consumableReturnOrder.Request_Number__c = consumableReturnOrderTable.OBSReturnOrderNumber;
                            consumableReturnOrder.OBS_RETURN_Order_Number__c = consumableReturnOrderTable.OBSReturnOrderNumber;
                        }

                        consumableReturnOrder.ReturnedById = UserInfo.getUserId();

                        // 반품 소모품 레코드 타입
                        consumableReturnOrder.RecordTypeId = RO_CONSUMABLE_RECORDTYPE_ID;
                        // 반품 채널 타입
                        consumableReturnOrder.Order_CHNL_TYPE_Code__c = channelType;
                        // 반품 소모품 주문 여부
                        consumableReturnOrder.Consumables_Order_YN__c = true;
                        // 반품 타입 Return(반품) / ExchangeReturn(교환 반품)
                        consumableReturnOrder.Consumables_Business_Type_Code__c = returnType;

                        // 원 주문 번호
                        consumableReturnOrder.Order_Number__c = consumableReturnOrderTable.OriginOrderNumber;
                        // 원 주문 Id
                        consumableReturnOrder.ProductRequestId = consumableReturnOrderTable.OriginOrderId;
                        System.debug('consumableReturnOrderTable.OriginOrderId => ' + consumableReturnOrderTable.OriginOrderId);
                        // 원 주문 고객/결제자 Id
                        consumableReturnOrder.ContactId = consumableReturnOrderTable.ContactId;

                        if (!contacts.isEmpty()) {
                            consumableReturnOrder.AccountId = contacts[0].AccountId;
                        }
                        // 원 주문 고객 이름
                        consumableReturnOrder.Order_CUST_Name__c = consumableReturnOrderTable.CustomerName;
                        // 원 주문 고객 전화번호
                        consumableReturnOrder.Order_CUST_TPNO_1__c = consumableReturnOrderTable.CustomerPhone;
                        // 주문 고객 주소
                        consumableReturnOrder.Order_CUST_Address__c = consumableReturnOrderTable.CustomerAddress;
                        // 주문 고객 주소
                        consumableReturnOrder.Order_CUST_Address_DETAIL__c = consumableReturnOrderTable.CustomerDetailAddress;

                        // TODO : 주문자 우편번호
                        consumableReturnOrder.Order_CUST_PostalCode__c = consumableReturnOrderTable.CustomerPostalCode;


                        // 반품 수취인 이름
                        consumableReturnOrder.CONSIGNEE_Name__c = consumableReturnOrderTable.CONSIGNEE_Name;
                        // 반품 수취인 전화번호
                        consumableReturnOrder.CONSIGNEE_TPNO_1__c = consumableReturnOrderTable.CONSIGNEE_Phone;
                        // 반품 수취인 주소
                        consumableReturnOrder.CONSIGNEE_Address__c = consumableReturnOrderTable.CONSIGNEE_Address;
                        // 반품 수취인 상세 주소
                        consumableReturnOrder.CONSIGNEE_Address_DETAIL__c = consumableReturnOrderTable.CONSIGNEE_DetailAddress == null ? '( )' : consumableReturnOrderTable.CONSIGNEE_DetailAddress;
                        // 반품 배송 메세지
                        consumableReturnOrder.Delivery_Message_CONTENT__c = consumableReturnOrderTable.DeliveryMessageContent;
                        // 반품 요청 일자
                        consumableReturnOrder.Return_Order_Request_DTM__c = (Date) consumableReturnOrderTable.ReturnRequestedDateTime != null ? consumableReturnOrderTable.ReturnRequestedDateTime : Date.today();

                        // TODO : 수추인 우편번호
                        consumableReturnOrder.CONSIGNEE_PostalCode__c = consumableReturnOrderTable.CONSIGNEE_PostalCode;

                        // 23.05.03 // 반품 환불 관련 금액 필드 추가
                        if (consumableReturnOrderTable.ReturnSaleAmount != null) {
                            consumableReturnOrder.RETURN_SALE_Amount__c = consumableReturnOrderTable.ReturnSaleAmount; // 반품판매금액
                        }

                        if (consumableReturnOrderTable.PaymentAmount != null) {
                            consumableReturnOrder.RETURN_PAYMENT_Amount__c = consumableReturnOrderTable.ReturnPaymentAmount; // 반품결제금액
                        }
                        if (consumableReturnOrderTable.ReturnDiscountAmount != null) {
                            consumableReturnOrder.RETURN_Last_Discount_Amount__c = consumableReturnOrderTable.ReturnDiscountAmount; // 반품할인금액
                        }

                        if (consumableReturnOrderTable.ReturnCardPaymentAmount != null) {
                            consumableReturnOrder.RETURN_CARD_PAYMENT_Amount__c = consumableReturnOrderTable.ReturnCardPaymentAmount; // 반품카드결제금액
                        }

                        if (consumableReturnOrderTable.ReturnVBankPaymentAmount != null) {
                            consumableReturnOrder.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c = consumableReturnOrderTable.ReturnVBankPaymentAmount; // 반품가상계좌결제금액
                        }
                        if (consumableReturnOrderTable.ReturnPointAmount != null) {
                            consumableReturnOrder.RETURN_POINT_Amount__c = consumableReturnOrderTable.ReturnPointAmount; // 반품포인트금액
                        }

                        // 임시 External Key 채번
                        externalKey = generateRandomString(6);
                        consumableReturnOrderTable.TempExternalKey = externalKey;
                        tempReturnOrderExternalKeyItemTables.put(externalKey, consumableReturnOrderTable.ConsumableReturnOrderLineItemTables);
                        tempKeyReturnOrderMap.put(externalKey, consumableReturnOrder);

                        for (EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable item : consumableReturnOrderTable.ConsumableReturnOrderLineItemTables) {
                            item.TempExternalKey = externalKey;
                        }
                    }
                }


                insert tempKeyReturnOrderMap.values();
                
                System.debug('속도측정 -------------------------------------------------- EX_ConsumableUtil.createReturnRequest (insert tempKeyReturnOrderMap):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                
                Map<String, String> tempExternalKeyReturnOrderIdMap = new Map<String, String>();
                for (String tempExternalKey : tempKeyReturnOrderMap.keySet()) {
                    tempExternalKeyReturnOrderIdMap.put(tempExternalKey, tempKeyReturnOrderMap.get(tempExternalKey).Id);
                }

                Set<String> productLineItemIdSet = new Set<String>();
                for (String tempExternalKey : tempReturnOrderExternalKeyItemTables.keySet()) {
                    for (EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable item : tempReturnOrderExternalKeyItemTables.get(tempExternalKey)) {
                        productLineItemIdSet.add(item.Id);
                    }
                }
                Map<String, Product2> product2Map = new Map<String, Product2>();
                for (ProductRequestLineItem prli : [SELECT Id, Product2Id, Product2.Name, Product2.DIV_CODE__c, Product2.Id FROM ProductRequestLineItem WHERE Id IN :productLineItemIdSet]) {
                    product2Map.put(prli.Id, prli.Product2);
                }
                System.debug('속도측정 -------------------------------------------------- EX_ConsumableUtil.createReturnRequest (map product2Map):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
                // 서브번호 채번을 위한 컬렉션
                List<SObject> lineItemList = new List<SObject>();
                Set<Id> prLiIdSet = new Set<Id>();
                Map<Id, ProductRequestLineItem> idPrLiMap = new Map<Id, ProductRequestLineItem>();

                for (String tempExternalKey : tempReturnOrderExternalKeyItemTables.keySet()) {
                    for (EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable item : tempReturnOrderExternalKeyItemTables.get(tempExternalKey)) {
                        if (tempExternalKeyReturnOrderIdMap.containsKey(item.TempExternalKey)) {
                            item.ParentId = tempExternalKeyReturnOrderIdMap.get(item.TempExternalKey);

                            consumableReturnOrderLineItem = new ReturnOrderLineItem();
                            // OBS 반품 주문번호
                            if (channelType == EX_ConsumableUtil.CONSUMABLE_OBS && consumableReturnOrderTable.OBSReturnOrderNumber != null) {
                                //consumableReturnOrderLineItem.Request_Number__c = consumableReturnOrderTable.OBSReturnOrderNumber;
                                consumableReturnOrderLineItem.OBS_RETURN_Order_Number__c = consumableReturnOrderTable.OBSReturnOrderNumber;
                                consumableReturnOrderLineItem.Request_Number__c = consumableReturnOrderTable.OBSReturnOrderNumber;
                            }

                            // 반품 소모품 레코드 타입
                            consumableReturnOrderLineItem.RecordTypeId = ROLI_CONSUMABLE_RECORDTYPE_ID;
                            consumableReturnOrderLineItem.ReturnOrderId = item.ParentId;

                            //consumableReturnOrderLineItem.BASIS_Number__c = item.OrderNumber;
                            consumableReturnOrderLineItem.Order_Number__c = item.OrderNumber;
                            if(channelType == 'B') {
                                consumableReturnOrderLineItem.Order_Number__c = consumableReturnOrderTable.OriginOrderNumber;
                            }
                            // 원 주문 항번
                            consumableReturnOrderLineItem.Order_SEQ__c = item.OrderSEQ;
                            // 원 주문 항목 Id
                            consumableReturnOrderLineItem.ProductRequestLineItemId = item.Id;
                            prLiIdSet.add(item.Id);

                            // 소모품 창고
                            consumableReturnOrderLineItem.DestinationLocationId = consumableCenterId;


                            System.debug('ReturnOrder Created Item : ' + item);
                            /**
                              * 4/21 반품 완료여부 체크를 위한 필드 값 추가
                              */
                              //23 08 03 hyungho.chun 교환주문시(returnType == 'ExchangeReturn')에도 ETC_REFUND_Complete_YN__c or POINT_REFUND_Complete_YN__c 미리 추가
                              //23 08 08 returnType == 'ExchangeReturn' 조건 불필요 다시 삭제
                            if(returnType == 'Return' ) {
                                if(item.OrderChannel != null ) {
                                    if (item.OrderChannel.equals('소모품택배')) {
                                        if (item.CashAmount == 0 && item.CardAmount == 0) {
                                            consumableReturnOrderLineItem.ETC_REFUND_Complete_YN__c = 'Y';
                                        } else if (item.PointAmount == 0) {
                                            consumableReturnOrderLineItem.POINT_REFUND_Complete_YN__c = 'Y';
                                        }
                                    }
                                }
                            }

                            if (returnType == 'ExchangeReturn') {
                                consumableReturnOrderLineItem.Exchange_Order_Item_Id__c = null;
                            } else if (returnType == 'Return') {
                                if (item.IsRequestRefund != null) {
                                    if (item.IsRequestRefund) {
                                        // 환불 요청 여부
                                        consumableReturnOrderLineItem.REFUND_Request_YN__c = item.IsRequestRefund;
                                        // 환불 요청 일시
                                        consumableReturnOrderLineItem.REFUND_Request_DTM__c = System.now();
                                        // 환불 요청자 ID
                                        consumableReturnOrderLineItem.REFUND_Requester_Id__c = UserInfo.getUserId();

                                        // 환불 은행 코드
                                        // if (item.RefundBankCode != null) {
                                        //     consumableReturnOrderLineItem.REFUND_BANK_Code__c = item.RefundBankCode;
                                        // }
                                        // 환불 가상 계좌
                                        // if (item.RefundBankAccount != null) {
                                        //     consumableReturnOrderLineItem.REFUND_ACCT_Number__c = item.RefundBankAccount;
                                        // }
                                        // 환불 예끔주 명
                                        // if (item.RefundBankAccountName != null) {
                                        //     consumableReturnOrderLineItem.REFUND_DPSR_Name__c = item.RefundBankAccountName;
                                        // }
                                    }
                                }
                            }

                            // 반품 파트넘버
                            if (product2Map.containsKey(item.Id)) {
                                // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                                // consumableReturnOrderLineItem.Parts_Number__c = product2Map.get(item.Id).ProductCode;
                                consumableReturnOrderLineItem.Parts_Number__c = product2Map.get(item.Id).Name;
                            }
                            // 반품 요청 수량
                            consumableReturnOrderLineItem.QuantityReturned = item.RequestedReturnQuantity;
                            // 반품 예정 수량
                            consumableReturnOrderLineItem.Expected_Return_Quantity__c = item.RequestedReturnQuantity;

                            //consumableReturnOrderLineItem.QuantityReceived;

                            // 반품 금액

                            // 반품 금액

                            // 반품 요청 부서
                            consumableReturnOrderLineItem.Return_Order_Department_Code__c = deptCode;
                            // 반품 요청 일시
                            consumableReturnOrderLineItem.Return_Order_Request_DTM__c = System.now();
                            // 반품 요청자
                            consumableReturnOrderLineItem.Return_Requester_Id_c__c = UserInfo.getUserId();

                            // 원 주문 고객/결제자 Id
                            consumableReturnOrderLineItem.Order_CUST_Id__c = consumableReturnOrderTable.ContactId;

                            // 반품 수취인 정보
                            // consumableReturnOrderLineItem.CONSIGNEE_Name__c = consumableReturnOrderTable.CONSIGNEE_Name;
                            // 반품 수취인 전화번호
                            // consumableReturnOrderLineItem.CONSIGNEE_TPNO__c = consumableReturnOrderTable.CONSIGNEE_Phone;
                            // 반품 수취인 주소
                            // consumableReturnOrderLineItem.CONSIGNEE_Address__c = consumableReturnOrderTable.CONSIGNEE_Address;
                            // 반품 수취인 상세 주소
                            // consumableReturnOrderLineItem.CONSIGNEE_Address_DETAIL__c = consumableReturnOrderTable.CONSIGNEE_DetailAddress;


                            // 환불 계좌번호
                            System.debug('consumableReturnOrderTable.ReturnOrderBankAccountNo -> ' + consumableReturnOrderTable.ReturnOrderBankAccountNo);
                            consumableReturnOrderLineItem.ENC_REFUND_ACCT_Number__c = consumableReturnOrderTable.ReturnOrderBankAccountNo;
                            // 환불 예금주명
                            System.debug('consumableReturnOrderTable.ReturnOrderReceiverName -> ' + consumableReturnOrderTable.ReturnOrderReceiverName);
                            consumableReturnOrderLineItem.REFUND_DPSR_Name__c = consumableReturnOrderTable.ReturnOrderReceiverName;
                            // 환불 은행코드
                            System.debug('consumableReturnOrderTable.ReturnOrderBankCode -> ' + consumableReturnOrderTable.ReturnOrderBankCode);
                            consumableReturnOrderLineItem.REFUND_BANK_Code__c = consumableReturnOrderTable.ReturnOrderBankCode;

                            // 반품 소모품 주문 여부
                            consumableReturnOrderLineItem.Consumables_Order_YN__c = true;
                            // 반품 채널 타입
                            consumableReturnOrderLineItem.Order_CHNL_TYPE_Code__c = channelType;
                            // 반품 타입 Return(반품) / ExchangeReturn(교환 반품)
                            consumableReturnOrderLineItem.Consumables_Business_Type_Code__c = returnType;
                            // 반품 상태 -> 배송완료 의 경우 반품 요청, 배송 중인 경우 반품 예약 상태로 지정

                            if (returnType == 'ExchangeReturn') {
                                consumableReturnOrderLineItem.Consumables_Order_Status__c = returnStatusCodeMap('반품요청');
                            } else {
                                if(channelType == 'V') {
                                    consumableReturnOrderLineItem.Consumables_Order_Status__c = item.OrderStatus != '배송완료' ? returnStatusCodeMap('반품예약') : returnStatusCodeMap('반품요청');
                                } else {
                                    consumableReturnOrderLineItem.Consumables_Order_Status__c = returnStatusCodeMap('반품요청');
                                }
                            }

                            // 반품 사업부 코드
                            if (item.DIV == null && product2Map.containsKey(item.Id)) {
                                consumableReturnOrderLineItem.ENDP_Code__c = product2Map.get(item.Id).DIV_CODE__c;
                            } else {
                                consumableReturnOrderLineItem.ENDP_Code__c = item.DIV;
                            }
                            // 반품 PART NO
                            if (item.ReceivedPartNo == null && product2Map.containsKey(item.Id)) {
                                // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
                                // consumableReturnOrderLineItem.Parts_Number__c = product2Map.get(item.Id).ProductCode;
                                consumableReturnOrderLineItem.Parts_Number__c = product2Map.get(item.Id).Name;
                            } else {
                                consumableReturnOrderLineItem.Parts_Number__c = item.ReceivedPartNo;
                            }
                            if (item.Product2Id == null && product2Map.containsKey(item.Id)) {
                                consumableReturnOrderLineItem.Product2Id = product2Map.get(item.Id).Id;
                            } else {
                                consumableReturnOrderLineItem.Product2Id = item.Product2Id;
                            }

                            if (product2Map.containsKey(item.Id)) {
                                consumableReturnOrderLineItem.BASIS_COLLECT_Parts__c = product2Map.get(item.Id).Id;

                            }

                            // 반품 매핑 모델
                            // 반품 품명
                            //consumableReturnOrderLineItem.Product2.PART_DESC_KOR__c  = item.PartName;
                            // 반품 CJ 주문 번호
                            consumableReturnOrderLineItem.FFMT_Order_Number__c = null;
                            // 반품 송장 번호
                            //consumableReturnOrderLineItem.ProductRequestLineItem.INVOICE_Number__c = item.InvoiceNumber;
                            // 반품 CJ 전송 일시
                            consumableReturnOrderLineItem.FFMT_Transfer_DTM__c = null;
                            // 반품 판매 금액
                            //consumableReturnOrderLineItem.ProductRequestLineItem.SALE_Amount__c = item.SaleAmount;
                            // 반품 연동 여부
                            // 반품 수거 여부
                            consumableReturnOrderLineItem.COLLECTION_YN__c = false;
                            // 반품 확정 여부
                            //consumableReturnOrderLineItem.CONFIRM_YN__c = 'N';
                            // 반품 요청 사유
                            consumableReturnOrderLineItem.Return_Requester_Reason__c = item.ReturnRequestReason;
                            // 결제 일자
                            // consumableReturnOrderLineItem.paym = item.PaymentDate;
                            // 반품 출고 일자 나중에 개발
                            //consumableReturnOrderLineItem.FFMT_Transfer_DTM__c = item.CJSendDate;
                            // 반품 배송 완료 여부 나중에 개발
                            //consumableReturnOrderLineItem.FFMT_Transfer_DTM__c = item.CJSendDate;
                            // 반품 배송 일자 나중에 개발
                            //consumableReturnOrderLineItem.FFMT_Transfer_DTM__c = item.CJSendDate;
                            //  판매 일자
                            // consumableReturnOrderLineItem.sale = item.SalesDate;
                            //  판매 번호
                            // consumableReturnOrderLineItem.FFMT_Transfer_DTM__c = item.SalesNumber;
                            //  판매 항번
                            // consumableReturnOrderLineItem.FFMT_Transfer_DTM__c = item.SalesSeq;
                            //  주문 항번
                            // consumableReturnOrderLineItem.FFMT_Transfer_DTM__c = item.OrderSeq;
                            //  결제 금액
                            // consumableReturnOrderLineItem.FFMT_Transfer_DTM__c = item.PaymentDate;
                            //  결제 유형
                            //consumableReturnOrderLineItem.Consumables_Order_Status_Code__c = item.OrderStatus;
                            //  현금
                            // consumableReturnOrderLineItem.FFMT_Transfer_DTM__c = item.CashAmount;
                            //  카드
                            // consumableReturnOrderLineItem.FFMT_Transfer_DTM__c = item.CardAmount;
                            //  포인트
                            // consumableReturnOrderLineItem.point = item.PointAmount;

                            // 23.05.03 / 반품 환불 관련 금액 필드 추가
                            if (item.SaleAmount != null) {
                                //consumableReturnOrderLineItem.RETURN_SALE_Amount__c = item.ReturnSaleAmount; // 반품판매금액
                                consumableReturnOrderLineItem.RETURN_SALE_Amount__c = item.SaleAmount; // 반품판매금액
                            }
                            if (item.PaymentAmount != null) {
                                //consumableReturnOrderLineItem.RETURN_PAYMENT_Amount__c = item.ReturnPaymentAmount; // 반품결제금액
                                consumableReturnOrderLineItem.RETURN_PAYMENT_Amount__c = item.PaymentAmount; // 반품결제금액
                            }
                            if(item.DiscountAmount != null) {
                                consumableReturnOrderLineItem.RETURN_Last_Discount_Amount__c = item.DiscountAmount; // 반품할인금액
                            }

                            if (item.ReturnCardPaymentAmount != null) {
                                System.Debug('consumableReturnOrderLineItem.RETURN_CARD_PAYMENT_Amount__c -> ' + consumableReturnOrderLineItem.RETURN_CARD_PAYMENT_Amount__c);
                                consumableReturnOrderLineItem.RETURN_CARD_PAYMENT_Amount__c = item.ReturnCardPaymentAmount; // 반품카드결제금액
                            }
                            if (item.ReturnVBankPaymentAmount != null) {
                                consumableReturnOrderLineItem.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c = item.ReturnVBankPaymentAmount; // 반품가상계좌결제금액
                            }
                            if (item.ReturnPointAmount != null) {
                                consumableReturnOrderLineItem.RETURN_POINT_Amount__c = item.ReturnPointAmount; // 반품포인트금액
                            }

                            if (item.CustomerPrice != null) {
                                consumableReturnOrderLineItem.Consumer_Price__c = item.CustomerPrice; // 반품소비자가
                            }

                            consumableReturnOrderLineItem.Return_Order_Approval_DTM__c = System.now(); // 반품승인일시
                            //consumableReturnOrderLineItem.Return_Request_Status__c = 'N'; // "요청중" 상태

                            lineItemList.add(consumableReturnOrderLineItem);
                            requestedReturnOrderItems.add(consumableReturnOrderLineItem);

                            // key : 원 주문 행 항목
                            // value : 반품 항목 Status / 반품요청, 반품예약
                            originLineItemIdStatusMap.put(item.Id, consumableReturnOrderLineItem.Consumables_Order_Status__c);
                        }
                    }
                }

                System.debug('속도측정 -------------------------------------------------- EX_ConsumableUtil.createReturnRequest (job tempReturnOrderExternalKeyItemTables):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

                // lineItem 재쿼리
                List<ProductRequestLineItem> prLiList = [SELECT Id, Order_Number__c, Order_SEQ__c FROM ProductRequestLineItem WHERE Id IN :prLiIdSet];
                for (ProductRequestLineItem prLi : prLiList) {
                    idPrLiMap.put(prLi.Id, prLi);
                }
                for (SObject sObj : lineItemList) {
                    if (String.valueOf(sObj.getSObjectType()).equals('ReturnOrderLineItem')) {
                        ((ReturnOrderLineItem) sObj).ProductRequestLineItem = idPrLiMap.get((Id) sObj.get('ProductRequestLineItemId'));
                    }
                }

                // 23.02.27 서브 번호 채번
                Map<String, Integer> subNumberMap = getSubNumberMap(lineItemList);
                for (ReturnOrderLineItem ro : requestedReturnOrderItems) {
                    System.debug('check : ' + ro.ProductRequestLineItem);
                    ro.SUB_Order_Number__c = getSubNumber(subNumberMap, ro);
                }

                System.debug('consumableReturnOrderLineItem ::: ' + consumableReturnOrderLineItem);
                insert requestedReturnOrderItems;
               
                System.debug('속도측정 -------------------------------------------------- EX_ConsumableUtil.createReturnRequest (insert requestedReturnOrderItems):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
               
                Set<String> targetReturnReqeustMsgIdSet = new Set<String>();
                for (ReturnOrderLineItem roli : requestedReturnOrderItems) {
                    // 소모품택배 && 배송 완료 일 때
                    targetReturnReqeustMsgIdSet.add(roli.Id);
                }

                // 반품 행 항목 생성 이후 원 주문 행 항목의 주문 상태 상세에 반품 상태(반품요청, 반품예약) 업데이트
                for (String originLineItemId : originLineItemIdStatusMap.keySet()) {
                    updateOriginLineItem = new ProductRequestLineItem(
                            Id = originLineItemId,
                            Consumables_Order_DETAIL__c = originLineItemIdStatusMap.get(originLineItemId)
                    );
                    updateOriginLineItemMap.put(originLineItemId, updateOriginLineItem);
                }
                System.debug('updateOriginLineItemMap :::: ' + updateOriginLineItemMap);

                update updateOriginLineItemMap.values();
             
                System.debug('속도측정 -------------------------------------------------- EX_ConsumableUtil.createReturnRequest (update updateOriginLineItemMap):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
             
                if (!targetReturnReqeustMsgIdSet.isEmpty()) {
                    rtnMap.put('MsgIdSet', targetReturnReqeustMsgIdSet);
                }
            }
        } catch (Exception e) {
            System.debug(e.getLineNumber() + 'Line || ' + e.getMessage());
            if(channelType == 'V') {
                throw new AuraHandledException(e.getLineNumber() + 'Line || ' + e.getMessage());
            }
        }
        System.debug(' ====== 반품요청 후 Return Map ======');
        System.debug(rtnMap);
        System.debug(' ====== Return Map ======');
        
        System.debug('속도측정 -------------------------------------------------- EX_ConsumableUtil.createReturnRequest (end):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        
        return rtnMap;
    }

    /**
     * @AUTHOR I2MAX.SANGHUNYEO
     * @date  2023-02-15
     * @param
     * @description 계좌검증
     * @return Return Map
     */
    public static Map<String, Object> checkBankAccountUtil(String bankCode, String bankAccountNo, String receiverName, List<Object> selectedMasterData) {
        Map<String, Object> returnMap = new Map<String, Object>();
        String resultStat = 'SUCCESS';
        String resultMessage = '';

        //마스터 데이터 세팅
        Map<String, Object> selectedMasterMap = new Map<String, Object>();
        if (selectedMasterData.size() > 0) {
            selectedMasterMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(selectedMasterData[0]));
        }

        FN_PaymentModel.T_REQ_BankAccount kRequestModel = new FN_PaymentModel.T_REQ_BankAccount();

        String mid = '';
        String mKey = '';

        //sm_dept 들고오기//
        SM_DEPT__c smDept = [SELECT Id, DEPT_CODE__c FROM SM_DEPT__c WHERE DEPT_CODE__c = :EX_ConsumableUtil.PH8002 LIMIT 1];

        Payment_Gateway__c pg = FN_PaymentAgent.getMidKeyVirtualAccount(smDept.Id);

        //checkBankAccount(paramMap, pg.SIGN_KEY__c, pg.MID__c);

        // if (selectedMasterMap.containsKey('MOID')) {
        //     mid = String.valueOf(selectedMasterMap.get('MOID'));
        // } else {
        //     mid = 'tlgsmp001m';
        // }

        if(pg != null){
            mid = pg.MID__c;
            mKey = pg.SIGN_KEY__c;

            kRequestModel.Mid = mid;
            kRequestModel.merchantKey = mKey;
            kRequestModel.BankCode = bankCode;
            kRequestModel.BankAccount = bankAccountNo;
            kRequestModel.BankAccountName = receiverName;

            System.debug('========== kRequestModel ==========');
            System.debug(kRequestModel);
            System.debug('====================');
            //계좌검증 API 호출
            FN_PaymentModel.T_RES_BankAccount kResponseModel = FN_PaymentAgent.checkBankAccount(kRequestModel);
            if (!'Success'.equalsIgnoreCase(kResponseModel.message)) {
                resultStat = 'FAIL';
                resultMessage = '계좌검증이 실패하였습니다. ' + kResponseModel.message;
                throw new AuraHandledException('계좌검증이 실패하였습니다. ' + kResponseModel.message);
            }

            returnMap.put('resultStat', resultStat);
            returnMap.put('resultMessage', resultMessage);
        }else{
            resultStat = 'FAIL';
            resultMessage = '계좌검증이 실패하였습니다.';
            throw new AuraHandledException('계좌검증이 실패하였습니다. Payment_Gateway__c 데이터 없음');
        }
        return returnMap;
    }

    /**
     * @AUTHOR I2MAX.SANGHUNYEO
     * @date  2023-02-13
     * @param
     * @description 소모품 취소 요청
     * @return Return Map
     */
    public static Map<String, Object> cancelUtil(String strCaseId, String remark, List<Object> selectedRows, List<Object> draftValues, List<Object> selectedMasterData, String bankCode, String bankAccountNo, String receiverName) {
        /*주문취소*/
        Map<String, Object> returnMap = new Map<String, Object>();

        System.debug('selectedRows:' + JSON.serialize(selectedRows));
        System.debug('draftValues:' + JSON.serialize(draftValues));
        System.debug('selectedMasterData:' + JSON.serialize(selectedMasterData));
        User objUser = new User();
        Id recordId = UserInfo.getUserId();

        objUser = [
                SELECT DEPT_CODE__c
                        , Name
                        , EmployeeNumber
                        , Id
                FROM User
                WHERE Id = :recordId
        ];
        System.debug(objUser);
        

        List<Map<String, Object>> selectedList = new List<Map<String, Object>>();
        String resultStat = 'SUCCESS';
        String resultMessage = '';

        Timezone tz = Timezone.getTimeZone('Asia/Korea');
        Datetime dt = Datetime.now();
        Integer hour = dt.hour();

        //주문취소 가능시간 07:00 ~ 21:00
        if ((hour >= 7 && hour < 21) || Test.isRunningTest()) {
            //2024.03.22 seung yoon heo 취소건 id List
            List<String> cancelIdList = new List<String>();
            //마스터 데이터 세팅
            Map<String, Object> selectedMasterMap = new Map<String, Object>();
            if (selectedMasterData != null) {
                if (selectedMasterData.size() > 0) {
                    selectedMasterMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(selectedMasterData[0]));
                }
            }

            //주문채널 : 대표사이트, ThinQ, CIC, New Best, 미지정
            String orderChannel = '';
            if (selectedMasterMap.get('OrderChannel') == null) {
                resultStat = 'FAIL';
                resultMessage = '주문채널 정보가 없습니다. 확인 바랍니다.';
                throw new AuraHandledException('주문채널 정보가 없습니다. 확인 바랍니다.');
            } else {
                orderChannel = getStringNotNull(selectedMasterMap.get('OrderChannel'));
            }

            String divType = getStringNotNull(selectedMasterMap.get('PaymentMethod'));
            String divCode = 'PG카드_URL/가상계좌';

            if (divType == '현장카드') {
                divCode = 'PG카드_내부단말기';
            }
            
            List<String> rsrvNumberList = new List<String>();
            //23 10 10 hyungho.chun 예약주문 채번로직 변경
            Set<String> rsrvOrderId = new Set<String>();

            Payment_Gateway__c pg = [
                SELECT
                        DIV_CODE__c,
                        MID__c,
                        Name,
                        SIGN_KEY__c,
                        SM_DEPT__c
                FROM Payment_Gateway__c
                WHERE SM_DEPT__c IN (SELECT Id FROM SM_DEPT__c Where DEPT_CODE__c = 'PH8002') AND DIV_CODE__c = :divCode
                limit 1
        ];
        system.debug('pg : '+pg);

            //취소 데이터
            for (Object selectedInfo : selectedRows) {
                Map<String, Object> selectedMap = new Map<String, Object>();
                selectedMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(selectedInfo));
                System.debug('selectedMap:' + selectedMap);
                selectedMap.put('CancelQuantity', selectedMap.get('QuantityRequested')); //취소수량 = 전량(주문수량)
                //취소 수량, 취소 사유
                System.debug('취소대상 주문번호 : ' + selectedMap.get('OrderNumber'));
                System.debug('취소대상 데이터 : ' + selectedMap.values());
                //2023.07.15 gw.lee
                //미사용 로직 수정
                // if (draftValues != null) {
                //     for (Object draftInfo : draftValues) {
                //         Map<String, Object> draftMap = new Map<String, Object>();
                //         draftMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(draftInfo));
                //         if (selectedMap.get('Id').equals(draftMap.get('Id'))) {
                //             //selectedMap.put('CancelQuantity', draftMap.get('CancelQuantity')); //취소수량
                //             selectedMap.put('CancelRequestReason', draftMap.get('CancelRequestReason')); //취소사유
                //             Integer cancelReasonLength = getStringNotNull(draftMap.get('CancelRequestReason')).length();
                //             if (cancelReasonLength > 1000) {
                //                 throw new AuraHandledException('취소사유 최대 입력 글자 수 : 1000. 현재 : ' + cancelReasonLength);
                //             }
                //         }
                //     }
                // }
                selectedMap.put('CancelRequestReason', selectedMap.get('CancelRequestReason')); //취소사유
                Integer cancelReasonLength = getStringNotNull(selectedMap.get('CancelRequestReason')).length();
                if (cancelReasonLength > 1000) {
                    throw new AuraHandledException('취소사유 최대 입력 글자 수 : 1000. 현재 : ' + cancelReasonLength);
                }
                
                //23 10 10 hyungho.chun 예약주문 채번로직 변경
                // if (String.isNotEmpty(getStringNotNull(selectedMap.get('RSRV_Number')))) {
                //     rsrvNumberList.add(getStringNotNull(selectedMap.get('RSRV_Number')));
                // }
                
                //23 10 10 hyungho.chun 예약주문 채번로직 변경
                if (String.isNotEmpty(getStringNotNull(selectedMap.get('RSRV_Number')))) {
                    rsrvOrderId.add(getStringNotNull(selectedMap.get('Id')));
                }
                cancelIdList.add(getStringNotNull(selectedMap.get('Id')));
                selectedList.add(selectedMap);
            }
            
            //23 10 10 hyungho.chun 
            Map<String, Integer> rsrvMap = new Map<String, Integer>();
            System.debug('rsrvOrderId :: '+rsrvOrderId);
            if(rsrvOrderId.size() > 0){
                List<ProductRequestLineItem> tempPrliList = [SELECT SR_RESRV_PART_Id__r.RESRV_Number__c FROM ProductRequestLineItem WHERE Id IN: rsrvOrderId];

                for(ProductRequestLineItem item : tempPrliList){
                    rsrvNumberList.add(item.SR_RESRV_PART_Id__r.RESRV_Number__c);
                }

                List<ProductRequestLineItem> rsrvList = [SELECT RSRV_Number__c,PART_NO__c, QuantityRequested FROM ProductRequestLineItem WHERE RecordType.Name = '판매예약' AND RSRV_NUMBER__c IN :rsrvNumberList];
                System.debug('rsrvList :: '+rsrvList);
                for (ProductRequestLineItem pObj : rsrvList) {
                    // rsrvMap.put(pObj.RSRV_Number__c, Integer.valueOf(pObj.QuantityRequested));
                    rsrvMap.put(pObj.RSRV_Number__c+'_'+pObj.PART_NO__c, Integer.valueOf(pObj.QuantityRequested)); //24 03 15 hyungho.chun 예약채번 주문단위라서 lineItem key에 부품번호추가
                }
                System.debug('rsrvMap :: '+rsrvMap);
            }

            // 2024.03.22 seung yoon heo 결제 취소시 history확인해서 이전에 취소이력이 있으면 해당건 수불제외 로직
            List<ProductRequestLineItemHistory> checkStatus = [SELECT OldValue,ProductRequestLineItemId FROM ProductRequestLineItemHistory WHERE ProductRequestLineItemId=:cancelIdList
                                                   AND Field ='Consumables_Order_Status__c' ORDER BY CreatedDate DESC];

            Map<String, String> historyCancelMap = new Map<String, String>();
            for(ProductRequestLineItemHistory check : checkStatus){
               if(check.OldValue == '003' || check.OldValue == '004' || check.OldValue == '005' ){
                    historyCancelMap.put(check.ProductRequestLineItemId ,String.valueOf(check.OldValue));
               }
            }

            //23 10 10 hyungho.chun 채번로직변경
            // List<ProductRequestLineItem> rsrvList = [SELECT RSRV_Number__c, QuantityRequested FROM ProductRequestLineItem WHERE RecordType.Name = '판매예약' AND RSRV_NUMBER__c IN :rsrvNumberList];
            // Map<String, Integer> rsrvMap = new Map<String, Integer>();
            // for (ProductRequestLineItem pObj : rsrvList) {
            //     rsrvMap.put(pObj.RSRV_Number__c, Integer.valueOf(pObj.QuantityRequested));
            // }
            //23 10 20 hyungho.chun 더이상 포인트 환불 때 인터페이스타지않고 주문넣을떄 detail에 넣어준 MBS_CUST_ID__c 에서 받아서 쓴다
            List<SR_PRE_PAYMENT_DETAIL__c> detailList = [SELECT PAY_CUST_NAME__c, PAY_CUST_PHONE__c, DEPOSIT_TYPE__c, MBS_CUST_ID__c FROM SR_PRE_PAYMENT_DETAIL__c 
            WHERE SR_PRE_PAYMENT_HEADER_ID__r.BASIS_NO__c = :String.valueOf(selectedMasterMap.get('OrderNumber')) AND DEPOSIT_TYPE__c = 'D' 
            ORDER BY PAYMENT_AREA_NO__c];
            String mbs_cust_id = '';
            if(detailList.size() != 0){
                FN_PaymentModel.T_RES_CheckPoint_Item getMembership = new FN_PaymentModel.T_RES_CheckPoint_Item();
                if (selectedMasterMap.get('OrderType') == '일반주문') {
                    if (detailList[0].DEPOSIT_TYPE__c == 'D') {
                        if (!Test.isRunningTest()) {
                            // getMembership = FN_PaymentAgent.requestRetrievePoint(detailList[0].PAY_CUST_NAME__c, detailList[0].PAY_CUST_PHONE__c); //MBS_CUST_ID 가져오기
                            // System.debug('getMembership :: '+getMembership);
                            // System.debug('mbs_cust_id :: '+getMembership.MBS_CUST_ID);
                            //23 10 20 hyungho.chun 더이상 포인트 환불 때 인터페이스타지않고 주문넣을떄 detail에 넣어준 MBS_CUST_ID__c 에서 받아서 쓴다
                            // mbs_cust_id = getMembership.MBS_CUST_ID;
                            mbs_cust_id = (detailList[0].MBS_CUST_ID__c != null && detailList[0].MBS_CUST_ID__c != '') ? detailList[0].MBS_CUST_ID__c : '';
                        } else {
                            mbs_cust_id = '1000294683';
                        }
                    }
                }
            }


            System.debug('selectedList:' + selectedList);

            if (orderChannel.equals('소모품택배')) {
                for (Map<String, Object> selectedMap : selectedList) {

                    /** 포인트복원 : 공통API 확인 */
                    Integer pointAmt = 0;
                    if (selectedMap.get('PointAmount') != null) {
                        pointAmt = Double.valueOf(selectedMap.get('PointAmount')).intValue();
                    }
                    System.debug('PointAmount:' + pointAmt);
                    if (pointAmt > 0) {
                        Integer QuantityRequested = 0; //주문수량
                        if (selectedMap.get('QuantityRequested') != null) {
                            QuantityRequested = Integer.valueOf(selectedMap.get('QuantityRequested'));
                        }
                        Integer CancelQuantity = 0; //취소수량
                        if (selectedMap.get('CancelQuantity') != null) {
                            CancelQuantity = Integer.valueOf(selectedMap.get('CancelQuantity')); //취소수량
                        }

                        //20230208 포인트결제가 있는경우, 전량취소만 가능함.
                        /*if(QuantityRequested != CancelQuantity){
                            //주문수량과 취소수량이 다를경우, 취소수량만큼의 포인트 금액을 복원 ((포인트금액/주문수량)*취소수량))
                            pointAmt = Math.round(pointAmt / QuantityRequested) * CancelQuantity;
                        }*/

                        Map<String, Object> pointCancelLData = new Map<String, Object>();
                        //pointCancelLData.put('cardNo', settleMethodRefNo); //포인트카드번호(마스터 추가 예정)
                        pointCancelLData.put('mlgAmount', pointAmt);
                        /**
                         * (SAVE : 적립, SAVE_CNCL : 적립 취소, USED : 사용, USED_CNCL : 사용 취소)
                         */
                        pointCancelLData.put('saveType', 'USED_CNCL');
                        /** CSONE : 서비스 시스템 RMS:렌탈시스템 */
                        pointCancelLData.put('sourceSystem', 'CSONE');
                        pointCancelLData.put('billToCode', 'PH8002');
                        pointCancelLData.put('billToName', '소모품센터');
                        pointCancelLData.put('comments', 'SMILE-Membership Point 취소');
                        //pointCancelLData.put('cancelId', pointTrxId); // 포인트금액trx아이디(마스터 추가 예정)

                        /** 포인트 복원 API 호출 */
                        /*LData ldataResult = new LData();
                        ldataResult = bestWsBiz.callInsertSaveMileageBEST(pointCancelLData);

                        outparamCancelId = ldataResult.getString("id");
                        if ("".equals(outparamCancelId)) {
                            throw new SmileException(this.getClass().getName(), "포인트 복원에 실패하였습니다. 관리자에게 문의하세요.");
                        }*/

                        /** BEST POINT 적자 ID 업데이트 */
                        //API로부터 받아온 ID를 Update 한다.
                    }
                }
            }

            /** 취소작업 */
            List<Map<String, Object>> rsrvCancelMapList = new List<Map<String, Object>>();
            List<String> selectedIdList = new List<String>();
            for (Map<String, Object> selectedMap : selectedList) {
                selectedIdList.add(String.valueOf(selectedMap.get('Id')));
            }
            List<ProductRequestLineItem> prliListTotal = new List<ProductRequestLineItem>();
            List<ProductRequestLineItem> prliListSaleTotal = new List<ProductRequestLineItem>();
            Map<String, ProductRequestLineItem> prliSaleMap = new Map<String, ProductRequestLineItem>();            
            if (!selectedIdList.isEmpty()) {
                String query = '';
                query += 'SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
                query += ' ,Product2.Name, Product2.PART_DESC_KOR__c, SR_RESRV_PART_Id__r.RESRV_Number__c ';
                query += '  FROM ProductRequestLineItem';
                query += ' WHERE Id IN :selectedIdList ';
                prliListTotal = Database.query(query);
            }
            List<ProductRequestLineItem> updatePrliList = new List<ProductRequestLineItem>();
            List<ProductRequestLineItem> execABList = new List<ProductRequestLineItem>(); // alloc_qty 수불용
            //23 12 21 hyungho.chun execAEList는 일반예약/품절주문건 RESRV_QTY__c 수불용
            List<ProductRequestLineItem> execAEList = new List<ProductRequestLineItem>();
            Set<String> rsrvList = new Set<String>(); //예약번호 List
            Map<String, SI_REQUEST__c> divRequestMap = new Map<String, SI_REQUEST__c>(); //사업부 요청 List
            //23 12 21 hyungho.chun
            // List<SI_REQUEST__c> divUpdateList = new List<SI_REQUEST__c>();
            
            //gw.lee 2023.10.13 사업부 입고 예정건 확인 필요
            if (prliListTotal.size() > 0) {
                for (ProductRequestLineItem prli : prliListTotal) {
                    if (String.isNotEmpty(prli.SR_RESRV_PART_Id__r.RESRV_Number__c)) {
                        rsrvList.add(prli.SR_RESRV_PART_Id__r.RESRV_Number__c);
                    }
                }
    
                //사업부 미요청건에 대한것만 추출
                List<SI_REQUEST__c> divRequestList = [SELECT ID, TRANS_FLAG__c, RESV_NO__c FROM SI_REQUEST__c WHERE RESV_NO__c = :rsrvList AND TRANS_FLAG__c = 'N'];
                for (SI_REQUEST__c siObj : divRequestList) {
                    divRequestMap.put(siObj.RESV_NO__c, siObj);
                }

                String query = '';
                query += 'SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
                query += ' ,Product2.Name, Product2.PART_DESC_KOR__c, SR_RESRV_PART_Id__r.RESRV_Number__c ';
                query += '  FROM ProductRequestLineItem';
                query += ' WHERE SR_RESRV_PART_Id__r.RESRV_Number__c = :rsrvList ';
                query += ' AND RecordType.DeveloperName	= \'RESV_SALE\'';
                prliListSaleTotal = Database.query(query);

                if (prliListSaleTotal.size() > 0) {
                    for (ProductRequestLineItem prliSale : prliListSaleTotal) {
                        //23.10.19 gw.lee
                        //주문 예약번호 + 항번 추가 조치
                        prliSaleMap.put(prliSale.SR_RESRV_PART_Id__r.RESRV_Number__c + '_' + prliSale.RSRV_SEQ__c, prliSale);
                    }
                }
            }


            for (Map<String, Object> selectedMap : selectedList) {
                Map<String, Object> rsrvCancelMap = new Map<String, Object>();
                Integer QuantityRequested = 0; //주문수량
                if (selectedMap.get('QuantityRequested') != null) {
                    QuantityRequested = Integer.valueOf(selectedMap.get('QuantityRequested')); //주문수량
                }
                Integer CancelQuantity = 0; //취소수량
                if (selectedMap.get('CancelQuantity') != null) {
                    system.debug('초기 취소 수량  : ' + selectedMap.get('CancelQuantity'));
                    CancelQuantity = Integer.valueOf(selectedMap.get('CancelQuantity')); //취소수량
                }
                //Integer cardAmt = Integer.valueOf(selectedMap.get('CardAmount'));
                Integer cardAmt = 0;
                if (selectedMap.get('CardAmount') != null) {
                    cardAmt = Double.valueOf(selectedMap.get('CardAmount')).intValue();
                }
                //무조건 전량취소로 변경
                /*if(QuantityRequested != CancelQuantity){
                    //주문수량과 취소수량이 다를경우, 취소수량만큼의 금액을 복원 ((카드금액/주문수량)*취소수량))
                    cardAmt = Math.round(cardAmt / QuantityRequested) * CancelQuantity;
                }*/
                String saleDcType = ''; //SALE_Discount_Type_Code__c 판매할인유형 (DiscountType 그냥할인유형 아님) 아직 미개발
                if (selectedMap.get('DiscountType') != null) {
                    saleDcType = String.valueOf(selectedMap.get('DiscountType')); //SALE_Discount_Type_Code__c 판매할인유형 (DiscountType 그냥할인유형 아님) 아직 미개발
                }
                Integer paymentAmt = 0;
                if (selectedMap.get('PaymentAmount') != null) {
                    paymentAmt = Double.valueOf(selectedMap.get('PaymentAmount')).intValue();
                }
                //if (cancelAmt > 0 || (cancelAmt == 0 && "V".equals(saleDcType) && totalAmt == 0)) {
                //취소금액(Smile의 appr_amt(승인금액)의 합) => SFDC 카드결제금액 사용]이 있거나, VIP100%할인(결제금액0, 취소금액0) 일 경우
                //if(cardAmt > 0 || (cardAmt == 0 && saleDcType.equals('V') && paymentAmt == 0)){
                FN_PaymentModel.T_RES_CancelPayment kResponseModel = new FN_PaymentModel.T_RES_CancelPayment();


                //PTID : kResponseModel.pTid
                /*
                if ((!"".equals(smileCancelMData.getLData(i).getString("resrvNo")) && smileCancelMData.getLData(i).getString("resrvNo") != null)) {

                    smileCancelMData.addString("updateResrvCancel", "Y");

                    if ("".equals(smileCancelMData.getLData(i).getString("saleNo")) || smileCancelMData.getLData(i).getString("saleNo") == null) {
                        rtnLMData = cDao.executeQuery("/inv/pr/retrieve/partResrv/retrieveResrvMngList", smileCancelMData.getLData(i), "ets_app"); //약속관리조회
                        resrvStat = setResrvStat(rtnLMData, plData);
                        partResrvBiz.cudResrvCancel(plData, resrvStat);
                    }
                } else {
                    if ("".equals(smileCancelMData.getLData(i).getString("saleNo")) || smileCancelMData.getLData(i).getString("saleNo") == null) {
                        resultCnt = cDao.executeUpdate("/inv/ps/cud/sm_stock/updateStockAllocQty", smileCancelMData.getLData(i), "ets_app");
                    }
                }
                 */
                //예약번호
                String RSRV_Number = '';
                if (selectedMap.get('RSRV_Number') != null) {
                    RSRV_Number = String.valueOf(selectedMap.get('RSRV_Number'));
                }
                //판매번호
                String SalesNumber = '';
                if (selectedMap.get('SalesNumber') != null) {
                    SalesNumber = String.valueOf(selectedMap.get('SalesNumber'));
                }
                System.debug('RSRV_Number : ' + RSRV_Number);
                System.debug('orderChannel : ' + orderChannel);
                //if (RSRV_Number != null && !RSRV_Number.equals('') && orderChannel.equals('소모품택배')) { //예약번호 있음 & CIC
                //20230515 ysh 소모품택배 조건 삭제
                if (RSRV_Number != null && !RSRV_Number.equals('')) { //예약번호 있음
                    /** 예약취소 관련 API 호출부분 */
                    /** 모두입고 여부 */
                    // String strQ = '';
                    // strQ += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
                    // strQ += ' ,Product2.Name, Product2.PART_DESC_KOR__c ';
                    // strQ += ' FROM ProductRequestLineItem ';
                    // strQ += ' WHERE Id = \'' + selectedMap.get('Id') + '\' ';
                    // System.debug('strQ : ' + strQ);
                    // List<ProductRequestLineItem> prliList = Database.query(strQ);
                    List<ProductRequestLineItem> prliList = new List<ProductRequestLineItem>();
                    if (!prliListTotal.isEmpty()) {
                        for (ProductRequestLineItem pp : prliListTotal) {
                            if (pp.Id == String.valueOf(selectedMap.get('Id'))) {
                                prliList.add(pp);
                            }
                        }
                    }

                    Map<String, SI_REQUEST__c> siMap = new Map<String, SI_REQUEST__c>();

                    for (ProductRequestLineItem prli : prliList) {
                         //예약건 중 미입고 처리로 남아있는건 Update 조치 필요
                         System.debug('prli.SR_RESRV_PART_Id__r.RESRV_Number__c) :::: ' + prli.SR_RESRV_PART_Id__r.RESRV_Number__c);
                         if (divRequestMap.containsKey(prli.SR_RESRV_PART_Id__r.RESRV_Number__c)) {


                            // 23 12 21 hyungho.chun 더이상 SI_REQUEST__c는 소모품에서 업데이트하지않는다 -> 대신 취소건은 전부 si_pocancel를 생성해야한다 ex_rsrvutil에서 해당로직추가예정
                            // SI_REQUEST__c updateObj = divRequestMap.get(prli.SR_RESRV_PART_Id__r.RESRV_Number__c);
                            // updateObj.TRANS_FLAG__c = 'C';

                            // siMap.put(prli.SR_RESRV_PART_Id__r.RESRV_Number__c, updateObj);

                            // if (!siMap.containsKey(prli.SR_RESRV_PART_Id__r.RESRV_Number__c)) {
                            //     divUpdateList.add(updateObj);    
                            // }
                            //2024.03.22 seung yoon heo 해당 Map에 같은 키로 값이 있으면 재고 담기면 안됨
                            if(!historyCancelMap.containsKey(prli.Id)){
                                rsrvCancelMap.put('ProductRequestLineItem', prliSaleMap.get(prli.SR_RESRV_PART_Id__r.RESRV_Number__c + '_' + prli.RSRV_SEQ__c));
                                rsrvCancelMap.put('code', 'AD');

                                rsrvCancelMapList.add(rsrvCancelMap);
                            }
                        } else {
                            rsrvCancelMap.put('ProductRequestLineItem', prliSaleMap.get(prli.SR_RESRV_PART_Id__r.RESRV_Number__c + '_' + prli.RSRV_SEQ__c));
                            //24.02.16 gw.lee
                            //사업부 출하가 되던 안되던 사업부 주문수량 감소, 센터 약속 미입고 수량 감소 조치 (자재에서 전달 완료)
                            //2024.03.22 seung yoon heo 해당 Map에 같은 키로 값이 있으면 재고 담기면 안됨
                            if(!historyCancelMap.containsKey(prli.Id)){
                                rsrvCancelMap.put('code', 'AD');
                                // rsrvCancelMap.put('code', 'AM');

                                rsrvCancelMapList.add(rsrvCancelMap);
                            }
                        }


                        //사업부입고수량 = 요청수량 확인 ProductRequestLineItem > ENDP_RSV_Quantity__c = QuantityRequested
                        if (prli.ENDP_RSV_Quantity__c != null && prli.QuantityRequested != null && prli.ENDP_RSV_Quantity__c == prli.QuantityRequested) {
                            /** 약속취소(예약취소)(약속정리) */
                            System.debug('사업부약속취소(재입고알림)');
                            //EX_RsrvUtil.CANCEL_RESRV(prli, 'AE'); //'AE' : 사업부약속취소(재입고알림)

                            //gw.lee 2023.10.13
                            //호출하는 방식 변경, 약속미입고 수량 차감되게끔 조치
                            // rsrvCancelMap.put('ProductRequestLineItem', prli);
                            // rsrvCancelMap.put('code', 'AE');
                            
                            //23 12 21 hyungho.chun //일반예약 모든품목이 사업부에서 받아온경우 수불처리
                            //2024.03.22 seung yoon heo 해당 Map에 같은 키로 값이 있으면 재고 담기면 안됨
                            if(!historyCancelMap.containsKey(prli.Id)){
                                prli.CANCEL_Quantity__c = prli.QuantityRequested;
                                execAEList.add(prli);
                            }

 						} else if (prli.ENDP_RSV_Quantity__c != null && prli.QuantityRequested != null && prli.ENDP_RSV_Quantity__c < prli.QuantityRequested) {
                            /** 약속취소(예약취소)(약속정리) (센터재고 + 사업부 요청)일 경우, 사업부 요청 수량만 취소 처리 */               
                            //23 10 10 hyungho.chun
                            // if (rsrvMap.get(prli.RSRV_Number__c) != prli.QuantityRequested) {




                            // if (rsrvMap.get(prli.SR_RESRV_PART_Id__r.RESRV_Number__c) != prli.QuantityRequested) {
                                
                            //     //센터재고는 센터에서 기입한 재고만 다시 +하여 자재 List에 넣어줌
                            //     // 10 10 hyungho.chun
                            //     // prli.CANCEL_Quantity__c = prli.QuantityRequested - rsrvMap.get(prli.RSRV_Number__c);
                            //     prli.CANCEL_Quantity__c = prli.QuantityRequested - rsrvMap.get(prli.SR_RESRV_PART_Id__r.RESRV_Number__c);
                            //     execABList.add(prli);
                            // }

                            //23 12 21 hyungho.chun //일반예약 일부는 사업부, 일부는 적치장소에서 받아온 경우
                            //2024.03.22 seung yoon heo 해당 Map에 같은 키로 값이 있으면 재고 담기면 안됨
                            if(!historyCancelMap.containsKey(prli.Id)){
                                ProductRequestLineItem tempClonePrli1 = prli.clone();
                                tempClonePrli1.CANCEL_Quantity__c = prli.ENDP_RSV_Quantity__c; //사업부에서받은만큼 아래 원주문 업데이트직전에 다시 cancel_quantitiy를 QuantityRequested 로 증가시켜줘야함
                                execAEList.add(tempClonePrli1); //약속수량감소
                                // prli.CANCEL_Quantity__c = prli.QuantityRequested - rsrvMap.get(prli.SR_RESRV_PART_Id__r.RESRV_Number__c); //사업부에서받은만큼 아래 원주문 업데이트전에 CANCEL_Quantity__c 올려줌
                                // prli.CANCEL_Quantity__c = prli.QuantityRequested - rsrvMap.get(prli.SR_RESRV_PART_Id__r.RESRV_Number__c+'_'+prli.BASIS_Parts_Number__c); //사업부에서받은만큼 아래 원주문 업데이트전에 CANCEL_Quantity__c 올려줌
                                ProductRequestLineItem tempClonePrli2 = prli.clone();
                                tempClonePrli2.CANCEL_Quantity__c = prli.QuantityRequested - rsrvMap.get(prli.SR_RESRV_PART_Id__r.RESRV_Number__c+'_'+prli.BASIS_Parts_Number__c); //사업부에서받은만큼 아래 원주문 업데이트전에 CANCEL_Quantity__c 올려줌
                                execABList.add(tempClonePrli2); //할당수량감소
                            }
                            

                            //gw.lee 2023.10.13
                            //호출하는 방식 변경, 약속미입고 수량 차감되게끔 조치
                            // rsrvCancelMap.put('ProductRequestLineItem', prli);
                            // rsrvCancelMap.put('code', 'AE');
                        } else {
                            //입고안됨
                            //EX_RsrvUtil.CANCEL_RESRV(prli, 'AD'); //'AD' : 사업부약속취소(미입고상태)
                            System.debug('사업부약속취소(미입고상태)');

                            //약속취소(예약취소)(약속정리) (센터재고 + 사업부 요청)일 경우, 사업부 요청 수량만 취소 처리 
                            //23 10 10 hyungho.chun
                            // if (rsrvMap.get(prli.RSRV_Number__c) != prli.QuantityRequested) {




                            //23 12 21 hyungho.chun 입고가안된건 적치장소로내려온게없으니 소모품에서 수불처리하지않는다
                            // if (rsrvMap.get(prli.SR_RESRV_PART_Id__r.RESRV_Number__c) != prli.QuantityRequested) {
                            //     //센터재고는 센터에서 기입한 재고만 다시 +하여 자재 List에 넣어줌
                            //     // 10 10 hyungho.chun
                            //     // prli.CANCEL_Quantity__c = prli.QuantityRequested - rsrvMap.get(prli.RSRV_Number__c);
                            //     prli.CANCEL_Quantity__c = prli.QuantityRequested - rsrvMap.get(prli.SR_RESRV_PART_Id__r.RESRV_Number__c);
                            //     execABList.add(prli);

                            // }





                            //gw.lee 2023.10.13
                            //호출하는 방식 변경, 약속미입고 수량 차감되게끔 조치
                            // rsrvCancelMap.put('ProductRequestLineItem', prli);
                            // rsrvCancelMap.put('code', 'AD');
                        }
                        
                    } //for(ProductRequestLineItem)
                } else { //예약번호 없음
                    if (SalesNumber == null || SalesNumber.equals('')) { //판매번호 없음(To-Be 확인필요)
                        /** 할당수량 감소 재고 공통모듈 호출 */
                        // String strProductRequestLineItemQry = '';
                        // strProductRequestLineItemQry += 'SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
                        // strProductRequestLineItemQry += ' ,Product2.Name, Product2.PART_DESC_KOR__c ';
                        // strProductRequestLineItemQry += '  FROM ProductRequestLineItem';
                        // strProductRequestLineItemQry += ' WHERE Id IN (\'' + String.valueOf(selectedMap.get('Id')) + '\')';
                        // List<ProductRequestLineItem> productRequestLineItem = Database.query(strProductRequestLineItemQry);
                        List<ProductRequestLineItem> productRequestLineItemList = new List<ProductRequestLineItem>();
                        if (!prliListTotal.isEmpty()) {
                            for (ProductRequestLineItem pp : prliListTotal) {
                                if (pp.Id == String.valueOf(selectedMap.get('Id'))) {
                                    productRequestLineItemList.add(pp);
                                }
                            }
                        }

                        for (ProductRequestLineItem item : productRequestLineItemList) { //1건임
                            //2024.03.22 seung yoon heo 해당 Map에 같은 키로 값이 있으면 재고 담기면 안됨
                            if(!historyCancelMap.containsKey(item.Id)){
                                    item.CANCEL_Quantity__c = CancelQuantity;
                                    execABList.add(item);
                            }
                            // Map<String, Object> rtn = EX_RsrvUtil.execApplyProductItem(CancelQuantity, 'AB', consumableOrderItem); //AB 할당(-) 소모품주문취소                           
                            // if (rtn.get('boolIsSuccess') != null) {
                            //     System.debug('boolIsSuccess : ' + Boolean.valueOf(rtn.get('boolIsSuccess')));
                            // }
                            // if (rtn.get('strErrMsg') != null) {
                            //     System.debug('strErrMsg : ' + String.valueOf(rtn.get('strErrMsg')));
                            // }
                        }
                    }
                }

                /** 가상계좌 환불정보 처리 */
                if (orderChannel.equals('소모품택배') && selectedMap.get('OrderStatus').equals('결제요청')) {
                    //가상계좌환불정보 PAYMENT_Method_Code__c  (* 결제방식 = 현장현금, 가상계좌, 결제URL(=가상계좌)인 경우 화면 표시)
                    // 예정 : PAYMENT_Method_Code__c : O현금(현장현금), O현금(가상계좌), X카드(현장카드결제), X카드(결제URL)
                    if ((selectedMasterMap.get('PaymentMethod') != null && selectedMasterMap.get('PaymentMethod').equals('현금입금')) || (selectedMasterMap.get('PaymentMethod') != null && selectedMasterMap.get('PaymentMethod').equals('가상계좌'))) {
                        FN_PaymentModel.T_RES_BankAccount res_bankAccount = new FN_PaymentModel.T_RES_BankAccount();
                        Map<String, Object> aBody = new Map<String, Object>();
                        /* 은행코드 */
                        aBody.put('bank', bankCode);
                        /* 계좌번호 */
                        aBody.put('bankAccountNo', bankAccountNo);
                        /* 계좌예금주 */
                        aBody.put('receiverName', receiverName);
                        //res_bankAccount = FNPaymentCredit.checkBankAccount(aBody);
                        FN_PaymentModel.T_REQ_CancelPayment kRequest = new FN_PaymentModel.T_REQ_CancelPayment();
                        String mid = '';
                        if (selectedMasterMap.get('MOID') != null) {
                            mid = String.valueOf(selectedMasterMap.get('MOID'));
                        }

                        String prlId = '';
                        if (selectedMasterMap.get('Id') != null) {
                            prlId = String.valueOf(selectedMasterMap.get('Id'));
                        }
                        String cancelReason = String.valueOf(selectedMap.get('CancelRequestReason'));
                        SR_SMARTRO_PAYMENT_REQUEST__c kSmartro = new SR_SMARTRO_PAYMENT_REQUEST__c();
                        if(mid != '') {
                             kSmartro = EX_PaymentUtil.fetchRequestHistory(mid);
                        }
                        kRequest.merchantKey = pg.SIGN_KEY__c;
                        kRequest.Mid = pg.MID__c;

                        kRequest.Tid = kSmartro.TID__c;
                        kRequest.CancelAmt = String.valueOf(kSmartro.APPR_AMT__c);
                        String jsonStr = JSON.serialize(kRequest);
                        String jsonStrPoint = '';
                        System.debug('kRequest ' + kRequest);
                        if (selectedMap.get('PointAmount') != 0 && selectedMap.get('PointAmount') != null) {

                            FN_PaymentModel.T_REQ_SpendOrCancelPoint kRequestModelPoint = new FN_PaymentModel.T_REQ_SpendOrCancelPoint();
                            kRequestModelPoint.MBS_CUST_ID = mbs_cust_id;
                            kRequestModelPoint.ORG_CD = '';
                            kRequestModelPoint.ACCUM_FLAG = 'USED_CNCL';
                            kRequestModelPoint.ACCUM_PNT = String.valueOf(selectedMap.get('PointAmount'));
                            // kRequestModelPoint.BILL_TO_CD = objUser.DEPT_CODE__c;
                            kRequestModelPoint.BILL_TO_CD = 'PH8002'; //23 10 06 hyungho.chun
                            kRequestModelPoint.BILL_TO_NM = String.valueOf(selectedMasterMap.get('ConsultantDIV'));
                            kRequestModelPoint.ORIG_ACCUM_BRKDN_ID = String.valueOf(selectedMap.get('POINT_TRX_ID'));
                            jsonStrPoint = JSON.serialize(kRequestModelPoint);
                            callout(jsonStrPoint, '', 'point', false, prlId, cancelReason, String.valueOf(selectedMap.get('Id')));
                        }
                        callout(jsonStr, kSmartro.MOID__c, 'vaccount', false, prlId, cancelReason, String.valueOf(selectedMap.get('Id')));

                        // ResultCode=2014, ResultMsg=취소 불가능 거래, 이미 취소된 거래는 성공으로 표시
                        // 2014 코드는 이미 취소한 경우와 입금이 완료된 경우, 이미 환불한 경우 발생한다.
                        // 입금 완료는 이미 확인했으므로 여기에서는 이미 취소한 것으로 판단한다.

                    } else if ((selectedMasterMap.get('PaymentMethod') != null && selectedMasterMap.get('PaymentMethod').equals('카드URL')) || (selectedMasterMap.get('PaymentMethod') != null && selectedMasterMap.get('PaymentMethod').equals('결제URL'))) {
                        /*Date appr_dt;
                        if (selectedMasterMap.get('APPR_DT') != null) {
                            appr_dt = Date.valueOf(selectedMasterMap.get('APPR_DT'));
                        }
                        boolean isValidDate = true;
                        if (appr_dt == null || Date.today() > appr_dt.addYears(1)) {
                            isValidDate = false;
                        }*/
                        // if (cardAmt > 0 && isValidDate) { //카드일때만 스마트로 부분취소 요청처리 & 365일 이내 건 //가상계좌 및 VIP 100%할인건 예외
                        FN_PaymentModel.T_REQ_CancelCardUrl kRequestModel = new FN_PaymentModel.T_REQ_CancelCardUrl();
                        String mid = '';
                        if (selectedMasterMap.get('MOID') != null) {
                            mid = String.valueOf(selectedMasterMap.get('MOID'));
                        }
                        String tid = '';
                        if (selectedMasterMap.get('TID') != null) {
                            tid = String.valueOf(selectedMasterMap.get('TID'));
                        }
                        String prlId = '';
                        if (selectedMasterMap.get('Id') != null) {
                            prlId = String.valueOf(selectedMasterMap.get('Id'));
                        }

                        // kRequestModel.PartialCancelCode = '1'; //현재 카드결제 [부분취소] 결제모듈파트에서 수정중. 부분취소여부( 0:전체, 1:부분)
                        kRequestModel.merchantKey = pg.SIGN_KEY__c;
                        kRequestModel.Mid = pg.MID__c;
                        kRequestModel.Tid = tid;
                        kRequestModel.moid = mid;


                        //카드취소 결제API 호출
                        String jsonStr = JSON.serialize(kRequestModel);
                        String jsonStrPoint = '';
                        String cancelReason = String.valueOf(selectedMap.get('CancelRequestReason'));
                        System.debug('kRequestModel ' + kRequestModel);


                        if (selectedMap.get('PointAmount') != 0 && selectedMap.get('PointAmount') != null) {
                            FN_PaymentModel.T_REQ_SpendOrCancelPoint kRequestModelPoint = new FN_PaymentModel.T_REQ_SpendOrCancelPoint();
                            kRequestModelPoint.MBS_CUST_ID = mbs_cust_id;
                            kRequestModelPoint.ORG_CD = '';
                            kRequestModelPoint.ACCUM_FLAG = 'USED_CNCL';
                            kRequestModelPoint.ACCUM_PNT = String.valueOf(selectedMap.get('PointAmount'));
                            // kRequestModelPoint.BILL_TO_CD = objUser.DEPT_CODE__c;
                            kRequestModelPoint.BILL_TO_CD = 'PH8002'; //23 10 06 hyungho.chun
                            kRequestModelPoint.BILL_TO_NM = String.valueOf(selectedMasterMap.get('ConsultantDIV'));
                            kRequestModelPoint.ORIG_ACCUM_BRKDN_ID = String.valueOf(selectedMap.get('POINT_TRX_ID'));
                            jsonStrPoint = JSON.serialize(kRequestModelPoint);
                            callout(jsonStrPoint, '', 'point', false, prlId, cancelReason, String.valueOf(selectedMap.get('Id')));

                        }
                        callout(jsonStr, mid, 'card', false, prlId, cancelReason,String.valueOf(selectedMap.get('Id')));

                    } else if ((selectedMasterMap.get('PaymentMethod') != null && selectedMasterMap.get('PaymentMethod').equals('포인트'))) {
                        String prlId = '';
                        if (selectedMasterMap.get('Id') != null) {
                            prlId = String.valueOf(selectedMasterMap.get('Id'));
                        }
                        String cancelReason = String.valueOf(selectedMap.get('CancelRequestReason'));

                        FN_PaymentModel.T_REQ_SpendOrCancelPoint kRequestModel = new FN_PaymentModel.T_REQ_SpendOrCancelPoint();
                        kRequestModel.MBS_CUST_ID = mbs_cust_id;
                        kRequestModel.ORG_CD = '';
                        kRequestModel.ACCUM_FLAG = 'USED_CNCL';
                        kRequestModel.ACCUM_PNT = String.valueOf(selectedMap.get('PointAmount'));
                        // kRequestModel.BILL_TO_CD = objUser.DEPT_CODE__c;
                        kRequestModel.BILL_TO_CD = 'PH8002'; //23 10 06 hyungho.chun
                        kRequestModel.BILL_TO_NM = String.valueOf(selectedMasterMap.get('ConsultantDIV'));
                        kRequestModel.ORIG_ACCUM_BRKDN_ID = String.valueOf(selectedMap.get('POINT_TRX_ID'));
                        String jsonStr = JSON.serialize(kRequestModel);
                        callout(jsonStr, '', 'point', false, prlId, cancelReason, String.valueOf(selectedMap.get('Id')));
                    }
                } else if (orderChannel.equals('소모품택배') && (selectedMap.get('OrderStatus').equals('상품준비중') || selectedMap.get('OrderStatus').equals('결제완료'))) {
                    //23 12 01 hyungho.chun 결제URL(가상계좌)도 첫번째 분기(가상계좌)로 타게끔 
                    if ((selectedMasterMap.get('PaymentMethod') != null && selectedMasterMap.get('PaymentMethod').equals('현금입금')) 
                    || (selectedMasterMap.get('PaymentMethod') != null && selectedMasterMap.get('PaymentMethod').equals('가상계좌'))
                    || (selectedMasterMap.get('PaymentMethod') != null && selectedMasterMap.get('PaymentMethod').equals('결제URL') && selectedMasterMap.get('PaymentMethodCode') != null && selectedMasterMap.get('PaymentMethodCode').equals('VBANK'))
                    ) {
                        FN_PaymentModel.T_RES_BankAccount res_bankAccount = new FN_PaymentModel.T_RES_BankAccount();
                        Map<String, Object> aBody = new Map<String, Object>();
                        /* 은행코드 */
                        aBody.put('bank', bankCode);
                        /* 계좌번호 */
                        aBody.put('bankAccountNo', bankAccountNo);
                        /* 계좌예금주 */
                        aBody.put('receiverName', receiverName);
                        //res_bankAccount = FNPaymentCredit.checkBankAccount(aBody);
                        String mid = '';
                        if (selectedMasterMap.get('MOID') != null) {
                            mid = String.valueOf(selectedMasterMap.get('MOID'));
                        }
                        String tid = '';
                        if (selectedMasterMap.get('TID') != null) {
                            tid = String.valueOf(selectedMasterMap.get('TID'));
                        }
                        String prlId = '';
                        if (selectedMasterMap.get('Id') != null) {
                            prlId = String.valueOf(selectedMasterMap.get('Id'));
                        }
                        String cancelReason = String.valueOf(selectedMap.get('CancelRequestReason'));
                        FN_PaymentModel.T_REQ_RefundCash kRequest = new FN_PaymentModel.T_REQ_RefundCash();

                        kRequest.MerchantKey = pg.SIGN_KEY__c;
                        kRequest.Mid = pg.MID__c;
                        kRequest.Tid = tid;/** 거래번호 (필수) */
                        kRequest.Moid = mid;/** 상품주문번호 (필수) */
                        kRequest.Amt = String.valueOf(selectedMap.get('CashAmount'));/** 거래 금액 (필수)    */
                        kRequest.BuyerName = String.valueOf(selectedMap.get('CustomerName'));/** 구매자명 (필수) */
                        kRequest.GoodsName = (String) aBody.get('GOODS_NAME');/** 거래 상품명 (필수) */
                        kRequest.GoodsCnt = String.valueOf(aBody.get('GOODS_CNT'));/** 결제상품 품목 개수 (필수)   */

                        kRequest.PartialCancelCode = '1';/** 부분환불 여부 (0:전체환불, 1:부분환불) */
                        kRequest.BankCode = (String) aBody.get('bank');/** 은행코드 (필수) */
                        kRequest.BankAccount = (String) aBody.get('bankAccountNo');/** 계좌번호 (필수) */
                        kRequest.BankAccountName = (String) aBody.get('receiverName');/** 계좌예금주 (필수) */
                        // kRequest.BankCode = '003';
                        // kRequest.BankAccount = '010123456789';
                        // kRequest.BankAccountName = '홍길동테스트';

                        String jsonStr = JSON.serialize(kRequest);
                        String jsonStrPoint = '';
                        System.debug(kRequest);
                        if (selectedMap.get('PointAmount') != 0 && selectedMap.get('PointAmount') != null) {
                            FN_PaymentModel.T_REQ_SpendOrCancelPoint kRequestModelPoint = new FN_PaymentModel.T_REQ_SpendOrCancelPoint();
                            kRequestModelPoint.MBS_CUST_ID = mbs_cust_id;
                            kRequestModelPoint.ORG_CD = '';
                            kRequestModelPoint.ACCUM_FLAG = 'USED_CNCL';
                            kRequestModelPoint.ACCUM_PNT = String.valueOf(selectedMap.get('PointAmount'));
                            // kRequestModelPoint.BILL_TO_CD = objUser.DEPT_CODE__c;
                            kRequestModelPoint.BILL_TO_CD = 'PH8002'; //23 10 06 hyungho.chun
                            kRequestModelPoint.BILL_TO_NM = String.valueOf(selectedMasterMap.get('ConsultantDIV'));
                            kRequestModelPoint.ORIG_ACCUM_BRKDN_ID = String.valueOf(selectedMap.get('POINT_TRX_ID'));
                            jsonStrPoint = JSON.serialize(kRequestModelPoint);
                            callout(jsonStrPoint, '', 'point', true, prlId, cancelReason, String.valueOf(selectedMap.get('Id')));
                        }
                        callout(jsonStr, mid, 'vaccount', true, prlId, cancelReason, String.valueOf(selectedMap.get('Id')));

                        // ResultCode=2014, ResultMsg=취소 불가능 거래, 이미 취소된 거래는 성공으로 표시
                        // 2014 코드는 이미 취소한 경우와 입금이 완료된 경우, 이미 환불한 경우 발생한다.
                        // 입금 완료는 이미 확인했으므로 여기에서는 이미 취소한 것으로 판단한다.
                    
                        //23 12 01 hyungho.chun 결제URL(신용카드)는 첫 분기에서 걸러서 여기남은건 다 결제URL인경우엔 카드다
                    } else if ((selectedMasterMap.get('PaymentMethod') != null && selectedMasterMap.get('PaymentMethod').equals('결제URL')) 
                    || (selectedMasterMap.get('PaymentMethod') != null && selectedMasterMap.get('PaymentMethod').equals('카드'))
                    || (selectedMasterMap.get('PaymentMethod') != null && selectedMasterMap.get('PaymentMethod').equals('현장카드'))
                    ) {
                        /*Date appr_dt;
                        if (selectedMasterMap.get('APPR_DT') != null) {
                            appr_dt = Date.valueOf(selectedMasterMap.get('APPR_DT'));
                        }
                        boolean isValidDate = true;
                        if (appr_dt == null || Date.today() > appr_dt.addYears(1)) {
                            isValidDate = false;
                        }*/
                        // if (cardAmt > 0 && isValidDate) { //카드일때만 스마트로 부분취소 요청처리 & 365일 이내 건 //가상계좌 및 VIP 100%할인건 예외
                        FN_PaymentModel.T_REQ_CancelPayment kRequestModel = new FN_PaymentModel.T_REQ_CancelPayment();
                        String mid = '';
                        if (selectedMasterMap.get('MOID') != null) {
                            mid = String.valueOf(selectedMasterMap.get('MOID'));
                        }
                        String tid = '';
                        if (selectedMasterMap.get('TID') != null) {
                            tid = String.valueOf(selectedMasterMap.get('TID'));
                        }
                        String prlId = '';
                        if (selectedMasterMap.get('Id') != null) {
                            prlId = String.valueOf(selectedMasterMap.get('Id'));
                        }
                        String cancelReason = String.valueOf(selectedMap.get('CancelRequestReason'));
                        //kRequestModel.PartialCancelCode = '1'; //현재 카드결제 [부분취소] 결제모듈파트에서 수정중. 부분취소여부( 0:전체, 1:부분)
                        kRequestModel.merchantKey = pg.SIGN_KEY__c;
                        kRequestModel.Mid = pg.MID__c;
                        kRequestModel.Tid = tid;
                        kRequestModel.CancelAmt = String.valueOf(selectedMap.get('CardAmount'));

                        //카드취소 결제API 호출
                        String jsonStr = JSON.serialize(kRequestModel);
                        String jsonStrPoint = '';


                        if (selectedMap.get('PointAmount') != 0 && selectedMap.get('PointAmount') != null) {
                            FN_PaymentModel.T_REQ_SpendOrCancelPoint kRequestModelPoint = new FN_PaymentModel.T_REQ_SpendOrCancelPoint();
                            kRequestModelPoint.MBS_CUST_ID = mbs_cust_id;
                            kRequestModelPoint.ORG_CD = '';
                            kRequestModelPoint.ACCUM_FLAG = 'USED_CNCL';
                            kRequestModelPoint.ACCUM_PNT = String.valueOf(selectedMap.get('PointAmount'));
                            // kRequestModelPoint.BILL_TO_CD = objUser.DEPT_CODE__c;
                            kRequestModelPoint.BILL_TO_CD = 'PH8002'; //23 10 06 hyungho.chun
                            kRequestModelPoint.BILL_TO_NM = String.valueOf(selectedMasterMap.get('ConsultantDIV'));
                            kRequestModelPoint.ORIG_ACCUM_BRKDN_ID = String.valueOf(selectedMap.get('POINT_TRX_ID'));
                            jsonStrPoint = JSON.serialize(kRequestModelPoint);
                            callout(jsonStrPoint, '', 'point', TRUE, prlId, cancelReason, String.valueOf(selectedMap.get('Id')));

                        }
                        callout(jsonStr, mid, 'card', TRUE, prlId, cancelReason, String.valueOf(selectedMap.get('Id')));

                    } else if ((selectedMasterMap.get('PaymentMethod') != null && selectedMasterMap.get('PaymentMethod').equals('포인트'))) {
                        String prlId = '';
                        if (selectedMasterMap.get('Id') != null) {
                            prlId = String.valueOf(selectedMasterMap.get('Id'));
                        }
                        String cancelReason = String.valueOf(selectedMap.get('CancelRequestReason'));
                        FN_PaymentModel.T_REQ_SpendOrCancelPoint kRequestModel = new FN_PaymentModel.T_REQ_SpendOrCancelPoint();
                        kRequestModel.MBS_CUST_ID = mbs_cust_id;
                        kRequestModel.ORG_CD = '';
                        kRequestModel.ACCUM_FLAG = 'USED_CNCL';
                        kRequestModel.ACCUM_PNT = String.valueOf(selectedMap.get('PointAmount'));
                        // kRequestModel.BILL_TO_CD = objUser.DEPT_CODE__c;
                        kRequestModel.BILL_TO_CD = 'PH8002'; //23 10 06 hyungho.chun
                        kRequestModel.BILL_TO_NM = String.valueOf(selectedMasterMap.get('ConsultantDIV'));
                        kRequestModel.ORIG_ACCUM_BRKDN_ID = String.valueOf(selectedMap.get('POINT_TRX_ID'));
                        String jsonStr = JSON.serialize(kRequestModel);
                        System.debug('jsonStr123 :: '+jsonStr);
                        callout(jsonStr, '', 'point', TRUE, prlId, cancelReason, String.valueOf(selectedMap.get('Id')));
                    }
                } 
                // 24 01 17 PHJ 위에 동일한 조건 존재
                // else if (orderChannel.equals('소모품택배') && (selectedMap.get('OrderStatus').equals('상품준비중') || selectedMap.get('OrderStatus').equals('결제완료'))) {
                //     if ((selectedMasterMap.get('PaymentMethod') != null && selectedMasterMap.get('PaymentMethod').equals('포인트'))) {
                //         String prlId = '';
                //         if (selectedMasterMap.get('Id') != null) {
                //             prlId = String.valueOf(selectedMasterMap.get('Id'));
                //         }
                //         String cancelReason = String.valueOf(selectedMap.get('CancelRequestReason'));
                //         FN_PaymentModel.T_REQ_SpendOrCancelPoint kRequestModel = new FN_PaymentModel.T_REQ_SpendOrCancelPoint();
                //         kRequestModel.MBS_CUST_ID = mbs_cust_id;
                //         kRequestModel.ORG_CD = '';
                //         kRequestModel.ACCUM_FLAG = 'USED_CNCL';
                //         kRequestModel.ACCUM_PNT = String.valueOf(selectedMap.get('PointAmount'));
                //         // kRequestModel.BILL_TO_CD = objUser.DEPT_CODE__c;
                //         kRequestModel.BILL_TO_CD = 'PH8002'; //23 10 06 hyungho.chun
                //         kRequestModel.BILL_TO_NM = String.valueOf(selectedMasterMap.get('ConsultantDIV'));
                //         kRequestModel.ORIG_ACCUM_BRKDN_ID = String.valueOf(selectedMap.get('POINT_TRX_ID'));
                //         String jsonStr = JSON.serialize(kRequestModel);
                //         System.debug('jsonStr456 :: '+jsonStr);
                //         callout(jsonStr, '', 'point', TRUE, prlId, cancelReason, String.valueOf(selectedMap.get('Id')));
                //     }
                // }

                /** 상세주문의 오리지널 데이터 처리 Update */
                String oriId = String.valueOf(selectedMap.get('Id'));

                Integer sq = 0;
                System.debug('취소수량 : ' + CancelQuantity);
                if (selectedMap.get('SalesQuantity') != null) {
                    System.debug('판매수량 : ' + selectedMap.get('SalesQuantity'));
                    sq = Integer.valueOf(selectedMap.get('SalesQuantity')) - CancelQuantity;
                }

                try {

                    String orderStatusForCancel = CONSUMABLE_ORDER_STATUS_004; //주문취소
                    if (selectedMap.get('OrderStatus').equals('결제요청') || selectedMap.get('OrderStatus').equals('결제완료')) {
                        orderStatusForCancel = CONSUMABLE_ORDER_STATUS_003; //결제취소
                    }

                    system.debug('oriId : ' + oriId);
                    system.debug('orderStatusForCancel : ' + orderStatusForCancel);
                    if ((selectedMasterMap.get('PaymentMethod') != null && selectedMasterMap.get('PaymentMethod').equals('현금입금')) || (selectedMasterMap.get('PaymentMethod') != null && selectedMasterMap.get('PaymentMethod').equals('가상계좌'))) {
                        // update new ProductRequestLineItem(
                            // Id = oriId,
                            // Consumables_Order_Status__c = orderStatusForCancel,
                            // SALE_Quantity__c = sq,
                            // CANCEL_Quantity__c = CancelQuantity,
                            // CANCEL_Date__c = dt.date(),
                            // CANCEL_Request_DTM__c = System.now(),
                            // CANCEL_UserId__c = UserInfo.getUserId(),
                            // CANCEL_User__c = UserInfo.getName(),
                            // CANCEL_Reason__c = String.valueOf(selectedMap.get('CancelRequestReason')),
                            // CANCEL_Department_Code__c = objUser.DEPT_CODE__c,
                            // RETURN_PAYMENT_PTID__c = kResponseModel.pTid,
                            // REFUND_BANK_CODE__c = bankCode,
                            // REFUND_BANK_ACCOUNT_NAME__c = receiverName,
                            // ENC_REFUND_BANK_ACCOUNT__c = bankAccountNo
                        // );
                        ProductRequestLineItem updatePrli = new ProductRequestLineItem();
                        updatePrli.Id = oriId;
                        updatePrli.Consumables_Order_Status__c = orderStatusForCancel;
                        //2024.03.22 seung yoon heo 전에 취소된 이력이 있으면 판매수량 0 으로 수불 x 취소수량은 최초 요청갯수와 같아서 상관없음
                        updatePrli.SALE_Quantity__c = !historyCancelMap.containsKey(String.ValueOf(selectedMap.get('Id'))) ? sq : 0;
                        updatePrli.CANCEL_Quantity__c = CancelQuantity;
                        updatePrli.CANCEL_Date__c = dt.date();
                        updatePrli.CANCEL_Request_DTM__c = System.now();
                        updatePrli.CANCEL_UserId__c = UserInfo.getUserId();
                        updatePrli.CANCEL_User__c = UserInfo.getName();
                        updatePrli.CANCEL_Reason__c = String.valueOf(selectedMap.get('CancelRequestReason'));
                        updatePrli.CANCEL_Department_Code__c = objUser.DEPT_CODE__c;
                        //23 08 16 hyungho.chun RETURN_PAYMENT_PTID__c 업데이트부분 따로 분리
                        // updatePrli.RETURN_PAYMENT_PTID__c = kResponseModel.pTid;
                        updatePrli.REFUND_BANK_CODE__c = bankCode;
                        updatePrli.REFUND_BANK_ACCOUNT_NAME__c = receiverName;
                        updatePrli.ENC_REFUND_BANK_ACCOUNT__c = bankAccountNo;
                        //24.31.11 gw.lee
                        //송찬영님 요청, ETA화면 표출 시, 취소된건은 Staus == 'C' 조치 필요
                        updatePrli.Status = 'C';
                        //23.12.05 gw.lee
                        //약속이 있는 경우, 주문취소 했을 때 약속상태 취소 조치
                        System.debug('RSRV_Number :::: ' + RSRV_Number);
                        if (RSRV_Number != '') {
                            //2024.02.29 seung yoon heo Appointment_Status__c 약속취소로 변경
                            // updatePrli.Appointment_Status__c = '취소';
                            updatePrli.Appointment_Status__c = '약속취소';
                        }
                        updatePrliList.add(updatePrli);
                    } else {
                        // update new ProductRequestLineItem(
                            // Id = oriId,
                            // Consumables_Order_Status__c = orderStatusForCancel,
                            // SALE_Quantity__c = sq,
                            // CANCEL_Quantity__c = CancelQuantity,
                            // CANCEL_Date__c = dt.date(),
                            // CANCEL_Request_DTM__c = System.now(),
                            // CANCEL_UserId__c = UserInfo.getUserId(),
                            // CANCEL_User__c = UserInfo.getName(),
                            // CANCEL_Reason__c = String.valueOf(selectedMap.get('CancelRequestReason')),
                            // CANCEL_Department_Code__c = objUser.DEPT_CODE__c,
                            // RETURN_PAYMENT_PTID__c = kResponseModel.pTid
                        // );
                        ProductRequestLineItem updatePrli = new ProductRequestLineItem();
                        updatePrli.Id = oriId;
                        updatePrli.Consumables_Order_Status__c = orderStatusForCancel;
                        //2024.03.22 seung yoon heo 전에 취소된 이력이 있으면 판매수량 0 으로 수불 x 취소수량은 최초 요청갯수와 같아서 상관없음
                        updatePrli.SALE_Quantity__c =  !historyCancelMap.containsKey(String.ValueOf(selectedMap.get('Id'))) ? sq : 0;
                        updatePrli.CANCEL_Quantity__c = CancelQuantity;
                        updatePrli.CANCEL_Date__c = dt.date();
                        updatePrli.CANCEL_Request_DTM__c = System.now();
                        updatePrli.CANCEL_UserId__c = UserInfo.getUserId();
                        updatePrli.CANCEL_User__c = UserInfo.getName();
                        updatePrli.CANCEL_Reason__c = String.valueOf(selectedMap.get('CancelRequestReason'));
                        updatePrli.CANCEL_Department_Code__c = objUser.DEPT_CODE__c;
                        //24.31.11 gw.lee
                        //송찬영님 요청, ETA화면 표출 시, 취소된건은 Staus == 'C' 조치 필요
                        updatePrli.Status = 'C';
                        //23.12.05 gw.lee
                        //약속이 있는 경우, 주문취소 했을 때 약속상태 취소 조치
                        System.debug('RSRV_Number :::: ' + RSRV_Number);
                        if (RSRV_Number != '') {
                            //2024.02.29 seung yoon heo Appointment_Status__c 약속취소로 변경
                            // updatePrli.Appointment_Status__c = '취소';
                            updatePrli.Appointment_Status__c = '약속취소';
                        }
                        //23 08 16 hyungho.chun RETURN_PAYMENT_PTID__c 업데이트부분 따로 분리
                        // updatePrli.RETURN_PAYMENT_PTID__c = kResponseModel.pTid;
                        updatePrliList.add(updatePrli);
                    }
                } catch (Exception e) {
                    system.debug('ERROR : ' + e.getMessage());
                    resultStat = 'FAIL';
                    resultMessage = '주문취소 데이터 Update 실패.';
                    throw new AuraHandledException('취소실패 : ' + e.getMessage());
                }
                // }
            }//for
            if(!execABList.isEmpty()){
                EX_RsrvUtil.execApplyProductItemMulti('AB',execABList);
            }
            //23 12 21 hyungho.chun 적치장소 약속수량 감소 호출
            if(!execAEList.isEmpty()){
                EX_RsrvUtil.execApplyProductItemMulti('AE',execAEList);
            }
            System.debug('rsrvCancelMapList :::: ' + rsrvCancelMapList);
            if (!rsrvCancelMapList.isEmpty()) {
                EX_RsrvUtil.CANCEL_RESRV_MULTI(rsrvCancelMapList);
            }

            //23 12 21 hyungho.chun
            // if (divUpdateList.size() > 0) {

            //     update divUpdateList;
            // }
            System.debug('updatePrliList :::: ' + updatePrliList);
            if (!updatePrliList.isEmpty()) {
                System.debug('updatePrliList :::: ' + updatePrliList);
                update updatePrliList;
                system.debug('updatePrliList TOTAL : ' + updatePrliList.size());
                //23 08 16 hyungho.chun 주문취소 RETURN_PAYMENT_PTID__c 값 추가용 메소드
                // updatePrliPtid(updatePrliList);                
            }
        } else {
            //주문취소 가능시간 07:00 ~ 21:00
            resultStat = 'FAIL';
            resultMessage = '주문취소 가능시간은 07:00 ~ 21:00 입니다.';
            throw new AuraHandledException('주문취소 가능시간은 07:00 ~ 21:00 입니다.');
        }

        returnMap.put('resultStat', resultStat);
        returnMap.put('resultMessage', resultMessage);

        return returnMap;
    }

    //23 08 16 hyungho.chun 주문취소 RETURN_PAYMENT_PTID__c 값 추가용 메소드
    public static void updatePrliPtid(String prliId){
        system.debug('updatePrliPtid 시작');

        Map<String, String> requestMap = new Map<String, String>();
        Map<String, String> requestMap2 = new Map<String, String>();
        List<String> prliTidList = new List<String>();
        List<String> prliIdList = new List<String>();


        List<ProductRequestLineItem> tempPrLiList  = [
            SELECT Id, TID__c, RETURN_PAYMENT_PTID__c FROM ProductRequestLineItem WHERE Id =:prliId
        ];

        for (ProductRequestLineItem prLiItem : tempPrLiList) {
            prliTidList.add(prLiItem.TID__c);
        }
        system.debug('prliTidList ::'+prliTidList);

        List<SR_SMARTRO_PAYMENT_REQUEST__c> srSmartoReqList = [SELECT Id, TID__c FROM SR_SMARTRO_PAYMENT_REQUEST__c WHERE TID__c IN :prliTidList];
        for (SR_SMARTRO_PAYMENT_REQUEST__c tObj : srSmartoReqList) {
            requestMap.put(tObj.Id, tObj.TID__c);
        }
        system.debug('requestMap ::'+requestMap);

        List<SR_SMARTRO_PAYMENT_CANCEL__c> srSmartoCacList = [SELECT Id, PTID__c,SR_SMARTRO_PAYMENT_REQUEST_ID__c FROM SR_SMARTRO_PAYMENT_CANCEL__c WHERE SR_SMARTRO_PAYMENT_REQUEST_ID__c IN :requestMap.keySet()];
        for (SR_SMARTRO_PAYMENT_CANCEL__c sspoObj : srSmartoCacList) {
            if(requestMap.containsKey(sspoObj.SR_SMARTRO_PAYMENT_REQUEST_ID__c)) {
                requestMap2.put(requestMap.get(sspoObj.SR_SMARTRO_PAYMENT_REQUEST_ID__c), sspoObj.PTID__c);
            }
        }
        system.debug('requestMap2 ::'+requestMap2);

        for (ProductRequestLineItem prLiItem : tempPrLiList) {
            if(requestMap2.containsKey(prLiItem.TID__c)){
                prLiItem.RETURN_PAYMENT_PTID__c = requestMap2.get(prLiItem.TID__c);
            }
            
        }
        system.debug('tid_c 업데이트 !');
        system.debug('tempPrLiList ::'+tempPrLiList);
        update tempPrLiList;        
    }

    @future(callout=true)
    public static void callout(String jsonStr, String moid, String type, Boolean isPay, String prlId, String cancelReason, String prliId) {
        System.debug('callout안의 jsonStr 확인하자 :: '+jsonStr);
        System.debug('callout안의 moid 확인하자 :: '+moid);
        System.debug('callout안의 type 확인하자 :: '+type);
        System.debug('callout안의 isPay 확인하자 :: '+isPay);
        System.debug('callout안의 prlId 확인하자 :: '+prlId);
        System.debug('callout안의 cancelReason 확인하자 :: '+cancelReason);
        System.debug('callout안의 prliId 확인하자 :: '+prliId);
        if (isPay == false && moid != '') {
            if (type == 'vaccount') {
                System.debug('jsonstr : ' + jsonStr);
                FN_PaymentModel.T_REQ_CancelPayment kRequest = (FN_PaymentModel.T_REQ_CancelPayment) JSON.deserialize(jsonStr, FN_PaymentModel.T_REQ_CancelPayment.class);
                FN_PaymentModel.T_RES_CancelPayment kResponse = FN_PaymentAgent.cancelVirtualAccountBeforePay(kRequest, moid);
                System.debug('가상결제 결제전 input : ' + JSON.serialize(kRequest));
                System.debug('가상결제 결제전 output : ' + JSON.serialize(kResponse));
                //23 08 16 hyungho.chun 주문취소 RETURN_PAYMENT_PTID__c 값 추가용 메소드
                if(kResponse.PTid != null){
                    updatePrliPtid(prliId);
                }
            } else if (type == 'card') {
                FN_PaymentModel.T_REQ_CancelCardUrl kResponseModel = (FN_PaymentModel.T_REQ_CancelCardUrl) JSON.deserialize(jsonStr, FN_PaymentModel.T_REQ_CancelCardUrl.class);
                FN_PaymentModel.T_RES_CancelCardUrl kResponse = FN_PaymentAgent.cancelCardUrl(kResponseModel, moid);
                System.debug('카드url 결제전 input : ' + JSON.serialize(kResponseModel));
                System.debug('카드url 결제전 output : ' + JSON.serialize(kResponse));
            } else if (type == 'point') {
                FN_PaymentModel.T_REQ_SpendOrCancelPoint kResponseModel = (FN_PaymentModel.T_REQ_SpendOrCancelPoint) JSON.deserialize(jsonStr, FN_PaymentModel.T_REQ_SpendOrCancelPoint.class);
                FN_PaymentModel.T_RES_SpendOrCancelPoint kResponse = FN_PaymentAgent.requestSpendOrCancelPoint(kResponseModel);
                System.debug('포인트 결제전 input : ' + JSON.serialize(kResponseModel));
                System.debug('포인트 결제전 output : ' + JSON.serialize(kResponse));
            }
        } else {
            if (type == 'vaccount') {
                // FNPaymentCredit.refundBankAccount(aBody, aContext.MOID__c, kPg.MID__c, kPg.SIGN_KEY__c);
                FN_PaymentModel.T_REQ_RefundCash kResponseModel = (FN_PaymentModel.T_REQ_RefundCash) JSON.deserialize(jsonStr, FN_PaymentModel.T_REQ_RefundCash.class);
                FN_PaymentModel.T_RES_RefundCash kResponse = FN_PaymentAgent.refundCashFromVirtualAccount(kResponseModel, moid);
                System.debug('가상결제 결제후 input : ' + kResponseModel);
                System.debug('가상결제 결제후 output : ' + kResponse);
                //23 08 16 hyungho.chun 주문취소 RETURN_PAYMENT_PTID__c 값 추가용 메소드
                if(kResponse.PTid != null){
                    updatePrliPtid(prliId);
                }
            } else if (type == 'card') {
                FN_PaymentModel.T_REQ_CancelPayment kResponseModel = (FN_PaymentModel.T_REQ_CancelPayment) JSON.deserialize(jsonStr, FN_PaymentModel.T_REQ_CancelPayment.class);
                System.debug('카드url 결제후 input : ' + JSON.serialize(kResponseModel));
                if (!Test.isRunningTest()) {
                    FN_PaymentModel.T_RES_CancelPayment kResponse = FNPaymentCard.requestCancelCardPayPartial(kResponseModel.Tid, Decimal.valueOf(kResponseModel.CancelAmt), kResponseModel.Mid, kResponseModel.merchantKey);
                    //23 08 16 hyungho.chun 주문취소 RETURN_PAYMENT_PTID__c 값 추가용 메소드
                    if(kResponse.PTid != null ){
                        System.debug('카드url 결제후 output : ' + JSON.serialize(kResponse));
                        updatePrliPtid(prliId);
                    }
                }
            } else if (type == 'point') {
                System.debug('jsonStr22 :: '+jsonStr);
                FN_PaymentModel.T_REQ_SpendOrCancelPoint kResponseModel = (FN_PaymentModel.T_REQ_SpendOrCancelPoint) JSON.deserialize(jsonStr, FN_PaymentModel.T_REQ_SpendOrCancelPoint.class);
                System.debug('kResponseModel :: '+kResponseModel);
                FN_PaymentModel.T_RES_SpendOrCancelPoint kResponse = FN_PaymentAgent.requestSpendOrCancelPoint(kResponseModel);
                System.debug('kResponse :: '+kResponse);
                System.debug('포인트 결제후 input : ' + kResponseModel);
                System.debug('포인트 결제후 output : ' + kResponse);
            }
        }
    }

    public class ConsumableReturnOrderTable {
        @AuraEnabled public String Id;
        // 주문 순번
        @AuraEnabled public Integer OrderSEQ;
        // 반품 요청 채널
        @AuraEnabled public String ReturnChannel;
        // 원 주문 번호
        @AuraEnabled public String OriginOrderNumber;
        // 원 주문 ID
        @AuraEnabled public String OriginOrderId;

        // 반품 형태
        @AuraEnabled public String ReturnType;

        // 원 주문 고객/결제자 Id
        @AuraEnabled public String ContactId;

        // 결제자
        @AuraEnabled public String CustomerName;
        // 결제자전화번호1
        @AuraEnabled public String CustomerPhone;
        // 결제자전화번호2
        @AuraEnabled public String CustomerPhone2;

        // 결제자 주소
        @AuraEnabled public String CustomerAddress;
        // 결제자 상세주소
        @AuraEnabled public String CustomerDetailAddress;
        // 결제자 우편번호
        @AuraEnabled public String CustomerPostalCode;


        // 받는분
        @AuraEnabled public String CONSIGNEE_Name;
        // 받는분전화번호
        @AuraEnabled public String CONSIGNEE_Phone;
        @AuraEnabled public String CONSIGNEE_Address;
        @AuraEnabled public String CONSIGNEE_DetailAddress;

        // 받는분 우편번호
        @AuraEnabled public String CONSIGNEE_PostalCode;

        // 결제방식
        @AuraEnabled public String PaymentMethod;
        // 결제금액
        @AuraEnabled public Decimal PaymentAmount;
        // 결제여부
        @AuraEnabled public String PaymentYN;

        // 부서명
        @AuraEnabled public String ConsultantDIV;
        // 상담사사번
        @AuraEnabled public String ConsultantEmployeeNumber;
        // 상담사
        @AuraEnabled public String ConsultantUser;
        // 상담내용
        @AuraEnabled public String CaseDescription;
        // Case Id
        @AuraEnabled public String CaseId;

        // 소모품 배송 메시지
        @AuraEnabled public String DeliveryMessageContent;

        // 반품 요청 일시
        @AuraEnabled public Date ReturnRequestedDateTime;

        // 임시 External Key
        @AuraEnabled public String TempExternalKey;

        // 23.04.07
        @AuraEnabled public String OBSReturnOrderNumber;

        // 23.05.02 반품 환불 은행 코드
        @AuraEnabled public String ReturnOrderBankCode;
        // 23.05.02 반품 환불 은행 이름
        @AuraEnabled public String ReturnOrderBankAccountNo;
        // 23.05.02 반품 환불 검증 이름
        @AuraEnabled public String ReturnOrderReceiverName;

        // 23.05.03 / 반품 환불 관련 금액 필드 추가
        @AuraEnabled public Decimal ReturnSaleAmount; // 반품판매금액
        @AuraEnabled public Decimal ReturnPaymentAmount; // 반품결제금액
        @AuraEnabled public Decimal ReturnDiscountAmount; // 반품할인금액

        @AuraEnabled public Decimal ReturnCardPaymentAmount; // 반품카드결제금액
        @AuraEnabled public Decimal ReturnVBankPaymentAmount; // 반품가상계좌결제금액
        @AuraEnabled public Decimal ReturnPointAmount; // 반품포인트금액

        @AuraEnabled public Decimal ConsumerPrice; // 반품포인트금액

        // Item Table
        @AuraEnabled public List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable> ConsumableReturnOrderLineItemTables;
    }

    /**
     * @description 임시 External Key 생성하기 위한 랜덤 스트링 함수
     * @author 23.02.09 / I2MAX.SEOKHOLEE
     * @return String
     *
     */
    public static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz!@#$^&*&';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx + 1);
        }
        return randStr;
    }

    public static Map<String, Integer> getSubNumberMap(List<sObject> lineItemList) {
        String sObjectType = null, orderNumber = null, orderSeq = null;
        String basisOrderNumber = null, subNumber = null, baseFormat = null;
        Map<String, Integer> subNumberMap = new Map<String, Integer>();
        Map<String, ProductRequestLineItem> boIdBoMap = new Map<String, ProductRequestLineItem>();
        Set<String> basisOrderIdSet = new Set<String>();
        Set<String> subNumberSet = new Set<String>();
        List<ProductRequestLineItem> prLiList = null;
        List<ReturnOrderLineItem> roLiList = null;
        ProductRequestLineItem tmpPrLi = null;
        ReturnOrderLineItem tmpRoLi = null;
        Integer curValue = 0, mapValue = 0;

        System.debug('cu lineItemList : ' + lineItemList);
        for (sObject lineItem : lineItemList) {
            sObjectType = String.valueOf(lineItem.getSObjectType());
            switch on sObjectType {
                // 교환주문건 BASIS_Order 쿼리용
                when 'ProductRequestLineItem' {
                    tmpPrLi = (ProductRequestLineItem) lineItem;
                    System.debug('tmpPrLi.BASIS_Order_Item_Id__c -> ' + tmpPrLi.BASIS_Order_Item_Id__c);

                    if (tmpPrLi.BASIS_Order_Item_Id__c != null) {
                        basisOrderIdSet.add(tmpPrLi.BASIS_Order_Item_Id__c);
                    }
                }
                // 05.21
                // 반품 주문번호와 원주문 주문번호 다를 떄
                when 'ReturnOrderLineItem' {
                    tmpRoLi = (ReturnOrderLineItem) lineItem;

                    if (tmpRoLi.ProductRequestLineItemId != null) {
                        basisOrderIdSet.add(tmpRoLi.ProductRequestLineItemId);
                    }
                }
                when else {
                }
            }
        }

        List<ProductRequestLineItem> boList = [
                SELECT Id, Order_Number__c, Order_SEQ__c, BASIS_Order_Item_Id__c, BASIS_Order_Item_Id__r.Order_Number__c
                FROM ProductRequestLineItem
                WHERE Id = :basisOrderIdSet
        ];

        for (ProductRequestLineItem bo : boList) {
            if (!boIdBoMap.containsKey(bo.Id)) {
                boIdBoMap.put(bo.Id, bo);
            }
        }
        System.debug('boIdBoMap : ' + boIdBoMap);
        for (sObject lineItem : lineItemList) {
            sObjectType = String.valueOf(lineItem.getSObjectType());
            switch on sObjectType {
                // 교환주문건 BASIS_Order_Id__r
                when 'ProductRequestLineItem' {
                    tmpPrLi = (ProductRequestLineItem) lineItem;
                    System.debug('tmpPrLi : ' + tmpPrLi);
                    if (tmpPrLi.BASIS_Order_Item_Id__c != null && boIdBoMap.containsKey(tmpPrLi.BASIS_Order_Item_Id__c)) {
                        System.debug('contains bo');
                        tmpPrLi.BASIS_Order_Item_Id__r = boIdBoMap.get(tmpPrLi.BASIS_Order_Item_Id__c);
                    }
                }
                when 'ReturnOrderLineItem' {
                    tmpRoLi = (ReturnOrderLineItem) lineItem;
                    if (tmpRoLi.ProductRequestLineItemId != null && boIdBoMap.containsKey(tmpRoLi.ProductRequestLineItemId)) {
                        System.debug('contains bo roLi');
                        tmpRoLi.ProductRequestLineItem = boIdBoMap.get(tmpRoLi.ProductRequestLineItemId);
                    }
                }
                when else {
                }
            }
        }

        for (sObject lineItem : lineItemList) {
            sObjectType = String.valueOf(lineItem.getSObjectType());

            switch on sObjectType {
                when 'ProductRequestLineItem' {
                    tmpPrLi = (ProductRequestLineItem) lineItem;
                    orderNumber = tmpPrLi.Order_Number__c;
                    basisOrderNumber = tmpPrLi.BASIS_Order_Item_Id__r == null
                            ? null
                            : tmpPrLi.BASIS_Order_Item_Id__r.Order_Number__c;
                    orderSeq = String.valueOf(tmpPrLi.Order_SEQ__c);
                }
                when 'ReturnOrderLineItem' {
                    tmpRoLi = (ReturnOrderLineItem) lineItem;
                    orderNumber = tmpRoLi.Order_Number__c;
                    basisOrderNumber = tmpRoLi.ProductRequestLineItem != null
                            ? tmpRoLi.ProductRequestLineItem.Order_Number__c
                            : null;
                    orderSeq = String.valueOf(tmpRoLi.ProductRequestLineItem.Order_SEQ__c);
                }
                when else {
                }
            }

            // 원주문건 존재 할 경우 원주문번호 저장
            System.debug('orderSeq : ' + orderSeq);
            if (basisOrderNumber != null) {
                System.debug('원주문 존재');
                subNumberSet.add(basisOrderNumber + '-' + ('000000' + orderSeq).right(Math.max(orderSeq.length(), 3)) + '%');
            }
            subNumberSet.add(orderNumber + '-' + ('000000' + orderSeq).right(Math.max(orderSeq.length(), 3)) + '%');
        }

        System.debug('subNumberSet : ' + subNumberSet);
        prLiList = [
                SELECT Id, SUB_Order_Number__c
                FROM ProductRequestLineItem
                WHERE SUB_Order_Number__c LIKE :subNumberSet
                AND Consumables_Order_YN__c = TRUE
                AND Parent.Consumables_Order_USE_YN__c = TRUE
                // AND RecordType.DeveloperName != 'RESV'
                AND Consumables_Order_Class_Code__c != 'PO'
        ];
        roLiList = [
                SELECT Id, SUB_Order_Number__c, ProductRequestLineItem.Order_Number__c
                FROM ReturnOrderLineItem
                WHERE SUB_Order_Number__c LIKE :subNumberSet
                AND Consumables_Order_YN__c = TRUE
                AND RecordType.DeveloperName = 'Consumable'
        ];

        System.debug('prLiList : ' + prLiList);
        System.debug('roLiList : ' + roLiList);

        for (ProductRequestLineItem prLi : prLiList) {
            subNumber = prLi.SUB_Order_Number__c;
            System.debug('subNumber :: ' + subNumber);
            if (!subNumber.contains('-')) continue;
            if (subNumber.split('-').size() < 3) continue;

            // orderNumber = subNumber.split('-')[0];
            // orderSeq = subNumber.split('-')[1];
            orderSeq = subNumber.split('-')[subNumber.split('-').size() - 2];
            // orderNumber = subNumber.substring(0, subNumber.indexOf(orderSeq)-1);
            orderNumber = subNumber.substring(0, subNumber.lastIndexOf('-' + orderSeq + '-'));
            baseFormat = orderNumber + '-' + orderSeq;
            curValue = Integer.valueOf(subNumber.split('-')[subNumber.split('-').size() - 1]);
            System.debug('orderNumber :: ' + orderNumber);
            System.debug('orderSeq :: ' + orderSeq);

            if (!subNumberMap.containsKey(baseFormat)) {
                subNumberMap.put(baseFormat, curValue);
            } else {
                mapValue = subNumberMap.get(baseFormat);
                subNumberMap.put(baseFormat, Math.max(mapValue, curValue));
            }
        }
        for (ReturnOrderLineItem roLi : roLiList) {
            subNumber = roLi.SUB_Order_Number__c;
            if (!subNumber.contains('-')) continue;
            if (subNumber.split('-').size() < 3) continue;

            // orderNumber = subNumber.split('-')[0];
            // orderSeq = subNumber.split('-')[1];
            orderSeq = subNumber.split('-')[subNumber.split('-').size() - 2];
            // orderNumber = subNumber.substring(0, subNumber.indexOf(orderSeq)-1);
            orderNumber = subNumber.substring(0, subNumber.lastIndexOf('-' + orderSeq + '-'));
            baseFormat = orderNumber + '-' + orderSeq;
            curValue = Integer.valueOf(subNumber.split('-')[subNumber.split('-').size() - 1]);
            if (!subNumberMap.containsKey(baseFormat)) {
                subNumberMap.put(baseFormat, curValue);
            } else {
                mapValue = subNumberMap.get(baseFormat);
                subNumberMap.put(baseFormat, Math.max(mapValue, curValue));
            }
        }
        System.debug('subNumberMap :: ' + subNumberMap);
        System.debug('subNumberSet :: ' + subNumberSet);

        // 원주문건은 0로
        for (String str : subNumberSet) {
            System.debug('str : ' + str);
            str = str.replace('%', '');
            if (!subNumberMap.containsKey(str)) {
                System.debug('!containsKey');
                subNumberMap.put(str, 0);
            }
        }
        System.debug('subNumberMap : ' + subNumberMap);

        return subNumberMap;
    }
    /**
     * @description 원주문에 추가적인 액션으로 생성된 LineItem 서브번호 채번로직
     * @author 23.02.14 / I2MAX.SEUNGHUNAHN
     * @param Map<String, Integer> subNumberMap, sObject lineItem
     * @return String subNumber;
     *
     */
    public static String getSubNumber(Map<String, Integer> subNumberMap, sObject lineItem) {
        String sObjectType = String.valueOf(lineItem.getSObjectType()), orderNumber = null, orderSeq = null;
        String baseFormat = null;
        ProductRequestLineItem prLi = null;
        ReturnOrderLineItem roLi = null;
        Integer maxVal = 0;

        //System.debug('subNumberMap : ' + subNumberMap);

        switch on sObjectType {
            when 'ProductRequestLineItem' {
                prLi = (ProductRequestLineItem) lineItem;
                System.debug('prLi : ' + lineItem);
                if (prLi.BASIS_Order_Item_Id__r == null) {
                    orderNumber = prLi.Order_Number__c;
                    orderSeq = String.valueOf(prLi.Order_SEQ__c);
                    orderSeq = ('000000' + orderSeq).right(Math.max(orderSeq.length(), 3));
                    System.debug('basisOrderItem null');
                } else {
                    orderNumber = prLi.BASIS_Order_Item_Id__r.Order_Number__c;
                    orderSeq = String.valueOf(prLi.BASIS_Order_Item_Id__r.Order_SEQ__c);
                    orderSeq = ('000000' + orderSeq).right(Math.max(orderSeq.length(), 3));
                    System.debug('basisOrderItem not null');
                }
                System.debug('orderNumber : ' + orderNumber);
                System.debug('orderSeq : ' + orderSeq);

                baseFormat = orderNumber + '-' + orderSeq;
                System.debug('baseFormat : ' + baseFormat);
                if (subNumberMap.containsKey(baseFormat)) {
                    maxVal = Integer.valueOf(subNumberMap.get(baseFormat));
                    subNumberMap.put(baseFormat, maxVal + 1);
                    // baseFormat += '-' + ('000000' + (maxVal+1)).right(2);
                    // if (baseFormat.split('-').size() < 3) return 'INVALID_FORMAT';
                    // return baseFormat.split('-')[2].equals('01') ? baseFormat : 'ㄴ' + baseFormat;
                    return baseFormat + '-' + ('000000' + (maxVal + 1)).right(2);
                } else {
                    return 'PRLI_ERR';
                }
            }
            when 'ReturnOrderLineItem' {
                roLi = (ReturnOrderLineItem) lineItem;
                orderNumber = roLi.ProductRequestLineItem == null
                        ? roLi.Order_Number__c
                        : roLi.ProductRequestLineItem.Order_Number__c;
                orderSeq = ('000000' + roLi.ProductRequestLineItem.Order_SEQ__c).right(Math.max(String.valueOf(roLi.ProductRequestLineItem.Order_SEQ__c).length(), 3));
                baseFormat = orderNumber + '-' + orderSeq;
                if (subNumberMap.containsKey(baseFormat)) {
                    maxVal = Integer.valueOf(subNumberMap.get(baseFormat));
                    subNumberMap.put(baseFormat, maxVal + 1);
                    // baseFormat += '-' + ('000000' + (maxVal+1)).right(2);
                    // if (baseFormat.split('-').size() < 3) return 'INVALID_FORMAT';
                    // return baseFormat.split('-')[2].equals('01') ? baseFormat : 'ㄴ' + baseFormat;
                    return baseFormat + '-' + ('000000' + (maxVal + 1)).right(2);
                } else {
                    return 'ROLI_ERR';
                }
            }
            when else {
            }
        }
        return 'INVALID_SOBJECT_TYPE';
    }

    /**
    * @description 판매저장
    * @author 23.03.01 / I2MAX.SEUNGHUNAN
    * @return Map<String, String> rtnMap
    */
    public static Map<String, Object> doSaveSales2(Map<String, Object> paramMap, List<ProductRequest> prList) {
        Map<String, Object> rtnMap = new Map<String, Object>();

        // 현재 메소드가 실행되고 있는 위치
        String caller = (String)paramMap.get('caller');
        List<SI_CAREPLUS_BACKIF__c> backIFList = new List<SI_CAREPLUS_BACKIF__c>();
        //24 03 05 hyungho.chun prlilist도 모수받은 100개의 pr기준으로 다시쿼리해야한다
        // List<ProductRequestLineItem> prLiList = (List<ProductRequestLineItem>) paramMap.get('prLiList');

        //@@@@@@@@@@@@@@@@@@@@24 03 05 배치사이즈에맞는 모수 새로잡음
        Set<String> currentPrListId = new Set<String>(); 
        List<String> orderNumberList = new List<String>(); //24 03 07 hyungho.chun
        for(ProductRequest item :prList){  
            currentPrListId.add(item.Id);
            orderNumberList.add(item.Order_Number__c);
        }
        System.debug('currentPrListId size :: '+ currentPrListId.size());

        List<String> productRequestFields = SObjectUtil.getAllFields('ProductRequest');
        String prFields = '';
        for(String field : productRequestFields){
            if(field != 'Order_CUST_Id__c'){
                prFields += ', Parent.'+field+' ';
            }
        }
        System.debug('prFields :: '+prFields);
        
        String queryTemp = 'SELECT '+ SObjectUtil.getFieldForQuery('ProductRequestLineItem') +' \n' +
                '                        ,BASIS_Order_Item_Id__r.Order_Number__c, BASIS_Order_Item_Id__r.Consumables_Business_Type_Code__c, BASIS_Order_Item_Id__r.parent.PAYMENT_Amount__c, BASIS_Order_Item_Id__r.parent.Order_CUST_Id__c, BASIS_Order_Item_Id__r.parent.CARD_PAYMENT_Amount__c, BASIS_Order_Item_Id__r.parent.CASH_PAYMENT_Amount__c, BASIS_Order_Item_Id__r.parent.POINT_Amount__c, RecordType.DeveloperName, \n'+
                '                        BASIS_Order_Item_Id__r.Payment_Amount__c,BASIS_Order_Item_Id__r.SALE_Quantity__c, BASIS_Order_Item_Id__r.Exchange_Quantity__c, BASIS_Order_Item_Id__r.Order_CUST_Id__c, BASIS_Order_Item_Id__r.CARD_PAYMENT_Amount__c, BASIS_Order_Item_Id__r.CASH_PAYMENT_Amount__c, BASIS_Order_Item_Id__r.POINT_Amount__c, BASIS_Order_Item_Id__r.parent.PAYMENT_TYPE__c,\n'+
                '                        Parent.Order_CUST_Id__r.Phone, Parent.Order_CUST_Id__r.MobilePhone, Parent.Order_CUST_Id__r.Name, Product2.DIV_CODE__c,Product2.Name \n' +
                                         prFields;
        queryTemp += 'FROM ProductRequestLineItem ';
        queryTemp += 'WHERE ParentId IN: currentPrListId ';
        queryTemp += 'ORDER BY POINT_TRX_ID__c';

        
        System.debug('queryTemp :: '+queryTemp);
        List<ProductRequestLineItem> prLiList = Database.query(queryTemp);
        System.debug('prli size :: '+prLiList.size());
        //@@@@@@@@@@@@@@@@@@@@@@@@@@@

        //24 03 20 hyungho.chun 판메예약(RESV_SALE) pr 및 prli에 srSale 및 정리수량 정보도 판매저장때 업데이트하기위한 맵핑
        Set<String> currentPrLiListId = new Set<String>();
        for(ProductRequestLineItem item :prLiList){
            currentPrLiListId.add(item.Id);
        }
        Map<Id, ProductRequestLineItem> resvPrLiMap = new Map<Id, ProductRequestLineItem>([SELECT Id,ParentId,BASIS_Order_Item_Id__c,BASIS_Order_Item_Id__r.ParentId,QuantityRequested FROM ProductRequestLineItem WHERE RecordTypeId =: PRLI_RESV_SALE_RECORDTYPE_ID AND BASIS_Order_Item_Id__c IN: currentPrLiListId]);
        Map<String, ProductRequestLineItem> oriPrliAndResvMap = new Map<String, ProductRequestLineItem>(); //24 03 20 hyungho.chun (원 prli Id / 판매예약 prli )
        Map<String, ProductRequest> oriPrAndResvMap = new Map<String, ProductRequest>(); //24 03 20 hyunho.chun (원 pr Id / 판매예약 pr )
        Set<String> parentIdSet = new Set<String>();
        List<ProductRequest> updateResvPrList = new List<ProductRequest>();
        List<ProductRequestLineItem> updateResvPrLiList = new List<ProductRequestLineItem>();
        System.debug('resvPrLiMap size :: '+ resvPrLiMap.size());
            if(resvPrLiMap.size()>0){                
                for(ProductRequestLineItem item : resvPrLiMap.values()){
                    parentIdSet.add(item.ParentId);
                }
                Map<Id, ProductRequest> resvPrMap = new Map<Id, ProductRequest>([SELECT Id FROM ProductRequest WHERE Id IN: parentIdSet]);
                for(ProductRequestLineItem item : resvPrLiMap.values()){
                    oriPrliAndResvMap.put(item.BASIS_Order_Item_Id__c, item);
                    oriPrAndResvMap.put(item.BASIS_Order_Item_Id__r.ParentId, resvPrMap.get(item.ParentId));
                }
            }

        // 판매정보 재쿼리 하기 위해 아이디 저장하는 리스트 (트리거에 채번로직이 있음)
        List<String> srSaleIdList = new List<String>();
        List<SR_SALE__c> upsertSrSaleList = new List<SR_SALE__c>();
        List<ProductRequest> upsertSalePrList = new List<ProductRequest>();
        List<ProductRequestLineItem> upsertSalePrLiList = new List<ProductRequestLineItem>();
        List<ProductTransfer> upsertPrTrList = new List<ProductTransfer>();
        List<String> piKeyList = null;

        // 판매저장 진행하면서 실패한 주문번호 담아놓는 List
        List<String> salesFailOrderNumberList = (List<String>) paramMap.get('salesFailOrderNumberList');
        // 비동기 처리 에러 로깅할 수 있도록 만드는 레코드 리스트
        List<SR_ONLINE_AUTO_SALE_EXC__c> failRecordList = new List<SR_ONLINE_AUTO_SALE_EXC__c>();
        // 실패건들 Pass하면서 진행하다가 마지막 원 주문시에는 실패건들 제외하고 성공 건들만 이 리스트들에 담아서 DML 처리
        List<ProductRequest> prListForUpdate = new List<ProductRequest>();
        List<ProductRequestLineItem> prLiListForUpdate = new List<ProductRequestLineItem>();
        List<SR_PRE_PAYMENT_DETAIL__c> detailList = null;
        List<SR_PRE_PAYMENT_DETAIL__c> deleteDetailList = new List<SR_PRE_PAYMENT_DETAIL__c>();

        Set<String> headerIdSet = new Set<String>();

        // 판매저장 대상 주문번호 리스트, 결제 정보 중 Header 리스트 조회 시 사용
        // List<String> orderNumberList = (List<String>) paramMap.get('orderNumberList'); //24 03 07 hyungho.chun 이번모수만의 orderNum만 받아야하는데 전체모수를 받아오고있었음 위에 재조회로직에 위치이동시킴

        //23 12 04 hyungho.chun 판매저장 try-catch rollback작업
        Map<String,String> errorMap = new Map<String,String>();
        Savepoint sp = Database.setSavepoint();
        
        try{
            // 임직원 소속 회사코드 - 한글명 Map
            // 23 08 07 hyungho.chun USE_YN__c = Y 추가 (ATTRIBUTE1__c가 040으로 같은 'LG전자','하이로지스틱스' SM_CODE__c가 존재)
            Map<String, String> empCompanyCodeKORMap = new Map<String, String>();
            for (SM_CODE__c smCode : [
                    SELECT ATTRIBUTE1__c, CODE_NAME__c
                    FROM SM_CODE__c
                    WHERE CLASS_CODE__r.Name = 'UD009' AND USE_YN__c = 'Y'
            ]) {
                // 000 - 주)LG
                empCompanyCodeKORMap.put(smCode.ATTRIBUTE1__c, smCode.CODE_NAME__c);
            }

            /**
             *   Key: Order_Number    Value: List<ProductRequestLineItem>
             *   주문번호에 달린 품목(LineItem List)
             */
            Map<String, List<ProductRequestLineItem>> orderNumberPrLiMap = (Map<String, List<ProductRequestLineItem>>) paramMap.get('orderNumberPrLiMap');
            System.debug('orderNumberPrLiMap execute : ' + orderNumberPrLiMap);
            /**
             *   Key: ProductRequest Id    Value: SR_SALE__c
             *   ProductRequestId와 SR_SALE__c를 연결해두고 SALE 타입 PR 생성, 원 PR 업데이트 등에
             *   판매정보를 저장할 때 사용한다.
             */
            Map<String, SR_SALE__c> prIdSrSaleMap = new Map<String, SR_SALE__c>();

            /**
             *   Key: SR_SALE__c Id    Value: SR_SALE__c
             *   SR_SALE__c Id와 SR_SALE__c을 연결해두는 맵 기존 PR은 SALE_Number__c가 없는
             *   SR_SALE__c와 Lookup이라 Insert 후 판매번호가 생성된 Obj와 대체하기 위해 사용
             */
            Map<String, SR_SALE__c> srSaleIdSrSaleMap = new Map<String, SR_SALE__c>();

            /**
             *   Key: ProductRequestId    Value: ProductRequest (SALE Type)
             *   기존 소모품 타입 PR과 SALE 타입 PR을 연결해주는 맵
             *   SALE Type PRLI를 만들 때 ParentId의 값으로 사용
             */
            Map<String, ProductRequest> prIdSalePrMap = new Map<String, ProductRequest>();
            /**
             *   Key: OrderNumber    Value: PiKeyList
             *   주문번호와 수불처리에 사용되는 Pikey(prLi.SourceLocationId + '^' + prLi.Product2Id)
             *   리스트를 맵으로 구성한 후에 실패한 주문번호들은 자재쪽 수불처리에서 제외하기 위해 사용
             */
            Map<String, List<String>> orderNumberPiKeyListMap = new Map<String, List<String>>();
            Map<String, Decimal> orderNumberPaymentAmtMap = (Map<String, Decimal>) paramMap.get('orderNumberPaymentAmtMap');
            Map<String, Decimal> orderNumberDiscountAmtMap = (Map<String, Decimal>) paramMap.get('orderNumberDiscountAmtMap');
            Map<String, SR_PRE_PAYMENT_HEADER__c> headerIdHeaderMap = new Map<String, SR_PRE_PAYMENT_HEADER__c>();
            System.debug('prList : ' + prList);
            System.debug('prList size : ' + prList.size());
            for (ProductRequest pr : prList) {
                SR_SALE__c srSale = new SR_SALE__c();
                srSale.deficitCheck__c = false;
                srSale.Buyer_Type_Code__c = 'C';
                srSale.Department_Code__c = pr.Department_Code__c;
                srSale.Department_Id__c = pr.Department_Id__c;
                srSale.Contact__c = pr.Order_CUST_Id__c != null
                        ? pr.Order_CUST_Id__c
                        : null;
                srSale.Buyer_Code__c = pr.Order_CUST_Id__r.MobilePhone != null
                        ? pr.Order_CUST_Id__r.MobilePhone
                        : pr.Order_CUST_Id__r.Phone != null
                                ? pr.Order_CUST_Id__r.Phone
                                : null;
                srSale.Buyer_Name__c = pr.Order_CUST_Id__r.Name != null
                        ? pr.Order_CUST_Id__r.Name
                        : null;
                srSale.SALE_DTM__c = System.today();
                srSale.Total_DEPOSIT_Amount__c = 0;
                // srSale.Total_SALE_Amount__c = pr.SALE_Amount__c;
                srSale.Total_SALE_Amount__c = orderNumberPaymentAmtMap.get(pr.Order_Number__c);
                // srSale.Discount_Amount__c = pr.Discount_Amount__c;
                srSale.Discount_Amount__c = orderNumberDiscountAmtMap.get(pr.Order_Number__c);
                srSale.MCS_YN__c = 'N';
                // ?
                srSale.Inhouse_Service_YN__c = 'N';
                if (orderNumberPrLiMap.containsKey(pr.Order_Number__c)) {
                    for (ProductRequestLineItem prLi : orderNumberPrLiMap.get(pr.Order_Number__c)) {
                        srSale.SALE_Discount_Type_Code__c = prLi.SALE_Discount_Type_Code__c;
                    }
                }
                // srSale.SALE_Discount_Type_Code__c = pr.SALE_DC_TYPE__c;

                srSale.Consumables_Order_YN__c = true;
                srSale.Order_Number__c = pr.Order_Number__c;
                srSale.Order_CHNL_TYPE_Code__c = pr.Order_CHNL_TYPE_Code__c;

                srSale.paymentYN__c = true;

                // if (pr.Order_Number__c == 'O230001413597') {
                //     srSale.VIRTUAL_ACCT_Number__c = 'ERRORERRORERRORERRORERRORERROR';
                // }

                // 예약 부품 연결
                if (pr.SR_RSRV_PART_Id__c != null) {
                    srSale.SR_RESRV_PART_Id__c = pr.SR_RSRV_PART_Id__c;
                    srSale.RSRV_Number__c = pr.RSRV_Number__c;
                }
            
                //23 11 29 hyungho.chun srSale.Consumables_Order_Type_Code__c 채번 로직 변경
                // switch on pr.Order_CHNL_TYPE_Code__c {
                //     // 대표사이트
                //     when 'B' {
                //         srSale.Consumables_Order_Type_Code__c = 'B';
                //     }
                //     // ThinQ
                //     when 'S' {
                //         srSale.Consumables_Order_Type_Code__c = 'S';
                //     }
                //     // 소모품 택배
                //     when 'V' {
                //         srSale.Consumables_Order_Type_Code__c = 'V';
                //     }
                //     when 'BestShop' {
                //         srSale.Consumables_Order_Type_Code__c = 'BestShop';
                //     }
                // }

                switch on pr.Order_CHNL_TYPE_Code__c {
                    // 대표사이트
                    when 'B' {
                        srSale.Consumables_Order_Type_Code__c = pr.fm_funnel__c =='T' ? 'S' : 'B';
                    }
                    // ThinQ
                    when 'S' {
                        srSale.Consumables_Order_Type_Code__c = 'S';
                    }
                    // 소모품 택배
                    when 'V' {
                        srSale.Consumables_Order_Type_Code__c = pr.CaseId != null ? 'C' : 'G';
                    }
                    when 'BestShop' {
                        srSale.Consumables_Order_Type_Code__c = 'BestShop';
                    }
                    when 'Y' {
                        srSale.Consumables_Order_Type_Code__c = 'Y';
                    }                
                }
                

                prIdSrSaleMap.put(pr.Id, srSale);
                upsertSrSaleList.add(srSale);

                system.debug('prIdSrSaleMap :'+prIdSrSaleMap);
                system.debug('upsertSrSaleList'+upsertSrSaleList);
            }
            failRecordList.addAll(checkFail(upsertSrSaleList,
                    salesFailOrderNumberList,
                    'SR_SALE__c 생성 실패, '));
            System.debug('판매정보 생성 후 failRecordList : ' + failRecordList);
            System.debug('판매정보 생성 후 salesFailOrderNumberList : ' + salesFailOrderNumberList);

            system.debug('checkfail 후 ::: upsertSrSaleList'+upsertSrSaleList);

            for (SR_SALE__c src : upsertSrSaleList) {
                // 실패건 제외
                //23 08 10 hyungho.chun salesFailOrderNumberList != null 추가
                if (salesFailOrderNumberList != null &&salesFailOrderNumberList.contains(src.Order_Number__c)) continue;

                system.debug('src.Id ::'+src.Id);
                srSaleIdList.add(src.Id);
            }

            // SALE_Number__c 재쿼리
            upsertSrSaleList = [
                    SELECT Id, SALE_Number__c, Total_SALE_Amount__c, SALE_DTM__c
                    FROM SR_SALE__c
                    WHERE Id IN:srSaleIdList
            ];
            for (SR_SALE__c srSale : upsertSrSaleList) {
                srSaleIdSrSaleMap.put(srSale.Id, srSale);
            }

            // 기존 prIdSrSaleMap에 있던 SR_SALE__c를 트리거를 거쳐 SALE_Number__c가 생성된
            // SR_SALE__c로 대체
            // 위에 판매정보 생성에 실패한 ProductRequest Id가 키로 포함되더라도
            // 영향 없을 것 같아서 진행하도록 둠.
            for (String prId : prIdSrSaleMap.keySet()) {
                String srSaleId = prIdSrSaleMap.get(prId).Id;
                if (srSaleIdSrSaleMap.containsKey(srSaleId)) {
                    prIdSrSaleMap.put(prId, srSaleIdSrSaleMap.get(srSaleId));
                }
            }

            // 채권생성 시 ProductRequest Id -> SR_SALE__c Id 변경하기 위함
            paramMap.put('prIdSrSaleMap', prIdSrSaleMap);

            // =============================== SALE Type ProductRequest 생성 ===============================
            //23 10 11 hyungho.chun 10월이전까지 SALE product request 만들던부분-------------------------------------------------------------------------------------------------------시작
            // for (ProductRequest pr : prList) {
                //실패건 제외
                //23 08 10 hyungho.chun salesFailOrderNumberList != null 추가
                // if (salesFailOrderNumberList != null && salesFailOrderNumberList.contains(pr.Order_Number__c)) continue;

                // ProductRequest salePr = new ProductRequest();
                // salePr.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
                // salePr.Order_Number__c = pr.Order_Number__c;
                // if (pr.Order_Number__c == 'O230001413599') {
                    // salePR.BILL_TO_CODE__c = 'ERRORERRORERRORERRORERRORERROR';
                // }
                // salePr.Order_Date__c = System.today();
                // salePr.Order_CHNL_TYPE_Code__c = pr.Order_CHNL_TYPE_Code__c;
                // salePr.Consumables_Order_YN__c = pr.Consumables_Order_YN__c;
                // salePr.Requester_Code__c = pr.Requester_Code__c;
                //23 10 02 hyungho.chun
                // salePr.BASIS_Order_Item_Id__c = pr.BASIS_Order_Item_Id__c != null ? pr.BASIS_Order_Item_Id__c : null;
                
                // if (prIdSrSaleMap.containsKey(pr.Id)) {
                    // SR_SALE__c srSale = prIdSrSaleMap.get(pr.Id);
                    // salePr.SR_SALE__c = srSale.Id;
                    // salePr.SALE_Number__c = srSale.SALE_Number__c;

                    //원 주문건
                    // pr.SR_SALE__c = srSale.Id;
                    // pr.SALE_Number__c = srSale.SALE_Number__c;
                    // System.debug('원주문 Pr : ' + pr);
                // }

                // salePr.Order_CUST_Id__c = pr.Order_CUST_Id__c;
                // salePr.Department_Id__c = pr.Department_Id__c;
                // salePr.Department_Code__c = pr.Department_Code__c;
                // salePr.Order_Req_Dept_Type_Code__c = 'C';
                // salePr.Status = '제출됨';

                //PG사 정보
                // salePr.MOID__c = pr.MOID__c;
                // salePr.APPR_NUM__c = pr.APPR_NUM__c;
                // salePr.APPR_DT__c = pr.APPR_DT__c;
                // salePr.TID__c = pr.TID__c;

                // salePr.SourceLocationId = pr.SourceLocationId;

                //결제 정보
                // salePr.PAYMENT_Amount__c = pr.PAYMENT_Amount__c;
                // salePr.PAYMENT_Method_Code__c = pr.PAYMENT_Method_Code__c;
                // salePr.PAYMENT_TYPE__c = pr.PAYMENT_TYPE__c;
                // salePr.PAYMENT_COMPLETED_DTM__c = pr.PAYMENT_COMPLETED_DTM__c;

                // salePr.CARD_PAYMENT_Amount__c = pr.CARD_PAYMENT_Amount__c;
                // salePr.CASH_PAYMENT_Amount__c = pr.CASH_PAYMENT_Amount__c;
                // salePr.POINT_Amount__c = pr.POINT_Amount__c;
                // salePr.PARCEL_FEE_Amount__c = pr.PARCEL_FEE_Amount__c;

                // salePr.SALE_Amount__c = pr.SALE_Amount__c;
                // salePr.Discount_Amount__c = pr.Discount_Amount__c;

                // if (pr.SR_RSRV_PART_Id__c != null) {
                //     salePr.SR_RSRV_PART_Id__c = pr.SR_RSRV_PART_Id__c;
                //     salePr.RSRV_Number__c = pr.RSRV_Number__c;
                // }

                // if (!prIdSalePrMap.containsKey(pr.Id)) {
                //     prIdSalePrMap.put(pr.Id, salePr);
                // }

                // upsertSalePrList.add(salePr);
            // }
            //23 10 11 hyungho.chun 23/10/11이전까지 SALE product request 만들던부분-------------------------------------------------------------------------------------------------------끝

            //23 10 11 hyungho.chun 23/10/11이후까지 SALE product request 만들던부분-------------------------------------------------------------------------------------------------------시작
            for (ProductRequest pr : prList) {
                if (salesFailOrderNumberList != null && salesFailOrderNumberList.contains(pr.Order_Number__c)) continue;

                ProductRequest salePr = new ProductRequest();
                salePr = pr.clone();
                //23 10 30 hyungho.chun 새로생긴 필드 external id는 클론 뜰수없어서 제거
                salePr.External_id__c = null;            
                //23 10 26 hyungho.chun 이젠 교환주문도 Consumables_Business_Type_Code__c에 ExchangeReturn가 들어갈수있음! (재경요청)
                // salePr.Consumables_Business_Type_Code__c = salePr.Consumables_Business_Type_Code__c == 'ExchangeOrder' ? null: salePr.Consumables_Business_Type_Code__c;
                salePr.RecordTypeId = Schema.SObjectType.ProductRequest.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
                salePr.Order_Date__c = System.today();        
                
                if (prIdSrSaleMap.containsKey(pr.Id)) {
                    SR_SALE__c srSale = prIdSrSaleMap.get(pr.Id);
                    salePr.SR_SALE__c = srSale.Id;
                    salePr.SALE_Number__c = srSale.SALE_Number__c;

                    // 원 주문건
                    pr.SR_SALE__c = srSale.Id;
                    pr.SALE_Number__c = srSale.SALE_Number__c;
                    System.debug('원주문 Pr : ' + pr);

                    //24 03 20 hyungho.chun 판매예약건에도 sr_Sale연결!
                    if(oriPrAndResvMap.containskey(pr.Id)){
                        ProductRequest resvPrTemp = oriPrAndResvMap.get(pr.Id);
                        resvPrTemp.SR_SALE__c = srSale.Id;
                        resvPrTemp.SALE_Number__c = srSale.SALE_Number__c;
                        updateResvPrList.add(resvPrTemp);
                    }
                }
                salePr.Order_Req_Dept_Type_Code__c = 'C';
                salePr.Status = '제출됨';

                if (!prIdSalePrMap.containsKey(pr.Id)) {
                    prIdSalePrMap.put(pr.Id, salePr);
                }

                upsertSalePrList.add(salePr);
            }
            //23 10 11 hyungho.chun 23/10/11이후까지 SALE product request 만들던부분-------------------------------------------------------------------------------------------------------끝
            if(updateResvPrList.size()>0){
                update updateResvPrList; //24 03 20 hyungho.chun
            }
            


            failRecordList.addAll(checkFail(upsertSalePrList,
                    salesFailOrderNumberList,
                    'SALE Type ProductRequest 생성 실패, '));
            System.debug('SALE PR 생성 후 failRecordList : ' + failRecordList);
            System.debug('SALE PR 생성 후 salesFailOrderNumberList : ' + salesFailOrderNumberList);

            List<ProductRequestLineItem> updateOriPrliList = new List<ProductRequestLineItem>(); //24 03 05 hyungho.chun 원주문업데이트가 모수에맞는거만 제대로 안되고있었음
            
            //24 03 14 hyungho.chun 일반예약이면서 할당은 원부품에 잡히고 약속수량은 대치부품으로 잡힌경우 수불처리 예외케이스 대비용  / key : prli id , value : product2.name^Div_code
            Map<String, String> prliAndProductMap = new Map<String,String>(); 

            for (ProductRequest pr : prList) {
                Integer seq = 1;

                if (salesFailOrderNumberList != null && salesFailOrderNumberList.contains(pr.Order_Number__c)) continue;

                for (ProductRequestLineItem prLi : orderNumberPrLiMap.get(pr.Order_Number__c)) {
                    if (salesFailOrderNumberList != null && salesFailOrderNumberList.contains(prLi.Order_Number__c)) continue;

                    ProductRequestLineItem salePrLi  = new ProductRequestLineItem();
                    //23 12 07 hyungho.chun UnitPrice 판매저장때 넣어줌 (결제금액/수량)
                    prLi.UnitPrice__c = prLi.payment_amount__c/prLi.QuantityRequested;

                    //24 03 20 hyungho.chun 수기처리시 '임시조치' null 처리
                    prLi.ShipToStreet = null;

                    salePrLi = prLi.clone();
                    //23 10 30 hyungho.chun 새로생긴 필드 external id는 클론 뜰수없어서 제거
                    salePrLi.External_id__c = null;                
                    //23 10 26 hyungho.chun 이젠 교환주문도 Consumables_Business_Type_Code__c에 ExchangeReturn가 들어갈수있음! (재경요청)
                    // salePrLi.Consumables_Business_Type_Code__c = salePrLi.Consumables_Business_Type_Code__c == 'ExchangeOrder' ? null: salePrLi.Consumables_Business_Type_Code__c;
                    salePrLi.RecordTypeId = Schema.SObjectType.ProductRequestLineItem.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
                    salePrLi.ParentId = prIdSalePrMap.get(pr.Id).Id;

                    // 판매정보
                    if (prIdSrSaleMap.containsKey(pr.Id)) {
                        SR_SALE__c src = prIdSrSaleMap.get(pr.Id);
                        salePrLi.SR_SALE__c = src.Id;
                        salePrLi.SALE_Number__c = src.SALE_Number__c;
                        salePrLi.SALE_SEQ__c = seq++;
                        salePrLi.SALE_DTM__c = System.today();

                        // 원 주문건 업데이트
                        prLi.SR_SALE__C = src.Id;
                        prLi.SALE_Number__c = src.SALE_Number__c;

                        //24 03 20 hyungho.chun 판매예약건에도 sr_Sale연결!
                        if(oriPrliAndResvMap.containskey(prLi.Id)){
                            ProductRequestLineItem resvPrLiTemp = oriPrliAndResvMap.get(prLi.Id);
                            resvPrLiTemp.Last_Update_Date__c = System.now();
                            resvPrLiTemp.Adjust_Type__c  = 'B';
                            resvPrLiTemp.Adjust_Quantity__c = resvPrLiTemp.QuantityRequested;
                            resvPrLiTemp.SR_SALE__C = src.Id;
                            resvPrLiTemp.SALE_Number__c = src.SALE_Number__c;
                            updateResvPrLiList.add(resvPrLiTemp);
                        }
                    }

                    //24 03 07 hyungho.chun @@@@ prli의 예약기준으로 다시 if절해야해서 주석처리 @@@@(원인 : 예약과 일반이 같이있는 경우 일반품목에도 예약채번된다) @@@@@@@@@@@시작
                    // if (prLi.Parent.SR_RSRV_PART_Id__c != null) {
                    //     salePrLi.SR_RESRV_PART_Id__c = prLi.Parent.SR_RSRV_PART_Id__c;
                    //     prLi.SR_RESRV_PART_Id__c = prLi.Parent.SR_RSRV_PART_Id__c;

                    //     // ===== 기존 Consumable 타입 ProductRequestLineItem 예약정리 시작 =====
                    //     prLi.Adjust_Quantity__c = prLi.Adjust_Quantity__c == null ? 0 : prLi.Adjust_Quantity__c;
                    //     prLi.Adjust_Quantity__c += prLi.SALE_Quantity__c;
                    //     if (prLi.Adjust_Quantity__c == prLi.QuantityRequested) {
                    //         prLi.RSRV_Completion_YN__c = 'Y';
                    //     }
                    //     // ===== 기존 Consumable 타입 ProductRequestLineItem 예약정리 끝 =====

                    //     salePrLi.Adjust_Quantity__c = prLi.Adjust_Quantity__c;
                    //     salePrLi.RSRV_Completion_YN__c = prLi.RSRV_Completion_YN__c;
                    // }
                    //24 03 07 hyungho.chun @@@@ prli의 예약기준으로 다시 if절해야해서 주석처리 @@@@(원인 : 예약과 일반이 같이있는 경우 일반품목에도 예약채번된다) @@@@@@@@@@@끝

                    //24 03 07 hyungho.chun 위에 로직 고침 ->prLi.Parent.SR_RSRV_PART_Id__c 를 prLi.SR_RESRV_PART_Id__c 기준으로 변경
                    if (prLi.SR_RESRV_PART_Id__c  != null) {
                        // salePrLi.SR_RESRV_PART_Id__c = prLi.SR_RESRV_PART_Id__c ; //24 03 07 hyungho.chun 어차피 clone하기떄문에 필요없음
                        // prLi.SR_RESRV_PART_Id__c = prLi.SR_RESRV_PART_Id__c;

                        // ===== 기존 Consumable 타입 ProductRequestLineItem 예약정리 시작 =====
                        // prLi.Adjust_Quantity__c = prLi.Adjust_Quantity__c == null ? 0 : prLi.Adjust_Quantity__c; //24 03 07 hyungho.chun adjust_quantity 는 입고배치돌떄 오름/ 판매확정떈 올리지않는다
                        // prLi.Adjust_Quantity__c += prLi.SALE_Quantity__c;
                        prLi.Adjust_Quantity__c = prLi.Adjust_Quantity__c == null ? 0 : prLi.Adjust_Quantity__c; //24 03 09 hyungho.chun 정리수량은 사업부에서 받아온 수만큼 판매저장떄 증가한다
                        prLi.Adjust_Quantity__c += prLi.ENDP_RSV_Quantity__c;                        
                        // if (prLi.Adjust_Quantity__c == prLi.QuantityRequested) {
                        if (prLi.Adjust_Quantity__c == prLi.ENDP_RSV_Quantity__c) { //24 03 07 hyungho.chun 일반예약의 경우중에 부분적치장소 부분입고 주문 고려로 endp랑 비교로 수정
                            prLi.RSRV_Completion_YN__c = 'Y';
                        }
                        // ===== 기존 Consumable 타입 ProductRequestLineItem 예약정리 끝 =====

                        salePrLi.Adjust_Quantity__c = prLi.Adjust_Quantity__c;
                        salePrLi.RSRV_Completion_YN__c = prLi.RSRV_Completion_YN__c;
                    }




                    /**
                     *   5개 주문 후 2개 취소 한 다면 원주문의 QuantityRequested 5로 그대로다.
                     *   따라서 실제 판매된 양인 SALE_Quantity__c로 수정
                     */

                    salePrLi.QuantityRequested = prLi.SALE_Quantity__c;

                    salePrLi.PAYMENT_COMPLETED_DTM__c = prIdSalePrMap.containsKey(pr.Id)
                            ? prIdSalePrMap.get(pr.Id).PAYMENT_COMPLETED_DTM__c
                            : null;

                    // 230727 / 임직원 정보 추가
                    if(empCompanyCodeKORMap.containsKey(prli.Parent.EMP_COMPANY_CODE__c)) {
                        salePrli.Employees_Company__c = empCompanyCodeKORMap.get(prli.Parent.EMP_COMPANY_CODE__c);
                    }
                    salePrLi.Employees_Name__c = prli.Parent.EMP_NAME__c;
                    salePrLi.Employees_Number__c = prli.Parent.EMP_NO__c;

                    upsertSalePrLiList.add(salePrLi);

                    System.debug('PHJ =>? ' + salePrLi);
                    updateOriPrliList.add(prLi);

                    //24 03 14 hyungho.chun 일반예약이면서 할당은 원부품에 잡히고 약속수량은 대치부품으로 잡힌경우 수불처리 예외케이스
                    if(prLi.SR_RESRV_PART_Id__c != null && prLi.QuantityRequested > prLi.ENDP_RSV_Quantity__c && prLi.ENDP_RSV_Quantity__c != 0 && prli.Consumables_Order_Class_Code__c == 'General' && prli.PART_NO__c != prli.BASIS_Parts_Number__c){
                        prliAndProductMap.put(prLi.Id , prLi.BASIS_Parts_Number__c+'^'+prLi.ENDP_Code__c); // prli id , 원부품name + 사업부코드(사업부는 대치여도 바뀌지않아서 새로들어온 사업부코드를 써도 무관)
                    }
                }
            }
            if(updateResvPrLiList.size()>0){
                update updateResvPrLiList; //24 03 20 hyungho.chun
            }
            
            Map<String,String> partNumDivAndId = new Map<String,String>(); //key : PartNo^DIVcode , value : product2Id
            Map<String,String> productAndPiMap = new Map<String,String>(); //key : product2Id , value: productitem Id (해당 product2id를 가진 ph8002 ,99a999 productItem)
            
            if(prliAndProductMap.size()>0){
                System.debug('이번 배치사이클 모수건중에 할당부분잡힌 일반예약+대치부품 케이스가 존재함!!');

                String query = 'SELECT Id, Name, DIV_CODE__c ';
                query += ' FROM Product2 ';
                
                Integer loopCnt = 0;
                for(String key : prliAndProductMap.keySet()){
                    List<String> splitValue = prliAndProductMap.get(key).split('\\^');
                    if (loopCnt == 0) {
                        query += ' WHERE (Name = \'' + splitValue.get(0) + '\' AND DIV_CODE__c = \'' + splitValue.get(1) + '\')';
                    } else {
                        query += ' OR (Name = \'' + splitValue.get(0) + '\' AND DIV_CODE__c = \'' + splitValue.get(1) + '\')';
                    }
                    loopCnt++;
                }
                // List<Product2> p2ListTemp = Database.query(query);
                Map<Id, Product2> p2ListMap = new Map<Id,Product2>((List<Product2>)Database.query(query));
                System.debug('p2ListMap :: '+p2ListMap);

                for(Product2 item : p2ListMap.values()){
                    partNumDivAndId.put(item.name+'^'+item.DIV_CODE__c, item.Id);
                }
                //24 03 14 hyungho.chun ph8002로 고정가능 (케어용품의 경우 일반예약으로 할당만 따로잡히는건이 없다)
                Map<Id, ProductItem> piListMap = new Map<Id, ProductItem>([SELECT Id,Product2Id FROM ProductItem WHERE Product2Id IN: p2ListMap.keySet() AND DEPT_CODE__c = 'PH8002' AND Location.Name = :System.Label.EX_Location]);
                
                for(ProductItem item : piListMap.values()){
                    productAndPiMap.put(item.Product2Id, item.id);
                }
  
            }

            update updateOriPrliList;

            failRecordList.addAll(checkFail(upsertSalePrLiList,
                    salesFailOrderNumberList,
                    'SALE Type ProductRequestLineItem 생성 실패, '));
            System.debug('SALE PRLI 생성 후 failRecordList : ' + failRecordList);
            System.debug('SALE PRLI 생성 후 salesFailOrderNumberList : ' + salesFailOrderNumberList);

            // 재고 수불처리용
            List<Map<String, Object>> pListMapRequestInfo = new List<Map<String, Object>>();
            Map<String, ProductItem> pMapProductItemByKey = new Map<String, ProductItem>();
            Set<String> piKeySet = new Set<String>();

            // for (ProductRequestLineItem prLi : prLiList) { //24 03 05 hyungho.chun
            for (ProductRequestLineItem prLi : updateOriPrliList) {            
                // 실패건 패스
                //23 08 10 hyungho.chun salesFailOrderNumberList != null 추가
                if (salesFailOrderNumberList != null && salesFailOrderNumberList.contains(prLi.Order_Number__c)) continue;

                ProductTransfer upsertPrTr = new ProductTransfer();
                upsertPrTr.RecordTypeId = Schema.SObjectType.ProductTransfer.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();

                upsertPrTr.SourceLocationId = prLi.SourceLocationId;
                // upsertPrTr.Product2Id = prLi.Product2Id;
                upsertPrTr.Product2Id = prliAndProductMap.containsKey(prLi.Id) ? partNumDivAndId.get(prliAndProductMap.get(prLi.Id)) : prLi.Product2Id;

                // 수불 처리용
                String piKey = prLi.SourceLocationId + '^' + prLi.Product2Id;
                piKeySet.add(piKey);

                if(prliAndProductMap.containsKey(prLi.Id)){
                    String piKeyTemp = prLi.SourceLocationId + '^' + partNumDivAndId.get(prliAndProductMap.get(prLi.Id));
                    piKeySet.add(piKeyTemp);                    
                }

                // 실패한 주문건들은 자재쪽 수불처리 메서드 태우지 않기 위해 맵 구성
                piKeyList = orderNumberPiKeyListMap.containsKey(prLi.Order_Number__c)
                        ? orderNumberPiKeyListMap.get(prLi.Order_Number__c)
                        : new List<String>();
                piKeyList.add(piKey);
                orderNumberPiKeyListMap.put(prLi.Order_Number__c, piKeyList);

                // ProductRequestLineItem 저장시 ProductRequestId 확인
                // 기존에는 ProductRequestLineItemId 필드만 채웠지만
                // 부분 성공 체크를 위해 ProductRequestLineItem도 같이 넣어줌
                upsertPrTr.ProductRequestLineItem = prLi;
                upsertPrTr.ProductRequestLineItemId = prLi.Id;


                //23 12 22 hyungho.chun productTransfer 수량이 일반예약(재고를 적치장소+사업부에서 받아온경우) 수불따로 두번보내줘야함
                // upsertPrTr.SourceProductItemId = prLi.ProductItem__c;
                upsertPrTr.SourceProductItemId = prliAndProductMap.containsKey(prLi.Id) ? productAndPiMap.get(partNumDivAndId.get(prliAndProductMap.get(prLi.Id))) : prLi.ProductItem__c; //24 03 14 hyungho.chun lineitem별 quantiy on hand 수불처리를 나눠야하는 유일한 경우 (일반예약 적치장소재고+사업부(대치부품)재고차감) -> 깎아야하는 quantitiy on hand 가 2개의 다른 productItem을 봐야한다
                // upsertPrTr.QuantitySent = prLi.SALE_Quantity__c;
                upsertPrTr.QuantitySent = prliAndProductMap.containsKey(prLi.Id) ? (prLi.SALE_Quantity__c - prLi.ENDP_RSV_Quantity__c) : prLi.SALE_Quantity__c; //24 03 14 hyungho.chun lineitem별 quantiy on hand 수불처리를 나눠야하는 유일한 경우 (일반예약 적치장소재고+사업부(대치부품)재고차감) -> 깎아야하는 quantitiy on hand 가 2개의 다른 productItem을 봐야한다
                upsertPrTr.Status = '5';
                // upsertPrTr.QuantityReceived = prLi.SALE_Quantity__c;
                upsertPrTr.QuantityReceived = prliAndProductMap.containsKey(prLi.Id) ? (prLi.SALE_Quantity__c - prLi.ENDP_RSV_Quantity__c) : prLi.SALE_Quantity__c; //24 03 14 hyungho.chun lineitem별 quantiy on hand 수불처리를 나눠야하는 유일한 경우 (일반예약 적치장소재고+사업부(대치부품)재고차감) -> 깎아야하는 quantitiy on hand 가 2개의 다른 productItem을 봐야한다
                upsertPrTr.IsReceived = true;

                System.debug('upsertPrTr : ' + upsertPrTr);

                Map<String, Object> mapRequestInfo = new Map<String, Object>(); 

                ProductTransfer upsertPrTr2 = new ProductTransfer(); //일반예약(재고를 적치장소+사업부에서 받아온경우) 대비
                Map<String, Object> mapRequestInfo2 = new Map<String, Object>(); //일반예약(재고를 적치장소+사업부에서 받아온경우) 대비


                
                Double tempENDPquantity = 0;

                // 일반 판매건
                if (prLi.SR_RESRV_PART_Id__c == null) {
                    mapRequestInfo.put('requestType', 'AF');
                } else {
                    //23 12 22 hyungho.chun productTransfer 일반예약(재고를 적치장소+사업부에서 받아온경우) 수불따로 두번보내줘야함
                    if(prLi.ENDP_RSV_Quantity__c != null && prLi.QuantityRequested != null && prLi.ENDP_RSV_Quantity__c < prLi.QuantityRequested){ //일반예약(재고를 적치장소+사업부에서 받아온경우)
                        upsertPrTr2 = upsertPrTr.clone();

                        // upsertPrTr.QuantitySent = prli.QuantityRequested - prli.ENDP_RSV_Quantity__c; //전체판매수량 - 사업부에서받은수량 =  적치장소 할당수량
                        // upsertPrTr.QuantityReceived = prli.QuantityRequested - prli.ENDP_RSV_Quantity__c;
                        // tempENDPquantity = prli.QuantityRequested - prli.ENDP_RSV_Quantity__c; 
                        tempENDPquantity = prLi.ENDP_RSV_Quantity__c; //24 03 07 hyungho.chun 수량 잘못 넣고있었음


                        upsertPrTr2.QuantitySent = prLi.ENDP_RSV_Quantity__c; //사업부에서 받은 수량
                        upsertPrTr2.QuantityReceived = prLi.ENDP_RSV_Quantity__c;
                        
                        mapRequestInfo.put('requestType', 'AF'); //할당수량감소
                        mapRequestInfo2.put('requestType', 'AG'); //약속수량감소
                        
                        mapRequestInfo2.put('sourceLocationId', upsertPrTr2.SourceLocationId);
                        mapRequestInfo2.put('product2Id', (prliAndProductMap.containsKey(prLi.Id) ? prLi.Product2Id : upsertPrTr2.Product2Id));
                        mapRequestInfo2.put('requestQTY', upsertPrTr2.QuantitySent);
                        
                        // mapRequestInfo2.put('productTransfer', upsertPrTr2); //productTransfer로 수불은 총 수량용 productTransfer 한건으로 대체
                        if(prliAndProductMap.containsKey(prLi.Id)){
                            upsertPrTr2.SourceProductItemId = prLi.ProductItem__c;
                            upsertPrTr2.Product2Id  = prLi.Product2Id;
                            mapRequestInfo2.put('productTransfer', upsertPrTr2); //24 03 14 hyungho.chun lineitem별 quantiy on hand 수불처리를 나눠야하는 유일한 경우 (일반예약 적치장소재고+사업부(대치부품)재고차감) -> 깎아야하는 quantitiy on hand 가 2개의 다른 productItem을 봐야한다
                            upsertPrTrList.add(upsertPrTr2); //23 12 22 hyungho.chun productTrnasfer는 총 판매량으로 1건만 생성
                        }
                        System.debug('mapRequestInfo2 :: ' + mapRequestInfo2);

                        pListMapRequestInfo.add(mapRequestInfo2);
                        // upsertPrTrList.add(upsertPrTr2); //23 12 22 hyungho.chun productTrnasfer는 총 판매량으로 1건만 생성

                    }else{//전체다 사업부에서 재고 가져온 예약건
                        mapRequestInfo.put('requestType', 'AG');
                    }
                }
                mapRequestInfo.put('sourceLocationId', upsertPrTr.SourceLocationId);
                mapRequestInfo.put('product2Id', upsertPrTr.Product2Id);
                mapRequestInfo.put('requestQTY', (prliAndProductMap.containsKey(prLi.Id) ? upsertPrTr.QuantitySent : upsertPrTr.QuantitySent-tempENDPquantity));
                mapRequestInfo.put('productTransfer', upsertPrTr);
                System.debug('mapRequestInfo :: ' + mapRequestInfo);

                pListMapRequestInfo.add(mapRequestInfo);

                upsertPrTrList.add(upsertPrTr);
            }


            //23 12 22 hyungho.chun productTrnasfer insert를 할당 및 약속수량 수불후로 미룸 (fm_Available_Quantity__c <0 상황이 순간적으로 나옴)
            // failRecordList.addAll(checkFail(upsertPrTrList,
            //         salesFailOrderNumberList,
            //         'ProductTransfer 생성 실패, '));
            // System.debug('ProductTransfer 생성 후 failRecordList : ' + failRecordList);
            // System.debug('ProductTransfer 생성 후 salesFailOrderNumberList : ' + salesFailOrderNumberList);

            //23 12 22 hyungho.chun 어차피 checkFail에서 뻑남
            // // 실패건들 piKeyList 구성 
            // for (String orderNumber : orderNumberPiKeyListMap.keySet()) {
            //     //23 08 10 hyungho.chun salesFailOrderNumberList != null 추가
            //     if (salesFailOrderNumberList != null && salesFailOrderNumberList.contains(orderNumber)) {
            //         piKeySet.removeAll(orderNumberPiKeyListMap.get(orderNumber));
            //     }
            // }

            System.debug('piKeySet :: ' + piKeySet);
            // ProductItem 조회
            if (!piKeySet.isEmpty()) {
                Integer loopCnt = 0;
                String query = 'SELECT ' + SObjectUtil.getFieldForQuery('ProductItem');

                query += ', Product2.MODEL_CODE__c';
                query += ', Product2.PART_DESC__c';

                query += ' FROM ProductItem';
                for (String piKey : piKeySet) {
                    List<String> splitKey = piKey.split('\\^');
                    if (loopCnt == 0) {
                        query += ' WHERE (LocationId = \'' + splitKey.get(0) + '\' AND Product2Id = \'' + splitKey.get(1) + '\')';
                    } else {
                        query += ' OR (LocationId = \'' + splitKey.get(0) + '\' AND Product2Id = \'' + splitKey.get(1) + '\')';
                    }
                    loopCnt++;
                }
                List<ProductItem> piList = Database.query(query);

                for (ProductItem pi : piList) {
                    String piKey = pi.LocationId + '^' + pi.Product2Id;
                    pMapProductItemByKey.put(piKey, pi);
                }
                System.debug('pMapProductItemByKey : ' + pMapProductItemByKey);

                // 수불처리
                Map<String, Object> applyProductItemRtnMap = FS_MaterialUtil.applyProductItem(pListMapRequestInfo, pMapProductItemByKey);
                System.debug('applyProductItemRtnMap :: ' + applyProductItemRtnMap);
                System.debug('수불처리 결과 : ' + applyProductItemRtnMap.get('isSuccess'));
            }

            failRecordList.addAll(checkFail(upsertPrTrList,
            salesFailOrderNumberList,
            'ProductTransfer 생성 실패, '));
            System.debug('ProductTransfer 생성 후 failRecordList : ' + failRecordList);
            System.debug('ProductTransfer 생성 후 salesFailOrderNumberList : ' + salesFailOrderNumberList);

            for (ProductRequest pr : prList) {
                // 취소건 제외
                //23 08 10 hyungho.chun salesFailOrderNumberList != null 추가
                if (salesFailOrderNumberList != null && salesFailOrderNumberList.contains(pr.Order_Number__c)) continue;
                // 업데이트 대상 ProductRequest(원주문) List에 저장
                prListForUpdate.add(pr);
            }
            failRecordList.addAll(checkFail(prList,
                    salesFailOrderNumberList,
                    '원주문(ProductRequest) 업데이트 실패, '));
            System.debug('원주문 PR 업데이트 후 failRecordList : ' + failRecordList);
            System.debug('원주문 PR 업데이트 후 salesFailOrderNumberList : ' + salesFailOrderNumberList);

            for (ProductRequestLineItem prLi : prLiList) {
                // 취소건 제외
                //23 08 10 hyungho.chun salesFailOrderNumberList != null 추가
                if (salesFailOrderNumberList != null && salesFailOrderNumberList.contains(prLi.Order_Number__c)) continue;
                // 업데이트 대상 ProductRequestLineItem(원주문) List에 저장
                prLiListForUpdate.add(prLi);
            }

            failRecordList.addAll(checkFail(prLiList,
                    salesFailOrderNumberList,
                    '원주문 품목(ProductRequestLineItem) 업데이트 실패, '));
            System.debug('원주문 PRLI 업데이트 후 failRecordList : ' + failRecordList);
            System.debug('원주문 PRLI 업데이트 후 salesFailOrderNumberList : ' + salesFailOrderNumberList);

            /** 외부채널 채권생성
             * 2023.05.23 ysh
             */
            /** OBS, ThinQ, NewBest 흑자 채권생성 시작 */
            System.debug('OBS, ThinQ, NewBest 흑자 채권생성 시작');
            String siTSaleNo = '';
            if (!upsertSalePrList.isEmpty()) {
                //sm_dept 들고오기
                List<SM_DEPT__c> smDeptList = new List<SM_DEPT__c>();
                smDeptList = [SELECT Id, DEPT_CODE__c FROM SM_DEPT__c WHERE DEPT_CODE__c = :EX_ConsumableUtil.PH0300 OR DEPT_CODE__c = :EX_ConsumableUtil.PH8002];

                FNManager.BasisBundle[] bb = new FNManager.BasisBundle[]{
                };

                for (ProductRequest salePr : upsertSalePrList) {
                    FNManager.ARBundle[] arb = new FNManager.ARBundle[]{
                    };
                    //OBS, ThinQ, NewBest
                    if ((salePr.Order_CHNL_TYPE_Code__c == 'B' && salePr.Consumables_Business_Type_Code__c == 'Order') || salePr.Order_CHNL_TYPE_Code__c == 'S' || salePr.Order_CHNL_TYPE_Code__c == 'BestShop') {

                        // 실패건 제외
                        //23 08 10 hyungho.chun salesFailOrderNumberList != null 추가
                        if(salesFailOrderNumberList != null && salesFailOrderNumberList.contains(salePr.Order_Number__c)) continue;

                        String saleNo = salePr.SALE_Number__c; //판매번호
                        siTSaleNo = saleNo;
                        Date saleDt = srSaleIdSrSaleMap.get(salePr.SR_SALE__c) != null ? srSaleIdSrSaleMap.get(salePr.SR_SALE__c).SALE_DTM__c : System.today(); //판매일자
                        String srSaleId = salePr.SR_SALE__c; //SR_SALE의 Id
                        Decimal paymentAmt = salePr.PAYMENT_Amount__c; //판매금액
                        // Datetime paymentDtm = salePr.PAYMENT_COMPLETED_DTM__c != null ? salePr.PAYMENT_COMPLETED_DTM__c : System.now(); //결제일시
                        Datetime paymentDtm = System.now(); //24 01 05 hyungho.chun 판매확정일시가 들어가야한다는 재경요청
                        Date paymentDt = paymentDtm != null ? paymentDtm.date() : System.today(); //결제일시 -> 판매확정일시
                        String orderCustId = salePr.Order_CUST_Id__c; //고객 contact id
                        system.debug('orderCustId :'+orderCustId);
                        String deptCode = '';
                        //deptcode 결정
                        if (salePr.Order_CHNL_TYPE_Code__c == 'BestShop') {
                            deptCode = EX_ConsumableUtil.PH0300;
                        } else {
                            deptCode = EX_ConsumableUtil.PH8002;
                        }
                        //조직의 레코드 Id 들고오기 - SM_DEPT__c
                        String smDeptId = '';
                        if (!smDeptList.isEmpty()) {
                            if (salePr.Order_CHNL_TYPE_Code__c == 'BestShop') {
                                for (SM_DEPT__c sd : smDeptList) {
                                    if (sd.DEPT_CODE__c == EX_ConsumableUtil.PH0300) {
                                        smDeptId = sd.Id;
                                    }
                                }
                            } else {
                                for (SM_DEPT__c sd : smDeptList) {
                                    if (sd.DEPT_CODE__c == EX_ConsumableUtil.PH8002) {
                                        smDeptId = sd.Id;
                                    }
                                }
                            }
                        }

                        /** 1.결제근거(ProductRequest 1:1) */
                        system.debug('1.결제근거(ProductRequest 1:1)');
                        SR_PAYMENT_BASIS__c basis = new SR_PAYMENT_BASIS__c(
                                Name = saleNo
                                , BASIS_DT__c = saleDt
                                , BASIS_NO__c = saleNo
                                , BIZ_ORIGIN_TYPE__c = 'C'
                                , SM_DEPT_ID__c = smDeptId
                                , IsMIG__c = false
                                , PAYMENT_DTM__c = paymentDtm
                                , PAYMENT_DT__c = paymentDt
                                , RED_BLACK__c = 'B'
                                , SALE_AMT__c = paymentAmt
                                , SR_SALE_ID__c = srSaleId
                                , SETTLE_AMT__c = paymentAmt
                                , SETTLE_ORIGIN_TYPE__c = 'HIT'
                                , INVOICE_CHANGE_YN__c = false
                        );

                        /** 2.AR확정관리    (PR과는 1:N, 수금반제 내역과 1:1) */
                        /** 3.수금반제 내역  (PR과는 1:N, AR확정관리와 1:1) */
                        Integer arSlotNo = 1;
                        if (salePr.CARD_PAYMENT_Amount__c != null && salePr.CARD_PAYMENT_Amount__c > 0) {
                            Decimal amt = salePr.CARD_PAYMENT_Amount__c;
                            //AR확정관리
                            system.debug('2.AR확정관리 (PR과는 1:N, 수금반제 내역과 1:1) 카드');
                            //23 08 09 hyungho.chun AR_CONFIRM_TARGET_FLAG__c 값 뉴베스트건 분리
                            SR_AR_CONFIRM__c ar = new SR_AR_CONFIRM__c(
                                    AR_CONFIRM_TARGET_FLAG__c = salePr.Order_CHNL_TYPE_Code__c == 'BestShop' ? 'C' : 'Y'
                                    , AR_CONFIRM_YN__c = 'N'
                                    , IsMIG__c = false
                                    , CONTACT_ID__c = orderCustId != null ? orderCustId : ''
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_TYPE__c = 'B' //A:현금;B:카드;D:포인트;E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , DEPT_CODE__c = deptCode
                                    , INPUT_TYPE__c = 'N'
                                    , INVOICE_ISSUE_TYPE__c = 'D' //A:세금계산서;B:현금영수증;C:미발행;D:카드
                                    , SALE_AMT__c = amt
                                    , PAYMENT_AREA_NO__c = arSlotNo //결제 슬롯 번호 1~4, Default 1, 2건인 경우 1, 2 순차로 입력
                                    , BLACK_SR_AR_CONFIRM_ID__c = null //적자건에 대한 흑자 ID
                                    , APPR_DT__c = paymentDt //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 판매확정 date값 추가
                            );
                            arSlotNo++;
                            //수금반제내역
                            SR_DEPOSIT__c deposit = new SR_DEPOSIT__c(
                                    CM_DEPOSIT_STATUS_TYPE__c = 'A'
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_DT__c = paymentDt //결제일자, 포인트는 생성일자
                                    , DEPOSIT_STATUS_TYPE__c = 'B' //A:미수금, B:수금(포인트는 B, 나머지 A)
                                    , DEPOSIT_TYPE__c = 'B' //A:현금, B:카드, C:쿠폰, D:포인트, E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , IsMIG__c = false
                            );

                            FNManager.ARBundle arBundle = new FNManager.ARBundle(ar, deposit);
                            arb.add(arBundle);
                        }
                        if (salePr.CASH_PAYMENT_Amount__c != null && salePr.CASH_PAYMENT_Amount__c > 0) {
                            Decimal amt = salePr.CASH_PAYMENT_Amount__c;
                            //AR확정관리
                            system.debug('2.AR확정관리 (PR과는 1:N, 수금반제 내역과 1:1) 현금');

                            //23 08 09 hyungho.chun AR_CONFIRM_TARGET_FLAG__c 값 뉴베스트건 분리
                            //23 08 11 hyungho.chun INVOICE_ISSUE_TYPE__c = salePr.PAYMENT_TYPE__c == 'OBS-NA' ? 'C'  OBS 주문 페이(기타) 시 증빙유형미발행로직추가
                            SR_AR_CONFIRM__c ar = new SR_AR_CONFIRM__c(
                                    AR_CONFIRM_TARGET_FLAG__c = salePr.Order_CHNL_TYPE_Code__c == 'BestShop' ? 'C' : 'Y'
                                    , AR_CONFIRM_YN__c = 'N'
                                    , IsMIG__c = false
                                    , CONTACT_ID__c = orderCustId != null ? orderCustId : ''
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_TYPE__c = 'A' //A:현금;B:카드;D:포인트;E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , DEPT_CODE__c = deptCode
                                    , INPUT_TYPE__c = 'N'
                                    , INVOICE_ISSUE_TYPE__c = salePr.PAYMENT_TYPE__c == 'OBS-NA' ? 'C' :'B' //A:세금계산서;B:현금영수증;C:미발행;D:카드
                                    , SALE_AMT__c = amt
                                    , PAYMENT_AREA_NO__c = arSlotNo //결제 슬롯 번호 1~4, Default 1, 2건인 경우 1, 2 순차로 입력
                                    , BLACK_SR_AR_CONFIRM_ID__c = null //적자건에 대한 흑자 ID
                                    , APPR_DT__c = paymentDt //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 판매확정 date값 추가
                            );
                            system.debug('2.현금 세팅 끝');
                            arSlotNo++;
                            //수금반제내역
                            SR_DEPOSIT__c deposit = new SR_DEPOSIT__c(
                                    CM_DEPOSIT_STATUS_TYPE__c = 'A'
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_DT__c = paymentDt //결제일자, 포인트는 생성일자
                                    , DEPOSIT_STATUS_TYPE__c = 'B' //A:미수금, B:수금(포인트는 B, 나머지 A)
                                    , DEPOSIT_TYPE__c = 'A' //A:현금, B:카드, C:쿠폰, D:포인트, E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , IsMIG__c = false
                            );

                            FNManager.ARBundle arBundle = new FNManager.ARBundle(ar, deposit);
                            arb.add(arBundle);
                        }
                        if (salePr.POINT_Amount__c != null && salePr.POINT_Amount__c > 0) {
                            Decimal amt = salePr.POINT_Amount__c;
                            //AR확정관리
                            system.debug('2.AR확정관리 (PR과는 1:N, 수금반제 내역과 1:1) 포인트');
                            //23 08 09 hyungho.chun AR_CONFIRM_TARGET_FLAG__c 값 뉴베스트건 분리
                            SR_AR_CONFIRM__c ar = new SR_AR_CONFIRM__c(
                                    AR_CONFIRM_TARGET_FLAG__c = salePr.Order_CHNL_TYPE_Code__c == 'BestShop' ? 'C' : 'Y'
                                    , AR_CONFIRM_YN__c = 'N'
                                    , IsMIG__c = false
                                    , CONTACT_ID__c = orderCustId != null ? orderCustId : ''
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_TYPE__c = 'D' //A:현금;B:카드;D:포인트;E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , DEPT_CODE__c = deptCode
                                    , INPUT_TYPE__c = 'N'
                                    , INVOICE_ISSUE_TYPE__c = 'C' //A:세금계산서;B:현금영수증;C:미발행;D:카드
                                    , SALE_AMT__c = amt
                                    , PAYMENT_AREA_NO__c = arSlotNo //결제 슬롯 번호 1~4, Default 1, 2건인 경우 1, 2 순차로 입력
                                    , BLACK_SR_AR_CONFIRM_ID__c = null //적자건에 대한 흑자 ID
                                    , APPR_DT__c = paymentDt //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 판매확정 date값 추가
                            );
                            arSlotNo++;

                            //수금반제내역
                            SR_DEPOSIT__c deposit = new SR_DEPOSIT__c(
                                    CM_DEPOSIT_STATUS_TYPE__c = 'A'
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_DT__c = System.today() //결제일자, 포인트는 생성일자
                                    , DEPOSIT_STATUS_TYPE__c = 'B' //A:미수금, B:수금(포인트는 B, 나머지 A)
                                    , DEPOSIT_TYPE__c = 'D' //A:현금, B:카드, C:쿠폰, D:포인트, E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , IsMIG__c = false
                            );

                            FNManager.ARBundle arBundle = new FNManager.ARBundle(ar, deposit);
                            arb.add(arBundle);
                        }
                        if (arb != null && !arb.isEmpty()) {
                            FNManager.BasisBundle basisBundle = new FNManager.BasisBundle(basis, arb);
                            bb.add(basisBundle);
                        }
                    }//OBS, ThinQ, NewBest
                }//for upsertSalePrList


                //23 10 22 교환주문 (소모품 교환 / OBS 교환) 채권데이터 3가지 생성 시작 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                //23 10 22 hyungho.chun 교환주문 (소모품 교환 / OBS 교환)
                //교환주믄은 통합주문 화면단에서 요청하므로 PR과 PRLI는 늘 1:1이다.
                List<SR_AR_CONFIRM__c> sacList = new List<SR_AR_CONFIRM__c>();
                Map<String,String> exchangeAndOrigin = new Map<String,String>();
                Map<String,String> originARmap = new Map<String,String>();
                for(ProductRequestlineItem salePrLi : upsertSalePrLiList){
                    if (salePrLi.BASIS_Order_Item_Id__c != null) {
                        System.debug('salePrLi :: '+salePrLi);
                        System.debug('salePrLi.BASIS_Order_Item_Id__c :: '+salePrLi.BASIS_Order_Item_Id__c);
                        System.debug('salePrLi.BASIS_Order_Item_Id__r.Order_Number__c :: '+salePrLi.BASIS_Order_Item_Id__r.Order_Number__c);
                        exchangeAndOrigin.put(salePrLi.Order_Number__c,salePrLi.BASIS_Order_Item_Id__r.Order_Number__c);
                    }
                }
                System.debug('exchangeAndOrigin :: '+exchangeAndOrigin);

                sacList = [SELECT Id, FM_Order_Number__c FROM SR_AR_CONFIRM__c WHERE FM_Order_Number__c IN :exchangeAndOrigin.values() AND DEPOSIT_AMT__c>0 ORDER BY CreatedDate DESC];
                if(sacList.size()>0){
                    for(SR_AR_CONFIRM__c arConfirm : sacList){
                        originARmap.put(arConfirm.FM_Order_Number__c,arConfirm.Id);
                    }
                }
                System.debug('originARmap :: '+originARmap);

                for(ProductRequestlineItem salePrLi : upsertSalePrLiList){
                    FNManager.ARBundle[] arb = new FNManager.ARBundle[]{
                    };
                    //소모품 및 OBS 교환주문 !!
                    if (salePrLi.BASIS_Order_Item_Id__c != null) {
                        

                        // 실패건 제외
                        if(salesFailOrderNumberList != null && salesFailOrderNumberList.contains(salePrLi.Order_Number__c)) continue;

                        String saleNo = salePrLi.SALE_Number__c; //판매번호
                        siTSaleNo = saleNo;
                        Date saleDt = srSaleIdSrSaleMap.get(salePrLi.SR_SALE__c) != null ? srSaleIdSrSaleMap.get(salePrLi.SR_SALE__c).SALE_DTM__c : System.today(); //판매일자
                        String srSaleId = salePrLi.SR_SALE__c; //SR_SALE의 Id
                        System.debug('salePrLi.BASIS_Order_Item_Id__c =>? ' + salePrLi.BASIS_Order_Item_Id__c);
                        System.debug('salePrLi.BASIS_Order_Item_Id__r.Payment_Amount__c =>? ' + salePrLi.BASIS_Order_Item_Id__r.Payment_Amount__c);
                        System.debug('salePrLi.BASIS_Order_Item_Id__r.SALE_Quantity__c =>? ' + salePrLi.BASIS_Order_Item_Id__r.SALE_Quantity__c);
                        System.debug('salePrLi.QuantityRequested =>? ' + salePrLi.QuantityRequested);
                        Decimal paymentAmt = Math.floor(salePrLi.BASIS_Order_Item_Id__r.Payment_Amount__c/ (salePrLi.BASIS_Order_Item_Id__r.SALE_Quantity__c/salePrLi.QuantityRequested)); //판매금액
                        Datetime paymentDtm = System.now(); //24 01 05 hyungho.chun 결제일시->판매확정일시 재경요청
                        Date paymentDt = paymentDtm != null ? paymentDtm.date() : System.today(); //결제일시 -> 판매확정일시
                        String orderCustId = salePrLi.BASIS_Order_Item_Id__r.Order_CUST_Id__c; //고객 contact id
                        system.debug('orderCustId :'+orderCustId);
                        String deptCode = '';
                        //deptcode 결정 //베스트샾은 교환요청이없음!
                        deptCode = EX_ConsumableUtil.PH8002;
                        
                        //조직의 레코드 Id 들고오기 - SM_DEPT__c
                        String smDeptId = '';
                        if (!smDeptList.isEmpty()) {
                            //베스트샾은 교환요청이없음!
                            for (SM_DEPT__c sd : smDeptList) {
                                if (sd.DEPT_CODE__c == EX_ConsumableUtil.PH8002) {
                                    smDeptId = sd.Id;
                                }
                            }
                            
                        }
                        
                        /** 1.결제근거(ProductRequest 1:1) */
                        system.debug('1.결제근거(ProductRequest 1:1)');
                        SR_PAYMENT_BASIS__c basis = new SR_PAYMENT_BASIS__c(
                            Name = saleNo
                                , BASIS_DT__c = saleDt
                                , BASIS_NO__c = saleNo
                                , BIZ_ORIGIN_TYPE__c = 'C'
                                , SM_DEPT_ID__c = smDeptId
                                , IsMIG__c = false
                                , PAYMENT_DTM__c = paymentDtm
                                , PAYMENT_DT__c = paymentDt
                                , RED_BLACK__c = 'B'
                                , SALE_AMT__c = paymentAmt
                                , SR_SALE_ID__c = srSaleId
                                , SETTLE_AMT__c = paymentAmt
                                , SETTLE_ORIGIN_TYPE__c = 'HIT'
                                , INVOICE_CHANGE_YN__c = false
                        );
                                
                        /** 2.AR확정관리    (PR과는 1:N, 수금반제 내역과 1:1) */
                        /** 3.수금반제 내역  (PR과는 1:N, AR확정관리와 1:1) */
                        Integer arSlotNo = 1;
                        if (salePrLi.BASIS_Order_Item_Id__r.CARD_PAYMENT_Amount__c != null && salePrLi.BASIS_Order_Item_Id__r.CARD_PAYMENT_Amount__c > 0) {
                            Decimal amt = Math.floor(salePrLi.BASIS_Order_Item_Id__r.CARD_PAYMENT_Amount__c / (salePrLi.BASIS_Order_Item_Id__r.SALE_Quantity__c/salePrLi.QuantityRequested));
                            //AR확정관리
                            system.debug('2.AR확정관리 (PR과는 1:N, 수금반제 내역과 1:1) 카드');
                            //23 08 09 hyungho.chun AR_CONFIRM_TARGET_FLAG__c 값 뉴베스트건 분리
                            //23 10 22 hyungho.chun 교환주문은 베스트샾 없음
                            SR_AR_CONFIRM__c ar = new SR_AR_CONFIRM__c(
                                    AR_CONFIRM_TARGET_FLAG__c = 'Y'
                                    , AR_CONFIRM_YN__c = 'N'
                                    , IsMIG__c = false
                                    , CONTACT_ID__c = orderCustId != null ? orderCustId : ''
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_TYPE__c = 'B' //A:현금;B:카드;D:포인트;E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , DEPT_CODE__c = deptCode
                                    , INPUT_TYPE__c = 'N'
                                    , INVOICE_ISSUE_TYPE__c = 'D' //A:세금계산서;B:현금영수증;C:미발행;D:카드
                                    , SALE_AMT__c = amt
                                    , PAYMENT_AREA_NO__c = arSlotNo //결제 슬롯 번호 1~4, Default 1, 2건인 경우 1, 2 순차로 입력
                                    , BLACK_SR_AR_CONFIRM_ID__c = originARmap.get(exchangeAndOrigin.get(salePrLi.Order_Number__c)) != null ? originARmap.get(exchangeAndOrigin.get(salePrLi.Order_Number__c)) : null //적자건에 대한 흑자 ID (교환주문이라 원주문건 찾아넣어줌)
                                    , APPR_DT__c = paymentDt //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 판매확정 date값 추가
                            );
                            arSlotNo++;
                            //수금반제내역
                            SR_DEPOSIT__c deposit = new SR_DEPOSIT__c(
                                    CM_DEPOSIT_STATUS_TYPE__c = 'A'
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_DT__c = paymentDt //결제일자, 포인트는 생성일자
                                    , DEPOSIT_STATUS_TYPE__c = 'B' //A:미수금, B:수금(포인트는 B, 나머지 A)
                                    , DEPOSIT_TYPE__c = 'B' //A:현금, B:카드, C:쿠폰, D:포인트, E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , IsMIG__c = false
                            );

                            FNManager.ARBundle arBundle = new FNManager.ARBundle(ar, deposit);
                            arb.add(arBundle);
                        }
                        if (salePrLi.BASIS_Order_Item_Id__r.CASH_PAYMENT_Amount__c != null && salePrLi.BASIS_Order_Item_Id__r.CASH_PAYMENT_Amount__c > 0) {
                            Decimal amt = Math.floor(salePrLi.BASIS_Order_Item_Id__r.CASH_PAYMENT_Amount__c / (salePrLi.BASIS_Order_Item_Id__r.SALE_Quantity__c/salePrLi.QuantityRequested));
                            //AR확정관리
                            system.debug('2.AR확정관리 (PR과는 1:N, 수금반제 내역과 1:1) 현금');

                            //23 08 09 hyungho.chun AR_CONFIRM_TARGET_FLAG__c 값 뉴베스트건 분리
                            //23 08 11 hyungho.chun INVOICE_ISSUE_TYPE__c = salePr.PAYMENT_TYPE__c == 'OBS-NA' ? 'C'  OBS 주문 페이(기타) 시 증빙유형미발행로직추가
                            SR_AR_CONFIRM__c ar = new SR_AR_CONFIRM__c(
                                    AR_CONFIRM_TARGET_FLAG__c = 'Y'
                                    , AR_CONFIRM_YN__c = 'N'
                                    , IsMIG__c = false
                                    , CONTACT_ID__c = orderCustId != null ? orderCustId : ''
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_TYPE__c = 'A' //A:현금;B:카드;D:포인트;E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , DEPT_CODE__c = deptCode
                                    , INPUT_TYPE__c = 'N'
                                    , INVOICE_ISSUE_TYPE__c = salePrLi.BASIS_Order_Item_Id__r.parent.PAYMENT_TYPE__c == 'OBS-NA' ? 'C' :'B' //A:세금계산서;B:현금영수증;C:미발행;D:카드
                                    , SALE_AMT__c = amt
                                    , PAYMENT_AREA_NO__c = arSlotNo //결제 슬롯 번호 1~4, Default 1, 2건인 경우 1, 2 순차로 입력
                                    , BLACK_SR_AR_CONFIRM_ID__c = originARmap.get(exchangeAndOrigin.get(salePrLi.Order_Number__c)) != null ? originARmap.get(exchangeAndOrigin.get(salePrLi.Order_Number__c)) : null //적자건에 대한 흑자 ID (교환주문이라 원주문건 찾아넣어줌)
                                    , APPR_DT__c = paymentDt //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 판매확정 date값 추가
                            );
                            system.debug('2.현금 세팅 끝');
                            arSlotNo++;
                            //수금반제내역
                            SR_DEPOSIT__c deposit = new SR_DEPOSIT__c(
                                    CM_DEPOSIT_STATUS_TYPE__c = 'A'
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_DT__c = paymentDt //결제일자, 포인트는 생성일자
                                    , DEPOSIT_STATUS_TYPE__c = 'B' //A:미수금, B:수금(포인트는 B, 나머지 A)
                                    , DEPOSIT_TYPE__c = 'A' //A:현금, B:카드, C:쿠폰, D:포인트, E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , IsMIG__c = false
                            );

                            FNManager.ARBundle arBundle = new FNManager.ARBundle(ar, deposit);
                            arb.add(arBundle);
                        }
                        if (salePrLi.BASIS_Order_Item_Id__r.POINT_Amount__c != null && salePrLi.BASIS_Order_Item_Id__r.POINT_Amount__c > 0) {
                            Decimal amt = Math.floor(salePrLi.BASIS_Order_Item_Id__r.POINT_Amount__c / (salePrLi.BASIS_Order_Item_Id__r.SALE_Quantity__c/salePrLi.QuantityRequested));
                            //AR확정관리
                            system.debug('2.AR확정관리 (PR과는 1:N, 수금반제 내역과 1:1) 포인트');
                            //23 08 09 hyungho.chun AR_CONFIRM_TARGET_FLAG__c 값 뉴베스트건 분리
                            SR_AR_CONFIRM__c ar = new SR_AR_CONFIRM__c(
                                    AR_CONFIRM_TARGET_FLAG__c = 'Y'
                                    , AR_CONFIRM_YN__c = 'N'
                                    , IsMIG__c = false
                                    , CONTACT_ID__c = orderCustId != null ? orderCustId : ''
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_TYPE__c = 'D' //A:현금;B:카드;D:포인트;E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , DEPT_CODE__c = deptCode
                                    , INPUT_TYPE__c = 'N'
                                    , INVOICE_ISSUE_TYPE__c = 'C' //A:세금계산서;B:현금영수증;C:미발행;D:카드
                                    , SALE_AMT__c = amt
                                    , PAYMENT_AREA_NO__c = arSlotNo //결제 슬롯 번호 1~4, Default 1, 2건인 경우 1, 2 순차로 입력
                                    , BLACK_SR_AR_CONFIRM_ID__c = originARmap.get(exchangeAndOrigin.get(salePrLi.Order_Number__c)) != null ? originARmap.get(exchangeAndOrigin.get(salePrLi.Order_Number__c)) : null //적자건에 대한 흑자 ID (교환주문이라 원주문건 찾아넣어줌)
                                    , APPR_DT__c = paymentDt //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 판매확정 date값 추가
                            );
                            arSlotNo++;

                            //수금반제내역
                            SR_DEPOSIT__c deposit = new SR_DEPOSIT__c(
                                    CM_DEPOSIT_STATUS_TYPE__c = 'A'
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_DT__c = System.today() //결제일자, 포인트는 생성일자
                                    , DEPOSIT_STATUS_TYPE__c = 'B' //A:미수금, B:수금(포인트는 B, 나머지 A)
                                    , DEPOSIT_TYPE__c = 'D' //A:현금, B:카드, C:쿠폰, D:포인트, E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , IsMIG__c = false
                            );

                            FNManager.ARBundle arBundle = new FNManager.ARBundle(ar, deposit);
                            arb.add(arBundle);
                        }
                        if (arb != null && !arb.isEmpty()) {
                            FNManager.BasisBundle basisBundle = new FNManager.BasisBundle(basis, arb);
                            bb.add(basisBundle);
                        }
                    }//소모품 및 OBS 교환주문 !!
                }

                //23 10 22 교환주문 (소모품 교환 / OBS 교환) 채권데이터 3가지 생성 끝 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

                if (bb != null && !bb.isEmpty()) {
                    FNManager.builder().append(bb).build();
                }
            }
            System.debug('OBS, ThinQ, NewBest 흑자 채권생성 종료');
            System.debug('교환주문 흑자 채권생성 종료');
            /** OBS, ThinQ, NewBest 채권생성 종료 */
        

            /** 2023-05-18 ysh 케어플러스 SI_TRANSACTION__c 생석로직 추가 */
            // List<ProductRequestLineItem> carePlusPRLIList = new List<ProductRequestLineItem>();
            // Set<String> carePlusOrderNumSet = new Set<String>(); //23 09 13 hyungho.chun
            // for (ProductRequestLineItem allPrli : prLiList) {
            //     if (allPrli.RecordType.DeveloperName == 'CareSupplies') {
            //         carePlusPRLIList.add(allPrli);
            //         carePlusOrderNumSet.add(allPrli.Order_Number__c);
            //     }
            // }
            //24 02 24 hyungho.chun 앞으로 PH8002도 si_transaction 생성으로 메소드화
            
            // insertSiTransaction(prLiList, salesFailOrderNumberList, failRecordList);
            insertSiTransaction(updateOriPrliList, salesFailOrderNumberList, failRecordList); //24 03 05 hyungho.chun 업데이트이후의 라인아이템으로 si_transaciton 생성
            //24 02 21 hyungho.chun 부품요청 임시주석 시작@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            // if (!carePlusPRLIList.isEmpty()) {
            //     //23 09 13 hyungho.chun order_number기준으로 careplus_complete.LINE_ID__c 찾아서 si_transaction attribute 4번에 넣어주는용도
            //     List<SI_CAREPLUS_ORDER_COMPLETE__c> carePlusComList = new List<SI_CAREPLUS_ORDER_COMPLETE__c>();
            //     carePlusComList = [SELECT Id, CUST_PO_NO__c, LINE_ID__c FROM SI_CAREPLUS_ORDER_COMPLETE__c WHERE CUST_PO_NO__c IN: carePlusOrderNumSet AND LINE_ID__c != null];
            //     Map<String, String> orderNumAndLineId = new Map<String, String>();
            //     for(SI_CAREPLUS_ORDER_COMPLETE__c item : carePlusComList){
            //         orderNumAndLineId.put(item.CUST_PO_NO__c,  String.valueOf(item.LINE_ID__c));
            //     }            
            //     List<SI_TRANSACTION__c> insertSiTList = new List<SI_TRANSACTION__c>();
            //     List<SI_TRANSACTION__c> siTListForMaxList = new List<SI_TRANSACTION__c>();
            //     Integer maxTransactionId = 1;
            //     siTListForMaxList = [SELECT Id, TRANSACTION_ID__c FROM SI_TRANSACTION__c WHERE TRANSACTION_ID__c != null ORDER BY TRANSACTION_ID__c DESC LIMIT 1];
            //     if (!siTListForMaxList.isEmpty()) {
            //         maxTransactionId = Integer.valueOf(siTListForMaxList[0].TRANSACTION_ID__c);
            //     }
            //     Integer loopCnt = 1;
            //     for (ProductRequestLineItem cpPrli : carePlusPRLIList) {
            //         // 실패건 제외
            //         //23 08 10 hyungho.chun salesFailOrderNumberList != null 추가
            //         if (salesFailOrderNumberList != null && salesFailOrderNumberList.contains(cpPrli.Order_Number__c)) continue;

            //         SI_TRANSACTION__c siT = new SI_TRANSACTION__c();
            //         siT.TRANSACTION_ID__c = maxTransactionId + loopCnt; //572421 seq
            //         //siT.REQUEST_NUMBER__c = cpPrli.Order_Number__c; //R010004542
            //         siT.REQUEST_NUMBER__c = cpPrli.Sale_number__c; //R010004542 //23 11 27 hyungho.chun 다 같은 sale_number__c 값들어가던오류 수정 : siTSaleNo -> cpPrli.Sale_number__c
            //         siT.SEQ__c = 1;
            //         siT.SUB_SEQ__c = 1;
            //         siT.SOURCE_CODE__c = 'C'; //DECODE(A.DEPT_TYPE,'E', 'C', 'P')
            //         siT.TRX_CODE__c = 'CARE_STD';
            //         siT.STATUS_CODE__c = 'N';
            //         siT.LGC_CODE__c = EX_ConsumableUtil.PH0300; //( SELECT GERP_CODE FROM SM_DEPT WHERE DEPT_CODE = ( DECODE(A.DEPT_TYPE,'H',A.HIGH_DEPT_CODE,'G',A.HIGH_DEPT_CODE, 'I',A.HIGH_DEPT_CODE,'J',A.HIGH_DEPT_CODE, A.DEPT_CODE ) ) )
            //         siT.LGP_CODE__c = EX_ConsumableUtil.PH0300; //SM_DEPT.GERP_CODE
            //         siT.OBU_CODE__c = cpPrli.Product2.DIV_CODE__c; //${divCode}
            //         siT.TRX_DATE__c = Date.today();
            //         siT.ITEM_CODE__c = cpPrli.PART_NO__c; //partNo
            //         siT.UOM__c = 'EA';
            //         siT.TRX_QTY__c = cpPrli.QuantityRequested;
            //         siT.TRX_PRICE_1__c = cpPrli.SALE_Amount__c;
            //         //siT.TRX_PRICE_2__c;
            //         siT.TRANS_FLAG__c = 'N';
            //         siT.ATTRIBUTE1__c = 'CAREPLUS';
            //         siT.ATTRIBUTE2__c = cpPrli.Order_Number__c; //P10000388775
            //         siT.ATTRIBUTE3__c = '1';

            //         // if (cpPrli.Order_SEQ__c != null) {
            //         //     siT.ATTRIBUTE4__c = String.valueOf(cpPrli.Order_SEQ__c); //1711257043
            //         // }
            //         // 23 09 13 hyungho.chun order_number기준으로 careplus_complete.LINE_ID__c 찾아서 넣어줌
            //         if(orderNumAndLineId.containsKey(cpPrli.Order_Number__c)){
            //             siT.ATTRIBUTE4__c = orderNumAndLineId.get(cpPrli.Order_Number__c);
            //         }

            //         insertSiTList.add(siT);
            //         loopCnt++;
            //     }

            //     if (!insertSiTList.isEmpty()) {
            //         failRecordList.addAll(checkFail(insertSiTList,
            //                 salesFailOrderNumberList,
            //                 'SI_Transaction 생성 실패, '));
            //     }
            //     System.debug('SI_TRANSACTION__c 생성 후 failRecordList : ' + failRecordList);
            //     System.debug('SI_TRANSACTION__c 생성 후 salesFailOrderNumberList : ' + salesFailOrderNumberList);

            //     //23 11 30 hyungho.chun 판매확정 'SHIPPED' back IF 생성
            //     System.debug('판매확정 Back IF 생성 시작');
            //     Decimal maxNum = 0;
            //     List<SI_CAREPLUS_BACKIF__c> getMaxList = new List<SI_CAREPLUS_BACKIF__c>();
            //     getMaxList = [
            //             SELECT INTERFACE_ID__c
            //             FROM SI_CAREPLUS_BACKIF__c
            //             ORDER BY INTERFACE_ID__c DESC
            //             LIMIT 1
            //     ];
            //     if(!getMaxList.isEmpty()){
            //         SI_CAREPLUS_BACKIF__c getMax = getMaxList[0];
            //         if(getMax.INTERFACE_ID__c != null && getMax.INTERFACE_ID__c > 0){
            //             maxNum = getMax.INTERFACE_ID__c + 1;
            //         }
            //     }

            //     Decimal maxSubNum = 1;
                
            //     for (ProductRequestLineItem cpPrli : carePlusPRLIList) {
            //         String completeLineId = orderNumAndLineId.containsKey(cpPrli.Order_Number__c) ? orderNumAndLineId.get(cpPrli.Order_Number__c) : null;
            //         Map<String, Object> ifDataInfoMap = setCarePlusBackIFData(cpPrli, completeLineId, maxNum, maxSubNum,'SHIPPED');
            //         SI_CAREPLUS_BACKIF__c backIF = (SI_CAREPLUS_BACKIF__c) ifDataInfoMap.get('backIF');
            //         maxNum = (Decimal) ifDataInfoMap.get('maxNum');
            //         maxSubNum = (Decimal) ifDataInfoMap.get('maxSubnum');
            //         backIFList.add(backIF);

            //     }

            //     if (!backIFList.isEmpty()) {
            //         failRecordList.addAll(EX_ConsumableUtil.checkFail(backIFList,
            //                 salesFailOrderNumberList,
            //                 'SI_CAREPLUS_BACKIF__c 생성 실패, '));
            //     }
            // }
            //24 02 21 hyungho.chun 부품요청 임시주석 끝@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


            // List<String> salesFailOrderNumberList = (List<String>) paramMap.get('salesFailOrderNumberList');
            // OrderNumber를 통해서 결제 이력 헤더 조회 리스트
            List<SR_PRE_PAYMENT_HEADER__c> paymentHeaderList = null;
            //Map<String, SR_SALE__c> prIdSrSaleMap = (Map<String, SR_SALE__c>) paramMap.get('prIdSrSaleMap');
            System.debug('batch end : ' + system.now());

            // 판매저장대상 건이면서, 실패하지 않은 주문번호
            paymentHeaderList = [
                    SELECT Id, ATTR_RECORD_ID__c, SALE_AMT__c, SETTLE_AMT__c 
                    FROM SR_PRE_PAYMENT_HEADER__c
                    WHERE BASIS_NO__c IN:orderNumberList
                    AND BASIS_NO__c NOT IN:salesFailOrderNumberList
            ];


            //23 10 01 hyungho.chun 교환주문 판매확정용
            // Set<String> orderNumberForExchangeList = new Set<String>();
            // for(productrequestlineitem prli : prLiList){
            //     if(prli.Consumables_Business_Type_Code__c == 'ExchangeOrder' && prli.Order_CHNL_TYPE_Code__c == 'V'){
            //         orderNumberForExchangeList.add(prli.SUB_Order_Number__c.subString(0,13));
            //     }
            // }
            // System.debug('orderNumberForExchangeList :: '+orderNumberForExchangeList);

            // List<productrequestlineitem> oriPrliList = [SELECT id, Order_Number__c, SR_SALE__r.SALE_Number__c FROM productrequestlineitem WHERE Order_Number__c IN: orderNumberForExchangeList];
            // Set<String> srSaleNumSet = new Set<String>();
            // for(productrequestlineitem item : oriPrliList){
            //     srSaleNumSet.add(item.SR_SALE__r.SALE_Number__c);
            // }
            // System.debug('srSaleNumSet :: '+srSaleNumSet);

            // List<SR_PRE_PAYMENT_HEADER__c> headerForExchange = [
            //     SELECT Id, ATTR_RECORD_ID__c
            //     FROM SR_PRE_PAYMENT_HEADER__c
            //     WHERE BASIS_NO__c IN:srSaleNumSet
            // ];
            // System.debug('headerForExchange :: '+headerForExchange);

            // for(SR_PRE_PAYMENT_HEADER__c item : headerForExchange){
            //     paymentHeaderList.add(item);
            // }
        
            System.debug('paymentHeaderList before dml :: ' + paymentHeaderList);

            for (SR_PRE_PAYMENT_HEADER__c header : paymentHeaderList) {
                String prId = header.ATTR_RECORD_ID__c;
                if (prIdSrSaleMap.containsKey(prId)) {
                    header.ATTR_RECORD_ID__c = prIdSrSaleMap.get(prId).Id;
                    // 05.19 BASIS_NO 에 판매번호(SALE_Number__c)
                    header.BASIS_NO__c = prIdSrSaleMap.get(prId).SALE_Number__c;
                    //24 01 05 hyungho.chun 소모품주문 채권생성시 header정보받는데 basis_dt도 판매확정시점으로 들어가야한다서 추가
                    header.BASIS_DT__c = System.today();
                }
            }

            failRecordList.addAll(checkFail(paymentHeaderList,
                    salesFailOrderNumberList,
                    'SR_PRE_PAYMENT_HEADER__c 업데이트 실패, '));
            System.debug('SR_PRE_PAYMENT_HEADER__c 업데이트 후 failRecordList : ' + failRecordList);
            System.debug('SR_PRE_PAYMENT_HEADER__c 업데이트 후 salesFailOrderNumberList : ' + salesFailOrderNumberList);

            for (String str : salesFailOrderNumberList) {
                System.debug('failOrder : ' + str);
            }
            // 판매저장 오류 레코드 삽입
            if (!failRecordList.isEmpty()) {
                insert failRecordList;
            }

            for (SR_PRE_PAYMENT_Header__c header : paymentHeaderList) {
                if (!headerIdHeaderMap.containsKey(header.Id)) {
                    headerIdHeaderMap.put(header.Id, header);
                }
                headerIdSet.add(header.Id);
            }

            // 삭제 대상 밑 Header 업데이트 대상
            detailList = [
                    SELECT Id, DEPOSIT_AMT__c, SR_PRE_PAYMENT_HEADER_ID__c, SR_SMARTRO_PAYMENT_REQUEST_ID__r.CANCEL_AMT__c, SR_SMARTRO_PAYMENT_REQUEST_ID__r.CANCEL_FLAG__c
                    FROM SR_PRE_PAYMENT_DETAIL__c
                    WHERE SR_PRE_PAYMENT_HEADER_ID__c IN: headerIdSet
                    //23 12 05 hyungho.chun 삭제할대상은 detail.SR_SMARTRO_PAYMENT_REQUEST_ID__r.CANCEL_AMT__c == detail.DEPOSIT_AMT__c여기서 거른다
                    // AND SR_SMARTRO_PAYMENT_REQUEST_ID__r.CANCEL_FLAG__c = true
            ];

            List<SR_PRE_PAYMENT_DETAIL__c> updateDetailList = new List<SR_PRE_PAYMENT_DETAIL__c>();

            for (SR_PRE_PAYMENT_DETAIL__c detail : detailList) {
                String headerId = detail.SR_PRE_PAYMENT_HEADER_ID__c;
                if (headerIdHeaderMap.containsKey(headerId)) {
                    SR_PRE_PAYMENT_HEADER__c header = headerIdHeaderMap.get(headerId);
                    header.SALE_AMT__c -= detail.SR_SMARTRO_PAYMENT_REQUEST_ID__r.CANCEL_AMT__c;
                    header.SETTLE_AMT__c -= detail.SR_SMARTRO_PAYMENT_REQUEST_ID__r.CANCEL_AMT__c;

                    if (detail.SR_SMARTRO_PAYMENT_REQUEST_ID__r.CANCEL_AMT__c == detail.DEPOSIT_AMT__c) {
                        deleteDetailList.add(detail);
                    }
                    //23 12 05 hyungho.chun 복합결제 상품준비중 부분취소후 판매확정시 detail에도 deposit_amt update해야함
                    if(detail.SR_SMARTRO_PAYMENT_REQUEST_ID__r.CANCEL_AMT__c != null && detail.SR_SMARTRO_PAYMENT_REQUEST_ID__r.CANCEL_AMT__c != 0 && !deleteDetailList.contains(detail)){
                        detail.DEPOSIT_AMT__c -= detail.SR_SMARTRO_PAYMENT_REQUEST_ID__r.CANCEL_AMT__c;
                        updateDetailList.add(detail);
                    }
                }
            }

            update headerIdHeaderMap.values();
            update updateDetailList;
            delete deleteDetailList;


            Set<String> headerIds = new Set<String>(); // 24 03 11 hyungho.chun 배치때headerId따로받아서 Ex_saveSales_ba finish에서 한번에 흑자채권배치돌려야한다

            // try { //24 03 05 hyungho.chun 채권생성 에러 try catch 제거
                FNManager.BlackRecorder recorder = FNManager.black();
                for (SR_PRE_PAYMENT_HEADER__c header : paymentHeaderList) {
                    System.debug('append header Id :: ' + header.Id);
                    recorder.append(header.Id);
                    headerIds.add(header.Id);
                }
                // 화면에서 수동 판매저장일 경우 흑자채권 생성 메소드 실행
                // 배치에서 자동 판매저장일 경우 finish에서 흑자채권 메소드 실행
                if (caller.equals('Screen')) {
                    //23 12 04 hyungho.chun 화면/배치 구분 안넣고 다 여기서 실행할수도??
                    recorder.record();
                }
                else {
                    paramMap.put('blackRecorder', recorder);
                    paramMap.put('headerIds',headerIds);
                }

            // } catch(Exception e) {
                // // 채권 생성 에러 (화면단)
                // if (!rtnMap.containsKey('isSuccess')) {
                //     rtnMap.put('isSuccess', 'false');
                //     rtnMap.put('error', e.getLineNumber() + 'line : ' + e.getMessage());
                // }
            // }
            //23 12 18 hyungho.chun 판매저장 성공건도 기록
            errorMap.put('errorType','SaveSales');
            // errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
            errorMap.put('requestMsg', '[Success] : '+prList.size()+ ' 건');
            errorMap.put('isSuccess','Y');
            errorMap.put('className','EX_ConsumableUtil.doSaveSales2');
            System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
            saveSaleExc(errorMap);            
        }catch(Exception e){
            //23 12 04 hyungho.chun 판매저장 오류 로그 작업
            
            
            Database.rollback(sp);

            rtnMap.put('isSuccess', 'false');
            rtnMap.put('error', ' 관리자에게 문의하세요.');

            String orderNumListTemp = '';
            for(String orderNum : orderNumberList){
                orderNumListTemp += orderNum+' ';
            }
            String orderNumListFailTemp = '';
            if (salesFailOrderNumberList.isEmpty()) {
                for(String orderNum : salesFailOrderNumberList){
                    orderNumListFailTemp += orderNum+' ';
                }
            }

            for(ProductRequestLineItem item : prLiList){
                item.ShipToStreet ='임시조치'; //24 03 05 hyungho.chun 매치실패한 모수 묶음에 임시조치로 필드 값 넣어서 다음모수때 안잡히게 조치
            }
            update prLiList;

            String tempMsg = ' [Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage();
            System.debug('[Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage());

            if(salesFailOrderNumberList.size()>0){
                tempMsg += '실패 주문번호 : '+orderNumListFailTemp;
            }

            // errorMap.put('requestMsg', '배치 실행 주문번호 : '+orderNumListTemp);

            
            
            // errorMap.put('orderNum',roLiList[0].Order_Number__c);
            // errorMap.put('orderChannel',roLiList[0].Order_CHNL_TYPE_Code__c);
            errorMap.put('errorType','SaveSales');
            // errorMap.put('recordId',roLiList[0].Id);
            errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
            errorMap.put('requestMsg', '[Fail] : '+prList.size()+ ' 건 // ShipToStreet 임시조치 확인필요');
            errorMap.put('isSuccess','N');
            errorMap.put('className','EX_ConsumableUtil.doSaveSales2');
            System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
            saveSaleExc(errorMap);
            // rtnMap.put('isSuccess', 'false');
            // rtnMap.put('error', ' 관리자에게 문의하세요.');
        }



        // 진행하며 발생된 실패건 없고. 채권 생성 에러 없을 때 (화면)
        if (salesFailOrderNumberList.isEmpty()) {
            if (!rtnMap.containsKey('isSuccess')) {
                rtnMap.put('isSuccess', 'true');
            }
        }

        return rtnMap;
    }

    public static Map<String, Object> preWorkSaveSales(List<String> targetOrderNumberList) {
        Map<String, Object> paramMap = new Map<String, Object>();
        List<String> orderNumberList = new List<String>();
        // 임시 리스트 (주문번호)
        List<ProductRequestLineItem> orderNumberPrLiList = null;
        List<ProductRequest> basisOrderCountList = null;
        // ProductRequest 중복 삽입 방지
        Set<String> exceptOrderNumberSet = new Set<String>();
        Map<String, List<ProductRequestLineItem>> orderNumberPrLiMap = new Map<String, List<ProductRequestLineItem>>();

        /**
         *   Key: ProductRequestId    Value: Integer
         *   현재 주문건(Key)의 판매저장 대상 품목 개수 Map
         *   이 개수와 원 주문건의 원 주문품목 개수를 비교해 판매저장 여부 판단
         */
        Map<String, Integer> prIdChildCountMap = new Map<String, Integer>();
        Map<String, Integer> prIdBasisOrderMap = new Map<String, Integer>();
        Map<String, Decimal> orderNumberPaymentAmtMap = new Map<String, Decimal>();
        Map<String, Decimal> orderNumberDiscountAmtMap = new Map<String, Decimal>();

        // 판매 저장 대상 ProductRequest
        List<ProductRequest> prList = new List<ProductRequest>();
        //23 10 11 hyungho.chun 나중에 sale type / pr, prli clone하기위해 필드전체불러오게 쿼리수정
        List<String> productRequestFields = SObjectUtil.getAllFields('ProductRequest');
        String prFields = '';
        for(String field : productRequestFields){
            if(field != 'Order_CUST_Id__c'){
                prFields += ', Parent.'+field+' ';
            }
        }
        System.debug('prFields :: '+prFields);
        
        String query = 'SELECT '+ SObjectUtil.getFieldForQuery('ProductRequestLineItem') +' \n' +
                '                        ,BASIS_Order_Item_Id__r.Order_Number__c, BASIS_Order_Item_Id__r.Consumables_Business_Type_Code__c, BASIS_Order_Item_Id__r.parent.PAYMENT_Amount__c, BASIS_Order_Item_Id__r.parent.Order_CUST_Id__c, BASIS_Order_Item_Id__r.parent.CARD_PAYMENT_Amount__c, BASIS_Order_Item_Id__r.parent.CASH_PAYMENT_Amount__c, BASIS_Order_Item_Id__r.parent.POINT_Amount__c, RecordType.DeveloperName, \n'+
                '                        BASIS_Order_Item_Id__r.QuantityRequested,BASIS_Order_Item_Id__r.Payment_Amount__c,BASIS_Order_Item_Id__r.SALE_Quantity__c, BASIS_Order_Item_Id__r.Exchange_Quantity__c, BASIS_Order_Item_Id__r.Order_CUST_Id__c, BASIS_Order_Item_Id__r.CARD_PAYMENT_Amount__c, BASIS_Order_Item_Id__r.CASH_PAYMENT_Amount__c, BASIS_Order_Item_Id__r.POINT_Amount__c, BASIS_Order_Item_Id__r.parent.PAYMENT_TYPE__c,\n'+
                '                        Parent.Order_CUST_Id__r.Phone, Parent.Order_CUST_Id__r.MobilePhone, Parent.Order_CUST_Id__r.Name, Product2.DIV_CODE__c,Product2.Name \n' +
                                         prFields;


                // String query = 'SELECT Id, Order_Number__c, POINT_TRX_ID__c, Consumables_Business_Type_Code__c, POINT_Amount__c, SUB_Order_Number__c,SALE_Amount__c, BASIS_Order_Item_Id__r.Order_Number__c, SourceLocationId, BASIS_Order_Item_Id__r.Consumables_Business_Type_Code__c, BASIS_Order_Item_Id__r.parent.PAYMENT_Amount__c, BASIS_Order_Item_Id__r.parent.Order_CUST_Id__c, BASIS_Order_Item_Id__r.parent.CARD_PAYMENT_Amount__c, BASIS_Order_Item_Id__r.parent.CASH_PAYMENT_Amount__c, BASIS_Order_Item_Id__r.parent.POINT_Amount__c,\n' +
                // '                        DestinationLocationId, GSCS_Order_Number__c, Product2Id, PART_NO__c, MODEL_Code__c, MODEL__c, Employees_Discount_Amount__c,\n' +
                // '                        ProductItem__c, UnitPrice__c, CONSUMER_Price__c, ASC_Price__c, Last_Discount_Amount__c, COUPON_Discount_Amount__c,\n' +
                // '                        SALE_Quantity__c, PAYMENT_Amount__c, PAYMENT_Method_Code__c, PAYMENT_TYPE__c, PAYMENT_DTM__c,\n' +
                // '                        Department_Code__c, ENDP_Code__c, Consumables_Order_YN__c, LOCATED_PLACE_Number__c, SALE_Discount_Type_Code__c,\n' +
                // '                        Order_CUST_Id__c, Order_SEQ__c, Order_CHNL_TYPE_Code__c, CARD_PAYMENT_Amount__c, CARD_Company_Name__c,\n' +
                // '                        CARD_Company_Type_Code__c, SETTLE_METHOD_REF_NO__c, CASH_PAYMENT_Amount__c, SR_RESRV_PART_Id__c,\n' +
                // '                        Adjust_Quantity__c, QuantityRequested, RSRV_Completion_YN__c, VIP_Discount_Amount__c, fm_Last_Discount_Amount__c, \n' +
                // '                        Parent.Order_Number__c, Parent.Order_Date__c, Parent.Order_CHNL_TYPE_Code__c,PROMOTION_Discount_Amount__c,\n' +
                // '                        Parent.Order_Req_Dept_Type_Code__c, Parent.Consumables_Order_YN__c, Parent.Status, Parent.Requester_Code__c,\n' +
                // '                        Parent.SR_SALE__c, Parent.SALE_Number__c, Parent.SALE_Amount__c, Parent.Discount_Amount__c,\n' +
                // '                        Parent.Department_Id__c, Parent.Department_Code__c, Parent.MOID__c, Parent.TID__c, Parent.APPR_NUM__c,\n' +
                // '                        Parent.APPR_DT__c, Parent.SR_RSRV_PART_Id__c, Parent.Order_CUST_Id__r.Phone, Parent.Order_CUST_Id__r.MobilePhone,\n' +
                // '                        Parent.Order_CUST_Id__r.Name, Parent.RSRV_Number__c, Parent.SourceLocationId, Parent.DestinationLocationId,\n' +
                // '                        Parent.PAYMENT_Amount__c, Parent.PAYMENT_Method_Code__c, Parent.PAYMENT_TYPE__c, Parent.SALE_DC_TYPE__c, Product2.DIV_CODE__c,\n' +
                // '                        Parent.CARD_PAYMENT_Amount__c, Parent.POINT_Amount__c, Parent.CASH_PAYMENT_Amount__c, Parent.PARCEL_FEE_Amount__c,\n' +
                // '                        Parent.Consumables_Business_Type_Code__c, Parent.PAYMENT_COMPLETED_DTM__c, RecordType.DeveloperName,\n ' +
                // '                        Parent.EMP_NAME__c, Parent.EMP_COMPANY_CODE__c, Parent.EMP_NO__c ';                

        query += 'FROM ProductRequestLineItem ';
        query += 'WHERE (RecordType.DeveloperName=\'Consumable\' OR RecordType.DeveloperName=\'CareSupplies\') ';
        query += 'AND Consumables_Business_Type_Code__c IN (\'Order\', \'ExchangeOrder\') ';
        query += 'AND (Consumables_Order_Status__c = \'030\' OR Consumables_Order_Status__c = \'070\') ';
        query += 'AND (Parent.RecordType.DeveloperName=\'Consumable\' OR Parent.RecordType.DeveloperName=\'CareSupplies\') ';
        query += 'AND Parent.SR_SALE__c = NULL ';
        query += 'AND Parent.SALE_Number__c = NULL ';
        query += 'AND Consumables_Order_Status__c != \'003\' ';
        query += 'AND Consumables_Order_Status__c != \'004\' ';
        query += 'AND Consumables_Order_Status__c != \'005\' ';
        

        //23 11 27 hyungho.chun 연계테스트용 쿼리 임시 -> 23 12 04 연계테스트 끝 다시 주석처리
        // query += 'AND isMig__c = false ';
        // query += 'AND CreatedDate >= LAST_MONTH ';

        // query += 'AND Order_Number__c IN ( \'O230001290303\' ) ';
        // query += 'AND Order_Number__c IN ( \'O230001290309\',\'O230001290312\',\'O230001290314\',\'O230001290318\',\'O230001353309\',\'O230001353310\', \'ORD-1000069408-E1\',\'ORD-1000069435-E1\' ) ';
        // query += 'AND Order_Number__c IN ( \'O230001353309\' , \'O230001353310\' , \'ORD-1000069435-E1\' , \'ORD-1000069408-E1\'  ) ';

        //23 10 30 hyungho.chun mig 조건 제거
        // query += 'AND isMig__c = FALSE ';

        /**
         *   배치일 경우 targetOrderNumberList 조건 없이 대상 PRLI 모두 조회
         *   이 메소드가 실행되는 곳은 Batch / Screen 둘 중 하나이다.
         *   배치에서 실행될 경우 흑자채권 생성 메소드가 배치이므로 finish에서 생성하기 위해
         *   화면에서 실행된 경우 비동기로 바로 실행하기 위해 현재 메소드가 실행되는 곳을 알기 위함
         */
        if (targetOrderNumberList != null) {
            query += 'AND Order_Number__c IN: targetOrderNumberList ';
            paramMap.put('caller', 'Screen');
        }
        else {
            query += 'AND ShipToStreet = null '; //24 03 05 hyungho.chun 배치모수로잡힐떄 문제발생시 묶음모수에 값 기입
            paramMap.put('caller', 'Batch');
        }

        query += 'ORDER BY POINT_TRX_ID__c';

        System.debug('query :: '+query);
        List<ProductRequestLineItem> prLiList = Database.query(query);

        for (ProductRequestLineItem prLi : prLiList) {
            /**
             *   현재 Loop를 돌고 있는 ProductRequestLineItem의 Parent(ProductRequest)의
             *   Id를 Key로 ProductRequestLineItem의 등장횟수를 저장한다.
             *   이 count는 ProductRequest에 대한 판매 저장 대상 ProductRequestLineItem 개수이며
             *   후에 ProductRequest에 대한 원 주문 LineItem 개수를 count 해서 비교한다.
             *   이 두 값이 맞아야 판매저장 대상 주문건이 된다.
             */
            // ====================================================================================
            if (!prIdChildCountMap.containsKey(prLi.ParentId)) {
                prIdChildCountMap.put(prLi.ParentId, 1);
            }
            else {
                prIdChildCountMap.put(prLi.ParentId, prIdChildCountMap.get(prLi.ParentId) + 1);
            }
            // ====================================================================================

            orderNumberList.add(prLi.Order_Number__c);

            // 주문번호 별 PRLI 맵
            orderNumberPrLiList = orderNumberPrLiMap.containsKey(prLi.Order_Number__c)
                    ? orderNumberPrLiMap.get(prLi.Order_Number__c)
                    : new List<ProductRequestLineItem>();

            orderNumberPrLiList.add(prLi);
            orderNumberPrLiMap.put(prLi.Order_Number__c, orderNumberPrLiList);
            // orderNumberPaymentAmtMap.put(prLi.Order_Number__c, prli.Payment_Amount__c);
            //24 02 27 hyungho.chun 금액이 마지막 prli께 들어가고있었음
            if(orderNumberPaymentAmtMap.containsKey(prLi.Order_Number__c)){
                orderNumberPaymentAmtMap.put(prLi.Order_Number__c, orderNumberPaymentAmtMap.get(prLi.Order_Number__c)+prli.Payment_Amount__c);    
            }else{
                orderNumberPaymentAmtMap.put(prLi.Order_Number__c, prli.Payment_Amount__c);
            }
            
        }

        // 취소건제외 원주문건 카운트 (주문건만 확인)
        basisOrderCountList = [
                SELECT Id, Order_Number__c, (
                        SELECT Id
                        FROM ProductRequestLineItems
                        WHERE Order_Number__c IN:orderNumberList AND ((
                                Consumables_Business_Type_Code__c = 'Order'
                                AND BASIS_Order_Item_Id__c = NULL
                                AND SUB_Order_Number__c LIKE '%-01%'
                        )
                        OR (
                                Consumables_Business_Type_Code__c = 'ExchangeOrder'
                                AND BASIS_Order_Item_Id__c != NULL
                        ))
                        AND Consumables_Order_Status__c != '003'
                        AND Consumables_Order_Status__c != '004'
                        AND Consumables_Order_Status__c != '005'
                )
                FROM ProductRequest
                WHERE Order_Number__c IN:orderNumberList
        ];

        /**
         *   한 주문건에 대해 모든 품목들이 판매저장 가능 상태((배송중 || 배송완료) && 판매번호 = NULL)
         *   화면단에서의 판매저장은 Button Validation 사용
         *   배치에서는 모든 원 주문건 Count 할 수 있게
         */
        for (ProductRequest pr :basisOrderCountList) {
            if (!prIdBasisOrderMap.containsKey(pr.Id)) {
                prIdBasisOrderMap.put(pr.Id, pr.ProductRequestLineItems.size());
            }
        }

        // OrderNumber List는 execute에서 사용하기 위해서
        // 배치에 들어갈 Order_Number만 저장하기 위해 Clear
        orderNumberList.clear();
        /**
         *   대상 ProductRequestLineItem을 다시 순회하면서 대상 ProductRequest 추출
         *   1. exceptOrderNumberSet은 한 주문건의 여러개 품목이 있을 때 주문 건은 하나 특정하기 위해
         *   2. 주문건 Id, 원 주문 품목들 개수 맵에 키가 존재, 주문건 Id, 판매저장 대상 품목들 개수 맵에 키 존재
         *   3. 상기 두 맵의 값이 같을 때 즉, 모든 원주문 품목들이 판매저장 대상 품목일 때.
         */
        for (ProductRequestLineItem prLi : prLiList) {
            System.debug('prLi :: ' + prLi);
            if (exceptOrderNumberSet.contains(prLi.Order_Number__c)) continue;
            if (!(prIdBasisOrderMap.containsKey(prLi.ParentId) && prIdChildCountMap.containsKey(prLi.ParentId))) continue;
            if (prIdBasisOrderMap.get(prLi.ParentId) != prIdChildCountMap.get(prLi.ParentId)) {
                System.debug('ProductRequest의 모든 품목이 판매 대상 품목이 아님');
                System.debug('판매 대상 품목 개수 : ' + prIdChildCountMap.get(prLi.ParentId));
                System.debug('모든 품목(원주문) 개수 : ' + prIdBasisOrderMap.get(prLi.ParentId));
                continue;
            }

            // 실제 판매저장 대상 주문건 주문번호
            orderNumberList.add(prLi.Order_Number__c);
            prList.add(prLi.Parent);
            exceptOrderNumberSet.add(prLi.Order_Number__c);
        }

        paramMap.put('prList', prList);
        paramMap.put('prLiList', prLiList);
        paramMap.put('orderNumberList', orderNumberList);
        paramMap.put('orderNumberPrLiMap', orderNumberPrLiMap);
        paramMap.put('orderNumberPaymentAmtMap', orderNumberPaymentAmtMap);
        paramMap.put('orderNumberDiscountAmtMap', orderNumberDiscountAmtMap);
        paramMap.put('salesFailOrderNumberList', new List<String>());

        return paramMap;
    }

    /**
    * @description 반품 확정건들을 결제유형(카드, 가상계좌, 포인트)에 따라 환불처리
    * @author 23.04.19 / I2MAX.SEUNGHUNAN
    * @param List<String> 반품확정 대상 건 ReturnOrderLineItem Id 리스트
    * CJ 배치로 인해 반품 확정된 건들은 다수이기에 리스트로 처리한다.
    * @return
    */
    public static void doReturnConfirm(List<String> roLiIdList) {
        // ReturnOrderLineItem Id 리스트를 Set으로 중복 제거
        Set<String> roLiIdSet = new Set<String>(roLiIdList);
        // ReturnOrderLineItem Id 리스트
        List<ReturnOrderLineItem> roLiList = null;
        // 파라미터로 들어온 ReturnOrderLineItem의 ReturnOrder(Parent)
        List<ReturnOrder> roList = null;
        // ReturnOrder의 반품이 발생한 원 주문건(ProductRequest)
        List<ProductRequest> prList = null;
        // AR 확정관리(SR_AR_CONFIRM)
        List<SR_AR_CONFIRM__c> arConfirmList = null;
        // 결제이력헤더(SR_PRE_PAYMENT_HEADER__c)와 MOID를 묶기위한 리스트
        List<SR_PRE_PAYMENT_HEADER__c> headerList = null;
        // 맵을 만드는데 사용되는 임시 ReturnOrderLineItem 리스트
        List<ReturnOrderLineItem> tmpRoLiList = null;
        // 부서를 저장할 List
        List<SM_DEPT__c> smDeptList = new List<SM_DEPT__c>();

        // ReturnOrder의 ProductRequest(원 주문건)의 판매정보(SR_SALE__c)의 Id와 SR_AR_CONFIRM[] 맵
        Map<String, List<SR_AR_CONFIRM__c>> saleIdArConfirmMap = new Map<String, List<SR_AR_CONFIRM__c>>();
        // Header의 BASIS_NO__c(SALE_Number__c)와 MOID__c -> 판매번호 별 MOID Map
        Map<String, String> saleNumberMOIDMap = new Map<String, String>();
        // SR_AR_CONFIRM에 해당하는 TRX_ID를 얻기위한 맵
        Map<String, String> confirmIdTrxIdMap = new Map<String, String>();
        // DEPT_CODE와 SM_DEPT__c를 연결할 맵
        Map<String, SM_DEPT__c> deptCodeMap = new Map<String, SM_DEPT__c>();

        // Async로 만들어질 Function에 파라미터를 전달하기 위한 맵
        Map<String, Object> paramMap = new Map<String, Object>();
        // ReturnOrder를 기준으로 TRX_ID를 셋으로 묶는다 Key: ReturnOrderId,  Value: TRX_ID Set
        Map<String, Set<String>> roIdTrxIdSetMap = new Map<String, Set<String>>();
        // ReturnOrder별 ReturnOrderLineItem List 맵 Key: ReturnOrderId,  Value: ReturnOrderLineItem List
        Map<String, List<ReturnOrderLineItem>> roIdRoLiListMap = new Map<String, List<ReturnOrderLineItem>>();
        // TRX_ID와 ReturnOrderLineItem을 묶기 위한 맵
        Map<String, ReturnOrderLineItem> kTrxIdRoLiMap = new Map<String, ReturnOrderLineItem>();

        // ReturnOrder의 Id를 저장하기 위한 Set
        Set<String> roIdSet = new Set<String>();
        // 반품 건들의 주문번호를 저장하기 위한 Set
        Set<String> orderNumberSet = new Set<String>();
        // SR_PRE_PAYMENT_HEADER__c의 BASIS_NO__c가 판매번호(SALE_Number__c)로 바뀜에 따라 추가된 Set (Header 조회용)
        Set<String> saleNumberSet = new Set<String>();
        // 판매 정보(SR_SALE__c)의 Id를 저장하기 위한 Set
        Set<String> saleIdSet = new Set<String>();
        // 포인트 결제 시 환불 대상인 TID__c를 저장하기 위한 Set
        Set<String> kTrxIdSet = new Set<String>();
        // 부서 코드를 저장할 Set
        Set<String> deptCodeSet = new Set<String>();

        // AR확정관리(SR_AR_CONFIRM) -> 적자 조회를 위한 흑자건들
        SR_AR_CONFIRM__c[] kBlacks = null;
        // 최종 흑자건과 그에 관련된 적자건들
        SR_AR_CONFIRM__c[] kBlackReds = null;

        // 문자열 임시변수
        String str = null, query = null, moId = null;

        query = 'SELECT Id, Order_Number__c, ReturnOrderId, ProductRequestLineItem.POINT_TRX_ID__c, POINT_REFUND_Complete_YN__c, ETC_REFUND_Complete_YN__c, ProductRequestLineItem.Parent.SALE_Number__c';
        query += ' FROM ReturnOrderLineItem';
        query += ' WHERE Id IN:roLiIdSet';
        // query += ' AND Consumables_Order_YN__c=TRUE';
        //20230524 ysh 여기선 택배주문만 처리
        query += ' AND Order_CHNL_TYPE_Code__c=\'V\'';
        query += ' AND REFUND_Complete_YN__c = FALSE';
        // query += ' AND ReturnOrder.Consumables_Order_YN__c=TRUE';
        query += ' AND RecordType.DeveloperName=\'Consumable\'';

        System.debug('ReturnOrder LineItem 조회 : ' + query);
        roLiList = Database.query(query);

        System.debug('조회된 ReturnOrderLineItem 개수 : ' + roLiList.size());
        for (ReturnOrderLineItem roLi : roLiList) {
            System.debug(roLi);
            if (roLi.ReturnOrderId != null) {
                roIdSet.add(roLi.ReturnOrderId);
                tmpRoLiList = roIdRoLiListMap.containsKey(roLi.ReturnOrderId)
                        ? roIdRoLiListMap.get(roLi.ReturnOrderId)
                        : new List<ReturnOrderLineItem>();
                tmpRoLiList.add(roLi);
                roIdRoLiListMap.put(roLi.ReturnOrderId, tmpRoLiList);
            }
            if (roLi.Order_Number__c != null) {
                orderNumberSet.add(roLi.Order_Number__c);
            }
            if (roLi.ProductRequestLineItem.Parent.SALE_Number__c != null) {
                saleNumberSet.add(roLi.ProductRequestLineItem.Parent.SALE_Number__c);
            }
            if (roLi.ProductRequestLineItem.POINT_TRX_ID__c != null) {
                kTrxIdSet = roIdTrxIdSetMap.containsKey(roLi.ReturnOrderId)
                        ? roIdTrxIdSetMap.get(roLi.ReturnOrderId)
                        : new Set<String>();
                kTrxIdSet.add(roLi.ProductRequestLineItem.POINT_TRX_ID__c);
                roIdTrxIdSetMap.put(roLi.ReturnOrderId, kTrxIdSet);
                kTrxIdRoLiMap.put(roLi.ProductRequestLineItem.POINT_TRX_ID__c, roLi);
            }
        }

        // ReturnOrder 쿼리
        // ProductRequest.Department_Code__c
        query = 'SELECT Id, ProductRequest.SR_SALE__c, ProductRequest.Department_Code__c, ProductRequest.Department_Id__c,';
        query += ' RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c';
        query += ' FROM ReturnOrder';
        query += ' WHERE Id IN:roIdSet';
        // query += ' AND Consumables_Order_YN__c=TRUE';
        query += ' AND RecordType.DeveloperName=\'Consumable\'';

        System.debug('ReturnOrder 조회 : ' + query);
        roList = Database.query(query);

        System.debug('조회된 ReturnOrder 개수 : ' + roList.size());
        System.debug('ReturnOrder');
        for (ReturnOrder ro : roList) {
            System.debug(ro);
            deptCodeSet.add(ro.ProductRequest.Department_Code__c);
        }

        // 조직 (부서) 조회
        query = 'SELECT Id, DEPT_CODE__c, DEPT_NAME__c';
        query += ' FROM SM_DEPT__c';
        query += ' WHERE DEPT_CODE__c IN:deptCodeSet';

        smDeptList = Database.query(query);

        for (SM_DEPT__c smDept : smDeptList) {
            if (!deptCodeMap.containsKey(smDept.DEPT_CODE__c)) {
                deptCodeMap.put(smDept.DEPT_CODE__c, smDept);
            }
        }

        // ProductRequest 쿼리
        query = 'SELECT Id, SR_SALE__c';
        query += ' FROM ProductRequest';
        query += ' WHERE Order_Number__c IN:orderNumberSet';
        // query += ' AND Consumables_Order_YN__c=TRUE';
        // query += ' AND Consumables_Order_USE_YN__c=TRUE';
        query += ' AND RecordType.DeveloperName=\'Consumable\'';
        prList = Database.query(query);

        System.debug('ProductRequest 조회 : ' + query);
        prList = Database.query(query);

        System.debug('조회된 ProductRequest 개수 : ' + prList.size());
        System.debug('ProductRequest');
        for (ProductRequest pr : prList) {
            System.debug(pr);
        }
        //System.debug('prList : ' + prList);

        // ProductRequest를 순회하면서 판매 정보(SR_SALE__c) Id 저장
        for (ProductRequest pr : prList) {
            if (pr.SR_SALE__c != null) {
                saleIdSet.add(pr.SR_SALE__c);
            }
        }

        query = 'SELECT Id, SR_PAYMENT_BASIS_ID__r.SR_SALE_ID__c';
        query += ', SR_PAYMENT_BASIS_ID__r.BASIS_NO__c';
        query += ', TID_CASH__c';
        query += ', TID__c';
        query += ', APPR_NUM__c';
        query += ', DEPOSIT_TYPE__c';
        query += ', UPAD_DETAIL_TYPE__c';
        query += ', INVOICE_ISSUE_TYPE__c';
        query += ', AR_INVOICE_NO__c';
        query += ', DEPOSIT_AMT__c';
        query += ' FROM SR_AR_CONFIRM__c';
        query += ' WHERE SR_PAYMENT_BASIS_ID__r.SR_SALE_ID__c IN:saleIdSet';
        query += ' AND FM_RED_BLACK__c=\'B\'';
        query += ' AND LAST_SR_AR_CONFIRM_ID__c = NULL';

        System.debug('최종 흑자건 조회 : ' + query);

        kBlacks = Database.query(query);
        System.debug('조회된 최종 흑자건 개수 : ' + query);
        //System.debug('kBlacks : ' + kBlacks.size());

        // Key: SR_SALE__c Id,  Value: SR_AR_CONFIRM__c List
        for (SR_AR_CONFIRM__c arConfirm : kBlacks) {
            System.debug(arConfirm);
            str = arConfirm.SR_PAYMENT_BASIS_ID__r.SR_SALE_ID__c;
            arConfirmList = saleIdArConfirmMap.containsKey(str)
                    ? saleIdArConfirmMap.get(str)
                    : new List<SR_AR_CONFIRM__c>();
            arConfirmList.add(arConfirm);
            saleIdArConfirmMap.put(str, arConfirmList);
        }

        query = 'SELECT Id, BASIS_NO__c, (SELECT Id, MOID__c';
        query += ', POINT_TRX_ID__c';
        query += ', SR_SMARTRO_PAYMENT_REQUEST_ID__r.SR_AR_CONFIRM_ID__c';
        query += ' FROM SR_PAYMENT_HIST_DETAILS__r)';
        query += ' FROM SR_PRE_PAYMENT_HEADER__c';
        query += ' WHERE BASIS_NO__c=:orderNumberSet';
        System.debug('SR_PRE_PAYMENT_HEADER 조회 : ' + query);
        headerList = Database.query(query);
        System.debug('조회된 SR_PRE_PAYMENT_HEADER__c 개수 : ' + headerList.size());

        // Key: BASIS_NO__c(Order_Number)  Value: MOID
        for (SR_PRE_PAYMENT_HEADER__c header : headerList) {
            for (SR_PRE_PAYMENT_DETAIL__c detail : header.SR_PAYMENT_HIST_DETAILS__r) {
                System.debug('detail : ' + detail);
                System.debug('detail arconfirm : ' + detail.SR_SMARTRO_PAYMENT_REQUEST_ID__r.SR_AR_CONFIRM_ID__c);
                if (detail.MOID__c != null && !detail.MOID__c.equals('')) {
                    saleNumberMOIDMap.put(header.BASIS_NO__c, detail.MOID__c);
                }
                if (detail.POINT_TRX_ID__c != null && !detail.POINT_TRX_ID__c.equals('')) {
                    String arConfirmId = null;
                    if (detail.SR_SMARTRO_PAYMENT_REQUEST_ID__r.SR_AR_CONFIRM_ID__c != null
                            && !String.valueOf(detail.SR_SMARTRO_PAYMENT_REQUEST_ID__r.SR_AR_CONFIRM_ID__c).equals('')) {
                        confirmIdTrxIdMap.put(detail.SR_SMARTRO_PAYMENT_REQUEST_ID__r.SR_AR_CONFIRM_ID__c, detail.POINT_TRX_ID__c);
                    }
                }
            }
        }

        // paramMap.put('saleIdArConfirmMap', saleIdArConfirmMap);
        paramMap.put('saleNumberMOIDMap', saleNumberMOIDMap);
        paramMap.put('deptCodeMap', deptCodeMap);
        paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
        paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
        paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
        paramMap.put('kTrxIdRoLiMap', kTrxIdRoLiMap);

        for (ReturnOrder ro : roList) {
            for (SR_AR_CONFIRM__c arConfirm : saleIdArConfirmMap.get(ro.ProductRequest.SR_SALE__c)) {
                // SR_AR_CONFIRM 별 Async 호출
                // todo: 배치 들어오기전 INVOICE_NO 삽입 . 테스트용
                arConfirm.AR_INVOICE_NO__c = '^ㅇ^';
                if (!Test.isRunningTest()) {
                    System.enqueueJob(new EX_ReturnConfirmQueueable(ro, arConfirm, paramMap, null));
                }
            }
        }

        // 외부채널 교환주문 적자채권
        exChannelRed(roLiIdSet);
    }

    /**
    * @description 서브번호 채번을 위한 Wrapper
    * @author 23.02.20 / I2MAX.SEUNGHUNAN
    * @return Integer
    */
    public class LineItemWrapper implements Comparable {
        public sObject lineItem;

        public LineItemWrapper(sObject sObj) {
            lineItem = Schema.getGlobalDescribe().get(String.valueOf(sObj.getSObjectType())).newSObject();
            lineItem.put('CreatedDate', sObj.get('CreatedDate'));
            lineItem.put('Order_Number__c', sObj.get('Order_Number__c'));
            lineItem.put('Order_SEQ__c', sObj.get('Order_SEQ__c'));
            lineItem.put('SUB_Order_Number__c', '1');
            lineItem.put('Id', sObj.get('Id'));
        }

        /**
        * @description 서브번호 채번을 위해 List 정렬 Order By OrderNumber, Order_Seq, CreatedDate
        * @author 23.02.20 / I2MAX.SEUNGHUNAN
        * @return Integer
        */
        public Integer compareTo(Object compareTo) {
            sObject cmpTo = null;
            String jsonStr = compareTo.toString();
            jsonStr = jsonStr.substring(jsonStr.indexOf('{') + 1, jsonStr.indexOf('}'));
            String[] infoStr = jsonStr.split(',');
            String jsonStr2 = '';

            for (String tStr : infoStr) {
                jsonStr2 += ('"' + tStr.split('=')[0].replace(' ', '') + '"');
                jsonStr2 += (':');
                if (tStr.contains(':')) {
                    //2023-02-15 08:21:31
                    String tmpStr = tStr.split('=')[1];
                    String tmpStr1 = tmpStr.split(' ')[0];
                    String tmpStr2 = tmpStr.split(' ')[1];
                    tmpStr = tmpStr1 + 'T' + tmpStr2 + '.000+0000';
                    jsonStr2 += ('"' + tmpStr + '",');
                } else {
                    jsonStr2 += ('"' + tStr.split('=')[1] + '",');
                }
            }

            jsonStr2 = '{' + jsonStr2.subString(0, jsonStr2.length() - 1
            ) + '}';
            if (compareTo.toString().contains('ProductRequestLineItem')) {
                cmpTo = (ProductRequestLineItem) JSON.deserialize(jsonStr2, ProductRequestLineItem.class);
            } else {
                cmpTo = (ReturnOrderLineItem) JSON.deserialize(jsonStr2, ReturnOrderLineItem.class);
            }
            Datetime dt1 = (DateTime) lineItem.get('CreatedDate');
            Datetime dt2 = (DateTime) cmpTo.get('CreatedDate');
            String orderNumber1 = (String) lineItem.get('Order_Number__c');
            String orderNumber2 = (String) cmpTo.get('Order_Number__c');
            Decimal oSeq1 = (Decimal) lineItem.get('Order_SEQ__c');
            Decimal oSeq2 = (Decimal) cmpTo.get('Order_SEQ__c');

            if (orderNumber1.equals(orderNumber2)) {
                if (oSeq1 == oSeq2) {
                    if (dt1 >= dt2) {
                        return 1;
                    } else return -1;
                } else return Integer.valueOf(oSeq1 - oSeq2);
            } else return orderNumber1.compareTo(orderNumber2);
        }
    }


    /**
     * @description 소모품에서 사용하는 조직별 영업일 계산 공통 모듈
     * @AUTHOR I2MAX.SEOKHOLEE
     * @date  2023-03-02
     * @param deptCode : 조직 코드 / 조직별 휴일 관리
     * @param requestedDate : 현재 요청하는 일자
     * @param requestedWorkingDay : 현재 요청하는 일자 + requestedWorkingDays(영업 일)
     *
     * @return
     */
    public static Map<String, Object> calculateWorkingDays(String deptCode, Date requestedDate, Integer requestedWorkingDays) {
        Map<String, Object> resultMap = new Map<String, Object>();

        // TODO : 영업일 관련하여 조회 후 구현하여야 함.

        // 요청 데이터 리턴용
        resultMap.put('deptCode', deptCode);
        resultMap.put('requestedDate', requestedDate);
        resultMap.put('requestedWorkingDays', requestedWorkingDays);

        Date calculateWorkingDate = requestedDate;
        // 계산 데이터
        // 계산 후 Target Date
        resultMap.put('calculateWorkingDate', calculateWorkingDate.addDays(requestedWorkingDays));
        // 계산 후 영업 일이 아닌 실제 일 수
        resultMap.put('afterCalculateDays', requestedWorkingDays);

        return resultMap;
    }

    // TODO : working Day 구해 오는 Method 구현 필요
    public static Map<String, Map<String, Object>> getWorkingDays(String deptCode, Date requestedDate, Integer requestedWorkingDays) {
        return workingDaysMap != null ? workingDaysMap : null;
    }

    @AuraEnabled
    public static Date getDateWithNull(Object obj) {
        Date dt = null;
        if (obj != null) {
            dt = Date.valueOf(obj);
        }
        return dt;
    }

    @AuraEnabled
    public static Datetime getDatetimeWithNull(Object obj) {
        Datetime dt = null;
        if (obj != null) {
            dt = Datetime.valueOf(obj);
        }
        return dt;
    }

    @AuraEnabled
    public static String getStringNotNull(Object obj) {
        String str = '';
        if (obj != null) {
            str = String.valueOf(obj);
        }
        return str;
    }

    @AuraEnabled
    public static Integer getIntegerNotNull(Object obj) {
        Integer i = 0;
        if (obj != null) {
            i = Integer.valueOf(obj);
        }
        return i;
    }

    @AuraEnabled
    public static Double getDoubleNotNull(Object obj) {
        Double d = 0;
        if (obj != null) {
            d = Double.valueOf(obj);
        }
        return d;
    }

    @AuraEnabled
    public static Decimal getDecimalNotNull(Object obj) {
        Decimal d = 0;
        if (obj != null) {
            d = Decimal.valueOf(Double.valueOf(obj));
        }
        return d;
    }


    /**
     * @description 소모품센터(창고) 의 Location Id
     * @author I2MAX.SEOKHOLEE
     */
    public static Id getConsumableSiteId() {
        return [
                SELECT Name, DEPT_CODE__c, LocationType, Id
                FROM Location
                WHERE DEPT_CODE__c = 'PH8002'
                AND LocationType = 'Site'
        ]?.Id;
    }
    /**
     * @description 소모품센터(창고) 의 적치장소 Location Id
     * @author I2MAX.SEOKHOLEE
     */
    public static Id getConsumableWareHouseId() {
        return [
                SELECT Name, DEPT_CODE__c, LocationType, Id
                FROM Location
                WHERE DEPT_CODE__c = 'PH8002'
                AND LocationType = 'Warehouse'
                AND Location.Name = :System.Label.EX_Location
        ]?.Id;
    }
    /**
     * @description 케어용품센터(창고) 의 Location Id
     * @author I2MAX.SEOKHOLEE
     */
    public static Id getCarePlusWareSiteId() {
        return [
                SELECT Name, DEPT_CODE__c, LocationType, Id
                FROM Location
                WHERE DEPT_CODE__c = 'PH0300'
                AND LocationType = 'Site'
        ]?.Id;
    }

    /**
     * @description 케어용품센터(창고) 의 적치장소 Location Id
     * @author I2MAX.SEOKHOLEE
     */
    public static Id getCarePlusWareHouseId() {
        return [
                SELECT Name, DEPT_CODE__c, LocationType, Id
                FROM Location
                WHERE DEPT_CODE__c = 'PH0300'
                AND LocationType = 'Warehouse'
                AND Location.Name = :System.Label.EX_Location
        ]?.Id;
    }
    /**
     * @param pStrUserId
     * @description 사용자 로그인 정보 가져오기 / 자재영역 Util Clone
     * @author I2MAX.SEOKHOLEE
     * @return
     */
    @AuraEnabled
    public static Map<String, Object> getUserInfo(String pStrUserId) {
        User objUser = new User();
        // 상담사 여부
        Boolean isConsultant = false;


        if (pStrUserId == null || pStrUserId == '') pStrUserId = UserInfo.getUserId();
        objUser = [
                SELECT DEPT_CODE__c, Name, EmployeeNumber, Id, Responsibility__c
                FROM User
                WHERE Id = :pStrUserId
        ];

        System.debug('objUser: ' + objUser);
        if (objUser.DEPT_CODE__c == null) {
            throw new AuraHandledException('사용자의 조직코드 값이 없습니다.');
        }

        // ServiceResource objSR = new ServiceResource();
        // try {
        //     objSR = [
        //             SELECT Id, Name, JOB_TYPE__c, RecordType.DeveloperName
        //             FROM ServiceResource
        //             WHERE RelatedRecordId = :objUser.Id
        //             AND IsActive = TRUE
        //     ];
        // } catch (Exception e) {
        //     throw new AuraHandledException('사용자 이름의 서비스자원(ServiceResource) 데이터가 없습니다.');
        // }
        
        //23 09 20 hyungho.chun 사용자id로 service Resource 없으면 바로 AuraHandledException
        List<ServiceResource> objSR = new List<ServiceResource>();
        objSR = [
                SELECT Id, Name, JOB_TYPE__c, RecordType.DeveloperName
                FROM ServiceResource
                WHERE RelatedRecordId = :objUser.Id
                AND IsActive = TRUE
        ];

        if(objSR.size() == 0){
            throw new AuraHandledException('사용자 이름의 서비스자원(ServiceResource) 데이터가 없습니다.');
        }

        System.debug('objSR: ' + objSR);

        // if (objSR.RecordType.DeveloperName == 'CNSL') {
        if (objSR[0].RecordType.DeveloperName == 'CNSL') {            
            isConsultant = true;
        }

        // SM_DEPT__c objSmDept = new SM_DEPT__c();
        // try {
        //     objSmDept = [
        //             SELECT Id, Name, DEPT_CODE__c, HIGH_DEPT_CODE__c, DEPT_TYPE_SECOND__c, HIGH_DEPT_CODE__r.DEPT_CODE__c, AGENCY_DC_RATE__c
        //             FROM SM_DEPT__c
        //             WHERE DEPT_CODE__c = :objUser.DEPT_CODE__c
        //     ];
        // } catch (Exception e) {
        //     throw new AuraHandledException('사용자 소속의 조직(SM_DEPT__c) 데이터가 없습니다.');
        // }

        Map<String, Object> deptMap = getDeptInfo(objUser.DEPT_CODE__c);
        
        //23 09 20 hyungho.chun 사용자 dept_code로 SM_DEPT__c 없으면 바로 AuraHandledException
        // List<SM_DEPT__c> objSmDept = new List<SM_DEPT__c>();
        
        // objSmDept = [
        //         SELECT Id, Name, DEPT_CODE__c, HIGH_DEPT_CODE__c, DEPT_TYPE_SECOND__c, HIGH_DEPT_CODE__r.DEPT_CODE__c, AGENCY_DC_RATE__c
        //         FROM SM_DEPT__c
        //         WHERE DEPT_CODE__c = :objUser.DEPT_CODE__c
        // ];

        // if(objSmDept.size()==0){
        //     throw new AuraHandledException('사용자 소속의 조직(SM_DEPT__c) 데이터가 없습니다.');
        // }
        
        // Set<String> setDeptTypeSecond = new Set<String>{
        //         'I', 'J', 'Q', 'M'
        // };
        // String strCenterCode = objUser.DEPT_CODE__c;
        // if (setDeptTypeSecond.contains(objSmDept[0].DEPT_TYPE_SECOND__c)) {
        //     strCenterCode = objSmDept[0].HIGH_DEPT_CODE__r.DEPT_CODE__c;
        // }
        // System.debug('strDeptCode: ' + strCenterCode);

        // TODO : 상담사인 경우 Skip 필요

        Schema.Location objLocation = null;
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


        List<PermissionSetAssignment> listPermissionSetAssignment = [
                SELECT PermissionSet.Name
                        , PermissionSetId
                FROM PermissionSetAssignment
                WHERE AssigneeId = :pStrUserId
        ];

        PermissionSetAssignment objPSA = new PermissionSetAssignment();
        if (!listPermissionSetAssignment.isEmpty()) {
            for (PermissionSetAssignment tempPSA : listPermissionSetAssignment) {
                System.debug('tempPSA Name :: ' + tempPSA.PermissionSet.Name);
                if (tempPSA.PermissionSet.Name == 'FS_ProductItemAdmin') {
                    objPSA = tempPSA;
                }
            }
        }

        Map<String, Object> mapReturn = new Map<String, Object>{
                'User' => objUser,
                'DEPT' => deptMap.get('DEPT'),
                'ServiceResource' => objSR[0],
                'Location' => objLocation,
                'PermissionSetAssignment' => objPSA
        };

        return mapReturn;
    }

    @AuraEnabled
    public static Map<String, Object> getDeptInfo(String deptCode) {

        Map<String, Object> returnMap = new Map<String,Object>();
        
         //23 09 20 hyungho.chun 사용자 dept_code로 SM_DEPT__c 없으면 바로 AuraHandledException
         List<SM_DEPT__c> objSmDept = new List<SM_DEPT__c>();
            
         objSmDept = [
                 SELECT Id, Name, DEPT_CODE__c, HIGH_DEPT_CODE__c, DEPT_TYPE_SECOND__c, HIGH_DEPT_CODE__r.DEPT_CODE__c, AGENCY_DC_RATE__c
                 FROM SM_DEPT__c
                 WHERE DEPT_CODE__c = :deptCode
         ];
    
         if(objSmDept.size()==0){
             throw new AuraHandledException('사용자 소속의 조직(SM_DEPT__c) 데이터가 없습니다.');
         }
         
        //  Set<String> setDeptTypeSecond = new Set<String>{
        //          'I', 'J', 'Q', 'M'
        //  };
        //  String strCenterCode = deptCode;
        //  if (setDeptTypeSecond.contains(objSmDept[0].DEPT_TYPE_SECOND__c)) {
        //      strCenterCode = objSmDept[0].HIGH_DEPT_CODE__r.DEPT_CODE__c;
        //  }
        //  System.debug('strDeptCode: ' + strCenterCode);

        returnMap.put('DEPT' , objSmDept[0]);

        return returnMap;

    }


    /**
     * @description 문자열을 원화로 콤마 추가하여 파싱
     * @param String str
     * @author I2MAX.SEUNGHUNAN
     * @return String returnStr
     */
    public static String strToCurrencyWon(String str) {
        String returnStr = '';
        for (Integer i = 0; i < str.reverse().length(); i++) {
            if (i != 0 && Math.mod(i, 3) == 0) returnStr += ',';
            returnStr += str.reverse().substring(i, i + 1);
        }
        return returnStr.reverse();
    }
    /**
    * @description 알림톡 date MM월/dd일 형식으로 변환
    * @param String str
    * @author I2MAX.JAEYEONLEE
    * @return String returnStr
    */
    public static String convertDate(Datetime msgDate) {
        String convertDate = msgDate.format('MM월 dd일(E)');
        String dayOfWeek = convertDate.substring(convertDate.length() - 5, convertDate.length());
        String koreanDayOfWeek;
        System.debug('dayOfWeek : ' + dayOfWeek);
        switch on dayOfWeek {
            when '(Sun)' {
                koreanDayOfWeek = '(일)';
            }
            when '(Mon)' {
                koreanDayOfWeek = '(월)';
            }
            when '(Tue)' {
                koreanDayOfWeek = '(화)';
            }
            when '(Wed)' {
                koreanDayOfWeek = '(수)';
            }
            when '(Thu)' {
                koreanDayOfWeek = '(목)';
            }
            when '(Fri)' {
                koreanDayOfWeek = '(금)';
            }
            when '(Sat)' {
                koreanDayOfWeek = '(토)';
            }
        }
        System.debug('koreanDayOfWeek : ' + koreanDayOfWeek);
        convertDate = convertDate.replace(dayOfWeek, koreanDayOfWeek);
        return convertDate;
    }
    /**
     * @description DeptCode로 조직명 조회
     * @author I2MAX.SEOKHOLEE
     */
    public static String getDepartmentName(String deptCode) {
        return [
                SELECT Name
                FROM SM_DEPT__c
                WHERE DEPT_CODE__c = :deptCode
                LIMIT 1
        ]?.Name;
    }
    public static Map<String, String> getDepartmentNameMap(Set<String> deptCodeSet) {
        Map<String, String> deptNameMap = new Map<String, String>();
        List<SM_DEPT__c> deptList = [
                SELECT Name, DEPT_CODE__c
                FROM SM_DEPT__c
                WHERE DEPT_CODE__c IN:deptCodeSet
        ];
        for (SM_DEPT__c dept : deptList) {
            if (!deptNameMap.containsKey(dept.DEPT_CODE__c)) {
                deptNameMap.put(dept.DEPT_CODE__c, dept.Name);
            }
        }
        return deptNameMap;
    }

    public static void createNotExistProductItem(Set<String> productIdSet) {
        createNotExistProductItem(productIdSet, 'PH8002');
    }
    /**
    * @description 소모품 재고가 없는 경우 소모품 적치장소 재고 및 사업부 재고 레코드 생성
    * @param Set<String> productIdSet
    * @author I2MAX.SEOKHOLEE
    * @return
    */
    public static void createNotExistProductItem(Set<String> productIdSet, String deptCode) {
        String warehouseLocationId;
        if(deptCode == 'PH8002') {
            warehouseLocationId = EX_ConsumableUtil.getConsumableWareHouseId();
        } else if(deptCode == 'PH0300') {
            warehouseLocationId  = EX_ConsumableUtil.getCarePlusWareHouseId();
        }

        List<Product2> product2s = [
                SELECT Id, Name, PART_SPEC__c, ProductCode, MODEL_CODE__c, CUST_PRICE__c, ASC_PRICE__c, TECH_GRADE_PROD_CODE__c, TECH_PART_YN__c, DIV_CODE__c, DisplayUrl, Description, PART_DESC_KOR__c,
                        Disabled_Type__c, PART_TYPE__c, DISABLED_DT__c, DISABLED_REL_DT__c, THINQ_ITEM_YN__c, PARCEL_YN__c, lu_MODEL_CODE__c, OBS_DISPLAY_YN__c, (
                        SELECT Id, Name, toLabel(SUBSTITUTE_TYPE__c), SUBSTITUTE_PART_NO__c, PART_NO__r.lu_MODEL_CODE__c,
                                SUBSTITUTE_PART_NO__r.ProductCode, SUBSTITUTE_PART_NO__r.DIV_CODE__c, SUBSTITUTE_PART_NO__r.Name
                        FROM SM_SUBSTITUTE_PART_Product_PART__r
                )
                FROM Product2
                WHERE Id IN :productIdSet
        ];

        // 재고 생성을 위한 로직
        Map<String, Product2> exKeyMap = new Map<String, Product2>();
        Map<String, Schema.Location> divLocationMap = new Map<String, Schema.Location>();
        Map<String, Schema.Location> locationIdMap = new Map<String, Schema.Location>();

        for (Schema.Location lo : [SELECT Id, DIV_CODE__c, SM_DEPT_Id__r.DEPT_CODE__c FROM Location WHERE RecordType.DeveloperName = 'DIV']) {
            divLocationMap.put(lo.DIV_CODE__c, lo);
            locationIdMap.put(lo.Id, lo);
        }

        Set<String> productCodeSet = new Set<String>();
        Set<String> divCodeSet = new Set<String>();
        Map<String, Product2> partMasterMap = new Map<String, Product2>();

        for (Product2 prod2 : product2s) {
            productCodeSet.add(prod2.Name);
            divCodeSet.add(prod2.DIV_CODE__c);

            if (prod2.DIV_CODE__c != null && prod2.Name != null) {
                String productExternalKey = prod2.DIV_CODE__c + '_' + prod2.Name;
                partMasterMap.put(productExternalKey, prod2);
            }

            String custExternalKey = prod2.DIV_CODE__c + '_' + prod2.Name + '_' + warehouseLocationId;
            exKeyMap.put(custExternalKey, prod2);

            if (divLocationMap.containsKey(prod2.DIV_CODE__c)) {
                custExternalKey = prod2.DIV_CODE__c + '_' + prod2.Name + '_' + divLocationMap.get(prod2.DIV_CODE__c).Id;
                exKeyMap.put(custExternalKey, prod2);
            }
        }

        // 재고 조회
        // 소모품 적치장소 + 사업부
        Map<String, ProductItem> productItemMap = new Map<String, ProductItem>([
                SELECT Id, QuantityOnHand, fm_Available_Quantity__c, fm_Computerized_Quantity__c, RESRV_QTY__c,
                        LocationId, Location.DEPT_CODE__c, Location.LocationType, Location.DIV_CODE__c,
                        ProductName, DIV_CODE__c, Product2Id, Product2.Name, Product2.DIV_CODE__c,
                        Location.RecordType.DeveloperName
                FROM ProductItem
                WHERE Product2.Name IN :productCodeSet
                AND Product2.PART_TYPE__c = 'D'
                AND ((Location.DEPT_CODE__c = :deptCode AND Location.LocationType = 'Warehouse' AND Location.Name = :System.Label.EX_Location)
                OR (Location.RecordType.DeveloperName = 'DIV' AND Location.DIV_CODE__c IN :divCodeSet))
        ]);


        System.debug('productItemMap -> ' + productItemMap);

        Map<String, ProductItem> piMap = new Map<String, ProductItem>();
        for (ProductItem pi : productItemMap.values()) {
            String piKey = pi.Product2.DIV_CODE__c + '_' + pi.Product2.Name + '_' + pi.LocationId;
            piMap.put(piKey, pi);
        }

        System.debug(':::::::::::::::::::::::::::::::::::::::::');
        System.debug('piMap -> ' + piMap);
        System.debug('exKeyMap -> ' + exKeyMap);
        System.debug(':::::::::::::::::::::::::::::::::::::::::');
        Set<String> insertTarget = new Set<String>();
        for (String exKey : exKeyMap.keySet()) {
            System.debug(exKey + ' contains ? ' + piMap.containsKey(exKey));
            if (!piMap.containsKey(exKey)) {
                insertTarget.add(exKey);
            }
        }

        Map<String, ProductItem> insertProductItemMap = new Map<String, ProductItem>();
        ProductItem newPi;
        for (String key : insertTarget) {
            List<String> splitKeyList = key.split('_');

            String custExternalKey = splitKeyList[0] + '_' + splitKeyList[1];
            newPi = new ProductItem();
            // 조직코드_사업부코드_파트넘버_적치장소이름
            // PH0006_CNZ_AGF30366710_04U03A

            newPi.LocationId = splitKeyList[2];
            newPi.Product2Id = partMasterMap.get(custExternalKey).Id;
            
            //23 12 20 hyungho.chun productItem 생성시 DivCode찾아넣기
            newPi.DIV_CODE__c = partMasterMap.get(custExternalKey).DIV_CODE__c != null ? partMasterMap.get(custExternalKey).DIV_CODE__c : null;

            newPi.QuantityOnHand = 0;

            // 사업부 인경우
            // if(divLocationMap.containsKey(newPi.LocationId)) {
            //     newPi.External_id__c = divLocationMap.get(newPi.LocationId).DIV_CODE__c + '_' +  'SYSTEM' + '_' + divLocationMap.get(newPi.LocationId).DIV_CODE__c + '_' +  partMasterMap.get(custExternalKey).Name;
            // } else {         
            // }
            insertProductItemMap.put(custExternalKey, newPi);
        }

        System.debug('insertProductItemMap => ' + insertProductItemMap);
        //insert insertProductItemMap.values();
        Database.insert(insertProductItemMap.values(), false);
    }
    public static void doSendChatterFeed(Set<String> targetIds) {
        List<CollaborationGroup> consumableGroups = [
                SELECT Id
                FROM CollaborationGroup
                WHERE Name = '소모품 운영 담당'
                LIMIT 1
        ];

        List<SR_ONLINE_AUTO_SALE_EXC__c> targets = [
                SELECT SourceRecordId__c, Id, ORDER_NO__c, ErrorType__c
                FROM SR_ONLINE_AUTO_SALE_EXC__c
                WHERE Id IN :targetIds
        ];

        List<ConnectApi.BatchInput> listBatchInput = new List<ConnectApi.BatchInput>();

        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();

        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        ConnectApi.FeedElementCapabilitiesInput feedElementCapabilitiesInput = new ConnectApi.FeedElementCapabilitiesInput();
        ConnectApi.LinkCapabilityInput linkCapabilityInput = new ConnectApi.LinkCapabilityInput();

        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        for (SR_ONLINE_AUTO_SALE_EXC__c target : targets) {

            String errorType = '';
            switch on target.ErrorType__c {
                when 'SaveSales' {
                    errorType = '판매저장';
                }
                when 'ReturnConfirm' {
                    errorType = '반품확정';
                }
                when 'Reserve' {
                    errorType = '예약';
                }
            }
            system.debug('consumableGroups : '+consumableGroups);
            // 멘션 설정
            mentionSegmentInput.id = consumableGroups[0].Id;
            messageBodyInput.messageSegments.add(mentionSegmentInput);

            // 내용 설정
            String comment = '\\n';
            comment += '\'' + errorType + '\'' + ' 처리 시 오류가 발생 하였습니다.';
            comment += '\\n';
            comment += '담당자는 확인하여 조치 바랍니다.';
            comment += '\\n';

            textSegmentInput.text = comment;
            textSegmentInput.text += '\\n';

            messageBodyInput.messageSegments.add(textSegmentInput);

            // Link 설정
            linkCapabilityInput.url = baseUrl + '/' + target.SourceRecordId__c;
            linkCapabilityInput.urlName = 'URL Link';
            feedElementCapabilitiesInput.link = linkCapabilityInput;

            feedItemInput.subjectId = target.Id;                            // 게시자
            feedItemInput.body = messageBodyInput;                        // 10,000자 Limit (2022.12.16 기준)
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;    // 값은 Feed Item만 가능. 필수값.
            feedItemInput.capabilities = feedElementCapabilitiesInput;            // Link 삽입
            // feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;

            ConnectApi.EntityLinkSegmentInput entityLinkSegmentInputEndpSupReq = new ConnectApi.EntityLinkSegmentInput();
            entityLinkSegmentInputEndpSupReq.entityId = target.SourceRecordId__c;
            messageBodyInput.messageSegments.add(entityLinkSegmentInputEndpSupReq);

            ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
            listBatchInput.add(batchInput);
        }
        System.debug('*** listBatchInput: ' + listBatchInput);
        ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), listBatchInput);
    }

    public static Map<String, Object> reCheckAvailableQty(List<EX_SuppliesController.ItemTable> standardOrderDataList, List<EX_SuppliesController.ItemTable> soldOutOrderDataList) {
        Map<String, Object> objectMap = new Map<String, Object>();
        Set<String> productIdSet = new Set<String>();

        List<EX_SuppliesController.ItemTable> reCalculateDataList = new List<EX_SuppliesController.ItemTable>();
        reCalculateDataList.addAll(standardOrderDataList);
        reCalculateDataList.addAll(soldOutOrderDataList);

        for (EX_SuppliesController.ItemTable reCalcItem : reCalculateDataList) {
            productIdSet.add(reCalcItem.sProductId);
        }

        System.debug('productIdSet ::: ' + productIdSet);

        Map<String, ProductItem> productItemMap = new Map<String, ProductItem>([
                SELECT Id, QuantityOnHand, fm_Available_Quantity__c, fm_Computerized_Quantity__c, RESRV_QTY__c, ORDER_QTY__c,
                        LocationId, Location.DEPT_CODE__c, Location.LocationType, Location.DIV_CODE__c,
                        ProductName, DIV_CODE__c, Product2Id, Product2.Name, Product2.DIV_CODE__c, 
                        Location.RecordType.DeveloperName
                FROM ProductItem
                WHERE Product2Id IN :productIdSet
                AND ((Location.DEPT_CODE__c = :EX_ConsumableUtil.PH8002 AND Location.LocationType = 'Warehouse' AND Location.Name = :System.Label.EX_Location)
                OR (Location.RecordType.DeveloperName = 'DIV'))
        ]);
        // item 의 소모품 센터 가용 수량
        Map<String, ProductItem> itemAvailableQtyMap = new Map<String, ProductItem>();
        // item 의 사업부 가용 수량
        Map<String, ProductItem> itemAvailableDIVQtyMap = new Map<String, ProductItem>();

        System.debug('productItemMap :: ' + productItemMap.values());
        
        for (ProductItem pi : productItemMap.values()) {
            if (pi.Location.DEPT_CODE__c == EX_ConsumableUtil.PH8002 && pi.Location.LocationType == 'Warehouse') {
                String externalKey = EX_ConsumableUtil.PH8002 + '_' + pi.Product2Id;
                itemAvailableQtyMap.put(externalKey, pi);
            } else if (pi.Location.RecordType.DeveloperName == 'DIV') {
                String externalKey = pi.Location.DIV_CODE__c + '_' + pi.Product2Id;
                itemAvailableDIVQtyMap.put(externalKey, pi);
            }
        }

        System.debug('itemAvailableQtyMap :::: ' + itemAvailableQtyMap);

        List<EX_SuppliesController.ItemTable> newStdOrderDataList = new List<EX_SuppliesController.ItemTable>();
        List<EX_SuppliesController.ItemTable> newSoldOutOrderDataList = new List<EX_SuppliesController.ItemTable>();

        /**
           * 재고 재 조회시 재 세팅
           * 출고부서코드
        */

        Map<String, Map<String, String>> parentMap = new Map<String, Map<String, String>>();
        Map<String, String> reserveMap;

        Decimal newStdOrderTotalPaymentAmount = 0;
        Decimal newSoldOutOrderTotalPaymentAmount = 0;
        
        for (EX_SuppliesController.ItemTable reCalcItem : reCalculateDataList) {
            // 소모품 재고
            String consumableProductItemKey = EX_ConsumableUtil.PH8002 + '_' + reCalcItem.sProductId;
            System.debug('consumableProductItemKey ?? ' + consumableProductItemKey);
            System.debug('itemAvailableQtyMap ?? ' + itemAvailableQtyMap);
            ProductItem consumableProductItem = itemAvailableQtyMap.get(consumableProductItemKey);
            // 사업부 재고
            String divProductItemKey = reCalcItem.DIVCODE + '_' + reCalcItem.sProductId;
            ProductItem divProductItem = itemAvailableDIVQtyMap.get(divProductItemKey);
            if (reCalcItem.DiscountAmount == null) {
                reCalcItem.DiscountAmount = 0;
            }

            //24.01.31 gw.lee
            //센터 또는 사업부 재고가 null일 경우, div code 매핑 및 재고 생성
            String divCode = '';
            if (consumableProductItem != null || divProductItem != null) {
                divCode = consumableProductItem != null ? consumableProductItem.Product2.DIV_CODE__c : divProductItem.Location.DIV_CODE__c; //24 03 11 hyungho.chun div_code를 location이 아닌 product2에서 받아와서쓴다 (적치장소 location div_code는 값이 없거나 있더라도 잘못된값임)
            }

            //23.11.06 gw.lee
            //데이터 문제인지 모르겠지만, 현재 둘 중 하나만 있는 경우가 있어서 예외로직 추가
            //센터는 있지만, 사업부가 없는 경우
            //센터는 없지만, 사업부가 있는 경우
            //센터, 사업부 둘 다 있는 경우

            //센터재고
            Decimal centerQty = consumableProductItem != null ? consumableProductItem.fm_Available_Quantity__c : 0;
            //센터제거 + 사업부재고
            Decimal allQty = 0;
            if (consumableProductItem != null && divProductItem == null) {
                allQty = consumableProductItem.fm_Available_Quantity__c;
            } else if (consumableProductItem == null && divProductItem != null) {
                allQty = divProductItem.QuantityOnHand - divProductItem.ORDER_QTY__c;
            } else {
                allQty = consumableProductItem.fm_Available_Quantity__c + (divProductItem.QuantityOnHand - divProductItem.ORDER_QTY__c);
            }
            //사업부재고
            Decimal divQty = divProductItem != null ? divProductItem.QuantityOnHand - divProductItem.ORDER_QTY__c : 0;
            
            
            // 주문 수량이 소모품센터의 수량보다 작거나 같은 경우, 소모품센터에서 출고
            if (centerQty >= reCalcItem.QTY) {
                // ** 일반 주문 **
                reCalcItem.ShipmentCode = EX_ConsumableUtil.PH8002;
                newStdOrderTotalPaymentAmount += reCalcItem.QTY * reCalcItem.Price - reCalcItem.DiscountAmount;

                newStdOrderDataList.add(reCalcItem);
            } else if (allQty >= reCalcItem.QTY) {

                reCalcItem.ShipmentCode = divProductItem.Product2.DIV_CODE__c;
                newStdOrderTotalPaymentAmount += reCalcItem.QTY * reCalcItem.Price - reCalcItem.DiscountAmount;

                newStdOrderDataList.add(reCalcItem);

                Decimal newResrvQTY = reCalcItem.QTY;
                //재고가 센터에 있는 경우
                if (consumableProductItem != null) {
                    if (centerQty < reCalcItem.QTY) {
                        newResrvQTY = reCalcItem.QTY - centerQty;
                    }
                }

                reserveMap = new Map<String, String>{
                    'stdQuantity' => String.valueOf(centerQty),
                    'resrvQuantity' => String.valueOf(newResrvQTY)
                };

                parentMap.put(reCalcItem.sProductId, reserveMap);

            } else if (centerQty < reCalcItem.QTY && divQty >= reCalcItem.QTY) {
                // ** 일반 주문 **
                // 주문 수량이 소모품센터의 수량 보다 크고 사업부의 수량보다는 작거나 같은 경우 사업부에서 출고
                //reCalcItem.ShipmentCode = divProductItem.Location.DIV_CODE__c;
                reCalcItem.ShipmentCode = divCode;
                newStdOrderTotalPaymentAmount += reCalcItem.QTY * reCalcItem.Price - reCalcItem.DiscountAmount;

                

                newStdOrderDataList.add(reCalcItem);
            } else {
                // ** 품절 주문 **
                // 주문수량이 소모품센터 재고수량 보다 크고, 사업부의 재고수량 보다 큰 경우
                //reCalcItem.ShipmentCode = divProductItem.Location.DIV_CODE__c;
                reCalcItem.ShipmentCode = divCode;
                newSoldOutOrderTotalPaymentAmount += reCalcItem.QTY * reCalcItem.Price - reCalcItem.DiscountAmount;

                newSoldOutOrderDataList.add(reCalcItem);
            }

        }

        System.debug('reserveMap :::: ' + parentMap);

        // 재 세팅
        objectMap.put('standardOrderDataList', newStdOrderDataList);
        objectMap.put('soldOutOrderDataList', newSoldOutOrderDataList);
        objectMap.put('stdOrderTotalPaymentAmount', newStdOrderTotalPaymentAmount);
        objectMap.put('soldOutOrderTotalPaymentAmount', newSoldOutOrderTotalPaymentAmount);
        objectMap.put('reserveMap', reserveMap);
        objectMap.put('parentMap', parentMap);
        return objectMap;
    }

    public static void exChannelRed(Set<String> roLiIdSet) {
        /** 2023.05.24 ysh
         * 외부채널 (OBS,ThinQ,NewBest) 적자채권 처리 */
        List<ReturnOrderLineItem> redRoliList = new List<ReturnOrderLineItem>();
        List<ReturnOrderLineItem> exchangeRoLiList = new List<ReturnOrderLineItem>();
        //23 11 29 hyungho.chun
        List<ReturnOrderLineItem> carePlusRoliList = new List<ReturnOrderLineItem>();
        Set<String> carePlusOrderNumSet = new Set<String>();
    
        System.debug('OBS, ThinQ, NewBest 적자 채권생성 시작');
        //23 10 04 hyungho.chun 쿼리에 교환반품에 필요한 필드값 추가
        System.debug('교환주문 적자채권 생성 시작');
        String queryStr = '';
        queryStr = 'SELECT Id, Order_Number__c, SALE_DEFICIT_PAYMENT_Number__c, SR_PAYMENT_BASIS__c,  Order_CHNL_TYPE_Code__c, Order_CUST_Id__c, ReturnOrder.RETURN_CARD_PAYMENT_Amount__c, ProductRequestLineItem.parent.PAYMENT_Amount__c, ProductRequestLineItem.parent.CARD_PAYMENT_Amount__c, ProductRequestLineItem.parent.CASH_PAYMENT_Amount__c, ProductRequestLineItem.parent.POINT_Amount__c' +
                ', returnorder.RETURN_POINT_Amount__c, ReturnOrder.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c,Product2.DIV_CODE__c,Parts_Number__c,QuantityReturned,ProductRequestLineItem.Order_Number__c ' +
                ',RETURN_PAYMENT_Amount__c, Consumables_Business_Type_Code__c'+
                ', returnorder.RETURN_PAYMENT_Amount__c, ProductRequestLineItem.SALE_Number__c' +
                ', ProductRequestLineItem.SR_SALE__c, productrequestlineitem.SR_SALE__r.SALE_DTM__c' +
                ', returnorder.ProductRequest.PAYMENT_COMPLETED_DTM__c, returnorder.Order_Number__c, CreatedDate';
        queryStr += ' FROM ReturnOrderLineItem';
        queryStr += ' WHERE Id IN :roLiIdSet';
        queryStr += ' AND Consumables_Order_YN__c=TRUE';
        queryStr += ' AND (Order_CHNL_TYPE_Code__c IN (\'V\',\'B\',\'S\',\'BestShop\') OR Consumables_Business_Type_Code__c=\'ExchangeReturn\')'; //24 03 22 hyungho.chun 소모품 일반 반품도 교환일어났던건이라면 이제 들어와서 로직태움
        queryStr += ' AND ReturnOrder.Consumables_Order_YN__c=TRUE';
        queryStr += ' AND RecordType.DeveloperName IN (\'Consumable\',\'CareSupplies\')';
        System.debug('ReturnOrder LineItem 조회 : ' + queryStr);
        redRoliList = Database.query(queryStr);

        if (!redRoliList.isEmpty()) {
            //흑자의 Id 들고오기
            List<SR_AR_CONFIRM__c> sacList = new List<SR_AR_CONFIRM__c>();
            List<String> orderNoList = new List<String>();
            for (ReturnOrderLineItem rRoli : redRoliList) {
                //23 11 29 hyungho.chun 케어용품 반품주문 order_number매칭안됨
                String orderNoTemp = rRoli.Order_CHNL_TYPE_Code__c == 'BestShop' ? rRoli.ProductRequestLineItem.Order_Number__c : rRoli.returnorder.Order_Number__c;
                orderNoList.add(orderNoTemp);

                //23 11 29 hyungho.chun 케어용품만 추출(si_Transaction 생성용)
                if (rRoli.Order_CHNL_TYPE_Code__c == EX_ConsumableUtil.CONSUMABLE_BESTSHOP) {
                    carePlusRoliList.add(rRoli);
                    carePlusOrderNumSet.add(orderNoTemp);
                }
            }

            sacList = [SELECT Id, FM_Order_Number__c, DEPOSIT_TYPE__c,DEPOSIT_AMT__c,INVOICE_ISSUE_TYPE__c,CHANGE_SEQ__c FROM SR_AR_CONFIRM__c WHERE FM_Order_Number__c IN :orderNoList AND FM_RED_BLACK__c = 'B' 
            AND LAST_SR_AR_CONFIRM_ID__c = NULL 
            ORDER BY CHANGE_SEQ__c ASC NULLS FIRST]; //24 01 05 hyungho.chun 외부채권_복합결제시 각각 적자채권(포인트+그외)에 각각 흑자채권(포인트+그외)연결 필요

            //sm_dept 들고오기//
            List<SM_DEPT__c> rsmDeptList = new List<SM_DEPT__c>();
            rsmDeptList = [SELECT Id, DEPT_CODE__c FROM SM_DEPT__c WHERE DEPT_CODE__c = :EX_ConsumableUtil.PH0300 OR DEPT_CODE__c = :EX_ConsumableUtil.PH8002];

            FNManager.BasisBundle[] bb = new FNManager.BasisBundle[]{
            };

            for (ReturnOrderLineItem rRoli : redRoliList) {
                String orderNoTemp = rRoli.Order_CHNL_TYPE_Code__c == 'BestShop' ? rRoli.ProductRequestLineItem.Order_Number__c : rRoli.returnorder.Order_Number__c;
                FNManager.ARBundle[] arb = new FNManager.ARBundle[]{
                };
                //OBS, ThinQ, NewBest
                // if (rRoli.Order_CHNL_TYPE_Code__c == 'B' || rRoli.Order_CHNL_TYPE_Code__c == 'S' || rRoli.Order_CHNL_TYPE_Code__c == 'BestShop' || rRoli.Consumables_Business_Type_Code__c == 'ExchangeReturn') {
                if ((rRoli.Order_CHNL_TYPE_Code__c == 'V' && rRoli.Consumables_Business_Type_Code__c == 'Return') || rRoli.Order_CHNL_TYPE_Code__c == 'B' || rRoli.Order_CHNL_TYPE_Code__c == 'S' || rRoli.Order_CHNL_TYPE_Code__c == 'BestShop' || rRoli.Consumables_Business_Type_Code__c == 'ExchangeReturn') {
                    String saleNo = rRoli.ProductRequestLineItem.SALE_Number__c; //판매번호
                    Date saleDt = rRoli.productrequestlineitem.SR_SALE__r.SALE_DTM__c != null ? rRoli.productrequestlineitem.SR_SALE__r.SALE_DTM__c : System.today(); //판매일자
                    String srSaleId = rRoli.ProductRequestLineItem.SR_SALE__c; //SR_SALE의 Id

                    //23 08 03 hyungho.chun roli 각각의 금액이 ar confirm에 들어가야하나?
                    //23 10 11 hyungho.chun 반품금액 원복
                    // Decimal paymentAmt = rRoli.RETURN_PAYMENT_Amount__c != 0 ? -rRoli.RETURN_PAYMENT_Amount__c : -rRoli.returnorder.RETURN_PAYMENT_Amount__c; //반품금액
                    //24 02 27 hyungho.chun returnOrder와 전부 1:1 이다(OBS의 반품주문중  / 같은 반품주문 여러품목동시 반품건제외 -> 아래서 break처리로 for loop 탈출시킴)
                    Decimal paymentAmt = (rRoli.Order_CHNL_TYPE_Code__c == 'V' && rRoli.Consumables_Business_Type_Code__c == 'Return') ? (-(rRoli.returnorder.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c + rRoli.returnorder.RETURN_CARD_PAYMENT_Amount__c + rRoli.returnorder.RETURN_POINT_Amount__c)) : -rRoli.returnorder.RETURN_PAYMENT_Amount__c;//24 03 22 hyungho.chun 교환이일어났던 원주문의 반품의 경우 총 반품금액 계산을 다르게

                    //23 10 04 hyungho.chun 교환주문의경우 원주문의 총금액으로 항상 맞춰줌
                    // Decimal paymentAmt = rRoli.Consumables_Business_Type_Code__c == 'ExchangeReturn' ? -rRoli.ProductRequestLineItem.parent.PAYMENT_Amount__c : -rRoli.returnorder.RETURN_PAYMENT_Amount__c; //반품금액
                    // Datetime paymentDtm = rRoli.returnorder.ProductRequest.PAYMENT_COMPLETED_DTM__c != null ? rRoli.returnorder.ProductRequest.PAYMENT_COMPLETED_DTM__c : System.now(); //결제일시
                    // 23 09 11 hyungho.chun 재경측 요청으로 적자채권 생성 날짜기준 반품확정일자로 넣음(SR_PAYMENT_BASIS__c.PAYMENT_DTM__c / SR_AR_CONFIRM__c.APPR_DT__c 값 변경)
                    Datetime paymentDtm = System.now(); //결제일시
                    Date paymentDt = paymentDtm != null ? paymentDtm.date() : System.today(); //결제일시
                    String orderCustId = rRoli.Order_CUST_Id__c; //고객 contact id
                    String deptCode = '';
                    String sacId = null;
                    Map<String,SR_AR_CONFIRM__c> sacIdMap = new Map<String,SR_AR_CONFIRM__c>(); //24 01 05 hyungho.chun 외부채권 포인트용 흑자채권 key : depositType , value : arConfirm Object
                    if (!sacList.isEmpty()) {
                        for (SR_AR_CONFIRM__c sac : sacList) {
                            //23 11 29 hyungho.chun 케어용품만 추출(si_Transaction 생성용)
                            if (sac.FM_Order_Number__c == orderNoTemp) {
                                sacIdMap.put(sac.DEPOSIT_TYPE__c,sac); //24 01 05 hyungho.chun 복합결제 대비 매칭용 맵핑
                            }
                        }
                    }
                    System.debug('sacId :: '+sacId);
                    //deptcode 결정
                    if (rRoli.Order_CHNL_TYPE_Code__c == 'BestShop') {
                        deptCode = EX_ConsumableUtil.PH0300;
                    } else {
                        deptCode = EX_ConsumableUtil.PH8002;
                    }
                    //조직의 레코드 Id 들고오기 - SM_DEPT__c
                    String smDeptId = '';
                    if (!rsmDeptList.isEmpty()) {
                        if (rRoli.Order_CHNL_TYPE_Code__c == 'BestShop') {
                            for (SM_DEPT__c sd : rsmDeptList) {
                                if (sd.DEPT_CODE__c == EX_ConsumableUtil.PH0300) {
                                    smDeptId = sd.Id;
                                }
                            }
                        } else {
                            for (SM_DEPT__c sd : rsmDeptList) {
                                if (sd.DEPT_CODE__c == EX_ConsumableUtil.PH8002) {
                                    smDeptId = sd.Id;
                                }
                            }
                        }
                    }

                    if (rRoli.Consumables_Business_Type_Code__c == 'ExchangeReturn') {
                        rRoli.REFUND_Complete_YN__c = true;
                        exchangeRoLiList.add(rRoli);
                    }

                    System.debug('1.결제근거(ProductRequest 1:1) 생성');
                    System.debug('saleNo: ' + saleNo);
                    System.debug('saleDt: ' + saleDt);
                    System.debug('smDeptId: ' + smDeptId);
                    System.debug('srSaleId: ' + srSaleId);
                    System.debug('paymentAmt: ' + paymentAmt);

                    /** 1.결제근거(ProductRequest 1:1) */
                    SR_PAYMENT_BASIS__c basis = new SR_PAYMENT_BASIS__c(
                            Name = saleNo
                            , BASIS_DT__c = saleDt
                            , BASIS_NO__c = saleNo
                            , BIZ_ORIGIN_TYPE__c = 'C'
                            , SM_DEPT_ID__c = smDeptId
                            , IsMIG__c = false
                            , PAYMENT_DTM__c = paymentDtm
                            , PAYMENT_DT__c = paymentDt
                            , RED_BLACK__c = 'R' //흑자:B, 적자:R
                            , SALE_AMT__c = paymentAmt
                            , SR_SALE_ID__c = srSaleId
                            , SETTLE_AMT__c = paymentAmt
                            , SETTLE_ORIGIN_TYPE__c = 'HIT'
                            , INVOICE_CHANGE_YN__c = false
                    );
                    //23 10 04 교환반품 채권은 데이터를 원주문아이템에서 받아와야해서 분기처리
                    if(rRoli.Consumables_Business_Type_Code__c == 'ExchangeReturn'){
                        /** 2.AR확정관리    (PR과는 1:N, 수금반제 내역과 1:1) */
                        /** 3.수금반제 내역  (PR과는 1:N, AR확정관리와 1:1) */
                        Integer arSlotNo = 1;
                        Decimal amt =0;
                        if (rRoli.ProductRequestLineItem.parent.CARD_PAYMENT_Amount__c != null && rRoli.ProductRequestLineItem.parent.CARD_PAYMENT_Amount__c > 0) {
                            // Decimal amt = -rRoli.ProductRequestLineItem.parent.CARD_PAYMENT_Amount__c;
                            //23 10 11 hyungho.chun
                            amt = rRoli.RETURN_PAYMENT_Amount__c != 0 ? -rRoli.RETURN_PAYMENT_Amount__c : -rRoli.returnorder.RETURN_PAYMENT_Amount__c;
                            System.debug('2.AR확정관리[카드]    (PR과는 1:N, 수금반제 내역과 1:1) 생성');
                            //AR확정관리
                            //23 08 09 hyungho.chun AR_CONFIRM_TARGET_FLAG__c 값 뉴베스트건 분리
                            //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 반품확정 date값 추가
                            SR_AR_CONFIRM__c ar = new SR_AR_CONFIRM__c(
                                    AR_CONFIRM_TARGET_FLAG__c = rRoli.Order_CHNL_TYPE_Code__c == 'BestShop' ? 'C' : 'Y'
                                    , AR_CONFIRM_YN__c = 'N'
                                    , IsMIG__c = false
                                    , CONTACT_ID__c = orderCustId != null ? orderCustId : '' 
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_TYPE__c = 'B' //A:현금;B:카드;D:포인트;E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , DEPT_CODE__c = deptCode
                                    , INPUT_TYPE__c = 'N'
                                    // , INVOICE_ISSUE_TYPE__c = 'D' //A:세금계산서;B:현금영수증;C:미발행;D:카드
                                    , INVOICE_ISSUE_TYPE__c = sacIdMap.get('B').INVOICE_ISSUE_TYPE__c //24 01 05 hyungho.chun 연결하는 흑자채권에서 불러오게 수정
                                    , SALE_AMT__c = amt
                                    , PAYMENT_AREA_NO__c = arSlotNo //결제 슬롯 번호 1~4, Default 1, 2건인 경우 1, 2 순차로 입력
                                    // , BLACK_SR_AR_CONFIRM_ID__c = sacId //적자건에 대한 흑자 ID
                                    , BLACK_SR_AR_CONFIRM_ID__c = sacIdMap.get('B').Id //24 01 05 hyungho.chun 복합결제대비 매칭
                                    , APPR_DT__c = paymentDt //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 반품확정 date값 추가
                            );
                            arSlotNo++;
                            System.debug('3.수금반제 내역[카드]  (PR과는 1:N, AR확정관리와 1:1) 생성');
                            //수금반제내역
                            SR_DEPOSIT__c deposit = new SR_DEPOSIT__c(
                                    CM_DEPOSIT_STATUS_TYPE__c = 'A'
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_DT__c = paymentDt //결제일자, 포인트는 생성일자
                                    , DEPOSIT_STATUS_TYPE__c = 'B' //A:미수금, B:수금(포인트는 B, 나머지 A)
                                    , DEPOSIT_TYPE__c = 'B' //A:현금, B:카드, C:쿠폰, D:포인트, E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , IsMIG__c = false
                            );

                            FNManager.ARBundle arBundle = new FNManager.ARBundle(ar, deposit);
                            arb.add(arBundle);
                        }
                        if (rRoli.ProductRequestLineItem.parent.CASH_PAYMENT_Amount__c != null && rRoli.ProductRequestLineItem.parent.CASH_PAYMENT_Amount__c > 0) {
                            // Decimal amt = -rRoli.ProductRequestLineItem.parent.CASH_PAYMENT_Amount__c;
                            //23 10 11 hyungho.chun
                            amt = rRoli.RETURN_PAYMENT_Amount__c != 0 ? -rRoli.RETURN_PAYMENT_Amount__c : -rRoli.returnorder.RETURN_PAYMENT_Amount__c;                            
                            System.debug('2.AR확정관리[현금]    (PR과는 1:N, 수금반제 내역과 1:1) 생성');
                            //AR확정관리
                            //23 08 09 hyungho.chun AR_CONFIRM_TARGET_FLAG__c 값 뉴베스트건 분리
                            //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 반품확정 date값 추가
                            SR_AR_CONFIRM__c ar = new SR_AR_CONFIRM__c(
                                    AR_CONFIRM_TARGET_FLAG__c = rRoli.Order_CHNL_TYPE_Code__c == 'BestShop' ? 'C' : 'Y'
                                    , AR_CONFIRM_YN__c = 'N'
                                    , IsMIG__c = false
                                    , CONTACT_ID__c = orderCustId != null ? orderCustId : ''
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_TYPE__c = 'A' //A:현금;B:카드;D:포인트;E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , DEPT_CODE__c = deptCode
                                    , INPUT_TYPE__c = 'N'
                                    // , INVOICE_ISSUE_TYPE__c = 'B' //A:세금계산서;B:현금영수증;C:미발행;D:카드
                                    , INVOICE_ISSUE_TYPE__c = sacIdMap.get('A').INVOICE_ISSUE_TYPE__c //24 01 05 hyungho.chun 연결하는 흑자채권에서 불러오게 수정
                                    , SALE_AMT__c = amt
                                    , PAYMENT_AREA_NO__c = arSlotNo //결제 슬롯 번호 1~4, Default 1, 2건인 경우 1, 2 순차로 입력
                                    // , BLACK_SR_AR_CONFIRM_ID__c = sacId //적자건에 대한 흑자 ID
                                    , BLACK_SR_AR_CONFIRM_ID__c = sacIdMap.get('A').Id //24 01 05 hyungho.chun 복합결제대비 매칭
                                    , APPR_DT__c = paymentDt //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 반품확정 date값 추가
                            );
                            arSlotNo++;
                            System.debug('3.수금반제 내역[현금]  (PR과는 1:N, AR확정관리와 1:1) 생성');
                            //수금반제내역
                            SR_DEPOSIT__c deposit = new SR_DEPOSIT__c(
                                    CM_DEPOSIT_STATUS_TYPE__c = 'A'
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_DT__c = paymentDt //결제일자, 포인트는 생성일자
                                    , DEPOSIT_STATUS_TYPE__c = 'B' //A:미수금, B:수금(포인트는 B, 나머지 A)
                                    , DEPOSIT_TYPE__c = 'A' //A:현금, B:카드, C:쿠폰, D:포인트, E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , IsMIG__c = false
                            );

                            FNManager.ARBundle arBundle = new FNManager.ARBundle(ar, deposit);
                            arb.add(arBundle);
                        }
                        if (rRoli.ProductRequestLineItem.parent.POINT_Amount__c != null && rRoli.ProductRequestLineItem.parent.POINT_Amount__c > 0 && amt == 0) {
                            // Decimal amt = -rRoli.ProductRequestLineItem.parent.POINT_Amount__c;
                            //23 10 11 hyungho.chun
                            amt = rRoli.RETURN_PAYMENT_Amount__c != 0 ? -rRoli.RETURN_PAYMENT_Amount__c : -rRoli.returnorder.RETURN_PAYMENT_Amount__c;                            
                            System.debug('2.AR확정관리[포인트]    (PR과는 1:N, 수금반제 내역과 1:1) 생성');
                            //AR확정관리
                            //23 08 09 hyungho.chun AR_CONFIRM_TARGET_FLAG__c 값 뉴베스트건 분리
                            //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 반품확정 date값 추가
                            SR_AR_CONFIRM__c ar = new SR_AR_CONFIRM__c(
                                    AR_CONFIRM_TARGET_FLAG__c = rRoli.Order_CHNL_TYPE_Code__c == 'BestShop' ? 'C' : 'Y'
                                    , AR_CONFIRM_YN__c = 'N'
                                    , IsMIG__c = false
                                    , CONTACT_ID__c = orderCustId != null ? orderCustId : ''
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_TYPE__c = 'D' //A:현금;B:카드;D:포인트;E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , DEPT_CODE__c = deptCode
                                    , INPUT_TYPE__c = 'N'
                                    // , INVOICE_ISSUE_TYPE__c = 'C' //A:세금계산서;B:현금영수증;C:미발행;D:카드
                                    , INVOICE_ISSUE_TYPE__c = sacIdMap.get('D').INVOICE_ISSUE_TYPE__c //24 01 05 hyungho.chun 연결하는 흑자채권에서 불러오게 수정
                                    , SALE_AMT__c = amt
                                    , PAYMENT_AREA_NO__c = arSlotNo //결제 슬롯 번호 1~4, Default 1, 2건인 경우 1, 2 순차로 입력
                                    // , BLACK_SR_AR_CONFIRM_ID__c = sacId //적자건에 대한 흑자 ID
                                    , BLACK_SR_AR_CONFIRM_ID__c = sacIdMap.get('D').Id //24 01 05 hyungho.chun 복합결제대비 매칭
                                    , APPR_DT__c = paymentDt //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 반품확정 date값 추가
                            );
                            arSlotNo++;
                            System.debug('3.수금반제 내역[포인트]  (PR과는 1:N, AR확정관리와 1:1) 생성');
                            //수금반제내역
                            SR_DEPOSIT__c deposit = new SR_DEPOSIT__c(
                                    CM_DEPOSIT_STATUS_TYPE__c = 'A'
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_DT__c = rRoli.CreatedDate.date() //결제일자, 포인트는 생성일자
                                    , DEPOSIT_STATUS_TYPE__c = 'B' //A:미수금, B:수금(포인트는 B, 나머지 A)
                                    , DEPOSIT_TYPE__c = 'D' //A:현금, B:카드, C:쿠폰, D:포인트, E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , IsMIG__c = false
                            );

                            FNManager.ARBundle arBundle = new FNManager.ARBundle(ar, deposit);
                            arb.add(arBundle);
                        }  






                        
                    }else{
                        /** 2.AR확정관리    (PR과는 1:N, 수금반제 내역과 1:1) */
                        /** 3.수금반제 내역  (PR과는 1:N, AR확정관리와 1:1) */
                        Integer arSlotNo = 1;
                        if (rRoli.ReturnOrder.RETURN_CARD_PAYMENT_Amount__c != null && rRoli.ReturnOrder.RETURN_CARD_PAYMENT_Amount__c > 0) {
                            Decimal amt = -rRoli.ReturnOrder.RETURN_CARD_PAYMENT_Amount__c;
                            System.debug('2.AR확정관리[카드]    (PR과는 1:N, 수금반제 내역과 1:1) 생성');
                            //AR확정관리
                            //23 08 09 hyungho.chun AR_CONFIRM_TARGET_FLAG__c 값 뉴베스트건 분리
                            //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 반품확정 date값 추가
                            SR_AR_CONFIRM__c ar = new SR_AR_CONFIRM__c(
                                    AR_CONFIRM_TARGET_FLAG__c = rRoli.Order_CHNL_TYPE_Code__c == 'BestShop' ? 'C' : 'Y'
                                    , AR_CONFIRM_YN__c = 'N'
                                    , IsMIG__c = false
                                    , CONTACT_ID__c = orderCustId != null ? orderCustId : '' 
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_TYPE__c = 'B' //A:현금;B:카드;D:포인트;E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , DEPT_CODE__c = deptCode
                                    , INPUT_TYPE__c = 'N'
                                    // , INVOICE_ISSUE_TYPE__c = 'D' //A:세금계산서;B:현금영수증;C:미발행;D:카드
                                    , INVOICE_ISSUE_TYPE__c = sacIdMap.get('B').INVOICE_ISSUE_TYPE__c //24 01 05 hyungho.chun 연결하는 흑자채권에서 불러오게 수정
                                    , SALE_AMT__c = amt
                                    , PAYMENT_AREA_NO__c = arSlotNo //결제 슬롯 번호 1~4, Default 1, 2건인 경우 1, 2 순차로 입력
                                    // , BLACK_SR_AR_CONFIRM_ID__c = sacId //적자건에 대한 흑자 ID
                                    , BLACK_SR_AR_CONFIRM_ID__c = sacIdMap.get('B').Id //24 01 05 hyungho.chun 복합결제대비 매칭
                                    , APPR_DT__c = paymentDt //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 반품확정 date값 추가
                            );
                            arSlotNo++;
                            System.debug('3.수금반제 내역[카드]  (PR과는 1:N, AR확정관리와 1:1) 생성');
                            //수금반제내역
                            SR_DEPOSIT__c deposit = new SR_DEPOSIT__c(
                                    CM_DEPOSIT_STATUS_TYPE__c = 'A'
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_DT__c = paymentDt //결제일자, 포인트는 생성일자
                                    , DEPOSIT_STATUS_TYPE__c = 'B' //A:미수금, B:수금(포인트는 B, 나머지 A)
                                    , DEPOSIT_TYPE__c = 'B' //A:현금, B:카드, C:쿠폰, D:포인트, E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , IsMIG__c = false
                            );

                            FNManager.ARBundle arBundle = new FNManager.ARBundle(ar, deposit);
                            arb.add(arBundle);
                        }
                        if (rRoli.ReturnOrder.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c != null && rRoli.ReturnOrder.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c > 0) {
                            Decimal amt = -rRoli.ReturnOrder.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c;
                            System.debug('2.AR확정관리[현금]    (PR과는 1:N, 수금반제 내역과 1:1) 생성');
                            //AR확정관리
                            //23 08 09 hyungho.chun AR_CONFIRM_TARGET_FLAG__c 값 뉴베스트건 분리
                            //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 반품확정 date값 추가
                            SR_AR_CONFIRM__c ar = new SR_AR_CONFIRM__c(
                                    AR_CONFIRM_TARGET_FLAG__c = rRoli.Order_CHNL_TYPE_Code__c == 'BestShop' ? 'C' : 'Y'
                                    , AR_CONFIRM_YN__c = 'N'
                                    , IsMIG__c = false
                                    , CONTACT_ID__c = orderCustId != null ? orderCustId : ''
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_TYPE__c = 'A' //A:현금;B:카드;D:포인트;E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , DEPT_CODE__c = deptCode
                                    , INPUT_TYPE__c = 'N'
                                    // , INVOICE_ISSUE_TYPE__c = 'B' //A:세금계산서;B:현금영수증;C:미발행;D:카드
                                    , INVOICE_ISSUE_TYPE__c = sacIdMap.get('A').INVOICE_ISSUE_TYPE__c //24 01 05 hyungho.chun 연결하는 흑자채권에서 불러오게 수정
                                    , SALE_AMT__c = amt
                                    , PAYMENT_AREA_NO__c = arSlotNo //결제 슬롯 번호 1~4, Default 1, 2건인 경우 1, 2 순차로 입력
                                    // , BLACK_SR_AR_CONFIRM_ID__c = sacId //적자건에 대한 흑자 ID
                                    , BLACK_SR_AR_CONFIRM_ID__c = sacIdMap.get('A').Id //24 01 05 hyungho.chun 복합결제대비 매칭
                                    , APPR_DT__c = paymentDt //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 반품확정 date값 추가
                            );
                            arSlotNo++;
                            System.debug('3.수금반제 내역[현금]  (PR과는 1:N, AR확정관리와 1:1) 생성');
                            //수금반제내역
                            SR_DEPOSIT__c deposit = new SR_DEPOSIT__c(
                                    CM_DEPOSIT_STATUS_TYPE__c = 'A'
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_DT__c = paymentDt //결제일자, 포인트는 생성일자
                                    , DEPOSIT_STATUS_TYPE__c = 'B' //A:미수금, B:수금(포인트는 B, 나머지 A)
                                    , DEPOSIT_TYPE__c = 'A' //A:현금, B:카드, C:쿠폰, D:포인트, E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , IsMIG__c = false
                            );

                            FNManager.ARBundle arBundle = new FNManager.ARBundle(ar, deposit);
                            arb.add(arBundle);
                        }
                        if (rRoli.returnorder.RETURN_POINT_Amount__c != null && rRoli.returnorder.RETURN_POINT_Amount__c > 0) {
                            Decimal amt = -rRoli.returnorder.RETURN_POINT_Amount__c;
                            System.debug('2.AR확정관리[포인트]    (PR과는 1:N, 수금반제 내역과 1:1) 생성');
                            //AR확정관리
                            //23 08 09 hyungho.chun AR_CONFIRM_TARGET_FLAG__c 값 뉴베스트건 분리
                            //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 반품확정 date값 추가
                            SR_AR_CONFIRM__c ar = new SR_AR_CONFIRM__c(
                                    AR_CONFIRM_TARGET_FLAG__c = rRoli.Order_CHNL_TYPE_Code__c == 'BestShop' ? 'C' : 'Y'
                                    , AR_CONFIRM_YN__c = 'N'
                                    , IsMIG__c = false
                                    , CONTACT_ID__c = orderCustId != null ? orderCustId : ''
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_TYPE__c = 'D' //A:현금;B:카드;D:포인트;E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , DEPT_CODE__c = deptCode
                                    , INPUT_TYPE__c = 'N'
                                    // , INVOICE_ISSUE_TYPE__c = 'C' //A:세금계산서;B:현금영수증;C:미발행;D:카드
                                    , INVOICE_ISSUE_TYPE__c = sacIdMap.get('D').INVOICE_ISSUE_TYPE__c //24 01 05 hyungho.chun 연결하는 흑자채권에서 불러오게 수정
                                    , SALE_AMT__c = amt
                                    , PAYMENT_AREA_NO__c = arSlotNo //결제 슬롯 번호 1~4, Default 1, 2건인 경우 1, 2 순차로 입력
                                    // , BLACK_SR_AR_CONFIRM_ID__c = sacId //적자건에 대한 흑자 ID
                                    , BLACK_SR_AR_CONFIRM_ID__c = sacIdMap.get('D').Id //24 01 05 hyungho.chun 복합결제대비 매칭
                                    , APPR_DT__c = paymentDt //23 09 11 hyungho.chun 재경측 요청으로 sr_ar_confirm__c.APPR_DT__c 에 반품확정 date값 추가
                            );
                            arSlotNo++;
                            System.debug('3.수금반제 내역[포인트]  (PR과는 1:N, AR확정관리와 1:1) 생성');
                            //수금반제내역
                            SR_DEPOSIT__c deposit = new SR_DEPOSIT__c(
                                    CM_DEPOSIT_STATUS_TYPE__c = 'A'
                                    , DEPOSIT_AMT__c = amt
                                    , DEPOSIT_DT__c = rRoli.CreatedDate.date() //결제일자, 포인트는 생성일자
                                    , DEPOSIT_STATUS_TYPE__c = 'B' //A:미수금, B:수금(포인트는 B, 나머지 A)
                                    , DEPOSIT_TYPE__c = 'D' //A:현금, B:카드, C:쿠폰, D:포인트, E:미수
                                    , SM_DEPT_ID__c = smDeptId
                                    , IsMIG__c = false
                            );

                            FNManager.ARBundle arBundle = new FNManager.ARBundle(ar, deposit);
                            arb.add(arBundle);
                        }                        
                     
                    
                    }

                    if (arb != null && !arb.isEmpty()) {
                        FNManager.BasisBundle basisBundle = new FNManager.BasisBundle(basis, arb);
                        bb.add(basisBundle);
                    }

                    // if(rRoli.Order_CHNL_TYPE_Code__c == 'B' && rRoli.Consumables_Business_Type_Code__c != 'ExchangeReturn'){
                    if((rRoli.Order_CHNL_TYPE_Code__c == 'B' && rRoli.Consumables_Business_Type_Code__c != 'ExchangeReturn') || (rRoli.Order_CHNL_TYPE_Code__c == 'V' && rRoli.Consumables_Business_Type_Code__c != 'ExchangeReturn')){
                        break; //24 02 27 hyungho.chun OBS roli가 여러개인 ro의 경우 한번만들고 바로 for 밖으로 튕겨냄  //24 03 22 hyungho.chun 교환이일어났던 소모품 주문이라 exChannelRed에서 적자채권만드는 반품주문도 returnorder기준으로 한번태우고 break처리
                    }                    
                }//OBS, ThinQ, NewBest
            } // for redRoliList
            if (!exchangeRoLiList.isEmpty()) {
                update exchangeRoLiList;
            }

            if (bb != null && !bb.isEmpty()) {
                FNManager.builder().append(bb).build();
            }
            System.debug('NewBest 적자 Si_transaction 생성 시작');
            //23 11 29 hyungho.chun 케어용품 판매적자용 Si_transaction 생성시작@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            //1.케어플러스의 적자처리(환불은 X)
            //2.케어플러스 GERP전송 (SI_TRANSACTION)
            //24 02 21 hyungho.chun 부품요청 임시주석 시작@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            // if (!carePlusRoliList.isEmpty()) {
            //     //23 09 13 hyungho.chun order_number기준으로 careplus_complete.LINE_ID__c 찾아서 si_transaction attribute 4번에 넣어주는용도
            //     List<SI_CAREPLUS_ORDER_COMPLETE__c> carePlusComList = new List<SI_CAREPLUS_ORDER_COMPLETE__c>();
            //     carePlusComList = [SELECT Id, CUST_PO_NO__c, LINE_ID__c FROM SI_CAREPLUS_ORDER_COMPLETE__c WHERE CUST_PO_NO__c IN: carePlusOrderNumSet AND LINE_ID__c != null];
            //     Map<String, String> orderNumAndLineId = new Map<String, String>();
            //     for(SI_CAREPLUS_ORDER_COMPLETE__c item : carePlusComList){
            //         orderNumAndLineId.put(item.CUST_PO_NO__c,  String.valueOf(item.LINE_ID__c));
            //     }      



            //     List<SI_TRANSACTION__c> insertSiTList = new List<SI_TRANSACTION__c>();
            //     List<SI_TRANSACTION__c> siTListForMaxList = new List<SI_TRANSACTION__c>();
            //     Integer maxTransactionId = 1;
            //     siTListForMaxList = [SELECT Id, TRANSACTION_ID__c FROM SI_TRANSACTION__c WHERE TRANSACTION_ID__c != null ORDER BY TRANSACTION_ID__c DESC LIMIT 1];
            //     if (!siTListForMaxList.isEmpty()) {
            //         maxTransactionId = Integer.valueOf(siTListForMaxList[0].TRANSACTION_ID__c);
            //     }
            //     Integer loopCnt = 1;
            //     for (ReturnOrderLineItem cpRoli : carePlusRoliList) {
            //         SI_TRANSACTION__c siT = new SI_TRANSACTION__c();
            //         siT.TRANSACTION_ID__c = maxTransactionId + loopCnt; //572421 seq
            //         // siT.REQUEST_NUMBER__c = cpRoli.ProductRequestLineItem.SALE_Number__c; //A010004542
            //         //23 11 30 hyungho.chun A010004542 -> R010004542
            //         siT.REQUEST_NUMBER__c = cpRoli.ProductRequestLineItem.SALE_Number__c.replace('A','R'); //A010004542

            //         siT.SOURCE_CODE__c = 'C'; //DECODE(A.DEPT_TYPE,'E', 'C', 'P')
            //         siT.TRX_CODE__c = 'CARE_RED';
            //         siT.SEQ__c = 1;
            //         siT.SUB_SEQ__c = 1;
                    
                    
            //         siT.STATUS_CODE__c = 'N';
            //         siT.LGC_CODE__c = EX_ConsumableUtil.PH0300; //( SELECT GERP_CODE FROM SM_DEPT WHERE DEPT_CODE = ( DECODE(A.DEPT_TYPE,'H',A.HIGH_DEPT_CODE,'G',A.HIGH_DEPT_CODE, 'I',A.HIGH_DEPT_CODE,'J',A.HIGH_DEPT_CODE, A.DEPT_CODE ) ) )
            //         siT.LGP_CODE__c = EX_ConsumableUtil.PH0300; //SM_DEPT.GERP_CODE
            //         //siT.TRANS_LGC_CODE__c; //( SELECT GERP_CODE FROM SM_DEPT WHERE DEPT_CODE = ( SELECT DECODE( DEPT_TYPE, 'H', HIGH_DEPT_CODE, 'G', HIGH_DEPT_CODE, 'I',HIGH_DEPT_CODE,'J',HIGH_DEPT_CODE, DEPT_CODE ) FROM SM_DEPT WHERE DEPT_CODE = ${ordDeptCode}))
            //         //siT.TRANS_LGP_CODE__c; //(SELECT GERP_CODE FROM SM_DEPT WHERE DEPT_CODE = ${ordDeptCode} )
            //         siT.OBU_CODE__c = cpRoli.Product2.DIV_CODE__c; //${divCode}
            //         siT.TRX_DATE__c = Date.today();
            //         siT.ITEM_CODE__c = cpRoli.Parts_Number__c; //partNo
            //         siT.UOM__c = 'EA';
            //         siT.TRX_QTY__c = cpRoli.QuantityReturned;
            //         //siT.TRX_PRICE_1__c;
            //         //siT.TRX_PRICE_2__c;
            //         siT.TRANS_FLAG__c = 'N';
            //         siT.ATTRIBUTE1__c = 'CAREPLUS';
            //         siT.ATTRIBUTE2__c = cpRoli.ProductRequestLineItem.Order_Number__c; //P10000388775
            //         siT.ATTRIBUTE3__c = '1';
            //         if(orderNumAndLineId.containsKey(cpRoli.ProductRequestLineItem.Order_Number__c)){
            //             siT.ATTRIBUTE4__c = orderNumAndLineId.get(cpRoli.ProductRequestLineItem.Order_Number__c);
            //         }   

            //         insertSiTList.add(siT);
            //         loopCnt++;
            //     }
            //     insert insertSiTList;
            // }
            //24 02 21 hyungho.chun 부품요청 임시주석 끝@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@            
            //23 11 29 hyungho.chun 케어용품 판매적자용 Si_transaction 생성시작@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            System.debug('NewBest 적자 Si_transaction 생성 종료');
        }
        System.debug('OBS, ThinQ, NewBest 적자 채권생성 종료');
        //23 10 04 hyungho.chun 쿼리에 교환반품에 필요한 필드값 추가
        System.debug('교환주문 적자채권 생성 종료');

        //23 10 26 hyungho.chun 환불프로세스안타는 적자채권(외부 및 교환반품)관련 주문도 재경요청 필드값들 업데이트용추가
        if(!Test.isRunningTest()) EX_ReturnConfirmQueueable.updateRoliSDPN(redRoliList);
    }
    /**
    * @description 환불처리를 위한 Wrapper
    * @author 23.06.19 / I2MAX.SEUNGHUNAN
    */
    public class RefundWrapper {
        private final ReturnOrder ro;
        private final SR_AR_CONFIRM__c arConfirm;
        private final Decimal orderSeq;

        public RefundWrapper(ReturnOrder ro, SR_AR_CONFIRM__c arConfirm, Decimal orderSeq) {
            this.ro = ro;
            this.arConfirm = arConfirm;
            this.orderSeq = orderSeq;
        }

        public ReturnOrder getReturnOrder() {
            return this.ro;
        }

        public SR_AR_CONFIRM__c getArConfirm() {
            return this.arConfirm;
        }

        public Decimal getOrderSeq(){
            return this.orderSeq;
        }
    }

    /**
    * @description 비동기 처리 시 리스트에서 부분성공 체크
    * @author 23.07.10 / I2MAX.SEUNGHUNAN
    * @param List<SObject> targetList 대상 List
    * @param List<String> salesFailOrderNumberList 실패 주문번호 저장 리스트
    * @param String errorMsg 비동기 처리 오류 레코드에 저장할 에러 메시지
    * @return List<SR_ONLINE_AUTO_SALE_EXC__c> 비동기 처리 오류 레코드 리스트
    */
    public static List<SR_ONLINE_AUTO_SALE_EXC__c> checkFail(List<SObject> targetList, List<String> salesFailOrderNumberList, String errorMsg) {
        List<Integer> failIdxList = new List<Integer>();
        List<SR_ONLINE_AUTO_SALE_EXC__c> failRecordList = new List<SR_ONLINE_AUTO_SALE_EXC__c>();
        if (targetList.isEmpty() || targetList == null) return failRecordList;
        //23 12 04 hyungho.chun 실패하면 튕겨냄 false -> true
        List<Database.UpsertResult> dmlResults = Database.upsert(targetList, true);

        System.debug('errorMsg : ' + errorMsg);
        String sObjectType = targetList.get(0).getSObjectType().getDescribe().name;
        String orderNumber = null;
        String orderChannel = null;
        String id = null;

        for (Integer i = 0; i < dmlResults.size(); i++) {
            if (sObjectType.equals('ProductTransfer')) {
                System.debug('dmlResult : ' + dmlResults[i]);
            }
            // 실패건 인덱스 조회
            if (!dmlResults[i].isSuccess()) {
                failIdxList.add(i);
            }
        }

        if (!failIdxList.isEmpty()) {
            for (Integer i = 0, idx = 0; i < failIdxList.size(); i++) {
                idx = failIdxList.get(i);
                SObject errorObj = targetList.get(idx);
                Database.UpsertResult result = dmlResults.get(idx);

                if (sObjectType.equals('ProductTransfer')) {
                    errorObj = errorObj.getSObject('ProductRequestLineItem');
                }

                id = (String) errorObj.get('Id');
                switch on sObjectType {
                    when 'SI_TRANSACTION__c' {
                        orderNumber = (String) errorObj.get('ATTRIBUTE2__c');
                        orderChannel = 'BestShop';
                    }
                    when 'SI_CAREPLUS_BACKIF__c' {
                        orderNumber = (String) errorObj.get('ORDER_NO__c');
                        orderChannel = 'BestShop';
                    }
                    when 'SR_PRE_PAYMENT_HEADER__c' {
                        orderNumber = (String) errorObj.get('BASIS_NO__c');
                        orderChannel = 'V';
                    }
                    // SR_SALE__c, ProductRequest, ProductRequestLineItem ...
                    when else {
                        orderNumber = (String) errorObj.get('Order_Number__c');
                        orderChannel = (String) errorObj.get('Order_CHNL_TYPE_Code__c');
                    }
                }

                SR_ONLINE_AUTO_SALE_EXC__c saleExc = new SR_ONLINE_AUTO_SALE_EXC__c();

                saleExc.ERROR_DATE__c = System.today();
                saleExc.Input_date__c = System.now();
                saleExc.Last_update_date__c = System.now();
                saleExc.SourceRecordId__c = id;

                switch on orderChannel {
                    when 'V' {
                        saleExc.ORDER_CHANNEL__c = CONSUMABLE_CIC_LABEL;
                    }
                    when 'B' {
                        saleExc.ORDER_CHANNEL__c = CONSUMABLE_OBS_LABEL;
                    }
                    when 'S' {
                        saleExc.ORDER_CHANNEL__c = CONSUMABLE_THINQ_LABEL;
                    }
                    when 'BestShop' {
                        saleExc.ORDER_CHANNEL__c = CONSUMABLE_BESTSHOP_LABEL;
                    }
                }

                saleExc.ORDER_NO__c = orderNumber;
                saleExc.SALE_YN__c = 'N';
                saleExc.ErrorType__c = 'SaveSales';
                saleExc.ERROR_Message__c = errorMsg;
                saleExc.ERROR_MESSAGE__c += result.getErrors()[0].getMessage();

                // 오류가 발생한 주문번호 저장
                salesFailOrderNumberList.add(orderNumber);

                failRecordList.add(saleExc);
            }
        }

        return failRecordList;
    }

    public static Map<String, Object> preWorkReturnConfirm(Set<String> roLiIdSet) {
        Map<String, Object> paramMap = new Map<String, Object>();
        // ReturnOrder Id Set
        Set<String> roIdSet = new Set<String>();
        // ProductRequest 조회하기 위한 주문번호 리스트
        Set<String> orderNumberSet = new Set<String>();
        Set<String> saleNumberSet = new Set<String>();
        // 포인트 결제 시 환불 대상인 TID__c를 저장하기 위한 임시 Set
        Set<String> kTrxIdSet = null;
        Set<String> deptCodeSet = new Set<String>();
        Set<String> saleIdSet = new Set<String>();
        Set<String> originPrLiIdSet = new Set<String>();

        // 대상 ReturnOrderLineItem
        List<ReturnOrderLineItem> roLiList = null;
        // 맵을 만드는데 사용되는 임시 ReturnOrderLineItem 리스트
        List<ReturnOrderLineItem> tmpRoLiList = null;
        // AR 확정관리(SR_AR_CONFIRM). 맵을 구성하는데 사용하는 임시 리스트
        List<SR_AR_CONFIRM__c> arConfirmList = null;
        // 판매 적자 생성용 SR_SALE__c List (기존에 존재하던 A채번 SR_SALE__c) 이 판매정보를 베이스로 판매적자 SR_SALE__c 생성
        List<SR_SALE__c> srSaleList = null;
        List<ProductRequest> saleTypePrList = null;
        List<ProductRequestLineItem> saleTypePrLiList = null;

        // ReturnOrder Id를 Key로 그에 따른 ReturnOrderLineItem을 Value로 맵 구성
        Map<String, List<ReturnOrderLineItem>> roIdRoLiListMap = new Map<String, List<ReturnOrderLineItem>>();
        // ReturnOrder를 Key로 TRX_ID Set을 Value로 맵 구성
        Map<String, Set<String>> roIdTrxIdSetMap = new Map<String, Set<String>>();
        // TRX_ID를 Key로, 그에 대응하는 ReturnOrderLineItem을 Value로 맵 구성
        // Map<String, ReturnOrderLineItem> kTrxIdRoLiMap = new Map<String, ReturnOrderLineItem>();
        // 부서 코드에 따른 부서 (SM_DEPT__c) 오브젝트 맵
        Map<String, SM_DEPT__c> deptCodeMap = new Map<String, SM_DEPT__c>();
        // 판매번호별 채권 리스트 맵
        Map<String, List<SR_AR_CONFIRM__c>> saleIdArConfirmMap = new Map<String, List<SR_AR_CONFIRM__c>>();
        // Header의 BASIS_NO__c(SALE_Number__c)와 MOID__c -> 주문번호 별 MOID Map
        Map<String, String> saleNumberMOIDMap = new Map<String, String>();
        // SALE_Number 별 SR_SALE__c 맵 (판매적자 생성용)
        Map<String, SR_SALE__c> saleNumberSaleMap = new Map<String, SR_SALE__c>();
        // SR_AR_CONFIRM에 해당하는 TRX_ID를 얻기위한 맵
        Map<String, String> confirmIdTrxIdMap = new Map<String, String>();
        // 환불 수량 Map
        Map<String, Decimal> roIdReturnQuantityMap = new Map<String, Decimal>();
        // 환불 상품명 Map
        Map<String, String> roIdReturnGoodsNameMap = new Map<String, String>();
        Map<String, SR_SALE__c> saleNumberSrSaleMap = new Map<String, SR_SALE__c>();
        // ReturnOrderLineItem을 키, 원주문건을 Value로, 주문건 업데이트시 원주문의 판매수량 감소를 위해 사용
        Map<String, ProductRequestLineItem> roLiIdOriginPrLiMap = new Map<String, ProductRequestLineItem>();
        Map<String, ProductRequest> orderNumberSalePrMap = new Map<String, ProductRequest>();
        Map<String, ProductRequestLineItem> uniqueKeySalePrLiMap = new Map<String, ProductRequestLineItem>();

        // 문자열 임시 변수
        String str = null, query = null;

        //23 10 11 hyungho.chun clone떠야해서 필드 전체조회

        query = 'SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrderLineItem') + ' \n' +
                '                        ,ProductRequestLineItem.SR_SALE__r.SALE_DTM__c,ProductRequestLineItem.SALE_Number__c,ProductRequestLineItem.POINT_TRX_ID__c, ProductRequestLineItem.Parent.SALE_Number__c, ProductRequestLineItem.fm_Consumables_PART_DESC_KOR__c,ProductRequestLineItem.Parent.SALE_Amount__c, ProductRequestLineItem.Parent.Discount_Amount__c, \n' +
                '                        ProductRequestLineItem.REFUND_BANK_CODE__c, ProductRequestLineItem.REFUND_BANK_ACCOUNT_NAME__c,\n' +
                '                        ProductRequestLineItem.REFUND_BANK_ACCOUNT__c, ProductRequestLineItem.ENC_REFUND_BANK_ACCOUNT__c,\n' +
                '                        ProductRequestLineItem.Parent.SR_SALE__c, ProductRequestLineItem.SALE_Quantity__c, ProductRequestLineItem.Product2Id,\n' +
                '                        ProductRequestLineItem.Department_Code__c, ProductRequestLineItem.SourceLocationId,\n' +
                '                        ProductRequestLineItem.ProductItem__c, ProductRequestLineItem.fm_LOCATED_PLACE_Number__c, ProductRequestLineItem.CONSIGNEE_PostalCode__c, ProductRequestLineItem.Parent.CAREPLUS_Order_Requester_Class_Code__c, \n' +
                '                        Product2.PART_DESC_KOR__c, Product2.PART_DESC__c ,  ProductRequestLineItem.ParentId , ProductRequestLineItem.Parent.Order_Number__c , ProductRequestLineItem.Parent.Order_Date__c , ProductRequestLineItem.Parent.BILL_TO_CODE__c , ProductRequestLineItem.Parent.SHIP_TO_CODE__c , ProductRequestLineItem.Parent.Description, ProductRequestLineItem.Order_Number__c,\n' +
                '                        Product2.DIV_CODE__c , ProductRequestLineItem.MODEL_Code__c , Product2.Name , ProductRequestLineItem.QuantityRequested , ProductRequestLineItem.SHIP_QTY__c , ProductRequestLineItem.CANCEL_Quantity__c , ProductRequestLineItem.fm_UnitPrice__c,ProductRequestLineItem.UnitPrice__c ';

                // query = 'SELECT Id, Order_Number__c, ReturnOrderId, POINT_REFUND_Complete_YN__c, ETC_REFUND_Complete_YN__c, \n' +
                // '                        QuantityReturned, Expected_Return_Quantity__c, DestinationLocationId, SourceLocationId,\n' +
                // '                        Actual_Return_Quantity__c, ProductItemId, ENDP_Code__c, Product2Id, Parts_Number__c, Consumables_Business_Type_Code__c,\n' +
                // '                        Return_Requester_Reason__c, ProductRequestLineItemId, Exchange_Order_Item_Id__c, Order_CHNL_TYPE_Code__c, RETURN_SALE_Amount__c,\n' +
                // '                        RETURN_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_CARD_PAYMENT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c,\n' +
                // '                        ProductRequestLineItem.POINT_TRX_ID__c, ProductRequestLineItem.Parent.SALE_Number__c, ProductRequestLineItem.fm_Consumables_PART_DESC_KOR__c, \n' +
                // '                        ProductRequestLineItem.REFUND_BANK_CODE__c, ProductRequestLineItem.REFUND_BANK_ACCOUNT_NAME__c,\n' +
                // '                        ProductRequestLineItem.REFUND_BANK_ACCOUNT__c, ProductRequestLineItem.ENC_REFUND_BANK_ACCOUNT__c,\n' +
                // '                        ProductRequestLineItem.Parent.SR_SALE__c, ProductRequestLineItem.SALE_Quantity__c, ProductRequestLineItem.Product2Id,\n' +
                // '                        ProductRequestLineItem.Department_Code__c, ProductRequestLineItem.SourceLocationId,\n' +
                // '                        ProductRequestLineItem.ProductItem__c, ProductRequestLineItem.fm_LOCATED_PLACE_Number__c,\n' +
                // '                        Product2.PART_DESC_KOR__c, Product2.PART_DESC__c ,  ProductRequestLineItem.ParentId , ProductRequestLineItem.Parent.Order_Number__c , ProductRequestLineItem.Parent.Order_Date__c , ProductRequestLineItem.Parent.BILL_TO_CODE__c , ProductRequestLineItem.Parent.SHIP_TO_CODE__c , ProductRequestLineItem.Parent.Description,\n' +
                // '                        Request_Number__c, Request_SEQ__c , CONSIGNEE_Name__c , CONSIGNEE_PostalCode__c , CONSIGNEE_Address__c , CONSIGNEE_Address_DETAIL__c , CONSIGNEE_TPNO__c , Product2.DIV_CODE__c , ProductRequestLineItem.MODEL_Code__c , Product2.Name , ProductRequestLineItem.QuantityRequested , ProductRequestLineItem.SHIP_QTY__c , ProductRequestLineItem.CANCEL_Quantity__c , ProductRequestLineItem.fm_UnitPrice__c ';
        query += 'FROM ReturnOrderLineItem ';
        if(roliIdSet !=null){
            query += 'WHERE Id IN :roLiIdSet ';
        }else{
            query += 'WHERE Consumables_Order_Status__c = \'120\' ';
            //23 11 21 hyungho.chun ThinQ건은 수동으로만 하게끔 자동배치쿼리에선 제외
            query += 'AND Order_CHNL_TYPE_Code__c != \'S\' ';
            // query += 'AND (Order_Number__c = \'O230001293572\') ';
            query += 'AND COLLECTION_YN__c = TRUE ';
            query += 'AND REFUND_Complete_YN__c = FALSE ';
            query += 'AND (RecordType.DeveloperName = \'Consumable\' OR RecordType.DeveloperName = \'CareSupplies\') ';
            query += 'AND (Consumables_Business_Type_Code__c=\'Return\' OR Consumables_Business_Type_Code__c=\'ExchangeReturn\') ';
            query += 'AND Return_Order_CONFIRM_DTM__c = NULL ';            
            query += 'AND ProductRequestLineItem.ShipToStreet = NULL ';
        }

        // query += ' AND Order_Number__c IN ( \'O230001303322\' ) ';
        // query += ' AND Order_Number__c IN ( \'O230001303330\' ) ';
        // query += ' AND Order_Number__c IN ( \'O230001303331\', \'O230001303358\',\'O230001303395\',\'O230001303405\',\'O230001303408\') ';
        // query += ' AND Order_Number__c IN ( \'ORD-1000069399\',\'P10000403074\' ) ';

        
        // query += ' AND Order_Number__c IN ( \'ORD-1000069558\', \'P10000403075\' ) ';

        //23 10 30 hyungho.chun mig 조건 제거
        // query += 'AND isMig__c = FALSE';

        System.debug('query :: '+query);
        roLiList = Database.query(query);

        System.debug('roLiList :: ' + roLiList);
        System.debug('roLiList.size() :: ' + roLiList.size());

        List<String> trxList = new List<String>(); //24 01 08 hyungho.chun

        for (ReturnOrderLineItem roLi : roLiList) {
            if (roLi.ReturnOrderId != null) {
                roIdSet.add(roLi.ReturnOrderId);

                tmpRoLiList = roIdRoLiListMap.containsKey(roLi.ReturnOrderId)
                        ? roIdRoLiListMap.get(roLi.ReturnOrderId)
                        : new List<ReturnOrderLineItem>();
                tmpRoLiList.add(roLi);
                roIdRoLiListMap.put(roLi.ReturnOrderId, tmpRoLiList);
            }

            System.debug('orderNumber :: ' + roLi.Order_Number__c);
            if (roLi.Order_Number__c != null) {
                System.debug('orderNumber in :: ' + roLi.Order_Number__c);
                //23 11 29 케어플러스 pr / ro 오더 넘버 매칭안됨
                String orderNo = roLi.Order_CHNL_TYPE_Code__c == 'BestShop' ? roLi.ProductRequestLineItem.Parent.Order_Number__c : roLi.Order_Number__c;
                orderNumberSet.add(orderNo);
                // orderNumberSet.add(roLi.Order_Number__c);

            }

            if (roLi.ProductRequestLineItemId != NULL) {
                originPrLiIdSet.add(roLi.ProductRequestLineItemId);
            }

            if (roLi.ProductRequestLineItem.Parent.SALE_Number__c != null) {
                saleNumberSet.add(roLi.ProductRequestLineItem.Parent.SALE_Number__c);
            }

            if (roLi.ProductRequestLineItem.POINT_TRX_ID__c != null) {
                kTrxIdSet = roIdTrxIdSetMap.containsKey(roLi.ReturnOrderId)
                        ? roIdTrxIdSetMap.get(roLi.ReturnOrderId)
                        : new Set<String>();
                kTrxIdSet.add(roLi.ProductRequestLineItem.POINT_TRX_ID__c);
                roIdTrxIdSetMap.put(roLi.ReturnOrderId, kTrxIdSet);



                trxList.add(roLi.ProductRequestLineItem.POINT_TRX_ID__c);
            }
        }

        /**
         *   ReturnOrderLineItem 기준으로 ReturnOrder 조회
         *   ReturnOrderLineItem에 조건이 걸리므로 생략
         */
         //23 09 07 hyungho.chun 알림톡용 수취인 이름/ 수취인 번호 필드 추가
        // List<ReturnOrder> roList = [
        //         SELECT Id, RETURN_CARD_PAYMENT_Amount__c, RETURN_POINT_Amount__c, RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, CONSIGNEE_Name__c, CONSIGNEE_TPNO_1__c,
        //                 RETURN_PAYMENT_Amount__c, ProductRequestId, Order_Number__c, Order_CHNL_TYPE_Code__c, Consumables_Business_Type_Code__c,
        //                 ProductRequest.SR_SALE__c, ProductRequest.Department_Code__c, ProductRequest.Department_Id__c,
        //                 ProductRequest.SALE_Number__c

        //         FROM ReturnOrder
        //         WHERE Id IN:roIdSet
        // ];

         //23 10 11 hyungho.chun clone뜨기위해 필드전체쿼리로 수정
         //23 10 23 hyungho.chun 환불때 tid를 이제 PR.tid에서 받아쓰기위해 ProductRequest.TID__c 추가
        String strQueryRo = '';
        strQueryRo += 'SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrder');
        strQueryRo += ', ProductRequest.SR_SALE__c, ProductRequest.Department_Code__c, ProductRequest.Department_Id__c, ProductRequest.SALE_Number__c, ProductRequest.TID__c,ProductRequest.Order_Number__c,ProductRequest.SALE_Amount__c,ProductRequest.Discount_Amount__c ';
        strQueryRo += ' FROM ReturnOrder ';
        strQueryRo += 'WHERE Id IN: roIdSet';

        System.debug('strQueryRo :: '+strQueryRo);

        List<ReturnOrder> roList = Database.query(strQueryRo);

        System.debug('roList :: ' + roList);
        System.debug('roList.size() :: ' + roList.size());

        for (ReturnOrder ro : roList) {
            deptCodeSet.add(ro.ProductRequest.Department_Code__c);
        }

        List<SM_DEPT__c> smDeptList = [
                SELECT Id, DEPT_CODE__c, DEPT_NAME__c
                FROM SM_DEPT__c
                WHERE DEPT_CODE__c IN:deptCodeSet
        ];

        System.debug('smDeptList :: ' + smDeptList);
        System.debug('smDeptList.size() :: ' + smDeptList.size());

        for (SM_DEPT__c smDept : smDeptList) {
            if (!deptCodeMap.containsKey(smDept.DEPT_CODE__c)) {
                deptCodeMap.put(smDept.DEPT_CODE__c, smDept);
            }
        }

        List<ProductRequest> prList = [
                SELECT Id, SR_SALE__c
                FROM ProductRequest
                WHERE Order_Number__c IN:orderNumberSet
                AND Consumables_Order_YN__c = TRUE
                AND Consumables_Order_USE_YN__c = TRUE
                AND SR_SALE__c != NULL
                AND SALE_Number__c != NULL
                AND (RecordType.DeveloperName = 'Consumable' OR RecordType.DeveloperName='CareSupplies')
        ];

        System.debug('prList :: ' + prList);
        System.debug('prList.size() :: ' + prList.size());

        for (ProductRequest pr : prList) {
            System.debug('pr :: ' + pr);
            saleIdSet.add(pr.SR_SALE__c);
        }

        // 최종 흑자건 조회
        // 23 09 25 hyungho.chun 포인트시 이름/전화번호 정보 추가 (PAY_CUST_NAME__c, PAY_CUST_PHONE__c)
        // 23 10 20 hyungho.chun 포인트환불 인터페이스 조회 생략 위해 MBS_CUST_ID__c 필드 추가 적용
        SR_AR_CONFIRM__c[] kBlacks = [
                SELECT Id, SR_PAYMENT_BASIS_ID__r.SR_SALE_ID__c, TID_CASH__c, TID__c, SR_PAYMENT_BASIS_ID__r.SR_SALE_ID__r.Order_CHNL_TYPE_Code__c, IsMIG__c, 
                        APPR_NUM__c, DEPOSIT_TYPE__c, UPAD_DETAIL_TYPE__c, INVOICE_ISSUE_TYPE__c, PAY_CUST_NAME__c, PAY_CUST_PHONE__c, 
                        AR_INVOICE_NO__c, DEPOSIT_AMT__c, SR_PAYMENT_BASIS_ID__r.BASIS_NO__c, POINT_TRX_ID__c, MBS_CUST_ID__c , CHANGE_SEQ__c 
                FROM SR_AR_CONFIRM__c
                WHERE SR_PAYMENT_BASIS_ID__r.SR_SALE_ID__c IN:saleIdSet
                AND FM_RED_BLACK__c = 'B'
                AND LAST_SR_AR_CONFIRM_ID__c = NULL
        ];

        System.debug('kBlacks :: ' + kBlacks);
        System.debug('kBlacks.size() :: ' + kBlacks.size());

        Map<String,SR_AR_CONFIRM__c> srSaleARtempMap = new Map<String,SR_AR_CONFIRM__c>();
        String strKey = '';
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@        
        //24 01 08 hyungho.chun 기존 해당 흑자채권 모음
        // for (SR_AR_CONFIRM__c arConfirm : kBlacks) {
        //     str = arConfirm.SR_PAYMENT_BASIS_ID__r.SR_SALE_ID__c;
        //     System.debug('str :: ' + str);
        //     arConfirmList = saleIdArConfirmMap.containsKey(str)
        //             ? saleIdArConfirmMap.get(str)
        //             : new List<SR_AR_CONFIRM__c>();
        //     if(arConfirm.DEPOSIT_TYPE__c != 'D'){ //24 01 08 hyungho.chun 포인트아닌건
        //         arConfirmList.add(arConfirm);
        //         saleIdArConfirmMap.put(str, arConfirmList);
        //     }else{                                  //24 01 08 hyungho.chun  포인트건인경우 다 넣지말고 반품에해당하는 prli의 trxid가있는거만 넣는다
        //         if(trxList.contains(arConfirm.POINT_TRX_ID__c)){
        //             arConfirmList.add(arConfirm);
        //             saleIdArConfirmMap.put(str, arConfirmList);
        //         }
        //     }
        // }

        //24 01 08 hyungho.chun 이후 해당 흑자채권 모음 change_seq높은것부터
        for (SR_AR_CONFIRM__c arConfirm : kBlacks) {
            str = arConfirm.SR_PAYMENT_BASIS_ID__r.SR_SALE_ID__c;
            System.debug('str :: ' + str);
            // strKey = str+arConfirm.DEPOSIT_TYPE__c;
            strKey = str+arConfirm.Id+arConfirm.DEPOSIT_TYPE__c; //24 02 28 hyungho.chun 포인트들어간 ro 1개 roli 다수 의 경우 모든 포인트채권다찾아야함 키값 추가 
            System.debug('strKey :: ' + strKey);
            // arConfirmList = saleIdArConfirmMap.containsKey(str)
            //         ? saleIdArConfirmMap.get(str)
            //         : new List<SR_AR_CONFIRM__c>();
            if(arConfirm.DEPOSIT_TYPE__c != 'D'){ //24 01 08 hyungho.chun 포인트아닌건
                if(srSaleARtempMap.containsKey(strKey)){
                    if(srSaleARtempMap.get(strKey).CHANGE_SEQ__c == null || srSaleARtempMap.get(strKey).CHANGE_SEQ__c < arConfirm.CHANGE_SEQ__c){
                        srSaleARtempMap.put(strKey,arConfirm);
                    }
                }else{
                    srSaleARtempMap.put(strKey,arConfirm);
                }
                // arConfirmList.add(arConfirm);
                // saleIdArConfirmMap.put(str, arConfirmList);
            }else{                                  //24 01 08 hyungho.chun  포인트건인경우 다 넣지말고 반품에해당하는 prli의 trxid가있는거만 넣는다
                if(arConfirm.SR_PAYMENT_BASIS_ID__r.SR_SALE_ID__r.Order_CHNL_TYPE_Code__c == 'V' && !arConfirm.IsMIG__c){ //24 02 27 hyungho.chun 채권마이그는 trx별로 나뉘어있지않아서 분기처리
                    if(trxList.contains(arConfirm.POINT_TRX_ID__c)){
                        if(srSaleARtempMap.containsKey(strKey)){
                            if(srSaleARtempMap.get(strKey).CHANGE_SEQ__c == null || srSaleARtempMap.get(strKey).CHANGE_SEQ__c < arConfirm.CHANGE_SEQ__c){
                                srSaleARtempMap.put(strKey,arConfirm);
                            }
                        }else{
                            srSaleARtempMap.put(strKey,arConfirm);
                        }                    
                        // arConfirmList.add(arConfirm);
                        // saleIdArConfirmMap.put(str, arConfirmList);
                    }
                }else{ //24 02 26 hyungho.chun OBS경우 TRXID가 들어오지않아 따로 분기처리
                    if(srSaleARtempMap.containsKey(strKey)){
                        if(srSaleARtempMap.get(strKey).CHANGE_SEQ__c == null || srSaleARtempMap.get(strKey).CHANGE_SEQ__c < arConfirm.CHANGE_SEQ__c){
                            srSaleARtempMap.put(strKey,arConfirm);
                        }
                    }else{
                        srSaleARtempMap.put(strKey,arConfirm);
                    }                        
                }

            }
        }
        
        for(String strKeyTemp : srSaleARtempMap.keySet()){
            // str = strKeyTemp.substring(0,strKeyTemp.length()-1);
            str = strKeyTemp.substring(0,strKeyTemp.length()-19); //24 02 28 hyungho.chun 키값에 arConfirm아이디도 추가해서 recordId길이만큼 더짜름 -1 에서 -19 
            System.debug('str22 :: ' + str);
            arConfirmList = saleIdArConfirmMap.containsKey(str)
                    ? saleIdArConfirmMap.get(str)
                    : new List<SR_AR_CONFIRM__c>();

            arConfirmList.add(srSaleARtempMap.get(strKeyTemp));
            saleIdArConfirmMap.put(str, arConfirmList);
        }

        
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        List<SR_PRE_PAYMENT_HEADER__c> headerList = [
                SELECT Id, BASIS_NO__c,
                (
                        SELECT Id, MOID__c, POINT_TRX_ID__c,
                                SR_SMARTRO_PAYMENT_REQUEST_Id__r.SR_AR_CONFIRM_ID__c
                        FROM SR_PAYMENT_HIST_DETAILS__r
                )
                FROM SR_PRE_PAYMENT_HEADER__c
                WHERE BASIS_NO__c IN:saleNumberSet
        ];
        System.debug('headerList :: ' + headerList);
        System.debug('headerList.size() :: ' + headerList.size());

        for (SR_PRE_PAYMENT_HEADER__c header : headerList) {
            System.debug('header :: ' + header);
            for (SR_PRE_PAYMENT_DETAIL__c detail : header.SR_PAYMENT_HIST_DETAILS__r) {
                if (detail.MOID__c != null && !detail.MOID__c.equals('')) {
                    saleNumberMOIDMap.put(header.BASIS_NO__c, detail.MOID__c);
                }
            }
        }

        for (ReturnOrder ro : roList) {
            String goodsName = null;
            for (ReturnOrderLineItem roLi : roIdRoLiListMap.get(ro.Id)) {
                Decimal returnQuantity = roIdReturnQuantityMap.containsKey(ro.Id)
                        ? roIdReturnQuantityMap.get(ro.Id)
                        : 0;

                roIdReturnQuantityMap.put(ro.Id, returnQuantity + roLi.QuantityReturned);

                if (!roIdReturnGoodsNameMap.containsKey(ro.Id)) {
                    goodsName = roLi.Product2.PART_DESC_KOR__c == null
                            ? roLi.Product2.PART_DESC__c
                            : roLi.Product2.PART_DESC_KOR__c;
                    roIdReturnGoodsNameMap.put(ro.Id, goodsName);
                }
            }
            if (roIdRoLiListMap.get(ro.Id).size() > 1) {
                if (roIdReturnGoodsNameMap.containsKey(ro.Id)) {
                    goodsName = roIdReturnGoodsNameMap.get(ro.Id);
                    goodsName += '외 ' + String.valueOf(roIdRoLiListMap.get(ro.Id).size()-1) + '개';
                    roIdReturnGoodsNameMap.put(ro.Id, goodsName);
                }
            }
        }
        srSaleList = [
                SELECT Id, SALE_Number__c, Buyer_Code__c, Buyer_Name__c, Buyer_Type_Code__c,
                        Consumables_Order_Type_Code__c, Consumables_Order_YN__c,
                        Contact__c, Department_Code__c, Department_Id__c,
                        Order_CHNL_TYPE_Code__c, Order_Number__c, paymentYN__c, deficitCheck__c 
                FROM SR_SALE__c
                WHERE Id IN:saleIdSet
        ];
        //24 01 17 hyungho.chun 쿼리에 deficitCheck__c 추가 (자재 반품확정된 데이터 보는 기준에 deficitCheck__c = true 있어서)
        for (SR_SALE__c srSale : srSaleList) {
            if (!saleNumberSrSaleMap.containsKey(srSale.SALE_Number__c)) {
                saleNumberSrSaleMap.put(srSale.SALE_Number__c, srSale);
            }
        }

        saleTypePrList = [
                SELECT Id, Order_Number__c, SALE_Number__c 
                FROM ProductRequest
                WHERE Order_Number__c IN: orderNumberSet
                AND RecordType.DeveloperName = 'SALE'
        ];
        System.debug('saleTypePrList :: ' + saleTypePrList);
        for (ProductRequest salePr : saleTypePrList) {
            if (!orderNumberSalePrMap.containsKey(salePr.Order_Number__c)) {
                orderNumberSalePrMap.put(salePr.Order_Number__c, salePr);
            }
        }

        saleTypePrLiList = [
                SELECT Id, Order_Number__c, SourceLocationId, Product2Id
                FROM ProductRequestLineItem
                WHERE Order_Number__c IN: orderNumberSet
                AND RecordType.DeveloperName = 'SALE'
        ];
        System.debug('saleTypePrLiList :: ' + saleTypePrLiList);
        for (ProductRequestLineItem salePrLi : saleTypePrLiList) {
            String uniqueKey = salePrLi.SourceLocationId + '^' + salePrLi.Product2Id + salePrLi.Order_Number__c;
            if (!uniqueKeySalePrLiMap.containsKey(uniqueKey)) {
                uniqueKeySalePrLiMap.put(uniqueKey, salePrLi);
            }
        }

        System.debug('roIdRoLiListMap :: '+roIdRoLiListMap);

        paramMap.put('kBlacks', kBlacks);
        paramMap.put('saleIdArConfirmMap', saleIdArConfirmMap);
        paramMap.put('saleNumberMOIDMap', saleNumberMOIDMap);
        paramMap.put('deptCodeMap', deptCodeMap);
        paramMap.put('confirmIdTrxIdMap', confirmIdTrxIdMap);
        paramMap.put('roIdTrxIdSetMap', roIdTrxIdSetMap);
        paramMap.put('roIdRoLiListMap', roIdRoLiListMap);
        paramMap.put('roList', roList);
        paramMap.put('roIdReturnQuantityMap', roIdReturnQuantityMap);
        paramMap.put('roIdReturnGoodsNameMap', roIdReturnGoodsNameMap);
        paramMap.put('saleNumberSrSaleMap', saleNumberSrSaleMap);
        paramMap.put('failOrderNumberList', new List<String>());
        paramMap.put('orderNumberSalePrMap', orderNumberSalePrMap);
        paramMap.put('uniqueKeySalePrLiMap', uniqueKeySalePrLiMap);

        return paramMap;
    }

    public static Map<String, Object> doReturnOrderConfirm2(Map<String, Object> paramMap, List<ReturnOrder> roList) {
        //23 10 27 hyungho.chun 
        // savepoint rollback 및 마이그 데이터 문제 SR_ONLINE_AUTO_SALE_EXC__c 에 기록하는 로직 추가
        Savepoint sp = Database.setSavepoint();
        List<String> failOrderNumberList = (List<String>) paramMap.get('failOrderNumberList');
        ReturnOrder curRo = roList.get(0);
        Map<String, List<ReturnOrderLineItem>> roIdRoLiListMap = (Map<String, List<ReturnOrderLineItem>>) paramMap.get('roIdRoLiListMap');
        List<ReturnOrderLineItem> roLiList = roIdRoLiListMap.get(curRo.Id);

        Map<String,String> errorMap = new Map<String,String>();
        Map<String, Object> rtnMap = new Map<String, Object>();
        


        try{
            //23 11 29 hyungho.chun 케어플러스대비 원주문번호 임시저장
            //23 12 08 hyungho.chun 케어플러스일때만으로 바꿈
            // String orderNo = curRo.ProductRequest.Order_Number__c;
            String orderNo = curRo.Order_CHNL_TYPE_Code__c == 'BestShop' ? curRo.ProductRequest.Order_Number__c : curRo.Order_Number__c;

            Map<String, List<ReturnOrderLineItem>> prLiIdReturnOrderListMap = new Map<String, List<ReturnOrderLineItem>>();
            Map<String, List<SR_AR_CONFIRM__c>> saleIdArConfirmMap = (Map<String, List<SR_AR_CONFIRM__c>>) paramMap.get('saleIdArConfirmMap');
            // 수불처리용 맵
            Map<String, ProductItem> pMapProductItemByKey = new Map<String, ProductItem>();
            Map<String, SR_SALE__c> saleNumberSrSaleMap = (Map<String, SR_SALE__c>) paramMap.get('saleNumberSrSaleMap');
            Map<String, Object> mapRequestInfo = null;
            // Map<String, Decimal> prLiIdReturnQuantityMap = new Map<String, Decimal>();
            /**
             *   Key: OrderNumber    Value: PiKeyList
             *   주문번호와 수불처리에 사용되는 Pikey(prLi.SourceLocationId + '^' + prLi.Product2Id)
             *   리스트를 맵으로 구성한 후에 실패한 주문번호들은 자재쪽 수불처리에서 제외하기 위해 사용
             */
            Map<String, List<String>> orderNumberPiKeyListMap = new Map<String, List<String>>();
            /**
             *   적자타입 ReturnOrder, ReturnOrderLineItem 생성 시
             *   판매타입 ProductRequest, ProductReqestLineItem과 연결해주기 위한 맵
             *   판매는 주문 건 별이므로 ProductRequest는 OrderNumber로 특정하고
             *   ProductRequestLineItem은 uniqueKey(SourceLocationId + Product2Id + OrderNumber)로 특정한다.
             */
            Map<String, ProductRequest> orderNumberSalePrMap = (Map<String, ProductRequest>) paramMap.get('orderNumberSalePrMap');
            Map<String, ProductRequestLineItem> uniqueKeySalePrLiMap = (Map<String, ProductRequestLineItem>) paramMap.get('uniqueKeySalePrLiMap');
    
            List<ReturnOrderLineItem> bestShopRoLiList = new List<ReturnOrderLineItem>();
            List<ReturnOrderLineItem> tmpRoLiList = null;
            // 케어용품 Back IF 리스트
            List<SI_CAREPLUS_BACKIF__c> backIFList = new List<SI_CAREPLUS_BACKIF__c>();
            // 원주문건 리스트
            List<ProductRequestLineItem> originPrLiList = new List<ProductRequestLineItem>();
            // 수불처리용 List
            List<Map<String, Object>> pListMapRequestInfo = new List<Map<String, Object>>();
            List<ProductTransfer> upsertPrTrList = new List<ProductTransfer>();
            
            // 비동기 처리 에러 로깅할 수 있도록 만드는 레코드 리스트
            List<SR_ONLINE_AUTO_SALE_EXC__c> failRecordList = new List<SR_ONLINE_AUTO_SALE_EXC__c>();
    
            List<String> piKeyList = null;
    
            Set<String> originPrLiIdSet = new Set<String>();
            Set<String> roIdSet = new Set<String>();
            // 수불처리용 Set들
            Set<String> piKeySet = new Set<String>();
            Set<String> partIdSet = new Set<String>();
            Set<String> locationIdSet = new Set<String>();
            Set<String> orderNumberSet = new Set<String>();

            User getUserEmpNum = [SELECT EmployeeNumber__c FROM User WHERE Id =: UserInfo.getUserId()];

            //23 12 12 hyungho.chun
            List<EX_ConsumableUtil.RefundWrapper> refundWrapperList = new List<EX_ConsumableUtil.RefundWrapper>();
            FNManager.RedRecorder recorder = FNManager.red(curRo.ProductRequest.SR_SALE__c);
    
            // 수불처리용 String
            String stqProductItemQry = null, strKeyPI = null;
            Boolean isExchangeReturn = false;
    
            System.debug('roLiList At doReturnOrderConfirm2 :: '+roLiList);
            List<ReturnOrderLineItem> roLiListNotFullDC = new List<ReturnOrderLineItem>(); //24 01 11 hyunghoc.ho 100%할인건은 뺀 roli list
            //23 12 12 hyungho.chun try catch안에 try catch있는건 뺌
            // try {
                for (ReturnOrderLineItem roLi : roLiList) {
                    if (roLi.ProductRequestLineItem.Parent.SR_SALE__c == null) continue;
    
                    if (roLi.ReturnOrderId != null) {
                        roIdSet.add(roLi.ReturnOrderId);
                    }
    
                    if (roLi.Order_Number__c != null) {
                        orderNumberSet.add(roLi.Order_Number__c);
                    }
    
                    // 반품 확정 수량
                    roLi.Actual_Return_Quantity__c = roLi.Consumables_Business_Type_Code__c.equals('ExchangeReturn')
                            ? roLi.QuantityReturned
                            : roLi.Expected_Return_Quantity__c;
                    // 반품 확정 일시
                    roLi.Return_Order_CONFIRM_DTM__c = System.now();
                    
                    roLi.REFUND_Complete_YN__c = true;

                    //2024.03.11 seung yoon heo 반품자명 추가
                    roLi.CONFIRM_User_Id__c = getUserEmpNum.EmployeeNumber__c;

                    // if (roLi.ProductRequestLineItemId != null) {
                    //   // 0보다 다 작음 보장 원 주문건 판매수량 수정
                    //   roLi.ProductRequestLineItem.SALE_Quantity__c -= roLi.Actual_Return_Quantity__c;
                    //     Decimal qty = prLiIdReturnQuantityMap.containsKey(roLi.ProductRequestLineItemId)
                    //             ? prLiIdReturnQuantityMap.get(roLi.ProductRequestLineItemId)
                    //             : 0;
                    //     qty += roLi.Actual_Return_Quantity__c;
                    //     prLiIdReturnQuantityMap.put(roLi.ProductRequestLineItemId, qty);
                    // }
                    //prLiIdReturnQuantityMap 로 마지막에 다 빼준다.
    
                    // 트리거에서 업데이트
                    // roLi.COLLECTION_YN__c = true;
                    // roLi.Consumables_Order_Status__c = '120';
    
                    //23 08 19 hyungho.chun 이유모를 반품요청-> 반품확정
                    roLi.Consumables_Order_Status__c = '120';
                    //23 09 07 hyungho.chun 수거여부/확정/cj전송여부 true로

                    //23 12 09 hyungho.chun 더이상 수거여부를 늘 true로 하지않고 양품폐기 버튼 활성화조건은 CONFIRM_YN__c로만 체크한다
                    // roLi.COLLECTION_YN__c = true;
                    roLi.CONFIRM_YN__c = 'Y';
                    //23 09 19 hyungho.chun 반품요청하자마자 바로 확정하는경우가 있어서 조건 하나 제외
                    // roLi.FFMT_Order_Transfer_YN__c = true;
    
                    // 반품예정수량 초기화
                    roLi.Expected_Return_Quantity__c = 0;
    
                    originPrLiIdSet.add(roLi.ProductRequestLineItemId);
                    originPrLiIdSet.add(roLi.Exchange_Order_Item_Id__c);
    
                    tmpRoLiList = prLiIdReturnOrderListMap.containsKey(roLi.ProductRequestLineItemId)
                            ? prLiIdReturnOrderListMap.get(roLi.ProductRequestLineItemId)
                            : new List<ReturnOrderLineItem>();
                    tmpRoLiList.add(roLi);
                    prLiIdReturnOrderListMap.put(roLi.ProductRequestLineItemId, tmpRoLiList);
    
                    // 케어용품만 추출
                    if (roLi.Order_CHNL_TYPE_Code__c == EX_ConsumableUtil.CONSUMABLE_BESTSHOP) {
                        system.debug('careplus !! roLi ::: '+roLi);
                        bestShopRoLiList.add(roLi);
                    }

                    if(roLi.ProductRequestLineItem.Parent.SALE_Amount__c >roLi.ProductRequestLineItem.Parent.Discount_Amount__c){ //24 01 11 hyunghoc.ho 100%할인건은 뺀 roli list   // 아래에서 updateRoliSDPN 메소는 태우지않기위해
                        roLiListNotFullDC.add(roLi);
                    }                   
                }
                System.debug('tmpRoLiList :: '+tmpRoLiList);
                System.debug('prLiIdReturnOrderListMap :: ' + prLiIdReturnOrderListMap);
    
                // 원주문건 판매수량 업데이트
                // List<ProductRequestLineItem> prLiList = [
                //         SELECT Id, SALE_Quantity__c
                //         FROM ProductRequestLineItem
                //         WHERE Id IN:prLiIdReturnQuantityMap.keySet()
                // ];
                // for (ProductRequestLineItem prLi : prLiList) {
                //     prLi.SALE_Quantity__c -= prLiIdReturnQuantityMap.get(prLi.Id);
                // }
    
                // failRecordList.addAll(EX_ConsumableUtil.checkFail(prLiList,
                //         failOrderNumberList,
                //         '원주문건 판매수량 업데이트 실패'));
                // update prLiList;
                // prLiList.clear();
    
                if (!bestShopRoLiList.isEmpty()) {
                    Decimal maxNum = 0;
                    List<SI_CAREPLUS_BACKIF__c> getMaxList = new List<SI_CAREPLUS_BACKIF__c>();
                    getMaxList = [
                            SELECT INTERFACE_ID__c
                            FROM SI_CAREPLUS_BACKIF__c
                            ORDER BY INTERFACE_ID__c DESC
                            LIMIT 1
                    ];
                    if(!getMaxList.isEmpty()){
                        SI_CAREPLUS_BACKIF__c getMax = getMaxList[0];
                        if(getMax.INTERFACE_ID__c != null && getMax.INTERFACE_ID__c > 0){
                            maxNum = getMax.INTERFACE_ID__c + 1;
                        }
                    }
    
                    Decimal maxSubNum = 1;
    
                    for (ReturnOrderLineItem bestShopRoli : bestShopRoLiList) {
                        if (failOrderNumberList.contains(bestShopRoli.Order_Number__c)) continue;
    
                        Map<String, Object> ifDataInfoMap = EX_ReturnOrderManagementController.setCarePlusBackIFData(bestShopRoli, maxNum, maxSubNum,'RETURNED');
                        SI_CAREPLUS_BACKIF__c backIF = (SI_CAREPLUS_BACKIF__c) ifDataInfoMap.get('backIF');
                        maxNum = (Decimal) ifDataInfoMap.get('maxNum');
                        maxSubNum = (Decimal) ifDataInfoMap.get('maxSubnum');
                        backIFList.add(backIF);
                    }
                }
    
                if (!backIFList.isEmpty()) {
                    failRecordList.addAll(EX_ConsumableUtil.checkFail(backIFList,
                            failOrderNumberList,
                            'SI_CAREPLUS_BACKIF__c 생성 실패, '));
                }
    
                failRecordList.addAll(EX_ConsumableUtil.checkFail(roLiList,
                        failOrderNumberList,
                        '원반품건 업데이트 실패, '));
            // } catch(Exception e) {
            //     System.debug('[Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage());
            // }
    
            originPrLiList = [
                    SELECT Id, Order_Number__c, Consumables_Order_Status__c, Return_Order_Quantity__c, Consumables_Order_Detail__c, SALE_Quantity__c
                    FROM ProductRequestLineItem
                    WHERE Id IN:prLiIdReturnOrderListMap.keySet()
            ];
    
            System.debug('originPrLiList :: ' + originPrLiList);
            System.debug('originPrLiList.size() :: ' + originPrLiList.size());
    
            for (ProductRequestLineItem prLi : originPrLiList) {
                if (failOrderNumberList.contains(prLi.Order_Number__c)) continue;
    
                Integer totalReturnQuantity = 0;
                isExchangeReturn = false;
                if (prLiIdReturnOrderListMap.containsKey(prLi.Id)) {
                    for (ReturnOrderLineItem roLi : prLiIdReturnOrderListMap.get(prLi.Id)) {
                        if (roLi.Consumables_Business_Type_Code__c == 'ExchangeReturn') {
                            isExchangeReturn = true;
                            break;
                        }
                        totalReturnQuantity += roLi.Actual_Return_Quantity__c.intValue();
                    }
                }
                if (!isExchangeReturn) {
                    prLi.SALE_Quantity__c -= totalReturnQuantity;
                    prLi.Return_Order_Quantity__c = totalReturnQuantity;
                    prLi.Consumables_Order_Detail__c = '';
                }
                //2023.10.25 seung yoon heo 반품 확정일경우 교환수량 빼는 로직 SR_ONLINE_DELIVERY_INFO_HISTORY_tr로 옮김
                // else{
                //       //23 09 16 hyungho.chun 교환반품이 반품확정될때 교환수량 해당 수 만큼 감소로직 필요 (교환반품이 확정이란것은 몇개던 다 확정이라 값 0으로 고정 수정)
                //       prLi.Exchange_Quantity__c = 0;
                // }
                prLi.ShipToStreet = null; // 24 03 20 hyungho.chun 잘못됐던건들 '임시조치' 제거
            }
    
            failRecordList.addAll(EX_ConsumableUtil.checkFail(originPrLiList,
                    failOrderNumberList,
                    '원주문건 업데이트 실패, '));
            // try {
            //     update originPrLiList;
            // } catch(Exception e) {
            //     System.debug(e.getMessage());
            // }
    
            // 23.06.18 환불처리 배치 finish로
            // for (ReturnOrder ro : roList) {
            //     // 환불처리와 적자채권은 Queueable안에서 분기로 환불처리는 소모품택배만
            //     // if (ro.Order_CHNL_TYPE_Code__c != 'V') continue;
            //     System.debug('ba ro : ' + ro);
            //     System.debug('saleIdArConfirmMap : ' + saleIdArConfirmMap);
            //     System.debug('ro po : ' + ro.ProductRequest);
            //     for (SR_AR_CONFIRM__c arConfirm : saleIdArConfirmMap.get(ro.ProductRequest.SR_SALE__c)) {
            //         System.debug('arConfirmList size :: ' + saleIdArConfirmMap.get(ro.ProductRequest.SR_SALE__c).size());
            //         System.debug('ba arConfirm : ' + arConfirm);
            //         if (!Test.isRunningTest()) {
            //             // todo: 적자채권 생성 테스트용 INVOICE_NO
            //             arConfirm.AR_INVOICE_NO__c ='^d^';
            //             System.enqueueJob(new EX_ReturnConfirmQueueable(ro, arConfirm, paramMap));
            //         }
            //     }
            // }
    
            System.debug('execute roLiList :: ' + roLiList);

            //24 03 02 hyungho.chun 판매확정때는 수불을 전혀 하지않는다!!!!!!!!!!!!!!!주석시작@@@@@@@@ -> 추후 양품/폐기 시 수불 양품 -> 보유량(+) / 폐기 -> 보유량(+), 폐기예정수량(+)


            // // 수불처리
            // for (ReturnOrderLineItem roLi : roLiList) {
            //     if (failOrderNumberList.contains(roLi.Order_Number__c)) continue;
    
            //     System.debug('start====================');
            //     System.debug(roLi.ProductRequestLineItem.Product2Id);
            //     System.debug(roLi.Product2Id);
            //     System.debug('end====================');
            //     ProductTransfer upsertPrTr = new ProductTransfer();
            //     //upsertPrTr.RecordTypeId = Schema.SObjectType.ProductTransfer.getRecordTypeInfosByDeveloperName().get('SALE').getRecordTypeId();
            //     upsertPrTr.DestinationLocationId = roli.DestinationLocationId;
    
            //     upsertPrTr.Product2Id = roli.ProductRequestLineItem.Product2Id;
    
            //     // 수불 처리용
            //     String piKey = roli.DestinationLocationId + '^' + roli.ProductRequestLineItem.Product2Id;
            //     System.debug('piKey -> ' + piKey);
    
            //     piKeySet.add(piKey);
    
            //     // 실패한 주문건들은 자재쪽 수불처리 메서드 태우지 않기 위해 맵 구성
            //     piKeyList = orderNumberPiKeyListMap.containsKey(roli.Order_Number__c)
            //             ? orderNumberPiKeyListMap.get(roli.Order_Number__c)
            //             : new List<String>();
            //     piKeyList.add(piKey);
            //     orderNumberPiKeyListMap.put(roli.Order_Number__c, piKeyList);
    
            //     // ProductRequestLineItem 저장시 ProductRequestId 확인
            //     upsertPrTr.ProductRequestLineItemId = roli.ProductRequestLineItemId;
            //     upsertPrTr.ReturnOrderLineItemId = roli.Id;
            //     upsertPrTr.SourceProductItemId = roli.ProductItemId;
            //     //23 10 05 hyungho.chun 
            //     upsertPrTr.QuantityUnitOfMeasure = 'Each';
            //     upsertPrTr.Product2Id = roli.ProductRequestLineItem.Product2Id;
            //     upsertPrTr.QuantitySent = roli.Actual_Return_Quantity__c;
            //     upsertPrTr.Status = '5';
            //     upsertPrTr.QuantityReceived = roli.Actual_Return_Quantity__c;
            //     upsertPrTr.IsReceived = true;
            //     System.debug('upsertPrTr :::: ' + upsertPrTr);
            //     upsertPrTrList.add(upsertPrTr);
    
            //     mapRequestInfo = new Map<String, Object>();
    
            //     mapRequestInfo.put('product2Id', upsertPrTr.Product2Id);
            //     mapRequestInfo.put('requestQTY', upsertPrTr.QuantitySent);
            //     mapRequestInfo.put('productTransfer', upsertPrTr);
    
            //     mapRequestInfo.put('sourceLocationId', upsertPrTr.SourceLocationId);
            //     mapRequestInfo.put('destinationLocationId', upsertPrTr.DestinationLocationId);
            //     mapRequestInfo.put('requestType', 'AH');
    
            //     mapRequestInfo.put('productRequestLineItem', null);
            //     mapRequestInfo.put('returnOrderLineItem', roli);
            //     mapRequestInfo.put('productTransfer', upsertPrTr);
    
            //     partIdSet.add(roli.product2Id);
            //     locationIdSet.add(roli.SourceLocationId);
            //     locationIdSet.add(roli.DestinationLocationId);
    
            //     pListMapRequestInfo.add(mapRequestInfo);
            // }
    
            // failRecordList.addAll(EX_ConsumableUtil.checkFail(upsertPrTrList,
            //         failOrderNumberList,
            //         'ProductTransfer 생성 실패, '));
    
            // // 실패건들 piKeyList 구성
            // for (String orderNumber : orderNumberPiKeyListMap.keySet()) {
            //     if (failOrderNumberList.contains(orderNumber)) {
            //         piKeySet.removeAll(orderNumberPiKeyListMap.get(orderNumber));
            //     }
            // }
            // //23 10 11 hyungho.chun SObjectUtil호출로 변경
            // stqProductItemQry = 'SELECT ' + String.join(SObjectUtil.getAllFields('ProductItem'), ',');
            // stqProductItemQry += '  FROM ProductItem';
            // stqProductItemQry += ' WHERE Product2Id IN :partIdSet AND LocationId IN :locationIdSet';
    
            // List<ProductItem> productItems = Database.query(stqProductItemQry);
    
            // strKeyPI = '';
            // for (ProductItem productItem : productItems) {
            //     strKeyPI = productItem.LocationId + '^' + productItem.Product2Id;
            //     System.debug('strKeyPI :: ' + strKeyPI);
            //     pMapProductItemByKey.put(strKeyPI, productItem);
            // }
    
            // Map<String, Object> applyProductItemRtnMap = FS_MaterialUtil.applyProductItem(pListMapRequestInfo, pMapProductItemByKey);
            // System.debug('applyProductItemRtnMap :: ' + applyProductItemRtnMap);
            // System.debug('수불처리 결과 : ' + applyProductItemRtnMap.get('isSuccess'));


            //24 03 02 hyungho.chun 판매확정때는 수불을 전혀 하지않는다!!!!!!!!!!!!!!!주석끝@@@@@@@@ -> 추후 양품/폐기 시 수불 양품 -> 보유량(+) / 폐기 -> 보유량(+), 폐기예정수량(+)
    
            // 판매적자 생성
            // 판매 적자 RecordType
            String roSaleDeficitRecordTypeId = Schema.SObjectType.ReturnOrder.getRecordTypeInfosByDeveloperName().get('SALE_DEFICIT').getRecordTypeId();
            String roliSaleDeficitRecordTypeId = Schema.SObjectType.ReturnOrderLineItem.getRecordTypeInfosByDeveloperName().get('SALE_DEFICIT').getRecordTypeId();
    
            List<SR_SALE__c> saleDeficitSaleList = new List<SR_SALE__c>();
            List<ReturnOrder> saleDeficitRoList = new List<ReturnOrder>();
            List<ReturnOrderLineItem> saleDeficitRoLiList = new List<ReturnOrderLineItem>();
    
            Set<String> saleDeficitSaleNumberSet = new Set<String>();
    
            // 판매적자 판매번호
            Map<String, String> saleNumberSaleIdMap = new Map<String, String>();
            Map<String, String> roIdSaleNumberMap = new Map<String, String>();
    
            Decimal basisSeq = 0;
    
            System.debug('판매적자 전 ReturnOrderList :: ' + roList);
    
            //23 09 11 hyungho.chun 반품확정 R시작 판매정보 만들지않기로 재경측 요청 받음
            // // 판매적자건 판매정보 먼저 생성
            // for (ReturnOrder ro : roList) {
            //     // 기존 SR_SALE__c 존재
            //     if (!saleNumberSrSaleMap.containsKey(ro.ProductRequest.SALE_Number__c)) continue;
    
            //     if (failOrderNumberList.contains(ro.Order_Number__c)) continue;
    
            //     // 판매적자건 판매정보
            //     SR_SALE__c baseSale = saleNumberSrSaleMap.get(ro.ProductRequest.SALE_Number__c);
            //     SR_SALE__c saleDeficitSale = new SR_SALE__c();
    
            //     saleDeficitSale.Buyer_Code__c = baseSale.Buyer_Code__c;
            //     saleDeficitSale.Buyer_Name__c = baseSale.Buyer_Name__c;
            //     saleDeficitSale.Buyer_Type_Code__c = baseSale.Buyer_Type_Code__c;
            //     saleDeficitSale.Consumables_Order_Type_Code__c = baseSale.Consumables_Order_Type_Code__c;
            //     saleDeficitSale.Consumables_Order_YN__c = baseSale.Consumables_Order_YN__c;
            //     saleDeficitSale.Contact__c = baseSale.Contact__c;
            //     saleDeficitSale.Department_Code__c = baseSale.Department_Code__c;
            //     saleDeficitSale.Department_Id__c = baseSale.Department_Id__c;
            //     saleDeficitSale.isMig__c = false;
            //     // X?
            //     saleDeficitSale.Order_CHNL_TYPE_Code__c = baseSale.Order_CHNL_TYPE_Code__c;
            //     saleDeficitSale.Order_Number__c = baseSale.Order_Number__c;
            //     saleDeficitSale.paymentYN__c = baseSale.paymentYN__c;
    
            //     saleDeficitSale.deficitCheck__c = true;
            //     saleDeficitSale.SALE_Number__c = 'R' + baseSale.SALE_Number__c.substring(1, baseSale.SALE_Number__c.length());
            //     saleDeficitSale.SALE_DTM__c = System.today();
            //     saleDeficitSale.Total_SALE_Amount__c = ro.RETURN_PAYMENT_Amount__c;
            //     // saleDeficitSale.Discount_Amount__c = baseSale.Discount_Amount__c;
    
            //     saleDeficitSaleList.add(saleDeficitSale);
    
            //     if (!roIdSaleNumberMap.containsKey(ro.Id)) {
            //         roIdSaleNumberMap.put(ro.Id, saleDeficitSale.SALE_Number__c);
            //     }
    
            //     saleDeficitSaleNumberSet.add(saleDeficitSale.SALE_Number__c);
            // }
    
            // System.debug('saleDeficitSale List : ' + saleDeficitSaleList);
            // // 현재 소모품은 A판매건은 두고 R건 새로 생성하고 있음 insert시 A채번됨..
            // // R 판매정보는 트리거 타지 않아도 된다고 자재측 답변 받았음
            // TriggerHandler.bypass('SR_SALE_tr');
            // failRecordList.addAll(EX_ConsumableUtil.checkFail(saleDeficitSaleList,
            //         failOrderNumberList,
            //         '적자 판매정보 생성 실패, '));
            // // insert saleDeficitSaleList;
            // TriggerHandler.clearBypass('SR_SALE_tr');
    
            // saleDeficitSaleList = [
            //         SELECT Id, SALE_Number__c, Order_Number__c
            //         FROM SR_SALE__c
            //         WHERE SALE_Number__c IN:saleDeficitSaleNumberSet
            // ];
    
            // // SALE_Number Key, Value Sale(SALE_DEFICIT) Id
            // for (SR_SALE__c saleDeficitSale : saleDeficitSaleList) {
            //     if (failOrderNumberList.contains(saleDeficitSale.Order_Number__c)) continue;
    
            //     if (!saleNumberSaleIdMap.containsKey(saleDeficitSale.SALE_Number__c)) {
            //         saleNumberSaleIdMap.put(saleDeficitSale.SALE_Number__c, saleDeficitSale.Id);
            //     }
            // }
    
            Map<String, ReturnOrder> roIdSaleDeficitRoMap = new Map<String, ReturnOrder>();
            //23 10 11 hyungho.chun clone쓰기전 -------------------------------------------------------------------시작
            // for (ReturnOrder ro : roList) {
            //     // ReturnOrderLineItem 리스트 존재
            //     if (!roIdRoLiListMap.containsKey(ro.Id)){
            //         System.debug('check 1');
            //         System.debug('roIdRoLiListMap :: '+roIdRoLiListMap); 
            //         continue;
            //     } 
    
            //     if (failOrderNumberList.contains(ro.Order_Number__c)){
            //         System.debug('check 2');
            //         System.debug('roIdRoLiListMap :: '+roIdRoLiListMap); 
            //         continue;
            //     }
    
            //     ReturnOrder saleDeficitRo = new ReturnOrder();
            //     saleDeficitRo.RecordTypeId = roSaleDeficitRecordTypeId;
            //     // saleDeficitRo.ProductRequestId = ro.ProductRequestId;
            //     saleDeficitRo.ProductRequestId = orderNumberSalePrMap.get(ro.Order_Number__c).Id;
            //     saleDeficitRo.ReturnedById = UserInfo.getUserId();
            //     saleDeficitRo.Department_LocationId__c = null;
            //     saleDeficitRo.Department_Code__c = ro.ProductRequest.Department_Code__c;
            //     saleDeficitRo.Order_Number__c = ro.Order_Number__c;
    
            //     roIdSaleDeficitRoMap.put(ro.Id, saleDeficitRo);
    
            //     saleDeficitRoList.add(saleDeficitRo);
            // }
            //23 10 11 hyungho.chun clone쓰기전 -------------------------------------------------------------------끝
    
            //23 10 11 hyungho.chun clone이후
            for (ReturnOrder ro : roList) {
                // ReturnOrderLineItem 리스트 존재
                if (!roIdRoLiListMap.containsKey(ro.Id)){
                    System.debug('check 1');
                    System.debug('roIdRoLiListMap :: '+roIdRoLiListMap); 
                    continue;
                } 
    
                if (failOrderNumberList.contains(ro.Order_Number__c)){
                    System.debug('check 2');
                    System.debug('roIdRoLiListMap :: '+roIdRoLiListMap); 
                    continue;
                }
    
                ReturnOrder saleDeficitRo = new ReturnOrder();
                saleDeficitRo = ro.clone();
                //23 10 30 hyungho.chun 새로생긴 필드 external id는 클론 뜰수없어서 제거
                saleDeficitRo.External_id__c = null;                
                //23 10 26 hyungho.chun 이젠 교환반품주문도 Consumables_Business_Type_Code__c에 ExchangeReturn가 들어갈수있음! (재경요청)
                // saleDeficitRo.Consumables_Business_Type_Code__c = saleDeficitRo.Consumables_Business_Type_Code__c == 'ExchangeReturn' ? null: saleDeficitRo.Consumables_Business_Type_Code__c;
                saleDeficitRo.RecordTypeId = roSaleDeficitRecordTypeId;
                // saleDeficitRo.ProductRequestId = ro.ProductRequestId;
                //23 10 27 hyungho.chun 마이그데이터예상 예상 오류 로그
                //23 11 29 ro.Order_Number__c -> orderNo
                if(orderNumberSalePrMap.get(orderNo) == null){
                    errorMap.put('tempErrorMsg', '주문번호 : '+orderNo + ' SALE type ProductRequest가 없습니다.');
                }
                //23 11 29 ro.Order_Number__c -> orderNo
                saleDeficitRo.ProductRequestId = orderNumberSalePrMap.get(orderNo).Id;
                saleDeficitRo.ReturnedById = UserInfo.getUserId();
                saleDeficitRo.Department_LocationId__c = null;
                saleDeficitRo.Department_Code__c = ro.ProductRequest.Department_Code__c;
    
                roIdSaleDeficitRoMap.put(ro.Id, saleDeficitRo);
    
                saleDeficitRoList.add(saleDeficitRo);
            }            
    
            System.debug('saleDeficitRoList :: '+saleDeficitRoList);
    
            // upsert saleDeficitRoList;
            failRecordList.addAll(EX_ConsumableUtil.checkFail(saleDeficitRoList,
                    failOrderNumberList,
                    '판매적자 ReturnOrder 생성 실패, '));
            System.debug('failOrderNumberList :: '+failOrderNumberList);

            List<SR_SALE__c> updateSrSaleList = new List<SR_SALE__c>(); //24 01 17 hyungho.chun 
            for (ReturnOrder ro : roList) {
                basisSeq = 1;
                //23 10 02 hyungho.chun 교환반품의 경우제외
                if(ro.Consumables_Business_Type_Code__c != 'ExchangeReturn'){
                    if(ro.ProductRequest.SALE_Number__c == null){
                        //23 10 30 hyungho.chun 마이그데이터예상 예상 오류 로그
                        // errorMap.put('tempErrorMsg', '주문번호 : '+ro.Order_Number__c + ' 원주문 ProductRequest에 판매정보 Sale_number__c 가 없습니다.');
                        throw new FNException('주문번호 : '+orderNo + ' 원주문 ProductRequest에 판매번호 Sale_number__c 가 없습니다.');
                        
                    }else if (ro.ProductRequest.SALE_Number__c != null && !saleNumberSrSaleMap.containsKey(ro.ProductRequest.SALE_Number__c)){
                        //23 10 30 hyungho.chun 마이그데이터예상 예상 오류 로그
                        // errorMap.put('tempErrorMsg', '주문번호 : '+ro.Order_Number__c + ' 원주문 ProductRequest에 판매정보 SR_Sale__c 가 없습니다.');
                        throw new FNException('주문번호 : '+orderNo + ' 원주문 ProductRequest에 판매정보 SR_Sale__c 가 없습니다.');
                        
                    } 
                }
                if (failOrderNumberList.contains(ro.Order_Number__c)) continue;
    
                SR_SALE__c baseSale;
                if(ro.Consumables_Business_Type_Code__c != 'ExchangeReturn'){
                    baseSale = saleNumberSrSaleMap.get(ro.ProductRequest.SALE_Number__c);    
                }else{
                    //23 11 29 ro.Order_Number__c -> orderNo
                    baseSale = saleNumberSrSaleMap.get(orderNumberSalePrMap.get(orderNo).SALE_Number__c);
                }
                baseSale.deficitCheck__c = true; //24 01 17 hyungho.chun 자재화면 반품확정 조회기준
                updateSrSaleList.add(baseSale);

                for (ReturnOrderLineItem roLi : roLiList) {
                    // 한 번 더 체크 방어로직
                    if (failOrderNumberList.contains(roLi.Order_Number__c)) continue;
    
                    String uniqueKey = roLi.ProductRequestLineItem.SourceLocationId
                            + '^' + roLi.ProductRequestLineItem.Product2Id
                            //23 11 29 ro.Order_Number__c -> orderNo
                            + orderNo;
                    ReturnOrderLineItem saleDeficitRoLi = new ReturnOrderLineItem();
                    saleDeficitRoLi = roLi.clone();
                    //23 10 30 hyungho.chun 새로생긴 필드 external id는 클론 뜰수없어서 제거
                    saleDeficitRoLi.External_id__c = null;                    
                    //23 10 26 hyungho.chun 이젠 교환반품주문도 Consumables_Business_Type_Code__c에 ExchangeReturn가 들어갈수있음! (재경요청)
                    // saleDeficitRoLi.Consumables_Business_Type_Code__c = saleDeficitRoLi.Consumables_Business_Type_Code__c == 'ExchangeReturn' ? null: saleDeficitRoLi.Consumables_Business_Type_Code__c;
    
                    saleDeficitRoLi.ReturnOrderId = roIdSaleDeficitRoMap.get(ro.Id).Id;
                    saleDeficitRoLi.Order_Number__c = ro.Order_Number__c;
                    saleDeficitRoLi.RecordTypeId = roliSaleDeficitRecordTypeId;
                    // saleDeficitRoLi.BASIS_Number__c = baseSale != null
                    //         ? 'R' + baseSale.SALE_Number__c.substring(1, baseSale.SALE_Number__c.length())
                    //         : '';
                    
                    //23 08 23 hyungho.chun basis_number__c는 폐기처리됐을때만 넣어주어야함
                    // saleDeficitRoLi.BASIS_Number__c = baseSale.SALE_Number__c;
                    saleDeficitRoLi.BASIS_Number__c = null;
                    saleDeficitRoLi.BASIS_SEQ__c = basisSeq++;
                    
                    
                    saleDeficitRoLi.Department_Code__c = roLi.ProductRequestLineItem.Department_Code__c;
                    saleDeficitRoLi.SourceLocationId = roLi.ProductRequestLineItem.SourceLocationId;
                    
                    
                    // {2개월무상=A, 결재유형변경=E, 구입취소(서비스접수)=J, 기타=L, 모델상이=B, 색상상이=C, 실물상이=D, 인적사항오=G, 판매수량조정=H}
                    saleDeficitRoLi.SALE_DEFICIT_Reason_Code__c = 'H';
                    // 손상됨
                    saleDeficitRoLi.SALE_DEFICIT_Other_Reason__c = roLi.Return_Requester_Reason__c != null
                            ? roLi.Return_Requester_Reason__c
                            : '반품으로 인한 판매적자';
                    // saleDeficitRoLi.ProductRequestLineItemId = roLi.ProductRequestLineItemId;
                    if(uniqueKeySalePrLiMap.get(uniqueKey) == null){
                        errorMap.put('tempErrorMsg', '주문번호 : '+ro.Order_Number__c + ' SALE Type ProductRequestLineItem Order_Number__c 및 SourceLocationId 를 확인해주세요.');
                    }
                    saleDeficitRoLi.ProductRequestLineItemId = uniqueKeySalePrLiMap.get(uniqueKey).Id;
                    saleDeficitRoLi.ProductItemId = roLi.ProductRequestLineItem.ProductItem__c;
                    saleDeficitRoLi.LOCATED_PLACE_Number__c = roLi.ProductRequestLineItem.fm_LOCATED_PLACE_Number__c;
    
    
                    System.debug('saleDeficitRoLi :: ' + saleDeficitRoLi);
                    saleDeficitRoLiList.add(saleDeficitRoLi);
                }

                //23 12 12 hyungho.chun 환불제외 모든로직을 환불앞으로 뺌 
                if (ro.ProductRequest.SR_SALE__c != null && saleIdArConfirmMap != null && !saleIdArConfirmMap.isEmpty() && !saleIdArConfirmMap.containsKey(ro.ProductRequest.SR_SALE__c)) {
                    //23 10 31 hyungho.chun 오류 로그 저장
                    throw new FNException('주문번호 : '+ro.Order_Number__c + 'SR_PAYMENT_BASIS_ID__r.SR_SALE_ID__c 가 ' +ro.ProductRequest.SR_SALE__c + ' 인 흑자채권(SR_AR_CONFIRM__c)가 없습니다.');
                }
                if(saleIdArConfirmMap != null && ro.ProductRequest.SR_SALE__c != null && ro.ProductRequest.SALE_Amount__c > ro.ProductRequest.Discount_Amount__c){ //24 01 11 hyungho.chun SALE_Amount__c> Discount_Amount__c 조건추가( 100% 할인은 채권생성안함)
                    for (SR_AR_CONFIRM__c arConfirm : saleIdArConfirmMap.get(ro.ProductRequest.SR_SALE__c)) {
                        refundWrapperList.add(new EX_ConsumableUtil.RefundWrapper(ro, arConfirm, null));
                    }
                }   




            }
            update updateSrSaleList; //24 01 17 hyungho.chun sr_sale deficitCheck__c true로 업데이트용 (자재화면 deficitCheck__c가 true기준으로 반품데이터 조회)

            System.debug('saleDeficitRoLiList :: ' + saleDeficitRoLiList);
            
            failRecordList.addAll(EX_ConsumableUtil.checkFail(saleDeficitRoLiList,
                    failOrderNumberList,
                    '판매적자 ReturnOrder 생성 실패, '));


            //23 12 12 hyungho.chun 환불제외 모든로직을 환불앞으로 뺌
            Decimal returnVirtualAmount = curRo.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c;
            Decimal returnCardAmount = curRo.RETURN_CARD_PAYMENT_Amount__c;
            

            Decimal refundAmt = 0;
            for(EX_ConsumableUtil.RefundWrapper rw : refundWrapperList){
                
                ReturnOrder ro = rw.getReturnOrder();
                SR_AR_CONFIRM__c arConfirm = rw.getArConfirm();
                if(arConfirm != null || ro != null){
                    arConfirm.AR_INVOICE_NO__c = '^d^';
                    
                    if (arConfirm.DEPOSIT_TYPE__c == 'D') {
                        System.debug('포인트건');
                        // //23 12 12 hyungho.chun roli ro 어차피 1:1 
                        // roLiList[0].POINT_REFUND_Complete_YN__c = 'Y';
                        refundAmt = !arConfirm.isMig__c ? arConfirm.DEPOSIT_AMT__c : curRo.RETURN_POINT_Amount__c; //24 02 27 hyungho.chun 마이그데이터경우 arconfirm 포인트 채권들이 합쳐져있어서 roli에서 환불할 금액 찾아온다
                        // refundAmt = roLiList[0].RETURN_POINT_Amount__c; 

                    }else if ((arConfirm.DEPOSIT_TYPE__c == 'B') || (arConfirm.DEPOSIT_TYPE__c == 'A')) {
                        System.debug('결제 URL, 가상계좌건');
                        // roLiList[0].ETC_REFUND_Complete_YN__c = 'Y';
                        
                        if ( arConfirm.DEPOSIT_TYPE__c == 'A') {
                            System.debug('CASH_REM_YN__c = Y 업데이트');
                            // roLiList[0].CASH_REM_YN__c = 'Y';
                            refundAmt = returnVirtualAmount;
                        }else if(arConfirm.DEPOSIT_TYPE__c == 'B'){
                            refundAmt = returnCardAmount;
                        }else{
                            System.debug('Something went wrong');
                        }
                        
                    }
                    // roLiList[0].REFUND_Complete_YN__c = true; //24 02 28 hyungho.chun 어차피 환불제외로직 전체 묶어서해서 반품확정날짜입히는 for loop에 추가함

                    // 소모품택배
                    if (ro.Order_CHNL_TYPE_Code__c.equals('V') && arConfirm.AR_INVOICE_NO__c != null && ro.Consumables_Business_Type_Code__c != 'ExchangeReturn') {
                        System.debug('적자채권 생성');
                        System.debug('arConfirm :: '+arConfirm);
                        System.debug('refundAmt :: '+refundAmt);
                        recorder.append(arConfirm.Id, refundAmt);
                        
                        
                    }
                    else {
                        System.debug('적자채권 생성 대상 아님 -> INVOICE_NO__c NULL');
                    }
                    
                    
                }

            }
            //24 03 22 hyungho.chun 소모품 택배 + 교환이 한번이라도 이루어졌던 원주문에 대한 반품요청인경우 아래 exchannelRed에서 외부채권처럼 적자채권생성
            List<ReturnOrderLineItem> exchangedBeforeList = [SELECT ID FROM ReturnOrderLineItem 
            WHERE RecordType.DeveloperName = 'Consumable' 
            AND Order_CHNL_TYPE_Code__c = 'V' 
            AND Order_Number__c =: orderNo 
            AND Consumables_Business_Type_Code__c = 'ExchangeReturn'];
            //위 쿼리가 사이즈가 0보다 크다면 한번이라도 교환반품이일어났던 주문이다 -> 적자채권을 .record()가 아닌 exChannelRed에서 생성시켜야한다
            
            // if (curRo.Order_CHNL_TYPE_Code__c.equals('V')  && curRo.Consumables_Business_Type_Code__c != 'ExchangeReturn' && curRo.ProductRequest.SALE_Amount__c >curRo.ProductRequest.Discount_Amount__c) {//24 01 11 hyungho.chun SALE_Amount__c> Discount_Amount__c 조건추가( 100% 할인은 채권생성안함)
            if (curRo.Order_CHNL_TYPE_Code__c.equals('V')  && curRo.Consumables_Business_Type_Code__c != 'ExchangeReturn' && curRo.ProductRequest.SALE_Amount__c >curRo.ProductRequest.Discount_Amount__c && exchangedBeforeList.size() == 0) {//24 03 22 hyungho.chun 교환이일어났던 원주문은 이쪽안타고 exChannelRed로 보냄(exchangedBeforeList.size()==0 -> 교환주문일어난적없음)
                recorder.record();
            }

            //24 02 24 hyungho.chun 앞으로 PH8002도 si_transaction 생성으로 메소드화
            insertSiTransaction(roLiList, failOrderNumberList, failRecordList);                               

            // 현재 ReturnOrder에 대한 외부채널 적자채권 생성
            if (roIdRoLiListMap.containsKey(curRo.Id)) {
                if (!failOrderNumberList.contains(curRo.Order_Number__c)) {
                    Set<String> roLiIdSet = new Set<String>();
                    tmpRoLiList = roIdRoLiListMap.get(curRo.Id);
                    for (ReturnOrderLineItem roLi : tmpRoLiList) {
                        // if(roLi.ProductRequestLineItem.Parent.SALE_Amount__c >roLi.ProductRequestLineItem.Parent.Discount_Amount__c){ //24 01 11 hyungho.chun SALE_Amount__c> Discount_Amount__c 조건추가( 100% 할인은 채권생성안함)
                        if(roLi.ProductRequestLineItem.Parent.SALE_Amount__c >roLi.ProductRequestLineItem.Parent.Discount_Amount__c){
                            if(roLi.Order_CHNL_TYPE_Code__c == 'V'){
                                if(roLi.Consumables_Business_Type_Code__c == 'ExchangeReturn' || (roLi.Consumables_Business_Type_Code__c == 'Return' && exchangedBeforeList.size()>0)){
                                    roLiIdSet.add(roLi.Id);    
                                }
                            }else{
                                roLiIdSet.add(roLi.Id);
                            }
                            
                        }
                    }
                    System.debug('외부채널 Id Set Size : ' + roLiIdSet.size());
                    EX_ConsumableUtil.exChannelRed(roLiIdSet);
                }
            }

            //23 12 12 hyungho.chun  
            // EX_ReturnConfirmQueueable.updateRoliSDPN(roLiList);
            //24 01 11 hyungho.chun roLiListNotFullDC 100%할인건은 빼고 여길태움
            EX_ReturnConfirmQueueable.updateRoliSDPN(roLiListNotFullDC);


            // 진행하며 발생된 실패건 없고. 채권 생성 에러 없을 때 (화면)
            if (failOrderNumberList.isEmpty()) {
                if (!rtnMap.containsKey('isSuccess')) {
                    rtnMap.put('isSuccess', true);
                }
            }else{
                rtnMap.put('isSuccess', false);
                rtnMap.put('errMsg',failOrderNumberList[0] + ' 실패. 관리자에게 문의하세요.');
            }                        
            //23 12 18 hyungho.chun 판매저장 성공건도 기록
            errorMap.put('errorType','SaveSales');
            // errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
            errorMap.put('requestMsg', '[Success] : '+roList.size()+ ' 건');
            errorMap.put('isSuccess','Y');
            errorMap.put('className','EX_ConsumableUtil.doReturnOrderConfirm2');
            System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
            saveSaleExc(errorMap);   
        }
        catch(Exception e){
            String tempMsg = ' [Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage();
            System.debug('[Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage());
            Database.rollback(sp);


            //24 03 20 hyungho.chun 오류시 원주문line item shipToStreet에 임시조치 기입
            Map<String, List<ReturnOrderLineItem>> prLiIdReturnOrderListMap = new Map<String, List<ReturnOrderLineItem>>();
            List<ReturnOrderLineItem> tmpRoLiList = null;
            List<ProductRequestLineItem> originPrLiListTemp = new List<ProductRequestLineItem>();
            for (ReturnOrderLineItem roLi : roLiList) {

                tmpRoLiList = prLiIdReturnOrderListMap.containsKey(roLi.ProductRequestLineItemId)
                        ? prLiIdReturnOrderListMap.get(roLi.ProductRequestLineItemId)
                        : new List<ReturnOrderLineItem>();
                tmpRoLiList.add(roLi);
                prLiIdReturnOrderListMap.put(roLi.ProductRequestLineItemId, tmpRoLiList);

              
            }            
            originPrLiListTemp = [
                SELECT Id 
                FROM ProductRequestLineItem
                WHERE Id IN:prLiIdReturnOrderListMap.keySet()
            ];
            if(originPrLiListTemp.size()>0){
                for(ProductRequestLineItem item : originPrLiListTemp){
                    item.ShipToStreet = '임시조치';
                }
            }
            update originPrLiListTemp;

            //23 10 30 hyungho.chun 마이그데이터예상 예상 오류 로그
            errorMap.put('orderNum',roLiList[0].Order_Number__c);
            errorMap.put('orderChannel',roLiList[0].Order_CHNL_TYPE_Code__c);
            errorMap.put('errorType','ReturnConfirm');
            errorMap.put('recordId',roLiList[0].Id);
            errorMap.put('tempErrorMsg', errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg') + tempMsg : tempMsg);
            errorMap.put('requestMsg', '[Fail] : '+roList.size()+ ' 건');
            errorMap.put('isSuccess','N');
            errorMap.put('className','EX_ConsumableUtil.doReturnOrderConfirm2');
            System.debug('Before Calling saveSaleExc // errorMap :: '+errorMap);
            saveSaleExc(errorMap);
            rtnMap.put('isSuccess', false);
            rtnMap.put('errMsg', roLiList[0].Order_Number__c + ' 실패. 관리자에게 문의하세요.');

        }

        return rtnMap;
    }

    //23.12.18 gw.lee
    //로그 추가 메소드 재활용
    //recordId => 오류 recordId
    //ERROR_DATE__c => 실행 날짜(Date)
    //INPUT_DATE__c => 실행 시간(DateTime)
    //Sale_YN__c => 성공 실패 여부
    //ERROR_MESSAGE__c => 실패건에 대한 오류 내용
    //RequestMessage__c => 성공 및 실패 카운팅
    //ORDER_CHANNEL__c => CLASS 이름
    public static void saveSaleExc(Map<String,String> errorMap){

        SR_ONLINE_AUTO_SALE_EXC__c saleExc = new SR_ONLINE_AUTO_SALE_EXC__c();
        
        saleExc.ERROR_DATE__c = System.today();
        saleExc.Input_date__c = System.now();
        saleExc.Last_update_date__c = System.now();
        saleExc.SourceRecordId__c = errorMap.containsKey('recordId') ? errorMap.get('recordId') : null;
        saleExc.ORDER_CHANNEL__c = errorMap.containsKey('className') ? errorMap.get('className') : null;
        saleExc.ORDER_NO__c = errorMap.containsKey('orderNum') ? errorMap.get('orderNum') : null;
        saleExc.SALE_YN__c = errorMap.containsKey('isSuccess') ? errorMap.get('isSuccess') : null;
        saleExc.ErrorType__c =  errorMap.containsKey('errorType') ? errorMap.get('errorType') : null;
        saleExc.ERROR_Message__c = errorMap.containsKey('tempErrorMsg') ? errorMap.get('tempErrorMsg').length()>255 ? errorMap.get('tempErrorMsg').subString(0,255) : errorMap.get('tempErrorMsg') : null; //24 02 25 hyungho.chun 에러메세지 긴경우 짜름
        saleExc.RequestMessage__c = errorMap.containsKey('requestMsg') ? errorMap.get('requestMsg') : null;

        System.debug('Before Insert saleExc :: '+saleExc);
        if(errorMap.containsKey('isSuccess') && errorMap.get('isSuccess') == 'N'){ 
            EX_MessageUtil.sendSMSandEmail(errorMap); //24 02 25 hyungho.chun 배치실패시 담당자에게 이메일 및 SMS 전송
        }
        insert saleExc;

    }

    //23 11 30 hyungho.chun 판매확정시 PRLI 기준으로 bacif 생성할 메소드가 없어서 추가 (현재'SHIPPED'생성용)
    public static Map<String, Object> setCarePlusBackIFData(ProductRequestLineItem item, String completeLineId, Decimal maxNum, Decimal maxSubnum, String backStatus) {
        Map<String, Object> rtnInfoMap = new Map<String, Object>();

        SI_CAREPLUS_BACKIF__c backIF = new SI_CAREPLUS_BACKIF__c(); 

        backIF.INTERFACE_ID__c = maxNum++;
        backIF.TRANS_TYPE__c = 'O'; // backif 추가로 생성로직필요한경우 나중에 분기처리
        //트랜잭션 요청타입 :트랜잭션 요청타입(O:매입 주문 생성 요청, C:취소 요청, R:환입 주문 생성 요청)
        backIF.ORDER_NO__c = item.Order_Number__c;
        backIF.REQUEST_NO__c = item.Order_Number__c; //Request_no는 careplus_order에서 늘 order_no와 같게옴
        backIF.REQUEST_SEQ__c = 1;  //REQUEST_SEQ__c careplus_order에서 늘 1로 오는중 / 수정 필요하다면 order_no로 

        // backIF.BACK_SUB_SEQ__c = maxSubNum++;
        backIF.BACK_SUB_SEQ__c = maxSubNum; //24 01 30 hyungho.chun seq 증가로 일단 고정 ( 차후 송장번호분리건일때 seq증가하여 만드는 로직 추가 필요할수도있음)
        //23 08 25 hyungho.chun ProductRequest__c 비어있음
        // backIF.ORDER_DATE__c = item.ProductRequest__r.Order_Date__c;
        // backIF.BILL_TO_CODE__c = item.ProductRequest__r.BILL_TO_CODE__c;
        // backIF.ORDER_DATE__c = item.ReturnOrder.ProductRequest.Order_Date__c;
        // backIF.BILL_TO_CODE__c = item.ReturnOrder.ProductRequest.BILL_TO_CODE__c;
        backIF.ORDER_DATE__c = item.Parent.Order_Date__c;
        backIF.BILL_TO_CODE__c = item.Parent.BILL_TO_CODE__c;

        backIF.CREATION_DATE__c = Date.today();
        backIF.CREATED_BY__c = 'SYSTEM';
        backIF.LAST_UPDATE_DATE__c = Date.today();
        backIF.LAST_UPDATED_BY__c = 'SYSTEM';


        backIF.DIV_CODE__c = item.Product2.DIV_CODE__c;
        backIF.MODEL_CODE__c = item.MODEL_Code__c;
        backIF.PART_NO__c = item.Product2.Name;
        backIF.ORDER_QTY__c = item.QuantityRequested;
        backIF.SHIPPED_QTY__c = item.SHIP_QTY__c;
        backIF.CANCEL_QTY__c = item.CANCEL_Quantity__c;
        // backIF.ORDER_PRICE__c = item.ProductRequestLineItem.fm_UnitPrice__c;
        //23 11 28 hyungho.chun fm_UnitPrice__c -> UnitPrice__c
        backIF.ORDER_PRICE__c = item.UnitPrice__c;
        //주문단가, ProductRequestLineItem.UnitPrice__c OR fm_UnitPrice__c
        backIF.ORDER_AMT__c = (backIF.Order_Price__c * item.QuantityRequested);
        //주문금액, 주문단가 * 수량
        //23 11 28 hyungho.chun SHIP_AMT__c = 0 ---> backStatus 분기
        backIF.SHIP_AMT__c =  backIF.ORDER_AMT__c;//Ex_CarePlustOrder 457번째줄 참조
        backIF.RECEIVER_NAME__c = item.CONSIGNEE_Name__c;

        //23 08 28 hyungho.chun
        // backIF.SHIP_TO_CODE__c = item.ProductRequest__r.SHIP_TO_CODE__c;
        backIF.SHIP_TO_CODE__c = item.Parent.SHIP_TO_CODE__c;

        backIF.POSTAL_CODE__c = item.CONSIGNEE_PostalCode__c;
        backIF.BASIC_ADDRESS__c = item.CONSIGNEE_Address__c;
        backIF.DETAIL_ADDRESS__c = item.CONSIGNEE_Address_DETAIL__c;
        backIF.RECEIVER_PHONE_NO__c = item.CONSIGNEE_TPNO_1__c;
        backIF.ORIGINAL_REQUEST_NO__c = '';//AS-IS는 값 없음
        backIF.ORIGINAL_REQUEST_SEQ__c = 0;//AS-IS는 값 없음
        backIF.CANCEL_FLAG__c = '';// Ex_CarePlustOrder 77번째줄 참조
        backIF.CANCEL_DATE__c = null;//

        //23 08 25 hyungho.chun ProductRequest__c 비어있음
        // backIF.ORDER_DESCRIPTION__c = item.ProductRequest__r.Description;
        // backIF.ORDER_DESCRIPTION__c = item.ReturnOrder.ProductRequest.Description;
        backIF.ORDER_DESCRIPTION__c = item.Parent.Description;

        backIF.BACK_IF_STATUS__c = backStatus;
        backIF.BACK_IF_ERROR_DESC__c = '';// BILLTOCODE 체크안해서 없음
        backIF.TRANSFER_FLAG__c = 'N';

        backIF.ATTRIBUTE10__c = completeLineId != null ? completeLineId : null;
        backIF.ATTRIBUTE5__c = item.SALE_Number__c != null ? item.SALE_Number__c : null;
        backIF.ATTRIBUTE8__c = item.Parent.CAREPLUS_Order_Requester_Class_Code__c != null ? item.Parent.CAREPLUS_Order_Requester_Class_Code__c : null;

        rtnInfoMap.put('backIF', backIF);
        rtnInfoMap.put('maxNum', maxNum);
        rtnInfoMap.put('maxSubnum', maxSubnum);
        system.debug('rtnInfoMap : '+rtnInfoMap);
        return rtnInfoMap;
    }

    //24 02 24 hyungho.chun si_transaction 생성 메소드 ( 기존 : 케어플러스주문때만 생성 ->  변경 : 모든주문 판매확정과 반품확정때 si_transaciton 생성)
    public static void insertSiTransaction(List<SObject> inputList, List<String> salesFailOrderNumberList, List<SR_ONLINE_AUTO_SALE_EXC__c> failRecordList){

        Set<String> carePlusOrderNumSet = new Set<String>();
        List<ProductRequestLineItem> prLiList = new List<ProductRequestLineItem>();
        List<ReturnOrderlineItem> roLiList = new List<ReturnOrderlineItem>();
        //24 02 28 hyungho.chun 반품건 판매번호별 존재하는seq 조회용도
        List<String> roSaleNum = new List<String>();

        List<SI_CAREPLUS_BACKIF__c> backIFList = new List<SI_CAREPLUS_BACKIF__c>();

        for (SObject item : inputList) {
            if (item.get('RecordTypeId') == PRLI_CONSUMABLE_RECORDTYPE_ID || item.get('RecordTypeId') == PRLI_CARE_SUPPLIES_RECORDTYPE_ID) {
                prLiList.add((ProductRequestLineItem)item);
            }else if (item.get('RecordTypeId') == ROLI_CONSUMABLE_RECORDTYPE_ID || item.get('RecordTypeId') == ROLI_CARE_SUPPLIES_RECORDTYPE_ID){
                roLiList.add((ReturnOrderlineItem)item);
                roSaleNum.add(((ReturnOrderlineItem)item).ProductRequestLineItem.SALE_Number__c.replace('A','R'));
            }else{
                System.debug('잘못된 list를 param으로 받았음');
            }
            carePlusOrderNumSet.add(String.valueOf(item.get('Order_Number__c')));
        }

        if (!inputList.isEmpty() && (!prLiList.isEmpty() || !roLiList.isEmpty()) ){
            //23 09 13 hyungho.chun order_number기준으로 careplus_complete.LINE_ID__c 찾아서 si_transaction attribute 4번에 넣어주는용도
            List<SI_CAREPLUS_ORDER_COMPLETE__c> carePlusComList = new List<SI_CAREPLUS_ORDER_COMPLETE__c>();
            Map<String, String> orderNumAndLineId = new Map<String, String>();
            if(carePlusOrderNumSet.size()>0){
                carePlusComList = [SELECT Id, CUST_PO_NO__c, LINE_ID__c FROM SI_CAREPLUS_ORDER_COMPLETE__c WHERE CUST_PO_NO__c IN: carePlusOrderNumSet AND LINE_ID__c != null];
                if(!carePlusComList.isEmpty()){
                    for(SI_CAREPLUS_ORDER_COMPLETE__c item : carePlusComList){
                        orderNumAndLineId.put(item.CUST_PO_NO__c,  String.valueOf(item.LINE_ID__c));
                    } 
                }      
            }
            
           
            List<SI_TRANSACTION__c> insertSiTList = new List<SI_TRANSACTION__c>();

            //24 02 24  이후 hyungho.chun auto number 자동채번으로 따로 지정하지않음
            // List<SI_TRANSACTION__c> siTListForMaxList = new List<SI_TRANSACTION__c>();
            // Integer maxTransactionId = 1;
            // siTListForMaxList = [SELECT Id, TRANSACTION_ID__c FROM SI_TRANSACTION__c WHERE TRANSACTION_ID__c != null ORDER BY TRANSACTION_ID__c DESC LIMIT 1];
            // if (!siTListForMaxList.isEmpty()) {
            //     maxTransactionId = Integer.valueOf(siTListForMaxList[0].TRANSACTION_ID__c);
            // }
            // Integer loopCnt = 1;
            
            //24 02 24 hyungho.chun prli경우
            if(!prLiList.isEmpty()){
                Map<String, Decimal> seqMap = new Map<String,Decimal>();     

                for (ProductRequestLineItem cpPrli : prLiList) {
                    //24 02 28 hyungho.chun si_transaction seq__c 판매번호 기준으로 순서대로 채번
                    if (!seqMap.containsKey(cpPrli.Sale_number__c)) { 
                        seqMap.put(cpPrli.Sale_number__c, 1);
                    }else {
                        seqMap.put(cpPrli.Sale_number__c, seqMap.get(cpPrli.Sale_number__c) + 1);
                    }  

                    SI_TRANSACTION__c siT = new SI_TRANSACTION__c();
                    // siT.TRANSACTION_ID__c = maxTransactionId + loopCnt; //572421 seq //24 02 24  이후 hyungho.chun auto number 자동채번으로 따로 지정하지않음
                    
                    siT.REQUEST_NUMBER__c = cpPrli.Sale_number__c; 
                    // siT.SEQ__c = cpPrli.Order_SEQ__c != null ? cpPrli.Order_SEQ__c : 0; 
                    siT.SEQ__c = seqMap.get(cpPrli.Sale_number__c); //24 02 28 hyungho.chun 판배번호별 순서대로 채번
                    siT.SUB_SEQ__c = cpPrli.SUB_Order_SEQ__c != null ? cpPrli.SUB_Order_SEQ__c : 0; //24 02 24 hyungho.chun 현재까진 다 0으로넣고있음
                    siT.SOURCE_CODE__c = 'C'; //DECODE(A.DEPT_TYPE,'E', 'C', 'P') 
                    // siT.TRX_CODE__c = cpPrli.RecordTypeId == PRLI_CARE_SUPPLIES_RECORDTYPE_ID ? 'CARE_STD' : cpPrli.PAYMENT_Amount__c == 0 ? 'SERVICE_DC' : 'SELL_STD'; //24 02 24 hyungho.chun (PAYMENT_Amount__c ==0)100%vip경우 SERVICE_DC
                    siT.TRX_CODE__c = cpPrli.RecordTypeId == PRLI_CARE_SUPPLIES_RECORDTYPE_ID ? 'CARE_STD' : ((cpPrli.PAYMENT_Amount__c == 0 && cpPrli.Consumables_Business_Type_Code__c == 'Order' ) ? 'SERVICE_DC' : 'SELL_STD'); //24 03 22 hyungho.chun 교환주문도 payment_amount 가 0이라 추가로 order인지까지 확인
                    siT.STATUS_CODE__c = 'N';
                    siT.LGC_CODE__c = cpPrli.RecordTypeId == PRLI_CARE_SUPPLIES_RECORDTYPE_ID ? EX_ConsumableUtil.PH0300 : EX_ConsumableUtil.PH8002; 
                    siT.LGP_CODE__c = cpPrli.RecordTypeId == PRLI_CARE_SUPPLIES_RECORDTYPE_ID ? EX_ConsumableUtil.PH0300 : EX_ConsumableUtil.PH8002; 
                    siT.OBU_CODE__c = cpPrli.Product2.DIV_CODE__c; //${divCode}
                    siT.TRX_DATE__c = Date.today();
                    siT.ITEM_CODE__c = cpPrli.PART_NO__c; //partNo
                    siT.UOM__c = 'EA';
                    siT.TRX_QTY__c = cpPrli.QuantityRequested;
                    // siT.TRX_PRICE_1__c = cpPrli.SALE_Amount__c; 
                    // siT.TRX_PRICE_1__c = cpPrli.PAYMENT_Amount__c / cpPrli.QuantityRequested; //24 02 24 hyungho.chun 실제로 개수당 지불한 가격 
                    siT.TRX_PRICE_1__c = cpPrli.Consumables_Business_Type_Code__c == 'Order' ? (cpPrli.PAYMENT_Amount__c / cpPrli.QuantityRequested) : (cpPrli.BASIS_Order_Item_Id__r.Payment_Amount__c / cpPrli.BASIS_Order_Item_Id__r.QuantityRequested); //24 03 22 hyungho.chun 교환주문의 경우 payment_amount 가 0이라서 원주문에서 결제금액 가지고와서 개당 금액을 계산한다
                    //siT.TRX_PRICE_2__c;
                    siT.TRANS_FLAG__c = 'N';
                    siT.ATTRIBUTE1__c = cpPrli.RecordTypeId == PRLI_CARE_SUPPLIES_RECORDTYPE_ID ? 'CAREPLUS' : null;
                    siT.ATTRIBUTE2__c = cpPrli.RecordTypeId == PRLI_CARE_SUPPLIES_RECORDTYPE_ID ? cpPrli.Order_Number__c : null; //P10000388775
                    siT.ATTRIBUTE3__c = cpPrli.RecordTypeId == PRLI_CARE_SUPPLIES_RECORDTYPE_ID ? '1' : null;
    
                    // 23 09 13 hyungho.chun order_number기준으로 careplus_complete.LINE_ID__c 찾아서 넣어줌
                    if(orderNumAndLineId.containsKey(cpPrli.Order_Number__c)){
                        siT.ATTRIBUTE4__c = orderNumAndLineId.get(cpPrli.Order_Number__c);
                    }
                    
                    siT.External_id__c = siT.REQUEST_NUMBER__c+'_'+siT.SEQ__c+'_'+siT.SUB_SEQ__c+'_'+siT.LGP_CODE__c;

                    if (String.isNotEmpty(siT.REQUEST_NUMBER__c)) {
                        insertSiTList.add(siT);
                    }
                    // loopCnt++; //24 02 24  이후 hyungho.chun auto number 자동채번으로 따로 지정하지않음
                }                
            }

           //24 02 24 hyungho.chun roli 경우
            if (!roLiList.isEmpty()) {
                //24 02 28 hyungho.chun 부분반품 여러번 대비 판매번호별 가장높은 seq값 찾음(채번용도)
                List<SI_TRANSACTION__c> siTListForMaxList = new List<SI_TRANSACTION__c>();
                siTListForMaxList = [SELECT Id, REQUEST_NUMBER__c, SEQ__c FROM SI_TRANSACTION__c WHERE SEQ__c != null AND REQUEST_NUMBER__c IN: roSaleNum ORDER BY SEQ__c DESC];

                Map<String, Decimal> seqMap = new Map<String,Decimal>();
                if (!siTListForMaxList.isEmpty()) {
                    for(SI_TRANSACTION__c item : siTListForMaxList){
                        if(!seqMap.containsKey(item.REQUEST_NUMBER__c)){ //24 02 28 hyungo.chun seq 높은순 정렬이라 하나만찾아서 넣으면 그 이후로 맵에 넣지않음(request_num , 가장높은 seq)
                            seqMap.put(item.REQUEST_NUMBER__c,item.SEQ__c+1);
                        }
                    }
                }


                for (ReturnOrderLineItem cpRoli : roLiList) {
                    SI_TRANSACTION__c siT = new SI_TRANSACTION__c();

                    siT.REQUEST_NUMBER__c = cpRoli.ProductRequestLineItem.SALE_Number__c.replace('A','R'); //A010004542

                    siT.SOURCE_CODE__c = 'C'; //DECODE(A.DEPT_TYPE,'E', 'C', 'P') 
                    siT.TRX_CODE__c = cpRoli.RecordTypeId == ROLI_CARE_SUPPLIES_RECORDTYPE_ID ? 'CARE_RED' : 'SELL_RED';



                    // siT.SEQ__c = cpRoli.Order_SEQ__c != null ? cpRoli.Order_SEQ__c : 0; 
                    //24 02 28 hyungho.chun si_transaction seq 채번로직 수정
                    if(seqMap.containsKey(siT.REQUEST_NUMBER__c)){
                        siT.SEQ__c = seqMap.get(siT.REQUEST_NUMBER__c);
                        seqMap.put(siT.REQUEST_NUMBER__c,siT.SEQ__c + 1);
                    }else{
                        siT.SEQ__c = 1;
                        seqMap.put(siT.REQUEST_NUMBER__c,siT.SEQ__c + 1);
                    }
                    


                    siT.SUB_SEQ__c = cpRoli.Order_SUB_SEQ__c != null ? cpRoli.Order_SUB_SEQ__c : 0;
                    
                    siT.STATUS_CODE__c = 'N';
                    siT.LGC_CODE__c = cpRoli.RecordTypeId == ROLI_CARE_SUPPLIES_RECORDTYPE_ID ? EX_ConsumableUtil.PH0300 : EX_ConsumableUtil.PH8002;
                    siT.LGP_CODE__c = cpRoli.RecordTypeId == ROLI_CARE_SUPPLIES_RECORDTYPE_ID ? EX_ConsumableUtil.PH0300 : EX_ConsumableUtil.PH8002;
                    //siT.TRANS_LGC_CODE__c; //( SELECT GERP_CODE FROM SM_DEPT WHERE DEPT_CODE = ( SELECT DECODE( DEPT_TYPE, 'H', HIGH_DEPT_CODE, 'G', HIGH_DEPT_CODE, 'I',HIGH_DEPT_CODE,'J',HIGH_DEPT_CODE, DEPT_CODE ) FROM SM_DEPT WHERE DEPT_CODE = ${ordDeptCode}))
                    //siT.TRANS_LGP_CODE__c; //(SELECT GERP_CODE FROM SM_DEPT WHERE DEPT_CODE = ${ordDeptCode} )
                    siT.OBU_CODE__c = cpRoli.Product2.DIV_CODE__c; //${divCode}
                    siT.TRX_DATE__c = Date.today();
                    siT.ITEM_CODE__c = cpRoli.Parts_Number__c; //partNo
                    siT.UOM__c = 'EA';
                    siT.TRX_QTY__c = cpRoli.QuantityReturned;
                    //siT.TRX_PRICE_1__c;
                    //siT.TRX_PRICE_2__c;
                    siT.TRANS_FLAG__c = 'N';
                    siT.ATTRIBUTE1__c = cpRoli.RecordTypeId == ROLI_CARE_SUPPLIES_RECORDTYPE_ID ? 'CAREPLUS' : String.valueOf(cpRoli.ProductRequestLineItem.SR_SALE__r.SALE_DTM__c);
                    siT.ATTRIBUTE2__c = cpRoli.RecordTypeId == ROLI_CARE_SUPPLIES_RECORDTYPE_ID ? cpRoli.ProductRequestLineItem.Order_Number__c : null; //P10000388775
                    siT.ATTRIBUTE3__c = cpRoli.RecordTypeId == ROLI_CARE_SUPPLIES_RECORDTYPE_ID ? '1' : null;
                    if(orderNumAndLineId.containsKey(cpRoli.ProductRequestLineItem.Order_Number__c)){
                        siT.ATTRIBUTE4__c = orderNumAndLineId.get(cpRoli.ProductRequestLineItem.Order_Number__c);
                    }   

                    siT.External_id__c = siT.REQUEST_NUMBER__c+'_'+siT.SEQ__c+'_'+siT.SUB_SEQ__c+'_'+siT.LGP_CODE__c;

                    if (String.isNotEmpty(siT.REQUEST_NUMBER__c)) {
                        insertSiTList.add(siT);
                    }

                }
            }

            if (!insertSiTList.isEmpty()) {
                failRecordList.addAll(checkFail(insertSiTList,
                        salesFailOrderNumberList,
                        'SI_Transaction 생성 실패, '));
            }
            System.debug('SI_TRANSACTION__c 생성 후 failRecordList : ' + failRecordList);
            System.debug('SI_TRANSACTION__c 생성 후 salesFailOrderNumberList : ' + salesFailOrderNumberList);

            //23 11 30 hyungho.chun 판매확정 'SHIPPED' back IF 생성
            System.debug('판매확정 Back IF 생성 시작');
            Decimal maxNum = 0;
            List<SI_CAREPLUS_BACKIF__c> getMaxList = new List<SI_CAREPLUS_BACKIF__c>();
            getMaxList = [
                    SELECT INTERFACE_ID__c
                    FROM SI_CAREPLUS_BACKIF__c
                    ORDER BY INTERFACE_ID__c DESC
                    LIMIT 1
            ];
            if(!getMaxList.isEmpty()){
                SI_CAREPLUS_BACKIF__c getMax = getMaxList[0];
                if(getMax.INTERFACE_ID__c != null && getMax.INTERFACE_ID__c > 0){
                    maxNum = getMax.INTERFACE_ID__c + 1;
                }
            }

            Decimal maxSubNum = 1;
            
            for (ProductRequestLineItem cpPrli : prLiList) {
                if(cpPrli.RecordTypeId == PRLI_CARE_SUPPLIES_RECORDTYPE_ID){ //24 02 24 hyungho.chun 'RETRURNED'인 경우 반품확정 때 미리 만들기때매 prli 케어플러스만 고려
                    String completeLineId = orderNumAndLineId.containsKey(cpPrli.Order_Number__c) ? orderNumAndLineId.get(cpPrli.Order_Number__c) : null;
                    Map<String, Object> ifDataInfoMap = setCarePlusBackIFData(cpPrli, completeLineId, maxNum, maxSubNum,'SHIPPED');
                    SI_CAREPLUS_BACKIF__c backIF = (SI_CAREPLUS_BACKIF__c) ifDataInfoMap.get('backIF');
                    maxNum = (Decimal) ifDataInfoMap.get('maxNum');
                    maxSubNum = (Decimal) ifDataInfoMap.get('maxSubnum');
                    backIFList.add(backIF);
                }
            }

            if (!backIFList.isEmpty()) {
                failRecordList.addAll(EX_ConsumableUtil.checkFail(backIFList,
                        salesFailOrderNumberList,
                        'SI_CAREPLUS_BACKIF__c 생성 실패, '));
            }
        }
    }    

}