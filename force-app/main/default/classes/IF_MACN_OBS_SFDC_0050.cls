/**
 * Created by A81292 on 2023-02-24.
 * Order Cancelable YN
 * 1. OBS의 주문건의 취소 가능 여부 요청을 수신
2. 주문 건의 취소 가능 상태(CJ 전송 이전)를 확인하여 회신한다..
 */
@RestResource(UrlMapping='/v1/api/ma/obs/IF_MACN_OBS_SFDC_0050')
global with sharing class IF_MACN_OBS_SFDC_0050 {

    // =============================================================
    // 인터페이스 Id 값 설정 (SFDC에 ifId를 저장하여 사용)
    // =============================================================
    private static final String IFID    = 'IF-NEW-506';
    private static final String SUCCESS = 'SUCCESS';
    private static final String ERROR   = 'ERROR';

    global class Input{
        public InputBody Body;
        public Input(){
            Body = new InputBody();
        }
    }

    global class InputBody{
        public List<InputDetail> orderCancel;
        public InputBody(){
            orderCancel = new List<InputDetail>();
        }
    }

    global class InputDetail{
        public String orderNo;
        public Integer orderSeq;
        public String systemKey;
    }

    global class Output{
        public ResultMsg header;
        public OutputBody body;
        public Output(){
            body = new OutputBody();
        }
    }

    global class OutputBody{
        List<OutputData> data;
        public OutputBody(){
            data = new List<OutputData>();
        }
    }

    global class OutputData{
        public String orderNo;
        public Decimal orderSeq;
        public String systemKey;
        public String cancelableYn;
        public String resultMessage;
        public String deliveryCode;
        public String deliveryNo;
    }

    global class ResultMsg{
        public String code;
        public String message;
    }

    @HttpPost
    global static Output doPost(){
        Output objOutput = new Output();
        OutputBody objOutputBody = new OutputBody();
        ResultMsg result = new ResultMsg();

        RestRequest request =  RestContext.request;
        String requestBody = request.requestBody.toString();
        String requestHeader = request.headers.toString();

        // 로그 시작 (IF_Master에 등록되어 있으며, 로그 적재 여부가 true일 경우에만 쌓임)
        IFUtil ifUtil               = new IFUtil(IFID);
        IFUtil.LogWrapper log       = new IFUtil.LogWrapper(IFID, requestHeader, requestBody);

        try{

            if(requestBody != null && requestBody !=''){
                Input objInput = (Input)JSON.deserializeStrict(requestBody, Input.class);
                objOutput= retrieveOnlineObsOrderCancelCmd(objInput);
                //objOutput.body =objOutput.body;
                result.code ='200';
                result.message = '정상적으로 조회되었습니다 ';
            }
        } catch (JSONException je){
            result.code = '500';
            result.message = 'reason :: ' + je.getMessage();
        } catch (NullPointerException ne){
            result.code = '500';
            result.message = ' 조회된 값이 없습니다. '+ne.getMessage();
        } catch (Exception e){
            result.code = '500';
            result.message = e.getMessage();
        }
        objOutput.header = result;

        // =============================================================
        // RESPONSE
        // =============================================================

        log.responseTime            = System.now();
        log.responseBody            = JSON.serialize(objOutput);
        log.status                  = objOutput.header.code == '200' ? SUCCESS : ERROR;
        log.errorMessage            = objOutput.header.message;
        ifUtil.insertLog(log);

        return objOutput;

    }

    global static Output retrieveOnlineObsOrderCancelCmd(Input objInput){
        Output output  = new Output();
        Set<String> setOrderNo = new Set<String>();
        Set<Decimal> setOrderSeq = new Set<Decimal>();
        String orderNo;
        Decimal orderSeq;
        String systemKey;

        List<InputDetail> inputList = new List<InputDetail>();
        inputList = objInput.Body.orderCancel;

        for(InputDetail input : inputList){
            orderNo = input.orderNo;
            orderSeq = input.orderSeq;
            setOrderNo.add(orderNo);
            setOrderSeq.add(orderSeq);

        }

        List<ProductRequestLineItem> resultList = new List<ProductRequestLineItem>();
        String query='';
        query +=' SELECT Id, Order_Number__c, Order_SEQ__c, ';
        query +=' Consumables_Order_Status__c, CANCEL_Reason__c, DELIVERY_CODE__c, INVOICE_Number__c,  ';
        query +=' SALE_Number__c   ';
        query +=' FROM ProductRequestLineItem ';
        query +=' WHERE Order_Number__c = :setOrderNo ';
        query +=' AND Order_SEQ__c = : setOrderSeq  ';
        resultList = Database.query(query);
        System.debug( '>> resultList ' + resultList);
        List<OutputData>outputDataList = new List<OutputData>();


        if(resultList.isEmpty()){
            output.header.code='500';
            output.header.message = '조회된 값이 없습니다. ';
        } else {
           for(ProductRequestLineItem item : resultList) {
                OutputData outputData = new OutputData();
               outputData.orderNo = item.Order_Number__c;
               outputData.orderSeq = item.Order_SEQ__c;
               outputData.deliveryCode = item.DELIVERY_CODE__c;
               outputData.systemKey='LGEKR50MKT'; //키값은 API정의서에서 예시 request에서 들고옴
                //outputData.deliveryNo = item.INVOICE_Number__c;

                if( item.SALE_Number__c != null ){
                    outputData.cancelableYn = 'N';
                    outputData.deliveryNo = item.INVOICE_Number__c;
                    outputData.resultMessage = '판매처리 되었습니다. ';

                } else if(item.Consumables_Order_Status__c =='004'){
                    outputData.cancelableYn = 'N';
                    outputData.deliveryNo = item.INVOICE_Number__c;
                    outputData.resultMessage = '취소된 내역입니다. ';
                } else if (item.INVOICE_Number__c != null){
                    outputData.cancelableYn = 'N';
                    outputData.deliveryNo = item.INVOICE_Number__c;
                    outputData.resultMessage = '송장번호가 발행되었습니다. ';
                } else {
                    outputData.cancelableYn = 'Y';
                    outputData.resultMessage=null;
                    outputData.deliveryNo=null;
                }

               outputDataList.add(outputData);
                System.debug( '>> outputDataList '+ outputDataList);
                //outputDetail.data = orderDatList;

            }
            output.body.data = outputDataList;
            System.debug( 'output!! :: ' + output);
        }


            return output;
    }
}