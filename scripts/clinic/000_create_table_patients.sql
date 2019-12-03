-- create a table to store information about patients
CREATE TABLE patients (
  id SERIAL PRIMARY KEY,
  first_name TEXT,
  last_name TEXT,
  gender TEXT,
  height INTEGER,
  weight INTEGER,
  born_on DATE
);
