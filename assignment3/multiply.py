import MapReduce
import sys

mr = MapReduce.MapReduce()

L = 5
M = 5
N = 5

def mapper(record):
  matrix = record[0]
  if matrix == 'a':
    i,j,value = record[1:]
    for k in range(N):
      mr.emit_intermediate((i,k), record)
  else:
    j,k,value = record[1:]
    for i in range(L):
      mr.emit_intermediate((i,k), record)

def reducer(key, values):
  def find(m,i,j):
    vs = [v for (_m,_i,_j,v) in values if m == _m and i == _i and j == _j]
    return 0 if len(vs) == 0 else vs[0]

  i, j = key
  value = sum([find('a',i,k) * find('b',k,j) for k in range(M)])
  mr.emit((i, j, value))

if __name__ == '__main__':
  inputdata = open(sys.argv[1])
  mr.execute(inputdata, mapper, reducer)
