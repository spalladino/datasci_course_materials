import sys
import json
import re

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

def main():
  scores = None
  with open(sys.argv[1]) as sent_file:
    scores = load_scores(sent_file)

  with open(sys.argv[2]) as tweet_file:
    for tweet_json in tweet_file:
      tweet = json.loads(tweet_json)
      text = tweet['text']
      words = split_words(text)
      print sentiment(scores, words), text

if __name__ == '__main__':
  main()
