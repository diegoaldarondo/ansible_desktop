import argparse
import json
import os
from typing import Iterator, List

from instructor import OpenAISchema
from openai import OpenAI
from pydantic import BaseModel


class Change(BaseModel):
    """
    Represents a single change in a file.

    The original lines to change are replaced with the new lines to add.
    The first line number to change is 1-indexed.

    Args:
        firstLineNumberToChange (int): First line number to replace (1-indexed)
        originalLinesToChange (str): Lines to replace, including indentation, separated by newlines. Must be valid code in the original file.
        newLinesToAdd (str): Lines to add, including indentation, separated by newlines. Must be valid code.
    """

    firstLineNumberToChange: int
    originalLinesToChange: str
    newLinesToAdd: str


class FlexiblePatch(OpenAISchema):
    changes: List[Change]

    class Config:
        title = "flexible_patch"
        description = "Patch a file with a list of changes."

    def generate(self) -> str:
        """
        Generate a string representing the changes.

        Returns:
            str: A string representing the patch file.
        """
        patch = ""
        for change in self.changes:
            patch += f"\n{change.firstLineNumberToChange}\n{change.originalLinesToChange}\n{change.newLinesToAdd}\n"
        return patch


def find_all(a_str: str, sub: str) -> Iterator[int]:
    """
    Find all occurrences of a substring in a string.

    Args:
        a_str (str): The string to search in.
        sub (str): The substring to search for.

    Yields:
        Iterator[int]: An iterator over start indices where the substring is found.
    """
    start = 0
    while True:
        start = a_str.find(sub, start)
        if start == -1:
            return
        yield start
        start += len(sub)


def patch_file(file: str, changes: List[Change]) -> str:
    """
    Apply a list of changes to a file and return the patched file content.

    The function supports both insertion of new lines and replacement of existing lines.
    If the original lines to change are empty, the new lines are inserted at the specified
    line number. Otherwise, all occurrences of the original lines in the file are replaced
    with the new lines.

    Args:
        file (str): The original file content.
        changes (List[Change]): A list of Change objects representing the changes to apply.

    Returns:
        str: The content of the file with the applied patches.
    """
    lines = file.split("\n")
    changes = sorted(
        changes, key=lambda change: change.firstLineNumberToChange, reverse=True
    )
    for change in changes:
        if change.originalLinesToChange == "":
            lines.insert(change.firstLineNumberToChange, change.newLinesToAdd)
            file = "\n".join(lines)
        else:
            # Find all indices in file that match the original lines
            matches = find_all(file, change.originalLinesToChange)
            matches = list(matches)
            line_number_matches = [file[:match].count("\n") for match in matches]
            if len(line_number_matches) == 0:
                continue
            closest_line_number_match = min(
                line_number_matches,
                key=lambda match: abs(match - change.firstLineNumberToChange),
            )
            closest_match = matches[
                line_number_matches.index(closest_line_number_match)
            ]
            file = (
                file[:closest_match]
                + change.newLinesToAdd
                + file[closest_match + len(change.originalLinesToChange) :]
            )
            lines = file.split("\n")
    return "\n".join(lines)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Apply changes to a file based on a patch."
    )
    parser.add_argument(
        "--file", type=str, required=True, help="Path to the file to patch."
    )
    parser.add_argument("--prompt", type=str, required=True, help="Patch prompt input.")
    parser.add_argument(
        "--output",
        type=str,
        default="/tmp/patched_file",
        help="Path for the output patched file.",
    )
    args = parser.parse_args()

    client = OpenAI(
        api_key=os.environ["OPENAI_API_KEY"],
    )

    with open(args.file, "r") as file:
        filedata = file.read()
    lined_filedata = filedata.split("\n")
    lined_filedata = "\n".join(f"{i+1} {line}" for i, line in enumerate(lined_filedata))

    prompt = lined_filedata + "\n--------\n" + args.prompt
    response = client.chat.completions.create(
        model="gpt-4-1106-preview",
        messages=[{"role": "user", "content": prompt}],
        functions=[FlexiblePatch.openai_schema],
        function_call={"name": "flexible_patch"},
    )

    json_response = json.loads(response.choices[0].message.function_call.arguments)
    patch = FlexiblePatch(**json_response)
    patched_file = patch_file(filedata, patch.changes)
    with open("/tmp/flexpatch", "w") as file:
        file.write(patch.generate())
    with open(args.output, "w") as file:
        file.write(patched_file)
