/* How would you join Tables A and B together in order to retrieve names with no matches in the opposing tables?
Table A
Name	ID
Jon	1
Jacob	2
Jingleheimerscmidt	3

Table B
Name	ID
Paul	1
Jacob	2
Jingleheimerscmidt	3

*/

-- Creating the tables
CREATE TABLE TableA (
    ID INT,
    Name VARCHAR(255)
);

CREATE TABLE TableB (
    ID INT,
    Name VARCHAR(255)
);

-- Inserting the data into the tables
INSERT INTO TableA (ID, Name)
VALUES
    (1, 'Jon'),
    (2, 'Jacob'),
    (3, 'Jingleheimerscmidt');

INSERT INTO TableB (ID, Name)
VALUES
    (1, 'Paul'),
    (2, 'Jacob'),
    (3, 'Jingleheimerscmidt');

-- Retrieving the data where it having the no matching data
select tablea.Name as Name_A, tableb.name as Name_B
from tablea join tableb on tablea.ID = tableb.ID
where tablea.Name <> tableb.name;

/*
From this table we need to keep the newest version of each record using date_added, but would like to keep the oldest this_flag value. 
All fields, minus date_added and this_flag, are used to determine the uniqueness of a record. 
Also, please show the end result of the table after doing the performed actions.

Date_Added	this_flag	Name	DOB	ID
May 1st , 2015	Y	Jingleheimerscmidt	19901002	1
May 1st , 2015	N	Jingleheimerscmidt	19901002	3
April 5th, 2015	Y	Jon	19901001	1
May 1st , 2015	N	Jon	19901002	1
May 1st, 2015	Y	Jacob	19901001	2
April 5th, 2015	N	Jingleheimerscmidt	19901001	3
May 1st, 2015	Y	Jingleheimerscmidt	19901001	3

*/

-- Creating the tables with above colomn names
CREATE TABLE TempTable (
    Date_Added DATE,
    this_flag CHAR(1),
    Name VARCHAR(255),
    DOB DATE,
    ID INT
);

-- Inserting the data into the tables
INSERT INTO TempTable (Date_Added, this_flag, Name, DOB, ID)
VALUES
    ('2015-05-01', 'Y', 'Jingleheimerscmidt', '1990-10-02', 1),
    ('2015-05-01', 'N', 'Jingleheimerscmidt', '1990-10-02', 3),
    ('2015-04-05', 'Y', 'Jon', '1990-10-01', 1),
    ('2015-05-01', 'N', 'Jon', '1990-10-02', 1),
    ('2015-05-01', 'Y', 'Jacob', '1990-10-01', 2),
    ('2015-04-05', 'N', 'Jingleheimerscmidt', '1990-10-01', 3),
    ('2015-05-01', 'Y', 'Jingleheimerscmidt', '1990-10-01', 3);


-- Ordering the data by Date_Added and partitation with name, DOB and ID also assigning the row number for retreving the data.
WITH Results AS (
    SELECT
        Date_Added,
        this_flag,
        Name,
        DOB,
        ID,
        ROW_NUMBER() OVER (PARTITION BY Name, DOB, ID ORDER BY Date_Added DESC) AS RowNum
    FROM TempTable
)
SELECT
    Date_Added,
    this_flag,
    Name,
    DOB,
    ID
FROM Results
WHERE RowNum = 1;

/*
For the table given in Question #2, can you please show 2 rows in fixed, XML, JSON, and CSV file formats?
*/

-- Stored Procedure for Fixed Formate
CREATE PROCEDURE FixedFormateData
AS
BEGIN

    SELECT TOP 2
        CONCAT(
            FORMAT(Date_Added, 'MMMM d, yyyy'),
            this_flag,
            Name,
            FORMAT(DOB, 'yyyyMMdd'),
            ID
        ) AS FixedFormat
    FROM TempTable;
END;

EXEC FixedFormateData


-- Stored Procedure for XML Formate
CREATE PROCEDURE XMLFormateData

AS
BEGIN
    SELECT TOP 2
        CAST(
            (SELECT
                Date_Added AS "@Date_Added",
                this_flag AS "@this_flag",
                Name AS "Name",
                DOB AS "DOB",
                ID AS "ID"
            FOR XML PATH('Row'), TYPE) AS XML
        ).query('.') AS XMLFormat
    FROM TempTable;

END;

EXEC XMLFormateData

-- Stored Procedure for JSON Formate
CREATE PROCEDURE JSONFormateData
AS
BEGIN
    SELECT TOP 2
        JSON_QUERY(
            '[' +
            STRING_AGG(
                JSON_QUERY(
                    CONCAT(
                        '{',
                        '"Date_Added":"', CONVERT(VARCHAR, Date_Added, 120), '"',
                        ',"this_flag":"', this_flag, '"',
                        ',"Name":"', Name, '"',
                        ',"DOB":"', CONVERT(VARCHAR, DOB, 120), '"',
                        ',"ID":', ID,
                        '}'
                    )
                ),
                ','
            ) +
            ']'
        ) AS JSONFormat
    FROM TempTable;
END;

EXEC JSONFormateData

-- Stored Procedure for CSV Formate
CREATE PROCEDURE CSVFormateData
AS
BEGIN
    SELECT TOP 2
        'Date_Added,this_flag,Name,DOB,ID' AS CSVHeader,
        STRING_AGG(
            CONCAT(
                FORMAT(Date_Added, 'MMMM d, yyyy'),
                ',', this_flag,
                ',', Name,
                ',', FORMAT(DOB, 'yyyyMMdd'),
                ',', ID
            ),
            CHAR(13) + CHAR(10)
        ) AS CSVFormat
    FROM TempTable;
END;

EXEC CSVFormateData


