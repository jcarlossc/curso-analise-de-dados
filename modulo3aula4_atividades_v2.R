# =============================================================================
# MÓDULO 3 - AULA 4: Aplicação dos Modelos Estatísticos
# Atividades Complementares
# Curso: Introdução à Análise de Dados para Pesquisa no SUS
# =============================================================================
#
# OBJETIVO DESTA AULA:
# Aplicar os modelos estudados nas aulas anteriores em situações práticas
# de saúde pública, integrando os conceitos e praticando a interpretação.
#
# CASOS PRÁTICOS:
#   Caso 1: Fatores de risco para COVID-19 grave (Regressão Logística)
#   Caso 2: Comparação de tratamentos (ANOVA)
#   Caso 3: Sobrevida em oncologia (Kaplan-Meier + Cox)
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
# install.packages("broom")
# install.packages("survival")

# Carregar os pacotes
library(tidyverse)
library(broom)       # Para extrair resultados em formato "arrumado"
library(survival)    # Para análise de sobrevivência


# #############################################################################
#
# CASO 1: FATORES DE RISCO PARA COVID-19 GRAVE
#
# #############################################################################
#
# CONTEXTO:
# ---------
# Você é analista de dados em uma secretaria de saúde.
# Precisa identificar quais características dos pacientes estão associadas
# a casos GRAVES de COVID-19, para orientar políticas de saúde.
#
# PERGUNTA DE PESQUISA:
# "Quais fatores aumentam a chance de um paciente ter COVID-19 grave?"
#
# TIPO DE DESFECHO:
# Binário (grave vs não grave) → Regressão Logística
#
# =============================================================================


# -----------------------------------------------------------------------------
# DADOS: Pacientes com COVID-19
# -----------------------------------------------------------------------------

set.seed(2020)      # Ano da pandemia como semente!
n_covid <- 500      # 500 pacientes

# Criar dados simulados de pacientes com COVID-19:
dados_covid <- tibble(
  id = 1:n_covid,
  
  # Idade: entre 18 e 95 anos, média de 50
  idade = round(pmin(pmax(rnorm(n_covid, 50, 18), 18), 95)),
  
  # Sexo: distribuição igual
  sexo = sample(c("Feminino", "Masculino"), n_covid, replace = TRUE),
  
  # Comorbidades (com prevalências realistas):
  diabetes = sample(c("Não", "Sim"), n_covid, replace = TRUE, prob = c(0.85, 0.15)),
  hipertensao = sample(c("Não", "Sim"), n_covid, replace = TRUE, prob = c(0.70, 0.30)),
  obesidade = sample(c("Não", "Sim"), n_covid, replace = TRUE, prob = c(0.75, 0.25))
  
) %>%
  mutate(
    # Calcular probabilidade de caso grave baseada nos fatores de risco:
    # (esses coeficientes são fictícios, mas plausíveis)
    prob_grave = plogis(
      -3 +                                    # Intercepto
      0.04 * idade +                          # Idade aumenta risco
      0.3 * (sexo == "Masculino") +           # Homens: maior risco
      0.8 * (diabetes == "Sim") +             # Diabetes: maior risco
      0.5 * (hipertensao == "Sim") +          # Hipertensão: maior risco
      0.6 * (obesidade == "Sim")              # Obesidade: maior risco
    ),
    # Gerar o desfecho (0 = não grave, 1 = grave) baseado na probabilidade:
    caso_grave = rbinom(n_covid, 1, prob_grave)
  )


# Ver as primeiras linhas:
head(dados_covid)


# -----------------------------------------------------------------------------
# ANÁLISE DESCRITIVA
# -----------------------------------------------------------------------------

# Quantos casos graves e não graves?
table(dados_covid$caso_grave)

# Em porcentagem:
prop.table(table(dados_covid$caso_grave)) * 100


# Comparar características entre casos graves e não graves:
dados_covid %>%
  group_by(caso_grave) %>%
  summarise(
    n = n(),                                           # Número de pacientes
    idade_media = round(mean(idade), 1),               # Média de idade
    prop_masculino = round(mean(sexo == "Masculino") * 100, 1),    # % homens
    prop_diabetes = round(mean(diabetes == "Sim") * 100, 1),       # % diabéticos
    prop_hipertensao = round(mean(hipertensao == "Sim") * 100, 1), # % hipertensos
    prop_obesidade = round(mean(obesidade == "Sim") * 100, 1)      # % obesos
  )

# OBSERVE:
# → Os casos graves (1) têm mais idade em média?
# → Há maior proporção de comorbidades nos casos graves?


# -----------------------------------------------------------------------------
# MODELO DE REGRESSÃO LOGÍSTICA
# -----------------------------------------------------------------------------

# Ajustar modelo logístico para identificar fatores de risco:

modelo_covid <- glm(
  caso_grave ~ idade + sexo + diabetes + hipertensao + obesidade,
  data = dados_covid,
  family = binomial    # Indica que Y é binária
)

# Ver o resumo:
summary(modelo_covid)



# -----------------------------------------------------------------------------
# EXTRAIR OR (ODDS RATIOS) COM IC 95%
# -----------------------------------------------------------------------------

# tidy() transforma os resultados em uma tabela organizada
# exponentiate = TRUE converte os coeficientes em OR

resultados_or <- tidy(modelo_covid, conf.int = TRUE, exponentiate = TRUE)
print(resultados_or)

# COMO INTERPRETAR:
#
# term = variável
# estimate = OR (Odds Ratio / Razão de Chances)
# conf.low e conf.high = IC 95% para o OR
# p.value = p-valor (significativo se < 0.05)
#
# EXEMPLOS DE INTERPRETAÇÃO:
#
# idade (OR ≈ 1.04):
# → Para cada ano a mais de idade, a chance de caso grave aumenta ~4%
# → Para 10 anos a mais: (1.04)^10 ≈ 1.48 → 48% mais chance
#
# sexoMasculino (OR ≈ 1.35):
# → Homens têm ~35% mais chance de caso grave que mulheres
#
# diabetesSim (OR ≈ 2.2):
# → Diabéticos têm ~2.2 vezes mais chance de caso grave
# → Ou seja, ~120% mais chance que não diabéticos
#
# IC 95%:
# → Se o IC NÃO inclui 1, o fator é estatisticamente significativo
# → Se o IC inclui 1, não podemos afirmar que há associação


# -----------------------------------------------------------------------------
# VISUALIZAÇÃO: FOREST PLOT
# -----------------------------------------------------------------------------

# O Forest Plot é uma forma visual de mostrar os ORs e seus ICs

# Preparar dados para o gráfico:
dados_forest <- resultados_or %>%
  filter(term != "(Intercept)") %>%    # Remover o intercepto
  mutate(
    # Criar nomes mais amigáveis para as variáveis:
    variavel = case_when(
      term == "idade" ~ "Idade (por ano)",
      term == "sexoMasculino" ~ "Sexo Masculino",
      term == "diabetesSim" ~ "Diabetes",
      term == "hipertensaoSim" ~ "Hipertensão",
      term == "obesidadeSim" ~ "Obesidade"
    )
  )

# Criar o Forest Plot:
ggplot(dados_forest, aes(x = estimate, y = reorder(variavel, estimate))) +
  # Linha vertical em OR = 1 (sem efeito):
  geom_vline(xintercept = 1, linetype = "dashed", color = "gray50") +
  # Barras de erro (IC 95%):
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), height = 0.2) +
  # Pontos (OR):
  geom_point(size = 3, color = "steelblue") +
  # Títulos:
  labs(title = "Fatores Associados a COVID-19 Grave",
       subtitle = "Razões de Chances (OR) com IC 95%",
       x = "OR (Odds Ratio)", 
       y = "") +
  theme_minimal()

# COMO LER O FOREST PLOT:
#
# - Linha tracejada vertical = OR = 1 (sem efeito)
# - Pontos à DIREITA da linha = fatores de RISCO (OR > 1)
# - Pontos à ESQUERDA da linha = fatores de PROTEÇÃO (OR < 1)
# - Barras horizontais = IC 95%
# - Se a barra CRUZA a linha vertical → NÃO é significativo
# - Se a barra NÃO cruza → É significativo


# -----------------------------------------------------------------------------
# CONCLUSÃO PARA GESTORES
# -----------------------------------------------------------------------------

# Com base nos resultados, você poderia recomendar:
#
# "Os principais fatores de risco para COVID-19 grave são:
#  - Idade avançada
#  - Presença de diabetes
#  - Hipertensão
#  - Obesidade
#  - Sexo masculino
#
#  Recomendamos priorizar a vacinação e o monitoramento de pacientes
#  idosos e com essas comorbidades."


# #############################################################################
#
# CASO 2: COMPARAÇÃO DE TRATAMENTOS (ENSAIO CLÍNICO)
#
# #############################################################################
#
# CONTEXTO:
# ---------
# Um ensaio clínico testou 3 grupos:
# - Placebo (grupo controle)
# - Droga A (novo medicamento)
# - Droga B (outro novo medicamento)
#
# O desfecho é a REDUÇÃO da pressão arterial após 8 semanas.
#
# PERGUNTA DE PESQUISA:
# "Algum dos tratamentos é mais eficaz que o placebo para reduzir a PA?"
#
# TIPO DE DESFECHO:
# Contínuo (redução da PA) + 3 grupos → ANOVA
#
# =============================================================================


# -----------------------------------------------------------------------------
# DADOS: Ensaio Clínico
# -----------------------------------------------------------------------------

set.seed(123)
n_por_grupo <- 50   # 50 pacientes em cada grupo

# Criar dados simulados:
dados_trat <- tibble(
  # Tratamento: 50 de cada
  tratamento = factor(
    rep(c("Placebo", "Droga A", "Droga B"), each = n_por_grupo),
    levels = c("Placebo", "Droga A", "Droga B")  # Define ordem das categorias
  ),
  # PA basal (antes do tratamento):
  pa_basal = round(rnorm(n_por_grupo * 3, 150, 10))
) %>%
  mutate(
    # Redução da PA após 8 semanas (valores simulados):
    reducao = case_when(
      tratamento == "Placebo" ~ rnorm(n(), mean = 2, sd = 5),   # Placebo: pouca redução
      tratamento == "Droga A" ~ rnorm(n(), mean = 15, sd = 6),  # Droga A: boa redução
      tratamento == "Droga B" ~ rnorm(n(), mean = 20, sd = 7)   # Droga B: melhor redução
    )
  )

# Ver as primeiras linhas:
head(dados_trat)

# Quantos em cada grupo:
table(dados_trat$tratamento)


# -----------------------------------------------------------------------------
# ANÁLISE DESCRITIVA POR GRUPO
# -----------------------------------------------------------------------------

dados_trat %>%
  group_by(tratamento) %>%
  summarise(
    n = n(),                              # Número de pacientes
    media = round(mean(reducao), 1),      # Média de redução
    dp = round(sd(reducao), 1),           # Desvio-padrão
    minimo = round(min(reducao), 1),      # Valor mínimo
    maximo = round(max(reducao), 1)       # Valor máximo
  )

# OBSERVE:
# → Qual tratamento tem a maior média de redução?
# → As diferenças parecem grandes?


# -----------------------------------------------------------------------------
# VISUALIZAÇÃO: BOXPLOT
# -----------------------------------------------------------------------------

ggplot(dados_trat, aes(x = tratamento, y = reducao, fill = tratamento)) +
  # Boxplot:
  geom_boxplot(alpha = 0.7) +
  # Pontos individuais (para ver a distribuição):
  geom_jitter(width = 0.2, alpha = 0.4) +
  # Linha horizontal em y = 0 (sem redução):
  geom_hline(yintercept = 0, linetype = "dashed") +
  # Cores:
  scale_fill_brewer(palette = "Set2") +
  # Títulos:
  labs(title = "Redução da PA por Tratamento",
       subtitle = "Após 8 semanas de tratamento",
       x = "", 
       y = "Redução da PA (mmHg)") +
  theme_minimal() +
  theme(legend.position = "none")   # Remover legenda (redundante)

# COMO LER O BOXPLOT:
# - Linha horizontal dentro da caixa = MEDIANA
# - Caixa = 50% dos dados (do 1º ao 3º quartil)
# - Linhas verticais (bigodes) = extensão até 1.5 x IQR
# - Pontos fora = valores atípicos
# - Pontos coloridos = dados individuais


# -----------------------------------------------------------------------------
# ANOVA (Análise de Variância)
# -----------------------------------------------------------------------------

# A ANOVA testa se PELO MENOS um dos grupos tem média diferente dos outros
#
# H0: μ_placebo = μ_drogaA = μ_drogaB (todas as médias são iguais)
# H1: Pelo menos uma média é diferente

modelo_anova <- aov(reducao ~ tratamento, data = dados_trat)

# Ver o resultado:
summary(modelo_anova)

# COMO LER:
#
# Df = graus de liberdade
# Sum Sq = soma dos quadrados
# Mean Sq = média dos quadrados
# F value = estatística F (quanto maior, mais evidência de diferença)
# Pr(>F) = p-valor
#
# Se Pr(>F) < 0.05:
# → Rejeitamos H0
# → Há diferença significativa entre PELO MENOS dois grupos
# → MAS não sabemos QUAIS grupos diferem! Para isso, usamos Tukey.


# -----------------------------------------------------------------------------
# TESTE DE TUKEY (Comparações Múltiplas)
# -----------------------------------------------------------------------------

# O teste de Tukey compara TODOS os pares de grupos

TukeyHSD(modelo_anova)

# COMO LER:
#
# diff = diferença entre as médias dos dois grupos
# lwr = limite inferior do IC 95% para a diferença
# upr = limite superior do IC 95% para a diferença
# p adj = p-valor AJUSTADO para múltiplas comparações
#
# Se p adj < 0.05 → Esses dois grupos diferem significativamente
#
# EXEMPLO:
# Droga A - Placebo: diff = 13, p adj < 0.001
# → Droga A reduz em média 13 mmHg A MAIS que o placebo
# → Diferença SIGNIFICATIVA
#
# Droga B - Droga A: diff = 5, p adj = ?
# → Se p < 0.05: Droga B é melhor que Droga A
# → Se p >= 0.05: Não há evidência de diferença entre as drogas

# -----------------------------------------------------------------------------
# ALTERNATIVA: ANOVA usando lm()
# -----------------------------------------------------------------------------

# Também é possível fazer a ANOVA usando a função lm() (modelo linear).
# O resultado é equivalente, mas o summary() mostra informações adicionais.

mod_lm <- lm(reducao ~ tratamento, data = dados_trat)
summary(mod_lm)

# COMO LER:
#
# (Intercept) = média do grupo de referência (Placebo)
# tratamentoDroga A = diferença entre Droga A e Placebo
# tratamentoDroga B = diferença entre Droga B e Placebo
#
# O p-valor de cada coeficiente testa se aquele grupo difere do Placebo.
# O F-statistic no final é o mesmo da ANOVA.


# -----------------------------------------------------------------------------
# CONCLUSÃO PARA O ESTUDO
# -----------------------------------------------------------------------------

# Com base nos resultados, você poderia concluir:
#
# "Ambas as drogas são significativamente mais eficazes que o placebo
#  na redução da pressão arterial.
#
#  A Droga B apresentou a maior redução média (cerca de 20 mmHg),
#  seguida pela Droga A (cerca de 15 mmHg).
#
#  Recomendamos avaliar também custo, efeitos colaterais e facilidade
#  de administração para a decisão final."


# #############################################################################
#
# CASO 3: SOBREVIDA EM PACIENTES ONCOLÓGICOS
#
# #############################################################################
#
# CONTEXTO:
# ---------
# Um hospital oncológico quer comparar a sobrevida de pacientes
# tratados com quimioterapia convencional vs imunoterapia.
#
# PERGUNTA DE PESQUISA:
# "Há diferença na sobrevida entre os dois tratamentos?"
# "Quais fatores afetam a sobrevida?"
#
# TIPO DE DESFECHO:
# Tempo até evento (com censura) → Análise de Sobrevivência
#
# =============================================================================


# -----------------------------------------------------------------------------
# DADOS: Pacientes Oncológicos
# -----------------------------------------------------------------------------

set.seed(789)
n_onco <- 150   # 150 pacientes

# Criar dados simulados:
dados_onco <- tibble(
  id = 1:n_onco,
  # Tratamento:
  tratamento = sample(c("Quimio", "Imuno"), n_onco, replace = TRUE),
  # Idade: entre 40 e 80 anos
  idade = round(pmin(pmax(rnorm(n_onco, 60, 10), 40), 80)),
  # Estadio do câncer:
  estadio = sample(c("II", "III", "IV"), n_onco, replace = TRUE, prob = c(0.3, 0.4, 0.3))
) %>%
  mutate(
    # Taxa de risco (menor = melhor prognóstico):
    taxa = ifelse(tratamento == "Imuno", 0.02, 0.03) *   # Imuno melhor que Quimio
           case_when(
             estadio == "II" ~ 0.6,    # Estadio II: menor risco
             estadio == "III" ~ 1,     # Estadio III: risco médio
             TRUE ~ 1.5                 # Estadio IV: maior risco
           ),
    # Tempo até evento (simulado):
    tempo_evento = rexp(n_onco, rate = taxa),
    # Tempo de censura (variável - alguns saem antes):
    tempo_censura = runif(n_onco, 24, 60),
    # Tempo observado:
    tempo = pmin(tempo_evento, tempo_censura),
    # Status: 1 = evento, 0 = censurado
    status = as.integer(tempo_evento <= tempo_censura)
  )


# Ver os dados:
head(dados_onco)

# Quantos eventos e censuras:
table(dados_onco$status)

# Distribuição por tratamento:
table(dados_onco$tratamento, dados_onco$status)


# -----------------------------------------------------------------------------
# CRIAR OBJETO DE SOBREVIVÊNCIA
# -----------------------------------------------------------------------------

surv_onco <- Surv(time = dados_onco$tempo, event = dados_onco$status)


# -----------------------------------------------------------------------------
# CURVAS DE KAPLAN-MEIER POR TRATAMENTO
# -----------------------------------------------------------------------------

km_onco <- survfit(surv_onco ~ tratamento, data = dados_onco)

# Resumo:
print(km_onco)


# Plotar as curvas:
plot(km_onco,
     main = "Sobrevida por Tratamento",
     xlab = "Tempo (meses)",
     ylab = "Probabilidade de Sobrevida",
     col = c("coral", "steelblue"),
     lwd = 2)

# Adicionar legenda:
legend("bottomleft", 
       legend = c("Imuno", "Quimio"),
       col = c("coral", "steelblue"), 
       lwd = 2)

# OBSERVE:
# → Qual curva está MAIS ALTA? (melhor sobrevida)
# → As curvas se separam ao longo do tempo?


# -----------------------------------------------------------------------------
# TESTE LOG-RANK
# -----------------------------------------------------------------------------

# Testa se há diferença significativa entre as curvas

survdiff(surv_onco ~ tratamento, data = dados_onco)

# Se p < 0.05 → Há diferença significativa entre os tratamentos


# -----------------------------------------------------------------------------
# MODELO DE COX
# -----------------------------------------------------------------------------

# O modelo de Cox identifica fatores que afetam a sobrevida

modelo_cox <- coxph(surv_onco ~ tratamento + idade + estadio, data = dados_onco)

# Resumo:
summary(modelo_cox)

# -----------------------------------------------------------------------------
# VERIFICAÇÃO DO PRESSUPOSTO DE PROPORCIONALIDADE
# -----------------------------------------------------------------------------

# O modelo de Cox assume que os Hazard Ratios são CONSTANTES ao longo do tempo.
# Isso é chamado de "pressuposto de riscos proporcionais".
# Devemos testar se esse pressuposto é atendido.

# Teste estatístico de proporcionalidade:
test_ph <- cox.zph(modelo_cox)
test_ph

# COMO LER:
#
# Se p > 0.05 para uma variável → Pressuposto atendido para essa variável
# Se p < 0.05 → O efeito dessa variável pode variar ao longo do tempo
#               (violação do pressuposto)
#
# GLOBAL: testa o modelo como um todo


# Checagem visual do pressuposto:
plot(test_ph)

# COMO INTERPRETAR O GRÁFICO:
#
# → Se a linha for aproximadamente HORIZONTAL, o pressuposto é atendido
# → Se a linha tiver inclinação clara, o efeito da variável muda com o tempo
# → A linha tracejada mostra o intervalo de confiança


# Ver apenas os Hazard Ratios (HR):
exp(coef(modelo_cox))

# INTERPRETAÇÃO DOS HRs:
#
# tratamentoQuimio: HR > 1
# → Quimio tem MAIOR risco de evento que Imuno (referência)
# → Ex: HR = 1.5 significa 50% mais risco de óbito
#
# idade: HR por ano
# → Ex: HR = 1.02 significa 2% mais risco para cada ano a mais
#
# estadioIII e estadioIV: comparados com estadio II
# → HR > 1 significa pior prognóstico


# -----------------------------------------------------------------------------
# CONCLUSÃO PARA O HOSPITAL
# -----------------------------------------------------------------------------

# Com base nos resultados, você poderia concluir:
#
# "A imunoterapia apresentou melhor sobrevida que a quimioterapia
#  convencional nesta amostra de pacientes.
#
#  Outros fatores que afetam negativamente a sobrevida incluem:
#  - Idade mais avançada
#  - Estadio mais avançado do câncer (especialmente estadio IV)
#
#  Recomendamos considerar a imunoterapia como opção de tratamento,
#  especialmente para pacientes em estadios mais avançados."
# =============================================================================
