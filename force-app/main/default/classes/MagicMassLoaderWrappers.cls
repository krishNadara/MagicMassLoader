global with sharing class MagicMassLoaderWrappers {
    global class LoadResult {
        @AuraEnabled
        global Integer linesProcessed { get; private set;}
        @AuraEnabled
        global Integer numSuccess { get; private set;}
        @AuraEnabled
        global Integer numFailure { get; private set;}

        global LoadResult(Integer linesProcessed, Integer numSuccess, Integer numFailure) {
            this.linesProcessed = linesProcessed;
            this.numSuccess = numSuccess;
            this.numFailure = numFailure;

        }
    }
}
