/**
 * Created by I2MAX_SEOKHOLEE on 2022-12-19.
 */

public virtual without sharing class EX_ConsumableService {

    // 소모품 택배 제한 금액
    public static String CONSUMABLE_PARCEL_FEE_LIMIT_AMOUNT = 'Consumables_PARCEL_FEE_LIMIT_Amount';

    // 소모품 택배 제한 수량
    public static String CONSUMABLE_PARCEL_LIMIT_AMOUNT = 'Consumables_PARCEL_Amount_LIMIT';
    /**
     * @description 로그인 정보 가져오기
     * @param {Id} recordId 메세지 유형(success, error, info, warning, other)
     * @return {Map<String, Object>} User, ServiceResource, Location, PermissionSetAssignment 담은 Map 반환
     */
    @AuraEnabled // Get User Info
    public static Map<String, Object> getUserInfo() {

        // 업무 담당자 Object
        Boolean IsConsumableManagementTeam = false;
        // Service Resource Object
        Boolean IsConsultant = false;
        // Permission Set
        Boolean IsCenterPartsManager = false;

        Map<String, Object> mapReturn;
        try {
            User objUser = new User();
            String recordId = UserInfo.getUserId();
            objUser = [

                    SELECT DEPT_CODE__c
                            , Name
                            , EmployeeNumber
                            , Id
                            , EmployeeNumber__c
                    FROM User
                    WHERE Id = :recordId
            ];


            List<ServiceResource> objSR = [
                    SELECT
                            Id,
                            Name,
                            ResourceType,
                            SM_DEPT__r.fm_HIGH_DEPT_NAME__c,
                            SM_DEPT__r.DEPT_NAME__c
                    FROM
                            ServiceResource
                    WHERE
                            RelatedRecordId = :objUser.Id
            ];

            // 상담사 인 경우
            if (!objSR.isEmpty() && objSR[0].ResourceType == 'A') {
//            if (!objSR.isEmpty() && objSR[0].ResourceType == 'Agent') {
                IsConsultant = true;
            }

            List<PermissionSetAssignment> listPermissionSetAssignment = [
                    SELECT PermissionSet.Name
                            , PermissionSetId
                    FROM PermissionSetAssignment
                    WHERE AssigneeId = :recordId
            ];

            PermissionSetAssignment objPSA = new PermissionSetAssignment();
            // 서비스 센터의 관리자 인 경우 // 자재 관리자인 경우
            for (PermissionSetAssignment tempPSA : listPermissionSetAssignment) {
                if (tempPSA.PermissionSet.Name == 'FS_ProductItemAdmin') {
                    objPSA = tempPSA;
                    IsCenterPartsManager = true;
                }
            }
            List<SM_BIZ_MANAGER__c> consumableManagementTeam = [SELECT Id from SM_BIZ_MANAGER__c WHERE MANAGER_ID__c = :objUser.EmployeeNumber__c AND BIZ_MANAGER_TYPE__c = :'46'];

            if (!consumableManagementTeam.isEmpty()) {
                IsConsumableManagementTeam = true;
            }

            mapReturn = new Map<String, Object>{
                    'User' => objUser,
                    'ServiceResource' => objSR,
                    'PermissionSetAssignment' => objPSA,
                    'IsConsultant' => IsConsultant,
                    'IsCenterPartsManager' => IsCenterPartsManager,
                    'IsConsumableManagementTeam' => IsConsumableManagementTeam
            };




        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());

        }

        return mapReturn;

    }

    /**
     * @description 소모품 주문에서 택배제한금액을 Custom Metadata 에서 관리
     *
     * @author 22.12.21 / I2MAX.SEOKHOLEE
     * @return Decimal
     */
    @AuraEnabled
    public static Decimal doGetConsumableParcelFeeLimit() {
        Decimal parseFee = 0;
        Consumables_PARCEL_FEE_LIMIT_Amount__mdt apiInfo = Consumables_PARCEL_FEE_LIMIT_Amount__mdt.getInstance(CONSUMABLE_PARCEL_FEE_LIMIT_AMOUNT);
        parseFee = apiInfo.PARCEL_FEE_LIMIT_Amount__c;

        return parseFee;
    }

    /**
     * @description 소모품 주문에서 택배제한금액을 Custom Metadata 에서 관리
     *
     * @author 22.12.21 / I2MAX.SEOKHOLEE
     * @return Decimal
     */
    @AuraEnabled
    public static Decimal doGetConsumableAmountLimit() {
        Decimal amount = 0;
        Consumables_PARCEL_Amount_LIMIT__mdt apiInfo = Consumables_PARCEL_Amount_LIMIT__mdt.getInstance(CONSUMABLE_PARCEL_LIMIT_AMOUNT);
        amount = apiInfo.PARCEL_LIMIT_Amount__c;

        return amount;
    }

    /**
    * @description 소모품 주문에서 현재 상담사 정보 조회
    *
    * @author 22.12.26 / I2MAX.JAEYEONLEE
    * @return User
    */
    @AuraEnabled
    public static User doGetManagerInfo() {
        User currentManager = [SELECT Id, EmployeeNumber__c,Name,Phone,DEPT_CODE__c from User where id = :UserInfo.getUserId()];

        return currentManager;
    }


    /**
     * @description
     * @author 22.12.19 / I2MAX.SEOKHOLEE
     */
    public class ConsumableOrderWrapper {
        // 소모품 주문의 Id
        @AuraEnabled public String Id;
        // 소모품 주문의 고객(Contact Id)
        @AuraEnabled public String ContactId;
        // 소모품 주문고객 과 수취인 동일 여부
        @AuraEnabled public Boolean IsSameOrderContact;
        // 소모품 주문의 수취인 명
        @AuraEnabled public String ConsigneeName;
        // 소모품 주문의 수취인 전화번호1
        @AuraEnabled public String ConsigneePhone1;
        // 소모품 주문의 수취인 전화번호2
        @AuraEnabled public String ConsigneePhone2;
        // 소모품 주문의 수취인 주소1
        @AuraEnabled public String ConsigneeAddress1;
        // 소모품 주문의 수취인 주소2
        @AuraEnabled public String ConsigneeAddress2;
        // 소모품 주문의 수취인 주소3
        @AuraEnabled public String ConsigneeAddress3;
        // 소모품 주문의 수취인 요청 사항
        @AuraEnabled public String ConsigneeRequestTerm;
        // 소모품 주문의 특이 사항
        @AuraEnabled public String SpecialNote;
        // 소모품 주문 구분
        @AuraEnabled public String OrderClass;
        // 소모품 주문 채널
        @AuraEnabled public String OrderChannelCode;
        // 소모품 업무 유형
        @AuraEnabled public String BusinessType;
        // 소모품 배송 메시지
        @AuraEnabled public String DeliveryMessageContent;

    }


    public static List<String> getAllFields(String strObjectName) {

        SObjectType objType = Schema.getGlobalDescribe().get(strObjectName);
        Map<String, Schema.SObjectField> mfields = objType.getDescribe().fields.getMap();
        List<String> listFields = new List<String>();

        for (String key : mfields.keySet()) {
            listFields.add(String.valueOf(mfields.get(key)));
        }

        return listFields;
    }
}