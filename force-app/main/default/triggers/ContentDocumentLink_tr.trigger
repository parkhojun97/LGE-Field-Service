/**
 * Created by sm.yang on 2022-09-17.
 * 커뮤니티에서 게스트 사용자가 파일 업로드 할때 사용한다고 함.(양승민 상무)
 */

trigger ContentDocumentLink_tr on ContentDocumentLink (before insert) {

    System.debug('ContentDocumentLink_tr == START');
    TriggerHandler.runTriggerByCustomMeta(this);
    System.debug('ContentDocumentLink_tr == STOP');

/*
    List<ContentDocumentLink> listCDL = new List<ContentDocumentLink>();
    Set<Id> setIds = new Set<Id>();

    for(ContentDocumentLink obj : Trigger.new){
        setIds.add(obj.ContentDocumentId);
    }

    Map<Id, ContentDocument> mapCD = new Map<Id, ContentDocument>([
        SELECT Id, LatestPublishedVersionId,LatestPublishedVersion.BASIS_CNSL_ID_fileupload__c, LatestPublishedVersion.SWITCH_YN__c
          FROM ContentDocument
         where Id in :setIds
    ]);
    List<ContentVersion> listCV = new List<ContentVersion>();
    Map<String, String> mapCaseInfo = new Map<String, String>();
    for(ContentDocumentLink objCDL : Trigger.new){
        if(mapCD.containsKey(objCDL.ContentDocumentId)){
            ContentDocument obj = mapCD.get(objCDL.ContentDocumentId);
            System.debug(obj);
            if(!obj.LatestPublishedVersion.SWITCH_YN__c && obj.LatestPublishedVersion.BASIS_CNSL_ID_fileupload__c != null){
                ContentDocumentLink objDocumentLink = new ContentDocumentLink();
                objDocumentLink.ContentDocumentId = obj.Id;
                mapCaseInfo = DN_CommonUtil.doDecryptText(obj.LatestPublishedVersion.BASIS_CNSL_ID_fileupload__c);
                objDocumentLink.LinkedEntityId = mapCaseInfo.get('caseId');
                objDocumentLink.ShareType = 'V';
                objDocumentLink.Visibility = 'AllUsers';
                listCDL.add(objDocumentLink);
                listCV.add(new ContentVersion(Id=obj.LatestPublishedVersionId, SWITCH_YN__c=true));
            }
        }
    }

    if(!listCDL.isEmpty()){
        update listCV ;
        insert listCDL;
        publishNotifications(mapCaseInfo);
    }


    public static void publishNotifications(Map<String, String> mapCaseInfo) {
        List<Notice__e> notifications = new List<Notice__e>();
        notifications.add(new Notice__e(recordId__c = mapCaseInfo.get('caseId'), Subject__c='고객 업로드 완료', REFRESH_YN__c=true, UserId__c=mapCaseInfo.get('agentId')));


        List<Database.SaveResult> results = EventBus.publish(notifications);
        system.debug(results);
        // Inspect publishing results
        for (Database.SaveResult result : results) {
            if (!result.isSuccess()) {
                for (Database.Error error : result.getErrors()) {
                    System.debug('Error returned: ' +
                            error.getStatusCode() +' - '+
                            error.getMessage());
                }
            }
        }
    }

 */

}