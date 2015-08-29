#!/usr/bin/env bash
# bin/curlCommand.sh
# Martin Miller
# Created: 2015/08/28

curl 'https://webservice.lotek.com/DeviceDataForm.aspx' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' -H 'Accept-Encoding: gzip, deflate' -H 'Accept-Language: en-US,en;q=0.5' -H 'Connection: keep-alive' -H 'Cookie: ASP.NET_SessionId=xfv1ic45vgajuniehhdwjk55; GPS_WEB_Service=4A1119445C71A100E6915AE3BC6DA881BDC81AA9EF79B9A4DEEB30989EE5533AB966DC4169844FC2A5EC0FC50F3DB4C1D2F68C835C3FC48DDCA1E89DB710C451927607949F06F6C4F2D9249697C6E67F63F40C2F4298CE99E51C5BA84FC1DA525E096C5584922444F1734F8C02D67C5524B6744573862934736DDE3CE6A706C70D93FEC9' -H 'DNT: 1' -H 'Host: webservice.lotek.com' -H 'Referer: https://webservice.lotek.com/DeviceDataForm.aspx' -H 'User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:40.0) Gecko/20100101 Firefox/40.0' -H 'Content-Type: application/x-www-form-urlencoded' --data 'ctl00_ToolkitScriptManager2_HiddenField=&__EVENTTARGET=&__EVENTARGUMENT=&__LASTFOCUS=&__VIEWSTATE=%2FwEPDwUKMTM5OTY5OTYyMg9kFgJmD2QWAgIDD2QWCAIHDw8WAh4EVGV4dAVeTmV3IEZlYXR1cmU6IERldmljZSBOYW1lIGZvciBlYWNoIHVuaXQgY2FuIGJlIHNldCBpbiAiQWNjb3VudCBTZXR0aW5ncyAtPiBFZGl0IERldmljZSBQcm9maWxlImRkAgkPZBYCAgEPZBYCZg9kFgICAQ8PFgoeCUZvbnRfQm9sZGceCkZvbnRfTmFtZXMVAQVBcmlhbB4JRm9udF9TaXplKCoiU3lzdGVtLldlYi5VSS5XZWJDb250cm9scy5Gb250VW5pdAQxMnB0HglGb3JlQ29sb3IKpAEeBF8hU0IChBwWBh4LY2VsbHBhZGRpbmcFATYeC2NlbGxzcGFjaW5nBQEwHgVzdHlsZQUZYm9yZGVyLWNvbGxhcHNlOmNvbGxhcHNlOxYCZg9kFghmDw8WBB4FV2lkdGgbAAAAAAAAdEABAAAAHwUCgAJkZAIBDw8WBB8JGwAAAAAAwGJAAQAAAB8FAoACZBYCZg8PFgQfAAUMTWFwIEdQUyBEYXRhHgdUb29sVGlwBTJQbG90IGRhdGEgcG9pbnRzIHVzaW5nIEdvb2dsZSBNYXAgYW5kIEdvb2dsZSBFYXJ0aGRkAgIPDxYEHwkbAAAAAACgZEABAAAAHwUCgAJkFgJmDw8WCB8ABRREZXZpY2UgQ29uZmlndXJhdGlvbh8KBS5NYWtlIGNoYW5nZXMgdG8gZGV2aWNlIHNjaGVkdWxlcyBhbmQgYmVoYXZpb3IuHg5Gb250X1VuZGVybGluZWcfBQKAQGRkAgMPZBYCZg8PFgQfAAUQQWNjb3VudCBTZXR0aW5ncx8KBRtNYW5hZ2UgYWNjb3VudC1yZWxhdGVkIGRhdGFkZAILD2QWAmYPZBYCZg9kFhZmDw8WAh4HVmlzaWJsZWhkZAIBDw8WAh8ABRdUaGVzZSBhcmUgeW91ciBkZXZpY2VzLhYCHwgFJXBvc2l0aW9uOmFic29sdXRlO2xlZnQ6MTJweDt0b3A6MTJweDtkAgIPDxYCHwAFLFNlbGVjdCBkZXZpY2VzIHRvIHZpZXcgbGlzdGluZyBvciBkb3dubG9hZDogFgIfCAUlcG9zaXRpb246YWJzb2x1dGU7bGVmdDoxMnB4O3RvcDozMnB4O2QCAw8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kFgIfCAUycG9zaXRpb246YWJzb2x1dGU7dG9wOjY1M3B4O2xlZnQ6MTU1cHg7d2lkdGg6OTBweDsQFQQLTGFzdCBMb2cgSW4ITGFzdCBEYXkJTGFzdCBXZWVrCkxhc3QgTW9udGgVBAEwATEBMgEzFCsDBGdnZ2dkZAILDw9kFgIfCAUncG9zaXRpb246YWJzb2x1dGU7dG9wOjY1M3B4O2xlZnQ6MjUwcHg7ZAIND2QWFAIBDzwrAA0BAA8WAh4IUGFnZVNpemUCFGRkAgMPD2QPEBYFZgIBAgICAwIEFgUWAh4OUGFyYW1ldGVyVmFsdWVkFgIfGGQWAh8YZBYCHxhkFgIfGGQWBQIDAgMCAwIDAgNkZAIFDw9kDxAWBWYCAQICAgMCBBYFFgIfGGQWAh8YZBYCHxhkFgIfGGQWAh8YZBYFAgMCAwIDAgMCA2RkAgcPD2QPEBYFZgIBAgICAwIEFgUWAh8YZBYCHxhkFgIfGGQWAh8YZBYCHxhkFgUCAwIDAgMCAwIDZGQCCQ8PZA8QFgNmAgECAhYDFgIfGGQWAh8YZBYCHxhkFgMCAwIDAgNkZAILDw9kDxAWA2YCAQICFgMWAh8YZBYCHxhkFgIfGGQWAwIDAgMCA2RkAg0PD2QPEBYDZgIBAgIWAxYCHxhkFgIfGGQWAh8YZBYDAgMCAwIDZGQCDw8PZA8QFgNmAgECAhYDFgIfGGQWAh8YZBYCHxhkFgMCAwIDAgNkZAIRDw9kDxAWA2YCAQICFgMWAh8YZBYCHxhkFgIfGGQWAwIDAgMCA2RkAhMPFCsAAhQrAAMPFgIfD2hkZGQQFgFmFgEUKwADDxYCHw9oZGRkDxYBZhYBBXJUZWxlcmlrLldlYi5VSS5SYWRXaW5kb3csIFRlbGVyaWsuV2ViLlVJLCBWZXJzaW9uPTIwMTMuMy4xMTE0LjM1LCBDdWx0dXJlPW5ldXRyYWwsIFB1YmxpY0tleVRva2VuPTEyMWZhZTc4MTY1YmEzZDQWAmYPFCsAAw8WAh8PaGRkZGQYBAUeX19Db250cm9sc1JlcXVpcmVQb3N0QmFja0tleV9fFgYFL2N0bDAwJE1lbnVCYXJDb250ZW50JGx2TWVudSRsc0xvZ2luU3RhdHVzJGN0bDAxBS9jdGwwMCRNZW51QmFyQ29udGVudCRsdk1lbnUkbHNMb2dpblN0YXR1cyRjdGwwMwUqY3RsMDAkTGVmdEJhckNvbnRlbnQkbHZMZWZ0UGFuZWwkbGJEZXZpY2VzBSpjdGwwMCRMZWZ0QmFyQ29udGVudCRsdkxlZnRQYW5lbCRjaGtMYXRlc3QFJ2N0bDAwJE1haW5WaWV3Q29udGVudCRSYWRXaW5kb3dNYW5hZ2VyMQUxY3RsMDAkTWFpblZpZXdDb250ZW50JFJhZFdpbmRvd0NvbGxhckNvbmZpcm1hdGlvbgUhY3RsMDAkTWFpblZpZXdDb250ZW50JGdyZERhdGFWaWV3D2dkBSBjdGwwMCRMZWZ0QmFyQ29udGVudCRsdkxlZnRQYW5lbA8PZAIBZAUbY3RsMDAkTWVudUJhckNvbnRlbnQkbHZNZW51Dw9kAgFkz4bf58cQJUeGJqMrgO5cCGrOzJI%3D&__EVENTVALIDATION=%2FwEWLQKe1PnLBQLtj9y%2FCQLg7dkiAo7mtf4HAtCZsKgLAuef%2BLcEAvOf4dgBAtvr94oJAuP4udIBAuP4gRIC4%2FjpWgL2nvj9BgKApKCtBgLv3ff%2BAQLv3Y%2F0AQKSgK%2BOCwKNgK%2BOCwKPgK%2BOCwKBgOONCwKMgK%2BOCwKOgK%2BOCwKJgK%2BOCwKLgK%2BOCwKC74XgBwLpjq3SDgLm4ce%2FAgLm4fu%2FAgLn4ce%2FAgLn4fu%2FAgLk4ce%2FAgLk4fu%2FAgLl4ce%2FAgKC56joCALK35SHBAKkvPHiCgKRoti3BgLL7PyVAgL0uP%2FqCALSueCJDgKBiOeDDAKT6%2BnhDAKM6%2BnhDAKN6%2BnhDAKO6%2BnhDAK728LmBnT7TEY4%2FXUqnFNXQbtmDF33VjE7&ctl00_LeftBarContent_lvLeftPanel_lbDevices_ClientState=&ctl00%24LeftBarContent%24lvLeftPanel%24txtStartDate=January+1%2C+2000&ctl00%24LeftBarContent%24lvLeftPanel%24txtEndDate=August+28%2C+2015&ctl00%24LeftBarContent%24lvLeftPanel%24hiddenTextBox=&ctl00%24LeftBarContent%24lvLeftPanel%24rblDataType=0&ctl00%24LeftBarContent%24lvLeftPanel%24ddlLinePerPage=20&ctl00%24LeftBarContent%24lvLeftPanel%24ddlDLOptions=Spread+Sheet+%28CSV%29&ctl00%24LeftBarContent%24lvLeftPanel%24btnHidden=&ctl00%24LeftBarContent%24lvLeftPanel%24ddlAlertDetail=0&ctl00_MainViewContent_RadWindowCollarConfirmation_ClientState=&ctl00_MainViewContent_RadWindowManager1_ClientState=' -o foo1.csv



