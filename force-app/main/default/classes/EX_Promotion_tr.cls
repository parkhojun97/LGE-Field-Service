/**
 * Created by I2MAX.SEOKHOLEE on 2023-05-20.
 */

 public with sharing class EX_Promotion_tr extends TriggerHandler {


    public EX_Promotion_tr() {
        listNew = (List<EX_Promotion__c>) trigger.new;
        listOld = (List<EX_Promotion__c>) trigger.old;
        mapNew = (Map<Id, EX_Promotion__c>) trigger.newMap;
        mapOld = (Map<Id, EX_Promotion__c>) trigger.oldMap;
    }
    
    private List<EX_Promotion__c> listNew { get; set; }
    private List<EX_Promotion__c> listOld { get; set; }
    private Map<Id, EX_Promotion__c> mapNew { get; set; }
    private Map<Id, EX_Promotion__c> mapOld { get; set; }
    
    public override void beforeInsert() {
        setDefault();
        //PHJ231211
        insertSetting();
    }
    
    public override void afterInsert() {
        // setNotUsingPromotion();
    }
    
    public override void beforeUpdate() {
        validationDate(listNew);
    }
    
    /**
     * @description 프로모션 기초 데이터 세팅
     * @author I2MAX.SEOKHOLEE
     */
    public void setDefault() {
        List<SM_CODE_MASTER__c> promotionCode = [
                SELECT Id
                FROM SM_CODE_MASTER__c
                WHERE External_id__c = 'PT026'
                LIMIT 1
        ];
        Set<String> divCodeSet = new Set<String>();
        Set<String> partCodeSet = new Set<String>();
    
        for (EX_Promotion__c pm : listNew) {
            if (pm.DIV_CODE__c != null && pm.Part_No__c != null) {
                divCodeSet.add(pm.DIV_CODE__c);
                partCodeSet.add(pm.Part_No__c);
            }
        }
    
        Map<String, Product2> productMap = new Map<String, Product2>();
    
        String externalKey = '';
        for (Product2 prod : [
                SELECT Id,DIV_CODE__c,Name
                FROM Product2
                WHERE PART_TYPE__c = 'D'
                AND DIV_CODE__c IN :divCodeSet
                AND Name IN :partCodeSet
        ]) {
            externalKey = prod.DIV_CODE__c + '_' + prod.Name;
            productMap.put(externalKey, prod);
        }
    
        for (EX_Promotion__c exPm : listNew) {
            externalKey = exPm.DIV_CODE__c + '_' + exPm.Part_No__c;
            if(productMap.containsKey(externalKey)) {
                exPm.ProductId__c = productMap.get(externalKey).Id;
            }
            //23 08 30 hyungho.chun 이름 파트넘버로 자동변경 막아달래서 막음
            // exPm.Name = exPm.Part_No__c;
            exPm.CLASS_CODE__c = promotionCode[0].Id;
        }
    }
    
    /**
     * @description 프로모션 생성 세팅
     * @author DKBMC.HOJUNPARK
     * @createDate 2023.12.11
     */
    public void insertSetting() {
        // seung yoon heo 벌크형식 고려 안되어있음.
        // String expPartNo; // insert promotion의 파트넘버
        Set<String> expDivCode = new Set<String>(); // insert promotion의 사업부코드
        // String expDeptCode; // insert promotion의 출고센터코드
        // String itemDivCode; // insert promotion의 파트넘버의 사업부코드
        // String itemId; // insert promotion의 파트넘버 아이디
        // String itemName; // insert promotion의 파트넘버 이름
        // String deptId; // insert promotion의 출고센터 아이디
        // String newExpKey; // insert promotion의 key
        // String oldExpKey; // 이미 존재하는 promotion의 key
        // Decimal itemCUST_PRICE; // 아이템 소비자가
        Boolean excelUploadTF = false; // 엑셀 업로드인지 판별
        // Date oldPromotionEndDate; // 기존 프로모션 end date
        // String oldPromotion_USE_YN; // 기존 프로모션 사용여부
        Set<String> expDeptSet = new Set<String>();
        Map<String, String> promotionMap = new Map<String, String>();
        Set<String> expPdSet = new Set<String>();
        Map<String, List<Object>> promotionDate = new Map<String, List<Object>>();
        // Map<Stirng,Map<String, List<Date>>> dupPromotionMap = new Map<Stirng,Map<String, List<Date>>>();
        Map<String, List<String>> dupPromotionMap = new Map<String, List<String>>();
    
    
        // 업무그룹코드 고정
        System.debug('listNew?? ' + listNew);
        SM_CODE_MASTER__c smcm = [SELECT Id, Name, External_id__c FROM SM_CODE_MASTER__c WHERE External_id__c = 'PT026'];
        for(EX_Promotion__c exp : listNew){
            //Promotion_USE_YN__c가 Y인 경우에만 해당 val check
            if (exp.Promotion_USE_YN__c == 'Y') {
                exp.CLASS_CODE__c = smcm.Id;
                if(exp.PromotionStartDate__c <= System.today()) {
                    exp.PromotionStartDate__c.addError('프로모션 시작일자는 D+1부터 설정 가능합니다.'); // 프로모션 시작일자 Validation
                }
                // 엑셀인지 아닌지만 구분
                if(exp.SHIPPED_Department_Code__c != null && exp.Part_No__c != null) {
                    // newExpKey = exp.SHIPPED_Department_Code__c + '_' + exp.ProductId__c + '_' + exp.Promotion_USE_YN__c;
                    excelUploadTF = true;
                    expPdSet.add(exp.Part_No__c);
    
                    // exp.Department_Code__c = exp.SHIPPED_Department_Code__c;
                    
                    expDeptSet.add(exp.SHIPPED_Department_Code__c);
                    expDivCode.add(exp.DIV_CODE__c);
    
                    // expPartNo = exp.Part_No__c;
                    // expDeptCode = exp.SHIPPED_Department_Code__c;
                } else {
                    excelUploadTF = false;
                    expPdSet.add(exp.ProductId__c);
    
                    // exp.SHIPPED_Department_Code__c = exp.Department_Code__c;
                    expDeptSet.add(exp.Department_Code__c);
                    // newExpKey = exp.Department_Code__c + '_' + exp.ProductId__c + '_' + exp.Promotion_USE_YN__c;
                    // expPartNo = exp.ProductId__c;
                    // expDeptCode = exp.Department_Code__c;
                }
            }
            
    
        }
    
        // 프로모션 엑셀 업로드 시 입력된 출고센터코드로 출고센터 이름 가져오기
        if(expDeptSet.size() > 0){
            List<SM_DEPT__c> deptList = [
                                        SELECT Id, DEPT_CODE__c
                                        FROM   SM_DEPT__c
                                        WHERE  DEPT_CODE__c IN: expDeptSet
            ];
            if(deptList.size() > 0){
                Map<String, String> smDeptMap = new Map<String, String>();
                for(SM_DEPT__c dept : deptList){
                    smDeptMap.put(dept.DEPT_CODE__c, dept.Id);
                }
                for(EX_Promotion__c exp : listNew){
                    //여기 에러 띄우기
                    // exp.Department_Code__c = smDeptMap.get(exp.SHIPPED_Department_Code__c) == null ? smDeptMap.get(exp.Department_Code__c) == null ? 
                    // '해당 출고센터를 찾을 수 없습니다.' : smDeptMap.get(exp.Department_Code__c) : smDeptMap.get(exp.SHIPPED_Department_Code__c);

                    //23 12 18 hyungho.chun 위 로직 dept_code에 sm_dept_code id값을 넣어주고있음
                    exp.Department_Code__c = (excelUploadTF == true) ? exp.SHIPPED_Department_Code__c : exp.Department_Code__c ;      

                    exp.SHIPPED_Department_Code__c = (excelUploadTF == true) ? exp.SHIPPED_Department_Code__c : exp.Department_Code__c ;                    
                }
            } else {
                for(EX_Promotion__c exp : listNew){   
                    exp.SHIPPED_Department_Code__c.addError('해당 출고센터를 찾을 수 없습니다.');
                }
            }
            
            // 프로모션 엑셀 업로드 시 입력된 파트넘버와 사업부 코드로 해당 파트 정보 가져오기 및 사업부코드 자동 입력 BUT 엑셀 업로드가 아닐경우 사업부코드 자동 입력만
            // if(excelUploadTF){
                String proQuery = 'SELECT Id, Name, DIV_CODE__c, CUST_PRICE__c ';
                proQuery += ' FROM ';
                proQuery += ' Product2 ';
                proQuery += ' WHERE (Name IN:expPdSet  OR Id IN:expPdSet)  ';
                if (excelUploadTF) {
                    proQuery += ' AND DIV_CODE__c IN: expDivCode ';   
                }

                List<Product2> itemList = Database.query(proQuery);
                // List<Product2> itemList = [
                //     SELECT Id, Name, DIV_CODE__c, CUST_PRICE__c
                //     FROM   Product2 
                //     WHERE  (Name IN: expPdSet OR Id IN:expPdSet) 
                //     // AND    DIV_CODE__c IN: expDivCode
                //     ];
                    if(itemList.size() > 0){
                        Map<String, String> productMap = new Map<String, String>();
                        Map<String, String> productDivMap = new Map<String, String>();
                        Map<String, Decimal> productCustPriceMap = new Map<String, Decimal>();
                        for(Product2 item : itemList){
                            productMap.put(item.Name, item.Id);
                            productMap.put(item.Id, item.Name);
                            productCustPriceMap.put(item.Name , item.CUST_PRICE__c);
                            productCustPriceMap.put(item.Id , item.CUST_PRICE__c);
                            productDivMap.put(item.Name, item.DIV_CODE__c);
                            productDivMap.put(item.Id, item.DIV_CODE__c);
                            // itemId = item.Id;
                            // itemDivCode = item.DIV_CODE__c;
                            // itemCUST_PRICE = item.CUST_PRICE__c;
                        }
                    
                    for(EX_Promotion__c exp : listNew){
                        if (excelUploadTF) {
                            exp.ProductId__c = productMap.get(exp.Part_No__c);
                            exp.Department_Code__c = exp.SHIPPED_Department_Code__c;
                            exp.DIV_CODE__c = productDivMap.get(exp.Part_No__c);
                            if(exp.PromotionPrice__c >= productCustPriceMap.get(exp.Part_No__c)){
                                exp.PromotionPrice__c.addError('프로모션 할인 판매가는 소비자가보다 작아야합니다.');
                            }
                        } else {
                            exp.Part_No__c = productMap.get(exp.ProductId__c);
                            exp.SHIPPED_Department_Code__c = exp.Department_Code__c;
                            exp.DIV_CODE__c = productDivMap.get(exp.ProductId__c);
                            if(exp.PromotionPrice__c >= productCustPriceMap.get(exp.ProductId__c)){
                                exp.PromotionPrice__c.addError('프로모션 할인 판매가는 소비자가보다 작아야합니다.');
                            }
                        }
                    }

                    for (EX_Promotion__c exp : listNew) {
                        
                        if (exp.Promotion_USE_YN__c == 'Y') {
                            List<String> dateList = new List<String>();

                            promotionDate.put(exp.SHIPPED_Department_Code__c + '_' + exp.ProductId__c, new List<Object> {exp.PromotionStartDate__c, exp.PromotionEndDate__c});

                            if (dupPromotionMap.containsKey(exp.DIV_CODE__c+'_'+exp.Part_No__c)) {
                                // dateList.add(exp.PromotionStartDate__c);
                                // dateList.add(exp.PromotionEndDate__c);
                                dupPromotionMap.get(exp.DIV_CODE__c+'_'+exp.Part_No__c).add(exp.PromotionStartDate__c + '/' + exp.PromotionEndDate__c +'/' + exp.DIV_CODE__c + exp.Part_No__c + String.valueOf(exp.PromotionStartDate__c).replaceAll('0','').replaceAll('-','').replaceAll(':', '') + String.valueOf(exp.PromotionEndDate__c).replaceAll('0','').replaceAll('-','').replaceAll(':', '') );
                            } else {
                                dateList.add(exp.PromotionStartDate__c + '/' + exp.PromotionEndDate__c+'/' + exp.DIV_CODE__c + exp.Part_No__c + String.valueOf(exp.PromotionStartDate__c).replaceAll('0','').replaceAll('-','').replaceAll(':', '') + String.valueOf(exp.PromotionEndDate__c).replaceAll('0','').replaceAll('-','').replaceAll(':', '') );
                                // dateList.add(exp.PromotionEndDate__c);
                                dupPromotionMap.put(exp.DIV_CODE__c+'_'+exp.Part_No__c, dateList);
                            }
                         
                        }
                    }
                } else {
                    for(EX_Promotion__c exp : listNew){
                        exp.Part_No__c.addError('사업부에 해당 Part No를 찾을 수 없습니다.');
                    }
                }
        // } else {
        //     List<Product2> itemList = [
        //                                 SELECT Id, Name, DIV_CODE__c, CUST_PRICE__c
        //                                 FROM   Product2 
        //                                 WHERE  Id =: expPartNo 
        //     ];
        //     if(itemList.size() > 0){
        //         for(Product2 item : itemList){
        //             itemId = item.Id;
        //             itemName = item.Name;
        //             itemDivCode = item.DIV_CODE__c;
        //             itemCUST_PRICE = item.CUST_PRICE__c;
        //         }
        //         for(EX_Promotion__c exp : listNew){
        //             exp.DIV_CODE__c = itemDivCode;
        //             exp.Part_No__c = itemName;
        //             if(exp.PromotionPrice__c >= itemCUST_PRICE){
        //                 exp.PromotionPrice__c.addError('프로모션 할인 판매가는 소비자가보다 작아야합니다.');
        //             }
        //         }
        //     }
        // }
        
        // newKey와 oldKey를 확인하여 이미 존재하는 프로모션인지 체크
        
            // if(excelUploadTF){
                List<EX_Promotion__c> expList = [
                    SELECT Id, Name, Part_No__c, ProductId__c, PromotionStartDate__c, PromotionEndDate__c, SHIPPED_Department_Code__c, Promotion_USE_YN__c, Department_Code__c, ProductId__r.Name
                    FROM   EX_Promotion__c
                    WHERE  (Part_No__c IN: expPdSet OR ProductId__c IN: expPdSet) AND Promotion_USE_YN__c = 'Y'];
                                for(EX_Promotion__c exp : expList){
                                    //검증 필요
                                    // if (!(exp.PromotionEndDate__c < Date.ValueOf(promotionDate.get(exp.SHIPPED_Department_Code__c+'_'+exp.ProductId__c)[0])
                                    // || Date.ValueOf(promotionDate.get(exp.SHIPPED_Department_Code__c+'_'+exp.ProductId__c)[1]) > exp.PromotionStartDate__c) ) {
                                    //     promotionMap.put(exp.SHIPPED_Department_Code__c+'_'+exp.ProductId__c, exp.Id);
                                    // }
                                 
                                   if (promotionDate.get(exp.SHIPPED_Department_Code__c+'_'+exp.ProductId__c) != null) {
                                    
                                       if ((exp.PromotionStartDate__c <= Date.ValueOf(promotionDate.get(exp.SHIPPED_Department_Code__c+'_'+exp.ProductId__c)[0])   
                                       &&  exp.PromotionEndDate__c > Date.ValueOf(promotionDate.get(exp.SHIPPED_Department_Code__c+'_'+exp.ProductId__c)[0]))
                                       || (exp.PromotionStartDate__c < Date.ValueOf(promotionDate.get(exp.SHIPPED_Department_Code__c+'_'+exp.ProductId__c)[1])  
                                       &&  exp.PromotionEndDate__c >= Date.ValueOf(promotionDate.get(exp.SHIPPED_Department_Code__c+'_'+exp.ProductId__c)[1]))
                                       || (exp.PromotionStartDate__c >= Date.ValueOf(promotionDate.get(exp.SHIPPED_Department_Code__c+'_'+exp.ProductId__c)[0])
                                       &&  exp.PromotionEndDate__c  <= Date.ValueOf(promotionDate.get(exp.SHIPPED_Department_Code__c+'_'+exp.ProductId__c)[1]))) {
                                           promotionMap.put(exp.SHIPPED_Department_Code__c+'_'+exp.ProductId__c, exp.ProductId__c);
                                       }
                                   }
                                    // exPm.PromotionStartDate__c <= Date.ValueOf(promotionDate.get(exPm.SHIPPED_Department_Code__c+'_'+exPm.ProductId__c))
                                    // && Date.ValueOf(promotionDate.get(exPm.SHIPPED_Department_Code__c+'_'+exPm.ProductId__c)) <= exPm.PromotionEndDate__c
                                    // if(exp.SHIPPED_Department_Code__c != null && exp.Part_No__c != null) {
                                        //     oldExpKey = exp.SHIPPED_Department_Code__c + '_' + exp.ProductId__c + '_' + exp.Promotion_USE_YN__c;
                                        // } else {
                                            //     oldExpKey = exp.Department_Code__c + '_' + exp.ProductId__c + '_' + exp.Promotion_USE_YN__c;
                                            // }
                                            // if(newExpKey == oldExpKey){
                                                // }

                                        //         ( dupPromotionMap.get(exp.DIV_CODE__c+'_'+exp.Part_No__c)[0] <= exp.PromotionStartDate__c 
                                        // && dupPromotionMap.get(exp.DIV_CODE__c+'_'+exp.Part_No__c)[1] >= exp.PromotionStartDate__c) 

                                        // || dupPromotionMap.get(exp.DIV_CODE__c+'_'+exp.Part_No__c)[0] <= exp.PromotionEndDate__c  
                                        // &&  dupPromotionMap.get(exp.DIV_CODE__c+'_'+exp.Part_No__c)[1] >= exp.PromotionEndDate__c
                                }
                        
                            Integer i = 0;
                            for(EX_Promotion__c exp : listNew){
                                    if(exp.Promotion_USE_YN__c == 'Y' && promotionMap.get(exp.SHIPPED_Department_Code__c+'_'+exp.ProductId__c) != null){
                                        exp.addError('이미 프로모션이 진행중인 상품입니다.');
                                    }
                                    String listKey = exp.DIV_CODE__c + exp.Part_No__c + String.valueOf(exp.PromotionStartDate__c).replaceAll('0','').replaceAll('-','').replaceAll(':', '') + String.valueOf(exp.PromotionEndDate__c).replaceAll('0','').replaceAll('-','').replaceAll(':', '');
                                    if (exp.Promotion_USE_YN__c == 'Y') {
                                        if (dupPromotionMap.get(exp.DIV_CODE__c+'_'+exp.Part_No__c).size() > 1) {
                                            for (String valDate : dupPromotionMap.get(exp.DIV_CODE__c+'_'+exp.Part_No__c)) {
                                                Date startDate = Date.valueOf(valDate.split('/')[0]);
                                                Date endDate = Date.valueOf(valDate.split('/')[1]);
                                                String expKey = valDate.split('/')[2];
                                                    if (expKey != listKey) {
                                                        if (exp.PromotionStartDate__c <= startDate && exp.PromotionEndDate__c >  startDate
                                                        ||exp.PromotionStartDate__c < endDate && exp.PromotionEndDate__c >= endDate
                                                        ||exp.PromotionStartDate__c >= startDate && exp.PromotionEndDate__c <= endDate ) {
                                                            exp.addError('프로모션의 날짜를 재설정 해주세요.');
                                                        } 
                                                    }
                                            }
                                        }
                                    }
                                    
                                    // 동시에 insert할때 기간이 겹칠시 처리로직 (같은 번호로 날짜가 겹칠시)
                                    // System.debug('dupPromotionMap ??' + dupPromotionMap);
                                    // if (exp.Promotion_USE_YN__c == 'Y' && dupPromotionMap.containsKey(exp.DIV_CODE__c+'_'+exp.Part_No__c)) {
                                    //     //해당 번호의 첫번째 시작날짜가 뒤에 들어온 시작날짜보다 작고 
                                    //     if ((exp.PromotionStartDate__c <= dupPromotionMap.get(exp.DIV_CODE__c+'_'+exp.Part_No__c)[0]   
                                    //     &&  exp.PromotionEndDate__c >= dupPromotionMap.get(exp.DIV_CODE__c+'_'+exp.Part_No__c)[0])
                                    //     || (exp.PromotionStartDate__c <= dupPromotionMap.get(exp.DIV_CODE__c+'_'+exp.Part_No__c)[1]  
                                    //     &&  exp.PromotionEndDate__c >= dupPromotionMap.get(exp.DIV_CODE__c+'_'+exp.Part_No__c)[1])
                                    //     || (exp.PromotionStartDate__c >= dupPromotionMap.get(exp.DIV_CODE__c+'_'+exp.Part_No__c)[0]
                                    //     &&  exp.PromotionEndDate__c  <= dupPromotionMap.get(exp.DIV_CODE__c+'_'+exp.Part_No__c)[1])) {
                                    //         exp.addError('이미 프로모션이 진행중인 상품입니다.');
                                    //     }
                                        
                                    // } else {
                                    //     dupPromotionMap.put(exp.DIV_CODE__c+'_'+exp.Part_No__c , new List<Date> {exp.PromotionStartDate__c,exp.PromotionEndDate__c });
                                    // }
                                  
                                
                            }
                        
                         
                            
                        }
                    }
    
    //12.15 seung yoon heo
    public static void validationDate(List<EX_Promotion__c> listnew){
        Set<String> pmPartList = new Set<String>();
        Set<String> myPromotion = new Set<String>();
        Map<String, List<Object>> promotionDate = new Map<String, List<Object>>();
    
        for (EX_Promotion__c pm : listnew) {
            // N인 값들은 따로 찾을 필요가 없음.
            if (pm.Promotion_USE_YN__c == 'Y') {
                //2024.01.02 seung yoon heo 업데이트 시엔 날짜 설정 빼기
                // if(pm.PromotionStartDate__c <= System.today()) {
                //     pm.PromotionStartDate__c.addError('프로모션 시작일자는 D+1부터 설정 가능합니다.'); // 프로모션 시작일자 Validation
                // }
                if(pm.PromotionPrice__c >= pm.fm_PRODUCT_CUST_PRICE__c){
                    pm.PromotionPrice__c.addError('프로모션 할인 판매가는 소비자가보다 작아야합니다.');
                }
                // 이미 insert시에 SHIPPED_Department_Code__c와 Department_Code__c를 같은 값으로 맞춤
                pmPartList.add(pm.ProductId__c);
                myPromotion.add(pm.Id);
                promotionDate.put(pm.SHIPPED_Department_Code__c + '_' + pm.ProductId__c, new List<Object> {pm.PromotionStartDate__c, pm.PromotionEndDate__c} );
                // newExpKey = pm.SHIPPED_Department_Code__c + '_' + pm.ProductId__c;
                // expPartNo = pm.Part_No__c;
                // expDeptCode = pm.SHIPPED_Department_Code__c;
                
            }
        }
    
        List<EX_Promotion__c> existingPmList = [SELECT Id, Name,SHIPPED_Department_Code__c,ProductId__c, Part_No__c, PromotionStartDate__c, PromotionEndDate__c FROM EX_Promotion__c WHERE Id NOT IN: myPromotion AND ProductId__c IN: pmPartList AND Promotion_USE_YN__c = 'Y' ];
    
        if (existingPmList.size() > 0) {
            Map<String, String> promotionMap = new Map<String, String>();
            for (EX_Promotion__c exPm : existingPmList) {
                if (promotionDate.get(exPm.SHIPPED_Department_Code__c+'_'+exPm.ProductId__c) != null) {
                    if ((exPm.PromotionStartDate__c <= (Date.ValueOf(promotionDate.get(exPm.SHIPPED_Department_Code__c+'_'+exPm.ProductId__c)[0]))  
                    && exPm.PromotionEndDate__c > Date.ValueOf(promotionDate.get(exPm.SHIPPED_Department_Code__c+'_'+exPm.ProductId__c)[0]))
                    || (exPm.PromotionStartDate__c < Date.ValueOf(promotionDate.get(exPm.SHIPPED_Department_Code__c+'_'+exPm.ProductId__c)[1]) 
                    && exPm.PromotionEndDate__c >= Date.ValueOf(promotionDate.get(exPm.SHIPPED_Department_Code__c+'_'+exPm.ProductId__c)[1]))
                    || (exPm.PromotionStartDate__c >= Date.ValueOf(promotionDate.get(exPm.SHIPPED_Department_Code__c+'_'+exPm.ProductId__c)[0])
                    && exPm.PromotionEndDate__c <= Date.ValueOf(promotionDate.get(exPm.SHIPPED_Department_Code__c+'_'+exPm.ProductId__c)[1]))
                    ) {
                        promotionMap.put(exPm.SHIPPED_Department_Code__c+'_'+exPm.Part_No__c , exPm.Id);
                    }
                }
            }   

    
            for (EX_Promotion__c err : listnew) {
                if (promotionMap.get(err.SHIPPED_Department_Code__c+'_'+err.Part_No__c) != null) {
                    err.addError('이미 프로모션이 진행중인 상품입니다.');
                }
            }
        }
    
    }
    
    /**
     * @description 기존 프로모션 데이터 사용여부 N 처리
     * @author I2MAX.SEOKHOLEE
     */
    // public void setNotUsingPromotion() {
    //     Map<String, EX_Promotion__c> newMap = new Map<String, EX_Promotion__c>();
    //     for (EX_Promotion__c exPm : listNew) {
    //         if(expm.ProductId__c != null) {
    //             newMap.put(expm.ProductId__c, exPm);
    //         }
    //     }
    //     List<EX_Promotion__c> existPromotions = [
    //             SELECT Id, ProductId__c, Promotion_USE_YN__c
    //             FROM EX_Promotion__c
    //             WHERE ProductId__c IN :newMap.keySet()
    //             AND Promotion_USE_YN__c = 'Y'
    //     ];
    
    //     Map<String, EX_Promotion__c> notUsingPromotionMap = new Map<String, EX_Promotion__c>();
    //     for (EX_Promotion__c existPm : existPromotions) {
    //         if(!Trigger.newMap.containsKey(existPm.Id)){
    //             existPm.Promotion_USE_YN__c = 'N';
    //             notUsingPromotionMap.put(existPm.Id, existPm);
    //         }
    //     }
    //     if(!notUsingPromotionMap.isEmpty()) update notUsingPromotionMap.values();
    // }
    
    }