# Load data -----------------------
natl_data <- read.csv('~/Documents/research/ILINet-national.csv')
reg_data <- read.csv('~/Documents/research/ILINet-regional.csv')
natl_data$'REGION' <- 'Natl'

full_data <- rbind(reg_data, natl_data)
full_data[full_data == 'X'] <- NA
colnames(full_data) <- c('reg_type', 'reg', 'year', 'week', 'wILI', 'unwILI', 'age0_4', 
                         'age25_49', 'age25_64', 'age5_24', 'age50_64', 'age65', 'ILItotal', 
                         'num_providers', 'total_patients')

full_data$wILI <- as.numeric(as.character(full_data$wILI))
full_data$reg <- as.character(full_data$reg)

data <- full_data[c('reg', 'week', 'year', 'wILI')]