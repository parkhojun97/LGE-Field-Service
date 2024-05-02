@IsTest
public class EX_ReturnConfirmQueueableMessage_ts {
    @TestSetup
    static void setup(){
        Test.startTest();
        EX_TestDataUtil.getReturnOrderLineItem(true);

        ReturnOrder ro = [SELECT Id, Order_Number__c FROM ReturnOrder LIMIT 1];
        ro.Order_CHNL_TYPE_Code__c = 'V';
        ro.CONSIGNEE_Name__c = '테스트유저';
        ro.CONSIGNEE_TPNO_1__c = '010-1234-5678';
        update ro;
        
        

        List<EX_Message__c> msgList = new List<EX_Message__c>();
       

    
        EX_Message__c msg = new EX_Message__c();

        msg.Label1__c = ro.CONSIGNEE_Name__c;
        msg.Label2__c = ro.Order_Number__c;
        msg.Label3__c = '테스트part';
        
        insert msg;

        TemplateMgmt__c tmgt = new TemplateMgmt__c();
        tmgt.Content_c__c = 'teststests';
        tmgt.Title__c = 'testsetse';
        tmgt.TemplateCode__c = 'SVC_LGE_MACN_012_01';
        TemplateMgmt__c tm2 = tmgt.clone(false);
        tm2.TemplateCode__c = 'SVC_LGE_MACN_011';
        TemplateMgmt__c tm3 = tmgt.clone(false);
        tm3.TemplateCode__c = 'SVC_LGE_MACN_030';
        TemplateMgmt__c tm4 = tmgt.clone(false);
        tm4.TemplateCode__c = 'SVC_LGE_MACN_031';
        TemplateMgmt__c tm5 = tmgt.clone(false);
        tm5.TemplateCode__c = 'SVC_LGE_MACN_S012';
        TemplateMgmt__c tm6 = tmgt.clone(false);
        tm6.TemplateCode__c = 'SVC_LGE_MACN_S011';
        insert new List<TemplateMgmt__c>{tmgt, tm2, tm3, tm4, tm5,tm6};


        TemplateParams__c tprm = new TemplateParams__c();
        tprm.TemplateMgmt__c = tmgt.Id;
        TemplateParams__c tp2 = tprm.clone(false);
        tp2.TemplateMgmt__c = tm2.Id;
        TemplateParams__c tp3 = tprm.clone(false);
        tp3.TemplateMgmt__c = tm3.Id;
        TemplateParams__c tp4 = tprm.clone(false);
        tp4.TemplateMgmt__c = tm4.Id;
        TemplateParams__c tp5 = tprm.clone(false);
        tp5.TemplateMgmt__c = tm5.Id;
        TemplateParams__c tp6 = tprm.clone(false);
        tp6.TemplateMgmt__c = tm6.Id;
        insert new List<TemplateParams__c>{tprm, tp2, tp3, tp4, tp5, tp6};

        EX_Message__c exMessage = new EX_Message__c();
        exMessage.Label1__c = 'test';
        exMessage.Label2__c = 'test';
        insert exMessage;


        Test.stopTest();
    }

    @IsTest
    static void test01() {
        
       

        EX_Message__c msg = [SELECT Id FROM EX_Message__c LIMIT 1];
        ReturnOrder ro = [SELECT CONSIGNEE_TPNO_1__c FROM ReturnOrder LIMIT 1];

        List<EX_Message__c> exObjIdList = new List<EX_Message__c>();
        exObjIdList.add(msg);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HttpCalloutSuccessMock());
        
        // EX_ReturnConfirmQueueableMessage rcfqm = new EX_ReturnConfirmQueueableMessage(ro, exObjIdList);

    
            
        // Database.executeBatch(new EX_ReturnConfirmQueueableMessage(ro, exObjIdList));
        System.enqueueJob(new EX_ReturnConfirmQueueableMessage(ro, exObjIdList));
            // Database.executeBatch(rcfqm,1);


        Test.stopTest();
      

    }

    
    // StatusCode=200 Mock
    private class HttpCalloutSuccessMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = newResponse(200, req.getEndpoint());
            return res;
        }
    }
    // HTTPResponse 객체 생성
    private static HTTPResponse newResponse(Integer statusCode, String endpoint) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        if (endpoint.startsWith('https://eapi.singlex.com/lg/cic/ws/empinfo/search')) {
            res.setBody('{  }');
        } else if (endpoint.equalsIgnoreCase('https://eapi.singlex.com/scs/msg/api/v1/talk')) {
            res.setBody('{ "resultCount" : "1", "result" : "success", "message":"Success"}');
        } else if (endpoint.contains('www.test.com')) {
            res.setBody('{ "resultCount" : "1", "result" : "success", "message":"Success"}');
        } else if (endpoint.contains('/tooling/query/?q=Select+Metadata,Id+FROM+GlobalValueSet+WHERE+DeveloperName=%27')) {
            res.setBody('{ "records" : [ { "Metadata" : { "customValue" : [ { "isActive" : true, "label" : "005", "valueName" : "005"} ] } } ] }');
        } else {
            res.setBody('{ "Header" : {"rstType" : "test", "rstMsg" : "test" } , "Body" : { "data" : [ { "partNo" : "test", "divCode" : "test","PartNameKor" : "test","ObsSalesYN" : "Y", "ObsImageURL" : "testt","ObsSalesURL" : "test", "ObsMemberPrice" : 3000 } ] } } ');
        }

        return res;
    }

}