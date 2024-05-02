/**
 * Created by I2MAX.JAEYEONLEE on 2023-07-05.
 */
public without sharing class EXWijmoExtension {

    public String stub { get; set; }
    public String css { get; set; }
    public String gid { get; set; }

    public void onPageLoaded() {
        Map<String, String> kParam = ApexPages.currentPage().getParameters();

        if (kParam.isEmpty()) {
            return;
        }
        stub =  kParam.get('stub');
        css =  kParam.get('css');
        gid =  kParam.get('gid');
    }
}