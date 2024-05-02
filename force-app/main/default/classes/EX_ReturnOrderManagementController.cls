/**
 * Created by I2MAX.JAEYEONLEE on 2023-01-25.
 */

public with sharing class EX_ReturnOrderManagementController {
    @AuraEnabled
    public static Map<String, Object> doSendKakaoMessage() {
        Map<String, Object> data = null;
        return data;
    }
    @AuraEnabled
    public static Map<String, Object> doGetInitData() {
        try {
            system.debug('doGetInitData');
            Map<String, Map<String, Object>> mapSettingValue = new Map<String, Map<String, Object>>();

            Map<String, List<Map<String, String>>> mapCommPickLists = new Map<String, List<Map<String, String>>>();
            // 소모품 주문 상태 코드
            //List<Map<String, String>> listOrderStatusCode = SObjectUtil.getPicklist('ReturnOrderLineItem', 'Consumables_Order_Status_Code__c', false);
            List<Map<String, String>> listOrderStatusCode = EX_ConsumableUtil.getExOrderStatusList('ReturnOrderLineItem', 'Return');

            mapCommPickLists.put('listOrderStatusCode', listOrderStatusCode);
            system.debug('listOrderStatusCode :: ' + listOrderStatusCode);

            // 주문 채널
            List<Map<String, String>> listOrderChannel = SObjectUtil.getPicklist('ReturnOrderLineItem', 'Order_CHNL_TYPE_Code__c', false);
//            for (Map<String, String> orderChannel : listOrderChannel) {
//                for (String orderChannelKey : orderChannel.keySet()) {
//                    if (orderChannel.get(orderChannelKey) == EX_ConsumableUtil.CONSUMABLE_BESTSHOP) {
//                        orderChannel.remove(orderChannelKey);
//                    }
//                }
//            }

//            for (Integer i = 0; i < listOrderChannel.size(); i++) {
//                if (listOrderChannel[i].isEmpty()) {
//                    listOrderChannel.remove(i);
//                }
//            }

            mapCommPickLists.put('listOrderChannel', listOrderChannel);
            system.debug('listOrderChannel :: ' + listOrderChannel);

            // 상담 부서
            List<SM_DEPT__c> listConsultantCenter = new List<SM_DEPT__c>();

            listConsultantCenter = [
                    SELECT Id
                            , Name
                            , DEPT_CODE__c
                    FROM SM_DEPT__c
                    WHERE CLOSE_YN__c != 'Y'
                    AND DEPT_TYPE_SECOND__c = 'D'
                    ORDER BY DEPT_TYPE_FIRST__c DESC
                            , DEPT_TYPE_SECOND__c DESC
                            , DEPT_NAME__c ASC
            ];

            system.debug('listCenter :: ' + listConsultantCenter);

            List<Map<String, String>> listMapCenter = new List<Map<String, String>>();
            for (SM_DEPT__c obj : listConsultantCenter) {
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

            //지은 추가
            System.debug('MapReturn :: ' + mapReturn);
            System.debug('mapSettingValue :: ' + mapSettingValue);

            return mapReturn;

        } catch (Exception e) {
            System.debug(e.getLineNumber() + 'Line || ' + e.getMessage());
            throw new AuraHandledException(e.getLineNumber() + 'Line || ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Map<String, Object> doGetSearchData(Map<String, Object> mapSearchParam, Boolean collectionYN) {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<ReturnOrderLineItem> returnList = new List<ReturnOrderLineItem>();

        Integer recordCount = 0;
        Decimal recordLimit = (Decimal) mapSearchParam.get('recordLimit');
        Decimal pageOffset = (Decimal) mapSearchParam.get('pageOffset');
        Boolean isSearchBtnClick = (Boolean) mapSearchParam.get('isSearchBtnClick');

        String query = 'SELECT Return_Order_Request_DTM__c,';
        query += 'RecordType.DeveloperName,';
        query += 'ProductRequestLineItemId,';
        query += 'Order_Number__c,';
        query += 'SUB_Order_Number__c, ';//반품내역에서 주문sub번호 조회할때 사용
        query += 'createdDate,  ';
        //23 09 19 hyungho.chun 마스킹처리 기준 변경
        query += 'LastModifiedDate, ReturnOrder.fm_ReturnIsMaskingTarget__c, ';
        query += 'Order_CHNL_TYPE_Code__c,';
        query += 'CONSIGNEE_Name__c,';
        query += 'ENDP_Code__c,';
        query += 'Parts_Number__c,';
        query += 'ProductRequestLineItem.MODEL__r.Name , ';
        query += 'Product2.PART_DESC_KOR__c ,';
        query += 'QuantityReturned,';
        query += 'FFMT_Order_Number__c,'; //CJ반품 주문번호가 맞는지 일단 풀필먼트 주문번호
        query += ' FFMT_Order_Transfer_YN__c, ';//풀필먼트주문전송여부
        query += 'FFMT_Transfer_DTM__c,';
        query += 'COLLECTION_YN__c,';
        query += 'CONFIRM_Date__c,';
        query += 'CONFIRM_YN__c,';
        query += 'CONFIRM_Reason__c,';
        //query += 'ProductRequestLineItem.PAYMENT_DTM__c,';
        query += 'Return_Requester_Reason__c,';
        query += 'SHIPPED_Date__c,';
        query += 'ProductRequestLineItem.SALE_Number__c,';
        query += 'ProductRequestLineItem.SALE_DTM__c,';
        query += 'ProductRequestLineItem.SALE_SEQ__c,';
        query += 'Order_SEQ__c, ';
        query += 'INVOICE_Number__c, ';
        query += 'INVOICE_COUNT__c,  ';
        //query += 'Consumables_Order_Status_Code__c, ';
        query += 'toLabel(Consumables_Order_Status__c), ';
        query += 'ProductRequestLineItem.PAYMENT_Amount__c,';
        query += 'ProductRequestLineItem.CASH_PAYMENT_Amount__c,';
        query += 'ProductRequestLineItem.CARD_PAYMENT_Amount__c,';
        query += 'ProductRequestLineItem.POINT_Amount__c,';
        query += 'ProductRequestLineItem.SALE_Amount__c,';
        query += 'ProductRequestLineItem.BASIS_Parts__c,';
        query += 'ProductRequestLineItem.Order_CUST_Id__r.Name, ';
        query += 'DISPOSAL_Quantity__c, '; //폐기수량
        query += 'DISPOSAL_Reason__c,  '; //폐기사유
        query += 'Good_Quality_Quantity__c, '; //양품수량
        query += 'Return_Order_CONFIRM_DTM__c, '; //반품확정일시
        query += 'Return_DESCISION_COMPLETED_YN__c, '; //반품판정완료여부
        query += 'Return_DESCISION_COMPLETED_DTM__c,   '; //반품판정완료일시
        query += 'ReturnOrderId, ';
        query += 'Id, ';

        //바인딩 작업후 추가

        query += 'Product2.CAREPLUS_MODEL_CODE__c, ';
        query += 'Product2.Description, ';
        query += 'Return_SALE_Amount__c,  ';
        query += 'Return_Request_Status__c, ';
        query += 'ProductRequestLineItem.Parent.PAYMENT_COMPLETED_DTM__c, ';
        query += 'ProductRequestLineItem.SHIP_DTM__c, ';
        query += 'ProductRequestLineItem.DELIVERY_STATUS_CODE__c, ';
        query += 'ProductRequestLineItem.Delivery_DTM__c, ';
        query += 'ProductRequestLineItem.Order_SEQ__c,  ';
        query += 'RETURN_PAYMENT_Amount__c, ';
        query += 'RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c, ';
        query += 'RETURN_CARD_PAYMENT_Amount__c, ';
        query += 'RETURN_POINT_Amount__c, ';
        query += 'COLLECTION_Date__c, ';
        query += 'Product2.PART_DESC__c, ';
        //23 08 30 hyungho.chun
        query += 'returnOrder.RETURN_SALE_Amount__c, ';

        //폐기 Record 만들기 위해 query추가
//        query += ' Department_Code__c, ';//부서코드
//        query += ' DISPOSAL_Type__c, '; //폐기유형
//        query += ' DISPOSAL_CONFIRM_Type__c, ';//폐기확정유형
//        query += ' DISPOSAL_Created_Type__c, ';//폐기등록유형
//        query += ' Consumables_Order_YN__c, ';//소모품주문여부
//        query += ' Order_CUST_Info_SAME_YN__c, '; //주문고객정보동일여부
//        query += ' FAIR_PRD_DISPOSAL_TYPE_Code__c, ';//양품폐기구분코드
//        query += ' REFUND_Request_YN__c, ';//환불요청여부
//        query += ' HAND_WORK_YN__c, ';//수작업여부
//        query += ' Request_SEQ__c, ';//요청순번
//        query += ' BASIS_Number__c, '; //근거번호
//        query += ' BASIS_SEQ__c, ';//근거순번
//        query += ' CANCEL_LOST_Reason__c, ';//취소/분실사유
//        query += ' APPR_GRD__c, ';//결재등급
//        query += ' adjust_return_type__c, ';//판정
//        query += ' ProductItemId, ';//재고 ID
//        query += ' Product2Id, ';//제품 id
//        query += ' ReasonForReturn, ';//반품 이유
//        query += ' ProcessingPlan, ';//처리 계획
//        query += ' RepaymentMethod,  ';//재결제 방법
//        query += ' DestinationLocationId, '; //폐기 레코드를 생성할때 SourceLocationId에 매핑
//        query += ' DISPOSAL_SM_DEPT_Id__c,  '; //조직코드 ID
//        query += ' LOCATED_PLACE_Number__c, '; //적치장소번호

        query += ' CONSUMABLES_ERROR__c, ';//소모품오류

        //배송지수정을 위해 고객정보를 들고옴
        query += ' Order_CUST_Id__c, ';//주문고객ID
        query += ' Order_CUST_ID__r.Name, Order_CUST_Id__r.MobilePhone, ';//주문고객 이름, 주문고객 핸드폰번호
        query += ' CONSIGNEE_TPNO__c, '; // 수취인 전화번호
        query += ' CONSIGNEE_PostalCode__c, '; //수취인우편번호
        query += ' CONSIGNEE_Address__c, CONSIGNEE_Address_DETAIL__c, '; //수취인주소, 수취인상세주소
        query += ' Order_CUST_Id__r.B2B_Customer_YN__c, '; //B2B(기업고객) 여부
        query += ' ProductRequest__r.SR_SALE__c, ';//원주문의 판매저장오류건 체크
        query += ' ReturnOrder.Delivery_Message_CONTENT__c, ';//배송매세지
        

        query += ' Consumables_Business_Type_Code__c, ';

        //고객명
        //암호화된 고객명
        query += ' ReturnOrder.fm_ENC_Order_CUST_Name__c,  ';
        //수취인

        //암호화된 수취인
        query += ' ReturnOrder.fm_ENC_CONSIGNEE_Name__c,  ';

        query += ' ReturnOrder.CONSIGNEE_Name__c, ';
        query += ' ReturnOrder.CONSIGNEE_TPNO_1__c, ';
        query += ' ReturnOrder.CONSIGNEE_PostalCode__c, ';
        query += ' ReturnOrder.CONSIGNEE_Address__c, ';
        query += ' ReturnOrder.CONSIGNEE_Address_DETAIL__c, ';

        query += ' ReturnOrder.ContactId, ';
        query += ' ReturnOrder.Order_CUST_Name__c, ';
        query += ' ReturnOrder.Order_CUST_TPNO_1__c, ';

        //암호화 조건
        query += ' ProductRequestLineItem.Consumables_Order_Status__c ';

        ////////결제 일시 ProductRequestLineItemId 로 쿼리해서 결제금액,결제유형,현금,카드,포인트  결제 유형은 보류

        //23.09.01 PHJ
        query += ', CONFIRM_User_Id__c ';

        query += 'FROM ReturnOrderLineItem ';


        String whereQuery = ' ';
        whereQuery += ' WHERE RecordType.DeveloperName IN (\'Consumable\', \'CareSupplies\') ';

        System.debug(query + whereQuery);
        //주문번호 또는 CJ주문번호가 있을땐 다른 조건 무시하고 우선 적용
        //23.05.05 주문상태에 ALL 다시 추가. 주문번호/CJ반품번호 조회조건 = 번호 + 주문상태

        if (mapSearchParam.get('orderNo') != null && mapSearchParam.get('orderNo') != '') {
            whereQuery += ' AND Order_Number__c = \'' + mapSearchParam.get('orderNo') + '\'';
//            whereQuery += ' AND Consumables_Order_Status__c = \'' + mapSearchParam.get('orderStatus') + '\'';
        } else if (mapSearchParam.get('CJorderNo') != null && mapSearchParam.get('CJorderNo') != '') {
            whereQuery += ' AND FFMT_Order_Number__c = \'' + mapSearchParam.get('CJorderNo') + '\'';
//            whereQuery += ' AND Consumables_Order_Status__c = \'' + mapSearchParam.get('orderStatus') + '\'';
        } else {

            //주문채널
            if (mapSearchParam.get('orderChannel') != null && mapSearchParam.get('orderChannel') != 'ALL') {
                whereQuery += ' AND Order_CHNL_TYPE_Code__c = \'' + mapSearchParam.get('orderChannel') + '\'';
            }
            //반품상태
            if (mapSearchParam.get('orderStatus') != null && mapSearchParam.get('orderStatus') != 'ALL') {
                whereQuery += ' AND Consumables_Order_Status__c = \'' + mapSearchParam.get('orderStatus') + '\'';
            }

            //반품상태에서 ALL이 없을때는 반품예약을 디폴트벨류로 설정
//            if(mapSearchParam.get('orderStatus')==null || mapSearchParam.get('orderStatus').toString().equals('')){
//                whereQuery += ' AND Consumables_Order_Status__c = \'' + EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_101 + '\'';
//                System.debug('반품상태 null 로 들어옴');
//
//            }
//            //if(!mapSearchParam.get('orderStatus').toString().equals('')){
//            else{
//                whereQuery += ' AND Consumables_Order_Status__c = \'' + mapSearchParam.get('orderStatus') + '\'';
//            }

            //주문번호
            if (mapSearchParam.get('orderNo') != null && !mapSearchParam.get('orderNo').equals('')) {
                whereQuery += ' AND Order_Number__c = \'' + mapSearchParam.get('orderNo') + '\'';
            }

            //반품요청일자
            if (mapSearchParam.get('baseDateStart') != null && mapSearchParam.get('baseDateEnd') != null
                    && mapSearchParam.get('baseDateStart') != '' && mapSearchParam.get('baseDateEnd') != '') {
                // 소모품 주문 시작 기준 일자
                //whereQuery += ' AND DAY_ONLY(convertTimezone(CreatedDate)) >= ' + mapSearchParam.get('baseDateStart');
                // 소모품 주문 종료 기준 일자
                //whereQuery += ' AND DAY_ONLY(convertTimezone(CreatedDate)) <= ' + mapSearchParam.get('baseDateEnd');
                // 소모품 주문 시작 기준 일자
                whereQuery += ' AND DAY_ONLY(convertTimezone(Return_Order_Request_DTM__c)) >= ' + mapSearchParam.get('baseDateStart');
                // 소모품 주문 종료 기준 일자
                whereQuery += ' AND DAY_ONLY(convertTimezone(Return_Order_Request_DTM__c)) <= ' + mapSearchParam.get('baseDateEnd');
            }
            //주문고객명
            system.debug('contactName :: '+ mapSearchParam.get('contactName'));
            if (mapSearchParam.get('contactName') != null && !mapSearchParam.get('contactName').equals('')) {
                //23 08 19 hyungho.chun returnOrder의 고객명쿼리
                whereQuery += ' AND ReturnOrder.CONSIGNEE_Name__c LIKE \'%' + mapSearchParam.get('contactName') + '%\'';
            }
            //주문고객 전화번호
            if (mapSearchParam.get('contactPhone') != null && !mapSearchParam.get('contactPhone').equals('')) {
                // whereQuery += ' AND CONSIGNEE_TPNO__c = \'' + mapSearchParam.get('contactPhone') + '\'';
                //23 08 21 hyungho.chun returnOrder의 번호로 검색
                whereQuery += ' AND ReturnOrder.CONSIGNEE_TPNO_1__c = \'' + mapSearchParam.get('contactPhone') + '\'';
                
            }

            //CJ 주문번호
            if (mapSearchParam.get('CJorderNo') != null && !mapSearchParam.get('CJorderNo').equals('')) {
                whereQuery += ' AND FFMT_Order_Number__c = \'' + mapSearchParam.get('CJorderNo') + '\'';
            }

            //수거여부

            if (collectionYN != null) {
                System.debug('collectionYN : ' + collectionYN);
                if (collectionYN != null && collectionYN == true) {
                    whereQuery += ' AND COLLECTION_YN__c = :collectionYN ';

                }
            }

            if (mapSearchParam.get('partNo') != null && mapSearchParam.get('partNo') != '') {
                // 소모품 반품 파트 넘버
                String partNo = (String) mapSearchParam.get('partNo');
                whereQuery += ' AND ProductRequestLineItem.fm_PART_NO__c LIKE \'' + '%' + partNo + '%' + '\'';

            }

        }
        query += whereQuery;

        query += 'ORDER BY  Return_Order_Request_DTM__c DESC ';

        // Pagination
//        query += ' LIMIT ' + recordLimit + ' OFFSET ' + (pageOffset * recordLimit);

        //23.09.07 PHJ 굳이 class에서 카운트 할 필요 없음
        // if (isSearchBtnClick) {
        //     recordCount = Database.countQuery('SELECT COUNT() FROM ReturnOrderLineItem' + whereQuery);
        //     returnMap.put('totalRecord', recordCount);
        // } else {
        //     returnMap.put('totalRecord', null);
        // }

        returnList = Database.query(query);
        System.debug('returnList :: ' + returnList + '  , ' + returnList.size() + '건');

        // if (!returnList.isEmpty()) {

        //     returnList[0].ReturnOrder.Order_CUST_Name__c = returnList[0].ReturnOrder.fm_ENC_Order_CUST_Name__c;

        // }

//        System.debug('returnList[0].ReturnOrder.Order_CUST_Name__c :::' + returnList[0].ReturnOrder.Order_CUST_Name__c);


        List<ReturnItemTable> returnItemList = new List<ReturnItemTable>();
        Set<Id> requestLineItemIdList = new Set<Id>();
        
        // 24 01 30 PHJ
        Set<String> confirmEmpIds = new Set<String>();
        Map<String, String> confirmEmpMap = new Map<String, String>();
        for(ReturnOrderLineItem returnOrder : returnList){
            if(returnOrder.CONFIRM_User_Id__c != null){
                confirmEmpIds.add(returnOrder.CONFIRM_User_Id__c);
            }
        }
        List<User> uList = [SELECT Name, EmployeeNumber__c FROM User WHERE EmployeeNumber__c =: confirmEmpIds];
        if(!uList.isEmpty()){
            for(User u : uList){
                confirmEmpMap.put(u.EmployeeNumber__c, u.Name);
            }
        }

        for (ReturnOrderLineItem returnOrder : returnList) {
            //String collectionYN = 'N';
            String payment_Type = '';
            if (returnOrder.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c > 0) {
                payment_Type = '현금';
                if (returnOrder.RETURN_POINT_Amount__c > 0) {
                    payment_Type += '+포인트';
                }
            } else if (returnOrder.RETURN_CARD_PAYMENT_Amount__c > 0) {
                payment_Type = '카드';
                if (returnOrder.RETURN_POINT_Amount__c > 0) {
                    payment_Type += '+포인트';
                }
            } else if (returnOrder.RETURN_POINT_Amount__c > 0) {
                payment_Type = '포인트';
            }

            // 24 01 30 PHJ
            String confirmEmpId = '';
            if(!confirmEmpMap.isEmpty()){
                if (confirmEmpMap.get(returnOrder.CONFIRM_User_Id__c) != null) confirmEmpId = confirmEmpMap.get(returnOrder.CONFIRM_User_Id__c);
                else confirmEmpId = '';
            }


            ReturnItemTable returnItem;
            // if (returnOrder.SUB_Order_Number__c != null) {
            if (returnOrder.SUB_Order_Number__c != null && returnOrder.Consumables_Order_Status__c != '반품반려') {    //24 01 26 hyungho.chun '반품반려'는 화면에 보이지 않게 수정 (조회쿼리에서 toLabel이라 110이아닌 '반품반려' 로 비교)
                returnItem = new ReturnItemTable(returnOrder, payment_Type, confirmEmpId); // 24 01 30 PHJ
                returnItemList.add(returnItem);
            }

            // returnItemList.add(returnItem);

        }

        

        returnMap.put('returnOrderLineItems', returnItemList);
        System.debug('returnItemList =>' + returnItemList);

        return returnMap;
    }

    @AuraEnabled
    public static Boolean moreLoadValid(Integer dataLength, Integer recordLimit, Integer totalRecord) {
        Integer nextDataLength = dataLength + recordLimit;
        System.debug('nextDataLength : ' + nextDataLength);
        if (nextDataLength <= totalRecord) return true;
        else {
            return (nextDataLength - totalRecord) <= recordLimit;
        }
    }

    public class ReturnItemTable {
        //반품요청일시
        @AuraEnabled public Datetime return_Order_DTM;
        //주문번호
        @AuraEnabled public String Order_Number;
        //sub번호
        @AuraEnabled public String Sub_Order_Number;
        @AuraEnabled public Datetime createdDate;
        //주문채널
        @AuraEnabled public String order_Channel_TYPE;
        @AuraEnabled public String endp_Code;
        @AuraEnabled public String parts_Number;
        @AuraEnabled public String model_Name;

        @AuraEnabled public String product_Name;
        @AuraEnabled public Decimal quantity_Returned;
        @AuraEnabled public String ffmt_Order_Number;
        @AuraEnabled public Datetime ffmt_Transfer_DTM;
        @AuraEnabled public String ffmt_Transfer_YN;

        //@AuraEnabled public Boolean collection_YN;
        @AuraEnabled public String collection_YN;
        @AuraEnabled public String linkage_YN;
        @AuraEnabled public String CONFIRM_YN;
        @AuraEnabled public Datetime confirm_Date;
        @AuraEnabled public String reason;
        @AuraEnabled public Datetime PAYMENT_DTM;
        @AuraEnabled public Datetime shipped_Date;

        @AuraEnabled public String SALE_Number;
        @AuraEnabled public Datetime SALE_DTM;
        @AuraEnabled public Decimal SALE_SEQ;

        @AuraEnabled public String Return_Requester_Reason;

        @AuraEnabled public Decimal order_SEQ;


        @AuraEnabled public String invoice_Number;
        @AuraEnabled public String basis_Parts;
        @AuraEnabled public Decimal sale_Amount;

        @AuraEnabled public Decimal PAYMENT_Amount;
        @AuraEnabled public Decimal CASH_PAYMENT_Amount;
        @AuraEnabled public Decimal CARD_PAYMENT_Amount;
        @AuraEnabled public Decimal POINT_Amount;
        @AuraEnabled public String payment_Type;

        //query
        @AuraEnabled public String customer_Name;
        @AuraEnabled public Decimal Disposal_Quantity;
        @AuraEnabled public String Disposal_Reason;
        @AuraEnabled public Decimal Good_Quality_Quantity;
        @AuraEnabled public Datetime Return_Order_CONFIRM_DTM;
        @AuraEnabled public String Return_DESCISION_COMPLETED_YN;
        @AuraEnabled public Datetime Return_DESCISION_COMPLETED_DTM;
        @AuraEnabled public Id ReturnOrderId;
        @AuraEnabled public Id Id;
        @AuraEnabled public String Consumables_Error;
        @AuraEnabled public String Consumables_Order_Status;
        @AuraEnabled public String PRLI_Consumables_Order_Status;//원주문건의 상태 (반품내역 음영처리 조건)

        //배송지수정시 필요한 필드들

        @AuraEnabled public Id OrderCustId;
        @AuraEnabled public String OrderCustName;
        @AuraEnabled public String OrderCustMobilePhone;
        @AuraEnabled public String ConsigneeName;
        @AuraEnabled public String ConsigneeTPNO;
        @AuraEnabled public String ConsigneePostalCode;
        @AuraEnabled public String ConsigneeAddress;
        @AuraEnabled public String ConsigneeAddressDetail;
        @AuraEnabled public Boolean B2BCustomerYN;
        @AuraEnabled public String DeliveryMessage;

        @AuraEnabled public Id ProductRequest_SR_SaleId;
        @AuraEnabled public String Delivery_Completed;
        @AuraEnabled public DateTime Delivery_Date;

        @AuraEnabled public String Consumables_Business_Type_Code;

        //23.09.01 PHJ
        @AuraEnabled public String ConfirmReason;
        @AuraEnabled public String ConfirmUser;

        @AuraEnabled public Boolean isMasking;

        public ReturnItemTable() {

        }

        public ReturnItemTable(ReturnOrderLineItem returnOrder, String payment_Type, String confirmEmpId) {

            //23.09.01 PHJ
            this.ConfirmReason = returnOrder.CONFIRM_Reason__c;
            // 24 01 30 PHJ
            if (confirmEmpId != '') this.ConfirmUser = confirmEmpId;
            else if (returnOrder.CONFIRM_User_Id__c != null) this.ConfirmUser = returnOrder.CONFIRM_User_Id__c;
            else  this.ConfirmUser = '';

            this.Id = returnOrder.Id;
            this.returnOrderId = returnOrder.ReturnOrderId;
            this.return_Order_DTM = returnOrder.Return_Order_Request_DTM__c;
            this.Order_Number = returnOrder.Order_Number__c;
            //this.Sub_Order_Number = returnOrder.SUB_Order_Number__c;
            String subNum = returnOrder.SUB_Order_Number__c;
            if (subNum != null) {
                //23 09 14 hyungho.chun obs건 sub number 다른채널과 길이가 달라서 조정
                if(returnOrder.Order_CHNL_TYPE_Code__c != null && returnOrder.Order_CHNL_TYPE_Code__c =='B'){
                    // this.Sub_Order_Number = subNum.substring(subNum.length() - 11, subNum.length());
                    //23 10 16 hyungho.chun OBS 마이그데이터의 subnum 길이가 달라서 로직변경
                    this.Sub_Order_Number = subNum.substring(subNum.indexOf('-')+1).substring(subNum.substring(subNum.indexOf('-')+1).indexOf('-')+1);
                }else{
                    this.Sub_Order_Number = subNum.substring(subNum.length() - 6, subNum.length());
                }
                // this.Sub_Order_Number = subNum.substring(subNum.length() - 6, subNum.length());
            } else {
                this.Sub_Order_Number = '';
            }
            this.createdDate = returnOrder.CreatedDate;

            switch on returnOrder.Order_CHNL_TYPE_Code__c {
                when 'B' {
                    this.order_Channel_TYPE = EX_ConsumableUtil.CONSUMABLE_OBS_LABEL;
                }
                when 'S' {
                    this.order_Channel_TYPE = EX_ConsumableUtil.CONSUMABLE_THINQ_LABEL;
                }
                when 'V' {
                    this.order_Channel_TYPE = EX_ConsumableUtil.CONSUMABLE_CIC_LABEL;
                }
                when 'BestShop' {
                    this.order_Channel_TYPE = EX_ConsumableUtil.CONSUMABLE_BESTSHOP_LABEL;
                }
                when else {
                    this.order_Channel_TYPE = '미지정';
                }

            }


            //고객명
            //ReturnOrder의 Order_CUST_Name__c or CONSIGNEE_Name__c  소모품은 Order_CUST_Name__c 케어용품은 CONSIGNEE_Name__c
            //암호화 조건 : 1)ProductRequestLineItem의 주문상태값이 결제취소(003), 주문취소(004), 자동주문취소완료(005), 배송완료(070), 반품반려(110), 반품요청철회(090), 반품확정(120) =>
            //            => ProductRequestLineItem.fm_Num_Consumable_status__c의 SUM값이 0을 넘으면 필드 암호화
            //            2) & 최종수정일시 > 당일 - 14일


            //23.11.06 gw.lee
            //반품요청, 반품대기 상태일 경우, 무조건 마스킹 X 조치
            if (returnOrder.Consumables_Order_Status__c == '반품요청' || returnOrder.Consumables_Order_Status__c == '반품대기' || returnOrder.Consumables_Order_Status__c == '반품예약') {
                this.customer_Name = returnOrder.ReturnOrder.CONSIGNEE_Name__c;
            } else if (returnOrder.ReturnOrder.fm_ReturnIsMaskingTarget__c) {
                system.debug('returnOrderlineItem1 :: '+returnOrder);
                if (returnOrder.RecordType.DeveloperName == 'Consumable') {
                    //2023.10.16 fm_ENC_CONSIGNEE_Name__c > fm_ENC_Order_CUST_Name__c로 변경 // why?? PHJ Consignee name 바라봐야해서 돌려놓음
                    this.customer_Name = returnOrder.ReturnOrder.fm_ENC_CONSIGNEE_Name__c;
                    // this.customer_Name = returnOrder.ReturnOrder.fm_ENC_Order_CUST_Name__c;
                } else if (returnOrder.RecordType.DeveloperName == 'CareSupplies') {
                    this.customer_Name = returnOrder.ReturnOrder.fm_ENC_CONSIGNEE_Name__c;
                }
            } else {
                system.debug('returnOrderlineItem2 :: '+returnOrder);
                if (returnOrder.RecordType.DeveloperName == 'Consumable') {
                    //2023.10.16 CONSIGNEE_Name__c > Order_CUST_Name__c 변경 // why?? PHJ Consignee name 바라봐야해서 돌려놓음
                    // this.customer_Name = returnOrder.ReturnOrder.Order_CUST_Name__c;
                    this.customer_Name = returnOrder.ReturnOrder.CONSIGNEE_Name__c;
                } else if (returnOrder.RecordType.DeveloperName == 'CareSupplies') {
                    this.customer_Name = returnOrder.ReturnOrder.CONSIGNEE_Name__c;
                }
            }


            this.endp_Code = returnOrder.ENDP_Code__c;
            this.parts_Number = returnOrder.Parts_Number__c;
            this.model_Name = returnOrder.Product2.CAREPLUS_MODEL_CODE__c;
            //this.product_Name = returnOrder.Product2.PART_DESC_KOR__c;
            //this.product_Name = returnOrder.Product2.Description;
            //gw.lee 변경
            this.product_Name = returnOrder.Product2.PART_DESC__c;
            this.quantity_Returned = returnOrder.QuantityReturned;
            this.ffmt_Order_Number = returnOrder.FFMT_Order_Number__c;
            this.ffmt_Transfer_DTM = returnOrder.FFMT_Transfer_DTM__c;
            if (returnOrder.FFMT_Order_Transfer_YN__c == false) {
                this.ffmt_Transfer_YN = 'N';
            } else {
                this.ffmt_Transfer_YN = 'Y';
            }
            // this.collection_YN = returnOrder.COLLECTION_YN__c;
            if (returnOrder.COLLECTION_YN__c == false) {
                this.collection_YN = 'N';
            } else {
                this.collection_YN = 'Y';
            }
            this.linkage_YN = linkage_YN;

            this.confirm_Date = returnOrder.COLLECTION_Date__c;

            //반품확정 상태일때 -> 확정을 'Y'
            // if(returnOrder.Return_Order_CONFIRM_DTM__c != null) {
            //     this.CONFIRM_YN = 'Y';
            // } else {
            //     this.CONFIRM_YN = 'N';

            // }
            //23 09 19 반품확정시 이제 어떤경우던 CONFIRM_YN__c를 Y로 기입시켜 기준을 CONFIRM_YN__c로 바로보게 수정
            this.CONFIRM_YN = returnOrder.CONFIRM_YN__c == 'Y' ? 'Y' : 'N';

            //this.PAYMENT_DTM = returnOrder.ProductRequestLineItem.PAYMENT_DTM__c;
            //결제 일자 (소모품만 표시 )
            if (returnOrder.recordType.DeveloperName == 'Consumable') {
                this.PAYMENT_DTM = returnOrder.ProductRequestLineItem.Parent.PAYMENT_COMPLETED_DTM__c;
            }
            //23 08 30 hyungho.chun 케어플러스도 결제일자 표시
            if (returnOrder.recordType.DeveloperName == 'CareSupplies') {
                this.PAYMENT_DTM = returnOrder.ProductRequestLineItem.Parent.PAYMENT_COMPLETED_DTM__c;
            }

            this.reason = returnOrder.CONFIRM_Reason__c;
            this.Return_Requester_Reason = returnOrder.Return_Requester_Reason__c;
            this.order_SEQ = returnOrder.ProductRequestLineItem.Order_SEQ__c;
            this.shipped_Date = returnOrder.ProductRequestLineItem.SHIP_DTM__c;
            //배송상태가 배송완료(70)일때 배송완료 -> 'Y'
            //gw.lee 23.08.19
            //바라보는 필드 변경 DELIVERY_STATUS_CODE__c -> 
            // if (returnOrder.ProductRequestLineItem.DELIVERY_STATUS_CODE__c == '70') {
            if (returnOrder.ProductRequestLineItem.Consumables_Order_Status__c == '070') {
                this.Delivery_Completed = 'Y';
            } else {
                this.Delivery_Completed = 'N';
            }
            this.Delivery_Date = returnOrder.ProductRequestLineItem.Delivery_DTM__c;
            this.payment_Type = payment_Type;
            this.SALE_Number = returnOrder.ProductRequestLineItem.SALE_Number__c;
            this.SALE_DTM = returnOrder.ProductRequestLineItem.SALE_DTM__c;
            this.SALE_SEQ = returnOrder.ProductRequestLineItem.SALE_SEQ__c; 
        
            this.PAYMENT_Amount = returnOrder.RETURN_PAYMENT_Amount__c;
            
            
            this.basis_Parts = returnOrder.ProductRequestLineItem.BASIS_Parts__c;
            this.CARD_PAYMENT_Amount = returnOrder.RETURN_CARD_PAYMENT_Amount__c;
            this.CASH_PAYMENT_Amount = returnOrder.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c;
            this.POINT_Amount = returnOrder.RETURN_POINT_Amount__c;
            //2023.08.02 seung yoon heo ProductRequestLineItem.SALE_Amount__c > RETURN_SALE_Amount__c로 낱개처리가 안됨 변경
            //23 08 30 hyungho.chun 케어플러스는 returnOrder의 return_sale_amount__c를 넣어줌 (returnOrder/ returnOrderLineitem 1:1 )
            if (returnOrder.recordType.DeveloperName == 'CareSupplies') {
                this.sale_Amount = returnOrder.ReturnOrder.RETURN_SALE_Amount__c;
            }else{
                this.sale_Amount = returnOrder.RETURN_SALE_Amount__c;
            }
            

            if (returnOrder.INVOICE_COUNT__c != null && returnOrder.INVOICE_COUNT__c > 1) {
                this.invoice_Number = returnOrder.INVOICE_Number__c + '외 ' + (returnOrder.INVOICE_COUNT__c - 1) + '건';
            } else {
                this.invoice_Number = returnOrder.INVOICE_Number__c;
            }

            this.Disposal_Quantity = returnOrder.DISPOSAL_Quantity__c;
            this.Disposal_Reason = returnOrder.DISPOSAL_Reason__c;
            this.Good_Quality_Quantity = returnOrder.Good_Quality_Quantity__c;
            this.Return_Order_CONFIRM_DTM = returnOrder.Return_Order_CONFIRM_DTM__c;
            this.Return_DESCISION_COMPLETED_YN = returnOrder.Return_DESCISION_COMPLETED_YN__c;
            this.Return_DESCISION_COMPLETED_DTM = returnOrder.Return_DESCISION_COMPLETED_DTM__c;
            this.Consumables_Error = returnOrder.Consumables_Error__c;
            this.Consumables_Order_Status = returnOrder.Consumables_Order_Status__c;

            this.OrderCustId = returnOrder.ReturnOrder.ContactId;
            this.OrderCustName = returnOrder.ReturnOrder.Order_CUST_Name__c;
            this.OrderCustMobilePhone = returnOrder.ReturnOrder.Order_CUST_TPNO_1__c;

            //23 09 19 hyungho.chun 위에서 셋팅해줌 엎어쳐주는부분 주석처리
            // this.customer_Name = returnOrder.ReturnOrder.CONSIGNEE_Name__c;
            this.ConsigneeTPNO = returnOrder.ReturnOrder.CONSIGNEE_TPNO_1__c;
            this.ConsigneePostalCode = returnOrder.ReturnOrder.CONSIGNEE_PostalCode__c;
            this.ConsigneeAddress = returnOrder.ReturnOrder.CONSIGNEE_Address__c;
            this.ConsigneeAddressDetail = returnOrder.ReturnOrder.CONSIGNEE_Address_DETAIL__c;

            this.B2BCustomerYN = returnOrder.Order_CUST_Id__r.B2B_CUSTOMER_YN__c;
            this.ProductRequest_SR_SaleId = returnOrder.ProductRequest__r.SR_SALE__c;
            this.DeliveryMessage = returnOrder.ReturnOrder.Delivery_Message_CONTENT__c;

            this.Consumables_Business_Type_Code = returnOrder.Consumables_Business_Type_Code__c;
            this.PRLI_Consumables_Order_Status = EX_ConsumableUtil.CONSUMABLE_STATUS_CODE_KOR_MAP.get(returnOrder.ProductRequestLineItem.Consumables_Order_Status__c);

            this.isMasking = returnOrder.ReturnOrder.fm_ReturnIsMaskingTarget__c;
        }


    }

    /**
    * @description 다건의 반품요청철회
    * @param selectedRows
    * @author I2MAX.JIEUNSONG
    * @return Map<String, Object>
    */
    @AuraEnabled
    public static Map<String, Object> doCancelReturn(List<Object> selectedRows) {
        Map<String, Object> returnMap = new Map<String, Object>();

        ReturnOrderLineItem item = new ReturnOrderLineItem();
        List<ReturnOrderLineItem> roliList = new List<ReturnOrderLineItem>();
        List<Id> roliIdList = new List<Id>();

        for (Object selectedInfo : selectedRows) {
            String roliId;
            Map<String, Object> selectedMap = new Map<String, Object>();
            selectedMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(selectedInfo));
            roliId = selectedMap.get('Id').toString();
            roliIdList.add(roliId);
        }

        String query = '';
        query += ' SELECT Id, Order_Number__c, Order_SEQ__c, Consumables_Order_Status__c, ProductRequestLineItemId, Expected_Return_Quantity__c  ';
        query += ' FROM ReturnOrderLineItem  ';
        query += ' WHERE Id = :roliIdList   ';
        System.debug('query : ' + query);

        roliList = Database.query(query);
        System.debug('반품요청철회 대상 ReturnOrderLineItems : ' + roliList);

        for (ReturnOrderLineItem roli : roliList) {
            //이미 반품요청철회가 된 경우
            if (roli.Consumables_Order_Status__c == '090') {
                returnMap.put('resultState', 'ERROR');
                returnMap.put('resultMessage', '이미 반품요청 철회가 된 내역입니다.');

            }
            //반품예약(101) 또는 반품요청(100) 상태가 아닌 경우
            else if (roli.Consumables_Order_Status__c == null || (roli.Consumables_Order_Status__c != '101' && roli.Consumables_Order_Status__c != '100')) {
                returnMap.put('resultState', 'ERROR');
                returnMap.put('resultMessage', '반품예약 또는 반품요청 상태만 반품철회가 가능합니다.');
                System.debug('>> returnMap  :: ' + returnMap);
            } else {
                try {
                    //소모품 주문상태 반품요청철회(090)로 전환
                    roli.Consumables_Order_Status__c = '090';
                    //반품예정수량을 0으로 초기화
                    roli.Expected_Return_Quantity__c = 0;
                    String prId = roli.ProductRequestLineItemId;
                    ProductRequestLineItem prItem = new ProductRequestLineItem();
                    String query2 = 'SELECT Id, Consumables_Order_DETAIL__c FROM ProductRequestLineItem WHERE Id = :prId LIMIT 1';
                    prItem = Database.query(query2);

                    String resultState = 'SUCCESS';
                    String resultMessage = '반품 철회 완료';
                    returnMap.put('resultState', resultState);
                    returnMap.put('resultMessage', resultMessage);
                    System.debug('>> returnMap  :: ' + returnMap);
                    update roli;

                    if (prItem != null) {
                        //원주문 품목의 주문상태상세필드 초기화
                        prItem.Consumables_Order_DETAIL__c = '';
                        update prItem;
                    }
                } catch (Exception e) {
                    returnMap.put('resultState', 'ERROR');
                    returnMap.put('resultMessage', e.getMessage());
                    System.debug('>> returnMap  :: ' + returnMap);
                }
            }
        }

        return returnMap;
    }


    /**
         * @description 양품/폐기 처리
         * @param draftValues
         * @author I2MAX.JIEUNSONG
         * @return Map<String, Object>
         */

    @AuraEnabled
    public static Map<String, Object> doHandleDisposal(List<Object> draftValues) {

        // 양품만이 존재할때는 해당 ReturnOrderLineItem을 양품수량, 완료일시만 업데이트 시켜주며 해당 ReturnORder의 상태(Consumables_Order_Detail__c)를 반품완료로 업데이트
        List<ReturnOrderLineItem> itemList = new List<ReturnOrderLineItem>();
        Set<String> itemIdSet = new Set<String>();
        List<ReturnOrderLineItem> disposal_ROLI_Insert_List = new List<ReturnOrderLineItem>();
        List<ReturnOrder> disposal_RO_Insert_List = new List<ReturnOrder>();
        Map<String, Object> returnMap = new Map<String, Object>();
        Decimal draftGoodQty = 0;
        Decimal draftDisposalQty = 0 ;
        String draftDisposalReason = '';

        Set<String> failOrderNum = new Set<String>();
        List<ReturnOrderLineItem> failOrderId = new List<ReturnOrderLineItem>();

        Set<String> requestSet = new Set<String>();
        // Set<String> roidSet = new Set<String>();
        Savepoint sp = Database.setSavepoint();

        if (draftValues == null || draftValues.isEmpty()) {
            returnMap.put('resultState', 'ERROR');
            returnMap.put('resultMessage', '수정된 내용이 없습니다 .');
        }

        else {
            // 2024.03.09 seung yoon heo 양품폐기 로직 수정
            Map<String, Object> draftMap = new Map<String, Object>();
            Map<String, Object> draftGoodQtyMap = new Map<String, Object>();
            Map<String, Object> draftDisposalQtyMap = new Map<String, Object>();
            Map<String, Object> draftDisposalReasonMap = new Map<String, Object>();

            System.debug('draftValues :: ' + draftValues);
            for (Object draftInfo : draftValues) {
                draftMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(draftInfo));
                String returnOrderLineItemId = draftMap.get('Id').toString();
                requestSet.add(draftMap.get('Id').toString());
                // roidSet.add(draftMap.get('ReturnOrderId').toString());

                if (draftMap.get('Good_Quality_Quantity') != null) {
                    draftGoodQtyMap.put(draftMap.get('Id').toString() , Integer.valueOf(draftMap.get('Good_Quality_Quantity')));
                }
                if (draftMap.get('Disposal_Quantity') != null) {
                    draftDisposalQtyMap.put(draftMap.get('Id').toString() , Integer.valueOf(draftMap.get('Disposal_Quantity')));
                }
                if (draftMap.get('Disposal_Reason') != null) {
                    draftDisposalReasonMap.put(draftMap.get('Id').toString() , draftMap.get('Disposal_Reason').toString());
                }
            }
            List<ReturnOrderLineItem> roliList = new List<ReturnOrderLineItem>();

            // ReturnOrderLineItem item = new ReturnOrderLineItem();
            String query = '';
            query += ' SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrderLineItem');
            // seung yoon ReturnOrder 필드값 추가 
            query += ', ProductRequestLineItem.Parent.Department_Id__c , ReturnOrder.Order_Number__c, ReturnOrder.Request_Number__c ';
            query += ',  ReturnOrder.Request_SEQ__c, ReturnOrder.BASIS_SEQ__c, ReturnOrder.Department_Code__c, ReturnOrder.LOCATED_PLACE_Number__c ';
            query += ',  ReturnOrder.LOCATED_PLACE_LocationId__c, ReturnOrder.Consumables_Order_YN__c, ReturnOrder.Consumables_Business_Type_Code__c';
            //23 08 23 hyungho.chun 근거번호 필요
            query += ', ProductRequestLineItem.SR_SALE__r.SALE_Number__c ';
            //23 11 30 hyungho.chun
            query += ', ProductRequestLineItem.SALE_Number__c ';
            //23 09 13 hyungho.chun div code필요(si_transaction 용)
            query += ', Product2.DIV_CODE__c ';
            query += ', ProductRequestLineItem.Order_Number__c ';
            query += ' FROM ReturnOrderLineItem WHERE id IN :requestSet FOR UPDATE';
            roliList = Database.query(query);

            Set<String> prdIdSet = new Set<String>();
            Set<String> locationIdSet = new Set<String>();
            
            for (ReturnOrderLineItem pri : roliList) {
                prdIdSet.add(pri.Product2Id);
                locationIdSet.add(pri.DestinationLocationId);
            }

            List<ProductItem> ProductItemList = [SELECT id, DEPT_CODE__c, Product2Id, LocationId  FROM ProductItem WHERE Product2Id IN:prdIdSet AND LocationId IN:locationIdSet];
            
            Map<String, String> pritMap = new Map<String,String>();
            for (ProductItem prit : ProductItemList) {
                pritMap.put(prit.Product2Id +''+ prit.LocationId, prit.id +'_'+prit.DEPT_CODE__c);
            }
            // seung yoon heo 찾아온 returnOrderLineItem을 기준으로 다시 returnOrder를 쿼리하는 로직 이미 master-detail관계로 라인아이템에 충분히 존재
            // List<ReturnOrder> roList = new List<ReturnOrder>();
            // String query2 = '';
            // query2 += ' SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrder');
            // query2 += ' FROM ReturnOrder ';
            // query2 += ' WHERE Id IN :roidSet ';
            // roList = Database.query(query2);

           
            for (ReturnOrderLineItem item : roliList) {
                try {
                    // List<ProductItem> productItem = new List<ProductItem>([
                    //         SELECT Id, DEPT_CODE__c
                    //         FROM ProductItem
                    //         WHERE Product2Id = :item.Product2Id AND LocationId = :item.DestinationLocationId
                    //         LIMIT 1
                    // ]);
                    Decimal i = 0;
                    
                    // seung yoon heo 사용안함
                    // Decimal DisposalBasisNumber = 10000;

                    
                    system.debug('draftDisposalQty : '+Integer.valueOf(draftDisposalQtyMap.get(item.id)));
                    system.debug('draftGoodQtyMap : '+Integer.valueOf(draftGoodQtyMap.get(item.id)));

                    if ( item.QuantityReturned == (Integer.valueOf(draftDisposalQtyMap.get(item.id)) + Integer.valueOf(draftGoodQtyMap.get(item.id))) ) {
                        //양품수량만 존재하고 폐기수량이 0인경우
                        if ((Integer.valueOf(draftGoodQtyMap.get(item.id)) != 0) && (Integer.valueOf(draftDisposalQtyMap.get(item.id)) == 0)) {
                            returnMap.put('resultState', 'SUCCESS');
                            returnMap.put('resultMessage', ' 양품수량 업데이트 완료');
                            //양품수량만 업데이트
                            item.Good_Quality_Quantity__c = Integer.valueOf(draftGoodQtyMap.get(item.id));
                            item.DISPOSAL_Quantity__c = Integer.valueOf(draftDisposalQtyMap.get(item.id));
                            item.Return_DESCISION_COMPLETED_YN__c = 'Y'; //반품판정완료여부
                            item.Return_DESCISION_COMPLETED_DTM__c = System.now(); //반품판정완료일시
                            item.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_121;
                            System.debug(item.id + ' > ' + '양품수량 업데이트 ');

                        }
                        //폐기수량만 존재하는 경우
                        else if ((Integer.valueOf(draftGoodQtyMap.get(item.id)) == 0) && (Integer.valueOf(draftDisposalQtyMap.get(item.id)) != 0)) {
                            returnMap.put('resultState', 'SUCCESS');
                            returnMap.put('resultMessage', ' 폐기 생성 및 업데이트 완료');

                            item.Good_Quality_Quantity__c = Integer.valueOf(draftGoodQtyMap.get(item.id));
                            item.DISPOSAL_Quantity__c = Integer.valueOf(draftDisposalQtyMap.get(item.id));
                            item.DISPOSAL_Reason__c = draftDisposalReasonMap.get(item.id).toString();
                            item.Return_DESCISION_COMPLETED_YN__c = 'Y'; //반품판정완료여부
                            item.Return_DESCISION_COMPLETED_DTM__c = System.now(); //반품판정완료일시
                            item.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_121;


                            //폐기 ReturnOrderLineItem 레코드 생성
                            ReturnOrderLineItem newDisposalItem = new ReturnOrderLineItem();
                            // 폐기 RecordTypeId
                            newDisposalItem.recordTypeId = EX_ConsumableUtil.ROLI_DISPOSAL_RECORDTYPE_ID;
                            // Location ID
                            newDisposalItem.SourceLocationId = item.DestinationLocationId;
                            // productItemId
                            //newDisposalItem.ProductItemId = item.ProductItemId;
                            if (pritMap.get(item.Product2Id + '' + item.DestinationLocationId).split('_')[0] != 'null') {
                                newDisposalItem.ProductItemId = pritMap.get(item.Product2Id + '' + item.DestinationLocationId).split('_')[0];
                            }

                            // 근거번호 //todo 정의 필요 -- 현업 확인중
                            //newDisposalItem.BASIS_Number__c = item.Order_Number__c;
                            // newDisposalItem.BASIS_Number__c = 'K' + integer.valueOf(DisposalBasisNumber++);

                            //23 08 23 hyungho.chun 근거번호 Rxxxxxxxxx로 채번 예(R000104989)
                            //23 10 11 hyungho.chun 근거번호 Axxxxxxxxx로 채번 / 이용석책임님 요청으로 A채번으로 수정
                            newDisposalItem.BASIS_Number__c = 'A' + item.ProductRequestLineItem.SR_SALE__r.SALE_Number__c.substring(1);

                            // 근거 순번
                            //newDisposalItem.BASIS_SEQ__c = item.BASIS_SEQ__c;
                            newDisposalItem.BASIS_SEQ__c = i++;
                            // 부서코드
                            //newDisposalItem.Department_Code__c = item.Department_Code__c;
                            newDisposalItem.Department_Code__c = pritMap.get(item.Product2Id + '' + item.DestinationLocationId).split('_')[1] != 'null' ? pritMap.get(item.Product2Id + '' + item.DestinationLocationId).split('_')[1] : null;
                            // PartNo
                            newDisposalItem.Parts_Number__c = item.Parts_Number__c;
                            // 사업부 코드
                            newDisposalItem.ENDP_Code__c = item.ENDP_Code__c;
                            // 적치장소 코드

                            //newDisposalItem.LOCATED_PLACE_Number__c = item.LOCATED_PLACE_Number__c;
                            newDisposalItem.LOCATED_PLACE_Number__c = System.Label.EX_Location;
                            // 폐기사유
                            newDisposalItem.DISPOSAL_Reason__c = item.DISPOSAL_Reason__c;
                            // 폐기수량
                            newDisposalItem.DISPOSAL_Quantity__c = item.DISPOSAL_Quantity__c;
                            //폐기유형 //todo 정의 필요 -- 현업 확인중
                            //newDisposalItem.DISPOSAL_Type__c = item.DISPOSAL_Type__c;
                            newDisposalItem.DISPOSAL_Type__c = 'K';
                            // 조직코드 ID
                            newDisposalItem.DISPOSAL_SM_DEPT_Id__c = item.ProductRequestLineItem.Parent.Department_Id__c ;
                            // 반품 수량
                            newDisposalItem.QuantityReturned = item.QuantityReturned;
                            // 주문 번호
                            newDisposalItem.Order_Number__c = item.Order_Number__c;
                            //Product2Id
                            if (item.product2Id != null) {
                                newDisposalItem.Product2Id = item.Product2Id;
                            }
                            newDisposalItem.SUB_Order_Number__c = item.SUB_Order_Number__c;
                            newDisposalItem.Consumables_Business_Type_Code__c = item.Consumables_Business_Type_Code__c;
                            

                            disposal_ROLI_Insert_List.add(newDisposalItem);
                            System.debug('newDisposalItem :: ' + newDisposalItem);


                            //폐기 ReturnOrder 레코드 생성
                            ReturnOrder newDisposalReturnOrder = new ReturnOrder();
                            newDisposalReturnOrder.recordTypeId = EX_ConsumableUtil.RO_DISPOSAL_RECORDTYPE_ID;
                            newDisposalReturnOrder.Order_Number__c = item.ReturnOrder.Order_Number__c;
                            newDisposalReturnOrder.Request_Number__c = item.ReturnOrder.Request_Number__c;
                            newDisposalReturnOrder.Request_SEQ__c = item.ReturnOrder.Request_SEQ__c;
                            //newDisposalReturnOrder.BASIS_Number__c = ro.BASIS_Number__c;
                            //23 08 23 hyungho.chun 근거번호 Rxxxxxxxxx로 채번 예(R000104989)
                            //23 10 11 hyungho.chun 근거번호 Axxxxxxxxx로 채번 / 이용석책임님 요청으로 A채번으로 수정
                            newDisposalReturnOrder.BASIS_Number__c = 'A' + item.ProductRequestLineItem.SR_SALE__r.SALE_Number__c.substring(1);                        
                            newDisposalReturnOrder.BASIS_SEQ__c = item.ReturnOrder.BASIS_SEQ__c;
                            newDisposalReturnOrder.Department_Code__c = item.ReturnOrder.Department_Code__c;
                            newDisposalReturnOrder.LOCATED_PLACE_Number__c = item.ReturnOrder.LOCATED_PLACE_Number__c;
                            newDisposalReturnOrder.LOCATED_PLACE_LocationId__c = item.ReturnOrder.LOCATED_PLACE_LocationId__c;
                            newDisposalReturnOrder.Consumables_Order_YN__c = item.ReturnOrder.Consumables_Order_YN__c;
                            //24.02.27 gw.lee
                            //폐기건은 품목별 ReturnOrder가 생성되기때문에 seq필요
                            newDisposalReturnOrder.Order_SEQ__c = item.Order_SEQ__c;
                            newDisposalReturnOrder.Consumables_Business_Type_Code__c = item.ReturnOrder.Consumables_Business_Type_Code__c;

                            disposal_RO_Insert_List.add(newDisposalReturnOrder);

                        }

                        //양품수량과 폐기수량이 모두 존재하는 경우
                        else if (Integer.valueOf(draftGoodQtyMap.get(item.id)) != 0 && Integer.valueOf(draftDisposalQtyMap.get(item.id)) != 0) {
                            returnMap.put('resultState', 'SUCCESS');
                            returnMap.put('resultMessage', ' 양품수량 과 폐기수량 업데이트 및 생성 완료');
                            //양품수량 & 폐기수량 업데이트
                            item.Good_Quality_Quantity__c = Integer.valueOf(draftGoodQtyMap.get(item.id));
                            item.DISPOSAL_Quantity__c = Integer.valueOf(draftDisposalQtyMap.get(item.id));
                            item.DISPOSAL_Reason__c = draftDisposalReasonMap.get(item.id).toString();
                            item.Return_DESCISION_COMPLETED_YN__c = 'Y'; //반품판정완료여부
                            item.Return_DESCISION_COMPLETED_DTM__c = System.now(); //반품판정완료일시
                            item.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_121;

                            ReturnOrderLineItem newDisposalItem = new ReturnOrderLineItem();
                            // 폐기 RecordTypeId
                            newDisposalItem.recordTypeId = EX_ConsumableUtil.ROLI_DISPOSAL_RECORDTYPE_ID;
                            // Location ID
                            newDisposalItem.SourceLocationId = item.DestinationLocationId;
                            // productItemId
                            if (pritMap.get(item.Product2Id + '' + item.DestinationLocationId).split('_')[0] != 'null') {
                                newDisposalItem.ProductItemId = pritMap.get(item.Product2Id + '' + item.DestinationLocationId).split('_')[0];
                            }
                            // 근거번호 //todo 정의 필요 -- 현업 확인중
                            //newDisposalItem.BASIS_Number__c = item.Order_Number__c; -- 근거번호 데이터 maxlength 10
                            // newDisposalItem.BASIS_Number__c = 'K' + integer.valueOf(DisposalBasisNumber++);

                            //23 08 23 hyungho.chun 근거번호 Rxxxxxxxxx로 채번 예(R000104989)
                            //23 10 11 hyungho.chun 근거번호 Axxxxxxxxx로 채번 / 이용석책임님 요청으로 A채번으로 수정
                            newDisposalItem.BASIS_Number__c = 'A' + item.ProductRequestLineItem.SR_SALE__r.SALE_Number__c.substring(1);

                            // 근거 순번
                            //newDisposalItem.BASIS_SEQ__c = item.BASIS_SEQ__c;
                            newDisposalItem.BASIS_SEQ__c = i++;
                            // 부서코드
                            //newDisposalItem.Department_Code__c = item.Department_Code__c;
                            newDisposalItem.Department_Code__c = pritMap.get(item.Product2Id + '' + item.DestinationLocationId).split('_')[1] != 'null' ? pritMap.get(item.Product2Id + '' + item.DestinationLocationId).split('_')[1] : null;
                            // PartNo
                            newDisposalItem.Parts_Number__c = item.Parts_Number__c;
                            // 사업부 코드
                            newDisposalItem.ENDP_Code__c = item.ENDP_Code__c;
                            // 적치장소 코드
                            //newDisposalItem.LOCATED_PLACE_Number__c = item.LOCATED_PLACE_Number__c;
                            newDisposalItem.LOCATED_PLACE_Number__c = System.Label.EX_Location;
                            // 폐기사유
                            newDisposalItem.DISPOSAL_Reason__c = item.DISPOSAL_Reason__c;
                            // 폐기수량
                            newDisposalItem.DISPOSAL_Quantity__c = item.DISPOSAL_Quantity__c;
                            //폐기유형 //todo 정의 필요 -- 현업 확인중
                            //newDisposalItem.DISPOSAL_Type__c = item.DISPOSAL_Type__c;
                            newDisposalItem.DISPOSAL_Type__c = 'K';
                            // 조직코드 ID
                            newDisposalItem.DISPOSAL_SM_DEPT_Id__c = item.ProductRequestLineItem.Parent.Department_Id__c ;
                            // 반품 수량
                            newDisposalItem.QuantityReturned = item.QuantityReturned;
                            // 주문 번호
                            newDisposalItem.Order_Number__c = item.Order_Number__c;
                            //Product2Id
                            if (item.product2Id != null) {
                                newDisposalItem.Product2Id = item.Product2Id;
                            }
                            newDisposalItem.SUB_Order_Number__c = item.SUB_Order_Number__c;
                            

                            disposal_ROLI_Insert_List.add(newDisposalItem);
                            System.debug('newDisposalItem :: ' + newDisposalItem);


                            //폐기 ReturnOrder 레코드 생성
                            //seung yoon heo returnOrder를 또 조회를 할 필요가 없음 item을 또 왜 select 함
                            ReturnOrder newDisposalReturnOrder = new ReturnOrder();
                            newDisposalReturnOrder.recordTypeId = EX_ConsumableUtil.RO_DISPOSAL_RECORDTYPE_ID;
                            newDisposalReturnOrder.Order_Number__c = item.ReturnOrder.Order_Number__c;
                            newDisposalReturnOrder.Request_Number__c = item.ReturnOrder.Request_Number__c;
                            newDisposalReturnOrder.Request_SEQ__c = item.ReturnOrder.Request_SEQ__c;
                            // newDisposalReturnOrder.BASIS_Number__c = ro.BASIS_Number__c;
                            //23 08 23 hyungho.chun 근거번호 Rxxxxxxxxx로 채번 예(R000104989)
                            //23 10 11 hyungho.chun 근거번호 Axxxxxxxxx로 채번 / 이용석책임님 요청으로 A채번으로 수정
                            newDisposalReturnOrder.BASIS_Number__c = 'A' + item.ProductRequestLineItem.SR_SALE__r.SALE_Number__c.substring(1);
                            newDisposalReturnOrder.BASIS_SEQ__c = item.ReturnOrder.BASIS_SEQ__c;
                            newDisposalReturnOrder.Department_Code__c = item.ReturnOrder.Department_Code__c;
                            newDisposalReturnOrder.LOCATED_PLACE_Number__c = item.ReturnOrder.LOCATED_PLACE_Number__c;
                            newDisposalReturnOrder.LOCATED_PLACE_LocationId__c = item.ReturnOrder.LOCATED_PLACE_LocationId__c;
                            newDisposalReturnOrder.Consumables_Order_YN__c = item.ReturnOrder.Consumables_Order_YN__c;
                            //24.02.27 gw.lee
                            //폐기건은 품목별 ReturnOrder가 생성되기때문에 seq필요
                            newDisposalReturnOrder.Order_SEQ__c = item.Order_SEQ__c;
                            newDisposalReturnOrder.Consumables_Business_Type_Code__c = item.ReturnOrder.Consumables_Business_Type_Code__c;


                            disposal_RO_Insert_List.add(newDisposalReturnOrder);
                        }
                    }

                    //양품수량과 폐기수량이 모두 0 인경우
                    else if (Integer.valueOf(draftGoodQtyMap.get(item.id)) == 0 && Integer.valueOf(draftDisposalQtyMap.get(item.id)) == 0) {

                        returnMap.put('resultState', 'ERROR');
                        returnMap.put('resultMessage', '수량을 입력해주세요 ');

                    }

                    else {
                        returnMap.put('resultState', 'ERROR');
                        returnMap.put('resultMessage', '양품수량과 폐기수량의 합이 반품수량과 맞지 않습니다');
                    }

                    itemList.add(item);
                    itemIdSet.add(item.Id);
                } catch (Exception e) {
                    //실패한 Order_Number
                    System.debug('asdfasdf' + e);
                    failOrderNum.add(item.Order_Number__c);
                    failOrderId.add(item);
                }

            }

            System.debug('failOrderNum ?? ' + failOrderNum);
            System.debug('itemList ?? ' + itemList);
            System.debug('itemIdSet ?? ' + itemIdSet);

            // seung yoon heo 로직 변경 주석처리
            // List<ReturnOrderLineItem> roList = new List<ReturnOrderLineItem>();
            // for (Object draftInfo : draftValues) {
                // Map<String, Object> draftMap = new Map<String, Object>();
                // draftMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(draftInfo));
                // String returnOrderLineItemId = draftMap.get('Id').toString();
                
                // requestSet.add(draftMap.get('Id').toString());

                // if (draftMap.get('Good_Quality_Quantity') != null) {
                //     draftGoodQty = Integer.valueOf(draftMap.get('Good_Quality_Quantity'));
                // }
                // if (draftMap.get('Disposal_Quantity') != null) {
                //     draftDisposalQty = Integer.valueOf(draftMap.get('Disposal_Quantity'));
                // }
                // if (draftMap.get('Disposal_Reason') != null) {
                //     draftDisposalReason = draftMap.get('Disposal_Reason').toString();
                // }

                //선택된 ReturnOrderLineItem
                // ReturnOrderLineItem item = new ReturnOrderLineItem();
                // String query = '';
                // query += ' SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrderLineItem');
                // query += ', ProductRequestLineItem.Parent.Department_Id__c ';
                // //23 08 23 hyungho.chun 근거번호 필요
                // query += ', ProductRequestLineItem.SR_SALE__r.SALE_Number__c ';
                // //23 11 30 hyungho.chun
                // query += ', ProductRequestLineItem.SALE_Number__c ';
                // //23 09 13 hyungho.chun div code필요(si_transaction 용)
                // query += ', Product2.DIV_CODE__c ';
                // query += ', ProductRequestLineItem.Order_Number__c ';
                // query += ' FROM ReturnOrderLineItem WHERE id = :returnOrderLineItemId  LIMIT 1 FOR UPDATE';
                // item = Database.query(query);


                // String returnOrderId = String.valueOf(item.ReturnOrderId);

                // Decimal ReturnQty = item.QuantityReturned.intValue();

                // //선택된 ReturnOrderLineItem의 ReturnOrder
                // ReturnOrder ro = new ReturnOrder();
                // String query2 = '';
                // query2 += ' SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrder');
                // query2 += ' FROM ReturnOrder ';
                // query2 += ' WHERE Id = :returnOrderId ';
                // ro = Database.query(query2);
                // roList.add(item);
                // List<ProductItem> productItem = new List<ProductItem>([
                //         SELECT Id, DEPT_CODE__c
                //         FROM ProductItem
                //         WHERE Product2Id = :item.Product2Id AND LocationId = :item.DestinationLocationId
                //         LIMIT 1
                // ]);
                // Decimal i = 0;
                
                // Decimal DisposalBasisNumber = 10000;

                // system.debug('ReturnQty : '+ReturnQty);
                // system.debug('draftDisposalQty : '+draftDisposalQty);
                // system.debug('draftGoodQty : '+draftGoodQty);
                // //양품수량과 폐기수량이 반품수량과 같을 경우에만 진행
                // if (ReturnQty == (draftDisposalQty + draftGoodQty)) {

                //     //양품수량만 존재하고 폐기수량이 0인경우
                //     if ((draftGoodQty != 0) && (draftDisposalQty == 0)) {
                //         returnMap.put('resultState', 'SUCCESS');
                //         returnMap.put('resultMessage', ' 양품수량 업데이트 완료');
                //         //양품수량만 업데이트
                //         item.Good_Quality_Quantity__c = draftGoodQty;
                //         item.DISPOSAL_Quantity__c = draftDisposalQty;
                //         item.Return_DESCISION_COMPLETED_YN__c = 'Y'; //반품판정완료여부
                //         item.Return_DESCISION_COMPLETED_DTM__c = System.now(); //반품판정완료일시
                //         item.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_121;
                //         System.debug(item.id + ' > ' + '양품수량 업데이트 ');

                //     }
                //     //폐기수량만 존재하는 경우
                //     else if ((draftGoodQty == 0) && (draftDisposalQty != 0)) {
                //         returnMap.put('resultState', 'SUCCESS');
                //         returnMap.put('resultMessage', ' 폐기 생성 및 업데이트 완료');

                //         item.Good_Quality_Quantity__c = draftGoodQty;
                //         item.DISPOSAL_Quantity__c = draftDisposalQty;
                //         item.DISPOSAL_Reason__c = draftDisposalReason;
                //         item.Return_DESCISION_COMPLETED_YN__c = 'Y'; //반품판정완료여부
                //         item.Return_DESCISION_COMPLETED_DTM__c = System.now(); //반품판정완료일시
                //         item.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_121;


                //         //폐기 ReturnOrderLineItem 레코드 생성
                //         ReturnOrderLineItem newDisposalItem = new ReturnOrderLineItem();
                //         // 폐기 RecordTypeId
                //         newDisposalItem.recordTypeId = EX_ConsumableUtil.ROLI_DISPOSAL_RECORDTYPE_ID;
                //         // Location ID
                //         newDisposalItem.SourceLocationId = item.DestinationLocationId;
                //         // productItemId
                //         //newDisposalItem.ProductItemId = item.ProductItemId;
                //         if (!productItem.isEmpty()) {
                //             newDisposalItem.ProductItemId = productItem[0].Id;
                //         }

                //         // 근거번호 //todo 정의 필요 -- 현업 확인중
                //         //newDisposalItem.BASIS_Number__c = item.Order_Number__c;
                //         // newDisposalItem.BASIS_Number__c = 'K' + integer.valueOf(DisposalBasisNumber++);

                //         //23 08 23 hyungho.chun 근거번호 Rxxxxxxxxx로 채번 예(R000104989)
                //         //23 10 11 hyungho.chun 근거번호 Axxxxxxxxx로 채번 / 이용석책임님 요청으로 A채번으로 수정
                //         newDisposalItem.BASIS_Number__c = 'A' + item.ProductRequestLineItem.SR_SALE__r.SALE_Number__c.substring(1);

                //         // 근거 순번
                //         //newDisposalItem.BASIS_SEQ__c = item.BASIS_SEQ__c;
                //         newDisposalItem.BASIS_SEQ__c = i++;
                //         // 부서코드
                //         //newDisposalItem.Department_Code__c = item.Department_Code__c;
                //         newDisposalItem.Department_Code__c = productItem.size() > 0 ? productItem[0].DEPT_CODE__c : null;
                //         // PartNo
                //         newDisposalItem.Parts_Number__c = item.Parts_Number__c;
                //         // 사업부 코드
                //         newDisposalItem.ENDP_Code__c = item.ENDP_Code__c;
                //         // 적치장소 코드

                //         //newDisposalItem.LOCATED_PLACE_Number__c = item.LOCATED_PLACE_Number__c;
                //         newDisposalItem.LOCATED_PLACE_Number__c = System.Label.EX_Location;
                //         // 폐기사유
                //         newDisposalItem.DISPOSAL_Reason__c = item.DISPOSAL_Reason__c;
                //         // 폐기수량
                //         newDisposalItem.DISPOSAL_Quantity__c = item.DISPOSAL_Quantity__c;
                //         //폐기유형 //todo 정의 필요 -- 현업 확인중
                //         //newDisposalItem.DISPOSAL_Type__c = item.DISPOSAL_Type__c;
                //         newDisposalItem.DISPOSAL_Type__c = 'K';
                //         // 조직코드 ID
                //         newDisposalItem.DISPOSAL_SM_DEPT_Id__c = item.ProductRequestLineItem.Parent.Department_Id__c ;
                //         // 반품 수량
                //         newDisposalItem.QuantityReturned = item.QuantityReturned;
                //         // 주문 번호
                //         newDisposalItem.Order_Number__c = item.Order_Number__c;
                //         //Product2Id
                //         if (item.product2Id != null) {
                //             newDisposalItem.Product2Id = item.Product2Id;
                //         }
                //         newDisposalItem.SUB_Order_Number__c = item.SUB_Order_Number__c;
                //         newDisposalItem.Consumables_Business_Type_Code__c = item.Consumables_Business_Type_Code__c;
                        

                //         disposal_ROLI_Insert_List.add(newDisposalItem);
                //         System.debug('newDisposalItem :: ' + newDisposalItem);


                //         //폐기 ReturnOrder 레코드 생성
                //         ReturnOrder newDisposalReturnOrder = new ReturnOrder();
                //         newDisposalReturnOrder.recordTypeId = EX_ConsumableUtil.RO_DISPOSAL_RECORDTYPE_ID;
                //         newDisposalReturnOrder.Order_Number__c = ro.Order_Number__c;
                //         newDisposalReturnOrder.Request_Number__c = ro.Request_Number__c;
                //         newDisposalReturnOrder.Request_SEQ__c = ro.Request_SEQ__c;
                //         //newDisposalReturnOrder.BASIS_Number__c = ro.BASIS_Number__c;
                //         //23 08 23 hyungho.chun 근거번호 Rxxxxxxxxx로 채번 예(R000104989)
                //         //23 10 11 hyungho.chun 근거번호 Axxxxxxxxx로 채번 / 이용석책임님 요청으로 A채번으로 수정
                //         newDisposalReturnOrder.BASIS_Number__c = 'A' + item.ProductRequestLineItem.SR_SALE__r.SALE_Number__c.substring(1);                        
                //         newDisposalReturnOrder.BASIS_SEQ__c = ro.BASIS_SEQ__c;
                //         newDisposalReturnOrder.Department_Code__c = ro.Department_Code__c;
                //         newDisposalReturnOrder.LOCATED_PLACE_Number__c = ro.LOCATED_PLACE_Number__c;
                //         newDisposalReturnOrder.LOCATED_PLACE_LocationId__c = ro.LOCATED_PLACE_LocationId__c;
                //         newDisposalReturnOrder.Consumables_Order_YN__c = ro.Consumables_Order_YN__c;
                //         //24.02.27 gw.lee
                //         //폐기건은 품목별 ReturnOrder가 생성되기때문에 seq필요
                //         newDisposalReturnOrder.Order_SEQ__c = item.Order_SEQ__c;
                //         newDisposalReturnOrder.Consumables_Business_Type_Code__c = ro.Consumables_Business_Type_Code__c;

                //         disposal_RO_Insert_List.add(newDisposalReturnOrder);

                //     }

                //     //양품수량과 폐기수량이 모두 존재하는 경우
                //     else if (draftGoodQty != 0 && draftDisposalQty != 0) {
                //         returnMap.put('resultState', 'SUCCESS');
                //         returnMap.put('resultMessage', ' 양품수량 과 폐기수량 업데이트 및 생성 완료');
                //         //양품수량 & 폐기수량 업데이트
                //         item.Good_Quality_Quantity__c = draftGoodQty;
                //         item.DISPOSAL_Quantity__c = draftDisposalQty;
                //         item.DISPOSAL_Reason__c = draftDisposalReason;
                //         item.Return_DESCISION_COMPLETED_YN__c = 'Y'; //반품판정완료여부
                //         item.Return_DESCISION_COMPLETED_DTM__c = System.now(); //반품판정완료일시
                //         item.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_121;

                //         ReturnOrderLineItem newDisposalItem = new ReturnOrderLineItem();
                //         // 폐기 RecordTypeId
                //         newDisposalItem.recordTypeId = EX_ConsumableUtil.ROLI_DISPOSAL_RECORDTYPE_ID;
                //         // Location ID
                //         newDisposalItem.SourceLocationId = item.DestinationLocationId;
                //         // productItemId
                //         if (!productItem.isEmpty()) {
                //             newDisposalItem.ProductItemId = productItem[0].Id;
                //         }
                //         // 근거번호 //todo 정의 필요 -- 현업 확인중
                //         //newDisposalItem.BASIS_Number__c = item.Order_Number__c; -- 근거번호 데이터 maxlength 10
                //         // newDisposalItem.BASIS_Number__c = 'K' + integer.valueOf(DisposalBasisNumber++);

                //         //23 08 23 hyungho.chun 근거번호 Rxxxxxxxxx로 채번 예(R000104989)
                //         //23 10 11 hyungho.chun 근거번호 Axxxxxxxxx로 채번 / 이용석책임님 요청으로 A채번으로 수정
                //         newDisposalItem.BASIS_Number__c = 'A' + item.ProductRequestLineItem.SR_SALE__r.SALE_Number__c.substring(1);

                //         // 근거 순번
                //         //newDisposalItem.BASIS_SEQ__c = item.BASIS_SEQ__c;
                //         newDisposalItem.BASIS_SEQ__c = i++;
                //         // 부서코드
                //         //newDisposalItem.Department_Code__c = item.Department_Code__c;
                //         newDisposalItem.Department_Code__c = productItem[0].DEPT_CODE__c;
                //         // PartNo
                //         newDisposalItem.Parts_Number__c = item.Parts_Number__c;
                //         // 사업부 코드
                //         newDisposalItem.ENDP_Code__c = item.ENDP_Code__c;
                //         // 적치장소 코드
                //         //newDisposalItem.LOCATED_PLACE_Number__c = item.LOCATED_PLACE_Number__c;
                //         newDisposalItem.LOCATED_PLACE_Number__c = System.Label.EX_Location;
                //         // 폐기사유
                //         newDisposalItem.DISPOSAL_Reason__c = item.DISPOSAL_Reason__c;
                //         // 폐기수량
                //         newDisposalItem.DISPOSAL_Quantity__c = item.DISPOSAL_Quantity__c;
                //         //폐기유형 //todo 정의 필요 -- 현업 확인중
                //         //newDisposalItem.DISPOSAL_Type__c = item.DISPOSAL_Type__c;
                //         newDisposalItem.DISPOSAL_Type__c = 'K';
                //         // 조직코드 ID
                //         newDisposalItem.DISPOSAL_SM_DEPT_Id__c = item.ProductRequestLineItem.Parent.Department_Id__c ;
                //         // 반품 수량
                //         newDisposalItem.QuantityReturned = item.QuantityReturned;
                //         // 주문 번호
                //         newDisposalItem.Order_Number__c = item.Order_Number__c;
                //         //Product2Id
                //         if (item.product2Id != null) {
                //             newDisposalItem.Product2Id = item.Product2Id;
                //         }
                //         newDisposalItem.SUB_Order_Number__c = item.SUB_Order_Number__c;
                        

                //         disposal_ROLI_Insert_List.add(newDisposalItem);
                //         System.debug('newDisposalItem :: ' + newDisposalItem);


                //         //폐기 ReturnOrder 레코드 생성
                //         ReturnOrder newDisposalReturnOrder = new ReturnOrder();
                //         newDisposalReturnOrder.recordTypeId = EX_ConsumableUtil.RO_DISPOSAL_RECORDTYPE_ID;
                //         newDisposalReturnOrder.Order_Number__c = ro.Order_Number__c;
                //         newDisposalReturnOrder.Request_Number__c = ro.Request_Number__c;
                //         newDisposalReturnOrder.Request_SEQ__c = ro.Request_SEQ__c;
                //         // newDisposalReturnOrder.BASIS_Number__c = ro.BASIS_Number__c;
                //         //23 08 23 hyungho.chun 근거번호 Rxxxxxxxxx로 채번 예(R000104989)
                //         //23 10 11 hyungho.chun 근거번호 Axxxxxxxxx로 채번 / 이용석책임님 요청으로 A채번으로 수정
                //         newDisposalReturnOrder.BASIS_Number__c = 'A' + item.ProductRequestLineItem.SR_SALE__r.SALE_Number__c.substring(1);
                //         newDisposalReturnOrder.BASIS_SEQ__c = ro.BASIS_SEQ__c;
                //         newDisposalReturnOrder.Department_Code__c = ro.Department_Code__c;
                //         newDisposalReturnOrder.LOCATED_PLACE_Number__c = ro.LOCATED_PLACE_Number__c;
                //         newDisposalReturnOrder.LOCATED_PLACE_LocationId__c = ro.LOCATED_PLACE_LocationId__c;
                //         newDisposalReturnOrder.Consumables_Order_YN__c = ro.Consumables_Order_YN__c;
                //         //24.02.27 gw.lee
                //         //폐기건은 품목별 ReturnOrder가 생성되기때문에 seq필요
                //         newDisposalReturnOrder.Order_SEQ__c = item.Order_SEQ__c;
                //         newDisposalReturnOrder.Consumables_Business_Type_Code__c = ro.Consumables_Business_Type_Code__c;


                //         disposal_RO_Insert_List.add(newDisposalReturnOrder);
                //     }
                // }

                // //양품수량과 폐기수량이 모두 0 인경우
                // else if (draftGoodQty == 0 && draftDisposalQty == 0) {

                //     returnMap.put('resultState', 'ERROR');
                //     returnMap.put('resultMessage', '수량을 입력해주세요 ');

                // }

                // else {
                //     returnMap.put('resultState', 'ERROR');
                //     returnMap.put('resultMessage', '양품수량과 폐기수량의 합이 반품수량과 맞지 않습니다');
                // }

                // itemList.add(item);
            // }

            List<ReturnOrderLineItem> disposalRoliList = new List<ReturnOrderLineItem>();
            Map<String, ReturnOrderLineItem> disposalRoliMap = new Map<String, ReturnOrderLineItem>();

            try {
                
                if (!itemList.isEmpty()) {
                    List<ReturnOrderLineItem> dupCheckList = new List<ReturnOrderLineItem>();
                    List<ReturnOrderLineItem> dupUpdateList = new List<ReturnOrderLineItem>();
                    Set<String> dupSet = new Set<String>();

                    String dupQuery = '';
                    dupQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrderLineItem');
                    dupQuery += ', ProductRequestLineItem.Parent.Department_Id__c ';
                    //23 08 23 hyungho.chun 근거번호 필요
                    dupQuery += ', ProductRequestLineItem.SR_SALE__r.SALE_Number__c ';
                    //23 11 30 hyungho.chun
                    dupQuery += ', ProductRequestLineItem.SALE_Number__c ';
                    //23 09 13 hyungho.chun div code필요(si_transaction 용)
                    dupQuery += ', Product2.DIV_CODE__c ';
                    dupQuery += ', ProductRequestLineItem.Order_Number__c ';
                    dupQuery += ' FROM ReturnOrderLineItem WHERE id = :itemIdSet AND Return_DESCISION_COMPLETED_YN__c != \'Y\'  FOR UPDATE';
                    dupCheckList = Database.query(dupQuery);
                    System.debug('itemList :::: ' + itemList);
                    System.debug('dupCheckList :::: ' + dupCheckList);
                    

                    if (itemList.size() != dupCheckList.size()) {
                        for (ReturnOrderLineItem dup : dupCheckList) {
                            dupSet.add(dup.Id);
                        }

                        for (ReturnOrderLineItem item : itemList) {
                            if (dupSet.contains(item.Id)) {
                                dupUpdateList.add(item);
                            }else {
                                failOrderNum.add(item.Order_number__c);
                            }
                        }

                        returnMap.put('failOrderNum', failOrderNum);
                        returnMap.put('resultMessage', '이미 조치된 반품건이 존재합니다.');
                        update dupUpdateList;
                    } else {
                        update itemList;
                    }
                    System.debug('itemList Update ' + itemList);
                    System.debug('returnMap ' + returnMap);

                    List<ReturnOrderLineItem> carePlusRoliList = new List<ReturnOrderLineItem>();
                    
                    //23 08 25 hyungho.chun 양품만있을때 수불처리용
                    // List<ReturnOrderLineItem> goodRoliList = new List<ReturnOrderLineItem>();
                    Set<String> carePlusOrderNumSet = new Set<String>(); //23 09 13 hyungho.chun
                    System.debug( ' itemList?? ' +  itemList );
                    System.debug( ' dupUpdateList?? ' +  dupUpdateList );

                    if(!(itemList.size() != dupCheckList.size() && dupUpdateList.size()==0)){

                        for (ReturnOrderLineItem roli : (itemList.size() == dupCheckList.size()) ? itemList   : dupUpdateList) {
                            if (roli.Order_CHNL_TYPE_Code__c == EX_ConsumableUtil.CONSUMABLE_BESTSHOP) {
                                carePlusRoliList.add(roli);
                                carePlusOrderNumSet.add(roli.Order_Number__c);
                            }
                            //폐기수량용 리스트
                            //23 08 25 hyungho.chun 양품폐기만있는경우도있어서 걍 다 넣어줌
                            // if (roli.DISPOSAL_Quantity__c != null && roli.DISPOSAL_Quantity__c > 0) {
                            // }else{
                            //     //23 08 25 hyungho.chun 양품만있을때 수불처리용
                            //     goodRoliList.add(roli);
                            // }

                            // disposalRoliList.add(roli);
                            disposalRoliMap.put(roli.Order_Number__c + '*' + roli.SUB_Order_Number__c + '*' + roli.Parts_Number__c, roli);

                        }


                        if (!disposal_RO_Insert_List.isEmpty()) {
                                List<String> onList = new List<String>();
                                
                            
                                List<ReturnOrder> newDisposal_RO_Insert_List = new List<ReturnOrder>();
                                List<ReturnOrderLineItem> newDisposal_ROLI_Insert_List = new List<ReturnOrderLineItem>();

                                for (ReturnOrder disRo : disposal_RO_Insert_List) {
                                    if (!failOrderNum.contains(disRo.Order_number__c)) {
                                        newDisposal_RO_Insert_List.add(disRo);
                                    }
                                }
                                System.debug('disposal_RO_Insert_List' + disposal_RO_Insert_List);

                                System.debug('newDisposal_RO_Insert_List ???' + newDisposal_RO_Insert_List);
                                System.debug('newDisposal_RO_Insert_List.size ???' + newDisposal_RO_Insert_List.size());

                                insert newDisposal_RO_Insert_List; //ReturnOrder INSERT
                                if (!disposal_ROLI_Insert_List.isEmpty()) {

                                    for (ReturnOrderLineItem disRoli : disposal_ROLI_Insert_List) {
                                        if (!failOrderNum.contains(disRoli.Order_number__c)) {
                                            newDisposal_ROLI_Insert_List.add(disRoli);
                                        }
                                    }



                                    for (ReturnOrderLineItem childROLI : newDisposal_ROLI_Insert_List) {
                                        if (!newDisposal_RO_Insert_List.isEmpty()) {
                                            for (ReturnOrder parentRo : newDisposal_RO_Insert_List) {
                                                String childROLIOrderNo = childROLI.Order_Number__c;
                                                String parentRoOrderNo = parentRo.Order_Number__c;
                                                system.debug('childROLIOrderNo:' + childROLIOrderNo);
                                                system.debug('parentRoOrderNo:' + parentRoOrderNo);
                                                if (parentRoOrderNo != null && childROLIOrderNo != null && parentRoOrderNo.equals(childROLIOrderNo)) {
                                                    childROLI.ReturnOrderId = parentRo.Id;

                                                    break;
                                                }
                                            }
                                        }
                                    }
                                    System.debug('===============TEST=====================');
                                    System.debug('disposal_ROLI_Insert_List : ' + newDisposal_ROLI_Insert_List);
                                    System.debug('newDisposal_RO_Insert_List : ' + newDisposal_RO_Insert_List);
                                    //24.02.27 gw.lee
                                    //폐기 중복 생성건 방어로직 추가
                                    if (newDisposal_ROLI_Insert_List.size() > 0) {
                                            String roliQuery = '';
                                            roliQuery += 'SELECT ID, ReturnOrderId, Order_Number__c, SUB_Order_Number__c, Parts_Number__c FROM ReturnOrderLineItem WHERE RecordTypeId = \''+ EX_ConsumableUtil.ROLI_DISPOSAL_RECORDTYPE_ID + '\' AND (';
                                            // roliQuery += 'SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrderLineItem');
                                            // roliQuery += ' , ProductRequestLineItem.Parent.Department_Id__c , ProductRequestLineItem.SR_SALE__r.SALE_Number__c ';
                                            // roliQuery += ' , ProductRequestLineItem.SALE_Number__c, ProductRequestLineItem.Order_Number__c ';
                                            // roliQuery += ' FROM ReturnOrderLineItem WHERE RecordTypeId = \''+ EX_ConsumableUtil.ROLI_DISPOSAL_RECORDTYPE_ID + '\' AND (';
                                        
                                            for (ReturnOrderLineItem roli : newDisposal_ROLI_Insert_List) {

                                                roliQuery += ' ( Order_Number__c = \'' + roli.Order_Number__c + '\'  AND ';
                                                roliQuery += ' SUB_Order_Number__c = \'' + roli.SUB_Order_Number__c + '\'  AND ';
                                                roliQuery += ' Parts_Number__c = \'' + roli.Parts_Number__c + '\' ) OR ';
                                            }
                                            roliQuery = roliQuery.removeEnd('OR ');
                                            roliQuery += ')';
                                            List<ReturnOrderLineItem> roliDupList = Database.Query(roliQuery);
                                            
                                        if (roliDupList.size() != 0) {
                                            Set<String> deleteRo = new Set<String>();
                                            Set<String> elseInterRoli = new Set<String>();
                                            List<ReturnOrderLineItem> ReNewDisposal_ROLI_Insert_List = new List<ReturnOrderLineItem>();
                                            for (ReturnOrderLineItem dup : roliDupList) {
                                                elseInterRoli.add(dup.Order_Number__c + '*' + dup.SUB_Order_Number__c + '*' + dup.Parts_Number__c);
                                                disposalRoliMap.remove(dup.Order_Number__c + '*' + dup.SUB_Order_Number__c + '*' + dup.Parts_Number__c);
                                            }

                                            for (ReturnOrderLineItem dupRoli : newDisposal_ROLI_Insert_List) {
                                                if (!elseInterRoli.contains(dupRoli.Order_Number__c + '*' + dupRoli.SUB_Order_Number__c + '*' + dupRoli.Parts_Number__c)) {
                                                    // disposalRoliList.add(dupRoli);
                                                    ReNewDisposal_ROLI_Insert_List.add(dupRoli);
                                                } else {
                                                    deleteRo.add(dupRoli.ReturnOrderId);
                                                    failOrderNum.add(dupRoli.Order_Number__c);
                                                }
                                            }
                                            returnMap.put('failOrderNum', failOrderNum);
                                            returnMap.put('resultMessage', '이미 조치된 폐기건이 존재합니다.');
                                            // delete disposal_RO_Insert_List;
                                            List<ReturnOrder> deletRo =[SELECT Id FROM ReturnOrder WHERE ID IN: deleteRo];

                                            delete deletRo;
                                            insert ReNewDisposal_ROLI_Insert_List;
                                        } else {
                                            // disposalRoliList = newDisposal_ROLI_Insert_List;
                                            insert newDisposal_ROLI_Insert_List;
                                        }
                                    }
                                }
                            }
                            //폐기건 있으면
                            if (!disposalRoliMap.isEmpty()) {
                                disposalRoliList = new Map<String, ReturnOrderLineItem>(disposalRoliMap).values();
                                Map<String, Object> infoMap = new Map<String, Object>();
                                infoMap.put('handleDisposalReturnOrderLineItem', disposalRoliList);
                                system.debug( 'doApplyProductItem 직전 infoMap : '+infoMap);
                                //[AK]소모품 반품 폐기 : 적치장소 폐기예정수량 (-)
                                doApplyProductItem(infoMap);
                            }
                    } else {
                        returnMap.put('resultMessage', returnMap.get('resultMessage') + '조건에러');
                    }

                    
                    
                }

             
            } catch (Exception e) {
                returnMap.put('resultState', 'ERROR');
                returnMap.put('resultMessage', e.getMessage());
                Database.rollback(sp);
            }


        }
        if (failOrderNum.size() > 0) {
            returnMap.put('failOrder' , failOrderNum);
            returnMap.put('failOrderId', failOrderId);
        }
        return returnMap;
    }

    /**
        * @description 반품 반려 처리
        * @param selectedRows
        * @author I2MAX.JIEUNSONG
        * @return Map<String, Object>
        */
    @AuraEnabled
    public static Map<String, Object> doRefundDeclined(List<Object> selectedRows) {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<ReturnOrderLineItem> itemList = new List<ReturnOrderLineItem>();
        // List<ProductRequestLineItem> updatePrliList = new List<ProductRequestLineItem>(); //24 01 26 hyungho.chun 원주문 상세 반품반려 넣어줄 필요 없다.

        String itemId;

        try {
            for (Object row : selectedRows) {
                Map<String, Object> selectedMap = new Map<String, Object>();
                selectedMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(row));
                System.debug('selectedMap :: ' + selectedMap);
                ReturnOrderLineItem item = new ReturnOrderLineItem();
                itemId = selectedMap.get('Id').toString();

                //24 01 25 hyungho.chun 반품반려시 원prli detail에도 반품반려 상태값 update
                // ProductRequestLineItem prli = new ProductRequestLineItem(); //24 01 26 hyungho.chun 원주문 상세 반품반려 넣어줄 필요 없다.

                String refundDeclinedQuery = '';
                refundDeclinedQuery += ' SELECT Id, Order_Number__c, Expected_Return_Quantity__c, ';
                refundDeclinedQuery += ' Request_Number__c, Request_SEQ__c, ProductRequest__r.Order_Date__c, ProductRequest__r.BILL_TO_CODE__c, ';
                refundDeclinedQuery += ' Product2.DIV_CODE__c, ProductRequestLineItem.MODEL_Code__c, Product2.Name, ProductRequestLineItem.QuantityRequested, ProductRequestLineItemId, Product2.MODEL_CODE__c, ';
                refundDeclinedQuery += ' ProductRequestLineItem.SHIP_QTY__c, ProductRequestLineItem.CANCEL_Quantity__c, Order_CHNL_TYPE_Code__c, Consumables_Order_Status__c, CONSUMABLES_ERROR__c, Return_Order_Approval_Reason__c, ';
                refundDeclinedQuery += ' CONSIGNEE_Name__c, ProductRequest__r.SHIP_TO_CODE__c, ProductRequestLineItem.CONSIGNEE_PostalCode__c, CONSIGNEE_PostalCode__c, CONSIGNEE_Address__c, CONSIGNEE_Address_DETAIL__c, CONSIGNEE_TPNO__c, ';
                refundDeclinedQuery += ' ProductRequest__r.Description, ';
                refundDeclinedQuery += ' ProductRequest__r.Order_Number__c, ';
                refundDeclinedQuery += ' ProductRequestLineItem.fm_UnitPrice__c, ProductRequestLineItem.UnitPrice__c, ProductRequestLineItem.Parent.CAREPLUS_Order_Requester_Class_Code__c, ';

                //23 11 21 hyungho.chun soql쿼리 에러 (필드추가)
                refundDeclinedQuery += ' isMig__c, ProductRequestLineItem.Parent.Order_Number__c, ProductRequestLineItem.Parent.Order_Date__c, ProductRequestLineItem.Parent.BILL_TO_CODE__c, ProductRequestLineItem.Parent.SHIP_TO_CODE__c, ProductRequestLineItem.Parent.Description   ';

                refundDeclinedQuery += ' FROM ReturnOrderLineItem WHERE Id = :itemId LIMIT 1';
                System.debug('refundDeclinedQuery :: ' + refundDeclinedQuery);
                item = Database.query(refundDeclinedQuery);
                System.debug('반품 반려 대상 ID : ' + item.id);

                //24 01 25 hyungho.chun
                // prli = [SELECT ID, Consumables_Order_Detail__c FROM ProductRequestLineItem WHERE Id =: item.ProductRequestLineItemId LIMIT 1]; //24 01 26 hyungho.chun 원주문 상세 반품반려 넣어줄 필요 없다.

                //반품반려 조건 : 주문채널이 베스트샵, 주문상태가 = 반품대기(102), 소모품오류 = 반품오류 포함시 반품반려 가능
                if (((item.Order_CHNL_TYPE_Code__c != null && item.Order_CHNL_TYPE_Code__c == 'BestShop') && (item.Consumables_Order_Status__c != null && item.Consumables_Order_Status__c == '102'))
                        || (item.isMig__c)) {
                            //(item.CONSUMABLES_ERROR__c != null && (item.CONSUMABLES_ERROR__c == '반품오류' || item.CONSUMABLES_ERROR__c.contains('반품오류'))) ||  //24 01 31 hyungho.chun 해당조건 삭제 어떤경우던 반품대기상태라면 반품반려가능함 

                    //반려처리 하는 부분
                    item.Consumables_Order_Status__c = '110'; //110 -- '반품반려'
                    item.Return_Order_Approval_Reason__c = '반품 오류(주문건 매칭 불가)에 따른 수동 반려';

                    //prli.Consumables_Order_Detail__c = '110'; //24 01 25 hyungho.chun //24 01 26 hyungho.chun 원주문 상세 반품반려 넣어줄 필요 없다.

                    returnMap.put('resultState', 'SUCCESS');
                    returnMap.put('resultMessage', '반품 반려 완료');
                    System.debug('반품반려 완료 ');

                } else {
                    System.debug('반품 반려 대상이 아닌 내역 선택. ');
                    throw new AuraHandledException('반품 반려 대상이 아닌 내역이 선택되었습니다.');
                }
                itemList.add(item);
                // updatePrliList.add(prli); //24 01 26 hyungho.chun 원주문 상세 반품반려 넣어줄 필요 없다.
            }

            System.debug('itemList 반품내역 목록  : ' + itemList);
            if (itemList.size() > 0) {
                //SI_BackIF 생성
                List<SI_CAREPLUS_BACKIF__c> backIFList = new List<SI_CAREPLUS_BACKIF__c>();

                SI_CAREPLUS_BACKIF__c getMax = [SELECT INTERFACE_ID__c FROM SI_CAREPLUS_BACKIF__c ORDER BY INTERFACE_ID__c DESC LIMIT 1];
                Decimal maxNum = 1;
                if (getMax.INTERFACE_ID__c != null && getMax.INTERFACE_ID__c > 0) {
                    maxNum = getMax.INTERFACE_ID__c + 1;
                }
                Decimal maxSubNum = 1;

                for (ReturnOrderLineItem item : itemList) {
                    Map<String, Object> infoMap = setCarePlusBackIFData(item, maxNum, maxSubNum, 'REJECTED');
                    SI_CAREPLUS_BACKIF__c backIF = (SI_CAREPLUS_BACKIF__c) infoMap.get('backIF');
                    maxNum = (Decimal) infoMap.get('maxNum');
                    maxSubNum = (Decimal) infoMap.get('maxSubnum');
                    backIFList.add(backIF);
                }
                if (!backIFList.isEmpty()) {
                    insert backIFList;
                    System.debug('backIFList insert 완료 : ' + backIFList);
                }
                if (!itemList.isEmpty()) {
                    update itemList;
                    System.debug('ReturnOrderLineItem List Update 완료 : ' + itemList);
                }
                //24 01 26 hyungho.chun 원주문 상세 반품반려 넣어줄 필요 없다.
                // if(!updatePrliList.isEmpty()){
                //     update updatePrliList;
                //     System.debug('ProductRequestLineItem List Update 완료 : ' + updatePrliList);
                // }

            }

        } catch (AuraHandledException ae) {
            System.debug(ae.getMessage());
            System.debug(ae.getStackTraceString());                        
            returnMap.put('resultState', 'ERROR');
            returnMap.put('resultMessage', '반품반려대상이 아닌건이 선택되었습니다. 주문채널=베스트샵 & 주문상태=반품대기&반품오류 건만 가능합니다. ');
            System.debug('반품 반려 대상이 아님 ');
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            returnMap.put('resultState', 'ERROR');
            returnMap.put('resultMessage', 'Unknown ERROR ');
        }

        return returnMap;
    }
    /**
     * @description 배송지 수정 업데이트
     * @param cId
     * @param cName
     * @param cTPNO
     * @param cPostalCode
     * @param cAddressDetail
     * @param cDeliveryMessage
     * @author I2MAX.JIEUNSONG
     * @return Map<String, Object>
     */
    @AuraEnabled
    public static Map<String, Object> doChangeAddress(String cId, String cName, String cTPNO, String cPostalCode, String cAddress, String cAddressDetail, String cDeliveryMessage) {
        Map<String, Object> returnMap = new Map<String, Object>();

        if (cId == null || cId.equals('')) {
            returnMap.put('resultState', 'ERROR');
            returnMap.put('resultMessage', '반품내역을 선택해주세요 ');
            System.debug('선택된 내역이 없음');
        } else {
            String returnOrderId = cId;
            ReturnOrder ro;

            //2023.10.13 seung yoon heo 수취인 전화번호 val check
            if (cTPNO != null) {
                try{
                    String checkNo = cTPNO;
                    CM_CommonUtil cmUtil = new CM_CommonUtil();
                    String checkTelNoValidMessage = cmUtil.checkValidTelNo(checkNo);
                    if(!String.isEmpty(checkTelNoValidMessage)) {
                        // 전화번호가 유호 하지 않는 경우 처리 케이스.
                        returnMap.put('resultState', 'ERROR');
                        // returnMap.put('isPhoneVal' , checkTelNoValidMessage);
                        checkTelNoValidMessage = '받는분(수취인) 전화번호가 유효하지 않습니다.';
                        returnMap.put('resultMessage' , checkTelNoValidMessage);
                        return returnMap;
                    }
                } catch (Exception e){
                    System.debug(e.getLineNumber() + ' Line || ' + e.getMessage());
                    // throw new AuraHandledException(e.getLineNumber() + ' Line || ' + e.getMessage());
                    returnMap.put('resultState', 'ERROR');
                    // returnMap.put('isPhoneVal' , checkTelNoValidMessage);
                    
                    returnMap.put('resultMessage' , '받는분(수취인) 전화번호가 유효하지 않습니다.');
                    return returnMap;
                }
            }

            
            System.debug('returnOrderId -> ' + returnOrderId);
            // System.debug('returnOrderId2 -> ' + [SELECT CONSIGNEE_Name__c, CONSIGNEE_TPNO_1__c, CONSIGNEE_Address__c, CONSIGNEE_PostalCode__c, CONSIGNEE_Address_DETAIL__c, Delivery_Message_CONTENT__c    FROM ReturnOrder]);

            ro = [
                    SELECT CONSIGNEE_Name__c, CONSIGNEE_TPNO_1__c, CONSIGNEE_Address__c, CONSIGNEE_PostalCode__c,
                            CONSIGNEE_Address_DETAIL__c, Delivery_Message_CONTENT__c
                    FROM ReturnOrder
                    WHERE Id = :returnOrderId
            ];

            System.debug('is NULL2 ??? >>' + ro);

            if (cName == ro.CONSIGNEE_Name__c &&
                    cTPNO == ro.CONSIGNEE_TPNO_1__c &&
                    cPostalCode == ro.CONSIGNEE_PostalCode__c &&
                    cAddress == ro.CONSIGNEE_Address__c && cAddressDetail == ro.CONSIGNEE_Address_DETAIL__c &&
                    cPostalCode == ro.CONSIGNEE_PostalCode__c &&
                    cDeliveryMessage == ro.Delivery_Message_CONTENT__c) {
                returnMap.put('resultState', 'ERROR');
                returnMap.put('resultMessage', '수정된 내역이 없습니다.');
            }
            //수거여부가 'N'인 경우만 배송지수정 가능
//            else if (rolis[0].COLLECTION_YN__c != false) {
//                returnMap.put('resultState', 'ERROR');
//                returnMap.put('resultMessage', '수거여부가 \'N\'인 경우만 배송지수정이 가능합니다.');
//            }

            else {
                if (cName != null && cName != ro.CONSIGNEE_Name__c) {
                    ro.CONSIGNEE_Name__c = cName;
                }
                if (cTPNO != null && cTPNO != ro.CONSIGNEE_TPNO_1__c) {
                    ro.CONSIGNEE_TPNO_1__c = DN_CommonUtil.setTelnumFormat(cTPNO);
                }
                if (cPostalCode != null && cPostalCode != ro.CONSIGNEE_PostalCode__c) {
                    ro.CONSIGNEE_PostalCode__c = cPostalCode;
                }
                if (cAddress != null && cAddress != ro.CONSIGNEE_Address__c) {
                    ro.CONSIGNEE_Address__c = cAddress;
                }
                if (cAddressDetail != null && cAddressDetail != ro.CONSIGNEE_Address_DETAIL__c) {
                    ro.CONSIGNEE_Address_DETAIL__c = cAddressDetail;
                    System.debug('CONSIGNEE_Address_DETAIL__c -> ' + ro.CONSIGNEE_Address_DETAIL__c);
                }
                if (cDeliveryMessage != null && cDeliveryMessage != ro.Delivery_Message_CONTENT__c) {
                    ro.Delivery_Message_CONTENT__c = cDeliveryMessage;
                    System.debug('Delivery_Message_CONTENT__c -> ' + ro.Delivery_Message_CONTENT__c);
                }

                update ro; //배송메세지 업데이트

                try {
                    //update roliItem;
                    returnMap.put('resultState', 'SUCCESS');
                    returnMap.put('resultMessage', '배송지 수정 완료.');
                } catch (Exception e) {
                    returnMap.put('resultState', 'ERROR');
                    returnMap.put('resultMessage', e.getMessage());
                }

            }
        }
        return returnMap;
    }

    /**
   * @description 반품 건의 Back IF Data 세팅
   * @param item
   * @param maxNum
   * @param maxSubnum
   * @author I2MAX.SEOKHOLEE
   * @return Map<String, Object>
   */
    @AuraEnabled
    public static Map<String, Object> doReturnOrderConfirm(Map<String, Object> paramMap) {
        System.debug('doReturnOrderConfirm !!!');
        Map<String, Object> returnMap = new Map<String, Object>();
        Boolean boolIsSuccess = true;
        String strErrMsg = '';

        //23.09.01 PHJ
        String returnConfirmReason = JSON.serialize(paramMap.get('textAreaVal')).replace('"', '');
        // System.debug('is not null1?>?>'+paramMap);
        // System.debug('is not null2?>?>'+returnConfirmReason);
        // System.debug('is not null3?>?>'+UserInfo.getUserId());

        List<Object> returnOrderLineItemIdSet = (List<Object>) paramMap.get('returnOrderLineItemIdList');
        List<ReturnOrder> roList = null;
        Set<String> roliIdSet = new Set<String>();
        Map<String, Object> paramMap2 = null;
        for (Object obj : returnOrderLineItemIdSet) {
            roliIdSet.add(String.valueOf(obj));
        }
        //2024.03.06 seung yoon heo 채널 obs인건인지 확인하기 위한 set
        Set<String> checkObs = new Set<String>();
        //24 02 28 hyungho.chun 화면에서 roli아이디 하나받지만 모수돌릴땐 ro(부모)가 같은 roli 전부 묶어서 모수잡음  // roliIdSet은 화면에서 한개만 받음
        String roId = [SELECT Id, ReturnOrderId FROM ReturnOrderLineItem WHERE Id IN: roliIdSet][0].ReturnOrderId;
        List<ReturnOrderLineItem> tempRoLiList = [SELECT Id, Order_CHNL_TYPE_Code__c FROM ReturnOrderLineItem WHERE ReturnOrderId =: roId];
        for(ReturnOrderLineItem item : tempRoLiList){
            roliIdSet.add(item.Id);
            checkObs.add(item.Order_CHNL_TYPE_Code__c);
        }

        //23 10 01 hyungho.chun 현금영수증 경우 detail을 환불때 바라보는데 운영데이터에 detail없어서 미리 예외처리
        // List<ReturnorderLineItem> roliTempList= [SELECT id, Order_Number__c FROM ReturnorderLineItem WHERE Id IN: roliIdSet];
        // Set<String> orderNumTempList = new Set<String>();
        // Set<String> saleIdSet = new Set<String>();
        // for(ReturnorderLineItem item : roliTempList){
        //     orderNumTempList.add(item.Order_Number__c);
        // }

        // List<ProductRequest> prList = [
        //         SELECT Id, SR_SALE__c
        //         FROM ProductRequest
        //         WHERE Order_Number__c IN:orderNumTempList
        //         AND Consumables_Order_YN__c = TRUE
        //         AND Consumables_Order_USE_YN__c = TRUE
        //         AND SR_SALE__c != NULL
        //         AND SALE_Number__c != NULL
        //         AND (RecordType.DeveloperName = 'Consumable' OR RecordType.DeveloperName='CareSupplies')
        // ];
        
        // for (ProductRequest pr : prList) {
        //     System.debug('pr :: ' + pr);
        //     saleIdSet.add(pr.SR_SALE__c);
        // }

        // SR_AR_CONFIRM__c[] kBlacks = [
        //         SELECT Id, SR_PAYMENT_BASIS_ID__r.SR_SALE_ID__c, TID_CASH__c, TID__c,
        //                 APPR_NUM__c, DEPOSIT_TYPE__c, UPAD_DETAIL_TYPE__c, INVOICE_ISSUE_TYPE__c, PAY_CUST_NAME__c, PAY_CUST_PHONE__c, 
        //                 AR_INVOICE_NO__c, DEPOSIT_AMT__c, SR_PAYMENT_BASIS_ID__r.BASIS_NO__c, POINT_TRX_ID__c
        //         FROM SR_AR_CONFIRM__c
        //         WHERE SR_PAYMENT_BASIS_ID__r.SR_SALE_ID__c IN:saleIdSet
        //         AND FM_RED_BLACK__c = 'B'
        //         AND LAST_SR_AR_CONFIRM_ID__c = NULL
        // ];

        // System.debug('kBlacks :: ' + kBlacks);
        // System.debug('kBlacks.size() :: ' + kBlacks.size());

        // if(kBlacks[0].INVOICE_ISSUE_TYPE__c == 'B'){
        //     SR_PRE_PAYMENT_DETAIL__c aContext = (SR_PRE_PAYMENT_DETAIL__c) SUtil.oneOrNull([
        //         SELECT Id, INVOICE_ISSUE_TYPE__c, TID_CASH__c, APPR_NUM__c, TID__c, POINT_TRX_ID__c
        //         FROM SR_PRE_PAYMENT_DETAIL__c
        //         WHERE TID_CASH__c =: kBlacks[0].TID_CASH__c AND APPR_NUM__c =: kBlacks[0].APPR_NUM__c
        //         LIMIT 1
        //     ]);

        //     if(aContext == null){
        //         System.debug('주문번호에 맞는 SR_PRE_PAYMENT_DETAIL__c 가 없음');
        //         returnMap.put('errorReason','DetailMissing');
        //         returnMap.put('errorMessage','주문 결제 이력이 없습니다. 관리자에게 문의하세요.');                
        //         return returnMap;
        //     }
        // }
        
        
        

        // try {
            if (!roliIdSet.isEmpty()) {
                // returnMap = EX_ReturnOrderConfirm.doReturnOrderConfirm(roliIdSet);
                paramMap2 = EX_ConsumableUtil.preWorkReturnConfirm(roliIdSet);
                roList = (List<ReturnOrder>) paramMap2.get('roList');
                returnMap = EX_ConsumableUtil.doReturnOrderConfirm2(paramMap2, roList);

                //23 08 21 hyungho.chun 반품확정버튼-> 환불로직추가
                List<String> failOrderNumberList = (List<String>) paramMap2.get('failOrderNumberList');
                
                List<ReturnOrder> refundRoList = new List<ReturnOrder>();
                List<String> orderNoList = new List<String>();
                for (ReturnOrder ro : roList) {
                    if (!failOrderNumberList.contains(ro.Order_Number__c)) {
                        refundRoList.add(ro);
                        orderNoList.add(ro.Order_Number__c);
                    }
                }

                //23 12 09 hyungho.chun 수거여부 업데이트 화면에서 받아서함
                Boolean collectionYN = (Boolean)paramMap.get('collectionYN');

                //23.09.01 PHJ
                if(returnConfirmReason != null){
                    if (checkObs.contains('B')) {
                        //2024.03.06 seung yoon heo obs건 화면에서 반품확정시 모수 잡히게 info값 update
                        List<SR_ONLINE_DELIVERY_INFO__c> updateInfo = [SELECT ORDER_TYPE__c,IF_YN__c,PARTNER_CODE__c,DELIVERY_STATUS_CODE__c  FROM SR_ONLINE_DELIVERY_INFO__c WHERE ReturnOrderLineItem__c IN: roliIdSet AND DELIVERY_STATUS_CODE__c = '10'];
                        if (updateInfo.size() > 0) {
                            for (SR_ONLINE_DELIVERY_INFO__c info : updateInfo) {
                                info.ORDER_TYPE__c = 'R';
                                info.IF_YN__c = true;
                                info.PARTNER_CODE__c = 'FULFILLMENT';
                                info.DELIVERY_STATUS_CODE__c = '70';
                            }
                            update updateInfo;
                        }
                        
                    }
                    //23 12 09 hyungho.chun 아이디 기준말고 반품주문번호기준으로 찾는다 (SALE_DEFICIT 타입도 업데이트치려고)
                    List<ReturnOrderLineItem> roliListTemp = [SELECT Id, Return_Order_CONFIRM_DTM__c FROM ReturnOrderLineItem WHERE Id IN: roliIdSet];
                    DateTime confirmedDate = roliListTemp[0].Return_Order_CONFIRM_DTM__c;
                    // List<ReturnOrderLineItem> roliList = [SELECT Id, CONFIRM_Reason__c, CONFIRM_User_Id__c FROM ReturnOrderLineItem WHERE Order_number__c IN: orderNoList AND RecordType.DeveloperName IN ('Consumable','SALE_DEFICIT')]; //24 01 29 hyungho.chun RecordType.DeveloperName IN ('Consumable','SALE_DEFICIT') 추가 (인덱스용)
                    List<ReturnOrderLineItem> roliList = [SELECT Id, CONFIRM_Reason__c, CONFIRM_User_Id__c FROM ReturnOrderLineItem WHERE Order_number__c IN: orderNoList AND RecordType.DeveloperName IN ('Consumable','SALE_DEFICIT') AND Return_Order_CONFIRM_DTM__c =: confirmedDate]; // 24 03 14 hyungho.chun 같은 주문번호 다른 returnOrder 정보도 업데이트됨 방어로 확정날짜같은거로만 검색
                    User currentUser = [SELECT Id, EmployeeNumber__c FROM User WHERE Id =: UserInfo.getUserId()];
                    // System.debug('is not null?>?>4'+roliList);
                    // System.debug('is not null?>?>4'+currentUser);
                    for(ReturnOrderLineItem roli : roliList){
                        roli.CONFIRM_Reason__c = returnConfirmReason.replace('\\n', '');
                        roli.CONFIRM_User_Id__c = currentUser.EmployeeNumber__c;
                        roli.COLLECTION_YN__c  = collectionYN;
                        update roli;
                    }
                }
        
                Database.executeBatch(new EX_Refund_ba(refundRoList, paramMap2), 1);                
            }
        // } catch (Exception e) {
        //     boolIsSuccess = false;
        //     System.debug('[Error] line:' + e.getMessage());
        //     strErrMsg = '[Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage();
        // }

//        returnMap.put('isSuccess', returnMap.get('isSuccess'));
//        returnMap.put('errMsg', returnMap.get('error'));
        return returnMap;
    }

    /**
     * @description 반품 건의 Back IF Data 세팅
     * @param item
     * @param maxNum
     * @param maxSubnum
     * @author I2MAX.SEOKHOLEE
     * @return Map<String, Object>
     */
    public static Map<String, Object> setCarePlusBackIFData(ReturnOrderLineItem item, Decimal maxNum, Decimal maxSubnum, String backStatus) {
        Map<String, Object> rtnInfoMap = new Map<String, Object>();
//24 01 31 hyungho.chun 
        SI_CAREPLUS_ORDER__c carePlusOrder = [
            SELECT Id, ORDER_DATE__c, BILL_TO_CODE__c, ORDER_PRICE__c, ORDER_AMT__c, SHIP_TO_CODE__c, POSTAL_CODE__c, ORDER_DESCRIPTION__c, RECEIVER_NAME__c, RECEIVER_PHONE_NO__c, BASIC_ADDRESS__c, DETAIL_ADDRESS__c, ORDER_QTY__c, 
            ATTRIBUTE8__c, MODEL_CODE__c, CANCEL_QTY__c, PART_NO__c, DIV_CODE__c     
            FROM SI_CAREPLUS_ORDER__c WHERE TRANS_TYPE__c = 'R' AND ORDER_NO__c =: item.Order_Number__c ORDER BY CreatedDate DESC LIMIT 1];

        SI_CAREPLUS_BACKIF__c backIF = new SI_CAREPLUS_BACKIF__c(); 

        backIF.INTERFACE_ID__c = maxNum++;
        backIF.TRANS_TYPE__c = 'R';
        //트랜잭션 요청타입 :트랜잭션 요청타입(O:매입 주문 생성 요청, C:취소 요청, R:환입 주문 생성 요청)
        //23 08 25 hyungho.chun ProductRequest__c 비어있음
        // backIF.ORDER_NO__c = item.ProductRequest__r.Order_Number__c;
        // backIF.ORDER_NO__c = item.ReturnOrderId.ProductRequest.Order_Number__c;
        backIF.ORDER_NO__c = item.Order_Number__c;
        //23 11 30 hyungho.chun request_no 필수
        backIF.REQUEST_NO__c = item.Order_Number__c;
        // if(item.Request_Number__c != null){
        //     backIF.REQUEST_NO__c = item.Request_Number__c;
        // }
        //23 11 30 hyungho.chun
        backIF.CREATION_DATE__c = Date.today();
        backIF.CREATED_BY__c = 'SYSTEM';
        backIF.LAST_UPDATE_DATE__c = Date.today();
        backIF.LAST_UPDATED_BY__c = 'SYSTEM';


        backIF.REQUEST_SEQ__c = 1;
        
        // backIF.BACK_SUB_SEQ__c = maxSubNum++;
        backIF.BACK_SUB_SEQ__c = maxSubNum; //24 01 30 hyungho.chun seq 증가로 일단 고정 ( 차후 송장번호분리건일때 seq증가하여 만드는 로직 추가 필요할수도있음)
        //23 08 25 hyungho.chun ProductRequest__c 비어있음
        // backIF.ORDER_DATE__c = item.ProductRequest__r.Order_Date__c;
        // backIF.BILL_TO_CODE__c = item.ProductRequest__r.BILL_TO_CODE__c;
        // backIF.ORDER_DATE__c = item.ReturnOrder.ProductRequest.Order_Date__c;
        // backIF.BILL_TO_CODE__c = item.ReturnOrder.ProductRequest.BILL_TO_CODE__c;

        // backIF.ORDER_DATE__c = item.ProductRequestLineItemId != null ? item.ProductRequestLineItem.Parent.Order_Date__c : carePlusOrder.ORDER_DATE__c;
        backIF.ORDER_DATE__c = carePlusOrder.ORDER_DATE__c; //24 01 31 hyungho.chun 
        // backIF.BILL_TO_CODE__c = item.ProductRequestLineItemId != null ? item.ProductRequestLineItem.Parent.BILL_TO_CODE__c : carePlusOrder.BILL_TO_CODE__c;
        backIF.BILL_TO_CODE__c = carePlusOrder.BILL_TO_CODE__c; //24 01 31 hyungho.chun 


        // backIF.DIV_CODE__c = item.Product2.DIV_CODE__c;
        backIF.DIV_CODE__c = carePlusOrder.DIV_CODE__c;
        // backIF.MODEL_CODE__c = item.ProductRequestLineItemId != null ?  item.ProductRequestLineItem.MODEL_Code__c : item.Product2.MODEL_CODE__c; //24 01 31 hyungho.chun 반품반려인경우 prli 연결 없으므로 값 분기처리
        backIF.MODEL_CODE__c = carePlusOrder.MODEL_CODE__c; //24 03 12 hyungho.chun
        backIF.PART_NO__c = carePlusOrder.PART_NO__c;
        
        // backIF.ORDER_QTY__c = item.ProductRequestLineItemId != null ? item.ProductRequestLineItem.QuantityRequested : item.Expected_Return_Quantity__c;   //24 01 31 hyungho.chun 반품반려인경우 prli 연결 없으므로 값 분기처리
        backIF.ORDER_QTY__c = carePlusOrder.ORDER_QTY__c; //24 03 12 hyungho.chun  
        // backIF.SHIPPED_QTY__c = item.ProductRequestLineItemId != null ? item.ProductRequestLineItem.SHIP_QTY__c : 0;
        backIF.SHIPPED_QTY__c = carePlusOrder.ORDER_QTY__c; //24 03 12 hyungho.chun 0을 보내면안됨 prli ship_qty를보내면 부분반품처리가 제대로 안될수있음(예: 1개 반품신청했는데 원주문은 1개보다 많은경우)
        // backIF.CANCEL_QTY__c = item.ProductRequestLineItemId != null ? item.ProductRequestLineItem.CANCEL_Quantity__c : 0;
        backIF.CANCEL_QTY__c = carePlusOrder.CANCEL_QTY__c != null ? carePlusOrder.CANCEL_QTY__c : 0; //24 03 14 hyungho.chun null인경우 0처리
        
        // backIF.ORDER_PRICE__c = item.ProductRequestLineItem.fm_UnitPrice__c;
        //23 11 28 hyungho.chun fm_UnitPrice__c -> UnitPrice__c
        // backIF.ORDER_PRICE__c = item.ProductRequestLineItemId != null ? item.ProductRequestLineItem.UnitPrice__c : carePlusOrder.ORDER_PRICE__c;
        backIF.ORDER_PRICE__c = carePlusOrder.ORDER_PRICE__c; //24 03 12 hyungho.chun
        //주문단가, ProductRequestLineItem.UnitPrice__c OR fm_UnitPrice__c
        // backIF.ORDER_AMT__c = item.ProductRequestLineItemId != null ? (backIF.Order_Price__c * item.ProductRequestLineItem.QuantityRequested) : carePlusOrder.ORDER_AMT__c; //24 01 31 hyungho.chun 반품반려인경우 prli 연결 없으므로 값 분기처리
        backIF.ORDER_AMT__c = carePlusOrder.ORDER_AMT__c; //24 03 12 hyungho.chun 케어플러스 반품주문기준으로 값 기입
        //주문금액, 주문단가 * 수량
        //23 11 28 hyungho.chun SHIP_AMT__c = 0 ---> backStatus 분기
        backIF.SHIP_AMT__c = backStatus == 'RETURNED' ? backIF.ORDER_AMT__c : 0;//Ex_CarePlustOrder 457번째줄 참조
        // backIF.RECEIVER_NAME__c = item.CONSIGNEE_Name__c;
        backIF.RECEIVER_NAME__c = carePlusOrder.RECEIVER_NAME__c; //24 01 31 hyungho.chun 
        

        //23 08 28 hyungho.chun
        // backIF.SHIP_TO_CODE__c = item.ProductRequest__r.SHIP_TO_CODE__c;
        // backIF.SHIP_TO_CODE__c = item.ProductRequestLineItemId != null ? item.ProductRequestLineItem.Parent.SHIP_TO_CODE__c : carePlusOrder.SHIP_TO_CODE__c;
        backIF.SHIP_TO_CODE__c = carePlusOrder.SHIP_TO_CODE__c; //24 01 31 hyungho.chun  

        //23 11 30 hyungho.chun roli에 CONSIGNEE_PostalCode__c 없어서 원주문에서 찾아보냄
        // backIF.POSTAL_CODE__c = item.ProductRequestLineItemId != null ? item.ProductRequestLineItem.CONSIGNEE_PostalCode__c : carePlusOrder.POSTAL_CODE__c;
        backIF.POSTAL_CODE__c = carePlusOrder.POSTAL_CODE__c; //24 01 31 hyungho.chun  

        // backIF.BASIC_ADDRESS__c = item.CONSIGNEE_Address__c;
        backIF.BASIC_ADDRESS__c = carePlusOrder.BASIC_ADDRESS__c;
        
        // backIF.DETAIL_ADDRESS__c = item.CONSIGNEE_Address_DETAIL__c;
        backIF.DETAIL_ADDRESS__c = carePlusOrder.DETAIL_ADDRESS__c;
        
        // backIF.RECEIVER_PHONE_NO__c = item.CONSIGNEE_TPNO__c;
        backIF.RECEIVER_PHONE_NO__c = carePlusOrder.RECEIVER_PHONE_NO__c;  //24 01 31 hyungho.chun 
        backIF.ORIGINAL_REQUEST_NO__c = '';//AS-IS는 값 없음
        backIF.ORIGINAL_REQUEST_SEQ__c = 0;//AS-IS는 값 없음
        backIF.CANCEL_FLAG__c = '';// Ex_CarePlustOrder 77번째줄 참조
        backIF.CANCEL_DATE__c = null;//

        //23 08 25 hyungho.chun ProductRequest__c 비어있음
        // backIF.ORDER_DESCRIPTION__c = item.ProductRequest__r.Description;
        // backIF.ORDER_DESCRIPTION__c = item.ReturnOrder.ProductRequest.Description;
        // backIF.ORDER_DESCRIPTION__c = item.ProductRequestLineItemId != null ? item.ProductRequestLineItem.Parent.Description : carePlusOrder.ORDER_DESCRIPTION__c;
        backIF.ORDER_DESCRIPTION__c = carePlusOrder.ORDER_DESCRIPTION__c;

        backIF.BACK_IF_STATUS__c = backStatus;
        backIF.BACK_IF_ERROR_DESC__c = '';// BILLTOCODE 체크안해서 없음
        backIF.TRANSFER_FLAG__c = 'N';

        // backIF.ATTRIBUTE8__c = item.ProductRequestLineItem.Parent.CAREPLUS_Order_Requester_Class_Code__c != null ? item.ProductRequestLineItem.Parent.CAREPLUS_Order_Requester_Class_Code__c : carePlusOrder.ATTRIBUTE8__c;
        backIF.ATTRIBUTE8__c = carePlusOrder.ATTRIBUTE8__c;

        rtnInfoMap.put('backIF', backIF);
        rtnInfoMap.put('maxNum', maxNum);
        rtnInfoMap.put('maxSubnum', maxSubnum);
        system.debug('rtnInfoMap : '+rtnInfoMap);
        return rtnInfoMap;
    }


    /**
     * @description 4. 수불 처리(Product Transfer, ProductItem / Transaction)
     * @return
     */

    public static Map<String, Object> doApplyProductItem(Map<String, Object> infoMap) {
        List<Map<String, Object>> pListMapRequestInfo = new List<Map<String, Object>>();
        Map<String, Object> mapRequestInfo;
        //23 08 29 hyungho.chun 
        // List<Map<String, Object>> pListMapRequestInfoGood = new List<Map<String, Object>>();
        // Map<String, Object> mapRequestInfoForGood;
        List<Map<String, Object>> pListMapRequestInfoDisposal = new List<Map<String, Object>>();
        Map<String, Object> mapRequestInfoForDisposal;

        Set<String> partIdSet = new Set<String>();
        Set<String> locationIdSet = new Set<String>();

        Set<String> piKeySet = new Set<String>();

        List<ReturnOrderLineItem> handleDisposalReturnOrderLineItems = (List<ReturnOrderLineItem>) infoMap.get('handleDisposalReturnOrderLineItem');
        system.debug('handleDisposalReturnOrderLineItems : '+handleDisposalReturnOrderLineItems);
        List<String> roliIdList = new List<String>();
        for (ReturnOrderLineItem roli : handleDisposalReturnOrderLineItems) {
            roliIdList.add(roli.Id);
        }


        for (ReturnOrderLineItem roli : handleDisposalReturnOrderLineItems) {
            System.debug('start====================');
            //System.debug(roli.ProductRequestLineItem.Product2Id);
            //System.debug(roli.Product2Id);
            System.debug('end====================');

            System.debug('ReturnOrderManagementCtr.doApplyProductItem !!!');
            System.debug('roli.DISPOSAL_Quantity__c : ' + roli.DISPOSAL_Quantity__c);
            System.debug('roli.Good_Quality_Quantity__c : ' + roli.Good_Quality_Quantity__c);
            System.debug('roli.Product2Id : ' + roli.Product2Id);
            System.debug('roli.SourceLocationId : ' + roli.SourceLocationId);
            System.debug('roli.DestinationLocationId : ' + roli.DestinationLocationId);

            // mapRequestInfo = new Map<String, Object>();
            // mapRequestInfo.put('product2Id', roli.Product2Id);

            // //23 08 29 hyungho.chun
            // mapRequestInfoForGood = new Map<String, Object>();
            // mapRequestInfoForGood.put('product2Id', roli.Product2Id);

            mapRequestInfo = new Map<String, Object>();
            mapRequestInfo.put('product2Id', roli.Product2Id);            
            
            mapRequestInfoForDisposal = new Map<String, Object>();
            mapRequestInfoForDisposal.put('product2Id', roli.Product2Id);            

            // //23 08 25 hyungho.chun 양품폐기만있는경우도 고려 -> 0으로 들어감
            // mapRequestInfo.put('requestQTY', roli.DISPOSAL_Quantity__c);
            // mapRequestInfoForGood.put('requestQTY', roli.Good_Quality_Quantity__c);

            mapRequestInfo.put('requestQTY', roli.DISPOSAL_Quantity__c+roli.Good_Quality_Quantity__c);
            mapRequestInfoForDisposal.put('requestQTY', roli.DISPOSAL_Quantity__c);

            // mapRequestInfo.put('productTransfer', null);
            // mapRequestInfoForGood.put('productTransfer', null);

            mapRequestInfo.put('productTransfer', null);
            mapRequestInfoForDisposal.put('productTransfer', null);            

            // mapRequestInfo.put('sourceLocationId', roli.DestinationLocationId);
            // mapRequestInfo.put('destinationLocationId', null);
            // mapRequestInfo.put('requestType', 'AK');

            // mapRequestInfoForGood.put('sourceLocationId', null);
            // mapRequestInfoForGood.put('destinationLocationId', roli.DestinationLocationId);
            // mapRequestInfoForGood.put('requestType', 'W');

            mapRequestInfo.put('sourceLocationId', roli.DestinationLocationId);
            mapRequestInfo.put('destinationLocationId', null);
            mapRequestInfo.put('requestType', '양품및폐기');

            mapRequestInfoForDisposal.put('sourceLocationId', roli.DestinationLocationId);
            mapRequestInfoForDisposal.put('destinationLocationId', null);
            mapRequestInfoForDisposal.put('requestType', '폐기후처리');                        

            // mapRequestInfo.put('productRequestLineItem', null);
            // mapRequestInfo.put('returnOrderLineItem', roli);

            // mapRequestInfoForGood.put('productRequestLineItem', null);
            // mapRequestInfoForGood.put('returnOrderLineItem', roli);

            mapRequestInfo.put('productRequestLineItem', null);
            mapRequestInfo.put('returnOrderLineItem', roli);

            mapRequestInfoForDisposal.put('productRequestLineItem', null);
            mapRequestInfoForDisposal.put('returnOrderLineItem', roli);            

            partIdSet.add(roli.Product2Id);
            locationIdSet.add(roli.SourceLocationId);
            locationIdSet.add(roli.DestinationLocationId);

            // pListMapRequestInfo.add(mapRequestInfo);
            // pListMapRequestInfoGood.add(mapRequestInfoForGood);

            pListMapRequestInfo.add(mapRequestInfo);
            pListMapRequestInfoDisposal.add(mapRequestInfoForDisposal);            

        }
        Map<String, ProductItem> pMapProductItemByKey = new Map<String, ProductItem>();
        String stqProductItemQuery = '';
        //23 10 11 hyungho.chun SObjectUtil호출로 변경
        stqProductItemQuery += 'SELECT ' + String.join(SObjectUtil.getAllFields('ProductItem'), ',');

        stqProductItemQuery += ' FROM ProductItem';
        stqProductItemQuery += ' WHERE Product2Id IN :partIdSet AND LocationId IN :locationIdSet FOR UPDATE';

        System.debug('stqProductItemQuery :: ' + stqProductItemQuery);

        List<ProductItem> productItems = Database.query(stqProductItemQuery);
        system.debug(' productItems : '+productItems);
        String strKeyPI = '';
        for (ProductItem productItem : productItems) {
            strKeyPI = productItem.LocationId + '^' + productItem.Product2Id;
            pMapProductItemByKey.put(strKeyPI, productItem);

        }

        // try { //24 02 02 hyungho.chun exception은 최종단계 doHandleDisposal try catch에서 잡아낸다
            system.debug('pListMapRequestInfo : '+pListMapRequestInfo);
            system.debug('pMapProductItemByKey : '+pMapProductItemByKey);
            //23 08 29 hyungho.chun 폐기 수불처리
            // infoMap.putAll(FS_MaterialUtil.applyProductItem(pListMapRequestInfo, pMapProductItemByKey));
            //23 08 29 hyungho.chun 양품및폐기 모든경우에수에돌림 (총 수량을 폐기예정수량 감소 -> 가용재고 수량 증가)
            infoMap.putAll(applyProductItem(pListMapRequestInfo, pMapProductItemByKey));
            system.debug('pListMapRequestInfoDisposal : '+pListMapRequestInfoDisposal);
            system.debug('pMapProductItemByKey : '+pMapProductItemByKey);
            //23 08 29 hyungho.chun 폐기건수만큼 후처리
            infoMap.putAll(applyProductItem(pListMapRequestInfoDisposal, pMapProductItemByKey));

        // } catch (Exception e) { //24 02 02 hyungho.chun exception은 최종단계 doHandleDisposal try catch에서 잡아낸다
        //     infoMap.put('isSuccess', false);
        //     infoMap.put('error', e.getLineNumber() + 'line : ' + e.getMessage());
        // }

        return infoMap;

    }

    @AuraEnabled
    public static Map<String, Object> doGetConsigneeInfo(String selectedRowId) {
        Map<String, Object> returnMap = new Map<String, Object>();
        System.debug('selectedRowId -> ' + selectedRowId);
        List<ReturnOrderLineItem> rolis = [
                SELECT ReturnOrderId
                FROM ReturnOrderLineItem
                WHERE Id = :selectedRowId
        ];
        String returnOrderId = null;
        ReturnOrder ro;

        if(!Test.isRunningTest()){
            if (rolis.size() > 0) {
                returnOrderId = rolis[0].ReturnOrderId;
                System.debug('returnOrderId -> ' + returnOrderId);
                ro = [
                        SELECT CONSIGNEE_Name__c, CONSIGNEE_TPNO_1__c, CONSIGNEE_Address__c, CONSIGNEE_PostalCode__c,
                                CONSIGNEE_Address_DETAIL__c, Delivery_Message_CONTENT__c
                        FROM ReturnOrder
                        WHERE Id = :returnOrderId
                ];
            }
            System.debug('ro -> ' + ro);

            returnMap.put('roId', ro.Id);
            returnMap.put('consigneeName', ro.CONSIGNEE_Name__c);
            returnMap.put('consigneeTPNO', ro.CONSIGNEE_TPNO_1__c);
            returnMap.put('consigneePostalCode', ro.CONSIGNEE_PostalCode__c);
            returnMap.put('consigneeAddress', ro.CONSIGNEE_Address__c);
            returnMap.put('consigneeAddressDetail', ro.CONSIGNEE_Address_DETAIL__c != null ? ro.CONSIGNEE_Address_DETAIL__c : ' ');
            returnMap.put('deliveryMessage', ro.Delivery_Message_CONTENT__c != null ? ro.Delivery_Message_CONTENT__c : ' ');
        }
        return returnMap;
    }


    public static Map<String, Object> applyProductItem(List<Map<String, Object>> pListMapRequestInfo, Map<String, ProductItem> pMapProductItemByKey){
        Boolean boolIsSuccess = false;
        String strErrMsg = '';

        // try{ //24 02 02 hyungho.chun exception은 최종단계 doHandleDisposal try catch에서 잡아낸다
            List<ProductItem> listUpsertPI = new List<ProductItem>();
            Map<String, ProductItem> mapProductItemByKey = new Map<String, ProductItem>();
            List<ProductItemTransaction> listInsertPIT = new List<ProductItemTransaction>();
            String strProduct2Id = '';
            String strSourceLocationId = '';
            String strDestinationLocationId = '';
            Decimal decRequestQTY = 0;
            String strRequestType = '';
            if(pListMapRequestInfo != null && !pListMapRequestInfo.isEmpty()){
                for(Map<String, Object> mapRequestInfo : pListMapRequestInfo){
                    System.debug('[applyProductItem] mapRequestInfo: ' + JSON.serializePretty(mapRequestInfo));
                    strProduct2Id = mapRequestInfo.get('product2Id') != null ? (String) mapRequestInfo.get('product2Id') : '';
                    strSourceLocationId = mapRequestInfo.get('sourceLocationId') != null ? (String) mapRequestInfo.get('sourceLocationId') : '';
                    strDestinationLocationId = mapRequestInfo.get('destinationLocationId') != null ? (String) mapRequestInfo.get('destinationLocationId') : '';
                    decRequestQTY = mapRequestInfo.get('requestQTY') != null ? (Decimal) mapRequestInfo.get('requestQTY') : 0;
                    strRequestType = mapRequestInfo.get('requestType') != null ? (String) mapRequestInfo.get('requestType') : '';
                    //  Source Location의 재고정보 반영
                    String strKeySourcePI = strSourceLocationId + '^' + strProduct2Id;
                    System.debug('[applyProductItem] strKeySourcePI: ' + strKeySourcePI);
                    //  Destination Location의 재고정보 반영
                    String strKeyDestinationPI = strDestinationLocationId + '^' + strProduct2Id;
                    System.debug('[applyProductItem] strKeyDestinationPI: ' + strKeyDestinationPI);

                    System.debug('[applyProductItem] decRequestQTY: ' + decRequestQTY);

                    System.debug('[strRequestType] strRequestType: ' + strRequestType);

                    switch on strRequestType {
                        when '양품및폐기' {
                            pMapProductItemByKey.putAll(upsertPI('BK', strKeySourcePI, decRequestQTY, (ProductRequestLineItem) mapRequestInfo.get('productRequestLineItem'), (ReturnOrderLineItem) mapRequestInfo.get('returnOrderLineItem'), (ProductTransfer) mapRequestInfo.get('productTransfer'), pMapProductItemByKey));
                        }
                        when '폐기후처리' {
                            pMapProductItemByKey.putAll(upsertPI('AI', strKeySourcePI, decRequestQTY, (ProductRequestLineItem) mapRequestInfo.get('productRequestLineItem'), (ReturnOrderLineItem) mapRequestInfo.get('returnOrderLineItem'), (ProductTransfer) mapRequestInfo.get('productTransfer'), pMapProductItemByKey));
                        }
                    }
                }
            }
            if(!pMapProductItemByKey.isEmpty())     listUpsertPI.addAll(pMapProductItemByKey.values());
            if(!listUpsertPI.isEmpty()){
                System.debug('[applyProductItem] listUpsertPI: ' + JSON.serializePretty(listUpsertPI));
                upsert listUpsertPI;
                mapProductItemByKey = new Map<String, ProductItem>();

                for(ProductItem objPI : listUpsertPI){
                    String strKeyPI = objPI.LocationId + '^' + objPI.Product2Id;
                    System.debug('[applyProductItem] strKeyPI of listUpsertPI: ' + strKeyPI);
                    mapProductItemByKey.put(strKeyPI, objPI);
                }

                if(pListMapRequestInfo != null && !pListMapRequestInfo.isEmpty()){
                    for(Map<String, Object> mapRequestInfo : pListMapRequestInfo){
                        strProduct2Id = mapRequestInfo.get('product2Id') != null ? (String) mapRequestInfo.get('product2Id') : '';
                        strSourceLocationId = mapRequestInfo.get('sourceLocationId') != null ? (String) mapRequestInfo.get('sourceLocationId') : '';
                        strDestinationLocationId = mapRequestInfo.get('destinationLocationId') != null ? (String) mapRequestInfo.get('destinationLocationId') : '';
                        decRequestQTY = mapRequestInfo.get('requestQTY') != null ? (Decimal) mapRequestInfo.get('requestQTY') : 0;
                        strRequestType = mapRequestInfo.get('requestType') != null ? (String) mapRequestInfo.get('requestType') : '';
                        ProductRequestLineItem objPRLI = mapRequestInfo.get('productRequestLineItem') != null ? (ProductRequestLineItem) mapRequestInfo.get('productRequestLineItem') : new ProductRequestLineItem();
                        ReturnOrderLineItem objROLI = mapRequestInfo.get('returnOrderLineItem') != null ? (ReturnOrderLineItem) mapRequestInfo.get('returnOrderLineItem') : new ReturnOrderLineItem();
                        ProductTransfer objPT = mapRequestInfo.get('productTransfer') != null ? (ProductTransfer) mapRequestInfo.get('productTransfer') : new ProductTransfer();
                        String strKeySourcePI = strSourceLocationId + '^' + strProduct2Id;
                        String strKeyDestinationPI = strDestinationLocationId + '^' + strProduct2Id;
                        System.debug('[applyProductItem] mapProductItemByKey: ' + JSON.serializePretty(mapProductItemByKey));
                        System.debug('strRequestType::' +strRequestType);
                        switch on strRequestType {
                            when '양품및폐기'{
                                listInsertPIT.addAll(createPIT('BK', decRequestQTY, strKeySourcePI, objPRLI, objROLI, objPT, mapProductItemByKey));
                            }
                            when '폐기후처리'{
                                listInsertPIT.addAll(createPIT('AI', decRequestQTY, strKeySourcePI, objPRLI, objROLI, objPT, mapProductItemByKey));
                                
                            }

                        }
                    }
                }
            }

            if(!listInsertPIT.isEmpty()){
                System.debug('[applyProductItem] listInsertPIT: ' + JSON.serializePretty(listInsertPIT));
                insert listInsertPIT;
            }
            boolIsSuccess = true;
        // }catch(Exception e){  //24 02 02 hyungho.chun exception은 최종단계 doHandleDisposal try catch에서 잡아낸다
        //     boolIsSuccess = false;
        //     System.debug('[Error] line:' + e.getMessage());
        //     strErrMsg = '[Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage();
        // }

        return new Map<String, Object>{
                'isSuccess' => boolIsSuccess,
                'errMsg' => strErrMsg
        };
    }

    public static Map<String, ProductItem> upsertPI(String pStrRequestType, String pStrKeyPI, Decimal pRequestQTY, ProductRequestLineItem pObjPRLI, ReturnOrderLineItem pObjROLI, ProductTransfer pObjPT, Map<String, ProductItem> pMapProductItemByKey){
        System.debug('[upsertPI] pMapProductItemByKey: ' + JSON.serializePretty(pMapProductItemByKey));
        Map<String, ProductItem> mapPIByKey = new Map<String, ProductItem>();
        ProductItem objPI = new ProductItem();
        if(pMapProductItemBykey.containsKey(pStrKeyPI)){
            // objPI = (ProductItem)pMapProductItemByKey.get(pStrKeyPI); 
            objPI = pMapProductItemByKey.get(pStrKeyPI); //24 03 25 hyungho.chun  FOR UPDATE 안먹혀서 (ProductItem) 제거

        }else{
            objPI.QuantityOnHand = 0;
            List<String> listSplitInfo = new List<String>();
            String strTempKeyPI = pStrKeyPI;
            while(strTempKeyPI.contains('^')){
                listSplitInfo.add(pStrKeyPI.substringBefore('^'));
                strTempKeyPI = pStrKeyPI.substringAfter('^');
            }
            listSplitInfo.add(strTempKeyPI);
            objPI.LocationId = listSplitInfo.get(0);
            objPI.Product2Id = listSplitInfo.get(1);
        }

        if(objPI.LocationId != null && objPI.DEPT_CODE__c == null) {
            List<Schema.Location> listLocation = new List<Schema.Location>();
            listLocation = [
                    SELECT      DEPT_CODE__c
                    FROM        Location
                    WHERE       Id = :objPI.LocationId
                    AND         DEPT_CODE__c != null
            ];
            if(!listLocation.isEmpty()) objPI.DEPT_CODE__c = listLocation[0].DEPT_CODE__c;
            System.debug('objPI.DEPT_CODE__c 세팅 >> ' + objPI.DEPT_CODE__c);
        }
        System.debug('[upsertPI] pStrRequestType: ' + pStrRequestType);
        System.debug('[upsertPI] pRequestQTY: ' + pRequestQTY);
        System.debug('[upsertPI][before] objPI: ' + objPI);
        switch on pStrRequestType {
            when 'BK' {
                //소모품 양품처리
                // objPI.JUNK_ALLOC_QTY__c = (objPI.JUNK_ALLOC_QTY__c == null ? 0 : (objPI.JUNK_ALLOC_QTY__c - pRequestQTY));
                objPI.QuantityOnHand = (objPI.QuantityOnHand == null ? 0 : (objPI.QuantityOnHand + pRequestQTY)); //24 03 02 hyungho.chun 양품+폐기 둘다 일단 보유량 증가시킴
            }
            when 'AI' {
                //  재고이동(보유량)　　|　　AI　　　| (Source)적치장소 FROM: 보유량(-)
                // objPI.QuantityOnHand = (objPI.QuantityOnHand == null ? 0 : (objPI.QuantityOnHand - pRequestQTY));
                objPI.JUNK_ALLOC_QTY__c = (objPI.JUNK_ALLOC_QTY__c == null ? 0 : (objPI.JUNK_ALLOC_QTY__c + pRequestQTY)); //24 03 02 hyungho.chun 폐기건은 폐기예정수량 폐기예정건만큼 증가시킴
            }
        }
        if(objPI.IsDeleted__c = true) objPI.IsDeleted__c = false;
        System.debug('[upsertPI][after] objPI: ' + objPI);
        mapPIByKey.put(pStrKeyPI, objPI);
        System.debug('[upsertPI] mapPIByKey: ' + JSON.serializePretty(mapPIByKey));
        return mapPIByKey;
    }


    public static List<ProductItemTransaction> createPIT(String pStrRequestType, Decimal pDecRequestQTY, String pStrKeyPI, ProductRequestLineItem pObjPRLI, ReturnOrderLineItem pObjROLI, ProductTransfer pObjPT, Map<String, ProductItem> pMapProductItemByKey){
        List<String> listDontCreate = new List<String>{'AF', 'AI', 'AJ'};
        List<ProductItemTransaction> listPITs = new List<ProductItemTransaction>();
        ProductItemTransaction objPIT = new ProductItemTransaction();
        System.debug('pMapProductItemByKey :: ' + pMapProductItemByKey);
        System.debug('pStrKeyPI :: ' + pStrKeyPI);
        ProductItem objPI = (ProductItem) pMapProductItemByKey.get(pStrKeyPI);
        objPIT.TransactionType = 'Adjusted';
        objPIT.ProductItemId = objPI.Id;
        objPIT.Quantity = 0;
        objPIT.RSV_SHIPPED_Quantity__c = pDecRequestQTY;
        objPIT.RSV_SHIPPED_Type_Code__c = pStrRequestType;
        if(pObjPRLI != null && pObjPRLI.Id != null) objPIT.Parts_Request_Line_Item_Id__c = pObjPRLI.Id;
        if(pObjROLI != null && pObjROLI.Id != null) objPIT.Return_Order_Line_Item_Id__c = pObjROLI.Id;
        if(pObjPT != null && pObjPT.Id != null) objPIT.Product_Transfer_Id__c = pObjPT.Id;
        switch on pStrRequestType {
            when 'BK' {
                //소모품 양품 처리
                objPIT.Related_STOCK_Field__c = 'JUNK_ALLOC_QTY__c';
            }
            when 'AI' {
                //  재고이동(보유량)　　|　　AI　　　| (Source)적치장소 FROM: 보유량(-)
            }
        }

        if(!listDontCreate.contains(pStrRequestType)){
            listPITs.add(objPIT);
        }

        return listPITs;
    }

    //24 01 24 hyungho.chun 반품승인버튼 추가
    @AuraEnabled
    public static Map<String, Object> acceptRefund(List<Object> selectedRows) {
        Map<String, Object> returnMap = new Map<String, Object>();
        List<ReturnOrderLineItem> itemList = new List<ReturnOrderLineItem>();
        List<ProductRequestLineItem> updatePrliList = new List<ProductRequestLineItem>();

        String itemId;

        try {
            Boolean atLeastOneGoesWrong = false;
            for (Object row : selectedRows) {
                Map<String, Object> selectedMap = new Map<String, Object>();
                selectedMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(row));
                System.debug('selectedMap :: ' + selectedMap);
                ReturnOrderLineItem item = new ReturnOrderLineItem();
                itemId = selectedMap.get('Id').toString();

                //24 01 25 hyungho.chun 반품반려시 원prli detail에도 반품반려 상태값 update
                ProductRequestLineItem prli = new ProductRequestLineItem();

                String refundDeclinedQuery = '';
                refundDeclinedQuery += ' SELECT Id, Order_Number__c, Expected_Return_Quantity__c, ';
                refundDeclinedQuery += ' Request_Number__c, Request_SEQ__c, ProductRequest__r.Order_Date__c, ProductRequest__r.BILL_TO_CODE__c, ProductRequestLineItem.SALE_Number__c, ';
                refundDeclinedQuery += ' Product2.DIV_CODE__c, ProductRequestLineItem.MODEL_Code__c, Product2.Name, ProductRequestLineItem.QuantityRequested, ProductRequestLineItemId, Product2.MODEL_CODE__c, ';
                refundDeclinedQuery += ' ProductRequestLineItem.SHIP_QTY__c, ProductRequestLineItem.CANCEL_Quantity__c, Order_CHNL_TYPE_Code__c, Consumables_Order_Status__c, CONSUMABLES_ERROR__c, Return_Order_Approval_Reason__c, ';
                refundDeclinedQuery += ' CONSIGNEE_Name__c, ProductRequest__r.SHIP_TO_CODE__c, ProductRequestLineItem.CONSIGNEE_PostalCode__c, CONSIGNEE_PostalCode__c, CONSIGNEE_Address__c, CONSIGNEE_Address_DETAIL__c, CONSIGNEE_TPNO__c, ';
                refundDeclinedQuery += ' ProductRequest__r.Description, ';
                refundDeclinedQuery += ' ProductRequest__r.Order_Number__c, ';
                refundDeclinedQuery += ' ProductRequestLineItem.fm_UnitPrice__c, ProductRequestLineItem.UnitPrice__c, ProductRequestLineItem.Parent.CAREPLUS_Order_Requester_Class_Code__c, ';

                //23 11 21 hyungho.chun soql쿼리 에러 (필드추가)
                refundDeclinedQuery += ' isMig__c, ProductRequestLineItem.Parent.Order_Number__c, ProductRequestLineItem.Parent.Order_Date__c, ProductRequestLineItem.Parent.BILL_TO_CODE__c, ProductRequestLineItem.Parent.SHIP_TO_CODE__c, ProductRequestLineItem.Parent.Description   ';

                refundDeclinedQuery += ' FROM ReturnOrderLineItem WHERE Id = :itemId LIMIT 1';
                System.debug('refundDeclinedQuery :: ' + refundDeclinedQuery);
                item = Database.query(refundDeclinedQuery);
                System.debug('반품 승인 대상 ID : ' + item.id);
                System.debug('반품 승인 대상 ID : ' + item);

                //24 01 25 hyungho.chun
                //24 02 01 hyungho.chun 원주문연결안된건은제외하고 나머지는 성공해야해서 exception처리에서 빼고 따로 처리
                // if(item.ProductRequestLineItemId == null){
                //     System.debug('반품주문에 원주문이연결안된건 ');
                //     throw new AuraHandledException('반품 승인 대상이 아닌 내역이 선택되었습니다. 연결된 원주문이 없습니다.');
                // }
                // prli = [SELECT ID, Consumables_Order_Detail__c FROM ProductRequestLineItem WHERE Id =: item.ProductRequestLineItemId LIMIT 1];

                //반품반려 조건 : 주문채널이 베스트샵, 주문상태가 = 반품대기(102) //24 02 01 hyungho.chun 원주문건연결된 + 원주문이 판매확정찍힌 것만
                if (((item.Order_CHNL_TYPE_Code__c != null && item.Order_CHNL_TYPE_Code__c == 'BestShop') && (item.Consumables_Order_Status__c != null && item.Consumables_Order_Status__c == '102') && (item.ProductRequestLineItemId != null)&& (item.ProductRequestLineItem.SALE_Number__c != null))
                        || (item.isMig__c)) {
                    
                    prli = [SELECT ID, Consumables_Order_Detail__c FROM ProductRequestLineItem WHERE Id =: item.ProductRequestLineItemId LIMIT 1];

                    //반려처리 하는 부분
                    item.Consumables_Order_Status__c = '100'; //100 -- '반품요청'
                    item.Return_Order_Approval_Reason__c = '반품요청 승인';

                    prli.Consumables_Order_Detail__c = '100'; //24 01 25 hyungho.chun
                    
                    if(!atLeastOneGoesWrong){
                        returnMap.put('resultState', 'SUCCESS');
                        returnMap.put('resultMessage', '반품 승인 완료');
                    }
                    System.debug('반품승인 완료 ');

                    itemList.add(item);
                    updatePrliList.add(prli);
                } else {
                    atLeastOneGoesWrong = true;
                    System.debug('반품 승인 대상이 아닌 내역 선택. ');
                    // throw new AuraHandledException('반품 승인 대상이 아닌 내역이 선택되었습니다.'); //24 02 01 hyungho.chun
                    returnMap.put('resultState', 'ERROR');
                    returnMap.put('resultMessage', '원주문과 연결된 반품대기건만 승인 가능합니다.');
                }
                // itemList.add(item);
                // updatePrliList.add(prli);
            }

            System.debug('itemList 반품내역 목록  : ' + itemList);
            if (itemList.size() > 0) {
                //SI_BackIF 생성
                List<SI_CAREPLUS_BACKIF__c> backIFList = new List<SI_CAREPLUS_BACKIF__c>();

                SI_CAREPLUS_BACKIF__c getMax = [SELECT INTERFACE_ID__c FROM SI_CAREPLUS_BACKIF__c ORDER BY INTERFACE_ID__c DESC LIMIT 1];
                Decimal maxNum = 1;
                if (getMax.INTERFACE_ID__c != null && getMax.INTERFACE_ID__c > 0) {
                    maxNum = getMax.INTERFACE_ID__c + 1;
                }
                Decimal maxSubNum = 1;

                for (ReturnOrderLineItem item : itemList) {
                    Map<String, Object> infoMap = setCarePlusBackIFData(item, maxNum, maxSubNum, 'APPROVED');
                    SI_CAREPLUS_BACKIF__c backIF = (SI_CAREPLUS_BACKIF__c) infoMap.get('backIF');
                    maxNum = (Decimal) infoMap.get('maxNum');
                    maxSubNum = (Decimal) infoMap.get('maxSubnum');
                    backIFList.add(backIF);
                }
                if (!backIFList.isEmpty()) {
                    insert backIFList;
                    System.debug('backIFList insert 완료 : ' + backIFList);
                }
                if (!itemList.isEmpty()) {
                    update itemList;
                    System.debug('ReturnOrderLineItem List Update 완료 : ' + itemList);
                }
                if(!updatePrliList.isEmpty()){
                    update updatePrliList;
                    System.debug('ProductRequestLineItem List Update 완료 : ' + updatePrliList);
                }

            }

        } catch (AuraHandledException ae) {
            System.debug(ae.getMessage());
            System.debug(ae.getStackTraceString());            
            returnMap.put('resultState', 'ERROR');
            returnMap.put('resultMessage', '원주문과 연결된 반품대기건만 승인 가능합니다.');
            System.debug('반품 승인 대상이 아님 ');
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            returnMap.put('resultState', 'ERROR');
            returnMap.put('resultMessage', 'Unknown ERROR ');
        }

        return returnMap;
    }



}