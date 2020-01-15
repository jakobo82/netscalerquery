﻿Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted -ErrorAction SilentlyContinue 
Import-Module .\Posh-SSH\2.2\Posh-SSH.psm1


          $computerarray = @()
            do {
            $input = read-host -Prompt "nsip address"
                if ($input -ne '') { 
                    
                    $computerarray += $input 
                }
            }
            until ($input -eq '')

foreach ($nsip in $computerarray) {

Get-SSHSession | Remove-SSHSession

if (Test-Connection $nsip) {
$nscred = (Get-Credential -UserName nsroot -Message "netscaler pass")
$ssh = New-SSHSession -ComputerName $nsip -Credential $nscred  -Port 22 -AcceptKey
$newssh = New-SSHShellStream -SessionId $ssh.SessionId
$newssh.WriteLine("shell")
$newssh.WriteLine("ls /var/vpn/bookmark/*.xml")
$newssh.WriteLine("cat /var/log/httpaccess.log | grep vpns | grep xml")
$newssh.WriteLine("gzcat /var/log/httpaccess.log.*.gz | grep vpns | grep xml")
$newssh.WriteLine("cat /etc/crontab")
$newssh.WriteLine("top -n 10")
$newssh.WriteLine("cat /var/log/bash.log | grep nobody")
$tempfile = "$($nsip)_$($env:USERDNSDOMAIN).log" 
1..7000 | foreach -process { $newssh.Readline($_) | out-file -Append $tempfile }

}

