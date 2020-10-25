# Plots

source('setup.R')

ag <- sf::read_sf(here::here('data','shapes','agencias_set20 - agencias_set20.shp'))
country <- geobr::read_country()

plot1 <-
  ggplot(country) + 
  geom_sf(fill = 'white') +
  geom_sf(data = ag, alpha = .15, color = '#980036') +
  scale_x_continuous(limits = c(-73,-33)) +
  scale_y_continuous(limits = c(-35,5)) +
  cowplot::theme_map() +
  labs(subtitle = "Agências - Todos os Bancos") +
  theme(axis.text = element_blank())

caixa <- ag %>% dplyr::filter(banco ==  "CAIXA ECONOMICA FEDERAL")

plot2 <-
ggplot(country) + 
  geom_sf(fill = 'white') +
  geom_sf(data = caixa, alpha = .15, color = '#980036') +
  scale_x_continuous(limits = c(-73,-33)) +
  scale_y_continuous(limits = c(-35,5)) +
  cowplot::theme_map() +
  labs(subtitle = "Agências - Caixa Econômica Federal") +
  theme(axis.text = element_blank())

library(patchwork)
plot <- plot1 | plot2
plot
ggsave(here::here('img','brasil.png'), dpi = 300)
salvador <- ag %>% filter(municip == 'Salvador')

salvador_sf <- read_municipality(code_muni = 2927408)

ggplot(salvador_sf) +
  geom_sf() +
  geom_sf(data = salvador)
