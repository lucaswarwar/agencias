# Plots

source('setup.R')

ag <- sf::read_sf(here::here('data','shapes','agencias_set20.shp'))
country <- geobr::read_country()


ggplot(country) + 
  geom_sf(fill = 'white') +
  geom_sf(data = ag, alpha = .125, color = '#980036') +
  scale_x_continuous(limits = c(-73,-33)) +
  scale_y_continuous(limits = c(-35,5)) +
  cowplot::theme_map() +
  labs(subtitle = "Agências - Todos os Bancos") +
  theme(axis.text = element_blank())

caixa <- ag %>% dplyr::filter(banco ==  "CAIXA ECONOMICA FEDERAL")

ggplot(country) + 
  geom_sf(fill = 'white') +
  geom_sf(data = caixa, alpha = .125, color = '#980036') +
  scale_x_continuous(limits = c(-73,-33)) +
  scale_y_continuous(limits = c(-35,5)) +
  cowplot::theme_map() +
  labs(subtitle = "Agências - Caixa Econômica Federal") +
  theme(axis.text = element_blank())

SP <- ag %>% filter(municip == 'São Paulo')
ggplot() +
  geom_sf(data = SP, aes(color = banco))
