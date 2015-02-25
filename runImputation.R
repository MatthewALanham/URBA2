########################################################################
# This run the imputation based on parameters provided
# 
# Author: Matthew A. Lanham
# Updated: 01/08/2015
#########################################################################

runImputation = function(dataSetName, modelCluster, ModelOrScore, ImputeTechnique, recordTime, recordStats) {

#dataSetName = md
#modelCluster='MPOG-DATA_CLASSIFICATION'
#ModelOrScore='Model'
#ImputeTechnique='kNN'
#ImputeTechnique='median'
#recordTime=TRUE
#recordStats=TRUE
#rm(dataSetName,ModelOrScore,ImputeTechnique,recordTime,recordStats)

ptm = proc.time() #beginning run time

## measure initial data quality
initialQualityPct = DataQualityReportOverall(dataSetName)[3]

## record inital quality statistic
if (recordStats==TRUE) {
  # what is the correct measure name
  measure = defineMeasureName(ModelOrScore, statKind='initial')
  # what is the correct cluster we are using
  if (modelCluster == 'PART_TYPE-CLUSTER') {
    pmst[which(pmst$PART_TYPE == PART_TYPE & pmst$PLATFORM_CLUSTER_NAME == PLATFORM_CLUSTER_NAME), measure] = initialQualityPct
  } else if (modelCluster == 'MPOG-DATA_CLASSIFICATION') {
    pmst[which(pmst$DATA_CLASSIFICATION == DATA_CLASS & pmst$MPOG_ID == MPOG_ID), measure] = initialQualityPct
  }
}

## impute as needed  
if (initialQualityPct < 100) {
    dataSetName = suppressWarnings(Impute(dataSetName, ImputeTechnique=ImputeTechnique)) #Impute imputes missing values
  } 

## measure post imputation data quality
newQualityPct = DataQualityReportOverall(dataSetName)[3]

## record new quality statistic
if (recordStats==TRUE) {
  # what is the correct measure name
  measure = defineMeasureName(ModelOrScore, statKind='new')
  # what is the correct cluster we are using
  if (modelCluster == 'PART_TYPE-CLUSTER') {
    pmst[which(pmst$PART_TYPE == PART_TYPE & pmst$PLATFORM_CLUSTER_NAME == PLATFORM_CLUSTER_NAME), measure] = newQualityPct
  } else if (modelCluster == 'MPOG-DATA_CLASSIFICATION') {
    pmst[which(pmst$DATA_CLASSIFICATION == DATA_CLASS & pmst$MPOG_ID == MPOG_ID), measure] = newQualityPct
  }
}
 
ptm2 = proc.time() #ending run time

## record total run time in minutes
if (recordTime==TRUE) {
  # what is the correct measure name
  measure = defineMeasureName(ModelOrScore, statKind='time')
  # what is the correct cluster we are using
  if (modelCluster == 'PART_TYPE-CLUSTER') {
    pmst[which(pmst$PART_TYPE == PART_TYPE & pmst$PLATFORM_CLUSTER_NAME == PLATFORM_CLUSTER_NAME),measure] = (ptm2["elapsed"][[1]] - ptm["elapsed"][[1]])/60
  } else if (modelCluster == 'MPOG-DATA_CLASSIFICATION') {
    pmst[which(pmst$DATA_CLASSIFICATION == DATA_CLASS & pmst$MPOG_ID == MPOG_ID),measure] = (ptm2["elapsed"][[1]] - ptm["elapsed"][[1]])/60
  }
}

return(dataSetName)
}
