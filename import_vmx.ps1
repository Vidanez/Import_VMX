connect-viserver -server ENTER VCENTER FQDN HERE
#####################################################################
# Add .VMX (Virtual Machines) to Inventory from Storage Cluster #
#####################################################################
 
# Variables: Update these to the match the environment
$Cluster = &quot;ENTER CLUSTER NAME HERE&quot;
$Datastores = get-datastorecluster &quot;ENTER DATASTORE CLUSTER NAME HERE&quot; | get-datastore
$VMFolder = &quot;ENTER FOLDER NAME HERE&quot;
$ESXHost = Get-Cluster $Cluster | Get-VMHost | select -First 1
 
foreach($Datastores in $Datastores) {
# Set up Search for .VMX Files in Datastore Cluster
$ds = Get-Datastore -Name $Datastores | %{Get-View $_.Id}
$SearchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
$SearchSpec.matchpattern = &quot;*.vmx&quot;
$dsBrowser = Get-View $ds.browser
$DatastorePath = &quot;[&quot; + $ds.Summary.Name + &quot;]&quot;
 
# Find all .VMX file paths in Datastore variable and filters out .snapshot
$SearchResult = $dsBrowser.SearchDatastoreSubFolders($DatastorePath, $SearchSpec) | where {$_.FolderPath -notmatch &quot;.snapshot&quot;} | %{$_.FolderPath + ($_.File | select Path).Path}
 
# Register all .VMX files with vCenter
foreach($VMXFile in $SearchResult) {
New-VM -VMFilePath $VMXFile -VMHost $ESXHost -Location $VMFolder -RunAsync
}
}
