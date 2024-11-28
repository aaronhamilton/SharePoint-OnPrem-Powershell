<#
    INSTRUCTIONS
      1. Run script to load functions
      2. Call functions as needed from commented-out sections at the top  

    SERVICES ON EACH SERVER
    AppFabric Windows Service (services.msc)
    Distributed Cache Service (SharePoint timer service)
#>

Add-PSSnapIn Microsoft.SharePoint.PowerShell
cls

# Run this if NOT DIGITALLY SIGNED error appears
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# -------------------
#  DAILY MAINTENANCE
# -------------------

# D.CACHE HEALTH STATUS
# Use-CacheCluster;  Get-CacheHost

# BEFORE SERVER REBOOT...
#   GraceShutDownDistributeCache

# AFTER REBOOT...
#   Add-SPDistributedCacheServiceInstance
#   Use-CacheCluster; Get-CacheHost

# -------------------------------------------------
#  CUMULATIVE UPDATES FOR D.CACHE OR APPFABRIC (SP2019 or OLDER) 
# -------------------------------------------------

# GET APPFABRIC VERSION
#  (Get-ItemProperty "C:\Program Files\AppFabric 1.1 for Windows Server\PowershellModules\DistributedCacheConfiguration\Microsoft.ApplicationServer.Caching.Configuration.dll" -Name VersionInfo).VersionInfo.ProductVersion

# STEP 1
#   asnp *sharepoint*
#   Stop-SPDistributedCacheServiceInstance -Graceful
# Step 2 - install EXE
# Step 3 - update config file
# Step 4 - start the instance
#   $instance = Get-SPServiceInstance | ? {$_.TypeName -eq "Distributed Cache" -and $_.Server.Name -eq $env:computername}
#   $instance.Provision()

<# TO PATCH APPFABRIC
  Stop-SPDistributedCacheServiceInstance -Graceful
  $instance = Get-SPServiceInstance | ? {$_.TypeName -eq "Distributed Cache" -and $_.Server.Name -eq $env:computername}
  $instance.Provision()
#>

# --------------------------
#  ADVANCED TROUBLESHOOTING
# --------------------------

# DELETE A CURRUPT INSTANCE
#   $serviceInstance.Delete()
#   Add-SPDistributedCacheServiceInstance
#   Get-CacheHost

# FIX 
# Remove-SPDistributedCacheServiceInstance
# Add-SPDistributedCacheServiceInstance
# ... if it doesn't work, delete the whole thing:
# Delete
# $instanceName ="SPDistributedCacheService Name=AppFabricCachingService"
# $serviceInstance = Get-SPServiceInstance | ? {($_.service.tostring()) -eq $instanceName -and ($_.server.name) -eq $env:computername}
# If($serviceInstance -ne $null) {  $serviceInstance.Delete(); Write-Host "deleted" }
# ... and then do this:
# Add-SPDistributedCacheServiceInstance
#   Use-CacheCluster; Get-CacheHost

# Get-Cache | select Cachename

# STOP THE APPFABRIC WINDOWS SERVICE 
# Stop-CacheCluster
# Start-CacheCluster

# ADD A CACHE HOST (IE ADD A HOST SERVER)
#   Add-CacheHost
#   Add-SPDistributedCacheServiceInstance
#   Use-CacheCluster; Get-CacheHost

# REMOVE A HOST FROM THE CLUSTER (IE REMOVE A HOST SERVER)
# Unregister-CacheHost -HostName -ProviderType SPDistributedCacheClusterProvider -ConnectionString ""
# E.g. Unregister-CacheHost -HostName CASTOR.Corp01.oct.on.ca -ProviderType SPDistributedCacheClusterProvider -ConnectionString "Data Source=SP2019PRODSQL;Initial Catalog=sa_SP2019PROD_Config;Integrated Security=True;Persist Security Info=False;"

# EXPORT CACHE CLUSTER CONFIG
<# 
  Export-CacheClusterConfig c:\cacheclusterconfig.txt
  Import-CacheClusterConfig C:\temp\cacheclusterconfig_new.txt
  Start-CacheCluster
#>

# TO START DCACHE SERVICE in SP2019
<#  
    $instanceName ="SPDistributedCacheService Name=AppFabricCachingService"
    $serviceInstance = Get-SPServiceInstance | ? {($_.service.tostring()) -eq $instanceName -and ($_.server.name) -eq $env:computername}
    $serviceInstance.Provision()
#> 

# TO STOP DCACHE SERVICE in SP2019
<#
  $instanceName ="SPDistributedCacheService Name=AppFabricCachingService"
  $serviceInstance = Get-SPServiceInstance | ? {($_.service.tostring()) -eq $instanceName -and ($_.server.name) -eq $env:computername}
  $serviceInstance.Unprovision()
#>

# UPDATE Logon Token* CACHE
#  Get-SPDistributedCacheClientSetting -ContainerType DistributedLogonTokenCache

#$DLTC = Get-SPDistributedCacheClientSetting -ContainerType DistributedLogonTokenCache
#$DLTC.requestTimeout = "3000"
#Set-SPDistributedCacheClientSetting -ContainerType DistributedLogonTokenCache $DLTC
#Restart-Service -Name AppFabricCachingService

#Get-SPSecurityTokenServiceConfig

# UPDATE *ViewState* CACHE
#$DVSTC = Get-SPDistributedCacheClientSetting -ContainerType DistributedViewStateCache
#$DVSTC | select RequestTimeout

# ---------
# FUNCTIONS
# ---------

function StopDistibuteCache ($hostname) {
    $hostname = GetSubString $hostname
    Write-Host -f Cyan "Stopping Distribute Cache($hostname)..."
    $instanceName =”SPDistributedCacheService Name=AppFabricCachingService” 
    $serviceInstance = Get-SPServiceInstance | ? {($_.service.tostring()) -eq $instanceName -and ($_.server.name) -eq $hostname} 
    #$serviceInstance.Unprovision()
    Write-Host -f Cyan "Distribute Cache Stopped."
}

function GetSubString($somestring){
    $thisstring = ""
    try{
        $index = $somestring.IndexOf('.')
        $thisstring = $somestring.SubString(0, $index)
    }catch {
        $thisstring = $somestring
    }
    return $thisstring              
}

function StartDistributeCache ($hostname) {
    $hostname = GetSubString $hostname
    Write-Host -f Cyan "Starting Distribute Cache($hostname)..."
    $instanceName =”SPDistributedCacheService Name=AppFabricCachingService”
    $serviceInstance = Get-SPServiceInstance | ? {($_.service.tostring()) -eq $instanceName -and ($_.server.name) -eq $hostname} 
    $serviceInstance.Provision()
    Write-Host -f Cyan "Distribute Cache Started."
}

function CheckFarmDistributeCacheMemory{
    Use-CacheCluster
    $allhosts = Get-CacheHost
    foreach ($cachehost in $allhosts){
        $hostname = GetSubString $cachehost.Hostname
        Write-Host -f Cyan "Cache Info for $hostname"
        Get-AFCacheHostConfiguration -ComputerName $hostname -CachePort "22233"
        Write-Host -f Cyan " ---- "
    }    
}

function UpdateFarmDistributeCacheMemory (){
    $cachehosts = Get-CacheHost
    foreach ($cachesrv in $cachehosts){
        StopDistibuteCache $cachesrv.HostName
    }    

    $newsize = Read-Host "Enter new Cache Size for this Cache Host (integer in MB)"
    Write-Host -f Cyan "Resizing Cache Host Memory..."
    Update-SPDistributedCacheSize -CacheSizeInMB $newsize
    Write-Host -f Cyan "Cache Host Memory Updated."

    Write-Host -f Red "Log on to any other Cache host and Update Memory Allocation with cmd UpdateCacheMemoryOnThisServer"
    Read-Host -f Red "Once Update to all other Cache host is complete, Enter Any Key to procced..."

    foreach ($cachesrv in $cachehosts){
        StartDistributeCache $cachesrv.HostName
    }           
}

function UpdateCacheMemoryOnThisServer ($newsize){
    Update-SPDistributedCacheSize -CacheSizeInMB $newsize
}

# GraceShutDownDistributeCache
# Add-SPDistributedCacheServiceInstance

#When Shutting down the server execute Gracefull Shut down. 
# When the server is backk up execute Add-DistributeCacheServiceInstance command
function GraceShutDownDistributeCache{
    Write-Host -f Cyan "Stopping Distribbute Service Gracefully..."
    Stop-SPDistributedCacheServiceInstance -Graceful
    Remove-SPDistributedCacheServiceInstance
    Write-Host -f Cyan "Stopping Distribbute Service Gracefully..."

    $restart = Read-Host "Do you want to restart the Server?  (Yes - 1, N - 2)"
    if ($restart -eq '1'){        
        Restart-Computer -ComputerName  $env:computername
        Add-SPDistributedCacheServiceInstance
        Write-Host -f Cyan "Started Distribbute Service Instance."
        Read-Host "Press Any key to continue..."
    }else
    {
        Write-Host -f Cyan "Run Add-SPDistributedCacheServiceInstance after restart of the server."   
    }
}

function RepairDistributeCacheCache{
    try{
        $cacheinstances = Get-SPServiceInstance | Where-Object {$_.TypeName -eq "Distributed Cache"}         
        ForEach($cache in $cacheinstances){ 
            Write-Host "Deleting Cache Instace $cache.Name"
            $cache.delete() 
            Remove-SPDistributedCacheServiceInstance
            Write-Host "Deleted Cache Instace"
        }
        Add-SPDistributedCacheServiceInstance 
        Write-Host -f Green "Cache Recreated, Run the Add-SPDistributedCacheServiceInstance on other servers to be used for cache cluster"
    }catch {
        Write-Host "Repair Failed: $error"
    }    

}

function AttachDistributeCacheHost{
    Add-SPDistributedCacheServiceInstance
}

function List-DistributeCacheSettings{
    $cacheTypes = "DistributedDefaultCache", "DistributedAccessCache", "DistributedActivityFeedCache", "DistributedBouncerCache","DistributedLogonTokenCache", "DistributedServerToAppServerAccessTokenCache", "DistributedSearchCache", "DistributedSecurityTrimmingCache ", "DistributedActivityFeedLMTCache", "DistributedViewStateCache"
    foreach($cache in $cacheTypes){
        Write-Host -f Cyan "Cache Info: $cache"
        Get-SPDistributedCacheClientSetting -ContainerType $cache 
        Write-Host -f Cyan "------"

        Get-CacheStatistics $cache
    }
}

function List-CacheStatistics {
    Write-Host -f Green "Cache Statistics and Config" 
    
    $allCaches = Get-Cache
    foreach ($cache in $allCaches)
    {       
        Write-Host -f Cyan $cache.CacheName 
        Get-CacheStatistics -CacheName $cache.CacheName
        Get-CacheConfig -CacheName $cache.CacheName 
        Write-Host -f Cyan "------"
    }
}

#Get-CacheClusterHealth

#Get-CacheHost

function RepairUPS($servername ){
    $service = Get-SPServiceInstance | Where {$_.Typename -like "Distributed*" } 
    $service.Unprovision()

    $service.Provision()

}

