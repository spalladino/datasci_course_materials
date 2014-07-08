from collections import defaultdict

import sys
import json

def main():
  counts = defaultdict(int)

  with open(sys.argv[1]) as tweet_file:
    for tweet_json in tweet_file:
      tweet = json.loads(tweet_json)
      for hashtag in tweet['entities']['hashtags']:
        counts[hashtag['text']] += 1

  for count, tag in sorted([(count, tag) for (tag,count) in counts.iteritems()], reverse=True)[:10]:
    print "{0} {1}".format(tag.encode('utf-8'), count)

if __name__ == '__main__':
  main()
