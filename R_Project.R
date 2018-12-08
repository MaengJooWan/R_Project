#필요한 패키지 다운로드
#leaflet는 자바스크립트로 만든 지도
#devtools는 github에 올라온 라이브러리를 다운로드 해주는 역할을 해줌
#kormaps는 대한민국 행정지도 데이터
#data.table는 데이터를 table 형식으로 표현해주는 라이브러리
#install.packages("data.table")
#install.packages("leaflet")
#install.packages("devtools")  # 한번 설치한 경우에는 다시 설치할 필요 없습니다.
#devtools::install_github("cardiomoon/Kormaps")


#다운 받은 라이브러리를 셋팅
rm(list = ls())
library(webshot)
require(Kormaps)
require(tmap)
require(leaflet)
library(data.table)

#현재 프로젝트가 있는 경로로 변경
setwd("C:\\Users\\kkag2\\Desktop\\R_Project")

#현재 프로젝트 경로 표시
getwd()

#학교 데이터를 table 형식으로 가공 후 표시
school <- fread("school_data.csv", sep = ",", header = T, stringsAsFactors = F)
school

#korpopmap 라이브러리 인코딩 처리
Encoding(names(korpopmap1))<-"UTF-8"
Encoding(korpopmap1@data$name)<-"UTF-8"
Encoding(korpopmap1@data$행정구역별_읍면동)<-"UTF-8"

value <- data.table(kormap1@data)

korpopmap1@data$name

#school table의 열 이름을 쓰고 싶으면 열을 풀어야 됨
a <- unlist(school[,2], use.names = FALSE)

#school 데이터를 보면 16개의 obs, 10개의 variables로 되어 있음
korpopmap1@data<-cbind(korpopmap1@data, school[1:16])
mymap <- korpopmap1


#palette는 색상 지정, popup은 지역 클릭시 팝업에 노출될 글씨 설정
#paste0은 공백 없이 붙히는 함수
mypalette1 <- colorNumeric(palette = "Reds", domain = mymap@data$공립초등학교)
mypopup1 <- paste0(mymap$name, "공립 초등학교 수 : ",mymap@data$공립초등학교)
mypalette2 <- colorNumeric(palette = "Greens", domain = mymap@data$공립중학교)
mypopup2 <- paste0(mymap$name, "공립 중학교 수 : ",mymap@data$공립중학교)
mypalette3 <- colorNumeric(palette = "Blues", domain = mymap@data$공립고등학교)
mypopup3 <- paste0(mymap$name, "공립 고등학교 수 : ",mymap@data$공립고등학교)


#공립초등학교 데이터만 시각화
leaflet(mymap) %>%
  addTiles() %>%
  addPolygons(stroke = FALSE,
              smoothFactor = 0.2,
              fillOpacity = .8,
              popup = mypopup1,
              color = ~mypalette1(mymap@data$공립초등학교))

#공립초등학교, 공립중학교, 공립고등학교 데이터 시각화
multilayer_map<-leaflet(mymap) %>%
  addTiles() %>%
  addPolygons(stroke = FALSE,
              smoothFactor = 0.2,
              fillOpacity = .7,
              popup = mypopup1,
              color = ~mypalette1(mymap@data$공립초등학교),
              group="공립초등학교") %>%
  addPolygons(stroke = FALSE,
              smoothFactor = 0.2,
              fillOpacity = .7,
              popup = mypopup2,
              color = ~mypalette2(mymap@data$공립중학교),
              group="공립중학교") %>%
  addPolygons(stroke = FALSE,
              smoothFactor = 0.2,
              fillOpacity = .7,
              popup = mypopup3,
              color = ~mypalette3(mymap@data$공립고등학교),
              group="공립고등학교") %>%
  addLayersControl(
    baseGroups = c("공립초등학교","공립중학교","공립고등학교"),
    position = "bottomleft",
    options = layersControlOptions(collapsed = FALSE)
  )

#멀티지도 보여주기
multilayer_map


