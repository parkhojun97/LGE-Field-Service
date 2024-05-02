/**
 * Created by sm.yang on 2023-07-10.
 */

trigger Asset_tr on Asset (before insert, before update) {
	new Asset_trHandler().run();
}