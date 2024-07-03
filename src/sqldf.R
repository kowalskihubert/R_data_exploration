sql_1 <- function(Users){
  
  # W tym zapytaniu dla danej lokalizacji z tabeli Users zliczane są w sumie
  # polubienia (UpVotes) ale tylko dla lokalizacji niepustej.
  # Wynikowa tabela jest posortowana malejąco względem sumy polubień dla danej lokalizacji.
  # Tabela zawiera tylko 10 pierwszych wierszy.
  
  sqldf("SELECT Location, SUM(UpVotes) as TotalUpVotes FROM Users
  WHERE Location != ''
  GROUP BY Location
  ORDER BY TotalUpVotes DESC LIMIT 10")
  
}

sql_2 <- function(Posts){
  
  # W tym zapytaniu dla każdego miesiąca każdego roku zliczamy łączną ilość
  # postów typu Question lub Answear. Wyświetlamy jedynie te pary (Rok, Miesiąc),
  # dla których łączna ilość postów tego typu przekroczyła 1000. 
  # Dodatkowo dla każdej pary (Rok, Miesiąc) wyświetlamy najwyższy wynik posta (Score) z tego miesiąca
  
  sqldf("SELECT STRFTIME('%Y', CreationDate) AS Year, STRFTIME('%m', CreationDate) AS Month, 
    COUNT(*) AS PostsNumber, MAX(Score) AS MaxScore
    FROM Posts
    WHERE PostTypeId IN (1, 2) 
    GROUP BY Year, Month 
    HAVING PostsNumber > 1000")
}

sql_3 <- function(Posts, Users){
  
  #  W tym zapytaniu, dla każdego użytkownika, który kiedykolwiek napisał
  # na portalu pytanie (Question) zliczamy łączną ilość wyświetleń (ViewCount)
  # wszystkich jego pytań. Wyświetlane jest pierwsze 10 użytowników,
  # którzy mieli najwięcej wyświetleń pytań, podane jest Id użytkownika,
  # jego DisplayName i liczba wyświetleń jego pytań.
  
  sqldf(" SELECT Id, DisplayName, TotalViews 
  FROM (
      SELECT OwnerUserId, SUM(ViewCount) as TotalViews FROM Posts
      WHERE PostTypeId = 1
      GROUP BY OwnerUserId
    ) AS Questions 
  JOIN Users
  ON Users.Id = Questions.OwnerUserId 
  ORDER BY TotalViews DESC
  LIMIT 10")
  
}

sql_4 <- function(Posts, Users){
  
  # W tym zapytaniu, dla każdego użytkownika, który kiedykolwiek napisał post
  # typu Answer, zliczamy ilość napisanych przez niego takich postów. 
  # Podobnie, dla każdego użytkownika, który kiedykolwiek napisał post Question
  # zliczamy ilość napisanych przez niego pytań. 
  # Następnie z tych dwóch połączonych zestawień wybieramy tych użytkowników,
  # którzy napisali więcej Answers niż Questions i wybieramy pierwszych 5-ciu,
  # którzy napisali najwięcej Answers.
  # W ostatecznym zestawieniu wyświetlane są następujące dane użytkowników:
  # DisplayName, QuestionsNumber, AnswersNumber, Location, Reputation, UpVotes, DownVotes
  
  sqldf("SELECT DisplayName, QuestionsNumber, AnswersNumber, Location, Reputation, UpVotes, DownVotes 
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
  ON PostsCounts.OwnerUserId = Users.Id")
  
}

sql_5 <- function(Posts, Comments, Users){
  
  # W tym zapytaniu, dla każdego posta, który kiedykolwiek został skomentowany,
  # zliczamy sumę punktów (Score) przyznanych wszystkim komentarzom łącznie 
  # pod tym postem. 
  # Następnie z tego zestawienia wybieramy tylko posty typu Question, 
  # zatem dla każdego postu typu Question mamy sumę punktów przyznanych
  # jego komentarzom oraz dodatkowe informacje o poście: OwnerUserId, Title, CommentCount, ViewCount.
  # Z zestawienia wybieramy 10 postów, które miały największą sumę punktów za komentarze
  # (CommentsTotalScore).
  # W ostatecznym zestawieniu wyświetlane są dane posta:
  # Title, CommentCount, ViewCount, CommentsTotalScore
  # oraz dane użytkowanika, który dany post napisał:
  # DisplayName, Reputation, Location
  
  
  sqldf("
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
    LIMIT 10 ")
}

