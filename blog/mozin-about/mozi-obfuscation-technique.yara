rule Mozi_Obfuscation_Technique
{
  meta:
    author =  "Elastic Security, Lars Wallenborn (@larsborn)"
    description = "Detects obfuscation technique used by Mozi botnet."
  strings:
    $a = { 55 50 58 21
           [4]
           00 00 00 00
           00 00 00 00
           00 00 00 00 }
  condition:
    all of them
}
