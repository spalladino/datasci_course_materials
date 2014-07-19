import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):
  key, sequence = record
  mr.emit_intermediate(sequence[:-10], None)

def reducer(sequence, nothing):
  mr.emit(sequence)

if __name__ == '__main__':
  inputdata = open(sys.argv[1])
  mr.execute(inputdata, mapper, reducer)
