#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
#현재 프로젝트 경로 표시
getwd()

setwd("C:\\Users\\kkag2\\Desktop\\R_Project")

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


local1 <- mymap@data$공립초등학교+mymap@data$사립초등학교+mymap@data$국립초등학교
local2 <- mymap@data$공립중학교+mymap@data$사립중학교+mymap@data$국립중학교
local3 <- mymap@data$공립고등학교+mymap@data$사립고등학교+mymap@data$국립고등학교

school_result1 = data.frame(local1,local2,local3, stringsAsFactors = FALSE)
school_result1

colnames(school_result1) = list("초등학교","중학교","고등학교")
rownames(school_result1) = mymap$name
school_result1





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

