function Add-AzBuild {
    [CmdletBinding()]
    [CmdLetTag((("#Azure","AzureDevOps")))]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [ArgumentCompleter( {
                param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
                (Get-AzDefinition | Where-Object { $_.name -like "$wordToComplete*" }).Name
            })]
        [string[]]$Definition,
        [string[]]$Tag,
        [hashtable]$Parameters,
        [switch]$KeepForEver,
        [switch]$StopOthers,
        [switch]$StopIfRunning,
        [string]$Branch=$env:Build_SourceBranchName,
        [string]$Organization = $env:AzOrganization,
        [string]$Project = $env:AzProject,
        [string]$Token = $env:AzDevopsToken
    )
    
    begin {
        $cred = @{
            Project      = $Project
            Organization = $Organization
            Token        = $Token
        }   
    }
    
    process {
        if ($StopIfRunning) {
            $Definition | Get-AzBuilds -Status inProgress, notStarted, postponed @cred | Remove-AzBuild @cred
        }
        $builds = ($Definition | Get-AzDefinition).id | ForEach-Object {
            $body = @{
                definition   = @{id = $_ }
                parameters   = $Parameters | ConvertTo-Json
                keepForEver  = $KeepForEver.IsPresent
                sourceBranch = $Branch
            } | Remove-DefaultValueKeys 
            (Invoke-AzureRestMethod "build/builds" -Method Post -Body ($body | ConvertTo-Json) @cred)|ForEach-Object{
                $id=$_.id
                if ($Tag){
                    $Tag|ForEach-Object{Add-AzBuildTag -Tag $_ -Id $id}|Out-Null
                    Get-AzBuilds -Id $id
                }
                else{
                    $_
                }
            }
        }
        
        if ($StopOthers) {
            Get-AzBuilds -Status inProgress, notStarted, postponed @cred | Where-Object { $_.id -notin $builds.id } | Remove-AzBuild @cred
        }
        $builds
    }
    end {
        
    }
}