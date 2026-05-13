import os
import re
import hashlib
import logging
import argparse
import json

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# Utility Functions (Copied from Docs2saurus/d2c2.py)

def generate_unique_id(content):
    return hashlib.md5(content.encode('utf-8')).hexdigest()

def escape_title(title):
    if '"' in title:
        title = title.replace('"', '\\"')
    return f'title: "{title}"\n'

def sanitize_and_clean_name(name, max_length=20):
    """
    Strips list indicators, sanitizes, and truncates the name to ensure it is within the maximum length.

    Args:
        name (str): The name to be sanitized and cleaned.
        max_length (int): The maximum length for the cleaned name.
    """
    # Remove invalid filesystem characters: < > : " / \ | ? * ! % @ # $ ~ ` ^ [ ] { }
    name = re.sub(r'[<>:"/\\|?*!%@#$~`^\[\]{}]', '', name).strip()
    # Also remove leading list indicators
    name = re.sub(r'^[\.-]+\s*', '', name).strip()
    # ISSUE-006: Normalize whitespace - replace multiple spaces with single space
    name = re.sub(r'\s+', ' ', name)
    # Replace periods with underscores (but not in extension)
    name = re.sub(r'\.+', '_', name)
    # Remove trailing spaces
    name = name.rstrip()

    # Truncate the name if it exceeds the maximum length
    base, ext = os.path.splitext(name)
    if len(base) > max_length:
        # ISSUE-007: Smarter truncation - try to break at word boundary
        if max_length <= 3:
            base = base[:max_length]
        else:
            # Try to truncate at last space within max_length
            truncated = base[:max_length-3]  # Leave room for '...'
            last_space = truncated.rfind(' ')
            if last_space > max_length // 2:  # Only use word boundary if it's not too short
                base = base[:last_space] + '...'
            else:
                base = base[:max_length-3] + '...'

    # Disallow invalid folder characters like . or space in the last 5 characters
    # ISSUE-009: Only remove spaces/dots at the VERY END, not in the middle
    base = base.rstrip(' .')  # Only strip trailing spaces and dots
    # Also remove any spaces/dots that are in the last 5 chars if they cause issues
    if len(base) > 5:
        # Only remove problematic chars from the last 5 chars if they exist there
        suffix = base[-5:]
        suffix = re.sub(r'[ ._]', '', suffix)
        base = base[:-5] + suffix
    else:
        base = re.sub(r'[ .]', '', base)

    base = base.replace('.', '')
    return base + ext

def sanitize_no_digits(name, max_length=20):
    """
    Alternative sanitization function that removes leading digits and periods.
    Note: Also removes underscores from the last 5 characters.
    Args:
        name (str): The name to be sanitized and cleaned.
        max_length (int): The maximum length for the cleaned name.
    """
    # Remove invalid filesystem characters: < > : " / \ | ? * ! % @ # $ ~ ` ^ [ ] { }
    name = re.sub(r'[<>:"/\\|?*!%@#$~`^\[\]{}]', '', name)
    # Remove periods
    name = re.sub(r'\.', '', name)
    # ISSUE-006: Normalize whitespace
    name = re.sub(r'\s+', ' ', name)
    # Remove leading digits and spaces
    name = re.sub(r'^[\d\s]+', '', name)
    # Remove trailing spaces
    name = name.rstrip()

    # Truncate the name if it exceeds the maximum length
    base, ext = os.path.splitext(name)
    if len(base) > max_length:
        # ISSUE-007: Smarter truncation
        if max_length <= 3:
            base = base[:max_length]
        else:
            truncated = base[:max_length-3]
            last_space = truncated.rfind(' ')
            if last_space > max_length // 2:
                base = base[:last_space] + '...'
            else:
                base = base[:max_length-3] + '...'

    # Disallow invalid folder characters like . or space in the last 5 characters
    # ISSUE-009: Only remove spaces/dots at the VERY END, not in the middle
    base = base.rstrip(' .')  # Only strip trailing spaces and dots
    # Also remove any spaces/dots that are in the last 5 chars if they cause issues
    if len(base) > 5:
        # Only remove problematic chars from the last 5 chars if they exist there
        suffix = base[-5:]
        suffix = re.sub(r'[ ._]', '', suffix)
        base = base[:-5] + suffix
    else:
        base = re.sub(r'[ .]', '', base)

    base = base.replace('.', '')
    return base + ext

def write_md_file(path, lines, front_matter=None):
    """
    Writes content and front matter to a Markdown file.

    Args:
        path (str): The path to the Markdown file.
        lines (list): Content lines to write.
        front_matter (str, optional): The front matter to include at the top of the file.
    """
    os.makedirs(os.path.dirname(path), exist_ok=True)  # Ensure parent directories exist
    with open(path, 'w', encoding='utf-8') as md_file:
        # Write the front matter if provided
        if front_matter:
            md_file.write('---\n')  # Start of front matter
            md_file.write(front_matter)  # Write the front matter content
            md_file.write('---\n\n')  # End of front matter and add a blank line

        # Write content lines
        for line in lines:
            # Remove '**' markers from the line
            cleaned_line = line.replace('**', '')
            # Write the cleaned line to the file
            md_file.write(cleaned_line + '\n')


def parse_json_structure(json_data, parent_path=""):
    """
    Parse JSON structure and convert to internal node format.
    JSON format: {"name": "Item", "type": "file|directory", "body": "content", "children": []}
    
    Args:
        json_data (dict): The JSON data containing the structure.
        parent_path (str): The parent path for generating unique IDs.
    
    Returns:
        dict: The hierarchical structure compatible with create_structure().
    """
    root = {'Children': [], 'BodyLines': [], 'UniqueID': 'root'}
    
    def process_node(item, parent_node):
        """Process a single JSON node and its children."""
        name = item.get('name', 'Unnamed')
        node_type = item.get('type', 'file')  # Default to file
        body = item.get('body', '')
        children = item.get('children', [])
        
        # Generate unique ID from name and parent path
        unique_id = generate_unique_id(f"{parent_path}_{name}")
        
        # Create node
        node = {
            'Content': name,
            'Children': [],
            'BodyLines': body.split('\n') if body else [],
            'UniqueID': unique_id,
            'FULLLINE': name,
            'IndentLevel': 0  # Not used in JSON mode
        }
        
        # Process children recursively
        if children and node_type == 'directory':
            for child in children:
                process_node(child, node)
        
        # Add to parent
        parent_node['Children'].append(node)
    
    # Process top-level items
    items = json_data if isinstance(json_data, list) else json_data.get('children', [])
    for item in items:
        process_node(item, root)
    
    return root

def categorize_lines(list_content):
    """
    Categorizes lines from the list content into a hierarchical structure.

    Args:
        list_content (list): The list of lines to categorize.

    Returns:
        dict: The hierarchical structure of categorized lines.
    """
    stack = []
    root = {'Children': [], 'BodyLines': [], 'UniqueID': 'root'}

    for line_number, line in enumerate(list_content, 1):
        # Check if the line should be ignored based on the new rule
        if line_number <= 3 and line.strip().startswith('title:'):
            logging.info(f"Ignoring line {line_number} as it starts with 'title:' within the first 3 lines.")
            continue # Skip this line

        # Preserve original line for body lines
        original_line = line.rstrip()
        # Sanitize and clean the line for structure determination
        line_content = sanitize_and_clean_name(line)
        indent_level = len(line) - len(line.lstrip())
        content = line_content.strip()

        if not content:
            continue  # Skip empty lines

        # Body lines are marked with ** markers
        is_body_line = '**' in original_line

        if is_body_line:
            if stack:
                parent_node = stack[-1]
            else:
                parent_node = root  # Attach to root if no parent
            parent_node.setdefault('BodyLines', []).append(original_line)
            logging.info(f"  -> Attached as body line to {parent_node.get('Content', 'root')}")
            continue

        unique_id = generate_unique_id(f"{indent_level}_{content}_{line_number}")
        node = {
            'IndentLevel': indent_level,
            'Content': content,
            'Children': [],
            'BodyLines': [],
            'UniqueID': unique_id,
            'FULLLINE': line
        }

        while stack and stack[-1]['IndentLevel'] >= indent_level:
            stack.pop()

        if stack:
            parent_node = stack[-1]
            parent_node['Children'].append(node)
        else:
            root['Children'].append(node)

        stack.append(node)
        
    return root

# Structure Creation Function (Copied from Docs2saurus/d2c2.py)
def create_structure(node, parent_path, sanitize_function, allow_empty_folders):
    """
    Recursively creates directories and Markdown files based on the hierarchical structure.

    Args:
        node (dict): The current node in the hierarchical structure.
        parent_path (str): The path to the parent directory.
        sanitize_function (function): The function to use for sanitizing names.
        allow_empty_folders (bool): Whether to allow empty folders.
    """
    for child in node.get('Children', []):
        content = child['Content']
        content_FULLLINE = child['FULLLINE']

        # ISSUE-005: Check for quoted extensions (e.g. "notes.txt") using original line
        quoted_ext = None
        quoted_base = None
        full_line_stripped = content_FULLLINE.strip()
        if full_line_stripped.startswith('"') and full_line_stripped.endswith('"'):
            inner = full_line_stripped[1:-1]
            inner_base, ext = os.path.splitext(inner)
            if ext:
                quoted_ext = ext
                quoted_base = inner_base

        if quoted_ext:
            # Sanitize only the base name, then reattach the extension
            sanitized_name = sanitize_function(quoted_base)
            sanitized_name += quoted_ext
        else:
            sanitized_name = sanitize_function(content)

        current_path = os.path.join(parent_path, sanitized_name)

        # Normalize paths to ensure consistent comparison
        normalized_parent_path = os.path.normpath(parent_path)
        normalized_current_path = os.path.normpath(current_path)

        # Ensure the path is within the intended directory
        if not os.path.commonpath([normalized_current_path, normalized_parent_path]) == normalized_parent_path:
            raise ValueError(f"Invalid path detected: {normalized_current_path} is not within {normalized_parent_path}")

        # Handle extension
        base, ext = os.path.splitext(sanitized_name)
        if quoted_ext:
            md_file_path = os.path.join(parent_path, base + quoted_ext)
        elif ext:
            md_file_path = os.path.join(parent_path, sanitized_name)
        else:
            md_file_path = os.path.join(parent_path, base + '.md')

        # ISSUE-004: Handle name conflicts - check actual output path
        if child['Children'] or allow_empty_folders:
            # For directories, check directory path
            if os.path.exists(normalized_current_path):
                sanitized_name += '_' + child['UniqueID'][:6]
                normalized_current_path = os.path.join(normalized_parent_path, sanitized_name)
                md_file_path = os.path.join(normalized_current_path, 'index.md')
        else:
            # For leaf files, check file path
            if os.path.exists(md_file_path):
                base += '_' + child['UniqueID'][:6]
                md_file_path = os.path.join(parent_path, base + '.md')
                sanitized_name = base
                normalized_current_path = os.path.join(normalized_parent_path, sanitized_name)

        # Prepare the front matter with proper escaping
        title_line = escape_title(content_FULLLINE)
        front_matter = f"---\n{title_line}---\n\n"

        if child['Children']:
            # Create a directory for nodes with children
            os.makedirs(normalized_current_path, exist_ok=True)
            # Create an index.md file for the directory
            md_file_path = os.path.join(normalized_current_path, 'index.md')
            write_md_file(md_file_path, child.get('BodyLines', []), front_matter)
            # Recursively create structure for child nodes
            create_structure(child, normalized_current_path, sanitize_function, allow_empty_folders)
        elif allow_empty_folders:
            # Always create directories for leaf nodes when flag is set
            os.makedirs(normalized_current_path, exist_ok=True)
            md_file_path = os.path.join(normalized_current_path, 'index.md')
            write_md_file(md_file_path, child.get('BodyLines', []), front_matter)
        else:
            # Create a .md file for leaf nodes
            write_md_file(md_file_path, child.get('BodyLines', []), front_matter)


def main():
    parser = argparse.ArgumentParser(description='Process a Markdown list or JSON structure into a structured directory of Markdown files.')
    parser.add_argument('input_file', help='Path to the input file (text or JSON).')
    parser.add_argument('output_dir', help='Path to the output base directory.')
    parser.add_argument('--format', choices=['auto', 'text', 'json'], default='auto',
                        help='Input format: auto-detect, text, or json.')
    parser.add_argument('--remove-digits', action='store_true', help='Use alternative sanitization to remove digits.')
    parser.add_argument('--allow-empty-folders', action='store_true', help='Allow the creation of empty folders.')

    args = parser.parse_args()

    input_file = args.input_file
    base_dir = args.output_dir
    use_alternative_sanitization = args.remove_digits
    allow_empty_folders = args.allow_empty_folders
    format_mode = args.format  # This should work now

    # ISSUE-011: Input validation
    if not os.path.exists(input_file):
        print(f"Error: Input file '{input_file}' does not exist.")
        return 1
    
    if not os.path.isfile(input_file):
        print(f"Error: '{input_file}' is not a file.")
        return 1
    
    if os.path.getsize(input_file) == 0:
        print(f"Error: Input file '{input_file}' is empty.")
        return 1

    try:
        logging.info("Starting processing...")
        os.makedirs(base_dir, exist_ok=True)

        # Read the input file
        with open(input_file, 'r', encoding='utf-8') as f:
            content = f.read().strip()
        
        # Detect format
        if format_mode == 'auto':
            # Auto-detect: JSON starts with { or [
            if content.startswith('{') or content.startswith('['):
                format_mode = 'json'
            else:
                format_mode = 'text'
        
        logging.info(f"Using {format_mode} mode")
        
        if format_mode == 'json':
            # Parse JSON
            json_data = json.loads(content)
            root = parse_json_structure(json_data)
        else:
            # Parse text (original behavior)
            list_content = content.splitlines()
            root = categorize_lines(list_content)

        # Select the sanitization function based on the argument
        if use_alternative_sanitization:
            sanitize_function = sanitize_no_digits
        else:
            sanitize_function = sanitize_and_clean_name

        # Create the folder structure and .md files using the selected sanitization function
        create_structure(root, base_dir, sanitize_function, allow_empty_folders)

        logging.info("Processing completed successfully!")

    except json.JSONDecodeError as e:
        logging.error(f"Invalid JSON in input file: {str(e)}")
    except FileNotFoundError:
        logging.error(f"Error: Input file not found at {input_file}")
    except Exception as e:
        logging.error(f"An error occurred during processing: {str(e)}")

if __name__ == "__main__":
    main()
