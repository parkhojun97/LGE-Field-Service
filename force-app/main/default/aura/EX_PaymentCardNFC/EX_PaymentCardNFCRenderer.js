/**
 * Created by A78916 on 2023-06-02.
 */

({
    // render: function (component, helper) {
    //     const rendered = this.superRender();
    //     return rendered;
    // },
    unrender: function (component, helper) {
        const rendered = this.superUnrender();
        helper.unsubscribe(component);
        return rendered;
    }
});