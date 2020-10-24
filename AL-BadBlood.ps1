
# lab configs
$labSources = 'C:\LabSources' #here are the lab sources
$vmDrive = 'C:' #this is the drive where to create the virtual machines
$labName = 'BADBLOOD' #the name of the lab
#create the folder path for the lab using Join-Path
$labPath = Join-Path -Path $vmDrive -ChildPath $labName

#create the target directory if it does not exist
if (-not (Test-Path $labPath)) { New-Item $labPath -ItemType Directory | Out-Null }

#once this is done , The base image of windows server 2019 will start
#or if you have a base image of the OS , just copy it to the BADBLOOD directory this will save time.

#create an empty lab template and define where the lab XML files and the VMs will be stored
New-LabDefinition  -VmPath $labPath -Name $labName -DefaultVirtualizationEngine HyperV

#make the network definition
Add-LabVirtualNetworkDefinition -Name $labName -AddressSpace 192.168.60.0/24

#and the domain definition with the domain admin account
Add-LabDomainDefinition -Name WAKANDA.LOCAL -AdminUser Administrator -AdminPassword Password123

Set-LabInstallationCredential -Username Administrator -Password Password123

#The below code will be used for all vms as the default and base 

$PSDefaultParameterValues = @{
    'Add-LabMachineDefinition:Network' = $labName
    'Add-LabMachineDefinition:ToolsPath'= "$labSources\Tools"
    'Add-LabMachineDefinition:DnsServer1' = '192.168.60.10'
    'Add-LabMachineDefinition:Memory' = 2096MB
    'Add-LabMachineDefinition:OperatingSystem' = 'Windows Server 2019 Standard Evaluation (Desktop Experience)'
}

#the first machine is the root domain controller
Add-LabMachineDefinition -Name WAKDANDA-DC -IpAddress 192.168.60.10  -DomainName WAKANDA.LOCAL -Roles RootDC 

#-----------------here we add our servers and whatever else we want.-----------#


# We add a normal server and join it to the domain  'WAKANDA.LOCAL' ------------#
Set-LabInstallationCredential -Username Administrator -Password Password123
Add-LabMachineDefinition -Name SHURI-PC  -IpAddress 192.168.60.11  -DomainName WAKANDA.LOCAL


#Now the actual work begins.
Install-Lab

Show-LabDeploymentSummary -Detailed

#---------Checkpoint of the LAB before we mess it up ---------#
Checkpoint-LabVM -All -SnapshotName Clean-install


#-------- Install badblood:edit badblood and set the variable to badblood to automate this process --------------#
Copy-LabFileItem -Path C:\LabSources\Tools\BadBlood-master -ComputerName WAKDANDA-DC -DestinationFolderPath C:\Temp
Invoke-LabCommand -ScriptBlock { . C:\Temp\BadBlood-master\invoke-badblood.ps1 } -ComputerName WAKDANDA-DC -PassThru


