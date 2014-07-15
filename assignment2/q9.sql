SELECT
  a.docid, SUM(a.count * b.count)
FROM
  ((SELECT * FROM frequency
  UNION
  SELECT 'q' as docid, 'washington' as term, 1 as count
  UNION
  SELECT 'q' as docid, 'taxes' as term, 1 as count
  UNION
  SELECT 'q' as docid, 'treasury' as term, 1 as count) AS a
  INNER JOIN
    (SELECT * FROM frequency
    UNION
    SELECT 'q' as docid, 'washington' as term, 1 as count
    UNION
    SELECT 'q' as docid, 'taxes' as term, 1 as count
    UNION
    SELECT 'q' as docid, 'treasury' as term, 1 as count) AS b
  ON a.term = b.term)
WHERE
  b.docid = 'q'
GROUP BY
  a.docid
ORDER BY
  SUM(a.count * b.count) DESC;
