﻿#Global Variables
$Global:nmgroups = $null

#recipient variable
$Global:recipients = @()

#
$sendlist = @()
#get members of empty group to send emails to
#function GetEmptyGroupsMembers{

    #get all groups where the manager field is empty
    $nmgroups = Get-ADGroup -filter * -SearchBase "CN of OU to seach from" -Properties * | where ManagedBy -like ''

    #variable for final list
    $final = @()
    
    #loop through groups with no manager
    foreach ($g in $nmgroups){
        try{
            #get members of group
            $objects = Get-ADGroupMember $g.name
            
            #list of names of recipients for each group
            $recipients = @()

            #add names of each group to a list
            foreach ($r in $objects){
            $recipients += $r.name
            }        
        }
        Catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException]{
            write-host "Caught One!"
            #$gname = get-adgroup -Filter * | where name -eq $g.name
            #get members of group using sam account name
            $objects = Get-ADGroupMember $g.SamAccountName
            $recipients = @()
            foreach ($r in $objects){
                $recipients += $r.name
            }
        }
        Catch [Microsoft.ActiveDirectory.Management.ADException]{
            #if still gettings uses write out the name of the group
            write-host $g.name
            continue
        }        
        finally{
            #create object of groups and their members
            $object = New-Object -TypeName PSObject
            $object | Add-Member -MemberType NoteProperty -Name Groups -Value $g.name
            $object | Add-Member -MemberType NoteProperty -Name Recipients -value ($recipients -join ",")
            $final += $object
        }
    }
#}
$final | export-csv "nomanager.csv" -NoTypeInformation
$domain = @()
foreach ($f in $final){
    if ($f.Recipients -contains "Domain Users"){
        $domain += $f
    }
}