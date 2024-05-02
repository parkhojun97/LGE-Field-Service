/**
 * Created by I2MAX.SEOKHOLEE on 2023-03-26.
 */
@RestResource(UrlMapping='/v1/api/ma/obs/IF_MACN_OBS_SFDC_0030')

global without sharing class IF_MACN_OBS_SFDC_0030 {
    // =============================================================
    // 인터페이스 Id 값 설정 (SFDC에 ifId를 저장하여 사용)
    // =============================================================
    private static final String IFID    = 'IF-NEW-504';
    private static final String SUCCESS = 'SUCCESS';
    private static final String ERROR   = 'ERROR';

    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        String requestBody = request.requestBody.toString();
        String requestHeader = request.headers.toString();

        RestResponse response = RestContext.response;

        // 로그 시작 (IF_Master에 등록되어 있으며, 로그 적재 여부가 true일 경우에만 쌓임)
        IFUtil ifUtil               = new IFUtil(IFID);
        IFUtil.LogWrapper log       = new IFUtil.LogWrapper(IFID, requestHeader, requestBody);

        OutputHeader header = new OutputHeader();

        OutputBody body = new OutputBody();
        body.data = new List<IF_MACN_OBS_SFDC_0030.Data>();

        Boolean isSuccessFlag = true;
        Input objInput = new Input();
        Output objOutput = new Output();

        Savepoint sp = Database.setSavepoint();
        try {

            System.debug('============================================');
            System.debug('======= LGE.COM 주문취소 요청 I/F =======');
            System.debug('IF_MACN_OBS_SFDC_0030');
            System.debug('requestBody -> ' + requestBody);
            System.debug('requestHeader -> ' + requestHeader);
            System.debug('============================================');

            if (requestBody != null && requestBody != '') {
                objInput = (Input) JSON.deserialize(requestBody, Input.class);

                objOutput = createConsumableOrderCancelFromOBS(objInput);
            }

        } catch (Exception e) {
            Database.rollback(sp);

            isSuccessFlag = false;
            header.code = '500';
            header.message = e.getMessage();
            System.debug(e.getMessage() + ', LineNumber:' + e.getLineNumber());
            objOutput.Header = header;
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

    public static Output createConsumableOrderCancelFromOBS(Input objInput) {
        Output output = new Output();
        output.Header = new OutputHeader();

        output.Body = new IF_MACN_OBS_SFDC_0030.OutputBody();
        output.Body.data = new List<IF_MACN_OBS_SFDC_0030.Data>();

        // 1. 주문 번호 및 주문 항번 존재여부 체크
        // 2. CJ 전송여부 체크
        // 3. 판매처리 여부 및 송장여부 체크

        // 4. 약속번호 존재 여부 체크 // 존재 시 약속취소 처리
        // 4-1. 약속번호 존재 O : 약속 취소 처리,약속 수량 원복
        // 4-2. 약속번호 존재 X : 할당 수량 원복

        // 5. 주문취소 처리

        //InputBody objInputBody = objInput.body;
        List<IF_MACN_OBS_SFDC_0030.OrderCancel> objorderCancel = objInput.orderCancel;

        Boolean isSuccessFlag = true;

       
        
        try {

            IF_MACN_OBS_SFDC_0030.Data outputData;
            Map<String, Map<String, IF_MACN_OBS_SFDC_0030.OrderCancel>> orderNumberItemKeyMap = new Map<String, Map<String, IF_MACN_OBS_SFDC_0030.OrderCancel>>();
             // 2023.08.12 seung yoon heo 주문 취소 사유 추가
            Map<String, String> orderCancelMap = new Map<String, String>();
            // 2023.08.21 seung yoon heo part no 기준으로 부분 취소 추가
            Map<String, Boolean> parNoMap = new Map<String, Boolean>();

            for (IF_MACN_OBS_SFDC_0030.orderCancel item : objorderCancel) {
                outputData = new IF_MACN_OBS_SFDC_0030.Data();
                outputData.orderNo = item.orderNo;
                outputData.partNo = item.partNo;
                outputData.orderSeq = String.valueOf(item.orderSeq);
                outputData.divCode = item.divCode;

                outputData.deliveryCode = '';
                outputData.deliveryNo = '';
                outputData.salseNo = '';
                outputData.resultCode = '';

                output.Body.data.add(outputData);
                
                String itemKey = item.orderSeq + '_' + item.divCode + '_' + item.partNo;
                if (orderNumberItemKeyMap.containsKey(item.orderNo)) {
                    orderNumberItemKeyMap.get(item.orderNo).put(itemKey, item);
                } else {
                    orderNumberItemKeyMap.put(item.orderNo, new Map<String, IF_MACN_OBS_SFDC_0030.OrderCancel>{
                            itemKey => item
                    });
                }

                // 2023.08.12 seung yoon heo 주문 취소 사유 추가
                orderCancelMap.put('cancelRequestReason' , item.cancelRequestReason);
                orderCancelMap.put('isAdmin' , item.isAdmin);
                // 2023.08.21 seung yoon heo part no 기준으로 부분 취소 추가
                parNoMap.put(item.partNo ,  true);
            }

            // 주문 조회

            // 23-07-12 DKBMC 전형호 수정
            // RSRV_SEQ__c,Adjust_Quantity__c 조회 필요한 필드 추가로 RSRV_SEQ__c,Adjust_Quantity__c 추가
            // 2023.08.21 seung yoon heo part no 기준으로 부분 취소 추가 Product2.Name 추가
            List<ProductRequest> consumableOrders = [
                    SELECT Id, Order_Number__c, RESRV_Number__c, SR_RSRV_PART_Id__c, SALE_Number__c, SR_SALE__c, (
                            SELECT Id, Order_SEQ__c, Consumables_Order_Status__c, Appointment_Status__c, ENDP_RSV_Quantity__c, SALE_Quantity__c,
                                    SourceLocationId, DestinationLocationId,  Product2.DIV_CODE__c, Product2.ProductCode,
                                    ParentId, Parent.RESRV_Number__c, Parent.SR_RSRV_PART_Id__c, Parent.SALE_Number__c, Parent.SR_SALE__c,RSRV_Number__c,
                                    QuantityRequested, FFMT_Order_Transfer_YN__c, CJ_SHIPPED_STOP_YN__c,RSRV_SEQ__c,Adjust_Quantity__c , Product2.Name,
                                    SR_RESRV_PART_Id__r.RESRV_Number__c , CANCEL_Reason__c
                            FROM ProductRequestLineItems
                    )
                    FROM ProductRequest
                    WHERE Order_Number__c IN :orderNumberItemKeyMap.keySet()
            ];

            if (consumableOrders.isEmpty()) {
                isSuccessFlag = false;
                output.header.code = '500';
                output.header.message = '주문번호가 존재하지 않습니다. ';
                return output;
            }

            // 주문 / 항번 검증
            Boolean isValid = true;
            Map<String, IF_MACN_OBS_SFDC_0030.OrderCancel> pridOrderItemMap = new Map<String, IF_MACN_OBS_SFDC_0030.OrderCancel>();
//            for (ProductRequest co : consumableOrders) {
//                Integer coItemSize = co.ProductRequestLineItems.size();
//                Integer itemSize = orderNumberItemKeyMap.get(co.Order_Number__c).size();
//                Integer validItemSize = 0;
//                Map<String, IF_MACN_OBS_SFDC_0030.OrderCancel> orderItemMap = orderNumberItemKeyMap.get(co.Order_Number__c);
//
//                for (ProductRequestLineItem coItem : co.ProductRequestLineItems) {
//                    String coItemKey = coItem.Order_SEQ__c + '_' + coItem.Product2.DIV_CODE__c + '_' + coItem.Product2.ProductCode;
//                    for (String key : orderItemMap.keySet()) {
//                        IF_MACN_OBS_SFDC_0030.OrderCancel item = orderItemMap.get(key);
//                        String itemKey = item.orderSeq + '_' + item.divCode + '_' + item.partNo;
//                        if (itemKey == coItemKey) {
//                            pridOrderItemMap.put(coItem.Id, orderItemMap.get(itemKey));
//                            validItemSize += 1;
//                        }
//
//                    }
//                }
//
//                if (validItemSize != coItemSize || validItemSize != itemSize || coItemSize != itemSize) {
//                    isValid = false;
//                    output.header.code = '500';
//                    output.header.message = '주문 품목이 유효하지 않습니다.';
//                    return output;
//                }
//            }

            // 230516 / CJ 전송 여부 검증
            for (ProductRequest co : consumableOrders) {
                for (ProductRequestLineItem coItem : co.ProductRequestLineItems) {
                    // CJ 출고 중지인 경우
                    if(!Test.isRunningTest() && coItem.CJ_SHIPPED_STOP_YN__c == true) continue;

                    // CJ 전송 여부 True 인 경우
                    if(!Test.isRunningTest() && coItem.FFMT_Order_Transfer_YN__c == true) {
                        isSuccessFlag = false;
                        output.header.code = '500';
                        output.header.message = '해당 주문은 CJ로 전송되어 주문취소가 불가능 합니다.';
                        return output;
                    }
                }
            }


            Set<String> prliIdSet = new Set<String>();
            if (isValid) {
                for (ProductRequest co : consumableOrders) {
                    // 판매정보 여부 검증
                    if (co.SALE_Number__c != null || co.SR_SALE__c != null) {
                        isSuccessFlag = false;
                        output.header.code = '500';
                        output.header.message = '해당 주문의 판매번호가 이미 존재합니다. ' + co.SALE_Number__c;
                        return output;
                    }

                    for (ProductRequestLineItem coitem : co.ProductRequestLineItems) {
                        prliIdSet.add(coitem.Id);
                    }
                }
            }




            Map<String, SR_ONLINE_DELIVERY_INFO__c> prliDeliveryInfoMap = new Map<String, SR_ONLINE_DELIVERY_INFO__c>();
            List<SR_ONLINE_DELIVERY_INFO__c> deliveryInfos = [
                    SELECT Id, DELIVERY_CODE__c, DELIVERY_NO__c, ProductRequestLineItem__c
                    FROM SR_ONLINE_DELIVERY_INFO__c
                    WHERE ProductRequestLineItem__c IN :prliIdSet
            ];
            for (SR_ONLINE_DELIVERY_INFO__c di : deliveryInfos) {
                prliDeliveryInfoMap.put(di.ProductRequestLineItem__c, di);
            }

            // 배송정보 여부 검증
            for (ProductRequest co : consumableOrders) {
                for (ProductRequestLineItem coItem : co.ProductRequestLineItems) {
                    if (prliDeliveryInfoMap.containsKey(coItem.Id)) {
                        isSuccessFlag = false;
                        output.header.code = '500';
                        output.header.message = '해당 주문의 배송정보가 이미 존재합니다. ' + prliDeliveryInfoMap.get(coItem.Id).DELIVERY_NO__c;
                        return output;
                    }
                }
            }



       

            List<ProductRequestLineItem> updatePrliList = new List<ProductRequestLineItem>();
            List<Map<String, Object>> rsrvCancelMapList = new List<Map<String, Object>>();
            for (ProductRequest co : consumableOrders) {
                for (ProductRequestLineItem coitem : co.ProductRequestLineItems) {
                    // 2023.08.21 seung yoon heo part no 기준으로 부분 취소 추가
                    if (parNoMap.get(coitem.Product2.Name) != null && parNoMap.get(coitem.Product2.Name)) {
                        Map<String, Object> rsrvCancelMap = new Map<String, Object>();
                        // 예약건이 있는 경우
                        if (coItem.SR_RESRV_PART_Id__c != null) {
                            //사업부입고수량 = 요청수량 확인 ProductRequestLineItem > ENDP_RSV_Quantity__c = QuantityRequested
                            if (coItem.ENDP_RSV_Quantity__c != null && coItem.QuantityRequested != null && coItem.ENDP_RSV_Quantity__c == coItem.QuantityRequested) {
                                System.debug('약속취소(예약취소)(약속정리)');
                                /** 약속취소(예약취소)(약속정리) */
                                //EX_RsrvUtil.CANCEL_RESRV(coItem, 'AE'); //'AE' : 사업부약속취소(재입고알림)
                                rsrvCancelMap.put('ProductRequestLineItem',coItem);
                                rsrvCancelMap.put('code','AE');
                                rsrvCancelMapList.add(rsrvCancelMap);
                            } else {
                                //입고안됨
                                if(coItem.ENDP_RSV_Quantity__c == null) coItem.ENDP_RSV_Quantity__c = 0;
                                //EX_RsrvUtil.CANCEL_RESRV(coItem, 'AD'); //'AD' : 사업부약속취소(미입고상태)
                                rsrvCancelMap.put('ProductRequestLineItem',coItem);
                                rsrvCancelMap.put('code','AD');
                                rsrvCancelMapList.add(rsrvCancelMap);
                            }
                        } else {
                            /** 할당수량 감소 재고 공통모듈 호출 */
                            EX_RsrvUtil.execApplyProductItem(coitem.QuantityRequested, 'AB', coitem); //AB 할당(-) 소모품주문취소
                        }

                        coitem.Consumables_Order_Status__c = EX_ConsumableUtil.CONSUMABLE_ORDER_STATUS_004;
                        coitem.CANCEL_Quantity__c = coitem.SALE_Quantity__c;
                        coitem.SALE_Quantity__c = 0;
                        coitem.CANCEL_Date__c = System.today();
                        coitem.CANCEL_Request_DTM__c = System.now();
                        // 23-07-12 DKBMC 전형호 수정
                        // 'CANCEL_User__c' 필드에 'interface_ivr' 값 -> 공란 처리 수정
                        // coitem.CANCEL_User__c = UserInfo.getName();

                        // 2023.08.12 seung yoon heo 주문 취소 사유 추가
                        if (orderCancelMap.get('isAdmin') != null && orderCancelMap.get('isAdmin') == 'N') {
                            coitem.CANCEL_Reason__c = orderCancelMap.get('cancelRequestReason') != null ? '(고객) ' + orderCancelMap.get('cancelRequestReason') : '';
                        }else if(orderCancelMap.get('isAdmin') == 'Y'){
                            coitem.CANCEL_Reason__c = orderCancelMap.get('cancelRequestReason') != null ? '(관리자) ' +  orderCancelMap.get('cancelRequestReason') : '';
                        }
                        
                        
                        updatePrliList.add(coItem);
                    }
                }
            }
            if(!rsrvCancelMapList.isEmpty()){
                EX_RsrvUtil.CANCEL_RESRV_MULTI(rsrvCancelMapList);
            }
            if(!updatePrliList.isEmpty()) {
                update updatePrliList;
            }


        } catch (Exception e) {
            isSuccessFlag = false;
            output.header.code = '500';
            output.header.message = e.getMessage();
            System.debug(e.getMessage() + ', LineNumber:' + e.getLineNumber());
        }
        if (isSuccessFlag) {
            output.header.code = '200';
            output.header.message = '정상적으로 취소요청 되었습니다.';
        }
        return output;
    }

    /**
    * Input
    */
    global class Input {
        List<IF_MACN_OBS_SFDC_0030.orderCancel> orderCancel;
    }

//    global class InputBody {
//        public List<IF_MACN_OBS_SFDC_0030.OrderItem> orderItem;
//    }

    global class orderCancel {
        public String orderNo;    //1234567890
        public Integer orderSeq;    //1
        public String divCode;    //DGZ
        public String partNo;    //ACQ65928302
        // 2023.08.12 seung yoon heo 주문 취소 사유 추가
        public String cancelRequestReason; // "";
        public String isAdmin; // "";
                
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
        public String partNo;  // EAC63382204
        public String divCode; // DVZ
        public String resultCode;    //SUCESS
        public String salseNo; // "";
        public String deliveryCode; // "";
        public String deliveryNo; // "";
    }
}