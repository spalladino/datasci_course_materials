import sys
import json
import re

COUNT_THRESHOLD = 3

def load_scores(fp):
  scores = {}
  for line in fp:
    term, score  = line.split("\t")
    scores[term] = int(score)
  return scores

def split_words(text):
  return [word for word in re.split("\W+", text) if len(word) > 0]

def add_count(dictionary, words):
  for word in words:
    if word in dictionary: dictionary[word] += 1
    else: dictionary[word] = 1

def process(scores, positives, negatives, words):
  word_scores = [scores.get(word.lower(), 0) for word in words]
  unknown_words = [word.lower() for word in words if word.lower() not in scores]

  if any([score > 0 for score in word_scores]):
    add_count(positives, unknown_words)

  if any([score < 0 for score in word_scores]):
    add_count(negatives, unknown_words)

def main():
  scores = None
  positives = {}
  negatives = {}

  with open(sys.argv[1]) as sent_file:
    scores = load_scores(sent_file)

  with open(sys.argv[2]) as tweet_file:
    for tweet_json in tweet_file:
      tweet = json.loads(tweet_json)
      text = tweet['text']
      words = split_words(text)
      process(scores, positives, negatives, words)

  for word, neg in negatives.iteritems():
    pos = positives.get(word, 0)
    if neg + pos < COUNT_THRESHOLD: continue
    print word, float(pos) / float(neg)

if __name__ == '__main__':
  main()
