<#
Find and replace metadata field values in List
#>

Add-PSSnapin microsoft.sharepoint.powershell

<#
CIRCULATION --------------	Circulation - General
REFERENCE -------------- 	Reference - General
TECHNICAL -------------- 	Technical - General
#>

$web = Get-SPWeb -Identity http://site.domain.ca/prefix/web/library
$list = $web.Lists["Library Interaction Capture"]

$fieldInternalName = "Type_x0020_of_x0020_question"
$searchValue = "CIRCULATION --------------"  # Value to search for
$newValue = "Circulation - General"  # New value for the field

$searchValue2 = "REFERENCE --------------"  # Value to search for
$newValue2 = "Reference - General"  # New value for the field

$searchValue3 = "TECHNICAL --------------"  # Value to search for
$newValue3 = "Technical - General"  # New value for the field

# Build CAML query to search for items with specific field value
$query = New-Object Microsoft.SharePoint.SPQuery
$query.Query = "<Where><Contains><FieldRef Name='$fieldInternalName' /><Value Type='Text'>$searchValue</Value></Contains></Where>"

Write-Host "Looking for $searchValue ...."

# Get items based on the CAML query
$items = $list.GetItems($query)

$total = $items.Count
Write-Host "Total items found: $total"

$counter= 1
foreach ($item in $items) {
    # Read the current value of the field
    $currentValue = $item[$fieldInternalName]

    Write-Host "Item $counter of $total. Item ID: $($item.ID)"
    Write-Host " - OLD:" $currentValue

    $replacedValue = $currentValue.replace($searchValue,$newValue);
    $replacedValue = $replacedValue.replace($searchValue2,$newValue2);
    $replacedValue = $replacedValue.replace($searchValue3,$newValue3);
    #Write-Host "Replaced Value: $replacedValue (simulated)"

    # Update the value of the field
    $item[$fieldInternalName] = $replacedValue
    $item.SystemUpdate()

    Write-Host " - NEW: $($item[$fieldInternalName])" 

    Start-Sleep -Seconds 2
    $counter++
}

# Dispose of SharePoint objects
$web.Dispose()

#$site.Dispose()



