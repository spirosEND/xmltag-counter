# XML Tag Counter

A PowerShell script that recursively searches through XML files in a directory and counts occurrences of a specific XML tag. Perfect for analyzing large batches of XML files and extracting tag statistics.

## Features

- 🔍 **Recursive directory scanning** - Searches through all subdirectories automatically
- 📁 **Multiple file extension support** - Defaults to `.xml` and `.out` files, fully customizable
- 🌐 **XML namespace handling** - Automatically handles XML files with namespaces (no configuration needed)
- 🔤 **Case-sensitive tag matching** - Exact tag name matching (e.g., `RecordID` ≠ `RecordId`)
- 📊 **Progress tracking** - Optional progress indicator with estimated time remaining
- 🐛 **Debug mode** - Detailed debugging information for troubleshooting
- 📋 **Per-file breakdown** - Shows count for each file containing the tag
- ⚠️ **Error handling** - Gracefully skips invalid XML files with warnings
- ⏱️ **Performance metrics** - Shows processing time and file statistics

## Requirements

- **PowerShell 5.1** or later
- **Windows OS** (uses Windows PowerShell cmdlets)

## Installation

1. Clone this repository:
   git clone https://github.com/spirosEND/xmltag-counter.git
   cd xmltag-counter

2. Open powershell, cd thePathToTheXmlFolder

3. type .\count_xml_tags.ps1 -Directory "C:\path\to\xml\folder\xmlFolder" -TagName "DesiredTagName" -ShowProgress

4. Enjoy! 


## Debug Mode

Get detailed information about XML structure and tag detection:

.\count_xml_tags.ps1 -Directory "C:\path\to\xml\xmlFolderer" -TagName "DesiredTagName" -ShowDebug



## How It Works

1. File Discovery: Recursively scans the specified directory for files matching the given extensions
2. XML Parsing: Each file is parsed as XML using PowerShell's built-in XML parser
3. Tag Counting: Uses namespace-agnostic XPath queries to find all elements matching the tag name
4. Aggregation: Counts occurrences across all files and provides both total and per-file statistics



## Case Sensitivity