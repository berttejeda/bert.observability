# Mermaid Diagram Based Health Dashboard

This project demonstrates how to dynamically generate and style a Mermaid `architecture-beta` diagram based on shell script execution results, such as a health check or a curl command.

## Overview

Mermaid's `architecture-beta` syntax currently has limited support for inline styling of specific nodes (services) using the standard `style` directive. To work around this and achieve dynamic styling—such as highlighting a failing database node in red—this project uses a bash script (`generate.sh`) to inject custom CSS into the diagram before passing it to the Mermaid CLI (`mmdc`).

## Files
- `diagram.mmd`: The base Mermaid architecture diagram file.
- `generate.sh`: A shell script that reads the base diagram, runs conditions (like `curl`), dynamically injects a `%%{init}%%` JSON block with CSS targeting the failed nodes, and generates the final output image.
- `diagram-result.png`: An example output where the some diagram nodes are styled based on a fail condition, resulting in a red border around the affected node.

## Prerequisites
- [Mermaid CLI (`mmdc`)](https://github.com/mermaid-js/mermaid-cli) installed and available in your `$PATH`.
- `curl` (used for the example condition).
- Standard Unix utilities: `awk`, `cp`, `rm`.

## Usage

Run the generate script:

```bash
./generate.sh
```

### Debugging

If you want to view the intermediate Mermaid file (`diagram_temp.mmd`) that contains the injected CSS before it is rendered and deleted, use the `--keep-temp-files` flag:

```bash
./generate.sh --keep-temp-files
```

## How It Works

1. The script copies `diagram.mmd` to a temporary file (`diagram_temp.mmd`).
2. It executes one or more conditionals (e.g., checking if `database.local` is responsive).
3. If a condition fails, the script appends the target node's ID (e.g., `db`, `disk1`) to an `error_nodes` array.
4. The script iterates over `error_nodes` and constructs a valid JSON CSS block.
5. `awk` is used to safely prepend the constructed CSS block to the top of `diagram_temp.mmd` as a Mermaid `%%{init}%%` directive. 
6. `mmdc` renders the temporary file into the final PNG (`diagram-w-error.png`).
7. The temporary file is cleaned up.

### Adding New Conditions

You can easily modify `generate.sh` to add more conditions and target different nodes in the architecture diagram:

```bash
# Example Condition 2
if ! ping -c 1 10.0.0.1 >/dev/null; then
    echo "Condition failed for Server! Flagging 'server' node."
    error_nodes+=("server")
fi
```
This will automatically generate the corresponding CSS selector for the `server` node and highlight it in the output diagram.
