/**
 * Created by A81292 on 2023-03-03.
 * SFDC에서 전시품목정보 제공을 요청하면, OBS에서 전시품목정보를 리턴한다.
 * IF-NEW-544
 *
 */
global with sharing class IF_MACN_OBS_SFDC_0120 {
    private static String ifId= 'IF-NEW-544';

    global class Input {
        //public Map<String, Object> Header;
        public InputBody Body;
        public Input() {
            body = new InputBody();
        }
    }

    global class InputBody {
        public List<InputData> data;
        public InputBody() {
            data = new List<InputData>();
        }
    }

    global class InputData {
        String partNo;
        String divCode;
    }

    global class Output {

        public ResultMsg Header;
        public OutputBody Body;
        public Output() {
            Body = new OutputBody();
        }
    }

    global class OutputBody {
        public List<OutputData> data;
        public OutputBody() {
            data = new List<OutputData>();
        }
    }

    global class OutputData {
        String partNo;
        String divCode;
        String PartNameKor;
        String ObsSalesYN;
        String ObsSalesURL;
        String ObsImageURL;
        Integer ObsMemberPrice; //OBS 회원 판매가(5% 할인 적용가격)

    }

    global class ResultMsg {
        public String rstType;
        public String rstMsg;
        public Integer dataCount;
    }


    /**
     * @param divCodePartNoList 전시판매정보 조회 시 다건 조회
     *
     * @return
     */
    public static List<Map<String, String>> getObsSalesInfoList(Set<String> divCodePartNoKeySet) {
        // divCodePartNoKeySet : divCode + '_' + partNo
        Output objOutput = new Output();
        Input objInput = new Input();

        String divCode = '';
        String partNo = '';
        List<inputData> inputDataList = new List<inputData>();
        for (String divCodePartNoKey : divCodePartNoKeySet) {
            List<String> keyList = divCodePartNoKey.split('_');
            if(keyList.size() > 1){
                divCode = keyList[0];
                partNo = keyList[1];
                if(divCode != null && partNo != null) {
                    InputData inputData = new InputData();
                    inputData.divCode = divCode;
                    inputData.partNo = partNo;
                    inputDataList.add(inputData);
                }
            }
        }
        objInput.body.data = inputDataList;

        System.debug('objInput :: ' + objInput);


        IFUtil ifUtil = new IFUtil(ifId);
        IF_Master__c objMaster = ifUtil.objMaster;
        IFUtil.LogWrapper log = new IFUtil.LogWrapper();
        List<IFUtil.LogWrapper> logList = new List<IFUtil.LogWrapper>();
        log.ifId = ifId;
        Datetime requestTime = System.now();
        String resStatus = 'SUCCESS';
        String errorMsg = '';


        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String responseBody = '';

        //EndPoint 지정
        //String apiURL = 'https://dev-apigw-ext.lge.com:7221/gateway/lgekr50mkt/api2api/api/product/retrieveDisposableModelInfo';
        
        request.setMethod(objMaster.Method__c);
        request.setEndpoint(objMaster.Endpoint__c);
        request.setheader('x-Gateway-APIKey', 'e783d29a-a6f0-41c2-a853-e88e2f6c7109');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Logger', 'DEBUG');
        //23.09.12 gw.lee
        //Region이동 처리 작업
        HF_HttpCalloutOrgCache.APIMAuthInfo apimAuthInfo = HF_HttpCalloutSender.auth();
        request.setHeader('Authorization', 'Bearer ' +  apimAuthInfo.access_token);

        //23.09.19 gw.lee
        //Region이동 처리 작업
        if (objMaster.APIKeyValue__c != null) {
            request.setHeader('x-apiKey', 'B2uxz2Isi4drpvJUixXDLaHAfCDx2dJQ');
        }

        System.debug('x-Gateway-APIKey :::: ' + request.getHeader('x-Gateway-APIKey'));
        System.debug('Content-Type :::: ' + request.getHeader('Content-Type'));
        System.debug('Logger :::: ' + request.getHeader('Logger'));
        System.debug('Authorization :::: ' + request.getHeader('Authorization'));
        System.debug('x-apiKey :::: ' + request.getHeader('x-apiKey'));

        System.debug('objMaster.APIKeyValue__c :::: ' + objMaster.APIKeyValue__c);

        

        //request.setHeader('Authorization','Bearer gfddgz43yzohs4v62ufwbcd5ig6kyq6w');
        //request.setBody('{ "Body": { "data" : [{ "partNo" : "" , "divNo" : ""}]}}');
        //Input Object를 Json으로 변환
        request.setBody((String) JSON.serialize(objInput));
        //request.setBody((String)JSON.serialize(inputBody));



        System.debug('====IF_MACN_OBS_SFDC 0120====');
        System.debug('getObsSalesInfo START !');
        System.debug('request :: ' + request);
        System.debug('request.getBody() : ' + request.getBody());

        List<Map<String, String>> returnMapList = new List<Map<String, String>>();

        try {

            response = http.send(request);
            responseBody = response.getBody();
            System.debug('***response :: ' + response);
            System.debug('***responseBody :: ' + responseBody);

            //들고온 response로부터 outputData를 가공
            //response의 JSON을 Output에 넣음


            //objoutput =(Output) JSON.deserializeStrict(responseBody, Output.class);
            objoutput = (Output) JSON.deserialize(responseBody, Output.class);
            List<OutputData> datalist = objOutput.Body.data;
            System.debug('objOutput :: ' + objOutput);
            System.debug('datalist -> ' + datalist.size());
            if (!dataList.isEmpty()) {
                for (OutputData data : dataList) {
                    Map<String, String> returnMap = new Map<String, String>();

                    returnMap.put('code', objOutput.Header.rstType);
                    returnMap.put('message', objOutput.Header.rstMsg);
                    returnMap.put('partNo', data.partNo);
                    returnMap.put('divCode', data.divCode);
                    returnMap.put('PartNameKor', data.PartNameKor);
                    returnMap.put('ObsSalesYN', data.ObsSalesYN);
                    returnMap.put('ObsSalesURL', data.ObsSalesURL);
                    returnMap.put('ObsImageURL', data.ObsImageURL);
                    returnMap.put('ObsMemberPrice', data.ObsMemberPrice.format());
                    returnMapList.add(returnMap);
                }
            }
        } catch (Exception e) {
            Map<String, String> returnMap = new Map<String, String>();
            returnMap.put('resultState', 'ERROR');
            returnMap.put('resultMessage', e.getMessage());
            returnMap.put('resultDetailMessage', e.getStackTraceString());

            returnMapList.add(returnMap);
        }

        if(objMaster.isLogInsert__c){
            log.status = resStatus;
            log.errorMessage = errorMsg;
            log.requestTime = requestTime;
            log.responseTime = System.now();
            log.requestBody = JSON.serialize(request.getBody());
            log.responseBody = responseBody;

            ifUtil.addLog(log);
            logList.add(log);
            ifUtil.setLogList(logList);
        }


        return returnMapList;
    }

    //사업부코드와 부품번호를 가져와서 OBS로 조회
    //@HttpPost
    //global static Output doPost(String divNo, String partNo){
    public static List<Map<String, String>> getObsSalesInfo(String partNo, String divCode) {
        System.debug('partNo : ' + partNo + '  ' + 'divCode : ' + divCode);
        Output objOutput = new Output();
        Input objInput = new Input();
        //InputBody inputBody  = new InputBody();
        List<inputData> inputDataList = new List<inputData>();
        InputData inputData = new InputData();
        inputData.partNo = partNo;
        inputData.divCode = divCode;
        inputDataList.add(inputData);
        objInput.body.data = inputDataList;
        //inputBody.data = inputDataList;
        System.debug('objInput :: ' + objInput);


        ResultMsg result = new ResultMsg();
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        String responseBody = '';
        request.setMethod('POST');
        request.setheader('x-Gateway-APIKey', 'e783d29a-a6f0-41c2-a853-e88e2f6c7109');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Logger', 'DEBUG');

        //request.setHeader('Authorization','Bearer gfddgz43yzohs4v62ufwbcd5ig6kyq6w');
        //request.setBody('{ "Body": { "data" : [{ "partNo" : "" , "divNo" : ""}]}}');
        //Input Object를 Json으로 변환
        request.setBody((String) JSON.serialize(objInput));
        //request.setBody((String)JSON.serialize(inputBody));
        //EndPoint 지정
        String apiURL = '';
        //String apiURL = 'https://dev-apigw-ext.lge.com:7221/gateway/lgekr50mkt/api2api/api/product/retrieveDisposableModelInfo';
        //String apiURL ='http://mktsvc.lgekrdev.lge.co.kr/mkt/api/product/retrieveDisposableModelInfo';

        request.setEndpoint(apiURL);

        System.debug('====IF_MACN_OBS_SFDC 0120====');
        System.debug('getObsSalesInfo START !');
        System.debug('request :: ' + request);
        System.debug('request.getBody() : ' + request.getBody());

        List<Map<String, String>> returnMapList = new List<Map<String, String>>();

        try {

            response = http.send(request);
            responseBody = response.getBody();
            System.debug('***response :: ' + response);
            System.debug('***responseBody :: ' + responseBody);


            //들고온 response로부터 outputData를 가공
            //response의 JSON을 Output에 넣음


            //objoutput =(Output) JSON.deserializeStrict(responseBody, Output.class);
            objoutput = (Output) JSON.deserialize(responseBody, Output.class);
            System.debug(objOutput);
            List<OutputData> datalist = objOutput.Body.data;
            System.debug('objOutput :: ' + objOutput);

            if (!dataList.isEmpty()) {
                for (OutputData data : dataList) {
                    Map<String, String> returnMap = new Map<String, String>();

                    returnMap.put('code', objOutput.Header.rstType);
                    returnMap.put('message', objOutput.Header.rstMsg);
                    returnMap.put('partNo', data.partNo);
                    returnMap.put('divCode', data.divCode);
                    returnMap.put('PartNameKor', data.PartNameKor);
                    returnMap.put('ObsSalesYN', data.ObsSalesYN);
                    returnMap.put('ObsSalesURL', data.ObsSalesURL);
                    returnMap.put('ObsImageURL', data.ObsImageURL);
                    returnMap.put('ObsMemberPrice', data.ObsMemberPrice.format());
                    System.debug(' returnMap 출력  !!!!!! :: ' + returnMap);
                    returnMapList.add(returnMap);
                }
            }
        } catch (Exception e) {
            Map<String, String> returnMap = new Map<String, String>();
            returnMap.put('resultState', 'ERROR');
            returnMap.put('resultMessage', e.getMessage());
            returnMap.put('resultDetailMessage', e.getStackTraceString());

            returnMapList.add(returnMap);
        }

        System.debug('returnMapList :: ' + returnMapList);

        return returnMapList;
    }

    //JSON으로 OBS에서 받은 데이터를 SM_SVCBOM__c에 전시정보를 담아준다.
    // ==>> JSON 으로 OBS받은 데이터를 Product2에 업데이트 해준다.
    public static Map<String, Object> updateObsSalesInfo(String partNo, String divCode) {
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('code', '002');
        resultMap.put('Message', 'SUCCESS');


        return resultMap;
    }
}