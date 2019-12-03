-- SELECT * FROM books;

SELECT author, COUNT(*)
FROM books
GROUP BY author
ORDER BY COUNT(*);
