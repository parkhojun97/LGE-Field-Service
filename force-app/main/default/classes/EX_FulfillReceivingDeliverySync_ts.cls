/**
 * Created by A83210 on 2023-09-11.
 */

 @IsTest
 global with sharing class EX_FulfillReceivingDeliverySync_ts {
 
 
 //    @TestSetup
 //    static void setup() {
 //
 //    }
 
     public static String requestBodyR = '{"ReqType":"RECEIVING", "rParams" :[{\n' +
             '\t\t"dept_code" : "PH8002",\n' +
             '\t\t"order_no" : "DLNBN3R005",\n' +
             '\t\t"order_seq" : 4.0,\n' +
             '\t\t"order_sub_seq" : 1.0,\n' +
             '\t\t"ship_dept_code" : "DLZ",\n' +
             '\t\t"div_code" : "DLZ",\n' +
             '\t\t"part_no" : "ADQ75153461",\n' +
             '\t\t"rcv_qty" : 1.0,\n' +
             '\t\t"carton_no" : "221109PH8002CCSYA0002",\n' +
             '\t\t"product_transfer_id" : null,\n' +
             '\t\t"if_send_yn" : "Y",\n' +
             '\t\t"if_send_date" : "2022-11-10 00:04:43",\n' +
             '\t\t"if_response_yn" : "Y",\n' +
             '\t\t"if_response_date" : "2022-11-11 07:00:22",\n' +
             '\t\t"rcv_confirm_yn" : "Y",\n' +
             '\t\t"rcv_confirm_date" : "2022-11-09 15:00:00",\n' +
             '\t\t"custr_po_no" : "DLNBN3R005-4-1",\n' +
             '\t\t"item_seq" : 4.0,\n' +
             '\t\t"error_code" : null,\n' +
             '\t\t"error_desc" : null\n' +
             '\t},\n' +
             '\t{\n' +
             '\t\t"dept_code" : "PH8002",\n' +
             '\t\t"order_no" : "DLNBN3R006",\n' +
             '\t\t"order_seq" : 3.0,\n' +
             '\t\t"order_sub_seq" : 1.0,\n' +
             '\t\t"ship_dept_code" : "DLZ",\n' +
             '\t\t"div_code" : "DLZ",\n' +
             '\t\t"part_no" : "5231F71002J",\n' +
             '\t\t"rcv_qty" : 4.0,\n' +
             '\t\t"carton_no" : "221108PH8002CCSYA1022",\n' +
             '\t\t"product_transfer_id" : null,\n' +
             '\t\t"if_send_yn" : "Y",\n' +
             '\t\t"if_send_date" : "2022-11-10 00:03:40",\n' +
             '\t\t"if_response_yn" : "Y",\n' +
             '\t\t"if_response_date" : "2022-11-11 01:43:49",\n' +
             '\t\t"rcv_confirm_yn" : "Y",\n' +
             '\t\t"rcv_confirm_date" : "2022-11-09 15:00:00",\n' +
             '\t\t"custr_po_no" : "DLNBN3R006-3-1",\n' +
             '\t\t"item_seq" : 34.0,\n' +
             '\t\t"error_code" : null,\n' +
             '\t\t"error_desc" : null}]}';
 
     public static String requestBodyR2 = '{"ReqType":"RECEIVING", "rParams": [{"order_no":"DLNBN3R005"}]}';
 
 //    public static String requestBodyR3 = '{"ReqType": "RECEIVING", "rParams": ""}';
 
     public static String requestBodyD = '{"ReqType":"DELIVERY", "dParams" :[{\n' +
             '\t\t"order_no" : "ORD-1000067130-E1",\n' +
             '\t\t"order_seq" : 1.0,\n' +
             '\t\t"order_channel" : "B",\n' +
             '\t\t"order_type" : "O",\n' +
             '\t\t"seq" : 1.0,\n' +
             '\t\t"partner_code" : "FULFILLMENT",\n' +
             '\t\t"trans_unique_cd" : "T1000111084",\n' +
             '\t\t"unique_cd" : "O1000067048",\n' +
             '\t\t"if_yn" : true,\n' +
             '\t\t"goods_if_date" : "2023-07-03 20:22:46",\n' +
             '\t\t"goods_if_user_id" : "SYSTEM",\n' +
             '\t\t"delivery_qty" : 2.0,\n' +
             '\t\t"delivery_code" : "CJGLS",\n' +
             '\t\t"delivery_no" : "568354072856",\n' +
             '\t\t"delivery_status_code" : "10",\n' +
             '\t\t"ship_dtm" : "2023-07-03 15:00:00",\n' +
             '\t\t"sfdc_send_flag" : "Y",\n' +
             '\t\t"sfdc_send_date" : "2023-07-04 08:11:37",\n' +
             '\t\t"workflag" : true,\n' +
             '\t\t"resrv_no" : "C000408167",\n' +
             '\t\t"resrv_seq" : 1.0,\n' +
             '\t\t"input_date" : "2023-07-03 20:22:46",\n' +
             '\t\t"input_user_id" : "SYSTEM"\n' +
             '\t},\n' +
             '\t{\n' +
             '\t\t"order_no" : "O230001018803",\n' +
             '\t\t"order_seq" : 1.0,\n' +
             '\t\t"order_channel" : "V",\n' +
             '\t\t"order_type" : "O",\n' +
             '\t\t"seq" : 1.0,\n' +
             '\t\t"partner_code" : "FULFILLMENT",\n' +
             '\t\t"trans_unique_cd" : "T1000111620",\n' +
             '\t\t"unique_cd" : "O1000067373",\n' +
             '\t\t"if_yn" : true,\n' +
             '\t\t"goods_if_date" : "2023-07-27 03:18:31",\n' +
             '\t\t"goods_if_user_id" : "SYSTEM",\n' +
             '\t\t"delivery_qty" : 3.0,\n' +
             '\t\t"delivery_code" : "CJGLS",\n' +
             '\t\t"delivery_no" : "568354075262",\n' +
             '\t\t"delivery_status_code" : "10",\n' +
             '\t\t"ship_dtm" : "2023-07-27 15:00:00",\n' +
             '\t\t"sfdc_send_flag" : "Y",\n' +
             '\t\t"sfdc_send_date" : "2023-07-28 05:30:46",\n' +
             '\t\t"workflag" : true,\n' +
             '\t\t"resrv_no" : "C000408677",\n' +
             '\t\t"resrv_seq" : 1.0,\n' +
             '\t\t"input_date" : "2023-07-27 03:18:31",\n' +
             '\t\t"input_user_id" : "SYSTEM"\n' +
             '\t}]}';
 
     public static String requestBodyD2 = '{"ReqType": "DELIVERY", "dParams": [{"order_no":"O230001018803"}]}';
 
 //    public static String requestBodyD3 = '{"ReqType": "DELIVERY", "dParams": [{"order_no":"O230001018803"}]}';
 
 
 
 
     // RECEIVING SUCCESS
     @IsTest
     static void test00() {
 
 
         Test.startTest();
 
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/v1/api/ma/heroku/FulfillmentSync'; //Request URL
         req.httpMethod = 'POST';
 
         Map<String, String> headerD = new Map<String, String>();
         headerD.put('Content-Type', 'application/json');
 
 
 
         Blob jsonBlob = Blob.valueOf(requestBodyR);
 //        req.headers = headerD;
 
         req.requestBody = jsonBlob;
 
         RestContext.request = req;
         RestContext.response = res;
         EX_FulfillReceivingDeliverySync.doPost();
 
         Test.stopTest();
     }
 
 
     // RECEIVING FAIL
     @IsTest
     static void test01() {
 
         Test.startTest();
 
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/v1/api/ma/heroku/FulfillmentSync'; //Request URL
         req.httpMethod = 'POST';
 
 
         Blob jsonBlob = Blob.valueOf(requestBodyR2);
 
         req.requestBody = jsonBlob;
 
         RestContext.request = req;
         RestContext.response = res;
         EX_FulfillReceivingDeliverySync.doPost();
 
         Test.stopTest();
 
 
     }
 
 //    // RECEIVING rParams null
 //    @IsTest
 //    static void test02() {
 //
 //        Test.startTest();
 //
 //        RestRequest req = new RestRequest();
 //        RestResponse res = new RestResponse();
 //        req.requestURI = '/v1/api/ma/heroku/FulfillmentSync'; //Request URL
 //        req.httpMethod = 'POST';
 //
 //
 //        Blob jsonBlob = Blob.valueOf(requestBodyR3);
 //
 //
 //        req.requestBody = jsonBlob;
 //
 //        RestContext.request = req;
 //        RestContext.response = res;
 //        EX_FulfillReceivingDeliverySync.doPost();
 //
 //        Test.stopTest();
 //    }
 
 
     // DELIVERY SUCCESS
     @IsTest
     static void test03() {
 
 
         Test.startTest();
 
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/v1/api/ma/heroku/FulfillmentSync'; //Request URL
         req.httpMethod = 'POST';
 
         Map<String, String> headerD = new Map<String, String>();
         headerD.put('Content-Type', 'application/json');
 
         Blob jsonBlob = Blob.valueOf(requestBodyD);
 //        req.headers = headerD;
 
         req.requestBody = jsonBlob;
 
         RestContext.request = req;
         RestContext.response = res;
         EX_FulfillReceivingDeliverySync.doPost();
 
         Test.stopTest();
     }
 
 
     // DELIVERY FAIL
     @IsTest
     static void test04() {
 
         Test.startTest();
 
         RestRequest req = new RestRequest();
         RestResponse res = new RestResponse();
         req.requestURI = '/v1/api/ma/heroku/FulfillmentSync'; //Request URL
         req.httpMethod = 'POST';
 
         Map<String, String> headerD = new Map<String, String>();
         headerD.put('Content-Type', 'application/json');
 
         Blob jsonBlob = Blob.valueOf(requestBodyD2);
 
         req.requestBody = jsonBlob;
 
         RestContext.request = req;
         RestContext.response = res;
         EX_FulfillReceivingDeliverySync.doPost();
 
         Test.stopTest();
     }
 
     // DELIVERY dParams null
 //    @IsTest
 //    static void test05() {
 //
 //        Test.startTest();
 //        RestRequest req = new RestRequest();
 //        RestResponse res = new RestResponse();
 //        req.requestURI = '/v1/api/ma/heroku/FulfillmentSync'; //Request URL
 //        req.httpMethod = 'POST';
 //
 //        Map<String, String> headerD = new Map<String, String>();
 //        headerD.put('Content-Type', 'application/json');
 //
 //        Blob jsonBlob = Blob.valueOf(requestBodyD3);
 //
 //        req.requestBody = jsonBlob;
 //
 //        RestContext.request = req;
 //        RestContext.response = res;
 //        EX_FulfillReceivingDeliverySync.doPost();
 //
 //        Test.stopTest();
 //    }
 
 
 }