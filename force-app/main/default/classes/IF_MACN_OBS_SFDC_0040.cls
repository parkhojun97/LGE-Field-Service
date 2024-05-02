/**
 * Created by I2MAX.SEOKHOLEE on 2023-04-02.
 */

@RestResource(UrlMapping='/v1/api/ma/obs/IF_MACN_OBS_SFDC_0040')
global without sharing class IF_MACN_OBS_SFDC_0040 {

    // =============================================================
    // 인터페이스 Id 값 설정 (SFDC에 ifId를 저장하여 사용)
    // =============================================================
    private static final String IFID = 'IF-NEW-505';
    private static final String SUCCESS = 'SUCCESS';
    private static final String ERROR = 'ERROR';

    static Boolean isSuccessFlag = true;

    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        String requestBody = request.requestBody.toString();
        String requestHeader = request.headers.toString();

        RestResponse response = RestContext.response;

        // 로그 시작 (IF_Master에 등록되어 있으며, 로그 적재 여부가 true일 경우에만 쌓임)
        IFUtil ifUtil = new IFUtil(IFID);
        IFUtil.LogWrapper log = new IFUtil.LogWrapper(IFID, requestHeader, requestBody);


        OutputHeader header = new OutputHeader();

        OutputBody body = new OutputBody();
        body.data = new List<IF_MACN_OBS_SFDC_0040.Data>();

        Input objInput = new Input();
        Output objOutput = new Output();

        Savepoint sp = Database.setSavepoint();
        try {

            System.debug('============================================');
            System.debug('======= LGE.COM 반품 요청 I/F =======');
            System.debug('IF_MACN_OBS_SFDC_0040');
            System.debug(requestBody);
            System.debug(requestHeader);
            System.debug('============================================');

            if (requestBody != null && requestBody != '') {
                objInput = (Input) JSON.deserialize(requestBody, Input.class);

                objOutput = createConsumableReturnOrderFromOBS(objInput);
            }

        } catch (Exception e) {
            Database.rollback(sp);

            isSuccessFlag = false;
            header.code = '500';
            header.message = e.getMessage();
            System.debug(e.getMessage() + ', LineNumber:' + e.getLineNumber());
            objOutput.Header = header;
        }
        System.debug('isSuccessFlag => ' + isSuccessFlag);
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

        log.responseTime = System.now();
        log.responseBody = JSON.serialize(objOutput);
        log.status = objOutput.header.code == '200' ? SUCCESS : ERROR;
        log.errorMessage = objOutput.header.message;
        ifUtil.insertLog(log);

    }

    public static Output createConsumableReturnOrderFromOBS(Input objInput) {
        Output output = new Output();
        output.Header = new OutputHeader();

        output.Body = new IF_MACN_OBS_SFDC_0040.OutputBody();
        output.Body.data = new List<IF_MACN_OBS_SFDC_0040.Data>();

        List<IF_MACN_OBS_SFDC_0040.OrderReturn> objOrderReturn = objInput.orderReturn;

        IF_MACN_OBS_SFDC_0040.Data outputData;
        Map<String, Map<String, IF_MACN_OBS_SFDC_0040.OrderReturn>> orderNumberReturnKeyMap = new Map<String, Map<String, IF_MACN_OBS_SFDC_0040.OrderReturn>>();
        Map<String, IF_MACN_OBS_SFDC_0040.Data> returnKeyMap = new Map<String, IF_MACN_OBS_SFDC_0040.Data>();

        Set<String> divCodeSet = new Set<String>();
        Set<String> productCodeSet = new Set<String>();

        // OBS 반품주문번호 Set
        Set<String> obsReturnOrderNumberSet = new Set<String>();


        // Output setting
        for (IF_MACN_OBS_SFDC_0040.OrderReturn item : objOrderReturn) {
            // OBS 반품주문번호 Set
            obsReturnOrderNumberSet.add(item.orderNo);

            outputData = new IF_MACN_OBS_SFDC_0040.Data();

            // OBS 반품 주문번호
            outputData.orderNo = item.orderNo;
            // OBS 반품 주문 항번
            outputData.orderSeq = item.orderSeq;

            // OBS 실 주문 번호
            outputData.originOrderNo = item.originOrderNo;
            // OBS 실 주문 항번
            outputData.originOrderSeq = item.originOrderSeq;

            outputData.partNo = item.partNo;
            outputData.divCode = item.divCode;

            outputData.resultCode = '';
            outputData.resultMessage = '';
            outputData.returnRequestReason = '';
            
            //2023.08.14 seung yoon heo 결제자명 추가
            outputData.isAdmin = '';

            output.Body.data.add(outputData);



            // 1. 반품요청 중복 건 체크
            // 1-1. 반품요청 중복 Return


            // 2. 원주문 존재여부 체크
            // 2-1. 원주문 미존재 Return

            // 3. 원주문 배송여부 체크
            // 3-1 원주문 배송여부 체크

            // 4. 반품요청 Insert

            // 원 주문 번호 + '_' + 원 주문 항번 + '_' + 반품 주문번호 + '_' + 반품 주문 항번;
            String itemKey = String.join(new List<String>{
                    item.originOrderNo, String.valueOf(item.originOrderSeq),
                    item.orderNo, String.valueOf(item.orderSeq)
            }, '_');

            if (orderNumberReturnKeyMap.containsKey(item.originOrderNo)) {
                orderNumberReturnKeyMap.get(item.originOrderNo).put(itemKey, item);
            } else {
                orderNumberReturnKeyMap.put(item.originOrderNo, new Map<String, IF_MACN_OBS_SFDC_0040.OrderReturn>{
                        itemKey => item
                });
            }
            productCodeSet.add(item.partNo);
            divCodeSet.add(item.divCode);

            returnKeyMap.put(itemKey, outputData);
        }


        // 1. 반품요청 중복 건 체크
        // 1-1. 반품요청 중복 Return

        List<ReturnOrderLineItem> existReturnOrderlis = [
                SELECT Id
                FROM ReturnOrderLineItem
                WHERE Request_Number__c IN :obsReturnOrderNumberSet
        ];

        if (existReturnOrderlis.size() > 0) {
            isSuccessFlag = false;
            output.Header.code = '500';
            output.Header.message = '이미 요청된 반품 번호 입니다.';
            return output;
        }

        // 원 주문 조회
        List<ProductRequest> consumableOrders = [
                SELECT Id, Order_Number__c, RESRV_Number__c, SR_RSRV_PART_Id__c, SALE_Number__c, SR_SALE__c,  PAYMENT_Method_Code__c, CARD_PAYMENT_Amount__c, CASH_PAYMENT_Amount__c, POINT_Amount__c,
                    Order_CUST_Name__c, Order_CUST_TPNO_1__c, Order_CUST_Address__c, Order_CUST_Address_DETAIL__c, Order_CUST_PostalCode__c,
                        CONSIGNEE_Name__c, CONSIGNEE_TPNO_1__c, CONSIGNEE_Address__c, CONSIGNEE_Address_DETAIL__c, CONSIGNEE_PostalCode__c, Order_CUST_Id__c
                ,(
                        SELECT Id, Order_SEQ__c, Consumables_Order_Status__c, Appointment_Status__c, ENDP_RSV_Quantity__c, SALE_Quantity__c, Order_Number__c, PAYMENT_Amount__c,
                                SourceLocationId, DestinationLocationId, Product2.DIV_CODE__c, Product2.ProductCode, POINT_Amount__c, 
                                ParentId, Parent.RESRV_Number__c, Parent.SR_RSRV_PART_Id__c, Parent.SALE_Number__c, Parent.SR_SALE__c, CARD_PAYMENT_Amount__c, CASH_PAYMENT_Amount__c, VIRTUAL_ACCT_PAYMENT_Amount__c
                        FROM ProductRequestLineItems
                        WHERE RecordType.DeveloperName = 'Consumable'
                )
                FROM ProductRequest
                WHERE Order_Number__c IN :orderNumberReturnKeyMap.keySet()
                AND RecordType.DeveloperName = 'Consumable'
        ];
        if (consumableOrders.isEmpty()) {
            isSuccessFlag = false;
            output.Header.code = '500';
            output.Header.message = '주문번호가 존재하지 않습니다. ';
            return output;
        }

        Map<String, ProductRequest> originOrderNumberMap = new Map<String, ProductRequest>();

        Set<String> prliIdSet = new Set<String>();
        Map<String, ProductRequestLineItem> prliKeyMap = new Map<String, ProductRequestLineItem>();
        String prliKey = '';

        //2023.08.14 seung yoon heo 결제자명 추가  //08.22 결재자명 제거
        // Map<String, String> orderReturnName = new Map<String, String>();


        for (ProductRequest pr : consumableOrders) {
            // //2023.08.14 seung yoon heo 결제자명 추가
            // orderReturnName.put('payerName' , pr.Order_CUST_Name__c);

            for (ProductRequestLineItem prli : pr.ProductRequestLineItems) {
                prliIdSet.add(prli.Id);
                prliKey = prli.Order_Number__c + '_' + prli.Order_SEQ__c;
                prliKeyMap.put(prliKey, prli);

                
            }

            originOrderNumberMap.put(pr.Order_Number__c, pr);
            
            
        }



        // 1. 원 주문건의 배송정보 조회
        // 1-1. 원 주문건의 배송정보 미존재시 Return
        Map<String, ProductRequestLineItem> prliDeliveryInfoMap = new Map<String, ProductRequestLineItem>();
        List<ProductRequestLineItem> deliveryInfos = [
                SELECT Id, INVOICE_Number__c, Order_SEQ__c, Order_Number__c , PAYMENT_Amount__c
                FROM ProductRequestLineItem
                WHERE Id IN :prliIdSet
        ];


        for (ProductRequestLineItem prli : deliveryInfos) {
            prliDeliveryInfoMap.put(prli.Order_Number__c + '_' + prli.Order_SEQ__c, prli);

        }

        for (IF_MACN_OBS_SFDC_0040.OrderReturn item : objOrderReturn) {
            if (prliDeliveryInfoMap.containsKey(item.originOrderNo + '_' + item.originOrderSeq)) {
                ProductRequestLineItem originOrderItem = prliDeliveryInfoMap.get(item.originOrderNo + '_' + item.originOrderSeq);
                if(originOrderItem.INVOICE_Number__c == null) {
                    isSuccessFlag = false;
                    output.Header.code = '500';
                    output.Header.message = '해당 주문의 배송정보가 존재하지 않습니다.';
                    return output;
                }
            }
        }
        // 2. 기존 반품 여부 체크 : 기존 원 주문의 항목의 ReturnRequestDate 가 존재하는 경우(not null) 중복 처리 하였음.
        // 2-1 원주문 미존재 Return

        Boolean isValid = true;
        List<ReturnOrder> consumableReturnOrders = [
                SELECT Id, Order_Number__c, ProductRequestId, (
                        SELECT Id, Order_Number__c, Order_SEQ__c, ProductRequestLineItem.Order_Number__c
                        FROM ReturnOrderLineItems
                )
                FROM ReturnOrder
                WHERE Order_Number__c IN :orderNumberReturnKeyMap.keySet()
        ];

        // 4. 반품요청 Insert
        List<Map<String, Object>> pListMapRequestInfo = new List<Map<String, Object>>();
        Map<String, Object> mapRequestInfo = new Map<String, Object>();

        EX_ConsumableUtil.ConsumableReturnOrderTable consumableReturnOrderTable = new EX_ConsumableUtil.ConsumableReturnOrderTable();
        List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable> itemTables = new List<EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable>();
        EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable itemTable;

        // 부품마스터 조회
        // todo : 부품마스터에 해당 부품이 없을시 Error 리턴
        // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
        List<Product2> product2s = [
                SELECT Id, DIV_CODE__c, Name
                FROM Product2
                WHERE DIV_CODE__c IN :divCodeSet AND Name IN :productCodeSet
        ];

        // Key : '사업부코드' + '_' + 'ProductCode'
        // 2023.09.18 seung yoon heo ProductCode => Name으로 변경
        Map<String, Product2> partMasterMap = new Map<String, Product2>();
        for (Product2 prod : product2s) {
            if (prod.DIV_CODE__c != null && prod.Name != null) {
                String custExternalKey = prod.DIV_CODE__c + '_' + prod.Name;
                partMasterMap.put(custExternalKey, prod);
            }
        }
        

        //23 08 28 hyungho.chun 총 반품 금액 추가용
        Decimal totalPaymentAmt = 0;
        //24 02 26 hyungho.chun 결제방법별 금액(복합결제 대비)
        Decimal totalCardAmt = 0;
        Decimal totalCashAmt = 0;
        Decimal totalPoiintAmt = 0;

        for (IF_MACN_OBS_SFDC_0040.OrderReturn item : objOrderReturn) {
//            String itemKey = String.join(new List<String> {
//                    item.originOrderNo,
//                    String.valueOf(item.originOrderSeq),
//                    item.orderNo,
//                    String.valueOf(item.orderSeq)}, '_');
//            if(!returnKeyMap.containsKey(itemKey)) {
            itemTable = new EX_IntegrationOrderManagementController.IntegrationOrderLineItemTable();

            itemTable.OBSReturnOrderNumber = item.orderNo;
            itemTable.OBSReturnOrderSeq = item.orderSeq;
            itemTable.OrderSeq = item.orderSeq;

            itemTable.BasisOrderNumber = item.originOrderNo;

            itemTable.Id = prliKeyMap.get(item.originOrderNo + '_' + item.originOrderSeq).Id;

            itemTable.RequestedReturnQuantity = prliKeyMap.get(item.originOrderNo + '_' + item.originOrderSeq).SALE_Quantity__c;
            itemTable.ReceivedPartNo = item.partNo;
            itemTable.DIV = item.divCode;
            itemTable.OrderStatus = '';

            if (partMasterMap.containsKey(item.divCode + '_' + item.partNo)) {
                Product2 parts = partMasterMap.get(item.divCode + '_' + item.partNo);
                itemTable.Product2Id = parts.Id;
                itemTable.ReceivedPartNo = parts.Name;
                itemTable.DIV = parts.DIV_CODE__c;
            }


            //2023.08.14 seung yoon heo 반품취소자 명 추가
            if (item.isAdmin != null && item.isAdmin == 'N') {
                // itemTable.ReturnRequestReason = '(' + orderReturnName.get('payerName') + ') '  + item.returnRequestReason;
                itemTable.ReturnRequestReason = '(고객) '  + item.returnRequestReason;
            }else{
                itemTable.ReturnRequestReason = '(관리자) ' + item.returnRequestReason;
            }

 

            //2024 03 04 seun yoon heo 부분 반품금액 원주문 전체 금액으로 잘 못넣어주는거 수정
            totalCardAmt = totalCardAmt +  prliKeyMap.get(item.originOrderNo + '_' + item.originOrderSeq).CARD_PAYMENT_Amount__c;
            totalCashAmt = totalCashAmt +  (prliKeyMap.get(item.originOrderNo + '_' + item.originOrderSeq).CASH_PAYMENT_Amount__c != null ?
            prliKeyMap.get(item.originOrderNo + '_' + item.originOrderSeq).CASH_PAYMENT_Amount__c : prliKeyMap.get(item.originOrderNo + '_' + item.originOrderSeq).VIRTUAL_ACCT_PAYMENT_Amount__c);
            totalPoiintAmt = totalPoiintAmt +  prliKeyMap.get(item.originOrderNo + '_' + item.originOrderSeq).POINT_Amount__c;

            totalPaymentAmt = totalPaymentAmt + prliKeyMap.get(item.originOrderNo + '_' + item.originOrderSeq).PAYMENT_Amount__c;

            itemTables.add(itemTable);
        }

        consumableReturnOrderTable.ConsumableReturnOrderLineItemTables = itemTables;
        consumableReturnOrderTable.OriginOrderNumber = objOrderReturn[0].originOrderNo;
        consumableReturnOrderTable.OBSReturnOrderNumber = objOrderReturn[0].orderNo;

        if(originOrderNumberMap.containsKey(objOrderReturn[0].originOrderNo)) {
            consumableReturnOrderTable.OriginOrderId = originOrderNumberMap.get(objOrderReturn[0].originOrderNo).Id;
        }

        if (originOrderNumberMap.containsKey(consumableReturnOrderTable.OriginOrderNumber)) {
            ProductRequest originOrder = originOrderNumberMap.get(consumableReturnOrderTable.OriginOrderNumber);
            consumableReturnOrderTable.CustomerName = originOrder.Order_CUST_Name__c;
            consumableReturnOrderTable.CustomerPhone = originOrder.Order_CUST_TPNO_1__c;
            consumableReturnOrderTable.CustomerAddress = originOrder.Order_CUST_Address__c;
            consumableReturnOrderTable.CustomerDetailAddress = originOrder.Order_CUST_Address_DETAIL__c;
            consumableReturnOrderTable.CustomerPostalCode = originOrder.Order_CUST_PostalCode__c;

            consumableReturnOrderTable.CONSIGNEE_Name = originOrder.CONSIGNEE_Name__c;
            consumableReturnOrderTable.CONSIGNEE_Phone = originOrder.CONSIGNEE_TPNO_1__c;
            consumableReturnOrderTable.CONSIGNEE_Address = originOrder.CONSIGNEE_Address__c;
            consumableReturnOrderTable.CONSIGNEE_DetailAddress = originOrder.CONSIGNEE_Address_DETAIL__c;
            consumableReturnOrderTable.CONSIGNEE_PostalCode = originOrder.CONSIGNEE_PostalCode__c;
            consumableReturnOrderTable.ContactId = originOrder.Order_CUST_Id__c;


            //23 08 28 hyungh.chun 반품요청시 반품관련금액 return order 에 넣어주기
            // if(originOrder.PAYMENT_Method_Code__c == 'CARD'){
            //     consumableReturnOrderTable.ReturnCardPaymentAmount = totalPaymentAmt;
            // }else if(originOrder.PAYMENT_Method_Code__c == 'POINT'){
            //     consumableReturnOrderTable.ReturnPointAmount = totalPaymentAmt;
            // }else if(originOrder.PAYMENT_Method_Code__c == 'VBANK'){
            //     consumableReturnOrderTable.ReturnVBankPaymentAmount = totalPaymentAmt;
            // }
            //24 02 26 hyungho.chun 결제방법별로 넣으면 복합결제에 문제생겨서 원주문에 들어간 금액 그대로 찾아서 넣어줌
            consumableReturnOrderTable.ReturnCardPaymentAmount = totalCardAmt;
            consumableReturnOrderTable.ReturnVBankPaymentAmount = totalCashAmt;
            consumableReturnOrderTable.ReturnPointAmount = totalPoiintAmt;
            

            consumableReturnOrderTable.PaymentAmount = totalPaymentAmt;
            consumableReturnOrderTable.ReturnPaymentAmount = totalPaymentAmt;
        }

        mapRequestInfo.put('consumableReturnOrderTable', consumableReturnOrderTable);
        pListMapRequestInfo.add(mapRequestInfo);

        EX_ConsumableUtil.createReturnRequest(pListMapRequestInfo, EX_ConsumableUtil.CONSUMABLE_OBS, 'Return');

        return output;
    }

    /**
    * Input
    */
    global class Input {
        public List<OrderReturn> orderReturn;
    }

//    global class InputBody {
//        public List<OrderReturn> orderReturn;
//    }

    global class OrderReturn {
        public String orderNo;    // '12345'
        public Integer orderSeq;    // 1
        public String originOrderNo; // '12345'
        public Integer originOrderSeq;    // 1
        public String divCode;    //DGZ
        public String partNo;    // ACQ65928302
        public String returnRequestReason; // '테스트'
        // 2023.08.14 seung yoon heo 반품 요청자 추가
        public String isAdmin; // '테스트'
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
        public String orderNo;    // '12345'
        public Integer orderSeq;    // 1
        public String originOrderNo; // '12345'
        public Integer originOrderSeq;    // 1

        public String divCode; // DVZ
        public String partNo;  // EAC63382204

        public String resultCode;    // SUCESS
        public String resultMessage;    // ''
        public String returnRequestReason; // '테스트'
        // 2023.08.14 seung yoon heo 반품 요청자 추가
        public String isAdmin; // '테스트'
    }
}