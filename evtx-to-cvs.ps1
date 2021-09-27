param($evtxFile, $cvsOut)

# Write-Host $file.FullName
# $file = "Microsoft-Windows-TaskScheduler%4Operational.evtx"
$output_file = [System.IO.StreamWriter] $($cvsOut)
# $events = get-winevent -path $file.FullName
$events = get-winevent -path $evtxFile

foreach ($Event in $events) { 
	$xml = [xml]($Event.ToXml())

	foreach ($s in $xml.Event.System.ChildNodes) {
		$output_file.Write($s.Name + ":" + $s.InnerText + ",")
	}
	foreach ($d in $xml.Event.EventData.Data) {
		$text = $d.InnerText
		$text = if ($text) { $text.replace("`n","") } else { $text }
		$output_file.Write($d.Name + ":" + $text + ",")
	}
	$output_file.WriteLine()
}

$output_file.Flush()
$output_file.Close()
