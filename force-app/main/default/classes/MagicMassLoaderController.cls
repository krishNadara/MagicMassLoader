public with sharing class MagicMassLoaderController {

    @AuraEnabled
    public static MagicMassLoaderWrappers.LoadResult loadFileData(String base64) {
        
        MagicMassLoaderService mmls = new MagicMassLoaderService();
        
        return mmls.loadMassData(base64);
    }
}
