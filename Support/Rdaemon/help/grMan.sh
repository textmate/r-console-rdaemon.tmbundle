
if [ "$TM_RdaemonRAMDRIVE" == "1" ]; then
	RDRAMDISK="/tmp/TMRramdisk1"
else
	RDRAMDISK="$HOME"/Rdaemon
fi

RDHOME="$HOME/Rdaemon"
[[ ! -d "$HOME"/Rdaemon/plots/tmp ]] && mkdir "$HOME"/Rdaemon/plots/tmp > /dev/null
rm -f "$HOME"/Rdaemon/plots/tmp/*.* > /dev/null

POS=$(stat "$RDRAMDISK"/r_out | awk '{ print $8 }')
echo "@|sink('$RDRAMDISK/r_tmp');.chooseActiveScreenDevice();sink(file=NULL)" > ~/Rdaemon/r_in
POSNEW=$(stat "$RDRAMDISK"/r_out | awk '{ print $8 }')
OFF=$(($POSNEW - $POS + 2))
while [ 1 ]
do
	RES=$(tail -c 2 "$RDRAMDISK"/r_out)
	#expect these things from R
	[[ "$RES" == "> " ]] && break
	[[ "$RES" == "+ " ]] && break
	[[ "$RES" == ": " ]] && break
	#monitoring of the CPU coverage as progress bar
	cpu=$(ps o pcpu -p "$RPID" | tail -n 1)
	[[ "${cpu:0:1}" == "%" ]] && break
	CP=$(echo -n "$cpu" | perl -e 'print 100-<>')
	echo "$CP `tail -n 1 "$RDRAMDISK"/r_out`"
	sleep 0.1
done|CocoaDialog progressbar --title "Rdaemon is busy ..."

cat <<-H1 > "$HOME/Rdaemon/plots/tmp/grMan.html"
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<meta http-equiv="Pragma" content="no-cache">
<meta http-equiv="cache-control" content="no-cache">
<meta http-equiv="expires" content="0">
<title>Graphic Manager</title>
<script type='text/javascript' charset='utf-8'>
function setAct(obj) {
	var id = obj.split('_')[0];
	var index = obj.split('_')[1];
	var plots = document.getElementsByTagName('img');
	var btns = document.getElementsByTagName('button');
	for(var i=0; i<plots.length; i++) {
		plots[i].style.borderColor = '#DDDDDD';
		btns[i].style.visibility = 'visible';
		if(index==i){
			plots[i].style.borderColor = '#FF0000';
			btns[i].style.visibility = 'hidden';
		}
	}
	var cmd = 'echo -e \"@|dev.set(' + id + ')\n\" > \"$HOME/Rdaemon/r_in\"';
	myCommand = TextMate.system(cmd, function(task) { });
}
function closeMe(obj){
	var id = obj.split('_')[0];
	var index = obj.split('_')[1];
	document.getElementById('dev'+id).style.display = 'none';
	var cmd = 'echo -e \"@|dev.off(' + id + ')\n\" > \"$HOME/Rdaemon/r_in\"';
	myCommand = TextMate.system(cmd, function(task) { });

}
function closeAll(){
	var cmd = 'echo -e \"@|graphics.off()\n\" > \"$HOME/Rdaemon/r_in\"';
	myCommand = TextMate.system(cmd, function(task) { });
	window.close();
}
function saveMe(obj){
	var id = obj.split('_')[0];
	var index = obj.split('_')[1];
	var plots = document.getElementsByTagName('img');
	var cmd = "$HOME/Rdaemon/help/savePlotAs.sh '" + plots[index].src + "' " + id;
	myCommand = TextMate.system(cmd, function(task) { });
}
function refresh(){
	var cmd = "$HOME/Rdaemon/help/grMan2.sh";
	myCommand = TextMate.system(cmd, function(task) { });
	myCommand.onreadoutput = output;
}
function output (str) {
	document.getElementById("data").innerHTML = str;
}
</script>
</head>
<body bgcolor=#DDDDDD>
<center>
<div id="data">
H1

OUT=$(cat "$RDRAMDISK/r_tmp")
if [ "${#OUT}" -gt "30" ]; then
	echo "$OUT" | sed 's/^\[1\] "//;s/"$//' >> "$HOME/Rdaemon/plots/tmp/grMan.html"
else
	echo "No Graphic Devices found." && exit 206
fi

cat<<-H2 >> "$HOME/Rdaemon/plots/tmp/grMan.html"
</div>
<hr />
<button onclick='javascript:closeAll()'>Close All Devices</button><br /><br />
<button onclick="javascript:refresh();">&nbsp;&nbsp;Refresh&nbsp;&nbsp;</button>
</body></html>
H2

cat "$HOME"/Rdaemon/plots/tmp/grMan.html
exit 205