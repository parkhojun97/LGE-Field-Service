/**
 * Created by A81292 on 2023-02-20.
 *  BEST -> SFDC Care용품 재고 조회
/**

 * */
@RestResource(UrlMapping='/v1/api/ma/newbest/IF_MACN_NEWBEST_SFDC_0040')
global without sharing class IF_MACN_NEWBEST_SFDC_0040 {

    // =============================================================
    // 인터페이스 Id 값 설정 (SFDC에 ifId를 저장하여 사용)
    // =============================================================
    private static final String IFID    = 'IF-NEW-547';
    private static final String SUCCESS = 'SUCCESS';
    private static final String ERROR   = 'ERROR';


    global class Input {
        public InputBody Body;
        public Input(){
            Body = new InputBody();
        }
    }

    global class InputBody {
       public InputDetail data;
        public InputBody(){
            data = new InputDetail();
        }
    }

    global class InputDetail{
        public String deptCode;     //부서코드
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
        public List<OutputData> data;
        public OutputBody(){
            data = new List<OutputData>();
        }
    }

    global class OutputData {
          public String deptCode;         //부서코드
          public String deptName;         //부서코드명
          public String divCode;          //사업부코드
          public String partNo;           //PART_NO
          public Decimal availQty;        //가용수량
    }

    global class ResultMsg {
        public String code;
        public String message;
        public Integer dataCount;

    }

    @HttpPost
    global static Output doPost(){
        Output objOutput = new Output();
        OutputBody objOutputBody = new OutputBody();
        ResultMsg resultMsg = new ResultMsg();
        RestRequest request = RestContext.request;
        String requestBody = request.requestBody.toString();
        String requestHeader = request.headers.toString();
        System.debug('requestBody :: ' + requestBody);
        // 로그 시작 (IF_Master에 등록되어 있으며, 로그 적재 여부가 true일 경우에만 쌓임)
        IFUtil ifUtil               = new IFUtil(IFID);
        IFUtil.LogWrapper log       = new IFUtil.LogWrapper(IFID, requestHeader, requestBody);
        try{


            if(requestBody != null && requestBody !='') {
                Input objInput = (Input)JSON.deserializeStrict(requestBody, Input.class);
                objOutputBody = retrieveCarePlusStockQty(objInput);
                objOutput.body = objOutputBody;
                resultMsg.code = '200';
                resultMsg.message = '정상적으로 조회되었습니다';
                resultMsg.dataCount = objOutputBody.data.size();
            }
        } catch (JSONException je){

            resultMsg.code = '500';
            resultMsg.message = 'reason:'+je.getMessage();
        } catch (NullPointerException ne){

            resultMsg.code = '500';
            resultMsg.message = ' 조회된 값이 없습니다.  '+ ne.getMessage();
        } catch (Exception e) {
            resultMsg.code = '500';
            resultMsg.message =  e.getMessage();
        }
        objOutput.header = resultMsg;
        // =============================================================
        // RESPONSE
        // =============================================================

        log.responseTime            = System.now();
        log.responseBody            = JSON.serialize(objOutput);
        log.status                  = objOutput.header.code == '200' ? SUCCESS : ERROR;
        log.errorMessage            = objOutput.header.message;
        ifUtil.insertLog(log);
        return objOutput ;
    }

    global static OutputBody retrieveCarePlusStockQty (Input objInput) {
        OutputBody outputBody = new OutputBody();

        String DeptCode = objInput.Body.data.deptCode;
        String PartNo = objInput.Body.data.partNo;

        if(DeptCode != 'PH0300'){
            outputBody = null;
        } else {
            List<ProductItem> resultList = new List<ProductItem>();
            String query = '';
            //23 12 13 hyungho.chun  ProductName -> Product2.Name
            query += ' SELECT Id, Location.SM_DEPT_Id__r.DEPT_CODE__c, fm_DIV_CODE__c, Product2.Name, fm_Available_Quantity__c, Product2.CAREPLUS_YN__c, Location.SM_DEPT_Id__r.Name, Location.fm_RecordType__c ';
            query += ' FROM ProductItem';
            //query += ' WHERE Location.SM_DEPT_Id__r.DEPT_CODE__c = : DeptCode';

            query += ' WHERE Location.fm_RecordType__c = \'Location\'  ';
            query += ' AND Location.Name = \'99A999\'';

            query += ' AND Location.DEPT_CODE__c = : DeptCode';


            if(!PartNo.equals(null) && !PartNo.equals('')){
                query += ' AND Product2.Name = : PartNo ';
            }


            resultList = Database.query(query);
            System.debug(' resultList ::  ');
            List<OutputData> productDataList = new List<OutputData>();

            if(!resultList.isEmpty()){
                for(ProductItem objProductItem : resultList){
                    OutputData od = new OutputData();
                    od.deptCode = objProductItem.Location.SM_DEPT_Id__r.DEPT_CODE__c;
                    od.deptName = objProductItem.Location.SM_DEPT_Id__r.Name;
                    od.partNo = objProductItem.Product2.Name;
                    od.availQty = objProductItem.fm_Available_Quantity__c;
                    od.divCode = objProductItem.fm_DIV_CODE__c;
                    productDataList.add(od);
                }
                outputBody.data = productDataList;
            } else{
                outputBody= null;
            }
        }


        return outputBody;
    }
}