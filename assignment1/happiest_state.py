from collections import defaultdict

import sys
import json
import re

STATES = ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA", "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE", "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV", "WY"]

def load_scores(fp):
  scores = {}
  for line in fp:
    term, score  = line.split("\t")
    scores[term] = int(score)
  return scores

def split_words(text):
  return re.split("\W+", text)

def sentiment(scores, words):
  return sum([scores.get(word.lower(), 0) for word in words])

def extract_state_from_tweet(tweet):
  try:
    match = (tweet.get('place') and get_state(tweet['place']['full_name'])) or (tweet.get('user') and get_state(tweet['user']['location']))
    return (match and match.group(1).upper())
  except:
    None

def get_state(string):
  if not string: return None
  return re.search("\W({0})$".format('|'.join(STATES)), string, re.I)

def main():
  scores = None
  counts = defaultdict(int)
  values = defaultdict(int)

  with open(sys.argv[1]) as sent_file:
    scores = load_scores(sent_file)

  with open(sys.argv[2]) as tweet_file:
    for tweet_json in tweet_file:
      tweet = json.loads(tweet_json)
      state = extract_state_from_tweet(tweet)
      if not state: continue

      text = tweet['text']
      words = split_words(text)
      counts[state] += 1
      values[state] += sentiment(scores, words)

  print max([(float(values[s]) / float(counts[s]), s) for s in STATES if s in counts])[1]

if __name__ == '__main__':
  main()
