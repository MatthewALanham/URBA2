#################################################################################
## Tutorial: Using R for Business Analytics
## 
## Author: MatthewALanham.com
## 2015
#################################################################################
#################################################################################
### DATA section
## Task 2: Get data
getwd()              # your working directory
setwd("C:\\URBA")    # change your working directory
# downloand data from github repo into your machine's working directory
download.file(url="https://raw.githubusercontent.com/MatthewALanham/URBA2/master/urba_pres_data.csv"
              , destfile="urba_pres_data.csv")
# load data into R
data = read.csv("urba_pres_data.csv")

## Task 3: Get data ready for analysis
names(data)
head(data, n=3)
summary(data)                #summary of all variables
summary(data$RETAIL_PRICE)   #five number summary for retail price only
# a histogram of a variable
hist(data$RETAIL_PRICE
     ,main="Histogram of Retail Price"
     ,xlab="Retail price ($)"
     , col="lightblue")

## Lets discuss knitR here
library(knitr)
knit2html("knitR_ex1.Rmd")  #To create a webpage
browseURL("knitR_ex1.html") #Opens webpage

## Assess data quality
source("DataQualityReport.R")  #The source() function lets you load in function you created
DataQualityReport(data)        #Run data quality report
# I'll save this report as a data.frame
QAreport = DataQualityReport(data)

# Set the datatype correctly for these variables
data$DC = as.factor(data$DC)
data$STORE_NUMBER = as.factor(data$STORE_NUMBER)
data$REGION = as.factor(data$REGIOIN)
data$SKU_NUMBER = as.factor(data$SKU_NUMBER)
data$SOLD_SINCE_MAXI = as.factor(data$SOLD_SINCE_MAXI)
data$DIY_STORE = as.factor(data$DIY_STORE)
#Run data quality report again
QAreport = DataQualityReport(data)
#which variables have missing values?
QAreport[QAreport$NumberMissing>0, ]
    
## Load a couple functions that help clean up some of the data and run them
source("cleanData.R")
source("Impute.R")
data = cleanData(data)
data = Impute(dataSetName=data, ImputeTechnique='median')
#re-run quality report to see if anything else needs fixed
QAreport = DataQualityReport(data)
#which variables have missing values?
QAreport[QAreport$NumberMissing>0, ]

#################################################################################
## MODEL BUILDING
## create a dataset called "d" containing only those possible variables used for modeling
d = data[,c(
    # our 0/1 response
    "SOLD_SINCE_MAXI",                                 
    # about store
    "STORE_AGE_YRS",                                
    # type of part             
    "PART_TYPE",                        
    # vendor
    "VENDOR_NAME",                    
    # The total number of different year-make-model vehicle options that the respective SKU could be used for.
    "APPLICATION_COUNT",              
    "PLATFORM_CLUSTER_NAME",
    # The total number of "estimated" vehicles in operations associated to a particular store and adjusted based on market share adjustments based on warranty data.
    "TOTAL_VIO_CY",                  
    "TOTAL_VIO_PY",                   
    "UNADJUSTED_TOTAL_VIO_CY",        
    "UNADJUSTED_TOTAL_VIO_PY",       
    #The sum of (actual sales, second source sales, and lost sales) for a store-sku
    "PY_SALES_SIGNAL", 
    #The estimated unit store-sku sales based on replacement rates and the store's VIO.
    "BASE_SALES",                     
    "ADJUSTED_SALES",                 
    # The number of times a SKU was indicated as a lost sale because of out of stock, wait-time, high price, wrong brand, etc. at a particular store        
    "LOST_QTY_PY",                    
    # number of second source (skued items) sales also purchased with this store-sku combination
    "SS_SALES_PY",                    
    # The total number of SKUs sold at a particular store.                 
    "PY_QTY_SOLD",
    # The total number of SKUs sold at a particular store 2 years ago
    "PPY_QTY_SOLD",   
    # The total number of units sold for this particular SKU over all stores.
    "UNIT_SALES_PY",   
    # The projected percentage growth for this SKU over the next 13 periods/1 year.
    "PROJECTED_GROWTH_PCT",
    # The projected percentage growth for this SKU estimated last year 
    "PROJECTED_GROWTH_PCT_PY",  
    # competitor information
    "COMPETITOR_COUNT",              
    "COMPETITOR_INFLUENCE"
    )]      
## rename "SOLD_SINCE_MAXI" to "Y" for convenience
names(d)[1] = "Y"

################################################################################
##make sure you install these packages so eliminate any errors
install.packages(c("caret", "e1071", "ISLR", "gridExtra", "ggplot2", "Hmisc", "RANN", "SparseM"))
install.packages(c("AppliedPredictiveModeling", "pgmm", "ElemStatLearn", "gbm", "lubridate"))
install.packages(c("dplyr", "plyr", "sqldf", "gbm", "lubridate","tidyr","swirl","sweave"))

## load these packages so we can use their functions
library(e1071)
library(caret)
################################################################################

# select a random sample for plotting
sampd = d[sample.int(size=1000, n=dim(d)[1], replace=F), ]
sampd$Y = as.integer(sampd$Y)
# create a scatterplot matrix
featurePlot(x=sampd[,c(6,8)],
            y=sampd$Y,
            plot="pairs") 

################################################################################
## partition data set into training and testing
# set seed so results match
set.seed(123)
# data is partitioned
inTrain = createDataPartition(y=d$Y, p=0.60, list=FALSE)
head(inTrain)
training = d[inTrain,]
testing = d[-inTrain,]
dim(training)
#[1] 80688    22
dim(testing)
#[1] 26895    33

# Here we can see that the training response is unbalanced
table(training$Y)
#0     1 
#24512 56176 

# Rebalance the training data
training$SPSS_Partition = "Train"
source("Rebalance.R")
training = Rebalance(AlgorithmName="ubOver"
                     , dataSetName=training
                     , Inputs_RFile=NULL
                     , Covariates=names(training[,2:22])
                     , Response="Y")
table(training$Y)
#0     1 
#24512 24512

## Just for this tutorial and to get the models to run fast I'll use a subset of this data to fit
#dim(training)
#training=training[1:1000,1:22]
## still pretty balanced
#table(training$Y)
#0   1 
#498 502

# 180 packages you can use for modeling within caret
names(getModelInfo())
#[1] "ada"                 "AdaBag"              "AdaBoost.M1"         "amdai"               "ANFIS"              
#[6] "avNNet"              "bag"                 "bagEarth"            "bagEarthGCV"         "bagFDA"             
#[11] "bagFDAGCV"           "bayesglm"            "bdk"                 "binda"               "blackboost"         
# ...

# fit a logit on all the predictors
## Fit Predictive Models over Different Tuning Parameters
## Allows you to be more precise in how you want to train models
args(train.default) #shows you the default settings
args(trainControl)  #parameters you can change

## fit a logit model
lrFit = train(Y ~. 
                 , data=training
                 , method="glm"
                 , trControl = trainControl()
                 )
## fit a classification tree model
treeFit = train(Y ~. 
                 , data=training
                 , method="rpart"
                )

lrFit
#Generalized Linear Model 
#49024 samples
#21 predictor
#2 classes: '0', '1' 
#No pre-processing
#Resampling: Bootstrapped (25 reps) 
#Summary of sample sizes: 49024, 49024, 49024, 49024, 49024, 49024, ... 
#Resampling results
#Accuracy   Kappa      Accuracy SD  Kappa SD   
#0.6274562  0.2547774  0.002943196  0.005439009

lrFit$finalModel #gives you the model
#Coefficients:
#    (Intercept)            STORE_AGE_YRS               PART_TYPEB               PART_TYPEC  
#-2.664e-02                5.557e-03               -1.011e-01               -5.752e-01  
#VENDOR_NAMELARRY           VENDOR_NAMEMOE        APPLICATION_COUNT    PLATFORM_CLUSTER_NAME  
#-4.080e-01               -2.936e-01                2.977e-04               -8.461e-04  
#TOTAL_VIO_CY             TOTAL_VIO_PY  UNADJUSTED_TOTAL_VIO_CY  UNADJUSTED_TOTAL_VIO_PY  
#4.651e-03               -3.834e-03                4.312e-05               -5.937e-05  
#PY_SALES_SIGNAL               BASE_SALES           ADJUSTED_SALES              LOST_QTY_PY  
#1.351e-01               -1.602e-01                2.790e-01                1.851e+00  
#SS_SALES_PY              PY_QTY_SOLD             PPY_QTY_SOLD            UNIT_SALES_PY  
#1.324e+00                       NA                7.319e-02               -1.853e-05  
#PROJECTED_GROWTH_PCT  PROJECTED_GROWTH_PCT_PY         COMPETITOR_COUNT     COMPETITOR_INFLUENCE  
#2.547e-01                6.551e-01                7.895e-02               -2.255e-01  
#Degrees of Freedom: 49023 Total (i.e. Null);  49001 Residual
#Null Deviance:        67960 
#Residual Deviance: 62260 	AIC: 62310

lrPreds = predict(lrFit, newdata=testing)
confusionMatrix(lrPreds, testing$Y)
#Confusion Matrix and Statistics
#Reference
#Prediction     0     1
#0 12734 19678
#1  3606 17772
#Accuracy : 0.5671          
#95% CI : (0.5629, 0.5713)
#No Information Rate : 0.6962          
#P-Value [Acc > NIR] : 1               
#Kappa : 0.1988          
#Mcnemar's Test P-Value : <2e-16                       
#            Sensitivity : 0.7793          
#            Specificity : 0.4746          
#         Pos Pred Value : 0.3929          
#         Neg Pred Value : 0.8313          
#             Prevalence : 0.3038          
#         Detection Rate : 0.2367          
#   Detection Prevalence : 0.6026          
#      Balanced Accuracy : 0.6269                                                   
#       'Positive' Class : 0  


treeFit
#CART 
#49024 samples
#21 predictor
#2 classes: '0', '1' 
#No pre-processing
#Resampling: Bootstrapped (25 reps) 
#Summary of sample sizes: 49024, 49024, 49024, 49024, 49024, 49024, ... 
#Resampling results across tuning parameters:   
#    cp          Accuracy   Kappa       Accuracy SD  Kappa SD  
#0.01074984  0.6144653  0.22947899  0.008603207  0.01606533
#0.06972095  0.5811114  0.16324169  0.018762224  0.03581570
#0.13373042  0.5246106  0.05242422  0.033115785  0.06555543
#Accuracy was used to select the optimal model using  the largest value.
#The final value used for the model was cp = 0.01074984. 

treeFit$finalModel #gives you the model
#n= 49024 
#node), split, n, loss, yval, (yprob)
#* denotes terminal node
#1) root 49024 24512 0 (0.5000000 0.5000000)  
#2) LOST_QTY_PY< 0.5 44734 20728 0 (0.5366388 0.4633612)  
#4) PY_SALES_SIGNAL< 2.5 41039 18026 0 (0.5607593 0.4392407) *
#    5) PY_SALES_SIGNAL>=2.5 3695   993 1 (0.2687415 0.7312585) *
#    3) LOST_QTY_PY>=0.5 4290   506 1 (0.1179487 0.8820513) *

confusionMatrix(treePreds, testing$Y)
#Confusion Matrix and Statistics
#Reference
#Prediction     0     1
#0 15340 27413
#1  1000 10037
#Accuracy : 0.4718         
#95% CI : (0.4676, 0.476)
#No Information Rate : 0.6962         
#P-Value [Acc > NIR] : 1              
#Kappa : 0.1421         
#Mcnemar's Test P-Value : <2e-16         
#Sensitivity : 0.9388         
#Specificity : 0.2680         
#Pos Pred Value : 0.3588         
#Neg Pred Value : 0.9094         
#Prevalence : 0.3038         
#Detection Rate : 0.2852         
#Detection Prevalence : 0.7948         
#Balanced Accuracy : 0.6034         
#'Positive' Class : 0 
#'
## Fit Predictive Models over Different Tuning Parameters
## Allows you to be more precise in how you want to train models
args(train.default) #shows you the default settings
args(train)
args(trainControl)
# train() function parameters


require(pROC)    #used for auc()



#########################################################################################
## Shiny allows one to create a front end for their code
install.packages("shiny")
library(shiny)
?runExample

# example shiny apps within the package itself
system.file("examples", package="shiny")
# run your webapp
runExample("01_hello")

setwd("C:\\URBA\\webapp")
library(shiny)
# Run the web app using the runApp() function
?runApp         #see function details
runApp(appDir=getwd(), host = getOption("shiny.host", "127.0.0.1")
       , launch.browser = getOption("shiny.launch.browser", interactive()))
?runApp
getwd()

