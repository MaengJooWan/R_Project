---
title: "leaflet 이용한 전국 초,중,고 공립,사립,국립 개교 현황 시각화"
author: "JooWan Maeng"
date: '`r format(Sys.Date(), "%B %d, %Y")`'
output:
  html_document:
    df_print: paged
    highlight: tango
    number_sections: yes
    theme: united
    toc: no
    toc_depth: 3
    toc_float: yes
runtime: shiny
---

*********
#\.  Excel로 데이터 가공
- https://www.data.go.kr/dataset/15021158/standard.do 접속 후CSV 파일 다운로드

![](https://github.com/MaengJooWan/R_Project/blob/master/Image/Image_01.JPG?raw=true)

- Excel를 연 후에 다음 밑 사진과 같이 행 열 필드 값 작성



![](https://github.com/MaengJooWan/R_Project/blob/master/Image/Image_02.jpg?raw=true)

- offset 함수를 사용하여 "교육청", "설립형태", "학교구분" 필드의 값들을 참조 대상으로 이름 정의를 지정
- offset 함수는 Excel에서 행과 열로 구성되어 있는 범위에 대한 참조를 반환
- 수식 파라미터 : OFFSET(reference, rows, cols, [height], [width])
- 수식 EX : OFFSET(전국초중등학교위치표준데이터!$C$1,0,8,COUNTA(전국초중등학교위치표준데이터!$F:$F),1)


![](https://github.com/MaengJooWan/R_Project/blob/master/Image/Image_03.JPG?raw=true)

- 다음과 같이 수식을 사용하여 각 지역별 학교 현황 계산
- COUNTIFS는 다중 개수를 새기 위해서 사용하는 함수
- 데이터 가공이 완료 되었으면 CSV파일로 저장


#\. 필요한 라이브러리 설치
```{r}
#필요한 패키지 다운로드
#leaflet는 자바스크립트로 만든 지도
#devtools는 github에 올라온 라이브러리를 다운로드 해주는 역할을 해줌
#kormaps는 대한민국 행정지도 데이터
#data.table는 데이터를 table 형식으로 표현해주는 라이브러리
#install.packages("data.table")
#install.packages("ggplot2")
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
library(ggplot2)
```


#\.R언어로 데이터 가공
```{r}
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
#지역별 국립, 사립, 공립 초,중,고등학교 지도에 시각화 하기 위한 데이터 가공
#palette는 색상 지정, popup은 지역 클릭시 팝업에 노출될 글씨 설정
#paste0은 공백 없이 붙히는 함수
mypalette1 <- colorNumeric(palette = "Reds", domain = mymap@data$공립초등학교)
mypopup1 <- paste0(mymap$name, " 공립 초등학교 수 : ",mymap@data$공립초등학교)
mypalette2 <- colorNumeric(palette = "Greens", domain = mymap@data$공립중학교)
mypopup2 <- paste0(mymap$name, " 공립 중학교 수 : ",mymap@data$공립중학교)
mypalette3 <- colorNumeric(palette = "Blues", domain = mymap@data$공립고등학교)
mypopup3 <- paste0(mymap$name, " 공립 고등학교 수 : ",mymap@data$공립고등학교)
mypalette4 <- colorNumeric(palette = "Reds", domain = mymap@data$사립초등학교)
mypopup4 <- paste0(mymap$name, " 사립 초등학교 수 : ",mymap@data$사립초등학교)
mypalette5 <- colorNumeric(palette = "Greens", domain = mymap@data$사립중학교)
mypopup5 <- paste0(mymap$name, " 사립 중학교 수 : ",mymap@data$사립중학교)
mypalette6 <- colorNumeric(palette = "Blues", domain = mymap@data$사립고등학교)
mypopup6 <- paste0(mymap$name, " 사립 고등학교 수 : ",mymap@data$사립고등학교)
mypalette7 <- colorNumeric(palette = "Reds", domain = mymap@data$국립초등학교)
mypopup7 <- paste0(mymap$name, " 국립 초등학교 수 : ",mymap@data$국립초등학교)
mypalette8 <- colorNumeric(palette = "Greens", domain = mymap@data$국립중학교)
mypopup8 <- paste0(mymap$name, " 국립 중학교 수 : ",mymap@data$국립중학교)
mypalette9 <- colorNumeric(palette = "Blues", domain = mymap@data$국립고등학교)
mypopup9 <- paste0(mymap$name, " 국립 고등학교 수 : ",mymap@data$국립고등학교)
#전국별 학교개수
global1 <-sum(mymap@data$공립초등학교+mymap@data$사립초등학교+mymap@data$국립초등학교)
global2 <-sum(mymap@data$공립중학교+mymap@data$사립중학교+mymap@data$국립중학교)
global3 <-sum(mymap@data$공립고등학교+mymap@data$사립고등학교+mymap@data$국립고등학교)
#전국별 학교 개수를 frame으로 만듬
school_name = c("초등학교","중학교","고등학교")
school_all_value = c(global1,global2,global3)
#Factors 형식을 FALSE를 해야 데이터를 쓸 수 있음 ggplot에선 Factors 지원 안함..
scholl_result = data.frame(school_name,school_all_value, stringsAsFactors = FALSE)
scholl_result
#지역별 초,중,고 학교 데이터 가공
local1 <- mymap@data$공립초등학교+mymap@data$사립초등학교+mymap@data$국립초등학교
local2 <- mymap@data$공립중학교+mymap@data$사립중학교+mymap@data$국립중학교
local3 <- mymap@data$공립고등학교+mymap@data$사립고등학교+mymap@data$국립고등학교
school_result1 = data.frame(local1,local2,local3, stringsAsFactors = FALSE)
school_result1
colnames(school_result1) = list("초등학교","중학교","고등학교")
rownames(school_result1) = mymap$name
school_result1
```

- 지도랑 차트에 데이터를 표시하기 위해서 데이터 가공 과정을 거침

#\. 전국의 초, 중, 고등학교 차트로 시각화
```{r}
# rmd는 라이브러리 표시하는 게 최대 2개 밖에 안 되는건가... 문서에는 표시가 안 되네...
# p = ggplot(scholl_result, aes(x = school_name, y = school_all_value)) + geom_bar(stat = "identity", fill = "red")
# 
# p + geom_text(aes(label = school_all_value),size = 10,hjust=0.5, color='#FFFFFF')
```
- 좀 이해가 안 가는데.. rmd는 시각화 결과를 최대 2개밖에 출력이 안 된다..
- 무료버전이라서 그런건가.. 아님 시각화 한 결과 용량이 커서 그런건가... 잘 모르겠다..


#\. Shiny를 이용한 지역별 초, 중, 고 현황
```{r}
library(shiny)
# Define UI for application that draws a histogram
ui <- fluidPage(
   
  # Give the page a title
  titlePanel("전국 초 중 고등학교 현황"),
  
  # Generate a row with a sidebar
  sidebarLayout(      
    
    # Define the sidebar with one input
    sidebarPanel(
      selectInput("region", "학교 선택:", 
                  choices=colnames(school_result1))
    ),
      
      # Show a plot of the generated distribution
      mainPanel(
        plotOutput("phonePlot")  
      )
   )
)
# Define server logic required to draw a histogram
server <- function(input, output) {
   
  # Fill in the spot we created for a plot
  output$phonePlot <- renderPlot({
    
    # Render a barplot
    barplot(school_result1[,input$region]*100, 
            main=input$region,
            ylab="개수",
            xlab="서울, 부산, 대구, 인천, 광주, 대전, 울산, 경기도, 강원도, 충북, 충남, 전북, 전남, 경북, 경남, 제주")
  })
}
# Run the application 
shinyApp(ui = ui, server = server)
```



#\. 공립 초등학교만 지도로 시각화
```{r}
# #공립초등학교 데이터만 시각화
# leaflet(mymap) %>%
#   addTiles() %>%
#   addPolygons(stroke = FALSE,
#               smoothFactor = 0.2,
#               fillOpacity = .8,
#               popup = mypopup1,
#               color = ~mypalette1(mymap@data$공립초등학교))
```

- 단일 데이터만 지도에 표시를 했는데 우리는 다중의 데이터를 표시하는 게 좋으니


#\. 모든 학교 지도로 시각화
```{r}
#모든 학교 데이터 시각화
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
    addPolygons(stroke = FALSE,
              smoothFactor = 0.2,
              fillOpacity = .7,
              popup = mypopup4,
              color = ~mypalette4(mymap@data$사립초등학교),
              group="사립초등학교") %>%
  addPolygons(stroke = FALSE,
              smoothFactor = 0.2,
              fillOpacity = .7,
              popup = mypopup5,
              color = ~mypalette5(mymap@data$사립중학교),
              group="사립중학교") %>%
  addPolygons(stroke = FALSE,
              smoothFactor = 0.2,
              fillOpacity = .7,
              popup = mypopup6,
              color = ~mypalette6(mymap@data$사립고등학교),
              group="사립고등학교") %>%
    addPolygons(stroke = FALSE,
              smoothFactor = 0.2,
              fillOpacity = .7,
              popup = mypopup7,
              color = ~mypalette7(mymap@data$국립초등학교),
              group="국립초등학교") %>%
  addPolygons(stroke = FALSE,
              smoothFactor = 0.2,
              fillOpacity = .7,
              popup = mypopup8,
              color = ~mypalette8(mymap@data$국립중학교),
              group="국립중학교") %>%
  addPolygons(stroke = FALSE,
              smoothFactor = 0.2,
              fillOpacity = .7,
              popup = mypopup9,
              color = ~mypalette9(mymap@data$국립고등학교),
              group="국립고등학교") %>%
  
  addLayersControl(
    baseGroups = c("공립초등학교","공립중학교","공립고등학교","사립초등학교","사립중학교","사립고등학교","국립초등학교","국립중학교","국립고등학교"),
    position = "bottomleft",
    options = layersControlOptions(collapsed = FALSE)
  )
#멀티지도 보여주기
multilayer_map
```

- 각 지역별 학교의 데이터를 표시하자!
