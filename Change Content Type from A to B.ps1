# 
# CHANGE Content Type from Type A to Type B for a given List or Library
#
# Source: http://get-spscripts.com/2010/10/change-content-type-set-on-files-in.html

function Reset-SPFileContentType ($WebUrl, $ListName, $OldCTName, $NewCTName)
{
    #Get web, list and content type objects
    $web = Get-SPWeb $WebUrl
    $list = $web.Lists[$ListName]
    $oldCT = $list.ContentTypes[$OldCTName]
    $newCT = $list.ContentTypes[$NewCTName]
    $newCTID = $newCT.ID
    
    $countConverted_Yes = 0;
    $countConverted_Failed = 0;
    $countConverted_No = 0;

    #Check if the values specified for the content types actually exist on the list
    if (($oldCT -ne $null) -and ($newCT -ne $null))
    {
        $totalFiles = $list.Items.Count;

        #Go through each item in the list
        $list.Items | ForEach-Object {
            #Check if the item content type currently equals the old content type specified
            if ($_.ContentType.Name -eq $oldCT.Name)
            {
                #Check the check out status of the file
                if ($_.File.CheckOutType -eq "None")
                {
                    #Change the content type association for the item
                    $_.File.CheckOut()
                    write-host "Resetting content type for file" $_.Name "from" $oldCT.Name "to" $newCT.Name
                    $_["ContentTypeId"] = $newCTID
                    $_.Update()
                    $_.File.CheckIn("Content type changed to " + $newCT.Name, 1)

                    $countConverted_Yes = $countConverted_Yes + 1;
                }
                else
                {
                    write-host "File" $_.Name "is checked out to" $_.File.CheckedOutByUser.ToString() "and cannot be modified"

                    $countConverted_No = $countConverted_No + 1;

                }
            }
            else
            {
                write-host "File" $_.Name "is associated with the content type" $_.ContentType.Name "and shall not be modified"

                $countConverted_No = $countConverted_No + 1;
            }
        }
    }
    else
    {
        write-host "One of the content types specified has not been attached to the list"$list.Title
    }
    $web.Dispose()
    write-host ""
    write-host "Report:"
    write-host " - Total files in Library: " $totalFiles
    write-host " - Conversion Succeeded: " $countConverted_Yes
    write-host " - Conversion failed: " $countConverted_Failed
    write-host " - File Not converted: " $countConverted_No
}

# Look up library names if you are unsure
$spWeb = Get-SpWeb -Identity http://insite.oct.ca/ccs/it
$spWeb.Lists | select Title, ID, url
$spWeb.dispose()

# set these variables
$web = "http://insite.oct.ca/ccs/it"
$library = "Sourcing"

# backup data -- just in case
Export-SPWeb -Identity $web -Path "c:\exportedSites\it_Sourcing_NEW.cmp" -ItemUrl $library -IncludeUserSecurity -IncludeVersions All #-force

# set these variables
$CT_Old = "Summary - No PO" 
$CT_New = "Summary - PO"

#run the magic!
Reset-SPFileContentType -WebUrl $web -ListName $library -OldCTNam $CT_Old -NewCTName $CT_New


"Engagement Letter - No PO" - DONE
"Engagement Letter - PO"

"Contract - No PO" - 12 - DONE
"Contract - PO" - 2 

"Invoice - No PO" - DONE
"Invoice - PO"

"Quote - No PO" - DONE
"Quote"

"Email Reference - No PO" - DONE
"Email Reference - PO"

"Service Agreement - No PO" - DONE
"Service Agreement - PO"

"Letter of Intent - No PO" - DONE
"Letter of Intent - PO"

"Enrollment Form - No PO" - DONE
"Enrollment Form - PO"

"Applecare Protection - No PO" - DONE
"Applecare Protection - PO"

"Credit No PO" - DONE
"Credit"

"Service Call - No PO" - DONE
"Service Call - PO"

"Summary - No PO" - DONE
"Summary - PO"





#Rename Content Type
$spSite = Get-SPSite -Identity http://insite.oct.ca/ccs
$spsite.dispose()

$spWeb = Get-SpWeb -Identity http://insite.oct.ca/ccs/it
# find all content types whose names contain the string "No PO" 
$spWeb.ContentTypes | Where-Object {$_.Name -like "*No PO"} | Select Name

Engagement Letter - No PO                                                                                                                                                
Service Call - No PO                                                                                                                                                     
Applecare Protection - No PO                                                                                                                                             
Enrollment Form - No PO                                                                                                                                                  
Letter of Intent - No PO                                                                                                                                                 
Service Agreement - No PO                                                                                                                                                
Credit No PO                                                                                                                                                             
Summary - No PO                                                                                                                                                          
Sourcing Email - No PO                                                                                                                                                   
Invoice - No PO                                                                                                                                                          
Contract - No PO                                                                                                                                                         
Quote - No PO                                          

# remove contents types from Sourcing library where content type contains string "No PO"
$list = $spWeb.Lists["Sourcing"];
$list | Select Title, ID
$list.ContentTypes | Select Name

# delete a single targetted content type
    $list.ContentTypes.Delete($list.ContentTypes["Engagement Letter - No PO"].Id);

#delete a range of content types from a list
    $list.ContentTypes | Where-Object {$_.Name -like "*No PO"} | Select Name
    $contentTypesToDelete.Count = $null
    $contentTypesToDelete = $list.ContentTypes | Where-Object {$_.Name -like "*No PO"} | Select Name

    foreach ($ct in $contentTypesToDelete) {
        $list.ContentTypes.Delete($list.ContentTypes[$ct.Name].Id);
        #break;
    }
    $spWeb.update()

# delete a range of content types from a web

    $spWeb = Get-SpWeb -Identity http://insite.oct.ca/ccs/it
    # find all content types whose names contain the string "No PO" 
    $spWeb.ContentTypes | Where-Object {$_.Name -like "*No PO"} | Select Name  
    $contentTypesToDelete = $spWeb.ContentTypes | Where-Object {$_.Name -like "*No PO"} | Select Name
    $contentTypesToDelete.Count

foreach ($ct in $contentTypesToDelete) {
    $spWeb.ContentTypes.Delete($spWeb.ContentTypes[$ct.Name].Id);
    #break;
}
$spWeb.update()

 
$spWeb.ContentTypes[""]
$spWeb.Lists
$list = $spWeb.GetList("Sourcing")

$spWeb.Dispose()
