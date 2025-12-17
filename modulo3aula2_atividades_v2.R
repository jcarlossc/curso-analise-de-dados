# =============================================================================
# MÓDULO 3 - AULA 2: Modelos de Regressão
# Atividades Complementares
# Curso: Introdução à Análise de Dados para Pesquisa no SUS
# =============================================================================
#
# ATENÇÃO: Este módulo é mais avançado que os anteriores!
# Execute o código linha por linha e leia os comentários com atenção.
# Em caso de dúvidas, consulte o gabarito. 
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

# Carregar os pacotes
library(tidyverse)
library(broom)       # Para extrair resultados de modelos em formato "arrumado"


# =============================================================================
# ATIVIDADE 1: Correlação Linear
# =============================================================================
#
# O QUE É CORRELAÇÃO?
# -------------------
# A correlação mede a FORÇA e a DIREÇÃO da relação LINEAR entre duas
# variáveis numéricas.
#
# O coeficiente de correlação de Pearson (r) varia de -1 a +1:
#
#   r = +1  → Correlação positiva PERFEITA (quando X sobe, Y sobe)
#   r = -1  → Correlação negativa PERFEITA (quando X sobe, Y desce)
#   r = 0   → SEM correlação linear
#
# CLASSIFICAÇÃO DA FORÇA:
#   |r| < 0.3     → Correlação FRACA
#   0.3 ≤ |r| < 0.7 → Correlação MODERADA
#   |r| ≥ 0.7    → Correlação FORTE
#
# CUIDADO IMPORTANTE:
# Correlação NÃO significa causalidade!
# Exemplo: O consumo de sorvete está correlacionado com afogamentos.
# Isso não significa que sorvete causa afogamentos! (Ambos aumentam no verão)
#
# =============================================================================


# -----------------------------------------------------------------------------
# DADOS: Pressão Arterial e Idade
# -----------------------------------------------------------------------------

# Fixar semente para reprodutibilidade
# Seus resultados serão iguais aos do gabarito 
# Obs: Na aula 1 do módulo 3 você encontrará mais detalhes da função set.seed())
set.seed(42)

# Número de pessoas na amostra
n <- 30

# Criar dados simulados de PA e idade
pasis <- tibble(
  idade = round(runif(n, min = 25, max = 75)),   # Idades entre 25 e 75 anos
  pa = round(100 + 0.8 * idade + rnorm(n, 0, 10)), # PA relacionada com idade
  sexo = if_else(runif(n) >= 0.5, "Feminino", "Masculino")  # Sexo aleatório
)

# O que fizemos:
# - runif(n, min, max): gera n números aleatórios entre min e max
# - round(): arredonda para número inteiro
# - rnorm(n, 0, 10): adiciona "ruído" (variação aleatória) com média 0 e DP 10
# - A PA foi criada como: 100 + 0.8*idade + ruído
#   (ou seja, há uma relação real entre idade e PA nos nossos dados simulados)


# Visualizar os dados:
print(pasis)

# Veja que temos 30 pessoas com idade, PA e sexo


# -----------------------------------------------------------------------------
# CÁLCULO DA CORRELAÇÃO
# -----------------------------------------------------------------------------

# cor.test() calcula a correlação E testa se ela é significativa

cor.test(pasis$pa, pasis$idade)

# COMO LER O RESULTADO:
#
# t = estatística t do teste
# df = graus de liberdade
# p-value = probabilidade de observar essa correlação se não houvesse relação
#           Se p < 0.05 → correlação significativa
#
# cor = coeficiente de correlação (r)
#       Este é o número mais importante!
#       Veja se é positivo/negativo e quão forte é (veja classificação acima)
#
# 95 percent confidence interval = IC para o coeficiente de correlação


# Também podemos calcular só o coeficiente (sem o teste):
cor(pasis$pa, pasis$idade)


# -----------------------------------------------------------------------------
# VISUALIZAÇÃO: Gráfico de Dispersão
# -----------------------------------------------------------------------------

# O gráfico de dispersão mostra a relação entre duas variáveis numéricas:
# - Cada ponto é uma pessoa
# - Eixo X = idade
# - Eixo Y = PA

ggplot(pasis, aes(x = idade, y = pa)) +          # Definir dados e eixos
  geom_point(size = 3, color = "darkblue", alpha = 0.7) +  # Adicionar pontos
  labs(title = "Relação entre Idade e Pressão Arterial",   # Título
       x = "Idade (anos)",                                  # Rótulo eixo X
       y = "PA Sistólica (mmHg)") +                        # Rótulo eixo Y
  theme_bw()                                               # Tema visual

# OBSERVE:
# → Os pontos formam uma "nuvem" que sobe da esquerda para a direita?
# → Isso indica correlação POSITIVA (maior idade → maior PA)
# → Quanto mais "apertada" a nuvem, mais forte a correlação


# =============================================================================
# ATIVIDADE 2: Regressão Linear Simples
# =============================================================================
#
# O QUE É REGRESSÃO LINEAR?
# -------------------------
# A regressão linear MODELA a relação entre variáveis através de uma RETA.
#
# Fórmula: Y = β0 + β1*X + ε
#
# Onde:
#   Y  = variável DEPENDENTE (o que queremos prever/explicar) - ex: PA
#   X  = variável INDEPENDENTE (o que usamos para prever) - ex: idade
#   β0 = INTERCEPTO (valor de Y quando X = 0)
#   β1 = INCLINAÇÃO (quanto Y muda para cada unidade de X)
#   ε  = erro (variação não explicada pelo modelo)
#
# DIFERENÇA ENTRE CORRELAÇÃO E REGRESSÃO:
# - Correlação: mede a FORÇA da relação
# - Regressão: QUANTIFICA a relação (quanto Y muda quando X aumenta 1 unidade)
#
# =============================================================================


# -----------------------------------------------------------------------------
# AJUSTAR O MODELO
# -----------------------------------------------------------------------------

# lm() = linear model (modelo linear)
# Fórmula: variável_dependente ~ variável_independente
# Lê-se: "pa EM FUNÇÃO DE idade" ou "pa EXPLICADA POR idade"

modelo_simples <- lm(pa ~ idade, data = pasis)

# O modelo foi ajustado e guardado no objeto 'modelo_simples'


# -----------------------------------------------------------------------------
# VER OS COEFICIENTES
# -----------------------------------------------------------------------------

# Ver apenas os coeficientes (β0 e β1):
modelo_simples

# COMO LER:
# (Intercept) = β0 = valor de PA quando idade = 0
#               (não faz sentido prático - ninguém tem 0 anos!)
# idade = β1 = para cada ANO a mais de idade, a PA aumenta β1 mmHg


# -----------------------------------------------------------------------------
# RESUMO COMPLETO DO MODELO
# -----------------------------------------------------------------------------

summary(modelo_simples)

# COMO LER O RESULTADO:
#
# Coefficients:
#              Estimate = valor estimado do coeficiente
#              Std. Error = erro padrão (incerteza do coeficiente)
#              t value = estatística t
#              Pr(>|t|) = p-valor
#                         Se p < 0.05 → coeficiente significativo
#                         Asteriscos indicam significância (*** muito significativo)
#
# Multiple R-squared = R² = proporção da variação de Y explicada por X
#                      R² = 0.50 significa que X explica 50% da variação de Y
#                      Quanto mais próximo de 1, melhor o modelo
#
# F-statistic e p-value = teste se o modelo como um todo é significativo


# Ver só o R²:
summary(modelo_simples)$r.squared


# -----------------------------------------------------------------------------
# INTERPRETAÇÃO PRÁTICA
# -----------------------------------------------------------------------------

# Exemplo de como interpretar:
# Se β1 (coeficiente da idade) = 0.8
# Interpretação: "Para cada ano a mais de idade, a PA aumenta em média 0.8 mmHg"
#
# Se R² = 0.56
# Interpretação: "A idade explica 56% da variação na PA"


# -----------------------------------------------------------------------------
# VISUALIZAÇÃO: Reta de Regressão
# -----------------------------------------------------------------------------

ggplot(pasis, aes(x = idade, y = pa)) + 
  geom_point(size = 3, color = "darkblue", alpha = 0.7) +    # Pontos
  geom_smooth(method = "lm", se = TRUE, color = "red", linetype = "dashed") +  # Reta
  labs(title = "Regressão Linear: PA ~ Idade",
       x = "Idade (anos)", 
       y = "PA Sistólica (mmHg)") +
  theme_bw()

# O que significa cada elemento:
# - geom_smooth(method = "lm"): adiciona a reta de regressão
# - se = TRUE: mostra a faixa de incerteza (intervalo de confiança)
# - A reta vermelha é: PA = β0 + β1*idade

# OBSERVE:
# → A reta passa pelo "meio" da nuvem de pontos
# → A faixa cinza mostra a incerteza da estimativa


# =============================================================================
# ATIVIDADE 3: Regressão Linear Múltipla
# =============================================================================
#
# O QUE É REGRESSÃO MÚLTIPLA?
# ---------------------------
# É quando usamos MAIS DE UMA variável independente para explicar Y.
#
# Fórmula: Y = β0 + β1*X1 + β2*X2 + ... + ε
#
# POR QUE USAR?
# -------------
# Permite "controlar" ou "ajustar" o efeito de uma variável pelas outras.
#
# Exemplo: Queremos saber o efeito da idade na PA, MAS sabemos que o sexo
# também afeta a PA. A regressão múltipla nos dá o efeito da idade
# "ajustado por" ou "controlado por" sexo.
#
# =============================================================================


# -----------------------------------------------------------------------------
# MODELO COM DUAS VARIÁVEIS: idade + sexo
# -----------------------------------------------------------------------------

# O sinal + adiciona outra variável ao modelo
modelo_multiplo <- lm(pa ~ idade + sexo, data = pasis)

# Ver o resumo:
summary(modelo_multiplo)

# COMO LER:
#
# (Intercept) = PA estimada para idade=0 e sexo=Feminino (categoria de referência)
#
# idade = efeito da idade AJUSTADO por sexo
#         "Para cada ano a mais, PA aumenta β1 mmHg, mantendo sexo constante"
#
# sexoMasculino = diferença entre homens e mulheres AJUSTADA por idade
#                 "Homens têm PA β2 mmHg maior/menor que mulheres, na mesma idade"
#
# Note: O R mostra "sexoMasculino" porque "Feminino" é a categoria de referência


# -----------------------------------------------------------------------------
# VISUALIZAÇÃO: Retas por Sexo
# -----------------------------------------------------------------------------

ggplot(pasis, aes(x = idade, y = pa, color = sexo)) +
  geom_point(size = 3, alpha = 0.7) +                        # Pontos coloridos por sexo
  geom_smooth(method = "lm", se = FALSE, linewidth = 1) +    # Uma reta para cada sexo
  labs(title = "Regressão Múltipla: PA ~ Idade + Sexo",
       x = "Idade (anos)",
       y = "PA Sistólica (mmHg)") +
  theme_bw() +
  scale_color_manual(values = c("Feminino" = "coral", "Masculino" = "steelblue"))

# OBSERVE:
# → Temos DUAS retas paralelas (uma para cada sexo)
# → A distância vertical entre elas é o coeficiente do sexo
# → As retas são PARALELAS porque assumimos que o efeito da idade
#   é o MESMO para homens e mulheres


# -----------------------------------------------------------------------------
# MODELO COM INTERAÇÃO
# -----------------------------------------------------------------------------

# E se o efeito da idade for DIFERENTE para homens e mulheres?
# Usamos o operador * para incluir a INTERAÇÃO

modelo_interacao <- lm(pa ~ idade * sexo, data = pasis)
summary(modelo_interacao)

# O termo "idade:sexoMasculino" é a INTERAÇÃO
# Se for significativo → o efeito da idade difere entre os sexos
# (as retas não seriam mais paralelas)


# =============================================================================
# ATIVIDADE 4: Regressão Logística
# =============================================================================
#
# QUANDO USAR?
# ------------
# Quando a variável dependente (Y) é BINÁRIA (sim/não, 0/1).
#
# Exemplos:
# - Hipertenso ou não?
# - Óbito ou não?
# - Doente ou saudável?
#
# A regressão linear NÃO serve para Y binária porque:
# - Pode prever valores fora de 0 e 1
# - Não respeita a natureza da variável
#
# MEDIDA DE EFEITO: OR (Odds Ratio / Razão de Chances)
# ----------------------------------------------------
#   OR = 1  → Sem associação
#   OR > 1  → Fator de RISCO (aumenta a chance do evento)
#   OR < 1  → Fator de PROTEÇÃO (diminui a chance do evento)
#
# Exemplo: OR = 2.5 para tabagismo
# Interpretação: "Fumantes têm 2.5 vezes mais chance de ter a doença"
#
# =============================================================================


# -----------------------------------------------------------------------------
# DADOS: Hipertensão
# -----------------------------------------------------------------------------

set.seed(123)
n_pac <- 100   # 100 pacientes

# Criar dados simulados:
dados_hiper <- tibble(
  idade = round(runif(n_pac, 30, 70)),                              # Idade: 30-70 anos
  imc = round(rnorm(n_pac, 26, 4), 1),                              # IMC: média 26, DP 4
  sexo = sample(c("Feminino", "Masculino"), n_pac, replace = TRUE)  # Sexo aleatório
) %>%
  mutate(
    # Calcular probabilidade de hipertensão baseada nas variáveis:
    prob_hiper = plogis(-8 + 0.05 * idade + 0.15 * imc + 
                         0.3 * (sexo == "Masculino")),
    # Gerar o desfecho (0 ou 1) com essa probabilidade:
    hipertensao = rbinom(n_pac, 1, prob_hiper)
  )

# O que fizemos:
# - plogis() converte valores em probabilidades (entre 0 e 1)
# - rbinom() gera 0 ou 1 com base na probabilidade
# - Criamos dados onde idade, IMC e sexo afetam a chance de hipertensão


# Ver os primeiros dados:
head(dados_hiper)

# Quantos hipertensos e não-hipertensos?
table(dados_hiper$hipertensao)

# 0 = não hipertenso
# 1 = hipertenso


# -----------------------------------------------------------------------------
# AJUSTAR MODELO LOGÍSTICO
# -----------------------------------------------------------------------------

# glm() = generalized linear model (modelo linear generalizado)
# family = binomial indica que Y é binária (0/1)

modelo_logistico <- glm(hipertensao ~ idade + imc + sexo, 
                         data = dados_hiper,
                         family = binomial(link = "logit"))

# Ver o resumo:
summary(modelo_logistico)

# ATENÇÃO: Os coeficientes estão na escala de LOG-ODDS
# Para interpretar, precisamos calcular o OR (exponencial do coeficiente)


# -----------------------------------------------------------------------------
# CALCULAR OR COM INTERVALO DE CONFIANÇA
# -----------------------------------------------------------------------------

# A função tidy() do pacote broom facilita a extração dos resultados
# exponentiate = TRUE transforma os coeficientes em OR

tidy(modelo_logistico, conf.int = TRUE, exponentiate = TRUE)

# COMO LER:
#
# term = variável
# estimate = OR (Odds Ratio)
# conf.low e conf.high = IC 95% para o OR
# p.value = p-valor
#
# INTERPRETAÇÃO DOS ORs:
#
# idade: OR ≈ 1.05
# → Para cada ano a mais de idade, a chance de hipertensão aumenta ~5%
# → (OR - 1) * 100 = porcentagem de aumento
#
# imc: OR ≈ 1.15
# → Para cada unidade a mais de IMC, a chance aumenta ~15%
#
# sexoMasculino: OR ≈ 1.35
# → Homens têm ~35% mais chance de hipertensão que mulheres
#
# Se OR < 1: seria fator de proteção
# Exemplo: OR = 0.5 significa 50% MENOS chance


# -----------------------------------------------------------------------------
# PREDIÇÃO PARA UM NOVO PACIENTE
# -----------------------------------------------------------------------------

# Qual a probabilidade de hipertensão para um homem de 60 anos com IMC 28?

novo_paciente <- tibble(idade = 60, imc = 28, sexo = "Masculino")

# predict() com type = "response" retorna a PROBABILIDADE
predict(modelo_logistico, newdata = novo_paciente, type = "response")

# Resultado: probabilidade entre 0 e 1
# Exemplo: 0.45 significa 45% de chance de ser hipertenso


# =============================================================================
# ATIVIDADE 5: Diagnóstico do Modelo
# =============================================================================
#
# PRESSUPOSTOS DA REGRESSÃO LINEAR
# ---------------------------------
# Para que o modelo seja válido, alguns pressupostos devem ser atendidos:
#
# 1. LINEARIDADE: A relação entre X e Y deve ser linear
# 2. NORMALIDADE: Os resíduos (erros) devem seguir distribuição normal
# 3. HOMOCEDASTICIDADE: A variância dos resíduos deve ser constante
# 4. INDEPENDÊNCIA: As observações devem ser independentes
#
# Podemos verificar esses pressupostos com GRÁFICOS DE DIAGNÓSTICO
#
# =============================================================================


# -----------------------------------------------------------------------------
# GRÁFICOS DE DIAGNÓSTICO
# -----------------------------------------------------------------------------

# Dividir a tela em 4 partes (2x2)
par(mfrow = c(2, 2))

# Gerar os 4 gráficos de diagnóstico
plot(modelo_simples)


# COMO INTERPRETAR CADA GRÁFICO:
#
# 1. Residuals vs Fitted (Resíduos vs Valores Ajustados)
#    → Verifica LINEARIDADE e HOMOCEDASTICIDADE
#    → BOM: pontos dispersos aleatoriamente, sem padrão
#    → RUIM: pontos formam curva ou funil
#
# 2. Normal Q-Q (Quantil-Quantil)
#    → Verifica NORMALIDADE dos resíduos
#    → BOM: pontos seguem a linha diagonal
#    → RUIM: pontos se afastam muito da diagonal
#
# 3. Scale-Location
#    → Verifica HOMOCEDASTICIDADE
#    → BOM: linha aproximadamente horizontal, pontos dispersos
#    → RUIM: linha inclinada ou pontos em forma de funil
#
# 4. Residuals vs Leverage
#    → Identifica pontos INFLUENTES (que afetam muito o modelo)
#    → Pontos fora das linhas pontilhadas (distância de Cook) são preocupantes


# =============================================================================
# RESUMO: QUAL MODELO DE REGRESSÃO USAR?
# =============================================================================
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ TIPO DE Y (variável dependente)              │ MODELO                   │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ Y CONTÍNUA (peso, PA, glicemia, altura...)   │ lm() - Regressão Linear  │
# │                                              │ Medida: Coeficiente β    │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ Y BINÁRIA (sim/não, 0/1, doente/saudável)    │ glm(family = binomial)   │
# │                                              │ Regressão Logística      │
# │                                              │ Medida: OR (Odds Ratio)  │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ Y TEMPO ATÉ EVENTO (tempo até óbito, etc.)   │ coxph() - Modelo de Cox  │
# │                                              │ (ver próxima aula)       │
# │                                              │ Medida: HR (Hazard Ratio)│
# └─────────────────────────────────────────────────────────────────────────┘
#
# =============================================================================
