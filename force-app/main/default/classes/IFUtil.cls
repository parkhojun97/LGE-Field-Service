/******************************************************************
  * File Name   : IFUtil
  * Description : Interface Master 정보를 읽어 로그적재 및 호출정보를 공통으로 관리
  * Author      : sm.yang
  * Modification Log
  * ===============================================================
  * Ver  Date        Author          Modification
  * ===============================================================
    1.0  2022-10-06     sm.yang          Create
    2.0  2023-01-30		jihyun.lee		로직 수정
	3.0  2023-04-20		sungho.jo		bulk 처리 추가
******************************************************************/
global without sharing class IFUtil {

	//public IFCode__c objIFCode = IFCode__c.getOrgDefaults();
	public IF_Master__c objMaster;
	public Boolean isTest = false;
	public Integer recordCount;
	private static IF_LOG__c objIFLog;

	public IFUtil(String ifId) {
		//initIFUtil(ifId, -1);
		System.debug('ifId : ' +  ifId);
		initIFUtil(ifId, 0);
	}

	public IFUtil(String ifId, Integer fRecordCount) {
		initIFUtil(ifId, fRecordCount);
	}

	public void initIFUtil(String ifId, Integer fRecordCount) {
		List<IF_Master__c> listIFMaster = new List<IF_Master__c>();
		IF_Master__c objIFMaster = new IF_Master__c();
		listIFMaster = [
			SELECT Id, Name, Type__c, WebserviceType__c, Method__c, ContentType__c
				, Endpoint__c
				, IsSendParameter__c
				, ParaSuccess__c
				, ParaSuccessValue__c
				, ParaErrorMessage__c
				, ParaAddHeader__c
				, isLogInsert__c
				, IfId__c
				, APIKeyName__c
				, APIKeyValue__c
				, ApexClass__c
			FROM IF_Master__c
			WHERE IfId__c =:ifId
		];
		System.debug('*** listIFMaster: ' + listIFMaster);
		if (listIFMaster.size() > 0) {
			objIFMaster = listIFMaster[0];
			this.objMaster = objIFMaster;
		}
		if(fRecordCount != -1) {
			this.recordCount = fRecordCount;
		}
		else {
			this.recordCount = 0;
		}
	}

	public static void errorDebug(Exception e) {
		System.debug('*** Exception type: ' + e.getTypeName());
		System.debug('*** Message: ' + e.getMessage());
		System.debug('*** Stack trace: ' + e.getStackTraceString());
	}

	public void insertLog(LogWrapper log) {
		System.debug('*** log: ' + log);
		if (objMaster.isLogInsert__c) insert addLog(log);
	}

	public void setLog(LogWrapper logWrapper) {
		insert addLog(logWrapper);
	}

	public IF_LOG__c addLog(LogWrapper logWrapper) {

		Integer subLength = 130000;

		IF_LOG__c objLog = new IF_LOG__c();

		objLog.IF_Master__c 		= this.objMaster.Id;
		if (this.objMaster.ApexClass__c != null) objLog.Name = this.objMaster.ApexClass__c;
		objLog.Status__c 			= logWrapper.status;
		objLog.ErrorCode__c			= logWrapper.errorCode;
		objLog.ErrorMessage__c		= logWrapper.errorMessage <> null ? logWrapper.errorMessage.abbreviate(subLength) : null;
		objLog.RequestTime__c 		= logWrapper.requestTime;
		objLog.RequestHeader__c 	= logWrapper.requestHeader <> null ? logWrapper.requestHeader.abbreviate(subLength) : null;
		objLog.RequestBody__c 		= logWrapper.requestBody <> null ? logWrapper.requestBody.abbreviate(subLength) : null;
		objLog.ResponseTime__c 		= logWrapper.responseTime;
		objLog.ResponseHeader__c 	= logWrapper.responseHeader <> null ? logWrapper.responseHeader.abbreviate(subLength) : null;
		objLog.ResponseBody__c 		= logWrapper.responseBody <> null ? logWrapper.responseBody.abbreviate(subLength) : null;

		if(recordCount != null) objLog.RecordCount__c = recordCount;

		return objLog;

	}

	public void setLogList(List<LogWrapper> logList) {
		List<IF_LOG__c> setLogList = new List<IF_LOG__c>();
		for (LogWrapper objLog : logList) {
			setLogList.add(addLog(objLog));
		}
		if(objMaster.isLogInsert__c) insert setLogList;
	}

	public HttpResponse webCallout(String body) {

		HttpRequest request = new HttpRequest();
		HttpResponse response = new HttpResponse();

		Http http = new Http();

		String status = 'SUCCESS';
		String responseBody;
		String errorCode = '0';
		String errorMessage = '';

		LogWrapper objWrapper = new LogWrapper();
		

		try {

			if(this.objMaster.ParaAddHeader__c!=null) {
				Map<String, Object> mapParaAddHeader = (Map<String, Object>) JSON.deserializeUntyped(this.objMaster.ParaAddHeader__c);
				for(String strKey:mapParaAddHeader.keySet()) {
					request.setHeader(strKey, String.valueOf(mapParaAddHeader.get(strKey)));
				}
			}


			// 2023-01-30 추가 (jihyun.lee)
			if (this.objMaster.APIKeyName__c != null) {
				request.setHeader(this.objMaster.APIKeyName__c, this.objMaster.APIKeyValue__c);
			}
			
			// 공통 설정
			String contentType = this.objMaster.ContentType__c;
			request.setEndpoint(this.objMaster.Endpoint__c);
			request.setMethod(this.objMaster.Method__c);
			request.setHeader('Content-Type', contentType);
			
			// 2023-10-11 추가
			if (this.objMaster.ApexClass__c.equals('IF_CM_SFDC_KAKAO')) {
				HF_HttpCalloutOrgCache.APIMAuthInfo apimAuthInfo = HF_HttpCalloutSender.auth();
				request.setHeader('Authorization', 'Bearer ' + apimAuthInfo.access_token); 
			}
			request.setTimeout(120000);


			//request.setBody를 할 경우 Method GET으로 설정을 해도 실제로는 POST로 전송되기 때문에 분기처리
			if( String.isNotBlank(body) ) {
				request.setHeader('Content-Length', String.valueOf(body.length()));
				objWrapper.requestBody = body;
				request.setBody(body);
				System.debug('*** body: ' + body);
			}
			objWrapper.requestTime = Datetime.now();
			System.debug('*** request: ' + request);
			response = http.send(request);
			responseBody = response.getBody();
			System.debug(' responseBody : ' + responseBody);
			System.debug(' getStatusCode : ' + response.getStatusCode());
			if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {

				objWrapper.responseTime = Datetime.now();
				objWrapper.responseBody = responseBody;

				if(responseBody <> null && responseBody != '') {
					if(this.objMaster.ParaSuccess__c!=null) {
						Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
						if(mapResponse.get(this.objMaster.ParaSuccess__c)!=this.objMaster.ParaSuccessValue__c) {
							status = 'ERROR';
							errorCode = 'RESULT_FAIL';
							if(mapResponse.get(this.objMaster.ParaErrorMessage__c)!=null) errorMessage = String.valueOf(mapResponse.get(this.objMaster.ParaErrorMessage__c));
						}
					}

				} else {
					objWrapper.responseBody = 'Not ResponseBody';
				}

			} else {
				status = 'ERROR';
				errorCode = 'CALLOUT_FAIL_ERROR STATUS:' + String.valueOf(response.getStatusCode()) + ', STATUS:'+ response.getStatus();
				errorMessage = response.getBody();
			}
		} catch(Exception e) {
			status = 'ERROR';
			errorCode = 'SFDC_SERVER_ERROR';
			errorMessage = e.getMessage()+' Line : '+e.getLineNumber();
		}

		objWrapper.status 			= status;
		objWrapper.errorCode 		= errorCode;
		objWrapper.errorMessage 	= errorMessage;

		if(objMaster.isLogInsert__c) setLog(objWrapper);
		return response;
	}

	/**
	 * @description (REST API) Input Param 설정. 해당 API의 Parameter를 매핑하는 Class를 호출
	 * @param ifId String       IF_Master__c의 IfId__c
	 * @return Map<String, Object>  Body에 전송할 Parameter
	 */
	public static Map<String, Object> setInputParam(String ifId) {
		Map<String, Object> data = new Map<String, Object>();
		List<IF_Master__c> listIFMaster = [SELECT Id FROM IF_Master__c WHERE IfId__c =:ifId];
		if (listIFMaster.size() > 0) {
			List<IF_Detail__c> listIFDetail = new List<IF_Detail__c>();
			listIFDetail = [
					SELECT Id, Name, IF_Master__c, Value__c	
					FROM IF_Detail__c
					WHERE IF_Master__c =:listIFMaster[0].Id
			];
			if (listIFDetail.size() > 0) {
				for (IF_Detail__c detail : listIFDetail) {
					data.put(detail.Name, detail.Value__c);
				}
				return data;
			} else {
				return null;
			}
		} else {
			return null;
		}
	}

	public Map<String, Map<String, Map<String, String>>> getMapPicklist(List<String> lstSObjectType) {

		Map<String, SObjectType> globalDescribe = Schema.getGlobalDescribe();

		Map<String, Map<String, Map<String, String>>> objMap = new Map<String, Map<String, Map<String, String>>>();
		Map<String, Map<String, String>> fieldMap = new Map<String, Map<String, String>>();
		Map<String, String> pickListMap = new Map<String, String>();

		for(String sObjectType : lstSObjectType){
			// System.debug('object : ' + sObjectType);
			fieldMap = new Map<String, Map<String, String>>();
			DescribeSObjectResult describeResult = globalDescribe.get(sObjectType).getDescribe();
			Map<String, Schema.SObjectField> desribedFields = describeResult.fields.getMap();
			for(String fieldName : desribedFields.keySet()){
				Schema.SObjectField field = desribedFields.get(fieldName);
				Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
				if('PICKLIST'.equals(String.valueOf(fieldDescribe.getType()))){
					// System.debug('   fieldName : ' + fieldName);
					pickListMap = new Map<String, String>();
					for(Schema.PicklistEntry pick : field.getDescribe().getPickListValues()){
						pickListMap.put(pick.getLabel(), pick.getValue());
						// System.debug('      pickName : ' + pick.getLabel());
					}
					fieldMap.put(fieldName,pickListMap);
					// System.debug(fieldMap);
				}
			}
			objMap.put(sObjectType,fieldMap);
		}

		return objMap;

	}

	public void logInit(LogWrapper log) {
		// objIFLog = new IF_LOG__c();
		// timeTemp = System.currentTimeMillis();
		// objIFLog.Request_to_dit_time = datetime.new
		// if (objMaster.isLogInsert__c) setLog(objWrapper);
	}

	public String setReturnMessage(HttpResponse response) {
		String returnMessage = '';
		String responseBody = response.getBody();
		// System.debug('responseBody ==> ' + responseBody);
		try {
			if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {
				if(responseBody <> null && responseBody != '') {
					if(this.objMaster.ParaSuccess__c!=null) {
						Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
						if(mapResponse.get(this.objMaster.ParaSuccess__c)!=this.objMaster.ParaSuccessValue__c) {
							if(mapResponse.get(this.objMaster.ParaErrorMessage__c)!=null) returnMessage = '[RESULT_FAIL] ' + String.valueOf(mapResponse.get(this.objMaster.ParaErrorMessage__c));

						}
					}
				} else {
					returnMessage = '[RESULT_FAIL] Not ResponseBody';
				}
			} else {
				returnMessage = '[CALLOUT_FAIL_ERROR] STATUS:' + String.valueOf(response.getStatusCode()) + ', STATUS:'+ response.getStatus();
			}
		} catch(Exception e) {
			String systemError = e.getMessage() + ' Line : ' + e.getLineNumber();
			returnMessage = '[SFDC_SERVER_ERROR] ' + systemError;
		}
		return returnMessage;
	}

	global class ResponseWrapper {

		global String result {get;set;}			// success/fail
		global Integer resultCount {get;set;}
		global String path {get;set;}			// 요청 url
		global String message {get;set;}		// fail시 설명 메시지
		global String timestamp {get;set;}		// 요청 시간

		global responseWrapper() {}

	}

	public class LogWrapper {

		public String ifId;

		public String status;
		public String errorCode;
		public String errorMessage;

		public Datetime requestTime;
		public String requestHeader;
		public String requestBody;

		public Datetime responseTime;
		public String responseHeader;
		public String responseBody;

		public LogWrapper() {}

		// 최초 Request 데이터까지 생성
		public LogWrapper(String ifId, String requestHeader, String requestBody) {
			this.ifId 				= ifId;
			this.requestTime 		= System.now();
			this.requestHeader 		= requestHeader;
			this.requestBody 		= requestBody;
		}
	}

	
	/**
	* @description 카톡 배열처리를 위한 log 리턴용 추가 - jsh
	*/
	public class BulkResponse {
		public HttpResponse httpResponse;
		public IF_LOG__c log;

		public BulkResponse(){
			this.log = new IF_LOG__c();
		}
		public void setRes(HttpResponse response, IF_LOG__c log ){
			this.httpResponse = response;
			this.log 		  = log;
		}
	}

	/**
	* @param String body
	* @return BulkResponse
	* @description 호출 쪽 다건 처리를 위해 log를 해당 method에서 생성하지 않고 리턴함.
	*/
	public BulkResponse bulkWebCallout(String body) {
		BulkResponse res = new BulkResponse();
		HttpRequest request = new HttpRequest();
		HttpResponse response = new HttpResponse();

		Http http = new Http();

		String status = 'SUCCESS';
		String responseBody;
		String errorCode = '0';
		String errorMessage = '';

		LogWrapper objWrapper = new LogWrapper();
		try {
			if(this.objMaster.ParaAddHeader__c!=null) {
				Map<String, Object> mapParaAddHeader = (Map<String, Object>) JSON.deserializeUntyped(this.objMaster.ParaAddHeader__c);
				for(String strKey:mapParaAddHeader.keySet()) {
					request.setHeader(strKey, String.valueOf(mapParaAddHeader.get(strKey)));
				}
			}

			if (this.objMaster.APIKeyName__c != null) {
				request.setHeader(this.objMaster.APIKeyName__c, this.objMaster.APIKeyValue__c);
			}

			// 공통 설정
			String contentType = this.objMaster.ContentType__c;
			request.setHeader('Content-Type', contentType);
			
			request.setEndpoint(this.objMaster.Endpoint__c);
			request.setMethod(this.objMaster.Method__c);

			// 2023-10-11 추가
			if (this.objMaster.ApexClass__c.equals('IF_CM_SFDC_KAKAO')) {
				HF_HttpCalloutOrgCache.APIMAuthInfo apimAuthInfo = HF_HttpCalloutSender.auth();
				request.setHeader('Authorization', 'Bearer ' + apimAuthInfo.access_token); 
			}
			
			request.setTimeout(120000);
			if( String.isNotBlank(body) ) {
				request.setHeader('Content-Length', String.valueOf(body.length()));
				objWrapper.requestBody = body;
				request.setBody(body);
				System.debug('*** body: ' + body);
			}
			objWrapper.requestTime = Datetime.now();
			System.debug('*** request: ' + request);
			response = http.send(request);
			responseBody = response.getBody();

			if(response.getStatusCode() == 200 || response.getStatusCode() == 201) {

				objWrapper.responseTime = Datetime.now();
				objWrapper.responseBody = responseBody;

				if(responseBody <> null && responseBody != '') {
					if(this.objMaster.ParaSuccess__c!=null) {
						Map<String, Object> mapResponse = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
						if(mapResponse.get(this.objMaster.ParaSuccess__c)!=this.objMaster.ParaSuccessValue__c) {
							status = 'ERROR';
							errorCode = 'RESULT_FAIL';
							if(mapResponse.get(this.objMaster.ParaErrorMessage__c)!=null) errorMessage = String.valueOf(mapResponse.get(this.objMaster.ParaErrorMessage__c));
						}
					}
				} else {
					objWrapper.responseBody = 'Not ResponseBody';
				}

			} else {
				status = 'ERROR';
				errorCode = 'CALLOUT_FAIL_ERROR STATUS:' + String.valueOf(response.getStatusCode()) + ', STATUS:'+ response.getStatus();
				errorMessage = response.getBody();
			}
		} catch(Exception e) {
			status = 'ERROR';
			errorCode = 'SFDC_SERVER_ERROR';
			errorMessage = e.getMessage()+' Line : '+e.getLineNumber();
		}
		objWrapper.status 			= status;
		objWrapper.errorCode 		= errorCode;
		objWrapper.errorMessage 	= errorMessage;
		res.setRes(response, addLog(objWrapper));
		return res;

	}
}