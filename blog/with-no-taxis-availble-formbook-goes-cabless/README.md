# With No Taxis Available, FORMBOOK Goes Cab-less

## Abstract
On September 7, 2021, Microsoft confirmed a vulnerability for the browser rendering engine used in several applications such as those within the Microsoft Office suite. Within 3 days, proof-of-concept code was released, highlighting the maturity of the exploit development ecosystem - underscoring the importance of proactive threat hunting and patch management strategies.

Based on telemetry, we observed this exploit used in conjunction with the FORMBOOK information stealer, we also identified an adversary tradecraft oversight that led to us connecting, what appeared to be, campaign testing infrastructure and a FORMBOOK phishing campaign targeting manufacturing victims with global footprints.

This post details the tactics, techniques, and procedures (TTPs) of this campaign. Our goal is to enable detection capabilities for security practitioners using the Elastic Stack and any readers concerned with the CVE-2021-40444 vulnerability or campaigns related to FORMBOOK.


## URL

https://

## Artifacts
Artifacts and code snippets from the blog post.

| Artifact | Description | Note |  
| 70defbb4b846868ba5c74a526405f2271ab71de01b24fbe2d6db2c7035f8a7df | SHA256        | Request Document.docx | Testing phase email attachment       |
|------------------------------------------------------------------|---------------|-----------------------|--------------------------------------|
| 7c98db2063c96082021708472e1afb81f3e54fe6a4a8b8516e22b3746e65433b | SHA256        | comres.cab            | Testing phase CAB archive            |
| 363837d5c41ea6b2ff6f6184d817c704e0dc5749e45968a3bc4e45ad5cf028d7 | SHA256        | 1.doc.inf             | Testing phase VMProtect DLL          |
| 22cffbcad42363841d01cc7fef290511c0531aa2b4c9ca33656cc4aef315e723 | SHA256        | IEcache.inf           | Testing phase DLL loader             |
| e2ab6aab7e79a2b46232af87fcf3393a4fd8c4c5a207f06fd63846a75e190992 | SHA256        | Pope.txt              | Testing phase JavaScript             |
| 170eaccdac3c2d6e1777c38d61742ad531d6adbef3b8b031ebbbd6bc89b9add6 | SHA256        | Profile.rar           | Production phase email attachment    |
| d346b50bf9df7db09363b9227874b8a3c4aafd6648d813e2c59c36b9b4c3fa72 | SHA256        | document.docx         | Production phase compressed document |
| 776df245d497af81c0e57fb7ef763c8b08a623ea044da9d79aa3b381192f70e2 | SHA256        | abb01.exe             | Production phase dropper             |
| 95e03836d604737f092d5534e68216f7c3ef82f529b5980e3145266d42392a82 | SHA256        | Profile.html          | Production phase JavaScript          |
| bd1c1900ac1a6c7a9f52034618fed74b93acbc33332890e7d738a1d90cbc2126 | SHA256        | yxojzzvhi0.exe        | FORMBOOK malware                     |
| 0c560d0a7f18b46f9d750e24667721ee123ddd8379246dde968270df1f823881 | SHA256        | DWG.rar               | Generic phase email attachment       |
| 5a1ef64e27a8a77b13229b684c09b45a521fd6d4a16fdb843044945f12bb20e1 | SHA256        | D2110-095.gz          | Generic phase email attachment       |
| 4216ff4fa7533209a6e50c6f05c5216b8afb456e6a3ab6b65ed9fcbdbd275096 | SHA256        | D2110-095.exeDWG.exe  | FORMBOOK malware                     |
| admin0011[@]issratech.com                                        | Email address |                       | Phishing sending email address       |
| admin010[@]backsjoy.com                                          | Email address |                       | Phishing sending email address       |
| admin012[@]leoeni.com                                            | Email address |                       | Phishing sending email address       |
| issratech[.]com                                                  | Domain name   |                       | Adversary controlled domain          |
| backsjoy[.]com                                                   | Domain name   |                       | Adversary controlled domain          |
| leonei[.]com                                                     | Domain name   |                       | Adversary controlled domain          |
| 2[.]56[.]59[.]105                                                | IP Address    |                       | IP address of issratech[.]com        |
| 212[.]192[.]241[.]173                                            | IP Address    |                       | IP address of backsjoy[.]com         |
| 52[.]128[.]23[.]153                                              | IP Address    |                       | IP address of leonei[.]com           |
| 104[.]244[.]78[.]177                                             | IP Address    |                       | Adversary controlled IP address      |
| [FORMBOOK YARA Rule](Windows_Trojan_FORMBOOK.yar) | YARA rule to identify the FORMBOOK information stealer. | |  
