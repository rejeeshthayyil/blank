-- SQLite Table creation script
-- Creates a table with id, start_date, outcome, and end_date columns
-- end_date column allows NULL values

CREATE TABLE project_table (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    start_date DATE NOT NULL,
    outcome TEXT NOT NULL,
    end_date DATE NULL
);

-- Add some sample data
INSERT INTO project_table (start_date, outcome, end_date) VALUES
('2024-01-15', 'In Progress', NULL),
('2024-02-01', 'Completed', '2024-02-28'),
('2024-03-10', 'On Hold', NULL),
('2024-04-05', 'Completed', '2024-04-20'),
('2024-05-12', 'Cancelled', '2024-05-15');

-- Query examples
-- Select all records
SELECT * FROM project_table;

-- Select only ongoing projects (where end_date is NULL)
SELECT * FROM project_table WHERE end_date IS NULL;

-- Select completed projects
SELECT * FROM project_table WHERE end_date IS NOT NULL;