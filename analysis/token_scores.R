library(tidyverse)

good_scores = c(-3.2781143188476562,
                -7.457775115966797,
                -1.3316574096679688,
                -2.6977767944335938,
                -15.189865112304688,
                -1.5198516845703125,
                -6.570068359375,
                -0.7424736022949219,
                -4.113365173339844,
                -1.0492095947265625)

bad_scores = c(-3.2781143188476562,
               -7.457775115966797,
               -1.3316574096679688,
               -2.6977767944335938,
               -15.189865112304688,
               -3.4409637451171875,
               -5.7512664794921875,
               -0.6723098754882812,
               -4.5037078857421875,
               -1.2848892211914062)

tibble(
  word = c("The", "key", "to", "the1", "cabinets", "is/are", "on", "the2", "table", "."),
  is = good_scores,
  are = bad_scores,
  span = c("The key", "The key", "to", "the cabinets", "the cabinets", "is/are", "on the table.", "on the table.", "on the table.", "on the table.")
) %>%
  pivot_longer(is:are, names_to = "condition", values_to = "score") %>%
  group_by(span, condition) %>%
  summarize(
    score = sum(score)
  ) %>%
  ungroup() %>%
  mutate(
    span = factor(span, levels=c("The key", "to", "the cabinets", "is/are", "on the table."))
  ) %>%
  ggplot(aes(span, score, color = condition, group = condition)) +
  geom_point() +
  geom_line()
