library(tidyverse)
library(rdhs)

# Set up configuration of DHS API
set_rdhs_config(
  email = "jpinchoff@popcouncil.org",
  project = "COVID vulnerability mapping",
  password_prompt = TRUE,
  verbose_download = TRUE
)

password <- "Maps4COVID"

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
    fileType = c("PR", "KR", "IR", "MR", "AR", "GE") # 
  )

# Download datasets to local computer using DHS API
downloads <-
  get_datasets(dataset$FileName, clear_cache = TRUE)

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
      "hvidx",
      "midx",
      "b16",
      "hv001",
      "hv002",
      "hv003",
      "v001",
      "v002",
      "v003",
      "hivclust",
      "hivnumb",
      "hivline",
      "hiv06",
      "hiv07", 
      "hiv08"
    )
  )

# Extract relevant questions from the downloaded datasets
extract <- extract_dhs(questions, add_geo = TRUE)

geo_vars <- c(
  "CLUSTER",
  "ALT_DEM",
  "LATNUM",
  "LONGNUM",
  "ADM1NAME",
  "DHSREGNA",
  "SurveyId"
)

# Join into a single analytic dataset
df <- 
  left_join(
    extract$ZMPR71FL,
    select(extract$ZMKR71FL, -geo_vars), 
    by = c(
      "hv001" = "v001",
      "hv002" = "v002",
      "hvidx" = "b16"
    )
  ) %>%
  left_join(
    .,
    select(extract$ZMAR71FL, -geo_vars),
    by = c(
      "hv001" = "hivclust",
      "hv002" = "hivnumb",
      "hvidx" = "hivline"
    )
  )

df
