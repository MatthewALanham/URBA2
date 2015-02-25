########################################################################
# Missing value imputation
# This function wraps the 'VIM' package's imputation techniques into one
# function that a user can use by specifying only two inputs 
# 1) dataSetName
# 2) ImputeTechnique (kNN, median, hotdeck, irmi, regression)
# 3) Associated parameters
#     kNN
#     median
#     hotdeck
#     irmi       : params = list(y1=c("x1","x2"), y2=c("x1","x3")) 
#     regression : params = Dream+NonD~BodyWgt+BrainWgt
# Author: Matthew A. Lanham
# Updated: 10/31/2014
#########################################################################

################################################################################
## Notes on general imputation and the VIM package:
##
## Good approach to imputation
## 1) the visualization tools should be applied before imputation and the diagnostic tools afterwards.
## Calculate or plot the amount of missing/imputed values for each variable as well as in combination of variables
##
##
#################################################################################

Impute = function(dataSetName, ImputeTechnique, params) {
  
  #dataSetName = sleep
  
  ## The VIM package provides tools for the visualization of missing and/or imputed values, which can 
  require(VIM)    ## be used for exploring the data and the structure of the missing and/or imputed values
  require(VIMGUI) ## allows an easy handling of the implemented plot methods
                  ## http://cran.r-project.org/web/packages/VIM/VIM.pdf

if (ImputeTechnique == 'kNN') {

  #################################################################################
  ## k-Nearest Neighbour Imputation 
  ## based on a variation of the Gower Distance for numerical, categorical, ordered and semi-continous variables
  dataSetName_imp = 
    kNN(
      data = dataSetName     #data.frame or matrix
    , variable = colnames(dataSetName) #variables where missing values should be imputed
    #, metric = NULL         #metric to be used for calculating the distances between
    , k = 5                 #number of Nearest Neighbours used
    , dist_var = colnames(dataSetName)  #names or variables to be used for distance calculation
    , weights = NULL        #weights for the variables for distance calculation
    , numFun = median       #function for aggregating the k Nearest Neighbours in the case of a numerical variable
    , catFun = maxCat       #function for aggregating the k Nearest Neighbours in the case of a categorical variable
    , makeNA = NULL         #list of length equal to the number of variables, with values, that should be converted to NA for each variable
    , NAcond = NULL         #list of length equal to the number of variables, with a condition for imputing a NA
    , impNA = TRUE          #TRUE/FALSE whether NA should be imputed
    , donorcond = NULL      #condition for the donors e.g. ">5"
    #, mixed = vector()      #names of mixed variables
    , mixed.constant = NULL  #vector with length equal to the number of semi-continuous variables specifying the point of the semi-continuous distribution with non-zero probability
    , trace = FALSE         #TRUE/FALSE if additional information about the imputation process should be printed
    , imp_var = FALSE       #TRUE/FALSE if a TRUE/FALSE variables for each imputed variable should be created show the imputation status
    , imp_suffix = "imp"    #suffix for the TRUE/FALSE variables showing the imputation status
    , addRandom = FALSE     #TRUE/FALSE if an additional random variable should be added for distance calculation
    )

} 
else if (ImputeTechnique == 'median') {
  
  #################################################################################
  ## Median or kNN Imputation
  ## Missing values are imputed with the mean for vectors of class "numeric", with the median for
  ## vectors of class "integer", and with the mode for vectors of class "factor". Hence, x should be
  ## prepared in the following way: assign class "numeric" to numeric vectors, assign class "integer"
  ## to ordinal vectors, and assign class "factor" to nominal or binary vectors
  dataSetName_imp = initialise(
      x = dataSetName             #a vector.
    , mixed = NULL                #a character vector containing the names of variables of type mixed (semi-continous).
    , method = "median"           #Method used for Initialization (median or kNN)
    , mixed.constant = NULL       #vector with length equal to the number of semi-continuous variables specifying the point of the semi-continuous distribution with non-zero probability
    )
} 
else if (ImputeTechnique == 'hotdeck') {
  
  #################################################################################
  ## "Hot-Deck Imputation" Implementation of the popular Sequential, Random (within a domain) hot-deck algorithm for imputation.
  dataSetName_imp = hotdeck(
      data = dataSetName#data.frame or matrix
    , variable = NULL   #variables where missing values should be imputed
    , ord_var = NULL    #variables for sorting the data set before imputation
    , domain_var = NULL #variables for building domains and impute within these domains
    , makeNA = NULL     #list of length equal to the number of variables, with values, that should be converted to NA for each variable
    , NAcond = NULL     #list of length equal to the number of variables, with a condition for imputing a NA
    , impNA = TRUE      #TRUE/FALSE whether NA should be imputed
    , donorcond = NULL  #list of length equal to the number of variables, with a donorcond condition for the donors e.g. ">5"
    , imp_var = FALSE   #TRUE/FALSE if a TRUE/FALSE variables for each imputed variable should be created show the imputation status
    , imp_suffix = "imp"  #suffix for the TRUE/FALSE variables showing the imputation status
    )
} 
else if (ImputeTechnique == 'irmi') {
  
  #################################################################################
  ## "Iterative robust model-based imputation" (IRMI)
  ## In each step of the iteration, one variable is used as a response variable and the remaining variables serve as the regressors.
  dataSetName_imp = irmi(
      x = dataSetName       #data.frame or matrix
    , eps = 5               #threshold for convergency
    , maxit = 100           #maximum number of iterations
    , mixed = NULL          #column index of the semi-continuous variables
    , mixed.constant = NULL  #vector with length equal to the number of semi-continuous variables specifying the point of the semi-continuous distribution with non-zero probability
    , count = NULL          #column index of count variables
    , step = FALSE          #a stepwise model selection is applied when the parameter is set to TRUE
    , robust = FALSE        #if TRUE, robust regression methods will be applied
    , takeAll = TRUE        #takes information of (initialised) missings in the response as well for regression imputation.
    , noise = TRUE          #irmi has the option to add a random error term to the imputed values, this creates the possibility for multiple imputation. The error term has mean 0 and variance corresponding to the variance of the regression residuals.
    , noise.factor = 1      #amount of noise.
    , force = FALSE         #if TRUE, the algorithm tries to find a solution in any case, possible by using different robust methods automatically.
    , robMethod = "MM"      #regression method when the response is continuous.
    , force.mixed = TRUE    #if TRUE, the algorithm tries to find a solution in any case, possible by using different robust methods automatically.
    , mi = 1                #number of multiple imputations.
    , addMixedFactors = FALSE  #if TRUE add additional factor variable for each mixed variable as X variable in the regression
    , trace = FALSE         #Additional information about the iterations when trace equals TRUE.
    , init.method = "kNN"   #Method for initialization of missing values (kNN or median)
    , modelFormulas = params
                            #a named list with the name of variables for the rhs of the formulas, which must contain a rhs formula for each variable with missing values, it should look like
                            #list(y1=c("x1","x2"),y2=c("x1","x3"))
                            #if factor variables for the mixed variables should be created for the regression models
    , multinom.method = "multinom"  #Method for estimating the multinomial models (current default and only available method is multinom)
    )
} 
else if (ImputeTechnique == 'regression') {
  
  #################################################################################
  ## "Regression Imputation" - Impute missing values based on a regression model.
  dataSetName_imp = regressionImp(
      formula = params             #model formula to impute one variable
    , data = dataSetName           #A data.frame or survey object containing the data
    , family = "AUTO"              #family argument for "glm" ("AUTO" tries to choose automatically, only really tested option!!!)
    , robust = FALSE               #TRUE/FALSE if robust regression should be used
    , imp_var = FALSE               #TRUE/FALSE if a TRUE/FALSE variables for each imputed variable should be created show the imputation status
    , imp_suffix = "imp"           #suffix used for TF imputation variables
    , mod_cat = FALSE              #TRUE/FALSE if TRUE for categorical variables the level with the highest prediction probability is selected, otherwise it is sampled according to the probabilities.
    )
  #example
  #data(sleep)
  #sleepImp1 = regressionImp(Dream + NonD ~ BodyWgt + BrainWgt, data=sleep)
}
else {
  
  dataSetName_imp = dataSetName
}

# Return imputed data set
return(dataSetName_imp)
}











