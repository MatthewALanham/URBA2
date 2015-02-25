########################################################################
# This function generates a rebalanced training data set
# Author: Matthew A. Lanham
# Updated: 12/29/2014
#########################################################################

Rebalance = function(AlgorithmName, dataSetName, Inputs_RFile, Covariates, Response) {

###JUST FOR FUNCTION TESTING
#AlgorithmName="ubOver"
#dataSetName=md
#Inputs_RFile="binary_target_attributes.R"
#Inputs_RFile=NULL
#Covariates = ad_vars
#Covariates = myModelingSubset
#Covariates = NULL
#Response=Y_var
#names(dataSetName)
  
require(unbalanced) ##the package used for ubOver,UbUnder, etc.
##Allows a way to pass in an R file of attributes 
if (length(Covariates) > 1) {
  input = dataSetName[dataSetName["SPSS_Partition"]=="Train", Covariates] 
} else {
  input = dataSetName[dataSetName["SPSS_Partition"]=="Train", Inputs_RFile]
}
output = dataSetName[dataSetName["SPSS_Partition"]=="Train", Response]

##the count of the training data set responses before balancing
table(output)

##re-balance types:
##  "ubOver"  (over-sampling), 
##  "ubUnder" (over-sampling), 
##  "ubSMOTE" (SMOTE), 
##  "ubOSS"   (One Side Selection),
##  "ubCNN"   (One Side Selection),
##  "ubENN"   (Edited Nearest Neighbor), 
##  "ubNCL"   (Neighborhood Cleaning Rule), 
##  "ubTomek" (Tomek Link)).

if (AlgorithmName=="ubOver") {
##ubOver() replicates randomly some instances from the minority class in order to obtain a final dataset with the same number of instances from the two classes.
data = ubOver(
    X=input    # the input variables of the unbalanced dataset.
  , Y=output   # the response variable of the unbalanced dataset. It must be a binary factor where the majority class is coded as 0 and the minority as 1.
  , k=0        # defines the sampling method.
               ## If K=0: sample with replacement from the minority class until we have the same number of instances in each class. 
               ## If K>0: sample with replacement from the minority class until we have k-times the orginal number of minority instances.
  )

} else if (AlgorithmName=="ubUnder") { 
  
##ubUnder() removes randomly some instances from the majority class in order to obtain a more balanced dataset
data = ubUnder(
    X=input           # the input variables of the unbalanced dataset.
  , Y=output          # the response variable of the unbalanced dataset. It must be a binary factor where the majority class is coded as 0 and the minority as 1
  , propMinClass=110  # proportion of minority class wanted in the final dataset (propMinClass=40 means 40 minority instances every 100 instances)
  , w = 0.50          # weights used for sampling the majority class, if NULL all majority instances are sampled with equal weights
  )  

} else if (AlgorithmName=="ubSMOTE") {
  
##ubSMOTE() implements SMOTE (synthetic minority over-sampling technique)
data = ubSMOTE(
    X=input         # the input variables of the unbalanced dataset.
  , Y=output        # the response variable of the unbalanced dataset. It must be a binary factor where the majority class is coded as 0 and the minority as 1.
  , perc.over=100   # per.over/100 is the number of new instances generated for each rare instance. If perc.over < 100 a single instance is generated.
  , perc.under=100  # perc.under/100 is the number of "normal" (majority class) instances that are randomly selected for each smoted observation.
  , k=0             # the number of neighbours to consider as the pool from where the new examples are generated
  , verbose=FALSE   # print extra information (TRUE/FALSE)
  )

} else if (AlgorithmName=="ubOSS") {
##"ubOSS" (One Side Selection)
  
} else if (AlgorithmName=="ubCNN") {
##  "ubCNN" (One Side Selection)

} else if (AlgorithmName=="ubENN") {
##  "ubENN"  (Edited Nearest Neighbor)

} else if (AlgorithmName=="ubNCL") {
##  "ubNCL"  (Neighborhood Cleaning Rule)

} else if (AlgorithmName=="ubTomek") {
##  "ubTomek" (Tomek Link)).

} else {

}
#data = ubBalance(X=input, Y=output, type="ubSMOTE", perc.over=300, perc.under=100, verbose=TRUE)
#Check out the functions upSample() and downSample() from the library(AppliedPredictiveModeling) package is another option though less extensive

##the count of the balanced data set responses
Cnts = table(data$Y)

##the new balaneced data set
balancedData = cbind(data$X,data$Y)
names(balancedData)[names(balancedData)=="data$Y"] = Response
return(balancedData)
}

