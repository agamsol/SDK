$json = Get-Content -raw 'json-tests\Test-1.1.json'

Add-Type -AssemblyName System.Web.Extensions
$serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
$obj = $serializer.Deserialize($json, [type][hashtable])

$Result = ''
if ($obj.key -is [bool]) { $obj.key = $obj.key.ToString().ToLower() }
if ($obj.key -is [System.Collections.IDictionary]) {$DictionaryResult = $obj.key | ConvertTo-Json -Compress ; $Result = 'key=' + $DictionaryResult} else {$Result = 'key=' + $obj.key}
$Result

break
