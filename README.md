# Introdução à Análise de Dados para Pesquisa no SUS

Este repositório contém os materiais práticos do curso **Introdução à Análise de Dados para Pesquisa no SUS**, oferecido pelo Campus Virtual Fiocruz.

---

## 📚 ESTRUTURA DO CURSO

O curso está organizado em 3 módulos:

| Módulo | Tema | Status |
|--------|------|--------|
| **Módulo 1** | Introdução à Lógica de Programação | ✅ Disponível |
| **Módulo 2** | Estatística Descritiva e Comunicação de Resultados | ✅ Disponível |
| **Módulo 3** | Modelos Estatísticos | ✅ Disponível |

---

## 📁 CONTEÚDO DISPONÍVEL

### MÓDULO 1: Lógica e Linguagem de Programação

**Aula 1:** Introdução à Lógica de Programação

**Aula 2:** Introdução à Linguagem de Programação

| Tipo | Arquivo | Descrição |
|------|---------|-----------|
| Script | `modulo1aula2_script_1.R` | Operações básicas em R |
| Script | `modulo1aula2_script_2.R` | Manipulação de dados com tidyverse |
| Script | `modulo1aula2_atividades.R` | Gabarito das atividades práticas |
| PDF | `modulo1aula2_atividades.pdf` | Descrição das atividades propostas |
| PDF | `modulo1aula2_gabarito_atividade.pdf` | Gabarito dos resultados |

> **OBSERVAÇÃO:** Para responder as perguntas que estão em `modulo1aula2_atividades.pdf`, tente criar o seu código para encontrar as respostas, mas caso tenha dificuldades o gabarito em R (`modulo1aula2_atividades.R`) encontra-se na pasta.

---

### MÓDULO 2: Estatística Descritiva e Comunicação de Resultados

**Aula 1:** Análise Exploratória e Descritiva

| Tipo | Arquivo | Descrição |
|------|---------|-----------|
| Script | `modulo2aula1_atividades.R` | Atividades de estatística descritiva |
| PDF | `modulo2aula1_atividades.pdf` | Descrição das atividades propostas |
| PDF | `modulo2aula1_gabarito.pdf` | Gabarito dos resultados |

**Aula 2:** Formas de Visualização de Dados

| Tipo | Arquivo | Descrição |
|------|---------|-----------|
| Script | `modulo2aula2_atividades.R` | Atividades de visualização de dados |
| PDF | `modulo2aula2_atividades.pdf` | Descrição das atividades propostas |
| PDF | `modulo2aula2_gabarito.pdf` | Gabarito dos resultados |

> **OBSERVAÇÃO:** Os scripts do Módulo 2 contêm comentários explicativos detalhados. Execute o código acompanhando os comentários para melhor compreensão.

---

### MÓDULO 3: Modelos Estatísticos

**Aula 1:** Inferência Estatística

| Tipo | Arquivo | Descrição |
|------|---------|-----------|
| Script | `modulo3aula1_atividades.R` | Atividades de inferência estatística |
| PDF | `modulo3aula1_atividades.pdf` | Descrição das atividades propostas |
| PDF | `modulo3aula1_gabarito.pdf` | Gabarito dos resultados |

**Aula 2:** Modelos de Regressão

| Tipo | Arquivo | Descrição |
|------|---------|-----------|
| Script | `modulo3aula2_atividades.R` | Atividades de modelos de regressão |
| PDF | `modulo3aula2_atividades.pdf` | Descrição das atividades propostas |
| PDF | `modulo3aula2_gabarito.pdf` | Gabarito dos resultados |

**Aula 3:** Dados com Estruturas de Dependência

| Tipo | Arquivo | Descrição |
|------|---------|-----------|
| Script | `modulo3aula3_atividades.R` | Atividades de modelos multiníveis, séries temporais e sobrevivência |
| PDF | `modulo3aula3_atividades.pdf` | Descrição das atividades propostas |
| PDF | `modulo3aula3_gabarito.pdf` | Gabarito dos resultados |

**Aula 4:** Aplicação dos Modelos Estatísticos

| Tipo | Arquivo | Descrição |
|------|---------|-----------|
| Script | `modulo3aula4_atividades.R` | Casos práticos: COVID-19, ensaio clínico e oncologia |
| PDF | `modulo3aula4_atividades.pdf` | Descrição das atividades propostas |
| PDF | `modulo3aula4_gabarito.pdf` | Gabarito dos resultados |

> **OBSERVAÇÃO:** O Módulo 3 utiliza dados simulados para fins didáticos. Os scripts contêm explicações detalhadas de cada conceito estatístico, facilitando o aprendizado mesmo para quem não tem experiência prévia com modelagem.

---

## 📊 DADOS UTILIZADOS

A pasta `dados/` contém os arquivos utilizados nas atividades:

| Arquivo | Formato | Descrição |
|---------|---------|-----------|
| `sim_salvador_2023.csv` | CSV | Dados do Sistema de Informações sobre Mortalidade |
| `sim_salvador_2023.parquet` | Parquet | Mesmo dataset em formato otimizado |
| `sim_salvador_2023.xlsx` | Excel | Mesmo dataset em formato Excel |
| `sim_salvador_2023_processado.csv` | CSV | Dataset processado pelo Script 2 |
| `dicionario_sim.pdf` | PDF | Dicionário de variáveis do SIM |

### Estrutura do Dataset SIM

**Variáveis principais:**

- **SEXO:** categórica (0=Ignorado, 1=Masculino, 2=Feminino)
- **DTOBITO:** data do óbito (formato ddmmyyyy)
- **IDADE:** idade codificada do DATASUS
  - 1º dígito: tipo (0-3: menos de 1 ano, 4: anos, 5: centenários)
  - Demais dígitos: quantidade
- **DTNASC:** data de nascimento
- **CAUSABAS:** causa básica do óbito (CID-10)
- **CODMUNRES:** código IBGE do município de residência

---

## 🎯 OBJETIVOS DE APRENDIZAGEM

### Módulo 1 - Introdução à Linguagem R

- Operações básicas no R
- Criação de variáveis categóricas com `mutate()` e `case_when()`
- Contagem e agregação de dados com `count()` e `group_by()`
- Manipulação de datas com `lubridate`
- Importação e exportação de dados

### Módulo 2 - Estatística Descritiva e Comunicação de Resultados

- Classificação de variáveis (qualitativas e quantitativas)
- Medidas de locação (média, mediana, quantis)
- Medidas de dispersão (variância, desvio-padrão, CV, IQ)
- Construção de gráficos com `ggplot2`
- Boas práticas na visualização de dados
- Importância da exploração visual (Quarteto de Anscombe, Datasaurus Dozen)

### Módulo 3 - Modelos Estatísticos

- Teorema Central do Limite e distribuição amostral
- Intervalos de confiança para média e proporção
- Testes de hipóteses (t de Student, ANOVA, teste de proporção)
- Modelos de regressão linear simples e múltipla
- Regressão logística e interpretação de Odds Ratios
- Modelos multiníveis (hierárquicos)
- Análise de séries temporais (decomposição, ARIMA)
- Análise de sobrevivência (Kaplan-Meier, modelo de Cox)
- Aplicação prática em estudos de saúde pública

---

## 🚀 COMO UTILIZAR

1. Certifique-se de ter o **R** e o **RStudio** instalados
2. Instale os pacotes necessários (veja seção abaixo)
3. Defina o diretório de trabalho para esta pasta
4. Execute os scripts na ordem sugerida
5. Consulte o gabarito após tentar resolver as atividades

```r
# Definir diretório de trabalho
setwd("caminho/para/repositório")

# Instalar pacotes necessários (Módulos 1 e 2)
install.packages("tidyverse")
install.packages("lubridate")
install.packages("readxl")
install.packages("arrow")
install.packages("datasauRus")

# Pacotes adicionais para o Módulo 3
install.packages("broom")
install.packages("lme4")
install.packages("forecast")
install.packages("survival")
install.packages("survminer")
```

> **OBSERVAÇÃO:** Lembre-se de ajustar o caminho do diretório de trabalho (`setwd()`) nos scripts para corresponder à localização dos arquivos no seu computador.

---

## 📝 ESTRUTURA DAS ATIVIDADES

### Módulo 1

- Criação de variáveis derivadas usando `mutate()` e `case_when()`
- Contagem e sumarização de dados com `count()` e `group_by()`
- Análise exploratória de dados de mortalidade
- Transformação e limpeza de dados

> **DICA:** Tente criar seu próprio código antes de consultar o gabarito!

### Módulo 2

- Cálculo de estatísticas descritivas (locação e dispersão)
- Criação de funções personalizadas para análise
- Construção de gráficos (barras, boxplot, histograma, dispersão)
- Análise crítica de visualizações de dados
- Aplicação de boas práticas em comunicação visual

### Módulo 3

- **Aula 1:** Simulação do Teorema Central do Limite, cálculo de intervalos de confiança, testes t (uma e duas amostras), ANOVA com teste de Tukey, teste de proporção
- **Aula 2:** Correlação de Pearson, regressão linear simples e múltipla, regressão logística com Odds Ratios, diagnóstico de modelos
- **Aula 3:** Modelos multiníveis com `lme4`, decomposição de séries temporais, modelos ARIMA, curvas de Kaplan-Meier e modelo de Cox
- **Aula 4:** Aplicação integrada em três casos práticos de saúde pública (fatores de risco para COVID-19 grave, ensaio clínico comparando tratamentos, sobrevida em pacientes oncológicos)



---

## 🔗 MATERIAL DE APOIO

### Documentação Oficial

- [R Project](https://www.r-project.org/)
- [RStudio/Posit](https://posit.co/)
- [Tidyverse](https://www.tidyverse.org/)
- [ggplot2](https://ggplot2.tidyverse.org/)
- [dplyr](https://dplyr.tidyverse.org/)

### Livros Gratuitos

- [R for Data Science](https://r4ds.had.co.nz/) (Hadley Wickham)
- [ggplot2: Elegant Graphics for Data Analysis](https://ggplot2-book.org/)
- [Fundamentals of Data Visualization](https://clauswilke.com/dataviz/) (Claus Wilke)

### Tutoriais Interativos

- [RStudio Primers](https://posit.cloud/learn/primers)
- [Swirl](https://swirlstats.com/) - aprender R dentro do R
- [DataCamp](https://www.datacamp.com/) - cursos introdutórios gratuitos

### Galerias de Visualização

- [R Graph Gallery](https://r-graph-gallery.com/)
- [From Data to Viz](https://www.data-to-viz.com/)
- [Data Viz Project](https://datavizproject.com/)
- [Data Viz Catalogue](https://datavizcatalogue.com/)

### Dados de Saúde Pública

- [DATASUS](https://datasus.saude.gov.br/)
- [TabNet](http://tabnet.datasus.gov.br/)
- [OpenDataSUS](https://opendatasus.saude.gov.br/)
- [Portal Brasileiro de Dados Abertos](https://dados.gov.br/)

### Cheat Sheets

- [RStudio IDE](https://posit.co/resources/cheatsheets/)
- [dplyr - Data Transformation](https://posit.co/resources/cheatsheets/)
- [ggplot2 - Data Visualization](https://posit.co/resources/cheatsheets/)
- [lubridate - Dates and Times](https://posit.co/resources/cheatsheets/)

---

## 🔧 SOLUÇÃO DE PROBLEMAS COMUNS

### Pacote não instala

- Verificar conexão com internet
- Usar `install.packages("nome", dependencies = TRUE)`
- Atualizar o R e RStudio
- Verificar permissões do sistema

### Erro ao importar dados

- Verificar caminho do arquivo com `getwd()`
- Usar `setwd()` para mudar diretório
- Verificar separador (vírgula vs ponto-e-vírgula)
- Verificar encoding do arquivo

### Gráfico não aparece

- Usar `print()` para objetos ggplot
- Verificar se RStudio está atualizado
- Limpar painel de gráficos
- Salvar e reabrir o script

### Erro "object not found"

- Verificar nome do objeto (case-sensitive)
- Executar linhas anteriores que criam o objeto
- Verificar se pacote está carregado (`library()`)
- Reiniciar sessão R se necessário

### Erros específicos do Módulo 3

- **lme4 não instala:** Pode precisar de ferramentas de compilação. No Windows, instale o [Rtools](https://cran.r-project.org/bin/windows/Rtools/)
- **Erro em forecast:** Verificar se a série temporal foi criada corretamente com `ts()`
- **Erro em survival:** Certificar-se de que o objeto Surv() foi criado antes de usar survfit()

---

## ✨ BOAS PRÁTICAS DE PROGRAMAÇÃO

### Organização de Código

- Comentar código explicando "por quê", não "o quê"
- Usar nomes descritivos de variáveis
- Dividir código em seções lógicas
- Usar pipe `%>%` para encadear operações

### Estilo de Código

- Seguir [guia de estilo tidyverse](https://style.tidyverse.org/)
- Usar `snake_case` para nomes
- Espaços ao redor de operadores
- Indentação consistente (2 espaços)

### Reprodutibilidade

- Salvar versão dos pacotes usados
- Documentar sessão R (`sessionInfo()`)
- Usar projetos do RStudio (`.Rproj`)
- Nunca modificar dados originais

---

## 📖 COMO CITAR

> Introdução à Análise de Dados para Pesquisa no SUS. (2025). Scripts de R. Rio de Janeiro: Campus Virtual Fiocruz.

---

## 🙏 AGRADECIMENTOS E CRÉDITOS

Este material foi desenvolvido para o curso **"Introdução à Análise de Dados para Pesquisa no SUS"** com o objetivo de capacitar profissionais de saúde pública em análise de dados usando R.

**Inspirações:**
- R for Data Science (Hadley Wickham & Garrett Grolemund)
- Tidyverse style guide
- Comunidade R brasileira

**Dados:** Sistema de Informações de Mortalidade (SIM) - DATASUS/Ministério da Saúde

---

**Última Atualização:** Dezembro 2025  
**Versão:** 3.0

---

*Desenvolvido com ❤️ para a comunidade de saúde pública brasileira*