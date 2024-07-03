
table_1 <- function(Users){
  
  # Konwersja na data.table
  Users_dt <- as.data.table(Users)
  
  # Składnia DT[i,j,by=]
  # Odrzucenie pustych lokalizacji, grupowanie po Location, suma z UpVotes
  # Następnie sortowanie malejąco po TotalUpVotes i wybranie pierwszych 10 rekordów
  Users_dt <- Users_dt[Location != "", .(TotalUpVotes=sum(UpVotes)), by = Location][order(-TotalUpVotes)]
  Users_dt <- first(Users_dt, n=10)
  
  as.data.frame(Users_dt)
  
}

table_2 <- function(Posts){
  
  # Zamiast takiej konwersji, która wymaga kopiowania możemy użyć setDT()
  Posts_dt <- as.data.table(Posts)
  # Dodanie kolumn za pomocą ':=' oraz funkcji substring() (jest najszybsza
  # do prostego wyodrębnienia roku i miesiąca).
  # Jednocześnie wyodrębnienie tylko postów typu 1 lub 2 
  Posts_dt <- Posts_dt[PostTypeId %in% c(1,2), c("Year", "Month"):= list( substring(CreationDate,1,4), substring(CreationDate, 6,7)) ]
  # Grupowanie po Year i Month, dla każdej gdupy max(Score) oraz ilość elementów (length(Id))
  # Następnie odfiltrowanie tylko rekordów gdzie PostsNumber > 1000
  # Z wykorzystaniem chainingu DT[...][...]
  Posts_dt <- na.omit( Posts_dt[, .(PostsNumber = length(Id), MaxScore = max(Score, na.rm=T)), by=.(Year,Month) ] [PostsNumber > 1000] )    
  
  as.data.frame(Posts_dt)
  
}

table_3 <- function(Posts, Users){
  
  # Konwersja ramek na data.table
  Posts_dt <- as.data.table(Posts)
  Users_dt <- as.data.table(Users)
  # Z tab. Posts_dt odfiltrowanie jedynie postów typu 1
  # Jednocześnie grupowanie po OwnerUserId, suma z ViewCount
  # Zapis do pomocnieczej data.table Questions
  Questions <- Posts_dt[PostTypeId==1, .(TotalViews = sum(ViewCount, na.rm=T)), by = OwnerUserId]
  
  # Inner join Users_dt oraz Questions
  wynik <- merge.data.table(Users_dt, Questions, by.x="Id", by.y="OwnerUserId")
  # Sortowanie po TotalViews malejąco
  wynik <- wynik[order(-TotalViews)]
  # Wybór odpowiednich kolumn, potem 10 pierwszych rekordów
  wynik <- wynik[, .(Id, DisplayName, TotalViews) ]
  wynik <- first(wynik, n=10)
  wynik
  
}

table_4 <- function(Posts, Users){
  
  # Konwersja na data.table
  Posts_dt = as.data.table(Posts)
  Users_dt = as.data.table(Users)
  
  # Stowrzenie pomocniczej tab. Answers z tab. Posts_dt
  # Grupowanie po OwnerUserId i zliczenie rekordów w każdej grupie
  Answers <- Posts_dt[PostTypeId==2 & !is.na(OwnerUserId), .(AnswersNumber = length(Id)), by = OwnerUserId]
  # Stowrzenie pomocniczej tab. Questions z tab. Posts_dt
  # Grupowanie po OwnerUserId i zliczenie rekordów w każdej grupie
  Questions <- Posts_dt[PostTypeId==1 & !is.na(OwnerUserId), .(QuestionsNumber = length(Id)), by = OwnerUserId]
  
  # Inner join tabel Answers i Questions
  PostsCounts <- merge.data.table(Answers, Questions, by.x="OwnerUserId", by.y="OwnerUserId")
  # Wybranie tych rekordów, gdzie AnswersNumber > QuestionsNumber
  PostsCounts <- PostsCounts[AnswersNumber > QuestionsNumber]
  # Sortowanie malejąco po AnswersNumber, wybranie pierwszych 5 wyników
  PostsCounts <- first( PostsCounts[order(-AnswersNumber)], n = 5 )
  
  # Inner join z tabelą Users_dt, wybranie odpowiednich kolumn
  wynik <- merge.data.table(PostsCounts, Users_dt, by.x="OwnerUserId", by.y='Id')[order(-AnswersNumber), 
                                                                                  .(DisplayName, QuestionsNumber, AnswersNumber, Location, Reputation, UpVotes, DownVotes)]
  wynik
  
}

table_5 <- function(Posts, Comments, Users){
  
  # Konwersja na data.table
  Posts_dt = as.data.table(Posts)
  Users_dt = as.data.table(Users)
  Comments_dt = as.data.table(Comments)
  
  # Utworzenie pomocniczej tab. CmtTotScr z Comments_dt
  # Grupowanie po PostId, suma z Score
  CmtTotScr <- Comments_dt[, .(CommentsTotalScore = sum(Score, na.rm = T)), by=PostId]
  
  # Inner join CmtTotScr i Posts_dt, wybranie tylko postów typu 1 i odpowiednich kolumn
  PostsBestComments <- merge.data.table(Posts_dt, CmtTotScr, by.x="Id", by.y="PostId")[
    PostTypeId == 1, .(OwnerUserId, Title, CommentCount, ViewCount, CommentsTotalScore)]
  
  # Inner join pomocniczej tab. PostsBestComments z Users_dt 
  # Sortowanie po CommentsTotalScore malejąco i wybór odpowiednich kolumn
  wynik <- merge.data.table(PostsBestComments, Users_dt, by.x="OwnerUserId", by.y="Id")[
    order(-CommentsTotalScore), .(Title, CommentCount, ViewCount, CommentsTotalScore, DisplayName, Reputation, Location)] 
  
  first(wynik, n=10) # Pierwsze 10 rekordów
  
}
