/**
 * File Name    : EX_FulfillReceivingDeliverySync_Sample.cls
 * Author       :
 * Date         : 2023-09-01
 * Tester       : EX_FulfillReceivingDeliverySync_Sample_test.cls
 * Description  : 히로쿠 SFDC Sync
 * Modification Log
 * ======================================================================================
 * Ver      Date        Author              Modification
 * ======================================================================================
 * 1.0      2023-09-01            Create
 */
// /v1/api/ma/heroku/FulfillmentSync
@RestResource(UrlMapping='/v1/api/ma/heroku/FulfillmentSync')
global with sharing class EX_FulfillReceivingDeliverySync {

    // =============================================================
    // 인터페이스 Id 값 설정 (SFDC에 ifId를 저장하여 사용)
    // =============================================================
    private static final String ifId    = 'FulfillmentSync';
    private static final String SUCCESS = 'SUCCESS';
    private static final String ERROR   = 'ERROR';

    private static final String TARGET_OBJECT_DELIVERY  =  'SR_ONLINE_DELIVERY_INFO_HISTORY__c';
    private static final String TARGET_OBJECT_RECEIVING =  'SI_FULFILLMENT_RECEIVING__c';

    public class InputNullPointException extends Exception {}

    global class Input {
        public InputBody request;
        public Input() {
            request = new InputBody();
        }
    }

    global class InputBody {
        public String ReqType;
        public List<DeliveryData> dParams;
        public List<ReceiveData> rParams;
        public InputBody() {
            if ( 'DELIVERY'.equalsIgnoreCase( ReqType ) ) {
                dParams = new List< DeliveryData>();
            } else if ( 'RECEIVING'.equalsIgnoreCase( ReqType ) ) {
                rParams = new List< ReceiveData>();
            }
        }
    }

    global class Output{
        public ResultMsg result;
    }

    global class ResultMsg {
        public String rstType;
        public String rstMsg;
    }

    global static Map< String, Object> objectKeyMap;

//    /**
//    * @AUTHOR SEHJIKYANG
//    * date on 2023-08-31.
//    */
    @HttpPost
    global static Output doPost (){

        Savepoint sp = Database.setSavepoint();
        String requestBody = RestContext.request.requestBody.toString();
        String requestHeader = RestContext.request.headers.toString();

        // 로그 시작 (IF_Master에 등록되어 있으며, 로그 적재 여부가 true일 경우에만 쌓임)
        IFUtil ifUtil               = new IFUtil(ifId);
        IFUtil.LogWrapper logs       = new IFUtil.LogWrapper(ifId, requestHeader, requestBody);

        System.debug('requestBody :: ' + requestBody);
        Input objInput              = new Input();

        InputBody objInputBody      = new InputBody();

        ResultMsg result            = new ResultMsg();
        Output objOutput            = new Output();

        StringBuffer sfLog = new StringBuffer();

        Database.SaveResult[] rst = null;

        String rstType = '';

        try{

            instanceDeliveryKeyMap();

            objInputBody = (InputBody) JSON.deserialize( requestBody, InputBody.class );

            String targetObjectName = '';

            if ( String.isEmpty( objInputBody.ReqType ) ) {
                throw  new InputNullPointException( 'OCCURRED - EXCEPTION ===================[ objInputBody.ReqType is null ]' );
            }

            if ( 'DELIVERY'.equalsIgnoreCase( objInputBody.ReqType ) ) {

                if (  objInputBody.dParams.isEmpty() ) {
                    throw  new InputNullPointException( 'OCCURRED - EXCEPTION ===================[ objInputBody.dParams is null ]' );
                }

                targetObjectName =  TARGET_OBJECT_DELIVERY;

                List< DeliveryData> deliveryList = objInputBody.dParams;
                rst = insertDeliveryHistory( targetObjectName, deliveryList, ( Map<String, String> )objectKeyMap.get( objInputBody.ReqType ));

            } else if ( 'RECEIVING'.equalsIgnoreCase( objInputBody.ReqType )) {

                if (  objInputBody.rParams.isEmpty() ) {
                    throw  new InputNullPointException( 'OCCURRED - EXCEPTION ===================[ objInputBody.rParams is null ]' );
                }

                targetObjectName =  TARGET_OBJECT_RECEIVING;

                List< ReceiveData> receiveList = objInputBody.rParams;
                rst = insertDeliveryHistory( targetObjectName, receiveList, (Map<String, String>)objectKeyMap.get( objInputBody.ReqType ) );
            }

            Integer s = rst.size();
            Integer i = 0;

            for ( Database.SaveResult sr : rst ) {
                if ( sr.isSuccess() ) {
                    // Operation was successful, so get the ID of the record that was processed

                    sfLog.appendln('Successfully inserted.  ID: ' + sr.getId());
                    rstType ='SUCCESS';
                    i++;
                } else {
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {

                        sfLog.appendln('The following error has occurred.');
                        sfLog.appendln(err.getStatusCode() + ': ' + err.getMessage());
                        sfLog.appendln('fields that affected this error: ' + err.getFields());
                    }
                    rstType ='ERROR';
                }
            }

            sfLog.appendln('insert size : [' + i + '] toDo size : [' + s + ']' );

        } catch ( Exception e){
            sfLog.append ('OCCURRED - EXCEPTION ===================[' + e.getMessage() + ']' );
            rstType ='ERROR';
            throw  e;
        } finally {

            result.rstType = rstType;
            result.rstMsg = sfLog.print();

            objOutput.result = result;

            logs.responseTime            = System.now();
            logs.responseBody            = JSON.serialize(objOutput);
            logs.status                  = result.rstType == 'SUCCESS' ? SUCCESS : ERROR;
            logs.errorMessage            = result.rstMsg;

            //  ifUtil.insertLog(logs);
        }
        return objOutput;
    }


    global static Database.SaveResult[] insertDeliveryHistory( String targetName,  List<Object> inputList, Map<String, String>inputKeyMap ){

        List< SObject> insertList = new List< SObject>();

        String jstr = JSON.serializePretty( inputList.get( 0 ) );
        Map< String, Object> m =  (Map< String, Object>) JSON.deserializeUntyped( jstr );
        Set< String> keys = m.keySet();

        for ( Integer i = 0; i <  inputList.size(); i++ ) {

            SObject tObject = ( Schema.getGlobalDescribe() ).get( targetName ).newSObject();
            SObjectType ty = tObject.getSObjectType();

            for ( String k : keys ) {

                String SFDCField = inputKeyMap.get( k );
                Schema.SObjectField field = ty.getDescribe().fields.getMap().get( SFDCField );

                String newJ = JSON.serializePretty( inputList.get( i ) );
                Map< String, Object> newM =  (Map< String, Object>) JSON.deserializeUntyped( newJ );

                Object oval = (Object) newM.get( k );

                if ( oval instanceof String ) {

                    String fType = String.valueOf( field.getDescribe().getType() );
                    String value = String.valueOf( oval );

                    if ( 'DATETIME'.equalsIgnoreCase ( fType ) ) {
                        tObject.put( field, Datetime.valueOf( value ) );
                    } else if ('Decimal'.equalsIgnoreCase ( fType )) {
                        tObject.put( field, Decimal.valueOf( value ) );
                    } else IF ('DOUBLE'.equalsIgnoreCase ( fType )) {
                        tObject.put( field, Decimal.valueOf( value ) );
                    } else {
                        tObject.put( field, value );
                    }
                } else if ( oval instanceof Boolean ){

                    tObject.put( field, (Boolean) oval);
                } else if ( oval instanceof Decimal ){

                    tObject.put( field, (Decimal) oval );
                } else {
                    tObject.put( field, oval );
                }
            }

            insertList.add( tObject );
        }
        Database.SaveResult[] srList = Database.insert( insertList, false );
        return srList;
    }


    global class DeliveryData {

        public String input_date; // Datetime
        public String divided_qty;
        public String workdate;
        public Decimal seq;
        public Boolean workflag;
        public String exception_code;
        public String resrv_no;
        public String ship_dtm; // Datetime
        public String input_user_id;
        public String delivery_division;
        public String delivery_code;
        public String trans_unique_cd;
        public Boolean if_yn;
        public String goods_if_user_id;
        public String goods_if_id;
        public String order_channel;
        public String order_no;
        public String unique_cd;
        public String delivery_status_code;
        public Decimal order_seq;
        public String manual_yn;
        public String sr_online_delivery_info;
        public String delivery_no;
        public Decimal delivery_qty;
        public String order_type;
        public String delivery_complete_date; // Datetime
        public String if_error_msg;
        public String goods_if_date; // Datetime
        public String productrequestlineitem;
        public String resrv_sub_seq;
        public String returnorderlineitem;
        public String error_code;
        public Decimal resrv_seq;
        public String partner_code;
    }

    global class ReceiveData {

        public String dept_code;
        public String order_no;
        public Decimal order_seq;
        public Decimal order_sub_seq;
        public String ship_dept_code;
        public String div_code;
        public String part_no;
        public Decimal rcv_qty;
        public String carton_no;
        public String product_transfer_id;
        public String if_send_yn;
        public String if_send_date; // Datetime
        public String if_response_yn;
        public String if_response_date; // Datetime
        public String rcv_confirm_yn;
        public String rcv_confirm_date; // Datetime
        public String custr_po_no;
        public Decimal item_seq;
        public String error_code;
        public String error_desc;

    }

    public static void instanceDeliveryKeyMap(){

        objectKeyMap = new Map<String, Object>();

        Map <String, String> deliveryKeyMap = new Map< String, String>{
                'input_date'				=>	'INPUT_DATE__c'
                ,'divided_qty'				=>	'divided_qty__c'
                ,'workdate'					=>	'WORKDATE__c'
                ,'seq'						=>	'SEQ__c'
                ,'workflag'					=>	'WORKFLAG__c'
                ,'exception_code'			=>	'EXCEPTION_CODE__c'
                ,'resrv_no'					=>	'RESRV_NO__c'
                ,'ship_dtm'					=>	'SHIP_DTM__c'
                ,'input_user_id'			=>	'INPUT_USER_ID__c'
                ,'delivery_division'		=>	'DELIVERY_DIVISION__c'
                ,'delivery_code'			=>	'DELIVERY_CODE__c'
                ,'trans_unique_cd'			=>	'TRANS_UNIQUE_CD__c'
                ,'if_yn'					=>	'IF_YN__c'
                ,'goods_if_user_id'			=>	'GOODS_IF_USER_ID__c'
                ,'goods_if_id'				=>	'GOODS_IF_ID__c'
                ,'order_channel'			=>	'ORDER_CHANNEL__c'
                ,'order_no'					=>	'ORDER_NO__c'
                ,'unique_cd'				=>	'UNIQUE_CD__c'
                ,'delivery_status_code'		=>	'DELIVERY_STATUS_CODE__c'
                ,'order_seq'				=>	'ORDER_SEQ__c'
                ,'manual_yn'				=>	'MANUAL_YN__c'
                ,'sr_online_delivery_info'	=>	'SR_ONLINE_DELIVERY_INFO__c'
                ,'delivery_no'				=>	'DELIVERY_NO__c'
                ,'delivery_qty'				=>	'DELIVERY_QTY__c'
                ,'order_type'				=>	'ORDER_TYPE__c'
                ,'delivery_complete_date'	=>	'DELIVERY_COMPLETE_DATE__c'
                ,'if_error_msg'				=>	'IF_ERROR_MSG__c'
                ,'goods_if_date'			=>	'GOODS_IF_DATE__c'
                ,'productrequestlineitem'	=>	'ProductRequestLineItem__c'
                ,'resrv_sub_seq'		    =>	'RESRV_SUB_SEQ__c'
                ,'returnorderlineitem'		=>	'ReturnOrderLineItem__c'
                ,'resrv_seq'				=>	'RESRV_SEQ__c'
                ,'error_code'				=>	'ERROR_CODE__c'
                ,'partner_code'				=>	'PARTNER_CODE__c'
        };

        Map<String, String> receiveKeyMap = new Map< String, String>{
                'dept_code'				    =>	'dept_code__c'
                ,'order_no'				    =>	'order_no__c'
                ,'order_seq'				=>	'order_seq__c'
                ,'order_sub_seq'			=>	'order_sub_seq__c'
                ,'ship_dept_code'			=>	'ship_dept_code__c'
                ,'div_code'			        =>	'div_code__c'
                ,'part_no'					=>	'part_no__c'
                ,'rcv_qty'					=>	'rcv_qty__c'
                ,'carton_no'			    =>	'carton_no__c'
                ,'product_transfer_id'		=>	'product_transfer_id__c'
                ,'if_send_yn'			    =>	'if_send_yn__c'
                ,'if_send_date'			    =>	'if_send_date__c'
                ,'if_response_yn'			=>	'if_response_yn__c'
                ,'if_response_date'			=>	'if_response_date__c'
                ,'rcv_confirm_yn'			=>	'rcv_confirm_yn__c'
                ,'rcv_confirm_date'			=>	'rcv_confirm_date__c'
                ,'custr_po_no'				=>	'custr_po_no__c'
                ,'item_seq'				    =>	'item_seq__c'
                ,'error_code'		        =>	'error_code__c'
                ,'error_desc'				=>	'error_desc__c'
        };

        objectKeyMap.put('DELIVERY', deliveryKeyMap );
        objectKeyMap.put('RECEIVING', receiveKeyMap );
    }


    global class StringBuffer{

        private List<String> stringList;

        public StringBuffer(){
            this.stringList = new List<String>();
        }

        public void append ( String str ){
            this.stringList.add( str );
        }

        public void appendln ( String str ){
            this.stringList.add( str +'\n');
        }

        public String print () {
            return String.join( this.stringList, '');
        }

    }
}