register s3n://uw-cse-344-oregon.aws.amazon.com/myudfs.jar

-- load the file into Pig
raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/btc-2010-chunk-000' USING TextLoader as (line:chararray);
--raw = LOAD 's3n://uw-cse-344-oregon.aws.amazon.com/cse344-test-file' USING TextLoader as (line:chararray);

-- parse each line into ntriples
ntriples = FOREACH raw GENERATE FLATTEN(myudfs.RDFSplit3(line)) AS (subject:chararray,predicate:chararray,object:chararray);

-- filter the n-triples based on subject
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- | filtered_ntriples     | subject:chararray                                                   | predicate:chararray                                        | object:chararray                                           |
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |                       | <http://openean.kaufkauf.net/id/businessentities/GLN_7397540000038> | <http://purl.org/goodrelations/v1#hasGlobalLocationNumber> | "7397540000038"^^<http://www.w3.org/2001/XMLSchema#string> |
-- -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
filtered_ntriples = FILTER ntriples BY subject MATCHES '.*rdfabout\\.com.*';
--filtered_ntriples = FILTER ntriples BY subject MATCHES '.*business.*';


-- copy the n-triples
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- | filtered_ntriples_2     | subject2:chararray                                                  | predicate2:chararray                                       | object2:chararray                                          |
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |                         | <http://openean.kaufkauf.net/id/businessentities/GLN_7397540000038> | <http://purl.org/goodrelations/v1#hasGlobalLocationNumber> | "7397540000038"^^<http://www.w3.org/2001/XMLSchema#string> |
-- ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
filtered_ntriples_2 = FOREACH filtered_ntriples GENERATE * AS (subject2:chararray,predicate2:chararray,object2:chararray);

-- join them
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- | joined     | filtered_ntriples::subject:chararray                                | filtered_ntriples::predicate:chararray             | filtered_ntriples::object:chararray                | filtered_ntriples_2::subject2:chararray                             | filtered_ntriples_2::predicate2:chararray                           | filtered_ntriples_2::object2:chararray             |
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- |            | <http://openean.kaufkauf.net/id/businessentities/GLN_0162990000030> | <http://www.w3.org/1999/02/22-rdf-syntax-ns#type>  | <http://purl.org/goodrelations/v1#BusinessEntity>  | <http://openean.kaufkauf.net/id/businessentities/GLN_6406510000068> | <http://openean.kaufkauf.net/id/businessentities/GLN_0162990000030> | <http://www.w3.org/1999/02/22-rdf-syntax-ns#type>  |
-- |            | <http://openean.kaufkauf.net/id/businessentities/GLN_0162990000030> | <http://www.w3.org/1999/02/22-rdf-syntax-ns#type>  | <http://purl.org/goodrelations/v1#BusinessEntity>  | <http://openean.kaufkauf.net/id/businessentities/GLN_6406510000068> | <http://openean.kaufkauf.net/id/businessentities/GLN_0162990000030> | <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> |
-- |            | <http://openean.kaufkauf.net/id/businessentities/GLN_0162990000030> | <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> | <http://openean.kaufkauf.net/id/businessentities/> | <http://openean.kaufkauf.net/id/businessentities/GLN_6406510000068> | <http://openean.kaufkauf.net/id/businessentities/GLN_0162990000030> | <http://www.w3.org/1999/02/22-rdf-syntax-ns#type>  |
-- |            | <http://openean.kaufkauf.net/id/businessentities/GLN_0162990000030> | <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> | <http://openean.kaufkauf.net/id/businessentities/> | <http://openean.kaufkauf.net/id/businessentities/GLN_6406510000068> | <http://openean.kaufkauf.net/id/businessentities/GLN_0162990000030> | <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> |
-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
joined = JOIN filtered_ntriples BY object, filtered_ntriples_2 BY subject2 PARALLEL 50;

-- remove dupes
unique_joined = DISTINCT joined;

-- store the results in the folder /user/hadoop/example-results
store unique_joined into '/user/hadoop/problem-3b' using PigStorage();
