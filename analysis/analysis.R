require(data.table)
require(bit64)
require(igraph)

## Load
## ===================================================================
## Users
## -------------------------------------------------------------------
edgelist <- fread('edgelist.csv',
                  colClasses = c('integer', 'integer'))
# Dedupe edges
edgelist[, `:=`(uid1 = pmax(uid1, uid2), uid2 = pmin(uid1, uid2))]
edgelist <- edgelist[!duplicated(edgelist)]

users <- fread('users.csv',
               colClasses = c('character', 'integer', 'integer'))

user.graph <- graph.data.frame(edgelist, directed = FALSE)
V(user.graph)$degree <- degree(user.graph)
users$degree <- unname(degree(user.graph)[users[, uid]])
users[, uid := as.character(uid)]

## Donors
## -------------------------------------------------------------------
donors <- data.table(read.csv('donors.csv',
                              strip.white = TRUE,
                              stringsAsFactors = FALSE))

matched.names <- data.table(read.csv('matched_names.csv',
                                     header = FALSE,
                                     strip.white = TRUE,
                                     stringsAsFactors = FALSE))

setnames(matched.names, c('V1','V2'), c('Name', 'fb.name'))

donors <- merge(donors, matched.names, by = 'Name')
setnames(donors, c('Name', 'fb.name'), c('build.name', 'name'))

users <- merge(users, donors, by = 'name', all.x = TRUE)

users[, donor := as.integer(!is.na(build.name))]
setkey(users, uid)

#' Analysis
#' ===================================================================
v.color <- function(donor, fan)
    ifelse(donor,
           ifelse(fan, 'green', 'orange'),
           ifelse(fan, 'blue', 'yellow'))

#' Fan Network
#' -------------------------------------------------------------------
is.fan.or.donor <- V(user.graph)$name %in% as.character(
    users[fan == 1 | donor == 1, uid])

fan.graph <- induced.subgraph(user.graph, is.fan.or.donor)

vertex.names <- V(fan.graph)$name
is.donor <- as.logical(users[vertex.names, donor])
is.fan <- as.logical(users[vertex.names, fan])
donation.amount <- users[vertex.names, total.donation.amount]

plot(fan.graph,
     vertex.size = ifelse(is.na(donation.amount), 1, log10(donation.amount)),
     vertex.label = NA,
     vertex.color = v.color(is.donor, is.fan),
     vertex.frame.color = ifelse(is.donor, 'black', 'blue'),
     edge.width = 0.3)

#' Donor Network
#' -------------------------------------------------------------------
donor.graph <- induced.subgraph(fan.graph, is.donor)
plot(donor.graph,
     vertex.size = log10(donation.amount[is.donor]),
     vertex.label = NA,
     vertex.color = v.color(is.donor[is.donor], is.fan[is.donor]))

#' Friends of donors
#' -------------------------------------------------------------------
donors.friends.edgelist <- edgelist[(
    as.character(uid1) %in% users[donor == 1, uid]
    | as.character(uid2) %in% users[donor == 1, uid])]

donors.friends <- as.character(
    unique(c(donors.friends.edgelist[, uid1],
             donors.friends.edgelist[, uid2])))

donors.friends.graph <- induced.subgraph(
    fan.graph, V(fan.graph)$name %in% donors.friends)

vertex.names <- V(donors.friends.graph)$name
is.donor <- as.logical(users[vertex.names, donor])
is.fan <- as.logical(users[vertex.names, fan])
donation.amount <- users[vertex.names, total.donation.amount]

plot(donors.friends.graph,
     vertex.size = log10(donation.amount[is.donor]),
     vertex.label = NA,
     vertex.color = v.color(is.donor, is.fan),
     edge.width = 2)
