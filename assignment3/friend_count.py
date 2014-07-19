import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):
  person = record[0]
  mr.emit_intermediate(person, 1)

def reducer(person, friend_list):
  mr.emit((person, len(friend_list)))

if __name__ == '__main__':
  inputdata = open(sys.argv[1])
  mr.execute(inputdata, mapper, reducer)
