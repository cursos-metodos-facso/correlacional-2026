# Load necessary libraries
library(plotly)

# Create the x-axis values (common for all distributions)
x <- seq(-4, 4, length.out = 1000)

# Initial t-distribution y values with df = 10
initial_df <- 10
y_t <- dt(x, initial_df)

# Z-distribution (normal distribution) y values
y_z <- dnorm(x)

# Create the plot with both t-distribution and Z-distribution
p <- plot_ly() %>%
  add_trace(x = ~x, y = ~y_t, type = 'scatter', mode = 'lines', name = 't-distribution') %>%
  add_trace(x = ~x, y = ~y_z, type = 'scatter', mode = 'lines', name = 'Z-distribution', line = list(color = 'red')) %>%
  layout(
    title = paste("t-Distribution with", initial_df, "Degrees of Freedom"),
    xaxis = list(title = "t-value"),
    yaxis = list(title = "Density", range = c(0, 0.4)),  # Fix the y-axis range
    showlegend = TRUE,
    sliders = list(
      list(
        active = initial_df - 1,
        currentvalue = list(prefix = "Degrees of Freedom: "),
        steps = lapply(1:30, function(df) {
          list(
            label = df,
            method = "update",
            args = list(
              list(y = list(dt(x, df), y_z)),
              list(title = paste("t-Distribution with", df, "Degrees of Freedom"))
            )
          )
        })
      )
    ),
    updatemenus = list(
      list(
        type = "buttons",
        direction = "left",
        buttons = list(
          list(
            method = "restyle",
            args = list("visible", list(TRUE, FALSE)),
            label = "Z",
            args2 = list("visible", list(TRUE, TRUE)),
            showactive = TRUE
          )
        ),
        pad = list(r = 10, t = 10),
        showactive = TRUE,
        x = 1.1,  # Move to the right of the plot
        xanchor = "left",
        y = 0.5,  # Position below the legend
        yanchor = "middle"
      )
    )
  )

# Display the plot
p
