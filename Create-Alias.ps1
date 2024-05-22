[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    # Parameter help description
    [Parameter(Mandatory=$true)]
    [string]$file    
)
begin {
    Write-Host "BEGIN"
}
process {
    #connect exchange online
    Connect-ExchangeOnline
    #load csv
    Import-Csv -Path $file | ForEach-Object {
        $mb = get-mailbox $_.user
        if ($mb | Select-Object -ExpandProperty emailaddresses | Select-String -Pattern "smtp" | Select-String -Pattern $_.alias){
            Write-Host "Alias already found"
        }
        else {
            if ($_.primary -eq "True"){
                Write-Host "Setting primary"
                $mb | set-mailbox -MicrosoftOnlineServicesID $_.alias
            }
            else{
                Write-Host "Setting secondary"
                $mb | set-mailbox -EmailAddresses @{add=$_.alias}
            }
        }

    }
    #finally disconnect exchange online
    Disconnect-ExchangeOnline -Confirm:$false
}
end {
    Write-Host "END"
}