# Base de Dados: Lista e Localização de todas as Agências Bancárias de intituições financieras sob supervisão do BACEN
# O arquivo é atualizado mensalmente e pode ser baixado no link:
# https://www.bcb.gov.br/acessoinformacao/legado?url=https:%2F%2Fwww.bcb.gov.br%2Ffis%2Finfo%2Fagencias.asp


### Limpeza dos dados brutos e geolocalização das Agências Bancárias ###

# Setup 
source('setup.R')

# Set 2020 --------

path <- here::here('data-raw/','2020/','202009AGENCIAS.xlsx') # caminho do arquivo bruto no repositório

# Carrega a base de agências
ag_set20 <- readxl::read_xlsx(path, skip = 8) # para outros meses/anos, conferir nº de linhas pra skip no .xlsx

ag_set20 <- data.table::as.data.table(sapply(ag_set20, as.character)) # transforma todas as colunas em character

# Renomeia colunas

data.table::setnames(ag_set20,
                     old = names(ag_set20),
                     new = c('cnpj_agencia', 'cnpj_seq', 'cnpj_dv', 'banco', 'segmento', 
                             'cod_compensacao_agencia','nome_agencia', 'endereco', 'numero', 
                             'complemento', 'bairro', 'cep', 'municipio', 'uf', 
                             'data_abertura', 'ddd', 'fone', 'id_agencia')
                     )

# Recodifica algumas variáveis

# SEQ do CNPJ deve ter 4 dígitos
ag_set20 <- ag_set20[, cnpj_seq := data.table::fcase(stringr::str_length(cnpj_seq) == 1, paste0('000',cnpj_seq),
                                                     stringr::str_length(cnpj_seq) == 2, paste0('00',cnpj_seq),
                                                     stringr::str_length(cnpj_seq) == 3, paste0('0', cnpj_seq),
                                                     stringr::str_length(cnpj_seq) == 4, cnpj_seq)]

# DV do CNPJ deve ter 2 dígitos
ag_set20 <- ag_set20[, cnpj_dv := data.table::fcase(stringr::str_length(cnpj_dv) == 1, paste0('0',cnpj_dv),
                                                    stringr::str_length(cnpj_dv) == 2, cnpj_dv)]

# CNPJ completo
ag_set20 <- ag_set20[, cnpj_agencia := paste(paste(cnpj_agencia,cnpj_seq, sep = "/"),cnpj_dv,sep = "-")]
ag_set20 <- ag_set20[, !c('cnpj_seq','cnpj_dv')] # Remove colunas, mantem info

# Endereço
ag_set20 <- ag_set20[, endereco := data.table::fifelse(is.na(numero) == TRUE, endereco, paste(endereco,numero, sep = ", "))]
ag_set20 <- ag_set20[, !c('numero','complemento')] # Remove colunas, mantem info

# Nomes dos municípios com Códigos do IBGE
ag_set20 <- ag_set20[, municipio := stringr::str_to_lower(municipio)]
ag_set20 <- ag_set20[, municipio := paste(municipio,uf,sep = " ")]

munis <- geobr::lookup_muni(name_muni = 'all') # base com todos os municipios 
munis <- data.table::setDT(munis)[, municipio := paste(rm_accent(stringr::str_to_lower(name_muni)),abrev_state,sep = " ")]

ag_set20 <- data.table::merge.data.table(ag_set20,
                                         munis[,.(name_muni,municipio)],
                                         all.x = TRUE,
                                         by = 'municipio')

# Corrige manualmente os Municipios com merge que deu errado

muni_erros <- ag_set20[is.na(name_muni) == TRUE, .(municipio)]
unique(muni_erros)

ag_set20 <- ag_set20 %>% 
  dplyr::mutate(
    name_muni = dplyr::case_when(
      municipio == 'belem de sao francisco PE' ~ 'Belém do São Francisco',
      municipio %in% c('brasilia (aguas claras) DF', 'brasilia (brazlandia) DF','brasilia (candangolandia) DF',
                       'brasilia (ceilandia) DF','brasilia (cruzeiro) DF','brasilia (gama) DF','brasilia (guara) DF',
                       'brasilia (nucleo bandeirante) DF','brasilia (paranoa) DF','brasilia (planaltina) DF',
                       'brasilia (recanto das emas) DF','brasilia (riacho fundo) DF','brasilia (samambaia) DF',
                        'brasilia (santa maria) DF','brasilia (sao sebastiao) DF','brasilia (sobradinho) DF',
                       'brasilia (sudoeste/octogonal) DF','brasilia (taguatinga) DF') ~ 'Brasília',
      municipio == 'campo grande RN' ~ 'Augusto Severo',
      municipio == 'dona euzebia MG' ~ 'Dona Eusébia',
      municipio == 'embu das artes SP' ~ 'Embu',
      municipio == 'entre ijuis RS' ~ 'Entre-Ijuís',
      municipio == 'florinea SP' ~ 'Florínia',
      municipio == 'lagoa do itaenga PE' ~ 'Lagoa de Itaenga',
      municipio == 'mogi-guacu SP' ~ 'Mogi Guaçu',
      municipio == 'mogi-mirim SP' ~ 'Moji Mirim',
      municipio == 'mojui dos campos PA' ~ 'Santarém',
      municipio == 'pindare mirim MA' ~ 'Pindaré-Mirim',
      municipio == 'poxoreu MT' ~ 'Poxoréo',
      municipio == 'santa cruz do monte castelo PR' ~ 'Santa Cruz de Monte Castelo',
      municipio == 'santana do livramento RS' ~ "Sant'Ana do Livramento",
      municipio == "sao lourenco d'oeste SC" ~ 'São Lourenço do Oeste',
      municipio == "sao miguel d'oeste SC" ~ 'São Miguel do Oeste',
      municipio == 'sao tome das letras MG' ~ 'São Thomé das Letras',
      municipio == 'trajano de morais RJ' ~ 'Trajano de Moraes',
      TRUE ~ name_muni)
    )

# Novo merge para códigos do IBGE
ag_set20 <- ag_set20[,municipio := paste(name_muni,uf,sep = " ")]
munis <- munis[, municipio := paste(name_muni,abrev_state,sep = " ")]

ag_set20 <- data.table::merge.data.table(ag_set20,
                                         munis[,.(code_muni,municipio)],
                                         all.x = TRUE,
                                         by = 'municipio')

# Coluna com endereço completo usando padrão do Google Maps: "Endereço - Bairro, Municipio - UF, CEP"
ag_set20 <- ag_set20[, endereco_completo := paste(paste(paste(paste(endereco,bairro,sep = " - "),name_muni,sep = ", "),uf,sep=" - "),cep,sep=", ")]

# Remove 2 linhas nulas no final do .xlsx
ag_set20 <- na.omit(ag_set20) # 19,670 agências únicas

# Geolocalização das agência com Google API

library(ggmap)

my_api <- # "abc123"
register_google(key = my_api) # registra a key do Google API

# Enderecos
enderecos <- unique(ag_set20$endereco_completo) # 19,218 endereços únicos

# Run Google API
coords_enderecos <- lapply(enderecos,geocode) %>% data.table::rbindlist()

# Combina output da query do Google com endereços completos
enderecos <- as.data.frame(enderecos) %>% dplyr::bind_cols(coords_enderecos)
enderecos <- data.table::setDT(enderecos)[, endereco_completo := enderecos]

# Salva backup dos enderecos geolocalizados
data.table::fwrite(enderecos,here::here('data',"csv", 'geocode_enderecos.csv'))

# Merge com base original de agências
ag_set20 <- data.table::merge.data.table(ag_set20,
                                         enderecos[,!c('enderecos')],
                                         all.x = TRUE,
                                         by = 'endereco_completo')

# Cria colunas com fonte dos dados e transforma colunas em character
ag_set20 <- ag_set20[, fonte_agencias := "BCB"]
ag_set20 <- ag_set20[, fonte_geocode := "Google"]

# Seleciona, ordena e renomeia variáveis

ag_set20 <- ag_set20 %>% dplyr::select(id_agencia,
                                       municipio = name_muni,
                                       cod_ibge  = code_muni,
                                       uf,
                                       cnpj_agencia,
                                       nome_agencia,
                                       banco,
                                       segmento,
                                       cod_compensacao_agencia,
                                       endereco,
                                       bairro,
                                       cep,
                                       ddd,
                                       telefone = fone,
                                       fonte_agencias,
                                       fonte_geocode,
                                       lon,
                                       lat
                                       )

ag_set20$cod_ibge <- as.character(ag_set20$cod_ibge)
ag_set20$lat <- data.table::fifelse(ag_set20$lat > 30, -1*ag_set20$lat,ag_set20$lat)

# Salva a base geolocalizada em formato .csv
data.table::fwrite(ag_set20, here::here('data','csv','agencias_set20.csv'))

# Cria arquivo shapefile de pontos

ag_set20_sf <- sf::st_as_sf(ag_set20 %>% na.omit(),
                            coords = c("lon", "lat"),
                            crs = 4674)

# Salva arquivo
sf::st_write(ag_set20_sf, here::here('data','shapes','agencias_set20.shp'))
