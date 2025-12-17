# =============================================================================
# MÓDULO 3 - AULA 3: Dados com Estruturas de Dependência
# Atividades Complementares
# Curso: Introdução à Análise de Dados para Pesquisa no SUS
# =============================================================================
#
# ATENÇÃO: Esta é a aula mais avançada do módulo!
# Os tópicos aqui são apenas uma INTRODUÇÃO a métodos complexos.
# Execute o código linha por linha e leia os comentários com atenção.
#
# CONTEÚDO:
#   Parte 1: Modelos Multiníveis (dados hierárquicos)
#   Parte 2: Séries Temporais
#   Parte 3: Análise de Sobrevivência
#
# =============================================================================


# -----------------------------------------------------------------------------
# CONFIGURAÇÃO INICIAL
# -----------------------------------------------------------------------------

# Se necessário, defina o diretório de trabalho:
# setwd("C:/caminho/para/pasta/do/curso")  # Windows
# setwd("/home/usuario/pasta/do/curso")    # Linux/Mac

# Verificar o diretório atual
getwd()


# -----------------------------------------------------------------------------
# PACOTES NECESSÁRIOS
# -----------------------------------------------------------------------------

# Se ainda não instalou, remova o # e execute:
# install.packages("tidyverse")
# install.packages("survival")
# install.packages("lme4")
# install.packages("forecast")

# Carregar os pacotes
library(tidyverse)
library(survival)    # Para análise de sobrevivência
library(lme4)        # Para modelos multiníveis
library(forecast)    # Para séries temporais


# #############################################################################
#
# ATIVIDADE 1: MODELOS MULTINÍVEIS
#
# #############################################################################
#
# O QUE SÃO DADOS HIERÁRQUICOS?
# -----------------------------
# São dados organizados em NÍVEIS ou GRUPOS aninhados.
#
# Exemplos:
# - Pacientes dentro de HOSPITAIS
# - Alunos dentro de ESCOLAS
# - Funcionários dentro de EMPRESAS
# - Medidas repetidas no MESMO paciente
#
# POR QUE ISSO IMPORTA?
# ---------------------
# Pessoas do MESMO grupo tendem a ser mais parecidas entre si.
# Pacientes do mesmo hospital compartilham: mesmos médicos, protocolos, etc.
# Ignorar isso pode levar a conclusões ERRADAS!
#
# O QUE O MODELO MULTINÍVEL FAZ?
# ------------------------------
# Ele "reconhece" que existem grupos e permite que algumas características
# variem ENTRE os grupos (efeitos aleatórios).
#
# =============================================================================


# -----------------------------------------------------------------------------
# DADOS: Pacientes em Hospitais
# -----------------------------------------------------------------------------

# Fixar semente para reprodutibilidade
set.seed(123)

# Configuração
n_hospitais <- 10      # 10 hospitais diferentes
n_pac_por_hosp <- 30   # 30 pacientes em cada hospital

# Criar um "efeito" de cada hospital
# Alguns hospitais têm pacientes com PA mais alta, outros mais baixa
# Isso simula diferenças entre hospitais (qualidade, perfil de pacientes, etc.)
efeito_hospital <- rnorm(n_hospitais, mean = 0, sd = 5)

# Ver os efeitos de cada hospital:
efeito_hospital

# Hospital com efeito POSITIVO → PA mais alta em média
# Hospital com efeito NEGATIVO → PA mais baixa em média


# Criar os dados:
dados_multinivel <- tibble(
  hospital_id = rep(1:n_hospitais, each = n_pac_por_hosp),  # ID do hospital (1-10)
  paciente_id = 1:(n_hospitais * n_pac_por_hosp)           # ID do paciente (1-300)
) %>%
  mutate(
    idade = round(runif(n(), 30, 70)),                      # Idade: 30-70 anos
    sexo = sample(c("F", "M"), n(), replace = TRUE),        # Sexo aleatório
    efeito_hosp = efeito_hospital[hospital_id],             # Efeito do hospital
    # PA = valor base + efeito da idade + efeito do hospital + ruído
    pa = round(100 + 0.5 * idade + efeito_hosp + rnorm(n(), 0, 8), 1)
  )

# O que fizemos:
# - n() dentro do mutate retorna o número de linhas
# - efeito_hospital[hospital_id] pega o efeito do hospital de cada paciente
# - A PA depende da idade E do hospital onde o paciente está


# Ver as primeiras linhas:
head(dados_multinivel, 10)


# -----------------------------------------------------------------------------
# EXPLORAÇÃO: Médias por Hospital
# -----------------------------------------------------------------------------

# Calcular a média de PA em cada hospital:
dados_multinivel %>%
  group_by(hospital_id) %>%
  summarise(
    n = n(),                    # Número de pacientes
    media_pa = mean(pa),        # Média de PA
    dp_pa = sd(pa)              # Desvio-padrão
  )

# OBSERVE:
# → As médias de PA variam entre hospitais
# → Isso é o "efeito do hospital" que criamos


# -----------------------------------------------------------------------------
# COMPARAÇÃO: Modelo Comum vs Modelo Multinível
# -----------------------------------------------------------------------------

# MODELO COMUM (ignora a estrutura hierárquica)
# Trata todos os 300 pacientes como se fossem independentes
modelo_comum <- lm(pa ~ idade + sexo, data = dados_multinivel)
summary(modelo_comum)


# MODELO MULTINÍVEL
# Reconhece que pacientes estão agrupados em hospitais
#
# A notação (1 | hospital_id) significa:
# "Permita que o INTERCEPTO varie por hospital"
# Ou seja: cada hospital pode ter um "nível base" diferente de PA

modelo_multinivel <- lmer(pa ~ idade + sexo + (1 | hospital_id), 
                          data = dados_multinivel)

summary(modelo_multinivel)

# COMO LER O RESULTADO:
#
# Fixed effects (Efeitos Fixos):
# → São os efeitos que são IGUAIS para todos os hospitais
# → (Intercept): valor base de PA
# → idade: efeito de cada ano de idade (igual em todos os hospitais)
# → sexoM: diferença entre homens e mulheres (igual em todos os hospitais)
#
# Random effects (Efeitos Aleatórios):
# → Mostram quanta variação existe ENTRE os hospitais
# → Variance do hospital_id: variabilidade entre hospitais
# → Variance Residual: variabilidade dentro de cada hospital


# -----------------------------------------------------------------------------
# VER OS EFEITOS
# -----------------------------------------------------------------------------

# Efeitos FIXOS (iguais para todos):
fixef(modelo_multinivel)

# Efeitos ALEATÓRIOS (variam por hospital):
ranef(modelo_multinivel)

# Cada hospital tem um "ajuste" diferente no intercepto
# Hospitais com valor POSITIVO têm PA média mais alta
# Hospitais com valor NEGATIVO têm PA média mais baixa


# #############################################################################
#
# ATIVIDADE 2: SÉRIES TEMPORAIS
#
# #############################################################################
#
# O QUE É UMA SÉRIE TEMPORAL?
# ---------------------------
# São dados coletados ao longo do TEMPO, em intervalos regulares.
#
# Exemplos:
# - Casos de dengue por SEMANA
# - Temperatura diária
# - PIB trimestral
# - Internações mensais
#
# COMPONENTES DE UMA SÉRIE TEMPORAL:
# ----------------------------------
# 1. TENDÊNCIA: Direção geral (subindo, descendo, estável)
# 2. SAZONALIDADE: Padrões que se repetem (ex: gripe no inverno)
# 3. CICLOS: Flutuações de longo prazo
# 4. RUÍDO: Variações aleatórias
#
# =============================================================================


# -----------------------------------------------------------------------------
# DADOS: Casos de Síndrome Gripal por Semana
# -----------------------------------------------------------------------------

set.seed(42)
n_semanas <- 156  # 3 anos de dados (52 semanas x 3)

# Criar série temporal simulada:
serie_gripal <- tibble(
  semana = 1:n_semanas,                    # Semana 1 a 156
  ano = rep(2021:2023, each = 52),         # Ano correspondente
  semana_ano = rep(1:52, 3)                # Semana dentro do ano (1-52)
) %>%
  mutate(
    # TENDÊNCIA: aumenta levemente ao longo do tempo
    tendencia = 100 + 0.3 * semana,
    
    # SAZONALIDADE: pico no outono/inverno (função seno)
    # O padrão se repete a cada 52 semanas
    sazonalidade = 50 * sin(2 * pi * (semana_ano - 10) / 52),
    
    # RUÍDO: variação aleatória
    ruido = rnorm(n_semanas, 0, 15),
    
    # CASOS = tendência + sazonalidade + ruído
    # pmax(..., 10) garante que não tenhamos valores negativos
    casos = round(pmax(tendencia + sazonalidade + ruido, 10))
  )

# Ver os primeiros dados:
head(serie_gripal, 10)


# -----------------------------------------------------------------------------
# VISUALIZAÇÃO DA SÉRIE
# -----------------------------------------------------------------------------

ggplot(serie_gripal, aes(x = semana, y = casos)) +
  geom_line(color = "steelblue", linewidth = 0.8) +    # Linha conectando os pontos
  labs(title = "Casos de Síndrome Gripal por Semana (2021-2023)",
       x = "Semana", 
       y = "Número de Casos") +
  theme_minimal()

# OBSERVE:
# → Há uma TENDÊNCIA de aumento ao longo do tempo?
# → Há picos que se repetem todo ano (SAZONALIDADE)?
# → Há variações "irregulares" (RUÍDO)?


# -----------------------------------------------------------------------------
# CONVERTER PARA OBJETO DE SÉRIE TEMPORAL
# -----------------------------------------------------------------------------

# O R tem um formato especial para séries temporais: ts()
#
# ts(dados, frequency = ciclos_por_período, start = início)
#
# frequency = 52 porque temos dados SEMANAIS (52 semanas por ano)
# start = c(2021, 1) significa: começa no ano 2021, semana 1

serie_ts <- ts(serie_gripal$casos, frequency = 52, start = c(2021, 1))

# Ver a série:
print(serie_ts)


# -----------------------------------------------------------------------------
# DECOMPOSIÇÃO DA SÉRIE
# -----------------------------------------------------------------------------

# Podemos "separar" a série em seus componentes:
decomposicao <- decompose(serie_ts)

# Visualizar a decomposição:
plot(decomposicao)

# O GRÁFICO MOSTRA:
#
# 1. observed: Os dados originais (o que observamos)
# 2. trend: A TENDÊNCIA extraída (direção geral)
# 3. seasonal: O padrão SAZONAL (o que se repete todo ano)
# 4. random: O RUÍDO (o que sobra depois de remover tendência e sazonalidade)


# -----------------------------------------------------------------------------
# MODELO ARIMA E PREVISÃO
# -----------------------------------------------------------------------------

# ARIMA é um modelo muito usado para séries temporais.
# Não precisamos entender os detalhes matemáticos aqui.
#
# auto.arima() escolhe automaticamente o melhor modelo ARIMA

modelo_arima <- auto.arima(serie_ts)

# Ver o modelo escolhido:
print(modelo_arima)

# A notação ARIMA(p,d,q) descreve o modelo, mas não precisa decorar!


# -----------------------------------------------------------------------------
# FAZER PREVISÃO
# -----------------------------------------------------------------------------

# forecast() prevê os próximos valores
# h = 12 significa: prever as próximas 12 semanas

previsao <- forecast(modelo_arima, h = 12)

# Visualizar a previsão:
plot(previsao, 
     main = "Previsão de Casos para as Próximas 12 Semanas",
     xlab = "Tempo", 
     ylab = "Casos")

# O GRÁFICO MOSTRA:
# - Linha azul escura: valores observados
# - Linha azul clara: previsão
# - Áreas sombreadas: intervalos de confiança (80% e 95%)
#   → Quanto mais para o futuro, maior a incerteza


# #############################################################################
#
# ATIVIDADE 3: ANÁLISE DE SOBREVIVÊNCIA
#
# #############################################################################
#
# O QUE É ANÁLISE DE SOBREVIVÊNCIA?
# ---------------------------------
# Estuda o TEMPO até a ocorrência de um EVENTO.
#
# Exemplos de "evento":
# - Óbito
# - Recidiva de câncer
# - Alta hospitalar
# - Reinternação
#
# O QUE É CENSURA?
# ----------------
# Nem todos os participantes apresentam o evento durante o estudo.
# Alguns podem:
# - Sair do estudo antes do fim
# - Chegar ao fim do estudo sem ter o evento
# - Ser perdidos no acompanhamento
#
# Esses casos são "CENSURADOS" - sabemos que o tempo foi PELO MENOS X,
# mas não sabemos exatamente quando (ou se) o evento ocorreria.
#
# MÉTODOS PRINCIPAIS:
# -------------------
# - Kaplan-Meier: Estima a curva de sobrevivência
# - Log-Rank: Compara curvas entre grupos
# - Cox: Identifica fatores de risco
#
# =============================================================================


# -----------------------------------------------------------------------------
# DADOS: Sobrevida de Pacientes com Câncer
# -----------------------------------------------------------------------------

set.seed(456)
n_pac <- 150   # 150 pacientes

# Criar dados simulados:
dados_sobrevida <- tibble(
  id = 1:n_pac,
  # Tratamento: Quimioterapia ou Imunoterapia
  tratamento = sample(c("Quimio", "Imuno"), n_pac, replace = TRUE),
  # Idade: entre 35 e 85 anos
  idade = round(pmin(pmax(rnorm(n_pac, 60, 12), 35), 85)),
  # Estadio do câncer: II, III ou IV
  estadio = sample(c("II", "III", "IV"), n_pac, replace = TRUE, 
                   prob = c(0.3, 0.4, 0.3))
) %>%
  mutate(
    # Calcular uma "taxa de risco" baseada nas características
    # Menor taxa = melhor prognóstico
    taxa = case_when(
      tratamento == "Imuno" ~ 0.015,   # Imunoterapia: menor taxa (melhor)
      TRUE ~ 0.025                      # Quimio: maior taxa
    ) * case_when(
      estadio == "II" ~ 0.5,           # Estadio II: menor risco
      estadio == "III" ~ 1,            # Estadio III: risco médio
      TRUE ~ 1.8                        # Estadio IV: maior risco
    ),
    # Tempo até o evento (simulado com distribuição exponencial)
    tempo_evento = rexp(n_pac, rate = taxa),
    # Tempo de acompanhamento máximo (quando o estudo termina)
    tempo_censura = 60,  # 60 meses = 5 anos
    # Tempo observado: o menor entre tempo do evento e tempo de censura
    tempo = pmin(tempo_evento, tempo_censura),
    # Status: 1 se teve evento, 0 se foi censurado
    status = as.integer(tempo_evento <= tempo_censura)
  )


# Ver os primeiros dados:
head(dados_sobrevida, 10)

# ENTENDENDO AS COLUNAS:
# - tempo: tempo de acompanhamento em meses
# - status: 1 = teve o evento (óbito), 0 = censurado (não teve evento até o fim)


# Quantos tiveram evento e quantos foram censurados?
table(dados_sobrevida$status)

# 0 = censurados (ainda vivos ao final do estudo)
# 1 = tiveram o evento (óbito)


# -----------------------------------------------------------------------------
# CRIAR OBJETO DE SOBREVIVÊNCIA
# -----------------------------------------------------------------------------

# Surv() cria um objeto especial que o R reconhece como dados de sobrevivência
# Ele combina o TEMPO e o STATUS (evento ou censura)

surv_obj <- Surv(time = dados_sobrevida$tempo, 
                 event = dados_sobrevida$status)

# Ver o objeto:
head(surv_obj, 20)

# Os números com "+" são CENSURADOS
# Ex: "60+" significa: acompanhado por 60 meses, sem evento


# -----------------------------------------------------------------------------
# CURVA DE KAPLAN-MEIER (Geral)
# -----------------------------------------------------------------------------

# survfit() ajusta a curva de Kaplan-Meier
# ~ 1 significa: uma curva para todos (sem separar por grupos)

km_geral <- survfit(surv_obj ~ 1)

# Resumo:
print(km_geral)

# COMO LER:
# - n: número de pacientes
# - events: número de eventos
# - median: tempo mediano de sobrevida (50% ainda vivos)
# - 0.95LCL e 0.95UCL: IC 95% para a mediana


# Plotar a curva:
plot(km_geral, 
     main = "Curva de Sobrevida (Kaplan-Meier)",
     xlab = "Tempo (meses)",
     ylab = "Probabilidade de Sobrevida",
     col = "steelblue", 
     lwd = 2)           # lwd = espessura da linha

# COMO INTERPRETAR O GRÁFICO:
# - Eixo X: Tempo (em meses)
# - Eixo Y: Probabilidade de estar vivo
# - A curva começa em 1 (100%) e vai descendo
# - Cada "degrau" é um evento (óbito)
# - As linhas verticais tracejadas são os censurados
# - Quanto mais ALTA a curva, melhor a sobrevida


# -----------------------------------------------------------------------------
# COMPARAÇÃO ENTRE TRATAMENTOS
# -----------------------------------------------------------------------------

# Agora vamos comparar a sobrevida entre Quimio e Imunoterapia

# Kaplan-Meier por tratamento:
km_trat <- survfit(surv_obj ~ tratamento, data = dados_sobrevida)

# Resumo por grupo:
print(km_trat)


# Plotar as duas curvas:
plot(km_trat,
     main = "Sobrevida por Tratamento",
     xlab = "Tempo (meses)",
     ylab = "Probabilidade de Sobrevida",
     col = c("coral", "steelblue"),   # Cores para cada grupo
     lwd = 2)

# Adicionar legenda:
legend("bottomleft", 
       legend = c("Imuno", "Quimio"),
       col = c("coral", "steelblue"), 
       lwd = 2)

# OBSERVE:
# → Qual curva está MAIS ALTA? (melhor sobrevida)
# → As curvas são muito diferentes ou quase iguais?


# -----------------------------------------------------------------------------
# TESTE LOG-RANK
# -----------------------------------------------------------------------------

# O teste Log-Rank verifica se há diferença ESTATISTICAMENTE SIGNIFICATIVA
# entre as curvas de sobrevivência dos grupos

survdiff(surv_obj ~ tratamento, data = dados_sobrevida)

# COMO LER:
# - N: número em cada grupo
# - Observed: eventos observados
# - Expected: eventos esperados (se não houvesse diferença)
# - Chisq: estatística qui-quadrado
# - p: p-valor
#
# Se p < 0.05 → Há diferença significativa entre os tratamentos


# -----------------------------------------------------------------------------
# MODELO DE COX
# -----------------------------------------------------------------------------

# O modelo de Cox identifica FATORES DE RISCO para o evento
# É como uma regressão, mas para dados de sobrevivência
#
# Medida de efeito: HR (Hazard Ratio / Razão de Risco)
#   HR = 1: Sem efeito
#   HR > 1: Fator de RISCO (aumenta o risco do evento)
#   HR < 1: Fator de PROTEÇÃO (diminui o risco do evento)

modelo_cox <- coxph(surv_obj ~ tratamento + idade + estadio, 
                    data = dados_sobrevida)

summary(modelo_cox)

# COMO LER O RESULTADO:
#
# coef: coeficiente (na escala logarítmica)
# exp(coef): HR (Hazard Ratio) - É O MAIS IMPORTANTE!
# se(coef): erro padrão
# Pr(>|z|): p-valor
#
# lower .95 e upper .95: IC 95% para o HR


# Ver só os Hazard Ratios:
exp(coef(modelo_cox))

# INTERPRETAÇÃO DOS HRs:
#
# tratamentoQuimio: HR > 1
# → Quimio tem MAIOR risco que Imuno (categoria de referência)
# → Ex: HR = 1.5 significa 50% mais risco
#
# idade: HR por ano
# → Ex: HR = 1.02 significa 2% mais risco para cada ano de idade
#
# estadioIII e estadioIV: comparados com estadio II (referência)
# → HR > 1 significa maior risco que estadio II


# =============================================================================
# RESUMO: QUANDO USAR CADA MÉTODO
# =============================================================================
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ TIPO DE DADOS                    │ MÉTODO                              │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ DADOS HIERÁRQUICOS               │ lmer() - Modelo Multinível          │
# │ (grupos dentro de grupos)        │ Pacote: lme4                        │
# │ Ex: pacientes em hospitais       │                                     │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ DADOS TEMPORAIS                  │ ts() + auto.arima() + forecast()    │
# │ (medidas ao longo do tempo)      │ Pacote: forecast                    │
# │ Ex: casos semanais de dengue     │                                     │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ TEMPO ATÉ EVENTO                 │ survfit() - Kaplan-Meier            │
# │ (com censura)                    │ survdiff() - Teste Log-Rank         │
# │ Ex: tempo até óbito              │ coxph() - Modelo de Cox             │
# │                                  │ Pacote: survival                    │
# │                                  │ Medida: HR (Hazard Ratio)           │
# └─────────────────────────────────────────────────────────────────────────┘
#
# =============================================================================
