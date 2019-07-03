###################################################################################################
## Script that deals with the twitter data as described in paragraph 3.3.1 of the report          #
##      Input are the streaming twitter data collected fron Twitter API and processed in B script #
##      Output is a csv file of tweets                                                            #
###################################################################################################

#Source of the script from WUR Geoscripting course with theme "Harvesting tweets with Python"
#Ready to start the conda environment on your Prompt and install Twython package
#Import all the package that need to work for Twitter streaming
from twython import TwythonStreamer
import string, json, pprint
import urllib
from datetime import datetime
from datetime import date
from time import *
import string, os, sys, subprocess, time
import psycopg2

# Get access to your Twitter API
APP_KEY = "YOUR APP KEY"
APP_SECRET = "YOUR SECRET KEY"
OAUTH_TOKEN = "YOUR TOKEN"
OAUTH_TOKEN_SECRET = "YOUR SECRET TOKEN"

## Just some date and time to generate an unique filename if needed
output_file = 'result_' + datetime.now().strftime('%Y%m%d-%H%M%S') + '.csv' 

#Class to process JSON data comming from the twitter stream API. Extract relevant fields
class MyStreamer(TwythonStreamer):
    #This function will calles when data has been seccessfully received from stream an define the attributes will be retrieved from Twitter API
    def on_success(self, data):
         tweet_lat = 0.0
         tweet_lon = 0.0
         tweet_name = ""
         retweet_count = 0 

         if 'id' in data:
               tweet_id = data['id']
         if 'coordinates' in data:    
               geo = data['coordinates']
               if not geo is None:
                    latlon = geo['coordinates']
                    tweet_lon = latlon[0]
                    tweet_lat= latlon[1]
         if 'created_at' in data:
                    dt = data['created_at']
                    tweet_datetime = datetime.strptime(dt, '%a %b %d %H:%M:%S +0000 %Y')
         if tweet_lat != 0:
                    #some elementary output to console    
                    string_to_write = str(tweet_datetime)+", "+str(tweet_lat)+", "+str(tweet_lon)+": "+str(tweet_text)
                    print(string_to_write)
                    #write_tweet(string_to_write)
                    
    #Basic function to write tweets to a file
    def write_tweet(tweet, output_file):
        target = open(output_file, 'a')
        target.write(tweet)
        target.write('\n')
        target.close() 
    #This function will called when stream returns non-200 status code     
    def on_error(self, status_code, data):
         print("OOPS Error: " +str(status_code))
         #self.disconnect
         
         #Main procedure where the MyStreamer class is instantiated (with all authentication tokens)
         #and next only capture those tweets within a certain bounding box
def main():
    try:
        stream = MyStreamer(APP_KEY, APP_SECRET,OAUTH_TOKEN, OAUTH_TOKEN_SECRET)
        print('Connecting to twitter: will take a minute')
    except ValueError:
        print('OOPS! that hurts, something went wrong while making connection with Twitter: '+str(ValueError))
    #global target
    
    # Filter based on bounding box and word filter that you want to search on twitter see twitter api documentation for more info
    try:
        stream.statuses.filter(locations='LONGITUDEmin,LATITUDEmin,LONGITUDEmax,LATITUDEmax',track='HASHTAG/KEYWORDS')     
    except ValueError:
        print('OOPS! that hurts, something went wrong while getting the stream from Twitter: '+str(ValueError))

#Run this function to start the Twitter Streaming              
if __name__ == '__main__':
    main()
    write_tweet()