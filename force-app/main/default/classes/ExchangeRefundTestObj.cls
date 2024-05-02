/**************************************************************************************** 
 * File Name    : ExchangeRefundTestObj.cls
 * Author       : Ebhan
 * Date         : 2022-12-27
 * Description  : 테스트 클래스 obj 생성 하는 클래스
 * Modification Log
 * =============================================================== 
 * Ver      Date 		Author    			Modification
 * ===============================================================
   1.0		2022-12-27 	ebhan			Create
****************************************************************************************/
public class ExchangeRefundTestObj {

    public static List<IF_Master__c> ifList {
        get {
            if (ifList == null) {
                ifList = new List<IF_Master__c>();

                IF_Master__c ifmaster682 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_GERP_SFDC_682'
                );

                IF_Master__c ifmaster689 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_SFDC_GERP_NEW_689'
                );

                IF_Master__c ifmaster690 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_SFDC_GERP_NEW_690'
                );

                IF_Master__c ifmaster691 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_SFDC_GERP_NEW_691'
                );

                IF_Master__c ifmaster692 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_SFDC_GERP_NEW_692'
                );

                IF_Master__c ifmaster693 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_SFDC_GERP_NEW_693'
                );

                IF_Master__c ifmaster694 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_SFDC_GERP_NEW_694'
                );

                IF_Master__c ifmaster695 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_SFDC_GERP_NEW_695'
                );

                IF_Master__c ifmaster698 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_SFDC_GERP_NEW_698'
                );

                IF_Master__c ifmaster699 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_SFDC_HTLS_NEW_699'
                );

                IF_Master__c ifmaster784 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_SFDC_GERP_NEW_784'
                );

                IF_Master__c ifmaster929 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_SFDC_NEWBEST_NEW_929'
                );

                IF_Master__c ifmaster1352 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_SFDC_GERP_1352'
                );

                IF_Master__c ifmaster1373 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_SFDC_GERP_1373'
                );

                IF_Master__c ifmaster1053 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_SFDC_GERP_NEW_1053'
                );

                ifList.add(ifmaster682);
                ifList.add(ifmaster689);
                ifList.add(ifmaster690);
                ifList.add(ifmaster691);
                ifList.add(ifmaster692);
                ifList.add(ifmaster693);
                ifList.add(ifmaster694);
                ifList.add(ifmaster695);
                ifList.add(ifmaster698);
                ifList.add(ifmaster699);
                ifList.add(ifmaster784);
                ifList.add(ifmaster929);
                ifList.add(ifmaster1352);
                ifList.add(ifmaster1373);
                ifList.add(ifmaster1053);
            }
            return ifList;
        }
        set;
    }

    public static List<IF_Master__c> ifBatchList {
        get {
            if (ifBatchList == null) {
                ifBatchList = new List<IF_Master__c>();

                IF_Master__c if948 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_GERP_SFDC_NEW_948'
                );

                IF_Master__c if828 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_BATCH_SFDC_828'
                );

                IF_Master__c if2670 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_BATCH_SFDC_NEW_2670'
                );

                IF_Master__c ifU2670 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_BATCH_SFDC_NEW_U2670'
                );

                IF_Master__c ifD2670 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_BATCH_SFDC_NEW_D2670'
                );

                IF_Master__c if679 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_BATCH_SFDC_NEW_679'
                );

                IF_Master__c if001 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_BATCH_SFDC_NEW_001'
                );

                IF_Master__c if677 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_BATCH_SFDC_NEW_677'
                );

                IF_Master__c if676_1 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_BATCH_SFDC_676_1'
                );

                IF_Master__c if676_2 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_BATCH_SFDC_676_2'
                );

                IF_Master__c if797 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_BATCH_SFDC_NEW_797'
                );

                IF_Master__c if799 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_FS_BATCH_SFDC_NEW_799'
                );

                IF_Master__c if1037 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_GCAS_NEW_1037'
                );

                IF_Master__c if1038 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_GCAS_NEW_1038'
                );

                IF_Master__c if1039 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_GCAS_NEW_1039'
                );

                IF_Master__c if1041 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_GCAS_NEW_1041'
                );

                IF_Master__c if1042 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_GCAS_NEW_1042'
                );

                IF_Master__c if1043 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_GCAS_NEW_1043'
                );

                IF_Master__c if1044 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_GCAS_NEW_1044'
                );

                IF_Master__c if1045 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_GCAS_NEW_1045'
                );

                IF_Master__c if1046 = new IF_Master__c(
                    Method__c = 'POST',
                    Endpoint__c = 'test',
                    APIKeyName__c = 'test',
                    APIKeyValue__c ='test',
                    IfId__c ='IF_GCAS_NEW_1046'
                );

                ifBatchList.add(if948);
                ifBatchList.add(if828);
                ifBatchList.add(if2670);
                ifBatchList.add(ifU2670);
                ifBatchList.add(ifD2670);
                ifBatchList.add(if679);
                ifBatchList.add(if001);
                ifBatchList.add(if677);
                ifBatchList.add(if676_1);
                ifBatchList.add(if676_2);
                ifBatchList.add(if797);
                ifBatchList.add(if799);
                ifBatchList.add(if1037);
                ifBatchList.add(if1038);
                ifBatchList.add(if1039);
                ifBatchList.add(if1041);
                ifBatchList.add(if1042);
                ifBatchList.add(if1043);
                ifBatchList.add(if1044);
                ifBatchList.add(if1045);
                ifBatchList.add(if1046);
            }
            
            return ifBatchList;
        }
        set;
    }

    public static SM_CODE_MASTER__c codeMDR004 {
        get {
            if (codeMDR004 == null) {
                codeMDR004 = new SM_CODE_MASTER__c(
                    Name ='DR004',
                    CLASS_CODE_NAME__c = 'DR004',
                    USE_YN__c = 'Y'
                );
            }
            return codeMDR004;
        }
        set;
    }

    public static SM_CODE__c codeDR004 {
        get {
            if (codeDR004 == null) {
                codeDR004 = new SM_CODE__c(
                    CLASS_CODE__c = codeMDR004.Id,
                    USE_YN__c = 'Y',
                    CODE_NAME__c = '구입 1개월내 불량',
                    Name = 'DA1'
                );
            }
            return codeDR004;
        }
        set;
    }

    public static SM_CODE_MASTER__c codeMDR008 {
        get {
            if (codeMDR008 == null) {
                codeMDR008 = new SM_CODE_MASTER__c(
                    Name ='DR008',
                    CLASS_CODE_NAME__c = 'DR008',
                    USE_YN__c = 'Y'
                );
            }
            return codeMDR008;
        }
        set;
    }

    public static SM_CODE__c codeDR008 {
        get {
            if (codeDR008 == null) {
                codeDR008 = new SM_CODE__c(
                    CLASS_CODE__c = codeMDR008.Id,
                    USE_YN__c = 'Y',
                    CODE_NAME__c = '목포물류',
                    Name = 'Y03'
                );
            }
            return codeDR008;
        }
        set;
    }

    public static SM_CODE_MASTER__c codeMDR013 {
        get {
            if (codeMDR013 == null) {
                codeMDR013 = new SM_CODE_MASTER__c(
                    Name ='DR013',
                    CLASS_CODE_NAME__c = 'DR013',
                    USE_YN__c = 'Y'
                );
            }
            return codeMDR013;
        }
        set;
    }

    public static SM_CODE__c codeDR013 {
        get {
            if (codeDR013 == null) {
                codeDR013 = new SM_CODE__c(
                    CLASS_CODE__c = codeMDR013.Id,
                    USE_YN__c = 'Y',
                    CODE_NAME__c = '백화점',
                    Name = 'DP',
                    ATTRIBUTE1__c = 'DP'
                );
            }
            return codeDR013;
        }
        set;
    }

    public static SM_CODE_MASTER__c codeMDR016 {
        get {
            if (codeMDR016 == null) {
                codeMDR016 = new SM_CODE_MASTER__c(
                    Name ='DR016',
                    CLASS_CODE_NAME__c = 'DR016',
                    USE_YN__c = 'Y'
                );
            }
            return codeMDR016;
        }
        set;
    }

    public static SM_CODE__c codeDR016 {
        get {
            if (codeDR016 == null) {
                codeDR016 = new SM_CODE__c(
                    CLASS_CODE__c = codeMDR016.Id,
                    USE_YN__c = 'Y',
                    CODE_NAME__c = '액세서리',
                    Name = 'IPZ',
                    ATTRIBUTE1__c ='F00'
                );
            }
            return codeDR016;
        }
        set;
    }

    public static SM_CODE_MASTER__c codeMDR017 {
        get {
            if (codeMDR017 == null) {
                codeMDR017 = new SM_CODE_MASTER__c(
                    Name ='DR017',
                    CLASS_CODE_NAME__c = 'DR017',
                    USE_YN__c = 'Y'
                );
            }
            return codeMDR017;
        }
        set;
    }

    public static SM_CODE__c codeDR017 {
        get {
            if (codeDR017 == null) {
                codeDR017 = new SM_CODE__c(
                    CLASS_CODE__c = codeMDR017.Id,
                    USE_YN__c = 'Y',
                    CODE_NAME__c = '액세서리',
                    Name = 'IPZ',
                    ATTRIBUTE1__c ='F00'
                );
            }
            return codeDR017;
        }
        set;
    }    

    public static SM_CODE_MASTER__c codeMDR020 {
        get {
            if (codeMDR020 == null) {
                codeMDR020 = new SM_CODE_MASTER__c(
                    Name ='DR020',
                    CLASS_CODE_NAME__c = 'DR020',
                    USE_YN__c = 'Y'
                );
            }
            return codeMDR020;
        }
        set;
    }

    public static SM_CODE__c codeDR020 {
        get {
            if (codeDR020 == null) {
                codeDR020 = new SM_CODE__c(
                    CLASS_CODE__c = codeMDR020.Id,
                    USE_YN__c = 'Y',
                    CODE_NAME__c = '일반설치',
                    Name = 'A'
                );
            }    
            return codeDR020;
        }
        set;
    }

    public static SM_CODE_MASTER__c codeMDR027 {
        get {
            if (codeMDR027 == null) {
                codeMDR027 = new SM_CODE_MASTER__c(
                    Name ='DR027',
                    CLASS_CODE_NAME__c = 'DR027',
                    USE_YN__c = 'Y'
                );
            }
            return codeMDR027;
        }
        set;
    }

    public static SM_CODE__c codeDR027 {
        get {
            if (codeDR027 == null) {
                codeDR027 = new SM_CODE__c(
                    CLASS_CODE__c = codeMDR027.Id,
                    USE_YN__c = 'Y',
                    CODE_NAME__c = 'test@test',
                    Name = 'test@test.com'
                );
            }
            return codeDR027;
        }
        set;
    }

    public static SM_CODE_MASTER__c codeMDR032 {
        get {
            if (codeMDR032 == null) {
                codeMDR032 = new SM_CODE_MASTER__c(
                    Name ='DR032',
                    CLASS_CODE_NAME__c = 'DR032',
                    USE_YN__c = 'Y'
                );
            }
            return codeMDR032;
        }
        set;
    }

    public static SM_CODE__c codeDR032 {
        get {
            if (codeDR032 == null) {
                codeDR032 = new SM_CODE__c(
                    CLASS_CODE__c = codeMDR032.Id,
                    USE_YN__c = 'Y',
                    CODE_NAME__c = '액세서리',
                    Name = '3045FA9200A',
                    ATTRIBUTE1__c ='CNZ'
                );
            }
            return codeDR032;
        }
        set;
    }

    public static SM_CODE_MASTER__c codeMDR035 {
        get {
            if (codeMDR035 == null) {
                codeMDR035 = new SM_CODE_MASTER__c(
                    Name ='DR035',
                    CLASS_CODE_NAME__c = 'DR035',
                    USE_YN__c = 'Y'
                );
            }
            return codeMDR035;
        }
        set;
    }

    public static SM_CODE__c codeDR035 {
        get {
            if (codeDR035 == null) {
                codeDR035 = new SM_CODE__c(
                    CLASS_CODE__c = codeMDR035.Id,
                    USE_YN__c = 'Y',
                    CODE_NAME__c = '서울',
                    Name = '서울'
                );
            }
            return codeDR035;
        }
        set;
    }

    public static SM_CODE_MASTER__c codeMRP265 {
        get {
            if (codeMRP265 == null) {
                codeMRP265 = new SM_CODE_MASTER__c(
                    Name ='RP265',
                    CLASS_CODE_NAME__c = 'RP265',
                    USE_YN__c = 'Y'
                );
            }
            return codeMRP265;
        }
        set;
    }

    public static SM_CODE__c codeRP265 {
        get {
            if (codeRP265 == null) {
                codeRP265 = new SM_CODE__c(
                    CLASS_CODE__c = codeMRP265.Id,
                    USE_YN__c = 'Y',
                    CODE_NAME__c = '목포물류',
                    Name = '99009'
                );
            }
            return codeRP265;
        }
        set;
    }

    public static WorkOrder workorder1 {
        get {
            TriggerHandler.bypass('WorkOrder_tr');
            if (workorder1 == null) {
                workorder1 = new WorkOrder(
                    ReceiveNumber__c='TEST123',
                    Manufacture_Number__c='TEST123',
                    UNPROCESS_CODE__c ='G',
                    WorkOrder_Type_lv2__c='D1',
                    ContactId = con.Id,
                    REPAIR_RCPT_DTM__c = datetime.now(),
                    RETURN_REQ_NO__c = 'TEST123',
                    PRODUCT_YM__c = date.today()
                );
            }
            return workorder1;
        }
        set;
    }

    public static WorkOrder workorder2 {
        get {
            TriggerHandler.bypass('WorkOrder_tr');
            if (workorder2 == null) {
                workorder2 = new WorkOrder(
                    ReceiveNumber__c='TEST1234',
                    Manufacture_Number__c='ZZZ',
                    REPAIR_RCPT_DTM__c = datetime.now(),
                    UNPROCESS_CODE__c ='G',
                    WorkOrder_Type_lv2__c='D1'
                );
            }
            return workorder2;
        }
        set;
    }

    public static Product2 product1 {
        get {
            if (product1 == null) {
                Id productRecordTypeId1 = Schema.SObjectType.Product2.getRecordTypeInfosByName()
                .get('모델 마스터').getRecordTypeId();

                if(productLine2.Id == null) insert productLine2;
                product1 = new Product2(
                    name ='R-T822DBHGL.AKOR',
                    SALE_MODEL_CODE__c ='R-T822DBHGL.AKOR',
                    RecordTypeId = productRecordTypeId1,
                    DIV_CODE__c = 'CNZ',
                    isByPass__c = true,
                    PROD_LINE_CODE__c = productLine2.id,
                    IsActive = true
                );
            }
            return product1;
        }
        set;
    }

    public static Product2 product2 {
        get {
            if (product2 == null) {
                product2 = new Product2(
                    name ='R-B451GZS.AKOR',
                    SALE_MODEL_CODE__c ='R-B451GZS.AKOR',
                    isByPass__c = true,
                    DIV_CODE__c = 'WWZ'
                );
            }
            return product2;
        }
        set;
    }

    public static SM_PRODUCT_LINE__c productLine {
        get {
            if (productLine == null) {
                productLine = new SM_PRODUCT_LINE__c(
                  //  PRODUCT_CODE__c = product2.Id
                );
            }
            return productLine;
        }
        set;
    }

    public static SM_PRODUCT_LINE__c productLine2 {
        get {
            if (productLine2 == null) {
                productLine2 = new SM_PRODUCT_LINE__c(
                );
            }
            return productLine2;
        }
        set;
    }


    public static OperatingHours objOperationHours {
        get {
            if (objOperationHours == null) {
                objOperationHours = new OperatingHours();
                objOperationHours.Name = '표준 운영시간';
                objOperationHours.TimeZone = 'Asia/Seoul';
            }
            return objOperationHours;
        }
        set;
    }

    public static SM_ZIP__c objSmZip {
        get {
            if (objSmZip == null) {
                objSmZip = new SM_ZIP__c();
                objSmZip.Name = '06112';
                objSmZip.ZIP_NO__c = '06112';
                objSmZip.ZIP_ID__c = 3562009;
                objSmZip.ZIP_AREA_CODE__c = '003471';
                objSmZip.DDD_NO__c = '02';
                objSmZip.HIGH_ADDR__c = '서울';
                objSmZip.MID_ADDR__c = '강남구';
                objSmZip.LOW_ADDR__c = '.';
                objSmZip.ROAD_NM__c = '학동로';
                objSmZip.MASS_NO__c = '율암빌딩';
                objSmZip.HOUSE_NO__c = '158';
                objSmZip.USE_YN__c = 'Y';
                objSmZip.ROAD_ADDR_CODE__c = '1168031220110300015800000';
                objSmZip.POST_TYPE__c = '2';
            }
            return objSmZip;
        }
        set;
    }

    public static SM_DEPT__c objHighSMDEPT {
        get{
            if(objHighSMDEPT == null){
                if(objSmZip.Id == null) insert objSmZip;

                objHighSMDEPT = new SM_DEPT__c();
                objHighSMDEPT.Name = '수도권운영팀';
                objHighSMDEPT.DEPT_TYPE_FIRST__c = 'A';
                objHighSMDEPT.DEPT_TYPE_SECOND__c = 'A';
                objHighSMDEPT.DEPT_NAME__c = '수도권운영팀';
                objHighSMDEPT.BIZ_NAME__c = 'LG전자';
                objHighSMDEPT.DEPT_CODE__c = '12498';
                objHighSMDEPT.AGENCY_DC_RATE__c = 'A';
                objHighSMDEPT.ELEC_YN__c = 'N';
                objHighSMDEPT.KIOSK_YN__c = 'N';
                objHighSMDEPT.PC_YN__c = 'N';
                objHighSMDEPT.PHONE_YN__c = 'N';

            }
            return objHighSMDEPT;
        }
        set;
    }

    public static SM_DEPT__c objSmDept {
        get {
            if (objSmDept == null) {
                objSmDept = new SM_DEPT__c();
                objSmDept.Name = '강서서비스센터';
                objSmDept.DEPT_TYPE_FIRST__c = 'A';
                objSmDept.DEPT_TYPE_SECOND__c = 'E';
                objSmDept.CHIEF_NAME__c = '조주완,배두용';
                objSmDept.DEPT_NAME__c = '강서서비스센터';
                objSmDept.BIZ_NAME__c = '엘지전자(주) 강서서비스센터';
                objSmDept.SM_ZIP__c = objSmZip.Id;
                objSmDept.DEPT_CODE__c = 'PH0113'; //'PH0077';
                objSmDept.BIZ_ID__c = '1078614075';
                objSmDept.ELEC_YN__c = 'N';
                objSmDept.KIOSK_YN__c = 'N';
                objSmDept.PC_YN__c = 'N';
                objSmDept.PHONE_YN__c = 'N';
            }
            return objSmDept;
        }
        set;
    }

    public static SM_DEPT__c objSmDeptSvc {
        get {
            if (objSmDeptSvc == null) {
                objSmDeptSvc = new SM_DEPT__c();
                objSmDeptSvc.Name = '강서서비스센터';
                objSmDeptSvc.DEPT_TYPE_FIRST__c = 'A';
                objSmDeptSvc.DEPT_TYPE_SECOND__c = 'E';
                objSmDeptSvc.CHIEF_NAME__c = '조주완,배두용';
                objSmDeptSvc.DEPT_NAME__c = '강서서비스센터';
                objSmDeptSvc.BIZ_NAME__c = '엘지전자(주) 강서서비스센터';
                objSmDeptSvc.SM_ZIP__c = objSmZip.Id;
                objSmDeptSvc.DEPT_CODE__c = 'PH0113'; //'PH0131';
                objSmDeptSvc.BIZ_ID__c = '1078614075';
                objSmDeptSvc.ELEC_YN__c = 'N';
                objSmDeptSvc.KIOSK_YN__c = 'N';
                objSmDeptSvc.PC_YN__c = 'N';
                objSmDeptSvc.PHONE_YN__c = 'N';
            }
            return objSmDeptSvc;
        }
        set;
    }
    
    public static ServiceTerritory objServiceTerritory {
        get {
            if (objServiceTerritory == null) {
                if(objOperationHours.Id == null) insert objOperationHours;
                if(objSmDept.Id == null) insert objSmDept;
                objServiceTerritory = new ServiceTerritory();
                objServiceTerritory.IsActive = true;
                objServiceTerritory.Name = '강서서비스센터';
                objServiceTerritory.Street = '등촌동 655-42';
                objServiceTerritory.City = 'SEOUL';
                objServiceTerritory.State = 'GANG-SEO';
                objServiceTerritory.PostalCode = '157-031';
                objServiceTerritory.Country = 'KR';
                objServiceTerritory.CenterPhone__c = '1544-7777';
                objServiceTerritory.OperatingHoursId = objOperationHours.Id;
                objServiceTerritory.SM_DEPT_ID__c = objSmDept.Id;
            }
            return objServiceTerritory;
        }
        set;
    }

    public static ExchangeRefund__c exchange1 {
        get {
            if (exchange1 == null) {
                Id recordTypeId1 = Schema.SObjectType.ExchangeRefund__c.getRecordTypeInfosByName()
                .get('교환').getRecordTypeId();

                exchange1 = new ExchangeRefund__c(
                    Purchase_PROOF_Request_YN__c = true,
                    Bank_Book_Request_YN__c = true,
                    Personal_Information_Agreement_YN__c = true,
                    Family_Relations_Certificate_YN__c = true,
                    Minor14_YN__c = true,
                    CUST_PROOF_Request_PNO__c = '010-1234-5678',
                    CUST_PROOF_Request_DTM__c = datetime.now(),
                    CUST_PROOF_Requester_Id__c = UserInfo.getUserId(),
                    CustMobile_YN__c = true,
                    RecordTypeId = recordTypeId1,
                    WorkOrder_Id__c = workorder1.Id,
                    DPSR_REL_Description__c = 'TEST1',
                    Amount_Based_Code__c = 'C',
                    APPR_Method_Code__c = 'A',
                    Install_Type_Code__c = 'A',
                    Approval_Status_Code__c = '01',
                    RCPT_Date__c = Date.today(),
                    ServiceTerritoryId__c = objServiceTerritory.Id,
                    Manufacture_MODEL_Id__c = product1.Id,
                    BANK_Code__c = '20',
                    ENC_ACCT_Number__c = '1234567890',
                    MobielUpdate_YN__c = true,
                    ARBDecision_Amount__c = 1000000000
                );
            }
            return exchange1;
        }
        set;
    }

    public static ExchangeRefund__c exchange2 {
        get {
            if (exchange2 == null) {
                Id recordTypeId2 = Schema.SObjectType.ExchangeRefund__c.getRecordTypeInfosByName()
                .get('환불').getRecordTypeId();

                exchange2 = new ExchangeRefund__c(
                Purchase_PROOF_Request_YN__c = true,
                Bank_Book_Request_YN__c = true,
                Personal_Information_Agreement_YN__c = true,
                Family_Relations_Certificate_YN__c = true,
                Minor14_YN__c = true,
                CUST_PROOF_Request_PNO__c = '010-1234-5678',
                CUST_PROOF_Request_DTM__c = datetime.now(),
                CUST_PROOF_Requester_Id__c = UserInfo.getUserId(),
                CustMobile_YN__c = true,
                RecordTypeId = recordTypeId2,
                WorkOrder_Id__c = workorder2.Id,
                DPSR_REL_Description__c = 'TEST2',
                RCPT_Date__c = Date.today(),
                ServiceTerritoryId__c = objServiceTerritory.Id,
                Manufacture_MODEL_Id__c = product1.Id
                );
            }
            return exchange2;
        }
        set;
    }

    public static ExchangeRefund__c exchange3 {
        get {
            if (exchange3 == null) {
                Id recordTypeId3 = Schema.SObjectType.ExchangeRefund__c.getRecordTypeInfosByName()
                .get('영업환입').getRecordTypeId();

                exchange3 = new ExchangeRefund__c(
                Purchase_PROOF_Request_YN__c = true,
                Bank_Book_Request_YN__c = true,
                Personal_Information_Agreement_YN__c = true,
                Family_Relations_Certificate_YN__c = true,
                Minor14_YN__c = true,
                CUST_PROOF_Request_PNO__c = '010-1234-5678',
                CUST_PROOF_Request_DTM__c = datetime.now(),
                CUST_PROOF_Requester_Id__c = UserInfo.getUserId(),
                CustMobile_YN__c = true,
                RecordTypeId = recordTypeId3,
                WorkOrder_Id__c = workorder2.Id,
                DPSR_REL_Description__c = 'TEST3',
                RCPT_Date__c = Date.today(),
                ServiceTerritoryId__c = objServiceTerritory.Id,
                Manufacture_MODEL_Id__c = product1.Id
                );
            }
            return exchange3;
        }
        set;
    }

    public static ExchangeRefundLineItem__c lineItem {
        get {
            if (lineItem == null) {
                lineItem = new ExchangeRefundLineItem__c(
                    Exchange_REFUND_Number__c = exchange1.Id,
                    COLLECT_MODEL_Id__c = product1.Id,
                    SEQ__c =1
                    ,PurchaseDate__c = date.newInstance(2023, 03, 17)
                    ,Manufacture_YM__c ='202303'
                );
            }
            return lineItem;
        }
        set;
    }

    public static ExchangeRefundOrder__c orderItem {
        get {
            if (orderItem == null) {
                orderItem = new ExchangeRefundOrder__c(
                    Exchange_REFUND_Number__c = exchange1.Id,
                    SALE_UnitPrice__c = 10000000,
                    Order_MODEL_Id__c = product1.Id,
                    SEQ__c =2
                );
            }
            return orderItem;
        }
        set;
    }

    public static ExchangeRefundLineItem__c lineItem2 {
        get {
            if (lineItem2 == null) {
                lineItem2 = new ExchangeRefundLineItem__c(
                    Exchange_REFUND_Number__c = exchange2.Id
                    ,COLLECT_MODEL_Id__c = product2.Id
                    ,SEQ__c =3
                    ,PurchaseDate__c = date.newInstance(2023, 03, 17)
                    ,Manufacture_YM__c ='202303'
                );
            }
            return lineItem2;
        }
        set;
    }

    public static ExchangeRefundLineItem__c lineItem3 {
        get {
            if (lineItem3 == null) {
                lineItem3 = new ExchangeRefundLineItem__c(
                    Exchange_REFUND_Number__c = exchange3.Id,
                    COLLECT_MODEL_Id__c = product2.Id,
                    SEQ__c =4
                    ,PurchaseDate__c = date.newInstance(2023, 03, 17)
                    ,Manufacture_YM__c ='202303'
                );
            }
            return lineItem3;
        }
        set;
    }

    public static ExchangeRefundCashBack__c cashback {
        get {
            if (cashback == null) {
                cashback = cashback = new ExchangeRefundCashBack__c(
                    Exchange_REFUND_Number__c = exchange1.Id,
                    SALE_Date__c = System.today(),
                    Supplied_Date__c = System.today(),
                    COLLECT_Request_YN__c = true
                );
            }
            return cashback;
        }
        set;
    }

    public static ExchangeRefundMembership__c membership {
        get {
            if (membership == null) {
                membership = new ExchangeRefundMembership__c(
                    Exchange_REFUND_Number__c = exchange1.Id,
                    SALE_Date__c = System.today(),
                    Supplied_Date__c = System.today(),
                    COLLECT_Request_YN__c = true
                );
            }
            return membership;
        }
        set;
    }

    public static ExchangeRefundMobile__c mobile {
        get {
            if (mobile == null) {
                mobile = new ExchangeRefundMobile__c(
                    Exchange_REFUND_Number__c = exchange1.Id,
                    Request_Date__c = System.today(),
                    Send_Date__c = System.today(),
                    Z_EXCHANGE_DATE__c = System.today(),
                    COLLECT_Request_YN__c = true,
                    Z_KEY_ID__c = 'TEST'+String.valueOf(System.today())
                );
            }
            return mobile;
        }
        set;
    }

    public static ExchangeRefundDeprec__c exDeprec {
        get {
            if (exDeprec == null) {
                exDeprec = new ExchangeRefundDeprec__c(
                    Name ='test'
                );
            }
            return exDeprec;
        }
        set;
    }

    public static ExchangeRefundDeprecAdujust__c exDeprecAduject {
        get {
            if (exDeprecAduject == null) {
                exDeprecAduject = new ExchangeRefundDeprecAdujust__c(
                    ExchangeRefundDeprec_id__c = exDeprec.Id,
                    Apply_RT__c = 10,
                    MONTHS__c = 3
                );
            }
            return exDeprecAduject;
        }
        set;
    }

    public static sm_nonlge_model_price__c nonlgePrice {
        get {
            if (nonlgePrice == null) {
                nonlgePrice = new sm_nonlge_model_price__c(
                    SHIP_PRICE__c = 1000,
                    SELLING_PRICE__c =  500,
                    Name = 'R-T822DBHGL.AKOR',
                    DIV_CODE__c = 'BBS'
                );
            }
            return nonlgePrice;
        }
        set;
    }

    public static SM_EXCHANGE_RESTRICT_MODEL__c restrictModelSrch {
        get {
            if (restrictModelSrch == null) {
                restrictModelSrch = new SM_EXCHANGE_RESTRICT_MODEL__c(
                    MODEL_CODE__c = product1.Id,
                    RESTRICT_CODE__c = 'RESTRICT',
                    COMPARE_TARGET_LENGTH__c = 1,
                    RANGE_COMPARE_LENGTH__c = 1,
                    USE_YN__c = 'Y',
                    RETURN_VALUE__c = 3,
                    COMPARE_VALUE__c = 'A',
                    RANGE_START__c = 'A',
                    RANGE_END__c = 'A'
                );
            }
            return restrictModelSrch;
        }
        set;
    }

    public static TemplateMgmt__c template {
        get {
            if (template == null) {
                Id emailTemplateId = Schema.SObjectType.TemplateMgmt__c.getRecordTypeInfosByDeveloperName().get('Email').getRecordTypeId();
                template = new TemplateMgmt__c(
                    TemplateCode__c = 'SVC2101',
                    Title__c = 'TEST',
                    Content_c__c = 'TEst',
                    RecordTypeId = emailTemplateId
                );
            }
            return template;
        }
        set;
    }

    public static List<ContentVersion> conversionList {
        get {
            if (conversionList == null) {
                conversionList = new List<ContentVersion>();
                for(integer i=0; i<5;i++){
                    ContentVersion contentVersion = new ContentVersion(
                        Title          = 'a picture',
                        PathOnClient   = 'test'+i+'.pdf',
                        VersionData    = Blob.valueOf('Test Content'),
                        IsMajorVersion = true);
        
                    conversionList.add(contentVersion);
                }
            }
            return conversionList;
        }
        set;
    }

    public static List<ExchangeFileInformation__c> fileList {
        get {
            if (fileList == null) {
                fileList = new List<ExchangeFileInformation__c>();
                for(integer i=0; i<conversionList.size();i++){
                    ContentVersion item = conversionList[i];
                    Id conDocument = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:item.Id].ContentDocumentId;
        
                    ExchangeFileInformation__c objFileInfo = new ExchangeFileInformation__c(
                        File_DocumentId__c = conDocument,
                        Obj_Name__c = 'ExchangeRefund__c',
                        Obj_Record_Id__c = exchange1.Id,
                        Type__c = 'A0'+(i+1),
                        Name = '테스틉123'
                    );
        
                    fileList.add(objFileInfo);
                }  
            }
            return fileList;
        }
        set;
    }

    public static User user{
        get {
            if (user == null) {
                Profile pf= [Select Id from profile where Name in ('Standard User','표준 사용자') limit 1];
        
                String orgId=UserInfo.getOrganizationId(); 
                String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
                Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
                String uniqueName=orgId+dateString+RandomId; 

                user = new User(firstname = 'Test1', 
                         lastName = 'Tester', 
                         email = 'test1.tester' + '@lgepartner.com', 
                         Username = 'test1.tester' + '@lgepartner.com', 
                         isActive = true,
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id,
                         EmployeeNumber__c ='99009',
                         DEPT_CODE__c = 'PH0113' //'PH0077'
                        ); 
            }
            return user;
        }
        set;
    }

    public static User userSvc{
        get {
            if (userSvc == null) {
                Profile pf= [Select Id from profile where Name='SVC(HiT, LGE)_센터장'];
        
                String orgId=UserInfo.getOrganizationId(); 
                String dateString=String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','') ;
                Integer RandomId=Integer.valueOf(Math.rint(Math.random()*1000000)); 
                String uniqueName=orgId+dateString+RandomId; 

                userSvc = new User(firstname = 'Test1', 
                         lastName = 'Tester2', 
                         email = 'test2.tester' + '@lgepartner.com', 
                         Username = 'test2.tester' + '@lgepartner.com', 
                         isActive = true,
                         EmailEncodingKey = 'ISO-8859-1', 
                         Alias = uniqueName.substring(18, 23), 
                         TimeZoneSidKey = 'America/Los_Angeles', 
                         LocaleSidKey = 'en_US', 
                         LanguageLocaleKey = 'en_US', 
                         ProfileId = pf.Id,
                         EmployeeNumber__c ='99010',
                         DEPT_CODE__c = 'PH0113' //'PH0077'
                        ); 
            }
            return userSvc;
        }
        set;
    }

    public static SM_DIV__C smDiv {
        get {
            TriggerHandler.bypass('SM_DIV_trHandler');
            if (smDiv == null) {
                smDiv = new SM_DIV__C(
                    name ='냉장고',
                    DIV_CODE__C='CNZ',
                    SORT_ORDER__c =7,
                    EXT_DIV_FLAG__c ='Y'
                );
            }
            return smDiv;
        }
        set;
    }

    public static Contact con {
        get {
            if (con == null) {
                con = new Contact(
                    LastName ='홍굼딜',
                    MobilePhone = '01012345678'
                );
            }
            return con;
        }
        set;
    }

    public static ServiceResource objServiceResource {
        get{
            if(objServiceResource == null){
                if(objSmDept.id == null) insert objSmDept;
                if(user.id == null) insert user;

                objServiceResource = new ServiceResource();
                objServiceResource.Name = user.Username;
                objServiceResource.RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('SE').getRecordTypeId();
                objServiceResource.RelatedRecordId = user.id;
                objServiceResource.SM_DEPT__c = objSmDept.Id;
                objServiceResource.JOB_TYPE__c = 'A60'; // 주직무가 내방
                objServiceResource.IsActive = true;
            }
            return objServiceResource;
        }
        set;
    }

    public static ServiceResource objServiceResourceSvc {
        get{
            if(objServiceResourceSvc == null){
                if(objSmDeptSvc.id == null) insert objSmDeptSvc;
                if(userSvc.id == null) insert userSvc;
                objServiceResourceSvc = new ServiceResource();
                objServiceResourceSvc.Name = userSvc.Username;
                objServiceResourceSvc.RecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName().get('SE').getRecordTypeId();
                objServiceResourceSvc.RelatedRecordId = userSvc.id;
                objServiceResourceSvc.SM_DEPT__c = objSmDeptSvc.Id;
                objServiceResourceSvc.JOB_TYPE__c = 'A60'; // 주직무가 내방
                objServiceResourceSvc.IsActive = true;
            }
            return objServiceResourceSvc;
        }
        set;
    }

    public static ServiceTerritoryMember objServiceTerritoryMember {
        get{
            if(objServiceTerritoryMember == null) {
                if(objServiceResourceSvc.Id == null) insert objServiceResourceSvc;
                if(objServiceTerritory.Id == null) insert objServiceTerritory;
                objServiceTerritoryMember = new ServiceTerritoryMember();
                objServiceTerritoryMember.ServiceResourceId = objServiceResourceSvc.Id;
                objServiceTerritoryMember.EffectiveStartDate = Date.today();
                objServiceTerritoryMember.ServiceTerritoryId = objServiceTerritory.Id;
                objServiceTerritoryMember.TerritoryType = 'P';
                objServiceTerritoryMember.EffectiveStartDate = date.newInstance(2023, 12, 10);
            }
            return objServiceTerritoryMember;
        }
        set;
    }

    public static Product2 product3 {
        get {
            if (product3 == null) {
                Id productRecordTypeId1 = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get('PRODUCT_GROUP').getRecordTypeId();

                if(productLine2.Id == null) insert productLine2;
                product3 = new Product2(
                    name ='R-T822DBHGL.AKO',
                    SALE_MODEL_CODE__c ='R-T822DBHGL.AKO',
                    RecordTypeId = productRecordTypeId1,
                    DIV_CODE__c = 'CNZ',
                    isByPass__c = true,
                    PROD_LINE_CODE__c = productLine2.id,
                    IsActive = true
                );
            }
            return product3;
        }
        set;
    }
}