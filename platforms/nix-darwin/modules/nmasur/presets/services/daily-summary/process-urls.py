import requests
from bs4 import BeautifulSoup
import json
import os
import sys
from datetime import datetime
from urllib.parse import urlparse


def find_urls(data):
    urls = []
    if isinstance(data, dict):
        for key, value in data.items():
            if key == 'url' and isinstance(value, str):
                urls.append(value)
            else:
                urls.extend(find_urls(value))
    elif isinstance(data, list):
        for item in data:
            urls.extend(find_urls(item))
    return urls


def main():
    if len(sys.argv) > 1:
        base_dir = sys.argv[1]
        if not os.path.isdir(base_dir):
            print(f"Error: Directory '{base_dir}' not found.")
            sys.exit(1)
    else:
        base_dir = '.'

    today = datetime.now().strftime('%Y.%m.%d')
    output_filename = 'todays_urls.md'
    output_filepath = os.path.join(base_dir, output_filename)
    url_titles = {}

    print(f"Searching for files in '{base_dir}' "
          f"starting with 'snapshot-{today}-'")

    with open(output_filepath, 'w') as md_file:
        md_file.write(f'# URLs from Sidebery Snapshots for '
                      f'{today.replace(".", "-")}\n\n')

        files_processed = 0
        for filename in sorted(os.listdir(base_dir)):
            # Debugging print removed
            if (filename.startswith(f'snapshot-{today}-')
                    and filename.endswith('.json')):
                files_processed += 1
                print(f"Processing file: "
                      f"{os.path.join(base_dir, filename)}")

                # Extract and format date and time from filename
                # Example: snapshot-2026.01.25-13.19.29.json
                clean_filename = (filename.replace('snapshot-', '')
                                  .replace('.json', ''))
                date_time_parts = clean_filename.split('-', 1)

                formatted_date = date_time_parts[0].replace('.', '-')
                formatted_time = date_time_parts[1].replace('.', ':')

                datetime_str = f"{formatted_date} {formatted_time}"

                md_file.write(f'## {datetime_str}\n\n')

                with open(os.path.join(base_dir, filename), 'r') as json_file:
                    try:
                        data = json.load(json_file)
                        urls = find_urls(data)
                        print(f"  Found {len(urls)} URLs")
                        for url in urls:
                            if url not in url_titles:
                                try:
                                    # Get title of URL
                                    res = requests.get(
                                       url,
                                       timeout=10,
                                       allow_redirects=True
                                    )
                                    soup = BeautifulSoup(
                                        res.text,
                                        'html.parser'
                                    )
                                    if soup.title and soup.title.string:
                                        title = soup.title.string.strip()
                                    else:
                                        domain = urlparse(url).netloc
                                        title = domain if domain else url
                                    url_titles[url] = title
                                except requests.exceptions.InvalidSchema:
                                    continue
                                except Exception:
                                    domain = urlparse(url).netloc
                                    title = domain if domain else url
                                    url_titles[url] = title
                            if url in url_titles:
                                title = url_titles[url]
                                md_file.write(f'- [{title}]({url})\n')
                        md_file.write('\n')
                    except json.JSONDecodeError:
                        print(f"  Error decoding JSON in {filename}")
                        md_file.write('- Error decoding JSON\n\n')

        if files_processed == 0:
            print("No files found for today.")

    print(f"Processing complete. Output written to {output_filepath}")


if __name__ == '__main__':
    main()
