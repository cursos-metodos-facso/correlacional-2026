# Load necessary libraries
library(plotly)

# Create the x-axis values (common for all distributions)
x <- seq(-4, 4, length.out = 1000)

# Function to create the plot for a given alpha
create_z_plot <- function(alpha) {
  y_z <- dnorm(x)
  
  # Calculate the critical values for the given alpha
  crit_value <- qnorm(1 - alpha / 2)
  
  # Determine shading regions
  shade_left <- x <= -crit_value
  shade_right <- x >= crit_value
  
  plot_ly() %>%
    add_trace(x = ~x, y = ~y_z, type = 'scatter', mode = 'lines', name = 'Z-distribution', line = list(color = 'blue')) %>%
    add_trace(
      x = x[shade_left], y = y_z[shade_left],
      type = 'scatter', mode = 'none', fill = 'tozeroy', fillcolor = 'rgba(255,0,0,0.3)', showlegend = FALSE
    ) %>%
    add_trace(
      x = x[shade_right], y = y_z[shade_right],
      type = 'scatter', mode = 'none', fill = 'tozeroy', fillcolor = 'rgba(255,0,0,0.3)', showlegend = FALSE
    ) %>%
    layout(
      title = list(
        text = paste("Z-Distribution with Shaded Rejection Regions (alpha =", alpha, ")"),
        x = 0.5,  # Center the title
        y = 0.95,  # Move the title down slightly
        xanchor = "center",
        yanchor = "top"
      ),
      xaxis = list(title = "Z-value"),
      yaxis = list(title = "Density", range = c(0, 0.4)),  # Fix the y-axis range
      margin = list(t = 120),  # Increase top margin to create more space between the title and the graph
      showlegend = FALSE
    )
}

# Create initial plot with alpha = 0.05
p <- create_z_plot(0.05)

# Add slider to update alpha
p <- p %>%
  layout(
    sliders = list(
      list(
        active = 5,  # Set the default active value to alpha = 0.05
        currentvalue = list(prefix = "Significance Level: ", font = list(size = 20)),
        steps = lapply(c(0.5, 0.4, 0.3, 0.2, 0.1, 0.05, 0.01, 0.001), function(alpha) {
          crit_value <- qnorm(1 - alpha / 2)
          list(
            label = as.character(alpha),
            method = "update",
            args = list(
              list(
                x = list(x, x[x <= -crit_value], x[x >= crit_value]),
                y = list(dnorm(x), dnorm(x)[x <= -crit_value], dnorm(x)[x >= crit_value])
              ),
              list(
                title = paste("Z-Distribution with Shaded Rejection Regions (alpha =", alpha, ")")
              )
            )
          )
        })
      )
    )
  )

# Display the plot
p
