import { LightningElement,api } from 'lwc';
import loadData from '@salesforce/apex/MagicMassLoaderController.loadFileData'

export default class MagicMassLoaderHome extends LightningElement {
    @api
    myRecordId;

    get acceptedFormats() {
        return ".txt, .csv";
    }

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

    startUpload(){
        const {base64, filename} = this.uploadData;

        loadData({ base64}).then(result=>{
            this.loadResult = result
            this.startRolling = false
        })
    }

}