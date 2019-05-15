<#------------------------------------------------------------
Gras, Gero | Plass, Dirk
Erstellt am 03.08.2015
Veraendert am 13.09.2016

cmdlet fuer das einheitliche Loging von PowerShell Scripten
------------------------------------------------------------#>

$Global:strFileLog = "C:\_Logs\ps.log"
$Global:intSizeLogSplit = 10485760 #10MB in Byte
$Global:logLevel = "DEB"           #DEB < INFO < WARN < ERR
$Global:logRotated = "10"		   #Anzahl Logfiles

Function write-log()
{
    <#
      .SYNOPSIS
      Schreibt events in das Log
      .DESCRIPTION
      Diese Methode schreibt Logeintraege in eine vorgegebene Log Datei
      .EXAMPLE
      write-log "DEB" "Dies ist ein Debug eintrag"
      .EXAMPLE
      write-log "ERR" Dies ist ein Error eintrag
      .PARAMETER type
      Typ: gibt den Typ des Eintrags an (DEB < INFO < WARN < ERR)
      .PARAMETER msg
      gibt den eigentlichen Logtext an
    #>
    [CmdletBinding()]
    Param([parameter(Position=0)] $type, [parameter(Position=1)] $id, [parameter(Position=2)] $msg)
    #Uhrzeit festlegen
    $time = Get-Date -Format "yyyy-MM-dd hh:mm:ss.fff"  

    Function split-file()
    {
        if(Test-Path $Global:strFileLog)
        {
            #Wenn Log >$Global:intSizeLogSplit wird neue Datei erstellt
            $sizeTMP = get-childitem $Global:strFileLog | select -ExpandProperty Length
            if($sizeTMP -gt $Global:intSizeLogSplit)
            {
                #Filenamen.log vom Verzeichnis trennen
        	    $filenameTMP = $Global:strFileLog.Split("\")
		        $filename = $filenameTMP[$filenameTMP.length -1]
                $filepath = $Global:strFileLog.Replace($filename,"")

                #Altes Logfile Menge > $Global:logRotated löschen
                $directoryentry = (gci $filepath | Where {$_.Name -match $filename} | sort LastWriteTime)
                if ($directoryentry -and ($directoryentry.Count -gt ($Global:logRotated -1)))
                {
                    Remove-Item ($filepath + $directoryentry[0])
                }
                rename-item -path $Global:strFileLog -newname "$(Get-Date -Format 'yyyyMMdd-hhmmssfff')_Arch_$($filename)"
            } 
        }
    }

    Function check-file()
    {
        if(!(Test-Path $Global:strFileLog))
        {
            $dir = Split-Path -Parent $Global:strFileLog
            New-Item -Path $dir -ItemType Directory -ErrorAction SilentlyContinue # | Out-Null
            New-Item $Global:strFileLog -ItemType File 
        }
    }

    switch($type)
    {
        "DEB"
        {
            if($Global:logLevel -eq "DEB")
            {
                split-file
                check-file
                $x = $time + " [DEBUG] [" + $id + "] " + $msg | Out-File -FilePath $Global:strFileLog -Append
            }
            break
        }
        "INFO"
        {
            if($Global:logLevel -eq "DEB" -or $Global:logLevel -eq "INFO")
            {
                split-file
                check-file
                $x = $time + " [INFO] [" + $id + "] " + $msg | Out-File -FilePath $Global:strFileLog -Append
            }
            break
        }
        "WARN"
        {
            if($Global:logLevel -eq "DEB" -or $Global:logLevel -eq "INFO" -or $Global:logLevel -eq "WARN" )
            {
                split-file
                check-file
                $x = $time + " [WARNING] [" + $id + "] " + $msg | Out-File -FilePath $Global:strFileLog -Append
            }
            break
        }
        "ERR"
        {
            split-file
            check-file
            $x = $time + " [ERROR] [" + $id + "] " + $msg | Out-File -FilePath $Global:strFileLog -Append
            break
        }
    }
}

Function write-LogDebug()
{
    <#
      .SYNOPSIS
      Schreibt DEBUG events in das Log
      .DESCRIPTION
      Diese Methode schreibt Debug Logeintraege in eine vorgegebene Log Datei
      .EXAMPLE
      write-LogDebug -ID 1 -Message "Dies ist ein Debug eintrag"
      .PARAMETER ID
      gibt die ID des Logtextes an
      .PARAMETER Message
      gibt den eigentlichen Logtext an
    #>
    Param([parameter(Position=0)][String] $ID, [parameter(Position=1)][String] $Message)
    write-log "DEB" $ID $Message
}

Function write-LogInfo()
{
    <#
      .SYNOPSIS
      Schreibt INFO events in das Log
      .DESCRIPTION
      Diese Methode schreibt Info Logeintraege in eine vorgegebene Log Datei
      .EXAMPLE
      write-LogInfo -ID 1 -Message "Dies ist ein Info eintrag"
      .PARAMETER ID
      gibt die ID des Logtextes an
      .PARAMETER Message
      gibt den eigentlichen Logtext an
    #>
    Param([parameter(Position=0)][String] $ID, [parameter(Position=1)][String] $Message)
    write-log "INFO" $ID $Message
}

Function write-LogWarning()
{
    <#
      .SYNOPSIS
      Schreibt WARNING events in das Log
      .DESCRIPTION
      Diese Methode schreibt Warning Logeintraege in eine vorgegebene Log Datei
      .EXAMPLE
      write-LogWarning -ID 1 -Message "Dies ist ein Warning eintrag"
      .PARAMETER ID
      gibt die ID des Logtextes an
      .PARAMETER Message
      gibt den eigentlichen Logtext an
    #>
    Param([parameter(Position=0)][String] $ID, [parameter(Position=1)][String] $Message)
    write-log "WARN" $ID $Message
}

Function write-LogError()
{
    <#
      .SYNOPSIS
      Schreibt ERROR events in das Log
      .DESCRIPTION
      Diese Methode schreibt Error Logeintraege in eine vorgegebene Log Datei
      .EXAMPLE
      write-LogError -ID 1 -Message "Dies ist ein Error eintrag"
      .PARAMETER ID
      gibt die ID des Logtextes an
      .PARAMETER Message
      gibt den eigentlichen Logtext an
    #>
    Param([parameter(Position=0)][String] $ID, [parameter(Position=1)][String] $Message)
    write-log "ERR" $ID $Message
}

Function set-LogFilePath()
{
    <#
      .SYNOPSIS
      Setzt Pfad für die Logdatei
      .DESCRIPTION
      Diese Methode setzt den Pfad zur Logdatei 
      .EXAMPLE
      set-LogFilePath -Path "C:\_Logs\Log\log.log"
      .PARAMETER Path
      gibt den Pfad zur Logdatei mit Logdatei an
    #>
    Param([parameter(Position=0)][String] $Path)
    $Global:strFileLog = $Path
}

Function set-LogLevel()
{
    <#
      .SYNOPSIS
      Setzt Loglevel
      .DESCRIPTION
      Diese Methode setzt das Loglevel
      .EXAMPLE
      set-LogLevel -Level "DEB"
      .PARAMETER Level
      gibt den Loglevel an DEB < INFO < WARN < ERR
    #>
    Param([parameter(Position=0)][String] $Level)
    $Global:logLevel = $Level
}

Function set-LogSplitSize()
{
    <#
      .SYNOPSIS
      Setzt die Splitgroesse
      .DESCRIPTION
      Diese Methode setzt die groesse, ab wann die Dateien gesplitet werden in Byte
      .EXAMPLE
      set-LogSplitSize -Size 10485760 
      .PARAMETER Size
      groesse der Dateie in Byte
    #>
    Param([parameter(Position=0)][uint32] $Size)
    $Global:intSizeLogSplit = $Size
}

Function set-LogRotate()
{
    <#
      .SYNOPSIS
      Setzt die Anzahl an Logs die Archiviert werden
      .DESCRIPTION
      Diese Methode setzt die Anzahl der zu behaltenden Log Archive. Das älteste wird dann gelöscht
      .EXAMPLE
      set-LogRotate -Count 10 
      .PARAMETER Count
      Anzahl der Logs
    #>
    [CmdletBinding()]
    Param([parameter(Position=0)][uint32] $Count)
    $Global:logRotated = $Count
}


Export-ModuleMember -Function 'write-LogDebug'
Export-ModuleMember -Function 'write-LogInfo'
Export-ModuleMember -Function 'write-LogWarning'
Export-ModuleMember -Function 'write-LogError'
Export-ModuleMember -Function 'set-LogFilePath'
Export-ModuleMember -Function 'set-LogLevel'
Export-ModuleMember -Function 'set-LogSplitSize'
Export-ModuleMember -Function 'set-LogRotate'