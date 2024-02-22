# ===============================================================================
# Name   	: Parallel processing example
# Author 	: Filippo Ferrario : run by Katie MacGregor
# Date   	:  [dd-mm-yyyy] 31-01-2024 : 2024-02-08
# Version	: 0.1
# URL		: 
# Aim    	: Provide an example on how to use parallel processing in R
# ===============================================================================

#' run on the `r date()`

#' # Parallel processing example
#' 
#' This script is an example on how to use parallel processing in R.  
#' Parallel processing is usefull to speed up calculations taking advantage of more than 1 core, if these are available on your pc.  
#'  
#' ## Create a dummy dataset
#' # -----------------------------
# create a dataset

my_data<- data.frame('site'=c(rep(paste0('site_0',1:9),each=100),rep('site_10',100)) , x=rnorm(1000))

my_data$site<-as.factor(my_data$site)

summary(my_data)

my_data %>%
	group_by(site) %>%
	summarize(n_obs=n())

#' `my_data` is a dataset that has 10 sites and for each site there are 100 measured values of the `x` variable.
#' 
#' The task we want to do is to take a mean of the _x_ variable for each site. We will do it using a `for` loop (instead of using the more proper `mean` function with `tapply`) just to later show the parallelization approach.  
#' 
#' A bit of terminology first. When using a `for` loop (or some other type of iterative operation), usually _R_ cycle through each element of an object (e.g., a vector, a data.frame, or a list) and perfom some kind of task. This is usually done using a single 'core' (i.e., a 'computing unit' in your pc).  
#' This way of functioning is called 'serial' because each iteration is carried out one after the other.  
#' If we could used more than one core at the same time (provided that our pc has multiple cores, as usually is the case), then we could tell R to split the iterations of our `for loop` among _n_ cores so that at a given time _n_ iterations will be processed instead of just one.  
#' By doing this we could save time if the time required to perform a single iteration is considerably long.
#' 
#' 
#' ## Serial example
#' # --------------------
#' 
#' We will first produce a job that will run in a serial way, i.e., using just one core.

# initialize the output object. This will be a list for the sake of comaprison with the parallel approach. 
my_means<- list()

# get the names of the sites
sites<-unique(my_data$site)
sites<-as.character(sites)

for (i in seq_along(sites)){
	# subset the dataframe to just get the data for a single site
	tmp<-filter(my_data, site==sites[i])
	# calculate the mean of x and store it in a dataframe with a column site and one for the mean_x
	res<-data.frame(site=sites[i], mean_x= mean(tmp$x))
	# store this dataframe in the i element of our output list
	my_means[[i]]<-res
}

#' Our output is
my_means
#' We can now convert this list into a dataframe by doing
my_means_df<- bind_rows(my_means)
my_means_df

#' 
#' ## Parallel example
#' # --------------------
#' 
#' To use more cores we need to:
#' + prepare the data in a format that makes it possible to send chunks of them to different cores (each core will then process only the chunk of data it was provided with)
#' + know how many cores we have and decide how many to use
#' + Creating a _cluster_ with the _n_ cores we want to use.
#' + 'Activate' the cluster by _registering_ it. 
#' + send the different data chuncks to the different cores and perform the task.
#' + collect the output and close the cluster.
#' 
#' Check how many cores we have.
cores_avail<-detectCores()
#' Since we have `r cores_avail` core and `r length(sites)`, we cannot process all the sites at the same time.  
#' The best will be to just use 5 cores and do 2 iterations: in the first iteration the first 5 sites will be processed, and the other 5 in the second iteration. 
#' 
#' Lets first prep the data in the good format, that is we will split the dataset into a list in which each element will contain data of one particular site.  

df_list<-split(my_data, f=my_data$site)
str(df_list)

# create a cluster with 5 cores
cl = makeCluster(5, type = "PSOCK") 
cl
# register the cluster
registerDoParallel(cl)

#' using the `foreach` function from the package `foreach` we can run the parallel process. Also, the output of the function will be a list whose element will store the output of each core. So, we just need to save this in an object to 'collect' the output.  
#' The `foreach` function is actually really similar to a _for loop_ in its syntax. This makes it easier to adapt our loops to parallel processing. In the `for` loop we need to define a counter (usually _i_), in `foreach` we need to do the same. 
#' 
my_means_par<-foreach(i= seq_along(sites), .inorder=FALSE)  %dopar% {
	# pick the i element of out dataframe list.
	tmp<-df_list[[i]]
	# calculate the mean of x and store it in a dataframe with a column site and one for the mean_x
	res<-data.frame(site=sites[i], mean_x= mean(tmp$x))
	res
	# we don't need to manually store the res object in an output list: the function does it for us.
	}

# close the cluster
stopCluster(cl)

#' Our output is
my_means_par
#' We can now convert this list into a dataframe by doing
my_means_par_df<- bind_rows(my_means_par)
my_means_par_df

# check that the serial and parallel outputs are the same
all.equal(my_means_df,my_means_par_df) 

#' Done!  
#' 
#' _A small warning_: In this particular case we have very a simple task and the serial process is actually more time efficient than the parallel one. This is because the parallel process has some 'overhead' cost associated to it: it takes some time to set up and register the cluster and also to communicate to the different cores. But if the processing is really long, then this price could be minimal compare to the advantage.  
#' You can find more info on parallel processing here:  	
#' + https://www.r-bloggers.com/2014/07/implementing-mclapply-on-windows-a-primer-on-embarrassingly-parallel-computation-on-multicore-systems-with-r/
#' + https://psu-psychology.github.io/r-bootcamp-2018/talks/parallel_r.html

#' Info on my Session (R and package versions ) 

sessionInfo()