
base_1 <- function(Users){
  
  users_filtered <- Users[Users$Location != '',]  # usunięcie pustych lokalizacji
  # Grupowanie po lokalizacji, sumowanie pola UpVotes dla każdej grupy
  wynik <- aggregate(users_filtered$UpVotes, by=list(users_filtered$Location), sum)
  colnames(wynik) <- c("Location", "TotalUpVotes")  # nadanie właściwych nazw kolumnom
  wynik <- wynik[ order(wynik$TotalUpVotes, decreasing=T), ]  # sortowanie malejąco po TotalUpVotes
  wynik <- head(wynik, 10)  # pierwsze 10 wierszy z wyniku
  rownames(wynik) <- 1:nrow(wynik)  # dla estetyki nadanie etykiet wierszom
  wynik
  
}

base_2 <- function(Posts){
  # Tworzona jest tabela Posts_ex zawierająca dodatkowe kol. Year i Month
  # Poprzez przekształcenie tabeli Posts
  Posts_ex <- transform(Posts, 
                        Year = format(as.Date(Posts$CreationDate), format = "%Y"),
                        Month = format(as.Date(Posts$CreationDate), format = "%m") )
  # Ograniczamy PostTypeId do jedynie 1 lub 2
  Posts_ex <- Posts_ex[Posts_ex$PostTypeId == 1 | Posts_ex$PostTypeId == 2, ]
  
  # Grupowanie po Year i Month, jednocześnie zliczamy ilość elementów w każdej
  # grupie za pomocą lenght() i maksymalny Score za pomocą max()
  # Konwersja na data.frame za pomocą do.call(data.frame, x)
  wynik <- do.call(data.frame, aggregate( Posts_ex$Score,
                                          by=list(Year=Posts_ex$Year, Month=Posts_ex$Month),
                                          FUN = function(x) cbind(PostsNumber = length(x), MaxScore = max(x)) ) )
  
  colnames(wynik) <- c("Year","Month","PostsNumber","MaxScore")
  wynik <- wynik[wynik$PostsNumber>1000,]  # wybranie tylko tych wierszy, gdzie liczba postów >1000
  wynik
  
}


base_3 <- function(Posts, Users){
  
  # Wybranie postów typu Question z tab. Posts
  Posts_filtered <- Posts[Posts$PostTypeId == 1, ]
  # Grupowanie po OwnerUserId, dla każdej grupy suma wyświetleń (ViewCount)
  # Otrzymujemy pomocniczą ramkę danych Questions
  Questions <- aggregate(Posts_filtered$ViewCount, by = list(OwnerUserId = Posts_filtered$OwnerUserId), sum )
  colnames(Questions)[2] <- "TotalViews"
  
  # Inner Join tabeli Users oraz Questions po polach Id i OwnerUserId
  wynik <- base::merge(Users, Questions, by.x = "Id", by.y = "OwnerUserId")
  # Posortowanie malejąco po liczbie wyświetleń, wybranie odpowiednich kolumn
  wynik <- wynik[order(wynik$TotalViews, decreasing = T), c(1,4,13)]
  rownames(wynik) <- 1:nrow(wynik)
  head(wynik,10)
  
}

base_4 <- function(Posts, Users){
  
  #   Wybranie z tab. Posts jedynie odpowiedzi (Answers) i odfiltrowanie nieznanych
  #   OwnerUserId. Następnie grupowanie po OwnerUserId i zliczenie ilości wystąpień w każdej grupie
  #   za pomocą length()
  
  Posts_filtered <- Posts[Posts$PostTypeId == 2 & !is.na(Posts$OwnerUserId),]
  Answers <- aggregate(Posts_filtered$Id, by=list(OwnerUserId = Posts_filtered$OwnerUserId), length)
  colnames(Answers)[2] <- "AnswersNumber"
  
  # Jak wyżej, tylko dla pytań (Questions)
  Posts_filtered <- Posts[Posts$PostTypeId == 1 & !is.na(Posts$OwnerUserId),]
  Questions <- aggregate(Posts_filtered$Id, by=list(OwnerUserId = Posts_filtered$OwnerUserId), length)
  colnames(Questions)[2] <- "QuestionsNumber"
  
  # Inner join ramek pomocniczych Answers i Questions
  PostsCounts <- merge(Answers, Questions)
  # Wybranie tych rekordów, gdzie AnswersNumber > QuestionsNumber
  PostsCounts <- PostsCounts[PostsCounts$AnswersNumber > PostsCounts$QuestionsNumber, ]
  # Sortowanie po ilości pytań malejąco i wybranie 5 pierwszych rekordów
  PostsCounts <- PostsCounts[order(PostsCounts$AnswersNumber, decreasing = T), ]
  PostsCounts <- head(PostsCounts, 5)
  
  # Inner join ramek PostsCounts i Users
  wynik <- merge(Users, PostsCounts, by.x = "Id", by.y="OwnerUserId")
  # Ponowne sortowanie po AnswersNumber i wybranie odpowiednich kolumn do wynikowej ramki
  wynik <- wynik[order(wynik$AnswersNumber, decreasing = T), 
                 c("DisplayName", "QuestionsNumber", "AnswersNumber", "Location", "Reputation", "UpVotes", "DownVotes")]
  rownames(wynik) <- 1:nrow(wynik)
  wynik
  
}

base_5 <- function(Posts, Comments, Users){
  
  # Grupowanie po PostId i suma z Score dla każdej grupy.
  # Zapis do pomocniczej ramki CmtTotScr
  CmtTotScr <- aggregate(Score ~ PostId, Comments, sum)
  colnames(CmtTotScr)[2] <- "CommentsTotalScore"
  
  # Inner join z tab. Posts. Wybranie tylko postów typu 1 oraz wybranie odpowiednich kolumn.
  PostsBestComments <- merge(CmtTotScr, Posts, by.x="PostId", by.y = "Id")
  PostsBestComments <- PostsBestComments[PostsBestComments$PostTypeId == 1, 
                                         c("OwnerUserId", "Title", "CommentCount","ViewCount", "CommentsTotalScore")]
  
  # Inner join ramki PostsBestComments z ramką Users.
  # Następnie sortowanie rekordów malejąco po CommentsTotalScore i wybranie
  # odpowiednich kolumn.
  wynik <- merge(PostsBestComments, Users, by.x="OwnerUserId", by.y = "Id")
  wynik <- wynik[order(wynik$CommentsTotalScore, decreasing = T), 
                 c("Title", "CommentCount", "ViewCount", "CommentsTotalScore", "DisplayName", "Reputation", "Location")]
  wynik <- head(wynik, 10) # Pierwsze 10 rekordów
  wynik
  
}