dplyr_1 <- function(Users){
  # Z tabeli Users usuwamy najpierw puste lokalizacje, następnie grupujemy
  # po lokalizacji i za pomocą summarise() sumujemy dla każdej lokalizacji
  # ilość UpVotes
  
  Users %>%
    filter(Location != '') %>%
    group_by(Location) %>%
    summarise(TotalUpVotes = sum(UpVotes, na.rm=T) ) -> wynik
  
  # Wynik poprzednich operacji porządkujemy malejąco po TotalUpVotes
  # Następnie za pomocą slice() wybieramy pierwsze 10 wierszy i
  # konwertujemy wynik z tibble na data.frame
  
  wynik %>%
    arrange(desc(TotalUpVotes)) %>%
    slice(1:10) %>%
    data.frame()
}

dplyr_2 <- function(Posts){
  
  Posts %>%
    # Dodanie kolumn Year i Month  do tab. Posts za pomocą mutate()
    mutate(Year = format(as.Date(CreationDate), format = "%Y"), 
           Month = format(as.Date(CreationDate), format = "%m") ) %>%
    # Ograniczamy PostTypeId do jedynie 1 lub 2
    filter(PostTypeId %in% c(1,2) ) %>%
    # Grupowanie po Year i Month, następnie zliczenie ilosci postów 
    # oraz maksymalnego Score
    group_by(Year, Month) %>%
    summarise( PostsNumber = length(Id),
               MaxScore = max(Score, na.rm=T), .groups = "drop" ) %>%
    # Wybranie tylko tych wierszy, gdzie PostsNumber > 1000
    filter(PostsNumber > 1000) -> wynik
  
  wynik
}

dplyr_3 <- function(Posts, Users){
  
  # Filtorwanie postów typu 1, następnie grupowanie po OwnerUserId i dla każdej 
  # grupy obliczenie sumy wyświetleń
  # Zapis do pomocniczej ramki danych Questions
  Posts %>%
    filter(PostTypeId == 1) %>%
    group_by(OwnerUserId) %>%
    summarise( TotalViews = sum(ViewCount, na.rm=T) ) -> Questions
  
  # Inner join tabel Users i Questions
  inner_join(Users, Questions, by=c("Id" = "OwnerUserId")) %>%
    # Wybranie odpowiednich kolumn
    select(Id, DisplayName, TotalViews) %>%
    # Ustawienie wierszy w kolejności malejącej względem TotalViews
    arrange(desc(TotalViews)) %>%
    slice_head(n = 10) -> wynik
  
  wynik
}

dplyr_4 <- function(Posts, Users){
  
  # Stworzenie tabeli Answers poprzez wybranie tylko postów typu Answer,
  # odfiltrowanie nieznanych wartości OwnerUserId. Następnie dla każdego OwnerUserId
  # zliczenie ilości jego odpowiedzi ( n() zwraca ilość wierszy w danej grupie)
  Posts %>%
    filter(PostTypeId == 2, !is.na(OwnerUserId)) %>%
    group_by(OwnerUserId) %>%
    summarise( AnswersNumber = n() ) -> Answers
  
  # Jak wyżej, tylko że dla odpowiedzi (Questions)
  Posts %>%
    filter(PostTypeId == 1, !is.na(OwnerUserId)) %>%
    group_by(OwnerUserId) %>%
    summarise( QuestionsNumber = n() ) -> Questions
  
  # Inner join tabel Questions i Answers
  # Filtrowanie tylko tych wierszy (użytkowników) gdzie odpowiedzi było 
  # więcej niż pytań. Ustawienie kolejności malejącej po ilości pytań i 
  # wzięcie pierwszych 5 wierszy
  inner_join(Answers, Questions, by=c("OwnerUserId" = "OwnerUserId")) %>%
    filter(AnswersNumber > QuestionsNumber) %>%
    arrange(desc(AnswersNumber)) %>%
    slice_head(n=5) -> PostsCounts
  
  # Inner join tabeli Users i PostsCounts. Wyświetlane są wymagane kolumny.
  # Wynik jeszcze raz sortowany malejąco po AnswersNumber
  inner_join(Users, PostsCounts, by=c("Id" = "OwnerUserId")) %>%
    select(DisplayName, QuestionsNumber, AnswersNumber, Location, Reputation, UpVotes, DownVotes) %>%
    arrange(desc(AnswersNumber)) -> wynik
  
  wynik
  
}

dplyr_5 <- function(Posts, Comments, Users){
  
  # Z ramki Comments grupowanie po PostId i zliczenie dla każdej grupy sumy ze Score.
  # Zapis do pomocniczej ramki CmtTotScr.
  Comments %>%
    group_by(PostId) %>%
    summarise( CommentsTotalScore = sum(Score, na.rm = T)) -> CmtTotScr
  
  # Inner join CmtTotScr z tab. Posts
  inner_join(CmtTotScr, Posts, by=c("PostId" = "Id")) %>%
    # Wybranie tylko postów typu 1
    filter( PostTypeId == 1 ) %>%
    # Wybór odpowiednich kolumn
    select( OwnerUserId, Title, CommentCount, ViewCount, CommentsTotalScore ) %>%
    # Inner join ramki uzyskanej funkcję wyżej z ramką Users
    inner_join(Users, by= c("OwnerUserId" = "Id")) %>%
    # Sortowanie po CommentsTotalScore malejąco
    arrange(desc(CommentsTotalScore)) %>%
    # Pierwsze 10 rekordów i wybór odpowiednich kolumn
    slice_head(n = 10) %>%
    select(Title, CommentCount, ViewCount, CommentsTotalScore, 
           DisplayName, Reputation, Location) -> wynik
  wynik
  
}
