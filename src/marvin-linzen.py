import pickle
import os
import utils

dataset = []

path = "data/marvin-linzen"
idx = 1
for file in os.listdir(path):
    file_path = f"{path}/{file}"

    phenomenon = file.replace(".pickle", "")
    with open(file_path, "rb") as f:
        loaded = pickle.load(f)
        for condition, sent_pairs in loaded.items():
            for good, bad in sent_pairs:
                dataset.append((idx, phenomenon, condition, good, bad))
                idx += 1 

utils.write_csv(
    data=dataset,
    path="data/marvin-linzen/phenomena.csv",
    header=["idx", "phenomenon", "condition", "good", "bad"],
)
