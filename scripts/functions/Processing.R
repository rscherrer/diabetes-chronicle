# Function to get chunk limits from a column of chunk symbols
get_chunks <- function(x, t) {
  
  # x: the column of symbols
  # t: the column of timestamps
  
  # Otherwise NA cannot be logically compared
  x <- replace_na(x, "na")
  
  # Keep track of whether the previous symbol was an "a"
  was_a <- FALSE
  
  # Initialize containers
  from <- NULL
  to <- NULL
  
  # For each event...
  for (i in seq(x)) {
    
    # If we are in a chunk...
    if (x[i] == "a") {
      
      # Record start time if it is a new chunk
      if (!was_a) from <- c(from, t[i])
      
      # Make sure we will remember that we were in a chunk
      was_a <- TRUE
      
    } else {
      
      # Otherwise remember that we were not in a chunk
      was_a <- FALSE
      
      # And record end time if we just reached a chunk end
      if (x[i] == "b") to <- c(to, t[i])
      
    }
  } 
  
  # Sanity check
  if (length(from) != length(to)) 
    stop(str_c(length(from), " sarting points but ", length(to), " ends"))
  
  # Make sure times are timestamps
  from <- as_datetime(from)
  to <- as_datetime(to)
  
  # Assemble in a table
  out <- tibble(StartTime = from, EndTime = to)
  
  return(out)
  
}

# Function to create a dataset on a per chunk basis
create_dataset <- function(data, threshold = 3, plotit = FALSE) {
  
  # data: the master database
  # threshold: time threshold for what qualifies as a chunk
  # plotit: whether or not to show a plot of the result 
  
  # Remove spaces in column names
  colnames(data) <- str_remove_all(colnames(data), " ")
  
  # Combine date and time to create timestamps
  data <- data %>%
    mutate(Timestamp = as_datetime(paste(Date, Time)))
  
  # Correction for the blood sugar column
  data <- data %>% 
    mutate(BloodSugar = if_else(BloodSugar == "HI", NA, BloodSugar)) %>%
    mutate(BloodSugar = if_else(BloodSugar == "LO", NA, BloodSugar)) %>%
    mutate(BloodSugar = as.numeric(BloodSugar))
  
  # Rename the columns that contain the relevant time chunk information
  data <- data %>% 
    rename(
      Key = str_c("Key", threshold),
      A = str_c("Chunk", threshold, "A"), 
      B = str_c("Chunk", threshold, "B")
    )
  
  # Record chunk bounds from both columns of symbols
  chunksA <- get_chunks(data$A, data$Timestamp)
  chunksB <- get_chunks(data$B, data$Timestamp)
  
  # Assemble both tables into one
  chunks <- rbind(chunksA, chunksB)
  
  # Arrange chunks by starting time
  chunks <- chunks %>% arrange(StartTime)
  
  # For each chunk...
  chunk_data <- chunks %>%
    mutate(Data = map2(StartTime, EndTime, function(from, to) {
      
      # from: starting point
      # to: end point
      
      # Extract the bit of the database located within that chunk in time
      data %>% filter(Timestamp <= to, Timestamp >= from)
      
    }))
  
  # Note: it was not as simple as taking the rows between start and end of each
  # chunk because of simultaneously timed entries (e.g. an event written just
  # before the end of a chunk but happening at the same time also counts for the
  # next chunk).
  
  # For each chunk...
  chunk_data <- chunk_data %>%
    mutate(Summary = map(Data, function(data) {
      
      # Sanity check
      if (sum(data$Key == "Yes") != 2L) 
        stop("There should be two key glycemias in a chunk")
      
      # Summarize key variables
      data %>%
        summarize(
          
          # First and last glycemia
          StartBloodSugar = BloodSugar[Key == "Yes"][1L],
          EndBloodSugar = BloodSugar[Key == "Yes"][2L],
          
          # Total amount of insulin injected
          TotalInsulin = sum(InsulinDose[EventType == "Insulin"]),
          
          # Total amount of glucose consumed
          TotalGlucose = sum(FoodGlucose[EventType == "Food"]),
          
          # Was there a low-precision glucose estimate?
          IsImprecise = any(FoodGlucosePrecision[EventType == "Food"] == "Low"),
          
          # What was the proportion of the time under slow insulin?
          SlowCoverDuration = diff(Timestamp[which(SlowInsulinCover == "Yes")[c(1L, n())]]),
          
          # How much alcohol was consumed during that time?
          MaxInebriationStatus = max(InebriationStatus, na.rm = TRUE),
          MaxInebriationStatus = if_else(MaxInebriationStatus == -Inf, 0, MaxInebriationStatus),
          
          # Note: NAs turn into -Inf, should be 0.
          
          # How much activity?
          TotalActivityImpact = sum(ActivityImpactScore[EventType == "Activity"]),
          
          # Was I sick?
          IsSick = any(Sick == "Yes"),
          
          # Which insulin was I using?
          MainInsulinCartridge = InsulinCartridge[EventType == "Insulin"][1L]
          
        )
      
    })) %>%
    select(-Data) %>%
    unnest(Summary)
  
  # Remove chunks with incomplete data
  chunk_data <- chunk_data %>% drop_na()
  
  # Compute the final important variables
  chunk_data <- chunk_data %>%
    mutate(
      Duration = EndTime - StartTime,
      GlycemiaChange = EndBloodSugar - StartBloodSugar,
      ScaledGlycemiaChange = GlycemiaChange / TotalGlucose,
      Ratio = TotalInsulin / TotalGlucose
    )
  
  # Convert slow insulin into proportion of time covered
  chunk_data <- chunk_data %>% 
    mutate(SlowCover = SlowCoverDuration / (as.numeric(Duration) * 60))
  
  # Convert confounders into binary variables
  chunk_data <- chunk_data %>%
    mutate(
      Precision = if_else(IsImprecise, "Low", "High"),
      Activity = if_else(TotalActivityImpact >= 2, "Yes", "No"),
      Alcohol = if_else(MaxInebriationStatus >= 2, "Yes", "No"),
      SlowInsulin = if_else(SlowCover == 1, "Yes", "No"),
      IsLong = if_else(Duration >= 500, "Yes", "No"),
      Sick = if_else(IsSick, "Yes", "No")
    )
  
  # If needed...
  if (plotit) {
    
    # Make plot
    plot <- chunk_data %>%
      ggplot(aes(x = Ratio, y = GlycemiaChange)) +
      geom_point()
    
    # Show
    print(plot)
    
  }
  
  # Return the table
  return(chunk_data)
  
}

# Filter out what we do not want in our analysis
filter_dataset <- function(data) {
  
  # Remove the low-precision measurements
  data <- data %>% filter(Precision == "High")
  
  # Remove times not under slow insulin
  data <- data %>% filter(SlowInsulin == "Yes")
  
  # Remove infinite ratios
  data <- data %>% filter(Ratio < Inf)
  
  # Remove outliers
  data <- data %>% filter(Ratio < 0.4)
  
  return(data)
  
}