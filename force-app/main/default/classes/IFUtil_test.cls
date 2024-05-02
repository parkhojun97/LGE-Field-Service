/******************************************************************
  * File Name   : IFUtil_test
  * Description : 
  * Author      : sm.yang
  * Modification Log
  * ===============================================================
  * Ver  Date        Author          Modification
  * ===============================================================
    1.0  2022-10-06     sm.yang          Create                      
******************************************************************/

@isTest
private class IFUtil_test {

	static testMethod void testSMPSuccess() {

		IFUtil ifUtil = new IFUtil('SMP_TEST');

		List<IFUtil.LogWrapper> testLogWrapperList = new List<IFUtil.LogWrapper>();

		IFUtil.LogWrapper testLogWrapper = new IFUtil.LogWrapper();
		testLogWrapper.status = 'ERROR';
		testLogWrapperList.add(testLogWrapper);

		ifUtil.ResponseWrapper responseWrapper = new ifUtil.ResponseWrapper();

		responseWrapper.result  = 'success';
		responseWrapper.path  = 'test';
		responseWrapper.message  = 'test';
		responseWrapper.timestamp  = '2020';

		Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessSMPMock());

		HttpResponse response = ifUtil.webCallout('{"data":"data"}');
		ifUtil.setLogList(testLogWrapperList);
		ifUtil.setReturnMessage(response);

		IfUtil.getMapPicklist(new List<String>{'Opportunity'});
		// IfUtil.getEmployeeNumber();

		Test.StopTest();

	}

	static testMethod void testPRSuccess() {

		IFUtil ifUtil = new IFUtil('PR_TEST', 1);

		Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessPRMock());

		HttpResponse response = ifUtil.webCallout('{"data":"data"}');
		ifUtil.setReturnMessage(response);

		Test.StopTest();

	}

	static testMethod void testBulkSuccess() {
		IFUtil ifUtil = new IFUtil('PR_TEST', 1);
		Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessPRMock());
		IFUtil.BulkResponse response = ifUtil.bulkWebCallout('{"data":"data"}');
		Test.StopTest();
	}

	static testMethod void testBulkFail() {
		IFUtil ifUtil = new IFUtil('PR_TEST', 1);
		Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new HttpCalloutResultFailMock());
		IFUtil.BulkResponse response = ifUtil.bulkWebCallout('{"data":"data"}');
		Test.StopTest();
	}

	static testMethod void testResultFail() {

		IFUtil ifUtil = new IFUtil('SMP_TEST');

		Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new HttpCalloutResultFailMock());

		HttpResponse response = ifUtil.webCallout('{"data":"data"}');
		ifUtil.setReturnMessage(response);

		Test.StopTest();
	}

	static testMethod void testResultBodyFail() {

		IFUtil ifUtil = new IFUtil('SMP_TEST');

		Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new HttpCalloutResultBodyFailMock());

		HttpResponse response = ifUtil.webCallout('{"data":"data"}');
		ifUtil.setReturnMessage(response);

		Test.StopTest();
	}

	static testMethod void testCalloutFail() {

		IFUtil ifUtil = new IFUtil('SMP_TEST');

		Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new HttpCalloutFailMock());

		HttpResponse response = ifUtil.webCallout('{"data":"data"}');
		ifUtil.setReturnMessage(response);

		Test.StopTest();
	}

	static testMethod void testResultServerFail() {

		IFUtil ifUtil = new IFUtil('SMP_TEST');

		Test.StartTest();
		Test.setMock(HttpCalloutMock.class, new HttpCalloutResultServerFailMock());

		HttpResponse response = ifUtil.webCallout('{"data":"data"}');
		ifUtil.setReturnMessage(response);

		Test.StopTest();
	}

	@testSetup static void setData() {

		List<IF_Master__c> ifMasterList = new List<IF_Master__c>();
		IF_Master__c objIfMaster = new IF_Master__c();
		objIfMaster.Name = 'SMP_TEST';
		objIfMaster.Endpoint__c = 'https://test.test.com/test'; //23.01.07 이지현 임시 주석 처리
		objIfMaster.Method__c = 'POST';
		objIfMaster.ContentType__c = 'application/json';
		objIfMaster.ParaSuccess__c = 'result';
		objIfMaster.ParaSuccessValue__c = 'success';
		objIfMaster.ParaErrorMessage__c = 'message';
		objIfMaster.ParaAddHeader__c = '{"x-apikey":"MTdFNjS183Gs5DrSabAkSMn12jBswn1n"}';
		objIfMaster.isLogInsert__c = true; //23.03.31 이상재 error로 인한 필드 값 추가
		objIfMaster.IfId__c = 'SMP_TEST'; //23.03.31 이상재 error로 인한 필드 값 추가
        objIfMaster.ApexClass__c = 'TEST';
		ifMasterList.add(objIfMaster);

		objIfMaster = new IF_Master__c();
		objIfMaster.Name = 'PR_TEST';
		objIfMaster.Endpoint__c = 'https://test.test.com/test'; //23.01.07 이지현 임시 주석 처리
		objIfMaster.Method__c = 'POST';
		objIfMaster.ContentType__c = 'application/json';
		objIfMaster.ParaSuccess__c = 'returnMsg';
		objIfMaster.ParaSuccessValue__c = 'success';
		objIfMaster.ParaErrorMessage__c = 'returnMsg';
		objIfMaster.ParaAddHeader__c = '{"x-apikey":"9O1Jgyu9VTfIKEVfZ5deK37y0XpGn7KW","Auth-Token":"RBh8YvfHJx05ylpYGFyKmPFQ4DMqzWVPY5ckjUup","Tenant-Id":"L4500","Src-Name":"pipeline"}';
		objIfMaster.isLogInsert__c = true; //23.03.31 이상재 error로 인한 필드 값 추가
		objIfMaster.IfId__c = 'PR_TEST'; //23.03.31 이상재 error로 인한 필드 값 추가
        objIfMaster.ApexClass__c = 'TEST';
		ifMasterList.add(objIfMaster);

		insert ifMasterList;
	}

	private static HTTPResponse successSMPResponse(Integer statusCode) {
		HttpResponse response = new HttpResponse();
        
        
		
		response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);

		String reponseBody = '{ "result":"success"'
			+ ', "message":""'
			+ ', "timestamp":"2020-05-07T09:30:49.795"'
			+ '}';

		response.setBody(reponseBody);

		return response;

	}

	private static HTTPResponse successPRResponse(Integer statusCode) {
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setStatusCode(statusCode);

		String reponseBody = '{ "returnMsg":"success"'
			+ ', "message":""'
			+ ', "timestamp":"2020-05-07T09:30:49.795"'
			+ '}';

		response.setBody(reponseBody);

		return response;

	}

	private static HTTPResponse resultErrorResponse(Integer statusCode) {
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setStatusCode(statusCode);

		String reponseBody = '{"result":"fail","message":"error"}';

		response.setBody(reponseBody);

		return response;
	}

	private static HTTPResponse resultBodyErrorResponse(Integer statusCode) {
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setStatusCode(statusCode);

		String reponseBody = '';

		response.setBody(reponseBody);

		return response;
	}

	private static HTTPResponse resultCalloutErrorResponse(Integer statusCode) {
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setStatusCode(statusCode);

		String reponseBody = '{}';

		response.setBody(reponseBody);

		return response;
	}

	private static HTTPResponse resultServerErrorResponse(Integer statusCode) {
		HttpResponse response = new HttpResponse();
		response.setHeader('Content-Type', 'application/json');
		response.setStatusCode(statusCode);

		String reponseBody = '{,,}';

		response.setBody(reponseBody);

		return response;
	}

	private class HttpCalloutSuccessSMPMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest request) {
			HttpResponse response = successSMPResponse(200);

			return response;
		}
	}

	private class HttpCalloutSuccessPRMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest request) {
			HttpResponse response = successPRResponse(200);

			return response;
		}
	}

	private class HttpCalloutResultFailMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest request) {
			HttpResponse response = resultErrorResponse(200);

			return response;
		}
	}

	private class HttpCalloutResultBodyFailMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest request) {
			HttpResponse response = resultBodyErrorResponse(200);

			return response;
		}
	}

	private class HttpCalloutFailMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest request) {
			HttpResponse response = resultBodyErrorResponse(500);

			return response;
		}
	}

	private class HttpCalloutResultServerFailMock implements HttpCalloutMock {
		public HTTPResponse respond(HTTPRequest request) {
			HttpResponse response = resultServerErrorResponse(200);

			return response;
		}
	}

}