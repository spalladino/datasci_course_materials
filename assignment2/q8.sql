SELECT SUM(a.count * b.count) FROM frequency AS a INNER JOIN frequency AS b ON a.term = b.term WHERE a.docid = '10080_txt_crude' AND b.docid = '17035_txt_earn';
