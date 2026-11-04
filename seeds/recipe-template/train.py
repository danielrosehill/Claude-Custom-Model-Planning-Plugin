"""Placeholder training script. Replace the body of main() with real training.

Keep these arguments: they let one script serve every rung of the run ladder.
"""
import argparse
from pathlib import Path


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--train-rows", type=int, default=None)
    parser.add_argument("--eval-rows", type=int, default=None)
    parser.add_argument("--epochs", type=float, default=1)
    parser.add_argument("--lr", type=float, default=2e-4)
    parser.add_argument("--out", type=Path, default=Path("outputs"))
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    raise NotImplementedError("Write the training loop for this recipe.")


if __name__ == "__main__":
    main()
