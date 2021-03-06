
# Install packages that the program need

install_packages = function(names)
{
  for(name in names)
  {
    if (!(name %in% installed.packages()))
      install.packages(name, repos="http://cran.us.r-project.org")
    
    library(name, character.only=TRUE)
  }
}

install_packages(c("dplyr", "ggplot2","markdown",
                   "choroplethr","choroplethrMaps",
                   "plotly","countrycode","Rmisc"))

