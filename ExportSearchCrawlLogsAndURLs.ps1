
<# 

Below is a PowerShell script which retrieves the crawl logs and exports them to an excel.

https://blog.meenavalli.in/post/sharepoint2013-export-search-crawl-log-to-excel/

EXPLAINING THE METHOD'S PARAMETERS

The 'GetCrawledUrls' method has the following parameters

GetCrawledUrls(bool getCountOnly,long maxRows,string urlQueryString,bool isLike,int contentSourceID,int errorLevel,int errorID,DateTime startDateTime,DateTime endDateTime)

Return Value - DataTable
getCountOnly - If true, returns only the count of URLs matching the given parameters.
maxRows - This parameter specifies the number of rows to be retrieved.
urlQueryString - The prefix value to be used for matching the URLs
isLike - If true, all URLs that start with 'urlQueryString' will be returned.
contentSourceID - This is the ID of the content source for which crawl logs should be retrieved. If -1 is specified, URLs will not be filtered by content source. How to get the Content Source ID?
errorLevel - Only URLs with the specified error level will be returned.Possible Values -
-1 : Do not filter by error level.
0 : Return only successfully crawled URLs.
1 : Return URLs that generated a warning when crawled.
2 : Return URLs that generated an error when crawled.
3 : Return URLs that have been deleted.
4 : Return URLs that generated a top level error.
errorID - Only URLs with this error ID will be returned. If -1 is supplied, URLs will not be filtered by error ID.
startDateTime - Start Date Time. Logs after this date are retrieved.
endDateTime - End Date Time. Logs till this date are retrieved.

HOW TO GET CONTENT SOURCE ID
1. Open the Search Service Application.
2. Click on the Content Sources from the left navigation menu.
3. On this page, all the Content Sources are shown. Click on your required Content Source and check the URL in the address bar. The value of the query string parameter cid is the content source id.
http://<server-url>/_admin/search/editcontentsource.aspx?cid=2&appid={GUID}

HOW TO MAIL DAILY ALERTS OF SEARCH CRAWL ERRORS
https://blog.meenavalli.in/post/sharepoint2013-email-alerts-search-crawl-errors-powershell/
#>

Add-PSSnapin Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue
 
#Configuration Parameters
$ContentSourceName = "Searchable Decisions (www.oct.ca)"
$ResultsCount = 10
 
#Get Search Service application and Content Source
$SearchServiceApplication = Get-SPEnterpriseSearchServiceApplication
$ContentSource = Get-SPEnterpriseSearchCrawlContentSource -SearchApplication $searchServiceApplication | ? { $_.Name -eq $contentSourceName }
 
#Get Crawl History
$CrawlLog = new-object Microsoft.Office.Server.Search.Administration.CrawlLog ($searchServiceApplication)
$CrawlHistory = $CrawlLog.GetCrawlHistory($ResultsCount, $ContentSource.Id)
 
#Export the Crawl History to CSV
$CrawlHistory | Export-CSV "C:\CrawlHistory.csv" -NoTypeInformation

#Get Crawled URLs
$CrawledURLs = $CrawlLog.GetCrawledUrls($false,10000,"",$false,-1,0,-1,[System.DateTime]::MinValue,[System.DateTime]::MaxValue) 
#Export the Crawled URLs to CSV
$CrawledURLs | Export-Csv "C:\CrawledURLs-Successful.csv" -NoTypeInformation

#Get Crawled URLs
$CrawledURLs = $CrawlLog.GetCrawledUrls($false,10000,"",$false,-1,1,-1,[System.DateTime]::MinValue,[System.DateTime]::MaxValue) 
#Export the Crawled URLs to CSV
$CrawledURLs | Export-Csv "C:\CrawledURLs-Warning.csv" -NoTypeInformation

#Get Crawled URLs
$CrawledURLs = $CrawlLog.GetCrawledUrls($false,10000,"",$false,-1,2,-1,[System.DateTime]::MinValue,[System.DateTime]::MaxValue) 
#Export the Crawled URLs to CSV
$CrawledURLs | Export-Csv "C:\CrawledURLs-Error.csv" -NoTypeInformation

#Read more: https://www.sharepointdiary.com/2015/12/export-sharepoint-search-crawl-history-to-csv-using-powershell.html#ixzz8tVKmyySv
