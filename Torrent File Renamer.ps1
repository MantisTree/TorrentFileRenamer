<#
Torrent File Renamer.ps1
Copyright (C) 2020  MantisTree

Rename torrent files to the torrent name contained in the torrent file itself.

DOES NOT DEAL WELL WITH BACKTICKS IN FILENAME. If this is you, stop. Get help.

Originally written to rename Synology DownloadStation torrent files, 
which are named 001.torrent 002.torrent,etc

For Synology use cases, uncomment line 57 to prepend original torrent file number to new file name

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

See <http://www.gnu.org/licenses/> to read the GNU General Public License.
#>

$allfiles = gci *.torrent

$ToNatural= { [regex]::Replace($_, '\d+',{$args[0].Value.Padleft(20)})} # Define natural sort method

$allfiles  = $allfiles | Sort-Object $ToNatural

Foreach($ThisFileObject in $allfiles){

    $ThisFilePath = $ThisFileObject.fullname.Replace("[","``[").Replace("]","``]")
    $ThisFilePathEscaped = $ThisFileObject.fullname.Replace("[","``[").Replace("]","``]").Replace('`','```')

    
    $FileContents = Get-Content $ThisFilePath -raw
    
    $searchstring = "4:name"

    $target = ($FileContents | Where-Object {$_.Contains($searchstring)})

    $titleindex = $target.indexof($searchstring)+$searchstring.Length

    $targetlen = $target.Length

    $titlelen = $target.Substring($titleindex,4).split(":")[0]

    $indexofcolon = $target.Substring($titleindex,4).indexof(":")

    $TitleStart = $titleindex + $indexofcolon +1

    $title = $target.Substring($titleStart,$titlelen)

    $EscapedTitle = $title.Replace("""","'").Replace("[","``[").Replace("]","``]")

    while(test-path "$EscapedTitle.torrent"){
        $EscapedTitle = "$EscapedTitle(dupe)"
    }

    $NewFilename = "$EscapedTitle.torrent"
    
    #$NewFilename = "$($ThisFileObject.BaseName.Padleft(5,"0"))-$EscapedTitle.torrent" #Enable for Synlogy numeric torrent files

    $NewFileName = $NewFileName.Replace('`','')

    Write-host "$($ThisFileObject.Name)'s new title is '" -NoNewline
    Write-Host "$NewFilename" -NoNewline -ForegroundColor Yellow
    Write-Host "'"

    Rename-Item $($ThisFileObject.name).replace("\``","``") $NewFilename 
}