# input directory
$target=$Args[0]
# output directory
$output=$Args[1]
$jarfile="converter.jar"

$workDir = Split-Path $MyInvocation.MyCommand.Path
#the directory in which this script resides
cd $workDir

# recursively creates directories in the output directroy 
function prepareDir($output, $target) {
  cd $target
  $dirs= (ls $target -r | 
    ? { !$_.PSIsContainer -and $_.FullName.Contains("\msg\")} | 
    % {split-path -parent $_.FullName } | 
    Get-unique |
    %{Resolve-Path -relative $_} |
    %{Join-Path $output $_})
  cd $workDir
  $dirs | % {mkdir $_ -force} | out-null
}
# returns a conversion script in this script directory
function getScript($before) {
 cd $workDir
 return (split-path -leaf $before | % {$_ -replace "_\d+\.txt" , ".txt"})
}
# resolves the output path
function resolveOutput($before) {
  cd $target
  $rtn = ($before | resolve-path -relative | % {Join-Path $output $_ })
  cd $workDir
  return $rtn
} 

# performs the conversion
function convert($msg) {
  "$($msg.FullName)"
  iex "java -jar $jarfile  --files $($msg.FullName) $(resolveOutput $msg) $(getScript $msg)"
}

prepareDir $output $target

$messages = (ls $target -r |? { $_.FullName.Contains("\msg\") -and ($_.GetType().Name -eq "FileInfo") })

$messages | % { convert $_ }