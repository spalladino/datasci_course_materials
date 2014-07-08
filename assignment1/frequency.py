import sys
import json
import re

def split_words(text):
  return [word for word in re.split("\W+", text) if len(word) > 0]

def add_count(dictionary, words):
  for word in words:
    if word in dictionary: dictionary[word] += 1
    else: dictionary[word] = 1


def main():
  counts = {}
  total_count = 0

  with open(sys.argv[1]) as tweet_file:
    for tweet_json in tweet_file:
      tweet = json.loads(tweet_json)
      text = tweet['text']
      words = split_words(text)

      add_count(counts, words)
      total_count += len(words)

  for word, count in counts.iteritems():
    print word, "%0.20f" % (float(count) / float(total_count))

if __name__ == '__main__':
  main()
