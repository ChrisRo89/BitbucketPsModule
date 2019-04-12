function Enter-BitbucketData {
    if($null -eq $script:bitbucketData)
    {
        $script:bitbucketData = New-Object -TypeName psobject
        $script:bitbucketData | Add-Member -MemberType NoteProperty -Name ServerName -Value (Read-Host -Prompt "Enter the Bitbucket server name: ")
        $script:bitbucketData | Add-Member -MemberType NoteProperty -Name Credentials -Value (Get-Credential -Title "Bitbucket Credentials" -Message "Enter your Bitbucket credentials...")
    }
    return $script:bitbucketData
}
<#
    .SYNOPSIS
    Returns the complete projects
    .PARAMETER limit
    The limit will be used for 
#>
function Get-BitbucketProjectList {
    [CmdletBinding()] param([Int32] $limit = 999)
    $bitbucketData = Enter-BitbucketData
    $bitbucketServerName = $bitbucketData.ServerName
    $bitbucketServerUrl = "https://$bitbucketServerName/rest/api/1.0/projects?limit=$limit"
    return Invoke-WebRequest -Uri $bitbucketServerUrl -Authentication Basic -Credential $bitbucketData.Credentials | ConvertFrom-Json
}

function Get-BitbucketProject {
    [CmdletBinding()] param([string] $ProjectKey, [string] $ProjectName)
    $bitbucketProject = (Get-BitbucketProjectList).values | Where-Object {($_.key -eq $ProjectKey) -or ($_.name -eq $ProjectName)}
    return $bitbucketProject   
}

function Get-BitbucketRepositoryList {
    [CmdletBinding()] param([Int32] $limit = 999)
    $bitbucketData = Enter-BitbucketData
    $bitbucketServerName = $bitbucketData.ServerName
    $bitbucketServerUrl = "https://$bitbucketServerName/rest/api/1.0/repos?limit=$limit"
    return Invoke-WebRequest -Uri $bitbucketServerUrl -Authentication Basic -Credential $bitbucketData.Credentials | ConvertFrom-Json
}

function Get-BitbucketUserList {
    [CmdletBinding()] param([Int32] $limit = 999)
    $bitbucketData = Enter-BitbucketData
    $bitbucketServerName = $bitbucketData.ServerName
    $bitbucketServerUrl = "https://$bitbucketServerName/rest/api/1.0/users?limit=$limit"
    return Invoke-WebRequest -Uri $bitbucketServerUrl -Authentication Basic -Credential $bitbucketData.Credentials | ConvertFrom-Json
}

function Get-BitbucketObjectLink {
    [CmdletBinding()] param(
        [Parameter(Position = 0,
                   Mandatory = $true,
                   ValueFromPipeline = $true)] $BitbucketObject
    )
    return $BitbucketObject.links.self.href
}

function Get-BitbucketCloneLink {
    [CmdletBinding()] param (
        [Parameter(Position = 0,
                   Mandatory = $true,
                   ValueFromPipeline = $true)] $BitbucketObject,
        [Parameter(Position = 1)] [string] $TransferProoctol = "http"
    )
    ($BitbucketObject.links.clone | Where-Object {$_.Name -eq $TransferProoctol}).href
}

function Get-GitRepository {
    [CmdletBinding()] param (
        [string] $RepositoryUrl
    )
    Start-Process -FilePath "git.exe" -ArgumentList "clone $RepositoryUrl"
}