#!/usr/bin/env python3
"""Parse RSS/Atom XML from stdin and output TSV: title\tlink\tsource."""

import sys
import xml.etree.ElementTree as ET


def parse_rss(xml_text, source_name):
    """Parse RSS 2.0 or Atom feed, yield (title, link, source) tuples."""
    try:
        root = ET.fromstring(xml_text)
    except ET.ParseError:
        return

    # Atom namespace
    atom_ns = "{http://www.w3.org/2005/Atom}"

    # RSS 2.0: root is <rss>, items under <channel><item>
    if root.tag == "rss":
        for item in root.iter("item"):
            title = item.findtext("title", "").strip()
            link = item.findtext("link", "").strip()
            if title and link:
                yield (title, link, source_name)

    # Atom: root is <feed>, entries under <entry>
    elif root.tag == f"{atom_ns}feed" or root.tag == "feed":
        for entry in root.iter(f"{atom_ns}entry") or root.iter("entry"):
            title_el = entry.find(f"{atom_ns}title")
            if title_el is None:
                title_el = entry.find("title")
            title = (title_el.text or "").strip() if title_el is not None else ""

            link = ""
            link_el = entry.find(f"{atom_ns}link")
            if link_el is None:
                link_el = entry.find("link")
            if link_el is not None:
                link = link_el.get("href", "").strip()

            if title and link:
                yield (title, link, source_name)


def main():
    if len(sys.argv) < 2:
        source_name = "Unknown"
    else:
        source_name = sys.argv[1]

    xml_text = sys.stdin.read()
    for title, link, source in parse_rss(xml_text, source_name):
        # Sanitize: remove tabs and newlines from title
        clean_title = title.replace("\t", " ").replace("\n", " ").replace("\r", "")
        clean_link = link.replace("\t", " ").replace("\n", "").replace("\r", "")
        print(f"{clean_title}\t{clean_link}\t{source}")


if __name__ == "__main__":
    main()
