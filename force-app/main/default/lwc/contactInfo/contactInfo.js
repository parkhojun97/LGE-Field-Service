import { LightningElement, api, track } from 'lwc';
import getContactInfo from '@salesforce/apex/ContactController.getContacts';
import setContactInfo from '@salesforce/apex/ContactController.setContacts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ContactInfo extends LightningElement {
    @api recordId;
    contName;
    contBirthdate;
    contPhone;
    contEmail;
    contAccName;
    contDept;
    contEditClick = false;
    validChk = false;
    dataList = [];
    oldValSet;
    
    connectedCallback() {
        this.getInitData();
    }

    getInitData() {
        getContactInfo({recordId:this.recordId})
        .then((result) => {
            this.contName = result.contName;
            this.contBirthdate = result.contBirthdate;
            this.contMobilePhone = result.contMobilePhone;
            this.contEmail = result.contEmail;
            this.contAccName = result.contAccName;
            this.contDept = result.contDept;

            this.oldValSet = {
                'contName' : result.contName,
                'contBirthdate' : result.contBirthdate,
                'contMobilePhone' : result.contMobilePhone,
                'contEmail' : result.contEmail,
                'contAccName' : result.contAccName,
                'contDept' : result.contDept
            };
        })
        .catch((error) => {
            this.error = error;
        });
    }

    contInfoEdit() {
        this.contEditClick = true;
    }

    closeContInfoEdit() {
        console.log('old value set =>', JSON.stringify(this.oldValSet));
        this.contName = this.oldValSet.contName;
        this.contMobilePhone = this.oldValSet.contMobilePhone;
        this.contBirthdate = this.oldValSet.contBirthdate;
        this.contEmail = this.oldValSet.contEmail;
        this.contAccName = this.oldValSet.contAccName;
        this.contDept = this.oldValSet.contDept;

        this.contEditClick = false;
    }
    
    setNewVal(event) {
        var targetLabel = event.target.label;
        
        if(targetLabel == 'ContactName') this.contName        = event.target.value;
        if(targetLabel == 'Mobile')      this.contMobilePhone = event.target.value;
        if(targetLabel == 'Birth')       this.contBirthdate   = event.target.value;
        if(targetLabel == 'Email')       this.contEmail       = event.target.value;
        if(targetLabel == 'AccountName') this.contAccName     = event.target.value;
        if(targetLabel == 'Department')  this.contDept        = event.target.value;

    }

    setDataValidChk(){
        if((this.contName        == null || this.contName        == '' || this.contName        == undefined)
        || (this.contBirthdate   == null || this.contBirthdate   == '' || this.contBirthdate   == undefined)
        || (this.contMobilePhone == null || this.contMobilePhone == '' || this.contMobilePhone == undefined)
        || (this.contEmail       == null || this.contEmail       == '' || this.contEmail       == undefined)
        || (this.contAccName     == null || this.contAccName     == '' || this.contAccName     == undefined)
        || (this.contDept        == null || this.contDept        == '' || this.contDept        == undefined)){
            
            this.validChk = false;
        } else {
            this.validChk = true;
        }
    }

    saveContInfoEdit() {
        this.setDataValidChk();
        if(this.validChk) {
            this.dataList.push(
                {
                    'contName' : this.contName,
                    'contBirthdate' : this.contBirthdate,
                    'contMobilePhone' : this.contMobilePhone,
                    'contEmail' : this.contEmail,
                    'contAccName' : this.contAccName,
                    'contDept' : this.contDept
                }
            );

            console.log('dataList =>', JSON.stringify(this.dataList));

            setContactInfo({dataSet : this.dataList, recordId : this.recordId})
            .then((result) => {
                if(result == 'success'){
                    this.showToast('success', '저장 성공.');
                    console.log('result =>', result);
                    this.contEditClick = false;
                } else if(result == 'fail'){
                    console.log('result =>', result);
                    this.showToast('error', '저장에 실패하였습니다.');
                }
            })
            .catch((error) => {
                console.log(error);
            })

        } else {
            console.log('err');
            this.showToast('warning', '빈 값을 입력할 수 없습니다.');
        }
    }

    showToast(variant, message) {
        const evt = new ShowToastEvent({
            variant : variant,
            message : message,
        });
        this.dispatchEvent(evt);
    }
}