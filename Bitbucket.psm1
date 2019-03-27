function Enter-BitbucketData {
    # if(-not [System.IO.File]::Exists("$ENV:HOMEPATH\BitbucketPsmCredentials"))
    if($null -eq $script:bitbucketData)
    {
        $script:bitbucketData = New-Object -TypeName psobject
        $script:bitbucketData | Add-Member -MemberType NoteProperty -Name ServerName -Value (Read-Host -Prompt "Enter the Bitbucket server name: ")
        $script:bitbucketData | Add-Member -MemberType NoteProperty -Name Credentials -Value (Get-Credential -Title "Bitbucket Credentials" -Message "Enter your Bitbucket credentials...")
        # Export-Clixml -Path $ENV:HOMEPATH\BitbucketPsmCredentials -InputObject $bitbucketData
    }
    return $script:bitbucketData
}
function Get-BitbucketProjectList {
    [CmdletBinding()] param([Int32] $limit = 999)   
    $bitbucketData = Enter-BitbucketData
    $bitbucketServerName = $bitbucketData.ServerName
    $bitbucketServerUrl = "https://$bitbucketServerName/rest/api/1.0/projects?limit=$limit"
    return Invoke-WebRequest -Uri $bitbucketServerUrl -Authentication Basic -Credential $bitbucketData.Credentials | ConvertFrom-Json
}

function Get-BitbucketRepositoryList {
    [CmdletBinding()] param([Int32] $limit = 999)
    $bitbucketData = Enter-BitbucketData
    $bitbucketServerName = $bitbucketData.ServerName
    if ($null -ne $bitbucketServerUrl) {
        $bitbucketServerUrl = "https://$bitbucketServerName/rest/api/1.0/repos?limit=$limit"
        return Invoke-WebRequest -Uri $bitbucketServerUrl -Authentication Basic -Credential $bitbucketData.Credentials | ConvertFrom-Json
    }
    else {
        
    }
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
        [Parameter(Position = 1)] $TransferProoctol = "http"
    )
    ($BitbucketObject.links.clone | Where-Object {$_.Name -eq $TransferProoctol}).href
}