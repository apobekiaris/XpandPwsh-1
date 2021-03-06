function Remove-AzBuild {
    [CmdletBinding()]
    [CmdLetTag(("#Azure","AzureDevOps"))]
    param (
        [parameter(ValueFromPipelineByPropertyName,ParameterSetName="id")]
        [string]$Id,
        [parameter(ParameterSetName="switch")]
        [switch]$InProgress,
        [string]$Project=$env:AzProject,
        [string]$Organization=$env:AzOrganization,
        [string]$Token=$env:AzDevopsToken
    )
    
    begin {
        $cred=@{
            Project=$Project
            Organization=$Organization
            Token=$Token
        }        
    }
    
    process {
        if($InProgress){
            Get-AzBuilds -Status inProgress,notStarted|Remove-AzBuild
        }
        else{
            if ($Id){
                Invoke-AzureRestMethod "build/builds/$Id" @cred -Method Delete
            }
        }
    }
    
    end {
        
    }
}