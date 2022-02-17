dataframing <- function(path){
    names <- excel_sheets(path)
    if (length(excel_sheets(path)) == 1){
        df <- data.frame(read_excel(path))
        colnames(df)<-c("Date", names[1])
        return (df)
    } else {
        df<-data.frame(read_excel(path, sheet = 1))
        colnames(df)<-c("Date", names[1])
        for (i in 2:length(excel_sheets(path))){
            tempdf<- read_excel(path, sheet = i)
            colnames(tempdf)<- c("Date", names[i])
            df <- merge(df, tempdf, by = "Date") 
        }
        return (df)
    }
}