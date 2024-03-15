﻿<#
.Synopsis
   Create configuration for the Markdown in the site collection
.DESCRIPTION
   This script will save all the settings (endpoints, keys, instructions) to the
   Site Collection property bag "MarkdownChat".
   The parameter -SystemInstruction will set the bot role (the rules for the AI). It must include @text that will be replaced by the document text
   See https://github.com/rodneyviana/spfx-azure-ai-chat for more info
.EXAMPLE
   .\Set-ChatInfo.ps1 -Site https://contoso.sharepoint.com/sites/Texas -FormsEndpoint https://contoso-doc-intel.cognitiveservices.azure.com/ -FormsKey "123456a90cdd4359b872ca794a0c1170" -AzureOpenAIEndpoint https://contoso-deployment.openai.azure.com/openai/deployments/gpt4-turbo/chat/completions?api-version=2023-07-01-preview -AzureOpenAIKey "07df1003e59c4f1e8e5a958db6838bc1" -SystemInstructions "You are a legal scholar and you will respond questions about this legal document: `n@text" -WelcomeMessage "I am your AI assistant. Ask me about the document"
#>

Param
(
        # Site Collection Endpoint
        [Parameter(Mandatory=$True,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]$Site,
        # Forms Endpoint
        [Parameter(Mandatory=$True,
                   ValueFromPipelineByPropertyName=$true,
                   Position=1)]
        [string]$FormsEndpoint,
        # Forms Key
        [Parameter(Mandatory=$True,
                   ValueFromPipelineByPropertyName=$true,
                   Position=2)]
        [string]$FormsKey,
        # Chat Completion Endpoint
        [Parameter(Mandatory=$True,
                   Position=3)]
        [string]$AzureOpenAIEndpoint,
        # Chat Completion Key
        [Parameter(Mandatory=$True,
                   ValueFromPipelineByPropertyName=$true,
                   Position=4)]
        [string]$AzureOpenAIKey,
        # Instruction on what to do with the document use @text to define the document content
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=5)]
        [string]$SystemInstructions = "You are an AI assistant, answer questions from the following document and ignore what is not related to the doc except if it is a segue question: @text",
        # AI Welcome message 
        [Parameter(Mandatory=$False,
                   ValueFromPipelineByPropertyName=$true,
                   Position=6)]
        [string]$WelcomeMessage = "I am your AI assistant. Ask me about the document"


)



if (-not (Get-InstalledModule PnP.PowerShell)) {
  Write-Host "Installing PnP PowerShell module...";
  Install-Module PnP.PowerShell -Scope CurrentUser -AllowClobber;
  if (Get-InstalledModule PnP.PowerShell) {
    Write-Host "PowerShell component installed successfuly";
  } else {
    Write-Error "Unable to install PnP.PowerShell, try to install manually. Leaving...";
    Exit(1);
  }
} else {
  Write-Host "Good News, PnP.PowerShell is already installed";
}

Connect-PnPOnline -Url $Site -UseWebLogin;

$configuration = [PSCustomObject]@{
  formsEndpoint=$FormsEndpoint;
  formsKey=$FormsKey;
  azureOpenAIEndpoint=$AzureOpenAIEndpoint;
  azureOpenAIKey=$AzureOpenAIKey;
  systemInstruction=$SystemInstructions;
  welcomeMessage=$WelcomeMessage;
  type="Azure"; # For future expansion
  };

$json = ConvertTo-Json $configuration

try {
    Set-PnPPropertyBagValue -Key "MarkdownChat" -Value $json -ErrorAction Stop
    Write-Host "Settings where updated succesfully";
    Write-Host $json
    return;
} catch {
  Write-Error $Error[0];
  Exit(1);
}
# SIG # Begin signature block
# MIIo0wYJKoZIhvcNAQcCoIIoxDCCKMACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMO6UbunYBZqaW0dwMlOJ+6CZ
# ecWggiK8MIIEMjCCAxqgAwIBAgIBATANBgkqhkiG9w0BAQUFADB7MQswCQYDVQQG
# EwJHQjEbMBkGA1UECAwSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHDAdTYWxm
# b3JkMRowGAYDVQQKDBFDb21vZG8gQ0EgTGltaXRlZDEhMB8GA1UEAwwYQUFBIENl
# cnRpZmljYXRlIFNlcnZpY2VzMB4XDTA0MDEwMTAwMDAwMFoXDTI4MTIzMTIzNTk1
# OVowezELMAkGA1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3RlcjEQ
# MA4GA1UEBwwHU2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQxITAf
# BgNVBAMMGEFBQSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczCCASIwDQYJKoZIhvcNAQEB
# BQADggEPADCCAQoCggEBAL5AnfRu4ep2hxxNRUSOvkbIgwadwSr+GB+O5AL686td
# UIoWMQuaBtDFcCLNSS1UY8y2bmhGC1Pqy0wkwLxyTurxFa70VJoSCsN6sjNg4tqJ
# VfMiWPPe3M/vg4aijJRPn2jymJBGhCfHdr/jzDUsi14HZGWCwEiwqJH5YZ92IFCo
# kcdmtet4YgNW8IoaE+oxox6gmf049vYnMlhvB/VruPsUK6+3qszWY19zjNoFmag4
# qMsXeDZRrOme9Hg6jc8P2ULimAyrL58OAd7vn5lJ8S3frHRNG5i1R8XlKdH5kBjH
# Ypy+g8cmez6KJcfA3Z3mNWgQIJ2P2N7Sw4ScDV7oL8kCAwEAAaOBwDCBvTAdBgNV
# HQ4EFgQUoBEKIz6W8Qfs4q8p74Klf9AwpLQwDgYDVR0PAQH/BAQDAgEGMA8GA1Ud
# EwEB/wQFMAMBAf8wewYDVR0fBHQwcjA4oDagNIYyaHR0cDovL2NybC5jb21vZG9j
# YS5jb20vQUFBQ2VydGlmaWNhdGVTZXJ2aWNlcy5jcmwwNqA0oDKGMGh0dHA6Ly9j
# cmwuY29tb2RvLm5ldC9BQUFDZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDANBgkqhkiG
# 9w0BAQUFAAOCAQEACFb8AvCb6P+k+tZ7xkSAzk/ExfYAWMymtrwUSWgEdujm7l3s
# Ag9g1o1QGE8mTgHj5rCl7r+8dFRBv/38ErjHT1r0iWAFf2C3BUrz9vHCv8S5dIa2
# LX1rzNLzRt0vxuBqw8M0Ayx9lt1awg6nCpnBBYurDC/zXDrPbDdVCYfeU0BsWO/8
# tqtlbgT2G9w84FoVxp7Z8VlIMCFlA2zs6SFz7JsDoeA3raAVGI/6ugLOpyypEBMs
# 1OUIJqsil2D4kF501KKaU73yqWjgom7C12yxow+ev+to51byrvLjKzg6CYG1a4XX
# vi3tPxq3smPi9WIsgtRqAEFQ8TmDn5XpNpaYbjCCBRswggQDoAMCAQICEBxVdN1M
# t+nrMJ+IuERZBAMwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCR0IxGzAZBgNV
# BAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UE
# ChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNp
# Z25pbmcgQ0EwHhcNMjEwNTA1MDAwMDAwWhcNMjQwNTA0MjM1OTU5WjBfMQswCQYD
# VQQGEwJVUzEOMAwGA1UECAwFVGV4YXMxDjAMBgNVBAcMBVBsYW5vMRcwFQYDVQQK
# DA5Sb2RuZXkgSCBWaWFuYTEXMBUGA1UEAwwOUm9kbmV5IEggVmlhbmEwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC8mIDuZleI6ZKlifX13tJfydmgoZX/
# ELqLCx74t+gsCaerV0Tqc52BM09VkXheikVOqj15NAJgxtYAVV3a0Zwg89/N1gNe
# bV9q5fd1CAPMACvTQH3VNTa3Lqsj+dF4hFfNg1osKVmLZFjjbnm2L6kvJ4FDK8Y/
# xU/ovua9y8Imb1laayTKmwDwjqSDKWrACDKzBMU2bMcjvzXOxAHqsJ/vqIgJiqmV
# 8klQwOGsP63HfWY2AaAFllpFWTlriVpx78fHjIlRaY5xP8/zw0CJSYHORYz21NkU
# n1fPOkDOrNt3Z37K1cU9dmtzLnphzGAQ3uQGZk8C+jTgPKyd5scfZ3XpAgMBAAGj
# ggG0MIIBsDAfBgNVHSMEGDAWgBQO4TqoUzox1Yq+wbutZxoDha00DjAdBgNVHQ4E
# FgQUG+VsCmuw4tt/9cocbaUEi/SDUw0wDgYDVR0PAQH/BAQDAgeAMAwGA1UdEwEB
# /wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJYIZIAYb4QgEBBAQDAgQQMEoG
# A1UdIARDMEEwNQYMKwYBBAGyMQECAQMCMCUwIwYIKwYBBQUHAgEWF2h0dHBzOi8v
# c2VjdGlnby5jb20vQ1BTMAgGBmeBDAEEATBDBgNVHR8EPDA6MDigNqA0hjJodHRw
# Oi8vY3JsLnNlY3RpZ28uY29tL1NlY3RpZ29SU0FDb2RlU2lnbmluZ0NBLmNybDBz
# BggrBgEFBQcBAQRnMGUwPgYIKwYBBQUHMAKGMmh0dHA6Ly9jcnQuc2VjdGlnby5j
# b20vU2VjdGlnb1JTQUNvZGVTaWduaW5nQ0EuY3J0MCMGCCsGAQUFBzABhhdodHRw
# Oi8vb2NzcC5zZWN0aWdvLmNvbTAiBgNVHREEGzAZgRdyb2RuZXl2aWFuYUBvdXRs
# b29rLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEANL775csYEkm/3+DeQm893LIT0h7G
# KIe8rIaHkTQ0kbAKqMf8DZ+xiA5DWd/7LGjM2H/QmkEJSyAQyM8rQUyzezo7zfb9
# 1rzLB0vMjLS+lhiW2YEky0u8ZFy5xt9bZqy1irrmEl1281w0hqvOEDIgir4ydvwa
# NuzlFH/ryOqu2bbluC+Edk9LPyy36B5x26qf6f+e0u77cd9AREH2zyNUzOZZc60q
# +hJXv3c5wD9FU7w7sbOYqIH/vtTax0JVLIiK6TWZdKuDi88CF1BToAhdA5vIhobJ
# L3M2lPIdZ+kip5QVx1QiUBZDXj7dJHfMF43laSilNAkfiHq6xc7+2MmDnzCCBYEw
# ggRpoAMCAQICEDlyRDr5IrdR19NsEN0xNZUwDQYJKoZIhvcNAQEMBQAwezELMAkG
# A1UEBhMCR0IxGzAZBgNVBAgMEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBwwH
# U2FsZm9yZDEaMBgGA1UECgwRQ29tb2RvIENBIExpbWl0ZWQxITAfBgNVBAMMGEFB
# QSBDZXJ0aWZpY2F0ZSBTZXJ2aWNlczAeFw0xOTAzMTIwMDAwMDBaFw0yODEyMzEy
# MzU5NTlaMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKTmV3IEplcnNleTEUMBIG
# A1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29y
# azEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0
# eTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAIASZRc2DsPbCLPQrFcN
# du3NJ9NMrVCDYeKqIE0JLWQJ3M6Jn8w9qez2z8Hc8dOx1ns3KBErR9o5xrw6GbRf
# pr19naNjQrZ28qk7K5H44m/Q7BYgkAk+4uh0yRi0kdRiZNt/owbxiBhqkCI8vP4T
# 8IcUe/bkH47U5FHGEWdGCFHLhhRUP7wz/n5snP8WnRi9UY41pqdmyHJn2yFmsdSb
# eAPAUDrozPDcvJ5M/q8FljUfV1q3/875PbcstvZU3cjnEjpNrkyKt1yatLcgPcp/
# IjSufjtoZgFE5wFORlObM2D3lL5TN5BzQ/Myw1Pv26r+dE5px2uMYJPexMcM3+Ey
# rsyTO1F4lWeL7j1W/gzQaQ8bD/MlJmszbfduR/pzQ+V+DqVmsSl8MoRjVYnEDcGT
# VDAZE6zTfTen6106bDVc20HXEtqpSQvf2ICKCZNijrVmzyWIzYS4sT+kOQ/ZAp7r
# EkyVfPNrBaleFoPMuGfi6BOdzFuC00yz7Vv/3uVzrCM7LQC/NVV0CUnYSVgaf5I2
# 5lGSDvMmfRxNF7zJ7EMm0L9BX0CpRET0medXh55QH1dUqD79dGMvsVBlCeZYQi5D
# Gky08CVHWfoEHpPUJkZKUIGy3r54t/xnFeHJV4QeD2PW6WK61l9VLupcxigIBCU5
# uA4rqfJMlxwHPw1S9e3vL4IPAgMBAAGjgfIwge8wHwYDVR0jBBgwFoAUoBEKIz6W
# 8Qfs4q8p74Klf9AwpLQwHQYDVR0OBBYEFFN5v1qqK0rPVIDh2JvAnfKyA2bLMA4G
# A1UdDwEB/wQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MBEGA1UdIAQKMAgwBgYEVR0g
# ADBDBgNVHR8EPDA6MDigNqA0hjJodHRwOi8vY3JsLmNvbW9kb2NhLmNvbS9BQUFD
# ZXJ0aWZpY2F0ZVNlcnZpY2VzLmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUH
# MAGGGGh0dHA6Ly9vY3NwLmNvbW9kb2NhLmNvbTANBgkqhkiG9w0BAQwFAAOCAQEA
# GIdR3HQhPZyK4Ce3M9AuzOzw5steEd4ib5t1jp5y/uTW/qofnJYt7wNKfq70jW9y
# PEM7wD/ruN9cqqnGrvL82O6je0P2hjZ8FODN9Pc//t64tIrwkZb+/UNkfv3M0gGh
# fX34GRnJQisTv1iLuqSiZgR2iJFODIkUzqJNyTKzuugUGrxx8VvwQQuYAAoiAxDl
# DLH5zZI3Ge078eQ6tvlFEyZ1r7uq7z97dzvSxAKRPRkA0xdcOds/exgNRc2ThZYv
# Xd9ZFk8/Ub3VRRg/7UqO6AZhdCMWtQ1QcydER38QXYkqa4UxFMToqWpMgLxqeM+4
# f452cpkMnf7XkQgWoaNflTCCBfUwggPdoAMCAQICEB2iSDBvmyYY0ILgln0z02ow
# DQYJKoZIhvcNAQEMBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpOZXcgSmVy
# c2V5MRQwEgYDVQQHEwtKZXJzZXkgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVT
# VCBOZXR3b3JrMS4wLAYDVQQDEyVVU0VSVHJ1c3QgUlNBIENlcnRpZmljYXRpb24g
# QXV0aG9yaXR5MB4XDTE4MTEwMjAwMDAwMFoXDTMwMTIzMTIzNTk1OVowfDELMAkG
# A1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMH
# U2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0
# aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
# ggEKAoIBAQCGIo0yhXoYn0nwli9jCB4t3HyfFM/jJrYlZilAhlRGdDFixRDtsocn
# ppnLlTDAVvWkdcapDlBipVGREGrgS2Ku/fD4GKyn/+4uMyD6DBmJqGx7rQDDYaHc
# aWVtH24nlteXUYam9CflfGqLlR5bYNV+1xaSnAAvaPeX7Wpyvjg7Y96Pv25MQV0S
# IAhZ6DnNj9LWzwa0VwW2TqE+V2sfmLzEYtYbC43HZhtKn52BxHJAteJf7wtF/6PO
# F6YtVbC3sLxUap28jVZTxvC6eVBJLPcDuf4vZTXyIuosB69G2flGHNyMfHEo8/6n
# xhTdVZFuihEN3wYklX0Pp6F8OtqGNWHTAgMBAAGjggFkMIIBYDAfBgNVHSMEGDAW
# gBRTeb9aqitKz1SA4dibwJ3ysgNmyzAdBgNVHQ4EFgQUDuE6qFM6MdWKvsG7rWca
# A4WtNA4wDgYDVR0PAQH/BAQDAgGGMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0l
# BBYwFAYIKwYBBQUHAwMGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0gADBQBgNV
# HR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0
# UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYBBQUHAQEEajBoMD8G
# CCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNB
# QWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVz
# dC5jb20wDQYJKoZIhvcNAQEMBQADggIBAE1jUO1HNEphpNveaiqMm/EAAB4dYns6
# 1zLC9rPgY7P7YQCImhttEAcET7646ol4IusPRuzzRl5ARokS9At3WpwqQTr81vTr
# 5/cVlTPDoYMot94v5JT3hTODLUpASL+awk9KsY8k9LOBN9O3ZLCmI2pZaFJCX/8E
# 6+F0ZXkI9amT3mtxQJmWunjxucjiwwgWsatjWsgVgG10Xkp1fqW4w2y1z99KeYdc
# x0BNYzX2MNPPtQoOCwR/oEuuu6Ol0IQAkz5TXTSlADVpbL6fICUQDRn7UJBhvjmP
# eo5N9p8OHv4HURJmgyYZSJXOSsnBf/M6BZv5b9+If8AjntIeQ3pFMcGcTanwWbJZ
# GehqjSkEAnd8S0vNcL46slVaeD68u28DECV3FTSK+TbMQ5Lkuk/xYpMoJVcp+1EZ
# x6ElQGqEV8aynbG8HArafGd+fS7pKEwYfsR7MUFxmksp7As9V1DSyt39ngVR5UR4
# 3QHesXWYDVQk/fBO4+L4g71yuss9Ou7wXheSaG3IYfmm8SoKC6W59J7umDIFhZ7r
# +YMp08Ysfb06dy6LN0KgaoLtO0qqlBCk4Q34F8W2WnkzGJLjtXX4oemOCiUe5B7x
# n1qHI/+fpFGe+zmAEc3btcSnqIBv5VPU4OOiwtJbGvoyJi1qV3AcPKRYLqPzW0sH
# 3DJZ84enGm1YMIIG7DCCBNSgAwIBAgIQMA9vrN1mmHR8qUY2p3gtuTANBgkqhkiG
# 9w0BAQwFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDAS
# BgNVBAcTC0plcnNleSBDaXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdv
# cmsxLjAsBgNVBAMTJVVTRVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3Jp
# dHkwHhcNMTkwNTAyMDAwMDAwWhcNMzgwMTE4MjM1OTU5WjB9MQswCQYDVQQGEwJH
# QjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3Jk
# MRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJTAjBgNVBAMTHFNlY3RpZ28gUlNB
# IFRpbWUgU3RhbXBpbmcgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoIC
# AQDIGwGv2Sx+iJl9AZg/IJC9nIAhVJO5z6A+U++zWsB21hoEpc5Hg7XrxMxJNMvz
# RWW5+adkFiYJ+9UyUnkuyWPCE5u2hj8BBZJmbyGr1XEQeYf0RirNxFrJ29ddSU1y
# Vg/cyeNTmDoqHvzOWEnTv/M5u7mkI0Ks0BXDf56iXNc48RaycNOjxN+zxXKsLgp3
# /A2UUrf8H5VzJD0BKLwPDU+zkQGObp0ndVXRFzs0IXuXAZSvf4DP0REKV4TJf1bg
# vUacgr6Unb+0ILBgfrhN9Q0/29DqhYyKVnHRLZRMyIw80xSinL0m/9NTIMdgaZtY
# ClT0Bef9Maz5yIUXx7gpGaQpL0bj3duRX58/Nj4OMGcrRrc1r5a+2kxgzKi7nw0U
# 1BjEMJh0giHPYla1IXMSHv2qyghYh3ekFesZVf/QOVQtJu5FGjpvzdeE8NfwKMVP
# ZIMC1Pvi3vG8Aij0bdonigbSlofe6GsO8Ft96XZpkyAcSpcsdxkrk5WYnJee647B
# eFbGRCXfBhKaBi2fA179g6JTZ8qx+o2hZMmIklnLqEbAyfKm/31X2xJ2+opBJNQb
# /HKlFKLUrUMcpEmLQTkUAx4p+hulIq6lw02C0I3aa7fb9xhAV3PwcaP7Sn1FNsH3
# jYL6uckNU4B9+rY5WDLvbxhQiddPnTO9GrWdod6VQXqngwIDAQABo4IBWjCCAVYw
# HwYDVR0jBBgwFoAUU3m/WqorSs9UgOHYm8Cd8rIDZsswHQYDVR0OBBYEFBqh+GEZ
# IA/DQXdFKI7RNV8GEgRVMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/
# AgEAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMBEGA1UdIAQKMAgwBgYEVR0gADBQBgNV
# HR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0
# UlNBQ2VydGlmaWNhdGlvbkF1dGhvcml0eS5jcmwwdgYIKwYBBQUHAQEEajBoMD8G
# CCsGAQUFBzAChjNodHRwOi8vY3J0LnVzZXJ0cnVzdC5jb20vVVNFUlRydXN0UlNB
# QWRkVHJ1c3RDQS5jcnQwJQYIKwYBBQUHMAGGGWh0dHA6Ly9vY3NwLnVzZXJ0cnVz
# dC5jb20wDQYJKoZIhvcNAQEMBQADggIBAG1UgaUzXRbhtVOBkXXfA3oyCy0lhBGy
# sNsqfSoF9bw7J/RaoLlJWZApbGHLtVDb4n35nwDvQMOt0+LkVvlYQc/xQuUQff+w
# dB+PxlwJ+TNe6qAcJlhc87QRD9XVw+K81Vh4v0h24URnbY+wQxAPjeT5OGK/EwHF
# haNMxcyyUzCVpNb0llYIuM1cfwGWvnJSajtCN3wWeDmTk5SbsdyybUFtZ83Jb5A9
# f0VywRsj1sJVhGbks8VmBvbz1kteraMrQoohkv6ob1olcGKBc2NeoLvY3NdK0z2v
# gwY4Eh0khy3k/ALWPncEvAQ2ted3y5wujSMYuaPCRx3wXdahc1cFaJqnyTdlHb7q
# vNhCg0MFpYumCf/RoZSmTqo9CfUFbLfSZFrYKiLCS53xOV5M3kg9mzSWmglfjv33
# sVKRzj+J9hyhtal1H3G/W0NdZT1QgW6r8NDT/LKzH7aZlib0PHmLXGTMze4nmuWg
# wAxyh8FuTVrTHurwROYybxzrF06Uw3hlIDsPQaof6aFBnf6xuKBlKjTg3qj5PObB
# MLvAoGMs/FwWAKjQxH/qEZ0eBsambTJdtDgJK0kHqv3sMNrxpy/Pt/360KOE2See
# +wFmd7lWEOEgbsausfm2usg1XTN2jvF8IAwqd661ogKGuinutFoAsYyr4/kKyVRd
# 1LlqdJ69SK6YMIIG9TCCBN2gAwIBAgIQOUwl4XygbSeoZeI72R0i1DANBgkqhkiG
# 9w0BAQwFADB9MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVz
# dGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQx
# JTAjBgNVBAMTHFNlY3RpZ28gUlNBIFRpbWUgU3RhbXBpbmcgQ0EwHhcNMjMwNTAz
# MDAwMDAwWhcNMzQwODAyMjM1OTU5WjBqMQswCQYDVQQGEwJHQjETMBEGA1UECBMK
# TWFuY2hlc3RlcjEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSwwKgYDVQQDDCNT
# ZWN0aWdvIFJTQSBUaW1lIFN0YW1waW5nIFNpZ25lciAjNDCCAiIwDQYJKoZIhvcN
# AQEBBQADggIPADCCAgoCggIBAKSTKFJLzyeHdqQpHJk4wOcO1NEc7GjLAWTkis13
# sHFlgryf/Iu7u5WY+yURjlqICWYRFFiyuiJb5vYy8V0twHqiDuDgVmTtoeWBIHIg
# ZEFsx8MI+vN9Xe8hmsJ+1yzDuhGYHvzTIAhCs1+/f4hYMqsws9iMepZKGRNcrPzn
# q+kcFi6wsDiVSs+FUKtnAyWhuzjpD2+pWpqRKBM1uR/zPeEkyGuxmegN77tN5T2M
# VAOR0Pwtz1UzOHoJHAfRIuBjhqe+/dKDcxIUm5pMCUa9NLzhS1B7cuBb/Rm7Hzxq
# GXtuuy1EKr48TMysigSTxleGoHM2K4GX+hubfoiH2FJ5if5udzfXu1Cf+hglTxPy
# XnypsSBaKaujQod34PRMAkjdWKVTpqOg7RmWZRUpxe0zMCXmloOBmvZgZpBYB4DN
# QnWs+7SR0MXdAUBqtqgQ7vaNereeda/TpUsYoQyfV7BeJUeRdM11EtGcb+ReDZvs
# dSbu/tP1ki9ShejaRFEqoswAyodmQ6MbAO+itZadYq0nC/IbSsnDlEI3iCCEqIeu
# w7ojcnv4VO/4ayewhfWnQ4XYKzl021p3AtGk+vXNnD3MH65R0Hts2B0tEUJTcXTC
# 5TWqLVIS2SXP8NPQkUMS1zJ9mGzjd0HI/x8kVO9urcY+VXvxXIc6ZPFgSwVP77kv
# 7AkTAgMBAAGjggGCMIIBfjAfBgNVHSMEGDAWgBQaofhhGSAPw0F3RSiO0TVfBhIE
# VTAdBgNVHQ4EFgQUAw8xyJEqk71j89FdTaQ0D9KVARgwDgYDVR0PAQH/BAQDAgbA
# MAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwSgYDVR0gBEMw
# QTA1BgwrBgEEAbIxAQIBAwgwJTAjBggrBgEFBQcCARYXaHR0cHM6Ly9zZWN0aWdv
# LmNvbS9DUFMwCAYGZ4EMAQQCMEQGA1UdHwQ9MDswOaA3oDWGM2h0dHA6Ly9jcmwu
# c2VjdGlnby5jb20vU2VjdGlnb1JTQVRpbWVTdGFtcGluZ0NBLmNybDB0BggrBgEF
# BQcBAQRoMGYwPwYIKwYBBQUHMAKGM2h0dHA6Ly9jcnQuc2VjdGlnby5jb20vU2Vj
# dGlnb1JTQVRpbWVTdGFtcGluZ0NBLmNydDAjBggrBgEFBQcwAYYXaHR0cDovL29j
# c3Auc2VjdGlnby5jb20wDQYJKoZIhvcNAQEMBQADggIBAEybZVj64HnP7xXDMm3e
# M5Hrd1ji673LSjx13n6UbcMixwSV32VpYRMM9gye9YkgXsGHxwMkysel8Cbf+Pgx
# ZQ3g621RV6aMhFIIRhwqwt7y2opF87739i7Efu347Wi/elZI6WHlmjl3vL66kWSI
# df9dhRY0J9Ipy//tLdr/vpMM7G2iDczD8W69IZEaIwBSrZfUYngqhHmo1z2sIY9w
# wyR5OpfxDaOjW1PYqwC6WPs1gE9fKHFsGV7Cg3KQruDG2PKZ++q0kmV8B3w1RB2t
# WBhrYvvebMQKqWzTIUZw3C+NdUwjwkHQepY7w0vdzZImdHZcN6CaJJ5OX07Tjw/l
# E09ZRGVLQ2TPSPhnZ7lNv8wNsTow0KE9SK16ZeTs3+AB8LMqSjmswaT5qX010DJA
# oLEZKhghssh9BXEaSyc2quCYHIN158d+S4RDzUP7kJd2KhKsQMFwW5kKQPqAbZRh
# e8huuchnZyRcUI0BIN4H9wHU+C4RzZ2D5fjKJRxEPSflsIZHKgsbhHZ9e2hPjbf3
# E7TtoC3ucw/ZELqdmSx813UfjxDElOZ+JOWVSoiMJ9aFZh35rmR2kehI/shVCu0p
# wx/eOKbAFPsyPfipg2I2yMO+AIccq/pKQhyJA9z1XHxw2V14Tu6fXiDmCWp8Kwij
# SPUV/ARP380hHHrl9Y4a1LlAMYIFgTCCBX0CAQEwgZAwfDELMAkGA1UEBhMCR0Ix
# GzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEY
# MBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJTQSBD
# b2RlIFNpZ25pbmcgQ0ECEBxVdN1Mt+nrMJ+IuERZBAMwCQYFKw4DAhoFAKB4MBgG
# CisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcC
# AQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwIwYJKoZIhvcNAQkEMRYE
# FGjL2IGDKbj4m3/O6Cya3WJwaGP6MA0GCSqGSIb3DQEBAQUABIIBAIlZ09iknHW2
# VJ3xxDny7VyuuopviOEE+jZoGD/wOWqpOV7KeQs+/cU9mhzxEOztD+wP/d+kJLzB
# nSZl9muIpQh1edMmcqB/3fFX2vm0kHuC5Zxu9izL/97RLT0ntebeqsm2BqUN9BRO
# G7hL8rWgJAh3ki7YpopJjTRAP3Tqg+DJmfVUR/flrMaPC6Ymh1LnRgy7cb44Sy3j
# 4aJa3Uls7WL3uXEX5izCO9dpeXKzLhgfyMAqxGdOohJ1NPvicGnmw0NFdsT6QJZ9
# YxIfsq/WFan7qx8u+4Qj6yJyz38ZAOTKD6be4KbmS9EZRtWoHAKwJGbiZMm+x+0e
# NwZxqpthNE+hggNLMIIDRwYJKoZIhvcNAQkGMYIDODCCAzQCAQEwgZEwfTELMAkG
# A1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMH
# U2FsZm9yZDEYMBYGA1UEChMPU2VjdGlnbyBMaW1pdGVkMSUwIwYDVQQDExxTZWN0
# aWdvIFJTQSBUaW1lIFN0YW1waW5nIENBAhA5TCXhfKBtJ6hl4jvZHSLUMA0GCWCG
# SAFlAwQCAgUAoHkwGAYJKoZIhvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0B
# CQUxDxcNMjQwMzE1MjIyNTIzWjA/BgkqhkiG9w0BCQQxMgQwCW+pC55giDWyYuf7
# hHSl2Hw3P4OdNsuCpsNKHFO2+OgwksBEjjJdjNetg+n7/MYyMA0GCSqGSIb3DQEB
# AQUABIICABGzooxJW9ba+2tJ/vhubloaw6Z9ZcnMCnfHTXohlFYYm4QKPB17IlR/
# vq/2h88R/XRcjc7PRKJXf0EoapEzKAW9hrCqFmWiLKmJbV+FULy2Dd7kdnShgBeK
# 7RKXSuBNiEb3pSctYko02O+lB7yNcX7I3A9BcSQinTYiNKwyxDLfy3vdQNgmwiJD
# e2yFnC+fvJF9AfRJ6GtFfEj5h/Tme6OwCCnpZyWskAlsOqpj8So0m2SFFWrzv7fC
# SiLhQwdiSIHNyWCSSFYFavytD8cqRYrxQEALC7R4VAnR3+JsNl5Y8XCw9AkpyDIH
# GSCoLfRJ42GqNuKc5ayGxjPHEIa91rBl7aHC8MyT1oK5F/IsVsGdi//4TbArFaGj
# gXUI+AGDBVI7PQOqx85jLpP5jQwiIEvaJMqAf3VjAL+7t3SHJjjwprKCteOSXavo
# ISsmtjftXZv6+ayrU41W+wzOPCe4z8bsfS1+9eYWHV+VWibaN4N5QAuO3usMIHSl
# MMS13oFgmO0+Xa/n6ORnvSOPBQ/1YgRDTLifhPWbsyi5w0vMdIh0bk99Gis64daE
# 0S5seteHT7kbMbbcb82Xo3ZL6tdx5eC0dmucjoikYEWP6Q6csn+h3ioVu1LdqwQf
# 897uS0NsxtpzzPMbCdDOkN761NfM0AYZbuz4YbyW4q16AY6cJhNO
# SIG # End signature block
