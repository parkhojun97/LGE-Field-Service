/**
 * Created by I2MAX.SEOKHOLEE  on 2023-05-16.
 */


/*
    일회성 배치 / 소모품 Mig 데이터 Contact Mapping
    Database.executeBatch(new EX_ContactMapping_ba(), 50);
 */
public without sharing class EX_ContactMapping_ba implements Database.Batchable<SObject>, Database.Stateful {

    String SObjectType = null;
    Boolean isMig = null;
    Integer queryLimit = null;
    
    Set<String> recordIdSet = new Set<String>();
    List<String> contactDupCheck = new List<String>();
    List<String> contactDupCheckWithNoZipNo = new List<String>();
    
    public EX_ContactMapping_ba(String sobjType, Boolean isMig, Integer queryLimit, Set<String> recordIdSet){
        this.SObjectType = sobjType;
        this.isMig = isMig;
        this.recordIdSet = recordIdSet;

        if(queryLimit != null && queryLimit>50000){
            this.queryLimit = 50000;    
        }else{
            this.queryLimit = queryLimit;
        }
    }

    public EX_ContactMapping_ba() {
        // this.SObjectType = 'ProductRequest';
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {

        System.debug('속도측정 -------------------------------------------------- EX_ContactMapping_ba 시작 '+SObjectType+'  '+ System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));
        System.debug('Query Limit :: '+queryLimit);

        String query = ' SELECT ';

        if(SObjectType == 'ProductRequest') {
            query += 'Order_CUST_Id__c, Order_Date__c, ';
        } else {
            query += 'ContactId, ProductRequest.Order_Date__c, ';
        }
        query += 'Id, Order_CHNL_TYPE_Code__c, Order_CUST_Name__c, Order_CUST_TPNO_1__c, Order_CUST_TPNO_2__c, Order_CUST_Address__c, Order_CUST_Address_DETAIL__c, Order_CUST_PostalCode__c ';
        query += ' FROM  ' + SObjectType;
        if(recordIdSet != null){
            query += ' WHERE Id IN :recordIdSet '; 
        }else{
            query += ' WHERE isMig__c =: isMig ';
            query += ' AND RecordType.DeveloperName IN (\'Consumable\') '; 
            if(SObjectType == 'ProductRequest') {
                query += ' AND Order_CUST_Id__c = NULL AND Order_CUST_Name__c != null AND (Order_CUST_TPNO_1__c != null OR Order_CUST_TPNO_2__c != null) ';
            } else {
                query += ' AND ContactId = NULL AND Order_CUST_Name__c != null AND (Order_CUST_TPNO_1__c != null OR Order_CUST_TPNO_2__c != null) ';
            }
        }



        query += ' order by CreatedDate desc ';

        if(queryLimit != null){
            query += ' LIMIT  : queryLimit';
        }else{
            query += ' LIMIT 500';
        }
        
        System.debug('SObjectType -> ' + SObjectType);
        System.debug(query);

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Sobject> sObjects) {
        Map<String, Object> mapIbInfo;

        CM_CommonUtil cmUtil = new CM_CommonUtil();

        System.debug('SObjectType -> '+ SObjectType);
        System.debug('sObjects -> '+ sObjects);

        // Map<String, String> mapNameAndPhone = new Map<String, String>();
        Set<String> idSet = new Set<String>();
        List<String> itemSet = new List<String>();

        if(sObjects.size()>0){

            List<Map<String,Object>> conMapList = new List<Map<String,Object>>();

            for (Integer i = 0; i<sObjects.size(); i++) {
                Map<String,Object> paramMap = new Map<String,Object>();
                
                String item = String.valueOf(sObjects[i].get('Order_CUST_Name__c'));

                // 전화번호1
                if(String.valueOf(sObjects[i].get('Order_CUST_TPNO_1__c')) != null && String.valueOf(sObjects[i].get('Order_CUST_TPNO_1__c')) != '') {
                    String checkTelNoValidMessage = cmUtil.checkValidTelNo(String.valueOf(sObjects[i].get('Order_CUST_TPNO_1__c')));
                    if(!String.isEmpty(checkTelNoValidMessage)) {
                        // // 전화번호가 유호 하지 않는 경우 처리 케이스.
                        // throw new AuraHandledException('전화번호 유효성 검사');
                        item += '^전화번호실패';
                        
                    } else { 
                        item += '^'+ DN_CommonUtil.setTelnumFormat(String.valueOf(sObjects[i].get('Order_CUST_TPNO_1__c')));
                    }   
                } else {
                    item += '^';
                }

                // 전화번호2
                if(String.valueOf(sObjects[i].get('Order_CUST_TPNO_2__c')) != null && String.valueOf(sObjects[i].get('Order_CUST_TPNO_2__c')) != '') {
                    String checkTelNoValidMessage = cmUtil.checkValidTelNo(String.valueOf(sObjects[i].get('Order_CUST_TPNO_2__c')));
                    if(!String.isEmpty(checkTelNoValidMessage)) {
                        // // 전화번호가 유호 하지 않는 경우 처리 케이스.
                        // throw new AuraHandledException('전화번호 유효성 검사');
                        item += '^전화번호실패';
                    }else {
                        item += '^' + DN_CommonUtil.setTelnumFormat(String.valueOf(sObjects[i].get('Order_CUST_TPNO_2__c')));
                    }
                } else {
                    item += '^';
                }

                //주소
                if (sObjects[i].get('Order_CUST_Address__c') != null && sObjects[i].get('Order_CUST_Address__c') != '') {
                    item += '^' + sObjects[i].get('Order_CUST_Address__c');
                } else {
                    item += '^';
                }
                // 상세주소
                if (sObjects[i].get('Order_CUST_Address_DETAIL__c') != null && sObjects[i].get('Order_CUST_Address_DETAIL__c') != '') {
                    item += '^' + sObjects[i].get('Order_CUST_Address_DETAIL__c');
                } else {
                    item += '^';   
                }

                // 우편번호
                if (sObjects[i].get('Order_CUST_PostalCode__c') != null && sObjects[i].get('Order_CUST_PostalCode__c') != '' && String.valueOf(sObjects[i].get('Order_CHNL_TYPE_Code__c')) != 'B') {
                    item += '^' + sObjects[i].get('Order_CUST_PostalCode__c');
                } else {
                    item += '^';  
                }
                if(SObjectType == 'ProductRequest') {
                    if (sObjects[i].get('Order_Date__c') != null && sObjects[i].get('Order_Date__c') != '') {
                        item += '^' + sObjects[i].get('Order_Date__c');
                    } else {
                        item += '^';
                    }
                }else{
                    ReturnOrder roTemp = (ReturnOrder) sObjects[i];
                    if(roTemp.ProductRequest.Order_Date__c != null){
                        item += '^' + String.valueOf(roTemp.ProductRequest.Order_Date__c);
                    }else{
                        item += '^';
                    }
                    // if (sObjects[i].get('ProductRequest.Order_Date__c') != null && sObjects[i].get('ProductRequest.Order_Date__c') != '') {
                    //     item += '^' + sObjects[i].get('ProductRequest.Order_Date__c');
                    // } else {
                    //     item += '^';
                    // }
                }


                if (sObjects[i].get('Id') != null && sObjects[i].get('Id') != '') {
                    item += '^' + sObjects[i].get('Id');
                } else {
                    item += '^';
                }


                itemSet.add(item);

                

            }

            Map<String,Map<String, Object>> paramMapList = new Map<String,Map<String, Object>>();
            
            for(String item : itemSet){
                
                Map<String, Object> paramMap = new Map<String, Object>();
                List<String> itemList = item.split('\\^');
                paramMap.put('contactName' , String.valueOf(itemList[0]));
                paramMap.put('inboundNo' , String.valueOf(itemList[1]));
                paramMap.put('inboundNo2' , String.valueOf(itemList[2]));
                
                if(String.valueOf(itemList[5]) != null && String.valueOf(itemList[5]) != ''){
                    // paramMap.put('fAddress' , String.valueOf(itemList[3]) + ' ' + String.valueOf(itemList[4]));
                    // paramMap.put('fAddress' , String.valueOf(itemList[3]));
                    paramMap.put('detailAddress' , String.valueOf(itemList[4]));
                    paramMap.put('zipNo' , String.valueOf(itemList[5]));
                }
                
                paramMap.put('isMig' , 'Y');
                paramMap.put('usePersonalInfo' , 'Y');
                paramMap.put('firstConsentDate' , String.ValueOf(itemList[6].replace('-', '').replace(':','').replace(' ', '')));
                paramMap.put('lastConsentDate' , String.ValueOf(itemList[6].replace('-', '').replace(':','').replace(' ', '')));
                paramMap.put('receiptDate' , String.ValueOf(itemList[6].replace('-', '').replace(':','').replace(' ', '')));


                System.debug('paramMap ??? ' + paramMap);
                System.debug('paramMapJson ??? ' + JSON.serialize(paramMap));
                

                //23 11 08 hyungho.chun inboundNo 1,2 둘중 하나도없는 경우는 여기까지 오지 않는다.
                if(paramMap.get('inboundNo') != null && paramMap.get('inboundNo') != '' && paramMap.get('inboundNo') != '전화번호실패' ){
                    String saveKey = String.valueOf(paramMap.get('contactName'))+String.valueOf(paramMap.get('inboundNo'));
                    if(paramMap.containsKey('zipNo') && String.valueOf(paramMap.get('zipNo')).length()==5){
                        saveKey += String.valueOf(paramMap.get('zipNo'));
                        if(!contactDupCheck.contains(saveKey)){
                            paramMapList.put(String.valueOf(itemList[7]),paramMap);
                            contactDupCheck.add(saveKey);
                        }
                    }else if (!paramMap.containsKey('zipNo')) {
                        if(!contactDupCheckWithNoZipNo.contains(saveKey)){
                            paramMapList.put(String.valueOf(itemList[7]),paramMap);
                            contactDupCheckWithNoZipNo.add(saveKey);
                        }
                    }
                }else if(paramMap.get('inboundNo2') != null && paramMap.get('inboundNo2') != '' && paramMap.get('inboundNo2') != '전화번호실패' ){
                    String saveKey = String.valueOf(paramMap.get('contactName'))+String.valueOf(paramMap.get('inboundNo2'));
                    if(paramMap.containsKey('zipNo') && String.valueOf(paramMap.get('zipNo')).length()==5){
                        saveKey += String.valueOf(paramMap.get('zipNo'));
                        if(!contactDupCheck.contains(saveKey)){
                            paramMapList.put(String.valueOf(itemList[7]),paramMap);
                            contactDupCheck.add(saveKey);
                        }
                    }else if (!paramMap.containsKey('zipNo')){
                        if(!contactDupCheckWithNoZipNo.contains(saveKey)){
                            paramMapList.put(String.valueOf(itemList[7]),paramMap);
                            contactDupCheckWithNoZipNo.add(saveKey);
                        }
                    }
                }
                else{
                    System.debug('주문에 넣어진 전화번호가 옳바르지 않습니다');
                }

                
                


            }
                System.debug('paramMapList :: '+paramMapList);
                System.debug('contactDupCheck :: '+contactDupCheck);
                System.debug('contactDupCheckWithNoZipNo :: '+contactDupCheckWithNoZipNo);

                System.enqueueJob(new EX_ContactMapping_qa(paramMapList, sObjects));


    


    }

        System.debug('속도측정 -------------------------------------------------- EX_ContactMapping_ba 끝 '+SObjectType+'  '+ System.now().format('yyyy-MM-dd HH:mm:ss.SSS'));


    }
    public void finish(Database.BatchableContext bc) {
        System.debug('================== EX_ContactMapping_ba Finish ===================');
        if(SObjectType == 'ProductRequest') {
            // Database.executeBatch(new EX_ContactMapping_ba('ReturnOrder',true),200);
        }
    }
}