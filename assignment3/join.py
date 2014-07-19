import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):
  order_id = record[1]
  mr.emit_intermediate(order_id, record)

def reducer(key, list_of_values):
  order = [record for record in list_of_values if record[0] == 'order'][0]
  for item in list_of_values:
    if item[0] == 'line_item':
      mr.emit(order + item)

if __name__ == '__main__':
  inputdata = open(sys.argv[1])
  mr.execute(inputdata, mapper, reducer)
