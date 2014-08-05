register s3n://uw-cse-344-oregon.aws.amazon.com/myudfs.jar

-- load the test file into Pig
raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/btc-2010-chunk-000' USING TextLoader as (line:chararray);

-- parse each line into ntriples
ntriples = foreach raw generate FLATTEN(myudfs.RDFSplit3(line)) as (subject:chararray,predicate:chararray,object:chararray);

--group the n-triples by object column
subjects = group ntriples by (subject) PARALLEL 50;

-- flatten the objects out (because group by produces a tuple of each object
-- in the first column, and we want each object ot be a string, not a tuple),
-- and count the number of tuples associated with each object
-- ---------------------------------------------------------------------------------------------------------------
-- | count_by_subject     | group:chararray                                                     | count:long     |
-- ---------------------------------------------------------------------------------------------------------------
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_0412600000036> | 1              |
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_0520090000006> | 1              |
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_0723990000088> | 2              |
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_0752110000028> | 1              |
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_0769910000080> | 1              |
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_0924610000024> | 1              |
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_3504864720144> | 1              |
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_6057600000026> | 1              |
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_7004920000068> | 1              |
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_7014900000056> | 1              |
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_7437530000010> | 1              |
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_7990420000090> | 1              |
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_8113370000036> | 1              |
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_8219280000088> | 1              |
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_8586590010046> | 1              |
-- |                      | <http://openean.kaufkauf.net/id/businessentities/GLN_8947370010098> | 1              |
-- ---------------------------------------------------------------------------------------------------------------
count_by_subject = foreach subjects generate flatten($0), COUNT($1) as count PARALLEL 50;

-- set up subjects by count of ntriples in which they appear
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- | subject_count_by_count     | group:long     | count_by_subject:bag{:tuple(group:chararray,count:long)}                                                                                                  |
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |                            | 1              | {(<http://openean.kaufkauf.net/id/businessentities/GLN_0412600000036>, 1), ..., (<http://openean.kaufkauf.net/id/businessentities/GLN_8947370010098>, 1)} |
-- |                            | 2              | {(<http://openean.kaufkauf.net/id/businessentities/GLN_0723990000088>, 2)}                                                                                |
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
subjects_by_count = group count_by_subject by (count) PARALLEL 50;

-- create scatterplot
-- -----------------------------------------------------
-- | scatterplot     | group:long     | count:long     |
-- -----------------------------------------------------
-- |                 | 1              | 2              |
-- |                 | 2              | 1              |
-- -----------------------------------------------------
scatterplot = foreach subjects_by_count generate $0, COUNT($1) as count PARALLEL 50;

-- store the results in the folder /user/hadoop/example-results
store scatterplot into '/user/hadoop/problem-2b' using PigStorage();
