#' Analysis
#' ===================================================================
# Function to determine vertex color when plotting
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
user.names <- users[vertex.names, name]
betweenness <- betweenness(fan.graph)
donation.amount <- users[vertex.names, total.donation.amount]

# Show labels for top 20 nodes by betweenness centrality
bet.cutoff <- betweenness[order(betweenness, decreasing = TRUE)][20]

#' Precompute layout
fan.layout <- layout.fruchterman.reingold(fan.graph)

#' ### Plot colored by fan / donor status
plot(fan.graph,
     vertex.size = ifelse(!is.donor, 1, log10(donation.amount)),
     vertex.label = ifelse(betweenness > bet.cutoff, user.names, NA),
     vertex.label.cex = 0.5,
     vertex.label.family = "Arial",
     vertex.label.color = 'red',
     vertex.color = v.color(is.donor, is.fan),
     vertex.frame.color = ifelse(is.donor, 'black', 'blue'),
     edge.width = 0.3,
     layout = fan.layout)

#' ### Plot
plot(fan.graph,
     vertex.size = ifelse(!is.donor, 1, log10(donation.amount)),
     vertex.label = ifelse(betweenness > bet.cutoff, user.names, NA),
     vertex.label.cex = 0.5,
     vertex.label.family = "Arial",
     vertex.label.color = 'red',
     vertex.color = v.color(is.donor, is.fan),
     vertex.frame.color = ifelse(is.donor, 'black', 'blue'),
     edge.width = 0.3,
     layout = fan.layout)

## Who has the highest betweenness centrality?
print(users[V(fan.graph)$name][betweenness >= bet.cutoff,
                               list(name, total.donation.amount)])

#' Other Graphs
#' ===================================================================
#' Interesting but not immediately useful
#'
#' Donor Network
#' -------------------------------------------------------------------
#' Network of just donors
donor.graph <- induced.subgraph(fan.graph, is.donor)
plot(donor.graph,
     vertex.size = log10(donation.amount[is.donor]),
     vertex.label = NA,
     vertex.color = v.color(is.donor[is.donor], is.fan[is.donor]))

#' Friends of donors
#' -------------------------------------------------------------------
#' Network of donors
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
