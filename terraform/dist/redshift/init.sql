CREATE SCHEMA aduyko_test AUTHORIZATION test;

CREATE TABLE aduyko_test.rides (
  id BIGINT IDENTITY NOT NULL PRIMARY KEY,
  username VARCHAR(100) NOT NULL,
  unicorn_id INTEGER NOT NULL,
  request_time TIMESTAMP DEFAULT GETDATE()
);

CREATE TABLE aduyko_test.unicorns (
  id BIGINT IDENTITY NOT NULL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  color VARCHAR(100) NOT NULL,
  gender VARCHAR(100) NOT NULL
);

INSERT INTO aduyko_test.unicorns(name,color,gender) VALUES
('Bucephalus', 'Golden', 'Male'),
('Shadowfax', 'White', 'Female'),
('Rocinante', 'Yellow', 'Non-binary');
