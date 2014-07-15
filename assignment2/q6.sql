SELECT COUNT(*) FROM (SELECT * FROM frequency AS f1 INNER JOIN frequency AS f2 ON f1.docid = f2.docid WHERE f1.term = 'transactions' AND f2.term = 'world');
