#before splatting
Send-MailMessage -SmtpServer "smtp.gmail.com" -Port 587 -UseSsl -Credential 'sapsug.demo@gmail.com' -From 'sapsug.demo@gmail.com' -To 'sapsug.demo@gmail.com' -Subject 'San Antonio Powershell User Group - Meetup' -Body  "Sending e-mail from PowerShell" -Attachments 'c:\rs-pkgs\TPSreport.pdf'



#after splatting
$param = @{
    SmtpServer = 'smtp.gmail.com'
    Port = 587
    UseSsl = $true
    Credential  = 'sapsug.demo@gmail.com'
    From = 'sapsug.demo@gmail.com'
    To = 'sapsug.demo@gmail.com'
    Subject = 'San Antonio Powershell User Group - Meetup'
    Body = "Welcome to the Powershell Splatting Demo!"
    Attachments = 'c:\rs-pkgs\TPSreport.pdf'
}
 
Send-MailMessage @param



#reusable parameters
#Write a message with the colors in $Colors
$Colors = @{ForegroundColor = "black"; BackgroundColor = "white"}
Write-Host "Hello World from Splatting !!" @Colors
Write-Host @Colors "You can use your splatting argument anywhere on your cmdlet"
Write-Host "In addition, if you change one of your hash values, you only update it once" @Colors

#Organize your wmi queries together
#https://blogs.technet.microsoft.com/heyscriptingguy/2010/10/18/use-splatting-to-simplify-your-powershell-scripts/
$LocalUsers = @{Query="Select * From Win32_UserAccount WHERE LocalAccount='true'"} 
$Partition = @{Query="Select * from Win32_DiskPartition"}
$ComputerSystem = @{Query="Select * From Win32_ComputerSystem"} 
$OperatingSystem = @{Query="Select * From Win32_OperatingSystem"}


Get-WmiObject @LocalUsers
Get-WmiObject @Partition 
Get-WmiObject @ComputerSystem 
Get-WmiObject @OperatingSystem 




#Bonus
$params1 = @{
FilePath = "C:\windows\notepad.exe" 
WorkingDirectory = "C:\users\alex"
}

$params2 = @{
ArgumentList = "C:\rs-pkgs\myfile.txt" 
}

Start-Process @params1

Start-Process @params1 @params2
