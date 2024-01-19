import argparse
import os
import sys
from typing import List, Optional, Tuple


def parse_unified_diff(patch_file: str) -> List[Tuple[str, str, List[str]]]:
    """Parse a unified diff patch file.

    Args:
        patch_file: The path to the unified diff patch file.

    Returns:
        A list of tuples, where each tuple contains the change type ('add' or 'del'),
        the changed line, and the list of context lines.

    """
    changes: List[Tuple[str, str, List[str]]] = []
    current_context: List[str] = []
    with open(patch_file, "r", encoding="utf-8") as file:
        for line in file:
            if line.startswith("@@"):
                current_context = []
            elif line.startswith(" "):
                current_context.append(line[1:].rstrip())
            elif line.startswith("+") and not line.startswith("+++"):
                changes.append(("add", line[1:].rstrip(), list(current_context)))
            elif line.startswith("-") and not line.startswith("---"):
                changes.append(("del", line[1:].rstrip(), list(current_context)))
    return changes


def find_context_index(content: List[str], context: List[str]) -> Optional[int]:
    """Find the index in the content list where the context list matches.

    Args:
        content: The list of strings representing the content of a file.
        context: The list of strings representing a context of a change.

    Returns:
        The index in the content list immediately after the context if found,
        otherwise, None.

    """
    for i, _ in enumerate(content):
        if content[i : i + len(context)] == context:
            return i + len(context)
    return None


def apply_changes(
    source_file: str, changes: List[Tuple[str, str, List[str]]], output_file: str
) -> None:
    """Apply changes from a patch file to the source file and write to output file.

    Args:
        source_file: The path to the source file to which changes will be applied.
        changes: A list of tuples containing the changes to be applied.
        output_file: The path where the modified source file will be saved.

    """
    with open(source_file, "r", encoding="utf-8") as file:
        content: List[str] = file.readlines()

    sorted_changes: List[Tuple[int, str, str]] = []
    for change_type, change, context in changes:
        context = [line + "\n" for line in context]
        context_index = find_context_index(content, context)
        if context_index is None and context:
            for reduce_context in range(1, len(context)):
                context_index = find_context_index(content, context[reduce_context:])
                if context_index is not None:
                    break

        if context_index is not None:
            sorted_changes.append((context_index, change_type, change))
        else:
            print(
                f"Warning: Context for change '{change}' not found. Skipping this change."
            )

    # Sort the changes by context index in descending order
    sorted_changes.sort(key=lambda x: x[0], reverse=True)
    for context_index, change_type, change in sorted_changes:
        if change_type == "add":
            content.insert(context_index, change + "\n")
        elif change_type == "del" and (change + "\n") in content:
            content.remove(change + "\n")

    with open(output_file, "w", encoding="utf-8") as file:
        file.writelines(content)


def main() -> None:
    """Main function to apply a unified diff patch to a source file.

    The function takes a patch file and a source file from command-line arguments,
    applies the changes contained in the patch file to the source file, and writes
    the patched file to the specified output path or overwrites the source file if
    no output path is given.
    """
    parser = argparse.ArgumentParser(
        description="Apply a unified diff patch to a source file."
    )
    parser.add_argument(
        "patch_file", type=str, help="Path to the unified diff patch file"
    )
    parser.add_argument(
        "source_file", type=str, help="Path to the source file to patch"
    )
    parser.add_argument(
        "-o",
        "--output_file",
        type=str,
        help="Path to save the patched file",
        default=None,
    )

    args = parser.parse_args()

    if not os.path.exists(args.patch_file):
        print(f"Error: Patch file '{args.patch_file}' does not exist.", file=sys.stderr)
        sys.exit(1)

    if not os.path.exists(args.source_file):
        print(
            f"Error: Source file '{args.source_file}' does not exist.", file=sys.stderr
        )
        sys.exit(1)

    output_file = args.output_file if args.output_file else args.source_file

    try:
        changes = parse_unified_diff(args.patch_file)
    except Exception as e:
        print(
            f"Error: Failed to parse the patch file '{args.patch_file}': {e}",
            file=sys.stderr,
        )
        sys.exit(1)

    try:
        apply_changes(args.source_file, changes, output_file)
        print(f"Patch applied to {output_file}")
    except Exception as e:
        print(
            f"Error: Failed to apply changes to the source file '{args.source_file}': {e}",
            file=sys.stderr,
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
