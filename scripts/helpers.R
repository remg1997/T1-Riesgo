
Dataframing <- function(path){
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

PaymentDates <- function(today, frequency = 6 , origin = "1970-01-01", semesters){
    datePayments <- list(today)
    for (i in 1:semesters){
        datePayments <- append(datePayments, today %m+% months(6))
        datePayments <- lapply(datePayments, as.Date, origin = "1970-01-01")
        today <- today %m+% months(6)
    }
    return (datePayments)
}

DiscountFactor <- function (curve, T){
    intervals_r <- c(3,12,36,60,120)
    intervals_l <- c(0,3,12,36,60)
    mask <- intervals_l <= T
    minimum <- pmin(T, intervals_r)
    areas <- ((minimum-intervals_l)/12)*curve*mask
    sum_areas<- sum(areas)
    discount <- as.numeric(exp(-(sum_areas)))
    return (discount)
}

RateConverter <- function(rate, T, today){
    days <- as.numeric(-difftime(today, today %m+% months(T) , units = "days"))
    if (T==3){
        semrate <- (1+rate)^{1/4}-1
    } else {
        semrate <- (1+rate)^{1/2}-1
    }
    
    newrate <- semrate*(days/360) #(days/360)
    return (newrate)
}


alphacuts <- function(alpha){
    ls <- list()
    for (x in 1:120){
        if (x<=3){
            ls<- append(ls, alpha[[1]]) 
        } else if (x<=12){
            ls<- append(ls, alpha[[2]]) 
        } else if (x<=36){
            ls<- append(ls, alpha[[3]]) 
        } else if (x<=60){
            ls<- append(ls, alpha[[4]]) 
        } else if (x<=120){
            ls<- append(ls, alpha[[5]]) 
        }
    }
    return (ls)
}