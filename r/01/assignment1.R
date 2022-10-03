#A

#set up the working space
setwd("C:/Users/Jessica Lim/Downloads")
web <- read.csv("webforum.csv")

#Data fields
#ThreadID  Unique ID for each thread  we  "We, us, our" words 
#AuthorID  Unique ID for each author  you  "You" words  
#Date  Date  shehe  "She, her "him words 
#Time  Time  they  "They" words 
#WC  Word count of the text of the post  posemo  Expressing positive emotions 
#Analytic  Summary: Analytical thinking  negemo  Expressing negative emotions 
#Clout  Summary: Power, force, impact  anx  Indicating anxiety 
#Authentic  Summary: Authentic tone of voice  anger  Indicating anger 
#Tone  Summary: Emotional tone  sad  Indicating sadness 
#ppron  "I, we, you" words  focuspast  Expressing a focus on the past 
#i  "I, me, mine" words   focuspresent  Expressing a focus on the present 
#focusfuture  Expressing a focus on the future  focusfuture  Expressing a focus on the future 

#A.1.
library(dplyr)
library(data.table)

#without thinking multple post made by users
web$Date <- as.Date(web$Date,"%Y-%m-%d")

month <- table(format(web$Date, "%Y-%b"))

year <- table(format(web$Date, "%Y"))

plot(year, type='l', col="blue", lwd=5, ylab = "Count", xlab = "Years", main= "Participants over years")
plot(month, type='l', col="green", lwd=5, ylab = "Count", xlab = "Months over Years", main= "Participants over months ")

#for group by to see user trends
web_user <- web %>%
            group_by(AuthorID)

year_user <- plot(table(format(web_user$Date, "%Y")),type='b', col="blue", lwd=5, ylab = "Count", xlab = "Years", main= "Participants over years")
year_user

web_user <- group_by(as.Date(web$Date,"%Y-%m-%d"))
month_user <- plot(table(format(web_user$Date, "%Y-%b")), type='b', col="green", lwd=5, ylab = "Count", xlab = "Months over Years", main= "Participants over months ")
month_user


#A.2.
#https://www.statology.org/correlation-test-in-r/
#https://www.datanovia.com/en/blog/how-to-perform-multiple-t-test-in-r-for-different-variables/
#http://www.sthda.com/english/wiki/correlation-analyses-in-r#:~:text=Correlogram%20is%20a%20graph%20of%20correlation%20matrix.%20Useful,correlation%20coefficients%20are%20colored%20according%20to%20the%20value.cor()

# Load required R packages
install.packages('corrplot')
library(corrplot)
library(RColorBrewer)

#remove Date and Time to see the correlation for the other linguistic variables
unique(year(web$Date))

par(oma=c(0,0,2,0), mfrow = c(1, 3))

web_cor <-cor(web %>% filter(year(Date)==2002)%>% select(-Date,-Time))
corrplot(web_cor, type="upper", order="hclust",
         col=brewer.pal(n=8, name="RdYlBu"),title = "2002",mar=c(0,0,2,0))

web_cor <-cor(web %>% filter(year(Date)==2003)%>% select(-Date,-Time))
corrplot(web_cor, type="upper", order="hclust",
         col=brewer.pal(n=8, name="RdYlBu"),title = "2003",mar=c(0,0,2,0))

web_cor <-cor(web %>% filter(year(Date)==2004)%>% select(-Date,-Time))
corrplot(web_cor, type="upper", order="hclust",
         col=brewer.pal(n=8, name="RdYlBu"),title = "2004",mar=c(0,0,2,0))

web_cor <-cor(web %>% filter(year(Date)==2005)%>% select(-Date,-Time))
corrplot(web_cor, type="upper", order="hclust",
         col=brewer.pal(n=8, name="RdYlBu"),title = "2005",mar=c(0,0,2,0))

web_cor <-cor(web %>% filter(year(Date)==2006)%>% select(-Date,-Time))
corrplot(web_cor, type="upper", order="hclust",
         col=brewer.pal(n=8, name="RdYlBu"),title = "2006",mar=c(0,0,2,0))

web_cor <-cor(web %>% filter(year(Date)==2007)%>% select(-Date,-Time))
corrplot(web_cor, type="upper", order="hclust",
         col=brewer.pal(n=8, name="RdYlBu"),title = "2007",mar=c(0,0,2,0))

web_cor <-cor(web %>% filter(year(Date)==2008)%>% select(-Date,-Time))
corrplot(web_cor, type="upper", order="hclust",
         col=brewer.pal(n=8, name="RdYlBu"),title = "2008",mar=c(0,0,2,0))

web_cor <-cor(web %>% filter(year(Date)==2009)%>% select(-Date,-Time))
corrplot(web_cor, type="upper", order="hclust",
         col=brewer.pal(n=8, name="RdYlBu"),title = "2009",mar=c(0,0,2,0))

web_cor <-cor(web %>% filter(year(Date)==2010)%>% select(-Date,-Time))
corrplot(web_cor, type="upper", order="hclust",
         col=brewer.pal(n=8, name="RdYlBu"),title = "2010",mar=c(0,0,2,0))


web_cor <-cor(web %>% filter(year(Date)==2011)%>% select(-Date,-Time))
corrplot(web_cor, type="upper", order="hclust",
         col=brewer.pal(n=8, name="RdYlBu"),title = "2011",mar=c(0,0,2,0))
#spesific p-values from t-test

library(corrplot)
web_cor_no_date_no_time <- web %>% select(-Date,-Time)

par(oma=c(0,0,2,0), mfrow = c(1, 1))

corrplot(cor(web_cor_no_date_no_time),        # Correlation matrix
         method = "shade", # Correlation plot method
         type = "full",    # Correlation plot style (also "upper" and "lower")
         diag = TRUE,      # If TRUE (default), adds the diagonal
         tl.col = "black", # Labels color
         bg = "white",     # Background color
         title = "Correlation of Linguistic Variable of Webforum in Total",       # Main title
         col = NULL, # Color palette    # Change vertical position
         mar=c(0,0,2,0))       

#per variables
#Visualize the hourly pedestrian count for the four locations above, on the 31st December 2021,
#using an appropriate plot. Hint: First filter using the Date column to get the relevant data.
# Filter for date (31/12/2021) using earlier extracted data for the four
#locations
web_year =web %>% group_by(year(Date)) %>% select(-Date,-Time)

# Create line plot for comparison
#Four_Locations =DEC_long %>% filter(Sensor_Location == c("Melbourne.Central","Southern.Cross.Station", "Southbank",
 #                                        "The.Arts.Centre"))
#Create faceted histograms
library(ggplot2)
qplot(, data = Four_Locations, geom = "histogram") +
  facet_wrap(~Sensor_Location, ncol = 4) + ggtitle("Melbourne City Hourly
Pedestrian Count Distributions")

web$Year <- format(as.Date(web$Date,format="%Y-%m-%d"),"%Y")

graph = aggregate(web[,c(5:23)], by = web[24], data = web, FUN = mean )

ggplot(data = graph, mapping = aes(x = Year, group = 1))+ 
  geom_line(size = 1, aes( y = WC, color = "WC"))+
  geom_line(size = 1, aes( y = Clout, color = "Clout"))+
  geom_line(size = 1, aes( y = Authentic, color = "Authentic"))+ 
  geom_line(size = 1, aes( y = Tone, color = "Tone"))+
  theme(axis.text.x = element_text(size = rel(1), angle = 45))+
  labs(title = "Linguistic variables VS Year Pt. 1", y = "Linguistic variables", x = "Year")                                                                                                                                                          


ggplot(data = graph, mapping = aes(x = Year, group = 1))+ 
  geom_line(size = 1, aes( y = ppron, color = "Ppron"))+ 
  geom_line(size = 1, aes( y = i, color = "i"))+
  geom_line(size = 1, aes( y = we, color = "we"))+
  geom_line(size = 1, aes( y = you, color = "you"))+ 
  geom_line(size = 1, aes( y = shehe, color = "shehe"))+
  geom_line(size = 1, aes( y = they, color = "they"))+
  geom_line(size = 1, aes( y = posemo, color = "posemo"))+ 
  geom_line(size = 1, aes( y = negemo, color = "negemo"))+ 
  geom_line(size = 1, aes( y = anx, color = "anx"))+ 
  geom_line(size = 1, aes( y = anger, color = "anger"))+ 
  geom_line(size = 1, aes( y = sad, color = "sad"))+ 
  geom_line(size = 1, aes( y = focuspast, color = "focuspast"))+
  geom_line(size = 1, aes( y = focuspresent, color = "focuspresent"))+ 
  geom_line(size = 1, aes( y = focusfuture, color = "focusfuture"))+ 
  theme(axis.text.x = element_text(size = rel(1), angle = 45))+
  labs(title = "Linguistic variables VS Year Pt. 2", y = "Linguistic variables", x = "Year")     

web_linguistics =  aggregate(web %>% select(-ThreadID,-AuthorID,-Date,-Time,-Year),by=web$Year, FUN=mean)

#B
web_thread <- web %>%
             group_by(ThreadID)

web_thread_posemo <- aggregate(x=web$posemo, by=list(web$ThreadID, year(web$Date)),FUN=mean)
colnames(web_thread_posemo) <- c("ThreadID", "Year", "Mean")

web_thread_negemo <- aggregate(x=web$negemo, by=list(web$ThreadID, year(web$Date)),FUN=mean)
colnames(web_thread_negemo) <- c("ThreadID", "Year", "Mean")

web_thread_anger <- aggregate(x=web$anger, by=list(web$ThreadID, year(web$Date)),FUN=mean)
colnames(web_thread_anger) <- c("ThreadID", "Year", "Mean")

web_thread_sad <- aggregate(x=web$sad, by=list(web$ThreadID, year(web$Date)),FUN=mean)
colnames(web_thread_sad) <- c("ThreadID", "Year", "Mean")

web_thread_anx <- aggregate(x=web$anx, by=list(web$ThreadID, year(web$Date)),FUN=mean)
colnames(web_thread_anx) <- c("ThreadID", "Year", "Mean")

install.packages('ggthemes')

library(ggthemes)

ggplot(web_thread_posemo, aes(fill=ThreadID, y=Mean, x=Year)) + 
  geom_bar(position='stack', stat='identity') +
  geom_point()+
  geom_text(data = web_thread_posemo,aes(label=ThreadID),hjust=-0.2, size=3)
  theme_wsj()

posemo_data=web_thread_posemo[order(web_thread_posemo$Year,-web_thread_posemo$Mean),]
posemo_data = posemo_data[!duplicated(posemo_data$Year),]
ggplot(data = web_thread_posemo, aes(x = Year, y = Mean, color = ThreadID, group = ThreadID))+ 
  geom_point() +
  geom_text(data = posemo_data, aes(label = ThreadID), hjust = -0.2, size = 3) + 
  labs(title = "Positive Emotion Count Over The Year",y = "Positive Emotion Mean", x = "Year") 


install.packages("scatterplot3d") # Install
install.packages("rgl")
require(scatterplot3d)
require(rgl)

# Custom shapes/colors
unique(web_thread_posemo$Year)
year_colour <- c("red","blue","yellow","green","purple","brown","pink","plum2","black","khaki")
year_colour <- as.numeric(web_thread_posemo$Year)

# Plot
s3d <- scatterplot3d(web_thread_posemo[1:4722,1:3],pch=16,color = year_colour)+
  title("Happiness Indicator by posemo Mean over every ThreadID over years")

#C
#https://towardsdatascience.com/how-to-model-a-social-network-with-r-878b3a76c5a1
library(tidyverse)
library(ggraph)
library(tidygraph)


install.packages(c("igraph", "igraphdata"))
library(igraph)
library(igraphdata) 

#Choose which part
social_data <- web%>% filter(between(Date, as.Date("2007-08-01"),as.Date("2007-08-05")))
social_data <- subset(social_data, social_data$AuthorID != -1)

SocialData = as.data.frame(cbind(social_data$AuthorID, social_data$ThreadID))
colnames(SocialData) = c("Author", "Thread")


UniqueAuthor = as.data.frame(unique(social_data$AuthorID))
colnames(UniqueAuthor) = c("Author")

#create graph
g <- make_empty_graph(directed = FALSE)

# add vertices
for (i in 1 : nrow(UniqueAuthor)) {
  g <- add_vertices(g, 1, name = as.character(UniqueAuthor$Author[i]))
}

# make complete graph for each club and add to g
for (k in unique(SocialData$Thread)){
  temp = SocialData[(SocialData$Thread %in% k),]
  if(nrow(temp)>1){
  # combine each pair of agents to make an edge list
  Edgelist = as.data.frame(t(combn(temp$Author,2)))
  colnames(Edgelist) = c("P1", "P2")
  # add edges
  for (i in 1 : nrow(Edgelist)) {
    g <- add_edges(g,
                   c(as.character(Edgelist$P1[i]),as.character(Edgelist$P2[i])))
  }
  }
  else {
    g = g
  }
  # following line just to check groups are correct, not needed for graph
  print(temp)
}

g = simplify(g)
plot(g)+
  title("Social Network Graph for Forum 2007-08-01 to 2007-08-05")

#C2
#https://www.r-bloggers.com/2021/04/social-network-analysis-in-r/#:~:text=Social%20Network%20Analysis%20in%20R%2C%20Social%20Network%20Analysis,and%20analyzing%20the%20structural%20properties%20of%20the%20network.
V(g)$label <- V(g)$name
V(g)$degree <- degree(g)

hist(V(g)$degree,
     col = 'green',
     main = 'Histogram of Node Degree',
     ylab = 'Frequency',
     xlab = 'Degree of Vertices')

#network diagram
set.seed(222)
plot(g,
     vertex.color = 'green',
     vertext.size = 2,
     edge.arrow.size = 0.1,
     vertex.label.cex = 0.8)

#hubs
hs <- hub_score(g)$vector
as <- authority.score(g)$vector
set.seed(123)
plot(g,
     vertex.size=hs*30,
     main = 'Hubs',
     vertex.color = rainbow(52),
     edge.arrow.size=0.1,
     layout = layout.kamada.kawai)

#Analysis
#https://visiblenetworklabs.com/2021/04/16/understanding-network-centrality/#:~:text=Network%20Centrality%3A%20Understanding%20Degree%2C%20Closeness%20%26%20Betweenness%20Centrality,and%20some%20are%20easier%20to%20understand%20than%20others.
#https://www.webpages.uidaho.edu/~stevel/517/RDM-slides-network-analysis-with-r.pdf

degree <- g %>% degree() %>% print()
degree
plot(names(degree),degree,xlab = "ThreadID", ylab = "Number of Degree") + title("Degrees of Nodes")
text(names(degree),degree,names(degree),pos=1)

closeness <- g %>% closeness() %>% round(2) %>% print()
closeness
plot(names(closeness),closeness,xlab = "ThreadID", ylab = "Closeness Level") + title("Closeness of Nodes")
text(names(closeness),closeness,names(closeness),pos=1)

betweenness <- g %>% betweenness() %>% print()
betweenness
plot(names(betweenness),betweenness,xlab = "ThreadID", ylab = "Betweeness") + title("Betweeness of Nodes")
text(names(betweenness),betweenness,names(betweenness),pos=1)

eig = as.table(evcent(g)$vector) 
eig
plot(names(eig),eig,xlab = "ThreadID", ylab = "Eigenvector Centrality") + title("Eigenvector Centrality of Nodes")
text(names(eig),eig,names(eig),pos=1)

averagePath = average.path.length(g)
diameter = diameter(g)
diameter

tabularised = as.data.frame(rbind(degree, betweenness, closeness, eig)) 
tabularised = t(tabularised)

cat("Average Path Length: ", averagePath) 

cat("\nDiameter: ", diameter, "\n\n") 

# Print properties ordered by degree
cat("\nOrder by Degree\n")
print(head(tabularised[order(-degree),]), digits = 3) 

# Print properties ordered by betweenness
cat("\nOrder by Betweenness\n")
print(head(tabularised[order(-betweenness),]), digits = 3)

# Print properties ordered by closeness
cat("\nOrder by Closeness\n")
print(head(tabularised[order(-closeness),]), digits = 3) 

# Print properties ordered by eigenvector centrality
cat("\nOrder by Eigenvector Centrality\n")
print(head(tabularised[order(-eig),]), digits = 3)


