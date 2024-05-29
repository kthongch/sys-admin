pwsh -c '
$From = "sender@hotmail.com"
$SMTPServer = "SERVERNAME.domain"
$SMTPPort = "25"
$HTML_REPORT = "/path/report.html"
$recip = "abc@hotmail.com,bcd@hotmail.com"

$date = Get-Date -Format "dd/MM/yyyy"
$Subject = "Kafka services and connectors Status Report $date"
$HTML_Body = Get-Content -Path "$HTML_REPORT"
$Body = $HTML_Body | Out-String


#Build recipient list
$recipList = $recip.Split(",")
foreach ($name in $recipList) {
$name = $name.Trim()
Write-Host "Adding $name to email list"
$emailTo = ($emailTo + "<" + $name + ">" + ",")
}
$emailTo = $emailTo.TrimEnd(",")
[string[]]$To = $emailTo.Split(",")





Write-Host "Attempting to send email"
Send-MailMessage -From $From -to $To -Subject $Subject -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -port $SMTPPort -WarningAction:SilentlyContinue

if ($error[0]) {
Write-Host "Email send failed with error:" $error[0]
exit 1
}
Write-Host "Email sent"

Remove-Item "$HTML_REPORT" -Force

'
ReturnCode=$?
echo "Powershell ReturnCode is:" ${ReturnCode}
exit ${ReturnCode}