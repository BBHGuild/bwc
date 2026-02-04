import re
import os
import sys

def get_valid_bwc_ids(readme_path):
    valid_ids = set()
    try:
        with open(readme_path, 'r', encoding='utf-8') as f:
            content = f.read()
            # Regex to find BWC headers in the table (e.g., "BWC 1.1", "BWC 3.1.2")
            # They are usually inside <h1>, <h2>, <h3> tags in the HTML table
            # Pattern: >BWC (\d+(\.\d+)*)
            matches = re.findall(r'>BWC\s+(\d+(?:\.\d+)*)', content)
            for match in matches:
                if isinstance(match, tuple):
                    valid_ids.add(f"BWC {match[0]}")
                else:
                    valid_ids.add(f"BWC {match}")
    except FileNotFoundError:
        print(f"Error: Could not find {readme_path}")
        sys.exit(1)
    return valid_ids

def scan_incidents(incidents_dir, valid_ids):
    errors = []
    
    # Regex to find BWC citations in incident files
    # Looks for "BWC X.X.X" but tries to avoid capturing the "BWC" in "BWC: ..." header
    # We specifically look for the classification line format usually used:
    # "Primary Classification: BWC 3.1.1" or just "BWC 3.1.1" in text
    citation_pattern = re.compile(r'(BWC\s+\d+(?:\.\d+)*)')

    for root, dirs, files in os.walk(incidents_dir):
        for file in files:
            if not file.endswith(".md") or file == "Incidents.md":
                continue
            
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                lines = f.readlines()
                for i, line in enumerate(lines):
                    # Skip the "Broader Classification: BWC X" lines if we only want to validate specific IDs
                    # But actually we should validate all of them.
                    
                    matches = citation_pattern.findall(line)
                    for match in matches:
                        # Normalize match
                        bwc_id = match.strip()
                        
                        # Ignore "BWC" standalone or "BWC: " header
                        if bwc_id == "BWC": 
                            continue

                        if bwc_id not in valid_ids:
                            # Check if it's a "Top Level" BWC (e.g. BWC 1) that might be valid
                            # The table has "BWC 1: ..." inside <h1>. 
                            # My regex extraction above >BWC (\d...) should catch "BWC 1" if it's there.
                            # Let's verify if the user used "BWC 1" but the table has "BWC 1: Name"
                            
                            errors.append(f"{file}:{i+1} - Invalid Reference '{bwc_id}'")

    return errors

def main():
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    readme_path = os.path.join(base_dir, 'docs/src/README.md')
    incidents_dir = os.path.join(base_dir, 'docs/src/skills/bounty-hunting/references/incidents')

    print(f"Scanning BWC IDs in {readme_path}...")
    valid_ids = get_valid_bwc_ids(readme_path)
    print(f"Found {len(valid_ids)} unique BWC IDs.")

    print(f"Validating incidents in {incidents_dir}...")
    errors = scan_incidents(incidents_dir, valid_ids)

    if errors:
        print("\n❌ Validation Failed! Found invalid BWC references:")
        for err in errors:
            print(err)
        sys.exit(1)
    else:
        print("\n✅ All BWC references are valid.")
        sys.exit(0)

if __name__ == "__main__":
    main()
