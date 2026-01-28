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

## Installation and Execution

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

Tag matching is case-sensitive. The following are treated as different tags:
ProductID ≠ ProductId ≠ productid ≠ PRODUCTID


## Element Counting

The script counts XML elements, not raw text tags. Each <Tag>...</Tag> pair counts as 1 occurrence, not 2.
Example:

<RecordID>123</RecordID>
<RecordID>456</RecordID>

## Troubleshooting

No files found

1. Verify the directory path is correct
2. Check that files with the specified extensions exist
3. Ensure you have read permissions for the directory

## No occurrences found 

1. Verify the tag name is spelled correctly (case-sensitive!)
2. Run with -ShowDebug to see what tags are actually in your XML files
3. Check if the tag might be in a namespace (the script handles this automatically)


## Performance

The script processes files sequentially and is optimized for:

Small to medium files (< 10MB): Very fast
Large files (> 10MB): May take longer, use -ShowProgress to monitor
Many files (100+): Progress indicator recommended
Typical performance:
~50 files/second for average-sized XML files
Processing time scales linearly with file count and size

## Contributions

Contributions are more than welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (git checkout -b feature/AmazingFeature)
3. Commit your changes (git commit -m 'Add some AmazingFeature')
4. Push to the branch (git push origin feature/AmazingFeature)
5. Open a Pull Request

## License
This project is open source and available under the MIT License.

