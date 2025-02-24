import utils
import re

lgd_raw = utils.read_tsv("data/lgd-attractors/lgd_dataset-sampled.tsv")


def preprocess(sentence):
    sentence = re.sub(r"(?<=\s)(``)(?=(\s+|$))", '"', sentence)
    sentence = re.sub(r"(?<=\s)('')(?=(\s+|$))", '"', sentence)

    # sentence = re.sub(r"\b'\s+\b", "'", sentence)
    sentence = re.sub(r"\b\s+'(?=(s|t))", "'", sentence)
    # sentence = re.sub(r"\b(\s+')\s+\b", r"\1", sentence)
    sentence = re.sub(r"\s'\s", r"' ", sentence)

    sentence = re.sub(r"\s+(?=[\.,?!\)\]](\s+|$))", r"", sentence)
    sentence = re.sub(
        r"(?<=[\(\[])\s+", "", sentence
    )  # open brackets/parentheses/quotes
    # sentence = re.sub(r"\s\"\s", r' "', sentence)
    sentence = re.sub(r'"\s*([^"]*?)\s*"', r'"\1"', sentence)
    # print(sentence)
    return sentence


lgd = []

for idx, (attractors, sentence, masked, verb_correct, verb_incorrect) in enumerate(
    lgd_raw
):
    attractors = int(attractors)
    prefix = masked.split("***mask***")[0].strip()

    prefix = preprocess(prefix)

    lgd.append((idx + 1, f"{prefix} {verb_correct}", f"{prefix} {verb_incorrect}", verb_correct, verb_incorrect, attractors))

utils.write_csv(
    data=lgd,
    path="data/lgd-attractors/lgd.csv",
    header=["idx", "good", "bad", "correct_verb", "incorrect_verb", "attractors"],
)
