/**
 * Created by I2MAX.JAEYEONLEE on 2023-07-05.
 */

({
    sendMessage: function (component, payload) {
        const wijmo = component.find('wijmo').getElement().contentWindow;
        wijmo.postMessage(payload, '*');
    },
    wijmoListeners: {},
    addWijmoListener: function (component) {
        const id = component.getGlobalId();
        let listener = this.wijmoListeners[id];
        if (null != listener) {
            window.removeEventListener('message', listener);
        }
        listener = $A.getCallback((evt) => {
            const gid = component.get('v.gid');
            const payload = evt.data;
            if (gid === payload.gid) {
                this.onWijmoMessage(component, payload);
            }
        });
        window.addEventListener('message', listener);
        this.wijmoListeners[id] = listener;
    },
    removeWijmoListener: function (component) {
        const id = component.getGlobalId();
        let listener = this.wijmoListeners[id];
        if (listener) {
            window.removeEventListener('message', listener);
            delete this.wijmoListeners[id];
        }
    },
    onWijmoMessage: function (component, payload) {
        const event = component.getEvent('onmessage');
        event.setParam('payload', payload);
        event.fire();
    },
});