library(tidyverse)

model_names <- c("SmolLM-135M",
                 "gpt2", "gpt2-medium", "gpt2-large", "gpt2-xl", 
                 "opt-125m", "opt-350m", "opt-1.3b", "opt-2.7b", "opt-6.7b", 
                 "pythia-70m", "pythia-160m", "pythia-410m", "pythia-1.4b", "pythia-2.8b", "pythia-6.9b", "pythia-12b")

model_families <- c("SmolLM", rep("GPT-2", 4), rep("OPT", 5), rep("Pythia", 7))

model_colors <- c("#41ab5d",
                  "#fa9fb5", "#f768a1", "#c51b8a", "#7a0177", 
                  "#c6dbef", "#9ecae1", "#6baed6", "#3182bd", "#08519c", 
                  "#fff7bc", "#fee391", "#fec44f","#fe9929", "#ec7014", "#cc4c02", "#8c2d04")


model_short <- c("SmolLM-135M", "GPT-2", "GPT-2-M", "GPT-2-L", "GPT-2-XL",
                 "OPT-125m", "OPT-350m", "OPT-1.3b", "OPT-2.7b", "OPT-6.7b",
                 "Py-70m", "Py-160m", "Py-410m", "Py-1.4b", "Py-2.8b", "Py-6.9b", "Py-12b")

model_meta <- tibble(
  model = model_names,
  family = model_families,
  color = model_colors,
  short = model_short
)

lgd <- read_csv("data/lgd-attractors/lgd.csv")


wiki_vocab <- read_table("~/Downloads/wiki.vocab", skip = 1, col_names = c("word", "pos", "count")) %>%
  filter(str_detect(pos, "VB")) %>%
  group_by(word) %>%
  filter(count == max(count)) %>%
  ungroup()


lgd %>%
  inner_join(wiki_vocab %>% select(correct_verb = word, pos)) %>%
  count(pos)

tse_results <- fs::dir_ls("results/lgd/") %>%
  map_df(read_csv, .id="file") %>%
  mutate(
    model = str_remove(file, "results/lgd/"),
    model = str_remove(model, "(EleutherAI|facebook|HuggingFaceTB)__"),
    model = str_remove(model, "\\.csv"),
    model = str_remove(model, "-deduped")
  ) %>%
  select(-file) %>%
  inner_join(lgd)

att_results <- tse_results %>%
  group_by(model, attractors) %>%
  summarize(
    n = n(),
    accuracy = mean(good_score > bad_score),
    error_rate = 1 - accuracy
  ) %>%
  ungroup() %>%
  inner_join(model_meta)

att_results %>%
  filter(model == "gpt2") %>%
  ggplot(aes(attractors, error_rate, group = model)) +
  geom_point(size = 3.5, color = "#2c7fb8") +
  geom_line(linewidth = 0.8, color = "#2c7fb8") +
  geom_hline(yintercept = 0.5, linetype = "dashed", linewidth = 1, color = "darkgrey") +
  geom_hline(yintercept = 0.28, linetype = "dashed", linewidth = 1, color = "black") +
  geom_hline(yintercept = 1.0, linetype = "dashed", linewidth = 1, color = "#de2d26") +
  scale_y_continuous(limits = c(0,1), labels = scales::percent_format(), breaks = c(0, 0.2, 0.4, 0.6, 0.8, 1.0)) +
  theme_classic(base_size = 18) +
  theme(
    axis.text = element_text(color = "black")
  ) +
  labs(
    x = "Attractors",
    y = "Error Rate"
  )
  
# w347 h444

ggsave("figures/attractor-agreement.png", height=4.44, width = 3.47, dpi=300)

att_results %>%
  filter(model == "gpt2") %>%
  ggplot(aes(attractors, n)) +
  geom_col(width = 0.7, fill = "#756bb1") +
  theme_classic(base_size = 18) +
  scale_y_continuous(expand = c(0.01,0)) +
  scale_x_continuous(expand = c(0.01,0)) +
  labs(
    x = "Attractors",
    y = "Number of Sentences"
  )

ggsave("figures/attractor-sentences.png", height=4.20, width = 3.92, dpi=300)
