/**
 * Created by JIEUN on 2023-05-16.
 */
@RestResource(UrlMapping='/v1/api/ma/heroku/CicOrderAlarm')
global with sharing class EX_CicOrderAlarm {

    // =============================================================
    // 인터페이스 Id 값 설정 (SFDC에 ifId를 저장하여 사용)
    // =============================================================
    private static final String IFID    = 'CicOrderAlarm';
    private static final String SUCCESS = 'SUCCESS';
    private static final String ERROR   = 'ERROR';

    global class Input {
        public String ReqType;
        public List<InputBody> params;
        public Input() {
            params = new List<InputBody>();
        }
    }

    global class InputBody {
        public String sfid;
        public String updateDate;
    }

    global class Output{
        public ResultMsg result;
    }

    global class ResultMsg {
        public String rstType;
        public String rstMsg;
    }

    /**
     * @AUTHOR JIEUNSONG
     * date on 2023-05-16.
     */
    @HttpPost
    global static Output doPost(){
        SavePoint sp = Database.setSavepoint();
        String requestBody  = RestContext.request.requestBody.toString();
        String requestHeader = RestContext.request.headers.toString();

        // 로그 시작 (IF_Master에 등록되어 있으며, 로그 적재 여부가 true일 경우에만 쌓임)
        IFUtil ifUtil               = new IFUtil(IFID);
        IFUtil.LogWrapper log       = new IFUtil.LogWrapper(IFID, requestHeader, requestBody);

        System.debug('requestBody :: ' + requestBody);
        Input objInput              = new Input();
        Output objOutput            = new Output();
        InputBody objInputBody      = new InputBody();
        ResultMsg result            = new ResultMsg();

        try{

            objInput = (Input) JSON.deserialize(requestBody, Input.class);
            if((objInput.ReqType!=null && !objInput.ReqType.equals(''))
                    && (!objInput.params.isEmpty() && objInput.params!=null)){
                objOutput = updateCicOrderAlarm(objInput);
            } else {
                result.rstType = 'ERROR';
                result.rstMsg = 'No Input Data .';
                objOutput.result = result;
            }

        } catch (Exception e) {
            Database.rollback(sp);
            System.debug('*** e.getMessage: ' + e.getMessage());
            System.debug('*** e.getLine -> ' + e.getLineNumber());
            result.rstType = 'ERROR';
            result.rstMsg = e.getMessage();
            objOutput.result = result;

        }

        System.debug('objOutput >>> ' + objOutput);

        // =============================================================
        // RESPONSE
        // =============================================================

        log.responseTime            = System.now();
        log.responseBody            = JSON.serialize(objOutput);
        log.status                  = objOutput.result.rstType == 'SUCCESS' ? SUCCESS : ERROR;
        log.errorMessage            = objOutput.result.rstMsg;
        ifUtil.insertLog(log);

        return objOutput;

    }
    /**
     * 요청유형에 따라  발신일시를 업데이트
     * reqType = 'PaymentDelayAlarmDate'       =>    ProductRequest.PaymentDelayAlarmDate__c 업데이트
     * reqType = 'SoldOutAlarmDate'            =>    ProductRequest.SoldOutAlarmDate__c 업데이트
     * reqType = 'DisabledAlarmDate'           =>    ProductRequest.DisabledAlarmDate__c 업데이트
     * reqType = 'SoldOutReceivingAlarmDate'   =>    ProductRequestLineItem.SoldOutReceivingAlarmDate__c 업데이트
     * reqType = 'ReturnConfirmAlarmDate'      =>    ReturnOrderLineItem.ReturnConfirmAlarmDate__c 업데이트
     * */

    global static Output updateCicOrderAlarm(Input objInput){
        System.debug('===========START=========== ');
        System.debug('updateCicOrderAlarm >> ');
        Output output = new Output();
        ResultMsg result = new ResultMsg();
        List<InputBody> inputList = new List<inputBody>();
        inputList = objInput.params;
        System.debug('inputBody check  >> ');
        System.debug('inputList :: ' + inputList);
        String reqType = objInput.ReqType;
        System.debug('reqType :: ' + reqType);


        List<Map<String, String>> inputBodyMapList = new List<Map<String, String>>();
        List<Id> sfIdList = new List<Id>();


        for(InputBody ib : inputList){
            Map<String, String> inputBodyMap = new Map<String, String>();
            inputBodyMap.put('sfId', ib.sfid);
            inputBodyMap.put('updateDate', ib.updateDate); //DateTime 으로 들어오는지 String으로 들어오는지 체크 , 현재는 String으로 가정
            inputBodyMapList.add(inputBodyMap);
        }

        System.debug('inputBodyMapList :: ' + inputBodyMapList);
        List<ProductRequest> updatePRList = new List<ProductRequest>();
        List<ProductRequestLineItem> updatePRLIList = new List<ProductRequestLineItem>();
        List<ReturnOrderLineItem> updateROLIList = new List<ReturnOrderLineItem>();

        if(!inputBodyMapList.isEmpty()){
            if(reqType=='PaymentDelayAlarmDate'){
                for(Map<String,String> param : inputBodyMapList){
                    if(param.get('sfId') != null && param.get('updateDate') != null){
                        String paramSfid = '';
                        paramSfid = param.get('sfId');
                        ProductRequest updatePr = new ProductRequest();
                        updatePr.Id = paramSfid;
                        updatePr.PaymentDelayAlarmDate__c = Date.valueOf(param.get('updateDate').removeEnd('00:00:00'));
                        updatePRList.add(updatePr);
                    }
                }
            }
            //reqType = 'SoldOutAlarmDate'
            else if(reqType=='SoldOutAlarmDate'){
                for(Map<String,String> param : inputBodyMapList){
                    if(param.get('sfId') != null && param.get('updateDate') != null){
                        String paramSfid = '';
                        paramSfid = param.get('sfId');
                        ProductRequest updatePr = new ProductRequest();
                        updatePr.Id = paramSfid;
                        updatePr.SoldOutAlarmDate__c = Date.valueOf(param.get('updateDate').removeEnd('00:00:00'));
                        updatePRList.add(updatePr);
                    }
                }
            }
            //reqType = 'DisabledAlarmDate'
            else if(reqType=='DisabledAlarmDate'){
                for(Map<String,String> param : inputBodyMapList){
                    if(param.get('sfId') != null && param.get('updateDate') != null){
                        String paramSfid = '';
                        paramSfid = param.get('sfId');
                        ProductRequest updatePr = new ProductRequest();
                        updatePr.Id = paramSfid;
                        updatePr.DisabledAlarmDate__c = Date.valueOf(param.get('updateDate').removeEnd('00:00:00'));
                        updatePRList.add(updatePr);
                    }
                }
            }
            //reqType = 'SoldOutReceivingAlarmDate'
            else if(reqType=='SoldOutReceivingAlarmDate'){
                for(Map<String,String> param : inputBodyMapList){
                    if(param.get('sfId') != null && param.get('updateDate') != null){
                        String paramSfid = '';
                        paramSfid = param.get('sfId');
                        ProductRequestLineItem updatePrli = new ProductRequestLineItem();
                        updatePrli.Id = paramSfid;
                        updatePrli.SoldOutReceivingAlarmDate__c = Date.valueOf(param.get('updateDate').removeEnd('00:00:00'));
                        updatePRLIList.add(updatePrli);
                    }
                }
            }
            //reqType = 'ReturnConfirmAlarmDate'
            else if(reqType=='ReturnConfirmAlarmDate'){
                for(Map<String,String> param : inputBodyMapList){
                    if(param.get('sfId') != null && param.get('updateDate') != null){
                        String paramSfid = '';
                        paramSfid = param.get('sfId');
                        ReturnOrderLineItem updateRoli = new ReturnOrderLineItem();
                        updateRoli.Id = paramSfid;
                        updateRoli.ReturnConfirmAlarmDate__c = Datetime.valueOf(param.get('updateDate'));  //DateTime
                        updateROLIList.add(updateRoli);
                    }
                }
            }

            //ReqType = 'PaymentDelayAlarmDate' or 'SoldOutAlarmDate' or 'DisabledAlarmDate' 일 경우
            if(!updatePRList.isEmpty()){
                update updatePRList;
                result.rstType = 'SUCCESS';

            }
            //ReqType = 'SoldOutReceivingAlarmDate' 경우
            if(!updatePRLIList.isEmpty()){
                update updatePRLIList;
                result.rstType = 'SUCCESS';

            }
            //ReqType = 'ReturnConfirmAlarmDate' 경우
            if(!updateROLIList.isEmpty()){
                update updateROLIList;
                result.rstType = 'SUCCESS';

            }

            if(updatePRList.isEmpty() && updatePRLIList.isEmpty() &&updateROLIList.isEmpty()){
                result.rstType = 'FAIL';
                result.rstMsg = '조회된 항목이 없습니다.';
            }
            output.result = result;

        }
        System.debug('output >>> ' + output);
        System.debug('===========END=========== ');
        return output;

    }
}