# Climbing the Pyramid with Celestial-themed Malware

## Abstract
The Deimos trojan (AKA Jupyter Infostealer, SolarMarker) is a malware tool first reported in 2020, but has been in active development and employs advanced defensive countermeasures used to frustrate analysis. This post details the campaign TTPs through the malware indicators.

## URL

## Artifacts
Artifacts and code snippets from the blog post.

| Artifact | Description | Note |  
| - | - | - |
| f268491d2f7e9ab562a239ec56c4b38d669a7bd88181efb0bd89e450c68dd421 | Lure file | - |  
| af1e952b5b02ca06497e2050bd1ce8d17b9793fdb791473bdae5d994056cb21f | Malware installer | - |  
| d6e1c6a30356009c62bc2aa24f49674a7f492e5a34403344bfdd248656e20a54 | .NET DLL file | - |  
| 216[.]230[.]232[.]134 | Command and control | - |  
| [Deimos YARA Rule](windows_trojan_deimos.yar) | YARA rule to identify the Deimos DLL file. | - |  
