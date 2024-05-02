/**
 * Created by JIEUNSONG on 2023-02-22.
 * OBS -> SFDC 재고정보를 송수신
 */

@RestResource(UrlMapping='/v1/api/ma/obs/IF_MACN_OBS_SFDC_0020')
global with sharing class IF_MACN_OBS_SFDC_0020 {

    // =============================================================
    // 인터페이스 Id 값 설정 (SFDC에 ifId를 저장하여 사용)
    // =============================================================
    private static final String IFID    = 'IF-NEW-501';
    private static final String SUCCESS = 'SUCCESS';
    private static final String ERROR   = 'ERROR';

    global class Input{
        public List<InputBody> orderItem;
    }

    global class InputBody{
        public String divCode;      //사업부코드
        public String partNo;       //PART_NO
    }

    global class Output {
        public ResultMsg header;
        public OutputBody body;
        public Output(){
            body = new OutputBody();
        }
    }

    global class OutputBody {
        List<OutputData> data;
        public OutputBody(){
            data = new List<OutputData>();
        }
    }

    global class OutputData{
        public String divCode;      //사업부코드
        public String partNo;       //PART_NO
        public Decimal availQty;    //가용수량
        //public Decimal custPrice;   //소비자가
        //public Decimal ascPrice;    //ASC단가
        public String disabledDt;   //단종일자
    }

    global class ResultMsg {
        public String code;
        public String message;
        public Integer dataCount;
    }
    @HttpPost
    global static Output doPost(){
        RestRequest request = RestContext.request;
        String requestBody = request.requestBody.toString();
        String requestHeader = request.headers.toString();

        // 로그 시작 (IF_Master에 등록되어 있으며, 로그 적재 여부가 true일 경우에만 쌓임)
        IFUtil ifUtil               = new IFUtil(IFID);
        IFUtil.LogWrapper log       = new IFUtil.LogWrapper(IFID, requestHeader, requestBody);


        Output objOutput = new Output();
        OutputBody objOutputBody = new OutputBody();
        ResultMsg result = new ResultMsg();
        try{
            System.debug('requestBody :: ' + requestBody);
            //todo divCode나 partNo가 하나랃없을때는 에러
            if(requestBody != null && requestBody !=''){
                Input objInput = (Input)JSON.deserializeStrict(requestBody,Input.class);
                objOutput = retrieveOnlineObsStockQty(objInput);
                //objOutputBody = retrieveOnlineObsStockQty(objInput);
                //objOutput.body = objOutputBody;
                result.code = '200';
                result.message = '정상적으로 조회되었습니다 ';
                result.dataCount = objOutput.body.data.size();
            }
        } catch (JSONException je) {
            result.code = '500';
            result.message = 'reason :: ' + je.getMessage() + ', line:' + je.getLineNumber();
        } catch (NullPointerException ne){
            result.code = '500';
            result.message = ' 조회된 값이 없습니다.  '+ ne.getMessage() + ', line:' + ne.getLineNumber();
        } catch (Exception e){
            result.code = '500';
            result.message = e.getMessage() + ', line:' +e.getLineNumber();
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
    global static Output retrieveOnlineObsStockQty(Input objInput){
        Output output = new Output();
        OutputBody outputBody = new OutputBody();
        String divCode;
        String partNo;

        List<InputBody> inputList = new List<InputBody>();
        inputList=objInput.orderItem;

        List<String> divCodeList = new List<String>();
        List<String> partNoList = new List<String>();

        for(InputBody input : inputList){
            divCode = input.divCode;
            partNo = input.partNo;
            divCodeList.add(divCode);
            partNoList.add(partNo);
        }

        List<ProductItem> centerProductItems = new List<ProductItem>();
        //23.12.18 gw.lee
        //사업부 재고 추가
        //24.01.10 gw.lee
        //단종이 경우, 사업부 재고 0 로직 추가
        centerProductItems = [SELECT Id, DIV_CODE__c, fm_Parts_Number__c, fm_Available_Quantity__c, fm_DEPT_CODE__c, LocationId, 
                Location.RecordType.DeveloperName, QuantityOnHand, ORDER_QTY__c,
                Product2.Name, Product2.CUST_PRICE__c, Product2.ASC_PRICE__c, Product2.THINQ_ITEM_YN__c, Product2.DISABLED_DT__c, Product2.DISABLED_TYPE__c 
                FROM ProductItem
                WHERE product2.THINQ_ITEM_YN__c= 'Y'
                AND DIV_CODE__c IN :divCodeList
                AND Product2.Name IN :partNoList
                AND location.RecordType.DeveloperName IN ('DIV','Location')
                AND (fm_DEPT_CODE__c = NULL OR (fm_DEPT_CODE__c = 'PH8002' AND location.name = :System.Label.EX_Location))];

        List<OutputData> outputDataList= new List<OutputData>();

        if(divCodeList.isEmpty() || partNoList.isEmpty()){
            system.debug('param error');
            output.header.code='500';
            output.header.message='param error';
            return output;
        }

        if(!centerProductItems.isEmpty()){
            for(InputBody input : inputList){
                String inputDivCode = input.divCode;
                String inputPartNo = input.partNo;
                List<ProductItem> piList = new List<ProductItem>();
                for(ProductItem sfdcPi : centerProductItems) {
                    if(sfdcPi.DIV_CODE__c == inputDivCode && sfdcPi.Product2.Name == inputPartNo){
                        piList.add(sfdcPi);
                    }
                }
                if(!piList.isEmpty()){
                    ProductItem pi = piList[0];
                    OutputData data = new OutputData();
                    if(pi.product2.DISABLED_DT__c != null){
                        Datetime disabledt = Date.valueOf(pi.Product2.DISABLED_DT__c);
                        String Tdate = disabledt.formatGMT('YYYYMMdd');
                        data.disabledDt = Tdate;
                    }
                    data.divCode = pi.DIV_CODE__c;
                    data.partNo = pi.fm_Parts_Number__c;
                    Integer total = 0;
                    for(ProductItem pis : piList){
                        if (pis.Location.RecordType.DeveloperName == 'DIV') {
                            Integer divQty = Integer.valueOf(pis.QuantityOnHand) - Integer.valueOf(pis.ORDER_QTY__c) < 0 ? 0 : Integer.valueOf(pis.QuantityOnHand) - Integer.valueOf(pis.ORDER_QTY__c);
                            //24.01.10 gw.lee
                            //사업부 단종일 경우, 사업부 가용재고 0표기
                            if (pis.Product2.DISABLED_TYPE__c != null) {
                                divQty = 0;
                            }
                            total += divQty;
                        } else {
                            if(pis.fm_Available_Quantity__c != null){
                                total += Integer.valueOf(pis.fm_Available_Quantity__c);
                            }
                        }
                    }
                    data.availQty = total;
                    //가용수량이 0이하일 경우 0으로 보냄
                    if(data.availQty<0){
                        data.availQty = 0;
                    }
                    outputDataList.add(data);
                }
            }
            output.body.data = outputDataList;

            System.debug( 'outputBody :: ' +outputBody);
        } else {
            output.header.code = '500';
            output.header.message = '조회된 값이 없습니다.';
        }

        // return outputBody;
        return output;
    }

}