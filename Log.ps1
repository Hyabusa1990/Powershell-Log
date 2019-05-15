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
                rename-item -path $Global:strFileLog -newname (Get-Date -Format "yyyyMMdd-hhmmssfff") + "_Arch_" + $filename
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
                $time + " [DEBUG] [" + $id + "] " + $msg | Out-File -FilePath $Global:strFileLog -Append
            }
            break
        }
        "INFO"
        {
            if($Global:logLevel -eq "DEB" -or $Global:logLevel -eq "INFO")
            {
                split-file
                check-file
                $time + " [INFO] [" + $id + "] " + $msg | Out-File -FilePath $Global:strFileLog -Append
            }
            break
        }
        "WARN"
        {
            if($Global:logLevel -eq "DEB" -or $Global:logLevel -eq "INFO" -or $Global:logLevel -eq "WARN" )
            {
                split-file
                check-file
                $time + " [WARNING] [" + $id + "] " + $msg | Out-File -FilePath $Global:strFileLog -Append
            }
            break
        }
        "ERR"
        {
            split-file
            check-file
            $time + " [ERROR] [" + $id + "] " + $msg | Out-File -FilePath $Global:strFileLog -Append
            break
        }
    }
}

Function write-debugLog()
{
    <#
      .SYNOPSIS
      Schreibt DEBUG events in das Log
      .DESCRIPTION
      Diese Methode schreibt Debug Logeintraege in eine vorgegebene Log Datei
      .EXAMPLE
      write-debugLog "Dies ist ein Debug eintrag"
      .PARAMETER msg
      gibt den eigentlichen Logtext an
    #>
    [CmdletBinding()]
    Param([parameter(Position=0)] $id, [parameter(Position=1)] $msg)
    write-log "DEB" $id $msg
}

Function write-infoLog()
{
    <#
      .SYNOPSIS
      Schreibt INFO events in das Log
      .DESCRIPTION
      Diese Methode schreibt Info Logeintraege in eine vorgegebene Log Datei
      .EXAMPLE
      write-infoLog "Dies ist ein Info eintrag"
      .PARAMETER msg
      gibt den eigentlichen Logtext an
    #>
    [CmdletBinding()]
    Param([parameter(Position=0)] $id, [parameter(Position=1)] $msg)
    write-log "INFO" $id $msg
}

Function write-warningLog()
{
    <#
      .SYNOPSIS
      Schreibt WARNING events in das Log
      .DESCRIPTION
      Diese Methode schreibt Warning Logeintraege in eine vorgegebene Log Datei
      .EXAMPLE
      write-warningLog "Dies ist ein Warning eintrag"
      .PARAMETER msg
      gibt den eigentlichen Logtext an
    #>
    [CmdletBinding()]
    Param([parameter(Position=0)] $id, [parameter(Position=1)] $msg)
    write-log "WARN" $id $msg
}

Function write-errorLog()
{
    <#
      .SYNOPSIS
      Schreibt ERROR events in das Log
      .DESCRIPTION
      Diese Methode schreibt Error Logeintraege in eine vorgegebene Log Datei
      .EXAMPLE
      write-errorLog "Dies ist ein Error eintrag"
      .PARAMETER msg
      gibt den eigentlichen Logtext an
    #>
    [CmdletBinding()]
    Param([parameter(Position=0)] $id, [parameter(Position=1)] $msg)
    write-log "ERR" $id $msg
}

Function set-FilePath()
{
    <#
      .SYNOPSIS
      Setzt Pfad für die Logdatei
      .DESCRIPTION
      Diese Methode setzt den Pfad zur Logdatei 
      .EXAMPLE
      set-FilePath "C:\_Logs\Log\log.log"
      .PARAMETER path
      gibt den Pfad zur Logdatei mit Logdatei an
    #>
    #[CmdletBinding()]
    Param([parameter(Position=0)] $path)
    $Global:strFileLog = $path
}

Function set-LogLevel()
{
    <#
      .SYNOPSIS
      Setzt Loglevel
      .DESCRIPTION
      Diese Methode setzt das Loglevel
      .EXAMPLE
      set-LogLevel "DEB"
      .PARAMETER lvl
      gibt den Loglevel an DEB < INFO < WARN < ERR
    #>
   # [CmdletBinding()]
    Param([parameter(Position=0)] $lvl)
    $Global:logLevel = $lvl
}

Function set-splitSize()
{
    <#
      .SYNOPSIS
      Setzt die Splitgroesse
      .DESCRIPTION
      Diese Methode setzt die groesse, ab wann die Dateien gesplitet werden in Byte
      .EXAMPLE
      set-splitSize 10485760 
      .PARAMETER size
      groesse der Dateie in Byte
    #>
    [CmdletBinding()]
    Param([parameter(Position=0)] $size)
    $Global:intSizeLogSplit = $size
}

Function set-LogRotate()
{
    <#
      .SYNOPSIS
      Setzt die Anzahl an Logs die Archiviert werden
      .DESCRIPTION
      Diese Methode setzt die Anzahl der zu behaltenden Log Archive. Das älteste wird dann gelöscht
      .EXAMPLE
      set-LogRotate 10 
      .PARAMETER count
      Anzahl der Logs
    #>
    [CmdletBinding()]
    Param([parameter(Position=0)] $count)
    $Global:logRotated = $count
}