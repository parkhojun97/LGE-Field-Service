/**
 * @description       : 
 * @author            : hyungho.chun@dkbmc.com
 * @group             : 
 * @last modified on  : 01-18-2024
 * @last modified by  : hyungho.chun@dkbmc.com
**/
public without sharing class EX_ReceiptFormPdfController {

    public static ProductRequestTable prTable {get; set;}
    public static String jsonStr {get; set;}

    public static void doPdfGenerate() {
        System.debug('doPdfGenerate Start !!!!!!!!!');
        
        String productRequestId = ApexPages.currentPage().getParameters().get('productRequestId');
        String OrderChannel = ApexPages.currentPage().getParameters().get('OrderChannel');

        System.debug('productRequestId ::: '+productRequestId);
        System.debug('OrderChannel :::'+OrderChannel);

        String strQuery ='';
        
        strQuery += 'SELECT Id, Order_CHNL_TYPE_Code__c, Order_number__c, fm_MODEL_Code__c, PART_NO__c, SALE_Quantity__c, CONSUMER_Price__c, fm_Consumables_PART_DESC_KOR__c, fm_LOCATED_PLACE__c, SALE_Amount__c, Last_Discount_Amount__c, PAYMENT_Amount__c, Return_Order_Quantity__c, POINT_Amount__c, CASH_PAYMENT_Amount__c, CARD_PAYMENT_Amount__c, ';
        //23 10 04 hyungho.chun 이름도 마스킹처리 요청
        strQuery += 'parent.fm_ENC_Order_CUST_Name__c, parent.Order_CUST_Name__c, parent.SALE_Amount__c, parent.Discount_Amount__c, parent.PAYMENT_Amount__c, parent.Order_Date__c, parent.createdby.name, parent.SALE_Number__c, parent.fm_ENC_Order_CUST_TPNO_1__c, Parent.POINT_Amount__c, Parent.CASH_PAYMENT_Amount__c, Parent.CARD_PAYMENT_Amount__c, Parent.PAYMENT_COMPLETED_DTM__c, Parent.CreatedById__r.Name ';

        //23 09 08 hyungho.chun 데이터와 관계없이 SM_DEPT__c name이 '소모품센터'기준으로 나오게 수정
        // if(OrderChannel =='소모품택배'){
        //     strQuery += ', parent.CNSL_Department_Id__r.Name, parent.CNSL_Department_Id__r.ADDRESS__c, parent.CNSL_Department_Id__r.CHIEF_NAME__c, parent.CNSL_Department_Id__r.BIZ_ID__c , parent.CNSL_Department_Id__r.TEL_NO__c , parent.CNSL_Department_Id__r.BIZ_STAT__c , parent.CNSL_Department_Id__r.BIZ_CLASS__c ';
        // }else{
        //     strQuery += ', parent.Department_Id__r.Name, parent.Department_Id__r.ADDRESS__c, parent.Department_Id__r.CHIEF_NAME__c, parent.Department_Id__r.BIZ_ID__c , parent.Department_Id__r.TEL_NO__c , parent.Department_Id__r.BIZ_STAT__c , parent.Department_Id__r.BIZ_CLASS__c ';
        // }

        strQuery += 'FROM ProductRequestLineItem ';
        //23 09 08 hyungho.chun SALE_Quantity__c = 0 인경우(이미 다 반품확정 인 경우는 애시당초 아이템에서 제외)
        strQuery += 'WHERE parentid =: productRequestId AND SALE_Quantity__c != 0 ';
        strQuery += 'AND RecordType.DeveloperName IN (\'Consumable\' , \'CareSupplies\') ';
        
        List<ProductRequestLineItem> prliList = Database.query(strQuery);

        System.debug('prliList ::: '+prliList);

        //23 09 08 hyungho.chun 데이터와 관계없이 SM_DEPT__c DEPT_CODE__c가 'PH8002'기준으로 나오게 수정 ('소모품센터')
        //23 09 19 hyungho.chun address-> juso 보는거로 수정
        List<SM_DEPT__c> deptList = [SELECT name, JUSO__c,ADDRESS__c, CHIEF_NAME__c, BIZ_ID__c, TEL_NO__c, BIZ_STAT__c, BIZ_CLASS__c, DEPT_CODE__c, DETAIL_ADDR__c FROM SM_DEPT__c WHERE DEPT_CODE__c =: 'PH8002' LIMIT 1 ];
        SM_DEPT__c deptOne = deptList[0];

        List<ProductRequestLineItemTable> prLiListTable = new List<ProductRequestLineItemTable>(); 

        for(ProductRequestLineItem item : prliList){
            prLiListTable.add(new ProductRequestLineItemTable(item));
        }
        System.debug('prLiListTable :: '+prLiListTable );

        // ProductRequestTable prTable = new ProductRequestTable(prliList[0],OrderChannel);
        
        // prTable = new ProductRequestTable(prliList[0],OrderChannel,deptOne);
        //23 09 09 hyungho.chun prTable의 payment_amount, POINT_Amount, CASH_PAYMENT_Amount, CARD_PAYMENT_Amount 값을 productRequest가 아닌 반품안된 물품들의 가격 합을 따로 계산하기로 변경
        //23 09 09 -> prliList 통으로 받아서 계산해야함
        prTable = new ProductRequestTable(prliList,OrderChannel,deptOne);




        prTable.prLiListTable = prLiListTable;

        System.debug('prTable :: '+prTable);
        

        jsonStr = JSON.serialize(prTable);
        


        System.debug('doPdfGenerate End !!!!!!!!!!!');        
    }

    //23 09 12 hyungho.chun 금액부분 3자리마다 콤마 추가
    public static String convertNumToStr(Decimal num){

        List<String> args = new String[]{'0','number','###,###,##0.00'};
        String returnValue = String.format(num.format(), args);
        System.debug(returnValue);

        return returnValue;
    }
        
    public class ProductRequestTable {
        
        public String Order_Number { get; set; }
        public String Order_CUST_Name { get; set; }
        public String SALE_Amount { get; set; }
        public String Discount_Amount { get; set; }
        // public Decimal PAYMENT_Amount { get; set; }
        public String PAYMENT_Amount { get; set; }
        public String Order_Date { get; set; }
        public String CreatedByName { get; set; }
        public String deptName { get; set; }
        public String deptAddress { get; set; }
        public String deptChiefName { get; set; }
        public String deptBizId { get; set; }
        public String deptTelNo { get; set; }
        public String deptBizStat { get; set; }
        public String deptBizClass { get; set; }
        public String Sale_Number { get; set; }
        public String fm_ENC_Order_CUST_TPNO_1 { get; set; }
        //23 09 08 hyungho.chun 처리일자 기준 변경
        // public String Sale_CreatedDate { get; set; }
        // public Decimal POINT_Amount { get; set; }
        // public Decimal CASH_PAYMENT_Amount { get; set; }
        // public Decimal CARD_PAYMENT_Amount { get; set; }
        public String POINT_Amount { get; set; }
        public String CASH_PAYMENT_Amount { get; set; }
        public String CARD_PAYMENT_Amount { get; set; }
        public List<ProductRequestLineItemTable> prLiListTable { get; set; }

        public ProductRequestTable(){

        }
        //23 09 09 hyungho.chun ProductRequestLineItem 낱개만 확인하던 부분 주석처리
        // public ProductRequestTable(ProductRequestLineItem ProductRequestLineItem, String OrderChannel, SM_DEPT__c deptOne){
        //     this.Order_Number = ProductRequestLineItem.Order_Number__c;
        //     this.Order_CUST_Name = ProductRequestLineItem.parent.Order_CUST_Name__c;
        //     this.SALE_Amount = ProductRequestLineItem.parent.SALE_Amount__c;
        //     this.Discount_Amount = ProductRequestLineItem.parent.Discount_Amount__c;
        //     this.PAYMENT_Amount = ProductRequestLineItem.parent.PAYMENT_Amount__c;
        //     //23 09 08 hyungho.chun 주문날짜 -> 결제완료일자로 수정
        //     this.Order_Date = ProductRequestLineItem.parent.PAYMENT_COMPLETED_DTM__c.format('yyyy-MM-dd HH:mm:ss');
        //     // this.Order_Date = ProductRequestLineItem.parent.Order_Date__c.format('yyyy-MM-dd HH:mm:ss');
        //     this.CreatedByName = ProductRequestLineItem.parent.createdby.name;
        //     this.Sale_Number = ProductRequestLineItem.parent.SALE_Number__c;
        //     this.fm_ENC_Order_CUST_TPNO_1 = ProductRequestLineItem.parent.fm_ENC_Order_CUST_TPNO_1__c;
        //     //23 09 08 hyungho.chun 처리일자 기준 변경
        //     // this.Sale_CreatedDate = ProductRequestLineItem.SR_SALE__r.CreatedDate.format('yyyy-MM-dd');
        //     this.POINT_Amount = ProductRequestLineItem.Parent.POINT_Amount__c;
        //     this.CASH_PAYMENT_Amount = ProductRequestLineItem.Parent.CASH_PAYMENT_Amount__c;
        //     this.CARD_PAYMENT_Amount = ProductRequestLineItem.Parent.CARD_PAYMENT_Amount__c;
            //23 09 08 hyungho.chun 데이터와 관계없이 SM_DEPT__c name이 '소모품센터'기준으로 나오게 수정
            // if(OrderChannel == '소모품택배'){
            //     this.deptName = ProductRequestLineItem.parent.CNSL_Department_Id__r.Name;
            //     this.deptAddress = ProductRequestLineItem.parent.CNSL_Department_Id__r.ADDRESS__c;
            //     this.deptChiefName = ProductRequestLineItem.parent.CNSL_Department_Id__r.CHIEF_NAME__c;
            //     this.deptBizId = ProductRequestLineItem.parent.CNSL_Department_Id__r.BIZ_ID__c;
            //     this.deptTelNo = ProductRequestLineItem.parent.CNSL_Department_Id__r.TEL_NO__c;
            //     this.deptBizStat = ProductRequestLineItem.parent.CNSL_Department_Id__r.BIZ_STAT__c;
            //     this.deptBizClass = ProductRequestLineItem.parent.CNSL_Department_Id__r.BIZ_CLASS__c;
            // }else{
            //     this.deptName = ProductRequestLineItem.parent.Department_Id__r.Name;
            //     this.deptAddress = ProductRequestLineItem.parent.Department_Id__r.ADDRESS__c;
            //     this.deptChiefName = ProductRequestLineItem.parent.Department_Id__r.CHIEF_NAME__c;
            //     this.deptBizId = ProductRequestLineItem.parent.Department_Id__r.BIZ_ID__c;
            //     this.deptTelNo = ProductRequestLineItem.parent.Department_Id__r.TEL_NO__c;
            //     this.deptBizStat = ProductRequestLineItem.parent.Department_Id__r.BIZ_STAT__c;
            //     this.deptBizClass = ProductRequestLineItem.parent.Department_Id__r.BIZ_CLASS__c;
            // }


        //23 09 09 hyungho.chun ProductRequestLineItem 리스트로 받음
        public ProductRequestTable(List<ProductRequestLineItem> ProductRequestLineItems, String OrderChannel, SM_DEPT__c deptOne){
            this.Order_Number = ProductRequestLineItems[0].Order_Number__c;
            //23 10 04 hyungho.chun 이름도 마스킹 처리 요청
            this.Order_CUST_Name = ProductRequestLineItems[0].parent.fm_ENC_Order_CUST_Name__c;
            //23 12 04 hyungho.chun 부분반품고려 계산금액 수정 (아래 추가함)
            // this.SALE_Amount = convertNumToStr(ProductRequestLineItems[0].parent.SALE_Amount__c);
            //23 12 28 hyungho.chun 부분반품고려 할인금액 수정 (아래 추가함)
            // this.Discount_Amount = convertNumToStr(ProductRequestLineItems[0].parent.Discount_Amount__c);
            //23 09 09 hyungho.chun 반품안된것들의 합 계산
            Decimal sumOfPaymentAmt = 0;
            //23 12 28 hyungho.chun 반품안된것들 생각한 총 할인금액 로직추가
            Decimal sumOfDiscountAmt = 0;
            for (ProductRequestLineItem prli : ProductRequestLineItems){
                sumOfPaymentAmt += prli.Payment_Amount__c/(prli.SALE_Quantity__c+prli.Return_Order_Quantity__c) * prli.SALE_Quantity__c;
                sumOfDiscountAmt += prli.Last_Discount_Amount__c/(prli.SALE_Quantity__c+prli.Return_Order_Quantity__c) * prli.SALE_Quantity__c;
            }
            

            // this.PAYMENT_Amount = sumOfPaymentAmt;
            this.PAYMENT_Amount = convertNumToStr(sumOfPaymentAmt);
            //23 12 04 hyungho.chun 부분반품고려 계산금액 수정 -> 23 12 28 hyungho.chun 반품고려후의 총 결제금액 + 총 할인금액
            this.SALE_Amount = convertNumToStr(sumOfPaymentAmt+sumOfDiscountAmt);
            //2312 28 hyungho.chun 부분반품고려 할인금액 수정
            this.Discount_Amount = convertNumToStr(sumOfDiscountAmt);
            //23 09 11 hyungho.chun
            // this.Order_Date = ProductRequestLineItems[0].parent.PAYMENT_COMPLETED_DTM__c.format('yyyy-MM-dd HH:mm:ss');
            this.Order_Date = String.valueOf(ProductRequestLineItems[0].parent.PAYMENT_COMPLETED_DTM__c.date());
            
            this.CreatedByName = ProductRequestLineItems[0].Parent.CreatedById__r.Name != null ? ProductRequestLineItems[0].Parent.CreatedById__r.Name : ProductRequestLineItems[0].parent.createdby.name;
            this.Sale_Number = ProductRequestLineItems[0].parent.SALE_Number__c;
            this.fm_ENC_Order_CUST_TPNO_1 = ProductRequestLineItems[0].parent.fm_ENC_Order_CUST_TPNO_1__c;
            
            //23 09 09 hyungho.chun 반품안된것들의 합 계산 (결제방법 고려)
            Decimal sumOfPointAmt = 0;
            Decimal sumOfCashAmt = 0;
            Decimal sumOfCardAmt = 0;
            for (ProductRequestLineItem prli : ProductRequestLineItems){
                sumOfPointAmt += prli.POINT_Amount__c/(prli.SALE_Quantity__c+prli.Return_Order_Quantity__c) * prli.SALE_Quantity__c;
                sumOfCashAmt += prli.CASH_PAYMENT_Amount__c/(prli.SALE_Quantity__c+prli.Return_Order_Quantity__c) * prli.SALE_Quantity__c;
                sumOfCardAmt += prli.CARD_PAYMENT_Amount__c/(prli.SALE_Quantity__c+prli.Return_Order_Quantity__c) * prli.SALE_Quantity__c;
            }
            // this.POINT_Amount = ProductRequestLineItems[0].Parent.POINT_Amount__c;
            // this.CASH_PAYMENT_Amount = ProductRequestLineItems[0].Parent.CASH_PAYMENT_Amount__c;
            // this.CARD_PAYMENT_Amount = ProductRequestLineItems[0].Parent.CARD_PAYMENT_Amount__c;
            // this.POINT_Amount = sumOfPointAmt;
            // this.CASH_PAYMENT_Amount = sumOfCashAmt;
            // this.CARD_PAYMENT_Amount = sumOfCardAmt;
            
            this.POINT_Amount = convertNumToStr(sumOfPointAmt);
            this.CASH_PAYMENT_Amount = convertNumToStr(sumOfCashAmt);
            this.CARD_PAYMENT_Amount = convertNumToStr(sumOfCardAmt);








            // this.deptName = deptOne.Name;
            //23 09 21 hyungho.chun '엘지전자(주)' 로 하드코딩
            this.deptName = '엘지전자(주)';
            //23 09 19 hyungho.chun address-> juso 보는거로 수정
            //23 09 21 hyungho.chun 주소에 '소모품센터 , '추가 
            //23 11 22 hyungho.chun 주소에 DETAIL_ADDR__c (복합물류센터) 추가
            this.deptAddress = '소모품센터 , '+deptOne.JUSO__c+' '+deptOne.DETAIL_ADDR__c;
            // this.deptAddress = deptOne.ADDRESS__c;
            this.deptChiefName = deptOne.CHIEF_NAME__c;
            this.deptBizId = deptOne.BIZ_ID__c;
            this.deptTelNo = deptOne.TEL_NO__c;
            this.deptBizStat = deptOne.BIZ_STAT__c != null ? deptOne.BIZ_STAT__c : '' ;
            this.deptBizClass = deptOne.BIZ_CLASS__c != null ? deptOne.BIZ_CLASS__c : '';            
        }
        
        

    }

    public class ProductRequestLineItemTable {

        public Id Id { get; set; }
        public String Order_Channel_TYPE { get; set; }
        public String Order_Number { get; set; }
        public String fm_MODEL_Code { get; set; }
        public String PART_NO { get; set; }
        public Decimal SALE_Quantity { get; set; }
        // public Decimal CONSUMER_Price { get; set; }
        public String CONSUMER_Price { get; set; }
        public String fm_Consumables_PART_DESC_KOR { get; set; }
        public String fm_LOCATED_PLACE { get; set; }
        public String SALE_Amount { get; set; }
        public String Last_Discount_Amount { get; set; }
        // public Decimal PAYMENT_Amount { get; set; }
        public String PAYMENT_Amount { get; set; }
        public Decimal Return_Order_Quantity { get; set; }
        // public Decimal Actual_PriceEach { get; set; }
        public String Actual_PriceEach { get; set; }
    
        public ProductRequestLineItemTable(){

        }

        public ProductRequestLineItemTable(ProductRequestLineItem ProductRequestLineItem){
            this.Id = ProductRequestLineItem.Id;
            
            switch on ProductRequestLineItem.Order_CHNL_TYPE_Code__c {
                when 'B' {
                    this.Order_Channel_TYPE = EX_ConsumableUtil.CONSUMABLE_OBS_LABEL;
                }
                when 'S' {
                    this.Order_Channel_TYPE = EX_ConsumableUtil.CONSUMABLE_THINQ_LABEL;
                }
                when 'V' {
                    this.Order_Channel_TYPE = EX_ConsumableUtil.CONSUMABLE_CIC_LABEL;
                }
                when 'BestShop' {
                    this.Order_Channel_TYPE = EX_ConsumableUtil.CONSUMABLE_BESTSHOP_LABEL;
                }
                when else {
                    this.Order_Channel_TYPE = '미지정';
                }
            }

            this.Order_Number = ProductRequestLineItem.Order_Number__c;
            this.fm_MODEL_Code = ProductRequestLineItem.fm_MODEL_Code__c;
            this.PART_NO = ProductRequestLineItem.PART_NO__c;
            this.SALE_Quantity = ProductRequestLineItem.SALE_Quantity__c;
            // this.CONSUMER_Price = ProductRequestLineItem.CONSUMER_Price__c;
            this.CONSUMER_Price = convertNumToStr(ProductRequestLineItem.CONSUMER_Price__c);
            this.fm_Consumables_PART_DESC_KOR = ProductRequestLineItem.fm_Consumables_PART_DESC_KOR__c;
            this.fm_LOCATED_PLACE = ProductRequestLineItem.fm_LOCATED_PLACE__c;
            //23 12 04 hyungho.chun 부분반품고려 계산금액 수정 
            // this.SALE_Amount = convertNumToStr(ProductRequestLineItem.SALE_Amount__c);
            // this.SALE_Amount = convertNumToStr(ProductRequestLineItem.Payment_Amount__c/(ProductRequestLineItem.SALE_Quantity__c+ProductRequestLineItem.Return_Order_Quantity__c) * ProductRequestLineItem.SALE_Quantity__c);
            //24 01 18 hyungho.chun 금액 -> 결제금액-반품수량계산  => 판매금액-반품수량계산 (할인금액포함된가격이보이게)
            this.SALE_Amount = convertNumToStr(ProductRequestLineItem.SALE_Amount__c/(ProductRequestLineItem.SALE_Quantity__c+ProductRequestLineItem.Return_Order_Quantity__c) * ProductRequestLineItem.SALE_Quantity__c);
            this.Last_Discount_Amount = convertNumToStr(ProductRequestLineItem.Last_Discount_Amount__c);
            //23 09 08 부분반품케이스때문에 계산 다시해줌
            // this.PAYMENT_Amount = ProductRequestLineItem.PAYMENT_Amount__c;
            // this.PAYMENT_Amount = ProductRequestLineItem.Payment_Amount__c/(ProductRequestLineItem.SALE_Quantity__c+ProductRequestLineItem.Return_Order_Quantity__c) * ProductRequestLineItem.SALE_Quantity__c;
            // this.Actual_PriceEach = ProductRequestLineItem.Payment_Amount__c/(ProductRequestLineItem.SALE_Quantity__c+ProductRequestLineItem.Return_Order_Quantity__c);
            this.PAYMENT_Amount = convertNumToStr(ProductRequestLineItem.Payment_Amount__c/(ProductRequestLineItem.SALE_Quantity__c+ProductRequestLineItem.Return_Order_Quantity__c) * ProductRequestLineItem.SALE_Quantity__c);
            this.Actual_PriceEach = convertNumToStr(ProductRequestLineItem.Payment_Amount__c/(ProductRequestLineItem.SALE_Quantity__c+ProductRequestLineItem.Return_Order_Quantity__c));

            this.Return_Order_Quantity = ProductRequestLineItem.Return_Order_Quantity__c != 0 ?  ProductRequestLineItem.Return_Order_Quantity__c : 0;
            
            
        }

    }


}