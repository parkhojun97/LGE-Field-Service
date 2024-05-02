/**
 * Created by I2MAX.SEUNGHUNAN on 2023-05-23.
 */

public with sharing class EX_ReturnReceiptQueueable implements Queueable, Database.AllowsCallouts {
    // public final String templateCode = 'SVC_LGE_MACN_030';
    public final String templateCode = 'SVC_LGE_MACN_030_1'; //24 02 16 hyungho.chun 개행추가로 템플릿 코드 수정
    public List<ReturnOrder> roList = null;
    public Map<String, List<EX_Message__c>> roIdKakaoMessageListMap = null;
    public List<IF_CM_SFDC_KAKAO.InputParam> params = null;
    public Map<String, TemplateMgmt__c> tmplCodeTmplMap = null;
    public Map<String, List<TemplateParams__c>> tmplIdTmplParamListMap = null;

    /**
     *  fixme: EX_MessageUtil로 이식고려
     *  본래 기존 EX_MessageUtil을 사용하려 하였으나 유틸 작성 때까지는 단건 밖에 요건이 없었는데
     *  반품접수 알림톡이 추가로 Bulk 처리가 필요하여 전처리 과정을 Bulk 메서드로 작성
     */
    public void setUpBeforeExecuteForBulk() {
        Set<String> tmplIdSet = new Set<String>();
        List<TemplateParams__c> tParamList = null;
        List<TemplateMgmt__c> templateList = [
                SELECT Id, TemplateCode__c, Content_c__c
                FROM TemplateMgmt__c
                WHERE TemplateCode__c =: templateCode
        ];
        for (TemplateMgmt__c tmpl : templateList) {
            if (!tmplCodeTmplMap.containsKey(tmpl.TemplateCode__c)) {
                tmplCodeTmplMap.put(tmpl.TemplateCode__c, tmpl);
            }
            tmplIdSet.add(tmpl.Id);
        }
        List<TemplateParams__c> templateParamList = [
                SELECT Id, Name, FieldApi__c, TemplateMgmt__c
                FROM TemplateParams__c
                WHERE TemplateMgmt__c IN :tmplIdSet
        ];
        for (TemplateParams__c tmplParam : templateParamList) {
            tParamList = tmplIdTmplParamListMap.containsKey(tmplParam.TemplateMgmt__c)
                    ? tmplIdTmplParamListMap.get(tmplParam.TemplateMgmt__c)
                    : new List<TemplateParams__c>();

            tParamList.add(tmplParam);
            tmplIdTmplParamListMap.put(tmplParam.TemplateMgmt__c, tParamList);
        }
    }

    public EX_ReturnReceiptQueueable(List<ReturnOrder> roList, Map<String, List<EX_Message__c>> roIdKakaoMessageListMap) {
        this.roList = roList;
        this.roIdKakaoMessageListMap = roIdKakaoMessageListMap;
        this.params = new List<IF_CM_SFDC_KAKAO.InputParam>();
        this.tmplCodeTmplMap = new Map<String, TemplateMgmt__c>();
        this.tmplIdTmplParamListMap = new Map<String, List<TemplateParams__c>>();
    }

    public void execute(QueueableContext context) {
        System.debug('roList : ' + roList);
        System.debug('roIdKaKaoMessageListMap : ' + roIdKakaoMessageListMap);
        System.debug('param : ' + params);
        setUpBeforeExecuteForBulk();

        try {
            for (ReturnOrder ro : roList) {
                if (!roIdKakaoMessageListMap.containsKey(ro.Id)) return;
                for (EX_Message__c exObj : roIdKakaoMessageListMap.get(ro.Id)) {
                    TemplateMgmt__c template = tmplCodeTmplMap.get(templateCode);
                    List<TemplateParams__c> templateParamList = tmplIdTmplParamListMap.get(template.Id);

                    Map<String, Object> populateMap = exObj.getPopulatedFieldsAsMap();
                    IF_CM_SFDC_KAKAO.InputParam inputParam = EX_MessageUtil.getInputParamForKaKao(template, templateParamList, populateMap);
                    inputParam.smsTitle = '카카오 알림톡 대체';
                    inputParam.smsMsg = inputParam.kakaoMsg;
                    inputParam.setPhoneNumber = new Set<String>{
                            ro.Order_CUST_TPNO_1__c != null
                                    ? ro.Order_CUST_TPNO_1__c
                                    : ro.Order_CUST_TPNO_2__c
                    };
                    if (!EX_MessageUtil.isBusinessHours()) {
                        inputParam.sendAt = EX_MessageUtil.getNearSendDatetime();
                    }
                    params.add(inputParam);
                }
            }

            IF_CM_SFDC_KAKAO.BulkResult kakaoBulkResult = IF_CM_SFDC_KAKAO.doBulkSendKakao(params);
            System.debug('bulkResult :: ' + kakaoBulkResult);
        } catch(Exception e) {
            System.debug(e.getLineNumber() + ' line : ' + e.getMessage());
        }
    }
}