/************************************************************************************
* File Name   		: IF_GSCS_SFDC_FileUpload
* Description 		: 
* Modification Log
* Ver      Date            Author          Modification
* ===================================================================================
  1.0      2023-01-10        jihyun.lee         Create
*************************************************************************************/

@RestResource(urlMapping='/IF_GSCS_SFDC_FileUpload/*')
global class IF_GSCS_SFDC_FileUpload {

    @HttpPost
    global static void uploadDocument() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;

        // Parameter 조회
        String modelCode    = request.params.get('modelCode');
        String name         = request.params.get('name');

        // Body 조회
        Blob jsonBlob = request.requestBody;
        String jsonString = EncodingUtil.base64Encode(jsonBlob);
        System.debug('*** jsonString: ' + jsonString);

        // Product Model Code로 조회
        String modelRecordType = 'SM_MODEL';
        Id modelRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(modelRecordType).getRecordTypeId();
        List<Product2> listProduct = new List<Product2>();
        if(!Test.isRunningTest()) {
            listProduct = [SELECT Id, Name FROM Product2 WHERE Name = :modelCode AND RecordTypeId = :modelRecordTypeId];
        } else {
            listProduct = [SELECT Id, Name FROM Product2];
        }

        if (listProduct.size() == 0) {
            RestContext.response.addHeader('Content-Type', 'application/json');
            RestContext.response.responseBody = Blob.valueOf(generateJSON('error', '', 'modelCode와 일치하는 Product가 없습니다.'));
        } else {
            try {
                Id idTargetProduct = listProduct[0].Id;

                // ContentVersion 생성
                ContentVersion cVersion = new ContentVersion(
                        PathOnClient = name,                                        //File name with extention
                        Title = name,
                        VersionData = EncodingUtil.base64Decode(jsonString)         //File content
                );
                insert cVersion;

                // Content Version 저장 후, ContentDocumentId 가져옴
                Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cVersion.Id].ContentDocumentId;

                // Link 삽입
                ContentDocumentLink cDocLink = new ContentDocumentLink(
                        ContentDocumentId = conDocument,
                        LinkedEntityId = idTargetProduct
                );
                insert cDocLink;

                RestContext.response.addHeader('Content-Type', 'application/json');
                RestContext.response.responseBody = Blob.valueOf(generateJSON('success', conDocument, ''));
            } catch (Exception e) {
                RestContext.response.addHeader('Content-Type', 'application/json');
                if (name.split('\\.').size() != 2) {
                    RestContext.response.responseBody = Blob.valueOf(generateJSON('error', '', 'name은 파일명.확장자 형식이어야 합니다.'));
                } else {
                    RestContext.response.responseBody = Blob.valueOf(generateJSON('error', '', e.getMessage()));
                }

            }
        }

    }

    private static String generateJSON(String status, String content, String error) {
        JSONGenerator jsonGenerator = JSON.createGenerator(true);
        jsonGenerator.writeStartObject();
        jsonGenerator.writeStringField('status', status);
        jsonGenerator.writeStringField('contentId', content);
        jsonGenerator.writeStringField('error', error);
        jsonGenerator.writeEndObject();
        return jsonGenerator.getAsString();
    }

    //     String fileName_m = 'a12.pdf';
    //
    // //  Get Authentication Token
    //
    //     HttpRequest req = new HttpRequest();
    //
    //     req.setEndpoint('https://{server}.sf-api.com/oauth/token?grant_type=password&client_id={client_id}&client_secret={secret}&username={user_name}&password={password}!');
    //     req.setMethod('GET');
    //
    //     Http http = new Http();
    //     HttpResponse response = http.send(req);
    //     System.Debug(response.getBody());
    //
    //
    // Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
    // String token = '';
    // String refreshtoken = '';
    // if(response.getStatusCode() == 200){
    //     token = (String)results.get('access_token');
    //     refreshtoken = (String)results.get('refresh_token');
    // }
    //
    // system.debug('token=' + token);
    //
    //
    //
    //
    // // Get Folder ID
    // HttpRequest req1 = new HttpRequest();
    //
    // req1.setEndpoint('https://{server}.sf-api.com/sf/v3/Items?$expand=Children');
    // req1.setMethod('GET');
    // req1.setHeader('Authorization','Bearer ' + token);
    //
    // Http http1 = new Http();
    // HttpResponse response1 = http1.send(req1);
    // System.Debug(response1.getBody());
    //
    //
    // Map<String, Object> results1 = (Map<String, Object>)JSON.deserializeUntyped(response1.getBody());
    // String url = '';
    // if(response1.getStatusCode() == 200){
    //     url = (String)results1.get('url');
    // }
    //
    // System.Debug('Folder Url ' + url);
    //
    //
    //
    //
    // // Get Chunk URI
    // HttpRequest req2 = new HttpRequest();
    //
    // String endPoint = url + '/Upload2';
    // req2.setEndpoint(endPoint);
    // req2.setMethod('POST');
    // req2.setHeader('Authorization','Bearer ' + token);
    // req2.setHeader('Content-Type', 'application/x-www-form-urlencoded');
    //
    // String payload1 = 'FileName='+fileName_m;
    // req2.setBody(payload1);
    //
    // Http http2 = new Http();
    // HttpResponse response2 = http2.send(req2);
    //
    //
    // Map<String, Object> results2 = (Map<String, Object>)JSON.deserializeUntyped(response2.getBody());
    // String ChunkUri = '';
    // if(response2.getStatusCode() == 200){
    //     ChunkUri = (String)results2.get('ChunkUri');
    // }
    //
    // System.Debug('ChunkUri' + ChunkUri);
}