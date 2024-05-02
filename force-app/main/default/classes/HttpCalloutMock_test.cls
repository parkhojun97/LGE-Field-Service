/************************************************************************************
* File Name           : HttpCalloutMock_test
* Description         : callout테스트
* Modification Log
* Ver      Date            Author          Modification
* ===================================================================================
1.0      2023-05-03        sungho.jo          Create
*************************************************************************************/
public class HttpCalloutMock_test {
    public class HttpCalloutMockWrap implements HttpCalloutMock {
        private Integer statusCode;
        private String body;
        public HttpCalloutMockWrap(Integer statusCode, String body){
            this.statusCode = statusCode;
            this.body       = body;
        }
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(this.statusCode);
            response.setBody(this.body);
            return response;
        }
    }
}