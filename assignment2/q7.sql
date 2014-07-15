SELECT SUM(a.value * b.value) FROM a INNER JOIN b on a.col_num = b.row_num WHERE a.row_num = 2 AND b.col_num = 3;
