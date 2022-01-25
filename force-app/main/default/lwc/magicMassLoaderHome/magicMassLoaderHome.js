import { LightningElement,api } from 'lwc';
import loadData from '@salesforce/apex/MagicMassLoaderController.loadMassData'

export default class MagicMassLoaderHome extends LightningElement {
    @api
    myRecordId;

    get acceptedFormats() {
        return ".txt, .csv";
    }

    uploadData
    cacheUploadData(event) {
 
        const file = event.target.files[0]
        var reader = new FileReader()
        reader.onload = () => {
            let base64 = reader.result.split(',')[1];
            let numOfLines = atob(base64).split(/\r\n|\r|\n/).length;
            this.uploadData = {
                'filename': file.name,
                'base64': base64,
                'numOfLines':numOfLines
            }
        }
        reader.readAsDataURL(file);
    }

    startUpload(){
        console.log('test');
        const {base64, filename} = this.uploadData;

        loadData({ base64}).then(result=>{
            this.fileData = null
            let title = `${filename} uploaded successfully!!`
            console.log(title);
        })
    }

}