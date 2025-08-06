library(tidyverse)

model_names <- c("gpt2", "gpt2-medium", "gpt2-large", "gpt2-xl", 
                 "opt-125m", "opt-350m", "opt-1.3b", "opt-2.7b", "opt-6.7b", 
                 "pythia-70m", "pythia-160m", "pythia-410m", "pythia-1.4b", "pythia-2.8b", "pythia-6.9b", "pythia-12b")

model_families <- c(rep("GPT-2", 4), rep("OPT", 5), rep("Pythia", 7))

model_colors <- c("#fa9fb5", "#f768a1", "#c51b8a", "#7a0177", 
                  "#c6dbef", "#9ecae1", "#6baed6", "#3182bd", "#08519c", 
                  "#fff7bc", "#fee391", "#fec44f","#fe9929", "#ec7014", "#cc4c02", "#8c2d04")


model_short <- c("GPT-2", "GPT-2-M", "GPT-2-L", "GPT-2-XL",
                 "OPT-125m", "OPT-350m", "OPT-1.3b", "OPT-2.7b", "OPT-6.7b",
                 "Py-70m", "Py-160m", "Py-410m", "Py-1.4b", "Py-2.8b", "Py-6.9b", "Py-12b")

model_meta <- tibble(
  model = model_names,
  family = model_families,
  color = model_colors,
  short = model_short
)

tse_data <- read_csv("data/marvin-linzen/phenomena.csv")

tse_results <- fs::dir_ls("results/marvin-linzen/") %>%
  map_df(read_csv, .id="file") %>%
  mutate(
    model = str_remove(file, "results/marvin-linzen/"),
    model = str_remove(model, "(EleutherAI|facebook)__"),
    model = str_remove(model, "\\.csv"),
    model = str_remove(model, "-deduped")
  ) %>%
  select(-file) %>%
  inner_join(tse_data)

tse_results %>% count(model)

phen_results <- tse_results %>%
  group_by(model, phenomenon) %>%
  summarize(
    accuracy = mean(good_score > bad_score)
  ) %>%
  ungroup() %>%
  inner_join(model_meta) %>%
  mutate(
    short = factor(short, levels = model_short),
    family = factor(family, levels = unique(model_families))
  )

phen_results %>%
  ggplot(aes(family, accuracy, shape = family, color = color, fill = color)) +
  # geom_point(size = 3) +
  # geom_line() +
  geom_col(position = position_dodge2(0.7, preserve = "single", reverse = TRUE)) +
  scale_color_identity(aesthetics = c("color", "fill")) +
  facet_wrap(~phenomenon)

