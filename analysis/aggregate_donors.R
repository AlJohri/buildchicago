require(data.table)
require(lubridate)

most.frequent.value <- function(x) names(which.max(table(x)))
infiles <- c('donations_2013.csv', 'donations_2014.csv')
outfile <- 'donors.csv'

raws <- lapply(infiles, fread)
donations <- do.call(rbind, raws)
donations[, date := mdy(`Gift Date`)]

donors <- donations[, list(
    num.donations.2013 = sum(year(date) == 2013),
    donation.amount.2013 = sum(`Gift Amount`[year(date) == 2013]),
    num.donations.2014 = sum(year(date) == 2014),
    donation.amount.2014 = sum(`Gift Amount`[year(date) == 2014]),
    total.num.donations = .N,
    total.donation.amount = sum(`Gift Amount`),
    city = most.frequent.value(City),
    state = most.frequent.value(State),
    zip = most.frequent.value(ZIP),
    gender = most.frequent.value(Gender),
    marital.status = most.frequent.value(`Marital Status`)), Name]

write.csv(donors, file = outfile, row.names = FALSE)
