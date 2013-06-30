

#' merges 2 data.frame using a formula
#' example of formula is var1 + var2 | key1 + key2
#' @export
ddmergev <- function(data1,data2,form,verbose=FALSE) {
	
	expr = substitute(form)	

  # make sure we are using data.frame, data.table creates problems
  nns <- names(data1); data1 = data.frame(data1); names(data1)<-nns;
  nns <- names(data2); data2 = data.frame(data2); names(data2)<-nns;
	
	# constructing list of variables
	LHS = expr[[2]]
	RHS = expr[[3]]
  select_rule = parseSumDivide(RHS)
  rename_rule = parseSumDivide(LHS)

  missing_cols = setdiff(c(select_rule$b,rename_rule$a) , names(data2)) 


	# renaming data2
  # --------------
  nn = names(data2)
  for (i in 1:length(rename_rule$a)) {
    I <- which(nn==rename_rule$b[[i]])
    if  (length(I)>0) {
      nn[I] <- rename_rule$a[[i]]
      cat(paste('renaming in data2 ',nn[I],'->', rename_rule$a[[i]]))
    }
  }
  names(data2) <- nn

  # dropping other variables
  # ------------------------
  # checking that the vars are in the data.frame
  missing_cols = setdiff(c(select_rule$b,rename_rule$a) , names(data2)) 
  if (length(missing_cols)>0) stop(paste('data2 does not have columns: ' ,missing_cols,collapse=',') );
  data2 = data2[,c(select_rule$b,rename_rule$a)]

  # merging 
  # ------------------------
  missing_cols = setdiff(c(select_rule$a) , names(data1)) 
  if (length(missing_cols)>0) stop(paste('data1 does not have columns: ' ,missing_cols,collapse=',') );
  r = merge(data1,data2,by.x=select_rule$a, by.y = select_rule$b) 

  return(r)
}

#' useful to quickly profile code
#' @export
ticker <- function() {
  r = list()
  r$start = NA
  r$loops = 0
  r$times = list()
  r$last_pass = proc.time()[[3]]
  class(r) ='ticker'
  return(r)
}


#' useful to quickly profile code
#' @export
loop.ticker <- function(ticker,name) {

  etime =  proc.time()[[3]] - ticker$last_pass
  if (name %in% names(ticker$times)) {
    ticker$times[[name]] = ticker$times[[name]] + etime
  } else {
    ticker$times[[name]] = etime
  }
  ticker$last_pass = proc.time()[[3]]
  return(ticker)
}
