import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):
  person, friend = record
  mr.emit_intermediate(person, friend)
  mr.emit_intermediate(friend, person)

def reducer(person, friend_list):
  for friend in set(friend_list):
    mr.emit((person, friend))

if __name__ == '__main__':
  inputdata = open(sys.argv[1])
  mr.execute(inputdata, mapper, reducer)
