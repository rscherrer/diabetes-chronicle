# Function to plot the results
plot_basic <- function(data) {
  
  # Plot
  data %>%
    ggplot(aes(x = Ratio, y = ScaledGlycemiaChange)) +
    geom_hline(yintercept = 0, linetype = 2) +
    geom_point()
  
}

# Function to plot according to precision level
plot_by_precision <- function(data, facets = FALSE) {
  
  # Plot
  plot <- data %>%
    ggplot(aes(x = Ratio, y = ScaledGlycemiaChange, shape = Precision)) +
    geom_hline(yintercept = 0, linetype = 2) +
    scale_shape_manual(values = c(16, 21)) +
    geom_point()
  
  # Facet if needed
  if (facets) plot <- plot + facet_grid(. ~ Precision)
  
  return(plot)
  
}

# Function to plot according to activity score
plot_by_total_activity_impact <- function(data) {
  
  # Plot
  data %>%
    ggplot(aes(x = Ratio, y = ScaledGlycemiaChange, color = TotalActivityImpact)) +
    geom_hline(yintercept = 0, linetype = 2) +
    scale_color_gradient(low = "black", high = "brown1", name = "Activity", guide = "legend") +
    geom_point()
  
}

# Function to plot according to alcohol level
plot_by_max_inebriation_status <- function(data) {
  
  # Plot
  data %>%
    ggplot(aes(x = Ratio, y = ScaledGlycemiaChange, color = MaxInebriationStatus)) +
    geom_hline(yintercept = 0, linetype = 2) +
    scale_color_gradient(low = "black", high = "darkolivegreen3", name = "Alcohol", guide = "legend")  +
    geom_point()
  
}

# Function to plot according to slow insulin cover
plot_by_slow_cover <- function(data) {
  
  # Plot
  data %>%
    ggplot(aes(x = Ratio, y = ScaledGlycemiaChange, color = SlowCover)) +
    geom_hline(yintercept = 0, linetype = 2) +
    scale_color_gradient(low = "plum3", high = "black", name = "Slow\nInsulin", guide = "legend") +
    geom_point()
  
}

# Function to plot according to sickness
plot_by_sick <- function(data, facets = FALSE) {
  
  # Plot
  plot <- data %>%
    ggplot(aes(x = Ratio, y = ScaledGlycemiaChange, color = Sick)) +
    geom_hline(yintercept = 0, linetype = 2) +
    scale_color_manual(values = c("black", "dodgerblue")) +
    geom_point()
  
  # Facet if needed
  if (facets) plot <- plot + facet_grid(. ~ Sick)
  
  return(plot)
  
}

# Function to plot according to cartridge number
plot_by_main_insulin_cartridge <- function(data, facets = FALSE) {
  
  # Get cartridge numbers
  cartridges <- as.numeric(levels(as.factor(data$MainInsulinCartridge)))
  
  # Plot
  plot <- data %>%
    ggplot(aes(x = Ratio, y = ScaledGlycemiaChange, fill = MainInsulinCartridge)) +
    geom_hline(yintercept = 0, linetype = 2) +
    scale_fill_gradient(low = "black", high = "gray50", guide = "legend", breaks = cartridges, name = "Cartridge") +
    geom_point(shape = 21)
  
  # Facet if needed
  if (facets) plot <- plot + facet_grid(. ~ MainInsulinCartridge)
  
  return(plot)
  
}

# Function to plot according to plot duration
plot_by_duration <- function(data) {
  
  # Plot
  data %>%
    ggplot(aes(x = Ratio, y = ScaledGlycemiaChange, alpha = Duration)) +
    geom_hline(yintercept = 0, linetype = 2) +
    scale_alpha_continuous(range = c(1, 0.1), name = "Duration\n(min)") +
    geom_point()
  
}

# Function to plot according to activity score (binary)
plot_by_activity <- function(data, facets = FALSE) {
  
  # Plot
  plot <- data %>%
    ggplot(aes(x = Ratio, y = ScaledGlycemiaChange, color = Activity)) +
    geom_hline(yintercept = 0, linetype = 2) +
    scale_color_manual(values = c("black", "brown1")) +
    geom_point()
  
  # Facet if needed
  if (facets) plot <- plot + facet_grid(. ~ Activity)
  
  return(plot)
  
}

# Function to plot according to alcohol level (binary)
plot_by_alcohol <- function(data, facets = FALSE) {
  
  # Plot
  plot <- data %>%
    ggplot(aes(x = Ratio, y = ScaledGlycemiaChange, color = Alcohol)) +
    geom_hline(yintercept = 0, linetype = 2) +
    scale_color_manual(values = c("black", "darkolivegreen3"))  +
    geom_point()
  
  # Facet if needed
  if (facets) plot <- plot + facet_grid(. ~ Alcohol)
  
  return(plot)
  
}

# Function to plot according to slow insulin cover (binary)
plot_by_slow_insulin <- function(data, facets = FALSE) {
  
  # Plot
  plot <- data %>%
    ggplot(aes(x = Ratio, y = ScaledGlycemiaChange, color = SlowInsulin)) +
    geom_hline(yintercept = 0, linetype = 2) +
    scale_color_manual(values = c("plum3", "black"), name = "Slow\nInsulin") +
    geom_point()
  
  # Facet if needed
  if (facets) plot <- plot + facet_grid(. ~ SlowInsulin)
  
  return(plot)
  
}

# Function to plot according to plot duration (binary)
plot_by_is_long <- function(data, facets = FALSE) {
  
  # Plot
  plot <- data %>%
    ggplot(aes(x = Ratio, y = ScaledGlycemiaChange, alpha = IsLong)) +
    geom_hline(yintercept = 0, linetype = 2) +
    scale_alpha_manual(values = c(1, 0.1), name = "Long") +
    geom_point()
  
  # Facet if needed
  if (facets) plot <- plot + facet_grid(. ~ IsLong)
  
  return(plot)
  
}

# Axis labels
x_label <- function() { "Insulin-to-glucose ratio (units/g)" }
y_label <- function() { "Scaled change in glycemia (mg/dL/g)" }

# Wrapper around the plotting functions 
plot_by <- function(data, by = "basic", ...) {
  
  # data: the data set
  # by: suffix of the function to use
  
  # Add prefix if needed
  if (by != "basic") by <- str_c("by_", by)
  
  # Pick the right function
  FUN <- get(str_c("plot_", by))
  
  # Plot
  data %>%
    FUN(...) +
    xlab(x_label()) +
    ylab(y_label())
  
}

# Function to replace y-axes by a single one
common_y_axis <- function(P, y_label = "Y-axis", widths = c(1, 40)) {
  
  # P: a patchwork organized by row
  # y_label: title of the y-axis
  # widths: relative widths of the title panel and the rest of the plot
  
  # Remove individual y-axis titles
  for (i in seq(P)) P[[i]] <- P[[i]] + ylab(NULL)
  
  # Create a common y-axis title
  y_axis <- textGrob(y_label, rot = 90, gp = gpar(fontsize = 10))
  
  # Add new axis
  wrap_plots(y_axis, P, nrow = 1L, widths = widths)
  
}

# Combine all of the above in a patchwork
plot_all <- function(data, common_y = TRUE) {
  
  # common_y: whether to combine y-axes into one
  
  # For each plot...
  plots <- list(
    
    # Make the plot 
    plot_by(data, "basic") + rm_axis("x"),
    plot_by(data, "precision") + rm_axis("x"),
    plot_by(data, "total_activity_impact") + rm_axis("x"),
    plot_by(data, "max_inebriation_status") + rm_axis("x"),
    plot_by(data, "slow_cover") + rm_axis("x"),
    plot_by(data, "sick") + rm_axis("x"),
    plot_by(data, "main_insulin_cartridge") + rm_axis("x"),
    plot_by(data, "duration")
    
  )
  
  # Assemble
  P <- wrap_plots(plots, ncol = 1L)
  
  # Common axis if needed
  if (common_y) P <- P %>% common_y_axis(y_label(), widths = c(1, 40))
  
  return(P)
  
}

# Same but now with facetted binary confounders
plot_all_binary <- function(data, common_y = TRUE) {
  
  # common_y: whether to combine y-axes into one
  
  # For each plot...
  plots <- list(
    
    # Make the plot 
    plot_by(data, "precision", facets = TRUE) + rm_axis("x") + rm_strips("x"),
    plot_by(data, "activity", facets = TRUE) + rm_axis("x") + rm_strips("x"),
    plot_by(data, "alcohol", facets = TRUE) + rm_axis("x") + rm_strips("x"),
    plot_by(data, "slow_insulin", facets = TRUE) + rm_axis("x") + rm_strips("x"),
    plot_by(data, "sick", facets = TRUE) + rm_axis("x") + rm_strips("x"),
    plot_by(data, "main_insulin_cartridge", facets = TRUE) + rm_axis("x") + rm_strips("x"),
    plot_by(data, "is_long", facets = TRUE) + rm_strips("x")
    
  )
  
  # Assemble
  P <- wrap_plots(plots, ncol = 1L)
  
  # Common axis if needed
  if (common_y) P <- P %>% common_y_axis(y_label(), widths = c(1, 30))
  
  return(P)
  
}

# Function to plot the regression lines
plot_separate_regressions <- function(data) {
  
  # Fit models
  fit0 <- with(data, lm(ScaledGlycemiaChange ~ Ratio))
  fit1 <- with(data, lm(ScaledGlycemiaChange ~ Ratio * Activity))
  fit2 <- with(data, lm(ScaledGlycemiaChange ~ Ratio * Alcohol))
  fit3 <- with(data, lm(ScaledGlycemiaChange ~ Ratio * Sick))
  
  # Function to add regression lines to a plot
  ADDLINES <- function(plot, fit) {
    
    # plot: the scatter plot
    # fit: the fitted model
    
    # Create a dataset with predicted values 
    pred <- plot$data %>% mutate(ScaledGlycemiaChange = predict(fit, plot$data))
    
    # Add lines
    plot + geom_line(data = pred)
    
  }
  
  # Make plots
  p0 <- data %>% plot_by("basic") %>% ADDLINES(fit0)
  p1 <- data %>% plot_by("activity") %>% ADDLINES(fit1)
  p2 <- data %>% plot_by("alcohol") %>% ADDLINES(fit2)
  p3 <- data %>% plot_by("sick") %>% ADDLINES(fit3)
  
  # Combine
  wrap_plots(p0, p1, p2, p3)
  
}

# Function to plot one global regression
plot_global_regression <- function(data) {
  
  # Fit a global model
  fit <- with(data, lm(
    
    # With multiple slopes and intercepts
    ScaledGlycemiaChange ~ Ratio + Activity + Alcohol + Sick +
      Ratio:Activity + Ratio:Alcohol + Ratio:Sick
    
  ))
  
  # Capture bounds of the x-axis 
  min_ratio <- min(data$Ratio)
  max_ratio <- max(data$Ratio)
  
  # Prepare a prediction table
  pred <- data %>% 
    group_by(Activity, Alcohol, Sick) %>% 
    nest() %>% 
    mutate(Ratio = list(seq(min_ratio, max_ratio, 0.01))) %>%
    unnest(Ratio) %>%
    select(-data) %>%
    ungroup()
  
  # Add predictions
  pred <- pred %>% 
    mutate(ScaledGlycemiaChange = predict(fit, pred))
  
  # Function to prepare strip labels
  STRIPS <- function(data) {
    
    data %>%
      mutate(
        
        # Prepare strip labels...
        ActivityLab = if_else(Activity == "Yes", "Activity", "No activity"),
        AlcoholLab = if_else(Alcohol == "Yes", "Alcohol", "No alcohol"),
        SickLab = if_else(Sick == "Yes", "Sick", "Not sick")
        
      ) %>%
      mutate(
        
        # In alphabetical order
        ActivityLab = factor(ActivityLab, levels = c("No activity", "Activity")),
        AlcoholLab = factor(AlcoholLab, levels = c("No alcohol", "Alcohol"))
        
      )
    
  }
  
  # Prepare strip labels
  pred <- pred %>% STRIPS()
  data <- data %>% STRIPS()
  
  # Plot
  pred %>%
    ggplot(aes(x = Ratio, y = ScaledGlycemiaChange)) +
    geom_hline(yintercept = 0, linetype = 2) +
    geom_line() +
    geom_point(data = data, aes(color = NULL)) +
    facet_wrap(. ~ ActivityLab + AlcoholLab + SickLab) +
    xlab(x_label()) +
    ylab(y_label())
  
}
