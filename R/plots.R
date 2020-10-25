
ag <- read_sf(here('data','shapes','agencias_set20.shp'))
country <- geobr::read_country()

ggplot(country) + 
  geom_sf(fill = 'white') +
  geom_sf(data = ag, size = .9, alpha = .6, color = 'blue') +
  scale_x_continuous(limits = c(-80,-30)) +
  scale_y_continuous(limits = c(-35,5)) +
  theme_minimal() 
