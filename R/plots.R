### Plots demo ###

# Setup 
source('setup.R')

# Carrega shape das agências
ag <- sf::read_sf(here::here('data','shapes','agencias_set20_ok.shp'))

# Carrega shape do Brasil
country <- geobr::read_country()

# Todas as Agências do Brasil
plot1 <-
  ggplot(country) + 
  geom_sf(fill = 'white') +
  geom_sf(data = ag, alpha = .15, color = '#980036') +
  scale_x_continuous(limits = c(-73,-33)) +
  scale_y_continuous(limits = c(-35,5)) +
  cowplot::theme_map() +
  labs(subtitle = "Agências - Todos os Bancos") +
  theme(axis.text = element_blank())

# Filtra Agências da CEF
caixa <- ag %>% dplyr::filter(banco ==  "CAIXA ECONOMICA FEDERAL")

# Somente Agências da Caixa 
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

sp <- ag %>% dplyr::filter(cod_ibg == '3550308')

unique(sp$banco)

sp <- sp %>% dplyr::filter(banco %in% c("BANCO DO BRASIL S.A.",                                                                                        
                                        "ITAÃ? UNIBANCO S.A."  ,                                                                                       
                                        "BANCO BRADESCO S.A."   ,                                                                                      
                                        "CAIXA ECONOMICA FEDERAL",                                                                                     
                                        "BANCO SANTANDER (BRASIL) S.A."))

sp <- sp %>% dplyr::mutate(banco = dplyr::case_when(banco == "BANCO DO BRASIL S.A." ~ 'Banco do Brasil',
                                                    banco ==  "ITAÃ? UNIBANCO S.A." ~ 'Itaú',
                                                    banco == "BANCO BRADESCO S.A." ~ 'Bradesco',
                                                    banco == "CAIXA ECONOMICA FEDERAL" ~ 'Caixa Econômica',
                                                    banco == "BANCO SANTANDER (BRASIL) S.A." ~ 'Santander')
                           )


sp_sf <- geobr::read_municipality(code_muni = 3550308)

ggplot(sp_sf) +
  geom_sf(fill = NA) +
  ggthemes::scale_color_tableau() +
  geom_sf(data = sp,
          aes(color = banco), alpha = .6) +
  facet_wrap(~banco, nrow = 1) +
  cowplot::theme_map() +
  theme(legend.position = 'none',
        axis.text = element_blank())

ggsave(here::here('img','sp.png'),dpi = 300)

rj <- ag %>% dplyr::filter(cod_ibg == '3304557')

rj <- rj %>% dplyr::filter(banco %in% c("BANCO DO BRASIL S.A.",                                                                                        
                                        "ITAÃ? UNIBANCO S.A."  ,                                                                                       
                                        "BANCO BRADESCO S.A."   ,                                                                                      
                                        "CAIXA ECONOMICA FEDERAL")  )                                                                                   

rj <- rj %>% dplyr::mutate(banco = dplyr::case_when(banco == "BANCO DO BRASIL S.A." ~ 'Banco do Brasil',
                                                    banco ==  "ITAÃ? UNIBANCO S.A." ~ 'Itaú',
                                                    banco == "BANCO BRADESCO S.A." ~ 'Bradesco',
                                                    banco == "CAIXA ECONOMICA FEDERAL" ~ 'Caixa Econômica')
)


rj_sf <- geobr::read_municipality(code_muni = 3304557)

ggplot(rj_sf) +
  geom_sf(fill = NA) +
  ggthemes::scale_color_tableau() +
  geom_sf(data = rj,
          aes(color = banco), alpha = .6)+
  facet_wrap(~banco, nrow = 2) +
  scale_x_continuous(limits = c(-43.8,-43)) +
  scale_y_continuous(limits = c(-23.1,-22.7)) +
  theme_minimal() +
  theme(legend.position = 'none',
        axis.text = element_blank()
        )

ggsave(here::here('img','rj.png'),dpi = 300)

ce <- ag %>% dplyr::filter(uf == 'CE')
ce_sf <- geobr::read_state(code_state = 'CE')

ce_plot <-
ggplot(ce_sf) + 
  geom_sf(fill = 'white') +
  geom_sf(data = ce, alpha = .6, color = '#980036') + 
  theme_minimal() +
  labs(title = 'Ceará') +
  theme(legend.position = 'none',
        axis.text = element_blank()
  )

rs <- ag %>% dplyr::filter(uf == 'RS')
rs_sf <- geobr::read_state(code_state = 'RS')

rs_plot <-
  ggplot(rs_sf) + 
  geom_sf(fill = 'white') +
  geom_sf(data = rs, alpha = .6, color = '#2e8b57') + 
  theme_minimal() +
  labs(title = 'Rio Grande do Sul') +
  theme(legend.position = 'none',
        axis.text = element_blank()
  )

sp <- ag %>% dplyr::filter(uf == 'SP')
sp_sf <- geobr::read_state(code_state = 'SP')

sp_plot <-
  ggplot(sp_sf) + 
  geom_sf(fill = 'white') +
  geom_sf(data = sp, alpha = .5, color = '#6e3a07') + 
  theme_minimal() +
  labs(title = 'São Paulo') +
  theme(legend.position = 'none',
        axis.text = element_blank()
  )

ro <- ag %>% dplyr::filter(uf == 'RO')
ro_sf <- geobr::read_state(code_state = 'RO')

ro_plot <-
  ggplot(ro_sf) + 
  geom_sf(fill = 'white') +
  geom_sf(data = ro, alpha = .9, color = '#152fbd') + 
  theme_minimal() +
  labs(title = 'Rondônia') +
  theme(legend.position = 'none',
        axis.text = element_blank()
  )

library(patchwork)
states <- (rs_plot|ce_plot)/(sp_plot|ro_plot)
states
ggsave(here::here('img','uf.png'),dpi = 300)
