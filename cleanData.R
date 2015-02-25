########################################################################
# Clean data set - remove all the attributes that will provide nothing
# 
# Author: Matthew A. Lanham
# Updated: 01/07/2015
#########################################################################

cleanData = function(dataSetName) {

#assess quality of data
source("DataQualityReport.R")
quality = DataQualityReport(dataSetName)
#remove attributes that have less than 50% missing values
quality = quality[which(quality$PercentComplete>50),]
#remove attributes that are all the same number (ie. numeric vars without variation or only one factor for factors)
quality = quality[which((quality$Type == 'numeric' & (quality$Min != quality$Max)) | (quality$Type == 'factor' & quality$NumberLevels>1)),]
#vars to use
vars = as.character(quality$Attributes)
#cleaned data set
dataSetName = dataSetName[vars]

return(dataSetName)
}