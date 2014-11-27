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
               colClasses = c('character', 'character', 'integer'))

user.graph <- graph.data.frame(edgelist, directed = FALSE)
V(user.graph)$degree <- degree(user.graph)
users$degree <- unname(degree(user.graph)[users[, uid]])


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
#' This is a network of all fans and donors. Most of the analysis will
#' probably involve this graph.
is.fan.or.donor <- V(user.graph)$name %in% as.character(
    users[fan == 1 | donor == 1, uid])

fan.graph <- induced.subgraph(user.graph, is.fan.or.donor)

vertex.names <- V(fan.graph)$name
is.donor <- as.logical(users[vertex.names, donor])
is.fan <- as.logical(users[vertex.names, fan])
name <- users[vertex.names, name]
betweenness <- betweenness(fan.graph)
donation.amount <- users[vertex.names, total.donation.amount]

# Show labels for top 20 nodes by betweenness centrality
bet.cutoff <- betweenness[order(betweenness, decreasing = TRUE)][20]

plot(fan.graph,
     vertex.size = ifelse(!is.donor, 1, log10(donation.amount)),
     vertex.label = ifelse(betweenness > bet.cutoff, name, NA),
     vertex.label.cex = 0.5,
     vertex.label.family = "Arial",
     vertex.label.color = 'red',
     vertex.color = v.color(is.donor, is.fan),
     vertex.frame.color = ifelse(is.donor, 'black', 'blue'),
     edge.width = 0.3)

## Who has the highest betweenness centrality?
users[V(fan.graph)$name][betweenness >= bet.cutoff]

#' Donor Network
#' -------------------------------------------------------------------
donor.graph <- induced.subgraph(fan.graph, is.donor)
plot(donor.graph,
     vertex.size = log10(donation.amount[is.donor]),
     vertex.label = NA,
     vertex.color = v.color(is.donor[is.donor], is.fan[is.donor]))

#' Friends of donors
#' -------------------------------------------------------------------
donors.friends <- graph.union(
    graph.neighborhood(fan.graph, 1, V(fan.graph)[is.donor]))

df.vertex.names <- V(donors.friends)$name
df.is.donor <- as.logical(users[df.vertex.names, donor])
df.is.fan <- as.logical(users[df.vertex.names, fan])
df.donation.amount <- users[df.vertex.names, total.donation.amount]

plot(donors.friends,
     vertex.size = log10(df.donation.amount[df.is.donor]),
     vertex.label = NA,
     vertex.color = v.color(df.is.donor, df.is.fan))
