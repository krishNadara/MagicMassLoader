import { LightningElement,api,track,wire } from 'lwc';
import loadData from '@salesforce/apex/MagicMassLoaderController.loadFileData'
import getConfigs from '@salesforce/apex/MagicMassLoaderController.getObjectAllowed'

export default class MagicMassLoaderHome extends LightningElement {
    @track selectedStep = 'step1';
    @api
    myRecordId;
    @track objectsAllowed;
    @track showSelObj;
    @track showUpFile;
    @track showStartMagic;
    @track showReviewMagic;

    get acceptedFormats() {
        return ".txt, .csv";
    }

    targetObject
    noObjectConfigured
    loading
    progress
    loadResult
    startRolling
    uploadData
    cacheUploadData(event) {
 
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            this.loading = false;
            let base64 = reader.result.split(',')[1];
            let numOfLines = atob(base64).split(/\r\n|\r|\n/).length;
            this.uploadData = {
                'filename': file.name,
                'base64': base64,
                'numOfLines':numOfLines
            }
            this.startRolling = true
        }

        reader.onprogress = (data) => {
            this.loading = true;
            if (data.lengthComputable) {                                            
                this.progress = parseInt( ((data.loaded / data.total) * 100), 10 );
            }
        }

        reader.readAsDataURL(file);
    }

    @wire(getConfigs)
    wiredConfig({ error, data }) {
        if (data) {
            this.objectsAllowed = data;
            if(data.length == 0) {
                this.noObjectConfigured = true;
            } 
        } else if (error) {
            this.error = error;
            console.error('error => ', error); // error handling
        }
    }

    handleChange(event) {
        this.targetObject = event.detail.value;
    }

    startUpload(){
        const {base64, filename} = this.uploadData;
        const targetObject = this.targetObject;

        loadData({ targetObject, base64}).then(result=>{
            this.loadResult = result
            this.startRolling = false
        })
    }

    nextStep() {
        if(this.selectedStep == "step1")
            this.selectedStep = "step2";
        else if(this.selectedStep == "step2")
            this.selectedStep = "step3";
        else if(this.selectedStep == "step3")
            this.selectedStep = "step4";    
        else if(this.selectedStep == "step4")
            this.selectedStep = "step5";  
        if(this.selectedStep == "step2") {
            this.showSelObj = true;
            this.showUpFile = false;
            this.showStartMagic = false;
            this.showReviewMagic = false;
        }
        if(this.selectedStep == "step3") {
            this.showSelObj = false;
            this.showUpFile = true;
            this.showStartMagic = false;
            this.showReviewMagic = false;
        }
        if(this.selectedStep == "step4") {
            this.showSelObj = false;
            this.showUpFile = false;
            this.showStartMagic = true;
            this.showReviewMagic = false;
        }
    }
}