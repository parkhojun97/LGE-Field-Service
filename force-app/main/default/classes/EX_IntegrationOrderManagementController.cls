/**
 * Created by I2MAX.SHAHN on 2023-01-06.
 */

 public without sharing class EX_IntegrationOrderManagementController {

    public static Map<Object, String> CONSUMABLE_STATUS_CODE_KOR_MAP = new Map<Object, String>{
            '000' => '품절예약완료',
            '001' => '결제요청',
            '002' => '결제완료',
            '003' => '결제취소',
            '004' => '주문취소',
            '005' => '자동주문취소',
            '006' => '상품준비중',
            '010' => '배송준비중',
            '030' => '배송중',
            '070' => '배송완료',
            '100' => '반품요청',
            '101' => '반품예약',
            '102' => '반품대기',
            '120' => '반품확정',
            '121' => '반품완료',
            '090' => '반품요청철회',
            '130' => '교환요청'
    };

    public static Map<Object, String> CONSUMABLE_DELIVERY_STATUS_CODE_KOR_MAP = new Map<Object, String>{
            '10' => '송장수신',
            '27' => '집하예정',
            '29' => '미집하',
            '30' => '집하',
            '70' => '배송완료',
            '85' => '반송',
            '90' => '취소',
            '99' => '오류'
    };

    //주문상태=(003:결제취소,004:주문취소,005:자동주문취소완료,070:배송완료,110:반품반려,090:반품요청철회,120:반품확정
    public static Set<String> CONSUMABLE_MASKING_STATUS_CODE_SET = new Set<String>{
        '003', '004', '005', '070', '110', '090', '120'
    };

    /**
    * @description Query String에 사용하기 위해 Set 데이터를 String으로 파싱
    * @author 23.01.27 / I2MAX.SEUNGHUNAN
    * @return
    */
    static String setToString(Set<Id> basisOrderIdSet) {
        String str = '';
        for (Id boId : basisOrderIdSet) {
            str += ('\'' + boId + '\'' + ', ');
        }
        return str.lastIndexOf(', ') != -1 ? '(' + str.substring(0, str.lastIndexOf(', ')) + ')' : '';
    }

    /**
    * @description 소모품 통합 주문 관리 최초 조회 데이터
    *
    * @author 23.01.06 / I2MAX.SHAHN
    * @return
    */
    @AuraEnabled
    public static Map<String, Object> doGetInitData() {
        try {
            System.debug('doGetInitData');
            Map<String, Map<String, Object>> mapSettingValue = new Map<String, Map<String, Object>>();

            Map<String, List<Map<String, String>>> mapCommPickLists = new Map<String, List<Map<String, String>>>();

            // 주문 채널
            List<Map<String, String>> listOrderChannel = SObjectUtil.getPicklist('ProductRequestLineItem', 'Order_CHNL_TYPE_Code__c', false);
            mapCommPickLists.put('listOrderChannel', listOrderChannel);
            System.debug('listOrderChannel :: ' + listOrderChannel);

            // 사업부
            List<Map<String, String>> listDepartment = SObjectUtil.getPicklist('ProductRequestLineItem', 'ENDP_Code__c', false);
            mapCommPickLists.put('listDepartment', listDepartment);
            System.debug('listDepartment :: ' + listDepartment);

            // 소모품 주문 진행 상태 코드
            //List<Map<String, String>> listOrderStatusCode = SObjectUtil.getPicklist('ProductRequestLineItem', 'Consumables_Order_Status_Code__c', false);
            List<Map<String, String>> listOrderStatusCode = EX_ConsumableUtil.getExOrderStatusList('ProductRequestLineItem', 'Order');

            mapCommPickLists.put('listOrderStatusCode', listOrderStatusCode);
            System.debug('listOrderStatusCode :: ' + listOrderStatusCode);

            // 약속 상태
//            List<Map<String, String>> listAppointmentStatus = SObjectUtil.getPicklist('ProductRequestLineItem', 'Appointment_Status__c', false);
//            mapCommPickLists.put('listAppointmentStatus', listAppointmentStatus);
//            system.debug('listAppointmentStatus :: ' + listAppointmentStatus);

            List<Map<String, String>> listAppointmentStatus = new List<Map<String, String>>();
            Map<String, String> statusMap = new Map<String, String>();
            statusMap.put('label', '요청');
            statusMap.put('value', '요청');
            Map<String, String> statusMap2 = new Map<String, String>();
            statusMap2.put('label', '입고완료');
            statusMap2.put('value', '입고완료');
            listAppointmentStatus.add(statusMap);
            listAppointmentStatus.add(statusMap2);
            mapCommPickLists.put('listAppointmentStatus', listAppointmentStatus);


            //리턴 값
            mapSettingValue.put('Comm', mapCommPickLists);

            Map<String, Object> mapReturn = new Map<String, Object>{
                    'mapSettingValueOrigin' => mapSettingValue
            };

            return mapReturn;

        } catch (Exception e) {
            System.debug(e.getLineNumber() + 'Line || ' + e.getMessage());
            throw new AuraHandledException(e.getLineNumber() + 'Line || ' + e.getMessage());
        }
    }
    /**
    * @description 소모품 통합 주문 관리 조회
    *
    * @author 23.01.09 / maru035
    * @return
    */
    @AuraEnabled
    public static Map<String, Object> doGetSearchData(Map<String, Object> mapSearchParam) {
            Map<String, Object> returnMap = new Map<String, Object>();
            // Integer recordCount = 0;
            // Decimal recordLimit = (Decimal) mapSearchParam.get('recordLimit');
            // Decimal pageOffset = (Decimal) mapSearchParam.get('pageOffset');
            // Boolean isSearchBtnClick = (Boolean) mapSearchParam.get('isSearchBtnClick');
            System.debug('start====================');
            System.debug('mapSearchParam');
            System.debug(JSON.serializePretty(mapSearchParam));
            System.debug('end====================');

            String strQuery = '', whereClause = '';
            strQuery += ' SELECT Id';
            strQuery += ', Consumables_Business_Type_Code__c ';//주문형태
            strQuery += ', SUB_Order_Number__c '; //Sub번호
            strQuery += ', tolabel(Order_CHNL_TYPE_Code__c) ';//주문채널
            strQuery += ', Parent.Order_Date__c ';//주문일시
            strQuery += ', Order_Number__c ';//주문번호
            strQuery += ', Consumables_Order_Status__c ';//주문상태
            strQuery += ', Consumables_Order_Detail__c '; //주문상태상세
            strQuery += ', BASIS_Parts_Number__c';//요청 PartNo
            strQuery += ', PART_NO__c';//입고 PartNo
            strQuery += ', SALE_Quantity__c';//판매수량
            strQuery += ', Appointment_Status__c';//예약상태
            strQuery += ', RSRV_Number__c';
            strQuery += ', ENDP_Code__c';//사업부
            // strQuery += ', PART_DESC_KOR__c';// 한글품명
            // strQuery += ', Product2.PART_DESC_KOR__c';
            strQuery += ', Product2.PART_DESC__c'; // 품명
            strQuery += ', Product2.MODEL_CODE__c';// 모델
            strQuery += ', SHIPPED_Department_Code__c';// 출고부서
            strQuery += ', UnitPrice__c';//소비자가
            strQuery += ', CONSUMER_Price__c';
            strQuery += ', SALE_Amount__c';// 판매금액
            strQuery += ', PAYMENT_Amount__c';// 결제금액
            strQuery += ', Last_Discount_Amount__c';// 할인금액
            // strQuery += ', Parent.SALE_DC_TYPE__c';// 할인유형
            strQuery += ', SALE_Discount_Type_Code__c';// 할인유형
            strQuery += ', PAYMENT_YN__c';
            strQuery += ', CASH_PAYMENT_Amount__c';// 현금결제
            strQuery += ', VIRTUAL_ACCT_PAYMENT_Amount__c'; // 현금결제
            strQuery += ', CARD_PAYMENT_Amount__c';// 카드결제
            strQuery += ', POINT_Amount__c';// 포인트결제
            strQuery += ', QuantityRequested';// 요청수량
            strQuery += ', CANCEL_Quantity__c';// 취소수량
            strQuery += ', Return_Order_Quantity__c';// 반품수량
            strQuery += ', Exchange_Quantity__c';// 교환수량
            strQuery += ', SALE_Number__c';//판매번호
            strQuery += ', FFMT_Order_Number__c';// CJ 주문번호
            strQuery += ', FFMT_Order_Transfer_YN__c';// CJ 주문 전송여부
            strQuery += ', FFMT_Transfer_DTM__c';// CJ 주문 전송일시
            strQuery += ', DELIVERY_STATUS_CODE__c';// 배송 상태
            strQuery += ', SHIP_DTM__c';// 출하일시
            strQuery += ', Delivery_DTM__c';// 배송일시
            strQuery += ', DELIVERY_CODE__c';// 택배사
            strQuery += ', PARCEL_FEE_Amount__c'; // 택배비
            strQuery += ', CANCEL_Department_Code__c';// 취소 부서
            strQuery += ', CANCEL_UserId__r.EmployeeNumber '; // 취소자사번
            strQuery += ', CANCEL_UserId__r.name ';// 취소자
            strQuery += ', CANCEL_Request_DTM__c'; // 취소요청일시
            strQuery += ', CANCEL_Reason__c';// 취소사유
            strQuery += ', Exchange_Request_Department_Code__c';// 교환요청부서
            strQuery += ', Exchange_Requester_Id__r.EmployeeNumber__c  ';// 교환요청자 
            strQuery += ', Exchange_Requester_Id__r.Name ';
            strQuery += ', Exchange_Request_DTM__c';// 교환요청일시
            strQuery += ', Parent.Case.Subject  ';//상담Case번호
            strQuery += ', Parent.Case.CaseNumber  ';
            strQuery += ', Parent.fmURL_CaseNumber__c  ';
            strQuery += ', Parent.PAYMENT_YN__c  ';
            strQuery += ', fm_Consumables_PART_DESC_KOR__c  ';
            strQuery += ', tolabel(Consumables_Order_Class_Code__c) ';
            strQuery += ', INVOICE_Number__c ';

            //---------------화면상 리스트 컬럼 완료--------------


            strQuery += ', ParentId ';
            strQuery += ', Order_SEQ__c ';
            strQuery += ', Order_CUST_Id__r.Name ';
            strQuery += ', Order_CUST_Id__r.MobilePhone ';
            strQuery += ', Parent.CONSIGNEE_TPNO_1__c ';
            strQuery += ', Parent.CONSIGNEE_Name__c ';
            strQuery += ', Parent.Order_CUST_Id__r.MobilePhone';
            strQuery += ', Parent.CreatedDate ';
            strQuery += ', CreatedBy.Name ';
            strQuery += ', fm_MODEL_Code__c';
            strQuery += ', CreatedBy.DEPT_CODE__c ';
            strQuery += ', BASIS_Order_Item_Id__c';
            strQuery += ', BASIS_Order_Item_Id__r.Order_Number__c ';
            strQuery += ', HAND_WORK_YN__c';
            strQuery += ', HAND_WORK_DATE__c';
            strQuery += ', HAND_WORK_USER_ID__c';
            strQuery += ', HAND_WORK_REASON__c';

            // 23.07.18 비식별 고객명, 전화번호 추가
            strQuery += ', Parent.fm_ENC_Order_CUST_Name__c ';
            strQuery += ', Parent.fm_ENC_Order_CUST_TPNO_1__c ';
            strQuery += ', Parent.fm_ENC_Order_CUST_TPNO_2__c ';
            strQuery += ', Parent.fm_IsMaskingTarget__c ';
            strQuery += ', Parent.Order_CUST_Name__c ';
            strQuery += ', Parent.Order_CUST_TPNO_1__c ';

            
            // Part
            // strQuery += ', Product2.Name ';
            // strQuery += ', Product2.CUST_PRICE__c ';
            strQuery += ', Product2.ASC_Price__c ';
            strQuery += ', SourceLocation.ParentLocationId__c ';
            strQuery += ', SourceLocation.ParentLocationId__r.Name ';
            strQuery += ', Product2Id';
            strQuery += ', SourceLocationId';
            strQuery += ', Parent.SR_RSRV_PART_Id__c ';
            strQuery += ', Order_Status_Change_History__c';
            // 2023.09.21 seung yoon heo returnOrder 따로 뺌
            // strQuery += ', (SELECT Expected_Return_Quantity__c FROM ReturnOrderLineItems ) ';
            // FROM
            strQuery += ' FROM ' + 'ProductRequestLineItem';
            whereClause += ' WHERE RecordType.DeveloperName IN (\'Consumable\', \'CareSupplies\') ';
            
            //주문번호 또는 CJ주문번호가 있을 경우, 다른 조건 무시하고 우선 적용
            if (mapSearchParam.get('orderNo') != null && mapSearchParam.get('orderNo') != '') {
                String orderNo = (String) mapSearchParam.get('orderNo');
                whereClause += ' AND Order_Number__c = \'' + orderNo + '\'';

            } else if (mapSearchParam.get('cjOrderNumber') != null && mapSearchParam.get('cjOrderNumber') != '') {
                String cjOrderNumber = (String) mapSearchParam.get('cjOrderNumber');
                whereClause += ' AND FFMT_Order_Number__c = \'' + '' + cjOrderNumber + '' + '\'';

            } //23.11.22 PHJ 판매번호 조건추가
            else if (mapSearchParam.get('salesNo') != null && mapSearchParam.get('salesNo') != '') {
                String salesNo = (String) mapSearchParam.get('salesNo');
                // whereClause += ' AND Sale_Number__c = \'' + salesNo + '\'';
                whereClause += ' AND SR_SALE__r.Sale_Number__c = \'' + salesNo + '\'';

            } //23 12 20 hyungho.chun 송장번호 조건 추가
            else if (mapSearchParam.get('invoiceNo') != null && mapSearchParam.get('invoiceNo') != '') {
                String invoiceNo = (String) mapSearchParam.get('invoiceNo');

                List<SR_ONLINE_DELIVERY_INFO_HISTORY__c> dInfos = new List<SR_ONLINE_DELIVERY_INFO_HISTORY__c>();                
                List<SR_ONLINE_DELIVERY_INFO__c> dInfos2 = new List<SR_ONLINE_DELIVERY_INFO__c>();
                Set<String> orderNoList = new Set<String>();

                dInfos = [
                    SELECT Id, ORDER_NO__c, DELIVERY_NO__c 
                    FROM SR_ONLINE_DELIVERY_INFO_HISTORY__c
                    WHERE DELIVERY_NO__c =: invoiceNo 
                ];
                //23 12 20 hyungho.chun 현데이터용
                if(dInfos.size()>0){
                    for(SR_ONLINE_DELIVERY_INFO_HISTORY__c item : dInfos){
                        if(item.ORDER_NO__c != null){
                            orderNoList.add(item.ORDER_NO__c);
                        }
                    }
                    
                }else{
                    dInfos2 = [
                        SELECT Id, ORDER_NO__c, DELIVERY_NO__c 
                        FROM SR_ONLINE_DELIVERY_INFO__c
                        WHERE DELIVERY_NO__c =: invoiceNo 
                    ];
                    if(dInfos2.size()>0){
                        for(SR_ONLINE_DELIVERY_INFO__c item : dInfos2){
                            if(item.ORDER_NO__c != null){
                                orderNoList.add(item.ORDER_NO__c);
                            }
                        }                        
                        
                    }
                }
                
                whereClause += ' AND Order_Number__c IN: orderNoList ';
                
            }else {
                //주문채널
                if (mapSearchParam.get('orderChannel') != null && mapSearchParam.get('orderChannel') != '' && mapSearchParam.get('orderChannel') != 'ALL') {
                    String orderChannel = (String) mapSearchParam.get('orderChannel');
                    whereClause += ' AND Order_CHNL_TYPE_Code__c = \'' + orderChannel + '\'';
                }
                //주문상태
                if (mapSearchParam.get('orderStatus') != null && mapSearchParam.get('orderStatus') != '') {
                    String orderStatus = (String) mapSearchParam.get('orderStatus');
                    whereClause += ' AND Consumables_Order_Status__c = \'' + orderStatus + '\'';
                }
                //주문기간
                if (mapSearchParam.get('baseDateStart') != null && mapSearchParam.get('baseDateEnd') != null
                        && mapSearchParam.get('baseDateStart') != '' && mapSearchParam.get('baseDateEnd') != '') {
                    // System.debug('startDate >>>');
                    // System.debug(mapSearchParam.get('baseDateStart'));
                    // System.debug('endDate >>>');
                    // System.debug(mapSearchParam.get('baseDateEnd'));
                    // // 소모품 주문 시작 기준 일자
                    // whereClause += ' AND DAY_ONLY(convertTimezone(Parent.Order_Date__c)) >= ' + mapSearchParam.get('baseDateStart');
                    // // 소모품 주문 종료 기준 일자
                    // whereClause += ' AND DAY_ONLY(convertTimezone(Parent.Order_Date__c)) <= ' + mapSearchParam.get('baseDateEnd');
                            //23 08 21 hyungho.chun day_only 제거
                    String tempStr = String.valueOf(mapSearchParam.get('baseDateStart'));
                    
                    Date tempDate = Date.valueOf(tempStr), tempDate2 = tempDate.addDays(-1);
      
                    tempStr = String.valueOf(tempDate2);
                    system.debug('tempStr after :: '+tempStr);                

                    // whereClause += ' parentId AND Parent.Order_Date__c >= ' + tempStr+'T15:00:00.000+0000';                        


                    // 소모품 주문 종료 기준 일자
                    // whereClause += ' AND Parent.Order_Date__c <= ' + mapSearchParam.get('baseDateEnd')+'T14:59:59.000+0000';

                    whereClause += ' AND parentId IN (SELECT ID FROM ProductRequest WHERE Order_Date__c >= ' + tempStr+'T15:00:00.000+0000';                        


                    // 소모품 주문 종료 기준 일자
                    whereClause += ' AND Order_Date__c <= ' + mapSearchParam.get('baseDateEnd')+'T14:59:59.000+0000) ';
                    
                    // whereClause += ' AND Order_CHNL_TYPE_Code__c != null )';


                }
                //고객명
                if (mapSearchParam.get('contactName') != null && mapSearchParam.get('contactName') != '') {
                    String contactName = (String) mapSearchParam.get('contactName');
                    //대량 주문처리를 위해 LIKE 제거
                    //whereClause += ' AND Order_CUST_Id__r.Name = \'' + contactName + '\'';
                    //2023.07.19 gw.lee
                    //Order Cust Id 안들어가는 이슈로 수정
                    whereClause += ' AND Parent.Order_CUST_Name__c = \'' + contactName + '\'';
                    
                }
                //전화번호
                if (mapSearchParam.get('contactPhone') != null && mapSearchParam.get('contactPhone') != '') {
                    // 소모품 주문 고객 전화 번호
                    String contactPhone = (String) mapSearchParam.get('contactPhone');
                    //whereClause += ' AND Order_CUST_Id__r.MobilePhone = \'' + contactPhone + '\'';
                    // whereClause += ' AND Parent.Order_CUST_Id__r.MobilePhone = \'' + contactPhone + '\'';
                    // 2023.09.07 seung yoon heo 주문 기준으로 전화번호 조회
                    whereClause += ' AND Parent.Order_CUST_TPNO_1__c = \'' + contactPhone + '\'';
                }
                //사업부
                if (mapSearchParam.get('department') != null && mapSearchParam.get('department') != '' && mapSearchParam.get('department') != 'ALL') {
                    String department = (String) mapSearchParam.get('department');
                    whereClause += ' AND ENDP_Code__c = \'' + department + '\'';
                }

                //약속상태
                if (mapSearchParam.get('appointmentStatus') != null && mapSearchParam.get('appointmentStatus') != '') {
                    String appointmentStatus = (String) mapSearchParam.get('appointmentStatus');
                    //RSRV_Number__c가 없는 ProductRequestLineItem도 약속상태가 '입고완료'로 세팅 되기 때문에 아래의 OR 조건 추가
                    if (appointmentStatus != null) {
                        if (appointmentStatus.equals('입고완료')) {
                            whereClause += ' AND (Appointment_Status__c = \'' + appointmentStatus + '\' OR Appointment_Status__c = \'\')';
                        } else {
                            whereClause += ' AND Appointment_Status__c = \'' + appointmentStatus + '\'';
                        }
                    }
                }

                // 판매 완료 여부
                if (mapSearchParam.get('isSalesCompleteY') != null && mapSearchParam.get('isSalesCompleteN') != null) {
                    if (mapSearchParam.get('isSalesCompleteY') != mapSearchParam.get('isSalesCompleteN')) {
                        if ((Boolean) mapSearchParam.get('isSalesCompleteY')) {
                            whereClause += ' AND SALE_NUMBER__c != NULL ';
                        } else {
                            whereClause += ' AND SALE_NUMBER__c = NULL ';
                        }
                    }
                }

                // 23.10.23 PHJ 판매수량 '0' 제외 여부 mapSearchParam.isSalesQtyNotZero
                if (mapSearchParam.get('isSalesQtyNotZero') != null) {
                    if (mapSearchParam.get('isSalesQtyNotZero') == true) {
                        whereClause += ' AND SALE_Quantity__c != 0 ';
                    }
                }
            }

            // 23.03.16 수정 원주문건만 조회
            // 23.09.01 gw.lee 수정 교환주문건 조회 가능 
            //whereClause += ' AND BASIS_Order_Item_Id__c = NULL';
            strQuery += whereClause;
            // ORDER BY
            strQuery += ' ORDER BY Parent.Order_Date__c DESC ';
            // Pagination
    //        strQuery += ' LIMIT ' + recordLimit + ' OFFSET ' + (pageOffset * recordLimit);


            System.debug('strQuery -> ' + strQuery);
            
            List<ProductRequestLineItem> productRequestLineItems = Database.query(strQuery);
                        // 23.09.01 gw.lee
            //주문번호가 교환일 경우, 원주문 번호로 다시 재검색
            if (mapSearchParam.get('orderNo') != null) {
                if (productRequestLineItems.size() > 0) {
                    if (productRequestLineItems[0].Consumables_Business_Type_Code__c == 'ExchangeOrder' && mapSearchParam.get('orderNo') != productRequestLineItems[0].BASIS_Order_Item_Id__r.Order_Number__c) {
                        mapSearchParam.put('orderNo', productRequestLineItems[0].BASIS_Order_Item_Id__r.Order_Number__c);

                        returnMap = doGetSearchData(mapSearchParam);
                        return returnMap;
                    }                
                }
            }

            if((mapSearchParam.get('orderNo') != null || mapSearchParam.get('cjOrderNumber') != null || mapSearchParam.get('salesNo') != null || mapSearchParam.get('invoiceNo') != null) && productRequestLineItems.size() > 0){
                    //23 12 22 hyungho.chun 주문번호받았을땐 doGetReturnDeptSearch부분 미리돌게끔 조치(속도이슈)
                    List<String> prliIdList = new List<String>();
                    List<Map<String, Object>> returnMapList = new List<Map<String, Object>>();
                    for(productRequestLineItem item : productRequestLineItems){
                        if(!prliIdList.contains(item.Id)){
                            prliIdList.add(item.Id);
                        }
                    }
                    returnMapList = doGetReturnDeptSearch(prliIdList);
                    returnMap.put('returnValue',returnMapList[0]);    
            }

        
            System.debug(productRequestLineItems.size());
            returnMap.put('productRequestLineItems', productRequestLineItems);
            
      
        return returnMap;
    }

    @AuraEnabled
    public static List<Map<String, Object>> doGetReturnDeptSearch(List<String> prliId) {
        System.debug('속도측정 -------------------------------------------------- EX_IntegrationOrderManagementController.doGetReturnDeptSearch (start):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        //, List<String> deptCodeList, List<String> shipmentCodeList
        List<Map<String, Object>> returnMapList = new List<Map<String, Object>>();

        System.debug('prliId' + prliId);
        // System.debug('deptCodeList' + deptCodeList);
        // Set<String> deptCodeSet = new Set<String>();
        // if(deptCodeList.size() > 0) {
        //     for(String dept : deptCodeList){
        //         deptCodeSet.add(dept);
        //     }
        // }

        // System.debug('deptCodeSet' + deptCodeSet);

        
        List<returnOrderLineItem> roliList = [SELECT Expected_Return_Quantity__c, ProductRequestLineItemId FROM returnOrderLineItem WHERE ProductRequestLineItemId IN : prliId AND RecordType.DeveloperName IN ('Consumable', 'CareSupplies')];
        
        Map<String, Decimal> roilExpectedMap = new Map<String, Decimal>();

            if (roliList.size() > 0) {
                for (returnOrderLineItem roli : roliList) {
                    if (roilExpectedMap.containsKey(roli.ProductRequestLineItemId)) {
                        Decimal roliCount = roilExpectedMap.get(roli.ProductRequestLineItemId);
                        roilExpectedMap.put(roli.ProductRequestLineItemId, roliCount + roli.Expected_Return_Quantity__c);
                    } else {
                        roilExpectedMap.put(roli.ProductRequestLineItemId, roli.Expected_Return_Quantity__c);
                    }
                }
            }
            returnMapList.add(roilExpectedMap);

            //2023.12.08 seung yoon heo 출고부서 조회
            // List<SM_DEPT__c> smDeptList = [SELECT Name, DEPT_CODE__c FROM SM_DEPT__c WHERE DEPT_CODE__c IN: shipmentCodeList];

            // Map<String, String> shipmentNameMap = new Map<String, String>();
            // for (SM_DEPT__c dept : smDeptList) {
            //     shipmentNameMap.put(dept.DEPT_CODE__c, dept.Name);
            // }

            // returnMapList.add(shipmentNameMap);

            // if(deptCodeSet.size() > 0){
            //     Map<String, String> deptNameMap = EX_ConsumableUtil.getDepartmentNameMap(deptCodeSet);
            //     returnMapList.add(deptNameMap);
            // }
            System.debug('속도측정 -------------------------------------------------- EX_IntegrationOrderManagementController.doGetReturnDeptSearch (END):' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        return returnMapList;
    }

    @AuraEnabled(cacheable=true)
    public static List<SM_DEPT__c> dogetCenterSearch() {
        List<SM_DEPT__c> listCenter = new List<SM_DEPT__c>();

                    listCenter = [
                            SELECT Id
                                    , Name
                                    , DEPT_CODE__c
                            FROM SM_DEPT__c
                            WHERE CLOSE_YN__c != 'Y'
                            AND DEPT_TYPE_SECOND__c IN ('E', 'G', 'H')
                            ORDER BY DEPT_TYPE_FIRST__c DESC
                                    , DEPT_TYPE_SECOND__c DESC
                                    , DEPT_NAME__c ASC
                    ];
        
        return listCenter;
    }


    /**
    * @description 관련 주문 내역(ProductRequestLineItem + ReturnOrderLineItem) 조회
    * @author 23.01.27 / I2MAX.SEUNGHUNAN
    * @return returnMap
    */
    @AuraEnabled
    public static Map<String, Object> doGetOrderLineItemData(String orderNumber, String orderSeq) {
        Map<String, Object> returnMap = new Map<String, Object>();
        System.debug('orderNumber :: ' + orderNumber);
        System.debug('doGetOrderLineItemData : ' + orderSeq);
        String orderSeqStr = orderSeq == null ? null : '-' + (('00000' + orderSeq).right(3)) + '-';
        System.debug('orderSeqStr : ' + orderSeqStr);
        //System.debug(recordId);
        System.debug('order number >> : ' + orderNumber);

        // 원주문 항목 먼저 조회
        String strQuery = ' SELECT Id, Sub_Order_Number__c';
        strQuery += ' FROM ProductRequestLineItem';
        strQuery += ' WHERE BASIS_Order_Item_Id__c=null';
        strQuery += ' AND Order_Number__c=\'' + orderNumber + '\'';
        strQuery += ' AND Consumables_Order_YN__c = TRUE ';
        if (orderSeq != null) {
            strQuery += ' AND SUB_Order_Number__c LIKE \'%' + orderSeqStr + '%\'';
        }

        strQuery += ' AND Consumables_Order_YN__c = TRUE';
        strQuery += ' AND RecordType.DeveloperName != \'RESV_SALE\'';
        strQuery += ' AND RecordType.DeveloperName != \'SALE\'';

        System.debug('strQuery : ' + strQuery);

        List<ProductRequestLineItem> basisOrderList = Database.query(strQuery);
        System.debug(basisOrderList);

        // 원주문 항목 Id Set 생성
        Set<Id> basisOrderIdSet = new Set<Id>();
        for (ProductRequestLineItem bo : basisOrderList) {
            basisOrderIdSet.add(bo.Id);
        }

        String sts = setToString(basisOrderIdSet);
        //2023.08.17 seung yoon heo field 추출
        // strQuery = ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');

        strQuery = ' SELECT Id';
        strQuery += ', SALE_Number__c ';
        strQuery += ', SUB_Order_Number__c ';
        strQuery += ', CANCEL_Department_Code__c ';
        strQuery += ', Exchange_Request_Department_Code__c ';
        strQuery += ', Consumables_Order_Status__c ';
        strQuery += ', Consumables_Business_Type_Code__c ';
        strQuery += ', FFMT_Order_Transfer_YN__c ';
        strQuery += ', Order_CHNL_TYPE_Code__c ';
        strQuery += ', ParentId ';
        strQuery += ', Order_Number__c ';
        strQuery += ', Order_SEQ__c ';
        strQuery += ', Order_Status_Change_History__c ';
        strQuery += ', Order_CUST_Id__c ';
        strQuery += ', CONSIGNEE_Name__c ';
        strQuery += ', CONSIGNEE_TPNO_1__c ';
        strQuery += ', Consumables_Order_DETAIL__c ';
        strQuery += ', SALE_Quantity__c ';
        strQuery += ', CANCEL_Quantity__c ';
        strQuery += ', Return_Order_Quantity__c ';
        strQuery += ', QuantityRequested ';
        strQuery += ', ENDP_Code__c ';
        strQuery += ', BASIS_Parts_Number__c ';
        strQuery += ', PART_NO__c ';
        strQuery += ', UnitPrice__c ';
        strQuery += ', CONSUMER_Price__c ';
        strQuery += ', SALE_Amount__c ';
        strQuery += ', Last_Discount_Amount__c ';
        strQuery += ', PAYMENT_Amount__c ';
        strQuery += ', CARD_PAYMENT_Amount__c ';
        strQuery += ', CASH_PAYMENT_Amount__c ';
        strQuery += ', POINT_Amount__c ';
        strQuery += ', fm_MODEL_Code__c ';
        strQuery += ', HAND_WORK_YN__c ';
        strQuery += ', HAND_WORK_DATE__c ';
        strQuery += ', HAND_WORK_USER_ID__c ';
        strQuery += ', HAND_WORK_REASON__c ';
        strQuery += ', RSRV_Number__c ';
        strQuery += ', Appointment_Status__c ';
        strQuery += ', fm_Consumables_PART_DESC_KOR__c ';
        strQuery += ', SHIPPED_Department_Code__c ';
        strQuery += ', SALE_Discount_Type_Code__c ';
        strQuery += ', Product2Id ';
        strQuery += ', SourceLocationId ';
        strQuery += ', FFMT_Order_Number__c ';
        strQuery += ', FFMT_Transfer_DTM__c ';
        strQuery += ', DELIVERY_STATUS_CODE__c ';
        strQuery += ', SHIP_DTM__c ';
        strQuery += ', DELIVERY_CODE__c ';
        strQuery += ', PARCEL_FEE_Amount__c ';
        strQuery += ', CANCEL_Request_DTM__c ';
        strQuery += ', CANCEL_Reason__c ';
        strQuery += ', Exchange_Request_DTM__c ';
        strQuery += ', Exchange_Quantity__c ';
        strQuery += ', VIRTUAL_ACCT_PAYMENT_Amount__c ';
        strQuery += ', Delivery_DTM__c ';
        strQuery += ', INVOICE_Number__c ';
        
        strQuery += ', Order_CUST_Id__r.MobilePhone ';
        strQuery += ', Order_CUST_Id__r.Name ';
        strQuery += ', CreatedBy.Name ';
        strQuery += ', CreatedBy.EmployeeNumber__c ';
        strQuery += ', CreatedBy.DEPT_CODE__c ';
        strQuery += ', Parent.CreatedDate ';
        strQuery += ', Parent.CONSIGNEE_TPNO_1__c ';
        strQuery += ', Parent.CONSIGNEE_Name__c ';
        strQuery += ', Parent.PAYMENT_Method_Code__c ';
        strQuery += ', Parent.PAYMENT_TYPE__c ';
        strQuery += ', Parent.PAYMENT_YN__c ';

        // 23.02.09 추가
        strQuery += ', Parent.CONSIGNEE_Address__c ';
        strQuery += ', Parent.CONSIGNEE_Address_DETAIL__c';

        strQuery += ', Parent.Order_Date__c ';
        strQuery += ', Parent.SALE_DC_TYPE__c ';
        strQuery += ', Case.SuppliedName';
        strQuery += ', Parent.Case.Subject';
        strQuery += ', Parent.fmURL_CaseNumber__c';

        // 23.07.18 비식별 고객명, 전화번호 추가
        strQuery += ', Parent.fm_ENC_Order_CUST_Name__c ';
        strQuery += ', Parent.fm_ENC_Order_CUST_TPNO_1__c ';
        strQuery += ', Parent.fm_ENC_Order_CUST_TPNO_2__c ';
        strQuery += ', Parent.fm_IsMaskingTarget__c ';
        strQuery += ', Parent.Order_CUST_Name__c ';
        strQuery += ', Parent.Order_CUST_TPNO_1__c ';


        // Part
        strQuery += ', Product2.PART_DESC_KOR__c ';
        strQuery += ', Product2.PART_DESC__c ';
        strQuery += ', Product2.Name ';
        strQuery += ', Product2.CUST_PRICE__c ';
        strQuery += ', Product2.MODEL_CODE__c ';
        strQuery += ', Product2.ASC_PRICE__c ';

        strQuery += ', SourceLocation.ParentLocationId__c ';
        strQuery += ', SourceLocation.ParentLocationId__r.Name ';
        strQuery += ', Parent.SR_RSRV_PART_Id__c ';

        //취소 Section
        strQuery += ', CANCEL_UserId__r.EmployeeNumber ';
        //PHJ231205
        strQuery += ', CANCEL_UserId__r.EmployeeNumber__c ';
        strQuery += ', CANCEL_UserId__r.Name ';
        strQuery += ', Exchange_Requester_Id__r.LastName ';
        // 2023.09.07 seung yoon heo 교환요청자 명 추가
        strQuery += ', Exchange_Requester_Id__r.Name ';
        // 23.10.19 PHJ 교환자 사번추가
        strQuery += ', Exchange_Requester_Id__r.EmployeeNumber__c ';

        // FROM
        strQuery += ' FROM ' + 'ProductRequestLineItem';
        // WHERE
        if (sts.equals('')) {
            strQuery += ' WHERE Order_Number__c=\'' + orderNumber + '\'';
        } else {
            strQuery += ' WHERE (Order_Number__c=\'' + orderNumber + '\' OR BASIS_Order_Item_Id__c IN ' + sts + ')';
        }
        // 소모품 주문 여부
        strQuery += ' AND Consumables_Order_YN__c = TRUE';

        if (orderSeq != null) {
            strQuery += ' AND SUB_Order_Number__c LIKE \'%' + orderSeqStr + '%\'';
        }

        strQuery += ' AND RecordType.DeveloperName IN (\'Consumable\', \'CareSupplies\') ';

        strQuery += ' ORDER BY CreatedDate ASC';

        System.debug('strQuery -> ' + strQuery);
        List<ProductRequestLineItem> productRequestLineItems = Database.query(strQuery);
        System.debug('productRequestLineItems');

        Set<String> deptCodeSet = new Set<String>();

        for (ProductRequestLineItem prLi : productRequestLineItems) {
            System.debug(prLi.SUB_Order_Number__c);
            deptCodeSet.add(prLi.CANCEL_Department_Code__c);
            deptCodeSet.add(prLi.Exchange_Request_Department_Code__c);
        }

        List<ReturnOrderLineItem> returnOrderLineItems = new List<ReturnOrderLineItem>();
        if (!sts.equals('')) {
            String returnOrderQuery;
            //2023.08.17 seung yoon heo field 추출
            // returnOrderQuery = ' SELECT ' + SObjectUtil.getFieldForQuery('ReturnOrderLineItem');
            returnOrderQuery = ' SELECT Id ';
            returnOrderQuery += ', SUB_Order_Number__c ';
            returnOrderQuery += ', Return_Order_Department_Code__c ';
            returnOrderQuery += ', Expected_Return_Quantity__c ';
            returnOrderQuery += ', Consumables_Business_Type_Code__c ';
            returnOrderQuery += ', Consumables_Order_Status__c ';
            returnOrderQuery += ', FFMT_Order_Transfer_YN__c ';
            returnOrderQuery += ', Order_CHNL_TYPE_Code__c ';
            returnOrderQuery += ', ProductRequest__c ';
            returnOrderQuery += ', Order_Number__c ';
            returnOrderQuery += ', Order_SEQ__c ';
            returnOrderQuery += ', Return_Order_Request_DTM__c ';
            returnOrderQuery += ', CONSIGNEE_Name__c ';
            returnOrderQuery += ', CONSIGNEE_TPNO__c ';
            returnOrderQuery += ', CONSIGNEE_Address__c ';
            returnOrderQuery += ', QuantityReturned ';
            returnOrderQuery += ', Actual_Return_Quantity__c ';
            returnOrderQuery += ', Parts_Number__c ';
            returnOrderQuery += ', UnitPrice__c ';
            returnOrderQuery += ', CONSUMER_Price__c ';
            returnOrderQuery += ', RETURN_SALE_Amount__c ';
            returnOrderQuery += ', RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c ';
            returnOrderQuery += ', RETURN_CARD_PAYMENT_Amount__c ';
            returnOrderQuery += ', RETURN_POINT_Amount__c ';
            returnOrderQuery += ', RETURN_PAYMENT_Amount__c ';
            returnOrderQuery += ', FFMT_Order_Number__c ';
            returnOrderQuery += ', FFMT_Transfer_DTM__c ';
            returnOrderQuery += ', Return_Requester_Reason__c ';
            returnOrderQuery += ', Return_Order_CONFIRM_DTM__c ';
            returnOrderQuery += ', INVOICE_Number__c ';

            returnOrderQuery += ', CreatedBy.Name ';
            returnOrderQuery += ', CreatedBy.DEPT_CODE__c ';
            returnOrderQuery += ', ReturnOrder.CreatedDate ';
            returnOrderQuery += ', ProductRequestLineItem.Consumables_Order_Status__c ';
            returnOrderQuery += ', ProductRequest__r.CreatedDate ';
            returnOrderQuery += ', ProductRequestLineItem.Order_CUST_Id__r.Name ';
            returnOrderQuery += ', ProductRequestLineItem.Order_CUST_Id__r.MobilePhone ';
            returnOrderQuery += ', ProductRequestLineItem.Consumables_Order_DETAIL__c ';
            returnOrderQuery += ', ProductRequestLineItem.SALE_Number__c ';
            returnOrderQuery += ', ProductRequestLineItem.SALE_Amount__c ';
            returnOrderQuery += ', ProductRequestLineItem.SALE_Quantity__c ';
            returnOrderQuery += ', ProductRequestLineItem.Last_Discount_Amount__c ';
            returnOrderQuery += ', ProductRequestLineItem.PAYMENT_YN__c ';
            returnOrderQuery += ', ProductRequestLineItem.PAYMENT_Amount__c ';
            returnOrderQuery += ', ProductRequestLineItem.CARD_PAYMENT_Amount__c ';
            returnOrderQuery += ', ProductRequestLineItem.CASH_PAYMENT_Amount__c ';
            returnOrderQuery += ', ProductRequestLineItem.POINT_Amount__c ';
            returnOrderQuery += ', ProductRequestLineItem.fm_MODEL_Code__c ';
            returnOrderQuery += ', ProductRequestLineItem.CANCEL_Quantity__c ';
            returnOrderQuery += ', ProductRequestLineItem.Exchange_Quantity__c ';
            returnOrderQuery += ', ProductRequestLineItem.Return_Order_Quantity__c ';
            returnOrderQuery += ', ProductRequestLineItem.QuantityRequested ';
            returnOrderQuery += ', ProductRequestLineItem.CreatedDate ';
            returnOrderQuery += ', ProductRequestLineItem.Consumables_Order_Class_Code__c ';
            returnOrderQuery += ', ProductRequestLineItem.Product2Id ';
            returnOrderQuery += ', ProductRequestLineItem.Product2.PART_DESC_KOR__c ';
            returnOrderQuery += ', ProductRequestLineItem.Product2.Name ';
            returnOrderQuery += ', ProductRequestLineItem.Product2.MODEL_CODE__c ';
            returnOrderQuery += ', ProductRequestLineItem.Product2.CUST_PRICE__c ';
            returnOrderQuery += ', ProductRequestLineItem.fm_PART_NO__c ';
            returnOrderQuery += ', ProductRequestLineItem.SourceLocationId ';
            returnOrderQuery += ', ProductRequestLineItem.SourceLocation.ParentLocationId__c ';
            returnOrderQuery += ', ProductRequestLineItem.SourceLocation.ParentLocationId__r.Name ';
            returnOrderQuery += ', ProductRequestLineItem.Parent.SR_RSRV_PART_Id__c ';
            returnOrderQuery += ', ProductRequestLineItem.FFMT_Order_Transfer_YN__c ';
            returnOrderQuery += ', ProductRequestLineItem.Appointment_Status__c ';
            returnOrderQuery += ', ProductRequestLineItem.SHIPPED_Department_Code__c ';
            returnOrderQuery += ', ProductRequestLineItem.fm_Consumables_PART_DESC_KOR__c';
            returnOrderQuery += ', ProductRequestLineItem.Parent.PAYMENT_YN__c ';

            returnOrderQuery += ', Return_Requester_Id_c__r.EmployeeNumber__c ';
            returnOrderQuery += ', Return_Requester_Id_c__r.Name ';

            returnOrderQuery += ', Exchange_Order_Item_Id__r.CreatedBy.Name ';
            returnOrderQuery += ', Exchange_Order_Item_Id__r.CreatedDate ';

            // 바인딩 수정으로 컬럼 추가
            returnOrderQuery += ', ProductRequestLineItem.Parent.Order_Date__c ';
            returnOrderQuery += ', ProductRequestLineItem.ENDP_CODE__c ';
            returnOrderQuery += ', ProductRequestLineItem.PART_DESC_KOR__c ';
            returnOrderQuery += ', ProductRequestlineItem.fm_ProductName__c ';
            returnOrderQuery += ', ProductRequestlineItem.MODEL_Code__c ';
            returnOrderQuery += ', ProductRequestLineItem.SUB_Order_Number__c ';
            returnOrderQuery += ', productRequestLineItem.Exchange_Requester_Id__r.Name ';

            // OBS는 원주문 품목의 OrderSeq를 따라가기위해 추가
            returnOrderQuery += ', ProductRequestLineItem.Order_SEQ__c ';

            // 23/07/18
            returnOrderQuery += ', ReturnOrder.fm_ReturnIsMaskingTarget__c';
            returnOrderQuery += ', ReturnOrder.Order_CUST_Name__c';
            returnOrderQuery += ', ReturnOrder.Order_CUST_TPNO_1__c';
            returnOrderQuery += ', ReturnOrder.fm_ENC_Order_CUST_Name__c';
            returnOrderQuery += ', ReturnOrder.fm_ENC_Order_CUST_TPNO_1__c';

            // Part
            returnOrderQuery += ', Product2.PART_DESC_KOR__c ';
            returnOrderQuery += ', Product2.Name ';
            returnOrderQuery += ', Product2.CUST_PRICE__c ';
            returnOrderQuery += ', Product2.ASC_PRICE__c ';
            returnOrderQuery += ', Product2.PART_DESC__c ';

            // FROM
            returnOrderQuery += ' FROM ' + 'ReturnOrderLineItem';
            // WHERE
            returnOrderQuery += ' WHERE ProductRequestLineItemId IN ' + sts;

            // 소모품 주문 여부
            returnOrderQuery += ' AND Consumables_Order_YN__c = TRUE ';
            // 소모품 요청 구분 반품, 교환반품
            returnOrderQuery += ' AND Consumables_Business_Type_Code__c IN (\'Return\', \'ExchangeReturn\')';

            // 반품요청철회 X
            returnOrderQuery += ' AND Consumables_Order_Status__c != ' + '\'090\'';

            returnOrderQuery += ' ORDER BY CreatedDate ASC';
            System.debug('returnOrderQuery -> ' + returnOrderQuery);
            returnOrderLineItems = Database.query(returnOrderQuery);
        }

        System.debug('returnOrderLineItems');
        for (ReturnOrderLineItem roLi : returnOrderLineItems) {
            System.debug(roLi.SUB_Order_Number__c);
            deptCodeSet.add(roLi.Return_Order_Department_Code__c);
        }
        Map<String, String> deptNameMap = EX_ConsumableUtil.getDepartmentNameMap(deptCodeSet);

        Map<String, Map<String, Object>> returnParentMap = new Map<String, Map<String, Object>>();
        Map<String, Object> prliIdParentDataMap;
        List<IntegrationOrderLineItemTable> orderLineItemTables = new List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable>();
        IntegrationOrderLineItemTable integrationOrderLineItemTable;

        Boolean isSale = false;
        Boolean isCJSend = false;


        // 취소
        //Set<String> cancelStatusSet = new Set<String> {'결제취소', '주문취소'};
        Set<String> cancelStatusSet = new Set<String>{
                EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_003,
                EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_004
        };
        // 반품
        //Set<String> returnStatusSet = new Set<String>{'반품요청', '반품확정','반품완료'};
        Set<String> returnStatusSet = new Set<String>{
                EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_100,
                EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_120,
                EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_121
        };


        //센터
        List<SM_DEPT__c> listCenter = new List<SM_DEPT__c>();

        listCenter = [
                SELECT Id
                        , Name
                        , DEPT_CODE__c
                FROM SM_DEPT__c
                WHERE CLOSE_YN__c != 'Y'
                AND DEPT_TYPE_SECOND__c IN ('E', 'G', 'H')
                ORDER BY DEPT_TYPE_FIRST__c DESC
                        , DEPT_TYPE_SECOND__c DESC
                        , DEPT_NAME__c ASC
        ];

        System.debug('listCenter :: ' + listCenter);
        Map<String, String> listMapCenter = new Map<String, String>();
        for (SM_DEPT__c obj : listCenter) {
            listMapCenter.put(obj.DEPT_CODE__c, obj.Name);
        }

        // 관련주문내역 송장번호
        //주문과 반품 각각 배송정보를 가져옴.
        List<SR_ONLINE_DELIVERY_INFO__c> dPRInfos = new List<SR_ONLINE_DELIVERY_INFO__c>();
        dPRInfos = [
                SELECT Id, ProductRequestLineItem__c, DELIVERY_NO__c
                FROM SR_ONLINE_DELIVERY_INFO__c
                WHERE ProductRequestLineItem__c = :productRequestLineItems
                ORDER BY CreatedDate DESC
        ];

        //2023.12.08 seung yoon heo 출고부서 한글
        // Set<String> shipmentCodeSet = new Set<String>();


        // 송장번호 DeliveryInfo 조회용 Id 세팅
        List<String> prliIdList = new List<String>();
        for (ProductRequestLineItem prli : productRequestLineItems) {
            if (prli.Consumables_Order_Status__c != null && (prli.Consumables_Order_Status__c.equals('030') || prli.Consumables_Order_Status__c.equals('070'))) {
                prliIdList.add(prli.Id);
            }
            // shipmentCodeSet.add(prli.SHIPPED_Department_Code__c);
        }

        //2023.12.08 seung yoon heo 출고부서 조회
        // List<SM_DEPT__c> smDeptList = [SELECT Name, DEPT_CODE__c FROM SM_DEPT__c WHERE DEPT_CODE__c IN: shipmentCodeSet];

        // Map<String, String> shipmentNameMap = new Map<String, String>();
        // for (SM_DEPT__c dept : smDeptList) {
        //     shipmentNameMap.put(dept.DEPT_CODE__c, dept.Name);
        // }


        //송장번호 조회
        // List<Map<String, String>> dMap_list = new List<Map<String, String>>();
        // if (!prliIdList.isEmpty()) {
        //     dMap_list = EX_ConsumablesOrderManagementController.getDeliveryNoList(prliIdList, null);
        // }


        Map<String, Decimal> totalExpexcted = new Map<String, Decimal>();


        for (ReturnOrderLineItem returnOrderLineItem : returnOrderLineItems) {
            if (returnOrderLineItem.Expected_Return_Quantity__c != null && returnOrderLineItem.Expected_Return_Quantity__c > 0) {
                // 23.05.03 / 교환반품의 경우 반품예정수량으로 보여주지 않음.
                if (returnOrderLineItem.Consumables_Business_Type_Code__c != 'ExchangeReturn') {
                    Decimal total = totalExpexcted.get(returnOrderLineItem.ProductRequestLineItem.SUB_Order_Number__c);
                    if (total == null) {
                        totalExpexcted.put(returnOrderLineItem.ProductRequestLineItem.SUB_Order_Number__c, returnOrderLineItem.Expected_Return_Quantity__c);
                        total = 0;
                    } else {
                        total += returnOrderLineItem.Expected_Return_Quantity__c;
                        totalExpexcted.put(returnOrderLineItem.Id, total);
                    }
                }
            }
        }

        // 주문, 주문취소, 교환
        Integer orderQuerySeq = 1;
        for (ProductRequestLineItem productRequestLineItem : productRequestLineItems) {
            System.debug('productRequestLineItem :::: ' + productRequestLineItem.Payment_Amount__c);
            integrationOrderLineItemTable = new IntegrationOrderLineItemTable();
            integrationOrderLineItemTable.Id = productRequestLineItem.Id;
            integrationOrderLineItemTable.OrderQuerySeq = orderQuerySeq++;

            //반품예정수량의 합
            // 23.05.03 / 교환의 경우 반품예정수량으로 보여주지 않음.
            if (productRequestLineItem.Consumables_Business_Type_Code__c == 'ExchangeOrder') {
                integrationOrderLineItemTable.ExpectedReturnQuantity = 0;
            } else {
                //23.10.20 PHJ -> 23 10 22 hyungho.chun 원복
                integrationOrderLineItemTable.ExpectedReturnQuantity = totalExpexcted.get(productRequestLineItem.SUB_Order_Number__c) != null ? totalExpexcted.get(productRequestLineItem.SUB_Order_Number__c) : 0;
                // integrationOrderLineItemTable.ExpectedReturnQuantity = 0;

            }


            isSale = (EX_ConsumableUtil.returnStatusKORMap(productRequestLineItem.Consumables_Order_Status__c) == '배송중'
                    || EX_ConsumableUtil.returnStatusKORMap(productRequestLineItem.Consumables_Order_Status__c) == '배송완료')
                    && (productRequestLineItem.SALE_Number__c != null) ? true : false;

            isCJSend = productRequestLineItem.FFMT_Order_Transfer_YN__c;

            integrationOrderLineItemTable.TrackingNumber = isCJSend ? productRequestLineItem.INVOICE_Number__c : null;

            switch on productRequestLineItem.Order_CHNL_TYPE_Code__c {
                when 'B' {
                    integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_OBS_LABEL;
                }
                when 'S' {
                    integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_THINQ_LABEL;
                }
                when 'V' {
                    integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_CIC_LABEL;
                }
                when 'BestShop' {
                    integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_BESTSHOP_LABEL;
                }
                //2023.08.16 seung yoon heo Order_CHNL_TYPE_Code__c == 'Y'  >> 소모품샵  추가
                when 'Y' {
                //integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_BESTSHOP_LABEL;
                    integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_CICSHOP_LABEL;
                }
                when else {
                    integrationOrderLineItemTable.OrderChannel = '미지정';
                }
            }
            switch on productRequestLineItem.Consumables_Business_Type_Code__c {
                when 'Order' {
                    integrationOrderLineItemTable.ConsumablesBusinessTypeCode = '주문';
                }
                when 'ExchangeOrder' {
                    integrationOrderLineItemTable.ConsumablesBusinessTypeCode = '교환주문';
                }
                when 'ExchangeReturn' {
                    integrationOrderLineItemTable.ConsumablesBusinessTypeCode = '교환반품';
                }
                when 'Cancel' {
                    integrationOrderLineItemTable.ConsumablesBusinessTypeCode = '취소';
                }
                when 'Return' {
                    integrationOrderLineItemTable.ConsumablesBusinessTypeCode = '반품';
                }
            }


            integrationOrderLineItemTable.ParentId = productRequestLineItem.ParentId;
            integrationOrderLineItemTable.OrderNumber = productRequestLineItem.Order_Number__c;
            integrationOrderLineItemTable.OrderSeq = productRequestLineItem.Order_SEQ__c;
            String sn = productRequestLineItem.SUB_Order_Number__c;
            if (sn != null && sn.contains('-')) {
                Integer targetIndex = sn.split('-').size();
                if (targetIndex > 2) {
                    if (sn.split('-')[targetIndex - 1].equals('01')) {
                        integrationOrderLineItemTable.SubNumber = sn.split('-')[targetIndex - 2] + '-' + sn.split('-')[targetIndex - 1];
                    } else {
                        integrationOrderLineItemTable.SubNumber = 'ㄴ' + sn.split('-')[targetIndex - 2] + '-' + sn.split('-')[targetIndex - 1];
                    }
                } else {
                    integrationOrderLineItemTable.SubNumber = sn;
                }
            } else {
                integrationOrderLineItemTable.SubNumber = sn;
            }

            // 23.02.09 수정
            integrationOrderLineItemTable.OrderDate = productRequestLineItem.Parent.Order_Date__c;
            integrationOrderLineItemTable.CustomerName = productRequestLineItem.Order_CUST_Id__r.Name;
            integrationOrderLineItemTable.CustomerPhone = productRequestLineItem.Order_CUST_Id__r.MobilePhone;

            // 23.07.18 마스킹 대상 추가
            // 14일 이전 수정 이력이 없는 경우 && 대상 마스킹 상태 인경우 마스킹 처리
            if(productRequestLineItem.Parent.fm_IsMaskingTarget__c && CONSUMABLE_MASKING_STATUS_CODE_SET.contains(productRequestLineItem.Consumables_Order_Status__c)) {
                integrationOrderLineItemTable.CustomerName = productRequestLineItem.Parent.fm_ENC_Order_CUST_Name__c;
                integrationOrderLineItemTable.CustomerPhone = productRequestLineItem.Parent.fm_ENC_Order_CUST_TPNO_1__c;
            } else {
                integrationOrderLineItemTable.CustomerName = productRequestLineItem.Parent.Order_CUST_Name__c;
                integrationOrderLineItemTable.CustomerPhone = productRequestLineItem.Parent.Order_CUST_TPNO_1__c;
            }


            //PHJ231205 modify
            integrationOrderLineItemTable.CONSIGNEE_Name = productRequestLineItem.Parent.CONSIGNEE_Name__c;
            integrationOrderLineItemTable.CONSIGNEE_Phone = productRequestLineItem.Parent.CONSIGNEE_TPNO_1__c;
            integrationOrderLineItemTable.CONSIGNEE_Address = productRequestLineItem.Parent.CONSIGNEE_Address__c;
            integrationOrderLineItemTable.CONSIGNEE_Address_Detail = productRequestLineItem.Parent.CONSIGNEE_Address_DETAIL__c;

            // 23.02.09 추가
            // 23.03.14 삭제 --
            // integrationOrderLineItemTable.CONSIGNEE_Address = productRequestLineItem.Parent.CONSIGNEE_Address__c;
            // integrationOrderLineItemTable.CONSIGNEE_Address_Detail = productRequestLineItem.Parent.CONSIGNEE_Address_DETAIL__c;

            //integrationOrderLineItemTable.OrderStatus = productRequestLineItem.Consumables_Order_Status_Code_c;
            integrationOrderLineItemTable.OrderStatus = EX_ConsumableUtil.returnStatusKORMap(productRequestLineItem.Consumables_Order_Status__c);
            integrationOrderLineItemTable.OrderStatusDetail = EX_ConsumableUtil.returnStatusKORMap(productRequestLineItem.Consumables_Order_DETAIL__c);
//            integrationOrderLineItemTable.SalesNumber = isSale ? productRequestLineItem.SALE_Number__c : null;
            // 23.02.27 판매번호 확인
            integrationOrderLineItemTable.SalesNumber = productRequestLineItem.SALE_Number__c;
            integrationOrderLineItemTable.SalesDate = isSale ? productRequestLineItem.Parent.CreatedDate : null;
            // integrationOrderLineItemTable.CJOrderSendYN = isCJSend ? 'Y' : 'N';
            // integrationOrderLineItemTable.CJOrderNumber = isCJSend ? '00000001234' : null;
            // integrationOrderLineItemTable.ShipmentDate = isCJSend ? productRequestLineItem.Parent.CreatedDate.addHours(4) : null;
            //integrationOrderLineItemTable.DeliveryDate = isCJSend && productRequestLineItem.Consumables_Order_Status_Code__c == '배송완료' ? productRequestLineItem.Parent.CreatedDate.addDays(2) : null;
            // integrationOrderLineItemTable.DeliveryDate = isCJSend && EX_ConsumableUtil.returnStatusKORMap(productRequestLineItem.Consumables_Order_Status__c) == '배송완료' ? productRequestLineItem.CreatedDate.addDays(2) : null;
            integrationOrderLineItemTable.SalesQuantity = productRequestLineItem.SALE_Quantity__c != null ? productRequestLineItem.SALE_Quantity__c : 0;
            integrationOrderLineItemTable.CancelQuantity = productRequestLineItem.CANCEL_Quantity__c != null ? productRequestLineItem.CANCEL_Quantity__c : 0;
            integrationOrderLineItemTable.ReturnQuantity = productRequestLineItem.Return_Order_Quantity__c != null ? productRequestLineItem.Return_Order_Quantity__c : 0;
            // integrationOrderLineItemTable.ExchangeQuantity = productRequestLineItem.Exchange_Quantity__c != null ? productRequestLineItem.Consumables_Business_Type_Code__c == 'ExchangeOrder' ? productRequestLineItem.QuantityRequested : productRequestLineItem.Exchange_Quantity__c : 0;
            //23 09 16 hyungho.chun 교환주문 요청수량 0으로 표기
            integrationOrderLineItemTable.ExchangeQuantity = productRequestLineItem.Exchange_Quantity__c != null ? productRequestLineItem.Consumables_Business_Type_Code__c == 'ExchangeOrder' ? 0 : productRequestLineItem.Exchange_Quantity__c : 0;
            integrationOrderLineItemTable.QuantityRequested = productRequestLineItem.QuantityRequested != null ? productRequestLineItem.QuantityRequested : 0;

            integrationOrderLineItemTable.DIV = productRequestLineItem.ENDP_Code__c;
            //integrationOrderLineItemTable.RequestedPartNo = productRequestLineItem.fm_PART_NO__c;
            integrationOrderLineItemTable.RequestedPartNo = productRequestLineItem.BASIS_Parts_Number__c;
            //integrationOrderLineItemTable.ReceivedPartNo = productRequestLineItem.fm_PART_NO__c;
            integrationOrderLineItemTable.ReceivedPartNo = productRequestLineItem.PART_NO__c;

            // integrationOrderLineItemTable.PartName = productRequestLineItem.Product2.PART_DESC_KOR__c != null ? productRequestLineItem.Product2.PART_DESC_KOR__c + '(' + productRequestLineItem.Product2.Name + ')' : productRequestLineItem.Product2.Name;
            //integrationOrderLineItemTable.CustomerPrice = productRequestLineItem.Product2.CUST_PRICE__c != null ? productRequestLineItem.Product2.CUST_PRICE__c : 0;
            // if (productRequestLineItem.UnitPrice__c > 0) {
            //     integrationOrderLineItemTable.CustomerPrice = productRequestLineItem.UnitPrice__c;
            // } else {
                //23 12 27 hyungho.chun 화면에서 항상 CONSUMER_Price__c 보이게
                integrationOrderLineItemTable.CustomerPrice = productRequestLineItem.CONSUMER_Price__c != null ? productRequestLineItem.CONSUMER_Price__c : 0;
            // }
            integrationOrderLineItemTable.ASCPrice = productRequestLineItem.Product2.ASC_PRICE__c != null ? productRequestLineItem.Product2.ASC_PRICE__c : 0;
            integrationOrderLineItemTable.SaleAmount = productRequestLineItem.SALE_Amount__c != null ? productRequestLineItem.SALE_Amount__c : 0 ;
            integrationOrderLineItemTable.DiscountAmount = productRequestLineItem.Last_Discount_Amount__c != null ? productRequestLineItem.Last_Discount_Amount__c : 0;
            integrationOrderLineItemTable.PaymentAmount = productRequestLineItem.PAYMENT_Amount__c != null ? productRequestLineItem.PAYMENT_Amount__c : 0;
            integrationOrderLineItemTable.RequestedDate = productRequestLineItem.Parent.CreatedDate;
            integrationOrderLineItemTable.RequestedUser = productRequestLineItem.CreatedBy.Name;

            System.debug('integrationOrderLineItemTable.PaymentAmount :::: ' + integrationOrderLineItemTable.PaymentAmount);
            // integrationOrderLineItemTable.DeliveryCompany = isCJSend ? 'CJ대한통운' : null;
            //지은
            //integrationOrderLineItemTable.TrackingNumber = isCJSend ? '568051311435 외 1건' : null;
            //List<Map<String, String>> results = EX_ConsumablesOrderManagementController.getProliDeliveryNoList(productRequestLineItem);
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
            //         integrationOrderLineItemTable.TrackingNumber = isCJSend ? tNum + '외 ' + (matchCnt - 1) + '건' : null;
            //     } else {
            //         integrationOrderLineItemTable.TrackingNumber = isCJSend ? tNum : null;
            //     }
            // }


            //integrationOrderLineItemTable.CardAmount = productRequestLineItem.CARD_PAYMENT_Amount__c != null ? productRequestLineItem.CARD_PAYMENT_Amount__c : 0;
            //integrationOrderLineItemTable.CaSHAmount = productRequestLineItem.CASH_PAYMENT_Amount__c != null ? productRequestLineItem.CASH_PAYMENT_Amount__c : 0;
            //integrationOrderLineItemTable.PointAmount = productRequestLineItem.POINT_Amount__c != null ? productRequestLineItem.POINT_Amount__c : 0;

            // 결제 완료(선 결제)
            if (productRequestLineItem.Parent.PAYMENT_YN__c == true) {
                if (productRequestLineItem.CARD_PAYMENT_Amount__c == null) productRequestLineItem.CARD_PAYMENT_Amount__c = 0;
                if (productRequestLineItem.CASH_PAYMENT_Amount__c == null) productRequestLineItem.CASH_PAYMENT_Amount__c = 0;
                if (productRequestLineItem.POINT_Amount__c == null) productRequestLineItem.POINT_Amount__c = 0;

                // 현금결제 (CASH_PAYMENT_Amount__c + VIRTUAL_ACCT_PAYMENT_Amount__c)
                if (productRequestLineItem.CASH_PAYMENT_Amount__c > 0 && productRequestLineItem.CASH_PAYMENT_Amount__c != null) {
                    integrationOrderLineItemTable.CASHAmount = Math.ceil(productRequestLineItem.CASH_PAYMENT_Amount__c);
                } else if (productRequestLineItem.VIRTUAL_ACCT_PAYMENT_Amount__c > 0 && productRequestLineITem.VIRTUAL_ACCT_PAYMENT_Amount__c != null) {
                    integrationOrderLineItemTable.CASHAmount = Math.ceil(productRequestLineItem.CASH_PAYMENT_Amount__c);
                }
                // 카드결제
                if (productRequestLineItem.CARD_PAYMENT_Amount__c != 0 && productRequestLineItem.CARD_PAYMENT_Amount__c != null) {
                    integrationOrderLineItemTable.CardAmount = Math.ceil(productRequestLineItem.CARD_PAYMENT_Amount__c);
                } else {
                    integrationOrderLineItemTable.CardAmount = 0;
                }
                // 포인트결제
                if (productRequestLineItem.POINT_Amount__c != 0 && productRequestLineItem.POINT_Amount__c != null) {
                    integrationOrderLineItemTable.PointAmount = Math.ceil(productRequestLineItem.POINT_Amount__c);
                } else {
                    integrationOrderLineItemTable.PointAmount = 0;
                }

            } else {
                // 결제 미완료
                if (productRequestLineItem.CARD_PAYMENT_Amount__c == null) productRequestLineItem.CARD_PAYMENT_Amount__c = 0;
                if (productRequestLineItem.CASH_PAYMENT_Amount__c == null) productRequestLineItem.CASH_PAYMENT_Amount__c = 0;
                if (productRequestLineItem.POINT_Amount__c == null) productRequestLineItem.POINT_Amount__c = 0;

                // 카드결제
                if (productRequestLineItem.CARD_PAYMENT_Amount__c != null) {
                    //integrationOrderLineItemTable.CardAmount = Math.ceil(productRequestLineItem.CARD_PAYMENT_Amount__c);
                    integrationOrderLineItemTable.CardAmount = 0;

                }
                // 현금결제
                if (productRequestLineItem.CASH_PAYMENT_Amount__c != null) {
//                    if(productRequestLineItem.VIRTUAL_ACCT_PAYMENT_Amount__c != null){
//                        integrationOrderLineItemTable.CASHAmount = Math.ceil(productRequestLineItem.CASH_PAYMENT_Amount__c + productRequestLineItem.VIRTUAL_ACCT_PAYMENT_Amount__c);
//                    } else{
//                        integrationOrderLineItemTable.CASHAmount = Math.ceil(productRequestLineItem.CASH_PAYMENT_Amount__c);
//                    }
                    integrationOrderLineItemTable.CashAmount = 0;
                }
                // 포인트결제
                if (productRequestLineItem.POINT_Amount__c != null) {
                    //integrationOrderLineItemTable.PointAmount = Math.ceil(productRequestLineItem.POINT_Amount__c);
                    integrationOrderLineItemTable.PointAmount = 0;
                }

            }

            // integrationOrderLineItemTable.DeliveryFee = 0;
            integrationOrderLineItemTable.ModelCode = productRequestLineItem.fm_MODEL_Code__c;
            integrationOrderLineItemTable.RequestedDept = listMapCenter.get(productRequestLineItem.CreatedBy.DEPT_CODE__c);

            // 23.02.09 교환상태변경 컬럼 추가
            // 23.03.14 삭제
            // integrationOrderLineItemTable.OrderSeq = productRequestLineItem.Order_SEQ__c;

            // 23.02.13 수작업관련 컬럼 추가
            integrationOrderLineItemTable.HandWorkYN = productRequestLineItem.HAND_WORK_YN__c ? 'Y' : 'N';
            integrationOrderLineItemTable.HandWorkDate = productRequestLineItem.HAND_WORK_DATE__c;
            integrationOrderLineItemTable.HandWorkUser = productRequestLineItem.HAND_WORK_USER_ID__c;
            integrationOrderLineItemTable.HandWorkReason = productRequestLineItem.HAND_WORK_REASON__c;

            // 23.02.13 통합주문관리 컬럼 추가
            //integrationOrderLineItemTable.SubstituteYN = '원';
            if (productRequestLineItem.BASIS_Parts_Number__c != null && productRequestLineItem.PART_NO__c != null) {
                if (productRequestLineItem.BASIS_Parts_Number__c == productRequestLineItem.PART_NO__c) {
                    integrationOrderLineItemTable.SubstituteYN = '원';
                } else {
                    integrationOrderLineItemTable.SubstituteYN = '대치';
                }
            } else {
                integrationOrderLineItemTable.SubstituteYN = '';
            }


            // 약속 상태 수정
            //부품예약번호가 없을때 약속상태를 자동으로 '입고완료' 표시 하고 취소상태의 품목은 취소로 표시한다
            if (productRequestLineItem.RSRV_Number__c != null && !productRequestLineItem.RSRV_Number__c.equals('')) {
                integrationOrderLineItemTable.AppointmentStatus = productRequestLineItem.Appointment_Status__c;
            } else {
                // if (productRequestLineItem.Consumables_Order_Status__c == EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_003 ||
                //         productRequestLineItem.Consumables_Order_Status__c == EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_004) {
                //     integrationOrderLineItemTable.AppointmentStatus = '취소';
                // }
                // else {
                //     integrationOrderLineItemTable.AppointmentStatus = productRequestLineItem.Appointment_Status__c;
                // }
                //23.12.05 gw.lee
                //약속 상태에서 취소했을 경우만 취소로 보이게끔 조치
                integrationOrderLineItemTable.AppointmentStatus = productRequestLineItem.Appointment_Status__c;
            }
            if (productRequestLineItem.Appointment_Status__c != null && productRequestLineItem.Appointment_Status__c == 'PO Canceld') {
                // 2024.02.29 seung yoon heo 취소 => 약속취소
                // integrationOrderLineItemTable.AppointmentStatus = '취소';
                integrationOrderLineItemTable.AppointmentStatus = '약속취소';
            }
            //23.05.04 약속 상태 : 부가품예약번호가 없을시 약속상태를 '입고완료'로 자동으로 매핑.
//            if(productRequestLineItem.RSRV_Number__c!=null && !productRequestLineItem.RSRV_Number__c.equals('')){
//                if(productRequestLineItem.Appointment_Status__c == 'PO Canceld') {
//                    integrationOrderLineItemTable.AppointmentStatus = '취소';
//                }else{
//                    integrationOrderLineItemTable.AppointmentStatus = productRequestLineItem.Appointment_Status__c;
//                }
//            } else {
//                integrationOrderLineItemTable.AppointmentStatus = '입고완료';
//            }

            /*if(productRequestLineItem.Consumables_Order_Class_Code__c == 'Sold Out' && productRequestLineItem.FFMT_Order_Transfer_YN__c) {
                integrationOrderLineItemTable.AppointmentStatus = '입고완료';
            } else if (productRequestLineItem.Consumables_Order_Class_Code__c == 'Sold Out' && !productRequestLineItem.FFMT_Order_Transfer_YN__c){
                integrationOrderLineItemTable.AppointmentStatus = '입고요청';
            }*/

            // 한글 품명

            integrationOrderLineItemTable.PartNameKOR = productRequestLineItem.fm_Consumables_PART_DESC_KOR__c;
            // 품명
            integrationOrderLineItemTable.PartName = productRequestLineItem.Product2.PART_DESC__c;

            // 모델
            integrationOrderLineItemTable.Model = productRequestLineItem.Product2.MODEL_Code__c;
            // 출고부서
            // integrationOrderLineItemTable.ShippedDepartment = shipmentNameMap.get(productRequestLineItem.SHIPPED_Department_Code__c);
            //23 12 22 hyungho.chun 한글아니고 바로 코드로
            integrationOrderLineItemTable.ShippedDepartment = productRequestLineItem.SHIPPED_Department_Code__c;

            // 소비자가, 판매수량, 판매금액 존재
            System.debug('productRequestLineItem.Parent.PAYMENT_YN__c :::: ' + productRequestLineItem.Parent.PAYMENT_YN__c);
            if (productRequestLineItem.Parent.PAYMENT_YN__c == true) {
                if (productRequestLineItem.CARD_PAYMENT_Amount__c == null) productRequestLineItem.CARD_PAYMENT_Amount__c = 0;
                if (productRequestLineItem.CASH_PAYMENT_Amount__c == null) productRequestLineItem.CASH_PAYMENT_Amount__c = 0;
                if (productRequestLineItem.POINT_Amount__c == null) productRequestLineItem.POINT_Amount__c = 0;

                // 현금결제 (CASH_PAYMENT_Amount__c + VIRTUAL_ACCT_PAYMENT_Amount__c)
                if (productRequestLineItem.CASH_PAYMENT_Amount__c != 0 && productRequestLineItem.CASH_PAYMENT_Amount__c != null) {
                    integrationOrderLineItemTable.CASHAmount = Math.ceil(productRequestLineItem.CASH_PAYMENT_Amount__c);
                } else {
                    integrationOrderLineItemTable.CASHAmount = 0;
                }
                // 카드결제
                if (productRequestLineItem.CARD_PAYMENT_Amount__c != 0 && productRequestLineItem.CARD_PAYMENT_Amount__c != null) {
                    integrationOrderLineItemTable.CardAmount = Math.ceil(productRequestLineItem.CARD_PAYMENT_Amount__c);
                } else {
                    integrationOrderLineItemTable.CardAmount = 0;
                }
                // 포인트결제
                if (productRequestLineItem.POINT_Amount__c != 0 && productRequestLineItem.POINT_Amount__c != null) {
                    integrationOrderLineItemTable.PointAmount = Math.ceil(productRequestLineItem.POINT_Amount__c);
                } else {
                    integrationOrderLineItemTable.PointAmount = 0;
                }

                //23 08 07 hyungho.chun 결제금액 맵핑오류
                integrationOrderLineItemTable.PaymentAmount = productRequestLineItem.Payment_Amount__c;
                System.debug('productRequestLineItem.CARD_PAYMENT_Amount__c + productRequestLineItem.CASH_PAYMENT_Amount__c + productRequestLineItem.POINT_Amount__c :::: ' + productRequestLineItem.CARD_PAYMENT_Amount__c + productRequestLineItem.CASH_PAYMENT_Amount__c + productRequestLineItem.POINT_Amount__c);
                System.debug('PaymentAMount :::: ' + integrationOrderLineItemTable.PaymentAmount);
            } else {
                // 결제 미완료
                if (productRequestLineItem.CARD_PAYMENT_Amount__c == null) productRequestLineItem.CARD_PAYMENT_Amount__c = 0;
                if (productRequestLineItem.CASH_PAYMENT_Amount__c == null) productRequestLineItem.CASH_PAYMENT_Amount__c = 0;
                if (productRequestLineItem.POINT_Amount__c == null) productRequestLineItem.POINT_Amount__c = 0;

                // 카드결제
                if (productRequestLineItem.CARD_PAYMENT_Amount__c != 0 && productRequestLineItem.CARD_PAYMENT_Amount__c != null) {
                    integrationOrderLineItemTable.CardAmount = Math.ceil(productRequestLineItem.CARD_PAYMENT_Amount__c);
                }
                // 현금결제 (CASH_PAYMENT_Amount__c + VIRTUAL_ACCT_PAYMENT_Amount__c)
                if (productRequestLineItem.CASH_PAYMENT_Amount__c != 0 && productRequestLineItem.CASH_PAYMENT_Amount__c != null) {
                    integrationOrderLineItemTable.CASHAmount = Math.ceil(productRequestLineItem.CASH_PAYMENT_Amount__c);
                } else {
                    integrationOrderLineItemTable.CASHAmount = 0;
                }
                // 포인트결제
                if (productRequestLineItem.POINT_Amount__c != 0 && productRequestLineItem.POINT_Amount__c != null) {
                    integrationOrderLineItemTable.PointAmount = Math.ceil(productRequestLineItem.POINT_Amount__c);
                }

                // 결제 예정 금액
                integrationOrderLineItemTable.EstimatedPaymentAmount = productRequestLineItem.CARD_PAYMENT_Amount__c + productRequestLineItem.CASH_PAYMENT_Amount__c + productRequestLineItem.POINT_Amount__c;
                //23 08 07 hyungho.chun 결제금액 맵핑오류
                integrationOrderLineItemTable.PaymentAmount = productRequestLineItem.Payment_Amount__c;
                // integrationOrderLineItemTable.PaymentAmount = productRequestLineItem.CARD_PAYMENT_Amount__c + productRequestLineItem.CASH_PAYMENT_Amount__c + productRequestLineItem.POINT_Amount__c;
                System.debug('productRequestLineItem.CARD_PAYMENT_Amount__c + productRequestLineItem.CASH_PAYMENT_Amount__c + productRequestLineItem.POINT_Amount__c :::: ' + productRequestLineItem.CARD_PAYMENT_Amount__c + productRequestLineItem.CASH_PAYMENT_Amount__c + productRequestLineItem.POINT_Amount__c);
                System.debug('PaymentAMount :::: ' + integrationOrderLineItemTable.PaymentAmount);
            }
            // 할인 금액
            integrationOrderLineItemTable.DiscountAmount = productRequestLineItem.Last_Discount_Amount__c;
            // 할인 유형
            //integrationOrderLineItemTable.DiscountType = productRequestLineItem.Parent.SALE_DC_TYPE__c;
            if (productRequestLineItem.SALE_Discount_Type_Code__c == 'V') {
                integrationOrderLineItemTable.DiscountType = 'VIP';
            } else if (productRequestLineItem.SALE_Discount_Type_Code__c == 'E') {
                integrationOrderLineItemTable.DiscountType = '임직원';
            } else if (productRequestLineItem.SALE_Discount_Type_Code__c == 'P') {
                integrationOrderLineItemTable.DiscountType = '프로모션';
            } 
            // 2023.08.14 seung yoon heo 할인유형 추가
             else if (productRequestLineItem.SALE_Discount_Type_Code__c == 'D') {
                integrationOrderLineItemTable.DiscountType = '쿠폰';
            } else if (productRequestLineItem.SALE_Discount_Type_Code__c == 'L') {
                integrationOrderLineItemTable.DiscountType = '회원';
            } 

            // 취소수량
            integrationOrderLineItemTable.CancelQuantity = productRequestLineItem.CANCEL_Quantity__c;
            // 취소금액 (취소수량 * 소비자가)
            if (integrationOrderLineItemTable.CancelQuantity != null && integrationOrderLineItemTable.CancelQuantity > 0 && integrationOrderLineItemTable.CustomerPrice != null && integrationOrderLineItemTable.CustomerPrice > 0) {
                integrationOrderLineItemTable.CancelAmount = integrationOrderLineItemTable.CancelQuantity * integrationOrderLineItemTable.CustomerPrice;
            } else {
                integrationOrderLineItemTable.CancelAmount = 0;
            }

            // 반품수량
            //23.10.20 PHJ -> 23 10 22 hyungho.chun 원복
            integrationOrderLineItemTable.ReturnQuantity = productRequestLineItem.Return_Order_Quantity__c;
            // integrationOrderLineItemTable.ReturnQuantity = 0;

            integrationOrderLineItemTable.ParentLocationId = productRequestLineItem.SourceLocation.ParentLocationId__c;
            integrationOrderLineItemTable.ParentLocation = productRequestLineItem.SourceLocation.ParentLocationId__r.Name;
            integrationOrderLineItemTable.Product2Id = productRequestLineItem.Product2Id;
            integrationOrderLineItemTable.LocationId = productRequestLineItem.SourceLocationId;
            integrationOrderLineItemTable.SR_RSRV_PART_Id = productRequestLineItem.Parent.SR_RSRV_PART_Id__c;
            //20230515 ysh
            integrationOrderLineItemTable.RSRV_Number = productRequestLineItem.RSRV_Number__c;

            // CJ 주문번호
            // FFMT_Order_Number__c
            integrationOrderLineItemTable.CJOrderNumber = isCJSend ? productRequestLineItem.FFMT_Order_Number__c : null;
            // CJ 주문 전송여부
            // FFMT_Order_Transfer_YN__c
            integrationOrderLineItemTable.CJOrderSendYN = isCJSend ? 'Y' : 'N';
            // CJ 주문 전송일시
            // FFMT_Transfer_DTM__c
            integrationOrderLineItemTable.CJOrderSendDate = isCJSend ? productRequestLineItem.FFMT_Transfer_DTM__c : null;
            if (EX_ConsumableUtil.CONSUMABLE_DELIVERY_STATUS_CODE_KOR_MAP.containsKey(productRequestLineItem.DELIVERY_STATUS_CODE__c)) {
                integrationOrderLineItemTable.DeliveryStatus = EX_ConsumableUtil.CONSUMABLE_DELIVERY_STATUS_CODE_KOR_MAP.get(productRequestLineItem.DELIVERY_STATUS_CODE__c);
            }

            // 출하일시
            // SHIP_DTM__c
            integrationOrderLineItemTable.ShipmentDate = isCJSend ? productRequestLineItem.SHIP_DTM__c : null;
            // 배송일시
            // Delivery_DTM__c
            integrationOrderLineItemTable.DeliveryDate = isCJSend && EX_ConsumableUtil.returnStatusKORMap(productRequestLineItem.Consumables_Order_Status__c) == '배송완료' ? productRequestLineItem.Delivery_DTM__c : null;

            // 택배사
            integrationOrderLineItemTable.DeliveryCompany = isCJSend ? productRequestLineItem.DELIVERY_CODE__c : null;
            // 택배비
            // PARCEL_FEE_Amount__c
            integrationOrderLineItemTable.DeliveryFee = productRequestLineItem.PARCEL_FEE_Amount__c;
            // 배송 Section End

            // 취소 Section Start

            // 취소 부서
            if(productRequestLineItem.CANCEL_Department_Code__c != null){
                //integrationOrderLineItemTable.CancelDepartment = EX_ConsumableUtil.getDepartmentName(productRequestLineItem.CANCEL_Department_Code__c);
                integrationOrderLineItemTable.CancelDepartment = deptNameMap.containsKey(productRequestLineItem.CANCEL_Department_Code__c)
                        ? deptNameMap.get(productRequestLineItem.CANCEL_Department_Code__c)
                        : '';
            }
            // 취소자사번
            integrationOrderLineItemTable.CancelRequesterEmployeeNumber = productRequestLineItem.CANCEL_UserId__r.EmployeeNumber__c ;
            // 취소자
            // CANCEL_User__c
            integrationOrderLineItemTable.CancelRequester = productRequestLineItem.CANCEL_UserId__r.name;
            // 취소요청일시
            integrationOrderLineItemTable.CancelRequestedDate = productRequestLineItem.CANCEL_Request_DTM__c;
            // 취소사유
            integrationOrderLineItemTable.CancelRequestReason = productRequestLineItem.CANCEL_Reason__c;
            // 취소 Section End

            // 반품 Section Start

            // 반품 Section End

            // 교환 Section Start
            // 교환요청부서
            if (productRequestLineItem.Exchange_Request_Department_Code__c != null) {
                //integrationOrderLineItemTable.ExchangeRequesterDepartment = EX_ConsumableUtil.getDepartmentName(productRequestLineItem.Exchange_Request_Department_Code__c);
                integrationOrderLineItemTable.ExchangeRequesterDepartment = deptNameMap.containsKey(productRequestLineItem.Exchange_Request_Department_Code__c)
                        ? deptNameMap.get(productRequestLineItem.Exchange_Request_Department_Code__c)
                        : '';
            }
            // 교환요청자
            integrationOrderLineItemTable.ExchangeRequester = productRequestLineItem.Exchange_Requester_Id__r.Name == 'xplenty' ? '' : productRequestLineItem.Exchange_Requester_Id__r.Name;
            // 교환요청자사번 23.10.19 PHJ 
            integrationOrderLineItemTable.ExchangeRequesterEmployeeNumber = productRequestLineItem.Exchange_Requester_Id__r.EmployeeNumber__c == 'xplenty' ? '' : productRequestLineItem.Exchange_Requester_Id__r.EmployeeNumber__c;
            // 교환요청일시
            integrationOrderLineItemTable.ExchangeRequestedDate = productRequestLineItem.Exchange_Request_DTM__c;
            // 교환 Section End

            integrationOrderLineItemTable.CaseNumber = productRequestLineItem.Parent.Case.Subject;
            integrationOrderLineItemTable.CaseURL = productRequestLineItem.Parent.fmURL_CaseNumber__c;

            // 23.02.19 추가
            integrationOrderLineItemTable.OrderStatusChangeHistory = productRequestLineItem.Order_Status_Change_History__c;


            integrationOrderLineItemTable.ContactId = productRequestLineItem.Order_CUST_Id__c;

            // 결제방법코드
            integrationOrderLineItemTable.PaymentMethodCode = productRequestLineItem.Parent.PAYMENT_Method_Code__c;

            String paymentMethodCode = productRequestLineItem.Parent.PAYMENT_Method_Code__c;
            String paymentType = productRequestLineItem.Parent.PAYMENT_TYPE__c;
            if (paymentMethodCode != null || paymentType != null) {
                if (paymentMethodCode == 'CARD' && paymentType == 'CARD') {
                    integrationOrderLineItemTable.PaymentMethod = '실물카드';
                } else if (paymentType == 'CASH') {
                    integrationOrderLineItemTable.PaymentMethod = '현금입금';
                } else if (paymentMethodCode == 'POINT') {
                    integrationOrderLineItemTable.PaymentMethod = '포인트';
                } else if (paymentMethodCode == 'DISCOUNT') {
                    integrationOrderLineItemTable.PaymentMethod = '할인';
                } else if (paymentType == 'VBANK' && (productRequestLineItem.CASH_PAYMENT_Amount__c == 0 || productRequestLineItem.CASH_PAYMENT_Amount__c == NULL)) {
                    integrationOrderLineItemTable.PaymentMethod = '가상계좌';
                } else if (paymentType == 'VBANK' && (productRequestLineItem.CASH_PAYMENT_Amount__c != 0 || productRequestLineItem.CASH_PAYMENT_Amount__c != NULL)) {
                    integrationOrderLineItemTable.PaymentMethod = '가상계좌';
                }
                if (paymentMethodCode == 'CARD' && (productRequestLineItem.CARD_PAYMENT_Amount__c == 0 || productRequestLineItem.CARD_PAYMENT_Amount__c == NULL)) {
                    integrationOrderLineItemTable.PaymentMethod = '카드URL';
                } else if (paymentMethodCode == 'CARD' && (productRequestLineItem.CARD_PAYMENT_Amount__c == 0 || productRequestLineItem.CARD_PAYMENT_Amount__c != NULL)) {
                    integrationOrderLineItemTable.PaymentMethod = '카드URL';
                }

                if (paymentType == 'URL') {
                    integrationOrderLineItemTable.PaymentMethod = '결제URL';
                }
                if (paymentType == 'URL' && paymentMethodCode == 'CARD') {
                    integrationOrderLineItemTable.PaymentMethod = '카드URL';
                }
                if (paymentType == 'URL' && paymentMethodCode == 'CASH') {
                    integrationOrderLineItemTable.PaymentMethod = '가상계좌';
                }
            }


            integrationOrderLineItemTable.DeliveryColor = 'bg_color_delivery';
            integrationOrderLineItemTable.CancelColor = 'bg_color_cancel';
            integrationOrderLineItemTable.ReturnColor = 'bg_color_return';
            integrationOrderLineItemTable.ExchangeColor = 'bg_color_exchange';

            integrationOrderLineItemTable.CheckFlag = false;
            System.debug('integrationOrderLineItemTable ::: ' + integrationOrderLineItemTable);
            System.debug('integrationOrderLineItemTable.PaymentAmount :::: ' + integrationOrderLineItemTable.PaymentAmount);
            orderLineItemTables.add(integrationOrderLineItemTable);

            prliIdParentDataMap = new Map<String, Object>();
            prliIdParentDataMap.put('contactName', productRequestLineItem.Order_CUST_Id__r.Name);
            prliIdParentDataMap.put('contactPhone', productRequestLineItem.Order_CUST_Id__r.MobilePhone);
            prliIdParentDataMap.put('createdByName', productRequestLineItem.CreatedBy.Name);
            returnParentMap.put(productRequestLineItem.Id, prliIdParentDataMap);
        }

        // 송장번호 DeliveryInfo 조회용 Id 세팅
        List<String> roliIdList = new List<String>();
        for (ReturnOrderLineItem roli : returnOrderLineItems) {
            if (roli.Consumables_Order_Status__c != null && (roli.Consumables_Order_Status__c.equals('030') || roli.Consumables_Order_Status__c.equals('070') | roli.Consumables_Order_Status__c.equals('120'))) {
                roliIdList.add(roli.Id);
            }
        }

        //송장번호 조회
        // List<Map<String, String>> rodMap_list = new List<Map<String, String>>();
        // if (!roliIdList.isEmpty()) {
        //     rodMap_list = EX_ConsumablesOrderManagementController.getDeliveryNoList(null, roliIdList);
        // }

        // 반품
        for (ReturnOrderLineItem returnOrderLineItem : returnOrderLineItems) {
            integrationOrderLineItemTable = new IntegrationOrderLineItemTable();
            integrationOrderLineItemTable.Id = returnOrderLineItem.Id;
            integrationOrderLineItemTable.OrderQuerySeq = orderQuerySeq++;

            //isPayment = returnOrderLineItem.ProductRequestLineItem.Consumables_Order_Status_Code__c != '결제취소' || returnOrderLineItem.ProductRequestLineItem.Consumables_Order_Status_Code__c != '주문취소' ? true : false;
            //isSale = returnOrderLineItem.ProductRequestLineItem.Consumables_Order_Status_Code__c == '배송중' || returnOrderLineItem.ProductRequestLineItem.Consumables_Order_Status_Code__c == '배송완료' ? true : false;
            //isPayment = EX_ConsumableUtil.returnStatusKORMap(returnOrderLineItem.productRequestLineItem.Consumables_Order_Status__c) != '결제취소' || EX_ConsumableUtil.returnStatusKORMap(returnOrderLineItem.productRequestLineItem.Consumables_Order_Status__c) != '주문취소' ? true : false;
            isSale = (EX_ConsumableUtil.returnStatusKORMap(returnOrderLineItem.ProductRequestLineItem.Consumables_Order_Status__c) == '배송중'
                    || EX_ConsumableUtil.returnStatusKORMap(returnOrderLineItem.ProductRequestLineItem.Consumables_Order_Status__c) == '배송완료')
                    && returnOrderLineItem.ProductRequestLineItem.SALE_Number__c != null ? true : false;
            isCJSend = returnOrderLineItem.FFMT_Order_Transfer_YN__c;

            integrationOrderLineItemTable.TrackingNumber = isCJSend ? returnOrderLineItem.INVOICE_Number__c : null;

            System.debug('returnrderLineItem : ' + returnOrderLineItem);

            switch on returnOrderLineItem.Order_CHNL_TYPE_Code__c {
                when 'B' {
                    integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_OBS_LABEL;
                }
                when 'S' {
                    integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_THINQ_LABEL;
                }
                when 'V' {
                    integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_CIC_LABEL;
                }
                when 'BestShop' {
                    integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_BESTSHOP_LABEL;
                }
                //2023.08.16 seung yoon heo Order_CHNL_TYPE_Code__c == 'Y'  >> 소모품샵  추가
                when 'Y' {
                    //integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_BESTSHOP_LABEL;
                    integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_CICSHOP_LABEL;
                }
                when else {
                    integrationOrderLineItemTable.OrderChannel = '미지정';
                }
            }
            switch on returnOrderLineItem.Consumables_Business_Type_Code__c {
                when 'Return' {
                    integrationOrderLineItemTable.ConsumablesBusinessTypeCode = '반품';
                }
                when 'ExchangeReturn' {
                    integrationOrderLineItemTable.ConsumablesBusinessTypeCode = '교환반품';
                }
            }

            integrationOrderLineItemTable.ParentId = returnOrderLineItem.ProductRequest__c;
            integrationOrderLineItemTable.OrderNumber = returnOrderLineItem.Order_Number__c;
            integrationOrderLineItemTable.SubNumber = returnOrderLineItem.SUB_Order_Number__c;
            integrationOrderLineItemTable.OrderSeq = !returnOrderLineItem.Order_CHNL_TYPE_Code__c.equals('B')
                    ? returnOrderLineItem.Order_SEQ__c
                    : returnOrderLineItem.ProductRequestLineItem.Order_SEQ__c;

            String sn = returnOrderLineItem.SUB_Order_Number__c;
            if (sn != null && sn.contains('-')) {
                Integer targetIndex = sn.split('-').size();
                if (targetIndex > 2) {
                    if (sn.split('-')[targetIndex - 1].equals('01')) {
                        integrationOrderLineItemTable.SubNumber = sn.split('-')[targetIndex - 2] + '-' + sn.split('-')[targetIndex - 1];
                    } else {
                        integrationOrderLineItemTable.SubNumber = 'ㄴ' + sn.split('-')[targetIndex - 2] + '-' + sn.split('-')[targetIndex - 1];
                    }
                } else {
                    integrationOrderLineItemTable.SubNumber = sn;
                }
            } else {
                integrationOrderLineItemTable.SubNumber = sn;
            }

            // 23.02.09 수정
            integrationOrderLineItemTable.OrderDate = returnOrderLineItem.Return_Order_Request_DTM__c;
            integrationOrderLineItemTable.CustomerName = returnOrderLineItem.ProductRequestLineItem.Order_CUST_Id__r.Name;
            integrationOrderLineItemTable.CustomerPhone = returnOrderLineItem.ProductRequestLineItem.Order_CUST_Id__r.MobilePhone;

            // 23.07.18 마스킹 대상 추가
            // 14일 이전 수정 이력이 없는 경우 && 대상 마스킹 상태 인경우 마스킹 처리
            if(returnOrderLineItem.ReturnOrder.fm_ReturnIsMaskingTarget__c && CONSUMABLE_MASKING_STATUS_CODE_SET.contains(returnOrderLineItem.Consumables_Order_Status__c)) {
                integrationOrderLineItemTable.CustomerName = returnOrderLineItem.ReturnOrder.fm_ENC_Order_CUST_Name__c;
                integrationOrderLineItemTable.CustomerPhone = returnOrderLineItem.ReturnOrder.fm_ENC_Order_CUST_TPNO_1__c;
            } else {
                integrationOrderLineItemTable.CustomerName = returnOrderLineItem.ReturnOrder.Order_CUST_Name__c;
                integrationOrderLineItemTable.CustomerPhone = returnOrderLineItem.ReturnOrder.Order_CUST_TPNO_1__c;
            }


            integrationOrderLineItemTable.CONSIGNEE_Name = returnOrderLineItem.CONSIGNEE_Name__c;
            integrationOrderLineItemTable.CONSIGNEE_Phone = returnOrderLineItem.CONSIGNEE_TPNO__c;
            // 23.02.09 추가 todo: CONSIGNEE_Address_Detail
            integrationOrderLineItemTable.CONSIGNEE_Address = returnOrderLineItem.CONSIGNEE_Address__c;
            integrationOrderLineItemTable.CONSIGNEE_Address_Detail = '주소 디테일';

            integrationOrderLineItemTable.OrderStatus = EX_ConsumableUtil.returnStatusKORMap(returnOrderLineItem.Consumables_Order_Status__c);
            integrationOrderLineItemTable.SalesDate = isSale ? returnOrderLineItem.ProductRequestLineItem.CreatedDate : null;

            //취소수량
            integrationOrderLineItemTable.CancelQuantity = 0;
            //반품수량
            integrationOrderLineItemTable.ReturnQuantity = returnOrderLineItem.Actual_Return_Quantity__c;
            //교환수량
            //integrationOrderLineItemTable.ExchangeQuantity = returnOrderLineItem.Consumables_Business_Type_Code__c == 'ExchangeReturn' ? returnOrderLineItem.QuantityReturned : 0;
            //23 09 16 hyungho.chun 교환반품경우 교환수량 0으로 표기
            integrationOrderLineItemTable.ExchangeQuantity = 0;
            //요청수량
            //23 09 16 hyuogho.chun 반품인경우 요청수량 0으로 표기 (EX_ConsumablesOrderManagementController와 같게)
            // integrationOrderLineItemTable.QuantityRequested = returnOrderLineItem.QuantityReturned;
            integrationOrderLineItemTable.QuantityRequested = 0;
            //반품예정수량
            integrationOrderLineItemTable.ExpectedReturnQuantity = returnOrderLineItem.Consumables_Business_Type_Code__c == 'Return' || returnOrderLineItem.Consumables_Business_Type_Code__c == 'ExchangeReturn' ? returnOrderLineItem.Expected_Return_Quantity__c : 0;

            //integrationOrderLineItemTable.DIV = returnOrderLineItem.ENDP_Code__c;
            integrationOrderLineItemTable.DIV = returnOrderLineItem.ProductRequestLineItem.ENDP_Code__c;
            // integrationOrderLineItemTable.RequestedPartNo = returnOrderLineItem.fm_Parts_Number__c;
            integrationOrderLineItemTable.RequestedPartNo = returnOrderLineItem.Parts_Number__c;
            // integrationOrderLineItemTable.ReceivedPartNo = returnOrderLineItem.fm_Parts_Number__c;
            integrationOrderLineItemTable.ReceivedPartNo = returnOrderLineItem.Parts_Number__c;
            // integrationOrderLineItemTable.PartName = returnOrderLineItem.Product2.PART_DESC_KOR__c != null ? returnOrderLineItem.Product2.PART_DESC_KOR__c + '(' + returnOrderLineItem.Product2.Name + ')' : returnOrderLineItem.Product2.Name;
            // integrationOrderLineItemTable.CustomerPrice = returnOrderLineItem.Product2.CUST_PRICE__c != null ? returnOrderLineItem.Product2.CUST_PRICE__c : 0;
            integrationOrderLineItemTable.ASCPrice = returnOrderLineItem.Product2.ASC_PRICE__c != null ? returnOrderLineItem.Product2.ASC_PRICE__c : 0;
            // integrationOrderLineItemTable.SaleAmount = returnOrderLineItem.ProductRequestLineItem.SALE_Amount__c != null ? returnOrderLineItem.ProductRequestLineItem.SALE_Amount__c : 0 ;
            // integrationOrderLineItemTable.DiscountAmount = returnOrderLineItem.ProductRequestLineItem.Last_Discount_Amount__c != null ? returnOrderLineItem.ProductRequestLineItem.Last_Discount_Amount__c : 0;
            // integrationOrderLineItemTable.PaymentAmount = returnOrderLineItem.ProductRequestLineItem.PAYMENT_Amount__c != null ? returnOrderLineItem.ProductRequestLineItem.PAYMENT_Amount__c : 0;
            //integrationOrderLineItemTable.RequestedDate = returnOrderLineItem.ProductRequest__r.CreatedDate;
            // integrationOrderLineItemTable.RequestedUser = returnOrderLineItem.CreatedBy.Name;

            // integrationOrderLineItemTable.DeliveryCompany = isCJSend ? 'CJ대한통운' : null;
            //integrationOrderLineItemTable.TrackingNumber = isCJSend ? '568051311435 외 1건' : null;

            //List<Map<String, String>> results = EX_ConsumablesOrderManagementController.getRoliDeliveryNoList(returnOrderLineItem);
            /*List<Map<String, String>> results = rodMap_list;
            if(!results.isEmpty()){
                if(results.size()>1){
                    String size = String.valueOf(results.size()-1);
                    if(results[0].get(String.valueOf(returnOrderLineItem.id)) != null){
                        integrationOrderLineItemTable.TrackingNumber = isCJSend ? results[0].get(String.valueOf(returnOrderLineItem.id)) + '외 ' + size+'건' : null;
                    }
                } else {
                    if(results[0].get(String.valueOf(returnOrderLineItem.id)) != null){
                        integrationOrderLineItemTable.TrackingNumber = isCJSend ? results[0].get(String.valueOf(returnOrderLineItem.id)) : null;
                    }
                }
            }*/

            //송장번호
            // List<Map<String, String>> results = rodMap_list;
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
            //         integrationOrderLineItemTable.TrackingNumber = isCJSend ? tNum + '외 ' + (matchCnt - 1) + '건' : null;
            //     } else {
            //         integrationOrderLineItemTable.TrackingNumber = isCJSend ? tNum : null;
            //     }
            // }


            integrationOrderLineItemTable.ModelCode = returnOrderLineItem.ProductRequestLineItem.fm_MODEL_Code__c;
            integrationOrderLineItemTable.RequestedDept = listMapCenter.get(returnOrderLineItem.CreatedBy.DEPT_CODE__c);

            // 23.02.13 통합주문관리 컬럼 추가
            ProductRequestLineItem baseOrder = returnOrderLineItem.ProductRequestLineItem;

            // 주문 상세 상태
            //integrationOrderLineItemTable.OrderStatusDetail = EX_ConsumableUtil.returnStatusKORMap(baseOrder.Consumables_Order_DETAIL__c);
            // 송장 번호
            //integrationOrderLineItemTable.TrackingNumber = isCJSend ? '568051311435 외 1건' : null;

            // 요청 Part No
            //integrationOrderLineItemTable.RequestedPartNo = baseOrder.fm_PART_NO__c;
            integrationOrderLineItemTable.RequestedPartNo = returnOrderLineItem.Parts_Number__c;
            // 입고 Part No
            //integrationOrderLineItemTable.ReceivedPartNo = baseOrder.fm_PART_NO__c;
            integrationOrderLineItemTable.ReceivedPartNo = returnOrderLineItem.Parts_Number__c;
            // 대치 (반품은 대치를 표시하지 않음)
            integrationOrderLineItemTable.SubstituteYN = '';
            // 부분 입고
//            integrationOrderLineItemTable.PartiallyReceived = '';

            // 약속 상태 (반품은 약속상태를 표시하지 않음)
            integrationOrderLineItemTable.AppointmentStatus = null;
            // 한글품명
            integrationOrderLineItemTable.PartNameKOR = baseOrder.fm_Consumables_PART_DESC_KOR__c;
            // 품명
            //integrationOrderLineItemTable.PartName = baseOrder.Product2.Name;
            integrationOrderLineItemTable.PartName = returnOrderLineItem.Product2.PART_DESC__c;
            // 모델
            integrationOrderLineItemTable.Model = baseOrder.Product2.MODEL_CODE__c;
            // 출고부서
            //integrationOrderLineItemTable.ShippedDepartment  = baseOrder.SHIPPED_Department_Code__c;
            integrationOrderLineItemTable.ShippedDepartment = null;
            // 소비자가
            //integrationOrderLineItemTable.CustomerPrice = baseOrder.Product2.CUST_PRICE__c;
            // if (returnOrderLineItem.UnitPrice__c > 0) {
            //     integrationOrderLineItemTable.CustomerPrice = returnOrderLineItem.UnitPrice__c;
            // } else {
                //23 12 27 hyungho.chun 화면에서 항상 CONSUMER_Price__c 보이게 
                integrationOrderLineItemTable.CustomerPrice = returnOrderLineItem.CONSUMER_Price__c != null ? returnOrderLineItem.CONSUMER_Price__c : 0;
            // }

            // 판매수량
            integrationOrderLineItemTable.SalesQuantity = 0;
            // 판매금액
            integrationOrderLineItemTable.SaleAmount = returnOrderLineItem.RETURN_SALE_Amount__c == null ? 0 : returnOrderLineItem.RETURN_SALE_Amount__c;


            // 230612 반품 결제금액 표시 관련 교환반품은 결제금액 표시하지 않음.
            // 2023.10.20 seung yoon heo PAYMENT_YN__c 조건 해제
            if(returnOrderLineItem.Consumables_Business_Type_Code__c == 'Return') {
                //결제 완료(선 결제)
                // if (baseOrder.PAYMENT_YN__c == true) {
                    if (baseOrder.CARD_PAYMENT_Amount__c == null) baseOrder.CARD_PAYMENT_Amount__c = 0;
                    if (baseOrder.CASH_PAYMENT_Amount__c == null) baseOrder.CASH_PAYMENT_Amount__c = 0;
                    if (baseOrder.POINT_Amount__c == null) baseOrder.POINT_Amount__c = 0;

                    // 현금결제

                    if (returnOrderLineItem.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c != 0 && returnOrderLineItem.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c != null) {
                        integrationOrderLineItemTable.CashAmount = Math.ceil(returnOrderLineItem.RETURN_VIRTUAL_ACCT_PAYMENT_Amount__c);
                        
                    } else {
                        integrationOrderLineItemTable.CashAmount = 0;
                    }
                    // 카드결제
                    if (returnOrderLineItem.RETURN_CARD_PAYMENT_Amount__c != 0 && returnOrderLineItem.RETURN_CARD_PAYMENT_Amount__c != null) {
                        integrationOrderLineItemTable.CardAmount = Math.ceil(baseOrder.CARD_PAYMENT_Amount__c) != null ? Math.ceil(baseOrder.CARD_PAYMENT_Amount__c) : 0;
                    } else {
                        integrationOrderLineItemTable.CardAmount = 0;
                    }
                    // 포인트결제
                    if (returnOrderLineItem.RETURN_POINT_Amount__c != 0 && returnOrderLineItem.RETURN_POINT_Amount__c != null) {
                        integrationOrderLineItemTable.PointAmount = Math.ceil(returnOrderLineItem.RETURN_POINT_Amount__c);
                    } else {
                        integrationOrderLineItemTable.PointAmount = 0;
                    }

                    integrationOrderLineItemTable.PaymentAmount = returnOrderlineItem.RETURN_PAYMENT_Amount__c;
                // } else {
                //     // 결제 미완료
                //     if (baseOrder.CARD_PAYMENT_Amount__c == null) baseOrder.CARD_PAYMENT_Amount__c = 0;
                //     if (baseOrder.CASH_PAYMENT_Amount__c == null) baseOrder.CASH_PAYMENT_Amount__c = 0;
                //     if (baseOrder.POINT_Amount__c == null) baseOrder.POINT_Amount__c = 0;

                //     // 카드결제
                //     if (baseOrder.CARD_PAYMENT_Amount__c != 0 && baseOrder.CARD_PAYMENT_Amount__c != null) {
                //         // integrationOrderLineItemTable.CardAmount = Math.ceil(baseOrder.CARD_PAYMENT_Amount__c);
                //         integrationOrderLineItemTable.CardAmount = 0;
                //     } else {
                //         integrationOrderLineItemTable.CardAmount = 0;
                //     }
                //     // 현금결제
                //     if (baseOrder.CASH_PAYMENT_Amount__c != 0 && baseOrder.CASH_PAYMENT_Amount__c != null) {
                //         // integrationOrderLineItemTable.CASHAmount = Math.ceil(baseOrder.CASH_PAYMENT_Amount__c);
                //         integrationOrderLineItemTable.CASHAmount = 0;
                //     } else {
                //         integrationOrderLineItemTable.CASHAmount = 0;
                //     }
                //     // 포인트결제
                //     if (baseOrder.POINT_Amount__c != 0 && baseOrder.POINT_Amount__c != null) {
                //         //integrationOrderLineItemTable.PointAmount = Math.ceil(baseOrder.POINT_Amount__c);
                //         integrationOrderLineItemTable.PointAmount = 0;
                //     } else {
                //         integrationOrderLineItemTable.PointAmount = 0;
                //     }

                //     // 결제 예정 금액
                //     integrationOrderLineItemTable.EstimatedPaymentAmount = baseOrder.CARD_PAYMENT_Amount__c + baseOrder.CASH_PAYMENT_Amount__c + baseOrder.POINT_Amount__c;
                //     integrationOrderLineItemTable.PaymentAmount = returnOrderLineItem.RETURN_PAYMENT_Amount__c;
                // }
            } else {
                // 230612 반품 결제금액 표시 관련 교환반품은 결제금액 표시하지 않음.
                integrationOrderLineItemTable.CASHAmount = 0;
                integrationOrderLineItemTable.CardAmount = 0;
                integrationOrderLineItemTable.PointAmount = 0;
                integrationOrderLineItemTable.EstimatedPaymentAmount = 0;
                integrationOrderLineItemTable.PaymentAmount = 0;
            }




            // 할인 금액
            integrationOrderLineItemTable.DiscountAmount = 0;

            // 할인 유형
            // 반품은 할인유형을 표시하지 않음
            integrationOrderLineItemTable.DiscountType = '';

            // 반품수량
//            integrationOrderLineItemTable.ReturnQuantity = baseOrder.Return_Order_Quantity__c;
//            // 교환수량
//            integrationOrderLineItemTable.ExchangeQuantity = 0;

            integrationOrderLineItemTable.ParentLocationId = baseOrder.SourceLocation.ParentLocationId__c;
            integrationOrderLineItemTable.ParentLocation = baseOrder.SourceLocation.ParentLocationId__r.Name;
            integrationOrderLineItemTable.Product2Id = baseOrder.Product2Id;
            integrationOrderLineItemTable.LocationId = baseOrder.SourceLocationId;
            integrationOrderLineItemTable.SR_RSRV_PART_Id = baseOrder.Parent.SR_RSRV_PART_Id__c;

            // 배송 Section Start
            // 판매번호
            // SALE_Number__c
            integrationOrderLineItemTable.SalesNumber = baseOrder.SALE_Number__c;
            // CJ 주문번호
            integrationOrderLineItemTable.CJOrderNumber = returnOrderLineItem.FFMT_Order_Number__c;
            // CJ 주문 전송여부
            integrationOrderLineItemTable.CJOrderSendYN = returnOrderLineItem.FFMT_Order_Transfer_YN__c ? 'Y' : 'N';
            // CJ 주문 전송일시
            integrationOrderLineItemTable.CJOrderSendDate = returnOrderLineItem.FFMT_Transfer_DTM__c;

            // 230612 / 반품 즈믄상태 반품확정/반품완료 인 경우 배송완료로 표시
//            if (EX_ConsumableUtil.returnStatusKORMap(baseOrder.Consumables_Order_Status__c) == '배송중' || EX_ConsumableUtil.returnStatusKORMap(baseOrder.Consumables_Order_Status__c) == '배송완료') {
//                integrationOrderLineItemTable.DeliveryStatus = EX_ConsumableUtil.returnStatusKORMap(baseOrder.Consumables_Order_Status__c);
//            }
            if(returnOrderLineItem.Consumables_Order_Status__c == '120' || returnOrderLineItem.Consumables_Order_Status__c == '121') {
                integrationOrderLineItemTable.DeliveryStatus = '배송완료';
            }


            // 출하일시
            // SHIP_DTM__c
//            integrationOrderLineItemTable.ShipmentDate = isCJSend ? baseOrder.CreatedDate.addHours(4) : null;
            // 배송일시
            // Delivery_DTM__c
//            integrationOrderLineItemTable.DeliveryDate = isCJSend && EX_ConsumableUtil.returnStatusKORMap(baseOrder.Consumables_Order_Status__c) == '배송완료' ? baseOrder.CreatedDate.addDays(2) : null;
            // 택배사
            integrationOrderLineItemTable.DeliveryCompany = isCJSend ? 'CJGLS' : null;
            // 택배비
            // PARCEL_FEE_Amount__c
            integrationOrderLineItemTable.DeliveryFee = 0;
            // 배송 Section End

            // 반품부서명
            // ReturnOrderLineItem.Department_Code__c
//            integrationOrderLineItemTable.ReturnDepartment = returnOrderLineItem.Return_Requester_Id_c__r.DEPT_NAME__c;
            if(returnOrderLineItem.Return_Order_Department_Code__c != null) {
                //integrationOrderLineItemTable.ReturnDepartment = EX_ConsumableUtil.getDepartmentName(returnOrderLineItem.Return_Order_Department_Code__c);
                // 2024.03.15 seung yoon heo 반품부서명 OBS, 반품일 경우 '' 표시
                integrationOrderLineItemTable.ReturnDepartment = returnOrderLineItem.Order_CHNL_TYPE_Code__c == 'B' && returnOrderLineItem.Consumables_Business_Type_Code__c == 'Return' ? '' : deptNameMap.containsKey(returnOrderLineItem.Return_Order_Department_Code__c)
                        ? deptNameMap.get(returnOrderLineItem.Return_Order_Department_Code__c)
                        : '';
            }
            //Consumables_Business_Type_Code__c
            
            // 반품요청자사번
            integrationOrderLineItemTable.ReturnRequesterEmployeeNumber = returnOrderLineItem.Return_Requester_Id_c__r.EmployeeNumber__c;
            // 반품요청자명
            // integrationOrderLineItemTable.ReturnRequester = returnOrderLineItem.Order_CHNL_TYPE_Code__c != 'B'  ? returnOrderLineItem.Return_Requester_Id_c__r.Name : '';
            // 2023.10.16 seung yoon heo 반품요청자 안뜨는 현상 해결
            integrationOrderLineItemTable.ReturnRequester = returnOrderLineItem.Return_Requester_Id_c__c != null  ? returnOrderLineItem.Return_Requester_Id_c__r.Name : '';
            // 반품요청일시
            // ReturnOrderLineItem.Return_Order_Request_DTM__c
            integrationOrderLineItemTable.ReturnRequestedDate = returnOrderLineItem.Return_Order_Request_DTM__c;
            // 반품요청사유
            integrationOrderLineItemTable.ReturnRequestReason = returnOrderLineItem.Return_Requester_Reason__c;
            // 반품요청상태
            //integrationOrderLineItemTable.ReturnRequestStatus = returnOrderLineItem.Return_Request_Status__c;
            // 2023-07-14 gw.lee
            // 반품승인일시
            //integrationOrderLineItemTable.ReturnApprovedDate = returnOrderLineItem.Return_Order_Approval_DTM__c;
            integrationOrderLineItemTable.ReturnApprovedDate = returnOrderLineItem.Return_Order_CONFIRM_DTM__c;

            //배송일시 seung yoon hoe 반품확정일시값으로 입력
            integrationOrderLineItemTable.DeliveryDate = returnOrderLineItem.Return_Order_CONFIRM_DTM__c;

            // 교환요청부서
            // Exchange_Request_Department_Code__c
            //integrationOrderLineItemTable.ExchangeRequesterDepartment = returnOrderLineItem.Exchange_Order_Item_Id__r.Department_Code__c;
            // 교환요청자
            // Exchange_Requester_Id__c
            //integrationOrderLineItemTable.ExchangeRequester = returnOrderLineItem.Exchange_Order_Item_Id__r.CreatedBy.Name;
            // 교환요청일시
            // Exchange_Request_DTM__c
            //integrationOrderLineItemTable.ExchangeRequestedDate = returnOrderLineItem.Exchange_Order_Item_Id__r.CreatedDate;
            // 교환 Section End

            // 상담 Case 번호
            //integrationOrderLineItemTable.CaseNumber = '';
            integrationOrderLineItemTable.CaseNumber = '';

            // Column Color Setting
            integrationOrderLineItemTable.DeliveryColor = 'bg_color_delivery';
            integrationOrderLineItemTable.CancelColor = 'bg_color_cancel';
            integrationOrderLineItemTable.ReturnColor = 'bg_color_return';
            integrationOrderLineItemTable.ExchangeColor = 'bg_color_exchange';

            // 23.02.09 교환상태변경 컬럼 추가
            // integrationOrderLineItemTable.OrderSeq = returnOrderLineItem.Order_SEQ__c;
            integrationOrderLineItemTable.CheckFlag = false;

            //24 01 26 hyungho.chun 상태값이 null(목표는 반품반려)이거나 '반품대기'일때는 통합주문관리화면에 연결된 returnOrderLineitem 보이지 않게     
            if(integrationOrderLineItemTable.OrderStatus != null && integrationOrderLineItemTable.OrderStatus != '반품대기'){
                orderLineItemTables.add(integrationOrderLineItemTable);
            }

            // orderLineItemTables.add(integrationOrderLineItemTable);

            prliIdParentDataMap = new Map<String, Object>();
            prliIdParentDataMap.put('contactName', returnOrderLineItem.ProductRequestLineItem.Order_CUST_Id__r.Name);
            prliIdParentDataMap.put('contactPhone', returnOrderLineItem.ProductRequestLineItem.Order_CUST_Id__r.MobilePhone);
            prliIdParentDataMap.put('createdByName', returnOrderLineItem.CreatedBy.Name);
            returnParentMap.put(returnOrderLineItem.Id, prliIdParentDataMap);
        }

        // 23.01.27 테스트 용
        System.debug(orderLineItemTables);
        System.debug(JSON.serialize(orderLineItemTables));
        System.debug('orderLineItemTables.size() -> ' + orderLineItemTables.size());
        orderLineItemTables.sort();
        System.debug(JSON.serialize(orderLineItemTables));
        returnMap.put('productRequestLineItems', orderLineItemTables);
        returnMap.put('parent', returnParentMap);

        return returnMap;
    }

    // 송장번호 조회
    @AuraEnabled
    public static Map<String, Object> doGetTrackingNumberList(String str) {
        Map<String, Object> mapResult = new Map<String, Object>();
        mapResult.put('data', 'https://tracker.delivery/#/kr.cjlogistics/364377440874');

        return mapResult;
    }

    /**
    * @description 주문 리스트 조회
    *
    * @author 23.01.25 / I2MAX
    * @return
    */
    // 주문리스트 조회
    @AuraEnabled
    public static Map<String, Object> doGetSearchOrderList(Map<String, Object> mapSearchOrderParam) {
        Map<String, Object> returnMap = new map<String, Object>();

        String strQuery = '';
        // SELECT
         //2023.08.17 seung yoon heo field 추출
        // strQuery += ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
        strQuery += ' SELECT Id ';
        strQuery += ', FFMT_Order_Transfer_YN__c ';
        strQuery += ', Order_CHNL_TYPE_Code__c ';
        strQuery += ', CreatedDate ';
        strQuery += ', PAYMENT_DTM__c ';
        strQuery += ', Order_Number__c ';
        strQuery += ', Order_SEQ__c ';
        strQuery += ', CONSIGNEE_Name__c ';
        strQuery += ', CONSIGNEE_TPNO_1__c ';
        strQuery += ', CONSIGNEE_TPNO_2__c ';
        strQuery += ', ENDP_Code__c ';
        strQuery += ', fm_PART_NO__c ';
        strQuery += ', QuantityRequested ';
        strQuery += ', LOCATED_PLACE_Number__c ';
        strQuery += ', FFMT_Transfer_DTM__c ';
        strQuery += ', FFMT_Order_Number__c ';
        strQuery += ', Consumables_Order_Status__c ';

        strQuery += ', Parent.CreatedDate ';
        strQuery += ', Order_CUST_Id__r.MobilePhone ';
        strQuery += ', Order_CUST_Id__r.Name ';
        strQuery += ', Product2.PART_DESC_KOR__c ';
        strQuery += ', CreatedBy.Name ';
        strQuery += ', Parent.CONSIGNEE_Address__c ';
        strQuery += ', Parent.CONSIGNEE_CHG_YN__c ';
        strQuery += ', Parent.Order_Date__c ';

        // FROM
        strQuery += ' FROM ' + 'ProductRequestLineItem';

        // WHERE
        // strQuery += ' WHERE Id != null ';
        strQuery += ' WHERE Consumables_Order_YN__c = TRUE ';
        // 주문상태
        //strQuery += ' AND Consumables_Order_Status_Code__c = \'결제요청\'' ;
        strQuery += ' AND Consumables_Order_Status__c = \'001\'' ;

        if (mapSearchOrderParam.get('orderChannel') != null && mapSearchOrderParam.get('orderChannel') != '' && mapSearchOrderParam.get('orderChannel') != 'ALL') {
            // 주문 채널
            String orderChannel = (String) mapSearchOrderParam.get('orderChannel');
            strQuery += ' AND Order_CHNL_TYPE_Code__c = \'' + orderChannel + '\'';
        }

        if (mapSearchOrderParam.get('department') != null && mapSearchOrderParam.get('department') != '' && mapSearchOrderParam.get('department') != 'ALL') {
            // 사업부
            String department = (String) mapSearchOrderParam.get('department');
            strQuery += ' AND ENDP_Code__c = \'' + department + '\'';
        }

        if (mapSearchOrderParam.get('orderNo') != null && mapSearchOrderParam.get('orderNo') != '') {
            // 주문 번호
            String orderNo = (String) mapSearchOrderParam.get('orderNo');
            strQuery += ' AND Order_Number__c LIKE \'' + '%' + orderNo + '%' + '\'';
        }

        if (mapSearchOrderParam.get('baseDateStart') != null && mapSearchOrderParam.get('baseDateEnd') != null
                && mapSearchOrderParam.get('baseDateStart') != '' && mapSearchOrderParam.get('baseDateEnd') != '') {
            // 소모품 주문 시작 기준 일자
            strQuery += ' AND DAY_ONLY(convertTimezone(Parent.Order_Date__c)) >= ' + mapSearchOrderParam.get('baseDateStart');
            // 소모품 주문 종료 기준 일자
            strQuery += ' AND DAY_ONLY(convertTimezone(Parent.Order_Date__c)) <= ' + mapSearchOrderParam.get('baseDateEnd');
        }

        if (mapSearchOrderParam.get('contactName') != null && mapSearchOrderParam.get('contactName') != '') {
            // 고객명
            String contactName = (String) mapSearchOrderParam.get('contactName');
            strQuery += ' AND Order_CUST_Id__r.Name = \''  + contactName  + '\'';
        }

        if (mapSearchOrderParam.get('contactPhone') != null && mapSearchOrderParam.get('contactPhone') != '') {
            // 소모품 주문 고객 전화 번호
            String contactPhone = (String) mapSearchOrderParam.get('contactPhone');
            strQuery += ' AND Order_CUST_Id__r.MobilePhone LIKE \'' + '%' + contactPhone + '%' + '\'';
        }

        // CJ 전송 여부
        Boolean CJOrderY;
        Boolean CJOrderN;
        if (mapSearchOrderParam.get('CJOrderY') == true && mapSearchOrderParam.get('CJOrderN') == true) {
            CJOrderY = (Boolean) mapSearchOrderParam.get('CJOrderY');
            CJOrderN = (Boolean) mapSearchOrderParam.get('CJOrderN');
            strQuery += ' AND (FFMT_Order_Transfer_YN__c = true OR  FFMT_Order_Transfer_YN__c = false) ';
        } else {
            if (mapSearchOrderParam.get('CJOrderY') != null && mapSearchOrderParam.get('CJOrderY') != '' && mapSearchOrderParam.get('CJOrderY') == true) {
                CJOrderY = (Boolean) mapSearchOrderParam.get('CJOrderY');
                strQuery += ' AND FFMT_Order_Transfer_YN__c = true ';
            }
            if (mapSearchOrderParam.get('CJOrderN') != null && mapSearchOrderParam.get('CJOrderN') != '' && mapSearchOrderParam.get('CJOrderN') == true) {
                CJOrderN = (Boolean) mapSearchOrderParam.get('CJOrderN');
                strQuery += ' AND FFMT_Order_Transfer_YN__c = false ';
            }
        }

        if (mapSearchOrderParam.get('CJOrderNo') != null && mapSearchOrderParam.get('CJOrderNo') != '') {
            // CJ 출고 번호
            String CJOrderNo = (String) mapSearchOrderParam.get('CJOrderNo');

            strQuery += ' AND FFMT_Order_Number__c  = \'' + mapSearchOrderParam.get('CJorderNo') + '\'';
        }

        // ORDER BY 결제유형이 CASH이고 결제여부가 N인경우에만 검색
        strQuery += 'AND PAYMENT_TYPE__c = \'CASH\' AND PAYMENT_YN__c = false ORDER BY CreatedDate DESC ';

        System.debug('### strQuery -> ' + strQuery);
        List<ProductRequestLineItem> productRLineItems = Database.query(strQuery);
        //returnMap.put('productRLineItems', productRLineItems);

        Map<String, Map<String, Object>> reParentMap = new Map<String, Map<String, Object>>();
        Map<String, Object> prParentDataMap;
        List<IntegrationOrderLineItemTable> orderListLineItemTable = new List<IntegrationOrderLineItemTable>();
        IntegrationOrderLineItemTable integrationOrderLineItemTable;

        Boolean CJOrderYN = false;

        for (ProductRequestLineItem productRequestLineItem : productRLineItems) {
            integrationOrderLineItemTable = new IntegrationOrderLineItemTable();
            integrationOrderLineItemTable.Id = productRequestLineItem.Id;

            CJOrderYN = productRequestLineItem.FFMT_Order_Transfer_YN__c;

            switch on productRequestLineItem.Order_CHNL_TYPE_Code__c {
                when 'B' {
                    integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_OBS_LABEL;
                }
                when 'S' {
                    integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_THINQ_LABEL;
                }
                when 'V' {
                    integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_CIC_LABEL;
                }
                when 'BestShop' {
                    integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_BESTSHOP_LABEL;
                }
                //2023.08.16 seung yoon heo Order_CHNL_TYPE_Code__c == 'Y'  >> 소모품샵  추가
                when 'Y' {
                //integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_BESTSHOP_LABEL;
                    integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_CICSHOP_LABEL;
                }
                when else {
                    integrationOrderLineItemTable.OrderChannel = '미지정';
                }
            }

            // 23.02.09 수정
            // integrationOrderLineItemTable.OrderDate = productRequestLineItem.Parent.CreatedDate;
            integrationOrderLineItemTable.OrderDate = productRequestLineItem.CreatedDate;
            integrationOrderLineItemTable.PaymentDate = productRequestLineItem.PAYMENT_DTM__c;
            integrationOrderLineItemTable.OrderNumber = productRequestLineItem.Order_Number__c;
            integrationOrderLineItemTable.OrderSeq = productRequestLineItem.Order_SEQ__c;
            integrationOrderLineItemTable.CustomerName = productRequestLineItem.Order_CUST_Id__r.Name;
            integrationOrderLineItemTable.CustomerPhone = productRequestLineItem.Order_CUST_Id__r.MobilePhone;
            integrationOrderLineItemTable.CONSIGNEE_Name = productRequestLineItem.CONSIGNEE_Name__c;
            integrationOrderLineItemTable.CONSIGNEE_Phone = productRequestLineItem.CONSIGNEE_TPNO_1__c != null ? productRequestLineItem.CONSIGNEE_TPNO_1__c : productRequestLineItem.CONSIGNEE_TPNO_2__c ;
            integrationOrderLineItemTable.DIV = productRequestLineItem.ENDP_Code__c;
            integrationOrderLineItemTable.PartName = productRequestLineItem.Product2.PART_DESC_KOR__c;
            integrationOrderLineItemTable.RequestedPartNo = productRequestLineItem.fm_PART_NO__c;
            //integrationOrderLineItemTable.RequestAmount = productRequestLineItem.Request_Amount__c;
            integrationOrderLineItemTable.ReceivedPartNo = productRequestLineItem.fm_PART_NO__c;
            //integrationOrderLineItemTable.ReceivedAmount = productRequestLineItem.RSV_Amount__c;
            integrationOrderLineItemTable.QuantityRequested = productRequestLineItem.QuantityRequested;
            integrationOrderLineItemTable.CenterLocatedPlace = productRequestLineItem.LOCATED_PLACE_Number__c;
            integrationOrderLineItemTable.LocatedPlace = productRequestLineItem.LOCATED_PLACE_Number__c;
            integrationOrderLineItemTable.CJOrderSendYN = CJOrderYN ? 'Y' : 'N';
            integrationOrderLineItemTable.CJSendDate = productRequestLineItem.FFMT_Transfer_DTM__c;
            integrationOrderLineItemTable.CJOrderNumber = productRequestLineItem.FFMT_Order_Number__c;
            integrationOrderLineItemTable.RequestedUser = productRequestLineItem.Order_CHNL_TYPE_Code__c != 'B' ? productRequestLineItem.CreatedBy.Name : '';
            integrationOrderLineItemTable.CONSIGNEE_Address = productRequestLineItem.Parent.CONSIGNEE_Address__c;
            //integrationOrderLineItemTable.OrderStatus = productRequestLineItem.Consumables_Order_Status_Code__c;

            integrationOrderLineItemTable.OrderStatus = EX_ConsumableUtil.returnStatusKORMap(productRequestLineItem.Consumables_Order_Status__c);

            integrationOrderLineItemTable.CONSIGNEE_CHANGE_YN = productRequestLineItem.Parent.consignee_chg_yn__c == true ? 'Y' : 'N';

            orderListLineItemTable.add(integrationOrderLineItemTable);

            prParentDataMap = new Map<String, Object>();
            prParentDataMap.put('contactName', productRequestLineItem.Order_CUST_Id__r.Name);
            prParentDataMap.put('contactPhone', productRequestLineItem.Order_CUST_Id__r.MobilePhone);
            prParentDataMap.put('createdByName', productRequestLineItem.CreatedBy.Name);
            reParentMap.put(productRequestLineItem.Id, prParentDataMap);
        }
        returnMap.put('productRLineItems', orderListLineItemTable);
        returnMap.put('parent', reParentMap);

        return returnMap;
    }

    @AuraEnabled
    public static Map<String, Object> doGetConsigneeDetail(String orderNumber) {
        Map<String, Object> returnMap = new Map<String, Object>();

        // SELECT
        //2023.08.17 seung yoon heo field 추출
        String strQuery = '';
        // strQuery += ' SELECT ' + sObjectUtil.getFieldForQuery('ProductRequest');
        strQuery += ' SELECT Id ';
        strQuery += ' , Order_Number__c ';
        strQuery += ' , CONSIGNEE_Name__c ';
        strQuery += ' , CONSIGNEE_TPNO_1__c ';
        strQuery += ' , CONSIGNEE_TPNO_2__c ';
        strQuery += ' , CONSIGNEE_PostalCode__c ';
        strQuery += ' , CONSIGNEE_Address__c ';
        strQuery += ' , CONSIGNEE_Address_DETAIL__c ';

        // FROM
        strQuery += ' FROM ' + ' ProductRequest ';

        // WHERE
        strQuery += ' WHERE Order_Number__c =  \'' + orderNumber + '\' ';

        System.debug('strQuery -> ' + strQuery);
        List<ProductRequest> productRequestItems = Database.query(strQuery);

        List<IntegrationOrderLineItemTable> orderListLineItemTable = new List<IntegrationOrderLineItemTable>();
        IntegrationOrderLineItemTable integrationOrderLineItemTable;

        for (ProductRequest productRequestItem : productRequestItems) {
            integrationOrderLineItemTable = new IntegrationOrderLineItemTable();
            integrationOrderLineItemTable.Id = productRequestItem.Id;

            integrationOrderLineItemTable.OrderNumber = productRequestItem.Order_Number__c;
            integrationOrderLineItemTable.CONSIGNEE_Name = productRequestItem.CONSIGNEE_Name__c;
            integrationOrderLineItemTable.CONSIGNEE_Phone = (productRequestItem.CONSIGNEE_TPNO_1__c != '' && productRequestItem.CONSIGNEE_TPNO_1__c != NULL) ? productRequestItem.CONSIGNEE_TPNO_1__c : productRequestItem.CONSIGNEE_TPNO_2__c ;
            integrationOrderLineItemTable.CONSIGNEE_PostalCode = productRequestItem.CONSIGNEE_PostalCode__c;
            integrationOrderLineItemTable.CONSIGNEE_Address = productRequestItem.CONSIGNEE_Address__c;
            integrationOrderLineItemTable.CONSIGNEE_Address_Detail = productRequestItem.CONSIGNEE_Address_DETAIL__c;
            integrationOrderLineItemTable.CONSIGNEE_CHANGE_YN = 'Y';
            orderListLineItemTable.add(integrationOrderLineItemTable);
        }
        returnMap.put('productRequest', orderListLineItemTable);
        return returnMap;
    }

    /**
    * @description 수취인 업데이트
    *
    * @author 23.01.31 / I2MAX
    * @return
    */
    @AuraEnabled
    public static Map<String, Object> doUpdateConsigneeData(Map<String, Object> productRequesItem) {
        Boolean isSuccess = true;
        ProductRequest updatePRItem;

        try {
            updatePRItem = new ProductRequest();
            updatePRItem.Id = (Id) productRequesItem.get('Id');
            updatePRItem.CONSIGNEE_Name__c = (String) productRequesItem.get('CONSIGNEE_Name__c');
            updatePRItem.CONSIGNEE_TPNO_1__c = (String) productRequesItem.get('CONSIGNEE_TPNO_1__c');
            updatePRItem.CONSIGNEE_Address__c = (String) productRequesItem.get('CONSIGNEE_Address__c');
            updatePRItem.CONSIGNEE_Address_Detail__c = (String) productRequesItem.get('CONSIGNEE_Address_Detail__c');

            updatePRItem.CONSIGNEE_PostalCode__c = (String) productRequesItem.get('CONSIGNEE_PostalCode__c');

            update updatePRItem;

            List<ProductRequest> updateItems = [
                    SELECT CONSIGNEE_Name__c, CONSIGNEE_TPNO_1__c, CONSIGNEE_Address__c, CONSIGNEE_Address_DETAIL__c, CONSIGNEE_PostalCode__c
                    FROM ProductRequest
                    WHERE Id = :updatePRItem.Id
            ];

            for (ProductRequest pRLineItem : updateItems) {
                pRLineItem.CONSIGNEE_Name__c = pRLineItem.CONSIGNEE_Name__c;
                pRLineItem.CONSIGNEE_TPNO_1__c = pRLineItem.CONSIGNEE_TPNO_1__c;
                pRLineItem.CONSIGNEE_Address__c = pRLineItem.CONSIGNEE_Address__c;
                pRLineItem.CONSIGNEE_Address_DETAIL__c = pRLineItem.CONSIGNEE_Address_DETAIL__c;

                pRLineItem.CONSIGNEE_PostalCode__c = pRLineItem.CONSIGNEE_PostalCode__c;
            }

            update updateItems;

        } catch (Exception e) {
            System.debug(e.getMessage());
            isSuccess = false;
        }

        return new Map<String, Object>{
                'isSuccess' => isSuccess
        };
    }
    @AuraEnabled
    public static void doChangeConsignee(Map<String, Object> paramMap) {
        String orderNumber = (String) paramMap.get('orderNumber');
        String newName = (String) paramMap.get('newName');
        String newPhone = (String) paramMap.get('newPhone');
        String newPostalCode = (String) paramMap.get('newPostalCode');
        String newAddress = (String) paramMap.get('newAddress');
        String newDetailAddress = (String) paramMap.get('newDetailAddress');
        String newId = (String) paramMap.get('id');

        System.debug(paramMap);
        ProductRequestLineItem lineItem = [SELECT id, CONSIGNEE_Name__c, CONSIGNEE_TPNO_1__c, CONSIGNEE_PostalCode__c, CONSIGNEE_Address__c, CONSIGNEE_Address_DETAIL__c, Order_Number__c FROM ProductRequestLineItem WHERE id = :newId][0];
        if (newName != '' || newName != null)
            lineItem.CONSIGNEE_Name__c = newName;
        if (newPhone != '' || newPhone != null)
            lineItem.CONSIGNEE_TPNO_1__c = newPhone;
        if (newPostalCode != '' || newPostalCode != null)
            lineItem.CONSIGNEE_PostalCode__c = newPostalCode;
        if (newAddress != '' || newAddress != null)
            lineItem.CONSIGNEE_Address__c = newAddress;
        if (newDetailAddress != '' || newDetailAddress != null)
            lineItem.CONSIGNEE_Address_DETAIL__c = newDetailAddress;
        System.debug(lineItem);
        update lineItem;
    }

    /**
    * @description 계좌검증
    * @author 23.02.15 / I2MAX.SANGHUNYEO
    * @return returnMap
    */
    @AuraEnabled
    public static Map<String, Object> doCheckBankAccount(String bankCode, String bankAccountNo, String receiverName, List<Object> selectedMasterData) {
        Map<String, Object> returnMap = new Map<String, Object>();
        String resultStat = 'SUCCESS';
        String resultMessage = '';
        returnMap = EX_ConsumableUtil.checkBankAccountUtil(bankCode, bankAccountNo, receiverName, selectedMasterData);
        returnMap.put('resultStat', resultStat);
        returnMap.put('resultMessage', resultMessage);
        return returnMap;
    }

    /**
    * @description 주문취소
    * @author 23.02.14 / I2MAX.SANGHUNYEO
    * @return returnMap
    */
    @AuraEnabled
    public static Map<String, Object> doCancel(String strCaseId, String remark, List<Object> selectedRows, List<Object> draftValues, List<Object> selectedMasterData, String bankCode, String bankAccountNo, String receiverName) {
        /*주문취소*/
        Map<String, Object> returnMap = new Map<String, Object>();
        String resultStat = 'SUCCESS';
        String resultMessage = '';
        returnMap = EX_ConsumableUtil.cancelUtil(strCaseId, remark, selectedRows, draftValues, selectedMasterData, bankCode, bankAccountNo, receiverName);

        returnMap.put('resultStat', returnMap.get('resultStat'));
        returnMap.put('resultMessage', returnMap.get('resultMessage'));

        return returnMap;
    }

    /**
   * @description 반품요청에서의 반품 요청시 원 주문의 원 주문 내역(ProductRequestLineItem) 조회
   * @author 23.02.08 / I2MAX.SEOKHOLEE
   * @return returnMap
   */
    @AuraEnabled
    public static Map<String, Object> doGetOrderLineItemDataByReturnRequest(String orderNumber) {
        Map<String, Object> returnMap = new Map<String, Object>();
        // 원주문 항목 먼저 조회
        //2023.08.17 seung yoon heo field 추출
        // String strQuery = ' SELECT ' + SObjectUtil.getFieldForQuery('ProductRequestLineItem');
        String strQuery = ' SELECT Id ';
        strQuery += ' , ParentId ';
        strQuery += ' , Order_Number__c ';
        strQuery += ' , fm_PART_NO__c ';
        strQuery += ' , fm_Consumables_PART_DESC_KOR__c ';
        strQuery += ' , Order_CHNL_TYPE_Code__c ';
        strQuery += ' , Consumables_Order_Status__c ';
        strQuery += ' , CONSUMER_Price__c ';
        strQuery += ' , SALE_Quantity__c ';
        strQuery += ' , SALE_Amount__c ';
        strQuery += ' , Last_Discount_Amount__c ';
        strQuery += ' , PAYMENT_Amount__c ';
        strQuery += ' , ENDP_Code__c ';
        strQuery += ' , PART_NO__c ';
        strQuery += ' , Return_Order_Quantity__c ';
        strQuery += ' , FFMT_Order_Number__c ';
        strQuery += ' , INVOICE_Number__c ';
        strQuery += ' , FFMT_Transfer_DTM__c ';
        strQuery += ' , PAYMENT_DTM__c ';
        strQuery += ' , SHIPPED_Scheduling_Date__c ';
        strQuery += ' , SALE_DTM__c ';
        strQuery += ' , SALE_Number__c ';
        strQuery += ' , SALE_SEQ__c ';
        strQuery += ' , Order_SEQ__c ';
        strQuery += ' , CASH_PAYMENT_Amount__c ';
        strQuery += ' , CARD_PAYMENT_Amount__c ';
        strQuery += ' , POINT_Amount__c ';
        strQuery += ' , Order_CUST_Id__c ';
        
        strQuery += ' , Product2.PART_DESC_KOR__c';
        strQuery += ', Order_CUST_Id__r.Name, Order_CUST_Id__r.MobilePhone, Order_CUST_Id__r.Phone, Order_CUST_Id__r.fm_ADDRESS_NEW__c, Order_CUST_Id__r.fm_ADDRESS_OLD__c, Order_CUST_Id__r.ADDRESS_DETAIL__c';
        strQuery += ' , Parent.SMILE_MIGRATION_DATA_YN__c ';
        strQuery += ', Parent.CaseId, Parent.Case.Description ';
        // 고객 정보
        strQuery += ',  Parent.Order_CUST_Name__c, Parent.Order_CUST_PostalCode__c, Parent.Order_CUST_Address__c, Parent.Order_CUST_Address_DETAIL__c, Parent.Order_CUST_TPNO_1__c  ';
        strQuery += ',        Parent.CONSIGNEE_Name__c, Parent.CONSIGNEE_PostalCode__c, Parent.CONSIGNEE_Address__c, Parent.CONSIGNEE_Address_DETAIL__c, Parent.CONSIGNEE_TPNO_1__c, Parent.Description ';


        strQuery += ' FROM ProductRequestLineItem';
        strQuery += ' WHERE BASIS_Order_Item_Id__c = null';
        strQuery += ' AND Order_Number__c=\'' + orderNumber + '\'';
        strQuery += ' AND Consumables_Order_YN__c = TRUE ';
        strQuery += ' AND RecordType.DeveloperName IN (\'Consumable\', \'CareSupplies\') ';

        List<ProductRequestLineItem> basisOrderList = Database.query(strQuery);
        Set<String> prliIdSet = new Set<String>();
        for (ProductRequestLineItem prli : basisOrderList) {
            prliIdSet.add(prli.Id);
        }

        Map<String, Decimal> basisOrderItemIdExpectedQuantityCountReturnQuantityMap = new Map<String, Decimal>();

        Decimal expectedQuantityCount;

        for (ReturnOrderLineItem roli : [
                SELECT QuantityExpected, QuantityReturned, Id, ProductRequestLineItemId, ProductRequestLineItem.Consumables_Business_Type_Code__c
                FROM ReturnOrderLineItem
                WHERE ProductRequestLineItemId IN :prliIdSet
                AND Consumables_Order_Status__c != :EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_090
                AND Consumables_Business_Type_Code__c = 'Return'
        ]) {
            expectedQuantityCount = 0;

            if (basisOrderItemIdExpectedQuantityCountReturnQuantityMap.containsKey(roli.ProductRequestLineItemId)) {
                expectedQuantityCount = basisOrderItemIdExpectedQuantityCountReturnQuantityMap.get(roli.ProductRequestLineItemId);
                expectedQuantityCount += roli.QuantityReturned;

                basisOrderItemIdExpectedQuantityCountReturnQuantityMap.put(roli.ProductRequestLineItemId, expectedQuantityCount);
            } else {
                expectedQuantityCount = roli.QuantityReturned;

                basisOrderItemIdExpectedQuantityCountReturnQuantityMap.put(roli.ProductRequestLineItemId, expectedQuantityCount);
            }
        }

        List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable> IntegrationOrderLineItemTables = new List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable>();
        EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable itemTable;

        Map<String, Object> contactConsigneeInfoMap = new Map<String, Object>();
        Map<String, Object> caseInfoMap = new Map<String, Object>();

        for (ProductRequestLineItem prli : basisOrderList) {
            itemTable = new EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable();
            itemTable.Id = prli.Id;
            itemTable.ParentId = prli.ParentId;

            // 주문번호
            itemTable.OrderNumber = prli.Order_Number__c;
            // 파트 넘버
            itemTable.ReceivedPartNo = prli.fm_PART_NO__c;
            // 품명
            itemTable.PartName = prli.fm_Consumables_PART_DESC_KOR__c;
            System.debug('prli.fm_Consumables_PART_DESC_KOR__c => ' + prli.fm_Consumables_PART_DESC_KOR__c);

            switch on prli.Order_CHNL_TYPE_Code__c {
                when 'B' {
                    itemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_OBS_LABEL;
                }
                when 'S' {
                    itemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_THINQ_LABEL;
                }
                when 'V' {
                    itemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_CIC_LABEL;
                }
                when 'BestShop' {
                    itemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_BESTSHOP_LABEL;
                }
                //2023.08.16 seung yoon heo Order_CHNL_TYPE_Code__c == 'Y'  >> 소모품샵  추가
                when 'Y' {
                //integrationOrderLineItemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_BESTSHOP_LABEL;
                    itemTable.OrderChannel = EX_ConsumableUtil.CONSUMABLE_CICSHOP_LABEL;
                }
                when else {
                    itemTable.OrderChannel = '미지정';
                }
            }
            //itemTable.OrderStatus = prli.Consumables_Order_Status_Code__c;
//            itemTable.OrderStatus = EX_ConsumableUtil.returnStatusKORMap(prli.Consumables_Order_Status_Code__c);
            itemTable.OrderStatus = EX_ConsumableUtil.returnStatusKORMap(prli.Consumables_Order_Status__c);
            // 소비자가
            itemTable.CustomerPrice = prli.CONSUMER_Price__c;
            // 반품 요청 수량
            itemTable.RequestedReturnQuantity = 0;
            // 반품 요청 금액
            itemTable.RequestedReturnAmount = 0;
            // 주문 수량(판매 수량)
            itemTable.SalesQuantity = prli.SALE_Quantity__c;
            // 판매 금액
            itemTable.SaleAmount = prli.SALE_Amount__c;
            // 할인 금액
            itemTable.DiscountAmount = prli.Last_Discount_Amount__c;
            // 결제 금액
            itemTable.PaymentAmount = prli.PAYMENT_Amount__c;
            // 반품 사유
            itemTable.ReturnRequestReason = null;
            // 반품 컬러
            itemTable.ReturnColor = 'bg_color_return';
            // 반품 사업부 코드
            itemTable.DIV = prli.ENDP_Code__c;
            // 반품 PART NO
            itemTable.RequestedPartNo = prli.PART_NO__c;
            // 반품 매핑 모델

            // 반품 수량
            itemTable.ReturnQuantity = prli.Return_Order_Quantity__c == null ? 0 : prli.Return_Order_Quantity__c;

            // 반품 예정 수량
            if (basisOrderItemIdExpectedQuantityCountReturnQuantityMap.containsKey(prli.Id)) {
                itemTable.ExpectedReturnQuantity = basisOrderItemIdExpectedQuantityCountReturnQuantityMap.get(prli.Id);
            } else {
                itemTable.ExpectedReturnQuantity = 0;
            }

            // 반품 CJ 주문 번호
            itemTable.CJOrderNumber = prli.FFMT_Order_Number__c;
            // 송장 번호
            itemTable.InvoiceNumber = prli.INVOICE_Number__c;
            // 반품 CJ 전송 일시
            itemTable.CJSendDate = prli.FFMT_Transfer_DTM__c ;
            // 반품 연동 여부
            // 반품 수거 여부 최초 생성시 false
            // 반품 확정 여부 최초 생성시 false
            // 반품 요청 사유 최초 생성시 null
            // 결제 일자
            itemTable.PaymentDate = prli.PAYMENT_DTM__c;

            //출고 일자
            itemTable.ReleaseDate = prli.SHIPPED_Scheduling_Date__c;
//            // 반품 배송 완료 여부
//            itemTable.FFMT_Transfer_DTM__c = item.CJSendDate;
//            // 반품 배송 일자 나중에 개발
//            itemTable.FFMT_Transfer_DTM__c = item.CJSendDate;
//            //  판매 일자 나중에 개발
            itemTable.SalesDate = prli.SALE_DTM__c;
//            //  판매 번호
            itemTable.SalesNumber = prli.SALE_Number__c;
//            //  판매 항번
            itemTable.SalesSeq = prli.SALE_SEQ__c;
//            //  주문 항번
            itemTable.OrderSeq = prli.Order_SEQ__c;


            // 반품 현금
            itemTable.CashAmount = prli.CASH_PAYMENT_Amount__c != null ? prli.CASH_PAYMENT_Amount__c : 0;
            // 반품 카드
            itemTable.CardAmount = prli.CARD_PAYMENT_Amount__c != null ? prli.CARD_PAYMENT_Amount__c : 0;
            // 반품 포인트
            itemTable.PointAmount = prli.POINT_Amount__c != null ? prli.POINT_Amount__c : 0;

            // Mig 여부
            itemTable.IsMig = prli.Parent.SMILE_MIGRATION_DATA_YN__c;

            // 고객 이름
            itemTable.CustomerName = prli.Parent.Order_CUST_Name__c;
            // 고객 전화번호
            itemTable.CustomerPhone = prli.Parent.Order_CUST_TPNO_1__c;
            System.debug('IntegrationOrderLineItemTables :::: ' + IntegrationOrderLineItemTables);
            IntegrationOrderLineItemTables.add(itemTable);

            // 고객 / 수취인 정보
            if (!contactConsigneeInfoMap.containsKey('ContactName')) {
                contactConsigneeInfoMap.put('ContactName', prli.Parent.Order_CUST_Name__c);
            }
            if (!contactConsigneeInfoMap.containsKey('ContactMobilePhone')) {
                contactConsigneeInfoMap.put('ContactMobilePhone', prli.Parent.Order_CUST_TPNO_1__c);
            }
            if (!contactConsigneeInfoMap.containsKey('ContactAddress')) {
                contactConsigneeInfoMap.put('ContactAddress', prli.Parent.Order_CUST_Address__c);
            }

            if (!contactConsigneeInfoMap.containsKey('ContactDetailAddress')) {
                contactConsigneeInfoMap.put('ContactDetailAddress', prli.Parent.Order_CUST_Address_DETAIL__c);
            }

            if (!contactConsigneeInfoMap.containsKey('CustomerPostalCode')) {
                contactConsigneeInfoMap.put('CustomerPostalCode', prli.Parent.Order_CUST_PostalCode__c);
            }

            if (!contactConsigneeInfoMap.containsKey('ConsigneeName')) {
                contactConsigneeInfoMap.put('ConsigneeName', prli.Parent.CONSIGNEE_Name__c);
            }
            if (!contactConsigneeInfoMap.containsKey('ConsigneePhone')) {
                contactConsigneeInfoMap.put('ConsigneePhone', prli.Parent.CONSIGNEE_TPNO_1__c);
            }
            if (!contactConsigneeInfoMap.containsKey('ConsigneeAddress')) {
                contactConsigneeInfoMap.put('ConsigneeAddress', prli.Parent.CONSIGNEE_Address__c);
            }
            if (!contactConsigneeInfoMap.containsKey('ConsigneeDetailAddress')) {
                contactConsigneeInfoMap.put('ConsigneeDetailAddress', prli.Parent.CONSIGNEE_Address_DETAIL__c);
            }

            if (!contactConsigneeInfoMap.containsKey('CONSIGNEE_PostalCode')) {
                contactConsigneeInfoMap.put('CONSIGNEE_PostalCode', prli.Parent.CONSIGNEE_PostalCode__c);
            }

            if (!contactConsigneeInfoMap.containsKey('ContactId')) {
                contactConsigneeInfoMap.put('ContactId', prli.Order_CUST_Id__c);
            }

            if (!caseInfoMap.containsKey('CaseId')) {
                if (prli.Parent.CaseId != null) {
                    caseInfoMap.put('CaseId', prli.Parent.CaseId);
                }
            }
            if (!caseInfoMap.containsKey('CaseDescription')) {
                if (prli.Parent.CaseId != null) {
                    caseInfoMap.put('CaseDescription', prli.Parent.Case.Description);
                }
            }
            //23.11.15 PHJ
            if (!caseInfoMap.containsKey('Description')) {
                if (prli.Parent.CaseId != null) {
                    caseInfoMap.put('Description', prli.Parent.Description);
                }
            }
        }
        returnMap.put('productRequestLineItemsByReturnRequest', IntegrationOrderLineItemTables);
        returnMap.put('contactConsigneeInfo', contactConsigneeInfoMap);
        returnMap.put('caseInfo', caseInfoMap);

        return returnMap;
    }

    /**
     * @description 소모품 반품 요청
     * @author 23.02.09 / I2MAX.SEOKHOLEE
     * @return Map
     *
     */
    @AuraEnabled
    public static Map<String, Object> doRequestReturnOrder(Map<String, Object> paramMap) {
        Map<String, Object> returnMap = new Map<String, Object>();


        EX_ConsumableUtil.ConsumableReturnOrderTable consumableReturnOrderTable = new EX_ConsumableUtil.ConsumableReturnOrderTable();
        List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable> itemTables;
        Map<Object, Object> contactConsigneeInfoMap;
        CM_CommonUtil cmUtil = new CM_CommonUtil();


        System.debug(paramMap.get('productRequestLineItemsByReturnRequest'));

        if (paramMap.containsKey('productRequestLineItemsByReturnRequest')) {
            itemTables = (List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable>) JSON.deserialize((String) paramMap.get('productRequestLineItemsByReturnRequest'), List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable>.class);
        }
        System.debug('start====================');
        System.debug(itemTables);
        System.debug('end====================');
        System.debug(paramMap.get('contactConsigneeInfo'));
        if (paramMap.containsKey('contactConsigneeInfo')) {
            contactConsigneeInfoMap = (Map<Object, Object>) paramMap.get('contactConsigneeInfo');
        }

        System.debug('**************************');
        System.debug(paramMap.get('bankCode'));
        System.debug(paramMap.get('bankAccountNo'));
        System.debug(paramMap.get('receiverName'));
        System.debug('**************************');

        String bankCode = '';
        if (paramMap.containsKey('bankCode')) {
            bankCode = (String) paramMap.get('bankCode');
        }
        String bankAccountNo = '';
        if (paramMap.containsKey('bankAccountNo')) {
            bankAccountNo = (String) paramMap.get('bankAccountNo');
        }

        String receiverName = '';
        if (paramMap.containsKey('receiverName')) {
            receiverName = (String) paramMap.get('receiverName');
        }

        consumableReturnOrderTable.ConsumableReturnOrderLineItemTables = itemTables;

        // 230520 반품요청시 원 주문건의 판매처리 여부 확인
//        List<ProductRequest> originPrs = [
//                SELECT SALE_Number__c, SR_SALE__c
//                FROM ProductRequest
//                WHERE Id = :consumableReturnOrderTable.ConsumableReturnOrderLineItemTables[0].ParentId
//                AND SR_SALE__c != null
//        ];

        List<ProductRequestLineItem> originPrlis = [
                SELECT SALE_Number__c, SR_SALE__c
                FROM ProductRequestLineItem
                WHERE ParentId = :consumableReturnOrderTable.ConsumableReturnOrderLineItemTables[0].ParentId
                AND Consumables_Order_Status__c = '070'
                AND Parent.SR_SALE__c = NULL
        ];

        if (!Test.isRunningTest() && !originPrlis.isEmpty()) {
            //throw new AuraHandledException('원 주문건의 판매 처리가 진행되지 않았습니다. 반품 요청시에 판매 저장 처리가 필요합니다.');
        }


        Decimal returnOrderReturnPaymentAmount = 0;
        Decimal returnOrderReturnCardPaymentAmount = 0;
        Decimal returnOrderReturnVBankPaymentAmount = 0;
        Decimal returnOrderReturnPointAmount = 0;

        Decimal returnOrderReturnSaleAmount = 0;
        // Decimal returnOrderReturnPaymentAmount = 0;
        Decimal returnOrderReturnDiscountAmount = 0;

        // 23.05.04 // 환불 관련 금액 필드 세팅
        for (EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable itemTable : itemTables) {
            if (itemTable.RequestedReturnQuantity == 0) {
                throw new AuraHandledException('반품 요청 수량을 1개 이상 입력 하세요.');
            }

            System.debug('########');
            System.debug('환불 itemTable');
            System.debug(itemTable);
            System.debug('########');

            itemTable.ReturnCardPaymentAmount = 0;
            itemTable.ReturnVBankPaymentAmount = 0;
            itemTable.ReturnPointAmount = 0;

            if (itemTable.CardAmount != null && itemTable.CardAmount > 0) {
                // 카드 결제로 판단
                // itemTable.ReturnCardPaymentAmount = itemTable.CardAmount / (itemTable.SalesQuantity / itemTable.RequestedReturnQuantity);
                itemTable.ReturnCardPaymentAmount = itemTable.CardAmount / ((itemTable.SalesQuantity + itemTable.ExpectedReturnQuantity)/ itemTable.RequestedReturnQuantity); //24 02 27 hyungho.chun 부분반품후 또 반품할때 계산 로직 추가
                returnOrderReturnCardPaymentAmount += itemTable.ReturnCardPaymentAmount;
            }
            if (itemTable.CashAmount != null && itemTable.CashAmount > 0) {
                // 현금 결제로 판단
                // itemTable.ReturnVBankPaymentAmount = itemTable.CashAmount / (itemTable.SalesQuantity / itemTable.RequestedReturnQuantity);
                itemTable.ReturnVBankPaymentAmount = itemTable.CashAmount / ((itemTable.SalesQuantity + itemTable.ExpectedReturnQuantity) / itemTable.RequestedReturnQuantity);  //24 02 27 hyungho.chun 부분반품후 또 반품할때 계산 로직 추가
                returnOrderReturnVBankPaymentAmount += itemTable.ReturnVBankPaymentAmount;
            }
            if (itemTable.PointAmount != null && itemTable.PointAmount > 0) {

                // 포인트 결제로 판단
                itemTable.ReturnPointAmount = itemTable.PointAmount;
                returnOrderReturnPointAmount += itemTable.ReturnPointAmount;



                //23 11 06 hyungho.chun 복합결제경우 포인트아닌 다른 방식 금액이 중복으로 들어가서 제외
                // // 부분 환불 불가
                // // 카드 결제금액
                // itemTable.ReturnCardPaymentAmount = itemTable.CardAmount;
                // returnOrderReturnCardPaymentAmount += itemTable.ReturnCardPaymentAmount;

                // // 현금 결제 금액
                // itemTable.ReturnVBankPaymentAmount = itemTable.CashAmount;
                // returnOrderReturnVBankPaymentAmount += itemTable.ReturnVBankPaymentAmount;

            }
            returnOrderReturnSaleAmount += (itemTable.CustomerPrice * itemTable.SalesQuantity);
            returnOrderReturnPaymentAmount += itemTable.PaymentAmount;
            returnOrderReturnDiscountAmount += itemTable.DiscountAmount;

            // 아이템 별 판매 금액
            if(itemTable.RequestedReturnQuantity != null && itemTable.RequestedReturnQuantity > 0) {
                itemTable.SaleAmount = (itemTable.CustomerPrice * itemTable.RequestedReturnQuantity);

            } else {
                itemTable.SaleAmount = (itemTable.CustomerPrice * itemTable.RequestedQuantity);
            }
            // 아이템 별 결제 금액
            itemTable.PaymentAmount = (itemTable.ReturnCardPaymentAmount + itemTable.ReturnVBankPaymentAmount + itemTable.ReturnPointAmount);
            // 아이템 별 할인 금액
            if(itemTable.RequestedReturnQuantity != null && itemTable.RequestedReturnQuantity > 0) {
                itemTable.DiscountAmount = itemTable.DiscountAmount != null ? (itemTable.DiscountAmount / (itemTable.SalesQuantity / itemTable.RequestedReturnQuantity)) : 0;
            } else {
                itemTable.DiscountAmount = itemTable.DiscountAmount != null ? (itemTable.DiscountAmount  / (itemTable.SalesQuantity / itemTable.RequestedQuantity)) : 0;
            }

            System.debug('아이템 별 판매 금액');
            System.debug(itemTable.SaleAmount);
            System.debug('아이템 별 결제 금액');
            System.debug(itemTable.PaymentAmount);
            System.debug(itemTable.ReturnCardPaymentAmount);
            System.debug(itemTable.ReturnVBankPaymentAmount);
            System.debug(itemTable.ReturnPointAmount);
            System.debug('아이템 별 할인 금액');
            System.debug(itemTable.DiscountAmount);

            }

        // consumableReturnOrderTable.ReturnPaymentAmount = returnOrderReturnCardPaymentAmount + returnOrderReturnVBankPaymentAmount + returnOrderReturnPointAmount;
        consumableReturnOrderTable.ReturnCardPaymentAmount = returnOrderReturnCardPaymentAmount;
        consumableReturnOrderTable.ReturnVBankPaymentAmount = returnOrderReturnVBankPaymentAmount;
        consumableReturnOrderTable.ReturnPointAmount = returnOrderReturnPointAmount;
        //23 07 14 hyungho.chun ROLI에 판매금액, 결제금액, 할인금액 값 추가 해야함 그전에 반품요청버튼에서 만들때 묶어주는 param이제대론지확인필요
        // consumableReturnOrderTable.ReturnSaleAmount
        // consumableReturnOrderTable.ReturnPaymentAmount
        // consumableReturnOrderTable.ReturnDiscountAmount
        consumableReturnOrderTable.ReturnSaleAmount = returnOrderReturnSaleAmount;
        consumableReturnOrderTable.ReturnPaymentAmount = returnOrderReturnPaymentAmount;
        consumableReturnOrderTable.ReturnDiscountAmount = returnOrderReturnDiscountAmount;
        system.debug('consumableReturnOrderTable.ReturnSaleAmount ::: '+consumableReturnOrderTable.ReturnSaleAmount);
        system.debug('consumableReturnOrderTable.ReturnPaymentAmount ::: '+consumableReturnOrderTable.ReturnPaymentAmount);
        system.debug('consumableReturnOrderTable.ReturnDiscountAmount ::: '+consumableReturnOrderTable.ReturnDiscountAmount);


        // 23.05.04 // 환불 관련 금액 필드 세팅 END
        System.debug('contactConsigneeInfoMap not null :: ' + contactConsigneeInfoMap != null);
        if (contactConsigneeInfoMap != null) {
            if (contactConsigneeInfoMap.containsKey('ContactName')) {
                consumableReturnOrderTable.CustomerName = (String) contactConsigneeInfoMap.get('ContactName');
            }
            if (contactConsigneeInfoMap.containsKey('ContactMobilePhone')) {
                consumableReturnOrderTable.CustomerPhone = (String) contactConsigneeInfoMap.get('ContactMobilePhone');
                //2023.11.08 seung yoon heo 수취인 전화번호 val
                String checkTelNoValidMessage = cmUtil.checkValidTelNo(consumableReturnOrderTable.CustomerPhone);
                if(!String.isEmpty(checkTelNoValidMessage)) {
                    // 전화번호가 유호 하지 않는 경우 처리 케이스.
                    returnMap.put('isPhoneVal' , checkTelNoValidMessage);
                    return returnMap;
                }

            }
            if (contactConsigneeInfoMap.containsKey('ContactAddress')) {
                consumableReturnOrderTable.CustomerAddress = (String) contactConsigneeInfoMap.get('ContactAddress');
            }
            if (contactConsigneeInfoMap.containsKey('ContactDetailAddress')) {
                consumableReturnOrderTable.CustomerDetailAddress = (String) contactConsigneeInfoMap.get('ContactDetailAddress');
            }
            if (contactConsigneeInfoMap.containsKey('CustomerPostalCode')) {
                consumableReturnOrderTable.CustomerPostalCode = (String) contactConsigneeInfoMap.get('CustomerPostalCode');
            }

            if (contactConsigneeInfoMap.containsKey('ConsigneeName')) {
                consumableReturnOrderTable.CONSIGNEE_Name = (String) contactConsigneeInfoMap.get('ConsigneeName');
            }
            if (contactConsigneeInfoMap.containsKey('ConsigneePhone')) {
                consumableReturnOrderTable.CONSIGNEE_Phone = (String) contactConsigneeInfoMap.get('ConsigneePhone');
                //2023.11.08 seung yoon heo 수취인 전화번호 val
                String checkTelNoValidMessage = cmUtil.checkValidTelNo(consumableReturnOrderTable.CONSIGNEE_Phone);
                if(!String.isEmpty(checkTelNoValidMessage)) {
                    // 전화번호가 유호 하지 않는 경우 처리 케이스.
                    returnMap.put('isPhoneVal' , checkTelNoValidMessage);
                    return returnMap;
                }
            }
            if (contactConsigneeInfoMap.containsKey('ConsigneeAddress')) {
                consumableReturnOrderTable.CONSIGNEE_Address = (String) contactConsigneeInfoMap.get('ConsigneeAddress');
            }
            if (contactConsigneeInfoMap.containsKey('ConsigneeDetailAddress')) {
                consumableReturnOrderTable.CONSIGNEE_DetailAddress = (String) contactConsigneeInfoMap.get('ConsigneeDetailAddress');
            }
            if (contactConsigneeInfoMap.containsKey('CONSIGNEE_PostalCode')) {
                consumableReturnOrderTable.CONSIGNEE_PostalCode = (String) contactConsigneeInfoMap.get('CONSIGNEE_PostalCode');
            }
            if (contactConsigneeInfoMap.containsKey('ContactId')) {
                consumableReturnOrderTable.ContactId = (String) contactConsigneeInfoMap.get('ContactId');
            }

            consumableReturnOrderTable.ReturnOrderBankCode = bankCode;
            consumableReturnOrderTable.ReturnOrderBankAccountNo = bankAccountNo;
            consumableReturnOrderTable.ReturnOrderReceiverName = receiverName;
        }
        consumableReturnOrderTable.OriginOrderNumber = consumableReturnOrderTable.ConsumableReturnOrderLineItemTables[0].OrderNumber;
        consumableReturnOrderTable.OriginOrderId = consumableReturnOrderTable.ConsumableReturnOrderLineItemTables[0].ParentId;

        System.debug('start====================');
        System.debug('consumableReturnOrderTable');
        System.debug(JSON.serializePretty(consumableReturnOrderTable));
        System.debug('end====================');


        List<Map<String, Object>> pListMapRequestInfo = new List<Map<String, Object>>();
        Map<String, Object> mapRequestInfo = new Map<String, Object>();
        mapRequestInfo.put('consumableReturnOrderTable', consumableReturnOrderTable);
        pListMapRequestInfo.add(mapRequestInfo);

        String channelType;
        if (paramMap.containsKey('channelType')) {
            switch on (String) paramMap.get('channelType') {
                when '소모품택배' {
                    channelType = EX_ConsumableUtil.CONSUMABLE_CIC;
                }
                when 'LGE.COM' {
                    channelType = EX_ConsumableUtil.CONSUMABLE_OBS;
                }
                when 'ThinQ' {
                    channelType = EX_ConsumableUtil.CONSUMABLE_THINQ;
                }
                when '베스트샵' {
                    channelType = EX_ConsumableUtil.CONSUMABLE_BESTSHOP;
                }
                //2023.08.16 seung yoon heo Order_CHNL_TYPE_Code__c == 'Y'  >> 소모품샵  추가
                when '소모품샵' {
                    channelType = EX_ConsumableUtil.CONSUMABLE_CICSHOP;
                }
            }
        }

        returnMap = EX_ConsumableUtil.createReturnRequest(pListMapRequestInfo, channelType, 'Return');
        Set<String> msgIdSet;
        if (returnMap.containsKey('MsgIdSet')) {
            msgIdSet = (Set<String>) returnMap.get('MsgIdSet');
            List<ReturnOrderLineItem> roLineItems = [
                    SELECT ProductRequestLineItem.Order_Number__c, Product2.Name, Expected_Return_Quantity__c, Order_CUST_Id__r.MobilePhone, Order_CUST_Id__r.Name,

                            ProductRequestLineItem.PART_DESC_KOR__c, ProductRequestLineItem.BASIS_Parts__r.PART_DESC_KOR__c, ProductRequestLineItem.fm_ProductName__c, ProductRequestLineItem.BASIS_Parts__r.fm_PartDescription__c, ProductRequestLineItem.BASIS_Parts__r.ProductCode,
                            ProductRequestLineItem.fm_Consumables_PART_DESC_KOR__c
                    FROM ReturnOrderLineItem
                    WHERE Id IN :msgIdSet
                    AND Consumables_Order_Status__c = '100'
                    AND Order_CHNL_TYPE_Code__c = 'V'
            ];


            if (roLineItems.size() > 0) {
                List<EX_Message__c> msgList = new List<EX_Message__c>();
                List<String> exObjIdList = new List<String>();
                for (ReturnOrderLineItem roli : roLineItems) {
                    EX_Message__c msg = new EX_Message__c();
                    String productName = '';

                    productName = roli.ProductRequestLineItem.fm_Consumables_PART_DESC_KOR__c;
                    msg.Label1__c = roli.Order_CUST_Id__r.Name;
                    msg.Label2__c = roli.ProductRequestLineItem.Order_Number__c;
                    msg.Label3__c = productName;
                    msg.Label4__c = String.valueOf(roli.Expected_Return_Quantity__c);

                    msgList.add(msg);
                    exObjIdList.add(msg.Id);
                }
                insert msgList;
                System.debug('msgList');
                System.debug(msgList);
                for (EX_Message__c exMessage : msgList) {
                    exObjIdList.add(exMessage.Id);
                }
                returnMap.put('exObjIdList', exObjIdList);
            }
        }

        Map<Object, Object> caseInfoMap;
        String caseId;
        String appendRemark;
        if (paramMap.containsKey('caseInfo')) {
            caseInfoMap = (Map<Object, Object>) paramMap.get('caseInfo');
            if (caseInfoMap.containsKey('CaseId')) {
                caseId = (String) caseInfoMap.get('CaseId');
                appendRemark = '\n' + (String) paramMap.get('appendRemarkByReturnRequest');

            }
        }
        try {
            if (caseId != null && caseId != '') {
                Map<String, Object> mapResult = SC_CommonUtil.setCallCode(caseId, true, appendRemark, true);

                if (mapResult.get('stat') == 'SUCCESS') {
                    System.debug('Case Update Success');
                } else {
                    System.debug('Case Update Fail >> ' + mapResult.get('message'));
                    String errorMsg = (String) mapResult.get('message');
                    returnMap.put('caseUpdateFail', errorMsg.split(',')[1].replaceAll(':|\\[\\]', ''));
                }
            }

        } catch (Exception e) {
            System.debug(e.getLineNumber() + 'Line || ' + e.getMessage());
            throw new AuraHandledException(e.getLineNumber() + 'Line || ' + e.getMessage());
        }
        return returnMap;
    }

    /**
     * @description 소모품 변경 후 주문 상태 업데이트
     * @author 23.02.13 / I2MAX.SEUNGHUNAHN
     * @return
     *
     */
    @AuraEnabled
    public static String doUpdateOrderStatus(List<String> targetObjsId, String prLiList) {
        System.debug('targetObjsId : ' + targetObjsId);
        System.debug('prLiList : ' + prLiList);
        //23 09 20 hyungho.chun 체크한 prli만이아닌 해당과 같은pr부모를 가진 모든 prli의 주문상태 변경을위해 재쿼리후 받아서 넣어줌
        List<Object> lineItemList = (List<Object>) JSON.deserializeUntyped(prLiList);
        Map<String, Object> lineItemInfoMapTemp = null;
        lineItemInfoMapTemp = (Map<String, Object>) lineItemList[0];
        String orderNum = (String) lineItemInfoMapTemp.get('OrderNumber');
        List<ProductRequestLineItem> prLiListTemp = [SELECT Id FROM ProductRequestLineItem WHERE Order_Number__c =: orderNum 
                                                AND RecordType.DeveloperName IN ('Consumable', 'CareSupplies')
                                            ];
        List<Object> prliListMapList = new List<Object>();                                           
        for(ProductRequestLineItem item : prLiListTemp){
            Map<String,Object> lineItemListTemp = lineItemInfoMapTemp.clone();
            lineItemListTemp.put('Id', item.Id);
            prliListMapList.add(lineItemListTemp);
        }


        List<ProductRequestLineItem> updatePrLiList = new List<ProductRequestLineItem>();
        Set<String> updateOrderNumberSet = new Set<String>();
        Map<Object, String> orderStatusCodeMap = EX_ConsumableUtil.CONSUMABLE_STATUS_KOR_CODE_MAP;

        ProductRequestLineItem targetObj = null;
        Map<String, Object> lineItemInfoMap = null;
        String oldHistory = null, orderStatusChangeHistory = null;

        System.debug(lineItemList);
        System.debug(lineItemList.size());

        System.debug(prliListMapList);
        System.debug(prliListMapList.size());

        try {
            //23 09 20 hyungho.chun LineItemList - > prliListMapList
            //23 11 21 hyungho.chun 다시 pr주문단위아니고 화면에서 체크한 prli만 상품준비중으로 되돌리게 수정
            //23 11 21 hyungho.chun prliListMapList - > LineItemList
            for (Object obj : LineItemList) {
            // for (Object obj : prliListMapList) {                
                targetObj = new ProductRequestLineItem();
                lineItemInfoMap = (Map<String, Object>) obj;

                // for (String a : lineItemInfoMap.keySet()) {
                //     System.debug('key :::: ' + a + ' value :::: ' + lineItemInfoMap.get(a));
                // }

                // if (!targetObjsId.contains((String) lineItemInfoMap.get('Id'))) continue;
                updateOrderNumberSet.add((String) lineItemInfoMap.get('OrderNumber'));
                targetObj.Id = (String) lineItemInfoMap.get('Id');
                //targetObj.Consumables_Order_Status_Code__c = (String) lineItemInfoMap.get('UpdatedOrderStatus');
                // 23.08.07 확인 PHJ
                // targetObj.Consumables_Order_Status__c = (String) orderStatusCodeMap.get(lineItemInfoMap.get('UpdatedOrderStatus'));
                targetObj.Consumables_Order_Status__c = (String) orderStatusCodeMap.get('상품준비중');
                targetObj.HAND_WORK_REASON__c = (String) lineItemInfoMap.get('HandWorkReason');

                System.debug('?? 4>>> : ' + (String) orderStatusCodeMap.get(lineItemInfoMap.get('UpdatedOrderStatus')));
                
                System.debug('?? 5>>> : ' + targetObj.HAND_WORK_REASON__c);

                targetObj.HAND_WORK_YN__c = true;
                targetObj.HAND_WORK_DATE__c = System.now();
                targetObj.HAND_WORK_USER_ID__c = UserInfo.getName();

                // CJ 관련 필드 초기화
                targetObj.FFMT_Order_Number__c = null;
                targetObj.FFMT_Order_Transfer_YN__c = false;
                targetObj.FFMT_Transfer_DTM__c = null;
                targetObj.FFMT_Transfer_Request_DTM__c = null;

                // 배송 상태 초기화
                targetObj.DELIVERY_STATUS_CODE__c = null;

                // CJ 출고중지여부
                targetObj.CJ_SHIPPED_STOP_YN__c = true;

                // 변경 이력 Append null[배송준비중 -> 상품준비중] - [변경1]2023-02-19 17:30:19
                oldHistory = (String) lineItemInfoMap.get('OrderStatusChangeHistory');
                orderStatusChangeHistory = '[' + (String) lineItemInfoMap.get('OrderStatus')
                        + ' -> ' + (String) lineItemInfoMap.get('UpdatedOrderStatus')
                        + '] - [' + (String) lineItemInfoMap.get('HandWorkReason')
                        + '] - ['
                        + String.valueOf(System.now()) + ']';

                if (oldHistory == null) {
                    targetObj.Order_Status_Change_History__c = orderStatusChangeHistory;
                } else {
                    targetObj.Order_Status_Change_History__c = oldHistory + +'\n\n' + orderStatusChangeHistory;
                }
                updatePrLiList.add(targetObj);
            }

            // SR_DELIVERY_INFO 주문 정보 삭제
            //23 11 21 hyungho.chun 주문pr단위로 모든 delivery_info 삭제 -> prli단위로 삭제로 수정
            // List<SR_ONLINE_DELIVERY_INFO__c> deliveryInfoList = [SELECT Id, ORDER_NO__c FROM SR_ONLINE_DELIVERY_INFO__c WHERE ORDER_NO__c IN :updateOrderNumberSet];
            List<SR_ONLINE_DELIVERY_INFO__c> deliveryInfoList = [SELECT Id, ORDER_NO__c FROM SR_ONLINE_DELIVERY_INFO__c WHERE ProductRequestLineItem__c IN :targetObjsId ];
            delete deliveryInfoList;

            update updatePrLiList;
        } catch (Exception e) {
            return e.getMessage();
        }

        return 'SUCCESS';
    }

    public static Map<String, Object> assignRequestInfos(List<Map<String, String>> pListMapRequestInfos, String pCenterId) {
        Boolean isRequestOtherCenter = false;
        List<Map<String, String>> listMapMyCenterRequest = new List<Map<String, String>>();
        List<Map<String, String>> listMapOtherRequest = new List<Map<String, String>>();
        for (Map<String, String> mapRequestInfo : pListMapRequestInfos) {
            String releaseCenterId = mapRequestInfo.get('ParentLocationId');
            if (releaseCenterId != pCenterId) {
                isRequestOtherCenter = true;
                listMapOtherRequest.add(mapRequestInfo);
            } else {
                listMapMyCenterRequest.add(mapRequestInfo);
            }
        }

        Decimal decMyCenterTotalAmount = 0;
        if (!listMapMyCenterRequest.isEmpty()) {
            for (Map<String, String> mapRequestInfo : listMapMyCenterRequest) {
                decMyCenterTotalAmount += Decimal.valueOf(mapRequestInfo.get('subTotal'));
            }
        }

        Decimal decOtherCenterTotalAmount = 0;
        if (!listMapOtherRequest.isEmpty()) {
            for (Map<String, String> mapRequestInfo : listMapOtherRequest) {
                decOtherCenterTotalAmount += Decimal.valueOf(mapRequestInfo.get('subTotal'));
            }
        }

        return new Map<String, Object>{
                'isRequestOtherCenter' => isRequestOtherCenter,
                'listMapMyCenterRequest' => listMapMyCenterRequest,
                'myCenterTotalAmount' => decMyCenterTotalAmount,
                'listMapOtherRequest' => listMapOtherRequest,
                'otherCenterTotalAmount' => decOtherCenterTotalAmount
        };
    }
    /**
    * @description 판매저장
    * @author 23.03.01 / I2MAX.SEUNGHUNAHN
    * @param List<String> orderNumberList
    */
    @AuraEnabled
    public static Map<String, Object> doSaveSales(List<String> orderNumberList) {

        Map<String, Object> rtnMap = new Map<String, Object>();
        //23 10 01 hyungho.chun
        // List<SR_PRE_PAYMENT_HEADER__c> paymentHeaderList = null;

        // // 판매저장대상 건이면서, 실패하지 않은 주문번호
        // paymentHeaderList = [
        //         SELECT Id, ATTR_RECORD_ID__c
        //         FROM SR_PRE_PAYMENT_HEADER__c
        //         WHERE BASIS_NO__c IN:orderNumberList 
        // ];
        // List<ProductRequest> prListTemp = [SELECT Id,Consumables_Business_Type_Code__c FROM ProductRequest WHERE Order_Number__c IN: orderNumberList];
        // Boolean isExchange = false;
        // for(ProductRequest item : prListTemp){
        //     if(item.Consumables_Business_Type_Code__c == 'ExchangeOrder'){
        //         isExchange = true;
        //     }
        // }
        // if((paymentHeaderList.size() != prListTemp.size()) && !isExchange){
        //     System.debug('주문번호에 맞는 SR_PRE_PAYMENT_HEADER__c 가 없음');
        //     rtnMap.put('errorReason','HeaderMissing');
        //     rtnMap.put('errorMessage','주문 결제 이력이 없습니다. 관리자에게 문의하세요.');
        //     return rtnMap;
        //     // throw new FNException('주문 결제 이력이 없습니다. 관리자에게 문의하세요.');
        // }

        Map<String, Object> paramMap = EX_ConsumableUtil.preWorkSaveSales(orderNumberList);
        List<ProductRequest> prList = (List<ProductRequest>)paramMap.get('prList');
        System.debug('doSaveSales :: ' + prList);
        rtnMap = EX_ConsumableUtil.doSaveSales2(paramMap, prList);

        return rtnMap;
    }

    @AuraEnabled
    public static Map<String, Object> doSaveTmpExMessageObj(String jsonString, String resendType) {
        return EX_ConsumablesOrderManagementController.doSaveTmpExMessageObj(jsonString, resendType);
    }

    /**
        * @description 소모품 알림(알림톡, SMS) 재전송
        *
        * @author 23.02.02 / I2MAX.SEUNGHUNAHN
        * @return Map<String, Object>
        */
    @AuraEnabled
    public static Map<String, Object> doResendKakao(String exObjId, String resendType, String jsonString, String receiverNumber) {
        System.debug(exObjId);
        System.debug(resendType);
        System.debug(jsonString);
        System.debug(receiverNumber);
        return EX_ConsumablesOrderManagementController.doResend(exObjId, resendType, jsonString, receiverNumber);
    }

    @AuraEnabled
    public static List<Map<String, String>>getDeliveryNumWithId(String Id) {
        List<Map<String, String>> dMap_list = new List<Map<String, String>>();
        dMap_list = EX_ConsumablesOrderManagementController.getProliDeliveryNoListwithId(Id);
        return dMap_List;
    }
    @AuraEnabled
    public static Map<String, Object> doResendReturnRequest(List<String> exObjIdList, String resendType, String jsonString, String receiverNumber) {
        return EX_ConsumablesOrderManagementController.doResendReturnRequest(exObjIdList, resendType, jsonString, receiverNumber);
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

    // ProductRequestLineItem의 송장번호를 가져오기 위해 SR_DELIVERY_INFO__c 조회
    public static Map<String, List<String>> getDeliveryNoMap(List<String> prliIdList) {
        Map<String, List<String>> dMap_list = new Map<String, List<String>>();
        List<SR_ONLINE_DELIVERY_INFO__c> srODIList = new List<SR_ONLINE_DELIVERY_INFO__c>();
        if (prliIdList != null && !prliIdList.isEmpty()) {
            srODIList = [
                    SELECT Id, ProductRequestLineItem__c, ReturnOrderLineItem__c, DELIVERY_NO__c
                    FROM SR_ONLINE_DELIVERY_INFO__c
                    WHERE ProductRequestLineItem__c IN :prliIdList
            ];
            if (!srODIList.isEmpty()) {
                for (SR_ONLINE_DELIVERY_INFO__c dInfo : srODIList) {

                    if (dMap_list.containsKey(dInfo.ProductRequestLineItem__c)) {
                        Integer cnt = Integer.valueOf(dMap_list.get(dInfo.ProductRequestLineItem__c)[1]);
                        dMap_list.put(dInfo.ProductRequestLineItem__c, new List<String>{dInfo.DELIVERY_NO__c , String.valueOf(cnt + 1)}  );
                    } else {
                        Integer cnt = 0;
                        dMap_list.put(dInfo.ProductRequestLineItem__c, new List<String>{dInfo.DELIVERY_NO__c , String.valueOf(cnt) });
                    }

                    // dMap_list.put(dInfo.ProductRequestLineItem__c, dInfo.DELIVERY_NO__c);
                }
                  
            }
        } 

        return dMap_list;
    }


    public class IntegrationOrderLineItemTable implements Comparable {
        @AuraEnabled public String Id;
        @AuraEnabled public String ParentId;
        @AuraEnabled public String OrderChannel;
        @AuraEnabled public String OrderNumber;
        @AuraEnabled public Decimal OrderSeq;

        // 23.02.13 추가
        @AuraEnabled public Decimal OrderQuerySeq;

        @AuraEnabled public String SubNumber;
        @AuraEnabled public Datetime OrderDate;
        @AuraEnabled public Datetime PaymentDate;

        @AuraEnabled public String CustomerName;
        @AuraEnabled public String CustomerPhone;

        // 23.07.07 비식별 고객명, 전화번호 추가
        @AuraEnabled public String CustomerNameEnc;
        @AuraEnabled public String CustomerPhoneEnc;

        @AuraEnabled public String CONSIGNEE_Name;
        @AuraEnabled public String CONSIGNEE_Phone;

        @AuraEnabled public String OrderStatus;
        @AuraEnabled public String OrderStatusDetail;

        @AuraEnabled public String AppointmentStatus;
        @AuraEnabled public String SalesNumber;
        @AuraEnabled public Datetime SalesDate;
        @AuraEnabled public Decimal SalesSeq;


        @AuraEnabled public String CJOrderSendYN;
        @AuraEnabled public String CJOrderNumber;

        @AuraEnabled public Datetime ShipmentDate;
        @AuraEnabled public Datetime DeliveryDate;

        @AuraEnabled public Decimal RequestedQuantity;
        @AuraEnabled public Decimal SalesQuantity;
        @AuraEnabled public Decimal CancelQuantity;
        @AuraEnabled public Decimal ReturnQuantity;
        @AuraEnabled public Decimal ExchangeQuantity;
        @AuraEnabled public Decimal QuantityRequested;

        @AuraEnabled public String DeliveryCompany;
        @AuraEnabled public String TrackingNumber;
        @AuraEnabled public String RequestedPartNo;
        @AuraEnabled public String ReceivedPartNo;
        @AuraEnabled public String DIV;

        @AuraEnabled public String PartName;
        @AuraEnabled public Decimal CustomerPrice;

        @AuraEnabled public Decimal SaleAmount;
        @AuraEnabled public Decimal DiscountAmount;
        @AuraEnabled public Decimal PaymentAmount;
        @AuraEnabled public String DiscountType;

        @AuraEnabled public Decimal CashAmount;
        @AuraEnabled public Decimal CardAmount;
        @AuraEnabled public Decimal PointAmount;

        @AuraEnabled public Decimal DeliveryFee;
        @AuraEnabled public String ModelCode;
        @AuraEnabled public String ConsumablesBusinessTypeCode;

        @AuraEnabled public Datetime RequestedDate;
        @AuraEnabled public String RequestedUser;
        @AuraEnabled public String RequestedDept;

        // 결제방법코드
        @AuraEnabled public String PaymentMethodCode;
        @AuraEnabled public String PaymentMethod;

        // 23.01.27 원주문 번호 필드
        @AuraEnabled public String BasisOrderNumber;
        @AuraEnabled public String UpdatedOrderStatus;

        // 23.02.13 수작업 관련 필드
        // 수작업여부
        @AuraEnabled public String HandWorkYN;
        // 수작업일시
        @AuraEnabled public DateTime HandWorkDate;
        // 수작업처리자
        @AuraEnabled public String HandWorkUser;
        // 수작업사유
        @AuraEnabled public String HandWorkReason;

        // 23.02.13 통합주문관리 컬럼 추가 필드
        // 대치
        @AuraEnabled public String SubstituteYN;
        // 부분 입고
        @AuraEnabled public String PartiallyReceived;
        // 약속 상태 AppointmentStatus 존재
        // 한글 품명
        @AuraEnabled public String PartNameKOR;
        // 품명 ShippedDepartment 존재
        // 모델
        @AuraEnabled public String Model;
        // 출고 부서
        @AuraEnabled public String ShippedDepartment;
        // 소비자가 CustomerPrice 존재
        // 할인유형 DiscountType 존재
        // 취소수량 CancelQuantity 존재
        // 반품수량 ReturnQuantity 존재
        // 교환수량 ExchangeQuantity 존재
        // CJ 주문전송여부 CJOrderSendYN 존재
        // CJ 주문 전송일시
        @AuraEnabled public Datetime CJOrderSendDate;
        // 배송상태
        @AuraEnabled public String DeliveryStatus;
        // 출하일시 ShipmentDate 존재
        // 배송일시 DeliveryDate 존재
        // 택배사 DeliveryCompany 존재
        // 택배비 DeliveryFee 존재

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
        // 원 회수 부품
        @AuraEnabled public String BASIS_COLLECT_Parts;

        // 반품 승인자, 반품승인사유, 부품상태 제거
        // 반품 Section End

        // 교환 Section Start
        // 교환정보, 교환대상 제거
        // 교환요청부서
        @AuraEnabled public String ExchangeRequesterDepartment;
        // 교환요청자
        @AuraEnabled public String ExchangeRequester;
        // 교환요청자사번 23.10.19 PHJ
        @AuraEnabled public String ExchangeRequesterEmployeeNumber;
        // 교환요청일시
        @AuraEnabled public Datetime ExchangeRequestedDate;
        // 교환 Section End

        // 상담 Case 번호
        @AuraEnabled public String CaseNumber;
        @AuraEnabled public String CaseURL;

        // 23.02.19 추가
        @AuraEnabled public String OrderStatusChangeHistory;

        // 취소금액
        @AuraEnabled public Decimal CancelAmount;
        @AuraEnabled public Decimal EstimatedPaymentAmount;

        // 주문리스트
        @AuraEnabled public String CenterLocatedPlace;
        @AuraEnabled public String LocatedPlace;
        @AuraEnabled public Datetime CJSendDate;
        @AuraEnabled public String RequestAmount;
        @AuraEnabled public String ReceivedAmount;
        @AuraEnabled public String CONSIGNEE_Address;
        @AuraEnabled public String CONSIGNEE_Address_Detail;

        @AuraEnabled public Boolean CJOrderYN;
        @AuraEnabled public String CONSIGNEE_PostalCode;
        @AuraEnabled public String CONSIGNEEYN;
        @AuraEnabled public String CONSIGNEE_CHANGE_YN;

        // 반품요청에서 사용하기 위한 Attribute
        // 23.02.08

        // 기존 반품건 진행 여부
        @AuraEnabled public Boolean ReturnProgressYN;
        // 반품 요청 수량
        @AuraEnabled public Decimal RequestedReturnQuantity;
        // 반품 예정 수량
        @AuraEnabled public Decimal ExpectedReturnQuantity;

        // 반품 요청 금액
        @AuraEnabled public Decimal RequestedReturnAmount;
        // 반품 사유 (ReturnRequestReason)
        // 반품 수거 여부
        @AuraEnabled public Boolean Collection_YN;
        // 원 주문 ID
        @AuraEnabled public String BasisOrderId;
        // 원 주문 행 항번
        @AuraEnabled public String OriginConsumableOrderItemSeq;
        // 원 주문 행 Id
        @AuraEnabled public String OriginConsumableOrderItemId;

        // 반품 채널
        @AuraEnabled public String ReturnChannel;
        // 원 주문 고객/결제자 Id
        @AuraEnabled public String ContactId;

        // 환불 요청 여부
        @AuraEnabled public Boolean IsRequestRefund;

        // 환불 은행 코드
        @AuraEnabled public String RefundBankCode;
        // 환불 가상 계좌
        @AuraEnabled public String RefundBankAccount;
        // 환불 예금주 명
        @AuraEnabled public String RefundBankAccountName;

        // Old / New Check
        @AuraEnabled public String oldNewCheck;
        // 임시 External Key
        @AuraEnabled public String TempExternalKey;

        // 송장 번호
        @AuraEnabled public String InvoiceNumber;

        //반품 확정 여부
        @AuraEnabled public String Confirm_YN;

        //출고 일자
        @AuraEnabled public Datetime ReleaseDate;


        // 판매 저장 attribute
        @AuraEnabled public Decimal ASCPrice;
        @AuraEnabled public String Product2Id;
        @AuraEnabled public String LocationId;
        @AuraEnabled public String ParentLocationId;
        @AuraEnabled public String ParentLocation;
        @AuraEnabled public String SR_RSRV_PART_Id;
        @AuraEnabled public String RSRV_Number;


        // Table Cell Color
        @AuraEnabled public String DeliveryColor;
        @AuraEnabled public String CancelColor;
        @AuraEnabled public String ReturnColor;
        @AuraEnabled public String ExchangeColor;

        // 판매저장 오류 관련 셀 필드
        @AuraEnabled public String SalesError;

        // Mig 여부
        @AuraEnabled public Boolean IsMig;

        // 23.04.07 OBS 반품 주문번호
        @AuraEnabled public String OBSReturnOrderNumber;
        // 23.04.07 OBS 반품 주문항번
        @AuraEnabled public Integer OBSReturnOrderSeq;

        // 23.05.02 반품 환불 은행 코드
        @AuraEnabled public String ReturnOrderBankCode;
        // 23.05.02 반품 환불 은행 이름
        @AuraEnabled public Integer ReturnOrderBankAccountNo;
        // 23.05.02 반품 환불 검증 이름
        @AuraEnabled public Integer ReturnOrderReceiverName;

        // 23.05.03 / 반품 환불 관련 금액 필드 추가
        @AuraEnabled public Decimal ReturnSaleAmount; // 반품판매금액
        @AuraEnabled public Decimal ReturnPaymentAmount; // 반품결제금액
        @AuraEnabled public Decimal ReturnDiscountAmount; // 반품할인금액

        @AuraEnabled public Decimal ReturnCardPaymentAmount; // 반품카드결제금액
        @AuraEnabled public Decimal ReturnVBankPaymentAmount; // 반품가상계좌결제금액
        @AuraEnabled public Decimal ReturnPointAmount; // 반품포인트금액

        @AuraEnabled public Decimal ConsumerPrice; // 소비자가
        // 주문내역(True), 관련 주문내역(False) 체크
        // Custom Comparator에 사용
        @AuraEnabled public Boolean CheckFlag;

        /**
        * @description SubOrderNumber를 정렬하기 위한 Custom Comparator
        * @author 23.01.27 / I2MAX.SEUNGHUNAN
        * @return Integer
        */
        // public Integer compareTo(Object compareTo) {
        //     Integer res = 0;
        //     Decimal tmpOrderQuerySeq = 0;
        //     IntegrationOrderLineItemTable cmp = (IntegrationOrderLineItemTable) compareTo;

        //     if (this.CheckFlag != null && this.CheckFlag) {
        //         return this.OrderDate >= cmp.OrderDate ? -1 : 1;
        //     }

        //     if ((this.SubNumber == null || cmp.SubNumber == null) ||
        //             ((!this.SubNumber.contains('-') || !cmp.SubNumber.contains('-')))) return res;

        //     String[] baseSubOrderNumbers = this.SubNumber.replace('ㄴ', '').split('-');
        //     String[] cmpSubOrderNumbers = cmp.SubNumber.replace('ㄴ', '').split('-');

        //     for (Integer i = 0; i < baseSubOrderNumbers.size(); i++) {
        //         res = baseSubOrderNumbers[i].compareTo(cmpSubOrderNumbers[i]);
        //         if (res > 0) {
        //             tmpOrderQuerySeq = this.OrderQuerySeq;
        //             this.OrderQuerySeq = cmp.OrderQuerySeq;
        //             cmp.OrderQuerySeq = tmpOrderQuerySeq;
        //             return res;
        //         }
        //     }
        //     return res;
        // }
        public Integer compareTo(Object compareTo) {
            Integer res = 0;
            IntegrationOrderLineItemTable cmp = (IntegrationOrderLineItemTable) compareTo;

            if (this.CheckFlag != null && this.CheckFlag) {
                return this.OrderDate >= cmp.OrderDate ? -1 : 1;
            }
            
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
}