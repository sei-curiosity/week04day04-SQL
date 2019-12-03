SELECT COUNT(*),
  CASE
    WHEN DATE_PART('year', AGE(born_on)) < 30
      THEN 'child'
    WHEN DATE_PART('year', AGE(born_on)) < 60
      THEN 'adult'
    ELSE
      'wisest'
  END AS type
FROM patients
GROUP BY type;
