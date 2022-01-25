public with sharing class MagicMassLoaderController {

    @AuraEnabled
    public static void loadMassData(String base64) {
        Blob decodeData = EncodingUtil.base64Decode(base64);
        System.debug(decodeData.toString());
    }
}
