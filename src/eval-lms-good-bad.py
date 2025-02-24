'''
Basic code to evaluate LMs using the minicons package
in a setting with a good vs a bad sentence.
'''

import argparse
import utils
import pathlib

from minicons import scorer
from torch.utils.data import DataLoader
from tqdm import tqdm


def main(args):

    model = args.model
    model_name = model.replace("/", "__")

    lm = scorer.IncrementalLMScorer(model, device=args.device)

    stimuli = utils.read_csv_dict(args.input_data)
    batches = DataLoader(stimuli, batch_size=args.batch_size)

    results = []
    for batch in tqdm(batches):
        idx = batch["idx"]

        if "gpt2" in model_name or "pythia" in model_name:
            good_scores = lm.sequence_score(
                batch["good"], bow_correction=True, bos_token=True
            )
            bad_scores = lm.sequence_score(
                batch["bad"], bow_correction=True, bos_token=True
            )
        else:
            good_scores = lm.sequence_score(batch["good"], bow_correction=True)
            bad_scores = lm.sequence_score(batch["bad"], bow_correction=True)

        for i, g, b in zip(idx, good_scores, bad_scores):
            results.append((i, g, b))

    pathlib.Path(args.output_dir).mkdir(parents=True, exist_ok=True)
    utils.write_csv(
        data=results,
        path=f"{args.output_dir}/{model_name}.csv",
        header=["idx", "good_score", "bad_score"],
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--model", type=str)
    parser.add_argument("--input_data", type=str)
    parser.add_argument("--output_dir", type=str)
    parser.add_argument("--batch_size", type=int, default=32)
    parser.add_argument("--device", type=str, default="cpu")

    args = parser.parse_args()
    main(args)
