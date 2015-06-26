#v1.0
#Written by nojeffrey(https://github.com/nojeffrey)
#Writes a list of active(if ping successful) AD computers to a text file(C:\AD\ListOfActiveADComputers.txt), and prints some stats to the console.

#Test if C:\AD directory exists, if not create it.
if((Test-Path C:\AD) -eq 0){
    New-Item -ItemType Directory -Path C:\AD | Out-Null
    Write-Host "Created directory C:\AD"}

#Zero out ListOfActiveADComputers.txt if it exists for a fresh start, else touch new file.
if((Test-Path C:\AD\ListOfActiveADComputers.txt) -eq 1){
    Clear-Content C:\AD\ListOfActiveADComputers.txt}
else{
    New-Item -ItemType File C:\AD\ListOfActiveADComputers.txt | Out-Null
    Write-Host "Touched file C:\AD\ListOfActiveADComputers.txt"}


#Get list of AD Computers that contain an IP address(the ones that don't are in 'Disabled Accounts' OU), you can add -ResultSetSize 10 to test first.
$list = Get-ADComputer -Properties Name, IPv4Address -Filter * | Select-Object Name, IPv4Address | where {$_.ipv4address -like “*.*” } 
if($x = "Iterating through " + $list.Count + " ADComputers"){$x}

#Iterate through $list, send 1 ping, if response: write to console in Green and append $_.name to ListOfActiveADComputers.txt, else write to console in Red.
$list | ForEach-Object {
        if (Test-Connection -ComputerName $_.Name -Count 1 -BufferSize 1 -Quiet) {
            Write-Output $_.Name | Out-File C:\AD\ListOfActiveADComputers.txt -Append -Encoding ASCII
            Write-Host $_.Name -ForegroundColor Green}
        
        else {
            Write-Host $_.Name -ForegroundColor Red}
}

#Count active computers.
$count = Get-Content C:\AD\ListOfActiveADComputers.txt | Measure-Object | Select-Object -ExpandProperty Count

#Echo statistics to console.
if ( $totals = "There are a total of " + $list.Count + " AD computers, " + $count + " of those are active and have been written to C:\AD\ListOfActiveADComputers.txt" ) { $totals }