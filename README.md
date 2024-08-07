# R_data_exploration
The project in which I explore archival data using different R libraries.

## About the project
In this project I used data from https://archive.org/details/stackexchange. 
It's goal was to explore this data set using different libraries in R
and compare the speed of the functions.

## Technologies used:
  - R
  - Libraries; sqldf. dplyr, data.table, microbenchmark

## Usage
1. Clone the repository: `git clone https://github.com/kowalskihubert/R_data_exploration.git`.
2. Unzip `Posts.csv.gz`, `Comments.csv.gz`, `Users.csv.gz` into the `data/` folder.
3. Navigate to the project directory: `cd R_data_exploration`.
4. Run `main.R` to see the results of the queries using the fastest library from the ones that were tested (*data.table*).
5. Run `benchmark.R` to compare the time efficiency of all tested methods: *sqldf, dplyr, data.table* and *base R*.


# SQL queries
## Query 1
```
SELECT Location, SUM(UpVotes) as TotalUpVotes FROM Users
  WHERE Location != ''
  GROUP BY Location
  ORDER BY TotalUpVotes DESC LIMIT 10
```
## Query 2
```
SELECT STRFTIME('%Y', CreationDate) AS Year, STRFTIME('%m', CreationDate) AS Month, 
    COUNT(*) AS PostsNumber, MAX(Score) AS MaxScore
    FROM Posts
    WHERE PostTypeId IN (1, 2) 
    GROUP BY Year, Month 
    HAVING PostsNumber > 1000
```
## Query 3
```
 SELECT Id, DisplayName, TotalViews 
  FROM (
      SELECT OwnerUserId, SUM(ViewCount) as TotalViews FROM Posts
      WHERE PostTypeId = 1
      GROUP BY OwnerUserId
    ) AS Questions 
  JOIN Users
  ON Users.Id = Questions.OwnerUserId 
  ORDER BY TotalViews DESC
  LIMIT 10
```

## Query 4
```
SELECT DisplayName, QuestionsNumber, AnswersNumber, Location, Reputation, UpVotes, DownVotes 
    FROM (
      SELECT * FROM (
          SELECT COUNT(*) as AnswersNumber, OwnerUserId 
          FROM Posts
          WHERE PostTypeId = 2
          GROUP BY OwnerUserId
        ) AS Answers 
      JOIN
      (
          SELECT COUNT(*) as QuestionsNumber, OwnerUserId 
          FROM Posts
          WHERE PostTypeId = 1
          GROUP BY OwnerUserId
      ) AS Questions
      ON Answers.OwnerUserId = Questions.OwnerUserId 
      WHERE AnswersNumber > QuestionsNumber
      ORDER BY AnswersNumber DESC
      LIMIT 5
  ) AS PostsCounts 
  JOIN Users
  ON PostsCounts.OwnerUserId = Users.Id
```
## Query 5
```
SELECT Title, CommentCount, ViewCount, CommentsTotalScore, DisplayName, Reputation, Location 
    FROM (
        SELECT Posts.OwnerUserId, Posts.Title, Posts.CommentCount, Posts.ViewCount, CmtTotScr.CommentsTotalScore
        FROM (
              SELECT PostId, SUM(Score) AS CommentsTotalScore 
              FROM Comments
              GROUP BY PostId
            ) AS CmtTotScr
        JOIN Posts ON Posts.Id = CmtTotScr.PostId 
        WHERE Posts.PostTypeId=1
      ) AS PostsBestComments
    JOIN Users 
    ON PostsBestComments.OwnerUserId = Users.Id 
    ORDER BY CommentsTotalScore DESC
    LIMIT 10
```

