/**
 * @description       : 
 * @author            : hyungho.chun@dkbmc.com
 * @group             : 
 * @last modified on  : 11-16-2023
 * @last modified by  : hyungho.chun@dkbmc.com
**/
public with sharing class EX_ContactMapping_qa  implements Queueable{

    Map<String,Map<String, Object>> paramMapList;
    List<Sobject> sObjects;
    // @TestVisible
    // Set<String> failPrliIdSet;
    public EX_ContactMapping_qa() {

    }

    public EX_ContactMapping_qa(Map<String,Map<String, Object>> paramMapList , List<Sobject> sObjects) {
        System.debug(' ========== EX_ContactMapping_qa ========== ');
        this.paramMapList = paramMapList;
        this.sObjects = sObjects;
    }
    
    @TestVisible
    public void execute(QueueableContext context) {
    System.debug('속도측정 -------------------------------------------------- EX_ContactMapping_qa 시작 ' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

        System.debug('Contact param Value ?? ' + paramMapList);

        // Map<String,String> recordIdConMap = new Map<String,String>();
        Map<String, String> conIdMap = new Map<String, String>();
        
        for (String key : paramMapList.keySet()) {
                
            // Contact 생성 공동모듈 호출
            Map<String, Object> paramMap = paramMapList.get(key);
            System.debug('paramMap Value ?? ' + paramMap);

            if(paramMap.get('inboundNo2') == '전화번호실패' ){
                paramMap.put('inboundNo2', '');
            }

            if (paramMap.get('inboundNo') != '전화번호실패') {
                Map<String, Object> resultMap = SC_IFUtil.getContactForCM(paramMap);
                String isPostalCode = paramMap.containsKey('zipNo') ? 'Y' : 'N';
                conIdMap.put(String.ValueOf(resultMap.get('contactId')), isPostalCode);
                // if(resultMap.containsKey('contactId') && String.valueOf(resultMap.get('contactId')) != ''){
                //     recordIdConMap.put(key,String.valueOf(resultMap.get('contactId')));
                // }
            }
        }

    System.debug('속도측정 -------------------------------------------------- EX_ContactMapping_qa 1 '+ System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));


    Set<String> roidSet = new Set<String>();

    List<Contact> getConInfoList = [SELECT Id, LastName, MobilePhone, Phone, POSTAL_CODE__c FROM Contact WHERE Id IN: conIdMap.keySet()];

    if (getConInfoList.size() > 0) {
        
        String strPr = 'SELECT Id, Order_CHNL_TYPE_Code__c, Order_CUST_Id__c, Order_CUST_Name__c, Order_CUST_TPNO_1__c, Order_CUST_TPNO_2__c, Order_CUST_PostalCode__c FROM ProductRequest WHERE Order_CUST_Id__c = null AND isMig__c = true AND  ';
        String strRo = 'SELECT Id, Order_CHNL_TYPE_Code__c, ContactId, Order_CUST_Name__c, Order_CUST_TPNO_1__c, Order_CUST_TPNO_2__c, Order_CUST_PostalCode__c FROM ReturnOrder WHERE ContactId = null AND isMig__c = true AND  ';
        strPr +=  '(';   
        strRo +=  '(';
        Integer i = 0;
        for (Contact con : getConInfoList) {
            if(conIdMap.get(con.Id) == 'Y'){
                conIdMap.put(con.LastName + '^' + con.MobilePhone + '^' + con.POSTAL_CODE__c , con.Id);
                conIdMap.put(con.LastName + '^' + con.Phone + '^' + con.POSTAL_CODE__c , con.Id);
            }else{
                conIdMap.put(con.LastName + '^' + con.MobilePhone, con.Id);
                conIdMap.put(con.LastName + '^' + con.Phone, con.Id);
            }

            
            strPr += ' (Order_CUST_Name__c =\''+ con.LastName +'\' AND (Order_CUST_TPNO_1__c = \''+con.MobilePhone +'\' OR Order_CUST_TPNO_2__c = \''+con.MobilePhone +'\' OR Order_CUST_TPNO_1__c = \''+con.Phone +'\' OR Order_CUST_TPNO_2__c = \''+con.Phone+ '\')';
            strRo += ' (Order_CUST_Name__c =\''+ con.LastName +'\' AND (Order_CUST_TPNO_1__c = \''+con.MobilePhone +'\' OR Order_CUST_TPNO_2__c = \''+con.MobilePhone +'\' OR Order_CUST_TPNO_1__c = \''+con.Phone +'\' OR Order_CUST_TPNO_2__c = \''+con.Phone+ '\')';
            if(conIdMap.get(con.Id) == 'Y'){
                strPr += ' AND  Order_CUST_PostalCode__c =\''+con.POSTAL_CODE__c+'\')';
                strRo += ' AND  Order_CUST_PostalCode__c =\''+con.POSTAL_CODE__c+'\')';
            }else{
                strPr += ')';
                strRo += ')';   
            }

            if (i != getConInfoList.size() - 1) {
                strPr += ' OR ';
                strRo += ' OR ';
            }
            i++;


        }
        strPr += ')';
        strRo += ')';  

    
        strPr += ' LIMIT 1000';
        strRo += ' LIMIT 1000';
    
        
        System.debug('strPr :: '+strPr);
        System.debug('strRo :: '+strRo);
    
    
        List<ProductRequest> updatePRList = Database.query(strPr);
        List<ReturnOrder> updateROList = Database.query(strRo);
    
        if (updatePRList.size() > 0) {
            Set<String> pridSet = new Set<String>();
    
            for (ProductRequest updatePr : updatePRList) {
                if (updatePr.Order_CHNL_TYPE_Code__c != 'B' && 
                    (conIdMap.containsKey(updatePr.Order_CUST_Name__c + '^' + updatePr.Order_CUST_TPNO_1__c + '^' + updatePr.Order_CUST_PostalCode__c)
                    || conIdMap.containsKey(updatePr.Order_CUST_Name__c + '^' + updatePr.Order_CUST_TPNO_2__c + '^' + updatePr.Order_CUST_PostalCode__c))
                ) {
                    updatePr.Order_CUST_Id__c = String.ValueOf(conIdMap.get(updatePr.Order_CUST_Name__c + '^' + updatePr.Order_CUST_TPNO_1__c + '^' + updatePr.Order_CUST_PostalCode__c) != null ? 
                    conIdMap.get(updatePr.Order_CUST_Name__c + '^' + updatePr.Order_CUST_TPNO_1__c + '^' + updatePr.Order_CUST_PostalCode__c) : conIdMap.get(updatePr.Order_CUST_Name__c + '^' + updatePr.Order_CUST_TPNO_2__c + '^' + updatePr.Order_CUST_PostalCode__c));
                    pridSet.add(updatePr.Id);
                }else if(
                    conIdMap.containsKey(updatePr.Order_CUST_Name__c + '^' + updatePr.Order_CUST_TPNO_1__c)
                    || conIdMap.containsKey(updatePr.Order_CUST_Name__c + '^' + updatePr.Order_CUST_TPNO_2__c )
                ){
                    updatePr.Order_CUST_Id__c = String.ValueOf(conIdMap.get(updatePr.Order_CUST_Name__c + '^' + updatePr.Order_CUST_TPNO_1__c) != null ? 
                    conIdMap.get(updatePr.Order_CUST_Name__c + '^' + updatePr.Order_CUST_TPNO_1__c) : conIdMap.get(updatePr.Order_CUST_Name__c + '^' + updatePr.Order_CUST_TPNO_2__c));
                    pridSet.add(updatePr.Id);
                }
            }
    
            TriggerHandler.bypass('ProductRequest_tr');
            // Database.SaveResult[] listSr = Database.update(sObjects, false);
            update updatePRList;
            TriggerHandler.clearBypass('ProductRequest_tr');
    
    
            List<ProductRequestlineitem> updatePrliList = [SELECT Order_CUST_Id__c, Parent.Order_CUST_Id__c  FROM ProductRequestlineitem WHERE Parentid IN:pridSet];
    
            for (ProductRequestlineitem updatePrli : updatePrliList) {
                updatePrli.Order_CUST_Id__c = updatePrli.Parent.Order_CUST_Id__c;
            }
    
            TriggerHandler.bypass('ProductRequestLineItem_tr');
            update updatePrliList;
            TriggerHandler.clearBypass('ProductRequestLineItem_tr');
        
        }
       
        if (updateROList.size() > 0) {
            for (ReturnOrder updateRo : updateROList) {
                if (updateRo.Order_CHNL_TYPE_Code__c != 'B' && 
                    (conIdMap.containsKey(updateRo.Order_CUST_Name__c + '^' + updateRo.Order_CUST_TPNO_1__c + '^' + updateRo.Order_CUST_PostalCode__c)
                || conIdMap.containsKey(updateRo.Order_CUST_Name__c + '^' + updateRo.Order_CUST_TPNO_2__c + '^' + updateRo.Order_CUST_PostalCode__c))
                ) {
                    updateRo.ContactId = String.ValueOf(conIdMap.get(updateRo.Order_CUST_Name__c + '^' + updateRo.Order_CUST_TPNO_1__c + '^' + updateRo.Order_CUST_PostalCode__c) != null ? 
                    conIdMap.get(updateRo.Order_CUST_Name__c + '^' + updateRo.Order_CUST_TPNO_1__c + '^' + updateRo.Order_CUST_PostalCode__c) : conIdMap.get(updateRo.Order_CUST_Name__c + '^' + updateRo.Order_CUST_TPNO_2__c + '^' + updateRo.Order_CUST_PostalCode__c));
                    roidSet.add(updateRo.Id);
                }else if(
                    conIdMap.containsKey(updateRo.Order_CUST_Name__c + '^' + updateRo.Order_CUST_TPNO_1__c)
                    || conIdMap.containsKey(updateRo.Order_CUST_Name__c + '^' + updateRo.Order_CUST_TPNO_2__c )
                ) {
                    updateRo.ContactId = String.ValueOf(conIdMap.get(updateRo.Order_CUST_Name__c + '^' + updateRo.Order_CUST_TPNO_1__c) != null ? 
                    conIdMap.get(updateRo.Order_CUST_Name__c + '^' + updateRo.Order_CUST_TPNO_1__c) : conIdMap.get(updateRo.Order_CUST_Name__c + '^' + updateRo.Order_CUST_TPNO_2__c));
                    roidSet.add(updateRo.Id);
                }

            }
    
            TriggerHandler.bypass('ReturnOrder_tr');
            // Database.SaveResult[] listSr = Database.update(sObjects, false);
            update updateROList;
            TriggerHandler.clearBypass('ReturnOrder_tr');
    
    
            List<ReturnOrderlineitem> updateROLIList = [SELECT Order_CUST_Id__c, ReturnOrder.ContactId FROM ReturnOrderlineitem WHERE ReturnOrderId IN:roidSet ];
    
    
            for (ReturnOrderlineitem updateROLI : updateROLIList) {
                updateROLI.Order_CUST_Id__c = updateROLI.ReturnOrder.ContactId;
            }
    
    
            TriggerHandler.bypass('ReturnOrderLineItem_tr');
            update updateROLIList; 
            TriggerHandler.clearBypass('ReturnOrderLineItem_tr');    
    
    
            
        }
    }

    // for (SObject sobj : sObjects){



    //     if(String.valueOf(sObj.getSObjectType()).equals('ProductRequest')){
    //         if (recordIdConMap.containsKey(String.valueOf(sObj.get('Id')))) {
    //             ((ProductRequest) sObj).Order_CUST_Id__c = recordIdConMap.get(String.valueOf(sObj.get('Id')));
    //         }
    //     }else{
    //         if (recordIdConMap.containsKey(String.valueOf(sObj.get('Id')))) {
    //             ((ReturnOrder) sObj).ContactId = recordIdConMap.get(String.valueOf(sObj.get('Id')));
    //         }
    //     }
    // }
    // // update sObjects;
    
    // System.debug('속도측정 -------------------------------------------------- EX_ContactMapping_qa 2 ' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));


    // TriggerHandler.bypass('ProductRequest_tr');
    // TriggerHandler.bypass('ReturnOrder_tr');
    // // Database.SaveResult[] listSr = Database.update(sObjects, false);
    
    // TriggerHandler.clearBypass('ProductRequest_tr');
    // TriggerHandler.clearBypass('ReturnOrder_tr');


    // Set<String> sObjectsIdSet = paramMapList.keySet();
    // String strQry3 = '';
    // strQry3 += 'SELECT Id, Order_CUST_Id__c, ';

    // if(String.valueOf(sObjects[0].getSObjectType()).equals('ProductRequest')){
    //     strQry3 += 'Parent.Order_CUST_Id__c FROM ProductRequestlineitem WHERE Parentid IN: sObjectsIdSet';
    // }else{
    //     strQry3 += 'ReturnOrder.ContactId FROM ReturnOrderlineitem WHERE ReturnOrderId IN: sObjectsIdSet';
    // }

    // List<SObject> lineItem = Database.query(strQry3);
    

    // for(SObject item : lineItem){ 
    //     if(String.valueOf(item.getSObjectType()).equals('ProductRequestLineItem')){
    //         ((ProductRequestLineItem) item).Order_CUST_Id__c = ((ProductRequestLineItem) item).Parent.Order_CUST_Id__c;
    //     }else{
    //         ((ReturnOrderLineItem) item).Order_CUST_Id__c = ((ReturnOrderLineItem) item).ReturnOrder.ContactId;
    //     }
    // }

    // TriggerHandler.bypass('ProductRequestLineItem_tr');
    // TriggerHandler.bypass('ReturnOrderLineItem_tr');
    // update lineItem;
    // TriggerHandler.clearBypass('ProductRequestLineItem_tr');
    // TriggerHandler.clearBypass('ReturnOrderLineItem_tr');    


    

    System.debug('속도측정 -------------------------------------------------- EX_ContactMapping_qa 끝 ' + System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));

    
    // for (Database.SaveResult sr : listSr) {
    //     if (sr.isSuccess()) {
    //         System.debug('Successfully Product Request ID: ' + sr.getId());
    //     }
    //     else {
    //         for(Database.Error err : sr.getErrors()) {
    //             System.debug('The following error has occurred.');
    //             System.debug(err.getStatusCode() + ': ' + err.getMessage());
    //             System.debug('this error: ' + err.getFields());
    //         }
    //     }
    // }


    }
}