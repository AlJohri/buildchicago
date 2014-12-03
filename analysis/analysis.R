require(knitr)

source('load.R')

opts_chunk$set(echo = FALSE, fig.width = 15, fig.height = 15)
#' Analysis
#' ===================================================================
# Function to determine vertex color when plotting
v.color <- function(donor, fan)
    ifelse(donor,
           ifelse(fan, 'green', 'orange'),
           ifelse(fan, 'blue', 'yellow'))

personnel.colors <- data.table(
    type = c('None', 'Staff', 'Associate Board', 'Board'),
    color = c('gray', 'blue', 'orange', 'red'))
setkey(personnel.colors, type)

#' Fan Network
#' -------------------------------------------------------------------
#' This is a network of all fans and donors. Most of the analysis will
#' probably involve this graph.
#'
#' There are a few fans (Danny Zulo, Mnm Romero, etc; see list of top
#' fans by betweenness centrality) who seem to be exceptional at bringing
#' in more facebook fans; however, these typically don't convert into
#' donations.
#'
#' The top 20 fans by betweenness centraility have their names labeled.

is.fan.or.donor <- V(user.graph)$name %in% as.character(
    merged[fan == 1 | donor == 1, uid])

fan.graph <- induced.subgraph(user.graph, is.fan.or.donor)

vertex.names <- V(fan.graph)$name
is.donor <- as.logical(merged[vertex.names, donor])
is.fan <- as.logical(merged[vertex.names, fan])
user.names <- merged[vertex.names, name]
betweenness <- betweenness(fan.graph)
donation.amount <- merged[vertex.names, total.donation.amount]

personnel.type <- merged[vertex.names, role]
personnel.type[is.na(personnel.type)] <- 'None'

# Show labels for top 20 nodes by betweenness centrality
bet.cutoff <- betweenness[order(betweenness, decreasing = TRUE)][20]

#' Precompute layout
set.seed(42)
fan.layout <- layout.fruchterman.reingold(fan.graph)

#' ### Plot colored by fan / donor status
plot(fan.graph,
     vertex.size = ifelse(!is.donor, 1, log10(donation.amount)),
     vertex.label = ifelse(betweenness > bet.cutoff, user.names, NA),
     vertex.label.cex = 0.5,
     vertex.label.color = 'red',
     vertex.color = v.color(is.donor, is.fan),
     vertex.frame.color = ifelse(is.donor, 'black', 'blue'),
     edge.width = 0.3,
     layout = fan.layout)

#' ### Plot colored by personnel type
#' Staff seem to be much more likely to be friends with fans, perhaps
#' indicating that they play a role in bringing fans to the page.
#' Their friends do donate, but only in limited quantities.
#'
#' Board members are likely to be connected with each other and with
#' donors, as opposed to staff or fans. These relationships seem to
#' bring in large amounts of donations.
#'
#' Associate board members tend to donate little, are not connected with
#' the rest of the organization, and do little to bring in outside
#' donations. This suggests that there is strong potential for BUILD to
#' leverage associate board members further.

plot(fan.graph,
     vertex.size = ifelse(!is.donor, 1, log10(donation.amount)),
     vertex.label = ifelse(betweenness > bet.cutoff, user.names, NA),
     vertex.label.cex = 0.4,
     vertex.label.color = 'black',
     vertex.color = personnel.colors[personnel.type, color],
     vertex.frame.color = personnel.colors[personnel.type, color],
     edge.width = 0.3,
     layout = fan.layout)

#' ### Community detection
#' This confirms the structure that we can identify visually: there
#' appears to be a large central community of staff and fans, next to a
#' community of donors and board members. There are also several small
#' communities centered around a small number of fans.
eb.communities <- edge.betweenness.community(
    fan.graph, directed = FALSE)$membership

community.counts <- data.table(
    id = names(table(eb.communities)), count = table(eb.communities)
)[count > 10]
. <- community.counts[, color := rainbow(13)]
setkey(community.counts, id)

plot(fan.graph,
     vertex.size = ifelse(!is.donor, 1, log10(donation.amount)),
     vertex.label = ifelse(betweenness > bet.cutoff, user.names, NA),
     vertex.label.cex = 0.4,
     vertex.label.color = 'black',
     vertex.color = community.counts[
         as.character(eb.communities), color],
     vertex.frame.color = 'black',
     edge.width = 0.3,
     layout = fan.layout)

legend(1000, 200,
       personnel.colors[, type],
       col = personnel.colors[, color])

                                        # Useful statistics
                                        # -------------------------------------------------------------------
fan.edgelist <- get.edgelist(fan.graph)
edge.table <- data.table(
    rbind(fan.edgelist, cbind(fan.edgelist[,2], fan.edgelist[, 1])))
setnames(edge.table, 'V2', 'uid')
edge.table <- merge(edge.table, merged, by = 'uid')
friend.data <- edge.table[, list(
    donor.friend.count = sum(donor),
    fan.friend.count = sum(fan),
    personnel.friend.count = sum(personnel),
    board.friend.count = sum(role == 'Board', na.rm = TRUE),
    assoc.board.friend.count = sum(
        role == 'Associate Board', na.rm = TRUE),
    staff.friend.count = sum(role == 'Staff', na.rm = TRUE),
    friends.num.donations.2013 = sum(num.donations.2013),
    friends.num.donations.2014 = sum(num.donations.2014),
    friends.total.num.donations = sum(total.num.donations),
    friends.donation.amount.2013 = sum(donation.amount.2013),
    friends.donation.amount.2014 = sum(donation.amount.2014),
    friends.total.donation.amount = sum(total.donation.amount)),
                          list(uid = V1)]
. <- merged[vertex.names, `:=`(
    betweenness = betweenness,
    closeness = closeness(fan.graph),
    eigenvector = evcent(fan.graph)$vector)]

build.network <- merge(friend.data, merged[vertex.names], by = 'uid')
. <- build.network[is.na(role), role := 'None']

                                        # Write datasets to disk
write.csv(build.network, file = 'build_network.csv', row.names = FALSE)

attr.names <- c('label',
                'betweenness',
                'fan_status',
                'donor_status',
                'donation_metric',
                'donation_amount',
                'friends_donation_metric',
                'freinds_donation_amount',
                'build_affiliation')

attr.vals <- as.list(
    build.network[vertex.names, list(
        name,
        betweenness,
        fan,
        donor,
        log10(total.donation.amount),
        total.donation.amount,
        log10(friends.total.donation.amount),
        friends.total.donation.amount,
        role)])

Map(function(attr.name, attr.val)
    fan.graph <<- set.vertex.attribute(
        fan.graph, attr.name, value = attr.val),
    attr.names, attr.vals)

size.vars <- c('donation_metric',
               'betweenness',
               'freinds_donation_amount')

color.vars <- c('fan_status', 'build_affiliation')

outer(size.vars,
      color.vars,
      function(size.var, color.var){
          tmp.graph <- set.vertex.attribute(
              fan.graph, 'color', value =
                 get.vertex.attribute(fan.graph, color.var))
          set.vertex.attribute(
              fan.graph, 'size', value =
                  get.vertex.attribute(fan.graph, size.var))
      })

write.graph(fan.graph)

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
df.is.donor <- as.logical(merged[df.vertex.names, donor])
df.is.fan <- as.logical(merged[df.vertex.names, fan])
df.donation.amount <- merged[df.vertex.names, total.donation.amount]

plot(donors.friends,
     vertex.size = log10(df.donation.amount[df.is.donor]),
     vertex.label = NA,
     vertex.color = v.color(df.is.donor, df.is.fan))
