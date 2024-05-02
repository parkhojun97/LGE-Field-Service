/**
 * Created by I2MAX.SEOKHOLEE on 2023-03-13.
 */
@RestResource(UrlMapping='/v1/api/ma/obs/IF_MACN_OBS_SFDC_0010')

global without sharing class IF_MACN_OBS_SFDC_0010 {

    // =============================================================
    // 인터페이스 Id 값 설정 (SFDC에 ifId를 저장하여 사용)
    // =============================================================
    private static final String IFID    = 'IF-NEW-500';
    private static final String SUCCESS = 'SUCCESS';
    private static final String ERROR   = 'ERROR';

    @HttpPost
    global static void doPost() {

        RestRequest request = RestContext.request;
        String requestBody = request.requestBody.toString();
        String requestHeader = request.headers.toString();

        // 로그 시작 (IF_Master에 등록되어 있으며, 로그 적재 여부가 true일 경우에만 쌓임)
        IFUtil ifUtil               = new IFUtil(IFID);
        IFUtil.LogWrapper log       = new IFUtil.LogWrapper(IFID, requestHeader, requestBody);


        RestResponse response = RestContext.response;
        OutputHeader header = new OutputHeader();
        OutputBody body = new OutputBody();
        body.data = new List<IF_MACN_OBS_SFDC_0010.Data>();

        Boolean isSuccessFlag = true;
        Input objInput = new Input();
        Output objOutput = new Output();


        Savepoint sp = Database.setSavepoint();
        try {

            System.debug('============================================');
            System.debug('======= LGE.COM 주문 요청 I/F =======');
            System.debug('IF_MACN_OBS_SFDC_0010');
            System.debug('requestBody -> ' + requestBody);
            System.debug('requestHeader -> ' + requestHeader);
            System.debug('============================================');


            if (requestBody != null && requestBody != '') {
                
                objInput = (Input) JSON.deserialize(requestBody, Input.class);

                List<Map<String, Object>> additionalMapList = new List<Map<String, Object>>();
                objOutput = createConsumableOrderFromOBS(objInput, EX_ConsumableUtil.CONSUMABLE_OBS, additionalMapList);
                for (Data data : objOutput.Body.data) {
                    if (data.resultCode != 'Success') {
                        isSuccessFlag = false;
                    }
                }
            }

        } catch (JSONException je) {
            Database.rollback(sp);
            isSuccessFlag = false;
            header.code = '500';
            header.message = ' 조회된 값이 없습니다.  ' + je.getMessage() + ', LineNumber:' + je.getLineNumber();
            System.debug(je.getMessage() + ', LineNumber:' + je.getLineNumber());
            objOutput.Header = header;
        } catch (NullPointerException ne) {
            Database.rollback(sp);

            isSuccessFlag = false;
            header.code = '500';
            header.message = ' 조회된 값이 없습니다.  ' + ne.getMessage() + ', LineNumber:' + ne.getLineNumber();
            System.debug(ne.getMessage() + ', LineNumber:' + ne.getLineNumber());
            objOutput.Header = header;
        } catch (Exception e) {
            Database.rollback(sp);

            isSuccessFlag = false;
            header.code = '500';
            header.message = e.getMessage();
            System.debug(e.getMessage() + ', LineNumber:' + e.getLineNumber());
            objOutput.Header = header;
        }

        if (isSuccessFlag) {
            header.code = '200';
            header.message = '정상적으로 조회되었습니다.';
            objOutput.Header = header;
        } else {
            Database.rollback(sp);
        }

        response.addHeader('Content-Type', 'application/json');
        System.debug(JSON.serialize(objOutput));
        response.responseBody = Blob.valueOf(JSON.serialize(objOutput));

        // =============================================================
        // RESPONSE
        // =============================================================

        log.responseTime            = System.now();
        log.responseBody            = JSON.serialize(objOutput);
        log.status                  = objOutput.header.code == '200' ? SUCCESS : ERROR;
        log.errorMessage            = objOutput.header.message;
        ifUtil.insertLog(log);
    }


    /**
     * @description OBS 로부터 인입된 주문 데이터 Insert
     */
    public static Output createConsumableOrderFromOBS(Input objInput, String chnl, List<Map<String, Object>> additionalMapList) {

        //2023.10.13 seung yoon heo 전화번호 val 추가
        CM_CommonUtil cmUtil = new CM_CommonUtil();

        Output output = new Output();


        output.Body = new IF_MACN_OBS_SFDC_0010.OutputBody();

        List<OrderInfo> objOrderInfo = objInput.orderInfo;
        List<IF_MACN_OBS_SFDC_0010.OrderItem> objOrderItem = objInput.orderItem;

        // info Map
        Map<String, Map<String, Object>> infoMap = new Map<String, Map<String, Object>>();
        // Order Number Map
        Map<String, OrderInfo> orderInfoMap = new Map<String, IF_MACN_OBS_SFDC_0010.OrderInfo>();
        // 2023.08.12 seung yoon heo 할인 유형 추가
        Map<String, String> disTypeMap = new Map<String, String>();
        for (OrderInfo orderInfo : objOrderInfo) {
            orderInfoMap.put(orderInfo.orderNo, orderInfo);

            // 2023.08.12 seung yoon heo 할인 유형 추가
            if(orderInfo.isMember != null) { 
                disTypeMap.put(orderInfo.isMember, 'L');
            }
            if(orderInfo.isEmployee != null) { 
                disTypeMap.put(orderInfo.isEmployee, 'E');
            }
        }
        // Order Number - Item Map
        Map<String, List<IF_MACN_OBS_SFDC_0010.OrderItem>> orderItemMap = new Map<String, List<IF_MACN_OBS_SFDC_0010.OrderItem>>();
        // 대상 Item 의 사업부 코드 Set
        Set<String> divCodeSet = new Set<String>();
        // 대상 Item 의 Product Code Set
        Set<String> productCodeSet = new Set<String>();

        List<Data> dataList = new List<IF_MACN_OBS_SFDC_0010.Data>();

        // 결제 방식
        String depositType = '';
        // 증빙 유형
        String invoiceIssueType = '';
        



        for (IF_MACN_OBS_SFDC_0010.OrderItem orderItem : objOrderItem) {
            if (orderItemMap.containsKey(orderItem.orderNo)) {
                orderItemMap.get(orderItem.orderNo).add(orderItem);
            } else {
                orderItemMap.put(orderItem.orderNo, new List<IF_MACN_OBS_SFDC_0010.OrderItem>{
                        orderItem
                });
            }
            divCodeSet.add(orderItem.divCode);
            productCodeSet.add(orderItem.partNo);

            Data data = new Data();
            data.resultCode = '';
            data.orderNo = orderItem.orderNo;
            data.orderSeq = String.valueOf(orderItem.orderSeq);
            dataList.add(data);

            if (orderItem.depositType != null && orderItem.depositType != '') {
                depositType = orderItem.depositType;
            }
            if (orderItem.invoiceissueType != null && orderItem.invoiceissueType != '') {
                invoiceIssueType = orderItem.invoiceissueType;
            }

            // 2023.08.12 seung yoon heo 할인 유형 추가 08.16일 쿠폰의 경우 보류로 전환
            
            // if(orderItem.useCoupon != null && disTypeMap.get('Y') != 'E') { 
            //     disTypeMap.put(orderItem.useCoupon, 'D');
            // }
          
        }

 

        output.Body.data = dataList;
        output.header = new OutputHeader();

        List<ProductRequest> existConsumableOrders = [
                SELECT Order_Number__c
                FROM ProductRequest
                WHERE Order_Number__c IN :orderInfoMap.keySet()
        ];

        for (ProductRequest pr : existConsumableOrders) {
            output.header.code = '500';
            output.header.message = '존재 하는 주문번호 입니다 : ' + pr.Order_Number__c ;
            return output;
        }

        // 부품마스터 조회
        // todo : 부품마스터에 해당 부품이 없을시 Error 리턴
        List<Product2> product2s = [
                SELECT Id, DIV_CODE__c, ProductCode, Name, CUST_PRICE__c, ASC_PRICE__c
                FROM Product2
                WHERE DIV_CODE__c IN :divCodeSet AND Name IN :productCodeSet
        ];

        System.debug('product2s List : ' + product2s);

        Map<String, Product2> productIdMap = new Map<String, Product2>();
        // Key : '사업부코드' + '_' + 'ProductCode'
        Map<String, Product2> partMasterMap = new Map<String, Product2>();
        for (Product2 prod : product2s) {
            if (prod.DIV_CODE__c != null && prod.Name != null) {
                String custExternalKey = prod.DIV_CODE__c + '_' + prod.Name;
                partMasterMap.put(custExternalKey, prod);
                productIdMap.put(prod.Id, prod);
            }
        }

        System.debug('objOrderItem : ' + objOrderItem);
        for (IF_MACN_OBS_SFDC_0010.OrderItem orderItem : objOrderItem) {
            String custExternalKey = orderItem.divCode + '_' + orderItem.partNo;

            if (!partMasterMap.containsKey(custExternalKey)) {
                output.header.code = '500';
                output.header.message = orderItem.divCode + ' / ' + orderItem.partNo + ' 해당 부품이 존재하지 않습니다.';
                return output;
            }
        }

        Map<String, Schema.Location> locationMap = new Map<String, Schema.Location>();
        for (Schema.Location lo : [SELECT Id, DIV_CODE__c FROM Location WHERE RecordType.DeveloperName = 'DIV']) {
            locationMap.put(lo.DIV_CODE__c, lo);
        }
        String consumableWarehouseId = EX_ConsumableUtil.getConsumableWareHouseId();

        Map<String, IF_MACN_OBS_SFDC_0010.OrderItem> exKeyMap = new Map<String, IF_MACN_OBS_SFDC_0010.OrderItem>();

        for (IF_MACN_OBS_SFDC_0010.OrderItem orderItem : objOrderItem) {
            String custExternalKey = orderItem.divCode + '_' + orderItem.partNo + '_' + consumableWarehouseId;
            exKeyMap.put(custExternalKey, orderItem);

            if(locationMap.containsKey(orderItem.divCode)) {
                custExternalKey = orderItem.divCode + '_' + orderItem.partNo + '_' + locationMap.get(orderItem.divCode).Id;
                exKeyMap.put(custExternalKey, orderItem);
            }

        }
        // 소모품 재고가 없는 경우 소모품 적치장소 재고 및 사업부 재고 레코드 생성
        EX_ConsumableUtil.createNotExistProductItem(productIdMap.keySet());

        // item 의 소모품 센터 가용 수량
        Map<String, ProductItem> itemAvailableQtyMap = new Map<String, ProductItem>();
        // item 의 사업부 가용 수량
        Map<String, ProductItem> itemAvailableDIVQtyMap = new Map<String, ProductItem>();

        Map<String, ProductItem> afterProductItemMap = new Map<String, ProductItem>([
                SELECT Id, QuantityOnHand, fm_Available_Quantity__c, fm_Computerized_Quantity__c, RESRV_QTY__c, ORDER_QTY__c,
                        LocationId, Location.DEPT_CODE__c, Location.LocationType, Location.DIV_CODE__c,
                        ProductName, DIV_CODE__c, Product2Id, Product2.Name, Product2.ProductCode, Product2.DIV_CODE__c, Product2.DISABLED_TYPE__c,
                        Location.RecordType.DeveloperName
                FROM ProductItem
                WHERE Product2.Name IN :productCodeSet
                AND ((Location.DEPT_CODE__c = :EX_ConsumableUtil.PH8002 AND Location.LocationType = 'Warehouse' AND Location.Name = :System.Label.EX_Location)
                OR (Location.RecordType.DeveloperName = 'DIV' AND Location.DIV_CODE__c IN :divCodeSet))
        ]);

        for (ProductItem pi : afterProductItemMap.values()) {

            if (pi.Location.DEPT_CODE__c == EX_ConsumableUtil.PH8002 && pi.Location.LocationType == 'Warehouse') {
                String externalKey = EX_ConsumableUtil.PH8002 + '_' + pi.Product2.DIV_CODE__c + '_' + pi.Product2.Name;
                itemAvailableQtyMap.put(externalKey, pi);
            } else if (pi.Location.RecordType.DeveloperName == 'DIV') {
                String externalKey = pi.Product2.DIV_CODE__c + '_' + pi.Product2.Name;
                itemAvailableDIVQtyMap.put(externalKey, pi);
            }
        }

        System.debug('itemAvailableDIVQtyMap =>' + itemAvailableDIVQtyMap);
        infoMap.put('partMasterMap', partMasterMap);
        infoMap.put('partMasterIdMap', productIdMap);
        infoMap.put('itemAvailableQtyMap', itemAvailableQtyMap);
        infoMap.put('itemAvailableDIVQtyMap', itemAvailableDIVQtyMap);


        // OBS 는 품절주문 X, 소모품센터 또는 사업부에서 출고
        // 사업부에서 출고 시 예약 생성
        Map<String, ProductRequest> productRequestMap = new Map<String, ProductRequest>();
        ProductRequest consumableOrder;
        OrderInfo orderInfo;
        // 소모품센터 SM_DEPT
        SM_DEPT__c consumableCenterDept = [
                SELECT Id, Name, DEPT_CODE__c
                FROM SM_DEPT__c
                WHERE DEPT_CODE__c = 'PH8002'
                LIMIT 1
        ];

        // 주문번호 별 판매, 결제금액 Map
        Map<String, Map<String, Decimal>> orderNumberAmountMap = new Map<String, Map<String, Decimal>>();
        Map<String, Decimal> amountMap;
        for (String orderNumber : orderInfoMap.keySet()) {
            amountMap = new Map<String, Decimal>();
            amountMap.put('orderAmt', 0);
            amountMap.put('totApprAmt', 0);
            amountMap.put('totPointAmt', 0);

            Decimal saleAmount = 0;
            Decimal paymentAmount = 0;
            Decimal discountAmount = 0;

            for (IF_MACN_OBS_SFDC_0010.OrderItem orderItem  : orderItemMap.get(orderNumber)) {
                saleAmount += Decimal.valueOf(orderItem.orderQty * orderItem.orderPrice);
                paymentAmount += Decimal.valueOf(orderItem.orderQty *  orderItem.priceCost);
                discountAmount += Decimal.valueOf(orderItem.orderQty * orderItem.orderPrice) - Decimal.valueOf(orderItem.orderQty * orderItem.priceCost);
            }
            amountMap.put('saleAmount', saleAmount);
            amountMap.put('paymentAmount', paymentAmount);
            amountMap.put('discountAmount', discountAmount);
            orderNumberAmountMap.put(orderNumber, amountMap);
        }

        System.debug('orderNumberAmountMap');
        System.debug(orderNumberAmountMap);


        for (String orderNumber : orderInfoMap.keySet()) {
            orderInfo = orderInfoMap.get(orderNumber);

            // 소모품 주문 생성
            consumableOrder = new ProductRequest();
            consumableOrder.Consumables_Order_YN__c = true;
            consumableOrder.Consumables_Order_USE_YN__c = true;

            consumableOrder.RecordTypeId = EX_ConsumableUtil.PR_CONSUMABLE_RECORDTYPE_ID;
            // 주문 번호
            consumableOrder.Order_Number__c = orderNumber;
            // 일반
            consumableOrder.Consumables_Order_Class_Code__c = 'General';
            // 주문
            consumableOrder.Consumables_Business_Type_Code__c = 'Order';
            // LGE.COM
            consumableOrder.Order_CHNL_TYPE_Code__c = chnl;

            // 23.05.18 추가
            // ally_chnl_id=thinq_parts
            if(orderInfo.allyChnlId != null && orderInfo.allyChnlId.equalsIgnoreCase('thinq_parts')){
                consumableOrder.ThinQ_OBS_Order_Flag__c = 'T';
            }
            //ThinQ처리
            String cashTy = ''; //카드결제유형(1:데이콤카드,2:데이콤이체,3:데이콤무통장)
            if(chnl.equals(EX_ConsumableUtil.CONSUMABLE_THINQ)){
                if(!additionalMapList.isEmpty()){
                    for(Map<String, Object> additionalMap : additionalMapList){
                        if(additionalMap.get('orderNo') != null && additionalMap.get('orderNo').equals(orderNumber)){
                            if(additionalMap.get('orderTime') != null){
                                String orderTimeStr = String.valueOf(additionalMap.get('orderTime'));
                                consumableOrder.Order_Date__c = Datetime.valueOf(orderTimeStr);
                                consumableOrder.PAYMENT_REQUEST_DATE__c = Datetime.valueOf(orderTimeStr);
                                consumableOrder.PAYMENT_COMPLETED_DTM__c = Datetime.valueOf(orderTimeStr);
                            }
                            if(additionalMap.get('cashTy') != null){
                                cashTy = String.valueOf(additionalMap.get('cashTy'));
                            }
                        }
                    }
                }
            }else{
                consumableOrder.Order_Date__c = System.now();
                consumableOrder.PAYMENT_REQUEST_DATE__c = System.now();
                consumableOrder.PAYMENT_COMPLETED_DTM__c = System.now();
            }

            // 주문 고객 이름
            consumableOrder.Order_CUST_Name__c = orderInfo?.orderCustName;
            // 주문 고객 전화 번호1
            // consumableOrder.Order_CUST_TPNO_1__c = DN_CommonUtil.setTelnumFormat(orderInfo?.orderTelNo1);
            //2023.10.13 seung yoon heo contact 공통모듈 호출
            if (orderInfo.orderTelNo1 != null && orderInfo.orderTelNo1 != '') {
            String checkTelNoValidMessage = cmUtil.checkValidTelNo(orderInfo.orderTelNo1);
            if(!String.isEmpty(checkTelNoValidMessage)) {
                // 전화번호가 유호 하지 않는 경우 처리 케이스.
                output.header.code = '500';
                output.header.message = checkTelNoValidMessage + ' : ' + orderInfo.orderTelNo1;
                return output;
            }
                consumableOrder.Order_CUST_TPNO_1__c = DN_CommonUtil.setTelnumFormat(orderInfo.orderTelNo1);
            }
            // 주문 고객 전화 번호2
            // consumableOrder.Order_CUST_TPNO_2__c = DN_CommonUtil.setTelnumFormat(orderInfo?.orderTelNo2);
            //2023.10.13 seung yoon heo contact 공통모듈 호출
            if (orderInfo.orderTelNo2 != null && orderInfo.orderTelNo2 != '') {
            String checkTelNoValidMessage = cmUtil.checkValidTelNo(orderInfo.orderTelNo2);
            if(!String.isEmpty(checkTelNoValidMessage)) {
                // 전화번호가 유호 하지 않는 경우 처리 케이스.
                output.header.code = '500';
                output.header.message = checkTelNoValidMessage + ' : ' + orderInfo.orderTelNo2;
                return output;
            }
                consumableOrder.Order_CUST_TPNO_2__c = DN_CommonUtil.setTelnumFormat(orderInfo.orderTelNo2);
            }
            // 주문 고객 주소
            consumableOrder.Order_CUST_Address__c = orderInfo?.orderAddress;
            // 주문 상세 주소
            consumableOrder.Order_CUST_Address_DETAIL__c = orderInfo?.orderDtlAddress;
            // 주문고객 우편번호
            consumableOrder.Order_CUST_PostalCode__c = orderInfo?.orderPostalCode;

            // 수취인 이름
            consumableOrder.CONSIGNEE_Name__c = orderInfo?.receiverName;

            // 수취인 전화 번호1
            // consumableOrder.CONSIGNEE_TPNO_1__c = DN_CommonUtil.setTelnumFormat(orderInfo?.receiverTelNo1);
            //2023.10.13 seung yoon heo contact 공통모듈 호출
            if (orderInfo.receiverTelNo1 != null && orderInfo.receiverTelNo1 != '') {
                String checkTelNoValidMessage = cmUtil.checkValidTelNo(orderInfo.receiverTelNo1);
                if(!String.isEmpty(checkTelNoValidMessage)) {
                    // 전화번호가 유호 하지 않는 경우 처리 케이스.
                    output.header.code = '500';
                    output.header.message = checkTelNoValidMessage + ' : ' + orderInfo.receiverTelNo1;
                    return output;
                }
                consumableOrder.CONSIGNEE_TPNO_1__c = DN_CommonUtil.setTelnumFormat(orderInfo.receiverTelNo1);
            }

        
            // 수취인 전화 번호2
            // consumableOrder.CONSIGNEE_TPNO_2__c = DN_CommonUtil.setTelnumFormat(orderInfo?.receiverTelNo2);
             //2023.10.13 seung yoon heo contact 공통모듈 호출
             if (orderInfo.receiverTelNo2 != null && orderInfo.receiverTelNo2 != '') {
                String checkTelNoValidMessage = cmUtil.checkValidTelNo(orderInfo.receiverTelNo2);
                if(!String.isEmpty(checkTelNoValidMessage)) {
                    // 전화번호가 유호 하지 않는 경우 처리 케이스.
                    output.header.code = '500';
                    output.header.message = checkTelNoValidMessage + ' : ' + orderInfo.receiverTelNo2;
                    return output;
                }
                consumableOrder.CONSIGNEE_TPNO_2__c = DN_CommonUtil.setTelnumFormat(orderInfo.receiverTelNo2);
            }
            // 수취인 주소
            consumableOrder.CONSIGNEE_Address__c = orderInfo?.receiverAddress;
            // 수취인 상세 주소
            consumableOrder.CONSIGNEE_Address_DETAIL__c = orderInfo?.receiverDtlAddress;
            // 수취인 우편번호
            consumableOrder.CONSIGNEE_PostalCode__c = orderInfo?.receiverPostalCode;
            // 특이사항
            consumableOrder.Delivery_Message_CONTENT__c = orderInfo?.description;

            if(chnl.equals(EX_ConsumableUtil.CONSUMABLE_THINQ) && !cashTy.equals('')){
                switch on cashTy {
                    when '1' {
                        //1.간편결제
                        // 결제 방법 코드
                        consumableOrder.PAYMENT_Method_Code__c = 'CARD';
                        // 카드결제금액
                        consumableOrder.CARD_PAYMENT_Amount__c = orderInfo?.totApprAmt;
                        // 결제유형
                        consumableOrder.PAYMENT_TYPE__c = '1';
                    }
                    when '2' {
                        //2.LG페이
                        // 결제 방법 코드
                        consumableOrder.PAYMENT_Method_Code__c = 'CARD';
                        // 현금결제금액
                        consumableOrder.CASH_PAYMENT_Amount__c = orderInfo?.totApprAmt;
                        // 결제유형
                        consumableOrder.PAYMENT_TYPE__c = '2';
                    }
                    when '3' {
                        //3.신용카드
                        // 결제 방법 코드
                        consumableOrder.PAYMENT_Method_Code__c = 'CARD';
                        // 현금결제금액
                        consumableOrder.CASH_PAYMENT_Amount__c = orderInfo?.totApprAmt;
                        // 결제유형
                        consumableOrder.PAYMENT_TYPE__c = '3';
                    }
                    when '4' {
                        //3.휴대폰
                        // 결제 방법 코드
                        consumableOrder.PAYMENT_Method_Code__c = 'VBANK';
                        // 현금결제금액
                        consumableOrder.CASH_PAYMENT_Amount__c = orderInfo?.totApprAmt;
                        // 결제유형
                        consumableOrder.PAYMENT_TYPE__c = '4';
                    }
                }
            }else{
                // OBS
                // 결제유형(A:현금, B:카드, D:포인트)
                switch on depositType {
                    // [A]현금
                    when 'A' {
                        // 결제 방법 코드
                        consumableOrder.PAYMENT_Method_Code__c = 'VBANK';
                        // 결제유형(A:현금, B:카드, D:포인트)
                        // 23 08 24 hyungho.chun 결제유형 A:현금 -> A:가상계좌  (필드 fm_PAYMENT_TYPE__c 수정)
                        consumableOrder.PAYMENT_TYPE__c = 'OBS-A';

                        // 현금결제금액
                        consumableOrder.CASH_PAYMENT_Amount__c = orderInfo?.totApprAmt;
                    }
                    // [B]카드
                    when 'B' {
                        // 결제 방법 코드
                        consumableOrder.PAYMENT_Method_Code__c = 'CARD';
                        // 결제 유형
                        consumableOrder.PAYMENT_TYPE__c = 'OBS-B';
                        // 카드결제금액
                        consumableOrder.CARD_PAYMENT_Amount__c = orderInfo?.totApprAmt;
                    }
                    // [D]포인트
                    when 'D' {
                        // 결제 방법 코드
                        consumableOrder.PAYMENT_Method_Code__c = 'POINT';
                        // 결제 유형
                        consumableOrder.PAYMENT_TYPE__c = 'OBS-D';
                    }
                    // [NA]페이(기타)
                    when 'NA' {
                        // 결제 방법 코드
                        consumableOrder.PAYMENT_Method_Code__c = 'VBANK';
                        // 결제 유형
                        consumableOrder.PAYMENT_TYPE__c = 'OBS-NA';
                        // 현금결제금액
                        consumableOrder.CASH_PAYMENT_Amount__c = orderInfo?.totApprAmt;
                    }
                    // [NB]페이(카드)
                    when 'NB' {
                        // 결제 방법 코드
                        consumableOrder.PAYMENT_Method_Code__c = 'CARD';
                        // 결제 유형
                        consumableOrder.PAYMENT_TYPE__c = 'OBS-NB';
                        // 카드결제금액
                        consumableOrder.CARD_PAYMENT_Amount__c = orderInfo?.totApprAmt;
                    }
                }
                // 결제유형(A:현금, B:카드, D:포인트)
                //consumableOrder.PAYMENT_TYPE__c = depositType;
            }

            // 증빙유형(A:세금계산서, B:현금영수증, C:미발행)
            consumableOrder.INVOICE_ISSUE_TYPE__c = invoiceIssueType;

            if(consumableOrder.Order_CHNL_TYPE_Code__c == EX_ConsumableUtil.CONSUMABLE_OBS) {
                // 판매금액 -> OBS : 주문금액
                //consumableOrder.SALE_Amount__c = orderInfo.orderAmt != null ? orderInfo.orderAmt : 0;
                consumableOrder.SALE_Amount__c = orderNumberAmountMap.get(orderNumber).get('saleAmount');

                // 결제금액 -> OBS : 총 승인 금액 + 총 포인트 금액
                consumableOrder.PAYMENT_Amount__c = orderInfo?.totApprAmt + orderInfo?.totPointAmt;
                //consumableOrder.PAYMENT_Amount__c = orderNumberAmountMap.get(orderNumber).get('paymentAmount');

                // 포인트금액 -> OBS : 총 포인트 금액
                consumableOrder.POINT_Amount__c = orderInfo.totPointAmt != null ? orderInfo.totPointAmt : 0;
                // 할인 금액
                consumableOrder.Discount_Amount__c = consumableOrder.SALE_Amount__c - consumableOrder.PAYMENT_Amount__c;
                //consumableOrder.Discount_Amount__c = orderNumberAmountMap.get(orderNumber).get('discountAmount');
            } else {
                // 판매금액 -> OBS : 주문금액
                consumableOrder.SALE_Amount__c = orderInfo?.orderAmt;
                // 결제금액 -> OBS : 총 승인 금액 + 총 포인트 금액
                consumableOrder.PAYMENT_Amount__c = orderInfo?.totApprAmt + orderInfo?.totPointAmt;
                // 포인트금액 -> OBS : 총 포인트 금액
                consumableOrder.POINT_Amount__c = orderInfo?.totPointAmt;
            }
            // 배송비
            consumableOrder.PARCEL_FEE_Amount__c = orderInfo?.deliveryAmt;

            // // Contact Id
            // //2023-05-15
            // Map<String, Object> mapIbInfo = new Map<String, Object>();
            // mapIbInfo.put('inboundNo',orderInfo?.orderTelNo1); //전화번호
            // mapIbInfo.put('ContactName',orderInfo?.orderCustName); //고객이름
            // mapIbInfo.put('InboundChannel','Unmanned'); //고정값
            // mapIbInfo.put('UsePersonalInfo',null); //개인정보활용동의여부
            // try{
            //     Map<String, Object> contactMap = SC_CommonUtil.getContact(mapIbInfo);
            //     if(contactMap.get('contactId') != null){
            //         consumableOrder.Order_CUST_Id__c = String.valueOf(contactMap.get('contactId'));
            //     }
            // }catch(Exception e){
            //     system.debug('line : ' + e.getLineNumber() + ', msg:' + e.getMessage());
            // }

            // Contact Id
            //23 09 23 hyungho.chun contact넣는방법 공통꺼 사용하지 않음
            // String custName = orderInfo?.orderCustName;
            

            String mobileNum = '';
            //2023.10.13 seung yoon heo contact 공통모듈 호출
            if (orderInfo.orderTelNo1 != null && orderInfo.orderTelNo1 != '') {
                String checkTelNoValidMessage = cmUtil.checkValidTelNo(orderInfo?.orderTelNo1);
                if(!String.isEmpty(checkTelNoValidMessage)) {
                    // 전화번호가 유호 하지 않는 경우 처리 케이스.
                    output.header.code = '500';
                    output.header.message = checkTelNoValidMessage + ' : ' + mobileNum;
                    return output;
                }
                mobileNum = DN_CommonUtil.setTelnumFormat(orderInfo?.orderTelNo1);
            }

            // String strQry = '';
            // strQry = 'SELECT Id, Name, MobilePhone FROM Contact WHERE Name =: custName AND MobilePhone =: mobileNum ';
            // List<Contact> conList = Database.query(strQry);
            // if(conList.size()>0){
            //     consumableOrder.Order_CUST_Id__c = String.valueOf(conList[0].Id);
            // }else{
                //23 09 23 hyungho.chun orderInfoMap.keySet()이 for 문이지만 OBS주문은 늘 사이즈가1개라 1바퀴돈다


                //2023.10.13 seung yoon heo contact 공통모듈 호출
                Map<String, Object> paramMap = new Map<String, Object>();
                paramMap.put('contactName' , orderInfo?.orderCustName);
                paramMap.put('inboundNo' , mobileNum);

                
                //2023.10.13 seung yoon heo contact 공통모듈 호출
                if (orderInfo.orderTelNo2 != null && orderInfo.orderTelNo2 != '') {
                    String checkTelNoValidMessage = cmUtil.checkValidTelNo(orderInfo?.orderTelNo2);
                    if(!String.isEmpty(checkTelNoValidMessage)) {
                        // 전화번호가 유호 하지 않는 경우 처리 케이스.
                        // output.header.code = '500';
                        // output.header.message = checkTelNoValidMessage + ' : ' + orderInfo?.orderTelNo2;
                        // return output;
                        paramMap.put('inboundNo2' , '');
                    } else {
                        paramMap.put('inboundNo2' , orderInfo.orderTelNo2);

                    }
                }

                // 2023.11.09 seung yoon heo 우편번호가 없는 경우 이름 + 전화번호만 전송
                // 2023.11.15 seung yoon heo OBS 주소값 없이 생성으로 변경
                // if (orderInfo.orderPostalCode != null && orderInfo.orderPostalCode != '') {
                //     paramMap.put('zipNo' , orderInfo?.orderPostalCode);
                //     paramMap.put('fAddress' , orderInfo?.orderAddress + ' ' + orderInfo?.orderDtlAddress);
                    
                //     // 2023.10.31 seung yoon heo 주소 디테일 제거
                //     // paramMap.put('detailAddress' , ' ');
                // }
                paramMap.put('usePersonalInfo' , 'Y');
                paramMap.put('inboundChannel' , 'D');
                

                System.debug('해당 name과 phone으로 Contact 생성');

                Map<String, Object> getContactId = SC_IFUtil.getContactForCM(paramMap);

                consumableOrder.Order_CUST_Id__c = String.valueOf(getContactId.get('contactId'));

                // Contact objCont = new Contact();
                // objCont.LastName = custName;
                // objCont.MobilePhone = mobileNum;
                // objCont.ADDRESS_NEW__c = orderInfo?.orderAddress;
                // objCont.POSTAL_CODE__c = orderInfo?.orderPostalCode;
                
                // TriggerHandler.bypass('Contact_trHandler');
                // insert objCont;
                // TriggerHandler.clearBypass('Contact_trHandler');

                // System.debug('objCont :: '+objCont);

                // consumableOrder.Order_CUST_Id__c = String.valueOf(objCont.Id);
            // }

            // 23.04.19 / 추가
            consumableOrder.Department_Code__c = EX_ConsumableUtil.PH8002;
            consumableOrder.Department_Id__c = consumableCenterDept.Id;
            //20230510 - ysh 위로 이동
//            consumableOrder.Order_Date__c = System.now();
//            consumableOrder.PAYMENT_REQUEST_DATE__c = System.now();
//            consumableOrder.PAYMENT_COMPLETED_DTM__c = System.now();
            consumableOrder.PAYMENT_YN__c = true;

            //2023.08.14 seung yoon heo 할인유형 추가
            consumableOrder.SALE_DC_TYPE__c = disTypeMap.get('Y') != null ? disTypeMap.get('Y') : '';
            

            productRequestMap.put(orderNumber, consumableOrder);
        }

        insert productRequestMap.values();

        if (!productRequestMap.isEmpty()) {
            output = createConsumableOrderItemFromOBS(productRequestMap, orderItemMap, infoMap, output, chnl, disTypeMap);
        }

        System.debug(output);
        return output;
    }
    /**
    * @description OBS 로부터 인입된 주문 데이터 Item Insert
    */
    public static Output createConsumableOrderItemFromOBS(Map<String, ProductRequest> productRequestMap, Map<String, List<IF_MACN_OBS_SFDC_0010.OrderItem>> orderItemMap, Map<String, Map<String, Object>> infoMap, Output output, String chnl, Map<String, String> disTypeMap) {
        System.debug('createConsumableOrderItemFromOBS');
        Map<String, Product2> partMasterMap = (Map<String, Product2>) infoMap.get('partMasterMap');
        // Key : PH8002 + '_' + ProductCode
        Map<String, ProductItem> itemAvailableQtyMap = (Map<String, ProductItem>) infoMap.get('itemAvailableQtyMap');
        // Key : DIV_CODE + '_' + ProductCode
        Map<String, ProductItem> itemAvailableDIVQtyMap = (Map<String, ProductItem>) infoMap.get('itemAvailableDIVQtyMap');

        List<ProductRequestLineItem> productRequestLineItems = new List<ProductRequestLineItem>();
        ProductRequestLineItem consumableOrderItem;
        List<SObject> lineItemList = new List<SObject>();
        DateTime deliveryDate = getDeliveryDate(); // 정상배송일

        String warehouseLocationId = EX_ConsumableUtil.getConsumableWareHouseId();

        Map<String, Product2> productIdMap = (Map<String, Product2>) infoMap.get('partMasterIdMap');
        List<ProductItem> prItemList = [SELECT Id, LocationId, Product2Id FROM ProductItem WHERE LocationId = :warehouseLocationId AND Product2Id IN :productIdMap.keySet()];

        Map<String, String> sProductItemMap = new Map<String, String>();
        for (ProductItem prItem : prItemList) {
            sProductItemMap.put(prItem.LocationId + '^' + prItem.Product2Id, prItem.Id);
        }

        for (String orderNumber : orderItemMap.keySet()) {
            for (IF_MACN_OBS_SFDC_0010.OrderItem orderItem : orderItemMap.get(orderNumber)) {
                consumableOrderItem = new ProductRequestLineItem();
                consumableOrderItem.Consumables_Order_YN__c = true;
                consumableOrderItem.ParentId = productRequestMap.get(orderNumber).Id;

                consumableOrderItem.Order_CUST_Id__c = productRequestMap.get(orderNumber).Order_CUST_Id__c;
                
                consumableOrderItem.RecordTypeId = EX_ConsumableUtil.PRLI_CONSUMABLE_RECORDTYPE_ID;

                // 주문 번호
                consumableOrderItem.Order_Number__c = orderNumber;
                // 주문 항번
                consumableOrderItem.Order_SEQ__c = orderItem.orderSeq;
                // LGE.COM
                consumableOrderItem.Order_CHNL_TYPE_Code__c = chnl;

                // 일반
                consumableOrderItem.Consumables_Order_Class_Code__c = 'General';
                // 주문
                consumableOrderItem.Consumables_Business_Type_Code__c = 'Order';

                // 사업부 코드
                consumableOrderItem.ENDP_Code__c = orderItem.divCode;

                // 요청 파트 넘버
                consumableOrderItem.PART_NO__c = orderItem.partNo;
                // 입고 파트 넘버
                consumableOrderItem.PART_NO__c = orderItem.partNo;

                // 사업부 코드 + 파트 넘버 유니크 Key
                String custExternalKey = orderItem.divCode + '_' + orderItem.partNo;

                if (partMasterMap.containsKey(custExternalKey)) {
                    consumableOrderItem.Product2Id = partMasterMap.get(custExternalKey).Id;
                    consumableOrderItem.BASIS_Parts_Number__c = partMasterMap.get(custExternalKey).Name;
                    consumableOrderItem.ProductItem__c = sProductItemMap.get(warehouseLocationId + '^' + consumableOrderItem.Product2Id);
                    //2024.02.23 seung yoon heo item에 asc_Price값 넣어주기
                    consumableOrderItem.ASC_PRICE__c = partMasterMap.get(custExternalKey).ASC_PRICE__c;
                }


                // 결제유형(A:현금, B:카드, D:포인트)
                switch on orderItem.depositType {
                    when 'A' {
                        consumableOrderItem.CASH_PAYMENT_Amount__c = orderItem.apprAmt;
                        consumableOrderItem.VIRTUAL_ACCT_PAYMENT_Amount__c = orderItem.apprAmt;
                    }
                    when 'B' {
                        consumableOrderItem.CARD_PAYMENT_Amount__c = orderItem.apprAmt;
                    }
                    when 'D' {
                        consumableOrderItem.POINT_Amount__c = orderItem.apprAmt;
                    }
                    // [NA]페이(기타) / 현금
                    when 'NA' {
                        consumableOrderItem.CASH_PAYMENT_Amount__c = orderItem.apprAmt;
                        consumableOrderItem.VIRTUAL_ACCT_PAYMENT_Amount__c = orderItem.apprAmt;
                    }
                    // [NB]페이(카드)
                    when 'NB' {
                        // 현금결제금액
                        consumableOrderItem.CARD_PAYMENT_Amount__c = orderItem.apprAmt;
                    }
                }

                // 결제유형(A:현금, B:카드, D:포인트)
                // 증빙유형(A:세금계산서, B:현금영수증, C:미발행)
                if(consumableOrderItem.Order_CHNL_TYPE_Code__c == EX_ConsumableUtil.CONSUMABLE_OBS) {
                    // 주문 수량(요청)
                    consumableOrderItem.QuantityRequested = orderItem.orderQty;
                    // 판매 수량
                    consumableOrderItem.SALE_Quantity__c = orderItem.orderQty;

                    // 판매 금액
                    consumableOrderItem.SALE_Amount__c = orderItem.orderPrice * orderItem.orderQty;
                    // 결제 금액
                    // 230517 수정
                    //consumableOrderItem.PAYMENT_Amount__c = orderItem.apprAmt + orderItem.pointAmt;
                    consumableOrderItem.PAYMENT_Amount__c = orderItem.priceCost;

                    // 포인트 금액
                    consumableOrderItem.POINT_Amount__c = orderItem.pointAmt;
                    // 할인 금액
                    consumableOrderItem.Last_Discount_Amount__c = consumableOrderItem.SALE_Amount__c - consumableOrderItem.PAYMENT_Amount__c;
                    //23 08 04 hyungho.chun 부품판매관리화면에서 할인금액보이게 임시로 임직원할인금액필드에 넣어줌
                    consumableOrderItem.Employees_Discount_Amount__c = consumableOrderItem.SALE_Amount__c - consumableOrderItem.PAYMENT_Amount__c;
                    // 소비자가
                    //consumableOrderItem.CONSUMER_Price__c = orderItem.orderPrice;
                    consumableOrderItem.CONSUMER_Price__c = partMasterMap.get(custExternalKey).CUST_PRICE__c;

                } else {
                    // 주문 수량(요청)
                    consumableOrderItem.QuantityRequested = orderItem.orderQty;
                    // 판매 수량
                    consumableOrderItem.SALE_Quantity__c = orderItem.orderQty;
                    // 판매 금액
                    consumableOrderItem.SALE_Amount__c = orderItem.orderPrice * orderItem.orderQty;
                    // 결제 금액 -> OBS : 승인금액 + 포인트금액
                    consumableOrderItem.PAYMENT_Amount__c = orderItem.priceCost;
                    // 포인트 금액 -> OBS : 포인트 금액
                    consumableOrderItem.POINT_Amount__c = orderItem.pointAmt;
                    // 할인 금액
                    consumableOrderItem.Last_Discount_Amount__c = (orderItem.apprAmt + orderItem.pointAmt) - orderItem.priceCost;
                }

                // 소모품 재고
                String consumableProductItemKey = EX_ConsumableUtil.PH8002 + '_' + orderItem.divCode + '_' + orderItem.partNo;
                ProductItem consumableProductItem = itemAvailableQtyMap.get(consumableProductItemKey);

                // 사업부 재고
                String divProductItemKey = orderItem.divCode + '_' + orderItem.partNo;
                ProductItem divProductItem = itemAvailableDIVQtyMap.get(divProductItemKey);

                

                //ThinQ 2023-05-11
                if(chnl.equals(EX_ConsumableUtil.CONSUMABLE_THINQ)){
                    consumableOrderItem.CONSUMER_Price__c = orderItem.orderPrice;
                    consumableOrderItem.UnitPrice__c = orderItem.orderPrice;

//                    ProductItem tpi = new ProductItem();
//                    tpi = itemAvailableQtyMap.get(EX_ConsumableUtil.PH8002 + '_' + orderItem.partNo);
//
//                    consumableOrderItem.ProductItem__c = tpi.Id;

                    consumableOrderItem.Employees_Discount_Amount__c = 0; //임직원할인금액
                    consumableOrderItem.COUPON_Discount_Amount__c = 0; //쿠폰할인금액

                    if (partMasterMap.containsKey(custExternalKey)) {
                        consumableOrderItem.BASIS_Parts__c = partMasterMap.get(custExternalKey).Id;
                    }
                }

                Boolean isConsumableCenter = false;

                // Source Location
                consumableOrderItem.SourceLocationId = warehouseLocationId;
                // 부서 코드
                consumableOrderItem.Department_Code__c = EX_ConsumableUtil.PH8002;

                // 주문 수량이 소모품센터의 수량보다 작거나 같은 경우, 소모품센터에서 출고
                if (consumableProductItem != null && consumableProductItem.fm_Available_Quantity__c != null && orderItem.orderQty != null && consumableProductItem.fm_Available_Quantity__c >= orderItem.orderQty) {
                    System.debug('========================================');
                    System.debug('주문 수량이 소모품센터의 수량보다 작거나 같은 경우, 소모품센터에서 출고');
                    System.debug('============================================');
                    System.debug('fm_Available_Quantity__c => ' + consumableProductItem.fm_Available_Quantity__c);
                    System.debug('orderItem.orderQty =>' + orderItem.orderQty);

                    isConsumableCenter = true;
                    // 출고 부서 코드
                    consumableOrderItem.SHIPPED_Department_Code__c = EX_ConsumableUtil.PH8002;
                    consumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_006;
                    consumableOrderItem.Appointment_Status__c = '입고완료';

                    // 정상배송일
                    consumableOrderItem.fm_deliveryTerm__c = deliveryDate;

                    // 주문 수량이 소모품센터의 수량 보다 크고 사업부의 수량보다는 작거나 같은 경우 사업부에서 출고
                } else if (consumableProductItem != null && consumableProductItem.fm_Available_Quantity__c != null && orderItem.orderQty != null && divProductItem.QuantityOnHand != null && consumableProductItem.fm_Available_Quantity__c < orderItem.orderQty && (divProductItem.QuantityOnHand - divProductItem.ORDER_QTY__c) >= orderItem.orderQty) {
                    System.debug('========================================');
                    System.debug('주문 수량이 소모품센터의 수량 보다 크고 사업부의 수량보다는 작거나 같은 경우');
                    System.debug('========================================');
                    System.debug('fm_Available_Quantity__c => ' + consumableProductItem.fm_Available_Quantity__c);
                    System.debug('orderItem.orderQty =>' + orderItem.orderQty);
                    System.debug('divProductItem.QuantityOnHand => ' + divProductItem.QuantityOnHand);
                    System.debug('divProductItem.ORDER_QTY__c => ' + divProductItem.ORDER_QTY__c);

                    consumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_002;

                    // 출고 부서 코드
                    consumableOrderItem.SHIPPED_Department_Code__c = divProductItem.Product2.DIV_CODE__c;
                    consumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_002;

                    // 정상배송일
                    consumableOrderItem.fm_deliveryTerm__c = deliveryDate;

                    //24.01.10 gw.lee
                    //단종부품 + 사업부 주문 요청 할 경우, 에러 리턴
                    if (divProductItem.Product2.DISABLED_TYPE__c != null) {
                        output.header.code = '500';
                        output.header.message = '단종 부품의 경우, 사업부 주문이 불가능합니다. : ' + divProductItem.Product2.Name ;
                        return output;
                    }

                } else {
                    // todo : 주문수량이 소모품센터 재고수량 보다 크고, 사업부의 재고수량 보다 큰 경우?
                    // todo : OBS / ThinQ 의 경우 품절주문이 아닌 일반주문 + 예약(약속) 의 형태로 진행
                    System.debug('========================================');
                    System.debug('주문수량이 소모품센터 재고수량 보다 크고, 사업부의 재고수량 보다 큰 경우');
                    System.debug('fm_Available_Quantity__c => ' + consumableProductItem.fm_Available_Quantity__c);
                    System.debug('orderItem.orderQty =>' + orderItem.orderQty);
                    System.debug('divProductItem.QuantityOnHand => ' + divProductItem.QuantityOnHand);
                    System.debug('divProductItem.ORDER_QTY__c => ' + divProductItem.ORDER_QTY__c);
                    System.debug('========================================');
                    // 출고 부서 코드
                    consumableOrderItem.SHIPPED_Department_Code__c = divProductItem.Product2.DIV_CODE__c;

                    consumableOrderItem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_002;

                    //24.01.10 gw.lee
                    //단종부품 + 사업부 주문 요청 할 경우, 에러 리턴
                    if (divProductItem.Product2.DISABLED_TYPE__c != null) {
                        output.header.code = '500';
                        output.header.message = '단종 부품의 경우, 사업부 주문이 불가능합니다. : ' + divProductItem.Product2.Name ;
                        return output;
                    }
                }

                //2023.08.14 seung yoon heo 할인유형 추가
                consumableOrderItem.SALE_Discount_Type_Code__c = disTypeMap.get('Y') != null ? disTypeMap.get('Y') : '';

                // 소모품 주문 상태
                // todo: AS-IS : 소모품 센터에 재고가 있는 경우 상품준비중, 사업부에서 출고하는 경우 결제완료
                productRequestLineItems.add(consumableOrderItem);
                lineItemList.add(consumableOrderItem);
            }
        }


        // 서브번호 채번
        Map<String, Integer> subNumberMap = EX_ConsumableUtil.getSubNumberMap(lineItemList);

        for (ProductRequestLineItem prLi : productRequestLineItems) {
            if (prLi.RecordType.DeveloperName != 'RESV_SALE') {
                prLi.SUB_Order_Number__c = EX_ConsumableUtil.getSubNumber(subNumberMap, prLi);
            }
        }

        Database.SaveResult[] srList = Database.insert(productRequestLineItems, true);
        Set<String> successIdSet = new Set<String>();
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                successIdSet.add(sr.getId());
            } else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('The following error has occurred.');
                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                }
            }
        }

        String strProductRequestLineItemQry = '';
        strProductRequestLineItemQry += 'SELECT Id, ParentId, Order_Number__c, Order_SEQ__c, Department_Code__c, BASIS_Parts_Number__c, QuantityRequested, ENDP_Code__c, SHIPPED_Department_Code__c';
        strProductRequestLineItemQry += ' ,Product2.Name, Product2.ProductCode, Product2.PART_DESC_KOR__c, Product2.DIV_CODE__c ';
        strProductRequestLineItemQry += ' ,Product2.Description, Parent.Order_CUST_TPNO_1__c, Parent.Order_CUST_Name__c, Parent.Order_Number__c ' +
                ' ,Parent.Discount_Amount__c, Parent.Sale_Amount__c ';

        strProductRequestLineItemQry += '  FROM ProductRequestLineItem';
        strProductRequestLineItemQry += ' WHERE Id IN :successIdSet';
        List<ProductRequestLineItem> afterDMLConsumableOrderItems = Database.query(strProductRequestLineItemQry);

        Set<String> shippedDeptCodeSet = new Set<String>();
        for (ProductRequestLineItem prli : afterDMLConsumableOrderItems) {
            shippedDeptCodeSet.add(prli.SHIPPED_Department_Code__c);
        }
        List<SM_DIV__c> divList = [
                SELECT Id, DIV_CODE__c
                FROM SM_DIV__c
                WHERE DIV_CODE__c IN :shippedDeptCodeSet
        ];

        Map<String, SM_DIV__c> divMap = new Map<String, SM_DIV__c>();
        for (SM_DIV__c smDiv : divList) {
            divMap.put(smDiv.DIV_Code__c, smDiv);
        }

        // ******************** 약속 Section ******************** //
        System.debug('@@@@ 약속 Section @@@@');
        List<Map<String, Object>> mapList = new List<Map<String, Object>>();
        for (ProductRequestLineItem prli : afterDMLConsumableOrderItems) {
            if(divMap.containsKey(prli.SHIPPED_Department_Code__c)) {
                Map<String, Object> mapItem = new Map<String, Object>();
                mapItem.put('oriPrId', prli.ParentId); //원주문 ProductRequestId
                mapItem.put('oriPrliId', prli.Id); //원주문 ProductRequestLineItemId
                mapItem.put('oriOrderNo', prli.Order_Number__c); //원주문번호
                mapItem.put('oriOrderSeq', prli.Order_SEQ__c); //원주문Seq
                mapItem.put('deptCode', prli.Department_Code__c); //부서코드
                mapItem.put('partNo', prli.BASIS_Parts_Number__c); //파트넘버
                mapItem.put('req_qty', prli.QuantityRequested); //요청수량
                mapItem.put('div_code', prli.ENDP_Code__c); //사업부
                mapList.add(mapItem);
            }
        }
        /** 약속모듈 호출 */
        EX_RsrvUtil.RESRV_MODULE(mapList);

        Map<String, String> successMap = new Map<String, String>();
        List<ProductRequestLineItem> sLineItems = [
                SELECT Order_Number__c, Order_SEQ__c, Department_Code__c, Parent.Department_Id__c, Product2.ProductCode, ENDP_Code__c, SALE_Quantity__c,
                        SourceLocation.RecordType.DeveloperName, DestinationLocation.RecordType.DeveloperName,
                        Product2Id, SourceLocationId, DestinationLocationId, QuantityRequested, SHIPPED_Department_Code__c, Product2.DIV_CODE__c
                FROM ProductRequestLineItem
                WHERE Id IN :successIdSet
        ];

        for (ProductRequestLineItem successPrli : sLineItems) {
            successMap.put(successPrli.Order_Number__c + '_' + successPrli.Order_SEQ__c, 'Success');
        }
        // ******************** 약속 Section ******************** //

        // ******************** 수불처리 Section ******************** //
        List<Map<String, Object>> pListMapRequestInfo = new List<Map<String, Object>>();
        Map<String, Object> mapRequestInfo;
        Set<String> partIdSet = new Set<String>();
        Set<String> locationIdSet = new Set<String>();

        for (ProductRequestLineItem item : sLineItems) {
            if(!divMap.containsKey(item.SHIPPED_Department_Code__c)) {
                mapRequestInfo = new Map<String, Object>();
                mapRequestInfo.put('product2Id', item.Product2Id);
                mapRequestInfo.put('sourceLocationId', item.SourceLocationId);
                mapRequestInfo.put('destinationLocationId', null);
                mapRequestInfo.put('requestQTY', item.QuantityRequested);
                mapRequestInfo.put('requestType', 'AA');

                mapRequestInfo.put('productRequestLineItem', item);
                mapRequestInfo.put('returnOrderLineItem', null);
                mapRequestInfo.put('productTransfer', null);

                partIdSet.add(item.product2Id);
                locationIdSet.add(item.SourceLocationId);
                locationIdSet.add(item.DestinationLocationId);

                pListMapRequestInfo.add(mapRequestInfo);
            }
        }

        Map<String, ProductItem> pMapProductItemByKey = new Map<String, ProductItem>();
        String stqProductItemQry = '';
        stqProductItemQry += 'SELECT ' + String.join(getAllFields('ProductItem'), ',');
        stqProductItemQry += '  FROM ProductItem';
        stqProductItemQry += ' WHERE Product2Id IN :partIdSet AND LocationId IN :locationIdSet';

        List<ProductItem> productItems = Database.query(stqProductItemQry);
        String strKeyPI = '';
        for (ProductItem productItem : productItems) {
            strKeyPI = productItem.LocationId + '^' + productItem.Product2Id;
            pMapProductItemByKey.put(strKeyPI, productItem);
        }

        Map<String, Object> returnMap = new Map<String, Object>();
        returnMap = FS_MaterialUtil.applyProductItem(pListMapRequestInfo, pMapProductItemByKey);
        // ******************** 수불처리 Section ******************** //

        for (Data data : output.Body.data) {
            String custExternalKey = data.orderNo + '_' + data.orderSeq;
            if (successMap.containsKey(custExternalKey)) {
                data.resultCode = successMap.get(custExternalKey);
            } else {
                data.resultCode = 'Fail';
            }
        }

        return output;
    }

    /**
     * Input
     */
    global class Input {
        public List<OrderInfo> orderInfo;
        public List<IF_MACN_OBS_SFDC_0010.OrderItem> orderItem;
    }

    public class OrderInfo {
        public String orderNo; //1234567890
        public String unifyId;    //123456
        public String allyChnlId;
        public String orderCustName;    //홍길동
        public String orderTelNo1;    //01012345678
        public String orderTelNo2;    //021231234
        public String orderAddress; //서울시 금천구 디지털로 10길 56
        public String orderDtlAddress;    //엘지전자 가산A
        public String orderPostalCode;    //123456
        public String description;    //빠른 배송 부탁드립니다.
        public String receiverName;    //홍길동
        public String receiverTelNo1; //01012345678
        public String receiverTelNo2;    //021231234
        public String receiverAddress;    //서울시 금천구 디지털로 10길 56
        public String receiverDtlAddress;    //엘지전자 가산A
        public String receiverPostalCode;    //123456
        public Integer orderAmt; //100000
        public Integer deliveryAmt;    //0
        public Integer totApprAmt;    //100000
        public Integer totPointAmt;    //0
        //2023.08.14 seung yoon heo 할인유형 추가
        public String isMember;
        public String isEmployee;
    }
    global class OrderItem {
        public String orderNo;    //1234567890
        public Integer orderSeq;    //1
        public String divCode;    //DGZ
        public String partNo;    //ACQ65928302
        public Integer orderQty;    //1
        public Integer orderPrice;    //60000
        public String depositType;    //A
        public String invoiceissueType;    //B
        public Integer apprAmt;    //60000
        public Integer pointAmt;    //0
        public Integer priceCost;
        //2023.08.14 seung yoon heo 할인유형 추가
        public String useCoupon;
        
    }

    /**
     * Output
     */

    global class Output {
        public OutputHeader Header;
        public OutputBody Body;
    }
    global class OutputHeader {
        public String code;    //200
        public String message;    //200:정상적으로 조회되었습니다.
    }
    global class OutputBody {
        public List<Data> data;
    }
    global class Data {
        public String orderNo;    //1234567890
        public String orderSeq;    //1
        public String resultCode;    //SUCESS
    }

    public static List<String> getAllFields(String strObjectName) {

        SObjectType objType = Schema.getGlobalDescribe(). get (strObjectName);
        Map<String, Schema.SObjectField> mfields = objType.getDescribe().fields.getMap();
        List<String> listFields = new List<String>();

        for (String key : mfields.keySet()) {
            listFields.add(String.valueOf(mfields.get(key)));
        }

        return listFields;
    }


    //sj.yang 2023.08.14
    public static Datetime getDeliveryDate() {

        Datetime deliveryDate = System.now(); // 정상배송완료일
        Integer stateYear = deliveryDate.year(); // 현재년도
        Integer countWDay = 0; // 평일 카운트
        Date stateDate = deliveryDate.date(); // 기준날짜
        Integer dTHour = deliveryDate.hour(); // 현재시간
        System.debug('현재시간 : ' + dTHour);
        
        if(dTHour >= 19) { // 19시 이후 기준날짜 + 1
            stateDate = Date.newInstance(deliveryDate.year(), deliveryDate.month(), deliveryDate.day()+1);
            System.debug('기준날짜 바뀜 : ' + stateDate);
        }
        
        
        List<SM_HOLIDAY_MASTER__c> HOLIDAYItems =  [SELECT 	Id, DIV_CODE__c, HOLI_END_DT__c, HOLI_START_DT__c, HOLI_TYPE__c, HOLY_REASON__c
        FROM SM_HOLIDAY_MASTER__c
        WHERE HOLI_TYPE__c IN('A', 'B', 'D', 'Z')
        AND HOLI_APPLY_TY__c = 'C'
        AND CALENDAR_YEAR(HOLI_START_DT__c) IN(:stateYear, :stateYear+1)
        AND HOLI_START_DT__c >= TODAY
        ORDER BY HOLI_START_DT__c ASC];
        
        
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




}

//{
//    "orderInfo": [
//{
//"RESPONSE_CODE": "",
//"RESPONSE_MSG": "",
//"allyChnlId": "",
//"deliveryAmt": "0",
//"description": " ",
//"orderAddress": "\uC11C\uC6B8 \uAC15\uC11C\uAD6C \uB9C8\uACE1\uC911\uC5598\uB85C 71 (\uB9C8\uACE1\uB3D9, LG\uC0AC\uC774\uC5B8\uC2A4\uD30C\uD06C)",
//"orderAmt": "98500",
//"orderCustName": "\uC774\uC6A9\uC11D",
//"orderDtlAddress": "E13",
//"orderNo": "ORD-9999967142",
//"orderPostalCode": "07795",
//"orderTelNo1": "01049312889",
//"orderTelNo2": "",
//"receiverAddress": "\uC11C\uC6B8 \uAC15\uC11C\uAD6C \uB9C8\uACE1\uC911\uC5598\uB85C 71 (\uB9C8\uACE1\uB3D9, LG\uC0AC\uC774\uC5B8\uC2A4\uD30C\uD06C)",
//"receiverDtlAddress": "E13",
//"receiverName": "\uC774\uC6A9\uC11D",
//"receiverPostalCode": "07795",
//"receiverTelNo1": "01049312889",
//"receiverTelNo2": "",
//"totApprAmt": "98500",
//"totPointAmt": "0"
//}
//],
//"orderItem": [
//{
//    "apprAmt": "23700",
//"depositType": "B",
//"divCode": "DLZ",
//"invoiceIssueType": "",
//    "orderNo": "ORD-9999967142",
//    "orderPrice": "25000",
//    "orderQty": "1",
//"orderSeq": "10799792",
//"partNo": "ADQ75133511",
//"pointAmt": "0",
//    "priceCost": "23700"
//},
//{
//"apprAmt": "11400",
//        "depositType": "B",
//"divCode": "DLZ",
//"invoiceIssueType": "",
//"orderNo": "ORD-9999967142",
//"orderPrice": "12000",
//"orderQty": "1",
//"orderSeq": "10799795",
//"partNo": "AKB75055435",
//"pointAmt": "0",
//"priceCost": "11400"
//},
//{
//"apprAmt": "63400",
//"depositType": "B",
//"divCode": "DLZ",
//"invoiceIssueType": "",
//"orderNo": "ORD-9999967142",
//"orderPrice": "66800",
//"orderQty": "1",
//"orderSeq": "10799798",
//"partNo": "ADQ75153455",
//"pointAmt": "0",
//"priceCost": "63400"
//}
//]
//}