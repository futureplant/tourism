

df_twitter <- read.csv(file="./data/tourist_pct.csv", header=TRUE, sep=",")

# Draw plot
ggplot(df_twitter, aes(x=hashtag, y=pct)) + 
  geom_bar(stat="identity", width=.5, fill=rainbow(n=length(df_twitter$hashtag))) + 
  labs(title="Percentage of tourists per hashtag",
       caption="source: Twitter") + 
  theme(axis.text.x = element_text(angle=65, vjust=0.6))+
  xlab('Hashtag')+ylab('%')