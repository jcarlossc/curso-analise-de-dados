# =============================================================================
# MÓDULO 3 - AULA 1: Inferência Estatística
# Atividades Complementares
# Curso: Introdução à Análise de Dados para Pesquisa no SUS
# =============================================================================
#
# ATENÇÃO: Este módulo é mais avançado que os anteriores!
# Execute o código linha por linha e leia os comentários com atenção.
# Em caso de dúvidas, consulte o gabarito ou o fórum do curso.
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

# Carregar o pacote
library(tidyverse)


# =============================================================================
# ATIVIDADE 1: Teorema Central do Limite (TCL)
# =============================================================================
#
# O QUE É O TCL?
# ---------------
# O Teorema Central do Limite é uma das ideias mais importantes da estatística.
# Ele diz que: se você pegar MUITAS amostras de uma população e calcular a 
# MÉDIA de cada amostra, essas médias vão formar uma distribuição normal
# (formato de sino), MESMO QUE a população original não seja normal!
#
# POR QUE ISSO IMPORTA?
# ---------------------
# Isso permite usar a distribuição normal para fazer inferências sobre
# médias populacionais, o que é a base dos testes estatísticos.
#
# =============================================================================


# -----------------------------------------------------------------------------
# O QUE É set.seed()?
# -----------------------------------------------------------------------------
# Quando usamos funções que geram números "aleatórios" (como rnorm, sample),
# o computador precisa de um ponto de partida. Esse ponto é a "semente" (seed).
#
# set.seed() fixa esse ponto de partida. Resultado:
#   - Seu histograma será igual ao do gabarito
#   - Suas estatísticas serão iguais às do gabarito
#   - Você pode reproduzir os resultados sempre que quiser
#
# IMPORTANTE: Ao executar set.seed(), nada aparece no console. Isso é normal!
# O efeito aparece nos resultados das funções que vêm DEPOIS dele.
# -----------------------------------------------------------------------------

set.seed(123456)


# -----------------------------------------------------------------------------
# PARÂMETROS DA SIMULAÇÃO
# -----------------------------------------------------------------------------

# Vamos simular uma população de pessoas e seu IMC (Índice de Massa Corporal)
# Imaginemos que CONHECEMOS os valores verdadeiros da população:

media_populacional <- 26    # A média REAL do IMC na população é 26 kg/m²
desvio_populacional <- 2    # O desvio-padrão REAL é 2 kg/m²

# Na prática, nunca conhecemos esses valores! Por isso fazemos inferência.
# Aqui vamos simular para MOSTRAR como a inferência funciona.

K <- 500   # Vamos coletar 500 amostras diferentes
n <- 100   # Cada amostra terá 100 pessoas


# -----------------------------------------------------------------------------
# SIMULAÇÃO: Coletando 500 amostras e calculando a média de cada uma
# -----------------------------------------------------------------------------

# O que esta linha faz, passo a passo:
#
# 1. rnorm(n, media_populacional, desvio_populacional)
#    → Gera n=100 valores simulando IMC de 100 pessoas
#    → Esses valores seguem uma distribuição normal com média 26 e DP 2
#
# 2. mean(...)
#    → Calcula a média desses 100 valores (média de UMA amostra)
#
# 3. replicate(K, ...)
#    → Repete esse processo K=500 vezes
#    → Resultado: um vetor com 500 médias amostrais

medias_amostrais <- replicate(K, mean(rnorm(n, media_populacional, desvio_populacional)))

# Veja as primeiras 10 médias calculadas:
head(medias_amostrais, 10)

# Note que cada média é um pouco diferente, mas todas estão PERTO de 26


# -----------------------------------------------------------------------------
# VISUALIZAÇÃO: Histograma das médias amostrais
# -----------------------------------------------------------------------------

# Vamos ver como se distribuem essas 500 médias:

hist(medias_amostrais,                              # Dados para o histograma
     col = "lightblue",                             # Cor das barras
     main = "Distribuição das Médias Amostrais (n=100)",  # Título
     xlab = "Média do IMC (kg/m²)",                 # Rótulo do eixo X
     ylab = "Frequência",                           # Rótulo do eixo Y
     breaks = 30)                                   # Número de barras

# Adicionar linha vertical na média verdadeira (26)
abline(v = media_populacional, col = "red", lwd = 2)

# OBSERVE O RESULTADO:
# → O histograma tem formato de SINO (distribuição normal!)
# → Está centralizado em torno de 26 (a média verdadeira)
# → Este é o Teorema Central do Limite em ação!


# -----------------------------------------------------------------------------
# VERIFICAÇÃO NUMÉRICA
# -----------------------------------------------------------------------------

# Qual é a média das 500 médias amostrais?
mean(medias_amostrais)
# → Deve ser muito próximo de 26 (a média populacional)

# Qual é o desvio-padrão das médias amostrais? (chamamos de ERRO PADRÃO)
sd(medias_amostrais)

# Qual é o erro padrão TEÓRICO segundo a fórmula?
# Fórmula: Erro Padrão = σ / √n = desvio_populacional / raiz quadrada de n
desvio_populacional / sqrt(n)

# → Os dois valores devem ser muito próximos!
# → Isso confirma a fórmula do erro padrão


# -----------------------------------------------------------------------------
# ATIVIDADE 1.2: O que acontece com amostras PEQUENAS?
# -----------------------------------------------------------------------------

# Agora vamos usar uma população ASSIMÉTRICA (não normal)
# para mostrar que o TCL funciona mesmo assim!

set.seed(42)

# Criar uma população com distribuição exponencial (assimétrica)
# rexp() gera números com distribuição exponencial
populacao <- rexp(10000, rate = 1)

# Veja como essa população é assimétrica:
hist(populacao, breaks = 30, main = "População Original (Assimétrica)", 
     col = "lightblue", border = "white")
# → Note que tem uma "cauda" longa para a direita


# Função para calcular médias amostrais
# Esta função:
#   1. Pega uma amostra de tamanho 'tam_amostra' da população
#   2. Calcula a média dessa amostra
#   3. Repete isso 'n_amostras' vezes

calcular_medias <- function(tam_amostra, n_amostras = 1000) {
  replicate(n_amostras, mean(sample(populacao, tam_amostra)))
}


# Vamos comparar o que acontece com diferentes tamanhos de amostra:

# par(mfrow = c(2, 2)) divide a tela em 4 partes (2 linhas x 2 colunas)
par(mfrow = c(2, 2))

# Gráfico 1: A população original (assimétrica)
hist(populacao, breaks = 30, main = "População (Assimétrica)", 
     col = "lightblue", border = "white")

# Gráfico 2: Médias de amostras com n=5 (muito pequeno)
hist(calcular_medias(5), breaks = 30, main = "Médias (n=5)", 
     col = "lightgreen", border = "white")

# Gráfico 3: Médias de amostras com n=30
hist(calcular_medias(30), breaks = 30, main = "Médias (n=30)", 
     col = "lightgreen", border = "white")

# Gráfico 4: Médias de amostras com n=100
hist(calcular_medias(100), breaks = 30, main = "Médias (n=100)", 
     col = "lightgreen", border = "white")

# Voltar para 1 gráfico por tela
par(mfrow = c(1, 1))

# OBSERVE:
# → Com n=5: ainda assimétrico
# → Com n=30: já parece mais normal
# → Com n=100: praticamente normal!
#
# CONCLUSÃO: Quanto MAIOR o tamanho da amostra, mais a distribuição
# das médias se aproxima da normal (mesmo que a população seja assimétrica)


# =============================================================================
# ATIVIDADE 2: Intervalo de Confiança (IC)
# =============================================================================
#
# O QUE É INTERVALO DE CONFIANÇA?
# --------------------------------
# É uma faixa de valores que provavelmente contém o parâmetro da população.
#
# Exemplo: "IC 95% para a média de IMC: [25.6, 26.4]"
# Isso significa que temos 95% de confiança de que a média verdadeira
# está entre 25.6 e 26.4.
#
# INTERPRETAÇÃO CORRETA:
# Se coletássemos 100 amostras diferentes e calculássemos o IC de cada uma,
# aproximadamente 95 desses ICs conteriam a média verdadeira.
#
# INTERPRETAÇÃO ERRADA:
# "Há 95% de chance da média estar no intervalo" - isso está incorreto!
#
# =============================================================================


# -----------------------------------------------------------------------------
# CÁLCULO DO IC PARA CADA AMOSTRA
# -----------------------------------------------------------------------------

# Valor crítico para IC de 95%
# qnorm(0.975) retorna o valor z onde 97.5% da distribuição normal está abaixo
# Para IC 95%, usamos z = 1.96

z_95 <- qnorm(0.975)
z_95  # Deve ser aproximadamente 1.96

# Erro padrão (já calculamos antes)
erro_padrao <- desvio_populacional / sqrt(n)
erro_padrao


# Vamos calcular o IC para cada uma das 500 amostras
# Fórmula do IC: média ± z * erro_padrão

# Criar um data frame com todas as informações:
df_ic <- tibble(
  amostra = 1:K,                                         # Número da amostra (1 a 500)
  media = medias_amostrais,                              # Média de cada amostra
  LI = media - z_95 * erro_padrao,                       # Limite Inferior do IC
  LS = media + z_95 * erro_padrao,                       # Limite Superior do IC
  contem_media = LI < media_populacional & LS > media_populacional  # O IC contém 26?
)

# Visualizar as primeiras linhas:
head(df_ic)


# -----------------------------------------------------------------------------
# VERIFICAÇÃO: Quantos ICs contêm a média verdadeira?
# -----------------------------------------------------------------------------

# Contagem: quantos TRUE (contém) e quantos FALSE (não contém)?
table(df_ic$contem_media)

# Proporção de ICs que contêm a média verdadeira:
mean(df_ic$contem_media)

# → Deve ser aproximadamente 0.95 (95%)!
# → Isso confirma a interpretação do IC de 95%


# -----------------------------------------------------------------------------
# VISUALIZAÇÃO: Gráfico dos ICs
# -----------------------------------------------------------------------------

# Vamos visualizar os primeiros 100 intervalos de confiança:

df_ic %>%
  slice(1:100) %>%                                       # Pegar apenas os 100 primeiros
  ggplot(aes(x = amostra, y = media, color = contem_media)) +
  geom_point(size = 2) +                                 # Ponto = média amostral
  geom_errorbar(aes(ymin = LI, ymax = LS), width = 0.3) + # Barras = IC
  geom_hline(yintercept = media_populacional, color = "black", linewidth = 0.8) +  # Linha = média verdadeira
  scale_color_manual(values = c("TRUE" = "steelblue", "FALSE" = "red")) +
  labs(title = "Intervalos de Confiança de 95%",
       subtitle = "Linha preta = média verdadeira (26)",
       x = "Amostra", 
       y = "IMC (kg/m²)") +
  theme_minimal() +
  theme(legend.position = "none")

# OBSERVE:
# → ICs em AZUL: contêm a média verdadeira (a linha preta passa pelo IC)
# → ICs em VERMELHO: NÃO contêm a média verdadeira
# → Aproximadamente 5% dos ICs são vermelhos - exatamente o esperado!


# =============================================================================
# ATIVIDADE 3: Teste t para Uma Amostra
# =============================================================================
#
# QUANDO USAR?
# ------------
# Quando queremos testar se a média de um grupo difere de um valor de referência.
#
# EXEMPLO:
# "A média de peso dos recém-nascidos deste hospital difere de 3200g?"
#
# ESTRUTURA DO TESTE:
# -------------------
# H0 (hipótese nula): μ = valor_referência (não há diferença)
# H1 (hipótese alternativa): μ ≠ valor_referência (há diferença)
#
# DECISÃO:
# - Se p-valor < 0.05: rejeitamos H0 → há evidência de diferença
# - Se p-valor >= 0.05: não rejeitamos H0 → não há evidência suficiente
#
# =============================================================================


# -----------------------------------------------------------------------------
# DADOS: Peso de 20 recém-nascidos
# -----------------------------------------------------------------------------

# Pesos em gramas de 20 recém-nascidos de uma maternidade:
peso_rn <- c(3265, 3260, 3245, 3484, 4146, 3323, 3649, 3200, 
             3031, 2069, 2581, 2841, 3609, 2838, 3541, 2759, 
             3248, 3314, 3101, 2834)

# Quantos bebês temos?
length(peso_rn)

# Estatísticas descritivas:
summary(peso_rn)   # Mínimo, quartis, média, mediana, máximo
sd(peso_rn)        # Desvio-padrão

# Média amostral:
mean(peso_rn)


# -----------------------------------------------------------------------------
# TESTE t: A média difere de 3200g?
# -----------------------------------------------------------------------------

# Pergunta: A média de peso dos bebês desta maternidade é diferente de 3200g?
# (3200g é um valor de referência nacional, por exemplo)

# H0: μ = 3200 (a média é igual a 3200g)
# H1: μ ≠ 3200 (a média é diferente de 3200g)

t.test(peso_rn, mu = 3200)

# COMO LER O RESULTADO:
#
# t = valor da estatística t (quanto maior em módulo, mais evidência contra H0)
# df = graus de liberdade (n - 1 = 19)
# p-value = probabilidade de observar esses dados se H0 fosse verdade
#
# Se p-value < 0.05 → Rejeitamos H0 → A média difere de 3200g
# Se p-value >= 0.05 → Não rejeitamos H0 → Não há evidência de diferença

# 95 percent confidence interval: é o IC para a média
# sample estimates: é a média amostral


# =============================================================================
# ATIVIDADE 4: Teste t para Duas Amostras
# =============================================================================
#
# QUANDO USAR?
# ------------
# Quando queremos comparar as médias de DOIS grupos independentes.
#
# EXEMPLO:
# "A média de colesterol difere entre dois métodos de medição?"
#
# ESTRUTURA:
# ----------
# H0: μ1 = μ2 (as médias são iguais)
# H1: μ1 ≠ μ2 (as médias são diferentes)
#
# =============================================================================


# -----------------------------------------------------------------------------
# DADOS: Colesterol medido por dois métodos
# -----------------------------------------------------------------------------

# Criamos uma tabela com os dados:
colesterol <- tibble(
  metodo = rep(c("AutoAnalyzer", "Microenzimatic"), each = 5),  # 5 medições de cada método
  valor = c(177, 193, 195, 209, 226,    # Valores do AutoAnalyzer
            192, 197, 200, 202, 209)     # Valores do Microenzimatic
)

# Visualizar os dados:
print(colesterol)


# -----------------------------------------------------------------------------
# ESTATÍSTICAS POR GRUPO
# -----------------------------------------------------------------------------

# Calcular n, média e desvio-padrão de cada método:
colesterol %>%
  group_by(metodo) %>%                    # Agrupar por método
  summarise(
    n = n(),                              # Contagem
    media = mean(valor),                  # Média
    dp = sd(valor)                        # Desvio-padrão
  )


# -----------------------------------------------------------------------------
# TESTE t PARA DUAS AMOSTRAS
# -----------------------------------------------------------------------------

# A fórmula valor ~ metodo significa:
# "Compare os valores entre os diferentes métodos"

t.test(valor ~ metodo, data = colesterol)

# INTERPRETAÇÃO:
# → Veja o p-valor
# → Se p < 0.05: há diferença significativa entre os métodos
# → Se p >= 0.05: não há evidência de diferença entre os métodos


# =============================================================================
# ATIVIDADE 5: ANOVA (Análise de Variância)
# =============================================================================
#
# QUANDO USAR?
# ------------
# Quando queremos comparar as médias de TRÊS ou mais grupos.
#
# Por que não usar vários testes t?
# Porque aumenta a chance de erro! A ANOVA faz tudo de uma vez.
#
# ESTRUTURA:
# ----------
# H0: μ1 = μ2 = μ3 = ... (todas as médias são iguais)
# H1: pelo menos uma média é diferente
#
# ATENÇÃO: Se a ANOVA for significativa, ela NÃO diz QUAIS grupos diferem.
# Para isso, usamos o teste de Tukey (comparações múltiplas).
#
# =============================================================================


# -----------------------------------------------------------------------------
# DADOS: Pressão arterial por faixa etária
# -----------------------------------------------------------------------------

# Fixar semente para reprodutibilidade
set.seed(123)

# Criar dados simulados de PA para 3 faixas etárias (20 pessoas cada):
dados_pa <- tibble(
  faixa_etaria = factor(
    rep(c("Jovem", "Adulto", "Idoso"), each = 20),   # Repetir cada categoria 20 vezes
    levels = c("Jovem", "Adulto", "Idoso")           # Definir ordem das categorias
  ),
  pressao = c(
    rnorm(20, mean = 115, sd = 10),   # 20 jovens: média 115, DP 10
    rnorm(20, mean = 125, sd = 12),   # 20 adultos: média 125, DP 12
    rnorm(20, mean = 135, sd = 15)    # 20 idosos: média 135, DP 15
  )
)

# Visualizar primeiras linhas:
head(dados_pa)


# -----------------------------------------------------------------------------
# ESTATÍSTICAS POR GRUPO
# -----------------------------------------------------------------------------

dados_pa %>%
  group_by(faixa_etaria) %>%
  summarise(
    n = n(),                    # Número de pessoas
    media = mean(pressao),      # Média da PA
    dp = sd(pressao)            # Desvio-padrão
  )


# -----------------------------------------------------------------------------
# VISUALIZAÇÃO: Boxplot
# -----------------------------------------------------------------------------

dados_pa %>%
  ggplot(aes(x = faixa_etaria, y = pressao, fill = faixa_etaria)) +
  geom_boxplot(alpha = 0.7, show.legend = FALSE) +           # Boxplot
  geom_jitter(width = 0.2, alpha = 0.4, show.legend = FALSE) + # Pontos individuais
  labs(title = "Pressão Arterial por Faixa Etária", 
       x = "", 
       y = "PA Sistólica (mmHg)") +
  theme_minimal() +
  scale_fill_brewer(palette = "Set2")                        # Paleta de cores


# -----------------------------------------------------------------------------
# ANOVA
# -----------------------------------------------------------------------------

# aov() = Analysis of Variance
# Fórmula: variável_resposta ~ variável_grupo

modelo_anova <- aov(pressao ~ faixa_etaria, data = dados_pa)

# Ver resultado:
summary(modelo_anova)

# COMO LER O RESULTADO:
#
# Df = graus de liberdade
# Sum Sq = soma dos quadrados
# Mean Sq = média dos quadrados
# F value = estatística F (quanto maior, mais evidência de diferença)
# Pr(>F) = p-valor
#
# Se Pr(>F) < 0.05 → Há diferença significativa entre PELO MENOS dois grupos


# -----------------------------------------------------------------------------
# TESTE DE TUKEY (Comparações Múltiplas)
# -----------------------------------------------------------------------------

# Se a ANOVA for significativa, usamos Tukey para saber QUAIS grupos diferem:

TukeyHSD(modelo_anova)

# COMO LER O RESULTADO:
#
# diff = diferença entre as médias dos grupos
# lwr = limite inferior do IC 95% para a diferença
# upr = limite superior do IC 95% para a diferença
# p adj = p-valor ajustado
#
# Se p adj < 0.05 → Esses dois grupos diferem significativamente


# =============================================================================
# ATIVIDADE 6: Teste de Proporção
# =============================================================================
#
# QUANDO USAR?
# ------------
# Quando queremos testar se uma PROPORÇÃO difere de um valor de referência.
#
# EXEMPLO:
# "A prevalência de hipertensão nesta população difere de 25%?"
#
# =============================================================================


# -----------------------------------------------------------------------------
# DADOS
# -----------------------------------------------------------------------------

# Em uma amostra de 200 adultos, 60 são hipertensos.
# Queremos testar se essa proporção difere de 25% (0.25).

# Proporção amostral:
60 / 200   # = 0.30 = 30%


# -----------------------------------------------------------------------------
# TESTE DE PROPORÇÃO
# -----------------------------------------------------------------------------

# prop.test(x, n, p)
#   x = número de "sucessos" (hipertensos)
#   n = tamanho da amostra
#   p = proporção esperada (referência)

prop.test(x = 60, n = 200, p = 0.25)

# INTERPRETAÇÃO:
# → Se p-valor < 0.05: a proporção difere significativamente de 25%
# → Se p-valor >= 0.05: não há evidência de que difira de 25%


# =============================================================================
# RESUMO: QUAL TESTE USAR?
# =============================================================================
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ VARIÁVEL NUMÉRICA (comparar MÉDIAS)                                     │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ 1 grupo vs valor de referência  →  t.test(x, mu = valor)                │
# │ 2 grupos independentes          →  t.test(y ~ grupo)                    │
# │ 3 ou mais grupos                →  aov() + TukeyHSD()                   │
# └─────────────────────────────────────────────────────────────────────────┘
#
# ┌─────────────────────────────────────────────────────────────────────────┐
# │ VARIÁVEL CATEGÓRICA (comparar PROPORÇÕES)                               │
# ├─────────────────────────────────────────────────────────────────────────┤
# │ 1 proporção vs referência       →  prop.test()                          │
# │ 2 ou mais grupos                →  chisq.test()                         │
# └─────────────────────────────────────────────────────────────────────────┘
#
# =============================================================================
