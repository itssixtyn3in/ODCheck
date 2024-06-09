# ODCheck

ODCheck is a C2-like proof-of-concept solution designed to empower security professionals in evaluating their alerting systems against specific cyber-attacks within the Office 365 environment. This tool simplifies the process of testing local security solutions, particularly in scenarios involving data exfiltration through OneDrive and Sharepoint traffic.


| MITRE Technique             | ID |
| :---------------- | :------: |
| Exfiltration over C2 Channel        |   [T1041](https://attack.mitre.org/techniques/T1041/)   |
| Masquerading: Right-to-Left Override            |   [T1036.002](https://attack.mitre.org/techniques/T1036/002/)   |
| Modify Registry    |  [T1112](https://attack.mitre.org/techniques/T1112/)   |
| Automated Collection |  [T1119](https://attack.mitre.org/techniques/T1119/)   |


 **Establishing A Sync Connection**
 
 The Microsoft Teams client in it's default configuration allows users to add website tabs to private conversations, or Teams channels. The website tab option can be linked to external pages, which can be used as a jumping point to have users sync specific Sharepoint libraries using the ODOpen:// protocol handler. For further details regarding this please see https://www.collectingflags.com

 Once this sync has been established, then ODCheck can assist with creating a C2 connection. 

 **Setting Up ODCheck**
 
```
# You will need to have the PS2EXE PowerShell module installed 
Install-Module PS2EXE

# Copy the full ODCheck Folder from Github
git clone https://github.com/itssixtyn3in/ODCheck

# Run Manager.ps1 to start the Wizard
.\manager.ps1
```
ODCheck provides a few customization options from here that can be used, depending on what all you want to test.

- Option 1) This will customize the variables of the files that ODCheck will watch out for when the agent has been executed on a host. The setup will also require that you know the tenant and document library name that you will be using for the mutual sync connection. When setting up a document library that can be 

- Option 2) Inject a file name with the Right-To-Left-Override character to spoof the file extension.

- Option 3) Packages the script into an EXE file.

**Running commands**

Once a sync connection has been set up to the Sharepoint Document Library and the ODCheck client has been executed, then commands can be executed by dropping the payload files into the shared sync folder. 

https://github.com/itssixtyn3in/ODCheck/assets/130003354/36ea337f-ed2c-427e-9d4e-9628c812404f

