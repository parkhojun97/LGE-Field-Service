@IsTest
private class EXWijmoExtension_ts {

    @TestSetup
    static void setData(){
        EXWijmoExtension onPageLoad = new EXWijmoExtension();
        onPageLoad.stub = 'stub';
        onPageLoad.css = 'css';
        onPageLoad.gid = 'gid';


        
    }

    @IsTest
    static void test01() {

        Test.startTest();
        ApexPages.currentPage().getParameters().put('stub', 'stub');
        ApexPages.currentPage().getParameters().put('css', 'css');
        ApexPages.currentPage().getParameters().put('gid', 'gid');
        EXWijmoExtension onPageLoad = new EXWijmoExtension();
        onPageLoad.onPageLoaded();
        Test.stopTest();
   
    }
}