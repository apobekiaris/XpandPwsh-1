function Get-XmlContent {
    [CmdletBinding()]
    [CmdLetTag(("#dotnet","#dotnetcore"))]
    param (
        [parameter(ValueFromPipeline,Mandatory)]
        [string]$FilePath
    )
    
    begin {
    }
    
    process {
        $ns=([xml](Get-Content $FilePath)).DocumentElement.NamespaceURI
        ( Select-Xml -Path $FilePath -XPath / -Namespace @{mse=$ns}).Node
    }
    
    end {
    }
}