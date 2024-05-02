/**
 * @description       : THINQ -> SFDC WARRANTY 조회
 * @author            : JIEUNSONG
 * @last modified on  : 03-03-2024
 * @last modified by  : hyungho.chun@dkbmc.com
 * Modifications Log
 * Ver   Date         Author                        Modification
 * 1.0   2023-04-10   JIEUNSONG                     Initial Version
 * 1.1   2024-02-15   gunting2000@cnspartner.com    정렬기준 변경 (Name => fm_InterfaceId__c)
 * 1.2   2024-03-02   gunting2000@cnspartner.com    Product2 - DAY_ONLY(convertTimezone(PROD_LINE_CODE__r.lastModifiedDate)) >= LAST_N_DAYS:1 기준으로 조회 (조회한 시점의 하루 전 변경 데이터 조회)
 *                                                  SI_THINQ_PRODUCT_LINE__c < DAY_ONLY(convertTimezone(CreatedDate)) <= LAST_N_DAYS:1 기준으로 조회 (조회한 시점의 하루 전 생성 데이터 조회)
 *                                                  각 조회한 것의 Key값 기준으로 생성 리스트 전달 예정
**/


@RestResource(UrlMapping='/v1/api/ma/thinqstore/IF_MACN_SFDC_THINQAPP_0030')
global with sharing class IF_MACN_SFDC_THINQAPP_0030 {

    // =============================================================
    // 인터페이스 Id 값 설정 (SFDC에 ifId를 저장하여 사용)
    // =============================================================
    private static final String IFID    = 'IF-NEW-744';
    private static final String SUCCESS = 'SUCCESS';
    private static final String ERROR   = 'ERROR';

    @HttpPost
    global static Output doPost(){
        Output objOutput = new Output();

        RestRequest request = RestContext.request;
        String requestBody = request.requestBody.toString();
        String requestHeader = request.headers.toString();

        // 로그 시작 (IF_Master에 등록되어 있으며, 로그 적재 여부가 true일 경우에만 쌓임)
        IFUtil ifUtil               = new IFUtil(IFID);
        IFUtil.LogWrapper log       = new IFUtil.LogWrapper(IFID, requestHeader, requestBody);


        System.debug('requestBody :: ' + requestBody);

        try{
            if(requestBody!= null && requestBody!=''){
                InputBody objInput = (InputBody)JSON.deserializeStrict(requestBody, InputBody.class);
                //insert
                List<SI_THINQ_PRODUCT_LINE__c> insertList = saveSITHINQProductLine();
                //insert 후에 송신할 데이터 조회
                // if(!insertList.isEmpty()){
                    objOutput = getSiThinqProductLines(objInput);
                // }
            }
        } catch ( Exception e ){
            System.debug('[Error] line: ' + e.getLineNumber() + ', message: ' + e.getMessage());
        }

        // =============================================================
        // RESPONSE
        // =============================================================

        log.responseTime            = System.now();
        log.responseBody            = JSON.serialize(objOutput);
        System.debug('result : ' + log.responseBody);
        //log.status                  = objOutput.header.code == '200' ? SUCCESS : ERROR;
        //log.errorMessage            = objOutput.header.message;
        ifUtil.insertLog(log);

        return objOutput;
    }

    /**
    * @description 1. 전일에 수정된 Product2 조회
    * 조건 : LastModifiedDate를 비교하는 날짜를 파라미터로 받음
    * @return
    */
    global static List<Product2> getProduct2List(Datetime param){

        List<Product2> productList = new List<Product2>();
        String product2Query = '';
        String product2whereQuery = '';
//        Date lastday = Date.today().addDays(-1);
//        String dateformat = lastday.year()+'-'+'0'+lastday.month()+'-'+lastday.day() + 'T00:00:00.000+00:00';
//        System.debug( 'dateformat : ' + dateformat);
        System.debug( 'Datetime.now().format(\'yyyy-MM-dd\')+\'T00:00:00.000+00:00\'' +Datetime.now().format('yyyy-MM-dd')+'T00:00:00.000+00:00' );
        product2Query += ' SELECT Id, PROD_LINE_CODE__c, SALE_MODEL_CODE__c, ';
        product2Query += ' PROD_LINE_CODE__r.PROD_LINE_NAME__c, PROD_LINE_CODE__r.PROD_LINE_NAME_ENG__c, PROD_LINE_CODE__r.Name, ';
        product2Query += ' fm_INWTY_PERIOD__c , RecordType.DeveloperName, LastModifiedDate, PROD_LINE_CODE__r.USE_YN__c,  ';
        product2Query += '  SIGNATURE_YN__c, PROD_LINE_CODE__r.INWTY_PERIOD__c, ';
        //23.05.08 추가
        product2Query += ' PROD_LINE_CODE__r.lastModifiedDate ';
        product2Query += ' FROM Product2 ';
        product2whereQuery += ' WHERE PROD_LINE_CODE__c!=null ';
        product2whereQuery += ' AND RecordType.DeveloperName = \'SM_MODEL\'';
        product2whereQuery += ' AND PROD_LINE_CODE__r.USE_YN__c = \'Y\'';
        // product2whereQuery += ' AND DAY_ONLY(convertTimezone(PROD_LINE_CODE__r.lastModifiedDate)) >= LAST_N_DAYS:1';
        // product2whereQuery += ' AND DAY_ONLY(convertTimezone(PROD_LINE_CODE__r.lastModifiedDate)) >= 2024-03-04'; //24 03 03 hyungho.chun 마이그 이후 중복생성으로 날짜하드코딩처리 (김병준책임요청)
        product2whereQuery += ' AND PROD_LINE_CODE__r.last_update_date__c >= LAST_N_DAYS:1'; // PROD_LINE_CODE__r.last_update_date__c 필드로 변경 24 03 03

        product2whereQuery += ' ORDER BY PROD_LINE_CODE__r.lastModifiedDate DESC  LIMIT 1000';

        System.debug( 'product2whereQuery : ' + product2whereQuery);
        productList = Database.query(product2Query + product2whereQuery);
        System.debug( 'productList :: ' + productList.size() + '건');
        return productList;
    }

    /**
    * @description 2. 전일 수정된 Product2로 SI_THINQ_PRODUCT_LINE 생성
    * 조건 : insertMap에 담아서 한방에 insert
    * @return
    */
    global static List<SI_THINQ_PRODUCT_LINE__c> saveSITHINQProductLine(){
        //조건 1 : 당일건이 있으면 SKIP, 없으면 데이터 생성
        //SI_THINQ_PRODUCT_LINE__c.CreatedDate가 Today가 있으면 생성 하지 않음.

        //24.03.02 gw.lee
        //체크로직 미사용으로 주석 조치
        List<SI_THINQ_PRODUCT_LINE__c> checkList = new List<SI_THINQ_PRODUCT_LINE__c>();
        DateTime param = System.today().addDays(-1);
        List<Product2> products  = getProduct2List(param);

        String checkListQuery ='';
        checkListQuery += ' SELECT ID, SALE_MODEL_CODE__c,  PROD_LINE_CODE__c, LIFE_PERIOD__c ';
        checkListQuery += ' FROM SI_THINQ_PRODUCT_LINE__c ';
        checkListQuery += ' WHERE DAY_ONLY(convertTimezone(CreatedDate)) <= LAST_N_DAYS:1 ';
        if (products.size() > 0) {
            checkListQuery += 'AND (';
            for (Product2 pd : products) {
                Decimal intKey = pd.SIGNATURE_YN__c == 'Y' ? 3 : pd.PROD_LINE_CODE__r.INWTY_PERIOD__c;
                checkListQuery += '( SALE_MODEL_CODE__c = \'' + pd.SALE_MODEL_CODE__c + '\' AND PROD_LINE_CODE__c = \'' + pd.PROD_LINE_CODE__r.Name + '\' AND LIFE_PERIOD__c = ' + intKey + ' ) OR ';
            }
    
            checkListQuery = checkListQuery.removeEnd('OR ');
            checkListQuery += ')';
        }
        checkListQuery += ' LIMIT 10000  ';
        System.debug('checkListQuery :::: ' + checkListQuery);
        checkList = Database.query(checkListQuery);

        Map<String, Object> returnMap = new Map<String, String>();
        List<SI_THINQ_PRODUCT_LINE__c> insertPLList = new List<SI_THINQ_PRODUCT_LINE__c>();
        
        

        Set<String> siSet = new Set<String>();
        for (SI_THINQ_PRODUCT_LINE__c dupObj :  checkList) {
            String siKey = dupObj.SALE_MODEL_CODE__c + '_' + dupObj.PROD_LINE_CODE__c + '_' + String.valueOf(dupObj.LIFE_PERIOD__c);
            siSet.add(siKey);
        }

            if(!products.isEmpty()){
            //if(!products.isEmpty() && checkList.isEmpty()){//////
                for (Product2 pd : products) {
                    String pdKey = pd.SALE_MODEL_CODE__c + '_' + pd.PROD_LINE_CODE__r.Name;
                    String pdpKey = pd.SIGNATURE_YN__c == 'Y' ? '3' : String.valueOf(pd.PROD_LINE_CODE__r.INWTY_PERIOD__c);
                    String mergeKey = pdKey + '_' + pdpKey;
                    if (!siSet.contains(mergeKey)) {
                        SI_THINQ_PRODUCT_LINE__c thinqPL = new SI_THINQ_PRODUCT_LINE__c();
                        thinqPL.SALE_MODEL_CODE__c = pd.SALE_MODEL_CODE__c;
                        thinqPL.PROD_LINE_CODE__c = pd.PROD_LINE_CODE__r.Name; //double check
                        thinqPL.PROD_LINE_NAME_ENG__c = pd.PROD_LINE_CODE__r.PROD_LINE_NAME_ENG__c;//double check
                        //thinqPL.LIFE_PERIOD__c = pd.PROD_LINE_CODE__r.LIFE_PERIOD__c;
                        thinqPL.LIFE_PERIOD__c = pd.fm_INWTY_PERIOD__c;//double check
                        thinqPL.TRANSFER_FLAG__c = 'N';
                        insertPLList.add(thinqPL);
                    }
                }
            }
                if(!insertPLList.isEmpty()){
                    insert insertPLList;
                }
                System.debug('SI_THINQ_PRODUCT_LINE insert 완료 : ' + insertPLList.size()+'건 ');


        return insertPLList;
    }

    /**
    * @description 3. THINQ에서 마지막 수신된 interface Id를 받아서 그거보다 큰  SI_THINQ_PRODUCT_LINE__c 데이터를 조회하고 송신 & 송신 성공시 Transfer_flag ='Y'로 업데이트
    * param : IF.lastkey , IF.limitedCount
    * 조건 : insertMap에 담아서 한방에 insert
    * @return
    */

    global static Output  getSiThinqProductLines(InputBody objInput){

        Integer lastkey = objInput.rcptInfo.lastkey;
        if(lastkey ==null) {
            SI_THINQ_PRODUCT_LINE__c stpl = new  SI_THINQ_PRODUCT_LINE__c();
//            stpl =  Database.query('SELECT MAX(fm_InterfaceId__c)FROM SI_THINQ_PRODUCT_LINE__c WHERE TRANSFER_FLAG__c = \'Y\' ');
//            lastkey =Integer.valueOf(stpl);
            List<AggregateResult> agg = Database.query('SELECT MAX(fm_InterfaceId__c) maxInterfaceId FROM SI_THINQ_PRODUCT_LINE__c WHERE TRANSFER_FLAG__c = \'Y\'');
            if(!agg.isEmpty()){
                lastkey = Integer.valueOf(agg[0].get('maxInterfaceId'));
            }

            System.debug( 'lastKey가 넘어오지 않았을떄 출력 : ' + lastkey);
        }




        Integer limitedcount = objInput.rcptInfo.limitedcount;

        List<SI_THINQ_PRODUCT_LINE__c> outputList = new List<SI_THINQ_PRODUCT_LINE__c>();
        Output objOutput = new Output();
        List<OutputBody> outputBodies = new List<OutputBody>();
        objOutput.resultData = outputBodies;
        String outputQuery ='';
        outputQuery += ' SELECT Id, NAME, SALE_MODEL_CODE__c, PROD_LINE_CODE__c, LIFE_PERIOD__c, ';
        outputQuery += ' TRANSFER_FLAG__c, TRANSFER_DATE__c ';
        outputQuery += ' FROM SI_THINQ_PRODUCT_LINE__c ';
        // outputQuery += ' WHERE TRANSFER_FLAG__c = \'N\'';
        outputQuery += 'WHERE fm_InterfaceId__c  >' + lastkey ;
        outputQuery += ' ORDER BY fm_InterfaceId__c asc '; //2024.02.15 gw.lee 인터페이스 아이디 기준으로 변경
        outputQuery += ' LIMIT '+limitedcount;

        System.debug('outputQuery ::: ' + outputQuery);
        outputList = Database.query(outputQuery);
        System.debug('outputList :: ' + outputList);
        if(!outputList.isEmpty()){
            for(SI_THINQ_PRODUCT_LINE__c stpl : outputList){
                OutputBody ob = new OutputBody();
                ob.interfaceId = integer.valueOf(stpl.Name);
                ob.sale_model_code = stpl.SALE_MODEL_CODE__c;
                ob.prod_line_code = stpl.PROD_LINE_CODE__c;
                ob.life_period = integer.valueOf(stpl.LIFE_PERIOD__c);
                outputBodies.add(ob);
            }
            //송신이 완료되면 송신한 si_thinq_product_line__c.Transfer_flag__c 를 'y'로 업데이트
            updateTransferFlag(outputList);
        }
        return objOutput;
    }

    global static void updateTransferFlag(List<SI_THINQ_PRODUCT_LINE__c> outputList ){
        List<SI_THINQ_PRODUCT_LINE__c> updateList = new LIst<SI_THINQ_PRODUCT_LINE__c>();
        for(SI_THINQ_PRODUCT_LINE__c stpl : outputList){
            stpl.TRANSFER_FLAG__c='Y';
            stpl.TRANSFER_DATE__c=System.today();
            stpl.TRANSFER_DESC__c ='';//double check
            updateList.add(stpl);
        }

        System.debug( ' flagUpdateList : ' + updateList);
        update updateList;
    }




    /**
     *  Input
     */

//    global class Input {
//        public InputBody Body;
//        public Input(){
//            Body = new InputBody();
//        }
//    }

    global class InputBody{
        public InputDetail rcptInfo;
        public InputBody(){
            rcptInfo = new InputDetail();
        }
    }

    global class InputDetail{
        public Integer lastkey; //interfaceId
        public Integer limitedcount; //송신데이터의 건수 기준
    }


    /**
     *  Output
     */

    global class Output{
        public ResultMsg header;
        public List<OutputBody> resultData;

        public Output(){
            resultData = new List<OutputBody>();

        }
    }

    global class OutputBody{

        public Integer INTERFACEID;
        public String SALE_MODEL_CODE;
        public String PROD_LINE_CODE;
        public Integer LIFE_PERIOD;

        ///////정의서에 추가되어있지 않은 필드들/////
        //public String transfer_flag;
        //public Date transfer_date;
        //public String transfer_desc; //todo 타입확인필요
    }

    global class ResultMsg {
        public String code;
        public String message;
        public Integer dataCount;
    }

}