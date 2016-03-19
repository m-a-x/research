# Replication


# Packages -----------------------
install.packages('genlasso')
install.packages('dplyr')
install.packages('tidyr')
library(genlasso)
library(dplyr)
library(tidyr)

# Load data -----------------------
setwd('~/Documents/research')
source('data_load.R')
attach(data)

START_WEEK <- 21
END_WEEK <- 20
START_YEAR <- min(year)
END_YEAR <- max(year)


# Group data ----------------------
season <- function(x) {
    y <- vector(mode = 'numeric', length = length(x))
    year <- x[1,'year']
    s <- (x[, 'week'] <= END_WEEK)
    init_season <- year - (START_YEAR + 1)
    next_season <- year - START_YEAR
    y[s] <- init_season
    y[!s] <- next_season
    return (y)
}

data$season <- rep(NA, nrow(data))
for (i in START_YEAR:END_YEAR)
  data[which(year == i),'season'] <- season(data[which(year == i),])

data <- na.omit(data[c('reg', 'season', 'year', 'week', 'wILI')])
grp_data <- data %>% group_by(reg, season)

# Trend filtering -----------------
tf_est <- function(x) {
  ps = trendfilter(y = x$wILI, ord = 2)
  lcv = cv.trendfilter(ps, k = 5)$lambda.1se
  est = coef(ps, lambda = lcv)
  return(est$beta[,1])
}

data <- grp_data %>% do(est = tf_est(.), wILI = .$wILI, week = .$week,
                           yrs = c(min(.$year), max(.$year)))

# Prior Stats ----------------------
funcs <- data %>% do(func = approxfun(.$est))
data <- rowwise(cbind(data, funcs))

data <- data %>% mutate(noise = sqrt(mean((est - wILI)^2)),
                        peak_height = max(wILI),
                        peak_week = week[which.max(wILI)])
