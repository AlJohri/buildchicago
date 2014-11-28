require(data.table)
require(bit64)
require(igraph)

## Users
## -------------------------------------------------------------------
edgelist <- fread('edgelist.csv', colClasses = c('integer', 'integer'))
users <- fread(
    'users.csv',
    colClasses = c('character', 'character', 'character', 'integer'))

# Dedupe edges
edgelist[, `:=`(uid1 = pmax(uid1, uid2), uid2 = pmin(uid1, uid2))]
edgelist <- edgelist[!duplicated(edgelist)]
user.graph <- graph.data.frame(edgelist, directed = FALSE)

## Donors
## -------------------------------------------------------------------
donors <- data.table(read.csv('donors.csv',
                              strip.white = TRUE,
                              stringsAsFactors = FALSE))

matched.donors <- data.table(read.csv('matched_donors.csv',
                                     header = FALSE,
                                     strip.white = TRUE,
                                     stringsAsFactors = FALSE))

setnames(matched.donors, c('V1','V2'), c('Name', 'fb.name'))

donors <- merge(donors, matched.donors, by = 'Name')
setnames(donors, c('Name', 'fb.name'), c('donor.name', 'name'))

## Personnel
## -------------------------------------------------------------------
personnel <- data.table(read.csv('build_personnel.csv',
                                 strip.white = TRUE,
                                 stringsAsFactors = FALSE))

matched.personnel <- data.table(read.csv('matched_personnel.csv',
                                         header = FALSE,
                                         strip.white = TRUE,
                                         stringsAsFactors = FALSE))
setnames(matched.personnel, c('V1','V2'), c('name', 'fb.name'))
personnel <- merge(personnel, matched.personnel, by = 'name')
setnames(personnel, c('name', 'fb.name'), c('personnel.name', 'name'))

## Merge
## -------------------------------------------------------------------
merged <- merge(
    merge(users, donors, by = 'name', all.x = TRUE),
    personnel, by = 'name', all.x = TRUE)

merged[, donor := as.integer(!is.na(donor.name))]
merged[, personnel := as.integer(!is.na(personnel.name))]
setkey(merged, uid)
