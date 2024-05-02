/**
 * @description       : 
 * @author            : hojun.park@dkbmc.com
 * @group             : 
 * @last modified on  : 04-30-2024
 * @last modified by  : hojun.park@dkbmc.com
**/
public with sharing class ContactController {

    @AuraEnabled
    public static Map<String, String> getContacts(String recordId) {
        try {
            Map<String, String> contInfoMap = new Map<String, String>();
            if(recordId != null){
                List<Contact> cList = [SELECT Id, Name, Birthdate, MobilePhone, Email, Account.Name, Department FROM Contact WHERE Id =: recordId];
                
                if(!cList.isEmpty()){
                    for(Contact c : cList){
                        contInfoMap.put('contName', c.Name);
                        contInfoMap.put('contBirthdate', String.valueOf(c.Birthdate));
                        contInfoMap.put('contMobilePhone', c.MobilePhone);
                        contInfoMap.put('contEmail', c.Email);
                        contInfoMap.put('contAccName', c.Account.Name);
                        contInfoMap.put('contDept', c.Department);
                    }
                }
            }
            return contInfoMap;
        }
        catch (Exception e) {
            System.debug('contact error ::' + e);
            return null;
        }
    }

    @AuraEnabled
    public static String setContacts(List<Map<String,String>> dataSet, String recordId) {
        try {
            Map<String, String> contInfoMap = new Map<String, String>();
            System.debug('dataSet =>' + dataSet);

            for(Map<String,String> infoMap : dataSet){
                System.debug('data =>>' + infoMap);
                contInfoMap.putAll(infoMap);
            }
            System.debug('Combined Map: ' + contInfoMap);

            if(recordId != null){
                Contact c = [SELECT Id, Name, Birthdate, MobilePhone, Email, Account.Name, Department, LastName FROM Contact WHERE Id =: recordId];
                
                c.LastName = contInfoMap.get('contName');
                c.Birthdate = Date.valueOf(contInfoMap.get('contBirthdate'));
                c.MobilePhone = contInfoMap.get('contMobilePhone');
                c.Email = contInfoMap.get('contEmail');
                c.Department = contInfoMap.get('contDept');

                // Account a = [SELECT Id, Name FROM Account WHERE ]
                // c.AccountId = dataSet.get('contName');

                update c;
            }
            return 'success';
        }
        catch (Exception e) {
            System.debug('contact error ::' + e);
            return 'fail';
        }
    }
}