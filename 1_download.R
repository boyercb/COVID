library(tidyverse)
library(rdhs)

# Set up configuration of DHS API
set_rdhs_config(
  email = "christopherbboyer@gmail.com",
  project = "Strengthening the evidence base for IPV prevention",
  verbose_download = TRUE
)

# Get information about 2018 Zambia DHS
survey <-
  dhs_surveys(
    countryIds = "ZM",
    surveyType = "DHS",
    surveyYearStart = 2018
  )

# We want child (KR) and household member (PR) datasets
dataset <- 
  dhs_datasets(
    surveyIds = survey$SurveyId,
    fileFormat = "flat",
    fileType = c("PR", "KR") # 
  )

# Download datasets to local computer using DHS API
downloads <-
  get_datasets(dataset$FileName)

# Get list of questions necessary for analysis
questions <-
  search_variables(
    dataset$FileName,
    variables = c(
      "hv105",
      "ha54",
      "hv012",
      "hv013",
      "hv241",
      "hv226",
      "hv230b",
      "v113",
      "hv219",
      "hv252",
      "h31",
      "h31b",
      "hhid",
      "hv001",
      "hv002",
      "hv003",
      "v001",
      "v002",
      "v003"
    )
  )

# Extract relevant questions from the downloaded datasets
extract <- extract_dhs(questions)

# Join into a single analytic dataset
df <- 
  inner_join(
    extract$ZMPR71FL,
    extract$ZMKR71FL,
    by = c(
      "hv001" = "v001",
      "hv002" = "v002",
      "hv003" = "v003"
    )
  )

df
